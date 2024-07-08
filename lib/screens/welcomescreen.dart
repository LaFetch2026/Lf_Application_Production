// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/app_text.dart';
import 'package:lafetch/commonwidget/doublebtn.dart';
import 'package:lafetch/commonwidget/welcomewidgets/welcomebackground.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const WelcomeBackground(),
            Container(
              width: MediaQuery.of(context).size.width,
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
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 16, right: 16),
                    child: AppText(
                      text:
                          "In Delhi? Get your order delivered in just 6-hours. Quick, hassle-free checkouts & so much more’s waiting for you on the other side.",
                      fontFamily: "Franklin Gothic Regular",
                      maxLines: 3,
                      fontWeight: FontWeight.w400,
                      color: whiteTextColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 40),
              child: DoubleButton(
                firstText: "Create Account",
                secondText: "Sign In",
                firstTextColor: whiteTextColor,
                secondTextColor: btnTextColor,
                firstBackgroundColor: blackColor,
                secondBackgroundColor: whiteBorderColor,
                firstBorderColor: whiteBorderColor,
                secondBorderColor: whiteBorderColor,
                onPressedFirst: () async {
                  Get.to(
                    () => const LoginScreen(
                      initialTab: 1,
                    ),
                  );
                  await analytics.logEvent(
                    name: 'welcome_page_btncreateaccount',
                    parameters: <String, Object>{
                      'page_name': 'welcome_page_btncreateaccount',
                    },
                  );
                },
                onPressedSecond: () async {
                  Get.to(
                    () => const LoginScreen(
                      initialTab: 0,
                    ),
                  );
                  await analytics.logEvent(
                    name: 'welcome_page_btnsignin',
                    parameters: <String, Object>{
                      'page_name': 'welcome_page_btnsignin',
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
