// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/womenwidget/question_card.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import '../../../commonwidget/app_text.dart';
import '../../../commonwidget/womenwidget/lafetch_card.dart';
import '../../../commonwidget/womenwidget/sale_card.dart';
import '../../../utils/constants.dart';

class DiscountScreen extends StatefulWidget {
  const DiscountScreen({super.key});

  @override
  State<DiscountScreen> createState() => DiscountScreenState();
}

class DiscountScreenState extends State<DiscountScreen> {
  List<String> items = [
    "100",
    "200",
    "300",
    "400",
    "500",
  ];
  List<String> images = [
    image,
    backImage,
    otpImage,
  ];

  int _currentPage = 0;

  Timer? timer;
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 2000),
        curve: Curves.easeIn,
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SaleCardWidget(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: double.infinity,
                color: colorSecondary,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16),
              child: AppText(
                text: "6 hour Express Delivery",
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w500,
                color: blackColor,
                fontSize: 16.sp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 250,
                child: ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const ProductDetailsScreen());
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 5),
                              width: 122,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(backImage,
                                      height: 150,
                                      width: 122,
                                      fit: BoxFit.cover),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: AppText(
                                      text:
                                          "Topman super skinny suit jacket and trousers in light blue",
                                      color: nameText,
                                      maxLines: 2,
                                      fontSize: 11.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 10, right: 10),
                                    child: Row(
                                      children: [
                                        AppText(
                                          text: "\u{20B9} ${items[index]}",
                                          color: deepGreytextColor,
                                          maxLines: 2,
                                          fontSize: 11.sp,
                                          fontFamily: "Franklin Gothic",
                                          fontWeight: FontWeight.w500,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: AppText(
                                            text: "\u{20B9} ${items[index]}",
                                            color: textHintColor,
                                            maxLines: 2,
                                            fontSize: 11.sp,
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 10, right: 10),
                                    child: Row(
                                      children: [
                                        const ImageIcon(
                                          AssetImage(truckImage),
                                          color: expressText,
                                          size: 14,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: AppText(
                                            text: "Express",
                                            color: expressText,
                                            maxLines: 2,
                                            fontSize: 11.sp,
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16),
              child: AppText(
                text: "We think you might also like",
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w500,
                color: blackColor,
                fontSize: 16.sp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 250,
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 5),
                              width: 122,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(backImage,
                                      height: 150,
                                      width: 122,
                                      fit: BoxFit.cover),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: AppText(
                                      text:
                                          "Topman super skinny suit jacket and trousers in light blue",
                                      color: nameText,
                                      maxLines: 2,
                                      fontSize: 11.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 10, right: 10),
                                    child: Row(
                                      children: [
                                        AppText(
                                          text: "\u{20B9} ${items[index]}",
                                          color: deepGreytextColor,
                                          maxLines: 2,
                                          fontSize: 11.sp,
                                          fontFamily: "Franklin Gothic",
                                          fontWeight: FontWeight.w500,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            "\u{20B9} ${items[index]}",
                                            style: TextStyle(
                                              color: textHintColor,
                                              fontSize: 11.sp,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16),
              child: AppText(
                text: "Popular Categories",
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: blackColor,
                fontSize: 16.sp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 180,
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 10),
                              width: 150,
                              height: 180,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(backImage,
                                      height: 144,
                                      width: 150,
                                      fit: BoxFit.cover),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: AppText(
                                      text: "Denim Jeans",
                                      color: greyTextColor,
                                      fontSize: 10.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.zero,
                  childAspectRatio: 0.7,
                  physics: const ScrollPhysics(),
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 1,
                  children: List.generate(
                    items.length,
                    (index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: SizedBox(
                              height: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Image.asset(backImage,
                                        width: 80,
                                        height: 72,
                                        fit: BoxFit.cover),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: AppText(
                                      text: "Sneakers${index + 1}",
                                      color: greyTextColor,
                                      fontSize: 10.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 210,
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  // onPageChanged: callOnchanged,
                  controller: _pageController,
                  itemCount: images.length,
                  itemBuilder: (context, int index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    child: Image.asset(chanelLogoImage,
                                        height: 32,
                                        width: 32,
                                        fit: BoxFit.cover),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      height: 0,
                                    ),
                                  ),
                                  AppText(
                                    text: "Flat ₹500 OFF*",
                                    color: whiteBorderColor,
                                    fontSize: 25.sp,
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w400,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: AppText(
                                      text: "on Chanel Handbags",
                                      color: whiteBorderColor,
                                      fontSize: 14.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              child: Image.asset(tcLogoImage,
                                  color: borderColor,
                                  height: 10,
                                  fit: BoxFit.cover),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: /* SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: */
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List<Widget>.generate(images.length, (int index) {
                          return AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              height: 6,
                              width: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                  color: (index == _currentPage)
                                      ? colorPrimary
                                      : colorSecondary));
                        })),
                //  ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const LafetchCardWidget(),
            QuestionCardWidget(
                text1: "FAQs",
                text2: "Your questions answered",
                onPressed: () {},
                icon: question2Image),
            QuestionCardWidget(
                text1: "Need Help?",
                text2: "Contact customer service",
                onPressed: () {},
                icon: question1Image),
            const SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
