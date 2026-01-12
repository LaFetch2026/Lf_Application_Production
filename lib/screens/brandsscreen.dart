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
  var brandDetails = {}.obs;
  var brandProductDetailsList = <Map<String, dynamic>>[].obs;
  var brand_category_List = <int>[].obs;
  var isDetails = false.obs;

  // ✅ Cache management - prevent unnecessary API calls
  static DateTime? _lastDataFetch;
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  static String? _lastSearchQuery;

  onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () async {
      brandController.queryText.value = query;

      // ✅ Reset cache when search query changes
      _lastDataFetch = null;
      _lastSearchQuery = query;

      brandController.getBrandData("brand");
      await analytics.logEvent(
        name: 'brand_page_search',
        parameters: <String, Object>{
          'page_name': 'brand_page_search',
        },
      );
    });
  }

  // ✅ Helper method to check if data should be fetched
  bool _shouldFetchData(String currentQuery) {
    // First time loading
    if (_lastDataFetch == null) {
      return true;
    }

    // Search query changed
    if (_lastSearchQuery != currentQuery) {
      return true;
    }

    // Cache expired
    final timeSinceLastFetch = DateTime.now().difference(_lastDataFetch!);
    if (timeSinceLastFetch > _cacheValidDuration) {
      return true;
    }

    // Data already loaded and still valid
    return false;
  }

