import 'package:get/get.dart';
import 'package:homezy_vendor/utils/routes/route_name.dart';
import 'package:homezy_vendor/views/auth/splash/splash.dart';

class AppRouteMethods {
  static GetPage<dynamic> getPage({required String name, required GetPageBuilder page, List<GetMiddleware>? middlewares}) {
    return GetPage(name: name, page: page, transition: Transition.topLevel, showCupertinoParallax: true, middlewares: middlewares ?? [], transitionDuration: 350.milliseconds);
  }

  static List<GetPage> pages = [getPage(name: AppRouteNames.splash, page: () => const Splash())];
}
