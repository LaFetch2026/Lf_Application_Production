// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../commonwidget/common_widgets.dart';
import '../commonwidget/loginwidgets/number_widget.dart';
import '../controller/login_controller.dart';
import '../utils/constants.dart';

class SocialMediaLoginScreen extends StatefulWidget {
  final String email;
  final String name;
  final String provider;
  const SocialMediaLoginScreen(
      {super.key,
      required this.name,
      required this.email,
      required this.provider});

  @override
  State<SocialMediaLoginScreen> createState() => SocialMediaLoginScreenState();
}

class SocialMediaLoginScreenState extends State<SocialMediaLoginScreen> {
  final loginController = Get.put(LoginController());

  @override
  void initState() {
    loginController.phoneNumberRegister.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackButtonAppbar(
                    text: "Login",
                    threeDot: false,
                    icon: threeDotImage,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: NumberWidget(
                        readonly: false,
                        controller: loginController.phoneNumberRegister),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: getSingleButton(
                label: "Continue",
                textColor: whiteTextColor,
                borderColor: colorPrimary,
                controller: loginController,
                backgroundColor: colorPrimary,
                onPressed: () {
                  if (loginController.checkNumbervalidation(loginController
                      .phoneNumberRegister.text
                      .toString()
                      .trim())) {
                    /* loginController.number.value =
                        "+91${loginController.phoneNumberRegister.text.toString().trim()}";
                    loginController.callSocailMediaRegister(
                        widget.name, widget.email, widget.provider); */
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
