// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/app_button.dart';
import 'package:lafetch/commonwidget/singlebtn.dart';
import 'package:lafetch/utils/constants.dart';

import '../commonwidget/app_text.dart';
import '../commonwidget/theme_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final phoneNumber = TextEditingController();

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
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
          //  backgroundColor: blackColor,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20, left: 16),
                          child: AppText(
                            text: "Hey there,",
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w400,
                            color: btnTextColor,
                            fontSize: 25.sp,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, left: 16),
                          child: AppText(
                            text:
                                "Lets set you up around, for a tailored shopping experience",
                            maxLines: 2,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w400,
                            color: textColor,
                            fontSize: 14.sp,
                          ),
                        ),
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
                              borderColor: greyColor,
                              fontSize: 14.sp,
                              backgroundColor: whiteTextColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  width: 100,
                                  color: lightText,
                                  height: 1,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: AppText(
                                  text: "OR",
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w400,
                                  color: lightText,
                                  fontSize: 11.sp,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: 100,
                                  color: lightText,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration:
                                ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextField(
                              controller: phoneNumber,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              style: const TextStyle(color: textColor),
                              decoration: InputDecoration(
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: borderColor)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(1),
                                  borderSide:
                                      const BorderSide(color: borderColor),
                                ),
                                /*   errorText: isValidate
                                                  ? 'Please enter number'
                                                  : null, */
                                prefix: SizedBox(
                                  width: 50,
                                  child: Row(
                                    children: [
                                      AppText(
                                        text: "+91",
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w400,
                                        color: greyTextColor,
                                        fontSize: 14.sp,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Container(
                                          width: 1,
                                          color: textHintColor,
                                          height: 25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                counterText: "",
                                hintText: "Mobile Number",
                                hintStyle: const TextStyle(
                                    fontSize: 14, color: textHintColor),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "By continuing, I agree to the",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w400,
                                  color: greyTextColor,
                                ),
                              ),
                              Text(
                                " Terms of Use",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w400,
                                  color: deepGreytextColor,
                                ),
                              ),
                              Text(
                                " and",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w400,
                                  color: greyTextColor,
                                ),
                              ),
                              Text(
                                " Privacy Policy",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w400,
                                  color: deepGreytextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SingleButton(
                              label: "Continue",
                              textColor: whiteTextColor,
                              borderColor: colorPrimary,
                              fontSize: 14.sp,
                              backgroundColor: colorPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: whiteBorderColor,
                  child: const Center(
                      child: Text("signup",
                          style: TextStyle(
                              color: blackColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold))),
                ),
              ),
            ),
          ])),
    );
  }
}
