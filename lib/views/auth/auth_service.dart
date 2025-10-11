import 'package:get/get.dart';
import 'package:homezy_vendor/utils/config/session.dart';
import 'package:homezy_vendor/utils/network/api_index.dart';
import 'package:homezy_vendor/utils/network/api_manager.dart';
import 'package:homezy_vendor/utils/routes/route_name.dart';
import 'package:homezy_vendor/utils/storage.dart';
import 'package:homezy_vendor/utils/toaster.dart';

class AuthService extends GetxService {
  Future<AuthService> init() async => this;

  Future<void> login(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.login, request, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      if (response.data["requiresVerification"] == true) {
        Get.toNamed(AppRouteNames.otp, arguments: request["phone"].toString());
      } else {
        await write(AppSession.token, response.data["accessToken"]);
        await write(AppSession.userData, response.data["vendor"]);
        Get.toNamed(AppRouteNames.dashboard);
        toaster.success('Login successful');
      }
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<void> verifyOtp(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.verifyOtp, request, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Invalid OTP');
        return;
      }
      await write(AppSession.token, response.data["accessToken"]);
      await write(AppSession.userData, response.data["vendor"]);
      Get.offAllNamed(AppRouteNames.dashboard);
      toaster.success('Login successful');
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<void> resendOtp(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.resendOtp, request, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Failed to resend OTP');
        return;
      }
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<void> register(dynamic request) async {
    try {
      final response = await ApiManager().call(APIIndex.register, request, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      if (response.data["isVerified"] != true) {
        Get.toNamed(AppRouteNames.otp, arguments: request["phone"].toString());
      } else {
        Get.back();
      }
      toaster.success(response.message.toString().capitalizeFirst.toString());
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> getProfile() async {
    try {
      final response = await ApiManager().call(APIIndex.getProfile, {}, ApiType.get);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> updateProfile(dynamic request) async {
    try {
      final response = await ApiManager().call(APIIndex.updateProfile, request, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }
}
