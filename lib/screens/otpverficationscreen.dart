// ignore_for_file: avoid_print

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/app_text.dart';
import 'package:lafetch/utils/constants.dart';
//import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:otp_text_field_v2/otp_field_style_v2.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:telephony/telephony.dart';
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
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Telephony telephony = Telephony.instance;
  Timer? timer;
  @override
  void initState() {
    otpController.showButton.value = false;
    callReceiveMsg();
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
                      height: 280.sp,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(otpImage), fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.sp, left: 16.sp),
                      child: AppText(
                        text: "Enter your\nVerification Code",
                        fontFamily: "Franklin Gothic",
                        maxLines: 2,
                        fontWeight: FontWeight.w500,
                        color: blackColor,
                        fontSize: 28,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 20.sp),
                      child: Row(
                        children: [
                          AppText(
                            text: "We’ve sent a code to ",
                            fontFamily: "Franklin Gothic Regular",
                            fontSize: 14,
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
                      height: 10,
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
                                  (MediaQuery.of(context).size.width - 78) / 4,
                              fieldStyle: FieldStyle.box,
                              outlineBorderRadius: 1.sp,
                              otpFieldStyle: OtpFieldStyle(
                                  focusBorderColor: borderColor,
                                  enabledBorderColor: borderColor),
                              style: TextStyle(
                                color: loginText,
                                fontSize: 16.sp,
                              ),
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
                    Padding(
                      padding: EdgeInsets.only(
                          right: 16.sp, top: 20.sp, left: 16.sp),
                      child: Row(
                        children: [
                          Obx(
                            () => Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  //  otpController.otpClear.value = true;
                                  /*   otpController.enableResend.value
                                      ? otpController
                                          .callResendOtp(widget.phoneMunber)
                                      : null; */
                                  if (otpController.enableResend.value) {
                                    otpController
                                        .callResendOtp(widget.phoneMunber);
                                    otpController.controller.value.clear();
                                    FocusScope.of(context).unfocus();
                                    otpController.showButton.value = true;
                                    setState(() {});
                                    otpController.update();
                                    callReceiveMsg();
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
                    ),
                  ],
                ),
              ),
            ),
            Obx(() => otpController.showButton.value
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.sp),
                    child: getSingleButton(
                        label: "Submit",
                        textColor: whiteBorderColor,
                        backgroundColor: btnTextColor,
                        controller: otpController,
                        onPressed: () {
                          if (otpController
                              .checkOtpvalidation(otpController.otp.value)) {
                            otpController.callVerifyOtp(widget.phoneMunber);
                          }
                        },
                        borderColor: btnTextColor),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.sp),
                    child: getSingleButton(
                        label: "Submit",
                        textColor: greyTextColor,
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
                  ))
          ],
        ),
      ),
    );
  }
}
