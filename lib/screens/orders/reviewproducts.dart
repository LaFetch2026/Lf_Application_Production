// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../controller/order_controller.dart';
import '../../utils/constants.dart';

class ReviewProductScreen extends StatefulWidget {
  final String productName;
  final int productId;
  final int orderId;
  final String productimage;
  const ReviewProductScreen(
      {super.key,
      required this.productName,
      required this.productimage,
      required this.orderId,
      required this.productId});

  @override
  State<ReviewProductScreen> createState() => ReviewProductScreenState();
}

class ReviewProductScreenState extends State<ReviewProductScreen> {
  final controller = Get.put(OrderController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    controller.rating.value = 0.0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          const BackButtonAppbar(
            text: "Review Product",
            threeDot: false,
            backgroundColor: whiteColor,
            icon: threeDotImage,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: whiteColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.sp, vertical: 20.sp),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 85.sp,
                                width: 70.sp,
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
                                    height: 85.sp,
                                    width: 70.sp,
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.sp,
                                    ),
                                    child: AppText(
                                      text: widget.productName,
                                      maxLines: 2,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: nameText,
                                    ),
                                  ),
                                  Obx(
                                    () => Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10.sp, horizontal: 10.sp),
                                      child: GFRating(
                                        value: controller.rating.value,
                                        borderColor: const Color(0XFFA6A39F),
                                        color: Colors.amber,
                                        size: 24.sp,
                                        onChanged: (value) {
                                          controller.rating.value = value;
                                          print(controller.rating.value);
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.sp,
                        ),
                        child: AppText(
                          text: "Write a Review",
                          maxLines: 2,
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: loginText,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.sp, vertical: 10.sp),
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                          ),
                          controller: controller.comment,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: whiteTextColor,
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1.sp),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1.sp),
                              borderSide: const BorderSide(color: borderColor),
                            ),
                            counterText: "",
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.sp, vertical: 10.sp),
                            hintText:
                                "How is the product? What do you like? What do you hate?",
                            hintStyle: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ),
                      Obx(() => Padding(
                            padding: EdgeInsets.only(top: 30.sp, bottom: 10.sp),
                            child: getSingleButton(
                                label: "Submit",
                                textColor: btnTextColor,
                                controller: controller,
                                backgroundColor: whiteColor,
                                onPressed: () async {
                                  if (controller.checkReviewValidation()) {
                                    controller.callAddReview(
                                        widget.productId, widget.orderId);
                                  }
                                  await analytics.logEvent(
                                    name: 'submit_productReviewClick',
                                    parameters: <String, Object>{
                                      'page_name': 'submit_productReviewClick',
                                    },
                                  );
                                },
                                borderColor: btnTextColor),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
