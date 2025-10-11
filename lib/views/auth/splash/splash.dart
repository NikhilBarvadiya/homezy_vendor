import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/views/auth/splash/splash_ctrl.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashCtrl>(
      init: SplashCtrl(),
      builder: (ctrl) {
        return Scaffold();
      },
    );
  }
}
