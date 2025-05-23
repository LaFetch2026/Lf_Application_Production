// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalog/productlist/producthorizontal.dart';
import 'package:lafetch/screens/catalog/productlist/productvertical.dart';
import '../../../commonwidget/app_text.dart';
import '../../../controller/product_controller.dart';
import '../../../utils/constants.dart';

class ViewProductScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final int genderType;
  final int catalogId;
  const ViewProductScreen(
      {super.key,
      required this.categoryId,
      required this.categoryName,
      required this.catalogId,
      required this.genderType});

  @override
  State<ViewProductScreen> createState() => ViewProductScreenState();
}

class ViewProductScreenState extends State<ViewProductScreen> {
  final productController = Get.put(ProductController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: whiteColor,
        body: GestureDetector(
          onTap: () {
            // Get.back();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16.sp, left: 16.sp),
                child: AppText(
                  text: widget.categoryName,
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: blackColor,
                  fontSize: 22,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.sp, right: 16.sp, top: 4.sp),
                child: GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Obx(
                        () => AppText(
                          text: productController.total.value == 0
                              ? ""
                              : productController.total.value == 1
                                  ? "${productController.total.value} item"
                                  : "${productController.total.value} items",
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                          color: textHintColor,
                          fontSize: 12,
                        ),
                      ),
                      const Expanded(
                        child: SizedBox(
                          width: 0,
                        ),
                      ),
                      SizedBox(
                        width: 100.sp,
                        height: 30.sp,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: TabBar(
                              isScrollable: true,
                              indicatorColor: btnTextColor,
                              dividerColor: Colors.transparent,
                              unselectedLabelColor: textHintColor,
                              labelColor: btnTextColor,
                              padding: EdgeInsets.zero,
                              onTap: (value) async {
                                String type;
                                if (value == 0) {
                                  type = "catalog_product_linear";
                                } else {
                                  type = "catalog_product_Grid";
                                }
                                await analytics.logEvent(
                                  name: type,
                                  parameters: <String, Object>{
                                    'page_name': type,
                                  },
                                );
                              },
                              indicatorPadding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.zero,
                              indicatorSize: TabBarIndicatorSize.label,
                              indicatorWeight: 2,
                              tabs: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(right: 5.sp, left: 5.sp),
                                  child: Tab(
                                    child: ImageIcon(
                                      AssetImage(outlineImage),
                                      size: 16.sp,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 5.sp, right: 5.sp),
                                  child: Tab(
                                    child: ImageIcon(
                                      AssetImage(menuImage),
                                      size: 16.sp,
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(children: [
                  ProductVerticalScreen(
                    categoryId: widget.categoryId,
                    genderType: widget.genderType,
                    catalogId: widget.catalogId,
                  ),
                  ProductHorizontalScreen(
                    categoryId: widget.categoryId,
                    genderType: widget.genderType,
                    catalogId: widget.catalogId,
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
