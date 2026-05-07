// ignore_for_file: avoid_print, deprecated_member_use

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';

import '../common/widget/appbar/home_appbar.dart';
import '../common/widget/other/common_widget.dart';
import '../controllers/product_controller.dart';
import '../controllers/search_controller.dart';
import '../core/constant/constants.dart';
import 'cartscreen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
  });

  @override
  State<CatalogScreen> createState() => CatalogScreenState();
}

class CatalogScreenState extends State<CatalogScreen> {
  final productController = Get.put(ProductController());
  final searchController = Get.put(SearchScreenController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    /*  WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant")); */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // ✅ FIXED: Always allow back navigation immediately
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          // Back was pressed and navigation succeeded
          // Navigation already handled by PopScope
        }
      },
      child: DefaultTabController(
        length: 3,
        initialIndex: productController.selectedTabCategory.value,
        child: Scaffold(
          backgroundColor: whiteColor,
          body: Column(
            children: [
              /*   CatalogAppbar(
                text: "Catalog",
                onPressedSearch: () async {
                  Get.to(const SearchScreen());
                  analytics
                      .logEvent(name: "search_page", parameters: <String, Object>{
                    "page_name": "search_page",
                  });
                },
                onPressedCart: () async {
                  Get.to(CartScreen());
                  analytics
                      .logEvent(name: "cart_page", parameters: <String, Object>{
                    "page_name": "cart_page",
                  });
                },
              ), */
              HomeAppbar(
                showSearch: true,
                title: "Categories",
                onPressedSearch: () async {
                  // searchController.searchController.clear();
                  Get.to(() => const SearchScreen(), preventDuplicates: true)?.then((_) {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                  await analytics.logEvent(
                    name: 'search_page',
                    parameters: <String, Object>{
                      'page_name': 'search_page',
                    },
                  );
                },
                onPressedHeart: () async {
                  Get.to(const WishlistScreen());
                  await analytics.logEvent(
                    name: 'wishlist_page',
                    parameters: <String, Object>{
                      'page_name': 'wishlist_page',
                    },
                  );
                },
                onPressedCart: () async {
                  Get.to(CartScreen());
                  await analytics.logEvent(
                    name: 'cart_page',
                    parameters: <String, Object>{
                      'page_name': 'cart_page',
                    },
                  );
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
                      dividerColor: Colors.transparent,
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
                          "Men".toUpperCase(),
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: "Clash Display",
                              fontWeight: FontWeight.w400),
                        )),
                        Tab(
                            child: Text(
                          "Women".toUpperCase(),
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: "Clash Display",
                              fontWeight: FontWeight.w400),
                        )),
                        Tab(
                            child: Text(
                          "Accessories".toUpperCase(),
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: "Clash Display",
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
                      CatalogScreen(
                          // categorytext: "Men",
                          //type: 2,
                          ),
                      CatalogScreen(
                          //   categorytext: "Women",
                          // type: 3,
                          ),
                      CatalogScreen(
                          //  categorytext: "Accessories",
                          //type: 1,
                          ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
