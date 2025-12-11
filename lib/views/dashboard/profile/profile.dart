import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:homenest_vendor/utils/network/api_config.dart';
import 'package:homenest_vendor/utils/routes/route_name.dart';
import 'package:homenest_vendor/utils/storage.dart';
import 'package:homenest_vendor/views/dashboard/profile/setting/setting.dart';
import 'package:homenest_vendor/views/dashboard/profile/ui/edit_profile.dart';
import 'package:homenest_vendor/views/dashboard/profile/profile_ctrl.dart';
import 'package:homenest_vendor/views/dashboard/profile/ui/profile_details.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  final ProfileCtrl ctrl = Get.put(ProfileCtrl());

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Obx(() {
            if (ctrl.isLoading.value) {
              return _buildLoadingState(context);
            }
            return RefreshIndicator(
              onRefresh: () async => await ctrl.loadProfileData(),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(context),
                  _buildProfileHeader(context),
                  _buildQuickStats(context),
                  _buildProfessionalSummary(context),
                  _buildBankSummary(context),
                  _buildPersonalInfoSection(context),
                  _buildBusinessInfoSection(context),
                  if (!isKeyboardVisible) _buildActionButtons(context),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text('Loading Profile...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 1,
      pinned: true,
      title: Text('My Profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      actions: [
        IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
          ),
          icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Get.to(() => EditProfile()),
        ),
        IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
          ),
          icon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Get.to(() => ProfileDetails()),
        ),
        SizedBox(width: 8.0),
      ],
    );
  }

  SliverToBoxAdapter _buildProfileHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).colorScheme.primary.withOpacity(0.05), Theme.of(context).colorScheme.secondary.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        ),
        child: Row(
          children: [
            _buildProfileAvatar(context),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ctrl.vendorName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ctrl.businessName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(children: [_buildStatusChip(context), const SizedBox(width: 8), _buildRatingChip(context)]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          final imageFile = ctrl.selectedImage.value;
          final imageUrl = ctrl.profileImage;
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primaryContainer,
              image: imageFile != null
                  ? DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover)
                  : imageUrl.isNotEmpty
                  ? DecorationImage(image: NetworkImage(APIConfig.resourceBaseURL + imageUrl), fit: BoxFit.cover)
                  : null,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: imageFile == null && imageUrl.isEmpty ? Icon(Icons.person, size: 32, color: Theme.of(context).colorScheme.onPrimaryContainer) : null,
          );
        }),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: ctrl.pickProfileImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Icon(Icons.camera_alt, size: 14, color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ctrl.isVerified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ctrl.isVerified ? Colors.green : Colors.orange, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ctrl.isVerified ? Icons.verified : Icons.pending, size: 14, color: ctrl.isVerified ? Colors.green : Colors.orange),
          const SizedBox(width: 4),
          Text(
            ctrl.isVerified ? 'Verified' : 'Pending',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: ctrl.isVerified ? Colors.green : Colors.orange, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: Theme.of(context).colorScheme.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            ctrl.rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildQuickStats(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, value: ctrl.completedJobs.toString(), label: 'Completed Jobs', icon: Icons.work_history_outlined),
            _buildStatItem(context, value: ctrl.status, label: 'Profile Status', icon: Icons.verified_user_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required String value, required String label, required IconData icon}) {
    return Column(
      spacing: 8.0,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildProfessionalSummary(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Professional Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(Icons.work_outline, color: Theme.of(context).colorScheme.primary),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (ctrl.experience > 0) _buildSkillChip(context, '${ctrl.experience} Years Exp'),
                ...ctrl.skills.take(4).map((skill) => _buildSkillChip(context, skill)),
                if (ctrl.skills.length > 4) _buildSkillChip(context, '+${ctrl.skills.length - 4} more'),
              ],
            ),
            if (ctrl.certifications.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Certifications: ${ctrl.certifications.length}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildBankSummary(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance_outlined, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bank Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    ctrl.hasBankDetails ? 'Account linked • ${ctrl.bankName}' : 'Bank account not added',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(BuildContext context, String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Text(
        skill,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
      ),
    );
  }

  SliverToBoxAdapter _buildPersonalInfoSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Personal Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary, size: 20),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(context, 'Name', ctrl.vendorName, Icons.person),
            _buildInfoRow(context, 'Email', ctrl.email, Icons.email),
            _buildInfoRow(context, 'Phone', ctrl.phone, Icons.phone),
            _buildInfoRow(context, 'Member Since', _formatDate(ctrl.joinDate), Icons.calendar_today, isNonDivider: true),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildBusinessInfoSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Business Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(Icons.business_center_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(context, 'Business Name', ctrl.businessName, Icons.business),
            _buildInfoRow(context, 'Address', ctrl.address.isNotEmpty ? ctrl.address : 'Not provided', Icons.location_on),
            _buildInfoRow(context, 'Description', ctrl.businessDescription.isNotEmpty ? ctrl.businessDescription : 'No description added', Icons.description, isNonDivider: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String value, IconData icon, {bool? isNonDivider}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(.5)),
                ),
                if (isNonDivider != true) ...[const SizedBox(height: 8), Divider(height: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.3))],
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildActionButtons(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          children: [
            _buildActionButton(context, icon: Icons.edit_outlined, title: 'Edit Profile', subtitle: 'Update your personal information', onTap: () => Get.to(() => EditProfile())),
            _buildActionButton(context, icon: Icons.visibility_outlined, title: 'View Full Profile', subtitle: 'See all your details', onTap: () => Get.to(() => ProfileDetails())),
            _buildActionButton(context, icon: Icons.settings_outlined, title: 'Settings', subtitle: 'App preferences and settings', onTap: () => Get.to(() => Settings())),
            _buildActionButton(context, icon: Icons.logout_outlined, title: 'Logout', subtitle: 'Sign out from your account', onTap: _showLogoutDialog, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap, bool isDestructive = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        leading: Icon(icon, color: isDestructive ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDestructive ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(.5))),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Logout', style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to logout?', style: Get.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () async {
              await clearStorage();
              Get.back();
              Get.offAllNamed(AppRouteNames.login);
            },
            child: Text('Logout', style: TextStyle(color: Get.theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return 'Not available';
    try {
      final parsedDate = DateTime.tryParse(date);
      if (parsedDate == null) return date;
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }
}
