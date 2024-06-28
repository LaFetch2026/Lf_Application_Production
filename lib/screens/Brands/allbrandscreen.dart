// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/allbrand_appbar.dart';
import 'package:lafetch/commonwidget/brandwidgits/dummy_brandall.dart';
import 'package:lafetch/commonwidget/brandwidgits/dummy_product_brand.dart';
import 'package:lafetch/commonwidget/brandwidgits/horizontal_list.dart';
import 'package:lafetch/screens/Brands/categoryproduct.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/catalogwidgets/bottomwishlist.dart';
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
  int tagId = 0;

  @override
  void initState() {
    getprefrenceData();
    wishlistController.getWishlistData();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => brandController.getCategoryData(brandController.brandId.value));
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant"));
    wishlistController.getWishlistData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.listController.addListener(() {
        productController.fetchMoreData("relevant");
        productController.update();
      });
    });
    productController.hasnextpage.value = true;
    productController.loadMore.value = false;
    productController.isProduct.value = false;
    productController.page.value = 1;
    super.initState();
  }

  getprefrenceData() async {
    final prefs = await SharedPreferences.getInstance();
    tagId = prefs.getInt('tagId')!;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getTagsProductData(tagId));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.tagsProductController.addListener(() {
        productController.fetchMoreTagsProductData(tagId);
        productController.update();
      });
    });
    productController.tagsHasnextpage.value = true;
    productController.tagsLoadMore.value = false;
    productController.istagsProduct.value = false;
    productController.tagsPage.value = 1;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.screen == "search") {
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
                  Get.close(1);
                } else {
                  brandController.showAllBrand.value = false;
                }
              },
              onPressedSearch: () {
                Get.to(const SearchScreen());
              },
              onPressedCart: () {
                Get.to(const CartScreen());
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
                            : SizedBox(
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
                              ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          margin: const EdgeInsets.only(top: 70),
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
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 7,
                                itemCount: brandController.categoryList.length,
                                itemBuilder: (context, index) {
                                  double ht = index % 2 == 0 ? 100 : 180;
                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(CategoryProductScreen(
                                        categoryId: brandController
                                            .categoryList[index]["id"],
                                        tagIds: const [],
                                        brandId: 0,
                                      ));
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
                                                    height: ht,
                                                    width: 156,
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
                                                        height: ht,
                                                        width: 156,
                                                      ),
                                                    ),
                                                  )
                                                : Center(
                                                    child: Image.asset(
                                                        dummyWishlistImage,
                                                        height: ht,
                                                        width: 156,
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
                          ? const DummyProductBrand(text: "New Arrivals")
                          : Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: HorizontalBrandList(
                                text: "New Arrivals",
                                controller:
                                    productController.tagsProductController,
                                onPressed: (p0) {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ProductDetailsScreen(
                                                  productId: p0, type: "add")))
                                      .then((value) => setState(
                                            () {
                                              productController
                                                  .tagsHasnextpage.value = true;
                                              productController
                                                  .tagsLoadMore.value = false;
                                              productController
                                                  .istagsProduct.value = false;
                                              productController.tagsPage.value =
                                                  1;
                                              productController
                                                  .getTagsProductData(tagId);
                                            },
                                          ));
                                },
                                onPressedHeart: (p0, p1) {
                                  if (productController.tagProductList[p1]
                                      ["wishlisted"]) {
                                    productController.callAddProductToWishlist(
                                        productController.tagProductList[p1]
                                            ["wishlist_id"],
                                        "tags",
                                        p0,
                                        0,
                                        0,
                                        [],
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
                                                      0,
                                                      [],
                                                      0);
                                            },
                                            wishlistList: wishlistController
                                                .wishlistList));
                                  }
                                },
                                list: productController.tagProductList,
                              ),
                            ),
                    ),
                    Obx(() => productController.isProduct.value
                        ? const DummyProductBrand(text: "Bestsellers")
                        : /* Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10, left: 16),
                                child: AppText(
                                  text: "Bestsellers",
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w500,
                                  color: whiteBorderColor,
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
                                      itemCount:
                                          productController.productList.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (ctx, index) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {},
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                margin: const EdgeInsets.only(
                                                    right: 5),
                                                width: 122,
                                                height: 250,
                                                child: Container(
                                                  color: whiteBorderColor,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Image.asset(backImage,
                                                              height: 150,
                                                              width: 122,
                                                              fit: BoxFit.cover),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal: 8,
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
                                                                    child: Image
                                                                        .asset(
                                                                      heartImage,
                                                                      height: 16,
                                                                      color:
                                                                          bottomnavBack,
                                                                      width: 16,
                                                                    ),
                                                                  ),
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
                                                          maxLines: 2,
                                                          fontSize: 11.sp,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
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
                                                                  FontWeight.w500,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 10),
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
                                                                      FontWeight
                                                                          .w400,
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
                                                                right: 10,
                                                                bottom: 5),
                                                        child: Row(
                                                          children: [
                                                            const ImageIcon(
                                                              AssetImage(
                                                                  truckImage),
                                                              color: expressText,
                                                              size: 14,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5),
                                                              child: AppText(
                                                                text: "Express",
                                                                color:
                                                                    expressText,
                                                                maxLines: 2,
                                                                fontSize: 11.sp,
                                                                fontFamily:
                                                                    "Franklin Gothic Regular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
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
                        Padding(
                            padding: const EdgeInsets.only(top: 25),
                            child: HorizontalBrandList(
                              text: "Bestsellers",
                              controller: productController.listController,
                              onPressed: (p0) {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ProductDetailsScreen(
                                                productId: p0, type: "add")))
                                    .then((value) => setState(
                                          () {
                                            productController
                                                .hasnextpage.value = true;
                                            productController.loadMore.value =
                                                false;
                                            productController.isProduct.value =
                                                false;
                                            productController.page.value = 1;
                                            productController
                                                .getProductData("relevant");
                                          },
                                        ));
                              },
                              onPressedHeart: (p0, p1) {
                                if (productController.productList[p1]
                                    ["wishlisted"]) {
                                  productController.callAddProductToWishlist(
                                      productController.productList[p1]
                                          ["wishlist_id"],
                                      "product",
                                      p0,
                                      0,
                                      0,
                                      [],
                                      0);
                                } else {
                                  scaffoldKey.currentState?.showBottomSheet(
                                      (context) => BottomWishlist(
                                          controller: wishlistController,
                                          onPressed: (p0) {
                                            productController
                                                .callAddProductToWishlist(
                                                    p0,
                                                    "product",
                                                    productController
                                                        .productList[p1]["id"],
                                                    0,
                                                    0,
                                                    [],
                                                    0);
                                          },
                                          wishlistList:
                                              wishlistController.wishlistList));
                                }
                              },
                              list: productController.productList,
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
