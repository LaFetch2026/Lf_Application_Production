import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/bottomnavscreen.dart';
import '../screens/userdetails.dart';
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
    await Future.delayed(const Duration(milliseconds: 80));

    final bool skipped = prefs.getBool("skip") ?? false;
    final bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    final String? token = prefs.getString("token");

    // -------------------------
    // GUEST MODE
    // -------------------------
    if (skipped && !isLoggedIn && (token == null || token.isEmpty)) {
      return _go(const BottomNavScreen());
    }

    // -------------------------
    // LOGGED-IN USER
    // -------------------------
    if (isLoggedIn && token != null && token.isNotEmpty) {
      final name = prefs.getString("name");
      final phone = prefs.getString("phonenumber");

      if (name != null && name.isNotEmpty) {
        return _go(const BottomNavScreen());
      }

      if (phone != null && phone.isNotEmpty) {
        return _go(const UserDetailsScreen());
      }

      return _go(const WelcomeScreen());
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
