import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:homezy_vendor/utils/toaster.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Helper {
  final ImagePicker _picker = ImagePicker();

  Future<void> launchURL(String val) async {
    if (await canLaunchUrl(Uri.parse(val))) {
      await launchUrl(Uri.parse(val));
    } else {
      throw 'Could not launch $val';
    }
  }

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

  void shareApp() async {
    try {
      final String shareText = '''
🚀 Check out Homenest Vendor App!

Homenest Vendor helps service providers manage their business efficiently. Features include:

• Profile Management
• Service Booking
• Payment Processing
• Customer Management
• Business Analytics

Download now and grow your business!

🔗 Download Link: https://play.google.com/store/apps/details?id=com.itfuturz.homezy_vendor
      ''';
      await Share.share(shareText, subject: 'Homenest Vendor App');
    } catch (e) {
      toaster.error('Failed to share app: $e');
    }
  }

  ratingApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.openStoreListing();
    }
  }
}

Helper helper = Helper();
