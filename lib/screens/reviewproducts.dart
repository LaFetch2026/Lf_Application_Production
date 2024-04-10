// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/controller/review_controller.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../utils/constants.dart';

class ReviewProductScreen extends StatefulWidget {
  final String productName;
  const ReviewProductScreen({super.key, required this.productName});

  @override
  State<ReviewProductScreen> createState() => ReviewProductScreenState();
}

class ReviewProductScreenState extends State<ReviewProductScreen> {
  final controller = Get.put(ReviewController());

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
                                      horizontal: 10,
                                    ),
                                    child: AppText(
                                      text:
                                          "Topman super skinny suit jacket and trousers in light blue",
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
                                onPressed: () {
                                  if (controller.checkReviewValidation()) {
                                    controller
                                        .callAddReview(18); //id will change
                                  }
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
