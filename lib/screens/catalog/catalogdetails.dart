// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalog/productlistscreen.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/catalog_appbar.dart';
import '../../utils/constants.dart';
import '../cartscreen.dart';
import '../searchscreen.dart';

class CatalogDetailsScreen extends StatefulWidget {
  final String title;

  const CatalogDetailsScreen({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<CatalogDetailsScreen> createState() => CatalogDetailsScreenState();
}

class CatalogDetailsScreenState extends State<CatalogDetailsScreen> {
  List<String> items = [
    "Suits",
    "Skirt",
    "Top",
    "Dresses",
    "jacket",
    "Footwear",
    "Jeans",
    "Sales Discount",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          CatalogAppbar(
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
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(backImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    height: 65,
                    color: whiteBorderColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppText(
                            text: widget.title,
                            color: appbarText,
                            fontSize: 22.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                          const Expanded(
                            child: SizedBox(
                              width: 0,
                            ),
                          ),
                          AppText(
                            text: "For Women",
                            color: textHintColor,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
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
                                    onTap: () {
                                      Get.to(const ProductListScreen());
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            AppText(
                                              text: items[index],
                                              color: greyTextColor,
                                              fontSize: 14.sp,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
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
