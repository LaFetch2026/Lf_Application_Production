// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:order_tracker/order_tracker.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../utils/constants.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<TextDto> orderList = [
    TextDto("Sun, 27th Mar '22 - 10:19am", null),
  ];

  List<TextDto> shippedList = [
    TextDto("Sun, 27th Mar '22 - 10:19am", null),
  ];

  List<TextDto> outOfDeliveryList = [
    TextDto("Sun, 27th Mar '22 - 10:19am", null)
  ];

  List<TextDto> deliveredList = [TextDto("Sun, 27th Mar '22 - 10:19am", null)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BackButtonAppbar(text: "Order details", threeDot: false),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Center(
                child: Image.asset(orderDispatchImage,
                    height: 250, width: 250, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          Icons.star_border,
                          color: Colors.grey,
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
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: OrderTracker(
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
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
