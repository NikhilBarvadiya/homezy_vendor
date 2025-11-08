import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/views/auth/splash/splash_ctrl.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashCtrl>(
      init: SplashCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                  child: Icon(Icons.home_work, size: 60, color: Theme.of(context).colorScheme.onPrimary),
                ),
                const SizedBox(height: 24),
                Text('Homenest Vendor', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Professional Service Provider', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 32),
                SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 3, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          ),
        );
      },
    );
  }
}
