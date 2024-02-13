// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/allbrand_appbar.dart';
import 'package:lafetch/screens/catalog/catalogdetails.dart';
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
  List<String> items = [
    "New In",
    "Clothing",
    "Accessories",
    "Footwear",
    "Sales Discount",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
          ],
        ),
      ),
    );
  }
}
