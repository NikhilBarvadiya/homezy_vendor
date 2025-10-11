import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/utils/helper.dart';
import 'package:homezy_vendor/utils/service/notification_service.dart';
import 'package:homezy_vendor/utils/toaster.dart';
import 'package:homezy_vendor/views/auth/auth_service.dart';

class OtpCtrl extends GetxController {
  AuthService get _authService => Get.find<AuthService>();
  final TextEditingController otpController = TextEditingController();
  final RxBool isLoading = false.obs, canResend = false.obs;
  final RxString otp = ''.obs;
  final RxInt timerCount = 60.obs;
  late String phoneNumber;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void onOtpChanged(String value) {
    otp.value = value;
    if (value.length == 6) {
      verifyOtp();
    }
  }

  Future<void> verifyOtp() async {
    if (otp.value.length != 4) {
      toaster.error('Please enter 4-digit OTP');
      return;
    }
    try {
      isLoading(true);
      String? fcmToken = await notificationService.getToken();
      String? deviceId = await helper.getDeviceUniqueId();
      await _authService.verifyOtp({'phone': phoneNumber, 'otpCode': otp.value, 'fcm': fcmToken, 'deviceId': deviceId});
    } catch (e) {
      toaster.error('Verification failed: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> resendOtp() async {
    if (!canResend.value) return;
    try {
      await _authService.resendOtp({'phone': phoneNumber});
      toaster.success('OTP sent successfully');
      startTimer();
    } catch (e) {
      toaster.error('Failed to resend OTP: ${e.toString()}');
    }
  }

  void startTimer() {
    canResend(false);
    timerCount(60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerCount.value > 0) {
        timerCount(timerCount.value - 1);
      } else {
        canResend(true);
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    super.onClose();
  }
}
