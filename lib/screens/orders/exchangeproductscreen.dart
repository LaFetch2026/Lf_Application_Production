// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/backbutton_appbar.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/controller/review_controller.dart';
import 'package:lafetch/utils/constants.dart';
import '../../commonwidget/app_text.dart';

class ExchangeProductScreen extends StatefulWidget {
  final String productName;
  final String productDescription;
  final String productimage;
  const ExchangeProductScreen(
      {super.key,
      required this.productName,
      required this.productimage,
      required this.productDescription});

  @override
  State<ExchangeProductScreen> createState() => ExchangeProductScreenState();
}

class ExchangeProductScreenState extends State<ExchangeProductScreen> {
  final controller = Get.put(ReviewController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  String? text1;

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
                                        text: widget.productDescription,
                                        maxLines: 1,
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
                            horizontal: 16,
                          ),
                          child: AppText(
                            text: "Choose why you exchanging this?",
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Radio(
                                      value: "Product Damage",
                                      activeColor: colorPrimary,
                                      groupValue: text1,
                                      onChanged: (value) {
                                        text1 = value.toString();
                                        setState(() {});
                                      }),
                                  GestureDetector(
                                    onTap: () {
                                      text1 = "Product Damage";
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Product Damage",
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 14.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio(
                                      value: "Wrong item was sent",
                                      activeColor: colorPrimary,
                                      groupValue: text1,
                                      onChanged: (value) {
                                        text1 = value.toString();
                                        setState(() {});
                                      }),
                                  GestureDetector(
                                    onTap: () {
                                      text1 = "Wrong item was sent";
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Wrong item was sent",
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 14.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio(
                                      value: "Received extra item",
                                      activeColor: colorPrimary,
                                      groupValue: text1,
                                      onChanged: (value) {
                                        text1 = value.toString();
                                        setState(() {});
                                      }),
                                  GestureDetector(
                                    onTap: () {
                                      text1 = "Received extra item";
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Received extra item",
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 14.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio(
                                      value: "Changed Size",
                                      activeColor: colorPrimary,
                                      groupValue: text1,
                                      onChanged: (value) {
                                        text1 = value.toString();
                                        setState(() {});
                                      }),
                                  GestureDetector(
                                    onTap: () {
                                      text1 = "Changed Size";
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Changed Size",
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 14.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio(
                                      value: "Changed Color",
                                      activeColor: colorPrimary,
                                      groupValue: text1,
                                      onChanged: (value) {
                                        text1 = value.toString();
                                        setState(() {});
                                      }),
                                  GestureDetector(
                                    onTap: () {
                                      text1 = "Changed Color";
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Changed Color",
                                      style: TextStyle(
                                        color: colorPrimary,
                                        fontSize: 14.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: AppText(
                            text: "Write a Comments",
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
                            textCapitalization: TextCapitalization.words,
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
                                borderSide:
                                    const BorderSide(color: borderColor),
                              ),
                              counterText: "",
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              hintText: "How is the product? What do you hate?",
                              hintStyle: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        Obx(() => Padding(
                              padding:
                                  const EdgeInsets.only(top: 30, bottom: 10),
                              child: getSingleButton(
                                  label: "Submit",
                                  textColor: btnTextColor,
                                  controller: controller,
                                  backgroundColor: whiteColor,
                                  onPressed: () async {
                                    await analytics.logEvent(
                                      name: 'submit_productExchangeClick',
                                      parameters: <String, Object>{
                                        'page_name':
                                            'submit_productExchangeClick',
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
          ),
        ],
      ),
    );
  }
}
