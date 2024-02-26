// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../utils/constants.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<String> items = [
    "1",
    "2",
  ];
  List<String> trackOrderItem = ["Order Confirmed", "Shipped", "Delivered"];
  /* List<TextDto> orderList = [
    TextDto("Sun, 27th Mar '22 - 10:19am", null),
  ];

  List<TextDto> shippedList = [
    TextDto("Sun, 27th Mar '22 - 10:19am", null),
  ];

  List<TextDto> outOfDeliveryList = [
    TextDto("Sun, 27th Mar '22 - 10:19am", null)
  ];

  List<TextDto> deliveredList = [TextDto("Sun, 27th Mar '22 - 10:19am", null)]; */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          const BackButtonAppbar(
            text: "Order details",
            threeDot: false,
            icon: threeDotImage,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Center(
                      child: Image.asset(orderDispatchImage,
                          height: 250, width: 250, fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: AppText(
                      text: "Order Details",
                      maxLines: 1,
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      fontSize: 18.sp,
                      color: loginText,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Image.asset(backImage,
                              height: 85, width: 70, fit: BoxFit.cover),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: AppText(
                                  text:
                                      "Topman super skinny suit jacket and trousers in light blue",
                                  maxLines: 1,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  color: nameText,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: AppText(
                                  text: "Jack & Jones Core",
                                  color: greyTextColor,
                                  maxLines: 2,
                                  fontSize: 12.sp,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: Row(
                                  children: [
                                    AppText(
                                      text: "Size :M",
                                      color: greyTextColor,
                                      maxLines: 2,
                                      fontSize: 12.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: AppText(
                                          text: "Qty :1",
                                          color: greyTextColor,
                                          maxLines: 2,
                                          fontSize: 12.sp,
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    AppText(
                                      text: "\u{20B9} ${120.00}",
                                      color: greyTextColor,
                                      fontSize: 12.sp,
                                      textAlign: TextAlign.right,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Container(
                      color: lightGreen,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 16, bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: AppText(
                                text: "Delivered",
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w500,
                                color: deepGreen,
                                fontSize: 14.sp,
                              ),
                            ),
                            AppText(
                              text: "29 July 2023",
                              fontFamily: "Franklin Gothic",
                              fontWeight: FontWeight.w500,
                              color: deepGreen,
                              fontSize: 15.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      color: whiteColor,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 16, bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: AppText(
                                text: "Rate this Product",
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: loginText,
                                fontSize: 16.sp,
                              ),
                            ),
                            RatingBar.builder(
                              initialRating: 0,
                              minRating: 1,
                              itemSize: 24,
                              unratedColor: whiteBorderColor,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 1.0),
                              itemBuilder: (context, _) => const Icon(
                                //  Icons.star_border,
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: whiteColor,
                    width: double.infinity,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: /* OrderTracker(
                        status: Status.order,
                        subTitleTextStyle: TextStyle(
                            color: textHintColor,
                            fontFamily: "Franklin Gothic Regular",
                            fontSize: 14.sp),
                        headingTitleStyle: TextStyle(
                            color: loginText,
                            fontFamily: "Franklin Gothic",
                            fontSize: 14.sp),
                        activeColor: Colors.green,
                        inActiveColor: Colors.grey[300],
                        orderTitleAndDateList: orderList,
                        shippedTitleAndDateList: shippedList,
                        outOfDeliveryTitleAndDateList: outOfDeliveryList,
                        deliveredTitleAndDateList: deliveredList,
                      ), */
                            Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AppText(
                              text: "Track Item",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: loginText,
                              fontSize: 18.sp,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 20, top: 30),
                              child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: trackOrderItem.length,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(greenCheckImage,
                                                height: 24, fit: BoxFit.cover),
                                            index == 2
                                                ? const SizedBox(
                                                    height: 0,
                                                  )
                                                : Container(
                                                    width: 2,
                                                    height: 60,
                                                    color: greyBack,
                                                  )
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AppText(
                                                text: trackOrderItem[index],
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w500,
                                                color: loginText,
                                                fontSize: 14.sp,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: AppText(
                                                  text: "3:30 PM, 24 July 2023",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textHintColor,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      color: whiteColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: "Delivery Address",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: loginText,
                              fontSize: 18.sp,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: AppText(
                                text: "Jane Doe",
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w500,
                                color: nameText,
                                fontSize: 14.sp,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  AppText(
                                    text: "example@mail.com",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: textHintColor,
                                    fontSize: 14.sp,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: AppText(
                                      text: "+9178xxxxxx23",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: textHintColor,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: AppText(
                                text:
                                    "123 Green Park, New Delhi, Delhi, 110016, India",
                                maxLines: 2,
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: textHintColor,
                                fontSize: 14.sp,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                "View on Maps",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w500,
                                  color: textHintColor,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: AppText(
                                text: "Billing Address",
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: bottomnavBack,
                                fontSize: 12.sp,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: AppText(
                                text: "Same as Delivery Address",
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: textHintColor,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      color: whiteColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: AppText(
                                      text: "Total Item Price",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: loginText,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: AppText(
                                      text: "\u{20B9} ${125.00}",
                                      fontFamily: "Franklin Gothic",
                                      fontWeight: FontWeight.w500,
                                      color: loginText,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  AppText(
                                    text: "You saved",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: greyTextColor,
                                    fontSize: 12.sp,
                                  ),
                                  AppText(
                                    text: " \u{20B9} ${125.00}",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                    color: greenText,
                                    fontSize: 12.sp,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: AppText(
                                      text: " on this item",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: greyTextColor,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  AppText(
                                    text: "View Breakup",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                    color: blackColor,
                                    fontSize: 12.sp,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: AppText(
                                      text: "Payment Method",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: bottomnavBack,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: AppText(
                                      text: "Google Pay",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: textHintColor,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Image.asset(gPayImage,
                                      height: 18, fit: BoxFit.cover),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      color: whiteColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: AppText(
                                text: "Other items in this order",
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: loginText,
                                fontSize: 18.sp,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: AppText(
                                text: "Order ID #123456789 ",
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: greyTextColor,
                                fontSize: 14.sp,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 20, top: 10),
                              child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: items.length,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              color: whiteColor,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Image.asset(
                                                                backImage,
                                                                height: 85,
                                                                width: 70,
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        5,
                                                                  ),
                                                                  child:
                                                                      AppText(
                                                                    text:
                                                                        "Topman super skinny suit jacket and trousers in light blue",
                                                                    maxLines: 1,
                                                                    fontFamily:
                                                                        "Franklin Gothic Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        14.sp,
                                                                    color:
                                                                        nameText,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5,
                                                                      vertical:
                                                                          5),
                                                                  child:
                                                                      AppText(
                                                                    text:
                                                                        "Jack & Jones Core",
                                                                    color:
                                                                        greyTextColor,
                                                                    maxLines: 2,
                                                                    fontSize:
                                                                        12.sp,
                                                                    fontFamily:
                                                                        "Franklin Gothic Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5,
                                                                      vertical:
                                                                          5),
                                                                  child: Row(
                                                                    children: [
                                                                      AppText(
                                                                        text:
                                                                            "Size :M",
                                                                        color:
                                                                            greyTextColor,
                                                                        maxLines:
                                                                            2,
                                                                        fontSize:
                                                                            12.sp,
                                                                        fontFamily:
                                                                            "Franklin Gothic Regular",
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(horizontal: 10),
                                                                        child:
                                                                            AppText(
                                                                          text:
                                                                              "Qty :1",
                                                                          color:
                                                                              greyTextColor,
                                                                          maxLines:
                                                                              2,
                                                                          fontSize:
                                                                              12.sp,
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
                                                          )
                                                        ],
                                                      ),
                                                    ]),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: AppText(
                                      text: "Total Item Price",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: loginText,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: AppText(
                                      text: "\u{20B9} ${1330.00}",
                                      fontFamily: "Franklin Gothic",
                                      fontWeight: FontWeight.w500,
                                      color: loginText,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  AppText(
                                    text: "You saved",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: greyTextColor,
                                    fontSize: 12.sp,
                                  ),
                                  AppText(
                                    text: " \u{20B9} ${125.00}",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                    color: greenText,
                                    fontSize: 12.sp,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: AppText(
                                      text: " on this item",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: greyTextColor,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  AppText(
                                    text: "View Breakup",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                    color: blackColor,
                                    fontSize: 12.sp,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
