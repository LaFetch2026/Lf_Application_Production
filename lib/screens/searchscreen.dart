// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  List<String> products = [
    "Salwar Suits",
    "Printed loose t-shirts",
    "Clothing",
    "Duffle bags",
    "Tuxedos"
  ];
  List<String> items = [
    "100",
    "200",
    "300",
    "400",
    "400",
  ];

  List<String> images = [
    image,
    backImage,
    otpImage,
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*   Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: ScrollController(),
                child: Wrap(
                  direction: Axis.horizontal,
                  spacing: 5.0,
                  runSpacing: 5.0,
                  runAlignment: WrapAlignment.spaceEvenly,
                  children: [
                    for (var product in products)
                      Container(
                        height: 20,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                            color: whiteBorderColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: btnTextColor, width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: Text(
                            product,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: btnTextColor,
                              fontSize: 12.sp,
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16),
              child: AppText(
                text: "Express Delivery",
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
                              margin: const EdgeInsets.only(right: 5),
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
                                      fontSize: 14.sp,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 100,
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
                              width: 80,
                              height: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(backImage,
                                      width: 80, height: 72, fit: BoxFit.cover),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: AppText(
                                      text: "Sneakers",
                                      color: greyTextColor,
                                      fontSize: 14.sp,
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
         */
          ],
        ),
      ),
    );
  }
}
