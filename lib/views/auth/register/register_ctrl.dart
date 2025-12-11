import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homenest_vendor/utils/helper.dart';
import 'package:homenest_vendor/utils/routes/route_name.dart';
import 'package:homenest_vendor/utils/service/location_service.dart';
import 'package:homenest_vendor/utils/toaster.dart';
import 'package:homenest_vendor/views/auth/auth_service.dart';

class RegisterCtrl extends GetxController {
  AuthService get _authService => Get.find<AuthService>();

  LocationService get locationService => Get.find<LocationService>();

  final PageController pageController = PageController();
  final RxInt currentStep = 0.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessDescriptionController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountHolderNameController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();

  final RxList<Map<String, dynamic>> certifications = <Map<String, dynamic>>[].obs;

  final RxString profileImagePath = ''.obs;
  final RxString businessLogoPath = ''.obs;
  final RxString businessBannerPath = ''.obs;
  final RxString aadhaarFrontPath = ''.obs;
  final RxString aadhaarBackPath = ''.obs;
  final RxString panImagePath = ''.obs;
  final RxDouble latitude = 0.0.obs, longitude = 0.0.obs;

  final RxBool isLoading = false.obs, isLocationLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    addCertificate();
  }

  Future<void> getCurrentLocation() async {
    try {
      isLocationLoading(true);
      final addressData = await locationService.getCurrentAddress();
      if (addressData != null) {
        addressController.text = addressData['address'] ?? '';
        pincodeController.text = addressData['pincode'] ?? '';
        cityController.text = addressData['city'] ?? '';
        stateController.text = addressData['state'] ?? '';
        latitude.value = addressData['latitude'] ?? 0.0;
        longitude.value = addressData['longitude'] ?? 0.0;
        toaster.success('Location fetched successfully');
      }
    } catch (e) {
      toaster.error('Failed to fetch location: ${e.toString()}');
    } finally {
      isLocationLoading(false);
    }
  }

  void nextStep() {
    if (currentStep.value < 6) {
      currentStep.value++;
      pageController.animateToPage(currentStep.value, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.animateToPage(currentStep.value, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void addCertificate() {
    certifications.add({"name": "", "issuingAuthority": "", "year": DateTime.now().year, "certificateImage": ""});
  }

  void removeCertificate(int index) {
    if (certifications.length > 1) {
      certifications.removeAt(index);
    } else {
      toaster.error('At least one certificate is required');
    }
  }

  void updateCertificateName(int index, String value) {
    certifications[index]['name'] = value;
  }

  void updateCertificateAuthority(int index, String value) {
    certifications[index]['issuingAuthority'] = value;
  }

  void updateCertificateYear(int index, String value) {
    certifications[index]['year'] = int.tryParse(value) ?? DateTime.now().year;
  }

  Future<void> pickCertificateImage(int index) async {
    try {
      final file = await helper.pickImage();
      if (file != null) {
        certifications[index]['certificateImage'] = file.path;
      }
    } catch (e) {
      toaster.error('Failed to pick certificate image: ${e.toString()}');
    }
  }

  Future<void> register() async {
    if (!_validateCurrentStep()) return;
    try {
      isLoading(true);
      final formData = dio.FormData.fromMap({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'businessName': businessNameController.text.trim(),
        'businessDescription': businessDescriptionController.text.trim(),
        'professionalInfo': _getProfessionalInfo(),
        'businessAddress': _getBusinessAddress(),
        'bankDetails': _getBankDetails(),
      });
      await _addImageToFormData(formData, 'image', profileImagePath.value);
      await _addImageToFormData(formData, 'businessLogo', businessLogoPath.value);
      await _addImageToFormData(formData, 'businessBanner', businessBannerPath.value);
      await _addImageToFormData(formData, 'aadhaarFront', aadhaarFrontPath.value);
      await _addImageToFormData(formData, 'aadhaarBack', aadhaarBackPath.value);
      await _addImageToFormData(formData, 'panImage', panImagePath.value);
      await _authService.register(formData);
    } catch (e) {
      toaster.error('Registration failed: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  bool _validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        if (nameController.text.isEmpty) {
          toaster.error('Please enter your full name');
          return false;
        }
        if (emailController.text.isEmpty || !GetUtils.isEmail(emailController.text)) {
          toaster.error('Please enter a valid email address');
          return false;
        }
        if (helper.isMobileValidation(phoneController.text) != true) {
          toaster.error('Please enter a valid 10-digit phone number');
          return false;
        }
        break;
      case 5:
        if (addressController.text.isEmpty) {
          toaster.error('Please enter your business address');
          return false;
        }
        break;
      case 6:
        if (accountNumberController.text.isEmpty) {
          toaster.error('Please enter your account number');
          return false;
        }
        if (ifscCodeController.text.isEmpty) {
          toaster.error('Please enter IFSC code');
          return false;
        }
        break;
    }
    return true;
  }

  Future<void> pickProfileImage() async => _pickImage(profileImagePath);

  Future<void> pickBusinessLogo() async => _pickImage(businessLogoPath);

  Future<void> pickBusinessBanner() async => _pickImage(businessBannerPath);

  Future<void> pickAadhaarFront() async => _pickImage(aadhaarFrontPath);

  Future<void> pickAadhaarBack() async => _pickImage(aadhaarBackPath);

  Future<void> pickPanImage() async => _pickImage(panImagePath);

  Future<void> _pickImage(RxString imagePath) async {
    try {
      final file = await helper.pickImage();
      if (file != null) {
        imagePath.value = file.path;
      }
    } catch (e) {
      toaster.error('Failed to pick image: ${e.toString()}');
    }
  }

  Map<String, dynamic> _getProfessionalInfo() {
    return {
      "experience": int.tryParse(experienceController.text) ?? 0,
      "skills": skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      "certifications": certifications.where((cert) => cert['name'].toString().isNotEmpty).toList(),
      "bio": businessDescriptionController.text.trim(),
    };
  }

  Map<String, dynamic> _getBusinessAddress() {
    return {
      "address": addressController.text.trim(),
      "pincode": pincodeController.text.trim(),
      "city": cityController.text.trim(),
      "state": stateController.text.trim(),
      "latitude": latitude.value,
      "longitude": longitude.value,
    };
  }

  Map<String, dynamic> _getBankDetails() {
    return {
      "accountNumber": accountNumberController.text.trim(),
      "accountHolderName": accountHolderNameController.text.trim(),
      "ifscCode": ifscCodeController.text.trim(),
      "bankName": bankNameController.text.trim(),
    };
  }

  Future<void> _addImageToFormData(dio.FormData formData, String fieldName, String imagePath) async {
    if (imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        formData.files.add(MapEntry(fieldName, await dio.MultipartFile.fromFile(file.path, filename: file.path.split('/').last)));
      }
    }
  }

  void goToLogin() => Get.offNamed(AppRouteNames.login);

  @override
  void onClose() {
    pageController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    businessNameController.dispose();
    businessDescriptionController.dispose();
    experienceController.dispose();
    skillsController.dispose();
    addressController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    stateController.dispose();
    accountNumberController.dispose();
    accountHolderNameController.dispose();
    ifscCodeController.dispose();
    bankNameController.dispose();
    super.onClose();
  }
}
