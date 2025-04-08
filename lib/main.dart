import 'dart:ui';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lafetch/firebase_options.dart';
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/splash/splashtwo.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:lafetch/utils/analytics_helper.dart'; // ✅ Make sure this path is correct

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Log App Install only once
  final prefs = await SharedPreferences.getInstance();
  bool? hasInstalled = prefs.getBool('app_install_logged');
  if (hasInstalled != true) {
    AnalyticsHelper.logAppInstall();
    await prefs.setBool('app_install_logged', true);
  }

  // ✅ Always log app launch
  AnalyticsHelper.logAppLaunch();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: homeAppBarColor,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: homeAppBarColor));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  final AppLinks appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) {
    if (uri != null) {
      String original = uri.toString();
      String toRemove = "https://shop.la-fetch.com/";
      String result = original.replaceAll(toRemove, "");
      List<String> parts = result.split('/');
      if (parts[0] == "products") {
        Get.to(ProductDetailsScreen(
          productId: 0,
          type: "add",
          brandName: "",
          Slug: parts[1],
        ));
      } else {
        Get.to(AllBrandScreen(
          screen: "home",
          id: 0,
          slug: parts[1],
        ));
      }
      print('Received URI: $uri');
    }
  });

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
          home: const SplashTwoScreen(),
        );
      },
    );
  }
}
