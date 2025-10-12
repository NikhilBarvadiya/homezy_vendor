import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/utils/helper.dart';
import 'package:homezy_vendor/utils/routes/route_name.dart';
import 'package:homezy_vendor/utils/storage.dart';
import 'package:homezy_vendor/utils/toaster.dart';
import 'package:homezy_vendor/utils/config/session.dart';
import 'package:homezy_vendor/views/auth/splash/splash_ctrl.dart';
import 'package:homezy_vendor/views/dashboard/profile/setting/ui/privacy_policy.dart';
import 'package:homezy_vendor/views/dashboard/profile/setting/ui/terms_of_service.dart';
import 'package:new_version_plus/new_version_plus.dart';

class SettingsCtrl extends GetxController {
  final Rx<ThemeMode> currentTheme = ThemeMode.system.obs;
  final RxBool isDarkMode = false.obs;

  final String appVersion = '1.0.0', buildNumber = '1';

  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    final themePreference = await read(AppSession.themeMode) ?? 'system';
    switch (themePreference) {
      case 'dark':
        currentTheme.value = ThemeMode.dark;
        isDarkMode.value = true;
        break;
      case 'light':
        currentTheme.value = ThemeMode.light;
        isDarkMode.value = false;
        break;
      default:
        currentTheme.value = ThemeMode.system;
        isDarkMode.value = Get.isPlatformDarkMode;
    }
    _applyTheme();
  }

  void changeTheme(ThemeMode themeMode) async {
    currentTheme.value = themeMode;
    switch (themeMode) {
      case ThemeMode.dark:
        isDarkMode.value = true;
        await write(AppSession.themeMode, 'dark');
        break;
      case ThemeMode.light:
        isDarkMode.value = false;
        await write(AppSession.themeMode, 'light');
        break;
      case ThemeMode.system:
        isDarkMode.value = Get.isPlatformDarkMode;
        await write(AppSession.themeMode, 'system');
        break;
    }

    _applyTheme();
    toaster.success('Theme updated successfully');
  }

  void _applyTheme() => Get.changeThemeMode(currentTheme.value);

  void toggleDarkMode(bool value) {
    if (value) {
      changeTheme(ThemeMode.dark);
    } else {
      changeTheme(ThemeMode.light);
    }
  }

  String get currentThemeName {
    switch (currentTheme.value) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  IconData get themeIcon {
    switch (currentTheme.value) {
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  void rateAppWithDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Rate Our App', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [for (int i = 0; i < 5; i++) Icon(Icons.star_rate_rounded, size: 40, color: Colors.amber)],
            ),
            const SizedBox(height: 16),
            Text('If you enjoy using Homezy Vendor, would you mind taking a moment to rate it? It won\'t take more than a minute.', textAlign: TextAlign.center, style: Get.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              'Thanks for your support!',
              textAlign: TextAlign.center,
              style: Get.textTheme.bodySmall?.copyWith(color: Get.theme.colorScheme.primary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Not Now', style: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              helper.ratingApp();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star, size: 18), const SizedBox(width: 6), Text('Rate Now')]),
          ),
        ],
      ),
    );
  }

  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Delete Account',
          style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Get.theme.colorScheme.error),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete your account? This action cannot be undone.', style: Get.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text('All your data including:', style: Get.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildDeleteItem('Profile information'),
            _buildDeleteItem('Business details'),
            _buildDeleteItem('Service history'),
            _buildDeleteItem('Bank account details'),
            _buildDeleteItem('All uploaded documents'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: _confirmDeleteAccount,
            style: ElevatedButton.styleFrom(backgroundColor: Get.theme.colorScheme.error, foregroundColor: Get.theme.colorScheme.onError),
            child: Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.remove, size: 16, color: Get.theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Get.textTheme.bodySmall?.copyWith(color: Get.theme.colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() async {
    try {
      Get.back();
      await clearStorage();
      Get.offNamedUntil(AppRouteNames.splash, (Route<dynamic> route) => false);
      Get.put(SplashCtrl(), permanent: true).onReady();
      toaster.success('Account deleted successfully');
    } catch (e) {
      toaster.error('Error: $e');
    }
  }

  void openPrivacyPolicy() => Get.to(() => PrivacyPolicy());

  void openTermsOfService() => Get.to(() => TermsOfService());

  void clearCache() async {
    Get.dialog(
      AlertDialog(
        title: Text('Clear Cache', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        content: Text('This will clear all cached data including images and temporary files. This action cannot be undone.', style: Get.textTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Get.theme.colorScheme.primaryContainer, foregroundColor: Get.theme.colorScheme.onPrimaryContainer),
            onPressed: _performClearCache,
            child: Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _performClearCache() async {
    try {
      Get.back();
      await clearStorage();
      Get.offNamedUntil(AppRouteNames.splash, (Route<dynamic> route) => false);
      Get.put(SplashCtrl(), permanent: true).onReady();
      toaster.success('Cache cleared successfully');
    } catch (e) {
      toaster.error('Failed to clear cache: $e');
    }
  }

  void checkForUpdates() async {
    try {
      NewVersionPlus newVersion = NewVersionPlus();
      final status = await newVersion.getVersionStatus();
      if (status != null && status.canUpdate) {
        newVersion.showUpdateDialog(
          context: Get.context!,
          versionStatus: status,
          dialogTitle: 'Update Available',
          dialogText: 'A new version of the app is available. Please update to continue.',
          updateButtonText: 'Update',
          allowDismissal: false,
        );
      } else {
        toaster.info("No update available");
      }
    } catch (e) {
      toaster.error('Failed to verify version checker: $e');
    }
  }
}
