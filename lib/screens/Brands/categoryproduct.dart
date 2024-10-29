// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import '../../../commonwidget/app_text.dart';
import '../../../commonwidget/catalogwidgets/bottomwishlist.dart';
import '../../../controller/product_controller.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../utils/constants.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../commonwidget/common_widgets.dart';
import '../../commonwidget/homewidget/dummy_grid_list.dart';

class CategoryProductScreen extends StatefulWidget {
  final int categoryId;
  final int brandId;
  final int genderType;
  final List tagIds;
  final List categoryList;
  const CategoryProductScreen(
      {super.key,
      required this.categoryId,
      required this.brandId,
      required this.genderType,
      required this.tagIds,
      required this.categoryList});

  @override
  State<CategoryProductScreen> createState() => CategoryProductScreenState();
}

class CategoryProductScreenState extends State<CategoryProductScreen> {
  final productController = Get.find<ProductController>();
  final wishlistController = Get.put(WishlistController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    productController.productCategoryList.clear();
    wishlistController.getWishlistData();
    if (widget.categoryId != 0) {
      productController.category_id.value = widget.categoryId;
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          productController.getProductByCategoryData(widget.categoryId,
              widget.brandId, "", [], "", widget.genderType, false, 0, false));
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        productController.brandProductController.addListener(() {
          productController.fetchCategoryProductMoreData(
              widget.brandId, "", widget.genderType, false);
          productController.update();
        });
      });
      productController.categoryProductHasnextpage.value = true;
      productController.categoryProductLoadMore.value = false;
      productController.isCategoryProduct.value = false;
      productController.categoryProductPage.value = 1;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => productController
          .getTagsBannerData(widget.tagIds, widget.categoryList));
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        productController.bannerTagController.addListener(() {
          productController.fetchMoreBannerTagProductData(
              widget.tagIds, widget.categoryList);
          productController.update();
        });
      });
      productController.bannerTagHasnextpage.value = true;
      productController.bannerTagLoadMore.value = false;
      productController.isCategoryProduct.value = false;
      productController.bannerTagPage.value = 1;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: whiteColor,
        body: Column(
          children: [
            const BackButtonAppbar(
              text: "Product List",
              threeDot: false,
              backgroundColor: whiteColor,
              icon: threeDotImage,
            ),
            Obx(
              () => productController.isCategoryProduct.value
                  ? const DummyGridList(
                      size: 2,
                    )
                  : productController.productCategoryList.isNotEmpty
                      ? Expanded(
                          child: SingleChildScrollView(
                            controller:
                                productController.brandProductController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.sp, vertical: 20.sp),
                                  child: GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: 2,
                                    controller: productController
                                        .brandProductController,
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
                                            Get.to(ProductDetailsScreen(
                                                productId: productController
                                                        .productCategoryList[
                                                    index]["id"],
                                                type: "add"));
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
                                                                .productCategoryList[index]
                                                                    ["images"]
                                                                .isNotEmpty &&
                                                            productController
                                                                        .productCategoryList[index][
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
                                                                              .productCategoryList[index]
                                                                          ["images"][0]
                                                                      ["name"])
                                                                  ? productController
                                                                              .productCategoryList[index]
                                                                          ["images"]
                                                                      [
                                                                      0]["name"]
                                                                  : productController
                                                                              .productCategoryList[index]
                                                                          ["images"]
                                                                      [1]["name"],
                                                              /* progressIndicatorBuilder:
                                                                  (context, url,
                                                                          downloadProgress) =>
                                                                      Center(
                                                                child: CircularProgressIndicator(
                                                                    value: downloadProgress
                                                                        .progress),
                                                              ), */
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
                                                      if (widget.categoryId !=
                                                          0) {
                                                        if (productController
                                                                .productCategoryList[
                                                            index]["wishlisted"]) {
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
                                                              widget.brandId,
                                                              [],
                                                              [],
                                                              0,
                                                              widget.genderType,
                                                              0);
                                                        } else {
                                                          scaffoldKey
                                                              .currentState
                                                              ?.showBottomSheet((context) =>
                                                                  BottomWishlist(
                                                                      controller:
                                                                          wishlistController,
                                                                      onPressed:
                                                                          (p0) {
                                                                        productController.callAddProductToWishlist(
                                                                            p0,
                                                                            "category",
                                                                            productController.productCategoryList[index]["id"],
                                                                            widget.categoryId,
                                                                            widget.brandId,
                                                                            [],
                                                                            [],
                                                                            0,
                                                                            widget.genderType,
                                                                            0);
                                                                      },
                                                                      wishlistList:
                                                                          wishlistController
                                                                              .wishlistList));
                                                        }
                                                      } else {
                                                        if (productController
                                                                .productCategoryList[
                                                            index]["wishlisted"]) {
                                                          productController.callAddProductToWishlist(
                                                              productController
                                                                          .productCategoryList[
                                                                      index][
                                                                  "wishlist_id"],
                                                              "bannerTag",
                                                              productController
                                                                      .productCategoryList[
                                                                  index]["id"],
                                                              widget.categoryId,
                                                              widget.brandId,
                                                              widget.tagIds,
                                                              widget
                                                                  .categoryList,
                                                              0,
                                                              0,
                                                              0);
                                                        } else {
                                                          scaffoldKey
                                                              .currentState
                                                              ?.showBottomSheet((context) =>
                                                                  BottomWishlist(
                                                                      controller:
                                                                          wishlistController,
                                                                      onPressed:
                                                                          (p0) {
                                                                        productController.callAddProductToWishlist(
                                                                            p0,
                                                                            "bannerTag",
                                                                            productController.productCategoryList[index]["id"],
                                                                            widget.categoryId,
                                                                            0,
                                                                            widget.tagIds,
                                                                            widget.categoryList,
                                                                            0,
                                                                            0,
                                                                            0);
                                                                      },
                                                                      wishlistList:
                                                                          wishlistController
                                                                              .wishlistList));
                                                        }
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
                                                                              .productCategoryList[
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
                                                                            .productCategoryList[index]
                                                                        [
                                                                        "aggregated_rating"] !=
                                                                    null
                                                                ? productController
                                                                    .productCategoryList[
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
                                                                .productCategoryList[
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
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.sp),
                                                child: AppText(
                                                  text: productController
                                                                  .productCategoryList[
                                                              index][
                                                          "short_description"] ??
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
                                                      color: deepGreytextColor,
                                                      maxLines: 2,
                                                      fontSize: 11,
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 5.sp),
                                                      child: Text(
                                                        "\u{20B9} ${productController.productCategoryList[index]["mrp"] ?? ""}",
                                                        style: TextStyle(
                                                          color: textHintColor,
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
                                                  ],
                                                ),
                                              ),
                                              productController
                                                          .productCategoryList[
                                                      index]["express_delivery"]
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 5.sp,
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
                                productController.categoryProductLoadMore.value
                                    ? DummyGridList()
                                    : const SizedBox(
                                        height: 0,
                                      ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height - 100,
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
          ],
        ));
  }
}
