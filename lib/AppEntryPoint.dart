import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/splash/splashtwo.dart';
import 'package:lafetch/utils/deeplink_handler.dart';

class EntryPointApp extends StatefulWidget {
  const EntryPointApp({super.key});

  @override
  State<EntryPointApp> createState() => _EntryPointAppState();
}

class _EntryPointAppState extends State<EntryPointApp> {
  @override
  void initState() {
    super.initState();
    DeepLinkHandler.init(context); // set up listeners only
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      useInheritedMediaQuery: true,
      builder: (_, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lafetch',
        theme: ThemeData(
          fontFamily: 'Franklin Gothic',
          primarySwatch: Colors.grey,
          textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
        ),
        home: const SplashTwoScreen(),
      ),
    );
  }
}
