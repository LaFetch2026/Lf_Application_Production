import 'dart:async'; // Keep for Future.delayed or if you want a fixed splash duration

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constant/constants.dart'; // Ensure this path is correct (for splashNewGif)
import '../bottomnavscreen.dart'; // Make sure this path is correct
import '../userdetails.dart'; // Make sure this path is correct
import '../welcomescreen.dart'; // This is now your primary unauthenticated entry point

class SplashTwoScreen extends StatefulWidget {
  const SplashTwoScreen({super.key});

  @override
  State<SplashTwoScreen> createState() => SplashTwoScreenState();
}

class SplashTwoScreenState extends State<SplashTwoScreen> {
  // Do not put HomeController here directly. Initialize it only when needed (e.g., in BottomNavScreen).
  // final homeController = Get.put(HomeController()); // Removed here

  @override
  void initState() {
    super.initState();
    // Start the navigation process immediately
    _initiateAppFlow();
  }

  Future<void> _initiateAppFlow() async {
    // Optional: Add a minimum splash screen display duration for better UX
    // Adjust this duration as needed for your splash animation/UI
    await Future.delayed(
        const Duration(milliseconds: 2000)); // Minimum 2 second display

    // Fetch preferences first
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? name = prefs.getString('name');
    final String? phone = prefs.getString('phonenumber');
    final bool? skip =
        prefs.getBool('skip'); // Assuming 'skip' means guest user

    print(
        "SplashTwoScreen: Token: ${token != null && token.isNotEmpty ? 'Present' : 'Absent'}");
    print("SplashTwoScreen: Name: ${name ?? 'N/A'}");
    print("SplashTwoScreen: Phone: ${phone ?? 'N/A'}");
    print("SplashTwoScreen: Skip (Guest): ${skip ?? false}");

    // --- Decision Logic for Navigation ---

    if (token != null && token.isNotEmpty) {
      // A token exists. Assume user is logged in or was a logged-in guest.
      // Check if user details (like name) are missing, implying incomplete profile.
      if (name != null && name.isNotEmpty) {
        // Token exists and name is present (fully logged in user)
        print("SplashTwoScreen: Navigating to BottomNavScreen (Full User)");
        Get.offAll(() => const BottomNavScreen());
      } else {
        // Token exists but name is missing (user logged in, but profile incomplete)
        print(
            "SplashTwoScreen: Navigating to UserDetailsScreen (Incomplete Profile)");
        Get.offAll(
            () => const UserDetailsScreen()); // Use Get.offAll for clean stack
      }
    } else {
      // No token found. User is either new, logged out, or previous token was invalid.
      // Send them to the initial onboarding/welcome screen.
      print(
          "SplashTwoScreen: No token found. Navigating to WelcomeScreen (New/Logged Out)");
      Get.offAll(() => const WelcomeScreen());
    }

    // Handle initial gender setup if needed, but ensure it doesn't cause errors
    // if HomeController is not yet initialized for a non-authenticated path.
    // If HomeController methods are used here, then it *must* be initialized,
    // but a better practice might be to handle gender initialization within
    // HomeController's onInit() or a dedicated user profile service.
    // Leaving this commented out to avoid potential issues if HomeController
    // expects a logged-in state.
    /*
    if (prefs.getInt('gender') != null) {
      int id = prefs.getInt('gender')!;
      if (id == 1) {
        Get.find<HomeController>().homeGenderValue.value = 3; // Ensure HomeController is ready
        Get.find<HomeController>().genderText.value = "Women";
      } else if (id == 2) {
        Get.find<HomeController>().homeGenderValue.value = 2;
        Get.find<HomeController>().genderText.value = "Men";
      }
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white, // Provide a solid background color during splash
      child: Image.asset(
        splashNewGif, // Ensure splashNewGif path is correct and asset exists
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }
}
