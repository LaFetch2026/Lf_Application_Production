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
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';

import '../common/widget/appbar/home_appbar.dart';
import '../common/widget/lists/dummy_brand_list.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/brand_controller.dart';
import '../core/constant/constants.dart';
import 'bottomnavscreen.dart';
import 'cartscreen.dart';

class BrandsScreen extends StatefulWidget {
  final String? screen;
  final String? logo;
  final String? backImage;
  final int? brandId;
  final String? name;

  const BrandsScreen(
      {super.key,
      this.screen,
      this.logo,
      this.backImage,
      this.name,
      this.brandId});

  @override
  State<BrandsScreen> createState() => BrandsScreenState();
}

class BrandsScreenState extends State<BrandsScreen> {
  final brandController = Get.put(BrandController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Timer? debounce;
  var brandDetails = {}.obs; // holds full brandInfo + products
  var brandProductDetailsList = <Map<String, dynamic>>[].obs;
  var brand_category_List = <int>[].obs;
  var isDetails = false.obs;

  onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () async {
      brandController.queryText.value = query;
      brandController.getBrandData("brand");
      await analytics.logEvent(
        name: 'brand_page_search',
        parameters: <String, Object>{
          'page_name': 'brand_page_search',
        },
      );
    });
  }

  @override
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      brandController.hasnextpage.value = true;
      brandController.loadMore.value = false;
      brandController.isBrand.value = false;
      brandController.page.value = 1;
      brandController.searchController.clear();
      brandController.queryText.value = "";

      // ✅ This ensures API is called with &type=alphabet
      await brandController.getBrandData("brand");
    });

    if (widget.screen == "search") {
      brandController.showAllBrand.value = true;
      brandController.brandlogo.value = widget.logo!;
      brandController.brandbackground.value = widget.backImage!;
      brandController.brandName.value = widget.name!;
      brandController.brandId.value = widget.brandId!;
      brandController.update();
    } else {
      brandController.showAllBrand.value = false;
    }

    brandController.text.value = "Expand All";
    brandController.selectIndex.value = 0;
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => WillPopScope(
          onWillPop: () async {
            Get.offAll(const BottomNavScreen(
              index: 0,
            ));
            return false;
          },
          child: Scaffold(
            backgroundColor: whiteColor,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeAppbar(
                  showSearch: false,
                  title: "Brands",
                  onPressedHeart: () async {
                    Get.to(const WishlistScreen())?.then(
                      (value) {
                        SystemChrome.setSystemUIOverlayStyle(
                            const SystemUiOverlayStyle(
                                statusBarColor: whiteColor,
                                systemNavigationBarColor: whiteColor));
                      },
                    );
                    await analytics.logEvent(
                      name: 'wishlist_page',
                      parameters: <String, Object>{
                        'page_name': 'wishlist_page',
                      },
                    );
                  },
                  onPressedCart: () async {
                    Get.to(const CartScreen())?.then(
                      (value) {
                        SystemChrome.setSystemUIOverlayStyle(
                            const SystemUiOverlayStyle(
                                statusBarColor: whiteColor,
                                systemNavigationBarColor: whiteColor));
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
                SizedBox(
                  height: 10.sp,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.sp, vertical: 4.sp),
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (value) {
                      print(value);
                      if (value is RawKeyDownEvent) {
                        brandController.queryText.value = "";
                        brandController.getBrandData("brand");
                      }
                    },
                    child: TextField(
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                          color: titleColor,
                          fontFamily: "Franklin Gothic Regular",
                          fontSize: 14.sp),
                      controller: brandController.searchController,
                      onChanged: onSearchChanged,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        filled: true,
                        isDense: true,
                        fillColor: whiteColor,
                        prefixIcon: IconButton(
                          icon: SvgPicture.asset(searchSvgImage,
                              color: titleColor,
                              height: 17.sp,
                              width: 17.sp,
                              fit: BoxFit.cover),
                          onPressed: () {},
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: borderColor)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1.sp),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1.sp),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        counterText: "",
                        hintText: "Search for 'Brands'",
                        hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: searchTextColor,
                            fontFamily: "Franklin Gothic Regular"),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: brandController.brandListController,
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        setState(() {});
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          brandController.isBrand.value
                              ? const DummybrandList()
                              : brandController.brandList.isNotEmpty
                                  ?
                                  // Replace your current ListView.builder section with this fixed version

// Replace your current ListView.builder section with this version
// This works with a flat list of brands from your API

                                  Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 10.sp, top: 4.sp),
                                      child: GetBuilder<BrandController>(
                                          builder: (val) {
                                        // Group brands by alphabet
                                        Map<String, List> groupedBrands = {};

                                        for (var brand in val.brandList) {
                                          String brandName =
                                              brand['name'] ?? '';
                                          if (brandName.isNotEmpty) {
                                            String firstLetter =
                                                brandName[0].toUpperCase();
                                            if (!groupedBrands
                                                .containsKey(firstLetter)) {
                                              groupedBrands[firstLetter] = [];
                                            }
                                            groupedBrands[firstLetter]!
                                                .add(brand);
                                          }
                                        }

                                        // Sort alphabets
                                        List<String> sortedAlphabets =
                                            groupedBrands.keys.toList()..sort();

                                        return ListView.builder(
                                            primary: false,
                                            shrinkWrap: true,
                                            controller: val.brandListController,
                                            physics: const ScrollPhysics(),
                                            itemCount: sortedAlphabets.length,
                                            padding: EdgeInsets.zero,
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (ctx, a) {
                                              String alphabet =
                                                  sortedAlphabets[a];
                                              List brandsForAlphabet =
                                                  groupedBrands[alphabet] ?? [];

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  // Divider (except for first item)
                                                  Visibility(
                                                    visible: a != 0,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8.sp),
                                                      child: Container(
                                                        height: 1.sp,
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                    ),
                                                  ),

                                                  // Alphabet Header
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 8.sp,
                                                      horizontal: 16.sp,
                                                    ),
                                                    child: AppText(
                                                      text: alphabet,
                                                      color: subtitleColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),

                                                  // Brands for this alphabet
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 16.sp),
                                                    child: ListView.builder(
                                                      primary: false,
                                                      shrinkWrap: true,
                                                      physics:
                                                          const ScrollPhysics(),
                                                      itemCount:
                                                          brandsForAlphabet
                                                              .length,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder:
                                                          (ctx, index) {
                                                        final brand =
                                                            brandsForAlphabet[
                                                                index];
                                                        final isExpanded = val
                                                                .selectIndex
                                                                .value ==
                                                            brand["id"];
                                                        final products =
                                                            brand["products"] ??
                                                                [];

                                                        return Column(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () async {
                                                                try {
                                                                  // 🔹 Store base brand info in controller for immediate UI access
                                                                  brandController
                                                                          .brandlogo
                                                                          .value =
                                                                      brand[
                                                                          "logo"];
                                                                  brandController
                                                                      .brandbackground
                                                                      .value = brand[
                                                                          "background_image"] ??
                                                                      "";
                                                                  brandController
                                                                          .brandName
                                                                          .value =
                                                                      brand[
                                                                          "name"];
                                                                  brandController
                                                                      .showAllBrand
                                                                      .value = true;
                                                                  brandController
                                                                          .brandId
                                                                          .value =
                                                                      brand[
                                                                          "id"];

                                                                  // 🔹 Fetch full brand details from API before navigation
                                                                  await brandController
                                                                      .getBrandDetails(
                                                                          brand[
                                                                              "id"],
                                                                          "");

                                                                  // 🔹 Navigate to brand detail screen
                                                                  await Get.to(
                                                                      () =>
                                                                          AllBrandScreen(
                                                                            id: brand["id"],
                                                                            slug:
                                                                                "",
                                                                            screen:
                                                                                widget.screen ?? "",
                                                                          ));

                                                                  // 🔹 Restore system UI colors
                                                                  SystemChrome
                                                                      .setSystemUIOverlayStyle(
                                                                          const SystemUiOverlayStyle(
                                                                    statusBarColor:
                                                                        whiteColor,
                                                                    systemNavigationBarColor:
                                                                        whiteColor,
                                                                    statusBarIconBrightness:
                                                                        Brightness
                                                                            .dark,
                                                                    statusBarBrightness:
                                                                        Brightness
                                                                            .light,
                                                                  ));

                                                                  // 🔹 Log analytics event
                                                                  await analytics
                                                                      .logEvent(
                                                                    name:
                                                                        'brand_details',
                                                                    parameters: {
                                                                      'page_name':
                                                                          'brand_details'
                                                                    },
                                                                  );
                                                                } catch (e) {
                                                                  print(
                                                                      "❌ Error navigating to brand details: $e");
                                                                }
                                                              },
                                                              child: Container(
                                                                color:
                                                                    statusBarColor,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(10
                                                                            .sp),
                                                                child: Row(
                                                                  children: [
                                                                    // Brand logo
                                                                    brand["logo"] !=
                                                                            null
                                                                        ? Container(
                                                                            height:
                                                                                48.sp,
                                                                            width:
                                                                                48.sp,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              border: Border.all(
                                                                                width: 1.sp,
                                                                                color: lightgreyColor,
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                ClipOval(
                                                                              child: CachedNetworkImage(
                                                                                cacheManager: CacheManager(
                                                                                  Config(
                                                                                    "customCacheKey",
                                                                                    stalePeriod: const Duration(days: 15),
                                                                                  ),
                                                                                ),
                                                                                fit: BoxFit.contain,
                                                                                imageUrl: brand["logo"],
                                                                                errorWidget: (context, url, error) => Image.asset(downloadImage),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : CircleAvatar(
                                                                            child:
                                                                                Image.asset(dummyWishlistImage),
                                                                          ),

                                                                    SizedBox(
                                                                        width: 12
                                                                            .sp),

                                                                    // Brand name
                                                                    Expanded(
                                                                      child:
                                                                          AppText(
                                                                        text: brand["name"] ??
                                                                            "",
                                                                        color:
                                                                            colorPrimary,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            "Franklin Gothic Regular",
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                    ),

                                                                    // Expand icon
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        val.selectIndex.value = isExpanded
                                                                            ? 0
                                                                            : brand["id"];
                                                                        val.update();
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(horizontal: 12.sp),
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          isExpanded
                                                                              ? upDropDownSvgImage
                                                                              : dropdownSvgImage,
                                                                          color:
                                                                              colorPrimary,
                                                                          height:
                                                                              7.sp,
                                                                          width:
                                                                              11.sp,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),

                                                            // Expandable Product Grid
                                                            isExpanded
                                                                ? (products
                                                                        .isNotEmpty
                                                                    ? Column(
                                                                        children: [
                                                                          SizedBox(
                                                                              height: 10.sp),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 16.sp),
                                                                            child:
                                                                                GridView.count(
                                                                              shrinkWrap: true,
                                                                              crossAxisCount: 3,
                                                                              childAspectRatio: 0.85,
                                                                              physics: const ScrollPhysics(),
                                                                              crossAxisSpacing: 10.sp,
                                                                              mainAxisSpacing: 10.sp,
                                                                              children: List.generate(products.length, (i) {
                                                                                final product = products[i];
                                                                                final imageUrl = product["images"]?.isNotEmpty == true ? product["images"][0]["name"] : null;

                                                                                return GestureDetector(
                                                                                  onTap: () async {
                                                                                    try {
                                                                                      // 🔹 Preload basic brand info
                                                                                      brandController.brandlogo.value = brand["logo"];
                                                                                      brandController.brandbackground.value = brand["background_image"] ?? "";
                                                                                      brandController.brandName.value = brand["name"];
                                                                                      brandController.showAllBrand.value = true;
                                                                                      brandController.brandId.value = brand["id"];

                                                                                      // 🔹 Fetch full details
                                                                                      await brandController.getBrandDetails(brand["id"], "");

                                                                                      // 🔹 Navigate
                                                                                      await Get.to(() => AllBrandScreen(
                                                                                            id: brand["id"],
                                                                                            slug: "",
                                                                                            screen: widget.screen ?? "",
                                                                                          ));

                                                                                      // 🔹 Restore system UI overlay colors
                                                                                      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                                                                                        statusBarColor: whiteColor,
                                                                                        systemNavigationBarColor: whiteColor,
                                                                                        statusBarIconBrightness: Brightness.dark,
                                                                                        statusBarBrightness: Brightness.light,
                                                                                      ));

                                                                                      // 🔹 Log analytics
                                                                                      await analytics.logEvent(
                                                                                        name: 'brand_details',
                                                                                        parameters: {
                                                                                          'page_name': 'brand_details'
                                                                                        },
                                                                                      );
                                                                                    } catch (e) {
                                                                                      print("❌ Error on product tap: $e");
                                                                                    }
                                                                                  },
                                                                                  child: Column(
                                                                                    children: [
                                                                                      imageUrl != null
                                                                                          ? SizedBox(
                                                                                              height: 97.sp,
                                                                                              width: 97.sp,
                                                                                              child: CachedNetworkImage(
                                                                                                cacheManager: CacheManager(
                                                                                                  Config(
                                                                                                    "customCacheKey",
                                                                                                    stalePeriod: const Duration(days: 15),
                                                                                                  ),
                                                                                                ),
                                                                                                fit: BoxFit.cover,
                                                                                                imageUrl: imageUrl,
                                                                                                errorWidget: (context, url, error) => Image.asset(
                                                                                                  downloadImage,
                                                                                                  height: 97.sp,
                                                                                                  width: 97.sp,
                                                                                                ),
                                                                                              ),
                                                                                            )
                                                                                          : Image.asset(
                                                                                              dummyWishlistImage,
                                                                                              height: 97.sp,
                                                                                              width: 97.sp,
                                                                                            ),
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              }),
                                                                            ),
                                                                          ),
                                                                          InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              brandController.brandlogo.value = brand["logo"];
                                                                              brandController.brandbackground.value = brand["background_image"] ?? "";
                                                                              brandController.brandName.value = brand["name"];
                                                                              brandController.showAllBrand.value = true;
                                                                              brandController.brandId.value = brand["id"];
                                                                              brandController.brandProductDetailsList.clear();

                                                                              Get.to(AllBrandScreen(
                                                                                id: brand["id"],
                                                                                slug: "",
                                                                                screen: widget.screen!,
                                                                              ))?.then((value) {
                                                                                SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                                                                                  statusBarColor: whiteColor,
                                                                                  systemNavigationBarColor: whiteColor,
                                                                                  statusBarIconBrightness: Brightness.dark,
                                                                                  statusBarBrightness: Brightness.light,
                                                                                ));
                                                                              });

                                                                              await analytics.logEvent(
                                                                                name: 'brand_details',
                                                                                parameters: {
                                                                                  'page_name': 'brand_details'
                                                                                },
                                                                              );
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.symmetric(vertical: 8.sp),
                                                                              child: Container(
                                                                                height: 42.sp,
                                                                                color: homeAppBarColor,
                                                                                width: double.infinity,
                                                                                child: Center(
                                                                                  child: AppText(
                                                                                    text: "EXPLORE BRAND",
                                                                                    fontFamily: "Franklin Gothic",
                                                                                    fontWeight: FontWeight.w400,
                                                                                    color: whiteColor,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      )
                                                                    : Padding(
                                                                        padding:
                                                                            EdgeInsets.all(12.sp),
                                                                        child:
                                                                            Text(
                                                                          "No Product Found",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14.sp,
                                                                            fontFamily:
                                                                                "Franklin Gothic Regular",
                                                                          ),
                                                                        ),
                                                                      ))
                                                                : const SizedBox
                                                                    .shrink(),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  )
                                                ],
                                              );
                                            });
                                      }),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 80.sp),
                                          child: Center(
                                            child: Image.asset(errorImage,
                                                height: 200.sp,
                                                width: 220.sp,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: 6.sp,
                                                left: 20.sp,
                                                bottom: 20.sp,
                                                right: 20.sp),
                                            child: brandController
                                                    .searchController.text
                                                    .toString()
                                                    .trim()
                                                    .isNotEmpty
                                                ? Text(
                                                    "No ${brandController.searchController.text.toString().trim()} found"
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: homeAppBarColor,
                                                        fontFamily:
                                                            "Franklin Gothic"))
                                                : Text(
                                                    "Coming Soon to Your Area",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: homeAppBarColor,
                                                        fontFamily:
                                                            "Franklin Gothic"))),
                                      ],
                                    ),
                          brandController.loadMore.value
                              ? const DummybrandList()
                              : const SizedBox(
                                  height: 0,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
