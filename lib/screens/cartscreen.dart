// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/cartwidgets/cartwidgets.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../commonwidget/singlebtn.dart';
import '../utils/constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  List<String> items = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          BackButtonAppbar(
            text: "Shopping Bag",
            threeDot: true,
            icon: heartImage,
            onPressedThreeDot: () {},
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*  Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CartWidget(
                        image: shopBagImage,
                        text1: "There is still room for more",
                        text2:
                            "Looking for items you previously saved?\nSign in to pick up where you left out",
                        btntext: "Continue Shopping",
                        visible: true),
                  ), */
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: "Shopping Bag",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: blackColor,
                              fontSize: 16.sp,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  AppText(
                                    text: "3 items",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: textHintColor,
                                    fontSize: 12.sp,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Container(
                                      width: 1,
                                      color: textHintColor,
                                      height: 16,
                                    ),
                                  ),
                                  AppText(
                                    text: "\u{20B9} ${125.0}",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: textHintColor,
                                    fontSize: 12.sp,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const Expanded(
                          child: SizedBox(
                            height: 0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              const ImageIcon(
                                AssetImage(deleteIcon),
                                color: colorPrimary,
                                size: 16,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: AppText(
                                  text: "Clear Bag",
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w500,
                                  color: colorPrimary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 5),
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
                                  top: 10, left: 16, right: 16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Image.asset(backImage,
                                              height: 78,
                                              width: 64,
                                              fit: BoxFit.cover),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                AppText(
                                                  text: "Kassually",
                                                  maxLines: 1,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14.sp,
                                                  color: blackColor,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: AppText(
                                                    text:
                                                        "Solid shirt style crop top",
                                                    color: nameText,
                                                    maxLines: 2,
                                                    fontSize: 12.sp,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                AppText(
                                                  text: "Sold by ABC company",
                                                  color: textHintColor,
                                                  fontSize: 10.sp,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        color: colorSecondary,
                                                        height: 40,
                                                        width: 70,
                                                        child: Row(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      5),
                                                              child: AppText(
                                                                text:
                                                                    "Size : S",
                                                                color:
                                                                    blackColor,
                                                                fontSize: 10.sp,
                                                                fontFamily:
                                                                    "Franklin Gothic Regular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                            const ImageIcon(
                                                              AssetImage(
                                                                  dropdownImage),
                                                              color: nameText,
                                                              size: 16,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                top: 5,
                                                                bottom: 5),
                                                        child: Container(
                                                          color: colorSecondary,
                                                          height: 40,
                                                          width: 70,
                                                          child: Row(
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        5),
                                                                child: AppText(
                                                                  text:
                                                                      "Qty : 1",
                                                                  color:
                                                                      blackColor,
                                                                  fontSize:
                                                                      10.sp,
                                                                  fontFamily:
                                                                      "Franklin Gothic Regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                              const ImageIcon(
                                                                AssetImage(
                                                                    dropdownImage),
                                                                color: nameText,
                                                                size: 16,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: Row(
                                                    children: [
                                                      AppText(
                                                        text: "\u{20B9} ${699}",
                                                        color: blackColor,
                                                        fontSize: 12.sp,
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Text(
                                                          "\u{20B9} ${1800}",
                                                          style: TextStyle(
                                                            color:
                                                                textHintColor,
                                                            fontSize: 12.sp,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Text(
                                                          "61% OFF",
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 12.sp,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Image.asset(blackCrossImage,
                                            height: 10,
                                            width: 10,
                                            fit: BoxFit.cover),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        width: double.infinity,
                                        color: colorSecondary,
                                        height: 1,
                                      ),
                                    ),
                                  ]),
                            ),
                          );
                        }),
                  ),
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
                  padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
                  child: AppText(
                    text: "3 items in shopping bag",
                    textAlign: TextAlign.center,
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: blackColor,
                    fontSize: 12.sp,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SingleButton(
                      label: "Proceed to checkout",
                      textColor: whiteBorderColor,
                      backgroundColor: btnTextColor,
                      onPressed: () {},
                      borderColor: btnTextColor),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
