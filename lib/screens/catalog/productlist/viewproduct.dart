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
  const ViewProductScreen(
      {super.key,
      required this.categoryId,
      required this.categoryName,
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
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16),
                  child: AppText(
                    text: widget.categoryName,
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: blackColor,
                    fontSize: 22.sp,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
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
                            fontSize: 12.sp,
                          ),
                        ),
                        const Expanded(
                          child: SizedBox(
                            width: 0,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          height: 30,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: TabBar(
                                isScrollable: true,
                                indicatorColor: btnTextColor,
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
                                tabs: const [
                                  Padding(
                                    padding: EdgeInsets.only(right: 5, left: 5),
                                    child: Tab(
                                      child: ImageIcon(
                                        AssetImage(outlineImage),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    child: Tab(
                                      child: ImageIcon(
                                        AssetImage(menuImage),
                                        size: 20,
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
                    ),
                    ProductHorizontalScreen(
                      categoryId: widget.categoryId,
                      genderType: widget.genderType,
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
