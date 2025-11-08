import 'package:get/get.dart';
import 'package:homezy_vendor/utils/storage.dart';
import 'package:homezy_vendor/utils/config/session.dart';
import 'package:homezy_vendor/utils/routes/route_name.dart';
import 'package:new_version_plus/new_version_plus.dart';

class SplashCtrl extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    // await _checkAuthStatus();
    await _checkVersion();
  }

  Future<void> _checkVersion() async {
    final newVersion = NewVersionPlus();

    final status = await newVersion.getVersionStatus();

    if (status != null && status.canUpdate) {
      newVersion.showUpdateDialog(
        context: Get.context!,
        versionStatus: status,
        dialogTitle: 'Update Available',
        dialogText: 'A new version of the app is available. Please update to continue.',
        updateButtonText: 'Update Now',
        allowDismissal: false,
      );
    } else {
      _checkAuthStatus();
    }
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
