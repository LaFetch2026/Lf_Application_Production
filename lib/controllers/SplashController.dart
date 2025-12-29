import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/bottomnavscreen.dart';
import '../screens/welcomescreen.dart';

class SplashController extends GetxController {
  bool _navigated = false;

  @override
  void onReady() {
    super.onReady();
    _start();
  }

  Future<void> _start() async {
    final prefs = await SharedPreferences.getInstance();

    // Allow prefs to fully load
    await Future.delayed(const Duration(seconds: 3));

    final bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    final String? token = prefs.getString("token");

    // -------------------------
    // LOGGED-IN USER
    // -------------------------
    // ✅ Trust the token and let BottomNavScreen handle profile verification
    // BottomNavScreen's safeInitProfile() will fetch profile from server and handle errors
    if (isLoggedIn && token != null && token.isNotEmpty) {
      return _go(const BottomNavScreen());
    }

    // -------------------------
    // NEW USER
    // -------------------------
    _go(const WelcomeScreen());
  }

  void _go(Widget screen) {
    if (_navigated) return;
    _navigated = true;

    Future.microtask(() {
      Get.offAll(() => screen);
    });
  }
}
