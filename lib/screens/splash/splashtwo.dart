import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/splash/splashthree.dart';
import 'package:lafetch/utils/constants.dart';

class SplashTwoScreen extends StatefulWidget {
  const SplashTwoScreen({super.key});

  @override
  State<SplashTwoScreen> createState() => SplashTwoScreenState();
}

class SplashTwoScreenState extends State<SplashTwoScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () => nextScreen());
  }

  void nextScreen() {
    Get.offAll(
      () => const SplashThreeScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: colorPrimary,
      ),
      child: Center(
          child: Center(
        child: Image.asset(logoImage, height: 82, width: 50, fit: BoxFit.cover),
      )),
    );
  }
}
