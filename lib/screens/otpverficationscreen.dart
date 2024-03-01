// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/app_text.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../commonwidget/common_widgets.dart';
import '../controller/login_controller.dart';

class OTPVerficationScreen extends StatefulWidget {
  final String phoneMunber;
  const OTPVerficationScreen({required this.phoneMunber, super.key});

  @override
  State<OTPVerficationScreen> createState() => OTPVerficationScreenState();
}

class OTPVerficationScreenState extends State<OTPVerficationScreen> {
  final otpController = Get.put(LoginController());
  @override
  void initState() {
    otpController.showButton.value = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: whiteTextColor,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 280,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(otpImage), fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 16),
                      child: AppText(
                        text: "Enter your\nVerification Code",
                        fontFamily: "Franklin Gothic",
                        maxLines: 2,
                        fontWeight: FontWeight.w500,
                        color: blackColor,
                        fontSize: 28.sp,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Row(
                        children: [
                          AppText(
                            text: "We’ve sent a code to ",
                            fontFamily: "Franklin Gothic Regular",
                            fontSize: 14.sp,
                            color: greyTextColor,
                          ),
                          Column(
                            children: [
                              Text(
                                widget.phoneMunber,
                                style: TextStyle(
                                  fontFamily: "Franklin Gothic",
                                  fontSize: 14.sp,
                                  decorationColor: greyTextColor,
                                  decoration: TextDecoration.underline,
                                  color: deepGreytextColor,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: OtpTextField(
                          borderRadius: BorderRadius.circular(1),
                          numberOfFields: 4,
                          fieldWidth:
                              (MediaQuery.of(context).size.width - 65) / 4,
                          textStyle: const TextStyle(
                              color: loginText, fontSize: 16, height: 2.5),
                          focusedBorderColor: borderColor,
                          borderWidth: 1,
                          enabledBorderColor: borderColor,
                          showFieldAsBox: true,
                          onCodeChanged: (String code) {
                            otpController.otp.value = code;
                          },
                          onSubmit: (String verificationCode) {
                            otpController.otp.value = verificationCode;
                            if (otpController.otp.value.length == 4) {
                              otpController.showButton.value = true;
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 16, top: 20, left: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {},
                              child: AppText(
                                text: "Resend Code",
                                fontFamily: "Franklin Gothic",
                                fontSize: 14.sp,
                                color: btnTextColor,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: AppText(
                              text: "00:30",
                              fontFamily: "Franklin Gothic Regular",
                              fontSize: 14.sp,
                              color: deepGreytextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() => otpController.showButton.value
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: getSingleButton(
                        label: "Submit",
                        textColor: whiteBorderColor,
                        backgroundColor: btnTextColor,
                        controller: otpController,
                        onPressed: () {
                          if (otpController
                              .checkOtpvalidation(otpController.otp.value)) {
                            otpController.callVerifyOtp();
                          }
                        },
                        borderColor: btnTextColor),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: getSingleButton(
                        label: "Submit",
                        textColor: greyTextColor,
                        backgroundColor: colorSecondary,
                        onPressed: () {},
                        borderColor: colorSecondary),
                  ))
          ],
        ),
      ),
    );
  }
}
