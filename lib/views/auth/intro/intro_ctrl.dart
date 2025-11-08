import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/utils/storage.dart';
import 'package:homezy_vendor/utils/routes/route_name.dart';
import 'package:homezy_vendor/utils/config/session.dart';

class IntroCtrl extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<IntroPageModel> introPages = [
    IntroPageModel(icon: Icons.work_outline, title: 'Welcome to Homenest Vendor', description: 'Join thousands of professional service providers and grow your business with Homenest.'),
    IntroPageModel(icon: Icons.schedule, title: 'Manage Your Schedule', description: 'Easily manage your appointments, bookings, and service schedules in one place.'),
    IntroPageModel(icon: Icons.payments, title: 'Get Paid Faster', description: 'Secure payments, instant notifications, and transparent earnings tracking.'),
    IntroPageModel(icon: Icons.groups, title: 'Grow Your Business', description: 'Reach more customers, get ratings and reviews, and build your reputation.'),
  ];

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void onGetStarted() {
    if (currentPage.value < introPages.length - 1) {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeIntro();
    }
  }

  void skipIntro() {
    _completeIntro();
  }

  Future<void> _completeIntro() async {
    await write(AppSession.isFirstTime, false);
    Get.offAllNamed(AppRouteNames.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class IntroPageModel {
  final IconData icon;
  final String title;
  final String description;

  IntroPageModel({required this.icon, required this.title, required this.description});
}
