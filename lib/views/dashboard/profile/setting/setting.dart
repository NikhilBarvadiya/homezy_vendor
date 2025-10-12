import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/utils/helper.dart';
import 'package:homezy_vendor/views/dashboard/profile/setting/setting_ctrl.dart';

class Settings extends StatelessWidget {
  Settings({super.key});

  final SettingsCtrl ctrl = Get.put(SettingsCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Settings', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppearanceSection(context),
            const SizedBox(height: 24),
            _buildPreferencesSection(context),
            const SizedBox(height: 24),
            _buildSupportSection(context),
            const SizedBox(height: 24),
            _buildAppSection(context),
            const SizedBox(height: 24),
            _buildAboutSection(context),
            const SizedBox(height: 24),
            _buildAccountSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return _buildSection(context, title: 'Appearance', icon: Icons.palette_outlined, children: [_buildThemeSelector(context)]);
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          _buildSettingItem(
            context,
            icon: ctrl.themeIcon,
            title: 'Theme',
            subtitle: ctrl.currentThemeName,
            trailing: Switch(value: ctrl.isDarkMode.value, onChanged: ctrl.toggleDarkMode, activeColor: Theme.of(context).colorScheme.primary),
            onTap: () => _showThemeSelectionDialog(context),
          ),
          if (ctrl.currentTheme.value == ThemeMode.system) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 48.0),
              child: Text('Follows your device theme settings', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          ],
        ],
      ),
    );
  }

  void _showThemeSelectionDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Select Theme', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(context, title: 'Light Mode', subtitle: 'Always use light theme', icon: Icons.light_mode_outlined, themeMode: ThemeMode.light),
            _buildThemeOption(context, title: 'Dark Mode', subtitle: 'Always use dark theme', icon: Icons.dark_mode_outlined, themeMode: ThemeMode.dark),
            _buildThemeOption(context, title: 'System Default', subtitle: 'Follow system theme', icon: Icons.brightness_auto_outlined, themeMode: ThemeMode.system),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, {required String title, required String subtitle, required IconData icon, required ThemeMode themeMode}) {
    return Obx(() {
      final isSelected = ctrl.currentTheme.value == themeMode;
      return ListTile(
        leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20) : null,
        onTap: () {
          ctrl.changeTheme(themeMode);
          Get.back();
        },
      );
    });
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Preferences',
      icon: Icons.settings_outlined,
      children: [
        _buildSettingItem(
          context,
          icon: Icons.storage_outlined,
          title: 'Storage',
          subtitle: 'Cache: temporary file & unused data are reset',
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onTap: ctrl.clearCache,
        ),
        _buildSettingItem(
          context,
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage your notifications',
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Support & About',
      icon: Icons.help_outline,
      children: [
        _buildSettingItem(
          context,
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'How we handle your data',
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onTap: ctrl.openPrivacyPolicy,
        ),
        _buildSettingItem(
          context,
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          subtitle: 'App usage terms and conditions',
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onTap: ctrl.openTermsOfService,
        ),
        _buildSettingItem(
          context,
          icon: Icons.help_center_outlined,
          title: 'Help & Support',
          subtitle: 'Get help with the app',
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onTap: () => helper.makePhoneCall("+919979066311"),
        ),
        _buildSettingItem(
          context,
          icon: Icons.update_outlined,
          title: 'Check for Updates',
          subtitle: 'Current version: ${ctrl.appVersion}',
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onTap: ctrl.checkForUpdates,
        ),
      ],
    );
  }

  Widget _buildAppSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'App',
      icon: Icons.apps_outlined,
      children: [
        _buildSettingItem(
          context,
          icon: Icons.share_outlined,
          title: 'Share App',
          subtitle: 'Share Homezy Vendor with friends',
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onTap: helper.shareApp,
        ),
        _buildSettingItem(
          context,
          icon: Icons.star_outline,
          title: 'Rate App',
          subtitle: 'Rate us on the app store',
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onTap: ctrl.rateAppWithDialog,
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'About',
      icon: Icons.info_outline,
      children: [
        _buildSettingItem(
          context,
          icon: Icons.phone_android_outlined,
          title: 'App Version',
          subtitle: 'Version ${ctrl.appVersion} (Build ${ctrl.buildNumber})',
          trailing: const SizedBox.shrink(),
          onTap: () {},
        ),
        _buildSettingItem(context, icon: Icons.copyright_outlined, title: 'Copyright', subtitle: '© 2024 Homezy Vendor. All rights reserved.', trailing: const SizedBox.shrink(), onTap: () {}),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Account',
      icon: Icons.account_circle_outlined,
      children: [
        _buildSettingItem(
          context,
          icon: Icons.delete_outline,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.error),
          titleColor: Theme.of(context).colorScheme.error,
          subtitleColor: Theme.of(context).colorScheme.error.withOpacity(0.8),
          onTap: ctrl.deleteAccount,
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
    Color? titleColor,
    Color? subtitleColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        leading: Icon(icon, size: 22, color: titleColor ?? Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: titleColor ?? Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: subtitleColor ?? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(.5))),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
