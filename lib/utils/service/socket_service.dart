import 'dart:convert';
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

  void connectToServer(dynamic userData) {
    try {
      socket = io(APIConfig.socketURL, OptionBuilder().setTransports(['websocket']).enableAutoConnect().build());
      socket.connect();
      final userId = userData["_id"]?.toString() ?? 'unknown';
      socket.onConnect((_) {
        log("Connected with socket channel");
        socket.emit('joinRoom', {"userType": "vendor", "userId": userId});
      });

      socket.on('on_new_chat_data', (data) async {
        log("Received notification by server 'on_new_chat_data'");
        if (data != null && data != '') {
          data = jsonDecode(data);
          log(data);
          if (data["id"] == userId) {
            if (Get.isRegistered<ChatCtrl>()) {
              ChatCtrl chatCtrl = Get.find();
              await chatCtrl.onNewDataUpdate();
            }
            _whistle("slow_spring_board.mp3");
            notificationService.createNotificationChat(AppConfig.appName, data['text'], data['name']);
          }
        }
      });

      socket.on('on_message_seen', (data) async {
        log("Received notification by server 'on_message_seen'");
        if (data != null && data != '') {
          data = jsonDecode(data);
          log(data);
          if (Get.isRegistered<ChatCtrl>()) {
            ChatCtrl chatCtrl = Get.find();
            await chatCtrl.markAsRead("adminId", messageId: data["messageId"]);
          }
          _whistle("slow_spring_board.mp3");
          notificationService.createNotificationChat(AppConfig.appName, data['text'], data['name']);
        }
      });

      socket.onDisconnect((_) => log('disconnect'));
    } catch (e) {
      log(e.toString());
    }
  }
}

SocketService socketService = SocketService();
