// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/cartwidgets/cartwidgets.dart';
import 'package:lafetch/commonwidget/smallbtn.dart';
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
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 16),
                    child: AppText(
                      text: "You may also like",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: colorPrimary,
                      fontSize: 12.sp,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, index) {
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 122,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(backImage,
                                            height: 150,
                                            width: 122,
                                            fit: BoxFit.cover),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: AppText(
                                            text: "Jack & Jones Core ",
                                            color: nameText,
                                            fontSize: 12.sp,
                                            fontFamily: "Franklin Gothic",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          child: AppText(
                                            text:
                                                "Topman super skinny suit jacket and trousers in light blue",
                                            color: nameText,
                                            maxLines: 2,
                                            fontSize: 11.sp,
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 10, right: 10),
                                          child: Row(
                                            children: [
                                              AppText(
                                                text:
                                                    "\u{20B9} ${items[index]}",
                                                color: deepGreytextColor,
                                                maxLines: 2,
                                                fontSize: 11.sp,
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w500,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: AppText(
                                                  text:
                                                      "\u{20B9} ${items[index]}",
                                                  color: textHintColor,
                                                  maxLines: 2,
                                                  fontSize: 11.sp,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: SmallButton(
                                              label: "Add to bag",
                                              onPressed: () {},
                                              textColor: btnTextColor,
                                              backgroundColor: whiteTextColor,
                                              borderColor: btnTextColor,
                                              width: 122),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ),
                  Container(
                    color: whiteColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: "Coupons",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: colorPrimary,
                            fontSize: 12.sp,
                          ),
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
                                      child: Row(
                                        children: [
                                          const ImageIcon(
                                            AssetImage(coupanImage),
                                            color: colorPrimary,
                                            size: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: AppText(
                                              text: "Apply Coupan",
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                              color: textFilter,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        height: 0,
                                      ),
                                    ),
                                    AppText(
                                      text: "Select",
                                      fontFamily: "Franklin Gothic",
                                      fontWeight: FontWeight.w500,
                                      color: textFilter,
                                      fontSize: 12.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
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
                                    color: textFilter,
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
                                  color: textFilter,
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
                                    color: textFilter,
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
                                  color: textFilter,
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
                                    color: textFilter,
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
                                    color: textFilter,
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
                                        color: textFilter,
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
                                        color: textFilter,
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
                                  color: textFilter,
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
                                    text: "Total Bill",
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
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: greyCardBack,
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
                  Container(
                    color: whiteColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: whiteBorderColor,
                                borderRadius: BorderRadius.circular(1)),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: "Return/Refund Policy",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                    color: nameText,
                                    fontSize: 14.sp,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: AppText(
                                      text:
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nibh augue, commodo eget pulvinar ac, pretium a ipsum.",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      maxLines: 3,
                                      color: greyTextColor,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  AppText(
                                    text: "READ POLICY",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                    color: greyTextColor,
                                    fontSize: 12.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30, bottom: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Image.asset(deliveredImage,
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: AppText(
                                        text: "Delivered in\n6 hours",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: greyTextColor,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        fontSize: 10.sp,
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image.asset(qualityImage,
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: AppText(
                                        text: "100% Quality\nassured",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: greyTextColor,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        fontSize: 10.sp,
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image.asset(locationBaseImage,
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: AppText(
                                        text: "Location based\nDeliveries",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: greyTextColor,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        fontSize: 10.sp,
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image.asset(exchangeImage,
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: AppText(
                                        text: "2 exchanges\nwithin 2 days",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: greyTextColor,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        fontSize: 10.sp,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
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
