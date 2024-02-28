import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/welcomescreen.dart';
import 'package:lafetch/utils/constants.dart';

class SplashThreeScreen extends StatefulWidget {
  const SplashThreeScreen({super.key});

  @override
  State<SplashThreeScreen> createState() => SplashThreeScreenState();
}

class SplashThreeScreenState extends State<SplashThreeScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () => nextScreen());
  }

  void nextScreen() {
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
        gradient: LinearGradient(
          colors: [
            btnTextColor,
            Color(0xFF241736),
            Color(0xFF1D132C),
            Color(0xFF130C1C),
            Color(0xFF040206),
            blackColor,
          ],
        ),
      ),
      child: Center(
          child: Center(
        child: Image.asset(appNameImage,
            height: 60, width: 150, fit: BoxFit.cover),
      )),
    );
  }
}
