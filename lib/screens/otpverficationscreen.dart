import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:otp_text_field_v2/otp_field_style_v2.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:telephony/telephony.dart';

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

class _OTPVerficationScreenState extends State<OTPVerficationScreen> {
  final otpController = Get.put(LoginController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final Telephony telephony = Telephony.instance;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    otpController.showButton.value = false;
    otpController.otpError.value = "";
    if (Platform.isAndroid) {
      _listenForOtpSms();
    }
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (otpController.secondsRemaining.value > 0) {
        otpController.secondsRemaining.value--;
      } else {
        otpController.enableResend.value = true;
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _listenForOtpSms() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        final sms = message.body ?? "";
        if (sms.contains('Lafetch')) {
          final otpCode = sms.replaceAll(RegExp(r'[^0-9]'), '');
          otpController.otp.value = otpCode;
          otpController.controller.value.set(otpCode.split(""));
          setState(() {});
          if (otpController.checkOtpValidation(otpCode)) {
            otpController.callVerifyOtp(widget.phoneMunber);
          }
        }
      },
      listenInBackground: false,
    );
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
                      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                      child: Row(
                        children: [
                          AppText(
                            text: "We’ve sent a code to ",
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
                            fieldWidth: (MediaQuery.of(context).size.width - 100) / 4,
                            fieldStyle: FieldStyle.box,
                            outlineBorderRadius: 1.sp,
                            otpFieldStyle: OtpFieldStyle(
                              focusBorderColor: homeAppBarColor,
                              enabledBorderColor: otpController.otp.value.length == 4
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
                            contentPadding: EdgeInsets.symmetric(vertical: 20.sp),
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
                  backgroundColor: otpController.showButton.value ? homeAppBarColor : colorSecondary,
                  controller: otpController,
                  onPressed: () async {
                    if (otpController.checkOtpValidation(otpController.otp.value)) {
                      await otpController.callVerifyOtp(widget.phoneMunber);
                    }
                    await analytics.logEvent(
                      name: 'otp_screen_btnsubmit',
                      parameters: {'page_name': 'otp_screen_btnsubmit'},
                    );
                  },
                  borderColor: otpController.showButton.value ? btnTextColor : colorSecondary,
                ),
              ),
            ),
            Obx(
                  () => otpController.enableResend.value
                  ? Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    otpController.callResendOtp(widget.phoneMunber);
                    otpController.controller.value.clear();
                    FocusScope.of(context).unfocus();
                    if (Platform.isAndroid) {
                      _listenForOtpSms();
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10.sp),
                    child: AppText(
                      text: "Resend Code".toUpperCase(),
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
                    text: '00 : ${otpController.secondsRemaining.value}',
                    fontFamily: "Franklin Gothic",
                    fontSize: 14,
                    color: titleColor,
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
