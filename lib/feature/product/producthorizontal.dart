// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/feature/product/productdetailsscreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../common/widget/bottom_sheets/bottomfiltters.dart';
import '../../common/widget/bottom_sheets/bottomsortby.dart';
import '../../common/widget/bottom_sheets/bottomwishlist.dart';
import '../../common/widget/button/doublebtn.dart';
import '../../common/widget/lists/dummy_grid_list.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/constant/constants.dart';


class ProductHorizontalScreen extends StatefulWidget {
  final int categoryId;
  final int genderType;
  final int catalogId;
  const ProductHorizontalScreen(
      {super.key,
        required this.categoryId,
        required this.genderType,
        required this.catalogId});

  @override
  State<ProductHorizontalScreen> createState() =>
      ProductHorizontalScreenState();
}

class ProductHorizontalScreenState extends State<ProductHorizontalScreen> {
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    productController.productCategoryList.clear();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.categoryProductHasnextpage.value = true;
      productController.categoryProductLoadMore.value = false;
      productController.isCategoryProduct.value = false;
      productController.categoryProductPage.value = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        productController.getProductByCategoryData(
            widget.categoryId,
            0,
            "",
            [],
            productController.sortBy.value,
            widget.genderType,
            productController.filterEnable.value,
            widget.catalogId,
            false,
            "catalog"));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.categoryProductController.addListener(() {
        productController.fetchCategoryProductMoreData(
            0,
            productController.sortBy.value,
            widget.genderType,
            productController.filterEnable.value,
            "catalog");
        productController.update();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove("brandList");
        prefs.remove("colorList");
        prefs.remove("sizeList");
        prefs.remove("upper");
        prefs.remove("lower");
        prefs.remove("sortby");
        productController.size_ids.clear();
        productController.color_ids.clear();
        productController.brand_ids.clear();
        return true;
      },
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: whiteColor,
          body: Obx(() => productController.isCategoryProduct.value
              ? const DummyGridList()
              : Stack(
            children: [
              Positioned.fill(
                child: productController.productCategoryList.isNotEmpty
                    ? SingleChildScrollView(
                    controller:
                    productController.categoryProductController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 16.sp,
                              right: 16.sp,
                              top: 20.sp,
                              bottom: 80.sp),
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            controller: productController
                                .categoryProductController,
                            scrollDirection: Axis.vertical,
                            padding: EdgeInsets.zero,
                            childAspectRatio: 0.5,
                            physics: const ScrollPhysics(),
                            crossAxisSpacing: 5.sp,
                            mainAxisSpacing: 0,
                            children: List.generate(
                              productController
                                  .productCategoryList.length,
                                  (index) {
                                return GestureDetector(
                                  onTap: () async {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                        builder: (BuildContext
                                        context) =>
                                            ProductDetailsScreen(
                                                brandName: productController
                                                    .productCategoryList[
                                                index]
                                                [
                                                "brand_name"],
                                                productId: productController
                                                    .productCategoryList[
                                                index]["id"],
                                                type: "add")))
                                        .then((value) => setState(
                                          () {
                                        productController
                                            .categoryProductHasnextpage
                                            .value = true;
                                        productController
                                            .categoryProductLoadMore
                                            .value = false;
                                        productController
                                            .isCategoryProduct
                                            .value = false;
                                        productController
                                            .categoryProductPage
                                            .value = 1;
                                        productController.getProductByCategoryData(
                                            widget.categoryId,
                                            0,
                                            "",
                                            [],
                                            productController
                                                .sortBy.value,
                                            widget.genderType,
                                            productController
                                                .filterEnable
                                                .value,
                                            widget.catalogId,
                                            false,
                                            "catalog");
                                      },
                                    ));
                                    await analytics.logEvent(
                                      name:
                                      'catalog_product_grid_details',
                                      parameters: <String, Object>{
                                        'page_name':
                                        'catalog_product_grid_details',
                                      },
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Center(
                                            child: productController
                                                .productCategoryList[index]
                                            ["images"]
                                                .isNotEmpty &&
                                                productController.productCategoryList[index]
                                                [
                                                "images"] !=
                                                    null
                                                ? SizedBox(
                                              height: (MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width /
                                                  2) +
                                                  10.sp,
                                              width: (MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width /
                                                  2) -
                                                  24.sp,
                                              child:
                                              CachedNetworkImage(
                                                cacheManager: CacheManager(Config(
                                                    "customCacheKey",
                                                    stalePeriod:
                                                    const Duration(
                                                        days:
                                                        15),
                                                    maxNrOfCacheObjects:
                                                    100)),
                                                fit: BoxFit
                                                    .cover,
                                                imageUrl: isImage(productController.productCategoryList[index]
                                                ["images"][0]
                                                [
                                                "name"])
                                                    ? productController.productCategoryList[index]
                                                ["images"][0]
                                                ["name"]
                                                    : productController.productCategoryList[index]
                                                ["images"][1]
                                                [
                                                "name"],
                                                errorWidget: (context,
                                                    url,
                                                    error) =>
                                                    Image.asset(
                                                      downloadImage,
                                                      fit: BoxFit
                                                          .cover,
                                                      height: (MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                          2) +
                                                          10.sp,
                                                      width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                          2) -
                                                          24.sp,
                                                    ),
                                              ),
                                            )
                                                : Image.asset(
                                                dummyWishlistImage,
                                                height: (MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                    2) +
                                                    10.sp,
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                    2) -
                                                    24.sp,
                                                fit: BoxFit.cover),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              if (productController
                                                  .productCategoryList[
                                              index]["wishlisted"]) {
                                                productController
                                                    .productCategoryList[
                                                index][
                                                "wishlisted"] = false;
                                                setState(() {});
                                                productController.callAddProductToWishlist(
                                                    productController
                                                        .productCategoryList[
                                                    index][
                                                    "wishlist_id"],
                                                    "category",
                                                    productController
                                                        .productCategoryList[
                                                    index]["id"],
                                                    widget.categoryId,
                                                    0,
                                                    [],
                                                    [],
                                                    0,
                                                    widget.genderType,
                                                    widget.catalogId);
                                              } else {
                                                scaffoldKey
                                                    .currentState
                                                    ?.showBottomSheet((context) =>
                                                    BottomWishlist(
                                                        controller:
                                                        wishlistController,
                                                        onPressed:
                                                            (p0) {
                                                          productController.productCategoryList[index]["wishlisted"] =
                                                          true;
                                                          setState(
                                                                  () {});
                                                          productController.callAddProductToWishlist(
                                                              p0,
                                                              "category",
                                                              productController.productCategoryList[index]["id"],
                                                              widget.categoryId,
                                                              0,
                                                              [],
                                                              [],
                                                              0,
                                                              widget.genderType,
                                                              widget.catalogId);
                                                        },
                                                        wishlistList:
                                                        wishlistController
                                                            .wishlistList));
                                              }
                                              await analytics
                                                  .logEvent(
                                                name:
                                                'catalog_product_grid_wishlist',
                                                parameters: <String,
                                                    Object>{
                                                  'page_name':
                                                  'catalog_product_grid_wishlist',
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  16.sp,
                                                  vertical:
                                                  10.sp),
                                              child: Align(
                                                alignment: Alignment
                                                    .topRight,
                                                child: InkWell(
                                                  child: SizedBox(
                                                    height: 24.sp,
                                                    width: 24.sp,
                                                    child:
                                                    CircleAvatar(
                                                      backgroundColor:
                                                      whiteColor,
                                                      child: productController
                                                          .productCategoryList[index]
                                                      [
                                                      "wishlisted"]
                                                          ? Image
                                                          .asset(
                                                        wishlistSelectImage,
                                                        height:
                                                        18.sp,
                                                        width: 18
                                                            .sp,
                                                      )
                                                          : Image
                                                          .asset(
                                                        heartImage,
                                                        height:
                                                        18.sp,
                                                        width: 18
                                                            .sp,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 16.sp,
                                            left: 16.sp,
                                            child: Container(
                                              color: const Color(
                                                  0xB3F7F7F5),
                                              height: 26.sp,
                                              width: 80.sp,
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .symmetric(
                                                        horizontal:
                                                        2.sp),
                                                    child:
                                                    Image.asset(
                                                      starImage,
                                                      height: 16.sp,
                                                      color:
                                                      bottomnavBack,
                                                      width: 16.sp,
                                                    ),
                                                  ),
                                                  AppText(
                                                    text: productController
                                                        .productCategoryList[index]
                                                    [
                                                    "aggregated_rating"] !=
                                                        null
                                                        ? productController
                                                        .productCategoryList[
                                                    index]
                                                    [
                                                    "aggregated_rating"]
                                                        .toString()
                                                        : "",
                                                    color:
                                                    colorPrimary,
                                                    fontSize: 12,
                                                    fontFamily:
                                                    "Franklin Gothic Regular",
                                                    fontWeight:
                                                    FontWeight
                                                        .w400,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .symmetric(
                                                        horizontal:
                                                        10.sp),
                                                    child: Container(
                                                      width: 1.sp,
                                                      color:
                                                      textHintColor,
                                                      height: 16.sp,
                                                    ),
                                                  ),
                                                  AppText(
                                                    text: productController
                                                        .productCategoryList[
                                                    index][
                                                    "reviews_count"]
                                                        .toString(),
                                                    color:
                                                    colorPrimary,
                                                    fontSize: 12,
                                                    fontFamily:
                                                    "Franklin Gothic Regular",
                                                    fontWeight:
                                                    FontWeight
                                                        .w400,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.sp,
                                            vertical: 5.sp),
                                        child: AppText(
                                          text: productController
                                              .productCategoryList[
                                          index]["name"] ??
                                              "",
                                          color: nameText,
                                          maxLines: 2,
                                          fontSize: 12,
                                          fontFamily:
                                          "Franklin Gothic",
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.sp),
                                        child: AppText(
                                          text: productController
                                              .productCategoryList[
                                          index]["brand_name"] ??
                                              "",
                                          color: nameText,
                                          maxLines: 2,
                                          fontSize: 11,
                                          fontFamily:
                                          "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 10.sp,
                                            left: 10.sp,
                                            right: 1.sp),
                                        child: Row(
                                          children: [
                                            AppText(
                                              text:
                                              "\u{20B9} ${productController.productCategoryList[index]["price"] ?? ""}",
                                              color:
                                              deepGreytextColor,
                                              maxLines: 2,
                                              fontSize: 11,
                                              fontFamily:
                                              "Franklin Gothic",
                                              fontWeight:
                                              FontWeight.w400,
                                            ),
                                            Visibility(
                                              visible: productController
                                                  .productCategoryList[
                                              index]["mrp"] !=
                                                  null
                                                  ? true
                                                  : false,
                                              child: Padding(
                                                padding:
                                                EdgeInsets.only(
                                                    left: 5.sp),
                                                child: Text(
                                                  "\u{20B9} ${productController.productCategoryList[index]["mrp"] ?? ""}",
                                                  style: TextStyle(
                                                    color:
                                                    textHintColor,
                                                    fontSize: 11.sp,
                                                    decoration:
                                                    TextDecoration
                                                        .lineThrough,
                                                    fontFamily:
                                                    "Franklin Gothic Regular",
                                                    fontWeight:
                                                    FontWeight
                                                        .w400,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      productController
                                          .productCategoryList[
                                      index]["express_delivery"]
                                          ? Padding(
                                        padding:
                                        EdgeInsets.only(
                                            top: 5.sp,
                                            left: 10.sp,
                                            right: 10.sp),
                                        child: Row(
                                          children: [
                                            ImageIcon(
                                              AssetImage(
                                                  truckImage),
                                              color:
                                              expressText,
                                              size: 14.sp,
                                            ),
                                            Padding(
                                              padding: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  5.sp),
                                              child: AppText(
                                                text: "Express",
                                                color:
                                                expressText,
                                                maxLines: 2,
                                                fontSize: 11,
                                                fontFamily:
                                                "Franklin Gothic Regular",
                                                fontWeight:
                                                FontWeight
                                                    .w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                          : SizedBox(
                                        height: 0,
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        productController
                            .categoryProductLoadMore.value
                            ? const DummyGridList()
                            : const SizedBox(
                          height: 0,
                        ),
                      ],
                    ))
                    : SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text("No Product Found",
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontFamily: "Franklin Gothic Regular")),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: 16.sp,
                      top: 20.sp,
                      left: 4.sp,
                      right: 12.sp),
                  child: DoubleButton(
                    firstText: "Sort By",
                    secondText: "Filters",
                    firstTextColor: deepGreytextColor,
                    secondTextColor: deepGreytextColor,
                    firstBackgroundColor: backWhite,
                    secondBackgroundColor: backWhite,
                    firstBorderColor: deepGreytextColor,
                    secondBorderColor: deepGreytextColor,
                    onPressedFirst: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        constraints: BoxConstraints(
                          maxWidth: double.infinity,
                          maxHeight: 340.sp,
                        ),
                        builder: (ctx) {
                          return BottomSortBy(
                            onPressedButton: (p0) {
                              productController.sortBy.value = p0;
                              productController.getProductByCategoryData(
                                  widget.categoryId,
                                  0,
                                  "",
                                  [],
                                  p0,
                                  widget.genderType,
                                  productController.filterEnable.value,
                                  widget.catalogId,
                                  false,
                                  "catalog");
                            },
                          );
                        },
                      );
                    },
                    onPressedSecond: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        constraints: BoxConstraints(
                          maxWidth: double.infinity,
                          maxHeight: 500.sp,
                        ),
                        builder: (ctx) {
                          return BottomFilters(
                            btnclearAll: () async {
                              productController.brand_ids.clear();
                              productController.color_ids.clear();
                              productController.size_ids.clear();
                              productController.sortBy.value = "";
                              productController.filterEnable.value =
                              false;
                              // Get.back();
                              final prefs =
                              await SharedPreferences.getInstance();
                              prefs.remove("brandList");
                              prefs.remove("colorList");
                              prefs.remove("sizeList");
                              prefs.remove("upper");
                              prefs.remove("lower");
                              prefs.remove("sortby");
                              productController.getProductByCategoryData(
                                  widget.categoryId,
                                  0,
                                  "",
                                  [],
                                  productController.sortBy.value,
                                  widget.genderType,
                                  productController.filterEnable.value,
                                  widget.catalogId,
                                  false,
                                  "catalog");
                            },
                            onClick: (p0, p1) {
                              productController.filterEnable.value = true;
                              productController.lowPrice.value = p0;
                              productController.highPrice.value = p1;
                              productController.getProductByCategoryData(
                                  widget.categoryId,
                                  0,
                                  "",
                                  [],
                                  productController.sortBy.value,
                                  widget.genderType,
                                  productController.filterEnable.value,
                                  widget.catalogId,
                                  true,
                                  "catalog");
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ))),
    );
  }
}
