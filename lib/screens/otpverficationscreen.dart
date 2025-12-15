import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:otp_text_field_v2/otp_field_style_v2.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../common/widget/appbar/login_appbar.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/login_controller.dart';
import '../../core/constant/constants.dart';

class OTPVerficationScreen extends StatefulWidget {
  final String phoneMunber;

  const OTPVerficationScreen({required this.phoneMunber, super.key});

  @override
  State<OTPVerficationScreen> createState() => _OTPVerficationScreenState();
}

class _OTPVerficationScreenState extends State<OTPVerficationScreen>
    with CodeAutoFill {
  final otpController = Get.put(LoginController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    otpController.showButton.value = false;
    otpController.otpError.value = "";
    otpController.secondsRemaining.value = 60; // Changed from default to 60
    otpController.resendAttempts.value = 0; // Reset attempts on init

    if (Platform.isAndroid) {
      listenForCode();
    }
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (otpController.secondsRemaining.value > 0) {
        otpController.secondsRemaining.value--;
      } else {
        otpController.enableResend.value = true;
        timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    cancel();
    super.dispose();
  }

  @override
  void codeUpdated() {
    if (code != null && code!.length >= 4) {
      final otpCode = code!.replaceAll(RegExp(r'[^0-9]'), '');
      if (otpCode.length >= 4) {
        final otp = otpCode.substring(0, 4);
        otpController.otp.value = otp;
        otpController.controller.value.set(otp.split(""));
        setState(() {});
        if (otpController.checkOtpValidation(otp)) {
          otpController.callVerifyOtp(widget.phoneMunber);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            LoginAppbar(controller: otpController, isSkip: false),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 40.sp, left: 16.sp),
                      child: AppText(
                        text: "Enter your Verification Code".toUpperCase(),
                        fontFamily: "Franklin Gothic Semibold",
                        maxLines: 2,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 8.sp),
                      child: Row(
                        children: [
                          AppText(
                            text: "We've sent a code to ",
                            fontFamily: "Franklin Gothic Regular",
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                          Text(
                            widget.phoneMunber.startsWith("+91")
                                ? widget.phoneMunber
                                : "+91${widget.phoneMunber}",
                            style: TextStyle(
                              fontFamily: "Franklin Gothic Regular",
                              fontSize: 14.sp,
                              color: subtitleColor,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 18.sp),
                    Obx(
                      () => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.sp),
                        child: Center(
                          child: OTPTextFieldV2(
                            controller: otpController.controller.value,
                            length: 4,
                            autoFocus: false,
                            width: MediaQuery.of(context).size.width,
                            textFieldAlignment: MainAxisAlignment.spaceAround,
                            spaceBetween: 4.sp,
                            fieldWidth:
                                (MediaQuery.of(context).size.width - 100) / 4,
                            fieldStyle: FieldStyle.box,
                            outlineBorderRadius: 1.sp,
                            otpFieldStyle: OtpFieldStyle(
                              focusBorderColor: homeAppBarColor,
                              enabledBorderColor:
                                  otpController.otp.value.length == 4
                                      ? otpController.otpError.value.isNotEmpty
                                          ? redColor
                                          : homeAppBarColor
                                      : borderColor,
                            ),
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 20.sp,
                              fontFamily: "Franklin Gothic Regular",
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 20.sp),
                            cursorColor: borderColor,
                            onChanged: (code) {
                              otpController.otp.value = code;
                            },
                            onCompleted: (pin) {
                              otpController.otp.value = pin;
                              if (pin.length == 4) {
                                otpController.showButton.value = true;
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => otpController.otpError.value.isNotEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20.sp, right: 20.sp, top: 24.sp),
                                child: AppText(
                                  text: otpController.otpError.value,
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w400,
                                  color: redColor,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            Obx(
              () => Padding(
                padding: EdgeInsets.symmetric(vertical: 16.sp),
                child: getSingleButton(
                  label: "Submit".toUpperCase(),
                  textColor: whiteColor,
                  backgroundColor: otpController.showButton.value
                      ? homeAppBarColor
                      : colorSecondary,
                  controller: otpController,
                  onPressed: () async {
                    if (otpController
                        .checkOtpValidation(otpController.otp.value)) {
                      await otpController.callVerifyOtp(widget.phoneMunber);
                    }
                    await analytics.logEvent(
                      name: 'otp_screen_btnsubmit',
                      parameters: {'page_name': 'otp_screen_btnsubmit'},
                    );
                  },
                  borderColor: otpController.showButton.value
                      ? btnTextColor
                      : colorSecondary,
                ),
              ),
            ),
            Obx(
              () => otpController.enableResend.value &&
                      otpController.resendAttempts.value <
                          otpController.maxResendAttempts
                  ? Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () async {
                          otpController.resendAttempts.value++;
                          otpController.enableResend.value = false;
                          otpController.secondsRemaining.value = 60;

                          await otpController.callResendOtp(widget.phoneMunber);
                          otpController.controller.value.clear();
                          FocusScope.of(context).unfocus();

                          if (Platform.isAndroid) {
                            listenForCode();
                          }

                          startTimer();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10.sp),
                          child: AppText(
                            text: "Resend Code ".toUpperCase(),
                            fontFamily: "Franklin Gothic",
                            fontSize: 14,
                            color: titleColor,
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(bottom: 10.sp),
                      child: Align(
                        alignment: Alignment.center,
                        child: AppText(
                          text: otpController.resendAttempts.value >=
                                  otpController.maxResendAttempts
                              ? 'Maximum resend attempts reached'
                              : '00 : ${otpController.secondsRemaining.value.toString().padLeft(2, '0')}',
                          fontFamily: "Franklin Gothic",
                          fontSize: 14,
                          color: otpController.resendAttempts.value >=
                                  otpController.maxResendAttempts
                              ? redColor
                              : titleColor,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 20.sp),
          ],
        ),
      ),
    );
  }
}
