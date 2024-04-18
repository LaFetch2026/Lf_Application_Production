// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import '../../../commonwidget/app_text.dart';
import '../../../commonwidget/catalogwidgets/bottomfiltters.dart';
import '../../../commonwidget/catalogwidgets/bottomsortby.dart';
import '../../../commonwidget/doublebtn.dart';
import '../../../controller/product_controller.dart';
import '../../../utils/constants.dart';

class ProductVerticalScreen extends StatefulWidget {
  const ProductVerticalScreen({super.key});

  @override
  State<ProductVerticalScreen> createState() => ProductVerticalScreenState();
}

class ProductVerticalScreenState extends State<ProductVerticalScreen> {
  final productController = Get.find<ProductController>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final PageController _pageController = PageController(
    initialPage: 0,
  );

  callOnchanged(int index) {
    setState(() {
      productController.currentpage.value = index;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: whiteTextColor,
        body: Obx(
          () => productController.isProduct.value
              ? const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : productController.productList.isNotEmpty
                  ? Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16),
                                child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: const ScrollPhysics(),
                                  itemCount:
                                      productController.productList.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(ProductDetailsScreen(
                                              productId: productController
                                                  .productList[index]["id"],
                                            ));
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  productController.productList[
                                                                  index]
                                                              ["images"] !=
                                                          null
                                                      ? SizedBox(
                                                          height: 400,
                                                          width:
                                                              double.infinity,
                                                          child:
                                                              PageView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            controller:
                                                                _pageController,
                                                            onPageChanged:
                                                                callOnchanged,
                                                            itemCount:
                                                                productController
                                                                    .productList[
                                                                        index][
                                                                        "images"]
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    int i) {
                                                              return productController
                                                                      .productList[index]
                                                                          [
                                                                          "images"]
                                                                      .isNotEmpty
                                                                  ? SizedBox(
                                                                      height:
                                                                          400,
                                                                      width: double
                                                                          .infinity,
                                                                      child:
                                                                          CachedNetworkImage(
                                                                        cacheManager: CacheManager(Config(
                                                                            "customCacheKey",
                                                                            stalePeriod:
                                                                                const Duration(days: 15),
                                                                            maxNrOfCacheObjects: 100)),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        imageUrl:
                                                                            productController.productList[index]["images"][0]["name"],
                                                                        progressIndicatorBuilder: (context,
                                                                                url,
                                                                                downloadProgress) =>
                                                                            Center(
                                                                          child:
                                                                              CircularProgressIndicator(value: downloadProgress.progress),
                                                                        ),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            Image.asset(
                                                                          dummyWishlistImage,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          height:
                                                                              400,
                                                                          width:
                                                                              double.infinity,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Image.asset(
                                                                      backImage,
                                                                      height:
                                                                          400,
                                                                      width: double
                                                                          .infinity,
                                                                      fit: BoxFit
                                                                          .cover);
                                                            },
                                                          ),
                                                        )
                                                      : Image.asset(
                                                          dummyWishlistImage,
                                                          height: 400,
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover),
                                                  GestureDetector(
                                                    onTap: () {
                                                      productController
                                                          .callAddProductToWishlist(
                                                              productController
                                                                      .productList[
                                                                  index]["id"],
                                                              "product",
                                                              0);
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
                                                            height: 30,
                                                            width: 30,
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  whiteColor,
                                                              child: productController
                                                                              .productList[
                                                                          index]
                                                                      [
                                                                      "wishlisted"]
                                                                  ? Image.asset(
                                                                      wishlistSelectImage,
                                                                      height:
                                                                          22,
                                                                      width: 22,
                                                                    )
                                                                  : Image.asset(
                                                                      heartImage,
                                                                      height:
                                                                          30,
                                                                      width: 30,
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
                                                        margin: const EdgeInsets
                                                            .only(top: 350),
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
                                                                              .productList[index]
                                                                          [
                                                                          "aggregated_rating"] !=
                                                                      null
                                                                  ? productController
                                                                      .productList[
                                                                          index]
                                                                          [
                                                                          "aggregated_rating"]
                                                                      .toString()
                                                                  : "",
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
                                                              child: Container(
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 10),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: /* SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: */
                                                      Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: List<
                                                                  Widget>.generate(
                                                              productController
                                                                  .productList[
                                                                      index]
                                                                      ["images"]
                                                                  .length,
                                                              (int index) {
                                                            return AnimatedContainer(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            400),
                                                                height: 6,
                                                                width: 6,
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        5),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                5),
                                                                    color: (index ==
                                                                            productController.currentpage.value)
                                                                        ? colorPrimary
                                                                        : colorSecondary));
                                                          })),
                                                  //  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: AppText(
                                                  text: productController
                                                              .productList[
                                                          index]["name"] ??
                                                      "",
                                                  color: nameText,
                                                  maxLines: 2,
                                                  fontSize: 14.sp,
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
                                                                  .productList[
                                                              index][
                                                          "short_description"] ??
                                                      "",
                                                  color: nameText,
                                                  maxLines: 2,
                                                  fontSize: 12.sp,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10,
                                                    left: 10,
                                                    right: 10),
                                                child: Row(
                                                  children: [
                                                    AppText(
                                                      text:
                                                          "\u{20B9} ${productController.productList[index]["price"] ?? ""}",
                                                      color: deepGreytextColor,
                                                      maxLines: 2,
                                                      fontSize: 14.sp,
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Text(
                                                        "\u{20B9} ${productController.productList[index]["mrp"] ?? ""}",
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
                                                    top: 5,
                                                    left: 10,
                                                    right: 10,
                                                    bottom: 30),
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
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 16, top: 20, left: 4, right: 8),
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
                    ),
        ));
  }
}
