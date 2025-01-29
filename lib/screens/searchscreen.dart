// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_grid_mostsearch.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';
import '../commonwidget/common_widgets.dart';
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
//  final brandController = Get.put(BrandController());
  final controller = Get.put(SearchScreenController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  bool isSearch = false;
  Timer? debounce;

  onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      controller.getSearchData(context);
      setState(() {});
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.searchController.clear();
      productController.hasnextpage.value = true;
      productController.loadMore.value = false;
      productController.isProduct.value = false;
      productController.page.value = 1;
      productController.mostViewHasnextpage.value = true;
      productController.mostViewLoadMore.value = false;
      productController.isMostSearch.value = false;
      productController.mostViewPage.value = 1;
      controller.selected.clear();
      controller.selected = List.generate(50, (i) => false).obs;
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getRecentSearchData());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getCatalogData());
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getMostViewProductData());
    /*  WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("recently-viewed")); */
    /*  WidgetsBinding.instance.addPostFrameCallback(
        (_) => brandController.getBrandData("brand search")); */
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.recentListController.addListener(() {
        productController.fetchMoreData("recently-viewed");
        productController.update();
      });
    }); */
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.mostViewController.addListener(() {
        productController.fetchMostSearchMoreData();
        productController.update();
      });
    });
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
                /*  Container(
                  width: MediaQuery.of(context).size.width,
                  color: statusBarColor,
                  child: Padding(
                    padding: EdgeInsets.only(top: 40.sp, bottom: 10.sp),
                    child: Row(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(arrowBack,
                              color: homeAppBarColor,
                              height: 15.sp,
                              width: 15.sp,
                              fit: BoxFit.cover),
                          onPressed: () {
                            Get.back();
                          },
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
                            child: AppText(
                              text: "Search for 'Bag'",
                              color: subtitleColor,
                              fontSize: 14,
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: SvgPicture.asset(crossSearchImage,
                              color: homeAppBarColor,
                              height: 13.sp,
                              width: 13.sp,
                              fit: BoxFit.cover),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                ),
                */
                Container(
                  color: statusBarColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 40.sp, left: 16.sp, bottom: 10.sp),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                /*  setState(() {
                                  isSearch = false;
                                  controller.searchList.clear();
                                  controller.searchController.clear();
                                  controller.searchText.value =
                                      "Search for products";
                                }); */
                                Get.back();
                              },
                              child: SvgPicture.asset(arrowBack,
                                  height: 15.sp,
                                  width: 15.sp,
                                  fit: BoxFit.cover),
                            ),
                            MediaQuery.of(context).size.width < 600
                                ? Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      height: 40.sp,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 4.sp),
                                        child: RawKeyboardListener(
                                          focusNode: FocusNode(),
                                          onKey: (value) {
                                            print(value);
                                            if (value is RawKeyDownEvent) {
                                              if (controller.searchController
                                                  .text.isEmpty) {
                                                FocusScope.of(context)
                                                    .unfocus();
                                              }
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
                                            style: TextStyle(
                                                color: homeAppBarColor,
                                                fontFamily: "Franklin Gothic",
                                                fontSize: 14.sp),
                                            controller:
                                                controller.searchController,
                                            onChanged: onSearchChanged,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              filled: true,
                                              isDense: true,
                                              fillColor: statusBarColor,
                                              suffixIcon: IconButton(
                                                icon: SvgPicture.asset(
                                                    crossSearchImage,
                                                    color: homeAppBarColor,
                                                    height: 13.sp,
                                                    width: 13.sp,
                                                    fit: BoxFit.cover),
                                                onPressed: () {
                                                  controller.searchController
                                                      .clear();
                                                  controller
                                                      .getSearchData(context);
                                                  controller.searchText.value =
                                                      "Search for products";
                                                },
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              statusBarColor)),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                                borderSide: const BorderSide(
                                                    color: statusBarColor),
                                              ),
                                              counterText: "",
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 10.sp),
                                              hintText: "Search for 'Bag'",
                                              hintStyle: TextStyle(
                                                color: subtitleColor,
                                                fontSize: 14,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      height: 40.sp,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 4.sp),
                                        child: RawKeyboardListener(
                                          focusNode: FocusNode(),
                                          onKey: (value) {
                                            print(value);
                                            if (value is RawKeyDownEvent) {
                                              if (controller.searchController
                                                  .text.isEmpty) {
                                                FocusScope.of(context)
                                                    .unfocus();
                                              }
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
                                            style: TextStyle(
                                                color: homeAppBarColor,
                                                fontFamily: "Franklin Gothic",
                                                fontSize: 14.sp),
                                            controller:
                                                controller.searchController,
                                            onChanged: onSearchChanged,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              filled: true,
                                              isDense: true,
                                              suffixIcon: IconButton(
                                                icon: SvgPicture.asset(
                                                    crossSearchImage,
                                                    color: homeAppBarColor,
                                                    height: 13.sp,
                                                    width: 13.sp,
                                                    fit: BoxFit.cover),
                                                onPressed: () {
                                                  controller.searchController
                                                      .clear();
                                                  controller
                                                      .getSearchData(context);
                                                  controller.searchText.value =
                                                      "Search for products";
                                                },
                                              ),
                                              fillColor: statusBarColor,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                                borderSide: const BorderSide(
                                                    color: statusBarColor),
                                              ),
                                              counterText: "",
                                              /*   contentPadding: EdgeInsets.symmetric(
                                                    horizontal: 10.sp), */
                                              hintText: "Search for 'Bag'",
                                              hintStyle: TextStyle(
                                                color: subtitleColor,
                                                fontSize: 14,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      Container(
                        height: 1.sp,
                        color: dividerColor,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1.sp,
                  color: dividerColor,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => controller.isRecentSearch.value
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 20.sp, left: 16.sp),
                                      child: AppText(
                                        text: "".toUpperCase(),
                                        fontFamily: "Franklin Gothic Semibold",
                                        fontWeight: FontWeight.w400,
                                        color: blackColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.sp),
                                      child: ListView.builder(
                                          primary: false,
                                          shrinkWrap: true,
                                          physics: const ScrollPhysics(),
                                          itemCount: 2,
                                          padding: EdgeInsets.zero,
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (ctx, i) {
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.sp),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 0.sp,
                                                    vertical: 1.sp),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 16.sp),
                                                        child: DummyContainer(
                                                            height: 20,
                                                            width: 60),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: SizedBox(
                                                        height: 0,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  16.sp),
                                                      child: DummyContainer(
                                                          height: 15,
                                                          width: 15),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  ],
                                )
                              : controller.recentSearchList.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 16.sp, left: 16.sp),
                                          child: AppText(
                                            text:
                                                "Recent Searches".toUpperCase(),
                                            fontFamily:
                                                "Franklin Gothic Semibold",
                                            fontWeight: FontWeight.w400,
                                            color: blackColor,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.sp),
                                          child: ListView.builder(
                                              primary: false,
                                              shrinkWrap: true,
                                              physics: const ScrollPhysics(),
                                              itemCount: controller
                                                  .recentSearchList.length,
                                              padding: EdgeInsets.zero,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder: (ctx, i) {
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 4.sp),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      /*  if (isSearch) {
                                                      } else { */
                                                      Navigator.of(context)
                                                          .push(MaterialPageRoute(
                                                              builder: (BuildContext context) => ProductDetailsScreen(
                                                                  brandName: controller
                                                                              .recentSearchList[i]
                                                                          ["product"]
                                                                      [
                                                                      "brand_name"],
                                                                  productId: controller
                                                                              .recentSearchList[i]
                                                                          ["product"]
                                                                      ["id"],
                                                                  type: "add")))
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
                                                      //   }
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
                                                      height: 35.sp,
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    0.sp,
                                                                vertical: 1.sp),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              flex: 3,
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left: 16
                                                                            .sp),
                                                                child: AppText(
                                                                  text: controller
                                                                          .recentSearchList[i]
                                                                      [
                                                                      "search_string"],
                                                                  maxLines: 1,
                                                                  color:
                                                                      appBarColor,
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontFamily:
                                                                      "Franklin Gothic Regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: SizedBox(
                                                                height: 0,
                                                              ),
                                                            ),
                                                            controller
                                                                    .selected[i]
                                                                ? Padding(
                                                                    padding: EdgeInsets.only(
                                                                        right: 16
                                                                            .sp),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          13.sp,
                                                                      width:
                                                                          13.sp,
                                                                      child: Center(
                                                                          child:
                                                                              CircularProgressIndicator()),
                                                                    ),
                                                                  )
                                                                : IconButton(
                                                                    icon: SvgPicture.asset(
                                                                        crossSearchImage,
                                                                        color:
                                                                            subtitleColor,
                                                                        height: 13
                                                                            .sp,
                                                                        width: 13
                                                                            .sp,
                                                                        fit: BoxFit
                                                                            .cover),
                                                                    onPressed:
                                                                        () {
                                                                      controller
                                                                              .selected[
                                                                          i] = !controller
                                                                              .selected[
                                                                          i];
                                                                      setState(
                                                                          () {});
                                                                      controller.callDeleteRecent(
                                                                          controller.recentSearchList[i]
                                                                              [
                                                                              "id"]);
                                                                    },
                                                                  )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                        /* Padding(
                                          padding: EdgeInsets.only(
                                              left: 16.sp,
                                              right: 16.sp,
                                              top: 20.sp),
                                          child: Wrap(
                                            // direction: Axis.vertical,
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
                                                                      brandName:
                                                                          product[
                                                                                  "product"]
                                                                              [
                                                                              "brand_name"],
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
                                                    height: 30.sp,
                                                    width: double.infinity,
                                                    margin: EdgeInsets.only(
                                                        right: 5.sp),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.sp,
                                                              vertical: 7.sp),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              product[
                                                                  "search_string"],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 12.sp,
                                                                fontFamily:
                                                                    "Franklin Gothic Regular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: SvgPicture.asset(
                                                                crossSearchImage,
                                                                // ignore: deprecated_member_use
                                                                color:
                                                                    homeAppBarColor,
                                                                height: 13.sp,
                                                                width: 13.sp,
                                                                fit: BoxFit
                                                                    .cover),
                                                            onPressed: () {},
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ), */
                                      ],
                                    )
                                  : Obx(() => controller.isCatalog.value
                                      ? const DummyGridMostSearch(
                                          text: "Suggested",
                                        )
                                      : controller.suggestedList.isNotEmpty
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 16.sp, left: 16.sp),
                                                  child: AppText(
                                                    text: "Suggested"
                                                        .toUpperCase(),
                                                    fontFamily:
                                                        "Franklin Gothic Semibold",
                                                    fontWeight: FontWeight.w400,
                                                    color: blackColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 16.sp,
                                                      top: 12.sp,
                                                      right: 16.sp,
                                                      bottom: 10.sp),
                                                  child: Center(
                                                    child: GridView.count(
                                                      shrinkWrap: true,
                                                      crossAxisCount: 3,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      padding: EdgeInsets.zero,
                                                      childAspectRatio: 0.6,
                                                      physics:
                                                          const ScrollPhysics(),
                                                      crossAxisSpacing: 12.sp,
                                                      mainAxisSpacing: 0.sp,
                                                      children: List.generate(
                                                        controller.suggestedList
                                                            .length,
                                                        (index) {
                                                          return Column(
                                                            children: [
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  if (isSearch) {
                                                                  } else {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(MaterialPageRoute(
                                                                            builder: (BuildContext context) => CategoryProductScreen(
                                                                                categoryName: controller.suggestedList[index]["name"],
                                                                                categoryId: controller.suggestedList[index]["id"],
                                                                                brandId: 0,
                                                                                genderName: "",
                                                                                genderType: 0,
                                                                                categoryList: [],
                                                                                tagIds: const [])))
                                                                        .then((value) => setState(
                                                                              () {
                                                                                controller.getCatalogData();
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
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    controller.suggestedList[index]["thumbnail"].isNotEmpty &&
                                                                            controller.suggestedList[index]["thumbnail"] !=
                                                                                null
                                                                        ? SizedBox(
                                                                            width:
                                                                                104.sp,
                                                                            height:
                                                                                130.sp,
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
                                                                              fit: BoxFit.cover,
                                                                              imageUrl: isImage(controller.suggestedList[index]["thumbnail"]) ? controller.suggestedList[index]["thumbnail"] : controller.suggestedList[index]["thumbnail"],
                                                                              errorWidget: (context, url, error) => Image.asset(
                                                                                downloadImage,
                                                                                fit: BoxFit.cover,
                                                                                width: 104.sp,
                                                                                height: 130.sp,
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Center(
                                                                            child: Image.asset(dummyWishlistImage,
                                                                                width: 104.sp,
                                                                                height: 130.sp,
                                                                                fit: BoxFit.cover),
                                                                          ),
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal: 5
                                                                              .sp,
                                                                          vertical:
                                                                              6.sp),
                                                                      child:
                                                                          AppText(
                                                                        text: controller
                                                                            .suggestedList[index]["name"]
                                                                            .toUpperCase(),
                                                                        color:
                                                                            blackColor,
                                                                        fontSize:
                                                                            13,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        maxLines:
                                                                            1,
                                                                        fontFamily:
                                                                            "Franklin Gothic",
                                                                        fontWeight:
                                                                            FontWeight.w400,
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
                                                ),
                                              ],
                                            )
                                          : SizedBox(
                                              height: 0.sp,
                                            )),
                        ),
                        Obx(() => productController.isMostSearch.value
                            ? const DummyGridMostSearch(
                                text: "Most Searched",
                              )
                            : productController.mostSeachList.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 20.sp, left: 16.sp),
                                        child: AppText(
                                          text: "Most Searched".toUpperCase(),
                                          fontFamily:
                                              "Franklin Gothic Semibold",
                                          fontWeight: FontWeight.w400,
                                          color: blackColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.sp,
                                            top: 12.sp,
                                            right: 16.sp,
                                            bottom: 10.sp),
                                        child: Center(
                                          child: GridView.count(
                                            shrinkWrap: true,
                                            crossAxisCount: 3,
                                            scrollDirection: Axis.vertical,
                                            padding: EdgeInsets.zero,
                                            childAspectRatio: 0.6,
                                            physics: const ScrollPhysics(),
                                            crossAxisSpacing: 12.sp,
                                            mainAxisSpacing: 0.sp,
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
                                                                      categoryName:
                                                                          productController.mostSeachList[index]
                                                                              [
                                                                              "name"],
                                                                      categoryId:
                                                                          productController.mostSeachList[index]
                                                                              [
                                                                              "id"],
                                                                      brandId:
                                                                          0,
                                                                      genderName:
                                                                          "",
                                                                      genderType:
                                                                          0,
                                                                      categoryList: [],
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
                                                                  productController
                                                                              .mostSeachList[index]
                                                                          [
                                                                          "thumbnail"] !=
                                                                      null
                                                              ? SizedBox(
                                                                  width: 104.sp,
                                                                  height:
                                                                      130.sp,
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
                                                                    imageUrl: isImage(productController
                                                                                .mostSeachList[index]
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
                                                                      width: 104
                                                                          .sp,
                                                                      height:
                                                                          130.sp,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Center(
                                                                  child: Image.asset(
                                                                      dummyWishlistImage,
                                                                      width: 104
                                                                          .sp,
                                                                      height: 130
                                                                          .sp,
                                                                      fit: BoxFit
                                                                          .cover),
                                                                ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5.sp,
                                                                    vertical:
                                                                        6.sp),
                                                            child: AppText(
                                                              text: productController
                                                                  .mostSeachList[
                                                                      index]
                                                                      ["name"]
                                                                  .toUpperCase(),
                                                              color: blackColor,
                                                              fontSize: 13,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              maxLines: 1,
                                                              fontFamily:
                                                                  "Franklin Gothic",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
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
                                      ),
                                    ],
                                  )
                                : SizedBox(
                                    height: 0.sp,
                                  )),
                        /*  Obx(
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
                                                        ))?.then(
                                                            (value) => setState(
                                                                  () {
                                                                    brandController
                                                                        .getBrandData(
                                                                            "brand search");
                                                                  },
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
                                    onPressed: (p0, p1) async {
                                      if (isSearch) {
                                      } else {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ProductDetailsScreen(
                                                            brandName: p1,
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
                                  )), */
                      ],
                    ),
                  ),
                ),
              ],
            ),
            controller.searchController.text.isNotEmpty
                ? Container(
                    color: whiteColor,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        Obx(() => controller.isSearchItem.value
                            ? SizedBox(
                                height: 0,
                              )
                            : controller.searchList.isNotEmpty
                                ? Container(
                                    color: statusBarColor,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 40.sp,
                                              left: 16.sp,
                                              bottom: 10.sp),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  /*  setState(() {
                                          isSearch = false;
                                          controller.searchList.clear();
                                          controller.searchController.clear();
                                          controller.searchText.value =
                                              "Search for products";
                                        }); */
                                                  Get.back();
                                                },
                                                child: SvgPicture.asset(
                                                    arrowBack,
                                                    height: 15.sp,
                                                    width: 15.sp,
                                                    fit: BoxFit.cover),
                                              ),
                                              MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      600
                                                  ? Expanded(
                                                      flex: 1,
                                                      child: SizedBox(
                                                        height: 40.sp,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 4.sp),
                                                          child:
                                                              RawKeyboardListener(
                                                            focusNode:
                                                                FocusNode(),
                                                            onKey: (value) {
                                                              print(value);
                                                              if (value
                                                                  is RawKeyDownEvent) {
                                                                setState(() {
                                                                  isSearch =
                                                                      false;
                                                                  controller
                                                                          .searchText
                                                                          .value =
                                                                      "Search for products";
                                                                });
                                                              }
                                                            },
                                                            child: TextField(
                                                              textCapitalization:
                                                                  TextCapitalization
                                                                      .words,
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                  color:
                                                                      homeAppBarColor,
                                                                  fontFamily:
                                                                      "Franklin Gothic",
                                                                  fontSize:
                                                                      14.sp),
                                                              controller: controller
                                                                  .searchController,
                                                              onChanged:
                                                                  onSearchChanged,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              decoration:
                                                                  InputDecoration(
                                                                filled: true,
                                                                isDense: true,
                                                                fillColor:
                                                                    statusBarColor,
                                                                suffixIcon:
                                                                    IconButton(
                                                                  icon: SvgPicture.asset(
                                                                      crossSearchImage,
                                                                      color:
                                                                          homeAppBarColor,
                                                                      height:
                                                                          13.sp,
                                                                      width:
                                                                          13.sp,
                                                                      fit: BoxFit
                                                                          .cover),
                                                                  onPressed:
                                                                      () {
                                                                    controller
                                                                        .searchController
                                                                        .clear();
                                                                    controller
                                                                        .getSearchData(
                                                                            context);
                                                                    controller
                                                                            .searchText
                                                                            .value =
                                                                        "Search for products";
                                                                  },
                                                                ),
                                                                focusedBorder: const OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                statusBarColor)),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              1),
                                                                ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              1),
                                                                  borderSide:
                                                                      const BorderSide(
                                                                          color:
                                                                              statusBarColor),
                                                                ),
                                                                counterText: "",
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10.sp),
                                                                hintText:
                                                                    "Search for 'Bag'",
                                                                hintStyle:
                                                                    TextStyle(
                                                                  color:
                                                                      subtitleColor,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      "Franklin Gothic Regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Expanded(
                                                      flex: 1,
                                                      child: SizedBox(
                                                        height: 40.sp,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 4.sp),
                                                          child:
                                                              RawKeyboardListener(
                                                            focusNode:
                                                                FocusNode(),
                                                            onKey: (value) {
                                                              print(value);
                                                              if (value
                                                                  is RawKeyDownEvent) {
                                                                setState(() {
                                                                  isSearch =
                                                                      false;
                                                                  controller
                                                                          .searchText
                                                                          .value =
                                                                      "Search for products";
                                                                });
                                                              }
                                                            },
                                                            child: TextField(
                                                              textCapitalization:
                                                                  TextCapitalization
                                                                      .words,
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                  color:
                                                                      homeAppBarColor,
                                                                  fontFamily:
                                                                      "Franklin Gothic",
                                                                  fontSize:
                                                                      14.sp),
                                                              controller: controller
                                                                  .searchController,
                                                              onChanged:
                                                                  onSearchChanged,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              decoration:
                                                                  InputDecoration(
                                                                filled: true,
                                                                isDense: true,
                                                                suffixIcon:
                                                                    IconButton(
                                                                  icon: SvgPicture.asset(
                                                                      crossSearchImage,
                                                                      color:
                                                                          homeAppBarColor,
                                                                      height:
                                                                          13.sp,
                                                                      width:
                                                                          13.sp,
                                                                      fit: BoxFit
                                                                          .cover),
                                                                  onPressed:
                                                                      () {
                                                                    controller
                                                                        .searchController
                                                                        .clear();
                                                                    controller
                                                                        .getSearchData(
                                                                            context);
                                                                    controller
                                                                            .searchText
                                                                            .value =
                                                                        "Search for products";
                                                                  },
                                                                ),
                                                                fillColor:
                                                                    statusBarColor,
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              1),
                                                                ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              1),
                                                                  borderSide:
                                                                      const BorderSide(
                                                                          color:
                                                                              statusBarColor),
                                                                ),
                                                                counterText: "",
                                                                /*   contentPadding: EdgeInsets.symmetric(
                                                    horizontal: 10.sp), */
                                                                hintText:
                                                                    "Search for 'Bag'",
                                                                hintStyle:
                                                                    TextStyle(
                                                                  color:
                                                                      subtitleColor,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      "Franklin Gothic Regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 1.sp,
                                          color: dividerColor,
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(
                                    height: 0,
                                  )),
                        Column(
                          children: [
                            SizedBox(
                              height: 20.sp,
                            ),
                            Obx(() => controller.isSearchItem.value
                                ? SizedBox(
                                    //  height: 260.sp,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 5.sp,
                                          top: 80.sp,
                                          left: 16.sp),
                                      child: ListView.builder(
                                          primary: false,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
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
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    0.sp),
                                                        child: DummyContainer(
                                                            height: 16,
                                                            width: 100),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  16.sp),
                                                      child: DummyContainer(
                                                          height: 14,
                                                          width: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  )
                                : controller.searchList.isNotEmpty
                                    ? SizedBox(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 16.sp,
                                              bottom: 5.sp,
                                              top: 5.sp),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ListView.builder(
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: controller
                                                      .categoryList.length,
                                                  padding: EdgeInsets.zero,
                                                  //  scrollDirection: Axis.vertical,
                                                  itemBuilder: (ctx, i) {
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 4.sp),
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          Navigator.of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          CategoryProductScreen(
                                                                            categoryName:
                                                                                controller.categoryList[i]["name"],
                                                                            categoryId:
                                                                                controller.categoryList[i]["id"],
                                                                            brandId:
                                                                                0,
                                                                            genderType:
                                                                                0,
                                                                            genderName:
                                                                                "",
                                                                            tagIds: const [],
                                                                            categoryList: [],
                                                                          )))
                                                              .then(
                                                                  (value) =>
                                                                      setState(
                                                                        () {
                                                                          controller
                                                                              .searchController
                                                                              .clear();
                                                                          controller
                                                                              .getSearchData(context);
                                                                          isSearch =
                                                                              false;
                                                                          controller
                                                                              .searchText
                                                                              .value = "Search for products";
                                                                        },
                                                                      ));

                                                          /*  setState(() {
                                                            isSearch = false;
                                                            controller.searchText
                                                                    .value =
                                                                "Search for products";
                                                          }); */
                                                          await analytics
                                                              .logEvent(
                                                            name:
                                                                "search_page_searchcategory",
                                                            parameters: <String,
                                                                Object>{
                                                              'page_name':
                                                                  'search_page_searchcategory',
                                                            },
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      6.sp),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              /*  SizedBox(
                                                                height: 20.sp,
                                                                width: 20.sp,
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
                                                                  imageUrl: controller
                                                                          .categoryList[i]
                                                                      [
                                                                      "thumbnail"],
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Image
                                                                          .asset(
                                                                    downloadImage,
                                                                    height:
                                                                        20.sp,
                                                                    width:
                                                                        20.sp,
                                                                  ),
                                                                ),
                                                              ), */
                                                              Expanded(
                                                                flex: 1,
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              0.sp),
                                                                  child:
                                                                      AppText(
                                                                    text: controller.categoryList[i]
                                                                            [
                                                                            "name"] ??
                                                                        "",
                                                                    maxLines: 1,
                                                                    fontFamily:
                                                                        "Franklin Gothic Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        14,
                                                                    color:
                                                                        homeAppBarColor,
                                                                  ),
                                                                ),
                                                              ),
                                                              AppText(
                                                                text: controller
                                                                    .categoryList[
                                                                        i][
                                                                        "product_count"]
                                                                    .toString(),
                                                                maxLines: 1,
                                                                fontFamily:
                                                                    "Franklin Gothic Regular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 14,
                                                                color:
                                                                    homeAppBarColor,
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left: 8
                                                                            .sp,
                                                                        right: 16
                                                                            .sp),
                                                                child: SvgPicture.asset(
                                                                    searchSvgImage,
                                                                    height:
                                                                        16.sp,
                                                                    width:
                                                                        16.sp,
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                              Visibility(
                                                visible: controller
                                                        .categoryList.isNotEmpty
                                                    ? true
                                                    : false,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 16.sp,
                                                      bottom: 10.sp,
                                                      top: 10.sp),
                                                  child: Container(
                                                    height: 1.sp,
                                                    color: dividerColor,
                                                  ),
                                                ),
                                              ),
                                              ListView.builder(
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: controller
                                                      .searchList.length,
                                                  padding: EdgeInsets.zero,
                                                  itemBuilder: (ctx, index) {
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 4.sp),
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          Navigator.of(context)
                                                              .push(MaterialPageRoute(
                                                                  builder: (BuildContext context) => ProductDetailsScreen(
                                                                      brandName:
                                                                          controller.searchList[index]
                                                                              [
                                                                              "brand_name"],
                                                                      productId:
                                                                          controller.searchList[index]
                                                                              [
                                                                              "id"],
                                                                      type:
                                                                          "add")))
                                                              .then(
                                                                  (value) =>
                                                                      setState(
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
                                                                              .getSearchData(context);
                                                                        },
                                                                      ));
                                                          controller.callRecentSearch(
                                                              controller
                                                                      .searchList[
                                                                  index]["id"],
                                                              controller
                                                                      .searchList[
                                                                  index]["name"]);
                                                          setState(() {
                                                            isSearch = false;
                                                            controller
                                                                    .searchText
                                                                    .value =
                                                                "Search for products";
                                                          });
                                                          await analytics
                                                              .logEvent(
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
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      6.sp),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              /*   Icon(Icons.search,
                                                                  size: 20.sp,
                                                                  color: Colors
                                                                      .grey), */
                                                              Expanded(
                                                                flex: 1,
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              0.sp),
                                                                  child:
                                                                      AppText(
                                                                    text: controller.searchList[index]
                                                                            [
                                                                            "name"] ??
                                                                        "",
                                                                    maxLines: 1,
                                                                    fontFamily:
                                                                        "Franklin Gothic Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        14,
                                                                    color:
                                                                        homeAppBarColor,
                                                                  ),
                                                                ),
                                                              ),
                                                              /*  Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8.sp),
                                                                child: AppText(
                                                                  text: controller
                                                                      .searchList[
                                                                          index]
                                                                          [
                                                                          "hits"]
                                                                      .toString(),
                                                                  maxLines: 1,
                                                                  fontFamily:
                                                                      "Franklin Gothic Regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14,
                                                                  color:
                                                                      greyTextColor,
                                                                ),
                                                              ), */
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            16.sp),
                                                                child: SvgPicture.asset(
                                                                    arrowSearchImage,
                                                                    color:
                                                                        homeAppBarColor,
                                                                    height:
                                                                        13.sp,
                                                                    width:
                                                                        13.sp,
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 50.sp,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10.sp, left: 16.sp),
                                              child: Row(
                                                children: [
                                                  AppText(
                                                    text:
                                                        "No results found for",
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                    color: subtitleColor,
                                                    fontSize: 16,
                                                  ),
                                                  AppText(
                                                    text:
                                                        " '${controller.searchController.text.toString()}'",
                                                    fontFamily:
                                                        "Franklin Gothic Semibold",
                                                    fontWeight: FontWeight.w400,
                                                    color: subtitleColor,
                                                    fontSize: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 2.sp, left: 16.sp),
                                              child: AppText(
                                                text: "0 items",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: subtitleColor,
                                                fontSize: 10,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 80.sp),
                                              child: Center(
                                                child: Image.asset(errorImage,
                                                    height: 200.sp,
                                                    width: 220.sp,
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 20.sp),
                                              child: getSingleButton(
                                                  width: double.infinity,
                                                  label: "Back to home"
                                                      .toUpperCase(),
                                                  textColor: whiteColor,
                                                  fontSize: 13,
                                                  backgroundColor:
                                                      homeAppBarColor,
                                                  onPressed: () {
                                                    Get.off(BottomNavScreen());
                                                  },
                                                  borderColor: colorPrimary),
                                            )
                                          ],
                                        ),
                                      )),
                          ],
                        ),
                      ],
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
