// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/allbrand_appbar.dart';
import 'package:lafetch/commonwidget/brandwidgits/dummy_brandall.dart';
import 'package:lafetch/commonwidget/brandwidgits/horizontal_list.dart';
import 'package:lafetch/screens/Brands/categoryproduct.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/catalogwidgets/bottomwishlist.dart';
import '../../commonwidget/homewidget/dummy_product_list.dart';
import '../../controller/brand_controller.dart';
import '../../controller/product_controller.dart';
import '../../controller/wishlist_controller.dart';
import '../../utils/constants.dart';
import '../cartscreen.dart';
import '../catalog/productlist/productdetailsscreen.dart';
import '../searchscreen.dart';

class AllBrandScreen extends StatefulWidget {
  final String title;
  final String brandbackground;
  final String screen;
  const AllBrandScreen(
      {required this.title,
      required this.brandbackground,
      required this.screen,
      super.key});

  @override
  State<AllBrandScreen> createState() => AllBrandScreenState();
}

class AllBrandScreenState extends State<AllBrandScreen> {
  final productController = Get.put(ProductController());
  final brandController = Get.put(BrandController());
  final wishlistController = Get.put(WishlistController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  int tagId = 0;
  late Future<void> _initializeVideoPlayerFuture;
  late VideoPlayerController videoController;
  List heightList = [
    100.00,
    180.00,
    180.00,
    100.00,
    100.00,
    180.00,
    180.00,
    100.00,
    100.00,
    180.00,
    180.00,
    100.00,
    100.00,
    180.00,
    180.00,
    100.00,
    100.00,
    180.00,
    180.00,
    100.00,
    100.00,
    180.00,
    180.00,
    100.00,
    100.00,
    180.00,
    180.00,
    100.00,
    100.00,
    180.00,
    180.00,
    100.00,
    100.00,
    180.00,
    180.00,
    100.00,
    100.00,
    180.00,
    180.00,
    100.00,
    100.00,
    180.00,
    180.00,
    100.00,
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
    videoController.setLooping(true);
    getprefrenceData();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => brandController.getCategoryData(brandController.brandId.value));
    WidgetsBinding.instance.addPostFrameCallback((_) => productController
        .getBestSellerProductData(brandController.brandId.value));
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

  getprefrenceData() async {
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
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.screen == "search") {
          videoController.pause();
          Get.close(1);
        } else {
          brandController.showAllBrand.value = false;
        }
        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: colorPrimary,
        body: Column(
          children: [
            AllBrandAppbar(
              text: widget.title,
              onPressedback: () {
                print(widget.screen);
                if (widget.screen == "search") {
                  videoController.pause();
                  Get.close(1);
                } else {
                  brandController.showAllBrand.value = false;
                }
              },
              onPressedSearch: () async {
                Get.to(const SearchScreen());
                await analytics.logEvent(
                  name: 'search_page',
                  parameters: <String, Object>{
                    'page_name': 'search_page',
                  },
                );
              },
              onPressedCart: () async {
                Get.to(const CartScreen());
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
                        widget.brandbackground == ""
                            ? Image.asset(brandback,
                                height: 112,
                                width: double.infinity,
                                fit: BoxFit.cover)
                            : /* SizedBox(
                                height: 112,
                                width: double.infinity,
                                child: CachedNetworkImage(
                                  cacheManager: CacheManager(Config(
                                      "customCacheKey",
                                      stalePeriod: const Duration(days: 15),
                                      maxNrOfCacheObjects: 100)),
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      brandController.brandbackground.value,
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    downloadImage,
                                    fit: BoxFit.cover,
                                    height: 112,
                                    width: double.infinity,
                                  ),
                                ),
                              ) */
                            Container(
                                height: 160,
                                width: double.infinity,
                                child: FutureBuilder(
                                  future: _initializeVideoPlayerFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: videoController
                                                .value.aspectRatio,
                                            child: VideoPlayer(videoController),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return const Center(
                                        child: SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator()),
                                      );
                                    }
                                  },
                                ),
                              ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          margin: const EdgeInsets.only(top: 110),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                              color: Colors.white,
                              shape: BoxShape.circle),
                          child: ClipOval(
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: CachedNetworkImage(
                                cacheManager: CacheManager(Config(
                                    "customCacheKey",
                                    stalePeriod: const Duration(days: 15),
                                    maxNrOfCacheObjects: 100)),
                                fit: BoxFit.cover,
                                imageUrl: brandController.brandlogo.value,
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  chanelLogoImage,
                                  fit: BoxFit.cover,
                                  height: 80,
                                  width: 80,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Obx(
                      () => brandController.isCategory.value
                          ? const DummybrandAll()
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: MasonryGridView.count(
                                primary: false,
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                crossAxisSpacing: 7,
                                mainAxisSpacing: 7,
                                itemCount: brandController.categoryList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      videoController.pause();
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  CategoryProductScreen(
                                                    categoryId: brandController
                                                            .categoryList[index]
                                                        ["id"],
                                                    tagIds: const [],
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
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                2) -
                                                            16,
                                                    child: CachedNetworkImage(
                                                      cacheManager:
                                                          CacheManager(Config(
                                                              "customCacheKey",
                                                              stalePeriod:
                                                                  const Duration(
                                                                      days: 15),
                                                              maxNrOfCacheObjects:
                                                                  100)),
                                                      fit: BoxFit.cover,
                                                      imageUrl: brandController
                                                              .categoryList[
                                                          index]["thumbnail"],
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
                                                        height:
                                                            heightList[index],
                                                        width: (MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2) -
                                                            16,
                                                      ),
                                                    ),
                                                  )
                                                : Center(
                                                    child: Image.asset(
                                                        dummyWishlistImage,
                                                        height:
                                                            heightList[index],
                                                        width: (MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2) -
                                                            16,
                                                        fit: BoxFit.cover),
                                                  ),
                                            Positioned.fill(
                                              child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 18,
                                                      vertical: 10),
                                                  child: AppText(
                                                    text: brandController
                                                                .categoryList[
                                                            index]["name"] ??
                                                        "",
                                                    color: whiteColor,
                                                    fontSize: 14.sp,
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
                          // const DummyProductBrand(text: "New Arrivals")
                          : Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: HorizontalBrandList(
                                text: "New Arrivals",
                                controller:
                                    productController.tagsProductController,
                                onPressed: (p0) async {
                                  videoController.pause();
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ProductDetailsScreen(
                                                  productId: p0, type: "add")))
                                      .then((value) => setState(
                                            () {
                                              videoController.play();
                                              productController
                                                  .tagsHasnextpage.value = true;
                                              productController
                                                  .tagsLoadMore.value = false;
                                              productController
                                                  .istagsProduct.value = false;
                                              productController.tagsPage.value =
                                                  1;
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
                                    productController.callAddProductToWishlist(
                                        productController.tagProductList[p1]
                                            ["wishlist_id"],
                                        "tags",
                                        p0,
                                        0,
                                        brandController.brandId.value,
                                        [],
                                        0,
                                        0,
                                        0);
                                  } else {
                                    scaffoldKey.currentState?.showBottomSheet(
                                        (context) => BottomWishlist(
                                            controller: wishlistController,
                                            onPressed: (p0) {
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
                            ),
                    ),
                    Obx(() => productController.isBestSeller.value
                        ? const DummyProductList(text: "Bestsellers")
                        //const DummyProductBrand(text: "Bestsellers")
                        : Padding(
                            padding: const EdgeInsets.only(top: 25),
                            child: HorizontalBrandList(
                              text: "Bestsellers",
                              controller:
                                  productController.bestSellerController,
                              onPressed: (p0) async {
                                videoController.pause();
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ProductDetailsScreen(
                                                productId: p0, type: "add")))
                                    .then((value) => setState(
                                          () {
                                            videoController.play();
                                            productController
                                                .bestSellerHasnextpage
                                                .value = true;
                                            productController.bestSellerLoadMore
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
                                    'page_name': 'allbrand_bestseller_details',
                                  },
                                );
                              },
                              onPressedHeart: (p0, p1) async {
                                if (productController.bestSellerList[p1]
                                    ["wishlisted"]) {
                                  productController.callAddProductToWishlist(
                                      productController.bestSellerList[p1]
                                          ["wishlist_id"],
                                      "seller",
                                      p0,
                                      0,
                                      brandController.brandId.value,
                                      [],
                                      0,
                                      0,
                                      0);
                                } else {
                                  scaffoldKey.currentState?.showBottomSheet(
                                      (context) => BottomWishlist(
                                          controller: wishlistController,
                                          onPressed: (p0) {
                                            productController
                                                .callAddProductToWishlist(
                                                    p0,
                                                    "seller",
                                                    productController
                                                            .bestSellerList[p1]
                                                        ["id"],
                                                    0,
                                                    brandController
                                                        .brandId.value,
                                                    [],
                                                    0,
                                                    0,
                                                    0);
                                          },
                                          wishlistList:
                                              wishlistController.wishlistList));
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
                          )),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
