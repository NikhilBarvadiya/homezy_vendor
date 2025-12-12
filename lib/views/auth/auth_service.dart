import 'package:get/get.dart';
import 'package:homenest_vendor/utils/config/session.dart';
import 'package:homenest_vendor/utils/network/api_index.dart';
import 'package:homenest_vendor/utils/network/api_manager.dart';
import 'package:homenest_vendor/utils/routes/route_name.dart';
import 'package:homenest_vendor/utils/storage.dart';
import 'package:homenest_vendor/utils/toaster.dart';

class AuthService extends GetxService {
  Future<AuthService> init() async => this;
  RxBool isInternetConnected = false.obs;

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
        await write(AppSession.token, response.data["token"]);
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
      await write(AppSession.token, response.data["token"]);
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
        Get.close(1);
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
      final response = await ApiManager().call(APIIndex.updateProfile, request, ApiType.put);
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

  Future<dynamic> setWeeklySlots(dynamic weeklySlots) async {
    try {
      final response = await ApiManager().call(APIIndex.setWeeklySlots, {'weeklySlots': weeklySlots}, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      toaster.success(response.message ?? 'Weekly slots saved successfully');
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> updateAvailability(String day, int index, bool isAvailable) async {
    try {
      final response = await ApiManager().call(APIIndex.updateAvailability, {'day': day, 'slotIndex': index, 'isAvailable': isAvailable}, ApiType.post);
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

  Future<dynamic> weeklySlots() async {
    try {
      final response = await ApiManager().call(APIIndex.weeklySlots, {}, ApiType.post);
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

  Future<dynamic> getVendorDashboard() async {
    try {
      final response = await ApiManager().call(APIIndex.dashboard, {}, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<dynamic> getEarningsDashboard() async {
    try {
      final response = await ApiManager().call(APIIndex.earningsDashboard, {}, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<dynamic> getVendorReviews({required int page, required int limit, int rating = 0}) async {
    try {
      final response = await ApiManager().call(APIIndex.reviews, {'page': page, 'limit': limit, 'rating': rating}, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<dynamic> reviewsRespond({required String reviewId, required String responseText}) async {
    try {
      final response = await ApiManager().call(APIIndex.reviewsRespond, {'reviewId': reviewId, 'responseText': responseText}, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      toaster.success(response.message.toString().capitalizeFirst.toString());
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }
}
