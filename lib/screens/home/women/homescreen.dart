// ignore_for_file: avoid_print, deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lafetch/common/widget/lists/dummy_product_list.dart';
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/Brands/categoryproduct.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/home/women/productviewscreen.dart';

import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:marquee/marquee.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_indicator_plus/page_indicator_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/widget/appbar/home_appbar.dart';
import '../../../common/widget/lists/dummy_grid_mostsearch.dart';
import '../../../common/widget/lists/dummy_home_brand.dart';
import '../../../common/widget/other/common_widget.dart';
import '../../../common/widget/text/app_text.dart';
import '../../../controllers/brand_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/catalog_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/search_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constant/constants.dart';
import '../../../core/utils/analytics_helper.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onPressed;

  const HomeScreen({this.onPressed, super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final homeController = Get.put(HomeController());
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final searchController = Get.put(SearchScreenController());
  final cartController = Get.put(CartController());
  final brandController = Get.put(BrandController());
  final catalogController = Get.put(CatalogController());
  final profileController = Get.put(ProfileController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final PageController _pageController = PageController(initialPage: 0);
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // Auto-scroll banners
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final pageCount = _currentBannerList().length;
      if (pageCount > 0) {
        final nextPage = (homeController.currentPage.value + 1) % pageCount;
        homeController.currentPage.value = nextPage;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeIn,
            );
          }
        });
      }
    });

    // Apply UI styles and fetch data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: whiteColor,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: whiteColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));

      homeController.showGenderList.value = false;
      homeController.currentPage.value = 0;
      productController.current.value = 50;
      productController.tagId.value = 0;
      productController.tagname.value = "";
      productController.productCategory = [];
      productController.productTags = [];
      productController.categoryFilter.value =
          homeController.homeGenderValue.value;

      await checkUserConnection();
      homeController.getBannerData(1);
      homeController.getBannerData(2);
      homeController.getBannerData(3);
      catalogController
          .getCatagoryData(catalogController.selectCategoryGender.value);

      // ✅ Fix hot reload visibility issue
      if (catalogController.catalogList.isNotEmpty) {
        catalogController.update();
      }

      homeController.getBrandData(
          "featured", homeController.homeGenderValue.value);
      productController.getHomeProduct(homeController.homeGenderValue.value);
      catalogController.getCatalogData(homeController.homeGenderValue.value);
      homeController.getDeviceName();
      initPlatformState();
      profileController.safeInitProfile(redirectIfMissing: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (brandController.brandList.isEmpty && !brandController.isBrand.value) {
      brandController.getBrandData("featured");
    }
  }

  // ---- helpers ----

  List<dynamic> _currentBannerList() {
    switch (homeController.homeGenderValue.value) {
      case 1:
        return homeController.banner1List;
      case 2:
        return homeController.banner2List;
      case 3:
        return homeController.banner3List;
      default:
        return homeController.banner1List;
    }
  }

  // Filter helper if you ever need it (kept from your codebase)

  static Future<bool> checkUserConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      getSnackBar("Please turn on internet");
      return false;
    }
  }

  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble('latitude') != null) {
      productController.lat.value = prefs.getDouble('latitude')!;
      productController.lng.value = prefs.getDouble('longitude')!;
      cartController.lat.value = prefs.getDouble('latitude')!;
      cartController.lng.value = prefs.getDouble('longitude')!;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ------- BANNERS -------

  List<Widget> widgitBannerList() {
    final currentBannerList = _currentBannerList();
    final List<Widget> list = [];

    for (var i = 0; i < currentBannerList.length; i++) {
      final item = (currentBannerList[i] as Map?) ?? const {};
      final int bannerId = () {
        final v = item["id"];
        if (v is int) return v;
        return int.tryParse(v?.toString() ?? '') ?? 0;
      }();
      final String imageUrl = item["image"]?.toString() ?? '';
      final String title =
          item["title"]?.toString() ?? item["name"]?.toString() ?? "Products";

      final int categoryIdFromList = () {
        final v = item["categoryId"];
        if (v is int) return v;
        return int.tryParse(v?.toString() ?? '') ?? 0;
      }();
      final int brandIdFromList = () {
        final v = item["brandId"];
        if (v is int) return v;
        return int.tryParse(v?.toString() ?? '') ?? 0;
      }();

      list.add(
        GestureDetector(
          onTap: () async {
            try {
              // Fetch detail (contains products, category, brand)
              final data = await homeController.getBannerDetail(bannerId);
              final List<Map<String, dynamic>> products =
                  (data?['products'] as List?)
                          ?.whereType<Map<String, dynamic>>()
                          .toList() ??
                      const [];

              // Pull ids from detail if available, fallback to list values
              final int categoryId = () {
                final v = data?["categoryId"] ?? data?["category"]?["id"];
                if (v is int) return v;
                return int.tryParse(v?.toString() ?? '') ?? categoryIdFromList;
              }();

              final int brandId = () {
                final v = data?["brandId"] ?? data?["brand"]?["id"];
                if (v is int) return v;
                return int.tryParse(v?.toString() ?? '') ?? brandIdFromList;
              }();

              // If the detail call returned products, show them directly.
              if (products.isNotEmpty) {
                Get.to(
                  () => BannerProductsScreen(
                    title: title,
                    products: products,
                    genderName: homeController.genderText.value,
                  ),
                )?.then((_) {
                  SystemChrome.setSystemUIOverlayStyle(
                      const SystemUiOverlayStyle(
                    statusBarColor: whiteColor,
                    systemNavigationBarColor: whiteColor,
                  ));
                });
              } else {
                // Fallback: open category route (old behavior)
                Get.to(
                  () => CategoryProductScreen(
                    categoryName: title,
                    categoryId: categoryId,
                    genderName: homeController.genderText.value,
                    brandId: brandId,
                    genderType: homeController.homeGenderValue.value,
                    tagIds: const [],
                    categoryList: categoryId != 0 ? [categoryId] : const [],
                    title: '',
                  ),
                )?.then((_) {
                  SystemChrome.setSystemUIOverlayStyle(
                      const SystemUiOverlayStyle(
                    statusBarColor: whiteColor,
                    systemNavigationBarColor: whiteColor,
                  ));
                });
              }

              // Analytics
              await analytics.logEvent(
                name: 'banner_home_page',
                parameters: {
                  'banner_id': bannerId,
                  'banner_title': title,
                  'category_id': categoryId,
                  'brand_id': brandId,
                  'products_count': products.length,
                },
              );
            } catch (e) {
              print("Banner tap error: $e");
              getSnackBar("Unable to open banner right now");
            }
          },
          child: CachedNetworkImage(
            cacheManager: CacheManager(
              Config(
                "customCacheKey",
                stalePeriod: const Duration(days: 15),
                maxNrOfCacheObjects: 100,
              ),
            ),
            fit: BoxFit.fill,
            imageUrl: imageUrl,
            height: 229.sp,
            width: MediaQuery.of(context).size.width,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Center(
              child: Container(
                height: 229.sp,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.04),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Image.asset(
              downloadImage,
              height: 229.sp,
            ),
          ),
        ),
      );
    }

    return list;
  }

  // ------- GEO & PUSH -------

  determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Location not enable");
      getPrefrenceValue();
    } else {
      setState(() {});
      Position position = await Geolocator.getCurrentPosition();
      productController.lat.value = position.latitude;
      productController.lng.value = position.longitude;
      final prefs = await SharedPreferences.getInstance();
      prefs.setDouble("latitude", productController.lat.value);
      prefs.setDouble("longitude", productController.lng.value);
      print("Location enable ${position.latitude}");
    }
  }

  Future<void> initPlatformState() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("ee370d7a-1d35-45bb-8f86-09e43c87c15a");
    OneSignal.Notifications.clearAll();
    OneSignal.User.pushSubscription.addObserver((state) {
      print(OneSignal.User.pushSubscription.optedIn);
      print("player id${OneSignal.User.pushSubscription.id}");
      print("token${OneSignal.User.pushSubscription.token}");
      homeController.playerId.value =
          OneSignal.User.pushSubscription.id.toString();
    });

    OneSignal.Notifications.addPermissionObserver((state) {
      print("Has permission $state");
    });

    OneSignal.Notifications.addClickListener((event) {
      print('NOTIFICATION CLICK LISTENER CALLED WITH EVENT: $event');
      setState(() {});
    });
    OneSignal.Notifications.requestPermission(true);
  }

  // ------- UI -------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          HomeAppbar(
            onPressedSearch: () async {
              final searchQuery = searchController.searchController.text;
              AnalyticsHelper.logSearch(
                searchQuery: searchQuery,
                contentType: 'product',
                value: 0.0,
                productId: productController.id.toString(),
              );
              await analytics.logEvent(
                name: 'search_page',
                parameters: {'search_string': searchQuery},
              );
              Get.to(const SearchScreen())?.then((value) {
                setState(() {
                  productController.categoryFilter.value =
                      homeController.homeGenderValue.value;
                  SystemChrome.setSystemUIOverlayStyle(
                      const SystemUiOverlayStyle(
                    statusBarColor: whiteColor,
                    systemNavigationBarColor: whiteColor,
                  ));
                });
              });
            },
            onPressedHeart: () async {
              facebookAppEvents.logEvent(
                name: 'fb_view_wishlist_page',
                parameters: {'page_name': 'wishlist_page'},
              );
              await analytics.logEvent(
                name: 'wishlist_page',
                parameters: {'page_name': 'wishlist_page'},
              );
              Get.to(const WishlistScreen())?.then((_) {
                SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                  statusBarColor: whiteColor,
                  systemNavigationBarColor: whiteColor,
                ));
              });
            },
            onPressedCart: () async {
              facebookAppEvents.logEvent(
                name: 'fb_view_cart_page',
                parameters: {'page_name': 'cart_page'},
              );
              await analytics.logEvent(
                name: 'cart_page',
                parameters: {'page_name': 'cart_page'},
              );
              Get.to(const CartScreen())?.then((_) {
                SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                  statusBarColor: whiteColor,
                  systemNavigationBarColor: whiteColor,
                ));
              });
            },
            onPressedDropDown: () {
              homeController.showGenderList.value =
                  !homeController.showGenderList.value;
              setState(() {});
            },
          ),

          // Gender tabs...
          Obx(
            () => SizedBox(
              height: 40.sp,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _genderTab("MEN", 1, onTap: () async {
                    homeController.genderText.value = "Men";
                    homeController.homeGenderValue.value = 1;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('selectedGender', 1);
                    _resetForTab();
                    homeController.getBannerData(1);
                    catalogController.getCatalogData(1);
                    // 🔁 Optional refresh (not strictly needed if featured is global)
                    homeController.getBrandData(
                        "featured", homeController.homeGenderValue.value);
                    productController.getHomeProduct(1);
                    catalogController.selectCategoryGender.value = 1;
                    catalogController.categoryName.value = "Men";
                    catalogController.getCatagoryData(1);
                    await analytics.logEvent(
                      name: 'home_page_menClick',
                      parameters: {'page_name': 'home_page_menClick'},
                    );
                  }),
                  _genderTab("WOMEN", 2, onTap: () async {
                    homeController.genderText.value = "Women";
                    homeController.homeGenderValue.value = 2;
                    _resetForTab();
                    homeController.getBannerData(2);
                    catalogController.getCatalogData(2);
                    // 🔁 Optional refresh
                    homeController.getBrandData(
                        "featured", homeController.homeGenderValue.value);
                    productController.getHomeProduct(2);
                    catalogController.selectCategoryGender.value = 2;
                    catalogController.categoryName.value = "Women";
                    catalogController.getCatagoryData(2);
                    await analytics.logEvent(
                      name: 'home_page_womenClick',
                      parameters: {'page_name': 'home_page_womenClick'},
                    );
                  }),
                  _genderTab("ACCESSORIES", 3, onTap: () async {
                    homeController.genderText.value = "Accessories";
                    homeController.homeGenderValue.value = 3;
                    _resetForTab();
                    homeController.getBannerData(3);
                    catalogController.getCatalogData(3);
                    // 🔁 Optional refresh
                    homeController.getBrandData(
                        "featured", homeController.homeGenderValue.value);
                    productController.getHomeProduct(3);
                    catalogController.selectCategoryGender.value = 3;
                    catalogController.categoryName.value = "Accessories";
                    catalogController.getCatagoryData(3);
                    await analytics.logEvent(
                      name: 'home_page_accessoriesClick',
                      parameters: {'page_name': 'home_page_accessoriesClick'},
                    );
                  }),
                ],
              ),
            ),
          ),

          Container(
              width: double.infinity, color: lightgreyColor, height: 2.sp),
          SizedBox(height: 16.sp),

          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: homeController.discountScreenController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => homeController.isBanner1.value
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp, bottom: 12.sp, right: 16.sp),
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
                                  },
                                ),
                              ),
                            )
                          : _currentBannerList().isNotEmpty &&
                                  productController.current.value == 50
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 16.sp,
                                          bottom: 12.sp,
                                          right: 16.sp),
                                      child: SizedBox(
                                        height: 210.sp,
                                        child: PageView(
                                          controller: _pageController,
                                          onPageChanged: (index) {
                                            homeController.currentPage.value =
                                                index;
                                            homeController.update();
                                          },
                                          children: widgitBannerList(),
                                        ),
                                      ),
                                    ),
                                    _currentBannerList().length == 1
                                        ? const SizedBox(height: 0)
                                        : Padding(
                                            padding: EdgeInsets.only(
                                                left: 10.sp, right: 10.sp),
                                            child: Center(
                                              child: PageIndicator(
                                                controller: _pageController,
                                                count:
                                                    _currentBannerList().length,
                                                size: 6.0.sp,
                                                activeColor: Colors.black,
                                                color: const Color(0xffE5E7EB),
                                                layout:
                                                    PageIndicatorLayout.WARM,
                                                scale: 0.65,
                                                space: 8.sp,
                                              ),
                                            ),
                                          ),
                                  ],
                                )
                              : const SizedBox(height: 0)),
                      Padding(
                        padding: EdgeInsets.only(top: 16.sp),
                        child: Container(
                          height: 30.sp,
                          color: const Color(0xff7A6ECC),
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: Platform.isIOS ? 7.sp : 6.sp,
                              bottom: Platform.isIOS ? 5.sp : 6.sp,
                            ),
                            child: Center(
                              child: Marquee(
                                text:
                                    '✦  More than 50+ Homegrown Brands  ✦  Fast and Reliable  ✦  Fashion for all occassions',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                velocity: 100.0,
                                pauseAfterRound: Duration.zero,
                                accelerationCurve: Curves.linear,
                                decelerationCurve: Curves.easeOut,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Obx(
                        () => catalogController.isCatalog.value
                            ? const DummyGridMostSearch(text: "")
                            : catalogController.catalogList.isNotEmpty
                                ? _ShopByCategorySection(
                                    catalogController: catalogController,
                                    analytics: analytics,
                                    homeController: homeController,
                                    // pass the callback from HomeScreen to this section
                                    onPressedViewAll: () =>
                                        widget.onPressed?.call(2),
                                  )
                                : SizedBox(height: 0.sp),
                      ),
                      Obx(() {
                        if (homeController.isBrand.value) {
                          return const DummyHomeBrand();
                        }
                        if (homeController.brandList.isEmpty) {
                          // Graceful empty state if backend has no featured brands yet
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text("No featured brands yet"),
                            ),
                          );
                        }
                        return _FeaturedBrandsRow(
                          homeController: homeController,
                          brandController: brandController,
                          analytics: analytics,
                          onPressedViewAll: () => widget.onPressed?.call(1),
                        );
                      }),
                      Obx(() {
                        if (productController.isHomeProduct.value) {
                          return Padding(
                            padding: EdgeInsets.only(top: 24.sp),
                            child: DummyProductList(
                              visibleSubtitle: true,
                              text: (productController.tagname.value)
                                  .toUpperCase(),
                            ),
                          );
                        }

                        final List<Map<String, dynamic>> collections =
                            productController.homeProductList
                                .whereType<Map<String, dynamic>>()
                                .where((c) =>
                                    (c['name']?.toString().trim().isNotEmpty ??
                                        false))
                                .toList();

                        if (collections.isEmpty) {
                          return SizedBox(height: 20.sp);
                        }

                        final int selectedSuperCat =
                            homeController.homeGenderValue.value; // 1/2/3

                        return ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: collections.length,
                          separatorBuilder: (_, __) => SizedBox(height: 16.sp),
                          itemBuilder: (context, index) {
                            final c = collections[index];
                            final int collectionId = c['id'] is int
                                ? c['id'] as int
                                : int.tryParse(c['id']?.toString() ?? '') ?? 0;
                            final String title = c['name']?.toString() ?? '';
                            final String subtitle = c['desc']?.toString() ?? '';

                            final List rawProducts = (c['products'] is List)
                                ? List.from(c['products'] as List)
                                : const [];

                            final List<Map<String, dynamic>> filteredProducts =
                                rawProducts
                                    .whereType<Map<String, dynamic>>()
                                    .where((p) {
                              final v = p['superCatId'];
                              final scId = v is int
                                  ? v
                                  : int.tryParse(v?.toString() ?? '') ?? 0;
                              return scId == selectedSuperCat;
                            }).toList();

                            final bool dark = index.isEven;

                            return Container(
                              color: dark ? Colors.black : Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: 18.sp,
                                        left: 16.sp,
                                        right: 16.sp,
                                        bottom: 10.sp,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            title.toUpperCase(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily:
                                                  "Franklin Gothic Semibold",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18.sp,
                                              color: dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                          if (subtitle.isNotEmpty)
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 6.sp),
                                              child: Text(
                                                subtitle,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12.sp,
                                                  color: dark
                                                      ? Colors.white
                                                          .withOpacity(0.85)
                                                      : Colors.black
                                                          .withOpacity(0.75),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (filteredProducts.isNotEmpty)
                                    _SectionStrip(
                                      products: filteredProducts,
                                      dark: dark,
                                      onProductTap: (productId) async {
                                        Get.to(
                                          ProductDetailsScreen(
                                            productId: productId,
                                            type: "add",
                                            brandName: "",
                                          ),
                                        )?.then((_) {
                                          setState(() {
                                            SystemChrome
                                                .setSystemUIOverlayStyle(
                                              const SystemUiOverlayStyle(
                                                statusBarColor: whiteColor,
                                                systemNavigationBarColor:
                                                    whiteColor,
                                              ),
                                            );
                                          });
                                        });

                                        await analytics.logEvent(
                                          name: 'product_details_home_page',
                                          parameters: <String, Object>{
                                            'page_name':
                                                'product_details_home_page',
                                            'collection_id': collectionId,
                                            'collection_name': title,
                                            'product_id': productId.toString(),
                                          },
                                        );
                                      },
                                      onExploreAll: () async {
                                        productController.tagId.value =
                                            collectionId;
                                        productController.productSortBy.value =
                                            "";
                                        productController
                                            .filterProductEnable.value = false;
                                        productController.categoryFilter.value =
                                            homeController
                                                .homeGenderValue.value;

                                        Get.to(
                                          ProductViewScreen(
                                            title: title,
                                            genderName:
                                                homeController.genderText.value,
                                          ),
                                        )?.then((_) {
                                          SystemChrome.setSystemUIOverlayStyle(
                                            const SystemUiOverlayStyle(
                                              statusBarColor: whiteColor,
                                              systemNavigationBarColor:
                                                  whiteColor,
                                            ),
                                          );
                                        });

                                        await analytics.logEvent(
                                          name: 'homepage_productExploreAll',
                                          parameters: <String, Object>{
                                            'page_name':
                                                'homepage_productExploreAll',
                                            'collection_id': collectionId,
                                            'collection_name': title,
                                          },
                                        );
                                      },
                                      seed: (productController
                                                  .productsShuffleSeed ??
                                              DateTime.now()
                                                  .millisecondsSinceEpoch) +
                                          collectionId,
                                    )
                                  else
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.sp, vertical: 8.sp),
                                      child: Text(
                                        "No products yet",
                                        style: TextStyle(
                                          color: dark
                                              ? Colors.white.withOpacity(0.85)
                                              : Colors.black.withOpacity(0.75),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      })
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderTab(String label, int value, {required VoidCallback onTap}) {
    final isSelected = homeController.homeGenderValue.value == value;
    return InkWell(
      onTap: onTap,
      child: _buildGenderTab(label: label, isSelected: isSelected),
    );
  }

  void _resetForTab() {
    productController.selectedTabCategory.value = 0;
    homeController.currentPage.value = 0;
    productController.current.value = 50;
    productController.tagId.value = 0;
    productController.productCategory = [];
    productController.productTags = [];
  }

  Widget _buildGenderTab({required String label, required bool isSelected}) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            text: label,
            color: isSelected ? homeAppBarColor : searchTextColor,
            fontSize: 13,
            fontFamily:
                isSelected ? "Franklin Gothic Semibold" : "Franklin Gothic",
            fontWeight: FontWeight.w500,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.sp),
            child: Container(
              color: isSelected ? homeAppBarColor : Colors.transparent,
              width: 110.sp,
              height: 2.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- helper sections reused from your file ----------
String? firstImageUrlFromProduct(Map<String, dynamic> m) {
  // Try an array like imageUrls: ["..."]
  final imgs = m['imageUrls'];
  if (imgs is List) {
    for (final e in imgs) {
      final s = e?.toString().trim();
      if (s != null && s.isNotEmpty) return s;
    }
  }
  // Try common single-image fields
  for (final k in const [
    'image',
    'thumbnail',
    'thumb',
    'cover',
    'defaultImage',
    'primaryImage',
    'img',
    'photo'
  ]) {
    final v = m[k];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return null;
}

class _SectionStrip extends StatelessWidget {
  final List<Map<String, dynamic>> products; // typed
  final bool dark;
  final void Function(int productId) onProductTap;
  final VoidCallback onExploreAll;
  final int seed;

  const _SectionStrip({
    required this.products,
    required this.dark,
    required this.onProductTap,
    required this.onExploreAll,
    required this.seed,
  });

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(products);
    items.shuffle(Random(seed));

    // show up to 4 items + 1 explore tile
    final pick = items.take(4).toList();
    final itemCount = pick.length + 1;

    // Choose a thumbnail for Explore tile:
    // Prefer the next (5th) shuffled item; fallback to first available.
    Map<String, dynamic>? exploreCandidate;
    if (items.length > pick.length) {
      exploreCandidate = items[pick.length];
    } else if (items.isNotEmpty) {
      exploreCandidate = items.first;
    }
    final String? exploreImageUrl = exploreCandidate != null
        ? firstImageUrlFromProduct(exploreCandidate)
        : null;

    return SizedBox(
      height: 260.sp,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: 16.sp),
        itemBuilder: (context, index) {
          if (index == pick.length) {
            // Explore tile with a real thumbnail 👇
            return _ExploreTile(
              dark: dark,
              onTap: onExploreAll,
              imageUrl: exploreImageUrl,
            );
          }

          final p = pick[index];
          final int id = p['id'] is int
              ? p['id'] as int
              : int.tryParse(p['id']?.toString() ?? '') ?? 0;

          final String title = p['title']?.toString() ?? '';

          String imageUrl = '';
          if (p['imageUrls'] is List && (p['imageUrls'] as List).isNotEmpty) {
            imageUrl = ((p['imageUrls'] as List).first).toString();
          }
          final String subtitle =
              (p['shortDescription']?.toString().trim().isNotEmpty ?? false)
                  ? p['shortDescription'].toString()
                  : p['type']?.toString() ?? '';

          return GestureDetector(
            onTap: () => onProductTap(id),
            child: SizedBox(
              width: 150.sp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.sp),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            height: 200.sp,
                            width: 170.sp,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              height: 180.sp,
                              width: 170.sp,
                              color: Colors.black.withOpacity(0.06),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              height: 180.sp,
                              width: 170.sp,
                              color: Colors.black.withOpacity(0.06),
                              child: const Icon(Icons.image_not_supported),
                            ),
                          )
                        : Container(
                            height: 180.sp,
                            width: 170.sp,
                            color: Colors.black.withOpacity(0.06),
                            child: const Icon(Icons.image_not_supported),
                          ),
                  ),
                  SizedBox(height: 8.sp),
                  Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "Franklin Gothic Semibold",
                      fontSize: 13.sp,
                      color: dark ? Colors.white : Colors.black,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "Franklin Gothic",
                        fontSize: 12.sp,
                        color: dark
                            ? Colors.white.withOpacity(0.85)
                            : Colors.black.withOpacity(0.85),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  final bool dark;
  final VoidCallback onTap;
  final String? imageUrl;

  const _ExploreTile({
    required this.dark,
    required this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        dark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 160.sp,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4.sp),
              child: (imageUrl != null && imageUrl!.trim().isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      height: 210.sp,
                      width: 170.sp,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 210.sp,
                        width: 170.sp,
                        color: bg,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 210.sp,
                        width: 170.sp,
                        color: bg,
                      ),
                    )
                  : Container(
                      height: 200.sp,
                      width: 170.sp,
                      color: bg,
                    ),
            ),
            // dark overlay for text legibility
            Container(
              height: 210.sp,
              width: 170.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.sp),
                color: Colors.black.withOpacity(0.25),
              ),
            ),
            Center(
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20.sp),
                ),
                child: const Text(
                  "EXPLORE ALL",
                  style: TextStyle(
                    fontFamily: "Franklin Gothic Semibold",
                    fontSize: 12,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- New: Screen to display products returned by /banner/:id ----------

class BannerProductsScreen extends StatelessWidget {
  final String title;
  final String genderName;
  final List<Map<String, dynamic>> products;

  const BannerProductsScreen({
    super.key,
    required this.title,
    required this.products,
    required this.genderName,
  });

  String? _imageFrom(Map<String, dynamic> m) {
    final list = (m['imageUrls'] as List?)
            ?.whereType()
            .map((e) => e.toString())
            .where((s) => s.trim().isNotEmpty)
            .toList() ??
        const <String>[];
    if (list.isNotEmpty) return list.first;
    for (final k in const [
      'image',
      'thumbnail',
      'thumb',
      'cover',
      'defaultImage',
      'primaryImage',
      'img',
      'photo'
    ]) {
      final v = m[k];
      if (v is String && v.trim().isNotEmpty) return v;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontFamily: "Franklin Gothic Semibold",
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: products.isEmpty
          ? const Center(child: Text("No products found"))
          : GridView.builder(
              padding: EdgeInsets.fromLTRB(16.sp, 8.sp, 16.sp, 20.sp),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.56,
                crossAxisSpacing: 16.sp,
                mainAxisSpacing: 18.sp,
              ),
              itemBuilder: (context, index) {
                final m = products[index];

                final String brand =
                    (m['brand_name'] ?? m['brandName'] ?? '').toString().trim();
                final String title =
                    (m['title'] ?? m['name'] ?? '').toString().trim();
                final String shortDesc = (m['shortDescription'] ??
                        m['short_description'] ??
                        m['shortDesc'] ??
                        '')
                    .toString()
                    .trim();

                num? price;
                final rawPrice = m['basePrice'] ??
                    m['base_price'] ??
                    m['baseprice'] ??
                    m['price'];
                if (rawPrice is num) {
                  price = rawPrice;
                } else if (rawPrice is String) {
                  price = num.tryParse(rawPrice);
                }

                num? mrp;
                final rawMrp = m['mrp'];
                if (rawMrp is num) {
                  mrp = rawMrp;
                } else if (rawMrp is String) {
                  mrp = num.tryParse(rawMrp);
                }

                final img = _imageFrom(m);
                final int pid = () {
                  final v = m['id'];
                  if (v is int) return v;
                  return int.tryParse(v?.toString() ?? '') ?? 0;
                }();

                return GestureDetector(
                  onTap: () {
                    if (pid == 0) return;
                    Get.to(
                      ProductDetailsScreen(
                        brandName: brand.isEmpty ? title : brand,
                        expressValue: 0,
                        backgroundcolor: whiteColor,
                        productId: pid,
                        type: "add",
                      ),
                    );
                  },
                  child: _BannerProductTile(
                    imageUrl: img,
                    brand: brand.isEmpty ? title : brand,
                    description: shortDesc.isEmpty ? title : shortDesc,
                    mrp: mrp,
                    price: price,
                  ),
                );
              },
            ),
    );
  }
}

class _BannerProductTile extends StatelessWidget {
  final String? imageUrl;
  final String brand;
  final String description;
  final num? mrp;
  final num? price;

  const _BannerProductTile({
    required this.imageUrl,
    required this.brand,
    required this.description,
    required this.mrp,
    required this.price,
  });

  String _fmtINR(num? v, {bool cents = true}) {
    if (v == null) return '';
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: cents ? 2 : 0,
    ).format(v);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null && imageUrl!.trim().isNotEmpty
                ? CachedNetworkImage(
                    cacheManager: CacheManager(
                      Config("bannerProductsCache",
                          stalePeriod: const Duration(days: 15),
                          maxNrOfCacheObjects: 100),
                    ),
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Image.asset(downloadImage, fit: BoxFit.cover),
                  )
                : Image.asset(dummyWishlistImage, fit: BoxFit.cover),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(6.sp, 8.sp, 6.sp, 0),
          child: Text(
            brand.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: blackColor,
              fontSize: 15,
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(6.sp, 4.sp, 6.sp, 0),
          child: Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(6.sp, 6.sp, 6.sp, 0),
          child: Row(
            children: [
              if (mrp != null && mrp! > 0)
                Padding(
                  padding: EdgeInsets.only(right: 6.sp),
                  child: Text(
                    _fmtINR(mrp, cents: true),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              Text(
                (price == null || price == 0)
                    ? ""
                    : _fmtINR(price, cents: true),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: blackColor,
                  fontSize: 15,
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------- Small section widgets ----------

class _ShopByCategorySection extends StatelessWidget {
  final CatalogController catalogController;
  final FirebaseAnalytics analytics;
  final HomeController homeController;

  /// Injected callback coming from HomeScreen
  final VoidCallback onPressedViewAll;

  const _ShopByCategorySection({
    required this.catalogController,
    required this.analytics,
    required this.homeController,
    required this.onPressedViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: statusBarColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 24.sp),
            child: Center(
              child: AppText(
                text: "SHOP BY CATEGORY",
                fontFamily: "Franklin Gothic Semibold",
                fontWeight: FontWeight.w400,
                color: blackColor,
                fontSize: 20,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.sp, top: 16.sp, right: 16.sp),
            child: Center(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.zero,
                childAspectRatio: 0.55,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12.sp,
                mainAxisSpacing: 0.sp,
                children: List.generate(
                  // ✅ show only top 6
                  min(6, catalogController.catalogList.length),
                  (index) {
                    final catalog = catalogController.catalogList[index];
                    return GestureDetector(
                      onTap: () async {
                        final categoryId = catalog["id"];
                        final catalogName = catalog["name"] ?? "Category";

                        // (Optional) prefetch, if you still want to warm the cache/UI:
                        await catalogController.getCategoryProductData(
                          categoryId,
                          homeController.homeGenderValue.value,
                        );

                        Get.to(
                          () => CategoryProductScreen(
                            categoryName: catalogName,
                            screen: "category",
                            genderName: homeController.genderText.value,
                            categoryId:
                                categoryId, // ✅ just pass the picked category id
                            brandId: 0,
                            genderType: homeController.homeGenderValue.value,
                            categoryList: const [], // ✅ no longer needed
                            tagIds: const [],
                            title: '',
                          ),
                        )?.then((_) {
                          SystemChrome.setSystemUIOverlayStyle(
                              const SystemUiOverlayStyle(
                            statusBarColor: whiteColor,
                            systemNavigationBarColor: whiteColor,
                          ));
                        });

                        await analytics.logEvent(
                          name: 'categories_home_page',
                          parameters: {'page_name': 'categories_home_page'},
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          (catalog["image"] != null &&
                                  catalog["image"].toString().isNotEmpty)
                              ? SizedBox(
                                  width: 104.sp,
                                  height: 130.sp,
                                  child: CachedNetworkImage(
                                    cacheManager: CacheManager(
                                      Config(
                                        "customCacheKey",
                                        stalePeriod: const Duration(days: 15),
                                        maxNrOfCacheObjects: 100,
                                      ),
                                    ),
                                    fit: BoxFit.cover,
                                    imageUrl: catalog["image"],
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      downloadImage,
                                      fit: BoxFit.cover,
                                      width: 104.sp,
                                      height: 130.sp,
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  dummyWishlistImage,
                                  width: 104.sp,
                                  height: 130.sp,
                                  fit: BoxFit.cover,
                                ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.sp),
                            child: AppText(
                              text: (catalog["name"] ?? "")
                                  .toString()
                                  .toUpperCase(),
                              color: blackColor,
                              fontSize: 13,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              fontFamily: "Franklin Gothic",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              // keep the current tab’s gender
              final g = homeController.homeGenderValue.value;
              final gName = g == 1
                  ? "Men"
                  : g == 2
                      ? "Women"
                      : "Accessories";

              // set it on the CatalogController so Categories tab reads the right state
              catalogController.selectCategoryGender.value = g;
              catalogController.categoryName.value = gName;

              // optional: pre-load categories for that gender
              await catalogController.getCatagoryData(g);

              // also persist it, in case the Categories screen reads from prefs
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('selectedGender', g);

              // now jump to the Categories tab (index 2 in your BottomNav)
              onPressedViewAll();
              await analytics.logEvent(
                name: 'home_page_btnviewall',
                parameters: {'page_name': 'home_page_btnviewall'},
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 16.sp),
              child: Container(
                height: 42.sp,
                color: homeAppBarColor,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppText(
                      text: "VIEW ALL",
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w400,
                      color: whiteColor,
                      fontSize: 12,
                    ),
                    SizedBox(width: 8.sp),
                    SvgPicture.asset(
                      arrowSearchImage,
                      color: whiteColor,
                      height: 7.sp,
                      width: 7.sp,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24.sp),
        ],
      ),
    );
  }
}

class _FeaturedBrandsRow extends StatelessWidget {
  final HomeController homeController;
  final BrandController brandController;
  final FirebaseAnalytics analytics;
  final VoidCallback onPressedViewAll;

  const _FeaturedBrandsRow({
    required this.homeController,
    required this.brandController,
    required this.analytics,
    required this.onPressedViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 24.sp, left: 16.sp, right: 16.sp),
          child: Row(
            children: [
              const AppText(
                text: "FEATURED BRANDS",
                fontFamily: "Franklin Gothic Semibold",
                color: blackColor,
                fontSize: 18,
              ),
              const Spacer(),
              InkWell(
                onTap: () async {
                  onPressedViewAll();
                  await analytics.logEvent(
                    name: 'homepage_featurebrandviewAll',
                    parameters: {'page_name': 'homepage_featurebrandviewAll'},
                  );
                },
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 2.sp, right: 12.sp, left: 20.sp),
                  child: SvgPicture.asset(
                    arrowViewAllImage,
                    height: 11.sp,
                    width: 7.sp,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16.sp),
          child: SizedBox(
            height: 100.sp,
            child: Obx(() {
              if (brandController.isBrand.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // ✅ Get only real brand entries (ignore grouping maps)
              final brands = brandController.brandList
                  .where((b) =>
                      b is Map &&
                      b.containsKey("id") &&
                      (b["name"]?.toString().isNotEmpty ?? false))
                  .toList();

              if (brands.isEmpty) {
                return const Center(child: Text("No featured brands yet"));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: brands.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (ctx, index) {
                  final brand = brands[index];
                  final logo = (brand["logo"] ?? "").toString().trim();
                  final name = (brand["name"] ?? "").toString().trim();
                  final bgImage =
                      (brand["background_image"] ?? "").toString().trim();

                  return GestureDetector(
                    onTap: () async {
                      brandController.brandbackground.value = bgImage;
                      final id = brand["id"];
                      final safeId = (id is int)
                          ? id
                          : int.tryParse(id?.toString() ?? '0') ?? 0;

                      Get.to(
                        () => AllBrandScreen(
                          id: safeId,
                          screen: "home",
                          slug: "",
                        ),
                      )?.then((_) {
                        SystemChrome.setSystemUIOverlayStyle(
                          const SystemUiOverlayStyle(
                            statusBarColor: whiteColor,
                            statusBarIconBrightness: Brightness.dark,
                            systemNavigationBarColor: whiteColor,
                          ),
                        );
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.sp),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 64.sp,
                            width: 64.sp,
                            margin: EdgeInsets.only(
                              right: index == brands.length - 1 ? 16.sp : 0,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: dividerColor,
                                width: 1.sp,
                              ),
                            ),
                            child: ClipOval(
                              child: logo.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: logo,
                                      height: 64.sp,
                                      width: 64.sp,
                                      fit: BoxFit.cover,
                                      fadeInDuration:
                                          const Duration(milliseconds: 300),
                                      placeholder: (_, __) => Container(
                                        color: Colors.black.withOpacity(0.05),
                                      ),
                                      errorWidget: (_, __, ___) => Image.asset(
                                        downloadImage,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : Image.asset(
                                      dummyWishlistImage,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          SizedBox(height: 8.sp),
                          SizedBox(
                            width: 64.sp,
                            child: Text(
                              name.isNotEmpty ? name : 'Unnamed',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
