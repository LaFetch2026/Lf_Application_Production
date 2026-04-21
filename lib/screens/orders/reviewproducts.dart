// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../../common/widget/appbar/backbutton_appbar.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/order_controller.dart';
import '../../core/constant/constants.dart';

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
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
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
                            SizedBox(
                              height: 85.sp,
                              width: 70.sp,
                              child: CachedNetworkImage(
                                cacheManager: CacheManager(Config(
                                    "customCacheKey",
                                    stalePeriod: const Duration(days: 15),
                                    maxNrOfCacheObjects: 100)),
                                fit: BoxFit.fill,
                                imageUrl: widget.productimage,
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  downloadImage,
                                  fit: BoxFit.fill,
                                  height: 85.sp,
                                  width: 70.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.sp),
                            Expanded(
                              child: AppText(
                                text: widget.productName,
                                maxLines: 2,
                                fontFamily: "Clash Display Regular",
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: nameText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.sp,
                        ),
                        child: const AppText(
                          text: "Write a Review",
                          maxLines: 2,
                          fontFamily: "Clash Display",
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
                            fontFamily: "Clash Display Regular",
                          ),
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
