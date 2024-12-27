// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/productlist_appbar.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_grid_list.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import '../../../commonwidget/app_text.dart';
import '../../../commonwidget/catalogwidgets/bottomwishlist.dart';
import '../../../controller/product_controller.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../utils/constants.dart';

class ProductListScreen extends StatefulWidget {
  final String title;

  const ProductListScreen({
    super.key,
    required this.title,
  });

  @override
  State<ProductListScreen> createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  final productController = Get.find<ProductController>();
  final wishlistController = Get.put(WishlistController());
  final controller = Get.put(CartController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    productController.productCategoryList.clear();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.hasnextpage.value = true;
      productController.loadMore.value = false;
      productController.isProduct.value = false;
      productController.page.value = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant"));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getCartData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.listController.addListener(() {
        productController.fetchMoreData("relevant");
        productController.update();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: whiteColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductAppbar(onPressedSearch: () async {
              Get.to(const SearchScreen())?.then((value) => setState(
                    () {
                      productController.getProductData("relevant");
                    },
                  ));
              analytics
                  .logEvent(name: "search_page", parameters: <String, Object>{
                "page_name": "search_page",
              });
            }, onPressedCart: () async {
              Get.to(const CartScreen())?.then((value) => setState(
                    () {
                      controller.getCartData();
                    },
                  ));
              analytics
                  .logEvent(name: "cart_page", parameters: <String, Object>{
                "page_name": "cart_page",
              });
            }),
            Padding(
              padding: EdgeInsets.only(left: 16.sp, top: 16.sp),
              child: AppText(
                text: "HANDPICKED FOR YOU",
                color: Color(0xFF4B5563),
                fontSize: 16,
                fontFamily: "Franklin Gothic",
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w500,
              ),
            ),
            Obx(() => Padding(
                  padding: EdgeInsets.only(left: 16.sp, top: 5.sp),
                  child: productController.isProduct.value
                      ? const DummyContainer(
                          height: 10,
                          width: 60,
                        )
                      : AppText(
                          text: productController.productList.length == 1
                              ? "${productController.productList.length.toString()} item"
                              : "${productController.productList.length.toString()} items",
                          color: Color(0xFF4B5563),
                          fontSize: 10,
                          fontFamily: "Franklin Gothic Regular",
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w500,
                        ),
                )),
            Obx(
              () => productController.isProduct.value
                  ? Expanded(
                      child: const DummyGridList(
                        size: 2,
                      ),
                    )
                  : productController.productList.isNotEmpty
                      ? Expanded(
                          child: SingleChildScrollView(
                            controller: productController.listController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.sp, vertical: 20.sp),
                                  child: GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: 2,
                                    controller:
                                        productController.listController,
                                    scrollDirection: Axis.vertical,
                                    padding: EdgeInsets.zero,
                                    childAspectRatio: 0.5,
                                    physics: const ScrollPhysics(),
                                    crossAxisSpacing: 5.sp,
                                    mainAxisSpacing: 0,
                                    children: List.generate(
                                      productController.productList.length,
                                      (index) {
                                        return GestureDetector(
                                          onTap: () async {
                                            Get.to(ProductDetailsScreen(
                                                    brandName: productController
                                                            .productList[index]
                                                        ["brand_name"],
                                                    productId: productController
                                                            .productList[index]
                                                        ["id"],
                                                    type: "add"))
                                                ?.then((value) => setState(
                                                      () {
                                                        productController
                                                            .hasnextpage
                                                            .value = true;
                                                        productController
                                                            .loadMore
                                                            .value = false;
                                                        productController
                                                            .isProduct
                                                            .value = false;
                                                        productController
                                                            .page.value = 1;
                                                      },
                                                    ));
                                            await analytics.logEvent(
                                              name: 'category_product_details',
                                              parameters: <String, Object>{
                                                'page_name':
                                                    'category_product_details',
                                              },
                                            );
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  Center(
                                                    child: productController
                                                                .productList[index]
                                                                    ["images"]
                                                                .isNotEmpty &&
                                                            productController
                                                                        .productList[index][
                                                                    "images"] !=
                                                                null
                                                        ? SizedBox(
                                                            height: (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2) +
                                                                10.sp,
                                                            width: (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2) -
                                                                24.sp,
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
                                                              fit: BoxFit.cover,
                                                              imageUrl: isImage(productController
                                                                              .productList[index]
                                                                          ["images"][0]
                                                                      ["name"])
                                                                  ? productController
                                                                              .productList[index]
                                                                          ["images"]
                                                                      [
                                                                      0]["name"]
                                                                  : productController
                                                                              .productList[index]
                                                                          ["images"]
                                                                      [1]["name"],
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Image.asset(
                                                                downloadImage,
                                                                fit: BoxFit
                                                                    .cover,
                                                                height: (MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        2) +
                                                                    10.sp,
                                                                width: (MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        2) -
                                                                    24.sp,
                                                              ),
                                                            ),
                                                          )
                                                        : Image.asset(
                                                            dummyWishlistImage,
                                                            height: (MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    2) +
                                                                10.sp,
                                                            width: (MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    2) -
                                                                24.sp,
                                                            fit: BoxFit.cover),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      if (productController
                                                                  .productList[
                                                              index]
                                                          ["wishlisted"]) {
                                                        productController.callAddProductToWishlist(
                                                            productController
                                                                        .productList[
                                                                    index]
                                                                ["wishlist_id"],
                                                            "product",
                                                            productController
                                                                    .productList[
                                                                index]["id"],
                                                            0,
                                                            0,
                                                            [],
                                                            [],
                                                            0,
                                                            0,
                                                            0);
                                                      } else {
                                                        scaffoldKey.currentState
                                                            ?.showBottomSheet((context) =>
                                                                BottomWishlist(
                                                                    controller:
                                                                        wishlistController,
                                                                    onPressed:
                                                                        (p0) {
                                                                      productController.callAddProductToWishlist(
                                                                          p0,
                                                                          "product",
                                                                          productController.productList[index]
                                                                              [
                                                                              "id"],
                                                                          0,
                                                                          0,
                                                                          [],
                                                                          [],
                                                                          0,
                                                                          0,
                                                                          0);
                                                                    },
                                                                    wishlistList:
                                                                        wishlistController
                                                                            .wishlistList));
                                                      }
                                                      await analytics.logEvent(
                                                        name:
                                                            'category_product_wishlist',
                                                        parameters: <String,
                                                            Object>{
                                                          'page_name':
                                                              'category_product_wishlist',
                                                        },
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16.sp,
                                                              vertical: 10.sp),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: InkWell(
                                                          child: SizedBox(
                                                            height: 24.sp,
                                                            width: 24.sp,
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
                                                                          18,
                                                                      width: 18,
                                                                    )
                                                                  : Image.asset(
                                                                      heartImage,
                                                                      height:
                                                                          18.sp,
                                                                      width:
                                                                          18.sp,
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 10.sp,
                                                    left: 16.sp,
                                                    child: Container(
                                                      color: const Color(
                                                          0xB3F7F7F5),
                                                      height: 26.sp,
                                                      width: 80.sp,
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        2.sp),
                                                            child: Image.asset(
                                                              starImage,
                                                              height: 16.sp,
                                                              color:
                                                                  bottomnavBack,
                                                              width: 16.sp,
                                                            ),
                                                          ),
                                                          AppText(
                                                            text: productController
                                                                            .productList[index]
                                                                        [
                                                                        "aggregated_rating"] !=
                                                                    null
                                                                ? productController
                                                                    .productList[
                                                                        index][
                                                                        "aggregated_rating"]
                                                                    .toString()
                                                                : "0",
                                                            color: colorPrimary,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10.sp),
                                                            child: Container(
                                                              width: 1,
                                                              color:
                                                                  textHintColor,
                                                              height: 16.sp,
                                                            ),
                                                          ),
                                                          AppText(
                                                            text: productController
                                                                .productList[
                                                                    index][
                                                                    "reviews_count"]
                                                                .toString(),
                                                            color: colorPrimary,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.sp,
                                                    vertical: 5.sp),
                                                child: AppText(
                                                  text: productController
                                                              .productList[
                                                          index]["name"] ??
                                                      "",
                                                  color: nameText,
                                                  maxLines: 2,
                                                  fontSize: 12,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.sp),
                                                child: AppText(
                                                  text: productController
                                                                  .productList[
                                                              index][
                                                          "short_description"] ??
                                                      "",
                                                  color: nameText,
                                                  maxLines: 2,
                                                  fontSize: 11,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 10.sp,
                                                    left: 10.sp,
                                                    right: 1.sp),
                                                child: Row(
                                                  children: [
                                                    AppText(
                                                      text:
                                                          "\u{20B9} ${productController.productList[index]["price"] ?? ""}",
                                                      color: deepGreytextColor,
                                                      maxLines: 2,
                                                      fontSize: 11,
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 5.sp),
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
                                              productController
                                                          .productList[index]
                                                      ["express_delivery"]
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 5.sp,
                                                          left: 10.sp,
                                                          right: 10.sp),
                                                      child: Row(
                                                        children: [
                                                          ImageIcon(
                                                            AssetImage(
                                                                truckImage),
                                                            color: expressText,
                                                            size: 14.sp,
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5.sp),
                                                            child: AppText(
                                                              text: "Express",
                                                              color:
                                                                  expressText,
                                                              maxLines: 2,
                                                              fontSize: 11,
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
                                productController.loadMore.value
                                    ? DummyGridList()
                                    : const SizedBox(
                                        height: 0,
                                      ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height - 100,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text("No Product Found",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                    fontFamily: "Franklin Gothic Regular")),
                          ),
                        ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.sp, horizontal: 10.sp),
                        child: Row(
                          children: [
                            Image.asset(
                              sortbyIcon,
                              height: 20.sp,
                              width: 20.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.sp),
                              child: Text(
                                "SORT BY",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF374151),
                                  decoration: TextDecoration.none,
                                  fontSize: 13.sp,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.sp),
                    child: Container(
                      width: 1.sp,
                      color: borderColor,
                      height: 40.sp,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.sp, horizontal: 10.sp),
                        child: Row(
                          children: [
                            Image.asset(
                              categoryIcon,
                              height: 20.sp,
                              width: 20.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.sp),
                              child: Text(
                                "CATEGORY",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF374151),
                                  decoration: TextDecoration.none,
                                  fontSize: 13.sp,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.sp),
                    child: Container(
                      width: 1.sp,
                      color: borderColor,
                      height: 40.sp,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.sp, horizontal: 10.sp),
                        child: Row(
                          children: [
                            Image.asset(
                              filterIcon,
                              height: 20.sp,
                              width: 20.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.sp),
                              child: Text(
                                "FILTERS",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF374151),
                                  decoration: TextDecoration.none,
                                  fontSize: 13.sp,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
