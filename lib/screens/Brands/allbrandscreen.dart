// ignore_for_file: avoid_print, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/allbrand_appbar.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/quickwidgets/brand_product_list.dart';
import 'package:lafetch/controller/home_controller.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/quick/brandproductscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../commonwidget/app_text.dart';
import '../../controller/brand_controller.dart';
import '../../controller/product_controller.dart';
import '../../utils/constants.dart';
import '../cartscreen.dart';

class AllBrandScreen extends StatefulWidget {
  final String screen;
  final String slug;
  final int id;
  const AllBrandScreen(
      {required this.id, required this.screen, super.key, required this.slug});

  @override
  State<AllBrandScreen> createState() => AllBrandScreenState();
}

class AllBrandScreenState extends State<AllBrandScreen> {
  final productController = Get.put(ProductController());
  final brandController = Get.put(BrandController());
  final homeController = Get.put(HomeController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  int tagId = 0;
  RegExp regExp = RegExp("");
  bool showDescription = false;
  late Future<void> _initializeVideoPlayerFuture;
  late VideoPlayerController videoController;
  late VideoPlayerController slugVideoController;
  List heightList = [
    100.00.sp,
    180.00.sp,
    180.00.sp,
    100.00.sp,
    100.00.sp,
    180.00.sp,
    180.00.sp,
    100.00.sp,
    100.00.sp,
    180.00.sp,
    180.00.sp,
    100.00.sp,
    100.00.sp,
    180.00.sp,
    180.00.sp,
    100.00.sp,
    100.00.sp,
    180.00.sp,
    180.00.sp,
    100.00.sp,
    100.00.sp,
    180.00.sp,
    180.00.sp,
    100.00.sp,
    100.00.sp,
    180.00.sp,
    180.00.sp,
    100.00.sp,
    100.00.sp,
    180.00.sp,
    180.00.sp,
    100.00.sp,
    100.00.sp,
    180.00.sp,
    180.00.sp,
    100.00.sp,
    100.00.sp,
    180.00.sp,
    180.00.sp,
    100.00.sp,
  ];

  @override
  void initState() {
    videoController = VideoPlayerController.networkUrl(
      Uri.parse(
        brandController.brandbackground.value,
      ),
    );
    _initializeVideoPlayerFuture = videoController.initialize();
    videoController.play();
    videoController.setVolume(0.05);
    videoController.setLooping(true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: homeAppBarColor,
          systemNavigationBarColor: homeAppBarColor));
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      brandController.brandProductDetailsList.clear();
      productController.productSortBy.value = "";
      productController.filterProductEnable.value = false;
      productController.categoryFilter.value = 0;
    });
    // getprefrenceData();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => brandController.getBrandDetails(widget.id, widget.slug));
    /*  WidgetsBinding.instance.addPostFrameCallback((_) => productController
        .getBrandDetailsProduct("", false, false, widget.id, "brand")); */
    /* WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => brandController.getCategoryData(brandController.brandId.value));
    WidgetsBinding.instance.addPostFrameCallback((_) => productController
        .getBestSellerProductData(brandController.brandId.value)); */
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.bestSellerController.addListener(() {
        productController.fetchBestSellerData();
        productController.update();
      });
    }); */
    /*  productController.bestSellerHasnextpage.value = true;
    productController.bestSellerLoadMore.value = false;
    productController.isBestSeller.value = false;
    productController.bestSellerPage.value = 1; */
    super.initState();
  }

  /*  getprefrenceData() async {
    final prefs = await SharedPreferences.getInstance();
    tagId = prefs.getInt('tagId')!;
    WidgetsBinding.instance.addPostFrameCallback((_) => productController
        .getTagsProductData(tagId, 0, brandController.brandId.value));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.tagsProductController.addListener(() {
        productController.fetchMoreTagsProductData(
            tagId, 0, brandController.brandId.value);
        productController.update();
      });
    });
    productController.tagsHasnextpage.value = true;
    productController.tagsLoadMore.value = false;
    productController.istagsProduct.value = false;
    productController.tagsPage.value = 1;
  } */

  Widget playvideo(String video) {
    slugVideoController = VideoPlayerController.networkUrl(
      Uri.parse(
        video,
      ),
    );
    _initializeVideoPlayerFuture = slugVideoController.initialize();
    slugVideoController.setLooping(true);
    slugVideoController.play();
    slugVideoController.setVolume(0.05);
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            fit: StackFit.expand,
            children: [
              AspectRatio(
                aspectRatio: slugVideoController.value.aspectRatio,
                child: VideoPlayer(slugVideoController),
              ),
            ],
          );
        } else {
          return Container(
            height: 211.sp,
            width: double.infinity,
            color: cardBg,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    videoController.pause();
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: homeAppBarColor,
      body: Column(
        children: [
          AllBrandAppbar(
            onPressedBack: () {
              videoController.pause();
              Get.close(1);
            },
            onPressedShare: () async {
              Share.share(brandController.brandDetails["share_link"]);
            },
            onPressedHeart: () {
              Get.to(const WishlistScreen())?.then(
                (value) {
                  SystemChrome.setSystemUIOverlayStyle(
                      const SystemUiOverlayStyle(
                    statusBarColor: homeAppBarColor,
                    systemNavigationBarColor: homeAppBarColor,
                  ));
                },
              );
            },
            onPressedCart: () async {
              Get.to(const CartScreen())?.then(
                (value) {
                  SystemChrome.setSystemUIOverlayStyle(
                      const SystemUiOverlayStyle(
                    statusBarColor: homeAppBarColor,
                    systemNavigationBarColor: homeAppBarColor,
                  ));
                },
              );
              await analytics.logEvent(
                name: 'cart_page',
                parameters: <String, Object>{
                  'page_name': 'cart_page',
                },
              );
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        // color: blue,
                        alignment: Alignment.bottomCenter,
                        margin: EdgeInsets.only(top: 210.sp),
                        child: Image.asset(
                          circleBack,
                        ),
                      ),
                      Obx(
                        () => brandController.isDetails.value
                            ? Container(
                                height: 211.sp,
                                width: double.infinity,
                                color: cardBg,
                              )
                            : brandController
                                        .brandDetails["background_image"] ==
                                    null
                                ? Image.asset(brandback,
                                    height: 211.sp,
                                    width: double.infinity,
                                    fit: BoxFit.cover)
                                : Container(
                                    height: 211.sp,
                                    width: double.infinity,
                                    child: widget.id != 0
                                        ? FutureBuilder(
                                            future:
                                                _initializeVideoPlayerFuture,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                return Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    AspectRatio(
                                                      aspectRatio:
                                                          videoController.value
                                                              .aspectRatio,
                                                      child: VideoPlayer(
                                                          videoController),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return Container(
                                                  height: 211.sp,
                                                  width: double.infinity,
                                                  color: cardBg,
                                                );
                                              }
                                            },
                                          )
                                        : playvideo(brandController
                                            .brandDetails["background_image"])),
                      ),
                      Obx(() => brandController.isDetails.value
                          ? SizedBox(
                              height: 0,
                            )
                          : Container(
                              alignment: Alignment.bottomCenter,
                              margin: EdgeInsets.only(top: 160.sp),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: homeAppBarColor,
                                    width: 4.0.sp,
                                  ),
                                  color: Colors.white,
                                  shape: BoxShape.circle),
                              child: ClipOval(
                                child: SizedBox(
                                  height: 80.sp,
                                  width: 80.sp,
                                  child: CachedNetworkImage(
                                    cacheManager: CacheManager(Config(
                                        "customCacheKey",
                                        stalePeriod: const Duration(days: 15),
                                        maxNrOfCacheObjects: 100)),
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        brandController.brandDetails["logo"],
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      chanelLogoImage,
                                      fit: BoxFit.cover,
                                      height: 80.sp,
                                      width: 80.sp,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      Container(
                        margin: EdgeInsets.only(top: 260.sp),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.sp),
                          child: Center(
                            child: Obx(() => brandController.isDetails.value
                                ? Container(
                                    height: 20.sp,
                                    width: 100.sp,
                                    color: cardBg,
                                  )
                                : AppText(
                                    text: brandController.brandDetails["name"]
                                        .toUpperCase(),
                                    color: whiteColor,
                                    fontSize: 16,
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w400,
                                  )),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 290.sp),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Obx(() => brandController.isDetails.value
                                    ? Container(
                                        height: 20.sp,
                                        width: double.infinity,
                                        color: cardBg,
                                      )
                                    : Text(
                                        brandController
                                            .brandDetails["description"],
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          color: productSubtitleColor,
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 14.sp,
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                        ),
                                        maxLines: showDescription ? 12 : 2,
                                      )),
                              ),
                              Obx(() => brandController.isDetails.value
                                  ? SizedBox(
                                      height: 0,
                                    )
                                  : Visibility(
                                      visible: regExp
                                                  .allMatches(brandController
                                                          .brandDetails[
                                                      "description"])
                                                  .length >
                                              50
                                          ? true
                                          : false,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 4.sp),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              showDescription =
                                                  !showDescription;
                                            });
                                          },
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              AppText(
                                                text: showDescription
                                                    ? "Show less"
                                                    : "Show more",
                                                color: productSubtitleColor,
                                                fontSize: 12,
                                                maxLines: 12,
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w400,
                                              ),
                                              Container(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 20.sp, left: 5.sp),
                                                  child: SvgPicture.asset(
                                                    showDescription
                                                        ? upDropDownSvgImage
                                                        : dropdownSvgImage,
                                                    color: productSubtitleColor,
                                                    height: 5.sp,
                                                    width: 7.sp,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )),
                              Padding(
                                padding: EdgeInsets.only(top: 24.sp),
                                child: AppText(
                                  text: "All Products",
                                  color: whiteColor,
                                  textAlign: TextAlign.start,
                                  fontSize: 20,
                                  maxLines: 1,
                                  fontFamily: "Playfair Display Medium",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  /*  Padding(
                    padding: EdgeInsets.only(top: 10.sp, left: 16.sp),
                    child: AppText(
                      text: "All Products",
                      color: whiteColor,
                      fontSize: 20,
                      maxLines: 1,
                      fontFamily: "Playfair Display Medium",
                      fontWeight: FontWeight.w400,
                    ),
                  ), */
                  Obx(() => brandController.isProductBrand.value
                      ? Padding(
                          padding: EdgeInsets.only(
                            top: 16.sp,
                            bottom: 16.sp,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 220.sp,
                            child: ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                physics: const BouncingScrollPhysics(),
                                itemCount: 3,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (ctx, index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 16.sp),
                                        color: cardBg,
                                        height: 170.sp,
                                        width: 136.sp,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 8.sp, left: 16.sp),
                                        child: Container(
                                          color: cardBg,
                                          height: 16.sp,
                                          width: 100.sp,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 8.sp, left: 16.sp),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 6.sp),
                                              child: Container(
                                                color: cardBg,
                                                height: 16.sp,
                                                width: 40.sp,
                                              ),
                                            ),
                                            Container(
                                              color: cardBg,
                                              height: 16.sp,
                                              width: 40.sp,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        )
                      : BrandProductList(
                          radius: 0,
                          onPressed: (p0, p1) async {
                            videoController.pause();
                            Get.to(ProductDetailsScreen(
                                    expresshour:
                                        homeController.expressHour.value,
                                    backgroundcolor: whiteColor,
                                    brandName: p1,
                                    productId: p0,
                                    type: "add"))
                                ?.then((value) => setState(
                                      () {
                                        videoController.play();
                                        productController.getBrandProductData();
                                        SystemChrome.setSystemUIOverlayStyle(
                                            const SystemUiOverlayStyle(
                                          statusBarColor: homeAppBarColor,
                                          systemNavigationBarColor:
                                              homeAppBarColor,
                                        ));
                                      },
                                    ));
                            await analytics.logEvent(
                              name: 'category_product_details',
                              parameters: <String, Object>{
                                'page_name': 'category_product_details',
                              },
                            );
                          },
                          list: brandController.brandProductDetailsList)),
                  /*   Obx(
                    () => brandController.isCategory.value
                        ? const DummybrandAll()
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.sp),
                            child: MasonryGridView.count(
                              primary: false,
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 7.sp,
                              mainAxisSpacing: 7.sp,
                              itemCount: brandController.categoryList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    videoController.pause();
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                CategoryProductScreen(
                                                  genderName: "",
                                                  categoryName: brandController
                                                          .categoryList[index]
                                                      ["name"],
                                                  categoryId: brandController
                                                          .categoryList[index]
                                                      ["id"],
                                                  tagIds: const [],
                                                  categoryList: [],
                                                  genderType: 0,
                                                  brandId: brandController
                                                      .brandId.value,
                                                )))
                                        .then((value) => setState(
                                              () {
                                                videoController.play();
                                              },
                                            ));
                                    await analytics.logEvent(
                                      name: 'allbrand_categoryList_page',
                                      parameters: <String, Object>{
                                        'page_name':
                                            'allbrand_categoryList_page',
                                      },
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          brandController.categoryList[index]
                                                      ["thumbnail"] !=
                                                  null
                                              ? SizedBox(
                                                  height: heightList[index],
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2) -
                                                      16.sp,
                                                  child: CachedNetworkImage(
                                                    cacheManager: CacheManager(
                                                        Config("customCacheKey",
                                                            stalePeriod:
                                                                const Duration(
                                                                    days: 15),
                                                            maxNrOfCacheObjects:
                                                                100)),
                                                    fit: BoxFit.cover,
                                                    imageUrl: brandController
                                                            .categoryList[index]
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
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      downloadImage,
                                                      fit: BoxFit.cover,
                                                      height: heightList[index],
                                                      width: (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2) -
                                                          16.sp,
                                                    ),
                                                  ),
                                                )
                                              : Center(
                                                  child: Image.asset(
                                                      dummyWishlistImage,
                                                      height: heightList[index],
                                                      width: (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2) -
                                                          16.sp,
                                                      fit: BoxFit.cover),
                                                ),
                                          Positioned.fill(
                                            child: Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 18.sp,
                                                    vertical: 10.sp),
                                                child: AppText(
                                                  text: brandController
                                                              .categoryList[
                                                          index]["name"] ??
                                                      "",
                                                  color: whiteColor,
                                                  fontSize: 14,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  Obx(
                    () => productController.istagsProduct.value
                        ? const DummyProductList(text: "New Arrivals")
                        : productController.tagProductList.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(top: 40.sp),
                                child: HorizontalBrandList(
                                  text: "New Arrivals",
                                  controller:
                                      productController.tagsProductController,
                                  onPressed: (p0, p1) async {
                                    videoController.pause();
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ProductDetailsScreen(
                                                    brandName: p1,
                                                    productId: p0,
                                                    type: "add")))
                                        .then((value) => setState(
                                              () {
                                                videoController.play();
                                                productController
                                                    .tagsHasnextpage
                                                    .value = true;
                                                productController
                                                    .tagsLoadMore.value = false;
                                                productController.istagsProduct
                                                    .value = false;
                                                productController
                                                    .tagsPage.value = 1;
                                                productController
                                                    .getTagsProductData(
                                                        tagId,
                                                        0,
                                                        brandController
                                                            .brandId.value);
                                              },
                                            ));
                                    await analytics.logEvent(
                                      name: 'allbrand_newarrival_details',
                                      parameters: <String, Object>{
                                        'page_name':
                                            'allbrand_newarrival_details',
                                      },
                                    );
                                  },
                                  onPressedHeart: (p0, p1) async {
                                    if (productController.tagProductList[p1]
                                        ["wishlisted"]) {
                                      /*  productController.tagProductList[p1]
                                          ["wishlisted"] = false;
                                      setState(() {}); */
                                      productController
                                          .callAddProductToWishlist(
                                              productController
                                                      .tagProductList[p1]
                                                  ["wishlist_id"],
                                              "tags",
                                              p0,
                                              0,
                                              brandController.brandId.value,
                                              [],
                                              [],
                                              0,
                                              0,
                                              0);
                                    } else {
                                      scaffoldKey.currentState?.showBottomSheet(
                                          (context) => BottomWishlist(
                                              controller: wishlistController,
                                              onPressed: (p0) {
                                                /*  productController
                                                            .tagProductList[p1]
                                                        ["wishlisted"] = true;
                                                    setState(() {}); */
                                                productController
                                                    .callAddProductToWishlist(
                                                        p0,
                                                        "tags",
                                                        productController
                                                                .tagProductList[
                                                            p1]["id"],
                                                        0,
                                                        brandController
                                                            .brandId.value,
                                                        [],
                                                        [],
                                                        0,
                                                        0,
                                                        0);
                                              },
                                              wishlistList: wishlistController
                                                  .wishlistList));
                                      await analytics.logEvent(
                                        name: 'allbrand_newarrival_wishlist',
                                        parameters: <String, Object>{
                                          'page_name':
                                              'allbrand_newarrival_wishlist',
                                        },
                                      );
                                    }
                                  },
                                  list: productController.tagProductList,
                                ),
                              )
                            : SizedBox(
                                height: 0,
                              ),
                  ),
                  Obx(() => productController.isBestSeller.value
                      ? const DummyProductList(text: "Bestsellers")
                      : productController.bestSellerList.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.only(top: 25.sp),
                              child: HorizontalBrandList(
                                text: "Bestsellers",
                                controller:
                                    productController.bestSellerController,
                                onPressed: (p0, p1) async {
                                  videoController.pause();
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ProductDetailsScreen(
                                                  brandName: p1,
                                                  productId: p0,
                                                  type: "add")))
                                      .then((value) => setState(
                                            () {
                                              videoController.play();
                                              productController
                                                  .bestSellerHasnextpage
                                                  .value = true;
                                              productController
                                                  .bestSellerLoadMore
                                                  .value = false;
                                              productController
                                                  .isBestSeller.value = false;
                                              productController
                                                  .bestSellerPage.value = 1;
                                              productController
                                                  .getBestSellerProductData(
                                                      brandController
                                                          .brandId.value);
                                            },
                                          ));
                                  await analytics.logEvent(
                                    name: 'allbrand_bestseller_details',
                                    parameters: <String, Object>{
                                      'page_name':
                                          'allbrand_bestseller_details',
                                    },
                                  );
                                },
                                onPressedHeart: (p0, p1) async {
                                  if (productController.bestSellerList[p1]
                                      ["wishlisted"]) {
                                    /*  productController.bestSellerList[p1]
                                        ["wishlisted"] = false;
                                    setState(() {}); */
                                    productController.callAddProductToWishlist(
                                        productController.bestSellerList[p1]
                                            ["wishlist_id"],
                                        "seller",
                                        p0,
                                        0,
                                        brandController.brandId.value,
                                        [],
                                        [],
                                        0,
                                        0,
                                        0);
                                  } else {
                                    scaffoldKey.currentState?.showBottomSheet(
                                        (context) => BottomWishlist(
                                            controller: wishlistController,
                                            onPressed: (p0) {
                                              /*  productController
                                                      .bestSellerList[p1]
                                                  ["wishlisted"] = true;
                                              setState(() {}); */
                                              productController
                                                  .callAddProductToWishlist(
                                                      p0,
                                                      "seller",
                                                      productController
                                                              .bestSellerList[
                                                          p1]["id"],
                                                      0,
                                                      brandController
                                                          .brandId.value,
                                                      [],
                                                      [],
                                                      0,
                                                      0,
                                                      0);
                                            },
                                            wishlistList: wishlistController
                                                .wishlistList));
                                    await analytics.logEvent(
                                      name: 'allbrand_bestseller_wishlist',
                                      parameters: <String, Object>{
                                        'page_name':
                                            'allbrand_bestseller_wishlist',
                                      },
                                    );
                                  }
                                },
                                list: productController.bestSellerList,
                              ),
                            )
                          : SizedBox(
                              height: 0,
                            )),
                 */

                  InkWell(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.remove("brandList");
                      prefs.remove("colorList");
                      prefs.remove("sizeList");
                      prefs.remove("upper");
                      prefs.remove("lower");
                      prefs.remove("sortby");
                      prefs.remove("category");
                      productController.productSortBy.value = "";
                      productController.filterProductEnable.value = false;
                      productController.categoryFilter.value = 0;
                      videoController.pause();
                      Navigator.push(
                          context,
                          scaleIn(
                            BrandViewProductScreen(
                                expresshour: homeController.expressHour.value,
                                brand_id: brandController.brandId.value,
                                title: brandController.brandDetails["name"],
                                screen: "brand",
                                genderName: ""),
                          )).then((value) => setState(
                            () {
                              productController.productSortBy.value = "";
                              productController.filterProductEnable.value =
                                  false;
                              productController.categoryFilter.value = 0;
                              videoController.play();
                              /*  productController.getBrandDetailsProduct(
                                      "",
                                      false,
                                      false,
                                      brandController.brandId.value,
                                      "brand"); */
                            },
                          ));
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 20.sp),
                      child: Container(
                        height: 42.sp,
                        color: whiteColor,
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8.sp),
                              child: AppText(
                                text: "Explore All".toUpperCase(),
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w400,
                                color: colorPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
