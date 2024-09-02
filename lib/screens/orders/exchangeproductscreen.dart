// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lafetch/commonwidget/appbarwidgets/backbutton_appbar.dart';
import 'package:lafetch/controller/exchange_controller.dart';
import 'package:lafetch/controller/review_controller.dart';
import 'package:lafetch/screens/orders/exchangeconfirm.dart';
import 'package:lafetch/utils/constants.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/cartwidgets/bottomsize.dart';

class ExchangeProductScreen extends StatefulWidget {
  final int productId;
  final String productName;
  final String productDescription;
  final String productimage;
  final int sizeId;
  const ExchangeProductScreen(
      {super.key,
      required this.productId,
      required this.productName,
      required this.productimage,
      required this.sizeId,
      required this.productDescription});

  @override
  State<ExchangeProductScreen> createState() => ExchangeProductScreenState();
}

class ExchangeProductScreenState extends State<ExchangeProductScreen> {
  final controller = Get.put(ReviewController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  String? text1;
  final exchangeController = Get.put(ExchangeController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    exchangeController.getProductDetails(widget.productId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: whiteColor,
      body: Column(
        children: [
          const BackButtonAppbar(
            text: "Exchange Product",
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 85,
                                  width: 70,
                                  child: CachedNetworkImage(
                                    cacheManager: CacheManager(Config(
                                        "customCacheKey",
                                        stalePeriod: const Duration(days: 15),
                                        maxNrOfCacheObjects: 100)),
                                    fit: BoxFit.cover,
                                    imageUrl: widget.productimage,
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      downloadImage,
                                      fit: BoxFit.cover,
                                      height: 85,
                                      width: 70,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: AppText(
                                        text: widget.productName,
                                        maxLines: 2,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.sp,
                                        color: nameText,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      child: AppText(
                                        text: Bidi.stripHtmlIfNeeded(
                                            widget.productDescription),
                                        maxLines: 2,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.sp,
                                        color: nameText,
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
                          child: AppText(
                            text: "Choose why you exchanging this?",
                            maxLines: 2,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                            color: loginText,
                          ),
                        ),
                        Obx(
                          () => exchangeController.isDetails.value
                              ? Center(
                                  child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: const CircularProgressIndicator(),
                                ))
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Radio(
                                              value: "Ordered wrong size",
                                              activeColor: colorPrimary,
                                              groupValue: text1,
                                              onChanged: (value) async {
                                                text1 = value.toString();
                                                scaffoldKey.currentState
                                                    ?.showBottomSheet(
                                                        (context) => BottomSize(
                                                              sizeList: exchangeController
                                                                      .productDetails[
                                                                  "new_inventories"],
                                                              controller:
                                                                  controller,
                                                              onPressedCross:
                                                                  () {
                                                                Get.back();
                                                                text1 = "";
                                                                setState(() {});
                                                              },
                                                              onPressed: (p0) {
                                                                text1 = "";
                                                                setState(() {});
                                                                Get.back();
                                                                Get.to(ExchangeConfirmScreen(
                                                                    sizeId: widget
                                                                        .sizeId,
                                                                    productId:
                                                                        widget
                                                                            .productId,
                                                                    productName:
                                                                        widget
                                                                            .productName,
                                                                    productimage:
                                                                        widget
                                                                            .productimage,
                                                                    productDescription:
                                                                        widget
                                                                            .productDescription));
                                                              },
                                                              selectedSizeId:
                                                                  widget.sizeId,
                                                            ));
                                                await analytics.logEvent(
                                                  name:
                                                      'exchange_product_updatesizeClick',
                                                  parameters: <String, Object>{
                                                    'page_name':
                                                        'exchange_product_updatesizeClick',
                                                  },
                                                );
                                                setState(() {});
                                              }),
                                          GestureDetector(
                                            onTap: () async {
                                              text1 = "Ordered wrong size";
                                              scaffoldKey.currentState
                                                  ?.showBottomSheet((context) =>
                                                      BottomSize(
                                                        sizeList: exchangeController
                                                                .productDetails[
                                                            "new_inventories"],
                                                        controller: controller,
                                                        onPressedCross: () {
                                                          Get.back();
                                                          text1 = "";
                                                          setState(() {});
                                                        },
                                                        onPressed: (p0) {
                                                          text1 = "";
                                                          setState(() {});
                                                          Get.back();
                                                          Get.to(ExchangeConfirmScreen(
                                                              sizeId:
                                                                  widget.sizeId,
                                                              productId: widget
                                                                  .productId,
                                                              productName: widget
                                                                  .productName,
                                                              productimage: widget
                                                                  .productimage,
                                                              productDescription:
                                                                  widget
                                                                      .productDescription));
                                                        },
                                                        selectedSizeId:
                                                            widget.sizeId,
                                                      ));
                                              await analytics.logEvent(
                                                name:
                                                    'exchange_product_updatesizeClick',
                                                parameters: <String, Object>{
                                                  'page_name':
                                                      'exchange_product_updatesizeClick',
                                                },
                                              );
                                              setState(() {});
                                            },
                                            child: Text(
                                              "Ordered wrong size",
                                              style: TextStyle(
                                                color: colorPrimary,
                                                fontSize: 14.sp,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio(
                                              value: "Others",
                                              activeColor: colorPrimary,
                                              groupValue: text1,
                                              onChanged: (value) async {
                                                text1 = value.toString();
                                                setState(() {});
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            ExchangeConfirmScreen(
                                                                sizeId: 0,
                                                                productId:
                                                                    widget
                                                                        .productId,
                                                                productName: widget
                                                                    .productName,
                                                                productimage: widget
                                                                    .productimage,
                                                                productDescription:
                                                                    widget
                                                                        .productDescription)))
                                                    .then((value) => setState(
                                                          () {
                                                            text1 = "";
                                                          },
                                                        ));
                                                await analytics.logEvent(
                                                  name:
                                                      'submit_productExchangeOtherClick',
                                                  parameters: <String, Object>{
                                                    'page_name':
                                                        'submit_productExchangeOtherClick',
                                                  },
                                                );
                                              }),
                                          GestureDetector(
                                            onTap: () async {
                                              text1 = "Others";
                                              setState(() {});
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          ExchangeConfirmScreen(
                                                              sizeId: 0,
                                                              productId: widget
                                                                  .productId,
                                                              productName: widget
                                                                  .productName,
                                                              productimage: widget
                                                                  .productimage,
                                                              productDescription:
                                                                  widget
                                                                      .productDescription)))
                                                  .then((value) => setState(
                                                        () {
                                                          text1 = "";
                                                        },
                                                      ));
                                              await analytics.logEvent(
                                                name:
                                                    'submit_productExchangeOtherClick',
                                                parameters: <String, Object>{
                                                  'page_name':
                                                      'submit_productExchangeOtherClick',
                                                },
                                              );
                                            },
                                            child: Text(
                                              "Others",
                                              style: TextStyle(
                                                color: colorPrimary,
                                                fontSize: 14.sp,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
