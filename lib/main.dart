import 'dart:ui';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/firebase_options.dart';
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/splash/splash.dart';
import 'package:lafetch/utils/constants.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: homeAppBarColor,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final AppLinks appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) {
    // ignore: unnecessary_null_comparison
    if (uri != null) {
      String original = uri.toString();
      String toRemove = "https://shop.la-fetch.com/ ";
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
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          /*  getPages: [
            GetPage(name: '/', page: () => SplashScreen()),
            GetPage(
              name: '/products',
              page: () => ProductDetailsScreen(
                productId: 0,
                type: "add",
                Slug: "womens-salwar-suit-set",
              ),
            ),
          ], */
          home: const SplashScreen(),
        );
      },
    );
  }
}
