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
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import '../../../commonwidget/app_text.dart';
import '../../../commonwidget/catalogwidgets/bottomwishlist.dart';
import '../../../controller/product_controller.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../utils/constants.dart';
import '../../commonwidget/common_widgets.dart';
import '../../commonwidget/homewidget/dummy_grid_list.dart';

class CategoryProductScreen extends StatefulWidget {
  final String categoryName;
  final int categoryId;
  final int brandId;
  final int genderType;
  final List tagIds;
  final List categoryList;
  const CategoryProductScreen(
      {super.key,
      required this.categoryName,
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
  final controller = Get.put(CartController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    productController.productCategoryList.clear();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.categoryProductHasnextpage.value = true;
      productController.categoryProductLoadMore.value = false;
      productController.categoryProductPage.value = 1;
      productController.isCategoryProduct.value = false;
      productController.bannerTagHasnextpage.value = true;
      productController.bannerTagLoadMore.value = false;
      productController.bannerTagPage.value = 1;
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getCartData());
    if (widget.categoryId != 0) {
      productController.category_id.value = widget.categoryId;
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          productController.getProductByCategoryData(
              widget.categoryId,
              widget.brandId,
              "",
              [],
              "",
              widget.genderType,
              false,
              0,
              false,
              ""));
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        productController.brandProductController.addListener(() {
          productController.fetchCategoryProductMoreData(
              widget.brandId, "", widget.genderType, false, "");
          productController.update();
        });
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          productController.getTagsBannerData(
              widget.tagIds, widget.categoryList, widget.genderType));
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        productController.bannerTagController.addListener(() {
          productController.fetchMoreBannerTagProductData(
              productController.productTags,
              productController.productCategory,
              widget.genderType);
          productController.update();
        });
      });
    }
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
            ProductAppbar(onPressedSearch: () async {
              Get.to(const SearchScreen());
              analytics
                  .logEvent(name: "search_page", parameters: <String, Object>{
                "page_name": "search_page",
              });
            }, onPressedCart: () async {
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
            Padding(
              padding: EdgeInsets.only(left: 16.sp, top: 16.sp),
              child: AppText(
                text: widget.categoryName.toUpperCase(),
                color: Color(0xFF4B5563),
                fontSize: 16,
                fontFamily: "Franklin Gothic",
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w500,
              ),
            ),
            Obx(() => Padding(
                  padding: EdgeInsets.only(left: 16.sp, top: 5.sp),
                  child: productController.isCategoryProduct.value
                      ? const DummyContainer(
                          height: 10,
                          width: 60,
                        )
                      : AppText(
                          text: productController.productCategoryList.length ==
                                  1
                              ? "${productController.productCategoryList.length.toString()} item"
                              : "${productController.productCategoryList.length.toString()} items",
                          color: Color(0xFF4B5563),
                          fontSize: 10,
                          fontFamily: "Franklin Gothic Regular",
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w500,
                        ),
                )),
            Obx(
              () => productController.isCategoryProduct.value
                  ? Expanded(
                      child: const DummyGridList(
                        size: 2,
                      ),
                    )
                  : productController.productCategoryList.isNotEmpty
                      ? Expanded(
                          child: SingleChildScrollView(
                            controller: widget.categoryId != 0
                                ? productController.brandProductController
                                : productController.bannerTagController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.sp, vertical: 20.sp),
                                  child: GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: 2,
                                    controller: widget.categoryId != 0
                                        ? productController
                                            .brandProductController
                                        : productController.bannerTagController,
                                    scrollDirection: Axis.vertical,
                                    padding: EdgeInsets.zero,
                                    childAspectRatio: 0.57,
                                    physics: const ScrollPhysics(),
                                    crossAxisSpacing: 5.sp,
                                    mainAxisSpacing: 8.sp,
                                    children: List.generate(
                                      productController
                                          .productCategoryList.length,
                                      (index) {
                                        return GestureDetector(
                                          onTap: () async {
                                            Get.to(ProductDetailsScreen(
                                                    brandName: productController
                                                            .productCategoryList[
                                                        index]["brand_name"],
                                                    productId: productController
                                                            .productCategoryList[
                                                        index]["id"],
                                                    type: "add"))
                                                ?.then((value) => setState(
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
                                                        /*  productController
                                                            .categoryProductPage
                                                            .value = 1; */
                                                        productController
                                                            .bannerTagHasnextpage
                                                            .value = true;
                                                        productController
                                                            .bannerTagLoadMore
                                                            .value = false;
                                                        /*  productController
                                                            .bannerTagPage
                                                            .value = 1; */
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
                                                              "category product",
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
                                                                            "category product",
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
                                                              productController
                                                                  .productTags,
                                                              productController
                                                                  .productCategory,
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
                                                                            "bannerTag",
                                                                            productController.productCategoryList[index]["id"],
                                                                            widget.categoryId,
                                                                            0,
                                                                            productController.productTags,
                                                                            productController.productCategory,
                                                                            0,
                                                                            widget.genderType,
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
                                                          index]["brand_name"] ??
                                                      "",
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
                                                                  .productCategoryList[
                                                              index][
                                                          "short_description"] ??
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
                                                    top: 10.sp,
                                                    left: 10.sp,
                                                    right: 1.sp),
                                                child: Row(
                                                  children: [
                                                    Text(
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
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 5.sp),
                                                      child: AppText(
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
                                productController
                                            .categoryProductLoadMore.value ||
                                        productController
                                            .bannerTagLoadMore.value
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
