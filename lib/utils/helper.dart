import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:homezy_vendor/utils/toaster.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class Helper {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({ImageSource? source}) async {
    try {
      final XFile? file = await _picker.pickImage(source: source ?? ImageSource.camera);
      if (file != null) {
        return File(file.path);
      }
      return null;
    } catch (err) {
      toaster.error("Error while clicking image!");
      return null;
    }
  }

  void makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (err) {
      toaster.warning("Invalid phone number...!");
    }
  }

  bool isMobileValidation(String phoneNumber) {
    String regexPattern = r'^[6-9][0-9]{9}$';
    var regExp = RegExp(regexPattern);
    if (phoneNumber.isEmpty) {
      return false;
    } else if (regExp.hasMatch(phoneNumber)) {
      return true;
    }
    return false;
  }

  Future<String> getDeviceUniqueId() async {
    String deviceIdentifier = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceIdentifier = androidInfo.id;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceIdentifier = iosInfo.identifierForVendor!;
    }
    return deviceIdentifier;
  }
}

Helper helper = Helper();
