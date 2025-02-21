import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/home_controller.dart';
import 'package:lafetch/utils/constants.dart';
//import 'package:lottie/lottie.dart';
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
  String? token;
  String? name;
  String? phone;

  @override
  void initState() {
    super.initState();
    getPrefrenceValue();
    Timer(const Duration(milliseconds: 4400), () => navigateToScreen());
  }

  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    name = prefs.getString('name');
    phone = prefs.getString('phonenumber');
    /* if (prefs.getInt('gender') != null) {
      int id = prefs.getInt('gender')!;
      if (id == 1) {
        homeController.homeGenderValue.value = 3;
        homeController.genderText.value = "Women";
      } else if (id == 2) {
        homeController.homeGenderValue.value = 2;
        homeController.genderText.value = "Men";
      } else {}
    } */
  }

  navigateToScreen() {
    if (token != null) {
      if (token!.isNotEmpty && name != null) {
        Get.offAll(
          () => const BottomNavScreen(),
        );
      } else {
        if (phone == null) {
          Get.off(
            () => const WelcomeScreen(),
          );
        } else {
          Get.off(
            () => const UserDetailsScreen(),
          );
        }
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
      //color: colorPrimary,
      child: Image.asset(
        splashNewGif,
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),
      /*  Lottie.asset(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          splashLottie,
        ) */
    );
  }
}
