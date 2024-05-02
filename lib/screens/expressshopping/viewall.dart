// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/catalogwidgets/bottomfiltters.dart';
import '../../commonwidget/catalogwidgets/bottomsortby.dart';
import '../../commonwidget/catalogwidgets/bottomwishlist.dart';
import '../../commonwidget/doublebtn.dart';
import '../../controller/product_controller.dart';
import '../../controller/wishlist_controller.dart';
import '../../utils/constants.dart';
import '../catalog/productlist/productdetailsscreen.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});

  @override
  State<ViewAllScreen> createState() => ViewAllScreenState();
}

class ViewAllScreenState extends State<ViewAllScreen> {
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.listController.addListener(() {
        productController.fetchMoreData("express");
        productController.update();
      });
    });
    productController.hasnextpage.value = true;
    productController.loadMore.value = false;
    productController.isProduct.value = false;
    productController.page.value = 1;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("express"));
    wishlistController.getWishlistData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: whiteTextColor,
        body: Obx(() => productController.isProduct.value
            ? const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator()),
              )
            : productController.productList.isNotEmpty
                ? Stack(
                    children: [
                      Positioned.fill(
                        child: SingleChildScrollView(
                          controller: productController.listController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 10, bottom: 90),
                                child: GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  controller: productController.listController,
                                  scrollDirection: Axis.vertical,
                                  padding: EdgeInsets.zero,
                                  childAspectRatio: 0.5,
                                  physics: const ScrollPhysics(),
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 0,
                                  children: List.generate(
                                    productController.productList.length,
                                    (index) {
                                      return Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(() => ProductDetailsScreen(
                                                    productId: productController
                                                            .productList[index]
                                                        ["id"],
                                                  ));
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Stack(
                                                  children: [
                                                    Center(
                                                      child: productController
                                                                  .productList[
                                                                      index]
                                                                      ["images"]
                                                                  .isNotEmpty &&
                                                              productController
                                                                              .productList[
                                                                          index]
                                                                      [
                                                                      "images"] !=
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
                                                                fit: BoxFit
                                                                    .cover,
                                                                imageUrl: productController
                                                                            .productList[index]
                                                                        [
                                                                        "images"]
                                                                    [0]["name"],
                                                                progressIndicatorBuilder:
                                                                    (context,
                                                                            url,
                                                                            downloadProgress) =>
                                                                        Center(
                                                                  child: CircularProgressIndicator(
                                                                      value: downloadProgress
                                                                          .progress),
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Image.asset(
                                                                  dummyWishlistImage,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  height: 190,
                                                                  width: 152,
                                                                ),
                                                              ),
                                                            )
                                                          : Image.asset(
                                                              dummyWishlistImage,
                                                              height: 190,
                                                              width: 152,
                                                              fit:
                                                                  BoxFit.cover),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (productController
                                                                    .productList[
                                                                index]
                                                            ["wishlisted"]) {
                                                          productController
                                                              .callAddProductToWishlist(
                                                            productController
                                                                        .productList[
                                                                    index]
                                                                ["wishlist_id"],
                                                            "product",
                                                            productController
                                                                    .productList[
                                                                index]["id"],
                                                          );
                                                        } else {
                                                          scaffoldKey
                                                              .currentState
                                                              ?.showBottomSheet((context) =>
                                                                  BottomWishlist(
                                                                      controller:
                                                                          wishlistController,
                                                                      onPressed:
                                                                          (p0) {
                                                                        productController
                                                                            .callAddProductToWishlist(
                                                                          p0,
                                                                          "product",
                                                                          productController.productList[index]
                                                                              [
                                                                              "id"],
                                                                        );
                                                                      },
                                                                      wishlistList:
                                                                          wishlistController
                                                                              .wishlistList));
                                                        }
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 22,
                                                                vertical: 10),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: InkWell(
                                                            child: SizedBox(
                                                              height: 24,
                                                              width: 24,
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    whiteColor,
                                                                child: productController
                                                                            .productList[index]
                                                                        [
                                                                        "wishlisted"]
                                                                    ? Image
                                                                        .asset(
                                                                        wishlistSelectImage,
                                                                        height:
                                                                            16,
                                                                        color:
                                                                            bottomnavBack,
                                                                        width:
                                                                            16,
                                                                      )
                                                                    : Image
                                                                        .asset(
                                                                        heartImage,
                                                                        height:
                                                                            16,
                                                                        color:
                                                                            bottomnavBack,
                                                                        width:
                                                                            16,
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
                                                          horizontal: 22,
                                                          vertical: 10),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
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
                                                                text: productController.productList[index]
                                                                            [
                                                                            "aggregated_rating"] !=
                                                                        null
                                                                    ? productController
                                                                        .productList[
                                                                            index]
                                                                            [
                                                                            "aggregated_rating"]
                                                                        .toString()
                                                                    : "aggregated_rating",
                                                                color:
                                                                    colorPrimary,
                                                                fontSize: 12.sp,
                                                                fontFamily:
                                                                    "Franklin Gothic Regular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10),
                                                                child:
                                                                    Container(
                                                                  width: 1,
                                                                  color:
                                                                      textHintColor,
                                                                  height: 16,
                                                                ),
                                                              ),
                                                              AppText(
                                                                text: "8",
                                                                color:
                                                                    colorPrimary,
                                                                fontSize: 12.sp,
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
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: AppText(
                                                    text: productController
                                                                .productList[
                                                            index]["name"] ??
                                                        "",
                                                    color: nameText,
                                                    maxLines: 1,
                                                    fontSize: 12.sp,
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: AppText(
                                                    text:
                                                        "${productController.productList[index]["short_description"]} \n"
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          left: 10,
                                                          right: 1),
                                                  child: Row(
                                                    children: [
                                                      AppText(
                                                        text:
                                                            "\u{20B9} ${productController.productList[index]["price"] ?? ""}",
                                                        color:
                                                            deepGreytextColor,
                                                        maxLines: 2,
                                                        fontSize: 11.sp,
                                                        fontFamily:
                                                            "Franklin Gothic",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 5),
                                                        child: Text(
                                                          "\u{20B9} ${productController.productList[index]["mrp"] ?? ""}",
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
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          left: 10,
                                                          right: 10),
                                                  child: Row(
                                                    children: [
                                                      const ImageIcon(
                                                        AssetImage(truckImage),
                                                        color: expressText,
                                                        size: 14,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
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
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              productController.loadMore.value
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.only(top: 10, bottom: 10),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    )
                                  : const SizedBox(
                                      height: 0,
                                    ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 30, top: 20, left: 4, right: 12),
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
                              scaffoldKey.currentState?.showBottomSheet(
                                  (context) => const BottomSortBy());
                            },
                            onPressedSecond: () {
                              Get.to(const BottomFilters());
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
                  )));
  }
}
