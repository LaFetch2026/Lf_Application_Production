// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/controller/review_controller.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../utils/constants.dart';

class ReviewProductScreen extends StatefulWidget {
  final String productName;
  final int productId;
  final String productimage;
  const ReviewProductScreen(
      {super.key,
      required this.productName,
      required this.productimage,
      required this.productId});

  @override
  State<ReviewProductScreen> createState() => ReviewProductScreenState();
}

class ReviewProductScreenState extends State<ReviewProductScreen> {
  final controller = Get.put(ReviewController());
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
                                  Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      child: GFRating(
                                        value: controller.rating.value,
                                        borderColor: const Color(0XFFA6A39F),
                                        color: Colors.amber,
                                        size: 24,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: AppText(
                          text: "Write a Review",
                          maxLines: 2,
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          color: loginText,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(
                            color: textColor,
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
                              borderRadius: BorderRadius.circular(1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1),
                              borderSide: const BorderSide(color: borderColor),
                            ),
                            counterText: "",
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            hintText:
                                "How is the product? What do you like? What do you hate?",
                            hintStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      Obx(() => Padding(
                            padding: const EdgeInsets.only(top: 30, bottom: 10),
                            child: getSingleButton(
                                label: "Submit",
                                textColor: btnTextColor,
                                controller: controller,
                                backgroundColor: whiteColor,
                                onPressed: () async {
                                  if (controller.checkReviewValidation()) {
                                    controller.callAddReview(
                                        widget.productId); //id will change
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
