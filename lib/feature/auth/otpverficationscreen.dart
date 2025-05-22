import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

//import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
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
  State<OTPVerficationScreen> createState() => OTPVerficationScreenState();
}

class OTPVerficationScreenState extends State<OTPVerficationScreen> {
  final otpController = Get.put(LoginController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Telephony telephony = Telephony.instance;
  Timer? timer;

  @override
  void initState() {
    otpController.showButton.value = false;
    otpController.otpError.value = "";
    if (Platform.isAndroid) {
      callReceiveMsg();
    }
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (otpController.secondsRemaining.value != 0) {
        otpController.secondsRemaining.value--;
      } else {
        otpController.enableResend.value = true;
      }
    });
    super.initState();
  }

  @override
  dispose() {
    timer!.cancel();
    super.dispose();
  }

  /* callReceiveMsg(List<TextEditingController?> controller) {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        print(message.address);
        print(message.body);

        String sms = message.body.toString();

        if (message.body!.contains('La Fetch')) {
          String otpcode = sms.replaceAll(new RegExp(r'[^0-9]'), '');
          String string = '$otpcode';
          print(string.split(''));
          otpController.otp.value = otpcode;
          print("abc $otpcode");
          controller[0]!.text = string[0];
          controller[1]!.text = string[1];
          controller[2]!.text = string[2];
          controller[3]!.text = string[3];

          setState(() {});
        } else {
          print("error");
        }
      },
      listenInBackground: false,
    );
  } */

  callReceiveMsg() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        print(message.address);
        print(message.body);

        String sms = message.body.toString();

        if (message.body!.contains('Lafetch')) {
          String otpcode = sms.replaceAll(new RegExp(r'[^0-9]'), '');
          String string = '$otpcode';
          print(string.split(''));
          otpController.otp.value = otpcode;
          print("abc $otpcode");
          otpController.controller.value.set(otpcode.split(""));
          setState(() {});
          if (otpController.checkOtpvalidation(otpController.otp.value)) {
            otpController.callVerifyOtp(widget.phoneMunber);
          }
        } else {
          print("error");
        }
      },
      listenInBackground: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            LoginAppbar(
              controller: otpController,
              isSkip: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*  Container(
                      width: MediaQuery.of(context).size.width,
                      height: 280.sp,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(otpImage), fit: BoxFit.cover),
                      ),
                    ), */
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
                            text: "We’ve sent a code to ",
                            fontFamily: "Franklin Gothic Regular",
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                          Column(
                            children: [
                              Text(
                                widget.phoneMunber.startsWith("+91")
                                    ? widget.phoneMunber
                                    : "+91${widget.phoneMunber}",
                                style: TextStyle(
                                  fontFamily: "Franklin Gothic Regular",
                                  fontSize: 14.sp,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 18.sp,
                    ),
                    /* Obx(
                      () => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: OtpTextField(
                            borderRadius: BorderRadius.circular(1),
                            numberOfFields: 4,
                            clearText: otpController.otpClear.value,
                            fieldWidth:
                                (MediaQuery.of(context).size.width - 65) / 4,
                            textStyle: const TextStyle(
                                color: loginText, fontSize: 16, height: 2.5),
                            focusedBorderColor: borderColor,
                            borderWidth: 1,
                            enabledBorderColor: borderColor,
                            showFieldAsBox: true,
                            onCodeChanged: (String code) {
                              otpController.otpClear.value = false;
                              otpController.otp.value = code;
                            },
                            handleControllers: (controllers) {
                              callReceiveMsg(controllers);
                            },
                            onSubmit: (String verificationCode) {
                              otpController.otpClear.value = false;
                              otpController.otp.value = verificationCode;
                              if (otpController.otp.value.length == 4) {
                                otpController.showButton.value = true;
                              }
                            },
                          ),
                        ),
                      ),
                    ), */
                    Obx(
                      () => Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.sp,
                        ),
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
                                          ? otpController.otpError.value != ""
                                              ? redColor
                                              : homeAppBarColor
                                          : borderColor),
                              style: TextStyle(
                                color: blackColor,
                                fontSize: 20.sp,
                                fontFamily: "Franklin Gothic Regular",
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 20.sp),
                              onChanged: (code) {
                                otpController.otp.value = code;
                                print("Changed: " + code);
                              },
                              cursorColor: borderColor,
                              onCompleted: (pin) {
                                otpController.otp.value = pin;
                                if (otpController.otp.value.length == 4) {
                                  otpController.showButton.value = true;
                                }
                              }),
                        ),
                      ),
                    ),
                    Obx(() => otpController.otpError.value != ""
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
                        : SizedBox(height: 0)),
                    /*  Padding(
                      padding: EdgeInsets.only(
                          right: 16.sp, top: 20.sp, left: 16.sp),
                      child: Row(
                        children: [
                          Obx(
                            () => Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  if (otpController.enableResend.value) {
                                    otpController
                                        .callResendOtp(widget.phoneMunber);
                                    otpController.controller.value.clear();
                                    FocusScope.of(context).unfocus();
                                    otpController.showButton.value = true;
                                    setState(() {});
                                    otpController.update();
                                    if (Platform.isAndroid) {
                                      callReceiveMsg();
                                    }
                                  }
                                },
                                child: AppText(
                                  text: "Resend Code",
                                  fontFamily: "Franklin Gothic",
                                  fontSize: 14,
                                  color: otpController.enableResend.value
                                      ? btnTextColor
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Obx(
                            () => Align(
                              alignment: Alignment.centerRight,
                              child: AppText(
                                text:
                                    '00 : ${otpController.secondsRemaining.value}',
                                fontFamily: "Franklin Gothic Regular",
                                fontSize: 14,
                                color: deepGreytextColor,
                              ),
                            ),
                          )
                        ],
                      ),
                    ), */
                  ],
                ),
              ),
            ),
            Obx(() => otpController.showButton.value
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.sp),
                    child: getSingleButton(
                        label: "Submit".toUpperCase(),
                        textColor: whiteColor,
                        backgroundColor: homeAppBarColor,
                        controller: otpController,
                        onPressed: () async {
                          if (otpController
                              .checkOtpvalidation(otpController.otp.value)) {
                            await otpController.callVerifyOtp(
                                widget.phoneMunber); // ← Add await here
                          }
                          await analytics.logEvent(
                            name: 'otp_screen_btnsubmit',
                            parameters: <String, Object>{
                              'page_name': 'otp_screen_btnsubmit',
                            },
                          );
                        },
                        borderColor: btnTextColor),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.sp),
                    child: getSingleButton(
                        label: "Submit".toUpperCase(),
                        textColor: whiteColor,
                        backgroundColor: colorSecondary,
                        onPressed: () async {
                          await analytics.logEvent(
                            name: 'otp_screen_btnsubmit',
                            parameters: <String, Object>{
                              'page_name': 'otp_screen_btnsubmit',
                            },
                          );
                        },
                        borderColor: colorSecondary),
                  )),
            Obx(
              () => otpController.enableResend.value
                  ? Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          if (otpController.enableResend.value) {
                            otpController.callResendOtp(widget.phoneMunber);
                            otpController.controller.value.clear();
                            FocusScope.of(context).unfocus();
                            otpController.showButton.value = true;
                            setState(() {});
                            otpController.update();
                            if (Platform.isAndroid) {
                              callReceiveMsg();
                            }
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
            SizedBox(
              height: 20.sp,
            )
          ],
        ),
      ),
    );
  }
}
