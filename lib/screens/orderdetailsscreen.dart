// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
//import 'package:getwidget/getwidget.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_orderdetails.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_ordertrack.dart';
import 'package:lafetch/screens/orders/exchangeproductscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../controller/order_controller.dart';
import '../controller/product_controller.dart';
import '../utils/constants.dart';
import 'orders/reviewproducts.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailsScreen({required this.orderId, super.key});

  @override
  State<OrderDetailsScreen> createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final orderController = Get.put(OrderController());
  final productController = Get.put(ProductController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // double _rating = 0;
  String email = "";
  List<String> items = [
    "1",
    "2",
  ];
  List<String> trackOrderItem2 = [
    "Order Confirmed",
    "Packed",
    "Shipped",
    "Delivered"
  ];
  List<String> trackOrderItem = ["Confirmed", "Packed", "Shipped", "Delivered"];
  List<String> orderItem = ["CONFIRMED", "PACKED", "SHIPPED", "DELIVERED"];

  @override
  void initState() {
    getPrefrenceValue();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => orderController.getOrderDetails(widget.orderId));
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => orderController.getTrackorder(widget.orderId));
    super.initState();
  }

  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('email') != null) {
      email = prefs.getString('email')!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          const BackButtonAppbar(
            text: "Order details",
            threeDot: false,
            backgroundColor: whiteColor,
            icon: threeDotImage,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: whiteColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => orderController.isTrack.value
                            ? DummyContainer(
                                height: 250,
                                width: MediaQuery.of(context).size.width)
                            : orderController.trackList.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (orderController.trackList[
                                              orderController.trackList.length -
                                                  1]["status"] ==
                                          4) ...[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Center(
                                            child: Image.asset(placedGif,
                                                height: 250, fit: BoxFit.cover),
                                          ),
                                        )
                                      ] else if (orderController.trackList[
                                              orderController.trackList.length -
                                                  1]["status"] ==
                                          3) ...[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Center(
                                            child: Image.asset(shippedGif,
                                                height: 250, fit: BoxFit.cover),
                                          ),
                                        )
                                      ] else if (orderController.trackList[
                                              orderController.trackList.length -
                                                  1]["status"] ==
                                          2) ...[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Center(
                                            child: Image.asset(truckGif,
                                                height: 250, fit: BoxFit.cover),
                                          ),
                                        )
                                      ] else ...[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Center(
                                            child: Image.asset(shippedGif,
                                                height: 250, fit: BoxFit.cover),
                                          ),
                                        )
                                      ],
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 14, right: 14, bottom: 10),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 30,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              primary: false,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemCount: orderItem.length,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (ctx, index) {
                                                return Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 2),
                                                      child: orderController
                                                              .trackList
                                                              .any((map) =>
                                                                  map['status_details'] ==
                                                                  orderItem[
                                                                      index])
                                                          ? Image.asset(
                                                              greenDotImage,
                                                              height: 8,
                                                              width: 8,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.asset(
                                                              greyDotImage,
                                                              height: 8,
                                                              width: 8,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 4),
                                                      child: AppText(
                                                        text: orderController
                                                                .trackList
                                                                .any((map) =>
                                                                    map['status_details'] ==
                                                                    orderItem[
                                                                        index])
                                                            ? trackOrderItem[
                                                                index]
                                                            : trackOrderItem[
                                                                index],
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 10.sp,
                                                        color: orderController
                                                                .trackList
                                                                .any((map) =>
                                                                    map['status_details'] ==
                                                                    orderItem[
                                                                        index])
                                                            ? color5StartReview
                                                            : greyDotColor,
                                                      ),
                                                    ),
                                                    index == 3
                                                        ? const SizedBox(
                                                            width: 0,
                                                          )
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: Container(
                                                              width: 20,
                                                              height: 2,
                                                              color: index < 1
                                                                  ? color5StartReview
                                                                  : greyDotColor,
                                                            ),
                                                          )
                                                  ],
                                                );
                                              }),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(
                                    height: 0,
                                  )),
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
                        Obx(
                          () => orderController.isDetails.value
                              ? const DummyOrderDetails()
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 5),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: orderController.orderDetails[
                                                        "order_lines"][0]
                                                    ["product"] !=
                                                null
                                            ? SizedBox(
                                                height: 85,
                                                width: 70,
                                                child: CachedNetworkImage(
                                                  cacheManager: CacheManager(
                                                      Config(
                                                          "customCacheKey",
                                                          stalePeriod:
                                                              const Duration(
                                                                  days: 15),
                                                          maxNrOfCacheObjects:
                                                              100)),
                                                  fit: BoxFit.cover,
                                                  imageUrl: isImage(orderController
                                                                  .orderDetails["order_lines"]
                                                              [0]["product"]
                                                          ["images"][0]["name"])
                                                      ? orderController.orderDetails["order_lines"]
                                                              [0]["product"]
                                                          ["images"][0]["name"]
                                                      : orderController.orderDetails["order_lines"]
                                                              [0]["product"]
                                                          ["images"][1]["name"],
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Image.asset(
                                                    downloadImage,
                                                    fit: BoxFit.cover,
                                                    height: 85,
                                                    width: 70,
                                                  ),
                                                ),
                                              )
                                            : Image.asset(dummyWishlistImage,
                                                height: 85,
                                                width: 70,
                                                fit: BoxFit.cover),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 5,
                                              ),
                                              child: AppText(
                                                text: orderController
                                                                    .orderDetails[
                                                                "order_lines"]
                                                            [0]["product"] !=
                                                        null
                                                    ? orderController
                                                                .orderDetails[
                                                            "order_lines"][0]
                                                        ["product"]["name"]
                                                    : "",
                                                maxLines: 1,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14.sp,
                                                color: nameText,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                              child: AppText(
                                                text: orderController
                                                                    .orderDetails[
                                                                "order_lines"]
                                                            [0]["product"] !=
                                                        null
                                                    ? orderController
                                                                    .orderDetails[
                                                                "order_lines"]
                                                            [0]["product"]
                                                        ["short_description"]
                                                    : "",
                                                color: greyTextColor,
                                                maxLines: 2,
                                                fontSize: 12.sp,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                              child: Row(
                                                children: [
                                                  orderController.orderDetails[
                                                                  "order_lines"]
                                                              [
                                                              0]["inventory"] !=
                                                          null
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 10),
                                                          child: AppText(
                                                            text:
                                                                "Size : ${orderController.orderDetails["order_lines"][0]["inventory"]["product_matrix_name_size"] ?? ""}",
                                                            color:
                                                                greyTextColor,
                                                            maxLines: 2,
                                                            fontSize: 12.sp,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        )
                                                      : const SizedBox(
                                                          height: 0,
                                                        ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: AppText(
                                                        text:
                                                            "Qty :${orderController.orderDetails["order_lines"][0]["quantity"].toString()}",
                                                        color: greyTextColor,
                                                        maxLines: 2,
                                                        fontSize: 12.sp,
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                  AppText(
                                                    text:
                                                        "\u{20B9} ${orderController.orderDetails["order_lines"][0]["total"] ?? "0"}",
                                                    color: greyTextColor,
                                                    fontSize: 12.sp,
                                                    textAlign: TextAlign.right,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
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
                        ),
                        Obx(() => orderController.isTrack.value
                            ? const SizedBox(
                                height: 0,
                              )
                            : orderController.trackList.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Container(
                                      color: orderController.trackList[
                                                  orderController
                                                          .trackList.length -
                                                      1]["status"] ==
                                              4
                                          ? lightGreen
                                          : whiteBack,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 16,
                                            bottom: 16),
                                        child: Row(
                                          children: [
                                            if (orderController.trackList[
                                                    orderController.trackList.length -
                                                        1]["status"] ==
                                                4) ...[
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
                                            ] else if (orderController.trackList[
                                                    orderController.trackList.length -
                                                        1]["status"] ==
                                                3) ...[
                                              Expanded(
                                                flex: 1,
                                                child: AppText(
                                                  text: "Order Shipped",
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                  color: deepGreen,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ] else if (orderController
                                                        .trackList[orderController.trackList.length - 1]
                                                    ["status"] ==
                                                2) ...[
                                              Expanded(
                                                flex: 1,
                                                child: AppText(
                                                  text: "Order Packed",
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                  color: deepGreen,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ] else if (orderController
                                                        .trackList[orderController.trackList.length - 1]
                                                    ["status"] ==
                                                1) ...[
                                              Expanded(
                                                flex: 1,
                                                child: AppText(
                                                  text: "Order Confirmed",
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                  color: deepGreen,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                            AppText(
                                              text: orderController.trackList[
                                                      orderController.trackList
                                                              .length -
                                                          1]["created"]
                                                  .split(",")
                                                  .last,
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                              color: deepGreen,
                                              fontSize: 15.sp,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    height: 0,
                                  )),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  /*  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      color: whiteColor,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 20, bottom: 20),
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
                            /*  RatingBar.builder(
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
                            ) */
                            GFRating(
                              value: _rating,
                              borderColor: const Color(0XFFA6A39F),
                              color: Colors.amber,
                              size: 24,
                              onChanged: (value) {
                                setState(() {
                                  _rating = value;
                                  print(value);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ), */
                  Obx(() => orderController.isTrack.value
                      ? const DummyOrderTrack()
                      : orderController.trackList.isNotEmpty
                          ? Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        padding: const EdgeInsets.only(
                                            bottom: 20, top: 30),
                                        child: ListView.builder(
                                            primary: false,
                                            shrinkWrap: true,
                                            physics: const ScrollPhysics(),
                                            itemCount: orderItem.length,
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
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      orderController.trackList
                                                              .any((map) =>
                                                                  map['status_details'] ==
                                                                  orderItem[
                                                                      index])
                                                          ? Image.asset(
                                                              greenCheckImage,
                                                              height: 24,
                                                              fit: BoxFit.cover)
                                                          : Image.asset(
                                                              whiteCircleImage,
                                                              height: 24,
                                                              fit:
                                                                  BoxFit.cover),
                                                      index == 3
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
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 12),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        AppText(
                                                          text: orderController
                                                                  .trackList
                                                                  .any((map) =>
                                                                      map['status_details'] ==
                                                                      orderItem[
                                                                          index])
                                                              ? trackOrderItem2[
                                                                  index]
                                                              : trackOrderItem2[
                                                                  index],
                                                          fontFamily:
                                                              "Franklin Gothic",
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: loginText,
                                                          fontSize: 14.sp,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 8),
                                                          child: AppText(
                                                            text: orderController
                                                                    .trackList
                                                                    .any((map) =>
                                                                        map['status_details'] ==
                                                                        orderItem[
                                                                            index])
                                                                ? orderController
                                                                            .trackList[
                                                                        index]
                                                                    ["created"]
                                                                : "",
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                textHintColor,
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
                            )
                          : const SizedBox(
                              height: 0,
                            )),
                  Obx(
                    () => orderController.isDetails.value
                        ? const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : orderController.orderDetails["address"] != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Container(
                                  color: whiteColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: "Delivery Address",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: loginText,
                                          fontSize: 18.sp,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: AppText(
                                            text: orderController
                                                        .orderDetails["address"]
                                                    ["name"] ??
                                                "",
                                            fontFamily: "Franklin Gothic",
                                            fontWeight: FontWeight.w500,
                                            color: nameText,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: AppText(
                                                  text: orderController
                                                              .orderDetails[
                                                          "address"]["phone"] ??
                                                      "",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textHintColor,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: AppText(
                                                  text: email,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textHintColor,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: AppText(
                                            text: orderController.orderDetails[
                                                        "address"]["city"] !=
                                                    null
                                                ? orderController
                                                        .orderDetails["address"]
                                                    ["city"]["name"]
                                                : "",
                                            maxLines: 2,
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                            color: textHintColor,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        /* Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Text(
                                            "View on Maps",
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                              color: underlineColor,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ), */
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: AppText(
                                            text: "Billing Address",
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                            color: bottomnavBack,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: AppText(
                                            text: "Same as Delivery Address",
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                            color: textHintColor,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(
                                height: 0,
                              ),
                  ),
                  Obx(
                    () => orderController.isDetails.value
                        ? const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : orderController.orderDetails["payment"] != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Container(
                                  color: whiteColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: AppText(
                                                  text: "Total Item Price",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: loginText,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: AppText(
                                                  text:
                                                      "\u{20B9} ${orderController.orderDetails["payment"]["amount"] ?? "0"}",
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
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Row(
                                            children: [
                                              AppText(
                                                text: "You saved",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: greyTextColor,
                                                fontSize: 12.sp,
                                              ),
                                              AppText(
                                                text:
                                                    " \u{20B9} ${orderController.orderDetails["saved_total"] ?? ""}",
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w500,
                                                color: greenText,
                                                fontSize: 12.sp,
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AppText(
                                                  text: " on this item",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
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
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: AppText(
                                                  text: "Payment Method",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: bottomnavBack,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16),
                                                child: AppText(
                                                  text: orderController
                                                                  .orderDetails[
                                                              "payment"]
                                                          ["payment_service"] ??
                                                      "",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textHintColor,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4, left: 4),
                                                child: Image.asset(
                                                    razorpayImage,
                                                    height: 40,
                                                    width: 55,
                                                    fit: BoxFit.cover),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(
                                height: 0,
                              ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        color: whiteColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          child: Obx(
                            () => orderController.isDetails.value
                                ? const Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          text:
                                              "Order ID ${orderController.orderDetails["payment"] != null ? orderController.orderDetails["payment"]["transaction_id"] : ""} ",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: greyTextColor,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 20, top: 10),
                                        child: ListView.builder(
                                            primary: false,
                                            shrinkWrap: true,
                                            physics: const ScrollPhysics(),
                                            itemCount: orderController
                                                .orderDetails["order_lines"]
                                                .length,
                                            padding: EdgeInsets.zero,
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (ctx, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: Container(
                                                        color: whiteColor,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 10),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: orderController.orderDetails["order_lines"][index]["product"] !=
                                                                              null
                                                                          ? SizedBox(
                                                                              height: 85,
                                                                              width: 70,
                                                                              child: CachedNetworkImage(
                                                                                cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
                                                                                fit: BoxFit.cover,
                                                                                imageUrl: isImage(orderController.orderDetails["order_lines"][index]["product"]["images"][0]["name"]) ? orderController.orderDetails["order_lines"][index]["product"]["images"][0]["name"] : orderController.orderDetails["order_lines"][index]["product"]["images"][1]["name"],
                                                                                errorWidget: (context, url, error) => Image.asset(
                                                                                  downloadImage,
                                                                                  fit: BoxFit.cover,
                                                                                  height: 85,
                                                                                  width: 70,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : Image.asset(
                                                                              dummyWishlistImage,
                                                                              height: 85,
                                                                              width: 70,
                                                                              fit: BoxFit.cover),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 3,
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(
                                                                              horizontal: 5,
                                                                            ),
                                                                            child:
                                                                                AppText(
                                                                              text: orderController.orderDetails["order_lines"][index]["product"] != null ? orderController.orderDetails["order_lines"][index]["product"]["name"] : "",
                                                                              maxLines: 1,
                                                                              fontFamily: "Franklin Gothic Regular",
                                                                              fontWeight: FontWeight.w400,
                                                                              fontSize: 14.sp,
                                                                              color: nameText,
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                                            child:
                                                                                AppText(
                                                                              text: orderController.orderDetails["order_lines"][index]["product"] != null ? orderController.orderDetails["order_lines"][index]["product"]["short_description"] : "",
                                                                              color: greyTextColor,
                                                                              maxLines: 2,
                                                                              fontSize: 12.sp,
                                                                              fontFamily: "Franklin Gothic Regular",
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                orderController.orderDetails["order_lines"][index]["inventory"] != null
                                                                                    ? Padding(
                                                                                        padding: const EdgeInsets.only(right: 10),
                                                                                        child: AppText(
                                                                                          // text: "Size :${orderController.orderDetails["order_lines"][0]["product"]["inventories"][orderController.orderDetails["order_lines"][0]["product"]["inventories"].indexWhere((f) => f['product_matrix']['product_matrix_group']["name"] == "Size")]['product_matrix']["name"]}",
                                                                                          text: "Size : ${orderController.orderDetails["order_lines"][index]["inventory"]["product_matrix_name_size"] ?? ""}",
                                                                                          color: greyTextColor,
                                                                                          maxLines: 2,
                                                                                          fontSize: 12.sp,
                                                                                          fontFamily: "Franklin Gothic Regular",
                                                                                          fontWeight: FontWeight.w400,
                                                                                        ),
                                                                                      )
                                                                                    : const SizedBox(
                                                                                        height: 0,
                                                                                      ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(right: 10),
                                                                                  child: AppText(
                                                                                    text: "Qty :${orderController.orderDetails["order_lines"][index]["quantity"].toString()}",
                                                                                    color: greyTextColor,
                                                                                    maxLines: 2,
                                                                                    fontSize: 12.sp,
                                                                                    fontFamily: "Franklin Gothic Regular",
                                                                                    fontWeight: FontWeight.w400,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          orderController.orderDetails["status_details"] == "DELIVERED"
                                                                              ? Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    GestureDetector(
                                                                                      onTap: () async {
                                                                                        Get.to(ReviewProductScreen(
                                                                                          productId: orderController.orderDetails["order_lines"][index]["product"] != null ? orderController.orderDetails["order_lines"][index]["product"]["id"] : 0,
                                                                                          productName: orderController.orderDetails["order_lines"][index]["product"] != null ? orderController.orderDetails["order_lines"][index]["product"]["name"] : "",
                                                                                          productimage: orderController.orderDetails["order_lines"][index]["product"] != null
                                                                                              ? isImage(orderController.orderDetails["order_lines"][index]["product"]["images"][0]["name"])
                                                                                                  ? orderController.orderDetails["order_lines"][index]["product"]["images"][0]["name"]
                                                                                                  : orderController.orderDetails["order_lines"][index]["product"]["images"][1]["name"]
                                                                                              : "",
                                                                                        ));
                                                                                        await analytics.logEvent(
                                                                                          name: 'order_reviewClick',
                                                                                          parameters: <String, Object>{
                                                                                            'page_name': 'order_reviewClick',
                                                                                          },
                                                                                        );
                                                                                      },
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                                        child: AppText(
                                                                                          text: "Write a Review",
                                                                                          color: blue,
                                                                                          fontSize: 11.sp,
                                                                                          fontFamily: "Franklin Gothic Regular",
                                                                                          fontWeight: FontWeight.w400,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    orderController.orderDetails["order_lines"][index]["product"]["has_exchange"]
                                                                                        ? GestureDetector(
                                                                                            onTap: () async {
                                                                                              Get.to(ExchangeProductScreen(
                                                                                                  productId: orderController.orderDetails["order_lines"][index]["product"] != null ? orderController.orderDetails["order_lines"][index]["product"]["id"] : 0,
                                                                                                  productName: orderController.orderDetails["order_lines"][index]["product"] != null ? orderController.orderDetails["order_lines"][index]["product"]["name"] : "",
                                                                                                  productimage: orderController.orderDetails["order_lines"][index]["product"] != null
                                                                                                      ? isImage(orderController.orderDetails["order_lines"][index]["product"]["images"][0]["name"])
                                                                                                          ? orderController.orderDetails["order_lines"][index]["product"]["images"][0]["name"]
                                                                                                          : orderController.orderDetails["order_lines"][index]["product"]["images"][1]["name"]
                                                                                                      : "",
                                                                                                  orderId: orderController.orderDetails["id"],
                                                                                                  sizeId: orderController.orderDetails["order_lines"][index]["inventory"]["id"] ?? 0,
                                                                                                  productDescription: orderController.orderDetails["order_lines"][index]["product"] != null ? orderController.orderDetails["order_lines"][index]["product"]["short_description"] : ""));
                                                                                              await analytics.logEvent(
                                                                                                name: 'order_exchangeClick',
                                                                                                parameters: <String, Object>{
                                                                                                  'page_name': 'order_exchangeClick',
                                                                                                },
                                                                                              );
                                                                                            },
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                                              child: AppText(
                                                                                                text: "Exchange",
                                                                                                color: blue,
                                                                                                fontSize: 11.sp,
                                                                                                fontFamily: "Franklin Gothic Regular",
                                                                                                fontWeight: FontWeight.w400,
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                        : SizedBox(
                                                                                            height: 0,
                                                                                          ),
                                                                                    GestureDetector(
                                                                                      onTap: () {
                                                                                        productController.sizeInventoryId.value = orderController.orderDetails["order_lines"][0]["inventory"]["id"];
                                                                                        productController.callAddtoCart(orderController.orderDetails["order_lines"][0]["quantity"], "reorder");
                                                                                      },
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                                        child: productController.isReorder.value
                                                                                            ? const SizedBox(
                                                                                                height: 10,
                                                                                                width: 10,
                                                                                                child: Center(child: CircularProgressIndicator()),
                                                                                              )
                                                                                            : AppText(
                                                                                                text: "Reorder",
                                                                                                color: blue,
                                                                                                fontSize: 11.sp,
                                                                                                fontFamily: "Franklin Gothic Regular",
                                                                                                fontWeight: FontWeight.w400,
                                                                                              ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              : const SizedBox(
                                                                                  height: 0,
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
                                                text: "Total Order Price",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: loginText,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: AppText(
                                                text:
                                                    "\u{20B9} ${orderController.orderDetails["total"] ?? "0"}",
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Row(
                                          children: [
                                            AppText(
                                              text: "You saved",
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                              color: greyTextColor,
                                              fontSize: 12.sp,
                                            ),
                                            AppText(
                                              text:
                                                  " \u{20B9} ${orderController.orderDetails["saved_total"] ?? ""}",
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                              color: greenText,
                                              fontSize: 12.sp,
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: AppText(
                                                text: " on this item",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
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
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
