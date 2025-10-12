import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_ctrl.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  final DashboardCtrl ctrl = Get.put(DashboardCtrl());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(backgroundColor: Theme.of(context).colorScheme.background, body: ctrl.tabs[ctrl.currentIndex.value], bottomNavigationBar: _buildBottomNavigationBar(context)));
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Obx(
        () => BottomNavigationBar(
          currentIndex: ctrl.currentIndex.value,
          onTap: ctrl.onTabChange,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          selectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: Theme.of(context).textTheme.labelSmall,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.work_outline), activeIcon: Icon(Icons.work), label: 'Services'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
