import 'dart:ui';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:lafetch/firebase_options.dart';
import 'package:lafetch/screens/splash/splashtwo.dart';
import 'package:lafetch/utils/analytics_helper.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AppEntryPoint.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await FacebookAppEvents().setAutoLogAppEventsEnabled(true);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  bool? hasInstalled = prefs.getBool('app_install_logged');
  if (hasInstalled != true) {
    AnalyticsHelper.logAppInstall();
    await prefs.setBool('app_install_logged', true);
  }

  AnalyticsHelper.logAppLaunch();

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

  runApp(const EntryPointApp());
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
          home: const SplashTwoScreen(),
        );
      },
    );
  }
}
