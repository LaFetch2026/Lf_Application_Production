// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/app_button.dart';
import 'package:lafetch/commonwidget/loginwidgets/login_widget.dart';
import 'package:lafetch/commonwidget/loginwidgets/multiple_text.dart';
import 'package:lafetch/commonwidget/loginwidgets/number_widget.dart';
import 'package:lafetch/commonwidget/loginwidgets/or_widget.dart';
import 'package:lafetch/commonwidget/singlebtn.dart';
import 'package:lafetch/screens/otpverficationscreen.dart';
import 'package:lafetch/utils/constants.dart';

import '../commonwidget/app_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final phoneNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: blackColor,
            title: const Align(
              alignment: Alignment.topRight,
              child: AppText(
                text: "Skip",
                textAlign: TextAlign.right,
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w400,
                color: whiteTextColor,
                fontSize: 14,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                    isScrollable: true,
                    indicatorColor: whiteTextColor,
                    unselectedLabelColor: textHintColor,
                    labelColor: whiteBorderColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 2,
                    tabs: [
                      Tab(
                          child: Text(
                        "Sign In",
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w400),
                      )),
                      Tab(
                          child: Text(
                        "I’m new here",
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w400),
                      ))
                    ]),
              ),
            ),
          ),
          body: TabBarView(children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: whiteBorderColor,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LoginWidget(
                                text1: "Hey there,",
                                text2:
                                    "Lets set you up around, for a tailored shopping experience"),
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: AppButton(
                                  label: "Continue with Facebook",
                                  image: facebookImage,
                                  textColor: whiteColor,
                                  borderColor: blue,
                                  fontSize: 14.sp,
                                  backgroundColor: blue),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: AppButton(
                                  label: "Continue with Gmail",
                                  image: googleImage,
                                  textColor: greyTextColor,
                                  borderColor: colorSecondary,
                                  fontSize: 14.sp,
                                  backgroundColor: whiteTextColor),
                            ),
                            const ORWidget(),
                            Padding(
                              padding: const EdgeInsets.only(top: 20, left: 16),
                              child: AppText(
                                text: "Let’s quickly verify it’s you",
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w400,
                                color: loginText,
                                fontSize: 14.sp,
                              ),
                            ),
                            NumberWidget(controller: phoneNumber),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: SingleButton(
                                  label: "Continue",
                                  textColor: whiteTextColor,
                                  borderColor: colorPrimary,
                                  onPressed: () {
                                    Get.to(
                                      () => const OTPVerficationScreen(),
                                    );
                                  },
                                  fontSize: 14.sp,
                                  backgroundColor: colorPrimary),
                            ),
                            MultipleTextWidget(
                                fontSize: 11.sp,
                                text1: "By continuing, I agree to the",
                                text2: " Terms of Use",
                                text3: " and",
                                text4: " Privacy Policy")
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: whiteBorderColor,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LoginWidget(
                                text1: "Welcome Back!",
                                text2: "We are so glad to have you back here"),
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: AppButton(
                                  label: "Continue with Facebook",
                                  image: facebookImage,
                                  textColor: whiteColor,
                                  borderColor: blue,
                                  fontSize: 14.sp,
                                  backgroundColor: blue),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: AppButton(
                                  label: "Continue with Gmail",
                                  image: googleImage,
                                  textColor: greyTextColor,
                                  borderColor: colorSecondary,
                                  fontSize: 14.sp,
                                  backgroundColor: whiteTextColor),
                            ),
                            const ORWidget(),
                            Padding(
                              padding: const EdgeInsets.only(top: 20, left: 16),
                              child: AppText(
                                text: "Let’s quickly verify it’s you",
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w400,
                                color: loginText,
                                fontSize: 14.sp,
                              ),
                            ),
                            NumberWidget(controller: phoneNumber),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: SingleButton(
                                  label: "Continue",
                                  textColor: whiteTextColor,
                                  borderColor: colorPrimary,
                                  onPressed: () {
                                    Get.to(
                                      () => const OTPVerficationScreen(),
                                    );
                                  },
                                  fontSize: 14.sp,
                                  backgroundColor: colorPrimary),
                            ),
                            MultipleTextWidget(
                              text1: "By continuing, I agree to the",
                              text2: " Terms of Use",
                              text3: " and",
                              text4: "",
                              fontSize: 12.sp,
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Center(
                                child: Text(
                                  "Privacy Policy",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w400,
                                    color: deepGreytextColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ])),
    );
  }
}
