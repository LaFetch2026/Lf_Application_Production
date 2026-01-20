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
import 'package:lafetch/screens/Brands/categoryproduct.dart'
    hide SizedBox, Center, Column, Padding;
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/home/women/productviewscreen.dart';
import 'package:lafetch/screens/loginscreen.dart';

import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:marquee/marquee.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_indicator_plus/page_indicator_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

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
import '../../../models/collection_extensions.dart';
import '../../../models/collection_banner_model.dart';

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
  bool isGuest = false;
  static bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();

    // Auto-scroll banners (only if more than 1 banner)
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final pageCount = _currentBannerList().length;
      if (pageCount > 1) {
        // ✅ Only auto-scroll when multiple banners exist
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

      // ✅ NEW: Fetch gender tabs FIRST
      await homeController.getGenderTabs();

      // ✅ Check if user is guest
      final prefs = await SharedPreferences.getInstance();
      isGuest = prefs.getBool('skip') ?? false;

      // ✅ NEW: Load saved gender preference or use first tab from API
      final savedGender = prefs.getInt('selectedGender');
      if (savedGender != null &&
          homeController.genderTabs.any((tab) => tab['id'] == savedGender)) {
        homeController.homeGenderValue.value = savedGender;
        final tab = homeController.genderTabs.firstWhere(
          (tab) => tab['id'] == savedGender,
          orElse: () => homeController.genderTabs.first,
        );
        homeController.genderText.value = tab['name']?.toString() ?? '';
      } else if (homeController.genderTabs.isNotEmpty) {
        homeController.homeGenderValue.value =
            homeController.genderTabs.first['id'] ?? 1;
        homeController.genderText.value =
            homeController.genderTabs.first['name']?.toString() ?? 'MEN';
        await prefs.setInt(
            'selectedGender', homeController.homeGenderValue.value);
      } else {
        homeController.homeGenderValue.value = 1;
        homeController.genderText.value = 'Men';
        print("⚠️ No gender tabs from API, using default");
      }

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

      final currentGender = homeController.homeGenderValue.value;

      // ✅ CRITICAL: Clear brand list before loading to ensure fresh data
      brandController.brandList.clear();
// ✅ UPDATED: Load all data together including brands and collection banners
      await Future.wait([
        homeController.initializeHomeData(currentGender),
        catalogController.getCatalogData(currentGender),
        productController.getHomeProduct(currentGender),
        productController.getCollectionBanners(),
        brandController.getBrandData("featured", currentGender),
      ]);

      // ✅ FORCE UPDATE: Trigger reactive update after all data is loaded
      brandController.update();

      // One-time setup calls
      if (_isInitialLoad) {
        homeController.getDeviceName();
        initPlatformState(); // OneSignal push notifications
        _isInitialLoad = false;
      }

      // ✅ Fix hot reload visibility issue
      if (catalogController.catalogList.isNotEmpty) {
        catalogController.update();
      }
    });
  }

  // ✅ Method to force refresh data (call when pull-to-refresh or manual refresh)
  Future<void> forceRefreshData() async {
    print("🔄 Force refresh triggered");

    final currentGender = homeController.homeGenderValue.value;

    // ✅ UPDATED: Include brands and collection banners in refresh
    await Future.wait([
      homeController.initializeHomeData(currentGender, forceRefresh: true),
      catalogController.getCatalogData(currentGender, forceRefresh: true),
      productController.getHomeProduct(currentGender, forceRefresh: true),
      productController.getCollectionBanners(forceRefresh: true),
      brandController.getBrandData("featured", currentGender),
    ]);
  }

  // ✅ Static method to clear all cached data (call on logout)
  static void clearCache() {
    print("🗑️ Clearing HomeScreen cache on logout");
    _isInitialLoad = true;
  }

  // ---- helpers ----

  List<dynamic> _currentBannerList() {
    final currentGender = homeController.homeGenderValue.value;

    // Map gender IDs to banner lists
    List<dynamic> bannerList;
    switch (currentGender) {
      case 1:
        bannerList = homeController.banner1List;
        break;
      case 2:
        bannerList = homeController.banner2List;
        break;
      case 3:
        bannerList = homeController.banner3List;
        break;
      default:
        // Return first available banner list
        if (homeController.banner1List.isNotEmpty) {
          bannerList = homeController.banner1List;
        } else if (homeController.banner2List.isNotEmpty) {
          bannerList = homeController.banner2List;
        } else if (homeController.banner3List.isNotEmpty) {
          bannerList = homeController.banner3List;
        } else {
          bannerList = [];
        }
    }

    // ✅ Filter to return ONLY banners with mobileImage (not null/empty)
    return bannerList.where((item) {
      final mobileImage = (item as Map?)?["mobileImage"]?.toString() ?? '';
      return mobileImage.isNotEmpty;
    }).toList();
  }

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
    final currentBannerList =
        _currentBannerList(); // ✅ Already filtered in _currentBannerList()
    final List<Widget> list = [];

    for (var i = 0; i < currentBannerList.length; i++) {
      final item = (currentBannerList[i] as Map?) ?? const {};
      final int bannerId = () {
        final v = item["id"];
        if (v is int) return v;
        return int.tryParse(v?.toString() ?? '') ?? 0;
      }();

      // ✅ Use mobileImage only
      final String imageUrl = item["mobileImage"]?.toString() ?? '';

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
          child: imageUrl.isNotEmpty && isVideoUrl(imageUrl)
              ? BannerVideoPlayer(
                  videoUrl: imageUrl,
                  height: 229.sp,
                  width: MediaQuery.of(context).size.width,
                )
              : CachedNetworkImage(
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
                    fit: BoxFit.cover,
                    height: 229.sp,
                    width: MediaQuery.of(context).size.width,
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
      body: RefreshIndicator(
        // ✅ ADDED: Pull-to-refresh functionality
        onRefresh: forceRefreshData,
        child: Column(
          children: [
            HomeAppbar(
              onPressedSearch: () async {
                final searchQuery = searchController.searchController.text;
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
                final prefs = await SharedPreferences.getInstance();
                final isGuest = prefs.getBool('skip') ?? false;

                if (isGuest) {
                  getSnackBar("Please login to view your wishlist");
                  Get.offAll(() => LoginScreen(
                        initialTab: 0,
                      ));
                  return;
                }

                Get.to(const WishlistScreen())
                    ?.then((_) => cartController.getCartData());
                await analytics.logEvent(
                  name: "wishlist_page",
                  parameters: {"page_name": "wishlist_page"},
                );
              },
              onPressedCart: () async {
                final prefs = await SharedPreferences.getInstance();
                final isGuest = prefs.getBool('skip') ?? false;

                if (isGuest) {
                  getSnackBar("Please login to view your cart");
                  Get.offAll(() => LoginScreen(
                        initialTab: 0,
                      ));
                  return;
                }

                Get.to(CartScreen())?.then((_) => cartController.getCartData());
                await analytics.logEvent(
                  name: "cart_page",
                  parameters: {"page_name": "cart_page"},
                );
              },
              onPressedDropDown: () {
                homeController.showGenderList.value =
                    !homeController.showGenderList.value;
                setState(() {});
              },
            ),

// Gender tabs...
            Obx(
              () => homeController.isLoadingTabs.value
                  ? SizedBox(
                      height: 40.sp,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : homeController.genderTabs.isEmpty
                      ? const SizedBox.shrink()
                      : SizedBox(
                          height: 40.sp,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: homeController.genderTabs.length,
                            itemBuilder: (context, index) {
                              final tab = homeController.genderTabs[index];
                              final int genderId = tab['id'] is int
                                  ? tab['id'] as int
                                  : int.tryParse(tab['id']?.toString() ?? '') ??
                                      0;
                              final String genderName =
                                  tab['name']?.toString() ?? '';

                              // ✅ WRAP EACH TAB IN Obx TO MAKE IT REACTIVE
                              return Obx(
                                () => _genderTab(
                                  genderName.toUpperCase(),
                                  genderId,
                                  onTap: () async {
                                    homeController.genderText.value =
                                        genderName;
                                    homeController.homeGenderValue.value =
                                        genderId;

                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setInt(
                                        'selectedGender', genderId);

                                    _resetForTab();

                                    // ✅ Reset banner page controller to first page
                                    if (_pageController.hasClients) {
                                      _pageController.jumpToPage(0);
                                    }

                                    // ✅ Reset scroll position to top when changing tabs
                                    if (homeController
                                        .discountScreenController.hasClients) {
                                      homeController.discountScreenController
                                          .jumpTo(0);
                                    }

                                    // ✅ Load data for new gender tab
                                    await Future.wait([
                                      homeController
                                          .initializeHomeData(genderId),
                                      productController
                                          .getHomeProduct(genderId),
                                      productController.getCollectionBanners(),
                                      catalogController
                                          .getCatalogData(genderId),
                                      brandController.getBrandData(
                                          "featured", genderId),
                                    ]);

                                    // ✅ Force update to ensure banners are displayed
                                    homeController.update();
                                    catalogController.update();
                                    brandController.update();

                                    catalogController
                                        .selectCategoryGender.value = genderId;
                                    catalogController.categoryName.value =
                                        genderName;

                                    // ✅ Force fresh catalog data
                                    catalogController.catalogList.clear();
                                    await catalogController
                                        .getCatalogData(genderId);

                                    await analytics.logEvent(
                                      name:
                                          'home_page_${genderName.toLowerCase()}Click',
                                      parameters: {
                                        'page_name':
                                            'home_page_${genderName.toLowerCase()}Click',
                                        'gender_id': genderId,
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
            Container(
                width: double.infinity, color: lightgreyColor, height: 2.sp),

            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: homeController.discountScreenController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Banner Section - ✅ WITH LOADING STATE
                        Obx(() {
                          // ✅ Track gender changes to trigger rebuild when switching tabs
                          homeController.homeGenderValue.value;

                          // Force Obx to track banner lists by accessing them
                          final banners = _currentBannerList();
                          final isLoading = homeController.isBanner1.value;
                          final showBanners = banners.isNotEmpty &&
                              productController.current.value == 50;

                          if (isLoading) {
                            return Container(
                              height: 210.sp,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(4.sp),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Loading banners...',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                        fontFamily: "Clash Display Regular",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (showBanners) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: SizedBox(
                                    height: 230,
                                    width: 410,
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
                                SizedBox(height: 8.sp),
                                banners.length == 1
                                    ? const SizedBox.shrink()
                                    : Center(
                                        child: PageIndicator(
                                          controller: _pageController,
                                          count: banners.length,
                                          size: 6.0.sp,
                                          activeColor: Colors.black,
                                          color: const Color(0xffE5E7EB),
                                          layout: PageIndicatorLayout.WARM,
                                          scale: 0.65,
                                          space: 8.sp,
                                        ),
                                      ),
                              ],
                            );
                          }

                          return const SizedBox.shrink();
                        }),

                        SizedBox(height: 8.sp), // ✅ REDUCED from 16.sp

                        // Marquee Banner
                        Container(
                          height: 30.sp,
                          color: const Color(0xff2D2D2E),
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: Platform.isIOS ? 5.sp : 5.sp,
                              bottom: Platform.isIOS ? 5.sp : 5.sp,
                            ),
                            child: Center(
                              child: Marquee(
                                text:
                                    '|    More than 50+ Homegrown Brands   |    Fast and Reliable   |    Fashion for all occassions  |    Easy Returns & Exchanges   |    Secure Payments   ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontFamily: "Clash Display Regular",
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

                        SizedBox(height: 16.sp), // ✅ REDUCED from 24.sp

                        // Shop by Category Section
                        Obx(
                          () => catalogController.isCatalog.value
                              ? const DummyGridMostSearch(text: "")
                              : catalogController.catalogList.isNotEmpty
                                  ? _ShopByCategorySection(
                                      catalogController: catalogController,
                                      analytics: analytics,
                                      homeController: homeController,
                                      onPressedViewAll: () =>
                                          widget.onPressed?.call(2),
                                    )
                                  : const SizedBox.shrink(),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            top: 8.sp,
                          ),
                          child: Obx(() {
                            // ✅ Watch brandController instead of homeController
                            if (brandController.isBrand.value) {
                              return const DummyHomeBrand();
                            }

                            // ✅ Get brands from brandController
                            final brands = brandController.brandList
                                .where((b) =>
                                    b.containsKey("id") &&
                                    (b["name"]?.toString().isNotEmpty ?? false))
                                .toList();

                            // ✅ If no brands, don't show anything (no empty space)
                            if (brands.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            // ✅ Show brands section
                            return _FeaturedBrandsRow(
                              homeController: homeController,
                              brandController: brandController,
                              analytics: analytics,
                              onPressedViewAll: () => widget.onPressed?.call(1),
                              brands: brands,
                            );
                          }),
                        ),

                        // Product Collections
                        Obx(() {
                          if (productController.isHomeProduct.value) {
                            return DummyProductList(
                              visibleSubtitle: true,
                              text: (productController.tagname.value)
                                  .toUpperCase(),
                            );
                          }

                          // ✅ Collections are already filtered by the API to only include those with products
                          // ✅ Extra safety check: Filter out any collections with empty products
                          final collections = productController.homeProductList
                              .where((c) => c.hasProducts)
                              .toList();

                          print(
                              "📊 Total collections with products: ${collections.length}");

                          if (collections.isEmpty) {
                            print(
                                "⚠️ No collections to display - showing empty space");
                            return Column(
                              children: [
                                SizedBox(height: 20.sp),
                                const Center(
                                  child: Text(
                                    "No products available for this category",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: "Clash Display Regular",
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.sp),
                              ],
                            );
                          }

                          return ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: collections.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: 16.sp),
                            itemBuilder: (context, index) {
                              final collection = collections[index];
                              final int collectionId = collection.id;
                              final String title = collection.name;
                              final String subtitle = collection.desc ?? '';

                              // ✅ Get banners for current gender from standalone banner API
                              final currentGender =
                                  homeController.genderText.value.toLowerCase();
                              final standaloneBanners =
                                  productController.getBannersForCollection(
                                collectionId,
                                currentGender,
                              );

                              // ✅ Convert products back to Map for existing widgets
                              final products = collection.products
                                  .map((p) => p.toJson())
                                  .toList();

                              // ✅ Safety check: Skip rendering if no products
                              if (products.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              final bool dark = index.isEven;

                              return Container(
                                color: dark ? Colors.black : Colors.transparent,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ✅ Left-aligned collection heading
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.sp, vertical: 12.sp),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title.toUpperCase(),
                                            textAlign: TextAlign.left,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily:
                                                  "Clash Display Semibold",
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
                                                  EdgeInsets.only(top: 4.sp),
                                              child: Text(
                                                subtitle,
                                                textAlign: TextAlign.left,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: "Clash Display",
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

                                    // ✅ NEW: Display collection banners from standalone API
                                    if (standaloneBanners.isNotEmpty)
                                      _StandaloneCollectionBanners(
                                        banners: standaloneBanners,
                                        collectionName: title,
                                      ),

                                    SizedBox(height: 6.sp),
                                    if (products.isNotEmpty)
                                      _SectionStrip(
                                        products: products,
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
                                              'product_id':
                                                  productId.toString(),
                                            },
                                          );
                                        },
                                        onExploreAll: () async {
                                          productController.tagId.value =
                                              collectionId;
                                          productController
                                              .productSortBy.value = "";
                                          productController.filterProductEnable
                                              .value = false;
                                          productController
                                                  .categoryFilter.value =
                                              homeController
                                                  .homeGenderValue.value;

                                          Get.to(
                                            ProductViewScreen(
                                              title: title,
                                              genderName: homeController
                                                  .genderText.value,
                                            ),
                                          )?.then((_) {
                                            SystemChrome
                                                .setSystemUIOverlayStyle(
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
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.sp,
                                              vertical: 10.sp),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Coming Soon",
                                                style: TextStyle(
                                                  fontFamily:
                                                      "Clash Display Semibold",
                                                  fontSize: 14.sp,
                                                  color: dark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 4.sp),
                                              Text(
                                                "Products will be added soon",
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: dark
                                                      ? Colors.white
                                                          .withOpacity(0.7)
                                                      : Colors.black
                                                          .withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: 12.sp),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderTab(String label, int value, {required VoidCallback onTap}) {
    final isSelected = homeController.homeGenderValue.value == value;
    return InkWell(
      onTap:
          onTap, // Use the passed callback which properly sets both genderText and genderValue
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
    // ✅ DON'T clear banner lists - let new data replace old data naturally
    // homeController.banner1List.clear();
    // homeController.banner2List.clear();
    // homeController.banner3List.clear();
    catalogController.catalogList.clear();
    brandController.brandList.clear();
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
            fontFamily: isSelected ? "Clash Display Semibold" : "Clash Display",
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

// ---------- helper sections ----------

// ✅ Helper to check if URL is a video
bool isVideoUrl(String url) {
  final videoExtensions = [
    '.mp4',
    '.mov',
    '.avi',
    '.mkv',
    '.flv',
    '.wmv',
    '.webm',
    '.m4v',
    '.3gp'
  ];
  final lowerUrl = url.toLowerCase();
  return videoExtensions.any((ext) => lowerUrl.contains(ext));
}

String? firstImageUrlFromProduct(Map<String, dynamic> m) {
  final imgs = m['imageUrls'];
  if (imgs is List) {
    for (final e in imgs) {
      final s = e?.toString().trim();
      if (s != null && s.isNotEmpty) return s;
    }
  }
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
  final List<Map<String, dynamic>> products;
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

  String resolveBrandName(Map<String, dynamic> p) {
    if (p['brand'] is Map && p['brand']?['name'] != null) {
      return p['brand']['name'].toString();
    }

    final brandId = p['brandId'] is int
        ? p['brandId']
        : int.tryParse(p['brandId']?.toString() ?? '') ?? 0;

    if (brandId != 0) {
      final homeController = Get.find<HomeController>();
      try {
        final brand = homeController.brandList.firstWhere(
          (b) => b["id"].toString() == brandId.toString(),
          orElse: () => null,
        );
        return brand?["name"]?.toString() ?? "";
      } catch (_) {
        return "";
      }
    }

    return "";
  }

  Map<String, dynamic> resolvePricing(Map<String, dynamic> p) {
    // Extract price with multiple fallbacks (same as product details screen)
    num price = 0;
    final rawPrice = p['displayPrice'] ??
        p['basePrice'] ??
        p['price'] ??
        p['netAmount'] ??
        p['msp'];
    if (rawPrice is num && rawPrice > 0) {
      price = rawPrice;
    } else {
      price = num.tryParse(rawPrice?.toString() ?? '0') ?? 0;
    }

    // Extract MRP with multiple fallbacks (same as product details screen)
    num? mrp;
    final rawMrp = p['displayMrp'] ?? p['mrp'] ?? p['manufacturingAmount'];
    if (rawMrp is num && rawMrp > 0) {
      mrp = rawMrp;
    } else {
      final parsed = num.tryParse(rawMrp?.toString() ?? '0');
      mrp = (parsed != null && parsed > 0) ? parsed : null;
    }

    // Calculate discount percentage if not provided
    int? discountPercent = p['discountPercent'] as int?;
    if (discountPercent == null && mrp != null && mrp > price && mrp > 0) {
      discountPercent = (((mrp - price) / mrp) * 100).round();
    }

    return {
      'price': price,
      'mrp': mrp,
      'discountPercent': discountPercent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(products)
      ..shuffle(Random(seed));

    // ✅ Show 12 products in 2 rows (6 columns) + 1 VIEW ALL button
    final pick = items.take(12).toList();

    // Split into pairs for 2-row layout
    final List<List<Map<String, dynamic>>> columnPairs = [];
    for (int i = 0; i < pick.length; i += 2) {
      if (i + 1 < pick.length) {
        columnPairs.add([pick[i], pick[i + 1]]);
      } else {
        columnPairs.add([pick[i]]);
      }
    }

    return SizedBox(
      height: 500.sp, // Height for 2 rows of products
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        itemCount: columnPairs.length + 1, // +1 for VIEW ALL button
        separatorBuilder: (_, __) => SizedBox(width: 12.sp),
        itemBuilder: (context, index) {
          // Last item is VIEW ALL button
          if (index == columnPairs.length) {
            return Container(
              width: 200.sp,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: onExploreAll,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 22.sp, vertical: 14.sp),
                  decoration: BoxDecoration(
                    color: dark ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(8.sp),
                    border: Border.all(
                      color: dark ? Colors.white : Colors.black,
                      width: 2.sp,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "VIEW ALL\nPRODUCTS",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Clash Display Semibold",
                          fontSize: 13.sp,
                          color: dark ? Colors.white : Colors.black,
                          letterSpacing: 0.3,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      Container(
                        padding: EdgeInsets.all(8.sp),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dark ? Colors.white : Colors.black,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 16.sp,
                          color: dark ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Regular product columns (2 products stacked vertically)
          final columnProducts = columnPairs[index];

          return SizedBox(
            width: 150.sp,
            child: Column(
              children: [
                // Top product
                _buildProductCard(columnProducts[0]),

                if (columnProducts.length > 1) ...[
                  SizedBox(height: 12.sp),
                  // Bottom product
                  _buildProductCard(columnProducts[1]),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> p) {
    final id =
        p['id'] is int ? p['id'] : int.tryParse(p['id']?.toString() ?? '') ?? 0;

    final title = p['title']?.toString() ?? '';
    final brandName = resolveBrandName(p);
    final pricing = resolvePricing(p);
    final numPrice = pricing['price'] as num;
    final numMrp = pricing['mrp'] as num?;
    final discount = pricing['discountPercent'] as int?;

    String imageUrl = "";
    if (p['imageUrls'] is List && (p['imageUrls'] as List).isNotEmpty) {
      imageUrl = p['imageUrls'][0].toString();
    }

    return GestureDetector(
      onTap: () => onProductTap(id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.sp),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 180.sp,
                    width: 150.sp,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      height: 180.sp,
                      width: 150.sp,
                      color: Colors.black.withOpacity(0.06),
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey.withOpacity(0.5),
                        size: 40.sp,
                      ),
                    ),
                  )
                : Container(
                    height: 180.sp,
                    width: 150.sp,
                    color: Colors.black.withOpacity(0.06),
                  ),
          ),
          SizedBox(height: 4.sp),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: "Clash Display Semibold",
              fontSize: 12.sp,
              color: dark ? Colors.white : Colors.black,
            ),
          ),
          if (brandName.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 1.sp),
              child: Text(
                brandName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: "Clash Display",
                  fontSize: 10.sp,
                  color: dark
                      ? Colors.white.withOpacity(0.85)
                      : Colors.black.withOpacity(0.7),
                ),
              ),
            ),
          if (numPrice > 0)
            Padding(
              padding: EdgeInsets.only(top: 3.sp),
              child: Wrap(
                spacing: 4.sp,
                runSpacing: 4.sp,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "₹$numPrice",
                    style: TextStyle(
                      fontFamily: "Clash Display Semibold",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: dark ? Colors.white : Colors.black,
                    ),
                  ),
                  if (numMrp != null && numMrp > numPrice)
                    Text(
                      "₹$numMrp",
                      style: TextStyle(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 10.sp,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: const Color(0xFF9CA3AF),
                        fontFamily: "Clash Display Regular",
                      ),
                    ),
                  if (discount != null && discount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 5.sp, vertical: 1.5.sp),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6D5FF),
                        borderRadius: BorderRadius.circular(3.sp),
                      ),
                      child: Text(
                        "$discount% OFF",
                        style: TextStyle(
                          fontSize: 8.5.sp,
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9575CD),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ✅ Video Player Widget for Banner Videos
class BannerVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double height;
  final double width;

  const BannerVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.height,
    required this.width,
  });

  @override
  State<BannerVideoPlayer> createState() => _BannerVideoPlayerState();
}

class _BannerVideoPlayerState extends State<BannerVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Autoplay with sound and loop
        _controller.setLooping(true);
        _controller.setVolume(1.0); // Full volume
        _controller.play();
      }
    } catch (e) {
      print("Error initializing video: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Show placeholder if video fails to load
      return Container(
        height: widget.height,
        width: widget.width,
        color: Colors.black.withOpacity(0.04),
        child: const Center(
          child: Icon(
            Icons.videocam_off,
            size: 48,
            color: Colors.grey,
          ),
        ),
      );
    }

    if (!_isInitialized) {
      // Show loading indicator while initializing
      return Container(
        height: widget.height,
        width: widget.width,
        color: Colors.black.withOpacity(0.04),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Show video player
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}

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
            fontFamily: "Clash Display Semibold",
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
                crossAxisSpacing: 12.sp, // ✅ REDUCED from 16.sp
                mainAxisSpacing: 14.sp, // ✅ REDUCED from 18.sp
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
                final rawPrice = m['displayPrice'] ??
                    m['basePrice'] ??
                    m['base_price'] ??
                    m['baseprice'] ??
                    m['price'];
                if (rawPrice is num) {
                  price = rawPrice;
                } else if (rawPrice is String) {
                  price = num.tryParse(rawPrice);
                }

                num? mrp;
                final rawMrp = m['displayMrp'] ?? m['mrp'];
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
          padding: EdgeInsets.fromLTRB(
              6.sp, 6.sp, 6.sp, 0), // ✅ REDUCED top from 8.sp
          child: Text(
            brand.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: blackColor,
              fontSize: 15,
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              6.sp, 3.sp, 6.sp, 0), // ✅ REDUCED top from 4.sp
          child: Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              6.sp, 4.sp, 6.sp, 0), // ✅ REDUCED top from 6.sp
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
                      fontFamily: "Clash Display Regular",
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
                  fontFamily: "Clash Display",
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

class _ShopByCategorySection extends StatelessWidget {
  final CatalogController catalogController;
  final FirebaseAnalytics analytics;
  final HomeController homeController;
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
          // ✅ Left-aligned section heading
          Padding(
            padding: EdgeInsets.only(left: 16.sp, top: 0.sp, bottom: 12.sp),
            child: AppText(
              text: "SHOP BY CATEGORY",
              fontFamily: "Clash Display Semibold",
              fontWeight: FontWeight.w400,
              color: blackColor,
              fontSize: 16,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child: Center(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.zero,
                childAspectRatio: 0.55,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10.sp, // ✅ REDUCED from 12.sp
                mainAxisSpacing: 0.sp,
                children: List.generate(
                  min(6, catalogController.catalogList.length),
                  (index) {
                    final catalog = catalogController.catalogList[index];
                    return GestureDetector(
                      onTap: () async {
                        final categoryId = catalog["id"];
                        final catalogName = catalog["name"] ?? "Category";

                        await catalogController.getCategoryProductData(
                          categoryId,
                          homeController.homeGenderValue.value,
                        );

                        Get.to(
                          () => CategoryProductScreen(
                            categoryName: catalogName,
                            screen: "category",
                            genderName: homeController.genderText.value,
                            categoryId: categoryId,
                            brandId: 0,
                            genderType: homeController.homeGenderValue.value,
                            categoryList: const [],
                            tagIds: const [],
                            title: '',
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          // 🟦 Category Image Container
                          Container(
                            width: 100.sp,
                            height: 120.sp,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 201, 200, 200),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: (catalog["image"] != null &&
                                      catalog["image"].toString().isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: catalog["image"],
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Image.asset(
                                        dummyWishlistImage,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      dummyWishlistImage,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),

                          SizedBox(height: 8.sp),

                          // 🏷 Category Name
                          AppText(
                            text: (catalog["name"] ?? "")
                                .toString()
                                .toUpperCase(),
                            color: blackColor,
                            fontSize: 13,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            fontFamily: "Clash Display",
                            fontWeight: FontWeight.w500,
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
              final g = homeController.homeGenderValue.value;
              final gName = g == 1
                  ? "Men"
                  : g == 2
                      ? "Women"
                      : "Accessories";

              catalogController.selectCategoryGender.value = g;
              catalogController.categoryName.value = gName;

              // ✅ UPDATED: Using the new API endpoint
              await catalogController.getCatagoryData(g);

              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('selectedGender', g);

              onPressedViewAll();
              await analytics.logEvent(
                name: 'home_page_btnviewall',
                parameters: {'page_name': 'home_page_btnviewall'},
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 6.sp, horizontal: 16.sp), // ✅ REDUCED from 16.sp
              child: Container(
                height: 42.sp,
                color: homeAppBarColor,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppText(
                      text: "VIEW ALL",
                      fontFamily: "Clash Display",
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
        ],
      ),
    );
  }
}

// ✅ Widget to display standalone collection banners with auto-scroll
class _StandaloneCollectionBanners extends StatefulWidget {
  final List<StandaloneCollectionBanner> banners;
  final String collectionName;

  const _StandaloneCollectionBanners({
    required this.banners,
    required this.collectionName,
  });

  @override
  State<_StandaloneCollectionBanners> createState() =>
      _StandaloneCollectionBannersState();
}

class _StandaloneCollectionBannersState
    extends State<_StandaloneCollectionBanners> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Auto-scroll only if there are multiple banners
    if (widget.banners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (_pageController.hasClients) {
          final nextPage = (_currentPage + 1) % widget.banners.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    // ✅ Edge-to-edge banners with vertical padding only
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full width banner carousel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.sp), // 👈 adjust radius
              child: SizedBox(
                height: 200.sp,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: widget.banners.length,
                  itemBuilder: (context, index) {
                    final banner = widget.banners[index];
                    return _BannerItem(
                      imageUrl: banner.getImageUrl(isMobile: true),
                      redirectUrl: banner.redirectUrl,
                      height: 200.sp,
                      collectionId: banner.collectionId,
                      collectionName: widget.collectionName,
                    );
                  },
                ),
              ),
            ),
          ),

          // Page indicators (only show if more than 1 banner)
          if (widget.banners.length > 1) ...[
            SizedBox(height: 8.sp),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.banners.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.sp),
                    width: _currentPage == index ? 8.sp : 6.sp,
                    height: _currentPage == index ? 8.sp : 6.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.black
                          : const Color(0xffE5E7EB),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Banner item widget
class _BannerItem extends StatelessWidget {
  final String imageUrl;
  final String redirectUrl;
  final double height;
  final int collectionId;
  final String collectionName;

  const _BannerItem({
    required this.imageUrl,
    required this.redirectUrl,
    required this.height,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final homeController = Get.find<HomeController>();

    return GestureDetector(
      onTap: () async {
        if (redirectUrl.isNotEmpty) {
          print("📍 Banner tapped: $redirectUrl");

          // Navigate to the collection's product view
          productController.tagId.value = collectionId;
          productController.productSortBy.value = "";
          productController.filterProductEnable.value = false;
          productController.categoryFilter.value =
              homeController.homeGenderValue.value;

          Get.to(
            ProductViewScreen(
              title: collectionName,
              genderName: homeController.genderText.value,
            ),
          )?.then((_) {
            SystemChrome.setSystemUIOverlayStyle(
              const SystemUiOverlayStyle(
                statusBarColor: whiteColor,
                systemNavigationBarColor: whiteColor,
              ),
            );
          });

          // Analytics tracking
          final analytics = FirebaseAnalytics.instance;
          await analytics.logEvent(
            name: 'collection_banner_tap',
            parameters: {
              'collection_id': collectionId,
              'collection_name': collectionName,
              'redirect_url': redirectUrl,
            },
          );
        }
      },
      // ✅ No border radius for edge-to-edge banners
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: height,
              fit: BoxFit.fill,
              placeholder: (_, __) => Container(
                width: double.infinity,
                height: height,
                color: Colors.black.withOpacity(0.04),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                width: double.infinity,
                height: height,
                color: Colors.black.withOpacity(0.04),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 48,
                  ),
                ),
              ),
            )
          : Container(
              width: double.infinity,
              height: height,
              color: Colors.black.withOpacity(0.04),
              child: const Center(
                child: Icon(
                  Icons.image,
                  color: Colors.grey,
                  size: 48,
                ),
              ),
            ),
    );
  }
}

class _FeaturedBrandsRow extends StatelessWidget {
  final HomeController homeController;
  final BrandController brandController;
  final FirebaseAnalytics analytics;
  final VoidCallback onPressedViewAll;
  final List<dynamic> brands; // ✅ ADD: Accept brands list

  const _FeaturedBrandsRow({
    required this.homeController,
    required this.brandController,
    required this.analytics,
    required this.onPressedViewAll,
    required this.brands, // ✅ ADD: Required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: Row(
            children: [
              const AppText(
                text: "FEATURED BRANDS",
                fontFamily: "Clash Display Semibold",
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
        SizedBox(height: 12.sp),
        SizedBox(
          height: 90.sp,
          child: ListView.builder(
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
                      SizedBox(height: 4.sp),
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
          ),
        ),
      ],
    );
  }
}
