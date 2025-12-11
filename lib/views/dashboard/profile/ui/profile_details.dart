import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homenest_vendor/views/dashboard/profile/profile_ctrl.dart';

class ProfileDetails extends StatelessWidget {
  ProfileDetails({super.key});

  final ProfileCtrl ctrl = Get.find<ProfileCtrl>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: Text('Complete Profile Details'), backgroundColor: Theme.of(context).colorScheme.surface, elevation: 0),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPersonalDetailsSection(context),
              const SizedBox(height: 20),
              _buildBusinessDetailsSection(context),
              const SizedBox(height: 20),
              _buildProfessionalInfoSection(context),
              const SizedBox(height: 20),
              _buildAddressSection(context),
              const SizedBox(height: 20),
              _buildBankDetailsSection(context),
              const SizedBox(height: 20),
              _buildDocumentsSection(context),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPersonalDetailsSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        _buildDetailItem(context, 'Full Name', ctrl.vendorName),
        _buildDetailItem(context, 'Email Address', ctrl.email),
        _buildDetailItem(context, 'Phone Number', ctrl.phone),
        _buildDetailItem(context, 'Member Since', _formatDate(ctrl.joinDate)),
        _buildDetailItem(context, 'Verification Status', ctrl.isVerified ? 'Verified' : 'Pending Verification', isNonDivider: true),
      ],
    );
  }

  Widget _buildBusinessDetailsSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Business Information',
      icon: Icons.business_center_outlined,
      children: [
        _buildDetailItem(context, 'Business Name', ctrl.businessName),
        _buildDetailItem(context, 'Business Description', ctrl.businessDescription.isNotEmpty ? ctrl.businessDescription : 'No description provided', isNonDivider: true),
      ],
    );
  }

  Widget _buildProfessionalInfoSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Professional Information',
      icon: Icons.work_outline,
      children: [
        _buildDetailItem(context, 'Experience', '${ctrl.experience} years'),
        _buildDetailItem(context, 'Skills', ctrl.skills.isNotEmpty ? ctrl.skills.join(', ') : 'No skills added'),
        _buildDetailItem(context, 'Completed Jobs', '${ctrl.completedJobs}'),
        _buildDetailItem(context, 'Overall Rating', ctrl.rating.toStringAsFixed(1)),
        _buildDetailItem(context, 'Account Status', ctrl.status, isNonDivider: true),
        if (ctrl.certifications.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Certifications:',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
          ...ctrl.certifications.map((cert) => _buildCertificateItem(context, cert)),
        ],
      ],
    );
  }

  Widget _buildCertificateItem(BuildContext context, dynamic cert) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cert['name']?.toString() ?? 'Unnamed Certificate', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          if (cert['issuingAuthority'] != null) ...[const SizedBox(height: 4), Text('Issued by: ${cert['issuingAuthority']}', style: Theme.of(context).textTheme.labelSmall)],
          if (cert['year'] != null) ...[const SizedBox(height: 2), Text('Year: ${cert['year']}', style: Theme.of(context).textTheme.labelSmall)],
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Business Address',
      icon: Icons.location_on_outlined,
      children: [
        _buildDetailItem(context, 'Address', ctrl.address.isNotEmpty ? ctrl.address : 'Not provided'),
        _buildDetailItem(context, 'Pincode', ctrl.pincode.isNotEmpty ? ctrl.pincode : 'Not provided'),
        _buildDetailItem(context, 'City', ctrl.city.isNotEmpty ? ctrl.city : 'Not provided'),
        _buildDetailItem(context, 'State', ctrl.state.isNotEmpty ? ctrl.state : 'Not provided', isNonDivider: ctrl.latitude != 0.0 && ctrl.longitude != 0.0 ? false : true),
        if (ctrl.latitude != 0.0 && ctrl.longitude != 0.0) _buildDetailItem(context, 'Coordinates', '${ctrl.latitude.toStringAsFixed(4)}, ${ctrl.longitude.toStringAsFixed(4)}', isNonDivider: true),
      ],
    );
  }

  Widget _buildBankDetailsSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Bank Details',
      icon: Icons.account_balance_outlined,
      children: [
        if (ctrl.hasBankDetails) ...[
          _buildDetailItem(context, 'Account Number', ctrl.accountNumber),
          _buildDetailItem(context, 'Account Holder Name', ctrl.accountHolderName),
          _buildDetailItem(context, 'IFSC Code', ctrl.ifscCode),
          _buildDetailItem(context, 'Bank Name', ctrl.bankName, isNonDivider: true),
        ] else ...[
          _buildEmptyState(context, 'No bank details added', 'Add your bank details to receive payments'),
        ],
      ],
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Documents',
      icon: Icons.folder_outlined,
      children: [
        _buildDocumentItem(context, 'Profile Photo', ctrl.profileImage),
        _buildDocumentItem(context, 'Business Logo', ctrl.businessLogo),
        _buildDocumentItem(context, 'Business Banner', ctrl.businessBanner),
        _buildDocumentItem(context, 'Aadhaar Front', ctrl.aadhaarFront),
        _buildDocumentItem(context, 'Aadhaar Back', ctrl.aadhaarBack),
        _buildDocumentItem(context, 'PAN Card', ctrl.panImage),
      ],
    );
  }

  Widget _buildDocumentItem(BuildContext context, String docName, String docPath) {
    final hasDocument = docPath.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(hasDocument ? Icons.check_circle : Icons.pending, size: 20, color: hasDocument ? Colors.green : Colors.orange),
          const SizedBox(width: 12),
          Expanded(child: Text(docName, style: Theme.of(context).textTheme.bodyMedium)),
          if (hasDocument) IconButton(icon: Icon(Icons.visibility_outlined, size: 20), onPressed: () => _viewDocument(docPath, docName)),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
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

  Widget _buildDetailItem(BuildContext context, String label, String value, {bool? isNonDivider}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(value.isEmpty ? "$label is not mention" : value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(.5))),
          if (isNonDivider != true) ...[const SizedBox(height: 8), Divider(height: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.3))],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
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

  void _viewDocument(String documentPath, String documentName) {
    if (documentPath.isEmpty) return;
    final fullUrl = ctrl.getDocumentUrl(documentPath);
    Get.dialog(
      AlertDialog(
        title: Text(documentName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              fullUrl,
              height: 300,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  children: [
                    Icon(Icons.error_outline, size: 50, color: Colors.red),
                    const SizedBox(height: 8),
                    Text('Failed to load document'),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Get.back(), child: Text('Close'))],
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
