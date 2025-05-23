import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/firebase_options.dart';
import 'package:lafetch/screens/splash/splashtwo.dart';

import 'core/constant/constants.dart';
import 'core/utils/deeplink_handler.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: homeAppBarColor,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: homeAppBarColor,
  ));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

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
          theme: ThemeData(
            fontFamily: 'Franklin Gothic',
            primarySwatch: Colors.grey,
            textTheme: Typography.englishLike2018.apply(
              fontSizeFactor: 1.sp,
            ),
          ),
          home: const DeepLinkInitializer(), // 👈 Modified to inject handler
        );
      },
    );
  }
}

/// Wrapper widget to handle DeepLinkHandler init before landing on Splash
class DeepLinkInitializer extends StatefulWidget {
  const DeepLinkInitializer({super.key});

  @override
  State<DeepLinkInitializer> createState() => _DeepLinkInitializerState();
}

class _DeepLinkInitializerState extends State<DeepLinkInitializer> {
  bool _isDeepLinkReady = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  // Updated _initDeepLinks method with error handling and logging
  Future<void> _initDeepLinks() async {
    try {
      await DeepLinkHandler.init(context); // ✅ Init AppsFlyer Deeplink handler
      setState(() => _isDeepLinkReady = true);
      print('Deep link handler initialized successfully');
    } catch (e) {
      print('Error initializing deep link handler: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDeepLinkReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const SplashTwoScreen(); // Go to your splash screen after deep link setup
  }
}
