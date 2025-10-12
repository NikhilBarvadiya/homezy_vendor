import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/utils/helper.dart';
import 'package:homezy_vendor/utils/service/notification_service.dart';
import 'package:homezy_vendor/utils/routes/route_name.dart';
import 'package:homezy_vendor/utils/toaster.dart';
import 'package:homezy_vendor/views/auth/auth_service.dart';

class LoginCtrl extends GetxController {
  AuthService get _apiService => Get.find<AuthService>();
  final TextEditingController phoneController = TextEditingController();
  final RxBool isLoading = false.obs;

  Future<void> login() async {
    if (helper.isMobileValidation(phoneController.text) != true) {
      toaster.error('Please enter a valid 10-digit phone number');
      return;
    }
    try {
      isLoading(true);
      String? fcmToken = await notificationService.getToken();
      String? deviceId = await helper.getDeviceUniqueId();
      await _apiService.login({'phone': phoneController.text, 'fcmToken': fcmToken, 'deviceId': deviceId});
    } catch (e) {
      toaster.error('Login failed: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void goToRegister() => Get.toNamed(AppRouteNames.register);
}
