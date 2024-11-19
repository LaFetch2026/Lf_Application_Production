// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_product_list.dart';
import 'package:lafetch/commonwidget/homewidget/horizontal_home_list.dart';
import 'package:lafetch/commonwidget/homewidget/question_card.dart';
import 'package:lafetch/controller/home_controller.dart';
import 'package:lafetch/controller/product_controller.dart';
import 'package:lafetch/screens/Brands/categoryproduct.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../commonwidget/app_text.dart';
import '../../../utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../account/customercare.dart';

class DiscountScreen extends StatefulWidget {
  final int tagId;
  final int genderType;
  const DiscountScreen(
      {super.key, required this.tagId, required this.genderType});

  @override
  State<DiscountScreen> createState() => DiscountScreenState();
}

class DiscountScreenState extends State<DiscountScreen> {
  final homeController = Get.put(HomeController());
  final productController = Get.put(ProductController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.currentPage.value = 0;
      productController.current.value = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.getConfigurationData();
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.tagsProductController.addListener(() {
        productController.fetchMoreTagsProductData(
            widget.tagId, widget.genderType, 0);
        productController.update();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.tagsHasnextpage.value = true;
      productController.tagsLoadMore.value = false;
      //  productController.istagsProduct.value = false;
      productController.tagsPage.value = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.expressListController.addListener(() {
        productController.fetchExpressMoreData(widget.tagId, widget.genderType);
        productController.update();
      });
    });
    /* WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.discountScreenController.addListener(() {
        print(homeController
            .discountScreenController.position.userScrollDirection);
        if (homeController
                .discountScreenController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          homeController.IsAnimateTag.value = false;
        }
        if (homeController
                .discountScreenController.position.userScrollDirection ==
            ScrollDirection.forward) {
          homeController.IsAnimateTag.value = true;
        }
      });
    }); */
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.expressHasnextpage.value = true;
      productController.expressLoadMore.value = false;
      //  productController.isExpress.value = false;
      productController.expressPage.value = 1;
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => homeController.getBannar1Data());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => homeController.getBannar2Data());
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => homeController.getCategoryData(widget.genderType));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        productController.homeTagshasnextpage.value = true;
        productController.homeTagsloadMore.value = false;
        // productController.istags.value = false;
        productController.homeTagsPage.value = 1;
      });
      productController.tagsController.addListener(() {
        productController.fetchMoreTagsData(widget.genderType);
        productController.update();
      });
    });
  }

  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('bannerImage') != null) {
      var list = prefs.getString('bannerImage');
      homeController.banners = jsonDecode(list!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        controller: homeController.discountScreenController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SaleCardWidget(),
            /*   const SizedBox(
              height: 10,
            ), */
            /*     Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: menu.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                current = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 5),
                              width: 100,
                              height: 30,
                              decoration: BoxDecoration(
                                color: current == index
                                    ? btnTextColor
                                    : whiteTextColor,
                                borderRadius: current == index
                                    ? BorderRadius.circular(20)
                                    : BorderRadius.circular(20),
                                border: current == index
                                    ? Border.all(color: btnTextColor, width: 1)
                                    : Border.all(
                                        color: textHintColor, width: 1),
                              ),
                              child: Center(
                                child: AppText(
                                  text: menu[index],
                                  color: current == index
                                      ? whiteBorderColor
                                      : textHintColor,
                                  fontSize: 12.sp,
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ),
           */
            Obx(() => productController.istags.value
                ? Padding(
                    padding: EdgeInsets.only(
                        left: 16.sp, bottom: 10.sp, right: 16.sp),
                    child: SizedBox(
                      height: 30.sp,
                      width: double.infinity,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: 5,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, index) {
                            return Container(
                              margin: EdgeInsets.only(right: 5.sp),
                              width: 100.sp,
                              height: 30.sp,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(20.sp),
                              ),
                            );
                          }),
                    ))
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.sp),
                    child: Center(
                      child: SizedBox(
                          width: double.infinity,
                          height: 50.sp,
                          child: GetBuilder<ProductController>(
                            builder: (value) => ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: productController.tagsList.length,
                                scrollDirection: Axis.horizontal,
                                controller: productController.tagsController,
                                itemBuilder: (ctx, index) {
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          productController.current.value =
                                              index;
                                          productController.tagId.value =
                                              productController.tagsList[index]
                                                  ["id"];
                                          productController.tagProductList
                                              .clear();
                                          productController.expressProductList
                                              .clear();
                                          productController
                                              .getExpressProductData(
                                                  productController.tagId.value,
                                                  widget.genderType);
                                          productController.getTagsProductData(
                                              productController.tagId.value,
                                              widget.genderType,
                                              0);
                                          productController.update();
                                          await analytics.logEvent(
                                            name: 'tabclick_home_page',
                                            parameters: <String, Object>{
                                              'page_name': 'tabclick_home_page',
                                            },
                                          );
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin: EdgeInsets.only(right: 5.sp),
                                          width: 100.sp,
                                          height: 30.sp,
                                          decoration: BoxDecoration(
                                            color: productController
                                                        .current.value ==
                                                    index
                                                ? btnTextColor
                                                : whiteColor,
                                            borderRadius: productController
                                                        .current.value ==
                                                    index
                                                ? BorderRadius.circular(20)
                                                : BorderRadius.circular(20),
                                            border: productController
                                                        .current.value ==
                                                    index
                                                ? Border.all(
                                                    color: btnTextColor,
                                                    width: 1)
                                                : Border.all(
                                                    color: textHintColor,
                                                    width: 1),
                                          ),
                                          child: Center(
                                            child: AppText(
                                              text: productController
                                                  .tagsList[index]["name"],
                                              color: productController
                                                          .current.value ==
                                                      index
                                                  ? whiteColor
                                                  : textHintColor,
                                              fontSize: 12,
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          )),
                    ),
                  )),
            Obx(() => homeController.isBanner1.value
                ? Padding(
                    padding: EdgeInsets.only(
                        left: 16.sp, bottom: 10.sp, right: 16.sp),
                    child: SizedBox(
                      height: 210.sp,
                      width: double.infinity,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: 5,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, index) {
                            return Container(
                              height: 210.sp,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                              ),
                            );
                          }),
                    ))
                : homeController.banner1List.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: 16.sp, bottom: 10.sp, right: 16.sp),
                        child: CarouselSlider.builder(
                          itemCount: homeController.banner1List.length,
                          options: CarouselOptions(
                            height: 210.sp,
                            viewportFraction: 1.0,
                            aspectRatio: 2.0,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 10),
                            enlargeCenterPage: true,
                          ),
                          itemBuilder: (BuildContext context, int itemIndex,
                                  int pageViewIndex) =>
                              GestureDetector(
                            onTap: () async {
                              homeController.bannerTag1Id.clear();
                              if (homeController
                                  .banner1List[itemIndex]["tags"].isNotEmpty) {
                                for (var i = 0;
                                    i <
                                        homeController
                                            .banner1List[itemIndex]["tags"]
                                            .length;
                                    i++) {
                                  homeController.bannerTag1Id.add(homeController
                                      .banner1List[itemIndex]["tags"][i]["id"]);
                                }
                                for (var i = 0;
                                    i <
                                        homeController
                                            .banner1List[itemIndex]
                                                ["categories"]
                                            .length;
                                    i++) {
                                  homeController.bannerCategory1Id.add(
                                      homeController.banner1List[itemIndex]
                                          ["categories"][i]["id"]);
                                }
                                print(homeController.bannerTag1Id);
                                Get.to(CategoryProductScreen(
                                  categoryName: "Product List",
                                  categoryId: 0,
                                  brandId: 0,
                                  genderType: widget.genderType,
                                  tagIds: homeController.bannerTag1Id,
                                  categoryList:
                                      homeController.bannerCategory1Id,
                                ));
                                await analytics.logEvent(
                                  name: 'banner_home_page',
                                  parameters: <String, Object>{
                                    'page_name': 'banner_home_page',
                                  },
                                );
                              }
                            },
                            child: CachedNetworkImage(
                              cacheManager: CacheManager(Config(
                                  "customCacheKey",
                                  stalePeriod: const Duration(days: 15),
                                  maxNrOfCacheObjects: 100)),
                              fit: BoxFit.fill,
                              imageUrl: homeController.banner1List[itemIndex]
                                  ["image"],
                              height: 210.sp,
                              width: MediaQuery.of(context).size.width,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                child: Container(
                                  height: 210.sp,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.04),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                downloadImage,
                                height: 210.sp,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 0,
                      )),
            /* Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp),
              child: Container(
                width: double.infinity,
                color: colorSecondary,
                height: 1,
              ),
            ),
            Obx(() => productController.isExpress.value
                ? const DummyProductList(text: "Express Delivery")
                : productController.expressProductList.isNotEmpty
                    ? HorizontalHomeList(
                        text: "Express Delivery",
                        height: 250.sp,
                        controller: productController.expressListController,
                        list: productController.expressProductList,
                        visibleExpress: true,
                        onPressed: (p0, p1) async {
                          Get.to(
                            ProductDetailsScreen(
                              productId: p0,
                              type: "add",
                              brandName: p1,
                            ),
                          )?.then((value) => setState(
                                () {
                                  productController.expressHasnextpage.value =
                                      true;
                                  productController.expressLoadMore.value =
                                      false;
                                  productController.isExpress.value = false;
                                  productController.expressPage.value = 1;
                                },
                              ));
                          await analytics.logEvent(
                            name: 'expressproductDetails_home_page',
                            parameters: <String, Object>{
                              'page_name': 'expressproductDetails_home_page',
                            },
                          );
                        },
                      )
                    : SizedBox(
                        height: 0,
                      )),
           */
            Obx(() => productController.istagsProduct.value
                ? const DummyProductList(text: "We think you might also like")
                : productController.tagProductList.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(top: 10.sp),
                        child: HorizontalHomeList(
                          text: "We think you might also like",
                          controller: productController.tagsProductController,
                          height: 250.sp,
                          visibleExpress: false,
                          onPressed: (p0, p1) async {
                            Get.to(
                              ProductDetailsScreen(
                                productId: p0,
                                type: "add",
                                brandName: p1,
                              ),
                            )?.then((value) => setState(
                                  () {
                                    productController.tagsHasnextpage.value =
                                        true;
                                    productController.tagsLoadMore.value =
                                        false;
                                    productController.istagsProduct.value =
                                        false;
                                    productController.tagsPage.value = 1;
                                  },
                                ));
                            await analytics.logEvent(
                              name: 'product_tabid_details_home_page',
                              parameters: <String, Object>{
                                'page_name': 'product_tabid_details_home_page',
                              },
                            );
                          },
                          list: productController.tagProductList,
                        ),
                      )
                    : const SizedBox(
                        height: 0,
                      )),
            Obx(
              () => homeController.isCategory.value
                  ? const DummyProductList(text: "Popular Categories")
                  : homeController.categoryList.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 10.sp, left: 16.sp),
                              child: AppText(
                                text: "Popular Categories",
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: blackColor,
                                fontSize: 16,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp,
                                  right: 16.sp,
                                  top: 15.sp,
                                  bottom: 10.sp),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  homeController.categoryList.length >= 1
                                      ? GestureDetector(
                                          onTap: () async {
                                            Get.to(CategoryProductScreen(
                                                categoryName: homeController
                                                    .categoryList[0]["name"],
                                                categoryId: homeController
                                                    .categoryList[0]["id"],
                                                brandId: 0,
                                                genderType: widget.genderType,
                                                categoryList: [],
                                                tagIds: const []));
                                            await analytics.logEvent(
                                              name: 'categories_home_page',
                                              parameters: <String, Object>{
                                                'page_name':
                                                    'categories_home_page',
                                              },
                                            );
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            margin:
                                                EdgeInsets.only(right: 8.sp),
                                            height: 180.sp,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                homeController.categoryList[0]
                                                            ["thumbnail"] !=
                                                        null
                                                    ? SizedBox(
                                                        height: 144.sp,
                                                        width: (MediaQuery.sizeOf(
                                                                        context)
                                                                    .width /
                                                                2) -
                                                            20.sp,
                                                        child:
                                                            CachedNetworkImage(
                                                          cacheManager: CacheManager(Config(
                                                              "customCacheKey",
                                                              stalePeriod:
                                                                  const Duration(
                                                                      days: 15),
                                                              maxNrOfCacheObjects:
                                                                  100)),
                                                          fit: BoxFit.cover,
                                                          imageUrl: homeController
                                                                  .categoryList[
                                                              0]["thumbnail"],
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Image.asset(
                                                            downloadImage,
                                                            fit: BoxFit.cover,
                                                            height: 144.sp,
                                                            width: (MediaQuery.sizeOf(
                                                                            context)
                                                                        .width /
                                                                    2) -
                                                                20.sp,
                                                          ),
                                                        ),
                                                      )
                                                    : Image.asset(
                                                        dummyWishlistImage,
                                                        height: 144.sp,
                                                        width: (MediaQuery.sizeOf(
                                                                        context)
                                                                    .width /
                                                                2) -
                                                            20.sp,
                                                        fit: BoxFit.cover),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.sp,
                                                      vertical: 5.sp),
                                                  child: AppText(
                                                    text: homeController
                                                                .categoryList[0]
                                                            ["name"] ??
                                                        "",
                                                    color: greyTextColor,
                                                    fontSize: 10,
                                                    maxLines: 2,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : const SizedBox(
                                          width: 0,
                                        ),
                                  homeController.categoryList.length >= 2
                                      ? GestureDetector(
                                          onTap: () async {
                                            Get.to(CategoryProductScreen(
                                                categoryName: homeController
                                                    .categoryList[1]["name"],
                                                categoryId: homeController
                                                    .categoryList[1]["id"],
                                                brandId: 0,
                                                categoryList: [],
                                                genderType: widget.genderType,
                                                tagIds: const []));
                                            await analytics.logEvent(
                                              name: 'categories_home_page',
                                              parameters: <String, Object>{
                                                'page_name':
                                                    'categories_home_page',
                                              },
                                            );
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            height: 180.sp,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                homeController.categoryList[1]
                                                            ["thumbnail"] !=
                                                        null
                                                    ? SizedBox(
                                                        height: 144.sp,
                                                        width: (MediaQuery.sizeOf(
                                                                        context)
                                                                    .width /
                                                                2) -
                                                            20.sp,
                                                        child:
                                                            CachedNetworkImage(
                                                          cacheManager: CacheManager(Config(
                                                              "customCacheKey",
                                                              stalePeriod:
                                                                  const Duration(
                                                                      days: 15),
                                                              maxNrOfCacheObjects:
                                                                  100)),
                                                          fit: BoxFit.cover,
                                                          imageUrl: homeController
                                                                  .categoryList[
                                                              1]["thumbnail"],
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Image.asset(
                                                            downloadImage,
                                                            fit: BoxFit.cover,
                                                            height: 144.sp,
                                                            width: (MediaQuery.sizeOf(
                                                                            context)
                                                                        .width /
                                                                    2) -
                                                                20.sp,
                                                          ),
                                                        ),
                                                      )
                                                    : Image.asset(
                                                        dummyWishlistImage,
                                                        height: 144.sp,
                                                        width: (MediaQuery.sizeOf(
                                                                        context)
                                                                    .width /
                                                                2) -
                                                            20.sp,
                                                        fit: BoxFit.cover),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.sp,
                                                      vertical: 5.sp),
                                                  child: AppText(
                                                    text: homeController
                                                                .categoryList[1]
                                                            ["name"] ??
                                                        "",
                                                    color: greyTextColor,
                                                    fontSize: 10,
                                                    maxLines: 2,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : const SizedBox(
                                          width: 0,
                                        ),
                                ],
                              ),
                            ),
                            homeController.categoryList.length >= 3
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.sp),
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
                                          homeController.categoryList.length -
                                              2,
                                          (index) {
                                            return Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    Get.to(CategoryProductScreen(
                                                        categoryName:
                                                            homeController
                                                                    .categoryList[
                                                                index +
                                                                    2]["name"],
                                                        categoryId: homeController
                                                                .categoryList[
                                                            index + 2]["id"],
                                                        brandId: 0,
                                                        categoryList: [],
                                                        genderType:
                                                            widget.genderType,
                                                        tagIds: const []));
                                                    await analytics.logEvent(
                                                      name:
                                                          'categories_home_page',
                                                      parameters: <String,
                                                          Object>{
                                                        'page_name':
                                                            'categories_home_page',
                                                      },
                                                    );
                                                  },
                                                  child: SizedBox(
                                                    height: 110.sp,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Center(
                                                          child: homeController
                                                                              .categoryList[
                                                                          index +
                                                                              2]
                                                                      [
                                                                      "thumbnail"] !=
                                                                  null
                                                              ? SizedBox(
                                                                  width: 80.sp,
                                                                  height: 72.sp,
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
                                                                    imageUrl: homeController
                                                                            .categoryList[
                                                                        index +
                                                                            2]["thumbnail"],
                                                                    /*   progressIndicatorBuilder:
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
                                                                        Image
                                                                            .asset(
                                                                      downloadImage,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width:
                                                                          80.sp,
                                                                      height:
                                                                          72.sp,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Image.asset(
                                                                  dummyWishlistImage,
                                                                  width: 80.sp,
                                                                  height: 72.sp,
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
                                                            text: homeController
                                                                            .categoryList[
                                                                        index +
                                                                            2]
                                                                    ["name"] ??
                                                                "",
                                                            color:
                                                                greyTextColor,
                                                            textAlign: TextAlign
                                                                .center,
                                                            fontSize: 10,
                                                            maxLines: 2,
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
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    width: 0,
                                  ),
                          ],
                        )
                      : SizedBox(
                          height: 0,
                        ),
            ),
            Obx(
              () => homeController.isBanner2.value
                  ? Padding(
                      padding: EdgeInsets.only(
                          left: 16.sp, bottom: 10.sp, right: 16.sp),
                      child: SizedBox(
                        height: 210.sp,
                        width: double.infinity,
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: 5,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (ctx, index) {
                              return Container(
                                height: 210.sp,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.04),
                                ),
                              );
                            }),
                      ))
                  : Column(
                      children: [
                        homeController.banner2List.isNotEmpty
                            ? CarouselSlider.builder(
                                itemCount: homeController.banner2List.length,
                                options: CarouselOptions(
                                  height: 210.sp,
                                  autoPlayInterval: const Duration(seconds: 10),
                                  onPageChanged: (index, reason) {
                                    homeController.currentPage.value = index;
                                    homeController.update();
                                  },
                                  viewportFraction: 1.0,
                                  aspectRatio: 2.0,
                                  autoPlay: true,
                                  enlargeCenterPage: true,
                                ),
                                itemBuilder: (BuildContext context,
                                        int itemIndex, int pageViewIndex) =>
                                    GestureDetector(
                                  onTap: () async {
                                    homeController.bannerTag2Id.clear();
                                    if (homeController
                                        .banner2List[itemIndex]["tags"]
                                        .isNotEmpty) {
                                      for (var i = 0;
                                          i <
                                              homeController
                                                  .banner2List[itemIndex]
                                                      ["tags"]
                                                  .length;
                                          i++) {
                                        homeController.bannerTag2Id.add(
                                            homeController
                                                    .banner2List[itemIndex]
                                                ["tags"][i]["id"]);
                                      }
                                      for (var i = 0;
                                          i <
                                              homeController
                                                  .banner2List[itemIndex]
                                                      ["categories"]
                                                  .length;
                                          i++) {
                                        homeController.bannerCategory2Id.add(
                                            homeController
                                                    .banner2List[itemIndex]
                                                ["categories"][i]["id"]);
                                      }
                                      print(homeController.bannerTag2Id);
                                      Get.to(CategoryProductScreen(
                                        categoryName: "Product List",
                                        categoryId: 0,
                                        brandId: 0,
                                        genderType: widget.genderType,
                                        tagIds: homeController.bannerTag2Id,
                                        categoryList:
                                            homeController.bannerCategory2Id,
                                      ));
                                      await analytics.logEvent(
                                        name: 'promotion_home_page',
                                        parameters: <String, Object>{
                                          'page_name': 'promotion_home_page',
                                        },
                                      );
                                    }
                                  },
                                  child: CachedNetworkImage(
                                    cacheManager: CacheManager(Config(
                                        "customCacheKey",
                                        stalePeriod: const Duration(days: 15),
                                        maxNrOfCacheObjects: 100)),
                                    fit: BoxFit.fill,
                                    height: 210.sp,
                                    width: MediaQuery.of(context).size.width,
                                    imageUrl: homeController
                                        .banner2List[itemIndex]["image"],
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            Center(
                                      child: Container(
                                        height: 210.sp,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.04),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      downloadImage,
                                      height: 210.sp,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(
                                height: 0,
                              ),
                        SizedBox(
                          height: 20.sp,
                        ),
                        homeController.banner2List.length == 1
                            ? SizedBox(
                                height: 0,
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: SizedBox(
                                  width: 50 *
                                      homeController.banner2List.length
                                          .toDouble(),
                                  height: 6,
                                  child: GetBuilder<HomeController>(
                                      builder: (value) => ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: value.banner2List.length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (ctx, index) {
                                            return AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 400),
                                                height: 6.sp,
                                                width: 40.sp,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 5.sp),
                                                decoration: BoxDecoration(
                                                    color: index ==
                                                            value.currentPage
                                                                .value
                                                        ? colorPrimary
                                                        : colorSecondary));
                                          })),
                                ),
                              ),
                        /*  Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List<Widget>.generate(
                                        homeController.banner2List.length,
                                        (int index) {
                                      return AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 400),
                                          height: 6,
                                          width: 40,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                              color: index ==
                                                      homeController
                                                          .currentPage.value
                                                  ? colorPrimary
                                                  : colorSecondary));
                                    })),
                              ),
                            ),
                          ),
                        ) */
                      ],
                    ),
            ),
            SizedBox(
              height: 20.sp,
            ),
            //  const LafetchCardWidget(),
            QuestionCardWidget(
                text1: "FAQs",
                text2: "Your questions answered",
                size: 26.sp,
                onPressed: () async {
                  await analytics.logEvent(
                    name: 'FAQ_home_page',
                    parameters: <String, Object>{
                      'page_name': 'FAQ_home_page',
                    },
                  );
                },
                icon: question2Image),
            QuestionCardWidget(
                text1: "Need Help?",
                text2: "Contact customer service",
                size: 32.sp,
                onPressed: () async {
                  Get.to(CustomerCareScreen());
                  await analytics.logEvent(
                    name: 'needhelp_home_page',
                    parameters: <String, Object>{
                      'page_name': 'needhelp_home_page',
                    },
                  );
                },
                icon: questionIcon),
            SizedBox(
              height: 40.sp,
            )
          ],
        ),
      ),
    );
  }
}
