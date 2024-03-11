// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lafetch/commonwidget/app_button.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/loginwidgets/login_widget.dart';
import 'package:lafetch/commonwidget/loginwidgets/multiple_text.dart';
import 'package:lafetch/commonwidget/loginwidgets/number_widget.dart';
import 'package:lafetch/commonwidget/loginwidgets/or_widget.dart';
import 'package:lafetch/utils/constants.dart';

import '../commonwidget/app_text.dart';
import '../controller/login_controller.dart';
import 'bottomnavscreen.dart';

class LoginScreen extends StatefulWidget {
  final int initialTab;
  const LoginScreen({required this.initialTab, super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final loginController = Get.put(LoginController());
  Color appbarColor = colorPrimary;

  @override
  void initState() {
    if (widget.initialTab == 0) {
      appbarColor = colorPrimary;
    } else {
      appbarColor = btnTextColor;
    }
    setState(() {});
    super.initState();
  }

  void googleSignInProcess(BuildContext context) async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      String? token = googleAuth.idToken;
      print("name ${googleUser.displayName}");
      print("email ${googleUser.email}");
      print("photoUrl ${googleUser.photoUrl}");
      print("id ${googleUser.id}");
      print("token $token");
      if (googleUser.displayName != null) {
        Get.to(const BottomNavScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: appbarColor,
              title: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      () => const BottomNavScreen(),
                    );
                  },
                  child: const AppText(
                    text: "Skip",
                    textAlign: TextAlign.right,
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: whiteTextColor,
                    fontSize: 14,
                  ),
                ),
              ),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(40),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                        isScrollable: true,
                        onTap: (value) {
                          if (appbarColor == btnTextColor) {
                            appbarColor = colorPrimary;
                          } else {
                            appbarColor = btnTextColor;
                          }
                          setState(() {});
                        },
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
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400),
                          )),
                          Tab(
                              child: Text(
                            "I’m new here",
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400),
                          ))
                        ]),
                  )),
            ),
            body: TabBarView(children: [
              Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: whiteTextColor,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const LoginWidget(
                            text1: "Welcome Back!",
                            fontfamily: "Franklin Gothic",
                            text2: "We are so glad to have you back here"),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: AppButton(
                              label: "Continue with Facebook",
                              fontFamily: "Franklin Gothic Regular",
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
                              fontFamily: "Franklin Gothic Regular",
                              image: googleImage,
                              textColor: greyTextColor,
                              onPressed: () {
                                //  signup(context);
                                googleSignInProcess(context);
                              },
                              borderColor: colorSecondary,
                              fontSize: 14.sp,
                              backgroundColor: whiteTextColor),
                        ),
                        const ORWidget(),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, left: 16),
                          child: AppText(
                            text: "Let’s quickly verify it’s you",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: loginText,
                            fontSize: 14.sp,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: NumberWidget(
                              controller: loginController.phoneNumberLogin),
                        ),
                        Obx(
                          () => Padding(
                            padding: const EdgeInsets.only(top: 40, bottom: 10),
                            child: getSingleButton(
                                label: "Continue",
                                textColor: whiteTextColor,
                                borderColor: colorPrimary,
                                controller: loginController,
                                onPressed: () {
                                  if (loginController.checkNumbervalidation(
                                      loginController.phoneNumberLogin.text
                                          .toString()
                                          .trim())) {
                                    loginController.number.value =
                                        "+91${loginController.phoneNumberLogin.text.toString().trim()}";
                                    loginController.callRegisterAccount();
                                  }
                                },
                                fontSize: 14.sp,
                                backgroundColor: colorPrimary),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: MultipleTextWidget(
                              fontSize: 11.sp,
                              text1: "By continuing, I agree to the",
                              text2: " Terms of Use",
                              text3: " and",
                              text4: " Privacy Policy"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: whiteTextColor,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const LoginWidget(
                            fontfamily: "Franklin Gothic Regular",
                            text1: "Hey there,",
                            text2:
                                "Lets set you up around, for a tailored shopping experience"),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: AppButton(
                              label: "Continue with Facebook",
                              image: facebookImage,
                              fontFamily: "Franklin Gothic Regular",
                              textColor: whiteColor,
                              borderColor: blue,
                              fontSize: 14.sp,
                              backgroundColor: blue),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: AppButton(
                              label: "Continue with Gmail",
                              fontFamily: "Franklin Gothic Regular",
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
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: loginText,
                            fontSize: 14.sp,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: NumberWidget(
                              controller: loginController.phoneNumberRegister),
                        ),
                        Obx(
                          () => Padding(
                            padding: const EdgeInsets.only(top: 40, bottom: 10),
                            child: getSingleButton(
                                label: "Continue",
                                textColor: whiteTextColor,
                                borderColor: colorPrimary,
                                controller: loginController,
                                onPressed: () {
                                  if (loginController.checkNumbervalidation(
                                      loginController.phoneNumberRegister.text
                                          .toString()
                                          .trim())) {
                                    loginController.number.value =
                                        "+91${loginController.phoneNumberRegister.text.toString().trim()}";
                                    loginController.callRegisterAccount();
                                  }
                                },
                                fontSize: 14.sp,
                                backgroundColor: colorPrimary),
                          ),
                        ),
                        MultipleTextWidget(
                          text1: "By continuing, I agree to the",
                          text2: " Terms of Use",
                          text3: " and",
                          text4: "",
                          fontSize: 12.sp,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: GestureDetector(
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ])),
      ),
    );
  }
}
