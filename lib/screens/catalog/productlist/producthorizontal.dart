// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_grid_list.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import '../../../commonwidget/app_text.dart';
import '../../../commonwidget/catalogwidgets/bottomfiltters.dart';
import '../../../commonwidget/catalogwidgets/bottomsortby.dart';
import '../../../commonwidget/catalogwidgets/bottomwishlist.dart';
import '../../../commonwidget/common_widgets.dart';
import '../../../commonwidget/doublebtn.dart';
import '../../../controller/product_controller.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../utils/constants.dart';

class ProductHorizontalScreen extends StatefulWidget {
  final int categoryId;
  final int genderType;
  const ProductHorizontalScreen(
      {super.key, required this.categoryId, required this.genderType});

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
            widget.categoryId, 0, "", [], "", widget.genderType, false));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.categoryProductController.addListener(() {
        productController.fetchCategoryProductMoreData(
            0, productController.sortBy.value, widget.genderType);
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
        body: Obx(
          () => productController.isCategoryProduct.value
              ? const DummyGridList()
              : productController.productCategoryList.isNotEmpty
                  ? Stack(
                      children: [
                        SingleChildScrollView(
                          controller:
                              productController.categoryProductController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 20, bottom: 60),
                                child: GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  controller: productController
                                      .categoryProductController,
                                  scrollDirection: Axis.vertical,
                                  padding: EdgeInsets.zero,
                                  childAspectRatio: 0.5,
                                  physics: const ScrollPhysics(),
                                  crossAxisSpacing: 5,
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
                                                          productId:
                                                              productController
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
                                                      productController
                                                          .getProductByCategoryData(
                                                              widget.categoryId,
                                                              0,
                                                              "",
                                                              [],
                                                              productController
                                                                  .sortBy.value,
                                                              widget.genderType,
                                                              productController
                                                                  .filterEnable
                                                                  .value);
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
                                                              .productCategoryList[
                                                                  index]
                                                                  ["images"]
                                                              .isNotEmpty &&
                                                          productController
                                                                          .productCategoryList[
                                                                      index]
                                                                  ["images"] !=
                                                              null
                                                      ? SizedBox(
                                                          height: 190,
                                                          width: 152,
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
                                                                        ["images"]
                                                                    [0]["name"])
                                                                ? productController
                                                                            .productCategoryList[index]
                                                                        ["images"]
                                                                    [0]["name"]
                                                                : productController
                                                                            .productCategoryList[index]
                                                                        ["images"]
                                                                    [1]["name"],
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Image.asset(
                                                              downloadImage,
                                                              fit: BoxFit.cover,
                                                              height: 190,
                                                              width: 152,
                                                            ),
                                                          ),
                                                        )
                                                      : Image.asset(
                                                          dummyWishlistImage,
                                                          height: 190,
                                                          width: 152,
                                                          fit: BoxFit.cover),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    if (productController
                                                            .productCategoryList[
                                                        index]["wishlisted"]) {
                                                      productController
                                                          .callAddProductToWishlist(
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
                                                              0,
                                                              widget
                                                                  .genderType);
                                                    } else {
                                                      scaffoldKey.currentState
                                                          ?.showBottomSheet((context) =>
                                                              BottomWishlist(
                                                                  controller:
                                                                      wishlistController,
                                                                  onPressed:
                                                                      (p0) {
                                                                    productController.callAddProductToWishlist(
                                                                        p0,
                                                                        "category",
                                                                        productController.productCategoryList[index]
                                                                            [
                                                                            "id"],
                                                                        widget
                                                                            .categoryId,
                                                                        0,
                                                                        [],
                                                                        0,
                                                                        widget
                                                                            .genderType);
                                                                  },
                                                                  wishlistList:
                                                                      wishlistController
                                                                          .wishlistList));
                                                    }
                                                    await analytics.logEvent(
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
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 10),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: InkWell(
                                                        child: SizedBox(
                                                          height: 24,
                                                          width: 24,
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                whiteColor,
                                                            child: productController
                                                                            .productCategoryList[
                                                                        index][
                                                                    "wishlisted"]
                                                                ? Image.asset(
                                                                    wishlistSelectImage,
                                                                    height: 18,
                                                                    width: 18,
                                                                  )
                                                                : Image.asset(
                                                                    heartImage,
                                                                    height: 24,
                                                                    width: 24,
                                                                  ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 10),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 140),
                                                      color: const Color(
                                                          0xB3F7F7F5),
                                                      height: 26,
                                                      width: 80,
                                                      child: Row(
                                                        children: [
                                                          Image.asset(
                                                            starImage,
                                                            height: 24,
                                                            color:
                                                                bottomnavBack,
                                                            width: 24,
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
                                                                : "",
                                                            color: colorPrimary,
                                                            fontSize: 12.sp,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            child: Container(
                                                              width: 1,
                                                              color:
                                                                  textHintColor,
                                                              height: 16,
                                                            ),
                                                          ),
                                                          AppText(
                                                            text: "8",
                                                            color: colorPrimary,
                                                            fontSize: 12.sp,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              child: AppText(
                                                text: productController
                                                            .productCategoryList[
                                                        index]["name"] ??
                                                    "",
                                                color: nameText,
                                                maxLines: 2,
                                                fontSize: 12.sp,
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: AppText(
                                                text: productController
                                                                .productCategoryList[
                                                            index]
                                                        ["short_description"] ??
                                                    "",
                                                color: nameText,
                                                maxLines: 2,
                                                fontSize: 11.sp,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, left: 10, right: 1),
                                              child: Row(
                                                children: [
                                                  AppText(
                                                    text:
                                                        "\u{20B9} ${productController.productCategoryList[index]["price"] ?? ""}",
                                                    color: deepGreytextColor,
                                                    maxLines: 2,
                                                    fontSize: 11.sp,
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5),
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
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, left: 10, right: 10),
                                              child: Row(
                                                children: [
                                                  const ImageIcon(
                                                    AssetImage(truckImage),
                                                    color: expressText,
                                                    size: 14,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5),
                                                    child: AppText(
                                                      text: "Express",
                                                      color: expressText,
                                                      maxLines: 2,
                                                      fontSize: 11.sp,
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              productController.categoryProductLoadMore.value
                                  ? const DummyGridList()
                                  : const SizedBox(
                                      height: 0,
                                    ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 16, top: 20, left: 4, right: 12),
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
                                scaffoldKey.currentState
                                    ?.showBottomSheet((context) => BottomSortBy(
                                          onPressedButton: (p0) {
                                            productController.sortBy.value = p0;
                                            productController
                                                .getProductByCategoryData(
                                                    widget.categoryId,
                                                    0,
                                                    "",
                                                    [],
                                                    p0,
                                                    widget.genderType,
                                                    productController
                                                        .filterEnable.value);
                                          },
                                        ));
                              },
                              onPressedSecond: () {
                                Get.to(BottomFilters(
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
                                        productController.filterEnable.value);
                                  },
                                ));
                              },
                            ),
                          ),
                        ),
                      ],
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
        ));
  }
}
