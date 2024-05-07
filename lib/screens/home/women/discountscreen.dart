// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/homewidget/horizontal_home_list.dart';
import 'package:lafetch/commonwidget/homewidget/question_card.dart';
import 'package:lafetch/controller/home_controller.dart';
import 'package:lafetch/controller/product_controller.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import '../../../commonwidget/app_text.dart';
import '../../../commonwidget/homewidget/lafetch_card.dart';
import '../../../utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DiscountScreen extends StatefulWidget {
  const DiscountScreen({super.key});

  @override
  State<DiscountScreen> createState() => DiscountScreenState();
}

class DiscountScreenState extends State<DiscountScreen> {
  final homeController = Get.put(HomeController());
  final productController = Get.put(ProductController());
  List<String> menu = [
    "Discounts",
    "New Arrivals",
    "Clothing",
    "Footwear",
  ];
  int current = 0;

  @override
  void dispose() {
    super.dispose();
    homeController.timer?.cancel();
  }

  callOnchanged(int index) {
    setState(() {
      homeController.currentPage.value = index;
    });
  }

  @override
  void initState() {
    super.initState();
    productController.listController.addListener(() {
      print("pages${productController.page.value}");
      productController.fetchMoreData("relevant");
      productController.update();
    });
    productController.hasnextpage.value = true;
    productController.loadMore.value = false;
    productController.isProduct.value = false;
    productController.page.value = 1;
    productController.expressListController.addListener(() {
      productController.fetchExpressMoreData();
      productController.update();
    });
    productController.expressHasnextpage.value = true;
    productController.expressLoadMore.value = false;
    productController.isExpress.value = false;
    productController.expressPage.value = 1;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => homeController.getBannar1Data());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => homeController.getBannar2Data());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => homeController.getCategoryData());
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant"));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => productController.getExpressProductData());
    /* homeController.timer =
        Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (homeController.currentPage.value < 2) {
        homeController.currentPage.value++;
      } else {
        homeController.currentPage.value = 0;
      }
      homeController.pageController.animateToPage(
        homeController.currentPage.value,
        duration: const Duration(milliseconds: 2000),
        curve: Curves.easeIn,
      );
      homeController.update();
    }); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SaleCardWidget(),
            const SizedBox(
              height: 16,
            ),
            Padding(
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
            Obx(
              () => homeController.isBanner1.value
                  ? const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                          left: 16, bottom: 10, right: 16),
                      child: SizedBox(
                        height: 210,
                        child: PageView.builder(
                          scrollDirection: Axis.horizontal,
                          //  controller: homeController..pageController,
                          itemCount: homeController.banner1List.length,
                          itemBuilder: (context, int index) {
                            return CachedNetworkImage(
                              key: UniqueKey(),
                              cacheManager: CacheManager(Config(
                                  "customCacheKey",
                                  stalePeriod: const Duration(days: 15),
                                  maxNrOfCacheObjects: 100)),
                              fit: BoxFit.cover,
                              imageUrl: homeController.banner1List[index]
                                  ["image"],
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                downloadImage,
                                height: 210,
                              ),
                            );
                            /* FadeInImage(
                                    fit: BoxFit.cover,
                                    height: 210,
                                    width: double.infinity,
                                    image: NetworkImage(homeController
                                        .banner1List[index]["image"]),
                                    placeholder:
                                        const AssetImage(placeHolderImage)); */
                          },
                        ),
                        /* ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: homeController.banner1List.length,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.zero,
                                itemBuilder: (ctx, index) {
                                  return FadeInImage(
                                      fit: BoxFit.cover,
                                      height: 210,
                                      width: MediaQuery.of(context).size.width,
                                      image: NetworkImage(homeController
                                          .banner1List[index]["image"]),
                                      placeholder:
                                          const AssetImage(downloadImage));
                                }), */
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: double.infinity,
                color: colorSecondary,
                height: 1,
              ),
            ),
            Obx(() => productController.isExpress.value
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : /*  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 16),
                        child: AppText(
                          text: "6 hour Express Delivery",
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w500,
                          color: blackColor,
                          fontSize: 16.sp,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: SizedBox(
                          width: double.infinity,
                          height: 250,
                          child: ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              physics: const BouncingScrollPhysics(),
                              itemCount: productController.productList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (ctx, index) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(() => ProductDetailsScreen(
                                              productId: productController
                                                  .productList[index]["id"],
                                            ));
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.only(right: 5),
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
                                                text: productController
                                                            .productList[index]
                                                        ["name"] ??
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
                                                  top: 10, left: 10, right: 10),
                                              child: Row(
                                                children: [
                                                  AppText(
                                                    text:
                                                        "\u{20B9} ${productController.productList[index]["price"] ?? ""}",
                                                    color: deepGreytextColor,
                                                    maxLines: 2,
                                                    fontSize: 11.sp,
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w500,
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
                                                  top: 10, left: 10, right: 10),
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
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ),
                    ],
                  ) */
                HorizontalHomeList(
                    text: "6 hour Express Delivery",
                    height: 250,
                    controller: productController.expressListController,
                    list: productController.expressProductList,
                    visibleExpress: true,
                    onPressed: (p0) {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ProductDetailsScreen(
                                    productId: p0,
                                  )))
                          .then((value) => setState(
                                () {
                                  productController.expressHasnextpage.value =
                                      true;
                                  productController.expressLoadMore.value =
                                      false;
                                  productController.isExpress.value = false;
                                  productController.expressPage.value = 1;
                                  //  productController.getExpressProductData();
                                },
                              ));
                    },
                  )),
            Obx(() => productController.isProduct.value
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : /* Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 16),
                        child: AppText(
                          text: "We think you might also like",
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w500,
                          color: blackColor,
                          fontSize: 16.sp,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: SizedBox(
                          width: double.infinity,
                          height: 250,
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: productController.productList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (ctx, index) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.only(right: 5),
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
                                                text: productController
                                                            .productList[index]
                                                        ["name"] ??
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
                                                  top: 10, left: 10, right: 10),
                                              child: Row(
                                                children: [
                                                  AppText(
                                                    text:
                                                        "\u{20B9} ${productController.productList[index]["price"] ?? ""}",
                                                    color: deepGreytextColor,
                                                    maxLines: 2,
                                                    fontSize: 11.sp,
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w500,
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
                  ) */
                HorizontalHomeList(
                    text: "We think you might also like",
                    controller: productController.listController,
                    height: 250,
                    visibleExpress: false,
                    onPressed: (p0) {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ProductDetailsScreen(
                                    productId: p0,
                                  )))
                          .then((value) => setState(
                                () {
                                  productController.hasnextpage.value = true;
                                  productController.loadMore.value = false;
                                  productController.isProduct.value = false;
                                  productController.page.value = 1;
                                  //   productController.getProductData("relevant");
                                },
                              ));
                    },
                    list: productController.productList,
                  )),
            Obx(
              () => homeController.isCategory.value
                  ? const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 0, left: 16),
                          child: AppText(
                            text: "Popular Categories",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: blackColor,
                            fontSize: 16.sp,
                          ),
                        ),
                        /*  Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: SizedBox(
                            width: double.infinity,
                            height: 180,
                            child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: homeController.categoryList.length,
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
                                              const EdgeInsets.only(right: 10),
                                          width: 150,
                                          height: 180,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Image.asset(categoryImage,
                                                  height: 144,
                                                  width: 150,
                                                  fit: BoxFit.cover),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: AppText(
                                                  text: homeController
                                                              .categoryList[
                                                          index]["name"] ??
                                                      "",
                                                  color: greyTextColor,
                                                  fontSize: 10.sp,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
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
                        ), */
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // ignore: prefer_is_empty
                              homeController.categoryList.length >= 1
                                  ? GestureDetector(
                                      onTap: () {},
                                      child: Expanded(
                                        flex: 1,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          //  width: 150,
                                          height: 180,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              homeController.categoryList[0]
                                                          ["thumbnail"] !=
                                                      null
                                                  ? SizedBox(
                                                      height: 144,
                                                      width: 150,
                                                      child: CachedNetworkImage(
                                                        cacheManager:
                                                            CacheManager(Config(
                                                                "customCacheKey",
                                                                stalePeriod:
                                                                    const Duration(
                                                                        days:
                                                                            15),
                                                                maxNrOfCacheObjects:
                                                                    100)),
                                                        fit: BoxFit.cover,
                                                        imageUrl: homeController
                                                                .categoryList[0]
                                                            ["thumbnail"],
                                                        /*  progressIndicatorBuilder:
                                                            (context, url,
                                                                    downloadProgress) =>
                                                                Center(
                                                          child: CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress),
                                                        ), */
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          downloadImage,
                                                          fit: BoxFit.cover,
                                                          height: 144,
                                                          width: 150,
                                                        ),
                                                      ),
                                                    )
                                                  : Image.asset(
                                                      dummyWishlistImage,
                                                      height: 144,
                                                      width: 150,
                                                      fit: BoxFit.cover),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: AppText(
                                                  text: homeController
                                                              .categoryList[0]
                                                          ["name"] ??
                                                      "",
                                                  color: greyTextColor,
                                                  fontSize: 10.sp,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(
                                      width: 0,
                                    ),
                              const Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: 10,
                                ),
                              ),
                              homeController.categoryList.length >= 2
                                  ? GestureDetector(
                                      onTap: () {},
                                      child: Expanded(
                                        flex: 1,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          // width: 150,
                                          height: 180,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              homeController.categoryList[1]
                                                          ["thumbnail"] !=
                                                      null
                                                  ? SizedBox(
                                                      height: 144,
                                                      width: 150,
                                                      child: CachedNetworkImage(
                                                        cacheManager:
                                                            CacheManager(Config(
                                                                "customCacheKey",
                                                                stalePeriod:
                                                                    const Duration(
                                                                        days:
                                                                            15),
                                                                maxNrOfCacheObjects:
                                                                    100)),
                                                        fit: BoxFit.cover,
                                                        imageUrl: homeController
                                                                .categoryList[1]
                                                            ["thumbnail"],
                                                        /*  progressIndicatorBuilder:
                                                            (context, url,
                                                                    downloadProgress) =>
                                                                Center(
                                                          child: CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress),
                                                        ), */
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          downloadImage,
                                                          fit: BoxFit.cover,
                                                          height: 144,
                                                          width: 150,
                                                        ),
                                                      ),
                                                    )
                                                  : Image.asset(
                                                      dummyWishlistImage,
                                                      height: 144,
                                                      width: 150,
                                                      fit: BoxFit.cover),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: AppText(
                                                  text: homeController
                                                              .categoryList[1]
                                                          ["name"] ??
                                                      "",
                                                  color: greyTextColor,
                                                  fontSize: 10.sp,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
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
                                    const EdgeInsets.symmetric(horizontal: 16),
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
                                      homeController.categoryList.length - 2,
                                      (index) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {},
                                              child: SizedBox(
                                                height: 100,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: homeController
                                                                          .categoryList[
                                                                      index + 2]
                                                                  [
                                                                  "thumbnail"] !=
                                                              null
                                                          ? SizedBox(
                                                              width: 80,
                                                              height: 72,
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
                                                                imageUrl: homeController
                                                                            .categoryList[
                                                                        index +
                                                                            2][
                                                                    "thumbnail"],
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
                                                                    Image.asset(
                                                                  downloadImage,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: 80,
                                                                  height: 72,
                                                                ),
                                                              ),
                                                            )
                                                          : Image.asset(
                                                              dummyWishlistImage,
                                                              width: 80,
                                                              height: 72,
                                                              fit:
                                                                  BoxFit.cover),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      child: AppText(
                                                        text: homeController
                                                                    .categoryList[
                                                                index +
                                                                    2]["name"] ??
                                                            "",
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
                                      },
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(
                                width: 0,
                              ),
                      ],
                    ),
            ),
            Obx(
              () => homeController.isBanner2.value
                  ? const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 210,
                          child: PageView.builder(
                            scrollDirection: Axis.horizontal,
                            onPageChanged: callOnchanged,
                            controller: homeController.pageController,
                            itemCount: homeController.banner2List.length,
                            itemBuilder: (context, int index) {
                              return /* CachedNetworkImage(
                                cacheManager: CacheManager(Config(
                                    "customCacheKey",
                                    stalePeriod: const Duration(days: 15),
                                    maxNrOfCacheObjects: 100)),
                                fit: BoxFit.cover,
                                imageUrl: homeController.banner2List[index]
                                    ["image"],
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
                                  child: CircularProgressIndicator(
                                      value: downloadProgress.progress),
                                ),
                                errorWidget: (context, url, error) => Image.asset(
                                  downloadImage,
                                  height: 210,
                                ),
                              ) */
                                  FadeInImage(
                                      fit: BoxFit.cover,
                                      height: 210,
                                      width: double.infinity,
                                      image: NetworkImage(homeController
                                          .banner2List[index]["image"]),
                                      placeholder:
                                          const AssetImage(downloadImage));
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
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
                                              color: (index ==
                                                      homeController
                                                          .currentPage.value)
                                                  ? colorPrimary
                                                  : colorSecondary));
                                    })),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
            ),

            const SizedBox(
              height: 20,
            ),
            const LafetchCardWidget(),
            QuestionCardWidget(
                text1: "FAQs",
                text2: "Your questions answered",
                onPressed: () {},
                icon: question2Image),
            QuestionCardWidget(
                text1: "Need Help?",
                text2: "Contact customer service",
                onPressed: () {},
                icon: question1Image),
            const SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
