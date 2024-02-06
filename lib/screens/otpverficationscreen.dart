// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/app_text.dart';
import 'package:lafetch/commonwidget/singlebtn.dart';
import 'package:lafetch/screens/userdetails.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OTPVerficationScreen extends StatefulWidget {
  const OTPVerficationScreen({super.key});

  @override
  State<OTPVerficationScreen> createState() => OTPVerficationScreenState();
}

class OTPVerficationScreenState extends State<OTPVerficationScreen> {
  String otp = "";

  @override
  void initState() {
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
                          fontSize: 14.sp,
                          color: greyTextColor,
                        ),
                        AppText(
                          text: "+91 123456789",
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
                    child: OtpTextField(
                      borderRadius: BorderRadius.circular(1),
                      numberOfFields: 4,
                      fieldWidth: (MediaQuery.sizeOf(context).width - 70) / 4,
                      textStyle:
                          const TextStyle(color: textColor, fontSize: 14),
                      focusedBorderColor: borderColor,
                      enabledBorderColor: borderColor,
                      //set to true to show as box or false to show as dash
                      showFieldAsBox: true,
                      //runs when a code is typed in
                      onCodeChanged: (String code) {
                        //handle validation or checks here
                      },
                      //runs when every textfield is filled
                      onSubmit: (String verificationCode) {
                        otp = verificationCode;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: AppText(
                        text: "00:30",
                        fontSize: 14.sp,
                        color: deepGreytextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleButton(
                label: "Submit",
                textColor: btnTextColor,
                backgroundColor: whiteTextColor,
                onPressed: () {
                  Get.to(
                    () => const UserDetailsScreen(),
                  );
                },
                borderColor: btnTextColor),
          )
        ],
      ),
    );
  }
}
