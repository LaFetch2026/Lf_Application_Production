// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/home_controller.dart';
import 'controllers/login_controller.dart';
import 'firebase_options.dart';
import 'core/constant/constants.dart';
import 'screens/splash/splashtwo.dart';

/// Background FCM handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔔 Background message received: ${message.notification?.title}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // -------------------------------------------------------
  // REGISTER ALL GLOBAL CONTROLLERS BEFORE runApp()
  // -------------------------------------------------------
  if (!Get.isRegistered<LoginController>()) {
    Get.put(LoginController(), permanent: true);
  }

  if (!Get.isRegistered<HomeController>()) {
    Get.put(HomeController(), permanent: true);
  }

  // ---------------- Firebase Init -----------------------
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    debugPrint('❌ Firebase initialization failed: $e');
    await FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
  }

  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final prefs = await SharedPreferences.getInstance();
  await _initPushNotifications(prefs);

  // UI Setup
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: homeAppBarColor,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: homeAppBarColor,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _sendFcmTokenIfLoggedIn();

  runApp(const MyApp());
}

Future<void> _sendFcmTokenIfLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('pending_fcm_token');

  if (token != null && token.isNotEmpty) {
    final userId = prefs.getInt('userId') ?? 0;
    final authToken = prefs.getString('token')?.trim() ?? '';

    if (userId > 0 && authToken.isNotEmpty) {
      final homeController = Get.find<HomeController>();
      await homeController.sendFcmToken(
        userId: userId,
        token: token,
        deviceType: Platform.isAndroid ? "android" : "ios",
      );
      print('✅ FCM Token sent to server');
    } else {
      print('⚠️ User is not logged in yet, will send token later.');
    }
  }
}

Future<void> _initPushNotifications(prefs) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Important notifications.',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((message) {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  });

  if (Platform.isIOS) {
    String? apnsToken;
    for (int i = 0; i < 5; i++) {
      apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) break;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  String? token = await messaging.getToken();
  print("📱 FCM Token: $token");

  if (token != null && token.isNotEmpty) {
    await prefs.setString('pending_fcm_token', token);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (_, __) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Lafetch",
          // No initialBinding needed anymore
          home: const SplashTwoScreen(),
        );
      },
    );
  }
}
