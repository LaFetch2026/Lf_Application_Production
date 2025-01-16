import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/home_controller.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bottomnavscreen.dart';
import '../userdetails.dart';
import '../welcomescreen.dart';

class SplashTwoScreen extends StatefulWidget {
  const SplashTwoScreen({super.key});

  @override
  State<SplashTwoScreen> createState() => SplashTwoScreenState();
}

class SplashTwoScreenState extends State<SplashTwoScreen> {
  final homeController = Get.put(HomeController());
  String _authStatus = 'Unknown';
  String? token;
  String? name;

  @override
  void initState() {
    super.initState();
    getPrefrenceValue();
    Timer(const Duration(seconds: 1), () => navigateToScreen());
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((_) => initPlugin());
  }

  Future<void> initPlugin() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      // Show a custom explainer dialog before the system dialog
      await showCustomTrackingDialog(context);
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      final TrackingStatus status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$status');
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $uuid");
    print("value: $_authStatus");
  }

  Future<void> showCustomTrackingDialog(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dear User'),
          content: const Text(
            'We care about your privacy and data security. We keep this app free by showing ads. '
            'Can we continue to use your data to tailor ads for you?\n\nYou can change your choice anytime in the app settings. '
            'Our partners will collect data and use a unique identifier on your device to show you ads.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    name = prefs.getString('name');
    if (prefs.getInt('gender') != null) {
      int id = prefs.getInt('gender')!;
      if (id == 1) {
        homeController.homeGenderValue.value = 3;
        homeController.genderText.value = "Women";
      } else if (id == 2) {
        homeController.homeGenderValue.value = 2;
        homeController.genderText.value = "Men";
      } else {}
    }
  }

  navigateToScreen() {
    if (token != null) {
      if (token!.isNotEmpty && name != null) {
        Get.offAll(
          () => const BottomNavScreen(),
        );
      } else {
        Get.off(
          () => const UserDetailsScreen(),
        );
      }
    } else {
      Get.offAll(
        () => const WelcomeScreen(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: colorPrimary,
      child: Image.asset(
        splashGif,
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }
}
