// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/home_appbar.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_grid_list.dart';
import 'package:lafetch/screens/expressshopping/viewall.dart';
import 'package:lafetch/screens/searchscreen.dart';
import '../commonwidget/app_text.dart';
import '../controller/brand_controller.dart';
import '../controller/product_controller.dart';
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
  final productController = Get.put(ProductController());
  int current = 0;
  PageController pageController = PageController();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      brandController.brandListController.addListener(() {
        brandController.fetchMoreData();
        brandController.update();
      });
    });
    brandController.hasnextpage.value = true;
    brandController.loadMore.value = false;
    brandController.isBrand.value = false;
    brandController.page.value = 1;
    productController.brand_id.value = 0;
    productController.brandExpressHasnextpage.value = true;
    productController.brandExpressLoadMore.value = false;
    productController.isBrandExpressProduct.value = false;
    productController.brandExpressPage.value = 1;
    productController.filterExpressEnable.value = false;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => brandController.getBrandData());
    super.initState();
  }

  callOnchanged(int index) {
    setState(() {
      current = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeAppbar(
            onPressedSearch: () async {
              Get.to(const SearchScreen());
              await analytics.logEvent(
                name: 'search_page',
                parameters: <String, Object>{
                  'page_name': 'search_page',
                },
              );
            },
            onPressedCatalog: () async {
              Get.to(const CatalogScreen());
              await analytics.logEvent(
                name: 'catalog_page',
                parameters: <String, Object>{
                  'page_name': 'catalog_page',
                },
              );
            },
            onPressedCart: () async {
              Get.to(const CartScreen());
              await analytics.logEvent(
                name: 'cart_page',
                parameters: <String, Object>{
                  'page_name': 'cart_page',
                },
              );
            },
          ),
          /*  Container(
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
          ), */
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
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 16, bottom: 10, right: 16),
                    child: SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: 5,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 100,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }),
                    ))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: GetBuilder<BrandController>(
                              builder: (value) => ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: value.brandList.length + 1,
                                  scrollDirection: Axis.horizontal,
                                  controller: value.brandListController,
                                  itemBuilder: (ctx, index) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            current = index;
                                            if (index == 0) {
                                              productController.brand_id.value =
                                                  0;
                                            } else {
                                              productController.brand_id.value =
                                                  value.brandList[index - 1]
                                                      ["id"];
                                            }
                                            productController
                                                .brandExpressHasnextpage
                                                .value = true;
                                            productController
                                                .brandExpressLoadMore
                                                .value = false;
                                            productController
                                                .isBrandExpressProduct
                                                .value = false;
                                            productController
                                                .brandExpressPage.value = 1;
                                            productController.update();
                                            setState(() {});
                                            pageController.animateToPage(
                                              current,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.ease,
                                            );
                                            await analytics.logEvent(
                                              name:
                                                  'express_page_brandtabclick',
                                              parameters: <String, Object>{
                                                'page_name':
                                                    'express_page_brandtabclick',
                                              },
                                            );
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            margin:
                                                const EdgeInsets.only(right: 5),
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
                                                      color: btnTextColor,
                                                      width: 1)
                                                  : Border.all(
                                                      color: textHintColor,
                                                      width: 1),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: Center(
                                                child: AppText(
                                                  text: index == 0
                                                      ? "View All"
                                                      : value.brandList[
                                                          index - 1]["name"],
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
                            )),
                      ),
                    ],
                  ),
          ),
          Obx(
            () => brandController.isBrand.value
                ? const Expanded(child: DummyGridList())
                : Expanded(
                    child: PageView.builder(
                      //  itemCount: brandController.brandList.length + 1,
                      controller: pageController,
                      onPageChanged: callOnchanged,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ViewAllScreen(
                          brandId: productController.brand_id.value,
                        );
                      },
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
