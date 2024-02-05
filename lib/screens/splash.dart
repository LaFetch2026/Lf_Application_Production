import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lafetch/screens/welcomescreen.dart';

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
    /*  if (token != null) {
      if (token!.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (BuildContext context) => const HomeScreen()),
        );
      }
    } else { */
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (BuildContext context) => const WelcomeScreen()),
    );
    //  }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/splash.gif"),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
