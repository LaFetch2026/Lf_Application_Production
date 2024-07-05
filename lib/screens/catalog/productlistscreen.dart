// ignore_for_file: avoid_print

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
  const ProductListScreen(
      {super.key, required this.tabTextList, required this.idList});

  @override
  State<ProductListScreen> createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  final productController = Get.put(ProductController());
  final List<Tab> _tabs = [];
  int categoryId = 0;

  @override
  void initState() {
    if (widget.idList.isNotEmpty) {
      categoryId = widget.idList[0];
    }
    super.initState();
  }

  List<Tab> getTabs() {
    _tabs.clear();
    for (int i = 0; i < widget.tabTextList.length; i++) {
      _tabs.add(getTab(i));
    }
    return _tabs;
  }

  Tab getTab(int widgetNumber) {
    return Tab(
      text: widget.tabTextList[widgetNumber],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tabTextList.length,
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
                    onTap: (index) {
                      categoryId = widget.idList[index];
                      setState(() {});
                    },
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3,
                    tabs: getTabs()
                    /* [
                      Tab(
                          child: Text(
                        "View All",
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w400),
                      )),
                      Tab(
                          child: Text(
                        "T-shirts",
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w400),
                      )),
                      Tab(
                          child: Text(
                        "Shirts",
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w400),
                      )),
                      Tab(
                          child: Text(
                        "Over-sized Shirts",
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w400),
                      ))
                    ] */
                    ),
              ),
            ),
            Container(
              width: double.infinity,
              color: whiteColor,
              height: 1,
            ),
            Expanded(
              child: /* TabBarView(children: [
                ViewProductScreen(
                  categoryId: widget.categoryId,
                ),
                 ViewProductScreen(categoryId: widget.categoryId),
                ViewProductScreen(categoryId: widget.categoryId),
                ViewProductScreen(categoryId: widget.categoryId),
              ]), */
                  TabBarView(
                children: List.generate(
                  widget.tabTextList.length,
                  (index) => ViewProductScreen(
                      categoryId: widget.idList[index],
                      categoryName: widget.tabTextList[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
