// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/home_appbar.dart';
import '../utils/constants.dart';
import 'cartscreen.dart';
import 'catalogscreen.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => BrandsScreenState();
}

class BrandsScreenState extends State<BrandsScreen> {
  bool showlist = false;
  String text = "Expand All";
  List<String> items = [
    "Salwar Suits",
    "Printed",
    "Clothing",
    "Duffle bags",
    "Tuxedos",
    "Salwar Suits",
    "Printed",
    "Clothing",
    "Duffle bags",
    "Tuxedos"
  ];
  List<String> childItem = [
    "Salwar Suits",
    "Printed",
    "Clothing Clothing Clothing",
    "Duffle bags",
    "Tuxedos Tuxedos Tuxedos",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorSecondary,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAppbar(
              onPressedSearch: () {
                Get.to(const SearchScreen());
              },
              onPressedCatalog: () {
                Get.to(const CatalogScreen());
              },
              onPressedCart: () {
                Get.to(const CartScreen());
              },
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              color: colorPrimary,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: colorPrimary,
                      borderRadius: BorderRadius.circular(1),
                      border: Border.all(color: colorSecondary, width: 1)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        const ImageIcon(
                          AssetImage(searchImage),
                          color: colorSecondary,
                          size: 14,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: AppText(
                            text: "Search for brands & products",
                            color: colorSecondary,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 20, right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AppText(
                    text: "Brand Style Catalog",
                    color: colorPrimary,
                    fontSize: 22.sp,
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
                      if (showlist) {
                        setState(() {
                          showlist = false;
                          text = "Expand All";
                        });
                      } else {
                        setState(() {
                          showlist = true;
                          text = "Collapse All";
                        });
                      }
                    },
                    child: AppText(
                      text: text,
                      color: blackColor,
                      fontSize: 12.sp,
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 10, top: 10),
              child: ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: items.length,
                  padding: EdgeInsets.zero,
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
                                decoration: const BoxDecoration(
                                    color: whiteBorderColor),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(AllBrandScreen(
                                          title: items[index],
                                        ));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(chanelLogoImage,
                                                height: 32,
                                                width: 32,
                                                fit: BoxFit.cover),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: AppText(
                                                text: items[index],
                                                color: colorPrimary,
                                                fontSize: 14.sp,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const Expanded(
                                              child: SizedBox(
                                                width: 0,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (showlist) {
                                                  setState(() {
                                                    showlist = false;
                                                    text = "Expand All";
                                                  });
                                                } else {
                                                  setState(() {
                                                    showlist = true;
                                                    text = "Collapse All";
                                                  });
                                                }
                                              },
                                              child: Image.asset(upArrowIcon,
                                                  height: 20,
                                                  width: 20,
                                                  fit: BoxFit.cover),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    showlist
                                        ? Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16, right: 16),
                                                child: GridView.count(
                                                  shrinkWrap: true,
                                                  crossAxisCount: 3,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  padding: EdgeInsets.zero,
                                                  childAspectRatio: 0.8,
                                                  physics:
                                                      const ScrollPhysics(),
                                                  crossAxisSpacing: 1,
                                                  mainAxisSpacing: 0,
                                                  children: List.generate(
                                                    childItem.length,
                                                    (i) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          // Get.to(const BoardScreen());
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Image.asset(
                                                                backImage,
                                                                height: 70,
                                                                width: 90,
                                                                fit: BoxFit
                                                                    .cover),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                              child: AppText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                text: childItem[
                                                                    i],
                                                                color:
                                                                    greyTextColor,
                                                                fontSize: 10.sp,
                                                                maxLines: 2,
                                                                fontFamily:
                                                                    "Franklin Gothic Regular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(
                                            height: 0,
                                          )
                                  ],
                                ),
                              ),
                            )),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
