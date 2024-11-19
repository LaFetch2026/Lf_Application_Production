// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/catalog_appbar.dart';
import 'package:lafetch/screens/catalog/women_catalog.dart';
import 'package:lafetch/screens/searchscreen.dart';
import '../controller/product_controller.dart';
import '../utils/constants.dart';
import 'cartscreen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => CatalogScreenState();
}

class CatalogScreenState extends State<CatalogScreen> {
  final productController = Get.put(ProductController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  @override
  void initState() {
    /*  WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant")); */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            CatalogAppbar(
              text: "Catalog",
              onPressedSearch: () async {
                Get.to(const SearchScreen());
                analytics
                    .logEvent(name: "search_page", parameters: <String, Object>{
                  "page_name": "search_page",
                });
              },
              onPressedCart: () async {
                Get.to(const CartScreen());
                analytics
                    .logEvent(name: "cart_page", parameters: <String, Object>{
                  "page_name": "cart_page",
                });
              },
            ),
            PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Align(
                alignment: Alignment.topCenter,
                child: TabBar(
                    isScrollable: false,
                    physics: const NeverScrollableScrollPhysics(),
                    indicatorColor: btnTextColor,
                    unselectedLabelColor: textHintColor,
                    labelColor: btnTextColor,
                    onTap: (value) async {
                      String type;
                      if (value == 0) {
                        type = "Women_catalog_page";
                      } else if (value == 1) {
                        type = "Men_catalog_page";
                      } else {
                        type = "Kids_catalog_page";
                      }
                      await analytics.logEvent(
                        name: type,
                        parameters: <String, Object>{
                          'page_name': type,
                        },
                      );
                    },
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                          child: Text(
                        "Women",
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w400),
                      )),
                      Tab(
                          child: Text(
                        "Men",
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w400),
                      )),
                      Tab(
                          child: Text(
                        "Accessories",
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w400),
                      ))
                    ]),
              ),
            ),
            Container(
              width: double.infinity,
              color: whiteColor,
              height: 1.sp,
            ),
            const Expanded(
              child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    WomenCatalogScreen(
                      categorytext: "women",
                      type: 3,
                    ),
                    WomenCatalogScreen(
                      categorytext: "men",
                      type: 2,
                    ),
                    WomenCatalogScreen(
                      categorytext: "accessories",
                      type: 1,
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
