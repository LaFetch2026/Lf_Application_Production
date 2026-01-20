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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Force clean state on every load
      Get.delete<SplashController>(force: true);

      // Ensure we're at the root route
      while (Get.currentRoute != '/') {
        Get.back();
      }

      // Create fresh controller
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
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
