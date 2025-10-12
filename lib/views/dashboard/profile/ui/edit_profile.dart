import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/utils/network/api_config.dart';
import 'package:homezy_vendor/views/dashboard/profile/profile_ctrl.dart';

class EditProfile extends StatelessWidget {
  EditProfile({super.key});

  final ProfileCtrl ctrl = Get.find<ProfileCtrl>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Edit Profile')),
            Obx(() {
              return Text('Step ${ctrl.currentEditStep.value + 1} of 6', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant));
            }),
            SizedBox(width: 8.0),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepperIndicator(context),
          Expanded(
            child: PageView(
              controller: ctrl.editPageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalInfoStep(context),
                _buildBusinessInfoStep(context),
                _buildProfessionalInfoStep(context),
                _buildAddressStep(context),
                _buildBankDetailsStep(context),
                _buildDocumentUploadStep(context),
              ],
            ),
          ),
          _buildNavigationButtons(context),
        ],
      ),
    );
  }

  Widget _buildStepperIndicator(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          children: List.generate(
            6,
            (index) => Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index == 5 ? 0 : 4),
                decoration: BoxDecoration(
                  color: index <= ctrl.currentEditStep.value ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCount(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600));
  }

  Widget _buildPersonalInfoStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCount(context, "Personal Information"),
          const SizedBox(height: 24),
          _buildProfileImageSection(context),
          const SizedBox(height: 20),
          _buildTextField(context, controller: ctrl.nameController, label: 'Full Name', hint: 'Enter your full name', isRequired: true),
          const SizedBox(height: 16),
          _buildTextField(context, controller: ctrl.emailController, label: 'Email Address', hint: 'Enter your email', keyboardType: TextInputType.emailAddress, isRequired: true),
          const SizedBox(height: 16),
          _buildTextField(context, controller: ctrl.phoneController, label: 'Phone Number', hint: 'Enter phone number', keyboardType: TextInputType.phone, isRequired: true),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCount(context, "Business Information"),
          const SizedBox(height: 24),
          _buildTextField(context, controller: ctrl.businessNameController, label: 'Business Name', hint: 'Enter business name', isRequired: true),
          const SizedBox(height: 16),
          _buildTextField(context, controller: ctrl.businessDescriptionController, label: 'Business Description', hint: 'Describe your business', maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCount(context, "Professional Information"),
          const SizedBox(height: 24),
          _buildTextField(context, controller: ctrl.experienceController, label: 'Experience (Years)', hint: 'Enter years of experience', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildTextField(context, controller: ctrl.skillsController, label: 'Skills', hint: 'e.g., Plumbing, Electrical, Carpentry'),
          const SizedBox(height: 16),
          _buildCertificationsSection(context),
        ],
      ),
    );
  }

  Widget _buildCertificationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepCount(context, "Certifications"),
        const SizedBox(height: 8),
        Obx(
          () => Column(
            children: [
              ...ctrl.certifications.asMap().entries.map((entry) {
                final index = entry.key;
                final cert = entry.value;
                return _buildCertificateItem(context, index, cert);
              }),
              _buildAddCertificateButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateItem(BuildContext context, int index, Map<String, dynamic> cert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Certificate ${index + 1}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
              IconButton(
                icon: Icon(Icons.delete, size: 20, color: Theme.of(context).colorScheme.error),
                onPressed: () => ctrl.removeCertificate(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            context,
            controller: TextEditingController(text: cert['name']),
            label: 'Certificate Name',
            hint: 'Enter certificate name',
            onChanged: (value) => ctrl.updateCertificateName(index, value),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            context,
            controller: TextEditingController(text: cert['issuingAuthority']),
            label: 'Issuing Authority',
            hint: 'Enter issuing authority',
            onChanged: (value) => ctrl.updateCertificateAuthority(index, value),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            context,
            controller: TextEditingController(text: cert['year'].toString()),
            label: 'Year',
            hint: 'Year',
            keyboardType: TextInputType.number,
            onChanged: (value) => ctrl.updateCertificateYear(index, value),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCertificateButton(BuildContext context) {
    return OutlinedButton(
      onPressed: ctrl.addCertificate,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text('Add Certificate', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _buildAddressStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCount(context, "Business Address"),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text('Business Location', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
              ElevatedButton.icon(
                onPressed: ctrl.getCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: Obx(
                  () => ctrl.isLocationLoading.value
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
                      : Icon(Icons.location_on, size: 15),
                ),
                label: Text('Get Current Location', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(context, controller: ctrl.addressController, label: 'Address', hint: 'Enter business address'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(context, controller: ctrl.pincodeController, label: 'Pincode', hint: 'Pincode', keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(context, controller: ctrl.cityController, label: 'City', hint: 'City'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(context, controller: ctrl.stateController, label: 'State', hint: 'State'),
        ],
      ),
    );
  }

  Widget _buildBankDetailsStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCount(context, "Bank Details"),
          const SizedBox(height: 24),
          _buildTextField(context, controller: ctrl.accountNumberController, label: 'Account Number', hint: 'Enter account number', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildTextField(context, controller: ctrl.accountHolderNameController, label: 'Account Holder Name', hint: 'Enter account holder name'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(context, controller: ctrl.ifscCodeController, label: 'IFSC Code', hint: 'IFSC Code'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(context, controller: ctrl.bankNameController, label: 'Bank Name', hint: 'Bank name'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCount(context, "Document Upload"),
          const SizedBox(height: 24),
          _buildImageUploadField(context, label: 'Business Logo', onTap: ctrl.pickBusinessLogo, imagePath: ctrl.businessLogoPath),
          const SizedBox(height: 16),
          _buildImageUploadField(context, label: 'Business Banner', onTap: ctrl.pickBusinessBanner, imagePath: ctrl.businessBannerPath),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildImageUploadField(context, label: 'Aadhaar Front', onTap: ctrl.pickAadhaarFront, imagePath: ctrl.aadhaarFrontPath),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildImageUploadField(context, label: 'Aadhaar Back', onTap: ctrl.pickAadhaarBack, imagePath: ctrl.aadhaarBackPath),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildImageUploadField(context, label: 'PAN Card', onTap: ctrl.pickPanImage, imagePath: ctrl.panImagePath),
          const SizedBox(height: 20),
          _buildDocumentStatusSection(context),
        ],
      ),
    );
  }

  Widget _buildDocumentStatusSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('Document Status', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Current documents will be replaced with new uploads. '
            'You can skip documents that don\'t need updating.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadField(BuildContext context, {required String label, required VoidCallback onTap, required RxString imagePath}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Obx(
          () => GestureDetector(
            onTap: onTap,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.upload, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      imagePath.value.isEmpty ? 'Upload $label' : 'Selected: ${imagePath.value.split('/').last}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: imagePath.value.isEmpty ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6) : Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  if (imagePath.value.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.close, size: 18, color: Theme.of(context).colorScheme.error),
                      onPressed: () => imagePath.value = '',
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImageSection(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          final imageFile = ctrl.selectedImage.value;
          final imageUrl = ctrl.profileImage;
          final hasNewImage = ctrl.profileImagePath.value.isNotEmpty && !ctrl.profileImagePath.value.contains("uploads");
          return Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  image: hasNewImage
                      ? DecorationImage(image: FileImage(File(ctrl.profileImagePath.value)), fit: BoxFit.cover)
                      : imageFile != null
                      ? DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover)
                      : imageUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(APIConfig.resourceBaseURL + imageUrl), fit: BoxFit.cover)
                      : null,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: (imageFile == null && imageUrl.isEmpty) ? Icon(Icons.person, size: 35, color: Theme.of(context).colorScheme.onPrimaryContainer) : null,
              ),
              if (hasNewImage)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
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
                    child: Icon(Icons.camera_alt, size: 16, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 10),
        Obx(
          () => Text(
            ctrl.profileImagePath.value.isNotEmpty ? 'New photo selected' : 'Update Profile Photo',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500)),
            if (isRequired) Text(' *', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(12)),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: Theme.of(context).textTheme.bodyMedium,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            if (ctrl.currentEditStep.value > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: ctrl.previousEditStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Back'),
                ),
              ),
            if (ctrl.currentEditStep.value > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: ctrl.currentEditStep.value == 5 ? ctrl.updateProfile : ctrl.nextEditStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: ctrl.isUpdating.value
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
                    : Text(
                        ctrl.currentEditStep.value == 5 ? 'UPDATE PROFILE' : 'Continue',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
