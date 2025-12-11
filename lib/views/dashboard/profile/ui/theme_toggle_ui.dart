import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homenest_vendor/utils/storage.dart';
import 'package:homenest_vendor/views/restart.dart';

class ThemeToggleUI extends StatefulWidget {
  const ThemeToggleUI({super.key});

  @override
  State<ThemeToggleUI> createState() => _ThemeToggleUIState();
}

class _ThemeToggleUIState extends State<ThemeToggleUI> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = read("isDarkMode") ?? false;
  }

  void _toggleTheme(BuildContext context) {
    _isDarkMode = !_isDarkMode;
    setState(() {});
    write("isDarkMode", _isDarkMode);
    if (_isDarkMode) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        RestartApp.restartApp(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary.withOpacity(.06)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
          ),
          icon: Icon(_isDarkMode ? Icons.nightlight_round : Icons.wb_sunny, color: _isDarkMode ? Colors.yellow : Colors.orange, size: 20),
          onPressed: () => _toggleTheme(context),
        ),
      ],
    );
  }
}
