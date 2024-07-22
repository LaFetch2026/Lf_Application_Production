// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/catalog_appbar.dart';
import '../../controller/catalog_controller.dart';
import '../../controller/product_controller.dart';
import '../../utils/constants.dart';
import '../cartscreen.dart';
import '../searchscreen.dart';

class CatalogDetailsScreen extends StatefulWidget {
  final String title;
  final String catalogText;
  final String catalogImage;
  final int genderType;

  const CatalogDetailsScreen({
    Key? key,
    required this.title,
    required this.catalogText,
    required this.catalogImage,
    required this.genderType,
  }) : super(key: key);

  @override
  State<CatalogDetailsScreen> createState() => CatalogDetailsScreenState();
}

class CatalogDetailsScreenState extends State<CatalogDetailsScreen> {
  final controller = Get.put(CatalogController());
  final productController = Get.put(ProductController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => controller.getCategoryData(widget.genderType));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          CatalogAppbar(
            text: widget.title,
            onPressedSearch: () {
              Get.to(const SearchScreen());
            },
            onPressedCart: () {
              Get.to(const CartScreen());
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.catalogImage.isNotEmpty
                      ? SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: CachedNetworkImage(
                            cacheManager: CacheManager(Config("customCacheKey",
                                stalePeriod: const Duration(days: 15),
                                maxNrOfCacheObjects: 100)),
                            fit: BoxFit.cover,
                            imageUrl: widget.catalogImage,
                            /*  progressIndicatorBuilder:
                                (context, url, downloadProgress) => Center(
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress),
                            ), */
                            errorWidget: (context, url, error) => Image.asset(
                              downloadImage,
                              height: 210,
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 100,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(backImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  Container(
                    height: 65,
                    color: whiteBorderColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppText(
                            text: widget.title,
                            color: appbarText,
                            fontSize: 22.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                          const Expanded(
                            child: SizedBox(
                              width: 0,
                            ),
                          ),
                          AppText(
                            text: "For ${widget.catalogText}",
                            color: textHintColor,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(() => controller.isCategory.value
                      ? const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : controller.categoryList.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 12),
                              child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: controller.categoryList.length,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return Column(
                                      children: [
                                        GestureDetector(
                                            onTap: () async {
                                              productController
                                                  .getProductByCategoryData(
                                                      controller.categoryList[
                                                          index]["id"],
                                                      0,
                                                      "Product Vertical",
                                                      controller.categoryList,
                                                      "");
                                              await analytics.logEvent(
                                                name:
                                                    "catalog_details_${widget.genderType}",
                                                parameters: <String, Object>{
                                                  'page_name':
                                                      "catalog_details_${widget.genderType}",
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    AppText(
                                                      text: controller
                                                                  .categoryList[
                                                              index]["name"] ??
                                                          "",
                                                      color: greyTextColor,
                                                      fontSize: 14.sp,
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ],
                                    );
                                  }),
                            )
                          : const Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Center(
                                child: Text("No Category Found",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontFamily: "Franklin Gothic Regular")),
                              ),
                            ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
