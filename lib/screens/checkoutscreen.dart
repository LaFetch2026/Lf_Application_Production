// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/backbutton_appbar.dart';
import 'package:lafetch/screens/shippingaddressscreen.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/singlebtn.dart';
import '../utils/constants.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  List<String> items = [
    " In next 6 hours",
    " In next 6 hours",
    " 10 May 2023",
  ];
  List<String> itemText = [
    "Estimated delivery :",
    "Estimated delivery :",
    "Estimated delivery by",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          BackButtonAppbar(
            text: "Checkout",
            threeDot: false,
            icon: threeDotImage,
            onPressedThreeDot: () {},
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: AppText(
                                  text: "Shipping Address",
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w500,
                                  color: loginText,
                                  fontSize: 16.sp,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, top: 2),
                                child: AppText(
                                  text: "Add a shipping address",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: greyTextColor,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 22),
                          child: Image.asset(rightArrowImage,
                              color: loginText,
                              height: 18,
                              width: 18,
                              fit: BoxFit.cover),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      color: colorSecondary,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: AppText(
                                  text: "Payment",
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w500,
                                  color: loginText,
                                  fontSize: 16.sp,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, top: 2),
                                child: AppText(
                                  text: "Select payment method",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: greyTextColor,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 22),
                          child: Image.asset(rightArrowImage,
                              color: loginText,
                              height: 18,
                              width: 18,
                              fit: BoxFit.cover),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      color: colorSecondary,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 20),
                    child: AppText(
                      text: "Delivery Estimates",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: blackColor,
                      fontSize: 16.sp,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 5),
                    child: ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: items.length,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (ctx, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, left: 16, right: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(backImage,
                                      height: 60, width: 50, fit: BoxFit.cover),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: AppText(
                                      text: itemText[index],
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: blackColor,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  AppText(
                                    text: items[index],
                                    fontFamily: "Franklin Gothic Bold",
                                    fontWeight: FontWeight.w700,
                                    color: blackColor,
                                    fontSize: 12.sp,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  Container(
                    color: whiteBorderColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: borderColor, width: 1),
                                  borderRadius: BorderRadius.circular(1)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: AppText(
                                        text: "Have a gift card?",
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        height: 0,
                                      ),
                                    ),
                                    AppText(
                                      text: "Apply",
                                      fontFamily: "Franklin Gothic",
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                      fontSize: 12.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: AppText(
                              text: "Price Details",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: colorPrimary,
                              fontSize: 12.sp,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Container(
                              width: double.infinity,
                              color: colorSecondary,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Total MRP",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: textColor,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "\u{20B9} ${2537.00}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Express Delivery Charges",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: textColor,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "\u{20B9} ${112.32}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Discount on MRP",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: textColor,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "\u{20B9} ${-36.00}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: greenText,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Coupon Discount",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: textColor,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "\u{20B9} ${-36.00}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: greenText,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: AppText(
                                        text: "Convenience Fee",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: textColor,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    Image.asset(questionIcon,
                                        height: 16,
                                        width: 16,
                                        fit: BoxFit.cover)
                                  ],
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "Free",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: greenText,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: AppText(
                                        text: "Tax & Charges",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: textColor,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    Image.asset(questionIcon,
                                        height: 16,
                                        width: 16,
                                        fit: BoxFit.cover)
                                  ],
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "\u{20B9} ${36}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Container(
                              width: double.infinity,
                              color: colorSecondary,
                              height: 1.5,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Bill total",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                    color: colorPrimary,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "\u{20B9} ${2501}",
                                  fontFamily: "Franklin Gothic Bold",
                                  fontWeight: FontWeight.w700,
                                  color: colorPrimary,
                                  fontSize: 18.sp,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: backWhite,
                    height: 34,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 6, bottom: 6),
                      child: Center(
                        child: AppText(
                          text:
                              "You will earn 100 LaFetch coins on this purchase",
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                          color: deepPurple,
                          fontSize: 12.sp,
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 30, left: 20, right: 8, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "INR 3,785",
                        textAlign: TextAlign.center,
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: blackColor,
                        fontSize: 16.sp,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      AppText(
                        text: "View details",
                        textAlign: TextAlign.center,
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        fontSize: 12.sp,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 16),
                    child: SingleButton(
                        label: "Pay Now",
                        textColor: whiteBorderColor,
                        backgroundColor: colorPrimary,
                        onPressed: () {
                          Get.to(const ShippingAddressScreen(
                            addressId: 0,
                          ));
                        },
                        borderColor: colorPrimary),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
