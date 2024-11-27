// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_grid_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/catalogwidgets/bottomfiltters.dart';
import '../../commonwidget/catalogwidgets/bottomsortby.dart';
import '../../commonwidget/catalogwidgets/bottomwishlist.dart';
import '../../commonwidget/doublebtn.dart';
import '../../commonwidget/dummy_container.dart';
import '../../controller/product_controller.dart';
import '../../controller/wishlist_controller.dart';
import '../../utils/constants.dart';
import '../catalog/productlist/productdetailsscreen.dart';

class ViewAllScreen extends StatefulWidget {
  final int brandId;
  const ViewAllScreen({super.key, required this.brandId});

  @override
  State<ViewAllScreen> createState() => ViewAllScreenState();
}

class ViewAllScreenState extends State<ViewAllScreen> {
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => (timeStamp) {
          productController.brandExpressHasnextpage.value = true;
          productController.brandExpressLoadMore.value = false;
          productController.isBrandExpressProduct.value = false;
          productController.brandExpressPage.value = 1;
        });
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        productController.getBrandExpressProductData(
            widget.brandId,
            productController.expressSortBy.value,
            productController.filterExpressEnable.value));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.brandExpressProductController.addListener(() {
        productController.fetchBrandExpressMoreData(
            "", productController.filterExpressEnable.value);
        productController.update();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: whiteColor,
        body: Obx(() => productController.isBrandExpressProduct.value
            ? Padding(
                padding: EdgeInsets.only(
                  left: 16.sp,
                  right: 16.sp,
                  top: 10.sp,
                ),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.zero,
                  childAspectRatio: 0.5,
                  physics: const ScrollPhysics(),
                  crossAxisSpacing: 5.sp,
                  mainAxisSpacing: 0.sp,
                  children: List.generate(
                    6,
                    (index) {
                      return Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      height:
                                          (MediaQuery.of(context).size.width /
                                                  2) +
                                              10.sp,
                                      width:
                                          (MediaQuery.of(context).size.width /
                                                  2) -
                                              24.sp,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.04),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 22.sp, vertical: 10.sp),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        child: DummyContainer(
                                          height: 24,
                                          width: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16.sp,
                                    left: 16.sp,
                                    child: DummyContainer(
                                      height: 26,
                                      width: 80,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.sp, vertical: 5.sp),
                                child: DummyContainer(
                                  height: 10,
                                  width: 50,
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 10.sp),
                                child: DummyContainer(
                                  height: 10,
                                  width: 50,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10.sp, left: 10.sp, right: 1.sp),
                                child: Row(
                                  children: [
                                    DummyContainer(
                                      height: 10,
                                      width: 50,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.sp),
                                      child: DummyContainer(
                                        height: 10,
                                        width: 50,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10.sp, left: 10.sp, right: 10.sp),
                                child: Row(
                                  children: [
                                    DummyContainer(
                                      height: 14,
                                      width: 14,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5.sp),
                                      child: DummyContainer(
                                        height: 10,
                                        width: 50,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              )
            : Stack(
                children: [
                  Positioned.fill(
                    child: productController.productExpressBrandList.isNotEmpty
                        ? SingleChildScrollView(
                            controller:
                                productController.brandExpressProductController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 16.sp,
                                      right: 16.sp,
                                      top: 10.sp,
                                      bottom: 90.sp),
                                  child: GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: 2,
                                    controller: productController
                                        .brandExpressProductController,
                                    scrollDirection: Axis.vertical,
                                    padding: EdgeInsets.zero,
                                    childAspectRatio: 0.5,
                                    physics: const ScrollPhysics(),
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 0,
                                    children: List.generate(
                                      productController
                                          .productExpressBrandList.length,
                                      (index) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            ProductDetailsScreen(
                                                                brandName: productController
                                                                            .productExpressBrandList[
                                                                        index][
                                                                    "brand_name"],
                                                                productId: productController
                                                                        .productExpressBrandList[
                                                                    index]["id"],
                                                                type: "add")))
                                                    .then((value) => setState(
                                                          () {
                                                            productController
                                                                .brandExpressHasnextpage
                                                                .value = true;
                                                            productController
                                                                .brandExpressLoadMore
                                                                .value = false;
                                                            productController
                                                                .isBrandExpressProduct
                                                                .value = false;
                                                            productController
                                                                .brandExpressPage
                                                                .value = 1;
                                                            productController.getBrandExpressProductData(
                                                                widget.brandId,
                                                                productController
                                                                    .expressSortBy
                                                                    .value,
                                                                productController
                                                                    .filterExpressEnable
                                                                    .value);
                                                          },
                                                        ));
                                                await analytics.logEvent(
                                                  name:
                                                      'express_page_brandproduct',
                                                  parameters: <String, Object>{
                                                    'page_name':
                                                        'express_page_brandproduct',
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
                                                                    .productExpressBrandList[index]
                                                                        [
                                                                        "images"]
                                                                    .isNotEmpty &&
                                                                productController.productExpressBrandList[index]["images"] !=
                                                                    null
                                                            ? SizedBox(
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
                                                                child:
                                                                    CachedNetworkImage(
                                                                  cacheManager: CacheManager(Config(
                                                                      "customCacheKey",
                                                                      stalePeriod: const Duration(
                                                                          days:
                                                                              15),
                                                                      maxNrOfCacheObjects:
                                                                          100)),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  imageUrl: isImage(productController.productExpressBrandList[index]["images"]
                                                                              [0]
                                                                          [
                                                                          "name"])
                                                                      ? productController.productExpressBrandList[index]
                                                                              ["images"][0]
                                                                          [
                                                                          "name"]
                                                                      : productController
                                                                              .productExpressBrandList[index]["images"][1]
                                                                          ["name"],
                                                                  /*  progressIndicatorBuilder:
                                                                    (context,
                                                                            url,
                                                                            downloadProgress) =>
                                                                        Center(
                                                                  child: CircularProgressIndicator(
                                                                      value: downloadProgress
                                                                          .progress),
                                                                ), */
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Image
                                                                          .asset(
                                                                    downloadImage,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    height: (MediaQuery.of(context).size.width /
                                                                            2) +
                                                                        10.sp,
                                                                    width: (MediaQuery.of(context).size.width /
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
                                                          productController
                                                              .brandExpressHasnextpage
                                                              .value = true;
                                                          productController
                                                              .brandExpressLoadMore
                                                              .value = false;
                                                          productController
                                                              .isBrandExpressProduct
                                                              .value = false;
                                                          productController
                                                              .brandExpressPage
                                                              .value = 1;
                                                          if (productController
                                                                      .productExpressBrandList[
                                                                  index]
                                                              ["wishlisted"]) {
                                                            productController.callAddProductToWishlist(
                                                                productController
                                                                            .productExpressBrandList[
                                                                        index][
                                                                    "wishlist_id"],
                                                                "brand",
                                                                productController
                                                                        .productExpressBrandList[
                                                                    index]["id"],
                                                                0,
                                                                widget.brandId,
                                                                [],
                                                                [],
                                                                0,
                                                                0,
                                                                0);
                                                          } else {
                                                            scaffoldKey.currentState?.showBottomSheet((context) =>
                                                                BottomWishlist(
                                                                    controller:
                                                                        wishlistController,
                                                                    onPressed:
                                                                        (p0) {
                                                                      productController.callAddProductToWishlist(
                                                                          p0,
                                                                          "brand",
                                                                          productController.productExpressBrandList[index]
                                                                              [
                                                                              "id"],
                                                                          0,
                                                                          widget
                                                                              .brandId,
                                                                          [],
                                                                          [],
                                                                          0,
                                                                          0,
                                                                          0);
                                                                    },
                                                                    wishlistList:
                                                                        wishlistController
                                                                            .wishlistList));
                                                            await analytics
                                                                .logEvent(
                                                              name:
                                                                  'express_page_brandproduct_wishlist',
                                                              parameters: <String,
                                                                  Object>{
                                                                'page_name':
                                                                    'express_page_brandproduct_wishlist',
                                                              },
                                                            );
                                                          }
                                                        },
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      22.sp,
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
                                                                              .productExpressBrandList[index]
                                                                          [
                                                                          "wishlisted"]
                                                                      ? Image
                                                                          .asset(
                                                                          wishlistSelectImage,
                                                                          height:
                                                                              18.sp,
                                                                          color:
                                                                              bottomnavBack,
                                                                          width:
                                                                              18.sp,
                                                                        )
                                                                      : Image
                                                                          .asset(
                                                                          heartImage,
                                                                          height:
                                                                              18.sp,
                                                                          color:
                                                                              bottomnavBack,
                                                                          width:
                                                                              18.sp,
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
                                                                text: productController.productExpressBrandList[index]
                                                                            [
                                                                            "aggregated_rating"] !=
                                                                        null
                                                                    ? productController
                                                                        .productExpressBrandList[
                                                                            index]
                                                                            [
                                                                            "aggregated_rating"]
                                                                        .toString()
                                                                    : "0",
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
                                                                child:
                                                                    Container(
                                                                  width: 1.sp,
                                                                  color:
                                                                      textHintColor,
                                                                  height: 16.sp,
                                                                ),
                                                              ),
                                                              AppText(
                                                                text: productController
                                                                    .productExpressBrandList[
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
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.sp,
                                                            vertical: 5.sp),
                                                    child: AppText(
                                                      text: productController
                                                                  .productExpressBrandList[
                                                              index]["name"] ??
                                                          "",
                                                      color: nameText,
                                                      maxLines: 1,
                                                      fontSize: 12,
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.sp),
                                                    child: AppText(
                                                      text:
                                                          "${productController.productExpressBrandList[index]["short_description"]} \n"
                                                          "",
                                                      color: nameText,
                                                      maxLines: 2,
                                                      fontSize: 11,
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
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
                                                              "\u{20B9} ${productController.productExpressBrandList[index]["price"] ?? ""}",
                                                          color:
                                                              deepGreytextColor,
                                                          maxLines: 2,
                                                          fontSize: 11,
                                                          fontFamily:
                                                              "Franklin Gothic",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5.sp),
                                                          child: Text(
                                                            "\u{20B9} ${productController.productExpressBrandList[index]["mrp"] ?? ""}",
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
                                                      ],
                                                    ),
                                                  ),
                                                  productController
                                                              .productExpressBrandList[
                                                          index]["express_delivery"]
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.sp,
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
                                                                  text:
                                                                      "Express",
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
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                productController.brandExpressLoadMore.value
                                    ? const DummyGridList()
                                    : const SizedBox(
                                        height: 0,
                                      ),
                              ],
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: const Center(
                              child: Text("No Product Found",
                                  style: TextStyle(
                                      fontSize: 14,
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
                          bottom: 30.sp, top: 20.sp, left: 4.sp, right: 12.sp),
                      child: DoubleButton(
                        firstText: "Sort By",
                        secondText: "Filters",
                        firstTextColor: deepGreytextColor,
                        secondTextColor: deepGreytextColor,
                        firstBackgroundColor: backWhite,
                        secondBackgroundColor: backWhite,
                        firstBorderColor: deepGreytextColor,
                        secondBorderColor: deepGreytextColor,
                        onPressedFirst: () async {
                          scaffoldKey.currentState?.showBottomSheet((context) =>
                              BottomSortBy(
                                onPressedButton: (p0) {
                                  productController.expressSortBy.value = p0;
                                  productController.getBrandExpressProductData(
                                      widget.brandId,
                                      productController.expressSortBy.value,
                                      productController
                                          .filterExpressEnable.value);
                                },
                              ));
                          await analytics.logEvent(
                            name: 'express_page_sortby',
                            parameters: <String, Object>{
                              'page_name': 'express_page_sortby',
                            },
                          );
                        },
                        onPressedSecond: () async {
                          Get.to(BottomFilters(
                            btnclearAll: () async {
                              productController.brand_ids.clear();
                              productController.color_ids.clear();
                              productController.size_ids.clear();
                              productController.expressSortBy.value = "";
                              productController.filterExpressEnable.value =
                                  false;
                              Get.back();
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.remove("brandList");
                              prefs.remove("colorList");
                              prefs.remove("sizeList");
                              prefs.remove("upper");
                              prefs.remove("lower");
                              productController.getBrandExpressProductData(
                                  widget.brandId,
                                  productController.expressSortBy.value,
                                  productController.filterExpressEnable.value);
                            },
                            onClick: (p0, p1) {
                              productController.filterExpressEnable.value =
                                  true;
                              productController.lowPrice.value = p0;
                              productController.highPrice.value = p1;
                              productController.getBrandExpressProductData(
                                  widget.brandId,
                                  productController.expressSortBy.value,
                                  productController.filterExpressEnable.value);
                            },
                          ));
                          await analytics.logEvent(
                            name: 'express_page_filter',
                            parameters: <String, Object>{
                              'page_name': 'express_page_filter',
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              )));
  }
}
