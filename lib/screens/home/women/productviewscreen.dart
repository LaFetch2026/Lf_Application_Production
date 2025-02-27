// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/productlist_appbar.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomcategory.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomfiltters.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomsortby.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
//import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_grid_list.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../commonwidget/app_text.dart';
//import '../../../commonwidget/catalogwidgets/bottomwishlist.dart';
import '../../../controller/product_controller.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../utils/constants.dart';

class ProductViewScreen extends StatefulWidget {
  final String title;
  final String genderName;

  const ProductViewScreen({
    super.key,
    required this.title,
    required this.genderName,
  });

  @override
  State<ProductViewScreen> createState() => ProductViewScreenState();
}

class ProductViewScreenState extends State<ProductViewScreen> {
  final productController = Get.find<ProductController>();
  final wishlistController = Get.put(WishlistController());
  final controller = Get.put(CartController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    productController.handPickedProductList.clear();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.handpickedHasnextpage.value = true;
      productController.handpickedLoadMore.value = false;
      productController.isHandPicked.value = false;
      productController.handpickedPage.value = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        productController.getHomeExploreProduct(
            productController.productSortBy.value,
            productController.filterProductEnable.value,
            false,
            productController.tagId.value));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getCartData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.handpickedController.addListener(() {
        productController.fetchMoreHomeProduct(
            productController.productSortBy.value,
            productController.filterProductEnable.value,
            productController.tagId.value);
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductAppbar(
                text: widget.title,
                onPressedSearch: () async {
                  Get.to(const SearchScreen())?.then((value) => setState(
                        () {
                          productController.getHomeExploreProduct(
                              productController.productSortBy.value,
                              productController.filterProductEnable.value,
                              false,
                              productController.tagId.value);
                        },
                      ));
                  analytics.logEvent(
                      name: "search_page",
                      parameters: <String, Object>{
                        "page_name": "search_page",
                      });
                },
                isHandPicked: true,
                onPressedHeart: () async {
                  Get.to(const BottomNavScreen(
                    index: 2,
                  ))?.then((value) => setState(
                        () {
                          controller.getCartData();
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
                          controller.getCartData();
                        },
                      ));
                  analytics
                      .logEvent(name: "cart_page", parameters: <String, Object>{
                    "page_name": "cart_page",
                  });
                }),
            /*  Padding(
              padding: EdgeInsets.only(left: 16.sp, top: 16.sp),
              child: AppText(
                text: "HANDPICKED FOR YOU",
                color: Color(0xFF4B5563),
                fontSize: 16,
                fontFamily: "Franklin Gothic",
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w500,
              ),
            ),
            Obx(() => Padding(
                  padding: EdgeInsets.only(left: 16.sp, top: 5.sp),
                  child: productController.isHandPicked.value
                      ? const DummyContainer(
                          height: 10,
                          width: 60,
                        )
                      : AppText(
                          text: productController.totalProductValue.value ==
                                      1 ||
                                  productController.totalProductValue.value == 0
                              ? "${productController.totalProductValue.value} item"
                              : "${productController.totalProductValue.value} items",
                          color: Color(0xFF4B5563),
                          fontSize: 10,
                          fontFamily: "Franklin Gothic Regular",
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w500,
                        ),
                )),
            */
            Obx(
              () => productController.isHandPicked.value
                  ? Expanded(
                      child: const DummyGridList(
                        size: 2,
                      ),
                    )
                  : productController.handPickedProductList.isNotEmpty
                      ? Expanded(
                          child: SingleChildScrollView(
                            controller: productController.handpickedController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.sp, vertical: 20.sp),
                                  child: GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: 2,
                                    controller:
                                        productController.handpickedController,
                                    scrollDirection: Axis.vertical,
                                    padding: EdgeInsets.zero,
                                    childAspectRatio: 0.57,
                                    physics: const ScrollPhysics(),
                                    crossAxisSpacing: 5.sp,
                                    mainAxisSpacing: 8.sp,
                                    children: List.generate(
                                      productController
                                          .handPickedProductList.length,
                                      (index) {
                                        return GestureDetector(
                                          onTap: () async {
                                            Get.to(ProductDetailsScreen(
                                                    brandName: productController
                                                            .handPickedProductList[
                                                        index]["brand_name"],
                                                    productId: productController
                                                            .handPickedProductList[
                                                        index]["id"],
                                                    type: "add"))
                                                ?.then((value) => setState(
                                                      () {
                                                        productController
                                                            .handpickedHasnextpage
                                                            .value = true;
                                                        productController
                                                            .handpickedLoadMore
                                                            .value = false;
                                                        productController
                                                            .isHandPicked
                                                            .value = false;
                                                        productController
                                                            .handpickedPage
                                                            .value = 1;
                                                        controller
                                                            .getCartData();
                                                      },
                                                    ));
                                            await analytics.logEvent(
                                              name: 'category_product_details',
                                              parameters: <String, Object>{
                                                'page_name':
                                                    'category_product_details',
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
                                                                .handPickedProductList[index]
                                                                    ["images"]
                                                                .isNotEmpty &&
                                                            productController
                                                                        .handPickedProductList[index][
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
                                                              fit: BoxFit.cover,
                                                              imageUrl: isImage(productController
                                                                              .handPickedProductList[index]
                                                                          ["images"][0]
                                                                      ["name"])
                                                                  ? productController
                                                                              .handPickedProductList[index]
                                                                          ["images"]
                                                                      [
                                                                      0]["name"]
                                                                  : productController
                                                                              .handPickedProductList[index]
                                                                          ["images"]
                                                                      [1]["name"],
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
                                                  /*   GestureDetector(
                                                    onTap: () async {
                                                      if (productController
                                                              .handPickedProductList[
                                                          index]["wishlisted"]) {
                                                        productController
                                                                    .handPickedProductList[
                                                                index][
                                                            "wishlisted"] = false;
                                                        setState(() {});
                                                        productController.callAddProductToWishlist(
                                                            productController
                                                                        .handPickedProductList[
                                                                    index]
                                                                ["wishlist_id"],
                                                            "handpicked",
                                                            productController
                                                                    .handPickedProductList[
                                                                index]["id"],
                                                            0,
                                                            0,
                                                            [],
                                                            [],
                                                            0,
                                                            productController
                                                                .categoryFilter
                                                                .value,
                                                            0);
                                                      } else {
                                                        scaffoldKey.currentState
                                                            ?.showBottomSheet((context) =>
                                                                BottomWishlist(
                                                                    controller:
                                                                        wishlistController,
                                                                    onPressed:
                                                                        (p0) {
                                                                      productController.handPickedProductList[index]
                                                                              [
                                                                              "wishlisted"] =
                                                                          true;
                                                                      setState(
                                                                          () {});
                                                                      productController.callAddProductToWishlist(
                                                                          p0,
                                                                          "handpicked",
                                                                          productController.handPickedProductList[index]
                                                                              [
                                                                              "id"],
                                                                          0,
                                                                          0,
                                                                          [],
                                                                          [],
                                                                          0,
                                                                          productController
                                                                              .categoryFilter
                                                                              .value,
                                                                          0);
                                                                    },
                                                                    wishlistList:
                                                                        wishlistController
                                                                            .wishlistList));
                                                      }
                                                      await analytics.logEvent(
                                                        name:
                                                            'category_product_wishlist',
                                                        parameters: <String,
                                                            Object>{
                                                          'page_name':
                                                              'category_product_wishlist',
                                                        },
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16.sp,
                                                              vertical: 10.sp),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: InkWell(
                                                          child: SizedBox(
                                                            height: 24.sp,
                                                            width: 24.sp,
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  whiteColor,
                                                              child: productController
                                                                              .handPickedProductList[
                                                                          index]
                                                                      [
                                                                      "wishlisted"]
                                                                  ? Image.asset(
                                                                      wishlistSelectImage,
                                                                      height:
                                                                          18,
                                                                      width: 18,
                                                                    )
                                                                  : Image.asset(
                                                                      heartImage,
                                                                      height:
                                                                          18.sp,
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
                                                    bottom: 10.sp,
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
                                                            child: Image.asset(
                                                              starImage,
                                                              height: 16.sp,
                                                              color:
                                                                  bottomnavBack,
                                                              width: 16.sp,
                                                            ),
                                                          ),
                                                          AppText(
                                                            text: productController
                                                                            .handPickedProductList[index]
                                                                        [
                                                                        "aggregated_rating"] !=
                                                                    null
                                                                ? productController
                                                                    .handPickedProductList[
                                                                        index][
                                                                        "aggregated_rating"]
                                                                    .toString()
                                                                : "0",
                                                            color: colorPrimary,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10.sp),
                                                            child: Container(
                                                              width: 1,
                                                              color:
                                                                  textHintColor,
                                                              height: 16.sp,
                                                            ),
                                                          ),
                                                          AppText(
                                                            text: productController
                                                                .handPickedProductList[
                                                                    index][
                                                                    "reviews_count"]
                                                                .toString(),
                                                            color: colorPrimary,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                */
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.sp,
                                                    vertical: 5.sp),
                                                child: AppText(
                                                  text:
                                                      "${productController.handPickedProductList[index]["brand_name"]}"
                                                          .toUpperCase(),
                                                  color: blackColor,
                                                  maxLines: 1,
                                                  fontSize: 13,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.sp),
                                                child: AppText(
                                                  text: productController
                                                              .handPickedProductList[
                                                          index]["name"] ??
                                                      "",
                                                  color: Color(0xFF6B7280),
                                                  maxLines: 1,
                                                  fontSize: 11,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 8.sp,
                                                    left: 10.sp,
                                                    right: 1.sp),
                                                child: Row(
                                                  children: [
                                                    Visibility(
                                                      visible: productController
                                                                      .handPickedProductList[
                                                                  index]["mrp"] !=
                                                              null
                                                          ? true
                                                          : false,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 5.sp),
                                                        child: Text(
                                                          "\u{20B9} ${productController.handPickedProductList[index]["mrp"] ?? ""}",
                                                          style: TextStyle(
                                                            color:
                                                                searchTextColor,
                                                            fontSize: 11.sp,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    AppText(
                                                      text:
                                                          "\u{20B9} ${productController.handPickedProductList[index]["price"] ?? ""}",
                                                      color: homeAppBarColor,
                                                      maxLines: 2,
                                                      fontSize: 11,
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              productController
                                                          .handPickedProductList[
                                                      index]["express_delivery"]
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 3.sp,
                                                          left: 10.sp,
                                                          right: 10.sp),
                                                      child: Row(
                                                        children: [
                                                          ImageIcon(
                                                            AssetImage(
                                                                truckImage),
                                                            color: expressText,
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
                                productController.handpickedLoadMore.value
                                    ? DummyGridList()
                                    : const SizedBox(
                                        height: 0,
                                      ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 0.sp),
                                child: Center(
                                  child: Image.asset(errorImage,
                                      height: 200.sp,
                                      width: 220.sp,
                                      fit: BoxFit.cover),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20.sp),
                                child: getSingleButton(
                                    width: double.infinity,
                                    label: "Back to home".toUpperCase(),
                                    textColor: whiteColor,
                                    fontSize: 13,
                                    backgroundColor: homeAppBarColor,
                                    onPressed: () {
                                      Get.off(BottomNavScreen());
                                    },
                                    borderColor: colorPrimary),
                              )
                            ],
                          ),
                        ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
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
                              productController.productSortBy.value = p0;
                              productController.getHomeExploreProduct(
                                  productController.productSortBy.value,
                                  productController.filterProductEnable.value,
                                  false,
                                  productController.tagId.value);
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.sp, horizontal: 5.sp),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              sortBySvgImage,
                              height: 19.sp,
                              width: 15.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.sp),
                              child: Text(
                                "SORT BY",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF374151),
                                  decoration: TextDecoration.none,
                                  fontSize: 13.sp,
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0.sp),
                    child: Container(
                      width: 1.sp,
                      color: borderColor,
                      height: 40.sp,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        constraints: BoxConstraints(
                          maxWidth: double.infinity,
                          maxHeight: 270.sp,
                        ),
                        builder: (ctx) {
                          return BottomCategory(
                            gender: widget.genderName,
                            onPressedButton: (p0) {
                              if (p0 == "Women") {
                                productController.categoryFilter.value = 3;
                              } else if (p0 == "Men") {
                                productController.categoryFilter.value = 2;
                              } else {
                                productController.categoryFilter.value = 1;
                              }
                              productController.getHomeExploreProduct(
                                  productController.productSortBy.value,
                                  productController.filterProductEnable.value,
                                  false,
                                  productController.tagId.value);
                            },
                            onPressedFilter: () {
                              Get.back();
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
                                      productController.productSortBy.value =
                                          "";
                                      productController
                                          .filterProductEnable.value = false;
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.remove("brandList");
                                      prefs.remove("colorList");
                                      prefs.remove("sizeList");
                                      prefs.remove("upper");
                                      prefs.remove("lower");
                                      prefs.remove("sortby");
                                      prefs.remove("category");
                                      productController.getHomeExploreProduct(
                                          productController.productSortBy.value,
                                          productController
                                              .filterProductEnable.value,
                                          false,
                                          productController.tagId.value);
                                    },
                                    onClick: (p0, p1) {
                                      productController
                                          .filterProductEnable.value = true;
                                      productController.lowPrice.value = p0;
                                      productController.highPrice.value = p1;
                                      productController.getHomeExploreProduct(
                                          productController.productSortBy.value,
                                          productController
                                              .filterProductEnable.value,
                                          true,
                                          productController.tagId.value);
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.sp, horizontal: 5.sp),
                        child: Column(
                          children: [
                            /*  Image.asset(
                              categoryIcon,
                              height: 20.sp,
                              width: 20.sp,
                            ), */
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.sp),
                              child: Text(
                                "CATEGORY",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF374151),
                                  decoration: TextDecoration.none,
                                  fontSize: 13.sp,
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: widget.genderName == "" ? false : true,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 5.sp, right: 5.sp, top: 1.sp),
                                child: Text(
                                  widget.genderName.toUpperCase(),
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: appBarColor,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0.sp),
                    child: Container(
                      width: 1.sp,
                      color: borderColor,
                      height: 40.sp,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
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
                              productController.productSortBy.value = "";
                              productController.filterProductEnable.value =
                                  false;
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.remove("brandList");
                              prefs.remove("colorList");
                              prefs.remove("sizeList");
                              prefs.remove("upper");
                              prefs.remove("lower");
                              prefs.remove("sortby");
                              prefs.remove("category");
                              productController.getHomeExploreProduct(
                                  productController.productSortBy.value,
                                  productController.filterProductEnable.value,
                                  false,
                                  productController.tagId.value);
                            },
                            onClick: (p0, p1) {
                              productController.filterProductEnable.value =
                                  true;
                              productController.lowPrice.value = p0;
                              productController.highPrice.value = p1;
                              productController.getHomeExploreProduct(
                                  productController.productSortBy.value,
                                  productController.filterProductEnable.value,
                                  true,
                                  productController.tagId.value);
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.sp, horizontal: 5.sp),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              filterSvgImage,
                              height: 11.sp,
                              width: 17.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.sp),
                              child: Text(
                                "FILTERS",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF374151),
                                  decoration: TextDecoration.none,
                                  fontSize: 13.sp,
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
