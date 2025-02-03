// ignore_for_file: avoid_print, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomcategory.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomfiltters.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomsortby.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_grid_black.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../commonwidget/app_text.dart';
import '../../../controller/product_controller.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../utils/constants.dart';

class BrandViewProductScreen extends StatefulWidget {
  final String title;
  final String genderName;

  const BrandViewProductScreen({
    super.key,
    required this.title,
    required this.genderName,
  });

  @override
  State<BrandViewProductScreen> createState() => BrandViewProductScreenState();
}

class BrandViewProductScreenState extends State<BrandViewProductScreen> {
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
        productController.getHandPickedProduct(
            productController.productSortBy.value,
            productController.filterProductEnable.value,
            false,
            productController.tagId.value));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getCartData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.handpickedController.addListener(() {
        productController.fetchMoreHandPickedProduct(
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
        backgroundColor: homeAppBarColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 2.sp, top: 30.sp),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(arrowBack,
                        color: whiteColor,
                        height: 15.sp,
                        width: 15.sp,
                        fit: BoxFit.cover),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  AppText(
                    text: widget.title,
                    color: whiteColor,
                    fontSize: 16,
                    fontFamily: "Franklin Gothic Semibold",
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 16.sp, top: 35.sp, right: 16.sp, bottom: 30.sp),
              child: Container(
                color: loginText,
                // height: 50.sp,
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (value) {
                    print(value);
                    if (value is RawKeyDownEvent) {}
                  },
                  child: TextField(
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                        color: colorSecondary,
                        fontFamily: "Franklin Gothic Regular",
                        fontSize: 14.sp),
                    //   controller: brandController.searchController,
                    //   onChanged: onSearchChanged,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      filled: true,
                      isDense: true,
                      fillColor: homeAppBarColor,
                      prefixIcon: IconButton(
                        icon: SvgPicture.asset(searchSvgImage,
                            color: searchTextColor,
                            height: 17.sp,
                            width: 17.sp,
                            fit: BoxFit.cover),
                        onPressed: () {},
                      ),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: searchTextColor)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.sp),
                        borderSide: const BorderSide(color: searchTextColor),
                      ),
                      counterText: "",
                      hintText: "Search for 'Kurta'",
                      hintStyle:
                          TextStyle(fontSize: 14.sp, color: searchTextColor),
                    ),
                  ),
                ),
              ),
            ),
            Obx(
              () => productController.isHandPicked.value
                  ? Expanded(
                      child: const DummyGridBlack(
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
                                    horizontal: 16.sp,
                                  ),
                                  child: GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: 2,
                                    controller:
                                        productController.handpickedController,
                                    scrollDirection: Axis.vertical,
                                    padding: EdgeInsets.zero,
                                    childAspectRatio: 0.6,
                                    physics: const ScrollPhysics(),
                                    crossAxisSpacing: 12.sp,
                                    mainAxisSpacing: 0.sp,
                                    children: List.generate(
                                      productController
                                          .handPickedProductList.length,
                                      (index) {
                                        return GestureDetector(
                                          onTap: () async {
                                            Get.to(ProductDetailsScreen(
                                                    backgroundcolor:
                                                        homeAppBarColor,
                                                    brandName: productController
                                                            .handPickedProductList[
                                                        index]["name"],
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
                                                                        .handPickedProductList[index]
                                                                    [
                                                                    "images"] !=
                                                                null
                                                        ? ClipRRect(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        8.sp),
                                                                topRight: Radius
                                                                    .circular(
                                                                        8.sp)),
                                                            child: SizedBox(
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
                                                                imageUrl: isImage(productController.handPickedProductList[index]
                                                                            ["images"][0]
                                                                        [
                                                                        "name"])
                                                                    ? productController.handPickedProductList[index]
                                                                            ["images"][0]
                                                                        ["name"]
                                                                    : productController.handPickedProductList[index]
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
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 8.sp),
                                                child: AppText(
                                                  text:
                                                      "${productController.handPickedProductList[index]["name"]}",
                                                  color: productSubtitleColor,
                                                  maxLines: 1,
                                                  fontSize: 11,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: 8.sp,
                                                ),
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
                                                                right: 6.sp),
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
                                                      color: whiteColor,
                                                      maxLines: 2,
                                                      fontSize: 11,
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                productController.handpickedLoadMore.value
                                    ? DummyGridBlack()
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
                                    label: "Back to Quick".toUpperCase(),
                                    textColor: whiteColor,
                                    fontSize: 13,
                                    backgroundColor: homeAppBarColor,
                                    onPressed: () {
                                      Get.back();
                                    },
                                    borderColor: whiteColor),
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
                          maxHeight: 360.sp,
                        ),
                        builder: (ctx) {
                          return BottomSortBy(
                            backgroundColor: homeAppBarColor,
                            onPressedButton: (p0) {
                              productController.productSortBy.value = p0;
                              productController.getHandPickedProduct(
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
                            Image.asset(
                              sortbyIcon,
                              color: whiteColor,
                              height: 20.sp,
                              width: 20.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.sp),
                              child: Text(
                                "SORT BY",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: whiteColor,
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
                            backgroundColor: homeAppBarColor,
                            gender: widget.genderName,
                            onPressedButton: (p0) {
                              if (p0 == "Women") {
                                productController.categoryFilter.value = 3;
                              } else if (p0 == "Men") {
                                productController.categoryFilter.value = 2;
                              } else {
                                productController.categoryFilter.value = 1;
                              }
                              productController.getHandPickedProduct(
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
                                    backgroundColor: homeAppBarColor,
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
                                      productController.getHandPickedProduct(
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
                                      productController.getHandPickedProduct(
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
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.sp),
                              child: Text(
                                "CATEGORY",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: whiteColor,
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
                                    color: whiteColor,
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
                            backgroundColor: homeAppBarColor,
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
                              productController.getHandPickedProduct(
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
                              productController.getHandPickedProduct(
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
                            Image.asset(
                              filterIcon,
                              color: whiteColor,
                              height: 20.sp,
                              width: 20.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.sp),
                              child: Text(
                                "FILTERS",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: whiteColor,
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
