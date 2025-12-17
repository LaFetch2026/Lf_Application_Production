// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalog/productlist/viewproduct.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';

import '../../common/widget/appbar/productlist_appbar.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../core/constant/constants.dart';
import '../cartscreen.dart';

class ProductListScreen extends StatefulWidget {
  final List<String> tabTextList;
  final List<int> idList;
  final int genderType;
  final int catalogId;
  final int initailIndex;

  const ProductListScreen(
      {super.key,
      required this.tabTextList,
      required this.idList,
      required this.catalogId,
      required this.initailIndex,
      required this.genderType});

  @override
  State<ProductListScreen> createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  final productController = Get.put(ProductController());
  final cartController = Get.put(CartController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Tab> _tabs = [];
  int categoryId = 0;

  @override
  void initState() {
    if (widget.idList.isNotEmpty) {
      categoryId = widget.idList[0];
      productController.category_id.value = 0;
    }
    productController.filterEnable.value = false;
    super.initState();
  }

  List<Tab> getTabs() {
    _tabs.clear();
    for (int i = 0; i < widget.tabTextList.length + 1; i++) {
      _tabs.add(getTab(i));
    }
    return _tabs;
  }

  Tab getTab(int widgetNumber) {
    if (widgetNumber == 0) {
      return Tab(
          child: Text(
        "View All",
        style: TextStyle(
            fontSize: 14.sp,
            fontFamily: "Clash Display",
            fontWeight: FontWeight.w400),
      ));
    } else {
      return Tab(
          child: Text(
        widget.tabTextList[widgetNumber - 1],
        style: TextStyle(
            fontSize: 14.sp,
            fontFamily: "Clash Display",
            fontWeight: FontWeight.w400),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tabTextList.length + 1,
      initialIndex: widget.initailIndex,
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*  CatalogProductAppbar(
              onPressedSearch: () {
                Get.to(const SearchScreen());
              },
              onPressedCart: () {
                Get.to(const CartScreen());
              },
            ), */
            ProductAppbar(onPressedSearch: () async {
              Get.to(SearchScreen());
              analytics
                  .logEvent(name: "search_page", parameters: <String, Object>{
                "page_name": "search_page",
              });
            }, onPressedHeart: () async {
              Get.to(WishlistScreen())?.then((value) => setState(
                    () {
                      cartController.getCartData();
                    },
                  ));
              analytics
                  .logEvent(name: "wishlist_page", parameters: <String, Object>{
                "page_name": "wishlist_page",
              });
            }, onPressedCart: () async {
              Get.to(const CartScreen())?.then((value) => setState(
                    () {
                      cartController.getCartData();
                    },
                  ));
              analytics
                  .logEvent(name: "cart_page", parameters: <String, Object>{
                "page_name": "cart_page",
              });
            }),
            PreferredSize(
              preferredSize: Size.fromHeight(40.sp),
              child: Align(
                alignment: Alignment.topCenter,
                child: TabBar(
                    isScrollable: true,
                    indicatorColor: btnTextColor,
                    tabAlignment: TabAlignment.start,
                    unselectedLabelColor: textHintColor,
                    labelColor: btnTextColor,
                    dividerColor: Colors.transparent,
                    onTap: (index) async {
                      categoryId = widget.idList[index];
                      if (index == 0) {
                        productController.category_id.value = 0;
                      } else {
                        productController.category_id.value =
                            widget.idList[index - 1];
                      }
                      setState(() {});
                      await analytics.logEvent(
                        name: "catalog_category_tabclick}",
                        parameters: <String, Object>{
                          'page_name': "catalog_category_tabclick",
                        },
                      );
                    },
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3,
                    tabs: getTabs()),
              ),
            ),
            Container(
              width: double.infinity,
              color: whiteColor,
              height: 1.sp,
            ),
            Expanded(
              child: TabBarView(
                children: List.generate(
                  widget.tabTextList.length + 1,
                  (index) => ViewProductScreen(
                      categoryId: index == 0 ? 0 : widget.idList[index - 1],
                      genderType: widget.genderType,
                      catalogId: widget.catalogId,
                      categoryName:
                          index == 0 ? "" : widget.tabTextList[index - 1]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
