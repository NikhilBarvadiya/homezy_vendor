import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/views/dashboard/home/home.dart';
import 'package:homezy_vendor/views/dashboard/orders/orders.dart';
import 'package:homezy_vendor/views/dashboard/profile/profile.dart';

class DashboardCtrl extends GetxController {
  final RxInt currentIndex = 0.obs;

  final List<Widget> tabs = [Home(), Orders(), const PlaceholderWidget(title: 'Services'), Profile()];

  void onTabChange(int index) => currentIndex.value = index;
}

class PlaceholderWidget extends StatelessWidget {
  final String title;

  const PlaceholderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIconForTitle(title), size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('$title Page', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('This page is under development', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'orders':
        return Icons.shopping_bag_outlined;
      case 'services':
        return Icons.work_outline;
      case 'profile':
        return Icons.person_outline;
      default:
        return Icons.help_outline;
    }
  }
}
