// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/catalog_product_appbar.dart';
import 'package:lafetch/screens/catalog/productlist/viewproduct.dart';
import 'package:lafetch/screens/searchscreen.dart';
import '../../controller/product_controller.dart';
import '../../utils/constants.dart';
import '../cartscreen.dart';

class ProductListScreen extends StatefulWidget {
  final List<String> tabTextList;
  final List<int> idList;
  final int genderType;
  final int catalogId;
  const ProductListScreen(
      {super.key,
      required this.tabTextList,
      required this.idList,
      required this.catalogId,
      required this.genderType});

  @override
  State<ProductListScreen> createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  final productController = Get.put(ProductController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Tab> _tabs = [];
  int categoryId = 0;

  @override
  void initState() {
    if (widget.idList.isNotEmpty) {
      categoryId = widget.idList[0];
      productController.category_id.value = 0;
    }
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
      return const Tab(
        text: "View All",
      );
    } else {
      return Tab(
        text: widget.tabTextList[widgetNumber - 1],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tabTextList.length + 1,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CatalogProductAppbar(
              onPressedSearch: () {
                Get.to(const SearchScreen());
              },
              onPressedCart: () {
                Get.to(const CartScreen());
              },
            ),
            PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Align(
                alignment: Alignment.topCenter,
                child: TabBar(
                    isScrollable: true,
                    indicatorColor: btnTextColor,
                    unselectedLabelColor: textHintColor,
                    labelColor: btnTextColor,
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
              height: 1,
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
