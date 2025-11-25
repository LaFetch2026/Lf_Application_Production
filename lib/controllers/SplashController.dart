import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/home_controller.dart';
import '../../core/utils/deeplink_handler.dart';
import '../screens/bottomnavscreen.dart';
import '../screens/userdetails.dart';
import '../screens/welcomescreen.dart';

class SplashController extends GetxController {
  static bool abortSplashFlow = false; // shared guard
  static bool _bootstrapped = false;

  bool _navigated = false;
  Timer? _delayTimer;

  late final HomeController homeController = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController(), permanent: true);

  @override
  void onReady() {
    super.onReady();

    if (_bootstrapped) return;
    _bootstrapped = true;

    _initSplashFlow();
  }

  Future<void> _initSplashFlow() async {
    // Small delay to allow bindings
    // await Future.delayed(const Duration(milliseconds: 200));

    final prefs = await SharedPreferences.getInstance();
    final bool isGuest = prefs.getBool('isGuest') ?? false;
    final bool skip = prefs.getBool('skip') ?? false;

    // ============================================
    //   FIXED — Guest / Skip should NAVIGATE,
    //   NOT abort the splash flow.
    // ============================================
    if (isGuest || skip) {
      if (kDebugMode) print('🟢 Guest mode detected — navigating instantly');
      await handleNavigation(); // Immediate navigation
      return;
    }

    // Try deep link init safely
    try {
      final ctx = Get.key.currentContext ?? Get.overlayContext;
      if (ctx != null) await DeepLinkHandler.init(ctx);
    } catch (_) {}

    // Normal splash delay
    _delayTimer = Timer(const Duration(seconds: 1), () async {
      if (abortSplashFlow) {
        if (kDebugMode) print('🚫 Splash aborted mid-delay (Skip pressed)');
        return;
      }
      await handleNavigation();
    });
  }

  Future<void> handleNavigation() async {
    if (_navigated || abortSplashFlow) return;
    _navigated = true;

    final prefs = await SharedPreferences.getInstance();

    final bool isGuest = prefs.getBool('isGuest') ?? false;
    final bool skip = prefs.getBool('skip') ?? false;

    // ==================================================
    //   GUEST / SKIP → Direct to BottomNavScreen
    // ==================================================
    if (isGuest || skip) {
      if (kDebugMode) print('🟢 Guest mode → BottomNavScreen (no flicker)');
      _goTo(const BottomNavScreen());
      return;
    }

    // ==================================================
    //               AUTHENTICATION FLOW
    // ==================================================
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String? token = prefs.getString('token');
    final String? name = prefs.getString('name');
    final String? phone = prefs.getString('phonenumber');

    if (isLoggedIn && token != null && token.isNotEmpty) {
      if (name != null && name.isNotEmpty) {
        if (kDebugMode) print('✅ Authenticated → BottomNavScreen');
        _goTo(const BottomNavScreen());
      } else if (phone != null && phone.isNotEmpty) {
        if (kDebugMode) print('🟡 Incomplete profile → UserDetailsScreen');
        _goTo(const UserDetailsScreen());
      } else {
        if (kDebugMode) print('⚠️ Missing user info → WelcomeScreen');
        _goTo(const WelcomeScreen());
      }
      return;
    }

    // ==================================================
    //                DEFAULT → WELCOME
    // ==================================================
    if (kDebugMode) print('🔴 No login/guest → WelcomeScreen');
    _goTo(const WelcomeScreen());
  }

  void _goTo(Widget screen) {
    Future.microtask(() async {
      if (abortSplashFlow) return;

      if (Get.isRegistered<SplashController>()) {
        Get.delete<SplashController>(force: true);
      }

      Get.offAll(() => screen);
    });
  }

  @override
  void onClose() {
    _delayTimer?.cancel();
    super.onClose();
  }
}
