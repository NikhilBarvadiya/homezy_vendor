import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:homenest_vendor/utils/config/session.dart';
import 'package:homenest_vendor/utils/helper.dart';
import 'package:homenest_vendor/utils/service/location_service.dart';
import 'package:homenest_vendor/views/auth/auth_service.dart';
import 'package:homenest_vendor/utils/toaster.dart';
import 'package:homenest_vendor/utils/network/api_config.dart';
import 'package:homenest_vendor/utils/storage.dart';

class ProfileCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  LocationService get locationService => Get.find<LocationService>();

  final RxMap<String, dynamic> _profileData = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> _localProfileData = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs, isUpdating = false.obs, isLocationLoading = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString profileImagePath = ''.obs;
  final RxString businessLogoPath = ''.obs;
  final RxString businessBannerPath = ''.obs;
  final RxString aadhaarFrontPath = ''.obs;
  final RxString aadhaarBackPath = ''.obs;
  final RxString panImagePath = ''.obs;
  final PageController editPageController = PageController();
  final RxInt currentEditStep = 0.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessDescriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountHolderNameController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadLocalData();
    loadProfileData();
  }

  void _loadLocalData() async {
    final userData = await read(AppSession.userData) ?? {};
    if (userData != null && userData is Map && userData.isNotEmpty) {
      _localProfileData.value = Map<String, dynamic>.from(userData);
      _updateFormControllers();
    }
  }

  Map<String, dynamic> get _effectiveData {
    return _profileData.isNotEmpty ? _profileData : _localProfileData;
  }

  String get vendorName => _effectiveData['name'] ?? '';

  String get email => _effectiveData['email'] ?? '';

  String get phone => _effectiveData['phone'] ?? '';

  String get businessName => _effectiveData['businessName'] ?? '';

  String get businessDescription => _effectiveData['businessDescription'] ?? '';

  String get address => _effectiveData['businessAddress']?['address'] ?? _effectiveData['address'] ?? '';

  String get profileImage => _effectiveData['image'] ?? '';

  double get rating => double.tryParse(_effectiveData['overallRating']?.toString() ?? '0') ?? 0.0;

  int get completedJobs {
    final jobs = _effectiveData['completedJobs'];
    if (jobs is num) return jobs.toInt();
    if (jobs is String) return int.tryParse(jobs) ?? 0;
    return 0;
  }

  String get joinDate => _effectiveData['createdAt'] ?? '';

  bool get isVerified => _effectiveData['verification']?['isVerified'] ?? false;

  String get status => _effectiveData['isActive'] == true ? 'ACTIVE' : 'INACTIVE';

  int get experience => int.tryParse(_effectiveData['professionalInfo']?['experience'].toString() ?? "0") ?? 0;

  List<String> get skills {
    final skillsData = _effectiveData['professionalInfo']?['skills'];
    if (skillsData is List) return skillsData.cast<String>();
    if (skillsData is String) return skillsData.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return [];
  }

  List<dynamic> get certifications => _effectiveData['professionalInfo']?['certifications'] ?? [];

  String get bio => _effectiveData['professionalInfo']?['bio'] ?? '';

  String get accountNumber => _effectiveData['bankDetails']?['accountNumber'] ?? '';

  String get accountHolderName => _effectiveData['bankDetails']?['accountHolderName'] ?? '';

  String get ifscCode => _effectiveData['bankDetails']?['ifscCode'] ?? '';

  String get bankName => _effectiveData['bankDetails']?['bankName'] ?? '';

  String get pincode => _effectiveData['businessAddress']?['pincode'] ?? '';

  String get city => _effectiveData['businessAddress']?['city'] ?? '';

  String get state => _effectiveData['businessAddress']?['state'] ?? '';

  double get latitude => double.tryParse(_effectiveData['businessAddress']?['latitude'] ?? "0.0") ?? 0.0;

  double get longitude => double.tryParse(_effectiveData['businessAddress']?['longitude'] ?? "0.0") ?? 0.0;

  String get aadhaarFront => _effectiveData['verification']?['aadhaarFront'] ?? '';

  String get aadhaarBack => _effectiveData['verification']?['aadhaarBack'] ?? '';

  String get panImage => _effectiveData['verification']?['panImage'] ?? '';

  String get businessLogo => _effectiveData['businessLogo'] ?? '';

  String get businessBanner => _effectiveData['businessBanner'] ?? '';

  Future<void> loadProfileData() async {
    try {
      isLoading(true);
      final response = await _authService.getProfile();
      if (response != null) {
        _profileData.value = response;
        await write(AppSession.userData, response);
        _updateFormControllers();
      }
    } catch (e) {
      toaster.error('Error loading profile: $e');
    } finally {
      isLoading(false);
    }
  }

  void _updateFormControllers() {
    nameController.text = vendorName;
    emailController.text = email;
    phoneController.text = phone;
    businessNameController.text = businessName;
    businessDescriptionController.text = businessDescription;
    addressController.text = address;
    experienceController.text = experience.toString();
    skillsController.text = skills.join(', ');
    accountNumberController.text = accountNumber;
    accountHolderNameController.text = accountHolderName;
    ifscCodeController.text = ifscCode;
    bankNameController.text = bankName;
    pincodeController.text = pincode;
    cityController.text = city;
    stateController.text = state;
    profileImagePath.value = profileImage;
    businessLogoPath.value = businessLogo;
    businessBannerPath.value = businessBanner;
    aadhaarFrontPath.value = aadhaarFront;
    aadhaarBackPath.value = aadhaarBack;
    panImagePath.value = panImage;
  }

  Future<void> updateProfile() async {
    try {
      isUpdating(true);
      final formData = dio.FormData.fromMap({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'businessName': businessNameController.text.trim(),
        'businessDescription': businessDescriptionController.text.trim(),
        'professionalInfo': {
          'experience': int.tryParse(experienceController.text) ?? 0,
          'skills': skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          'bio': businessDescriptionController.text.trim(),
        },
        'businessAddress': {'address': addressController.text.trim(), 'pincode': pincodeController.text.trim(), 'city': cityController.text.trim(), 'state': stateController.text.trim()},
        'bankDetails': {
          'accountNumber': accountNumberController.text.trim(),
          'accountHolderName': accountHolderNameController.text.trim(),
          'ifscCode': ifscCodeController.text.trim(),
          'bankName': bankNameController.text.trim(),
        },
      });
      await _addImageToFormData(formData, 'image', profileImagePath.value);
      await _addImageToFormData(formData, 'businessLogo', businessLogoPath.value);
      await _addImageToFormData(formData, 'businessBanner', businessBannerPath.value);
      await _addImageToFormData(formData, 'aadhaarFront', aadhaarFrontPath.value);
      await _addImageToFormData(formData, 'aadhaarBack', aadhaarBackPath.value);
      await _addImageToFormData(formData, 'panImage', panImagePath.value);
      final response = await _authService.updateProfile(formData);
      if (response != null) {
        _profileData.value = response ?? {};
        await write(AppSession.userData, _profileData);
        _updateFormControllers();
        toaster.success('Profile updated successfully');
        Get.close(1);
      } else {
        toaster.error('Failed to update profile');
      }
    } catch (e) {
      toaster.error('Error updating profile: $e');
    } finally {
      isUpdating(false);
    }
  }

  void nextEditStep() {
    if (currentEditStep.value < 5) {
      currentEditStep.value++;
      editPageController.animateToPage(currentEditStep.value, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void previousEditStep() {
    if (currentEditStep.value > 0) {
      currentEditStep.value--;
      editPageController.animateToPage(currentEditStep.value, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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

  Future<void> getCurrentLocation() async {
    try {
      isLocationLoading(true);
      final addressData = await locationService.getCurrentAddress();
      if (addressData != null) {
        addressController.text = addressData['address'] ?? '';
        pincodeController.text = addressData['pincode'] ?? '';
        cityController.text = addressData['city'] ?? '';
        stateController.text = addressData['state'] ?? '';
        _effectiveData['businessAddress']?['latitude'] = addressData['latitude'] ?? 0.0;
        _effectiveData['businessAddress']?['longitude'] = addressData['longitude'] ?? 0.0;
        toaster.success('Location fetched successfully');
      }
    } catch (e) {
      toaster.error('Failed to fetch location: ${e.toString()}');
    } finally {
      isLocationLoading(false);
    }
  }

  Future<void> _addImageToFormData(dio.FormData formData, String fieldName, String imagePath) async {
    if (imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        formData.files.add(MapEntry(fieldName, await dio.MultipartFile.fromFile(file.path, filename: file.path.split('/').last)));
      }
    }
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

  void clearImage() {
    selectedImage.value = null;
  }

  String getDocumentUrl(String documentPath) {
    if (documentPath.isEmpty) return '';
    return APIConfig.resourceBaseURL + documentPath;
  }

  bool get hasBankDetails => accountNumber.isNotEmpty || accountHolderName.isNotEmpty || ifscCode.isNotEmpty;

  bool get hasDocuments => aadhaarFront.isNotEmpty || panImage.isNotEmpty;

  bool get hasProfessionalInfo => experience > 0 || skills.isNotEmpty;

  bool get hasCertifications => certifications.isNotEmpty;

  @override
  void onClose() {
    editPageController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    businessNameController.dispose();
    businessDescriptionController.dispose();
    addressController.dispose();
    experienceController.dispose();
    skillsController.dispose();
    accountNumberController.dispose();
    accountHolderNameController.dispose();
    ifscCodeController.dispose();
    bankNameController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    stateController.dispose();
    super.onClose();
  }
}