// ✅ Method to force refresh data (for pull-to-refresh)
  Future<void> forceRefreshData() async {
    print("🔄 Force refresh triggered - Brands");

    setState(() {
      _lastDataFetch = null;
      _lastSearchQuery = null;
    });

    // ✅ Pass showLoader: false to prevent skeleton loader during pull-to-refresh
    await brandController.getBrandData("brand");

    _lastDataFetch = DateTime.now();
    _lastSearchQuery = brandController.queryText.value;

    if (mounted) {
      setState(() {});
    }
  }

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

      // ✅ Check if we need to fetch data or use cached data
      final currentQuery = brandController.queryText.value;
      final shouldFetch = _shouldFetchData(currentQuery);

      if (shouldFetch) {
        print("🔄 Fetching fresh brand data...");
        await brandController.getBrandData("brand");

        // ✅ Update cache timestamp
        _lastDataFetch = DateTime.now();
        _lastSearchQuery = currentQuery;
      } else {
        print(
            "✅ Using cached brand data (fetched ${DateTime.now().difference(_lastDataFetch!).inMinutes} minutes ago)");
      }
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
                    Get.to(CartScreen())?.then(
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

                        // ✅ Reset cache when clearing search
                        _lastDataFetch = null;
                        _lastSearchQuery = "";

                        brandController.getBrandData("brand");
                        _lastDataFetch = DateTime.now();
                      }
                    },
                    child: TextField(
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                          color: titleColor,
                          fontFamily: "Clash Display Regular",
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
                            fontFamily: "Clash Display Regular"),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    // ✅ ADDED: Pull-to-refresh functionality
                    onRefresh: forceRefreshData,
                    child: SingleChildScrollView(
                      controller: brandController.brandListController,
                      physics:
                          const AlwaysScrollableScrollPhysics(), // ✅ Enables pull-to-refresh even when content is short
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
                                    ? Padding(
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
                                              groupedBrands.keys.toList()
                                                ..sort();

                                          return ListView.builder(
                                              primary: false,
                                              shrinkWrap: true,
                                              controller:
                                                  val.brandListController,
                                              physics: const ScrollPhysics(),
                                              itemCount: sortedAlphabets.length,
                                              padding: EdgeInsets.zero,
                                              scrollDirection: Axis.vertical,
                                              addAutomaticKeepAlives: false,
                                              addRepaintBoundaries: true,
                                              cacheExtent: 500,
                                              itemBuilder: (ctx, a) {
                                                String alphabet =
                                                    sortedAlphabets[a];
                                                List brandsForAlphabet =
                                                    groupedBrands[alphabet] ??
                                                        [];

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
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 8.sp),
                                                        child: Container(
                                                          height: 1.sp,
                                                          color: Colors
                                                              .transparent,
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
                                                            "Clash Display Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),

                                                    // Brands for this alphabet
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  16.sp),
                                                      child: ListView.builder(
                                                        primary: false,
                                                        shrinkWrap: true,
                                                        physics:
                                                            const ScrollPhysics(),
                                                        itemCount:
                                                            brandsForAlphabet
                                                                .length,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        addAutomaticKeepAlives: false,
                                                        addRepaintBoundaries: true,
                                                        itemBuilder:
                                                            (ctx, index) {
                                                          final brand =
                                                              brandsForAlphabet[
                                                                  index];
                                                          final isExpanded = val
                                                                  .selectIndex
                                                                  .value ==
                                                              brand["id"];
                                                          // TODO: WORKAROUND - Using /view-brand API instead of /brand-products
                                                          // Root cause: /brand-products API returns incomplete data (only id + title)
                                                          // Impact: Fetching products from brandDetails["products"] when brand is expanded
                                                          // Action needed: Switch to getBrandProducts() when backend fixes the endpoint
                                                          final rawProducts = (isExpanded && val.selectIndex.value == brand["id"])
                                                              ? (brandController.brandDetails["products"] as List? ?? [])
                                                              : [];

                                                          // 🔍 DEBUG: Log brand and product data
                                                          if (isExpanded) {
                                                            print("📦 Brand expanded: ${brand["name"]} (ID: ${brand["id"]})");
                                                            print("   Brand logo URL: ${brand["logo"]}");
                                                            print("   Products count: ${rawProducts.length}");
                                                            if (rawProducts.isNotEmpty) {
                                                              print("   First product: ${rawProducts.first}");
                                                            }
                                                          }

                                                          // ✅ Show first 3 products in consistent order (by product ID)
                                                          final sortedProducts = List.from(rawProducts)..sort((a, b) => (a["id"] ?? 0).compareTo(b["id"] ?? 0));
                                                          final products = sortedProducts.take(3).toList();

                                                          return Column(
                                                            children: [
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  try {
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

                                                                    await brandController
                                                                        .getBrandDetails(
                                                                            brand["id"],
                                                                            "");

                                                                    await Get.to(
                                                                        () =>
                                                                            AllBrandScreen(
                                                                              id: brand["id"],
                                                                              slug: "",
                                                                              screen: widget.screen ?? "",
                                                                            ));

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
                                                                child:
                                                                    Container(
                                                                  color:
                                                                      statusBarColor,
                                                                  padding:
                                                                      EdgeInsets.only(
                                                                        left: 10.sp,
                                                                        right: 10.sp,
                                                                        top: 10.sp,
                                                                        bottom: isExpanded ? 6.sp : 10.sp,
                                                                      ),
                                                                  child: Row(
                                                                    children: [
                                                                      brand["logo"] !=
                                                                              null
                                                                          ? Container(
                                                                              height: 48.sp,
                                                                              width: 48.sp,
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                border: Border.all(
                                                                                  width: 1.sp,
                                                                                  color: lightgreyColor,
                                                                                ),
                                                                              ),
                                                                              child: ClipOval(
                                                                                child: CachedNetworkImage(
                                                                                  cacheManager: CacheManager(
                                                                                    Config(
                                                                                      "brandLogosCache",
                                                                                      stalePeriod: const Duration(days: 15),
                                                                                      maxNrOfCacheObjects: 100,
                                                                                    ),
                                                                                  ),
                                                                                  fit: BoxFit.contain,
                                                                                  imageUrl: brand["logo"],
                                                                                  placeholder: (context, url) => Container(
                                                                                    color: Colors.grey[200],
                                                                                    child: const Icon(Icons.storefront, size: 24, color: Colors.grey),
                                                                                  ),
                                                                                  errorWidget: (context, url, error) {
                                                                                    print("❌ [BrandsScreen] Brand logo load failed");
                                                                                    print("   URL: $url");
                                                                                    print("   Error: $error");
                                                                                    return Container(
                                                                                      color: Colors.grey[200],
                                                                                      child: const Icon(Icons.storefront, size: 24, color: Colors.grey),
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : CircleAvatar(
                                                                              child: Image.asset(dummyWishlistImage),
                                                                            ),
                                                                      SizedBox(
                                                                          width:
                                                                              12.sp),
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
                                                                              "Clash Display Regular",
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          // Toggle expansion
                                                                          if (isExpanded) {
                                                                            val.selectIndex.value = 0;
                                                                          } else {
                                                                            try {
                                                                              val.selectIndex.value = brand["id"];

                                                                              // TODO: WORKAROUND - Fetch complete product data from /view-brand API
                                                                              // because /brand-products only returns id and title
                                                                              // Only fetch if we don't have products cached for this brand
                                                                              final currentBrandDetails = brandController.brandDetails;
                                                                              final needsToFetch = currentBrandDetails.isEmpty ||
                                                                                  currentBrandDetails["brandInfo"]?["id"] != brand["id"] ||
                                                                                  (currentBrandDetails["products"] as List?)?.isEmpty == true;

                                                                              if (needsToFetch) {
                                                                                print("🔄 Fetching brand details for expanded brand: ${brand["name"]}");
                                                                                await brandController.getBrandDetails(brand["id"], "");
                                                                              } else {
                                                                                print("✅ Using cached brand details for: ${brand["name"]}");
                                                                              }
                                                                            } catch (e) {
                                                                              print("❌ Error fetching brand details on expand: $e");
                                                                              // Collapse on error
                                                                              val.selectIndex.value = 0;
                                                                            }
                                                                          }
                                                                          val.update();
                                                                        },
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 12.sp),
                                                                          child:
                                                                              SvgPicture.asset(
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
                                                                            // SizedBox(height: 8.sp),
                                                                            Padding(
                                                                              padding: EdgeInsets.symmetric(horizontal: 16.sp),
                                                                              child: GridView.count(
                                                                                padding: EdgeInsets.zero,
                                                                                shrinkWrap: true,
                                                                                crossAxisCount: 3,
                                                                                childAspectRatio: 0.85,
                                                                                physics: const ScrollPhysics(),
                                                                                crossAxisSpacing: 10.sp,
                                                                                mainAxisSpacing: 10.sp,
                                                                                addAutomaticKeepAlives: false,
                                                                                addRepaintBoundaries: true,
                                                                                children: List.generate(products.length, (i) {
                                                                                  final product = products[i];
                                                                                  // Support both image formats: "images" array or "imageUrls" array
                                                                                  String? imageUrl;
                                                                                  if (product["images"] != null &&
                                                                                      product["images"] is List &&
                                                                                      product["images"].isNotEmpty &&
                                                                                      product["images"][0] != null &&
                                                                                      product["images"][0] is Map &&
                                                                                      product["images"][0]["name"] != null) {
                                                                                    imageUrl = product["images"][0]["name"].toString();
                                                                                  } else if (product["imageUrls"] != null &&
                                                                                             product["imageUrls"] is List &&
                                                                                             product["imageUrls"].isNotEmpty &&
                                                                                             product["imageUrls"][0] != null) {
                                                                                    imageUrl = product["imageUrls"][0].toString();
                                                                                  }

                                                                                  return GestureDetector(
                                                                                    onTap: () async {
                                                                                      try {
                                                                                        brandController.brandlogo.value = brand["logo"];
                                                                                        brandController.brandbackground.value = brand["background_image"] ?? "";
                                                                                        brandController.brandName.value = brand["name"];
                                                                                        brandController.showAllBrand.value = true;
                                                                                        brandController.brandId.value = brand["id"];

                                                                                        await brandController.getBrandDetails(brand["id"], "");

                                                                                        await Get.to(() => AllBrandScreen(
                                                                                              id: brand["id"],
                                                                                              slug: "",
                                                                                              screen: widget.screen ?? "",
                                                                                            ));

                                                                                        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                                                                                          statusBarColor: whiteColor,
                                                                                          systemNavigationBarColor: whiteColor,
                                                                                          statusBarIconBrightness: Brightness.dark,
                                                                                          statusBarBrightness: Brightness.light,
                                                                                        ));

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
                                                                                                      "productThumbnailsCache",
                                                                                                      stalePeriod: const Duration(days: 15),
                                                                                                      maxNrOfCacheObjects: 150,
                                                                                                    ),
                                                                                                  ),
                                                                                                  fit: BoxFit.cover,
                                                                                                  imageUrl: imageUrl,
                                                                                                  placeholder: (context, url) => Container(
                                                                                                    height: 97.sp,
                                                                                                    width: 97.sp,
                                                                                                    color: Colors.grey[200],
                                                                                                    child: const Center(
                                                                                                      child: CircularProgressIndicator(strokeWidth: 2),
                                                                                                    ),
                                                                                                  ),
                                                                                                  errorWidget: (context, url, error) {
                                                                                                    print("❌ [BrandsScreen] Product image load failed");
                                                                                                    print("   URL: $url");
                                                                                                    print("   Error: $error");
                                                                                                    return Container(
                                                                                                      height: 97.sp,
                                                                                                      width: 97.sp,
                                                                                                      color: Colors.grey[200],
                                                                                                      child: const Icon(Icons.image_not_supported, size: 35, color: Colors.grey),
                                                                                                    );
                                                                                                  },
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
                                                                              onTap: () async {
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
                                                                              child: Padding(
                                                                                padding: EdgeInsets.only(top: 4.sp, bottom: 4.sp),
                                                                                child: Container(
                                                                                  height: 42.sp,
                                                                                  color: homeAppBarColor,
                                                                                  width: double.infinity,
                                                                                  child: Center(
                                                                                    child: AppText(
                                                                                      text: "EXPLORE BRAND",
                                                                                      fontFamily: "Clash Display",
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
                                                                              fontSize: 14.sp,
                                                                              fontFamily: "Clash Display Regular",
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
                                                          color:
                                                              homeAppBarColor,
                                                          fontFamily:
                                                              "Clash Display"))
                                                  : Text(
                                                      "Coming Soon to Your Area",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              homeAppBarColor,
                                                          fontFamily:
                                                              "Clash Display"))),
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
                ),
              ],
            ),
          ),
        ));
  }
}
