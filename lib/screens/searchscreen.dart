// ignore_for_file: avoid_print

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_grid_mostsearch.dart';
import 'package:lafetch/screens/brandsscreen.dart';
import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';
import '../commonwidget/common_widgets.dart';
import '../commonwidget/homewidget/dummy_product_list.dart';
import '../commonwidget/homewidget/horizontal_home_list.dart';
import '../controller/brand_controller.dart';
import '../controller/product_controller.dart';
import '../controller/search_controller.dart';
import 'Brands/categoryproduct.dart';
import 'catalog/productlist/productdetailsscreen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final productController = Get.put(ProductController());
  final brandController = Get.put(BrandController());
  final controller = Get.put(SearchScreenController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  bool isSearch = false;
  Timer? debounce;

  onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      controller.getSearchData();
    });
  }

  @override
  void initState() {
    controller.searchController.clear();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.recentListController.addListener(() {
        productController.fetchMoreData("recently-viewed");
        productController.update();
      });
    });
    productController.hasnextpage.value = true;
    productController.loadMore.value = false;
    productController.isProduct.value = false;
    productController.page.value = 1;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getRecentSearchData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.mostViewController.addListener(() {
        productController.fetchMostSearchMoreData();
        productController.update();
      });
    });
    productController.mostViewHasnextpage.value = true;
    productController.mostViewLoadMore.value = false;
    productController.isMostSearch.value = false;
    productController.mostViewPage.value = 1;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getMostViewProductData());
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("recently-viewed"));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => brandController.getBrandData());
    super.initState();
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isSearch = false;
        controller.searchText.value = "Search for products";
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {});
      },
      child: Scaffold(
        backgroundColor: isSearch ? const Color(0xF2F7F7F5) : whiteColor,
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: colorPrimary,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 16.sp, right: 16.sp, top: 40.sp, bottom: 20.sp),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: IconButton(
                            icon: Image.asset(
                              backWhiteArrow,
                              height: 16.sp,
                              width: 16.sp,
                            ),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              if (isSearch) {
                                isSearch = false;
                                controller.searchText.value =
                                    "Search for products";
                              } else {
                                isSearch = true;
                              }
                              setState(() {});
                              await analytics.logEvent(
                                name: "search_page_searches",
                                parameters: <String, Object>{
                                  'page_name': 'search_page_searches',
                                },
                              );
                            },
                            child: Container(
                              height: 40.sp,
                              decoration: BoxDecoration(
                                  color: whiteBorderColor,
                                  borderRadius: BorderRadius.circular(1.sp),
                                  border: Border.all(
                                      color: colorSecondary, width: 1.sp)),
                              child: Padding(
                                padding:
                                    EdgeInsets.only(left: 16.sp, right: 16.sp),
                                child: Row(
                                  children: [
                                    ImageIcon(
                                      AssetImage(searchImage),
                                      color: textHintColor,
                                      size: 14.sp,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5.sp),
                                      child: AppText(
                                        text: "Search for brands & products",
                                        color: textHintColor,
                                        fontSize: 14,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => controller.isRecentSearch.value
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 20.sp, left: 16.sp),
                                    child: AppText(
                                      text: "Recent Searches",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: bottomnavBack,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 16.sp,
                                          bottom: 10.sp,
                                          right: 16.sp,
                                          top: 20.sp),
                                      child: SizedBox(
                                        height: 30.sp,
                                        width: double.infinity,
                                        child: ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: 5,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (ctx, index) {
                                              return Container(
                                                margin: EdgeInsets.only(
                                                    right: 5.sp),
                                                width: 100.sp,
                                                height: 30.sp,
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.04),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.sp),
                                                ),
                                              );
                                            }),
                                      )),
                                ],
                              )
                            : controller.recentSearchList.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 20.sp, left: 16.sp),
                                        child: AppText(
                                          text: "Recent Searches",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: bottomnavBack,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.sp,
                                            right: 16.sp,
                                            top: 20.sp),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          controller: ScrollController(),
                                          child: Wrap(
                                            direction: Axis.horizontal,
                                            spacing: 5.0.sp,
                                            runSpacing: 9.0.sp,
                                            runAlignment:
                                                WrapAlignment.spaceEvenly,
                                            children: [
                                              for (var product in controller
                                                  .recentSearchList)
                                                GestureDetector(
                                                  onTap: () async {
                                                    if (isSearch) {
                                                    } else {
                                                      Navigator.of(context)
                                                          .push(MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  ProductDetailsScreen(
                                                                      productId:
                                                                          product["product"]
                                                                              [
                                                                              "id"],
                                                                      type:
                                                                          "add")))
                                                          .then((value) =>
                                                              setState(
                                                                () {
                                                                  controller
                                                                      .isRecentSearch
                                                                      .value = false;
                                                                  productController;
                                                                  controller
                                                                      .getRecentSearchData();
                                                                },
                                                              ));
                                                    }
                                                    await analytics.logEvent(
                                                      name:
                                                          "search_page_recentsearch_details",
                                                      parameters: <String,
                                                          Object>{
                                                        'page_name':
                                                            'search_page_recentsearch_details',
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    height: 33.sp,
                                                    margin: EdgeInsets.only(
                                                        right: 5.sp),
                                                    decoration: BoxDecoration(
                                                        color: whiteColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    20.sp),
                                                        border: Border.all(
                                                            color: btnTextColor,
                                                            width: 1.sp)),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.sp,
                                                              vertical: 7.sp),
                                                      child: Text(
                                                        product[
                                                            "search_string"],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 12.sp,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(
                                    height: 0,
                                  )),
                        Obx(() => productController.isMostSearch.value
                            ? const DummyGridMostSearch()
                            : productController.mostSeachList.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 30.sp, left: 16.sp),
                                        child: AppText(
                                          text: "Most Searched",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: bottomnavBack,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.sp,
                                            top: 20.sp,
                                            right: 16.sp,
                                            bottom: 10.sp),
                                        child: Center(
                                          child: GridView.count(
                                            shrinkWrap: true,
                                            crossAxisCount: 4,
                                            scrollDirection: Axis.vertical,
                                            padding: EdgeInsets.zero,
                                            childAspectRatio: 0.7,
                                            physics: const ScrollPhysics(),
                                            crossAxisSpacing: 5.sp,
                                            mainAxisSpacing: 1.sp,
                                            children: List.generate(
                                              productController
                                                  .mostSeachList.length,
                                              (index) {
                                                return Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        if (isSearch) {
                                                        } else {
                                                          Navigator.of(context)
                                                              .push(MaterialPageRoute(
                                                                  builder: (BuildContext context) => CategoryProductScreen(
                                                                      categoryId:
                                                                          productController.mostSeachList[index]
                                                                              [
                                                                              "id"],
                                                                      brandId:
                                                                          0,
                                                                      genderType:
                                                                          0,
                                                                      tagIds: const [])))
                                                              .then((value) =>
                                                                  setState(
                                                                    () {
                                                                      productController
                                                                          .mostViewHasnextpage
                                                                          .value = true;
                                                                      productController
                                                                          .mostViewLoadMore
                                                                          .value = false;
                                                                      productController
                                                                          .isMostSearch
                                                                          .value = false;
                                                                      productController
                                                                          .mostViewPage
                                                                          .value = 1;
                                                                      productController;
                                                                      productController
                                                                          .getMostViewProductData();
                                                                    },
                                                                  ));
                                                          await analytics
                                                              .logEvent(
                                                            name:
                                                                'categories_searchpage',
                                                            parameters: <String,
                                                                Object>{
                                                              'page_name':
                                                                  'categories_searchpage',
                                                            },
                                                          );
                                                        }
                                                        await analytics
                                                            .logEvent(
                                                          name:
                                                              "search_page_mostsearch_details",
                                                          parameters: <String,
                                                              Object>{
                                                            'page_name':
                                                                'search_page_mostsearch_details',
                                                          },
                                                        );
                                                      },
                                                      child: SizedBox(
                                                        height: 100.sp,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            productController
                                                                        .mostSeachList[
                                                                            index]
                                                                            [
                                                                            "thumbnail"]
                                                                        .isNotEmpty &&
                                                                    productController.mostSeachList[index]
                                                                            [
                                                                            "thumbnail"] !=
                                                                        null
                                                                ? SizedBox(
                                                                    width:
                                                                        80.sp,
                                                                    height:
                                                                        72.sp,
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
                                                                      imageUrl: isImage(productController.mostSeachList[index]
                                                                              [
                                                                              "thumbnail"])
                                                                          ? productController.mostSeachList[index]
                                                                              [
                                                                              "thumbnail"]
                                                                          : productController.mostSeachList[index]
                                                                              [
                                                                              "thumbnail"],
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Image
                                                                              .asset(
                                                                        downloadImage,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        width: 80
                                                                            .sp,
                                                                        height:
                                                                            72.sp,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Center(
                                                                    child: Image.asset(
                                                                        dummyWishlistImage,
                                                                        width: 80
                                                                            .sp,
                                                                        height: 72
                                                                            .sp,
                                                                        fit: BoxFit
                                                                            .cover),
                                                                  ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10.sp,
                                                                      vertical:
                                                                          5.sp),
                                                              child: AppText(
                                                                text: productController
                                                                        .mostSeachList[
                                                                    index]["name"],
                                                                color:
                                                                    greyTextColor,
                                                                fontSize: 10,
                                                                maxLines: 1,
                                                                fontFamily:
                                                                    "Franklin Gothic Regular",
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
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(
                                    height: 10.sp,
                                  )),
                        Obx(
                          () => brandController.isBrand.value
                              ? const DummyProductList(
                                  text: "Continue Browsing these Brands")
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 16.sp),
                                      child: AppText(
                                        text: "Continue Browsing these Brands",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: bottomnavBack,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.sp, vertical: 20.sp),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 235.sp,
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            primary: false,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: brandController
                                                .brandList.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (ctx, index) {
                                              return Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      if (isSearch) {
                                                      } else {
                                                        Get.to(BrandsScreen(
                                                          screen: "search",
                                                          logo: brandController
                                                                  .brandList[
                                                              index]["logo"],
                                                          backImage: brandController
                                                                          .brandList[
                                                                      index][
                                                                  "background_image"] ??
                                                              "",
                                                          name: brandController
                                                                  .brandList[
                                                              index]["name"],
                                                          brandId:
                                                              brandController
                                                                      .brandList[
                                                                  index]["id"],
                                                        ));
                                                      }
                                                      await analytics.logEvent(
                                                        name:
                                                            "continuebrowsing_branddetails",
                                                        parameters: <String,
                                                            Object>{
                                                          'page_name':
                                                              'continuebrowsing_branddetails',
                                                        },
                                                      );
                                                    },
                                                    child: AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      margin: EdgeInsets.only(
                                                          right: 10.sp),
                                                      width: 130.sp,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          brandController.brandList[
                                                                          index]
                                                                      [
                                                                      "logo"] !=
                                                                  null
                                                              ? SizedBox(
                                                                  height:
                                                                      180.sp,
                                                                  width: 130.sp,
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
                                                                        .contain,
                                                                    imageUrl: brandController
                                                                            .brandList[index]
                                                                        [
                                                                        "logo"],
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Image
                                                                            .asset(
                                                                      downloadImage,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      height:
                                                                          180.sp,
                                                                      width: 130
                                                                          .sp,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Image.asset(
                                                                  dummyWishlistImage,
                                                                  height:
                                                                      180.sp,
                                                                  width: 130.sp,
                                                                  fit: BoxFit
                                                                      .cover),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal: 10.sp,
                                                            ),
                                                            child: AppText(
                                                              text: brandController
                                                                      .brandList[
                                                                  index]["name"],
                                                              maxLines: 2,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              color:
                                                                  greyTextColor,
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  "Franklin Gothic",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10.sp,
                                                                    vertical:
                                                                        3.sp),
                                                            child: AppText(
                                                              text: brandController
                                                                      .brandList[
                                                                          index]
                                                                          [
                                                                          "categories"]
                                                                      .isNotEmpty
                                                                  ? brandController
                                                                              .brandList[index]
                                                                          [
                                                                          "categories"]
                                                                      [
                                                                      0]["name"]
                                                                  : "",
                                                              color:
                                                                  greyTextColor,
                                                              fontSize: 10,
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
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
                                              );
                                            }),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        /*  Padding(
                          padding: const EdgeInsets.only(top: 10, left: 16),
                          child: AppText(
                            text: "Items you have viewed",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: bottomnavBack,
                            fontSize: 16.sp,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 250,
                            child: ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                physics: const BouncingScrollPhysics(),
                                itemCount: items.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (ctx, index) {
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          width: 122,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.asset(backImage,
                                                  height: 150,
                                                  width: 122,
                                                  fit: BoxFit.cover),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: AppText(
                                                  text:
                                                      "Topman super skinny suit jacket and trousers in light blue",
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
                                                    top: 10,
                                                    left: 10,
                                                    right: 10),
                                                child: Row(
                                                  children: [
                                                    AppText(
                                                      text:
                                                          "\u{20B9} ${items[index]}",
                                                      color: deepGreytextColor,
                                                      maxLines: 2,
                                                      fontSize: 11.sp,
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Text(
                                                        "\u{20B9} ${items[index]}",
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ),
                     */
                        Obx(() => productController.isProduct.value
                            ? const DummyProductList(
                                text: "Items you have viewed")
                            : productController.productList.isNotEmpty
                                ? HorizontalHomeList(
                                    text: "Items you have viewed",
                                    height: 250.sp,
                                    controller:
                                        productController.recentListController,
                                    visibleExpress: false,
                                    textColor: bottomnavBack,
                                    fontFamily: "Franklin Gothic Regular",
                                    onPressed: (p0) async {
                                      if (isSearch) {
                                      } else {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ProductDetailsScreen(
                                                            productId: p0,
                                                            type: "add")))
                                            .then((value) => setState(
                                                  () {
                                                    productController
                                                        .hasnextpage
                                                        .value = true;
                                                    productController
                                                        .loadMore.value = false;
                                                    productController.isProduct
                                                        .value = false;
                                                    productController
                                                        .page.value = 1;
                                                    productController
                                                        .getProductData(
                                                            "recently-viewed");
                                                  },
                                                ));
                                      }
                                      await analytics.logEvent(
                                        name: "search_page_itemviewed_details",
                                        parameters: <String, Object>{
                                          'page_name':
                                              'search_page_itemviewed_details',
                                        },
                                      );
                                    },
                                    list: productController.productList,
                                  )
                                : const SizedBox(
                                    height: 0,
                                  )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearch
                ? Container(
                    color: whiteColor,
                    height: 290.sp,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 30.sp, left: 16.sp, right: 16.sp, bottom: 0.sp),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: ImageIcon(
                                  AssetImage(backWhiteArrow),
                                  color: colorPrimary,
                                  size: 16.sp,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 40.sp,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10.sp),
                                    child: RawKeyboardListener(
                                      focusNode: FocusNode(),
                                      onKey: (value) {
                                        print(value);
                                        if (value is RawKeyDownEvent) {
                                          setState(() {
                                            isSearch = false;
                                            controller.searchText.value =
                                                "Search for products";
                                          });
                                        }
                                      },
                                      child: TextField(
                                        textCapitalization:
                                            TextCapitalization.words,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: textColor,
                                          fontFamily: "Franklin Gothic Regular",
                                        ),
                                        controller: controller.searchController,
                                        /*  onChanged: (value) {
                                          controller.getSearchData();
                                        }, */
                                        onChanged: onSearchChanged,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          filled: true,
                                          isDense: true,
                                          fillColor: whiteColor,
                                          suffixIcon: InkWell(
                                            onTap: () {
                                              controller.searchController
                                                  .clear();
                                              controller.searchText.value =
                                                  "Search for products";
                                            },
                                            child: ImageIcon(
                                              AssetImage(greyCrossImage),
                                              size: 14.sp,
                                            ),
                                          ),
                                          prefixIcon: Icon(Icons.search,
                                              size: 20.sp, color: Colors.grey),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: borderColor)),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(1),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(1),
                                            borderSide: const BorderSide(
                                                color: borderColor),
                                          ),
                                          counterText: "",
                                          /*   contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10.sp), */
                                          hintText: "Search",
                                          hintStyle: TextStyle(fontSize: 14.sp),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Obx(() => controller.isSearchItem.value
                              ? Padding(
                                  padding:
                                      EdgeInsets.only(bottom: 4.sp, top: 8.sp),
                                  child: SizedBox(
                                    height: 187.sp,
                                    child: ListView.builder(
                                        primary: false,
                                        shrinkWrap: true,
                                        physics: const ScrollPhysics(),
                                        itemCount: 5,
                                        padding: EdgeInsets.zero,
                                        scrollDirection: Axis.vertical,
                                        itemBuilder: (ctx, index) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4.sp),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 6.sp),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  DummyContainer(
                                                      height: 16, width: 16),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  12.sp),
                                                      child: DummyContainer(
                                                          height: 16,
                                                          width: 100),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8.sp),
                                                    child: DummyContainer(
                                                        height: 14, width: 14),
                                                  ),
                                                  DummyContainer(
                                                      height: 14, width: 14),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                )
                              : controller.searchList.isNotEmpty
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 4.sp, top: 8.sp),
                                      child: SizedBox(
                                        height: 187.sp,
                                        child: ListView.builder(
                                            primary: false,
                                            shrinkWrap: true,
                                            physics: const ScrollPhysics(),
                                            itemCount:
                                                controller.searchList.length,
                                            padding: EdgeInsets.zero,
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (ctx, index) {
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4.sp),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    controller.callRecentSearch(
                                                        controller.searchList[
                                                            index]["id"],
                                                        controller.searchList[
                                                            index]["name"]);
                                                    setState(() {
                                                      isSearch = false;
                                                      controller.searchText
                                                              .value =
                                                          "Search for products";
                                                    });

                                                    Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                ProductDetailsScreen(
                                                                    productId:
                                                                        controller.searchList[index]
                                                                            [
                                                                            "id"],
                                                                    type:
                                                                        "add")))
                                                        .then(
                                                            (value) => setState(
                                                                  () {
                                                                    controller
                                                                        .isRecentSearch
                                                                        .value = false;
                                                                    controller
                                                                        .getRecentSearchData();
                                                                    controller
                                                                        .searchController
                                                                        .clear();
                                                                    controller
                                                                        .getSearchData();
                                                                  },
                                                                ));
                                                    await analytics.logEvent(
                                                      name:
                                                          "search_page_searchproductdetails",
                                                      parameters: <String,
                                                          Object>{
                                                        'page_name':
                                                            'search_page_searchproductdetails',
                                                      },
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 6.sp),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(Icons.search,
                                                            size: 20.sp,
                                                            color: Colors.grey),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        12.sp),
                                                            child: AppText(
                                                              text: controller.searchList[
                                                                          index]
                                                                      [
                                                                      "name"] ??
                                                                  "",
                                                              maxLines: 1,
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                              color: loginText,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      8.sp),
                                                          child: AppText(
                                                            text: controller
                                                                .searchList[
                                                                    index]
                                                                    ["hits"]
                                                                .toString(),
                                                            maxLines: 1,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                            color:
                                                                greyTextColor,
                                                          ),
                                                        ),
                                                        Image.asset(
                                                            curveArrowImage,
                                                            height: 14.sp,
                                                            width: 14.sp,
                                                            fit: BoxFit.cover),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                                    )
                                  : Container(
                                      margin: EdgeInsets.only(top: 100.sp),
                                      child: Center(
                                        child: Text(controller.searchText.value,
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.black,
                                                fontFamily:
                                                    "Franklin Gothic Regular")),
                                      ),
                                    )),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(
                    height: 0,
                  )
          ],
        ),
      ),
    );
  }
}
