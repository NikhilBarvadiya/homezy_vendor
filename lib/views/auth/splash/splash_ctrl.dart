import 'package:get/get.dart';
import 'package:homezy_vendor/utils/storage.dart';
import 'package:homezy_vendor/utils/config/session.dart';
import 'package:homezy_vendor/utils/routes/route_name.dart';

class SplashCtrl extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await read(AppSession.token);
    final isFirstTime = await read(AppSession.isFirstTime) ?? true;
    if (isFirstTime) {
      Get.offAllNamed(AppRouteNames.intro);
    } else if (token == null || token.isEmpty) {
      Get.offAllNamed(AppRouteNames.login);
    } else {
      Get.offAllNamed(AppRouteNames.dashboard);
    }
  }
}
