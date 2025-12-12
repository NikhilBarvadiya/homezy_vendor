import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homenest_vendor/utils/network/api_config.dart';
import 'package:homenest_vendor/utils/routes/route_name.dart';
import 'package:homenest_vendor/utils/storage.dart';
import 'package:homenest_vendor/views/dashboard/profile/setting/setting.dart';
import 'package:homenest_vendor/views/dashboard/profile/setting/slots/slots.dart';
import 'package:homenest_vendor/views/dashboard/profile/ui/edit_profile.dart';
import 'package:homenest_vendor/views/dashboard/profile/profile_ctrl.dart';
import 'package:homenest_vendor/views/dashboard/profile/ui/shimmer_ui.dart';
import 'package:homenest_vendor/views/dashboard/profile/ui/theme_toggle_ui.dart';

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
                  _buildBusinessInfoSection(context),
                  _buildProfessionalInfoSection(context),
                  _buildBankInfoSection(context),
                  _buildDocumentsSection(context),
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
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 1,
          pinned: true,
          title: Text('My Profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          actions: [Padding(padding: const EdgeInsets.only(right: 16), child: ShimmerWidget.circular(width: 40, height: 40))],
        ),
        SliverToBoxAdapter(child: ShimmerProfileHeader()),
        SliverToBoxAdapter(child: ShimmerExpandableCard()),
        SliverToBoxAdapter(child: ShimmerExpandableCard()),
        SliverToBoxAdapter(child: ShimmerExpandableCard()),
        SliverToBoxAdapter(child: ShimmerExpandableCard()),
        SliverToBoxAdapter(child: Column(children: List.generate(3, (index) => ShimmerActionButton()))),
      ],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 1,
      pinned: true,
      automaticallyImplyLeading: false,
      title: Text(
        'My Profile',
        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
      ),
      actions: [
        IconButton(
          tooltip: 'Edit Profile',
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary.withOpacity(.06)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
          ),
          icon: Icon(FeatherIcons.edit3, color: Theme.of(context).colorScheme.primary, size: 18),
          onPressed: () => Get.to(() => EditProfile()),
        ),
        IconButton(
          tooltip: 'Manage Slots',
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary.withOpacity(.06)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
          ),
          icon: Icon(FeatherIcons.clock, color: Theme.of(context).colorScheme.primary, size: 18),
          onPressed: () => Get.to(() => SlotManagement()),
        ),
        ThemeToggleUI(),
        const SizedBox(width: 8.0),
      ],
    );
  }

  SliverToBoxAdapter _buildProfileHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileAvatar(context),
            const SizedBox(height: 16),
            Text(
              ctrl.vendorName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              ctrl.businessName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [_buildStatusChip(context), const SizedBox(width: 8), _buildRatingChip(context), const SizedBox(width: 8), if (ctrl.experience > 0) _buildExperienceChip(context)],
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
            width: 100,
            height: 100,
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
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, color: ctrl.isVerified ? Colors.green : Colors.orange, fontWeight: FontWeight.w600),
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
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, color: Theme.of(context).colorScheme.onSecondaryContainer, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.work_history, size: 14, color: Theme.of(context).colorScheme.onTertiaryContainer),
          const SizedBox(width: 4),
          Text(
            '${ctrl.experience} yrs',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, color: Theme.of(context).colorScheme.onTertiaryContainer, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildBusinessInfoSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        return _buildExpandableInfoCard(
          context,
          title: 'Business Information',
          icon: Icons.business_center_outlined,
          isExpanded: ctrl.isBusinessInfoExpanded.value,
          onToggle: () => ctrl.isBusinessInfoExpanded.toggle(),
          children: [
            Divider(),
            SizedBox(height: 10),
            _buildInfoRow(context, 'Business Name', ctrl.businessName, Icons.storefront_outlined),
            _buildInfoRow(context, 'Description', ctrl.businessDescription.isNotEmpty ? ctrl.businessDescription : 'No description added', Icons.description_outlined),
            _buildInfoRow(context, 'Address', ctrl.address.isNotEmpty ? ctrl.address : 'Not provided', Icons.location_on_outlined),
            _buildInfoRow(context, 'City/State', '${ctrl.city}, ${ctrl.state}', Icons.map_outlined, isNonDivider: true),
          ],
        );
      }),
    );
  }

  SliverToBoxAdapter _buildProfessionalInfoSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        return _buildExpandableInfoCard(
          context,
          title: 'Professional Information',
          icon: Icons.work_outline,
          isExpanded: ctrl.isProfessionalInfoExpanded.value,
          onToggle: () => ctrl.isProfessionalInfoExpanded.toggle(),
          children: [
            Divider(),
            SizedBox(height: 10),
            _buildInfoRow(context, 'Experience', '${ctrl.experience} years', Icons.timeline_outlined),
            if (ctrl.skills.isNotEmpty) ...[_buildSkillsSection(context), SizedBox(height: 8)],
            _buildInfoRow(context, 'Completed Jobs', '${ctrl.completedJobs}', Icons.check_circle_outline),
            _buildInfoRow(context, 'Account Status', ctrl.status, Icons.account_circle_outlined, isNonDivider: true),
          ],
        );
      }),
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ctrl.skills.map((skill) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Text(
                skill,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  SliverToBoxAdapter _buildBankInfoSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        return _buildExpandableInfoCard(
          context,
          title: 'Bank Details',
          icon: Icons.account_balance_outlined,
          isExpanded: ctrl.isBankInfoExpanded.value,
          onToggle: () => ctrl.isBankInfoExpanded.toggle(),
          children: [
            Divider(),
            SizedBox(height: 10),
            if (ctrl.hasBankDetails) ...[
              _buildInfoRow(context, 'Bank Name', ctrl.bankName, Icons.account_balance_outlined),
              _buildInfoRow(context, 'Account Holder', ctrl.accountHolderName, Icons.person_outline),
              _buildInfoRow(context, 'Account Number', ctrl.accountNumber, Icons.numbers_outlined),
              _buildInfoRow(context, 'IFSC Code', ctrl.ifscCode, Icons.code_outlined),
              _buildInfoRow(context, 'Account Status', 'Linked ✓', Icons.check_circle_outline, valueColor: Colors.green, isNonDivider: true),
            ] else ...[
              _buildEmptyState(context, title: 'No Bank Details', subtitle: 'Add your bank account to receive payments', icon: Icons.account_balance_wallet_outlined),
            ],
          ],
        );
      }),
    );
  }

  SliverToBoxAdapter _buildDocumentsSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        return _buildExpandableInfoCard(
          context,
          title: 'Documents',
          icon: Icons.folder_outlined,
          isExpanded: ctrl.isDocumentsExpanded.value,
          onToggle: () => ctrl.isDocumentsExpanded.toggle(),
          children: [
            Divider(),
            SizedBox(height: 10),
            _buildDocumentStatus(context, title: 'Profile Photo', isUploaded: ctrl.profileImage.isNotEmpty),
            _buildDocumentStatus(context, title: 'Business Logo', isUploaded: ctrl.businessLogo.isNotEmpty),
            _buildDocumentStatus(context, title: 'Aadhaar Card', isUploaded: ctrl.aadhaarFront.isNotEmpty && ctrl.aadhaarBack.isNotEmpty),
            _buildDocumentStatus(context, title: 'PAN Card', isUploaded: ctrl.panImage.isNotEmpty),
            _buildDocumentStatus(context, title: 'Business Banner', isUploaded: ctrl.businessBanner.isNotEmpty, isNonDivider: true),
          ],
        );
      }),
    );
  }

  Widget _buildExpandableInfoCard(BuildContext context, {required String title, required IconData icon, required List<Widget> children, required bool isExpanded, required VoidCallback onToggle}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 20, top: 20, bottom: 8),
            child: Column(
              spacing: 12.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: isExpanded ? Column(children: children) : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String value, IconData icon, {Color? valueColor, bool? isNonDivider}) {
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'Not provided',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: valueColor ?? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(.5)),
                ),
                if (isNonDivider != true) ...[const SizedBox(height: 8), Divider(height: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.3))],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStatus(BuildContext context, {required String title, required bool isUploaded, bool isNonDivider = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(isUploaded ? Icons.check_circle : Icons.error_outline, size: 20, color: isUploaded ? Colors.green : Colors.orange),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyMedium)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: isUploaded ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(isUploaded ? 'Uploaded' : 'Pending', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isUploaded ? Colors.green : Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required String title, required String subtitle, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildActionButtons(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            _buildActionButton(context, icon: Icons.settings_outlined, title: 'Settings', subtitle: 'App preferences and settings', onTap: () => Get.to(() => Settings())),
            _buildActionButton(context, icon: Icons.logout_outlined, title: 'Logout', subtitle: 'Sign out from your account', onTap: _showLogoutDialog, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap, bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
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
}
