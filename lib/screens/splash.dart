import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/welcomescreen.dart';
import 'package:lafetch/utils/constants.dart';

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
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () => nextScreen());
  }

  void nextScreen() {
    /*  Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (BuildContext context) => const WelcomeScreen()),
    ); */
    Get.offAll(
      () => const WelcomeScreen(),
    );
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
          child: ScaleTransition(
        scale: animation,
        child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(logoBackImage), fit: BoxFit.cover)),
            child: Center(
              child: Image.asset(logoImage,
                  height: 50, width: 50, fit: BoxFit.cover),
            )),
      )),
    );
  }
}
