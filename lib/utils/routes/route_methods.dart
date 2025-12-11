import 'package:get/get.dart';
import 'package:homenest_vendor/utils/routes/route_name.dart';
import 'package:homenest_vendor/views/auth/intro/intro.dart';
import 'package:homenest_vendor/views/auth/login/login.dart';
import 'package:homenest_vendor/views/auth/otp/otp.dart';
import 'package:homenest_vendor/views/auth/register/register.dart';
import 'package:homenest_vendor/views/auth/splash/splash.dart';
import 'package:homenest_vendor/views/dashboard/dashboard.dart';

class AppRouteMethods {
  static GetPage<dynamic> getPage({required String name, required GetPageBuilder page, List<GetMiddleware>? middlewares}) {
    return GetPage(name: name, page: page, transition: Transition.topLevel, showCupertinoParallax: true, middlewares: middlewares ?? [], transitionDuration: 350.milliseconds);
  }

  static List<GetPage> pages = [
    getPage(name: AppRouteNames.splash, page: () => const Splash()),
    getPage(name: AppRouteNames.intro, page: () => const Intro()),
    getPage(name: AppRouteNames.login, page: () => Login()),
    getPage(
      name: AppRouteNames.otp,
      page: () => Otp(phoneNumber: Get.arguments),
    ),
    getPage(name: AppRouteNames.register, page: () => Register()),
    getPage(name: AppRouteNames.dashboard, page: () => Dashboard()),
  ];
}
