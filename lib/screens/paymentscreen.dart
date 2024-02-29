// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/singlebtn.dart';
import '../utils/constants.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  bool showUpiPayment = false;
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
            BackButtonAppbar(
              text: "Payment",
              threeDot: false,
              icon: threeDotImage,
              onPressedThreeDot: () {},
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 24),
                      child: AppText(
                        text: "Save Address as",
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: loginText,
                        fontSize: 14.sp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showUpiPayment = true;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              border: Border.all(width: 1, color: borderColor),
                              color: whiteBorderColor),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(chanelLogoImage,
                                        height: 32,
                                        width: 32,
                                        fit: BoxFit.cover),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: AppText(
                                        text: "Abc",
                                        color: colorPrimary,
                                        fontSize: 14.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        width: 0,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (showUpiPayment) {
                                          setState(() {
                                            showUpiPayment = false;
                                          });
                                        } else {
                                          setState(() {
                                            showUpiPayment = true;
                                          });
                                        }
                                      },
                                      child: Image.asset(upArrowIcon,
                                          height: 20,
                                          width: 20,
                                          fit: BoxFit.cover),
                                    ),
                                  ],
                                ),
                                showUpiPayment
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      )
                                    : const SizedBox(
                                        height: 0,
                                      )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: whiteBorderColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: SingleButton(
                        label: "Save and Continue",
                        textColor: whiteBorderColor,
                        backgroundColor: colorPrimary,
                        onPressed: () {
                          Get.to(const PaymentScreen());
                        },
                        borderColor: colorPrimary),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
