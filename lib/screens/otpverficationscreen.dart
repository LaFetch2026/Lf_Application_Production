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

const Color purpleColor = Color(0xff7268BF);

class OTPVerficationScreen extends StatefulWidget {
  final String phoneMunber;

  const OTPVerficationScreen({required this.phoneMunber, super.key});

  @override
  State<OTPVerficationScreen> createState() => _OTPVerficationScreenState();
}

class _OTPVerficationScreenState extends State<OTPVerficationScreen> {
  final LoginController otpController = Get.put(LoginController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final TextEditingController _pinController = TextEditingController();
  Timer? timer;

  @override
  void initState() {
    super.initState();

    otpController.showButton.value = false;
    otpController.otpError.value = "";
    otpController.secondsRemaining.value = 60;
    otpController.resendAttempts.value = 0;
    otpController.enableResend.value = false;
    otpController.otp.value = "";

    /// Detect OTP auto-fill (SMS / keyboard suggestion)
    _pinController.addListener(() {
      final text = _pinController.text;

      if (text.length == 4 && text != otpController.otp.value) {
        otpController.otp.value = text;
        otpController.showButton.value = true;

        if (otpController.checkOtpValidation(text)) {
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
    final double pinWidth = (MediaQuery.of(context).size.width - 32 - 12) / 4;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            LoginAppbar(controller: otpController, isSkip: false),

            /// BODY
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 40.sp, left: 16.sp),
                      child: AppText(
                        text: "ENTER YOUR VERIFICATION CODE",
                        fontFamily: "Clash Display Semibold",
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
                          AppText(
                            text: widget.phoneMunber.startsWith("+91")
                                ? widget.phoneMunber
                                : "+91${widget.phoneMunber}",
                            fontFamily: "Clash Display Regular",
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.sp),

                    /// OTP FIELD
                    Obx(() {
                      final defaultPinTheme = PinTheme(
                        width: pinWidth,
                        height: 56.sp,
                        textStyle: TextStyle(
                          fontSize: 20.sp,
                          color: blackColor,
                          fontFamily: "Clash Display Regular",
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: borderColor,
                            width: 1.5,
                          ),
                        ),
                      );

                      final focusedPinTheme = defaultPinTheme.copyWith(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: purpleColor,
                            width: 2,
                          ),
                        ),
                      );

                      final submittedPinTheme = defaultPinTheme.copyWith(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: otpController.otpError.value.isNotEmpty
                                ? lightPurpleColor
                                : purpleColor,
                            width: 1.5,
                          ),
                        ),
                      );

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.sp),
                        child: Pinput(
                          controller: _pinController,
                          length: 4,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          enableSuggestions: true,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          cursor: Container(
                            width: 2,
                            height: 24.sp,
                            color: purpleColor,
                          ),
                          onChanged: (code) {
                            otpController.otp.value = code;
                            otpController.showButton.value = code.length == 4;

                            /// Clear error when user types again
                            if (otpController.otpError.value.isNotEmpty) {
                              otpController.otpError.value = "";
                            }
                          },
                          onCompleted: (code) {
                            if (otpController.checkOtpValidation(code)) {
                              otpController.callVerifyOtp(widget.phoneMunber);
                            }
                          },
                        ),
                      );
                    }),

                    /// ERROR BELOW FIELD (NO SNACKBAR)
                    Obx(
                      () => otpController.otpError.value.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.only(top: 20.sp),
                              child: Center(
                                child: AppText(
                                  text: otpController.otpError.value,
                                  fontFamily: "Clash Display",
                                  color: lightPurpleColor,
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

            /// SUBMIT BUTTON
            Obx(
              () => Padding(
                padding: EdgeInsets.symmetric(vertical: 16.sp),
                child: getSingleButton(
                  label: "SUBMIT",
                  controller: otpController,
                  textColor: whiteColor,
                  backgroundColor: otpController.showButton.value
                      ? homeAppBarColor
                      : colorSecondary,
                  borderColor: otpController.showButton.value
                      ? btnTextColor
                      : colorSecondary,
                  onPressed: () async {
                    if (otpController
                        .checkOtpValidation(otpController.otp.value)) {
                      await otpController.callVerifyOtp(widget.phoneMunber);
                    }

                    await analytics.logEvent(
                      name: 'otp_submit_click',
                      parameters: {'screen': 'otp'},
                    );
                  },
                ),
              ),
            ),

            /// RESEND
            Obx(
              () => otpController.enableResend.value &&
                      otpController.resendAttempts.value <
                          otpController.maxResendAttempts
                  ? InkWell(
                      onTap: () async {
                        otpController.resendAttempts.value++;
                        otpController.enableResend.value = false;
                        otpController.secondsRemaining.value = 60;
                        otpController.otp.value = "";
                        otpController.otpError.value = "";
                        _pinController.clear();

                        await otpController.callResendOtp(widget.phoneMunber);
                        startTimer();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 12.sp),
                        child: AppText(
                          text: "RESEND CODE",
                          fontFamily: "Clash Display",
                          fontSize: 14,
                          color: titleColor,
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(bottom: 12.sp),
                      child: AppText(
                        text: otpController.resendAttempts.value >=
                                otpController.maxResendAttempts
                            ? "Maximum resend attempts reached"
                            : "00 : ${otpController.secondsRemaining.value.toString().padLeft(2, '0')}",
                        fontFamily: "Clash Display",
                        fontSize: 14,
                        color: otpController.resendAttempts.value >=
                                otpController.maxResendAttempts
                            ? lightPurpleColor
                            : titleColor,
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
