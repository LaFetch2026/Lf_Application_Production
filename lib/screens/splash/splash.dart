import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/splash/splashtwo.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:app_links/app_links.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  String? token;
  String? name;
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );
  final AppLinks appLinks = AppLinks();
  @override
  void initState() {
    super.initState();
    appLinks.uriLinkStream.listen((uri) {
      // ignore: unnecessary_null_comparison
      if (uri != null) {
        // Navigate to the specific screen based on the URI
        print('Received URI: $uri');
        Get.to(ProductDetailsScreen(
          productId: 0,
          type: "add",
          Slug: "womens-salwar-suit-set",
        ));
      }
    });
    Timer(const Duration(milliseconds: 500), () => nextScreen());
  }

  Route scaleIn(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, page) {
        var begin = 0.0;
        var end = 1.0;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return ScaleTransition(
          scale: animation.drive(tween),
          child: page,
        );
      },
    );
  }

  void nextScreen() {
    Navigator.push(context, scaleIn(const SplashTwoScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: whiteBorderColor,
      ),
      child: Center(
        child: Container(
            width: 120.sp,
            height: 120.sp,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(logoBackImage), fit: BoxFit.cover)),
            child: Center(
              child: Image.asset(logoImage,
                  height: 75.sp, width: 50.sp, fit: BoxFit.cover),
            )),
      ),
    );
  }
}
