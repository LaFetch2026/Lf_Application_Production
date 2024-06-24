// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/catalog_product_appbar.dart';
import 'package:lafetch/screens/catalog/productlist/viewproduct.dart';
import 'package:lafetch/screens/searchscreen.dart';
import '../../controller/product_controller.dart';
import '../../utils/constants.dart';
import '../cartscreen.dart';

class ProductListScreen extends StatefulWidget {
  final int categoryId;
  const ProductListScreen({super.key, required this.categoryId});

  @override
  State<ProductListScreen> createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  final productController = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
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
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3,
                    tabs: [
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
                    ]),
              ),
            ),
            Container(
              width: double.infinity,
              color: whiteColor,
              height: 1,
            ),
            Expanded(
              child: TabBarView(children: [
                ViewProductScreen(
                  categoryId: widget.categoryId,
                ),
                ViewProductScreen(categoryId: widget.categoryId),
                ViewProductScreen(categoryId: widget.categoryId),
                ViewProductScreen(categoryId: widget.categoryId),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
