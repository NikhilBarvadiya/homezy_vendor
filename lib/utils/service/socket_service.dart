import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/utils/config/app_config.dart';
import 'package:homezy_vendor/utils/network/api_config.dart';
import 'package:homezy_vendor/utils/service/notification_service.dart';
import 'package:homezy_vendor/views/dashboard/chat/chat_ctrl.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:vibration/vibration.dart';

class SocketService extends GetxController {
  late Socket socket;
  AudioPlayer player = AudioPlayer();

  _whistle(String sound) async {
    Vibration.vibrate(pattern: [150, 200, 300, 200, 150]);
    await player.setSource(AssetSource(sound)).then((value) {
      player.play(AssetSource(sound));
    });
    player.onPlayerStateChanged.listen((PlayerState s) async {
      if (s == PlayerState.completed) {
        await player.pause();
      }
    });
  }

  void connectToServer(String token, dynamic userData) {
    try {
      socket = io(APIConfig.socketURL, OptionBuilder().setTransports(['websocket']).enableAutoConnect().setAuth({'token': token}).build());
      socket.connect();
      final userId = userData["_id"]?.toString() ?? 'unknown';
      socket.onConnect((_) {
        log("Connected with socket channel (ID: ${socket.id})");
      });

      socket.on('vendor_admin_message_received', (data) async {
        log("Received notification by server 'vendor_admin_message_received'");
        if (data != null && data != '') {
          if (data["message"]['vendorId'] == userId) {
            if (Get.isRegistered<ChatCtrl>()) {
              ChatCtrl chatCtrl = Get.find();
              await chatCtrl.onNewDataUpdate(data["message"]);
              await chatCtrl.markAsRead(data["message"]["sender"]['_id'].toString(), messageId: data["message"]['_id'].toString());
            }
            _whistle("slow_spring_board.mp3");
            notificationService.createNotificationChat(AppConfig.appName, data['message']?['message'] ?? "No mention", data['sender']?['name'] ?? "Guest user");
          }
        }
      });

      socket.on('support_message_received', (data) async {
        log("Received notification by server 'support_message_received'");
        if (data != null && data != '') {
          if (data["message"]['vendorId'] == userId) {
            if (Get.isRegistered<ChatCtrl>()) {
              ChatCtrl chatCtrl = Get.find();
              await chatCtrl.markAsRead(data["message"]["sender"]['_id'].toString(), messageId: data["message"]['_id'].toString());
            }
            _whistle("slow_spring_board.mp3");
            notificationService.createNotificationChat(AppConfig.appName, data['message']?['message'] ?? "No mention", data['sender']?['name'] ?? "Guest user");
          }
        }
      });

      socket.onDisconnect((_) => log('disconnect'));
    } catch (e) {
      log(e.toString());
    }
  }
}

SocketService socketService = SocketService();
