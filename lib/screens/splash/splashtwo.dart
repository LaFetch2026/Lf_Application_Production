// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/controllers/SplashController.dart';
import '../../core/constant/constants.dart';

class SplashTwoScreen extends StatefulWidget {
  const SplashTwoScreen({super.key});

  @override
  State<SplashTwoScreen> createState() => _SplashTwoScreenState();
}

class _SplashTwoScreenState extends State<SplashTwoScreen> {
  @override
  void initState() {
    super.initState();

    // ⭐ Run controller AFTER first frame is drawn — fixes welcome flash & splash delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Remove old instance to avoid multiple splash runs
      if (Get.isRegistered<SplashController>()) {
        Get.delete<SplashController>(force: true);
      }

      // Create the controller (will auto-navigate)
      Get.put(SplashController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset(
          splashNewGif,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
