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
  late final SplashController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(SplashController()); // no permanent:true

    Future.delayed(const Duration(seconds: 2), () async {
      await _controller.handleNavigation(); // ✅ now accessible
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
