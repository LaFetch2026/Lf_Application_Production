// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
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
import 'screens/home/women/homescreen.dart' show routeObserver;

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
  // CLEAN UP GetX on hot restart/reload
  // -------------------------------------------------------
  if (kDebugMode) {
    // Clear all GetX instances on hot restart
    Get.deleteAll(force: true);
  }

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
    // ✅ Silently skip non-critical cache cleanup errors
    if (error is PathNotFoundException &&
        error.path.toString().contains('Cache')) {
      return true;
    }
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
  try {
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

        // Clear pending token after successful send
        await prefs.remove('pending_fcm_token');
      } else {
        print('⚠️ User is not logged in yet, will send token later.');
      }
    } else {
      print('⚠️ No pending FCM token found');
    }
  } catch (e, stackTrace) {
    print('❌ Error sending FCM token: $e');
    await FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}

Future<void> _initPushNotifications(prefs) async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions first
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('⚠️ User denied notification permissions');
      return;
    }

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Android notification channel setup
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

    // Initialize local notifications
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Foreground message listener
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

    // iOS APNS Token - Wait longer with more retries
    if (Platform.isIOS) {
      String? apnsToken;
      for (int i = 0; i < 10; i++) {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          print("✅ APNS Token obtained: $apnsToken");
          break;
        }
        print("⏳ Waiting for APNS token... attempt ${i + 1}");
        await Future.delayed(Duration(seconds: i < 5 ? 1 : 2));
      }

      if (apnsToken == null) {
        print('⚠️ Could not obtain APNS token after retries');
      }
    }

    // Get FCM Token with retry logic and error handling
    String? token;
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        token = await messaging.getToken();
        if (token != null && token.isNotEmpty) {
          print("📱 FCM Token obtained: $token");
          await prefs.setString('pending_fcm_token', token);
          break;
        }
        // If token is null, wait briefly before retry
        if (attempt < 2) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        print("⚠️ FCM Token retrieval attempt ${attempt + 1} failed: $e");
        // Shorter delay between retries
        if (attempt < 2) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    if (token == null) {
      print('⚠️ Failed to obtain FCM token after retries. Push notifications may not work.');
      print('   This is normal in simulators/emulators. On real devices, check:');
      print('   - Firebase project configuration');
      print('   - google-services.json (Android) or GoogleService-Info.plist (iOS)');
      print('   - APNS certificates (iOS)');
    }

    // Listen for token refresh
    messaging.onTokenRefresh.listen((newToken) {
      print("🔄 FCM Token refreshed: $newToken");
      prefs.setString('pending_fcm_token', newToken);
      _sendFcmTokenIfLoggedIn();
    });
  } catch (e, stackTrace) {
    print('❌ Error initializing push notifications: $e');
    await FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
          // Always start from SplashTwoScreen
          home: const SplashTwoScreen(),
          // Add this to ensure clean navigation on hot restart
          navigatorObservers: [GetObserver(), routeObserver],
          // Enable iOS-style swipe-to-go-back on both platforms
          defaultTransition: Transition.cupertino,
          // Configure page transitions for swipe gesture
          theme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
        );
      },
    );
  }
}
