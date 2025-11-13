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
import 'package:lafetch/controllers/home_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'core/constant/constants.dart';
import 'core/utils/analytics_helper.dart';
import 'screens/splash/splashtwo.dart';
import 'controllers/login_controller.dart';

/// ✅ Background handler (required for terminated / background notifications)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔔 Background message received: ${message.notification?.title}");
}

/// ✅ Local notification plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // --- Initialize Firebase ---
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    debugPrint('❌ Firebase initialization failed: $e');
    await FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
  }

  // --- Crashlytics wiring ---
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // // --- Analytics (Release mode only) ---
  // if (kReleaseMode) {
  //   AnalyticsHelper.logAppInstall();
  //   AnalyticsHelper.logAppLaunch();
  // }

  // --- FCM setup ---
  final prefs = await SharedPreferences.getInstance();
  await _initPushNotifications(prefs);

  // --- UI setup ---
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: homeAppBarColor,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: homeAppBarColor,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // --- Send FCM token if exists and user is logged in ---
  await _sendFcmTokenIfLoggedIn();

  runApp(const MyApp());
}

/// ------------------------------------------------------------
/// Send FCM Token if the user is logged in
/// ------------------------------------------------------------
Future<void> _sendFcmTokenIfLoggedIn() async {
  // Create an instance of SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Get the stored FCM token
  String? token = prefs.getString('pending_fcm_token');

  if (token != null && token.isNotEmpty) {
    print('📱 FCM Token retrieved from local storage: $token');

    // Ensure user is logged in before sending the token
    final userId = prefs.getInt('userId') ?? 0;
    final authToken = prefs.getString('token')?.trim() ?? '';

    if (userId > 0 && authToken.isNotEmpty) {
      final homeController = Get.put(HomeController());
      await homeController.sendFcmToken(
        userId: userId,
        token: token,
        deviceType: Platform.isAndroid ? "android" : "ios",
      );
      print('✅ FCM Token sent to server');
    } else {
      print('⚠️ User is not logged in, FCM token will be sent later');
    }
  }
}

/// ------------------------------------------------------------
/// Initialize Push Notifications
/// ------------------------------------------------------------
Future<void> _initPushNotifications(dynamic prefs) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Ask user permission (especially for iOS)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('🔔 Notification permission: ${settings.authorizationStatus}');

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Create a notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Initialize local notifications (Android + iOS + macOS)
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📩 Foreground message received: ${message.notification?.title}');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  });

  // iOS APNs token handling
  if (Platform.isIOS) {
    String? apnsToken;

    // Wait for APNs token to be available
    for (int i = 0; i < 5; i++) {
      apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) break;
      print("⏳ Waiting for APNs token...");
      await Future.delayed(const Duration(seconds: 1));
    }

    if (apnsToken == null) {
      print("⚠️ APNs token still not available after waiting.");
      return;
    }

    print("🍏 APNs Token acquired: $apnsToken");
  }

  // Retrieve and store FCM token
  String? token = await messaging.getToken();
  print('📱 FCM Token retrieved: $token');

  if (token != null && token.isNotEmpty) {
    await prefs.setString('pending_fcm_token', token);
    print('✅ FCM token stored locally, will send after login');
  }

  // Handle token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print('🔁 FCM Token refreshed: $newToken');
    await prefs.setString('pending_fcm_token', newToken);
    await _sendFcmTokenIfLoggedIn(); // Send token if user is logged in
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      useInheritedMediaQuery: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lafetch',
          initialBinding: BindingsBuilder(() {
            if (!Get.isRegistered<LoginController>()) {
              Get.lazyPut<LoginController>(() => LoginController(),
                  fenix: true);
            }
          }),
          theme: ThemeData(
            fontFamily: 'Franklin Gothic',
            primarySwatch: Colors.grey,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          home: const SplashTwoScreen(),
        );
      },
    );
  }
}
