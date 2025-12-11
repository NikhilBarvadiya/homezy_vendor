import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homenest_vendor/utils/routes/route_methods.dart';
import 'package:homenest_vendor/utils/routes/route_name.dart';
import 'package:homenest_vendor/utils/theme/app_theme.dart';
import 'package:homenest_vendor/views/dashboard/available_bookings/available_bookings_ctrl.dart';
import 'package:homenest_vendor/views/dashboard/dashboard_ctrl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:homenest_vendor/firebase_options.dart';
import 'package:homenest_vendor/utils/storage.dart';
import 'package:homenest_vendor/views/preload.dart';
import 'package:homenest_vendor/utils/service/notification_service.dart';
import 'package:homenest_vendor/views/restart.dart';
import 'package:toastification/toastification.dart';
import 'utils/config/app_config.dart';

Future<void> main() async {
  await GetStorage.init();
  GestureBinding.instance.resamplingEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await notificationService.init();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemStatusBarContrastEnforced: true));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await preload();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleNotificationClick(message);
  });
  terminatedNotification();
  runApp(const RestartApp(child: MyApp()));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  String? lastHandledMessageId = await read('notificationKey');
  if (message.messageId != null && message.messageId != lastHandledMessageId) {
    await write('notificationKey', message.messageId);
    await notificationService.init();
    _handleNotificationClick(message);
  }
}

void terminatedNotification() async {
  String? lastHandledMessageId = await read('notificationKey');
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null && initialMessage.messageId != lastHandledMessageId) {
    await write('notificationKey', initialMessage.messageId);
    await notificationService.init();
    _handleNotificationClick(initialMessage);
  }
}

void _handleNotificationClick(RemoteMessage message) async {
  if (Get.currentRoute != AppRouteNames.dashboard) {
    Get.offAllNamed(AppRouteNames.dashboard);
  }
  notificationService.createNotificationChat(message.data["title"] ?? AppConfig.appName, message.data["body"] ?? "No mention", AppConfig.appName);
  final ctrl = Get.isRegistered<DashboardCtrl>() ? Get.find<DashboardCtrl>() : Get.put(DashboardCtrl());
  ctrl.onTabChange(2);
  final availableBookingsCtrl = Get.isRegistered<AvailableBookingsCtrl>() ? Get.find<AvailableBookingsCtrl>() : Get.put(AvailableBookingsCtrl());
  await availableBookingsCtrl.loadData();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        builder: (BuildContext context, widget) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: widget!,
          );
        },
        debugShowCheckedModeBanner: false,
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        getPages: AppRouteMethods.pages,
        initialRoute: AppRouteNames.splash,
      ),
    );
  }
}
