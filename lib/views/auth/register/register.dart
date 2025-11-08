import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/views/auth/register/register_ctrl.dart';

class Register extends StatelessWidget {
  Register({super.key});

  final RegisterCtrl ctrl = Get.put(RegisterCtrl());

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildStepper(context),
                Expanded(
                  child: PageView(
                    controller: ctrl.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildPersonalInfoStep(context),
                      _buildBusinessInfoStep(context),
                      _buildDocumentUploadStep(context),
                      _buildProfessionalInfoStep(context),
                      _buildAddressStep(context),
                      _buildBankDetailsStep(context),
                    ],
                  ),
                ),
                if (!isKeyboardVisible) _buildNavigationButtons(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Icon(Icons.person_add_alt_1, size: 40, color: Theme.of(context).colorScheme.onPrimary),
          ),
          const SizedBox(height: 16),
          Text('Join Homenest Vendor', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Obx(() => Text('Step ${ctrl.currentStep.value + 1} of 6', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
        ],
      ),
    );
  }

  Widget _buildStepper(BuildContext context) {
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
                  color: index <= ctrl.currentStep.value ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep(BuildContext context) {
    return _buildStepContent(
      context,
      title: 'Personal Information',
      children: [
        _buildTextField(context, controller: ctrl.nameController, label: 'Full Name', hint: 'Enter your full name'),
        const SizedBox(height: 16),
        _buildTextField(context, controller: ctrl.emailController, label: 'Email Address', hint: 'Enter your email', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildPhoneField(context),
      ],
    );
  }

  Widget _buildBusinessInfoStep(BuildContext context) {
    return _buildStepContent(
      context,
      title: 'Business Information',
      canSkip: true,
      onSkip: () => ctrl.nextStep(),
      children: [
        _buildTextField(context, controller: ctrl.businessNameController, label: 'Business Name', hint: 'Enter business name'),
        const SizedBox(height: 16),
        _buildTextField(context, controller: ctrl.businessDescriptionController, label: 'Business Description', hint: 'Describe your business', maxLines: 3),
      ],
    );
  }

  Widget _buildDocumentUploadStep(BuildContext context) {
    return _buildStepContent(
      context,
      title: 'Document Upload',
      canSkip: true,
      onSkip: () => ctrl.nextStep(),
      children: [
        _buildImageUploadField(context, label: 'Profile Photo', onTap: ctrl.pickProfileImage, imagePath: ctrl.profileImagePath),
        const SizedBox(height: 16),
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
      ],
    );
  }

  Widget _buildProfessionalInfoStep(BuildContext context) {
    return _buildStepContent(
      context,
      title: 'Professional Information',
      canSkip: true,
      onSkip: () => ctrl.nextStep(),
      children: [
        _buildTextField(context, controller: ctrl.experienceController, label: 'Experience (Years)', hint: 'Enter years of experience', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField(context, controller: ctrl.skillsController, label: 'Skills', hint: 'e.g., Plumbing, Electrical, Carpentry'),
        const SizedBox(height: 16),
        _buildCertificationsSection(context),
      ],
    );
  }

  Widget _buildCertificationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Certifications', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500)),
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
    return _buildStepContent(
      context,
      title: 'Business Address',
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Business Location', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Obx(() {
              return ElevatedButton.icon(
                onPressed: ctrl.getCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: ctrl.isLocationLoading.value == true
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
                    : Icon(Icons.location_on, size: 15),
                label: Text('Get Current Location', style: TextStyle(fontSize: 12)),
              );
            }),
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
    );
  }

  Widget _buildBankDetailsStep(BuildContext context) {
    return _buildStepContent(
      context,
      title: 'Bank Details',
      children: [
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
    );
  }

  Widget _buildStepContent(BuildContext context, {required String title, required List<Widget> children, bool canSkip = false, VoidCallback? onSkip}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
              if (canSkip)
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              if (!canSkip)
                TextButton(
                  onPressed: null,
                  child: Text(
                    'Required',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
          const SizedBox(height: 40),
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
                      imagePath.value.isEmpty ? 'Upload $label' : 'Selected',
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

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500)),
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

  Widget _buildPhoneField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          height: 50,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(12)),
          child: TextFormField(
            controller: ctrl.phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Enter phone number',
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              prefixIcon: GestureDetector(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.phone, size: 20),
                      Container(height: 24, width: 1, color: Theme.of(context).colorScheme.outline, margin: const EdgeInsets.only(left: 8, right: 8)),
                    ],
                  ),
                ),
              ),
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
            if (ctrl.currentStep.value > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: ctrl.previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Back'),
                ),
              ),
            if (ctrl.currentStep.value > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: ctrl.currentStep.value == 6 ? ctrl.register : ctrl.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: ctrl.isLoading.value
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
                    : Text(
                        ctrl.currentStep.value == 5 ? 'CREATE ACCOUNT' : 'Continue',
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
