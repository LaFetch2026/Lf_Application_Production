// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/productlist_appbar.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import '../../commonwidget/app_text.dart';
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
  final int catalogId;

  const CatalogDetailsScreen({
    Key? key,
    required this.title,
    required this.catalogText,
    required this.catalogImage,
    required this.genderType,
    required this.catalogId,
  }) : super(key: key);

  @override
  State<CatalogDetailsScreen> createState() => CatalogDetailsScreenState();
}

class CatalogDetailsScreenState extends State<CatalogDetailsScreen> {
  final controller = Get.put(CatalogController());
  final productController = Get.put(ProductController());
  final cartController = Get.put(CartController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => controller.getCategoryData(widget.genderType, widget.catalogId));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => productController.id.value = 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          /*  CatalogAppbar(
            text: widget.title,
            onPressedSearch: () {
              Get.to(const SearchScreen());
            },
            onPressedCart: () {
              Get.to(const CartScreen());
            },
          ), */
          ProductAppbar(
              text: widget.title,
              onPressedSearch: () async {
                Get.to(const SearchScreen())?.then((value) => setState(
                      () {
                        productController.getHandPickedProduct(
                            productController.productSortBy.value,
                            productController.filterProductEnable.value,
                            false,
                            productController.tagId.value);
                      },
                    ));
                analytics
                    .logEvent(name: "search_page", parameters: <String, Object>{
                  "page_name": "search_page",
                });
              },
              isHandPicked: true,
              onPressedHeart: () async {
                Get.to(const WishlistScreen())?.then((value) => setState(
                      () {
                        cartController.getCartData();
                      },
                    ));
                analytics.logEvent(
                    name: "wishlist_page",
                    parameters: <String, Object>{
                      "page_name": "wishlist_page",
                    });
              },
              onPressedCart: () async {
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.catalogImage.isNotEmpty
                      ? SizedBox(
                          height: 100.sp,
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
                              height: 210.sp,
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 100.sp,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(backImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  Container(
                    height: 65.sp,
                    color: whiteBorderColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppText(
                            text: widget.title,
                            color: appbarText,
                            fontSize: 16,
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
                            fontSize: 14,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(() => controller.isCategory.value
                      ? Padding(
                          padding: EdgeInsets.only(
                              left: 16.sp, right: 16.sp, top: 22.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DummyContainer(height: 14, width: 80),
                              Padding(
                                padding: EdgeInsets.only(top: 20.sp),
                                child: DummyContainer(height: 14, width: 80),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20.sp),
                                child: DummyContainer(height: 14, width: 80),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20.sp),
                                child: DummyContainer(height: 14, width: 80),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20.sp),
                                child: DummyContainer(height: 14, width: 80),
                              ),
                            ],
                          ),
                        )
                      : controller.categoryList.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp, right: 16.sp, top: 22.sp),
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
                                              productController.catalogIndex
                                                  .value = index + 1;
                                              productController.id.value =
                                                  controller.categoryList[index]
                                                      ["id"];
                                              setState(() {});
                                              productController
                                                  .getProductByCategoryData(
                                                      controller.categoryList[
                                                          index]["id"],
                                                      0,
                                                      "Product Vertical",
                                                      controller.categoryList,
                                                      "",
                                                      widget.genderType,
                                                      false,
                                                      widget.catalogId,
                                                      false,
                                                      "catalog");
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
                                              padding: EdgeInsets.only(
                                                  bottom: 10.sp),
                                              child: Container(
                                                color: productController
                                                            .id.value ==
                                                        controller.categoryList[
                                                            index]["id"]
                                                    ? whiteTextColor
                                                    : whiteColor,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(6.sp),
                                                      child: AppText(
                                                        text: controller
                                                                    .categoryList[
                                                                index]["name"] ??
                                                            "",
                                                        color: greyTextColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ],
                                    );
                                  }),
                            )
                          : Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Center(
                                child: Text("No Category Found",
                                    style: TextStyle(
                                        fontSize: 14.sp,
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
