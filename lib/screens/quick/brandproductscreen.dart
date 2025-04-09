// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomcategory.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomfiltters.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomsortby.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_grid_black.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:lafetch/utils/analytics_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../commonwidget/app_text.dart';
import '../../../controller/product_controller.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../utils/constants.dart';

class BrandViewProductScreen extends StatefulWidget {
  final String title;
  final String genderName;
  final int brand_id;
  final String expresshour;
  final String screen;

  const BrandViewProductScreen(
      {super.key,
      required this.title,
      required this.genderName,
      required this.expresshour,
      required this.screen,
      required this.brand_id});

  @override
  State<BrandViewProductScreen> createState() => BrandViewProductScreenState();
}
 final ScrollController _scrollController = ScrollController();
  final List<String> _triggeredScrolls = [];
class BrandViewProductScreenState extends State<BrandViewProductScreen> {
  final productController = Get.find<ProductController>();
  final wishlistController = Get.put(WishlistController());
  final controller = Get.put(CartController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Timer? debounce;
  String categoryName = "";
  bool isBottomSheet = false;
  PersistentBottomSheetController? bottomController;

  @override
  void initState() {
        _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: homeAppBarColor,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: homeAppBarColor));
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.brandProductDetailsList.clear();
      productController.branddetailsSearchController.clear();
      productController.brandProductHasnextpage.value = true;
      productController.brandProductLoadMore.value = false;
      productController.isProductBrand.value = false;
      productController.brandProductPage.value = 1;
      productController.brandDetailsId.value = widget.brand_id;
      productController.brandDetailsScreen.value = widget.screen;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        productController.getBrandDetailsProduct(
            productController.productSortBy.value,
            productController.filterProductEnable.value,
            false,
            widget.brand_id,
            widget.screen));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getCartData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.brandDetailsController.addListener(() {
        productController.fetchMoreBrandDetails(
            productController.productSortBy.value,
            productController.filterProductEnable.value,
            productController.brandDetailsId.value,
            productController.brandDetailsScreen.value);
        productController.update();
      });
    });
    super.initState();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final scrollPercentage = (currentScroll / maxScroll) * 100;

    if (scrollPercentage >= 25 && !_triggeredScrolls.contains('25%')) {
      AnalyticsHelper.logScrollEvent('25%');
      _triggeredScrolls.add('25%');
    }
    if (scrollPercentage >= 50 && !_triggeredScrolls.contains('50%')) {
      AnalyticsHelper.logScrollEvent('50%');
      _triggeredScrolls.add('50%');
    }
    if (scrollPercentage >= 75 && !_triggeredScrolls.contains('75%')) {
      AnalyticsHelper.logScrollEvent('75%');
      _triggeredScrolls.add('75%');
    }
    if (scrollPercentage >= 100 && !_triggeredScrolls.contains('100%')) {
      AnalyticsHelper.logScrollEvent('100%');
      _triggeredScrolls.add('100%');
    }
  }



  onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      productController.getBrandDetailsProduct(
          productController.productSortBy.value,
          productController.filterProductEnable.value,
          false,
          widget.brand_id,
          widget.screen);
    });
  }

    @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
          sigmaX: isBottomSheet ? 1 : 0, sigmaY: isBottomSheet ? 1 : 0),
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: homeAppBarColor,
          body: Stack(
            children: [
              Visibility(
                visible: widget.screen == "brand" ? false : true,
                child: Positioned(
                  top: 0,
                  right: 0,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                        stops: [0.1, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      quickBackCircle,
                      height: 250.sp,
                      width: 300.sp,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.screen == "quick"
                      ? Padding(
                          padding: EdgeInsets.only(left: 2.sp, top: 56.sp),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: SvgPicture.asset(arrowBack,
                                    color: whiteColor,
                                    height: 15.sp,
                                    width: 15.sp,
                                    fit: BoxFit.cover),
                                onPressed: () {
                                  Get.back();
                                },
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2.sp,
                                child: AppText(
                                  text: widget.title.toUpperCase(),
                                  color: whiteColor,
                                  fontSize: 16,
                                  fontFamily: "Franklin Gothic Semibold",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          color: homeAppBarColor,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: 10.sp, top: 56.sp, bottom: 16.sp),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Get.back();
                                        },
                                        child: Container(
                                          alignment: Alignment.bottomCenter,
                                          padding: EdgeInsets.only(
                                              left: 16.sp,
                                              right: 12.sp,
                                              top: 4.sp),
                                          child: SvgPicture.asset(arrowBack,
                                              color: whiteColor,
                                              height: 15.sp,
                                              width: 15.sp,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      Container(
                                        height: 28.sp,
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 0.sp),
                                          child: AppText(
                                            text: widget.title.toUpperCase(),
                                            color: whiteColor,
                                            fontSize: 16,
                                            fontFamily:
                                                "Franklin Gothic Semibold",
                                            textAlign: TextAlign.center,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: SizedBox(
                                          height: 0,
                                        ),
                                      ),
                                      const Expanded(
                                        child: SizedBox(
                                          height: 0,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          Navigator.push(context,
                                                  scaleIn(const SearchScreen()))
                                              .then(
                                            (value) {
                                              SystemChrome
                                                  .setSystemUIOverlayStyle(
                                                      SystemUiOverlayStyle(
                                                statusBarColor: homeAppBarColor,
                                                statusBarIconBrightness:
                                                    Brightness.light,
                                                statusBarBrightness:
                                                    Brightness.dark,
                                              ));
                                            },
                                          );
                                          await analytics.logEvent(
                                            name: 'search_page',
                                            parameters: <String, Object>{
                                              'page_name': 'search_page',
                                            },
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.sp),
                                          child: SvgPicture.asset(
                                              searchSvgImage,
                                              color: whiteColor,
                                              height: 18.sp,
                                              width: 18.sp,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          Get.to(const WishlistScreen())?.then(
                                            (value) {
                                              SystemChrome
                                                  .setSystemUIOverlayStyle(
                                                      SystemUiOverlayStyle(
                                                statusBarColor: homeAppBarColor,
                                                statusBarIconBrightness:
                                                    Brightness.light,
                                                statusBarBrightness:
                                                    Brightness.dark,
                                              ));
                                            },
                                          );
                                          await analytics.logEvent(
                                            name: 'wishlist_page',
                                            parameters: <String, Object>{
                                              'page_name': 'wishlist_page',
                                            },
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.sp),
                                          child: SvgPicture.asset(heartSvgImage,
                                              height: 18.sp,
                                              color: whiteColor,
                                              width: 18.sp,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          Navigator.push(context,
                                                  scaleIn(const CartScreen()))
                                              .then(
                                            (value) {
                                              SystemChrome
                                                  .setSystemUIOverlayStyle(
                                                      SystemUiOverlayStyle(
                                                statusBarColor: homeAppBarColor
                                                    .withOpacity(0.5),
                                                statusBarIconBrightness:
                                                    Brightness.light,
                                                statusBarBrightness:
                                                    Brightness.dark,
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
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 8.sp, right: 8.sp),
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 3.sp),
                                                child: SvgPicture.asset(
                                                    cartSvgImage,
                                                    color: whiteColor,
                                                    height: 18.sp,
                                                    width: 18.sp,
                                                    fit: BoxFit.cover),
                                              ),
                                              Obx(() => controller
                                                          .cartTotalValue
                                                          .value !=
                                                      0
                                                  ? Positioned(
                                                      right: 0,
                                                      bottom: 0,
                                                      child: Container(
                                                        width: 10.sp,
                                                        height: 10.sp,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(0),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: whiteColor,
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                controller
                                                                    .cartTotalValue
                                                                    .value
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontSize: 8,
                                                                    color:
                                                                        homeAppBarColor,
                                                                    fontFamily:
                                                                        "Libre Franklin Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ), // inner content
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 0,
                                                    ))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16.sp, top: 35.sp, right: 16.sp, bottom: 30.sp),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(
                          widget.screen == "quick" ? 12.sp : 0.sp)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                            sigmaX: widget.screen == "quick" ? 3 : 0,
                            sigmaY: widget.screen == "quick" ? 3 : 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.screen == "quick"
                                ? Colors.black.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(
                                widget.screen == "quick" ? 12.sp : 0.sp)),
                          ),
                          child: RawKeyboardListener(
                            focusNode: FocusNode(),
                            onKey: (value) {
                              print(value);
                              if (value is RawKeyDownEvent) {
                                productController.getBrandDetailsProduct(
                                    productController.productSortBy.value,
                                    productController.filterProductEnable.value,
                                    false,
                                    widget.brand_id,
                                    widget.screen);
                              }
                            },
                            child: TextField(
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                  color: colorSecondary,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontSize: 14.sp),
                              controller: productController
                                  .branddetailsSearchController,
                              onChanged: onSearchChanged,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                filled: true,
                                isDense: true,
                                fillColor: widget.screen == "quick"
                                    ? Color(0xff443e73).withOpacity(0.1)
                                    : Color(0xff1b1b20),
                                prefixIcon: IconButton(
                                  icon: SvgPicture.asset(searchSvgImage,
                                      color: searchTextColor,
                                      height: 17.sp,
                                      width: 17.sp,
                                      fit: BoxFit.cover),
                                  onPressed: () {},
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        widget.screen == "quick"
                                            ? 12.sp
                                            : 0.sp),
                                    borderSide: BorderSide(
                                        color: widget.screen == "quick"
                                            ? appBarColor
                                            : Color(0xff333842))),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      widget.screen == "quick" ? 12.sp : 0.sp),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      widget.screen == "quick" ? 12.sp : 0.sp),
                                  borderSide: BorderSide(
                                      color: widget.screen == "quick"
                                          ? appBarColor
                                          : Color(0xff333842)),
                                ),
                                counterText: "",
                                hintText:
                                    "Search for products for ${widget.title.toUpperCase()}",
                                hintStyle: TextStyle(
                                    fontSize: 14.sp, color: searchTextColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => productController.isProductBrand.value
                        ? Expanded(
                            child: const DummyGridBlack(
                              size: 2,
                            ),
                          )
                        : productController.brandProductDetailsList.isNotEmpty
                            ? Expanded(
                                child: SingleChildScrollView(
                                  controller:
                                      productController.brandDetailsController,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.sp,
                                        ),
                                        child: GridView.count(
                                          shrinkWrap: true,
                                          crossAxisCount: 2,
                                          controller: productController
                                              .brandDetailsController,
                                          scrollDirection: Axis.vertical,
                                          padding: EdgeInsets.zero,
                                          childAspectRatio: 0.6,
                                          physics: const ScrollPhysics(),
                                          crossAxisSpacing: 12.sp,
                                          mainAxisSpacing: 0.sp,
                                          children: List.generate(
                                            productController
                                                .brandProductDetailsList.length,
                                            (index) {
                                              return GestureDetector(
                                                onTap: () async {
                                                  Get.to(ProductDetailsScreen(
                                                          expresshour: widget
                                                              .expresshour,
                                                          backgroundcolor: widget
                                                                      .screen ==
                                                                  "quick"
                                                              ? homeAppBarColor
                                                              : whiteColor,
                                                          expressValue:
                                                              widget.screen ==
                                                                      "quick"
                                                                  ? 1
                                                                  : 0,
                                                          brandName: productController
                                                                  .brandProductDetailsList[index]
                                                              ["name"],
                                                          productId:
                                                              productController
                                                                      .brandProductDetailsList[index]
                                                                  ["id"],
                                                          type: "add"))
                                                      ?.then(
                                                          (value) => setState(
                                                                () {
                                                                  FocusScope.of(
                                                                          context)
                                                                      .unfocus();
                                                                  productController
                                                                      .brandProductHasnextpage
                                                                      .value = true;
                                                                  productController
                                                                      .brandProductLoadMore
                                                                      .value = false;
                                                                  productController
                                                                      .isProductBrand
                                                                      .value = false;
                                                                  productController
                                                                      .brandProductPage
                                                                      .value = 1;
                                                                  controller
                                                                      .getCartData();
                                                                  SystemChrome
                                                                      .setSystemUIOverlayStyle(
                                                                          SystemUiOverlayStyle(
                                                                    statusBarColor:
                                                                        homeAppBarColor
                                                                            .withOpacity(0.5),
                                                                  ));
                                                                },
                                                              ));
                                                  await analytics.logEvent(
                                                    name:
                                                        'brandproduct_product_details',
                                                    parameters: <String,
                                                        Object>{
                                                      'page_name':
                                                          'brandproduct_product_details',
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
                                                          child:
                                                              productController
                                                                          .brandProductDetailsList[index]
                                                                              [
                                                                              "images"]
                                                                          .isNotEmpty &&
                                                                      productController.brandProductDetailsList[index]
                                                                              [
                                                                              "images"] !=
                                                                          null
                                                                  ? ClipRRect(
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(widget.screen == "brand"
                                                                              ? 0
                                                                              : 8
                                                                                  .sp),
                                                                          bottomLeft: Radius.circular(widget.screen == "brand"
                                                                              ? 0
                                                                              : 8
                                                                                  .sp),
                                                                          bottomRight: Radius.circular(widget.screen == "brand"
                                                                              ? 0
                                                                              : 8
                                                                                  .sp),
                                                                          topRight: Radius.circular(widget.screen == "brand"
                                                                              ? 0
                                                                              : 8.sp)),
                                                                      child:
                                                                          SizedBox(
                                                                        height: (MediaQuery.of(context).size.width /
                                                                                2) +
                                                                            10.sp,
                                                                        width: (MediaQuery.of(context).size.width /
                                                                                2) -
                                                                            24.sp,
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          cacheManager: CacheManager(Config(
                                                                              "customCacheKey",
                                                                              stalePeriod: const Duration(days: 15),
                                                                              maxNrOfCacheObjects: 100)),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          imageUrl: isImage(productController.brandProductDetailsList[index]["images"][0]["name"])
                                                                              ? productController.brandProductDetailsList[index]["images"][0]["name"]
                                                                              : productController.brandProductDetailsList[index]["images"][1]["name"],
                                                                          errorWidget: (context, url, error) =>
                                                                              Image.asset(
                                                                            downloadImage,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            height:
                                                                                (MediaQuery.of(context).size.width / 2) + 10.sp,
                                                                            width:
                                                                                (MediaQuery.of(context).size.width / 2) - 24.sp,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Image.asset(
                                                                      dummyWishlistImage,
                                                                      height: (MediaQuery.of(context).size.width /
                                                                              2) +
                                                                          10.sp,
                                                                      width: (MediaQuery.of(context).size.width /
                                                                              2) -
                                                                          24.sp,
                                                                      fit: BoxFit
                                                                          .cover),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 8.sp),
                                                      child: AppText(
                                                        text:
                                                            "${productController.brandProductDetailsList[index]["name"]}",
                                                        color:
                                                            productSubtitleColor,
                                                        maxLines: 1,
                                                        fontSize: 11,
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        top: 8.sp,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Visibility(
                                                            visible: productController
                                                                            .brandProductDetailsList[index]
                                                                        [
                                                                        "mrp"] !=
                                                                    null
                                                                ? true
                                                                : false,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          6.sp),
                                                              child: Text(
                                                                "\u{20B9} ${productController.brandProductDetailsList[index]["mrp"] ?? ""}",
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      searchTextColor,
                                                                  fontSize:
                                                                      11.sp,
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
                                                          ),
                                                          AppText(
                                                            text:
                                                                "\u{20B9} ${productController.brandProductDetailsList[index]["price"] ?? ""}",
                                                            color: isBottomSheet
                                                                ? whiteColor
                                                                    .withOpacity(
                                                                        0.5)
                                                                : whiteColor,
                                                            maxLines: 2,
                                                            fontSize: 11,
                                                            fontFamily:
                                                                "Franklin Gothic",
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      productController
                                              .brandProductLoadMore.value
                                          ? DummyGridBlack()
                                          : const SizedBox(
                                              height: 0,
                                            ),
                                    ],
                                  ),
                                ),
                              )
                            : Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 20.sp),
                                        child: Center(
                                          child: Image.asset(errorImage,
                                              height: 200.sp,
                                              width: 220.sp,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 20.sp),
                                        child: getSingleButton(
                                            width: double.infinity,
                                            label: widget.screen == "quick"
                                                ? "Back to Quick".toUpperCase()
                                                : "Back to Brands"
                                                    .toUpperCase(),
                                            textColor: whiteColor,
                                            fontSize: 13,
                                            backgroundColor: homeAppBarColor,
                                            onPressed: () {
                                              if (widget.screen == "quick") {
                                                Get.back();
                                              } else {
                                                Get.close(2);
                                              }
                                            },
                                            borderColor: whiteColor),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                  ),
                  Container(
                    height: 1.sp,
                    width: MediaQuery.of(context).size.width,
                    color: titleColor,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              isBottomSheet = true;
                            });
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              constraints: BoxConstraints(
                                maxWidth: double.infinity,
                                maxHeight: 340.sp,
                              ),
                              builder: (ctx) {
                                return BottomSortBy(
                                  backgroundColor: homeAppBarColor,
                                  onPressedButton: (p0) {
                                    productController.productSortBy.value = p0;
                                    productController.getBrandDetailsProduct(
                                        productController.productSortBy.value,
                                        productController
                                            .filterProductEnable.value,
                                        false,
                                        widget.brand_id,
                                        widget.screen);
                                  },
                                );
                              },
                            ).whenComplete(() {
                              setState(() {
                                isBottomSheet = false;
                              });
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.sp, horizontal: 5.sp),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    color: whiteColor,
                                    sortBySvgImage,
                                    height: 19.sp,
                                    width: 15.sp,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.sp),
                                    child: Text(
                                      "SORT BY",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: whiteColor,
                                        decoration: TextDecoration.none,
                                        fontSize: 13.sp,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.sp),
                          child: Container(
                            width: 1.sp,
                            color: titleColor,
                            height: 46.sp,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isBottomSheet = true;
                            });
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              constraints: BoxConstraints(
                                maxWidth: double.infinity,
                                maxHeight: 270.sp,
                              ),
                              builder: (ctx) {
                                return BottomCategory(
                                  backgroundColor: homeAppBarColor,
                                  gender: widget.genderName,
                                  onPressedButton: (p0) {
                                    if (p0 == "Women") {
                                      productController.categoryFilter.value =
                                          3;
                                    } else if (p0 == "Men") {
                                      productController.categoryFilter.value =
                                          2;
                                    } else {
                                      productController.categoryFilter.value =
                                          1;
                                    }
                                    productController.getBrandDetailsProduct(
                                        productController.productSortBy.value,
                                        productController
                                            .filterProductEnable.value,
                                        false,
                                        widget.brand_id,
                                        widget.screen);
                                    categoryName = p0;
                                    setState(() {});
                                  },
                                  onPressedFilter: () {
                                    Get.back();
                                    setState(() {
                                      isBottomSheet = true;
                                    });
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      constraints: BoxConstraints(
                                        maxWidth: double.infinity,
                                        maxHeight: 500.sp,
                                      ),
                                      builder: (ctx) {
                                        return BottomFilters(
                                          backgroundColor: homeAppBarColor,
                                          btnclearAll: () async {
                                            productController.brand_ids.clear();
                                            productController.color_ids.clear();
                                            productController.size_ids.clear();
                                            productController
                                                .productSortBy.value = "";
                                            productController
                                                .filterProductEnable
                                                .value = false;
                                            final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            prefs.remove("brandList");
                                            prefs.remove("colorList");
                                            prefs.remove("sizeList");
                                            prefs.remove("upper");
                                            prefs.remove("lower");
                                            prefs.remove("sortby");
                                            prefs.remove("category");
                                            productController
                                                .getBrandDetailsProduct(
                                                    productController
                                                        .productSortBy.value,
                                                    productController
                                                        .filterProductEnable
                                                        .value,
                                                    false,
                                                    widget.brand_id,
                                                    widget.screen);
                                          },
                                          onClick: (p0, p1) {
                                            productController
                                                .filterProductEnable
                                                .value = true;
                                            productController.lowPrice.value =
                                                p0;
                                            productController.highPrice.value =
                                                p1;
                                            productController
                                                .getBrandDetailsProduct(
                                                    productController
                                                        .productSortBy.value,
                                                    productController
                                                        .filterProductEnable
                                                        .value,
                                                    true,
                                                    widget.brand_id,
                                                    widget.screen);
                                          },
                                        );
                                      },
                                    ).whenComplete(() {
                                      setState(() {
                                        isBottomSheet = false;
                                      });
                                    });
                                  },
                                );
                              },
                            ).whenComplete(() {
                              setState(() {
                                isBottomSheet = false;
                              });
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.sp, horizontal: 5.sp),
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.sp),
                                    child: Text(
                                      "CATEGORY",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: whiteColor,
                                        decoration: TextDecoration.none,
                                        fontSize: 13.sp,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        categoryName.isEmpty ? false : true,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 5.sp, right: 5.sp, top: 1.sp),
                                      child: Text(
                                        categoryName.toUpperCase(),
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: lightgreyColor,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.sp),
                          child: Container(
                            width: 1.sp,
                            color: titleColor,
                            height: 46.sp,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isBottomSheet = true;
                            });
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              constraints: BoxConstraints(
                                maxWidth: double.infinity,
                                maxHeight: 500.sp,
                              ),
                              builder: (ctx) {
                                return BottomFilters(
                                  backgroundColor: homeAppBarColor,
                                  btnclearAll: () async {
                                    productController.brand_ids.clear();
                                    productController.color_ids.clear();
                                    productController.size_ids.clear();
                                    productController.productSortBy.value = "";
                                    productController
                                        .filterProductEnable.value = false;
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.remove("brandList");
                                    prefs.remove("colorList");
                                    prefs.remove("sizeList");
                                    prefs.remove("upper");
                                    prefs.remove("lower");
                                    prefs.remove("sortby");
                                    prefs.remove("category");
                                    productController.getBrandDetailsProduct(
                                        productController.productSortBy.value,
                                        productController
                                            .filterProductEnable.value,
                                        false,
                                        widget.brand_id,
                                        widget.screen);
                                  },
                                  onClick: (p0, p1) {
                                    productController
                                        .filterProductEnable.value = true;
                                    productController.lowPrice.value = p0;
                                    productController.highPrice.value = p1;
                                    productController.getBrandDetailsProduct(
                                        productController.productSortBy.value,
                                        productController
                                            .filterProductEnable.value,
                                        true,
                                        widget.brand_id,
                                        widget.screen);
                                  },
                                );
                              },
                            ).whenComplete(() {
                              setState(() {
                                isBottomSheet = false;
                              });
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.sp, horizontal: 5.sp),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    filterSvgImage,
                                    color: whiteColor,
                                    height: 11.sp,
                                    width: 17.sp,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.sp),
                                    child: Text(
                                      "FILTERS",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: whiteColor,
                                        decoration: TextDecoration.none,
                                        fontSize: 13.sp,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
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
                  ),
                  Container(
                    height: 1.sp,
                    width: MediaQuery.of(context).size.width,
                    color: titleColor,
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
