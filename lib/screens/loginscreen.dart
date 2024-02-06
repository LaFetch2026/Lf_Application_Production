// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/app_text.dart';
import 'package:lafetch/utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  onPressCreateAccount() {
    print("back");
  }

  onPressSignInButton() {
    /*  Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (BuildContext context) => const WelcomeScreen()),
    ); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 280,
                color: blackColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 16),
                      child: AppText(
                        text: "Welcome to Lafetch!",
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w500,
                        color: whiteTextColor,
                        fontSize: 22.sp,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
