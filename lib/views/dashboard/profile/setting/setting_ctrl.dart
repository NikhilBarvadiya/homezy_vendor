import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homenest_vendor/utils/helper.dart';
import 'package:homenest_vendor/utils/routes/route_name.dart';
import 'package:homenest_vendor/utils/storage.dart';
import 'package:homenest_vendor/utils/toaster.dart';
import 'package:homenest_vendor/views/auth/splash/splash_ctrl.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsCtrl extends GetxController {
  final String appVersion = '1.0.0', buildNumber = '1';

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
            Text('If you enjoy using Homenest Vendor, would you mind taking a moment to rate it? It won\'t take more than a minute.', textAlign: TextAlign.center, style: Get.textTheme.bodyMedium),
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
            onPressed: () => Get.close(1),
            child: Text('Not Now', style: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.close(1);
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
            onPressed: () => Get.close(1),
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
      Get.close(1);
      final url = "https://itfuturz.in/support/HomeNest_Vendor_Delete.html";
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await clearStorage();
      Get.offNamedUntil(AppRouteNames.splash, (route) => false);
      Get.put(SplashCtrl(), permanent: true).onReady();
      toaster.success('Account deleted successfully');
    } catch (e) {
      toaster.error('Error: $e');
    }
  }

  Future<void> openPrivacyPolicy() async {
    try {
      final url = "https://sites.google.com/view/homenest-service-partner-priva/home";
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      toaster.error('Error: $e');
    }
  }

  void openTermsOfService() async {
    try {
      final url = "https://itfuturz.in/support/HomeNest_Vendor_Support.html";
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      toaster.error('Error: $e');
    }
  }
}
