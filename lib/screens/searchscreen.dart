// ignore_for_file: avoid_print

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/brandsscreen.dart';
import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';
import '../commonwidget/homewidget/horizontal_home_list.dart';
import '../controller/brand_controller.dart';
import '../controller/product_controller.dart';
import '../controller/search_controller.dart';
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
  bool isSearch = false;
  Timer? debounce;

  /*  List<String> products = [
    "Salwar Suits",
    "Printed loose t-shirts",
    "Clothing",
    "Duffle bags",
    "Tuxedos"
  ]; */
  List<String> items = [
    "100",
    "200",
    "300",
    "400",
    "100",
    "200",
    "300",
    "400",
  ];
  List<String> searchItem = [
    "100",
    "200",
    "300",
    "400",
    "500",
    "400",
    "500",
  ];

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
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 40, bottom: 20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: ImageIcon(
                              AssetImage(backWhiteArrow),
                              color: whiteBorderColor,
                              size: 24,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              if (isSearch) {
                                isSearch = false;
                              } else {
                                isSearch = true;
                              }
                              setState(() {});
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: whiteBorderColor,
                                  borderRadius: BorderRadius.circular(1),
                                  border: Border.all(
                                      color: colorSecondary, width: 1)),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16),
                                child: Row(
                                  children: [
                                    const ImageIcon(
                                      AssetImage(searchImage),
                                      color: textHintColor,
                                      size: 14,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: AppText(
                                        text: "Search for brands & products",
                                        color: textHintColor,
                                        fontSize: 14.sp,
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
                        Obx(
                          () => controller.isRecentSearch.value
                              ? const Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 16),
                                      child: AppText(
                                        text: "Recent Searches",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: bottomnavBack,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16, top: 20),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        controller: ScrollController(),
                                        child: Wrap(
                                          direction: Axis.horizontal,
                                          spacing: 5.0,
                                          runSpacing: 9.0,
                                          runAlignment:
                                              WrapAlignment.spaceEvenly,
                                          children: [
                                            for (var product
                                                in controller.recentSearchList)
                                              GestureDetector(
                                                onTap: () {
                                                  Get.to(ProductDetailsScreen(
                                                      productId:
                                                          product["product"]
                                                              ["id"]));
                                                },
                                                child: Container(
                                                  height: 33,
                                                  margin: const EdgeInsets.only(
                                                      right: 5),
                                                  decoration: BoxDecoration(
                                                      color: whiteColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      border: Border.all(
                                                          color: btnTextColor,
                                                          width: 1)),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10,
                                                        vertical: 7),
                                                    child: Text(
                                                      product["search_string"],
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
                                ),
                        ),
                        Obx(() => productController.isMostSearch.value
                            ? const Padding(
                                padding: EdgeInsets.all(40.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : productController.mostSeachList.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 30, left: 16),
                                        child: AppText(
                                          text: "Most Searched",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: bottomnavBack,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16,
                                            top: 20,
                                            right: 16,
                                            bottom: 10),
                                        child: Center(
                                          child: GridView.count(
                                            shrinkWrap: true,
                                            crossAxisCount: 4,
                                            scrollDirection: Axis.vertical,
                                            padding: EdgeInsets.zero,
                                            childAspectRatio: 0.7,
                                            physics: const ScrollPhysics(),
                                            crossAxisSpacing: 5,
                                            mainAxisSpacing: 1,
                                            children: List.generate(
                                              productController
                                                  .mostSeachList.length,
                                              (index) {
                                                return Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Get.to(ProductDetailsScreen(
                                                            productId: productController
                                                                    .mostSeachList[
                                                                index]["id"]));
                                                      },
                                                      child: SizedBox(
                                                        height: 100,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            productController
                                                                        .mostSeachList[
                                                                            index]
                                                                            [
                                                                            "images"]
                                                                        .isNotEmpty &&
                                                                    productController.mostSeachList[index]
                                                                            [
                                                                            "images"] !=
                                                                        null
                                                                ? SizedBox(
                                                                    width: 80,
                                                                    height: 72,
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
                                                                      imageUrl: productController.mostSeachList[index]["images"]
                                                                              [
                                                                              0]
                                                                          [
                                                                          "name"],
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Image
                                                                              .asset(
                                                                        downloadImage,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        width:
                                                                            80,
                                                                        height:
                                                                            72,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Center(
                                                                    child: Image.asset(
                                                                        dummyWishlistImage,
                                                                        width:
                                                                            80,
                                                                        height:
                                                                            72,
                                                                        fit: BoxFit
                                                                            .cover),
                                                                  ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                              child: AppText(
                                                                text: productController
                                                                        .mostSeachList[
                                                                    index]["name"],
                                                                color:
                                                                    greyTextColor,
                                                                fontSize: 10.sp,
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
                                : const SizedBox(
                                    height: 10,
                                  )),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: AppText(
                            text: "Continue Browsing these Brands",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: bottomnavBack,
                            fontSize: 16.sp,
                          ),
                        ),
                        Obx(
                          () => brandController.isBrand.value
                              ? const Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 20),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 230,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        primary: false,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount:
                                            brandController.brandList.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (ctx, index) {
                                          return Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Get.to(BrandsScreen(
                                                    screen: "search",
                                                    logo: brandController
                                                            .brandList[index]
                                                        ["logo"],
                                                    backImage: brandController
                                                                    .brandList[
                                                                index][
                                                            "background_image"] ??
                                                        "",
                                                    name: brandController
                                                            .brandList[index]
                                                        ["name"],
                                                    brandId: brandController
                                                        .brandList[index]["id"],
                                                  ));
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  margin: const EdgeInsets.only(
                                                      right: 10),
                                                  width: 130,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      brandController.brandList[
                                                                      index]
                                                                  ["logo"] !=
                                                              null
                                                          ? SizedBox(
                                                              height: 180,
                                                              width: 130,
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
                                                                imageUrl: brandController
                                                                        .brandList[
                                                                    index]["logo"],
                                                                /*  progressIndicatorBuilder:
                                                                    (context,
                                                                            url,
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
                                                                  height: 180,
                                                                  width: 130,
                                                                ),
                                                              ),
                                                            )
                                                          : Image.asset(
                                                              dummyWishlistImage,
                                                              height: 180,
                                                              width: 130,
                                                              fit:
                                                                  BoxFit.cover),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10,
                                                                vertical: 5),
                                                        child: AppText(
                                                          text: brandController
                                                                  .brandList[
                                                              index]["name"],
                                                          color: greyTextColor,
                                                          fontSize: 14.sp,
                                                          fontFamily:
                                                              "Franklin Gothic",
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10,
                                                                vertical: 3),
                                                        child: AppText(
                                                          text: brandController
                                                                  .brandList[
                                                                      index][
                                                                      "categories"]
                                                                  .isNotEmpty
                                                              ? brandController
                                                                              .brandList[
                                                                          index]
                                                                      [
                                                                      "categories"]
                                                                  [0]["name"]
                                                              : "",
                                                          color: greyTextColor,
                                                          fontSize: 10.sp,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
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
                            ? const Padding(
                                padding: EdgeInsets.all(40.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : productController.productList.isNotEmpty
                                ? HorizontalHomeList(
                                    text: "Items you have viewed",
                                    height: 250,
                                    controller:
                                        productController.recentListController,
                                    visibleExpress: false,
                                    textColor: bottomnavBack,
                                    fontFamily: "Franklin Gothic Regular",
                                    onPressed: (p0) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  ProductDetailsScreen(
                                                    productId: p0,
                                                  )))
                                          .then((value) => setState(
                                                () {
                                                  productController
                                                      .hasnextpage.value = true;
                                                  productController
                                                      .loadMore.value = false;
                                                  productController
                                                      .isProduct.value = false;
                                                  productController.page.value =
                                                      1;
                                                  productController
                                                      .getProductData(
                                                          "relevant");
                                                },
                                              ));
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
                    height: 290,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 30, left: 16, right: 16, bottom: 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: const ImageIcon(
                                  AssetImage(backWhiteArrow),
                                  color: colorPrimary,
                                  size: 24,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 40,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: RawKeyboardListener(
                                      focusNode: FocusNode(),
                                      onKey: (value) {
                                        print(value);
                                        if (value is RawKeyDownEvent) {
                                          setState(() {
                                            isSearch = false;
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
                                          fillColor: whiteColor,
                                          suffixIcon: InkWell(
                                            onTap: () {
                                              controller.searchController
                                                  .clear();
                                            },
                                            child: Image.asset(
                                              greyCrossImage,
                                              height: 18,
                                              width: 18,
                                            ),
                                          ),
                                          prefixIcon: const Icon(Icons.search,
                                              size: 20, color: Colors.grey),
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
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10),
                                          hintText: "Search",
                                          hintStyle:
                                              const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Obx(() => controller.isSearchItem.value
                              ? const Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : controller.searchList.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 4, top: 8),
                                      child: SizedBox(
                                        height: 187,
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    controller.callRecentSearch(
                                                        controller.searchList[
                                                            index]["id"],
                                                        controller
                                                            .searchController
                                                            .text
                                                            .toString()
                                                            .trim());
                                                    setState(() {
                                                      isSearch = false;
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 6),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Icon(Icons.search,
                                                            size: 20,
                                                            color: Colors.grey),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        12),
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
                                                              fontSize: 14.sp,
                                                              color: loginText,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8),
                                                          child: AppText(
                                                            text: "41",
                                                            maxLines: 1,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14.sp,
                                                            color:
                                                                greyTextColor,
                                                          ),
                                                        ),
                                                        Image.asset(
                                                            curveArrowImage,
                                                            height: 12,
                                                            width: 12,
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
                                      margin: const EdgeInsets.only(top: 100),
                                      child: const Center(
                                        child: Text("No Item Found",
                                            style: TextStyle(
                                                fontSize: 14,
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
