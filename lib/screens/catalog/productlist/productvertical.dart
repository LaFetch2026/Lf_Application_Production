// ignore_for_file: avoid_print
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../../common/widget/bottom_sheets/bottomfiltters.dart';
import '../../../common/widget/bottom_sheets/bottomsortby.dart';
import '../../../common/widget/bottom_sheets/bottomwishlist.dart';
import '../../../common/widget/button/doublebtn.dart';
import '../../../common/widget/lists/dummy_vertical_list.dart';
import '../../../common/widget/other/productvedio.dart';
import '../../../common/widget/other/pounce_wrapper.dart';
import '../../../common/widget/other/product_price_display.dart';
import '../../../common/widget/text/app_text.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constant/constants.dart';

class ProductVerticalScreen extends StatefulWidget {
  final int categoryId;
  final int genderType;
  final int catalogId;

  const ProductVerticalScreen(
      {super.key,
      required this.categoryId,
      required this.genderType,
      required this.catalogId});

  @override
  State<ProductVerticalScreen> createState() => ProductVerticalScreenState();
}

class ProductVerticalScreenState extends State<ProductVerticalScreen> {
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late VideoPlayerController videoController;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  //late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    productController.curr.value = 0;
    //  productController.sortBy.value = "";
    productController.productCategoryList.clear();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.categoryProductHasnextpage.value = true;
      productController.categoryProductLoadMore.value = false;
      productController.isCategoryProduct.value = false;
      productController.categoryProductPage.value = 1;
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.categoryProductController.addListener(() {
        productController.update();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    productController.isVideoPlaying.value = true;
    videoController.dispose();
    super.dispose();
  }

  bool isImage(String path) {
    print(path);
    return path.contains('product_photo');
  }

  List<Widget> getListForPageView(int index) {
    List<Widget> list = [];
    if (productController.productCategoryList[index]["images"].isNotEmpty) {
      for (var i = 0;
          i < productController.productCategoryList[index]["images"].length;
          i++) {
        if (isImage(productController.productCategoryList[index]["images"][i]
            ["name"])) {
          list.add(Container(
            color: colorSecondary,
            child: CachedNetworkImage(
              cacheManager: CacheManager(Config("customCacheKey",
                  stalePeriod: const Duration(days: 15),
                  maxNrOfCacheObjects: 100)),
              fit: BoxFit.fill,
              imageUrl: productController.productCategoryList[index]["images"]
                  [i]["name"],
              errorWidget: (context, url, error) => Image.asset(
                downloadImage,
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ));
        } else {
          //  productController.isVideoPlaying.productController = true;
          videoController = VideoPlayerController.networkUrl(
            Uri.parse(
              productController.productCategoryList[index]["images"][i]["name"],
            ),
          );

          //  _initializeVideoPlayerFuture = videoController.initialize();
          //  videoController.setLooping(true);

          /*   list.add(
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Obx(() => Stack(
                        fit: StackFit.expand,
                        children: [
                          AspectRatio(
                            aspectRatio: videoController.productController.aspectRatio,
                            child: VideoPlayer(videoController),
                          ),
                          IconButton(
                            icon: CircleAvatar(
                              backgroundColor: blue,
                              child: Icon(
                                !productController.isVideoPlaying.productController
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                            ),
                            onPressed: () {
                              if (videoController.productController.isPlaying) {
                                videoController.pause();
                                productController.isVideoPlaying.productController = true;
                              } else {
                                productController.isVideoPlaying.productController = false;
                                videoController.play();
                              }
                            },
                          ),
                        ],
                      ));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          );
          */

          list.add(ProductVideo(
            videoController: videoController,
          ));
        }
      }
    } else {
      list.add(Image.asset(
        dummyWishlistImage,
        fit: BoxFit.fill,
        width: double.infinity,
        height: double.infinity,
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
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
          Get.back();
        }
      },
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: whiteColor,
          body: GetX<ProductController>(builder: (controller) {
            return productController.isCategoryProduct.value
                ? const DummyVerticalList()
                : Stack(
                    children: [
                      Positioned.fill(
                        child: productController.productCategoryList.isNotEmpty
                            ? SingleChildScrollView(
                                /*   controller:
                                    productController.categoryProductController, */
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10.sp,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 16.sp,
                                          right: 16.sp,
                                          bottom: 100.sp),
                                      child: GetBuilder<ProductController>(
                                        builder: (value) => ListView.builder(
                                          primary: false,
                                          shrinkWrap: true,
                                          controller: productController
                                              .categoryProductController,
                                          padding: EdgeInsets.zero,
                                          physics: const ScrollPhysics(),
                                          itemCount: productController
                                              .productCategoryList.length,
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (ctx, index) {
                                            return PounceWrapper(
                                              onTap: () async {
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            ProductDetailsScreenV2(
                                                                brandName: productController
                                                                            .productCategoryList[
                                                                        index][
                                                                    "brand_name"],
                                                                productId:
                                                                    productController
                                                                            .productCategoryList[index]
                                                                        ["id"],
                                                                type: "add")))
                                                    .then((productController) =>
                                                        setState(
                                                          () {
                                                            productController
                                                                .categoryProductHasnextpage
                                                                .productController = true;
                                                            productController
                                                                .categoryProductLoadMore
                                                                .productController = false;
                                                            productController
                                                                .isCategoryProduct
                                                                .productController = false;
                                                            productController
                                                                .categoryProductPage
                                                                .productController = 1;
                                                            /*  productController
                                                              .getProductByCategoryData(
                                                                  widget.categoryId,
                                                                  0,
                                                                  widget
                                                                      .genderType); */
                                                            productController.getProductByCategoryData(
                                                                widget
                                                                    .categoryId,
                                                                0,
                                                                "",
                                                                [],
                                                                productController
                                                                    .soryBy
                                                                    .value,
                                                                widget
                                                                    .genderType,
                                                                productController
                                                                    .filterEnable
                                                                    .value);
                                                          },
                                                        ));
                                                await analytics.logEvent(
                                                  name:
                                                      'catalog_product_linear_details',
                                                  parameters: <String, Object>{
                                                    'page_name':
                                                        'catalog_product_linear_details',
                                                  },
                                                );
                                              },
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      productController.productCategoryList[
                                                                      index]
                                                                  ["images"] !=
                                                              null
                                                          ? Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 16
                                                                          .sp),
                                                              child: SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width +
                                                                    40.sp,
                                                                width: double
                                                                    .infinity,
                                                                child: PageView(
                                                                    allowImplicitScrolling:
                                                                        true,
                                                                    scrollDirection:
                                                                        Axis
                                                                            .horizontal,
                                                                    onPageChanged:
                                                                        (number) {
                                                                      productController
                                                                          .curr
                                                                          .value = number;
                                                                      productController
                                                                          .index
                                                                          .value = index;
                                                                      productController
                                                                          .isVideoPlaying
                                                                          .value = true;
                                                                      productController
                                                                          .update();
                                                                    },
                                                                    children:
                                                                        getListForPageView(
                                                                            index)),
                                                              ))
                                                          : Image.asset(
                                                              dummyWishlistImage,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width +
                                                                  40.sp,
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit.fill),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          if (productController
                                                                      .productCategoryList[
                                                                  index]
                                                              ["wishlisted"]) {
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
                                                                        index]
                                                                    ["id"],
                                                                widget
                                                                    .categoryId,
                                                                0,
                                                                [],
                                                                [],
                                                                0,
                                                                widget
                                                                    .genderType,
                                                                widget
                                                                    .catalogId);
                                                          } else {
                                                            scaffoldKey.currentState?.showBottomSheet((context) =>
                                                                BottomWishlist(
                                                                    controller:
                                                                        wishlistController,
                                                                    onPressed:
                                                                        (p0) {
                                                                      productController.productCategoryList[index]
                                                                              [
                                                                              "wishlisted"] =
                                                                          true;
                                                                      setState(
                                                                          () {});
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
                                                                          [],
                                                                          0,
                                                                          widget
                                                                              .genderType,
                                                                          widget
                                                                              .catalogId);
                                                                    },
                                                                    wishlistList:
                                                                        wishlistController
                                                                            .wishlistList));
                                                          }
                                                          await analytics
                                                              .logEvent(
                                                            name:
                                                                'catalog_product_linear_wishlist',
                                                            parameters: <String,
                                                                Object>{
                                                              'page_name':
                                                                  'catalog_product_linear_wishlist',
                                                            },
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      20.sp,
                                                                  vertical:
                                                                      30.sp),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: InkWell(
                                                              child: SizedBox(
                                                                height: 30.sp,
                                                                width: 30.sp,
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
                                                                              22.sp,
                                                                          width:
                                                                              22.sp,
                                                                        )
                                                                      : Image
                                                                          .asset(
                                                                          heartImage,
                                                                          height:
                                                                              22.sp,
                                                                          width:
                                                                              22.sp,
                                                                        ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: 20.sp,
                                                        bottom: 20.sp,
                                                        child: Container(
                                                          color: const Color(
                                                              0xB3F7F7F5),
                                                          height: 26.sp,
                                                          width: 80.sp,
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
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
                                                              Flexible(
                                                                child: AppText(
                                                                  text: productController.productCategoryList[index]
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
                                                                      "Clash Display Regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
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
                                                              Flexible(
                                                                child: AppText(
                                                                  text: productController
                                                                      .productCategoryList[
                                                                          index][
                                                                          "reviews_count"]
                                                                      .toString(),
                                                                  color:
                                                                      colorPrimary,
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      "Clash Display Regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  productController
                                                              .productCategoryList[
                                                                  index]
                                                                  ["images"]
                                                              .length ==
                                                          1
                                                      ? const SizedBox(
                                                          height: 0,
                                                        )
                                                      : Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      16.sp,
                                                                  vertical:
                                                                      10.sp),
                                                          child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child: Center(
                                                              child:
                                                                  SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: List<
                                                                            Widget>.generate(
                                                                        productController
                                                                            .productCategoryList[index][
                                                                                "images"]
                                                                            .length,
                                                                        (int
                                                                            l) {
                                                                      if (isImage(productController.productCategoryList[index]["images"]
                                                                              [
                                                                              l]
                                                                          [
                                                                          'name'])) {
                                                                        return Padding(
                                                                          padding:
                                                                              EdgeInsets.only(top: 2.sp),
                                                                          child:
                                                                              AnimatedContainer(
                                                                            duration:
                                                                                const Duration(milliseconds: 400),
                                                                            height:
                                                                                6.sp,
                                                                            width:
                                                                                6.sp,
                                                                            margin:
                                                                                EdgeInsets.symmetric(
                                                                              horizontal: 5.sp,
                                                                            ),
                                                                            decoration:
                                                                                BoxDecoration(borderRadius: BorderRadius.circular(5.sp), color: (l == productController.curr.value && productController.index.value == index) ? colorPrimary : colorSecondary),
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 2.0.sp),
                                                                          child:
                                                                              AppText(
                                                                            text:
                                                                                '\u{25B6}',
                                                                            fontSize:
                                                                                14,
                                                                            color: (l == productController.curr.value && productController.index.value == index)
                                                                                ? colorPrimary
                                                                                : colorSecondary,
                                                                          ),
                                                                        );
                                                                      }
                                                                    })),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  SizedBox(
                                                    height: 10.sp,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.sp,
                                                            vertical: 5.sp),
                                                    child: AppText(
                                                      text: productController
                                                                  .productCategoryList[
                                                              index]["name"] ??
                                                          "",
                                                      color: nameText,
                                                      maxLines: 2,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          "Clash Display",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.sp),
                                                    child: AppText(
                                                      text: productController
                                                                      .productCategoryList[
                                                                  index]
                                                              ["brand_name"] ??
                                                          "",
                                                      color: nameText,
                                                      maxLines: 2,
                                                      fontSize: 12,
                                                      fontFamily:
                                                          "Clash Display Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10.sp,
                                                        left: 10.sp,
                                                        right: 1.sp),
                                                    child: ProductPriceDisplay(
                                                      price: productController
                                                                  .productCategoryList[
                                                              index]["price"] ??
                                                          0,
                                                      mrp: productController
                                                              .productCategoryList[
                                                          index]["mrp"],
                                                      fontSize: 14,
                                                      mrpFontSize: 11,
                                                      discountFontSize: 11,
                                                      fontWeight: FontWeight.w400,
                                                      spacing: 5,
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
                                                                  right: 10.sp,
                                                                  bottom:
                                                                      30.sp),
                                                          // child: Row(
                                                          //   children: [
                                                          //     ImageIcon(
                                                          //       AssetImage(
                                                          //           truckImage),
                                                          //       color:
                                                          //           expressText,
                                                          //       size: 14.sp,
                                                          //     ),
                                                          //     Padding(
                                                          //       padding: EdgeInsets
                                                          //           .symmetric(
                                                          //               horizontal:
                                                          //                   5.sp),
                                                          //       child: AppText(
                                                          //         text:
                                                          //             "Express",
                                                          //         color:
                                                          //             expressText,
                                                          //         maxLines: 2,
                                                          //         fontSize: 11,
                                                          //         fontFamily:
                                                          //             "Clash Display Regular",
                                                          //         fontWeight:
                                                          //             FontWeight
                                                          //                 .w400,
                                                          //       ),
                                                          //     ),
                                                          //   ],
                                                          // ),
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
                                        ? const DummyVerticalList()
                                        : const SizedBox(
                                            height: 0,
                                          ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Text("No Product Found",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.black,
                                          fontFamily: "Clash Display Regular")),
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
                              right: 8.sp),
                          child: DoubleButton(
                            firstText: "Sort By",
                            secondText: "Filters",
                            firstTextColor: deepGreytextColor,
                            secondTextColor: deepGreytextColor,
                            firstBackgroundColor: whiteTextColor,
                            secondBackgroundColor: whiteTextColor,
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
                                      //  Get.back();
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.remove("brandList");
                                      prefs.remove("colorList");
                                      prefs.remove("sizeList");
                                      prefs.remove("upper");
                                      prefs.remove("lower");
                                      prefs.remove("sortby");
                                    },
                                    onClick: (p0, p1) {
                                      productController.filterEnable.value =
                                          true;
                                      productController.lowPrice.value = p0;
                                      productController.highPrice.value = p1;
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
          })),
    );
  }
}
