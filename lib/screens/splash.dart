import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lafetch/screens/welcomescreen.dart';
import 'package:lafetch/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? token;
  String? name;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () => nextScreen());
  }

  void nextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (BuildContext context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: blackColor,
        /* image: DecorationImage(
          image: AssetImage("assets/splash.gif"),
          fit: BoxFit.fill,
        ), */
      ),
    );
  }
}
