// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/home_appbar.dart';
import 'package:lafetch/screens/expressshopping/viewall.dart';
import 'package:lafetch/screens/searchscreen.dart';
import '../commonwidget/app_text.dart';
import '../controller/brand_controller.dart';
import '../utils/constants.dart';
import 'cartscreen.dart';
import 'catalogscreen.dart';

class ExpressShoppingScreen extends StatefulWidget {
  const ExpressShoppingScreen({super.key});

  @override
  State<ExpressShoppingScreen> createState() => ExpressShoppingScreenState();
}

class ExpressShoppingScreenState extends State<ExpressShoppingScreen> {
  final brandController = Get.put(BrandController());
  final screen = [
    const ViewAllScreen(),
    const ViewAllScreen(),
    const ViewAllScreen(),
    const ViewAllScreen(),
  ];
  int current = 0;
  PageController pageController = PageController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      brandController.listController.addListener(() {
        brandController.fetchMoreData();
        brandController.update();
      });
    });
    brandController.hasnextpage.value = true;
    brandController.loadMore.value = false;
    brandController.isBrand.value = false;
    brandController.page.value = 1;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => brandController.getBrandData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
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
            padding:
                const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 5),
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
          Obx(
            () => brandController.isBrand.value
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: brandController.brandList.length,
                          scrollDirection: Axis.horizontal,
                          controller: brandController.listController,
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
                                      duration:
                                          const Duration(milliseconds: 200),
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
                                          ? Border.all(
                                              color: btnTextColor, width: 1)
                                          : Border.all(
                                              color: textHintColor, width: 1),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Center(
                                        child: AppText(
                                          text: brandController.brandList[index]
                                              ["name"],
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
                                ),
                              ],
                            );
                          }),
                    ),
                  ),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: screen.length,
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return screen[current];
              },
            ),
          ),
        ],
      ),
    );
  }
}
