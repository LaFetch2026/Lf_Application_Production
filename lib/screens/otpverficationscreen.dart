import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

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
  Timer? timer;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    otpController.showButton.value = false;
    otpController.otpError.value = "";
    otpController.secondsRemaining.value = 60;
    otpController.resendAttempts.value = 0;

    // Add listener to text controller for auto-fill detection
    _pinController.addListener(() {
      final text = _pinController.text;
      debugPrint('📝 Pin controller text changed: $text');

      // Sync with otpController if text changed externally (e.g., SMS auto-fill)
      if (text.isNotEmpty && text != otpController.otp.value) {
        otpController.otp.value = text;
        otpController.showButton.value = text.length == 4;

        // Auto-verify if valid OTP filled
        if (text.length == 4 && otpController.checkOtpValidation(text)) {
          debugPrint('🚀 Auto-verifying from controller listener...');
          otpController.callVerifyOtp(widget.phoneMunber);
        }
      }
    });

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
    _pinController.dispose();
    super.dispose();
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
                        fontFamily: "Clash Display Semibold",
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
                            fontFamily: "Clash Display Regular",
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                          Text(
                            widget.phoneMunber.startsWith("+91")
                                ? widget.phoneMunber
                                : "+91${widget.phoneMunber}",
                            style: TextStyle(
                              fontFamily: "Clash Display Regular",
                              fontSize: 14.sp,
                              color: subtitleColor,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 18.sp),
                    Obx(
                      () {
                        final defaultPinTheme = PinTheme(
                          width: 56.sp,
                          height: 56.sp,
                          textStyle: TextStyle(
                            color: blackColor,
                            fontSize: 20.sp,
                            fontFamily: "Clash Display Regular",
                          ),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            border: Border.all(
                              color: borderColor,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        );

                        final focusedPinTheme = defaultPinTheme.copyWith(
                          decoration: BoxDecoration(
                            color: whiteColor,
                            border: Border.all(
                              color: borderColor,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        );

                        final submittedPinTheme = defaultPinTheme.copyWith(
                          decoration: BoxDecoration(
                            color: whiteColor,
                            border: Border.all(
                              color: otpController.otpError.value.isNotEmpty
                                  ? redColor
                                  : homeAppBarColor,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        );

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.sp),
                          child: Center(
                            child: Pinput(
                              controller: _pinController,
                              length: 4,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: focusedPinTheme,
                              submittedPinTheme: submittedPinTheme,
                              autofocus: true,
                              separatorBuilder: (index) => SizedBox(width: 4.sp),
                              cursor: Container(
                                width: 2,
                                height: 24.sp,
                                color: borderColor,
                              ),
                              onChanged: (code) {
                                debugPrint('🔄 Pinput onChanged: $code');
                                otpController.otp.value = code;
                                otpController.showButton.value = code.length == 4;

                                if (code.length == 4) {
                                  if (otpController.checkOtpValidation(code)) {
                                    debugPrint('🚀 Auto-verifying OTP from Pinput...');
                                    otpController.callVerifyOtp(widget.phoneMunber);
                                  }
                                }
                              },
                              onCompleted: (code) {
                                debugPrint('🎯 Pinput onCompleted: $code');
                                otpController.otp.value = code;
                                otpController.showButton.value = true;
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Obx(
                      () => otpController.otpError.value.isNotEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20.sp, right: 20.sp, top: 24.sp),
                                child: AppText(
                                  text: otpController.otpError.value,
                                  fontFamily: "Clash Display",
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
                          otpController.otp.value = '';
                          _pinController.clear();

                          await otpController.callResendOtp(widget.phoneMunber);

                          if (mounted) {
                            FocusScope.of(context).unfocus();
                          }

                          startTimer();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10.sp),
                          child: AppText(
                            text: "Resend Code ".toUpperCase(),
                            fontFamily: "Clash Display",
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
                          fontFamily: "Clash Display",
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
