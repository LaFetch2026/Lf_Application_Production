// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/app_text.dart';
import 'package:lafetch/commonwidget/doublebtn.dart';
import 'package:lafetch/commonwidget/welcomewidgets/welcomebackground.dart';
import 'package:lafetch/controller/login_controller.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final loginController = Get.put(LoginController());
  /*  late AnimationController _controller;
  late Animation<Offset> _animation;
  late AnimationController _longtextcontroller;
  late Animation<Offset> _longTextanimation; */

  /*  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    _animation = Tween<Offset>(
      begin: const Offset(-0.9, 0.0),
      end: const Offset(-0.2, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    ));
    _longtextcontroller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    _longTextanimation = Tween<Offset>(
      begin: const Offset(-0.9, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _longtextcontroller,
      curve: Curves.easeInCubic,
    ));
  } */

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
                    padding: EdgeInsets.only(top: 20.sp, left: 16.sp),
                    child: AppText(
                      text: "Welcome to Lafetch!",
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w500,
                      color: whiteTextColor,
                      fontSize: 22,
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 20.sp, left: 16.sp, right: 16.sp),
                    child: AppText(
                      text:
                          "In Delhi? Get your order delivered in just 6-hours. Quick, hassle-free checkouts & so much more’s waiting for you on the other side.",
                      fontFamily: "Franklin Gothic Regular",
                      maxLines: 3,
                      fontWeight: FontWeight.w400,
                      color: whiteTextColor,
                      fontSize: 14,
                    ),
                  ),
                  /*   Builder(
                      builder: (context) => Center(
                            child: SlideTransition(
                              position: _animation,
                              child: Padding(
                                padding:
                                    EdgeInsets.only(top: 20.sp, left: 16.sp),
                                child: AppText(
                                  text: "Welcome to Lafetch!",
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w500,
                                  color: whiteTextColor,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          )),
                  Builder(
                      builder: (context) => Center(
                            child: SlideTransition(
                              position: _longTextanimation,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 20.sp, left: 16.sp, right: 16.sp),
                                child: AppText(
                                  text:
                                      "In Delhi? Get your order delivered in just 6-hours. Quick, hassle-free checkouts & so much more’s waiting for you on the other side.",
                                  fontFamily: "Franklin Gothic Regular",
                                  maxLines: 3,
                                  fontWeight: FontWeight.w400,
                                  color: whiteTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )),
                */
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30.sp),
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
            GestureDetector(
              onTap: () {
                loginController.callGuestUser();
              },
              child: Obx(() => loginController.isGuest.value
                  ? Transform.scale(
                      scale: 0.3.sp,
                      child: const CircularProgressIndicator(
                        color: whiteColor,
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(
                          top: 12.sp, left: 12.sp, right: 12.sp, bottom: 40.sp),
                      child: AppText(
                        text: "CONTINUE AS GUEST".toUpperCase(),
                        textAlign: TextAlign.right,
                        fontFamily: "Franklin Gothic bold",
                        fontWeight: FontWeight.w600,
                        color: whiteColor,
                        fontSize: 12,
                      ),
                    )),
            ),
          ],
        ),
      ),
    );
  }
}
