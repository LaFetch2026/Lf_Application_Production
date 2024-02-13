// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/allbrand_appbar.dart';
import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';
import '../cartscreen.dart';
import '../searchscreen.dart';

class AllBrandScreen extends StatefulWidget {
  final String title;
  const AllBrandScreen({required this.title, super.key});

  @override
  State<AllBrandScreen> createState() => AllBrandScreenState();
}

class AllBrandScreenState extends State<AllBrandScreen> {
  List<String> gridList = [
    "New In",
    "Clothing",
    "Accessories",
    "Footwear",
    "Sales Discount",
  ];
  List<String> items = [
    "100",
    "200",
    "300",
    "400",
    "500",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Column(
        children: [
          AllBrandAppbar(
            text: widget.title,
            onPressedSearch: () {
              Get.to(const SearchScreen());
            },
            onPressedCart: () {
              Get.to(const CartScreen());
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.asset(brandback,
                          height: 112,
                          width: double.infinity,
                          fit: BoxFit.cover),
                      Container(
                        alignment: Alignment.bottomCenter,
                        margin: const EdgeInsets.only(top: 70),
                        child: Image.asset(otpImage,
                            height: 80, width: 80, fit: BoxFit.cover),
                      ),
                    ],
                  ),
                  /*     Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: SizedBox(
                      height: 500,
                      child: ListView.builder(
                          physics: const ScrollPhysics(),
                          itemCount: items.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (ctx, index) {
                            return Column(
                              children: [
                                GestureDetector(
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Container(
                                        width: double.infinity,
                                        height: 100,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(backImage),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              AppText(
                                                text: items[index],
                                                color: whiteBorderColor,
                                                fontSize: 16.sp,
                                                fontFamily: "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                              const Expanded(
                                                child: SizedBox(
                                                  width: 0,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Get.to(const CatalogDetailsScreen(
                                                    title: "Clothing",
                                                  ));
                                                },
                                                child: Image.asset(rightArrowImage,
                                                    height: 20,
                                                    width: 20,
                                                    fit: BoxFit.cover),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )),
                              ],
                            );
                          }),
                    ),
                  ),
               */
                  /* MasonryGridView.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    itemBuilder: (context, index) {
                      return Tile(
                        index: index,
                        extent: (index % 5 + 1) * 100,
                      );
                    },
                  ) */
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 16),
                    child: AppText(
                      text: "New Arrivals",
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w500,
                      color: whiteBorderColor,
                      fontSize: 16.sp,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
                                    height: 250,
                                    child: Container(
                                      color: whiteBorderColor,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              Image.asset(backImage,
                                                  height: 150,
                                                  width: 122,
                                                  fit: BoxFit.cover),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 10),
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: InkWell(
                                                    child: SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            whiteColor,
                                                        child: Image.asset(
                                                          heartImage,
                                                          height: 16,
                                                          color: bottomnavBack,
                                                          width: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: AppText(
                                              text:
                                                  "Topman super skinny suit jacket and trousers in light blue",
                                              color: nameText,
                                              maxLines: 2,
                                              fontSize: 11.sp,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, left: 10, right: 10),
                                            child: Row(
                                              children: [
                                                AppText(
                                                  text:
                                                      "\u{20B9} ${items[index]}",
                                                  color: deepGreytextColor,
                                                  maxLines: 2,
                                                  fontSize: 11.sp,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: AppText(
                                                    text:
                                                        "\u{20B9} ${items[index]}",
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
                                                top: 10,
                                                left: 10,
                                                right: 10,
                                                bottom: 5),
                                            child: Row(
                                              children: [
                                                const ImageIcon(
                                                  AssetImage(truckImage),
                                                  color: expressText,
                                                  size: 14,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
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
                                ),
                              ],
                            );
                          }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 16),
                    child: AppText(
                      text: "Bestsellers",
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w500,
                      color: whiteBorderColor,
                      fontSize: 16.sp,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
                                    height: 250,
                                    child: Container(
                                      color: whiteBorderColor,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              Image.asset(backImage,
                                                  height: 150,
                                                  width: 122,
                                                  fit: BoxFit.cover),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 10),
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: InkWell(
                                                    child: SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            whiteColor,
                                                        child: Image.asset(
                                                          heartImage,
                                                          height: 16,
                                                          color: bottomnavBack,
                                                          width: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: AppText(
                                              text:
                                                  "Topman super skinny suit jacket and trousers in light blue",
                                              color: nameText,
                                              maxLines: 2,
                                              fontSize: 11.sp,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, left: 10, right: 10),
                                            child: Row(
                                              children: [
                                                AppText(
                                                  text:
                                                      "\u{20B9} ${items[index]}",
                                                  color: deepGreytextColor,
                                                  maxLines: 2,
                                                  fontSize: 11.sp,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: AppText(
                                                    text:
                                                        "\u{20B9} ${items[index]}",
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
                                                top: 10,
                                                left: 10,
                                                right: 10,
                                                bottom: 5),
                                            child: Row(
                                              children: [
                                                const ImageIcon(
                                                  AssetImage(truckImage),
                                                  color: expressText,
                                                  size: 14,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
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
                                ),
                              ],
                            );
                          }),
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
