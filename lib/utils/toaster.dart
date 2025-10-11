import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

class Toaster {
  success(String txt) {
    toastification.dismissAll();
    toastification.show(
      type: ToastificationType.success,
      title: Text(txt),
      progressBarTheme: const ProgressIndicatorThemeData(color: Colors.green, linearMinHeight: 2),
      animationDuration: const Duration(milliseconds: 200),
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  warning(String message) {
    toastification.dismissAll();
    toastification.show(
      type: ToastificationType.warning,
      title: Text(message),
      progressBarTheme: const ProgressIndicatorThemeData(color: Colors.amber, linearMinHeight: 2),
      animationDuration: const Duration(milliseconds: 200),
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  error(String error) {
    toastification.dismissAll();
    toastification.show(
      type: ToastificationType.error,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Internal server error occurred, please try again later.").paddingOnly(bottom: 4),
          Text(
            error.toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
      ),
      progressBarTheme: const ProgressIndicatorThemeData(color: Colors.red, linearMinHeight: 2),
      animationDuration: const Duration(milliseconds: 200),
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  info(String message) {
    toastification.dismissAll();
    toastification.show(
      type: ToastificationType.info,
      title: Text(message),
      progressBarTheme: const ProgressIndicatorThemeData(color: Colors.blueGrey, linearMinHeight: 2),
      animationDuration: const Duration(milliseconds: 200),
      autoCloseDuration: const Duration(seconds: 2),
    );
  }
}

Toaster toaster = Toaster();
