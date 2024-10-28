// ignore_for_file: avoid_print
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fl_downloader/fl_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
//import 'package:getwidget/getwidget.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_order_address.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_orderpayment.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_orderdetails.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_ordertrack.dart';
import 'package:lafetch/screens/orders/delivery_track.dart';
import 'package:lafetch/screens/orders/exchangeproductscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../commonwidget/homewidget/dummy_estimatedelivery.dart';
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
  final TextEditingController fileNameController = TextEditingController(
    text: 'test.pdf',
  );
  /* final TextEditingController urlController = TextEditingController(
    text:
        'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
  ); */
  /* int progress = 0;
  dynamic downloadId;
  String? status;
  late StreamSubscription progressStream; */

  @override
  void initState() {
    getPrefrenceValue();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => orderController.getOrderDetails(widget.orderId));
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => orderController.getTrackorder(widget.orderId));
    FlDownloader.initialize();
    /*    progressStream = FlDownloader.progressStream.listen((event) {
      if (event.status == DownloadStatus.successful) {
        debugPrint('event.progress: ${event.progress}');
        setState(() {
          progress = event.progress;
          downloadId = event.downloadId;
          status = event.status.name;
        });
        getSnackBar("Invoice downloaded");
        print("abc${event.filePath}");
        //  FlDownloader.openFile(filePath: event.filePath);
      } else if (event.status == DownloadStatus.running) {
        debugPrint('event.progress: ${event.progress}');
        setState(() {
          progress = event.progress;
          downloadId = event.downloadId;
          status = event.status.name;
        });
      } else if (event.status == DownloadStatus.failed) {
        debugPrint('event: $event');
        setState(() {
          progress = event.progress;
          downloadId = event.downloadId;
          status = event.status.name;
        });
      } else if (event.status == DownloadStatus.paused) {
        debugPrint('Download paused');
        setState(() {
          progress = event.progress;
          downloadId = event.downloadId;
          status = event.status.name;
        });
        Future.delayed(
          const Duration(milliseconds: 250),
          () => FlDownloader.attachDownloadProgress(event.downloadId),
        );
      } else if (event.status == DownloadStatus.pending) {
        debugPrint('Download pending');
        setState(() {
          progress = event.progress;
          downloadId = event.downloadId;
          status = event.status.name;
        });
      }
    });
    */
    super.initState();
  }

  @override
  void dispose() {
    // progressStream.cancel();
    super.dispose();
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
                                          padding: EdgeInsets.only(top: 5.sp),
                                          child: Center(
                                            child: Image.asset(placedGif,
                                                height: 250.sp,
                                                fit: BoxFit.cover),
                                          ),
                                        )
                                      ] else if (orderController.trackList[
                                              orderController.trackList.length -
                                                  1]["status"] ==
                                          3) ...[
                                        Padding(
                                          padding: EdgeInsets.only(top: 5.sp),
                                          child: Center(
                                            child: Image.asset(shippedGif,
                                                height: 250.sp,
                                                fit: BoxFit.cover),
                                          ),
                                        )
                                      ] else if (orderController.trackList[
                                              orderController.trackList.length -
                                                  1]["status"] ==
                                          2) ...[
                                        Padding(
                                          padding: EdgeInsets.only(top: 5.sp),
                                          child: Center(
                                            child: Image.asset(truckGif,
                                                height: 250.sp,
                                                fit: BoxFit.cover),
                                          ),
                                        )
                                      ] else ...[
                                        Padding(
                                          padding: EdgeInsets.only(top: 5.sp),
                                          child: Center(
                                            child: Image.asset(shippedGif,
                                                height: 250.sp,
                                                fit: BoxFit.cover),
                                          ),
                                        )
                                      ],
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 14.sp,
                                            right: 14.sp,
                                            bottom: 10.sp),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 30.sp,
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
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 2.sp),
                                                      child: orderController
                                                              .trackList
                                                              .any((map) =>
                                                                  map['status_details'] ==
                                                                  orderItem[
                                                                      index])
                                                          ? Image.asset(
                                                              greenDotImage,
                                                              height: 8.sp,
                                                              width: 8.sp,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.asset(
                                                              greyDotImage,
                                                              height: 8.sp,
                                                              width: 8.sp,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.sp),
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
                                                        fontSize: 10,
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
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        2.sp),
                                                            child: Container(
                                                              width: 20.sp,
                                                              height: 2.sp,
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.sp, vertical: 10.sp),
                          child: AppText(
                            text: "Order Details",
                            maxLines: 1,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            color: loginText,
                          ),
                        ),
                        Obx(
                          () => orderController.isDetails.value
                              ? const DummyOrderDetails()
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.sp, vertical: 5.sp),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: orderController.orderDetails[
                                                        "order_lines"][0]
                                                    ["product"] !=
                                                null
                                            ? SizedBox(
                                                height: 85.sp,
                                                width: 70.sp,
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
                                                    height: 85.sp,
                                                    width: 70.sp,
                                                  ),
                                                ),
                                              )
                                            : Image.asset(dummyWishlistImage,
                                                height: 85.sp,
                                                width: 70.sp,
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
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5.sp,
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
                                                fontSize: 14,
                                                color: nameText,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5.sp,
                                                  vertical: 5.sp),
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
                                                fontSize: 12,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5.sp,
                                                  vertical: 5.sp),
                                              child: Row(
                                                children: [
                                                  orderController.orderDetails[
                                                                  "order_lines"]
                                                              [
                                                              0]["inventory"] !=
                                                          null
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10.sp),
                                                          child: AppText(
                                                            text:
                                                                "Size : ${orderController.orderDetails["order_lines"][0]["inventory"]["product_matrix_name_size"] ?? ""}",
                                                            color:
                                                                greyTextColor,
                                                            maxLines: 2,
                                                            fontSize: 12,
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
                                                      padding: EdgeInsets.only(
                                                          right: 10.sp),
                                                      child: AppText(
                                                        text:
                                                            "Qty :${orderController.orderDetails["order_lines"][0]["quantity"].toString()}",
                                                        color: greyTextColor,
                                                        maxLines: 2,
                                                        fontSize: 12,
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
                                                    fontSize: 12,
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
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.sp, vertical: 10.sp),
                                    child: Container(
                                      color: orderController.trackList[
                                                  orderController
                                                          .trackList.length -
                                                      1]["status"] ==
                                              4
                                          ? lightGreen
                                          : whiteBack,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.sp,
                                            right: 16.sp,
                                            top: 16.sp,
                                            bottom: 16.sp),
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
                                                  fontSize: 14,
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
                                                  fontSize: 14,
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
                                                  fontSize: 14,
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
                                                  fontSize: 14,
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
                                              fontSize: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    height: 0,
                                  )),
                        SizedBox(
                          height: 20.sp,
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.sp, vertical: 16.sp),
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
                                        fontSize: 18,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 20.sp, top: 30.sp),
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
                                                              height: 24.sp,
                                                              fit: BoxFit.cover)
                                                          : Image.asset(
                                                              whiteCircleImage,
                                                              height: 24.sp,
                                                              fit:
                                                                  BoxFit.cover),
                                                      index == 3
                                                          ? const SizedBox(
                                                              height: 0,
                                                            )
                                                          : Container(
                                                              width: 2.sp,
                                                              height: 60.sp,
                                                              color: greyBack,
                                                            )
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12.sp),
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
                                                          fontSize: 14,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 8.sp),
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
                                                            fontSize: 14,
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
                        ? DummyOrderAddress()
                        : orderController.orderDetails["address"] != null
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.sp),
                                child: Container(
                                  color: whiteColor,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10.sp, horizontal: 16.sp),
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
                                          fontSize: 18,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.sp),
                                          child: AppText(
                                            text: orderController
                                                        .orderDetails["address"]
                                                    ["name"] ??
                                                "",
                                            fontFamily: "Franklin Gothic",
                                            fontWeight: FontWeight.w500,
                                            color: nameText,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 5.sp),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 10.sp),
                                                child: AppText(
                                                  text: orderController
                                                              .orderDetails[
                                                          "address"]["phone"] ??
                                                      "",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textHintColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5.sp),
                                                  child: AppText(
                                                    text: email,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                    color: textHintColor,
                                                    maxLines: 1,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.sp),
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
                                            fontSize: 14,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(DeliverTrackScreen(
                                                //change delivery partner lat lng
                                                dropLat: double.parse(
                                                    orderController
                                                            .orderDetails[
                                                        "address"]["latitude"]),
                                                dropLng: double.parse(
                                                    orderController
                                                                .orderDetails[
                                                            "address"]
                                                        ["longitude"]),
                                                deliverPartnerLat: 28.6263,
                                                deliverPartnerLng: 77.2185));
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5.sp),
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
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 20.sp),
                                          child: AppText(
                                            text: "Billing Address",
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                            color: bottomnavBack,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.sp),
                                          child: AppText(
                                            text: "Same as Delivery Address",
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                            color: textHintColor,
                                            fontSize: 14,
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
                        ? DummyOrderPayment()
                        : orderController.orderDetails["payment"] != null
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.sp),
                                child: Container(
                                  color: whiteColor,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10.sp, horizontal: 16.sp),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 5.sp),
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
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.sp),
                                                child: AppText(
                                                  text:
                                                      "\u{20B9} ${orderController.orderDetails["payment"]["amount"] ?? "0"}",
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                  color: loginText,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 8.sp),
                                          child: Row(
                                            children: [
                                              AppText(
                                                text: "You saved",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: greyTextColor,
                                                fontSize: 12,
                                              ),
                                              AppText(
                                                text:
                                                    " \u{20B9} ${orderController.orderDetails["saved_total"] ?? ""}",
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w500,
                                                color: greenText,
                                                fontSize: 12,
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AppText(
                                                  text: " on this item",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: greyTextColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              /*  AppText(
                                                text: "View Breakup",
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w500,
                                                color: blackColor,
                                                fontSize: 12.sp,
                                              ), */
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.sp),
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
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 16.sp),
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
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 4.sp, left: 4.sp),
                                                child: Image.asset(
                                                    razorpayImage,
                                                    height: 40.sp,
                                                    width: 55.sp,
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
                      padding: EdgeInsets.symmetric(vertical: 10.sp),
                      child: Container(
                        color: whiteColor,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.sp, horizontal: 16.sp),
                          child: Obx(
                            () => orderController.isDetails.value
                                ? const DummyEstimateDelivery()
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 16.sp),
                                        child: AppText(
                                          text: "Other items in this order",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: loginText,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5.sp),
                                        child: AppText(
                                          text:
                                              "Order ID ${orderController.orderDetails["payment"] != null ? orderController.orderDetails["payment"]["transaction_id"] : ""} ",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: greyTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 20.sp, top: 10.sp),
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
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5.sp),
                                                child: Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: Container(
                                                        color: whiteColor,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.sp),
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
                                                                              height: 85.sp,
                                                                              width: 70.sp,
                                                                              child: CachedNetworkImage(
                                                                                cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
                                                                                fit: BoxFit.cover,
                                                                                imageUrl: isImage(orderController.orderDetails["order_lines"][index]["product"]["images"][0]["name"]) ? orderController.orderDetails["order_lines"][index]["product"]["images"][0]["name"] : orderController.orderDetails["order_lines"][index]["product"]["images"][1]["name"],
                                                                                errorWidget: (context, url, error) => Image.asset(
                                                                                  downloadImage,
                                                                                  fit: BoxFit.cover,
                                                                                  height: 85.sp,
                                                                                  width: 70.sp,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : Image.asset(
                                                                              dummyWishlistImage,
                                                                              height: 85.sp,
                                                                              width: 70.sp,
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
                                                                                EdgeInsets.symmetric(
                                                                              horizontal: 5.sp,
                                                                            ),
                                                                            child:
                                                                                AppText(
                                                                              text: orderController.orderDetails["order_lines"][index]["product"] != null ? orderController.orderDetails["order_lines"][index]["product"]["name"] : "",
                                                                              maxLines: 1,
                                                                              fontFamily: "Franklin Gothic Regular",
                                                                              fontWeight: FontWeight.w400,
                                                                              fontSize: 14,
                                                                              color: nameText,
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
                                                                            child:
                                                                                AppText(
                                                                              text: orderController.orderDetails["order_lines"][index]["product"] != null ? orderController.orderDetails["order_lines"][index]["product"]["short_description"] : "",
                                                                              color: greyTextColor,
                                                                              maxLines: 2,
                                                                              fontSize: 12,
                                                                              fontFamily: "Franklin Gothic Regular",
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                orderController.orderDetails["order_lines"][index]["inventory"] != null
                                                                                    ? Padding(
                                                                                        padding: EdgeInsets.only(right: 10.sp),
                                                                                        child: AppText(
                                                                                          // text: "Size :${orderController.orderDetails["order_lines"][0]["product"]["inventories"][orderController.orderDetails["order_lines"][0]["product"]["inventories"].indexWhere((f) => f['product_matrix']['product_matrix_group']["name"] == "Size")]['product_matrix']["name"]}",
                                                                                          text: "Size : ${orderController.orderDetails["order_lines"][index]["inventory"]["product_matrix_name_size"] ?? ""}",
                                                                                          color: greyTextColor,
                                                                                          maxLines: 2,
                                                                                          fontSize: 12,
                                                                                          fontFamily: "Franklin Gothic Regular",
                                                                                          fontWeight: FontWeight.w400,
                                                                                        ),
                                                                                      )
                                                                                    : const SizedBox(
                                                                                        height: 0,
                                                                                      ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(right: 10.sp),
                                                                                  child: AppText(
                                                                                    text: "Qty :${orderController.orderDetails["order_lines"][index]["quantity"].toString()}",
                                                                                    color: greyTextColor,
                                                                                    maxLines: 2,
                                                                                    fontSize: 12,
                                                                                    fontFamily: "Franklin Gothic Regular",
                                                                                    fontWeight: FontWeight.w400,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          orderController.orderDetails["status_details"] == "DELIVERED" || orderController.orderDetails["status_details"] == "COMPLETED"
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
                                                                                        padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 2.sp),
                                                                                        child: AppText(
                                                                                          text: "Write a Review",
                                                                                          color: blue,
                                                                                          fontSize: 11,
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
                                                                                              padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 2.sp),
                                                                                              child: AppText(
                                                                                                text: "Exchange",
                                                                                                color: blue,
                                                                                                fontSize: 11,
                                                                                                fontFamily: "Franklin Gothic Regular",
                                                                                                fontWeight: FontWeight.w400,
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                        : Padding(
                                                                                            padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 2.sp),
                                                                                            child: AppText(
                                                                                              text: "No Exchange",
                                                                                              color: greyTextColor,
                                                                                              fontSize: 11,
                                                                                              fontFamily: "Franklin Gothic Regular",
                                                                                              fontWeight: FontWeight.w400,
                                                                                            ),
                                                                                          ),
                                                                                    GestureDetector(
                                                                                      onTap: () {
                                                                                        productController.sizeInventoryId.value = orderController.orderDetails["order_lines"][index]["inventory"]["id"];
                                                                                        productController.callAddtoCart(orderController.orderDetails["order_lines"][index]["quantity"], "reorder");
                                                                                      },
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 2.sp),
                                                                                        child: /*  productController.isReorder.value
                                                                                            ? const SizedBox(
                                                                                                height: 10,
                                                                                                width: 10,
                                                                                                child: Center(child: CircularProgressIndicator()),
                                                                                              )
                                                                                            :  */
                                                                                            AppText(
                                                                                          text: "Reorder",
                                                                                          color: blue,
                                                                                          fontSize: 11,
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
                                        padding: EdgeInsets.only(top: 5.sp),
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
                                                fontSize: 14,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5.sp),
                                              child: AppText(
                                                text:
                                                    "\u{20B9} ${orderController.orderDetails["total"] ?? "0"}",
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w500,
                                                color: loginText,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.sp),
                                        child: Row(
                                          children: [
                                            AppText(
                                              text: "You saved",
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                              color: greyTextColor,
                                              fontSize: 12,
                                            ),
                                            AppText(
                                              text:
                                                  " \u{20B9} ${orderController.orderDetails["saved_total"] ?? ""}",
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                              color: greenText,
                                              fontSize: 12,
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: AppText(
                                                text: " on this item",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: greyTextColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                            /*  AppText(
                                              text: "View Breakup",
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                              color: blackColor,
                                              fontSize: 12.sp,
                                            ), */
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      )),
                  Obx(() => Padding(
                        padding: EdgeInsets.only(top: 20.sp, bottom: 30.sp),
                        child: getSingleButton(
                            label: "Download Invoice",
                            controller: orderController,
                            textColor: whiteTextColor,
                            backgroundColor: btnTextColor,
                            onPressed: () async {
                              final permission =
                                  await FlDownloader.requestPermission();
                              if (permission ==
                                  StoragePermissionStatus.granted) {
                                /*   await FlDownloader.download(
                                                  urlController.text,
                                                  fileName:
                                                      fileNameController.text,
                                                ); */
                                orderController
                                    .getDownloadInvoice(widget.orderId);
                              } else {
                                debugPrint('Permission denied =(');
                              }
                              await analytics.logEvent(
                                name: 'download_invoice',
                                parameters: <String, Object>{
                                  'page_name': 'download_invoice',
                                },
                              );
                            },
                            borderColor: btnTextColor),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
