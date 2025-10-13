import 'package:get/get.dart';
import 'package:homezy_vendor/utils/service/chat_service.dart';
import 'package:homezy_vendor/utils/service/location_service.dart';
import 'package:homezy_vendor/utils/service/notification_api_service.dart';
import 'package:homezy_vendor/utils/service/order_service.dart';
import 'package:homezy_vendor/views/auth/auth_service.dart';

Future<void> preload() async {
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => LocationService().init());
  await Get.putAsync(() => ChatService().init());
  await Get.putAsync(() => OrderService().init());
  await Get.putAsync(() => NotificationApiService().init());
}
