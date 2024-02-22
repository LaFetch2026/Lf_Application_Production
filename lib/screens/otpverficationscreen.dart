// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/app_text.dart';
import 'package:lafetch/commonwidget/singlebtn.dart';
import 'package:lafetch/controller/otpverify_controller.dart';
import 'package:lafetch/screens/userdetails.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OTPVerficationScreen extends StatefulWidget {
  final String phoneMunber;
  const OTPVerficationScreen({required this.phoneMunber, super.key});

  @override
  State<OTPVerficationScreen> createState() => OTPVerficationScreenState();
}

class OTPVerficationScreenState extends State<OTPVerficationScreen> {
  final otpController = Get.put(OtpVerificationController());
  @override
  void initState() {
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
                          AppText(
                            text: widget.phoneMunber,
                            fontFamily: "Franklin Gothic",
                            fontSize: 14.sp,
                            color: deepGreytextColor,
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
                          fieldWidth: 69,
                          textStyle: const TextStyle(
                              color: loginText, fontSize: 16, height: 2),
                          focusedBorderColor: borderColor,
                          borderWidth: 1,
                          enabledBorderColor: borderColor,
                          showFieldAsBox: true,
                          onCodeChanged: (String code) {
                            //  otpController.showButton.value = true;
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
                          const EdgeInsets.only(right: 20, top: 20, left: 20),
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
                    child: SingleButton(
                        label: "Submit",
                        textColor: whiteBorderColor,
                        backgroundColor: btnTextColor,
                        onPressed: () {
                          Get.to(
                            () => const UserDetailsScreen(),
                          );
                        },
                        borderColor: btnTextColor),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SingleButton(
                        label: "Submit",
                        textColor: greyTextColor,
                        backgroundColor: colorSecondary,
                        onPressed: () {
                          Get.to(
                            () => const UserDetailsScreen(),
                          );
                        },
                        borderColor: colorSecondary),
                  ))
          ],
        ),
      ),
    );
  }
}
