import 'dart:io';
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
}

Helper helper = Helper();
