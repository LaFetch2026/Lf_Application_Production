// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/backbutton_appbar.dart';
import 'package:lafetch/screens/paymentsuccessscreen.dart';
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
  bool radioValue = false;
  String? upiText;
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
            BackButtonAppbar(
              text: "Payment",
              threeDot: false,
              icon: threeDotImage,
              backgroundColor: whiteColor,
              onPressedThreeDot: () {},
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                            color: whiteBorderColor,
                            borderRadius: BorderRadius.circular(1)),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "Bank Offer",
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w500,
                                color: nameText,
                                fontSize: 14.sp,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: AppText(
                                  text:
                                      "Get up to Rs 500 Cashback on CRED pay (Android devices only) on a min spend of Rs 10000. TCA",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  maxLines: 2,
                                  color: greyTextColor,
                                  fontSize: 12.sp,
                                ),
                              ),
                              AppText(
                                text: "Show more",
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w500,
                                color: greyTextColor,
                                fontSize: 12.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, top: 35, bottom: 10),
                      child: AppText(
                        text: "Recommended payment options",
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: blackColor,
                        fontSize: 16.sp,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, top: 16, right: 16, bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: Radio(
                                value: true,
                                activeColor: colorPrimary,
                                groupValue: radioValue,
                                onChanged: (value) {
                                  radioValue = value!;
                                  print(value);

                                  setState(() {});
                                }),
                          ),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                if (radioValue) {
                                  radioValue = false;
                                } else {
                                  radioValue = true;
                                }
                                setState(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "<upi_id>@<bank name>",
                                      style: TextStyle(
                                        color: blackColor,
                                        fontSize: 14.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        " User Name",
                                        style: TextStyle(
                                          color: loginText,
                                          fontSize: 12.sp,
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Image.asset(
                            upiImage,
                            fit: BoxFit.cover,
                            width: 45,
                            height: 18,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 25),
                      child: AppText(
                        text: "Other payment options",
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: blackColor,
                        fontSize: 16.sp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showUpiPayment = true;
                        });
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              border:
                                  Border.all(width: 1, color: textHintColor),
                              color: whiteColor),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16, bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    AppText(
                                      text: "Phonepe/Google Pay/ BHIM UPI",
                                      color: colorPrimary,
                                      fontSize: 14.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
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
                                        child: showUpiPayment
                                            ? Image.asset(dropdownImage,
                                                color: colorPrimary,
                                                height: 20,
                                                width: 20,
                                                fit: BoxFit.cover)
                                            : Image.asset(upArrowIcon,
                                                color: colorPrimary,
                                                height: 20,
                                                width: 20,
                                                fit: BoxFit.cover)),
                                  ],
                                ),
                              ),
                              showUpiPayment
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Container(
                                            width: double.infinity,
                                            color: textHintColor,
                                            height: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: Radio(
                                                    value: "g_pay",
                                                    activeColor: colorPrimary,
                                                    groupValue: upiText,
                                                    onChanged: (value) {
                                                      upiText =
                                                          value.toString();
                                                      setState(() {});
                                                    }),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  upiText = "g_pay";
                                                  setState(() {});
                                                },
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10),
                                                      child: Image.asset(
                                                        googlePayImage,
                                                        fit: BoxFit.cover,
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Google Pay",
                                                      style: TextStyle(
                                                        color: colorPrimary,
                                                        fontSize: 14.sp,
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: Radio(
                                                    value: "paytm",
                                                    activeColor: colorPrimary,
                                                    groupValue: upiText,
                                                    onChanged: (value) {
                                                      upiText =
                                                          value.toString();
                                                      setState(() {});
                                                    }),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  upiText = "paytm";
                                                  setState(() {});
                                                },
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10),
                                                      child: Image.asset(
                                                        paytmImage,
                                                        fit: BoxFit.cover,
                                                        width: 30,
                                                        height: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Paytm",
                                                      style: TextStyle(
                                                        color: colorPrimary,
                                                        fontSize: 14.sp,
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: Radio(
                                                    value: "upi",
                                                    activeColor: colorPrimary,
                                                    groupValue: upiText,
                                                    onChanged: (value) {
                                                      upiText =
                                                          value.toString();
                                                      setState(() {});
                                                    }),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  upiText = "upi";
                                                  setState(() {});
                                                },
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10),
                                                      child: Image.asset(
                                                        upiImage,
                                                        fit: BoxFit.cover,
                                                        width: 48,
                                                        height: 24,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Enter UPI Id",
                                                      style: TextStyle(
                                                        color: colorPrimary,
                                                        fontSize: 14.sp,
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        )
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
                    GestureDetector(
                      onTap: () {
                        /*  setState(() {
                          showUpiPayment = true;
                        }); */
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              border:
                                  Border.all(width: 1, color: textHintColor),
                              color: whiteColor),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16, bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    AppText(
                                      text: "PayTM/Wallets",
                                      color: colorPrimary,
                                      fontSize: 14.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        width: 0,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        /*  if (showUpiPayment) {
                                          setState(() {
                                            showUpiPayment = false;
                                          });
                                        } else {
                                          setState(() {
                                            showUpiPayment = true;
                                          });
                                        } */
                                      },
                                      child: showUpiPayment
                                          ? Image.asset(dropdownImage,
                                              color: colorPrimary,
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.cover)
                                          : Image.asset(upArrowIcon,
                                              color: colorPrimary,
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.cover),
                                    ),
                                  ],
                                ),
                              ),
                              showUpiPayment
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Container(
                                            width: double.infinity,
                                            color: textHintColor,
                                            height: 1,
                                          ),
                                        ),
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
                    GestureDetector(
                      onTap: () {
                        /*  setState(() {
                          showUpiPayment = true;
                        }); */
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              border:
                                  Border.all(width: 1, color: textHintColor),
                              color: whiteColor),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16, bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    AppText(
                                      text: "Net Banking",
                                      color: colorPrimary,
                                      fontSize: 14.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        width: 0,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        /*   if (showUpiPayment) {
                                          setState(() {
                                            showUpiPayment = false;
                                          });
                                        } else {
                                          setState(() {
                                            showUpiPayment = true;
                                          });
                                        } */
                                      },
                                      child: showUpiPayment
                                          ? Image.asset(dropdownImage,
                                              color: colorPrimary,
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.cover)
                                          : Image.asset(upArrowIcon,
                                              color: colorPrimary,
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.cover),
                                    ),
                                  ],
                                ),
                              ),
                              showUpiPayment
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Container(
                                            width: double.infinity,
                                            color: textHintColor,
                                            height: 1,
                                          ),
                                        ),
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
                    GestureDetector(
                      onTap: () {
                        /* setState(() {
                          showUpiPayment = true;
                        }); */
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              border:
                                  Border.all(width: 1, color: textHintColor),
                              color: whiteColor),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16, bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    AppText(
                                      text: "EMI",
                                      color: colorPrimary,
                                      fontSize: 14.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        width: 0,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        /*  if (showUpiPayment) {
                                          setState(() {
                                            showUpiPayment = false;
                                          });
                                        } else {
                                          setState(() {
                                            showUpiPayment = true;
                                          });
                                        } */
                                      },
                                      child: showUpiPayment
                                          ? Image.asset(dropdownImage,
                                              color: colorPrimary,
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.cover)
                                          : Image.asset(upArrowIcon,
                                              color: colorPrimary,
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.cover),
                                    ),
                                  ],
                                ),
                              ),
                              showUpiPayment
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Container(
                                            width: double.infinity,
                                            color: textHintColor,
                                            height: 1,
                                          ),
                                        ),
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
                    GestureDetector(
                      onTap: () {
                        /*  setState(() {
                          showUpiPayment = true;
                        }); */
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              border:
                                  Border.all(width: 1, color: textHintColor),
                              color: whiteColor),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16, bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    AppText(
                                      text: "Cash on Delivery (Cash/UPI)",
                                      color: colorPrimary,
                                      fontSize: 14.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        width: 0,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        /*   if (showUpiPayment) {
                                          setState(() {
                                            showUpiPayment = false;
                                          });
                                        } else {
                                          setState(() {
                                            showUpiPayment = true;
                                          });
                                        } */
                                      },
                                      child: showUpiPayment
                                          ? Image.asset(dropdownImage,
                                              color: colorPrimary,
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.cover)
                                          : Image.asset(upArrowIcon,
                                              color: colorPrimary,
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.cover),
                                    ),
                                  ],
                                ),
                              ),
                              showUpiPayment
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Container(
                                            width: double.infinity,
                                            color: textHintColor,
                                            height: 1,
                                          ),
                                        ),
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
                    const SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ),
            Container(
              color: whiteColor,
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
                          Get.to(const PaymentSuccessScreen());
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
