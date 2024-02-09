// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/home_appbar.dart';
import 'package:lafetch/screens/expressshopping/viewall.dart';
import '../commonwidget/app_text.dart';
import '../utils/constants.dart';
import 'catalogscreen.dart';

class ExpressShoppingScreen extends StatefulWidget {
  const ExpressShoppingScreen({super.key});

  @override
  State<ExpressShoppingScreen> createState() => ExpressShoppingScreenState();
}

class ExpressShoppingScreenState extends State<ExpressShoppingScreen> {
  List<String> items = [
    "View All",
    "Balenciaga",
    "Chanel",
    "Hermes",
  ];
  final screen = [
    const ViewAllScreen(),
    const ViewAllScreen(),
    const ViewAllScreen(),
    const ViewAllScreen(),
  ];
  int current = 0;
  PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAppbar(
              onPressedCatalog: () {
                Get.to(const CatalogScreen());
              },
            ),
            Container(
              height: 40,
              color: greyBack,
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 5),
                    child: ImageIcon(
                      AssetImage(shopImage),
                      color: expressText,
                      size: 20,
                    ),
                  ),
                  AppText(
                    text: "Delivered at your doorstep in the next 4 hours",
                    color: expressText,
                    maxLines: 2,
                    fontSize: 12.sp,
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
              child: AppText(
                text: "Express Shop",
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: blackColor,
                fontSize: 25.sp,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                current = index;
                              });
                              pageController.animateToPage(
                                current,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.ease,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 5),
                              width: 100,
                              height: 30,
                              decoration: BoxDecoration(
                                color: current == index
                                    ? btnTextColor
                                    : whiteBorderColor,
                                borderRadius: current == index
                                    ? BorderRadius.circular(20)
                                    : BorderRadius.circular(20),
                                border: current == index
                                    ? Border.all(color: btnTextColor, width: 1)
                                    : Border.all(
                                        color: textHintColor, width: 1),
                              ),
                              child: Center(
                                child: AppText(
                                  text: items[index],
                                  color: current == index
                                      ? whiteBorderColor
                                      : textHintColor,
                                  fontSize: 12.sp,
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 500,
              child: PageView.builder(
                itemCount: screen.length,
                controller: pageController,
                physics: const ScrollPhysics(),
                itemBuilder: (context, index) {
                  return screen[current];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
