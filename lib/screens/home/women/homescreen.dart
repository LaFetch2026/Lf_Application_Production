// ignore_for_file: avoid_print, deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:lafetch/common/widget/other/pounce_wrapper.dart';
import 'package:lafetch/screens/catalog/productlist/pdp_v2/product_details_screen_v2.dart';
import 'package:lafetch/screens/home/women/productviewscreen.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:marquee/marquee.dart';
import 'package:page_indicator_plus/page_indicator_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../../utils/audio_session_helper.dart';
import '../../../common/widget/appbar/home_appbar.dart';
import '../../../screens/accountscreen.dart';
import '../../../screens/catalog/women_catalog.dart';
import '../../../common/widget/lists/dummy_home_brand.dart';
import '../../../common/widget/lists/dummy_grid_list.dart';
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
import '../../../models/collection_model.dart';
import '../../../models/nudge_model.dart';
import '../../../common/widget/newsletter/newsletter_section.dart';
import '../../../core/utils/image_helper.dart';
import '../../../controllers/new_in_controller.dart';
import '../../../common/widget/cards/product_card.dart';
import '../../../widgets/nudge_badge_row.dart';
import 'package:lafetch/common/widget/other/lf_loader_widget.dart';
import 'package:shimmer/shimmer.dart';

// ✅ Global RouteObserver for video auto-pause on navigation
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomeScreen extends StatefulWidget {
  final Function(int)? onPressed;

  const HomeScreen({this.onPressed, super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final homeController = Get.put(HomeController());
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final searchController = Get.put(SearchScreenController());
  final cartController = Get.put(CartController());
  final brandController = Get.put(BrandController());
  final catalogController = Get.put(CatalogController());
  final profileController = Get.put(ProfileController());
  final newInController = Get.put(NewInController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final PageController _pageController = PageController(initialPage: 0);
  Timer? timer;
  bool isGuest = false;
  static bool _isInitialLoad = true;
  static bool _dataLoaded = false; // Static to persist across rebuilds
  bool _isRefreshing = false;
  double _pullOffset = 0;

  static const Map<int, String> _sectionVideoUrls = {
    1: "https://la-fetch.s3.ap-south-1.amazonaws.com/Application_Banners/Lafetch-Men's.mp4",
    2: "https://la-fetch.s3.ap-south-1.amazonaws.com/Application_Banners/Lafetch-Women.mp4",
    3: "https://la-fetch.s3.ap-south-1.amazonaws.com/Application_Banners/accessories-banner.mp4",
  };
  final Map<int, VideoPlayerController> _sectionVideoControllers = {};

  // Keep screen alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  // ✅ TabController for animated gender tabs
  TabController? _genderTabController;

  // ✅ Pagination variables
  int _currentCollectionPage = 1;
  bool _hasMoreCollections = true;
  bool _isLoadingMoreCollections = false;
  final int _collectionsPerPage =
      3; // ✅ Reduced to 3 to prevent memory overload
  bool _showAllCollections = false; // ✅ Track View All button state

  @override
  void initState() {
    super.initState();

    // ✅ Add scroll listener for pagination
    homeController.discountScreenController.addListener(_onScroll);

    // Apply UI styles and fetch data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return; // ✅ Check if widget is still mounted

      // ✅ Reset scroll state after frame
      homeController.isScrolling.value = false;

      try {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: whiteColor,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: whiteColor,
          systemNavigationBarIconBrightness: Brightness.dark,
        ));

        // ✅ NEW: Fetch gender tabs FIRST
        await homeController.getGenderTabs();
        if (!mounted) return; // ✅ Check after async call

        // ✅ Check if user is guest
        final prefs = await SharedPreferences.getInstance();
        if (!mounted) return; // ✅ Check after async call

        isGuest = prefs.getBool('skip') ?? false;

        // ✅ NEW: Load saved gender preference or use first tab from API
        final savedGender = prefs.getInt('selectedGender');
        int initialTabIndex = 0;

        if (savedGender != null &&
            homeController.genderTabs.any((tab) => tab['id'] == savedGender)) {
          homeController.homeGenderValue.value = savedGender;
          final tab = homeController.genderTabs.firstWhere(
            (tab) => tab['id'] == savedGender,
            orElse: () => homeController.genderTabs.first,
          );
          homeController.genderText.value = tab['name']?.toString() ?? '';
          // Find the index of the saved gender
          initialTabIndex = homeController.genderTabs.indexWhere(
            (tab) => tab['id'] == savedGender,
          );
          if (initialTabIndex < 0) initialTabIndex = 0;
        } else if (homeController.genderTabs.isNotEmpty) {
          homeController.homeGenderValue.value =
              homeController.genderTabs.first['id'] ?? 1;
          homeController.genderText.value =
              homeController.genderTabs.first['name']?.toString() ?? 'MEN';
          await prefs.setInt(
              'selectedGender', homeController.homeGenderValue.value);
          initialTabIndex = 0;
        } else {
          homeController.homeGenderValue.value = 1;
          homeController.genderText.value = 'Men';
          print("⚠️ No gender tabs from API, using default");
        }

        // ✅ Initialize TabController for animated gender tabs
        if (!mounted) return; // ✅ Check before calling setState
        _initGenderTabController(initialTabIndex);

        homeController.showGenderList.value = false;
        homeController.currentPage.value = 0;
        productController.current.value = 50;
        productController.collectionId.value = 0;
        productController.tagname.value = "";
        productController.productCategory = [];
        productController.productTags = [];
        productController.categoryFilter.value =
            homeController.homeGenderValue.value;

        await checkUserConnection();
        if (!mounted) return; // ✅ Check after async call

        final currentGender = homeController.homeGenderValue.value;

        // ✅ Skip loading if data already exists (prevents duplicate API calls on tab switch)
        final bool hasExistingData = homeController.banner1List.isNotEmpty ||
            homeController.banner2List.isNotEmpty ||
            productController.homeProductList.isNotEmpty;

        // CRASH FIX: Only initialize the active tab's video controller.
        // Previous code initialized all 3, causing MediaCodec exhaustion.
        final currentGenderId = homeController.homeGenderValue.value;
        if (_sectionVideoUrls.containsKey(currentGenderId) &&
            !_sectionVideoControllers.containsKey(currentGenderId)) {
          _initSectionVideoController(
              currentGenderId, _sectionVideoUrls[currentGenderId]!);
        }

        if (_dataLoaded && hasExistingData && !_isInitialLoad) {
          print("✅ Data already loaded, skipping API calls");
          // Still fire NEW IN fetch in case it was skipped (e.g. hot restart)
          if (newInController.products.isEmpty) {
            newInController.fetchProducts(currentGender);
          } else {
            newInController.isLoading.value = false;
          }
          return;
        }

        // ✅ Reset any stuck loading states
        homeController.isBanner1.value = false;

        // ✅ Force refresh on initial load to ensure fresh data
        final bool isFirstLoad = _isInitialLoad;

        // ✅ Load home data first (banners, categories, announcements, brands)
        // then load the remaining data — prevents hitting backend rate limits
        // from too many simultaneous requests (429 Too Many Requests)
        await homeController.initializeHomeData(currentGender,
            forceRefresh: isFirstLoad);

        if (!mounted) return;

        await Future.wait([
          catalogController.getCatalogData(currentGender,
              forceRefresh: isFirstLoad),
          productController.getHomeProduct(currentGender,
              forceRefresh: isFirstLoad),
          productController.getCollectionBanners(forceRefresh: isFirstLoad),
          productController.fetchLuxuryProducts(
              forceRefresh: isFirstLoad), // ✅ Fetch luxury products
          productController.fetchLuxeProducts(
              forceRefresh:
                  isFirstLoad), // ✅ Fetch LUXE products (segment=luxury, limit=8)
          brandController.getBrandData("featured", currentGender),
          brandController.getNewlyLaunchedBrands(gender: currentGender),
        ]);

        if (!mounted) return; // ✅ Check after async call

        // ✅ Fire NEW IN fetch after critical data — non-blocking
        newInController.fetchProducts(currentGender, forceRefresh: isFirstLoad);

        // ✅ Mark data as loaded
        _dataLoaded = true;

        // ✅ FORCE UPDATE: Trigger reactive update after all data is loaded
        brandController.update();

        // One-time setup calls
        if (_isInitialLoad) {
          homeController.getDeviceName();
          _isInitialLoad = false;
        }

        // ✅ Fix hot reload visibility issue
        if (catalogController.catalogByGender[currentGender]?.isNotEmpty ==
            true) {
          catalogController.update();
        }
      } catch (e, stackTrace) {
        print("❌ Error during home screen initialization: $e");
        print("Stack trace: $stackTrace");
        // Show error to user but don't crash the app
        if (mounted) {
          getSnackBar("Failed to load some data. Please try refreshing.");
        }
      }
    });
  }

  // ✅ Method to force refresh data (call when pull-to-refresh or manual refresh)
  Future<void> forceRefreshData() async {
    setState(() => _isRefreshing = true);
    try {
      print("🔄 Force refresh triggered");

      final currentGender = homeController.homeGenderValue.value;

      // ✅ Clear loaded tracking to allow fresh API calls
      homeController.clearLoadedGenders();
      productController.clearLoadedTracking();
      catalogController.clearLoadedTracking();
      brandController.clearLoadedTracking();
      newInController.clearCache();

      // ✅ UPDATED: Include brands, collection banners, and announcements in refresh
      await Future.wait([
        homeController.initializeHomeData(currentGender, forceRefresh: true),
        catalogController.getCatalogData(currentGender, forceRefresh: true),
        productController.getHomeProduct(currentGender, forceRefresh: true),
        productController.getCollectionBanners(forceRefresh: true),
        brandController.getBrandData("featured", currentGender),
        brandController.getNewlyLaunchedBrands(gender: currentGender),
        homeController.getAnnouncements(forceRefresh: true),
        newInController.fetchProducts(currentGender, forceRefresh: true),
      ]);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  // ✅ Static method to clear all cached data (call on logout)
  static void clearCache() {
    print("🗑️ Clearing HomeScreen cache on logout");
    _isInitialLoad = true;
    _dataLoaded = false;

    // ✅ Clear loaded tracking in controllers
    try {
      final homeController = Get.find<HomeController>();
      final productController = Get.find<ProductController>();
      final catalogController = Get.find<CatalogController>();
      final brandController = Get.find<BrandController>();
      homeController.clearLoadedGenders();
      productController.clearLoadedTracking();
      catalogController.clearLoadedTracking();
      brandController.clearLoadedTracking();
      try {
        Get.find<NewInController>().clearCache();
      } catch (_) {}
    } catch (e) {
      print("⚠️ Could not clear controller tracking: $e");
    }
  }

  // ---- helpers ----

  List<dynamic> _currentBannerList() {
    final currentGender = homeController.homeGenderValue.value;

    print("🔍 _currentBannerList: currentGender=$currentGender");
    print("🔍 banner1List.length=${homeController.banner1List.length}");
    print("🔍 banner2List.length=${homeController.banner2List.length}");
    print("🔍 banner3List.length=${homeController.banner3List.length}");

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

    print("🔍 Selected bannerList.length=${bannerList.length}");

    // ✅ Filter to return ONLY banners with mobileImage (not null/empty)
    final filtered = bannerList.where((item) {
      final mobileImage = (item as Map?)?["mobileImage"]?.toString() ?? '';
      final hasImage = mobileImage.isNotEmpty;
      if (mobileImage.isNotEmpty) {
        final preview = mobileImage.length > 50
            ? mobileImage.substring(0, 50)
            : mobileImage;
        print("🔍 Banner has mobileImage: $preview...");
      }
      return hasImage;
    }).toList();

    print("🔍 Filtered banners count: ${filtered.length}");
    return filtered;
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
    _scrollEndTimer?.cancel();
    _pageController.dispose(); // ✅ Dispose banner PageController
    _genderTabController?.dispose();
    homeController.discountScreenController.removeListener(_onScroll);
    for (final c in _sectionVideoControllers.values) {
      c.dispose();
    }
    _sectionVideoControllers.clear();
    super.dispose();
  }

  // ✅ Scroll listener for pagination
  void _onScroll() {
    if (!homeController.discountScreenController.hasClients) return;

    final scrollController = homeController.discountScreenController;
    final scrollPosition = scrollController.position;

    // Trigger when scrolled 80% to the bottom
    if (scrollPosition.pixels >= scrollPosition.maxScrollExtent * 0.8) {
      _loadMoreCollections();
    }
  }

  // Debounce timer for scroll end
  Timer? _scrollEndTimer;

  // Handle scroll notifications for navbar transparency
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      // Only set to scrolling if not already scrolling
      if (!homeController.isScrolling.value) {
        homeController.isScrolling.value = true;
      }
      // Reset timer on each scroll update
      _scrollEndTimer?.cancel();
      _scrollEndTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          homeController.isScrolling.value = false;
        }
      });
    }
    return false;
  }

  // ✅ Load more collections when scrolling
  Future<void> _loadMoreCollections() async {
    if (_isLoadingMoreCollections || !_hasMoreCollections) return;

    if (!mounted) return; // ✅ Check before setState

    setState(() {
      _isLoadingMoreCollections = true;
    });

    try {
      // Increment page
      _currentCollectionPage++;

      // Load more collections (this will be handled in the controller)
      // For now, we'll just mark that we've loaded more
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return; // ✅ Check after async call

      setState(() {
        _isLoadingMoreCollections = false;
      });
    } catch (e) {
      print("Error loading more collections: $e");
      if (!mounted) return; // ✅ Check before setState

      setState(() {
        _isLoadingMoreCollections = false;
      });
    }
  }

  // ✅ Initialize TabController for gender tabs with animated indicator
  void _initGenderTabController(int initialIndex) {
    if (!mounted) return; // ✅ Check if widget is still mounted

    _genderTabController?.dispose();
    if (homeController.genderTabs.isNotEmpty) {
      _genderTabController = TabController(
        length: homeController.genderTabs.length,
        vsync: this,
        initialIndex:
            initialIndex.clamp(0, homeController.genderTabs.length - 1),
      );
      _genderTabController!.addListener(_onGenderTabChanged);
      if (mounted) setState(() {}); // ✅ Check before setState
    }
  }

  // ✅ Handle tab change from TabController (both tap and swipe)
  void _onGenderTabChanged() {
    if (_genderTabController == null) return;
    if (_genderTabController!.indexIsChanging) return;

    final index = _genderTabController!.index;
    if (index < 0 || index >= homeController.genderTabs.length) return;

    final tab = homeController.genderTabs[index];
    final int genderId = tab['id'] is int
        ? tab['id'] as int
        : int.tryParse(tab['id']?.toString() ?? '') ?? 0;
    final String genderName = tab['name']?.toString() ?? '';

    // Only trigger if actually changed
    if (homeController.homeGenderValue.value != genderId) {
      _changeGenderTab(index);
      // CRASH FIX: Dispose old video controller and init new one on tab switch
      _switchSectionVideoController(genderId);
    }
  }

  // CRASH FIX: Dispose old section video and init new one on tab switch
  void _switchSectionVideoController(int newGenderId) {
    // Dispose all existing section video controllers
    for (final c in _sectionVideoControllers.values) {
      c.dispose();
    }
    _sectionVideoControllers.clear();

    // Initialize only the new active tab's video
    if (_sectionVideoUrls.containsKey(newGenderId)) {
      _initSectionVideoController(newGenderId, _sectionVideoUrls[newGenderId]!);
    }
  }

  /// Format price for display
  String _formatPrice(dynamic price) {
    if (price is num) {
      return price.toInt().toString();
    }
    return price?.toString() ?? '0';
  }

  // ------- BANNERS -------

  List<Widget> widgitBannerList() {
    final currentBannerList =
        _currentBannerList(); // ✅ Already filtered in _currentBannerList()
    final List<Widget> list = [];
    final currentGender = homeController
        .homeGenderValue.value; // ✅ Get current gender for unique keys

    // ✅ Safety check: Return empty list if no banners
    if (currentBannerList.isEmpty) {
      print("⚠️ No banners to display in widgitBannerList");
      return list;
    }

    for (var i = 0; i < currentBannerList.length; i++) {
      try {
        final item = (currentBannerList[i] as Map?) ?? const {};
        final int bannerId = () {
          final v = item["id"];
          if (v is int) return v;
          return int.tryParse(v?.toString() ?? '') ?? 0;
        }();

        // ✅ Use mobileImage only with trim to remove whitespace
        final String imageUrl = item["mobileImage"]?.toString().trim() ?? '';

        // ✅ Skip banner if no valid image URL
        if (imageUrl.isEmpty) {
          print("⚠️ Banner $i has empty imageUrl, skipping");
          continue;
        }

        print("🖼️ Banner $i: imageUrl='$imageUrl'");
        print("🖼️ Banner $i: isVideo=${isVideoUrl(imageUrl)}");

        list.add(
          Container(
            key: ValueKey(
                'banner_${currentGender}_$bannerId'), // ✅ Unique key per gender + banner
            // ✅ Banner tap disabled - no navigation
            child: imageUrl.isNotEmpty && isVideoUrl(imageUrl)
                ? BannerVideoPlayer(
                    videoUrl: imageUrl,
                    height: 229.sp,
                    width: MediaQuery.of(context).size.width,
                    scrollController: homeController.discountScreenController,
                  )
                : CachedNetworkImage(
                    cacheManager: CacheManager(
                      Config(
                        "customCacheKey",
                        stalePeriod: const Duration(days: 15),
                        maxNrOfCacheObjects: 50, // ✅ Reduced from 100 to 50
                      ),
                    ),
                    fit: BoxFit.fill,
                    imageUrl: ImageHelper.toWebP(imageUrl),
                    height: 229.sp,
                    width: MediaQuery.of(context).size.width,
                    // ✅ Removed resize parameters - incompatible with custom CacheManager
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      print("🖼️ Loading banner image: $url");
                      return Center(
                        child: Container(
                          height: 229.sp,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.04),
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      print("❌ Banner image error: $url - Error: $error");
                      return Image.asset(
                        downloadImage,
                        fit: BoxFit.fill,
                        height: 229.sp,
                        width: MediaQuery.of(context).size.width,
                      );
                    },
                  ),
          ),
        );
      } catch (e, stackTrace) {
        print("❌ Error building banner $i: $e");
        print("Stack trace: $stackTrace");
        // Skip this banner and continue with next one
        continue;
      }
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

  Future<void> onGenderChanged(int genderId) async {
    if (homeController.homeGenderValue.value == genderId) return;

    print("🔁 Gender changed → $genderId");

    homeController.homeGenderValue.value = genderId;

    // clear old UI instantly
    productController.homeProductList.clear();

    // reset pagination
    productController.current.value = 1;

    await productController.getHomeProduct(
      genderId,
      forceRefresh: false, // cache used
    );
  }

  // ------- UI -------

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: whiteColor,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          final home = Get.find<HomeController>();

          if (!home.isHomeTabActive.value) return false;

          if (notification.direction == ScrollDirection.reverse &&
              notification.metrics.pixels > 120) {
            home.isBottomNavVisible.value = false;
          } else if (notification.direction == ScrollDirection.forward) {
            home.isBottomNavVisible.value = true;
          }

          return false;
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is OverscrollNotification &&
                notification.overscroll < 0 &&
                !_isRefreshing) {
              // Accumulate pull distance
              final pull = (-notification.overscroll * 0.4).clamp(0.0, 80.0);
              if (_pullOffset != pull) {
                setState(() => _pullOffset = pull);
              }
            } else if (notification is ScrollEndNotification ||
                notification is UserScrollNotification) {
              if (_pullOffset > 50 && !_isRefreshing) {
                setState(() => _pullOffset = 0);
                forceRefreshData();
              } else if (_pullOffset > 0 && !_isRefreshing) {
                setState(() => _pullOffset = 0);
              }
            }
            return false;
          },
          child: Stack(
            children: [
              Column(
                children: [
                  HomeAppbar(
                    onPressedSearch: () async {
                      final searchQuery =
                          searchController.searchController.text;
                      await analytics.logEvent(
                        name: 'search_page',
                        parameters: {'search_string': searchQuery},
                      );
                      Get.to(const SearchScreen(), preventDuplicates: true)
                          ?.then((value) {
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

                      Get.to(CartScreen())
                          ?.then((_) => cartController.getCartData());
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
                    onPressedProfile: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final isGuest = prefs.getBool('skip') ?? false;
                      if (isGuest) {
                        getSnackBar("Please login to view your profile");
                        Get.to(() => const LoginScreen(initialTab: 0));
                      } else {
                        Get.to(() => AccountScreen(onPressed: () {}),
                            transition: Transition.rightToLeft);
                      }
                    },
                  ),

                  // Gender tabs with animated indicator
                  Obx(
                    () => homeController.isLoadingTabs.value
                        ? SizedBox(
                            height: 40.sp,
                            child: const Center(
                              child: LfLogoLoader(size: 20, showGlow: false),
                            ),
                          )
                        : homeController.genderTabs.isEmpty ||
                                _genderTabController == null
                            ? const SizedBox.shrink()
                            : SizedBox(
                                width: double.infinity,
                                height: 40.sp,
                                child: TabBar(
                                  controller: _genderTabController,
                                  isScrollable:
                                      homeController.genderTabs.length > 3,
                                  tabAlignment:
                                      homeController.genderTabs.length > 3
                                          ? TabAlignment.start
                                          : TabAlignment.fill,
                                  indicatorColor: homeAppBarColor,
                                  indicatorWeight: 2.sp,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  labelColor: homeAppBarColor,
                                  unselectedLabelColor: searchTextColor,
                                  dividerColor: Colors.transparent,
                                  labelStyle: TextStyle(
                                    fontSize: 13.sp,
                                    fontFamily: "Clash Display Semibold",
                                    fontWeight: FontWeight.w500,
                                  ),
                                  unselectedLabelStyle: TextStyle(
                                    fontSize: 13.sp,
                                    fontFamily: "Clash Display",
                                    fontWeight: FontWeight.w500,
                                  ),

                                  /// 🔥 THIS IS THE KEY LINE - call _changeGenderTab to load ALL data
                                  onTap: (index) {
                                    // Let the TabController listener handle the change
                                    // to avoid race condition with onGenderChanged
                                  },

                                  tabs: homeController.genderTabs.map((tab) {
                                    final String genderName =
                                        tab['name']?.toString() ?? '';
                                    return Tab(
                                      text: genderName.toUpperCase(),
                                    );
                                  }).toList(),
                                )),
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: _handleScrollNotification,
                          child: SingleChildScrollView(
                            controller: homeController.discountScreenController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section video banner (cached controllers, no extra S3 requests on tab switch)
                                Obx(() {
                                  final genderId =
                                      homeController.homeGenderValue.value;
                                  final controller =
                                      _sectionVideoControllers[genderId];
                                  return _SectionVideoBanner(
                                    controller: controller,
                                  );
                                }),
                                // ✅ Consistent spacing
                                // Marquee Banner - Dynamic from API with icons
                                Obx(() {
                                  final announcements =
                                      homeController.announcements;

                                  if (announcements.isEmpty) {
                                    // Fallback to static text if no announcements
                                    return Container(
                                      height: 30.sp,
                                      color: const Color(0xff2D2D2E),
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5.sp),
                                        child: Center(
                                          child: Marquee(
                                            text:
                                                '|    More than 50+ Homegrown Brands   |    Fast and Reliable   |    Fashion for all occassions  |    Easy Returns & Exchanges   |    Secure Payments   ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                              fontFamily:
                                                  "Clash Display Regular",
                                              fontWeight: FontWeight.w400,
                                            ),
                                            scrollAxis: Axis.horizontal,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            velocity: 100.0,
                                            pauseAfterRound: Duration.zero,
                                            accelerationCurve: Curves.linear,
                                            decelerationCurve: Curves.easeOut,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  // Show icons with text using custom marquee
                                  return _AnnouncementMarquee(
                                    announcements: announcements,
                                  );
                                }),

                                SizedBox(height: 12.sp), // ✅ Consistent spacing

                                // ── NEW IN Section ──────────────────────────────
                                _NewInSection(newInController: newInController),

                                SizedBox(
                                    height: 16
                                        .sp), // ✅ Spacing before newly launched

                                // ── NEWLY LAUNCHED BRANDS Section ──────────────────────────────
                                _NewlyLaunchedBrandsSection(
                                  brandController: brandController,
                                  analytics: analytics,
                                ),

                                // const SizedBox(height: 12),
                                // Divider(
                                //   color: Colors.grey[200],
                                //   height: 1,
                                //   thickness: 4.sp,
                                // ),
                                // const SizedBox(height: 12),

                                // Shop by Category Section
                                Obx(
                                  () {
                                    // Touch both observables so Obx re-runs when either changes
                                    homeController.homeGenderValue.value;
                                    catalogController.catalogByGender.length;
                                    catalogController.isCatalog.value;

                                    return _ShopByCategorySection(
                                      catalogController: catalogController,
                                      homeController: homeController,
                                      analytics: analytics,
                                    );
                                  },
                                ),

                                Divider(
                                  color: Colors.grey[200],
                                  height: 1,
                                  thickness: 4.sp,
                                ),
                                const SizedBox(height: 12),

                                Obx(() {
                                  // ✅ Watch brandController instead of homeController
                                  if (brandController.isBrand.value) {
                                    return const DummyHomeBrand();
                                  }

                                  // ✅ Get brands from brandController
                                  final brands = brandController.brandList
                                      .where((b) =>
                                          b.containsKey("id") &&
                                          (b["name"]?.toString().isNotEmpty ??
                                              false))
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
                                    onPressedViewAll: () =>
                                        widget.onPressed?.call(1),
                                    brands: brands,
                                  );
                                }),

                                // Banner Section - moved below Featured Brands
                                Obx(() {
                                  homeController.homeGenderValue.value;

                                  final banners = _currentBannerList();
                                  final isLoading =
                                      homeController.isBanner1.value;
                                  final currentValue =
                                      productController.current.value;
                                  final showBanners =
                                      banners.isNotEmpty && currentValue == 50;

                                  if (isLoading && banners.isEmpty) {
                                    return Container(
                                      height: 210.sp,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.04),
                                      ),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            LfLogoLoader(
                                                size: 32, showGlow: false),
                                            SizedBox(height: 12),
                                            Text(
                                              'Loading banners...',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                                fontFamily:
                                                    "Clash Display Regular",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  if (showBanners) {
                                    final bannerWidgets = widgitBannerList();
                                    if (bannerWidgets.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    return Column(
                                      children: [
                                        ClipRRect(
                                          child: AspectRatio(
                                            aspectRatio: 3 / 1,
                                            child: PageView(
                                              key: ValueKey(
                                                  'pageview_${homeController.homeGenderValue.value}'),
                                              controller: _pageController,
                                              onPageChanged: (index) {
                                                if (index >= 0 &&
                                                    index <
                                                        bannerWidgets.length) {
                                                  homeController.currentPage
                                                      .value = index;
                                                }
                                              },
                                              children: bannerWidgets,
                                            ),
                                          ),
                                        ),
                                        banners.length == 1
                                            ? const SizedBox.shrink()
                                            : Center(
                                                child: PageIndicator(
                                                  controller: _pageController,
                                                  count: banners.length,
                                                  size: 6.0.sp,
                                                  activeColor: Colors.black,
                                                  color:
                                                      const Color(0xffE5E7EB),
                                                  layout:
                                                      PageIndicatorLayout.WARM,
                                                  scale: 0.65,
                                                  space: 8.sp,
                                                ),
                                              ),
                                      ],
                                    );
                                  }

                                  return const SizedBox.shrink();
                                }),

                                // Product Collections
                                // removed due to no incoming data
                                Obx(() {
                                  final currentGender =
                                      homeController.homeGenderValue.value;

                                  // ✅ Show loader ONLY if actively loading AND list is empty
                                  // ✅ FIXED: Don't show skeleton if data already exists, even if loading flag is true
                                  if (productController
                                          .homeProductList.isEmpty &&
                                      (productController.isHomeProduct.value ||
                                          !productController
                                              .isHomeProductLoaded(
                                                  currentGender))) {
                                    return DummyProductList(
                                      visibleSubtitle: true,
                                      text: (productController.tagname.value)
                                          .toUpperCase(),
                                    );
                                  }

                                  // ✅ Collections are already filtered by the API to only include those with products
                                  // ✅ Extra safety check: Filter out any collections with empty products
                                  final allCollections = productController
                                      .homeProductList
                                      .where((c) => c.hasProducts)
                                      .toList();

                                  // ✅ PAGINATION: Only show a subset of collections
                                  final collectionsToShow =
                                      _currentCollectionPage *
                                          _collectionsPerPage;
                                  final collections = allCollections
                                      .take(collectionsToShow)
                                      .toList();

                                  // Update hasMore flag
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (_hasMoreCollections !=
                                        (collections.length <
                                            allCollections.length)) {
                                      setState(() {
                                        _hasMoreCollections =
                                            collections.length <
                                                allCollections.length;
                                      });
                                    }
                                  });

                                  print(
                                      "📊 Showing ${collections.length}/${allCollections.length} collections (page $_currentCollectionPage)");

                                  if (collections.isEmpty) {
                                    print(
                                        "⚠️ No collections to display - showing empty space");
                                    return Column(
                                      children: [
                                        SizedBox(
                                            height:
                                                24.sp), // ✅ Consistent spacing
                                        const Center(
                                          child: Text(
                                            "No products available for this category",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontFamily:
                                                  "Clash Display Regular",
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                24.sp), // ✅ Consistent spacing
                                      ],
                                    );
                                  }

                                  return Column(
                                    children: [
                                      ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        padding: EdgeInsets
                                            .zero, // ✅ Remove default ListView padding
                                        itemCount: collections.length,
                                        // ✅ No separator needed - each _CollectionSection has consistent bottom padding
                                        itemBuilder: (context, index) {
                                          final collection = collections[index];
                                          final int collectionId =
                                              collection.id;
                                          final String title = collection.name;
                                          final String subtitle =
                                              collection.desc ?? '';

                                          // ✅ Get banners for current gender from standalone banner API
                                          final currentGender = homeController
                                              .genderText.value
                                              .toLowerCase();
                                          final standaloneBanners =
                                              productController
                                                  .getBannersForCollection(
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

                                          return _CollectionSection(
                                            collectionId: collectionId,
                                            title: title,
                                            subtitle: subtitle,
                                            dark: dark,
                                            products: products,
                                            banners: standaloneBanners,
                                            onProductTap: (productId) async {
                                              Get.to(
                                                ProductDetailsScreenV2(
                                                  productId: productId,
                                                  type: "add",
                                                  brandName: "",
                                                ),
                                              )?.then((_) {
                                                setState(() {
                                                  SystemChrome
                                                      .setSystemUIOverlayStyle(
                                                    const SystemUiOverlayStyle(
                                                      statusBarColor:
                                                          whiteColor,
                                                      systemNavigationBarColor:
                                                          whiteColor,
                                                    ),
                                                  );
                                                });
                                              });

                                              await analytics.logEvent(
                                                name:
                                                    'product_details_home_page',
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
                                            onTitleTap: () {
                                              productController.collectionId
                                                  .value = collectionId;
                                              productController
                                                  .productSortBy.value = "";
                                              productController
                                                  .filterProductEnable
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
                                            },
                                            onExploreAll: () async {
                                              productController.collectionId
                                                  .value = collectionId;
                                              productController
                                                  .productSortBy.value = "";
                                              productController
                                                  .filterProductEnable
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
                                                name:
                                                    'homepage_productExploreAll',
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
                                          );
                                        },
                                      ),

                                      // ✅ Loading indicator for pagination
                                      if (_isLoadingMoreCollections)
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 24.sp),
                                          child: const Center(
                                            child: LfLogoLoader(
                                                size: 32, showGlow: false),
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                                SizedBox(
                                  height: 10.sp,
                                ),
                                // Newsletter Section
                                const NewsletterSection(
                                  title: "LF NEWS LETTERS",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Pull-to-refresh logo — slides down from top, no blur
              if (_pullOffset > 0 || _isRefreshing)
                Positioned(
                  top: MediaQuery.of(context).padding.top +
                      (_isRefreshing ? 8 : (_pullOffset - 40).clamp(0.0, 8.0)),
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _isRefreshing
                          ? 1.0
                          : (_pullOffset / 80.0).clamp(0.0, 1.0),
                      duration: const Duration(milliseconds: 150),
                      child: const LfLogoLoader(size: 28),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initSectionVideoController(int genderId, String url) async {
    try {
      // Dispose any existing controller for this gender before re-initializing
      // (prevents stale controllers lingering on hot restart)
      final existing = _sectionVideoControllers[genderId];
      if (existing != null) {
        existing.pause();
        existing.dispose();
        _sectionVideoControllers.remove(genderId);
      }

      await configureAmbientAudioSession();
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      controller
        ..setLooping(true)
        ..setVolume(0.0)
        ..play();
      _sectionVideoControllers[genderId] = controller;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ Section video init error for gender $genderId: $e');
    }
  }

  Future<void> _changeGenderTab(int tabIndex) async {
    if (tabIndex < 0 || tabIndex >= homeController.genderTabs.length) return;

    final tab = homeController.genderTabs[tabIndex];
    final int genderId = tab['id'] is int
        ? tab['id'] as int
        : int.tryParse(tab['id']?.toString() ?? '') ?? 0;
    final String genderName = tab['name']?.toString() ?? '';

    // Clear stale products BEFORE updating homeGenderValue so the Obx
    // doesn't briefly render old gender's data under the new gender label.
    productController.homeProductList.clear();

    // Clear NEW IN immediately so shimmer shows instead of stale products
    newInController.products.clear();
    newInController.isLoading.value = true;

    homeController.genderText.value = genderName;
    homeController.homeGenderValue.value = genderId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedGender', genderId);

    print("🔄 Switching to gender: $genderName");

    homeController.currentPage.value = 0;

    if (homeController.discountScreenController.hasClients) {
      homeController.discountScreenController.jumpTo(0);
    }

    // Always reload products for the new gender — uses cache when available.
    // forceRefresh: false so cached data loads instantly without a network hit.
    await productController.getHomeProduct(genderId, forceRefresh: false);

    // ✅ Reload NEW IN products for the new gender (cache-friendly)
    newInController.fetchProducts(genderId, forceRefresh: false);

    if (!homeController.isGenderDataLoaded(genderId)) {
      await homeController.initializeHomeData(genderId, forceRefresh: false);
      await Future.wait([
        catalogController.getCatalogData(genderId, forceRefresh: false),
        brandController.getBrandData("featured", genderId),
      ]);
    }
  }
}

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

class _NavCircleButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _NavCircleButton({
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.sp,
        height: 28.sp,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? blackColor : const Color(0xFFE5E7EB),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: enabled ? Colors.white : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

// class _NewInSection extends StatelessWidget {
//   final NewInController newInController;

//   const _NewInSection({required this.newInController});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (newInController.isLoading.value) {
//         //NEW IN Shimmer
//         return Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.sp),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Skeleton header row
//               Padding(
//                 padding: EdgeInsets.only(top: 10.sp, bottom: 8.sp),
//                 child: Row(
//                   children: [
//                     Container(
//                       height: 20.sp,
//                       width: 70.sp,
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.04),
//                         borderRadius: BorderRadius.circular(4.sp),
//                       ),
//                     ),
//                     const Spacer(),
//                     Container(
//                       height: 28.sp,
//                       width: 90.sp,
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.04),
//                         borderRadius: BorderRadius.circular(20.sp),
//                       ),
//                     ),
//                     SizedBox(width: 8.sp),
//                     Container(
//                       width: 28.sp,
//                       height: 28.sp,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.black.withOpacity(0.04),
//                       ),
//                     ),
//                     SizedBox(width: 6.sp),
//                     Container(
//                       width: 28.sp,
//                       height: 28.sp,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.black.withOpacity(0.04),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const DummyGridList(size: 4),
//             ],
//           ),
//         );
//       }
//       if (newInController.products.isEmpty) {
//         return const SizedBox.shrink();
//       }

//       final paged = newInController.pagedProducts;
//       final totalPages = newInController.totalPages;
//       final currentPage = newInController.currentPage.value;

//       final canGoPrev = currentPage > 0;
//       final canGoNext = currentPage < totalPages - 1;

//       return Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16.sp),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header row: NEW IN | Sort By button | prev/next arrows
//             Row(
//               children: [
//                 AppText(
//                   text: "NEW IN",
//                   fontFamily: "Clash Display Semibold",
//                   color: blackColor,
//                   fontSize: 18,
//                 ),
//                 const Spacer(),
//                 // Sort By pill button
//                 GestureDetector(
//                   onTap: () => _showSortSheet(context),
//                   child: Container(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: const Color(0xFFD1D5DB)),
//                       borderRadius: BorderRadius.circular(20.sp),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           "Sort By",
//                           style: TextStyle(
//                             fontFamily: "Clash Display Regular",
//                             fontSize: 12.sp,
//                             color: blackColor,
//                           ),
//                         ),
//                         SizedBox(width: 4.sp),
//                         Icon(Icons.tune, size: 14.sp, color: blackColor),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8.sp),
//                 // Prev arrow in circle
//                 _NavCircleButton(
//                   icon: Icons.chevron_left,
//                   enabled: canGoPrev,
//                   onTap: canGoPrev ? newInController.prevPage : null,
//                 ),
//                 SizedBox(width: 6.sp),
//                 // Next arrow in circle
//                 _NavCircleButton(
//                   icon: Icons.chevron_right,
//                   enabled: canGoNext,
//                   onTap: canGoNext ? newInController.nextPage : null,
//                 ),
//               ],
//             ),
//             SizedBox(height: 8.sp),
//             // Product grid — 2 columns, 8 items max
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               padding: EdgeInsets.zero,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 8.sp,
//                 mainAxisSpacing: 8.sp,
//                 childAspectRatio: 0.62,
//               ),
//               itemCount: paged.length,
//               itemBuilder: (context, index) {
//                 final product = paged[index];
//                 final imageUrl =
//                     (product['imageUrls'] as List?)?.firstOrNull?.toString() ??
//                         '';
//                 final title = product['title'] as String? ?? '';
//                 final brand =
//                     (product['brand'] as Map?)?['name'] as String? ?? '';
//                 final mrp = product['mrp'] as num? ?? 0;
//                 final price =
//                     (product['basePrice'] ?? product['mrp']) as num? ?? mrp;
//                 final productId = product['id'];

//                 return ProductGridCard(
//                   imageUrl: imageUrl,
//                   title: title,
//                   brandName: brand,
//                   price: price,
//                   mrp: mrp,
//                   onTap: () {
//                     if (productId == null) return;
//                     Get.to(() => ProductDetailsScreenV2(
//                           productId: productId is int
//                               ? productId
//                               : int.tryParse(productId.toString()) ?? 0,
//                           type: "add",
//                           brandName: brand,
//                         ));
//                   },
//                 );
//               },
//             ),
//             SizedBox(height: 16.sp),
//           ],
//         ),
//       );
//     });
//   }

//   void _showSortSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) => Obx(() {
//         final current = newInController.sortMode.value;
//         final options = [
//           ('default', 'Default'),
//           ('low_to_high', 'Price: Low to High'),
//           ('high_to_low', 'Price: High to Low'),
//           ('discount', 'Discount'),
//         ];
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: 12.sp),
//                 child: AppText(
//                   text: "Sort By",
//                   fontFamily: "Clash Display Semibold",
//                   color: blackColor,
//                   fontSize: 16,
//                 ),
//               ),
//               const Divider(height: 1),
//               ...options.map((opt) {
//                 final isActive = current == opt.$1;
//                 return ListTile(
//                   title: Text(
//                     opt.$2,
//                     style: TextStyle(
//                       fontFamily: isActive
//                           ? "Clash Display Semibold"
//                           : "Clash Display Regular",
//                       fontSize: 14.sp,
//                       color: blackColor,
//                     ),
//                   ),
//                   trailing: isActive
//                       ? Icon(Icons.check, size: 18.sp, color: blackColor)
//                       : null,
//                   onTap: () {
//                     newInController.applySort(opt.$1);
//                     Navigator.pop(context);
//                   },
//                 );
//               }),
//               SizedBox(height: 8.sp),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }

class _NewInSection extends StatelessWidget {
  final NewInController newInController;
  const _NewInSection({required this.newInController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (newInController.isLoading.value) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.sp, bottom: 8.sp),
                child: Row(
                  children: [
                    Container(
                      height: 20.sp,
                      width: 70.sp,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(4.sp),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 28.sp,
                      width: 90.sp,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(20.sp),
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    Container(
                      width: 28.sp,
                      height: 28.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.04),
                      ),
                    ),
                    SizedBox(width: 6.sp),
                    Container(
                      width: 28.sp,
                      height: 28.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.04),
                      ),
                    ),
                  ],
                ),
              ),
              const DummyGridList(size: 4),
            ],
          ),
        );
      }

      if (newInController.products.isEmpty) {
        return const SizedBox.shrink();
      }

      final paged = newInController.pagedProducts;
      final totalPages = newInController.totalPages;
      final currentPage = newInController.currentPage.value;
      final canGoPrev = currentPage > 0;
      final canGoNext = currentPage < totalPages - 1;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: NEW IN | Sort By button | prev/next arrows
            Row(
              children: [
                const AppText(
                  text: "NEW IN",
                  fontFamily: "Clash Display Semibold",
                  color: blackColor,
                  fontSize: 18,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showSortSheet(context),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                      borderRadius: BorderRadius.circular(20.sp),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Sort By",
                          style: TextStyle(
                            fontFamily: "Clash Display Regular",
                            fontSize: 12.sp,
                            color: blackColor,
                          ),
                        ),
                        SizedBox(width: 4.sp),
                        Icon(Icons.tune, size: 14.sp, color: blackColor),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.sp),
                _NavCircleButton(
                  icon: Icons.chevron_left,
                  enabled: canGoPrev,
                  onTap: canGoPrev ? newInController.prevPage : null,
                ),
                SizedBox(width: 6.sp),
                _NavCircleButton(
                  icon: Icons.chevron_right,
                  enabled: canGoNext,
                  onTap: canGoNext ? newInController.nextPage : null,
                ),
              ],
            ),
            SizedBox(height: 8.sp),

            // Swipeable product grid
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (details) {
                const swipeThreshold = 100.0;
                final velocity = details.primaryVelocity ?? 0;

                if (velocity < -swipeThreshold) {
                  // Swiped LEFT → go forward (wrap to page 0 at the end)
                  if (canGoNext) {
                    newInController.nextPage();
                  } else {
                    newInController.goToPage(0);
                  }
                } else if (velocity > swipeThreshold) {
                  // Swiped RIGHT → go back (wrap to last page at the start)
                  if (canGoPrev) {
                    newInController.prevPage();
                  } else {
                    newInController.goToPage(totalPages - 1);
                  }
                }
              },
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.sp,
                  mainAxisSpacing: 8.sp,
                  childAspectRatio: 0.62,
                ),
                itemCount: paged.length,
                itemBuilder: (context, index) {
                  final product = paged[index];
                  final imageUrl = (product['imageUrls'] as List?)
                          ?.firstOrNull
                          ?.toString() ??
                      '';
                  final title = product['title'] as String? ?? '';
                  final brand =
                      (product['brand'] as Map?)?['name'] as String? ?? '';
                  final mrp = product['mrp'] as num? ?? 0;
                  final price =
                      (product['basePrice'] ?? product['mrp']) as num? ?? mrp;
                  final productId = product['id'];
                  return ProductGridCard(
                    imageUrl: imageUrl,
                    title: title,
                    brandName: brand,
                    price: price,
                    mrp: mrp,
                    nudges: (product['nudges'] as List<dynamic>?)
                            ?.map((e) =>
                                Nudge.fromJson(e as Map<String, dynamic>))
                            .toList() ??
                        [],
                    onTap: () {
                      if (productId == null) return;
                      Get.to(() => ProductDetailsScreenV2(
                            productId: productId is int
                                ? productId
                                : int.tryParse(productId.toString()) ?? 0,
                            type: "add",
                            brandName: brand,
                          ));
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16.sp),
          ],
        ),
      );
    });
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Obx(() {
        final current = newInController.sortMode.value;
        final options = [
          ('default', 'Default'),
          ('low_to_high', 'Price: Low to High'),
          ('high_to_low', 'Price: High to Low'),
          ('discount', 'Discount'),
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.sp),
                child: AppText(
                  text: "Sort By",
                  fontFamily: "Clash Display Semibold",
                  color: blackColor,
                  fontSize: 16,
                ),
              ),
              const Divider(height: 1),
              ...options.map((opt) {
                final isActive = current == opt.$1;
                return ListTile(
                  title: Text(
                    opt.$2,
                    style: TextStyle(
                      fontFamily: isActive
                          ? "Clash Display Semibold"
                          : "Clash Display Regular",
                      fontSize: 14.sp,
                      color: blackColor,
                    ),
                  ),
                  trailing: isActive
                      ? Icon(Icons.check, size: 18.sp, color: blackColor)
                      : null,
                  onTap: () {
                    newInController.applySort(opt.$1);
                    Navigator.pop(context);
                  },
                );
              }),
              SizedBox(height: 8.sp),
            ],
          ),
        );
      }),
    );
  }
}

class _SectionStrip extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final bool dark;
  final void Function(int productId) onProductTap;
  final VoidCallback onExploreAll;
  final int seed;
  final bool skipShuffle;
  final int collectionId;

  const _SectionStrip({
    super.key,
    required this.products,
    required this.dark,
    required this.onProductTap,
    required this.onExploreAll,
    required this.seed,
    required this.collectionId,
    this.skipShuffle = false,
  });

  @override
  State<_SectionStrip> createState() => _SectionStripState();
}

class _SectionStripState extends State<_SectionStrip> {
  late final Future<List<Map<String, dynamic>>> _luxeFuture;

  @override
  void initState() {
    super.initState();
    final gender = Get.find<HomeController>().homeGenderValue.value;

    _luxeFuture = Get.find<ProductController>()
        .fetchCollectionLuxeProducts(widget.collectionId, gender: gender);
  }

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
    final items = List<Map<String, dynamic>>.from(widget.products);

    final pick = items.take(7).toList();

    final totalProducts = pick.length;
    final showTwoRows = totalProducts > 4;

    final row1Products = showTwoRows ? pick.take(4).toList() : pick;
    final row2Products =
        showTwoRows ? pick.skip(4).toList() : <Map<String, dynamic>>[];

    final screenWidth = ScreenUtil().screenWidth;
    final cardWidth = (screenWidth * 0.38).clamp(140.0, 170.0);
    final rowHeight = (cardWidth * 1.65).clamp(220.0, 280.0);

    Widget buildCardSlot(Map<String, dynamic> product) {
      return SizedBox(
        width: cardWidth,
        height: rowHeight,
        child: _buildProductCard(product),
      );
    }

    Widget _buildViewAllButton() {
      return GestureDetector(
        onTap: widget.onExploreAll,
        child: Container(
          width: cardWidth,
          height: rowHeight / 2,
          decoration: BoxDecoration(
            color: widget.dark ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(16.sp),
            border: Border.all(
              color: widget.dark ? Colors.white : Colors.black,
              width: 2.sp,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(14.sp),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.dark ? Colors.white : Colors.black,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  size: 18.sp,
                  color: widget.dark ? Colors.black : Colors.white,
                ),
              ),
              SizedBox(height: 12.sp),
              Text(
                "VIEW ALL\nPRODUCTS",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Clash Display Semibold",
                  fontSize: 11.sp,
                  color: widget.dark ? Colors.white : Colors.black,
                  letterSpacing: 0.3,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1 — always 4 products
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < row1Products.length; i++) ...[
                    if (i != 0) SizedBox(width: 10.sp),
                    buildCardSlot(row1Products[i]),
                  ],
                  // If only 1 row, View All goes here at the end
                  if (!showTwoRows) ...[
                    SizedBox(width: 10.sp),
                    // buildViewAllSlot(),
                    _buildViewAllButton(),
                  ],
                ],
              ),
              if (showTwoRows) ...[
                SizedBox(height: 10.sp),
                // Row 2 — up to 3 products + View All card in 4th slot
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < row2Products.length; i++) ...[
                      if (i != 0) SizedBox(width: 10.sp),
                      buildCardSlot(row2Products[i]),
                    ],
                    SizedBox(width: row2Products.isNotEmpty ? 10.sp : 0),
                    // buildViewAllSlot(), // always 4th slot = under last of row 1
                    _buildViewAllButton(),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 16.sp),
        _buildLuxeSection(
          collectionId: widget.collectionId,
          dark: widget.dark,
          onExploreAll: widget.onExploreAll,
        ),
      ],
    );
  }

  /// Build LUXE section for this specific collection
  /// Fetches LUXE products using ?segment=luxury API filter
  Widget _buildLuxeSection({
    required int collectionId,
    required bool dark,
    required VoidCallback onExploreAll,
  }) {
    // Navigate to LUXE category page with full black experience
    void goToLuxePage() {
      final homeController = Get.find<HomeController>();
      Get.to(
        CategoryProductScreen(
          categoryName: 'LUXE',
          categoryId: 0,
          brandId: 0,
          genderType: homeController.homeGenderValue.value,
          collectionIds: [collectionId],
          genderName: homeController.genderText.value,
          type: 'luxe',
          screen: 'luxe',
          categoryList: [],
          title: 'LUXE',
          segment: 'luxury',
        ),
      );
    }

    Widget _buildViewAllButton() {
      return GestureDetector(
        onTap: goToLuxePage,
        child: Container(
          width: 240,
          height: 120,
          decoration: BoxDecoration(
            color: widget.dark ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(16.sp),
            border: Border.all(
              color: widget.dark ? Colors.white : Colors.black,
              width: 2.sp,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(14.sp),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.dark ? Colors.white : Colors.black,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  size: 18.sp,
                  color: widget.dark ? Colors.black : Colors.white,
                ),
              ),
              SizedBox(height: 12.sp),
              Text(
                "VIEW ALL\nPRODUCTS",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Clash Display Semibold",
                  fontSize: 11.sp,
                  color: widget.dark ? Colors.white : Colors.black,
                  letterSpacing: 0.3,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _luxeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final luxeProducts = snapshot.data!.take(8).toList();
        if (luxeProducts.isEmpty) return const SizedBox.shrink();

        // Match background to the collection's dark flag
        final bgColor = dark ? Colors.black : Colors.white;
        final textColor = dark ? Colors.white : Colors.black;

        return Container(
          color: bgColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LUXE Heading — tapping goes to LUXE category page
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                child: GestureDetector(
                  onTap: goToLuxePage,
                  child: Text(
                    'LUXE',
                    style: TextStyle(
                      fontSize: 18.sp,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          widget.dark ? Colors.white : Colors.black,
                      fontFamily: 'Clash Display Bold',
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              // LUXE Products Horizontal Scroll
              SizedBox(
                height: 200.sp,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.sp),
                  itemCount: luxeProducts.length + 1,
                  separatorBuilder: (_, __) => SizedBox(width: 10.sp),
                  itemBuilder: (context, index) {
                    // Last item — View All card (inverted colors vs bg)
                    // if (index == luxeProducts.length) {
                    //   // return GestureDetector(
                    //   //   onTap: goToLuxePage,
                    //   //   child: Container(
                    //   //     width: 150.sp,
                    //   //     decoration: BoxDecoration(
                    //   //       borderRadius: BorderRadius.circular(8.sp),
                    //   //       color: dark ? Colors.white : Colors.black,
                    //   //       border: Border.all(
                    //   //         color: dark ? Colors.white : Colors.black,
                    //   //         width: 1,
                    //   //       ),
                    //   //     ),
                    //   //     child: Center(
                    //   //       child: Column(
                    //   //         mainAxisAlignment: MainAxisAlignment.center,
                    //   //         children: [
                    //   //           Text(
                    //   //             'VIEW ALL',
                    //   //             style: TextStyle(
                    //   //               fontSize: 13.sp,
                    //   //               fontWeight: FontWeight.w700,
                    //   //               color: dark ? Colors.black : Colors.white,
                    //   //               letterSpacing: 1.0,
                    //   //             ),
                    //   //           ),
                    //   //           SizedBox(height: 6.sp),
                    //   //           Icon(
                    //   //             Icons.arrow_forward,
                    //   //             size: 18.sp,
                    //   //             color: dark ? Colors.black : Colors.white,
                    //   //           ),
                    //   //         ],
                    //   //       ),
                    //   //     ),
                    //   //   ),
                    //   // );
                    // }
                    if (index == luxeProducts.length) {
                      return SizedBox(
                        width: 150.sp,
                        child: Center(
                          child: _buildViewAllButton(),
                        ),
                      );
                    }

                    final product = luxeProducts[index];
                    return SizedBox(
                      width: 150.sp,
                      child: _buildProductCard(product),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.sp),
            ],
          ),
        );
      },
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

    String _formatPrice(num value) {
      final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      );
      return formatter.format(value);
    }

    String imageUrl = "";
    if (p['imageUrls'] is List && (p['imageUrls'] as List).isNotEmpty) {
      imageUrl = p['imageUrls'][0].toString();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = 6.sp;

        return PounceWrapper(
          onTap: () => widget.onProductTap(id),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.dark
                      ? const Color.fromARGB(255, 47, 47, 47)
                      : const Color.fromARGB(255, 243, 241, 241),
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Image section with flexible height
                      Expanded(
                        flex: 72,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.sp),
                          child: imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: ImageHelper.toWebP(imageUrl),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  maxHeightDiskCache: 400,
                                  maxWidthDiskCache: 400,
                                  memCacheHeight: 400,
                                  memCacheWidth: 400,
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: double.infinity,
                                    color: Colors.black.withOpacity(0.06),
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey.withOpacity(0.5),
                                      size: 40.sp,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  color: Colors.black.withOpacity(0.06),
                                ),
                        ),
                      ),
                      SizedBox(height: 4.sp),
                      // ✅ Content section with flexible height
                      Expanded(
                        flex: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "Clash Display Semibold",
                                fontSize: 10.sp,
                                color:
                                    widget.dark ? Colors.white : Colors.black,
                              ),
                            ),
                            if (brandName.isNotEmpty)
                              Text(
                                brandName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: "Clash Display",
                                  fontSize: 8.sp,
                                  color: widget.dark
                                      ? Colors.white.withOpacity(0.85)
                                      : Colors.black.withOpacity(0.7),
                                ),
                              ),
                            if (numPrice > 0)
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatPrice(numPrice), //idhar
                                        style: TextStyle(
                                          fontFamily: "Clash Display Semibold",
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: widget.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      if (numMrp != null &&
                                          numMrp > numPrice) ...[
                                        SizedBox(width: 4.sp),
                                        Text(
                                          "₹$numMrp",
                                          style: TextStyle(
                                            color: const Color(0xFF9CA3AF),
                                            fontSize: 10.sp,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationColor:
                                                const Color.fromARGB(
                                                    255, 118, 122, 128),
                                            fontFamily: "Clash Display Regular",
                                          ),
                                        ),
                                      ],
                                      if (discount != null && discount > 0) ...[
                                        SizedBox(width: 4.sp),
                                        Text(
                                          "$discount% OFF",
                                          style: TextStyle(
                                            fontSize: 8.sp,
                                            fontFamily: "Clash Display",
                                            fontWeight: FontWeight.w600,
                                            color: lightPurpleColor,
                                          ),
                                        ),
                                      ],
                                    ],
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
              if ((p['nudges'] as List?)?.isNotEmpty == true)
                Positioned(
                  top: 8.sp,
                  left: 8.sp,
                  child: NudgeBadgeRow(
                    nudges: (p['nudges'] as List<dynamic>)
                        .map((e) => Nudge.fromJson(e as Map<String, dynamic>))
                        .toList(),
                    maxVisible: 2,
                    isExpanded: true,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Section Video Banner ────────────────────────────────────────────────────

class _SectionVideoBanner extends StatefulWidget {
  final VideoPlayerController? controller;

  const _SectionVideoBanner({
    required this.controller,
  });

  @override
  State<_SectionVideoBanner> createState() => _SectionVideoBannerState();
}

class _SectionVideoBannerState extends State<_SectionVideoBanner>
    with WidgetsBindingObserver, RouteAware {
  bool _isRouteActive = true;
  Worker? _tabListener;
  late final HomeController _homeController;

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<HomeController>();
    WidgetsBinding.instance.addObserver(this);
    _tabListener = ever(_homeController.isHomeTabActive, (bool isActive) {
      if (widget.controller == null || !widget.controller!.value.isInitialized)
        return;
      if (isActive && _isRouteActive) {
        widget.controller!.play();
      } else {
        widget.controller!.pause();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _SectionVideoBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ctrl = widget.controller;
    if (ctrl != null &&
        ctrl.value.isInitialized &&
        _homeController.isHomeTabActive.value) {
      if (oldWidget.controller == null) {
        // First assignment: reset route state and play unconditionally.
        // didPushNext may have fired during initial splash→home navigation
        // before this widget existed, leaving _isRouteActive = false incorrectly.
        _isRouteActive = true;
        ctrl.play();
      } else if (_isRouteActive && !ctrl.value.isPlaying) {
        ctrl.play();
      }
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.pause();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
    precacheImage(const AssetImage('assets/images/lafetch_logo.png'), context);
  }

  @override
  void didPushNext() {
    _isRouteActive = false;
    widget.controller?.pause();
  }

  @override
  void didPopNext() {
    _isRouteActive = true;
    if (_homeController.isHomeTabActive.value) {
      widget.controller?.play();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.controller == null || !widget.controller!.value.isInitialized)
      return;
    if (state == AppLifecycleState.paused) {
      // Only pause when fully backgrounded, not on brief inactive states
      // (inactive fires for system overlays, notifications, etc.)
      widget.controller!.pause();
    } else if (state == AppLifecycleState.resumed) {
      // Always resume if home tab is active — _isRouteActive may be stale
      // after hot restart so we don't gate on it here.
      if (_homeController.isHomeTabActive.value) {
        _isRouteActive = true;
        widget.controller!.play();
      }
    }
  }

  @override
  void dispose() {
    _tabListener?.dispose();
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    // Use AspectRatio 3:1 to match the image banner carousel sizing —
    // consistent across all screen sizes, no fixed height pushing layout.
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(color: Color(0xFFEEEEEE)),
      );
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: VideoPlayer(ctrl),
    );
  }
}

class BannerVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double height;
  final double width;
  final ScrollController? scrollController;

  const BannerVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.height,
    required this.width,
    this.scrollController,
  });

  @override
  State<BannerVideoPlayer> createState() => _BannerVideoPlayerState();
}

class _BannerVideoPlayerState extends State<BannerVideoPlayer>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver, RouteAware {
  VideoPlayerController? _controller;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = true;
  bool _isVisible = true;
  bool _isRouteActive = true;

  final GlobalKey _videoKey = GlobalKey();
  final HomeController _homeController = Get.find<HomeController>();
  Worker? _tabListener;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Add WidgetsBindingObserver to listen for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // ✅ Listen for tab changes to pause/play video
    _tabListener = ever(_homeController.isHomeTabActive, (isActive) {
      if (!_isInitialized || _controller == null) return;
      if (isActive && _isVisible && _isRouteActive) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    });

    // Slight delay prevents multiple videos loading together
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _initializeVideo();
      }
    });

    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Subscribe to route observer for navigation detection
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  // ✅ Called when navigating away from this screen
  @override
  void didPushNext() {
    _isRouteActive = false;
    _controller?.pause();
  }

  // ✅ Called when returning to this screen
  @override
  void didPopNext() {
    _isRouteActive = true;
    if (_isVisible && _homeController.isHomeTabActive.value) {
      _controller?.play();
    }
  }

  // ---------------- VIDEO INIT ----------------

  Future<void> _initializeVideo() async {
    try {
      await configureAmbientAudioSession();
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      _controller = controller;

      _controller!
        ..setLooping(true)
        ..setVolume(0.0);

      // ✅ Only play if home tab is active
      if (_homeController.isHomeTabActive.value) {
        _controller!.play();
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint("❌ Video init error: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  // ---------------- VISIBILITY CHECK ----------------

  void _onScroll() {
    if (!_isInitialized || _controller == null || !mounted) return;

    final renderObject = _videoKey.currentContext?.findRenderObject();

    if (renderObject == null) return;

    final renderBox = renderObject as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    final videoBottom = position.dy + widget.height;
    final visibleThreshold = widget.height * 0.5;

    final isNowVisible =
        position.dy < screenHeight && videoBottom > visibleThreshold;

    if (isNowVisible != _isVisible) {
      _isVisible = isNowVisible;

      if (_isVisible) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    }
  }

  // ---------------- MUTE TOGGLE ----------------

  void _toggleMute() {
    if (!_isInitialized || _controller == null) return;

    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  // ---------------- APP LIFECYCLE HANDLING ----------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized || _controller == null) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Pause the video when the app is paused or inactive
      _controller!.pause();
    } else if (state == AppLifecycleState.resumed && _isVisible) {
      // Resume the video only if it's visible
      _controller!.play();
    }
  }

  // ---------------- DISPOSE ----------------

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // ✅ Unsubscribe from route observer
    _tabListener?.dispose(); // ✅ Dispose tab listener
    widget.scrollController?.removeListener(_onScroll);
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    _controller?.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_hasError) {
      return Container(
        height: widget.height,
        width: widget.width,
        color: Colors.black.withOpacity(0.04),
        child: const Center(
          child: Icon(Icons.videocam_off, size: 40, color: Colors.grey),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        height: widget.height,
        width: widget.width,
        color: Colors.black.withOpacity(0.04),
        child: const Center(
          child: LfLogoLoader(size: 32, showGlow: false),
        ),
      );
    }

    return SizedBox(
      key: _videoKey,
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: [
          /// VIDEO
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),

          /// MUTE BUTTON
          Positioned(
            right: 10.sp,
            bottom: 10.sp,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        ],
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
              padding: EdgeInsets.fromLTRB(16.sp, 12.sp, 16.sp, 24.sp),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.56,
                crossAxisSpacing: 12.sp,
                mainAxisSpacing: 16.sp,
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

                return PounceWrapper(
                  onTap: () {
                    if (pid == 0) return;
                    Get.to(
                      ProductDetailsScreenV2(
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
            borderRadius: BorderRadius.circular(12.sp),
            child: imageUrl != null && imageUrl!.trim().isNotEmpty
                ? CachedNetworkImage(
                    cacheManager: CacheManager(
                      Config("bannerProductsCache",
                          stalePeriod: const Duration(days: 15),
                          maxNrOfCacheObjects: 50), // ✅ Reduced from 100
                    ),
                    imageUrl: ImageHelper.toWebP(imageUrl!),
                    fit: BoxFit.fill,
                    // ✅ Add memory limits
                    maxHeightDiskCache: 600,
                    maxWidthDiskCache: 600,
                    memCacheHeight: 600,
                    memCacheWidth: 600,
                    errorWidget: (_, __, ___) =>
                        Image.asset(downloadImage, fit: BoxFit.fill),
                  )
                : Image.asset(dummyWishlistImage, fit: BoxFit.fill),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8.sp, 8.sp, 8.sp, 0),
          child: Text(
            brand.toUpperCase(),
            softWrap: true,
            style: const TextStyle(
              color: blackColor,
              fontSize: 15,
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8.sp, 4.sp, 8.sp, 0),
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
          padding: EdgeInsets.fromLTRB(8.sp, 6.sp, 8.sp, 0),
          child: Row(
            children: [
              if (mrp != null && mrp! > 0)
                Padding(
                  padding: EdgeInsets.only(right: 8.sp),
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

  const _ShopByCategorySection({
    required this.catalogController,
    required this.analytics,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    final gender = homeController.homeGenderValue.value;
    final cats = List<Map<String, dynamic>>.from(
      catalogController.catalogByGender[gender] ?? [],
    );

    // Loading guard — show shimmer while catalog data is being fetched
    if (catalogController.isCatalog.value == true) {
      return const _ShopByCategoryShimmer();
    }

    // Empty guard — render nothing when there are no categories
    if (cats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: statusBarColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Padding(
            padding: EdgeInsets.only(left: 16.sp, top: 12.sp, bottom: 12.sp),
            child: const AppText(
              text: "SHOP BY CATEGORY",
              fontFamily: "Clash Display Semibold",
              fontWeight: FontWeight.w400,
              color: blackColor,
              fontSize: 16,
            ),
          ),
          // Horizontal scrollable row of category cards — no scrollbar indicator
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding:
                  EdgeInsets.only(left: 16.sp, right: 16.sp, bottom: 12.sp),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cats
                    .map((catalog) => _CategoryCard(
                          catalog: catalog,
                          homeController: homeController,
                          catalogController: catalogController,
                          analytics: analytics,
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single tappable category card rendered inside [_ShopByCategorySection].
///
/// Displays the category image (via [CachedNetworkImage] with disk/memory
/// cache limits) and the category name in uppercase below it.  Tapping the
/// card calls [catalogController.getSubCategoryProducts] and then navigates
/// to [CategoryProductScreen] with the correct gender context.
class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> catalog;
  final HomeController homeController;
  final CatalogController catalogController;
  final FirebaseAnalytics analytics;

  const _CategoryCard({
    required this.catalog,
    required this.homeController,
    required this.catalogController,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final categoryId = catalog['id'];
    final categoryName = (catalog['name'] ?? 'Category').toString();
    final imageUrl = catalog['image']?.toString() ?? '';

    return GestureDetector(
      onTap: () async {
        await catalogController.getSubCategoryProducts(categoryId);

        Get.to(
          () => CategoryProductScreen(
            categoryName: categoryName,
            screen: 'category',
            genderName: homeController.genderText.value,
            categoryId: categoryId,
            brandId: 0,
            genderType: homeController.homeGenderValue.value,
            categoryList: const [],
            collectionIds: const [],
            title: '',
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category image container
            Container(
              width: 100.sp,
              height: 120.sp,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 235, 233, 233),
                borderRadius: BorderRadius.circular(16.sp),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.sp),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: ImageHelper.toWebP(imageUrl),
                        fit: BoxFit.cover,
                        maxWidthDiskCache: 300,
                        maxHeightDiskCache: 300,
                        memCacheWidth: 300,
                        memCacheHeight: 300,
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

            // Category name in uppercase
            SizedBox(
              width: 100.sp,
              child: AppText(
                text: (catalog['name'] ?? '').toString().toUpperCase(),
                color: blackColor,
                fontSize: 12.sp,
                maxLines: 2,
                textAlign: TextAlign.center,
                fontFamily: 'Clash Display',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A shimmer placeholder that matches the height and card dimensions of the
/// loaded [_ShopByCategorySection] row.
///
/// Shown while [CatalogController.isCatalog] is `true` (i.e. while the
/// category list is being fetched from the network).
class _ShopByCategoryShimmer extends StatelessWidget {
  const _ShopByCategoryShimmer();

  @override
  Widget build(BuildContext context) {
    // Total row height: image (120.sp) + gap (8.sp) + label area (~40.sp)
    final double rowHeight = 168.sp;

    return SizedBox(
      height: rowHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(left: 16.sp),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              children: List.generate(5, (index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100.sp,
                        height: 120.sp,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.sp),
                        ),
                      ),
                      SizedBox(height: 8.sp),
                      Container(
                        width: 80.sp,
                        height: 12.sp,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.sp),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays collection banners in a carousel.
///
/// Banners are sorted by [position] and grouped into "slides" based on [tile]:
///   tile == 1 → one full-width banner per slide
///   tile == 2 → two banners side-by-side per slide
///   tile == 3 → three banners side-by-side per slide
///
/// Consecutive banners with the same tile value fill one slide; when the slide
/// is full (or the tile value changes) a new slide begins.
/// Multiple slides are shown in a swipeable PageView with dot indicators.
class _StandaloneCollectionBanners extends StatefulWidget {
  final List<StandaloneCollectionBanner> banners;
  final void Function(String redirectUrl)? onBannerTap;
  final VoidCallback? onFallbackTap;

  const _StandaloneCollectionBanners({
    required this.banners,
    this.onBannerTap,
    this.onFallbackTap,
  });

  @override
  State<_StandaloneCollectionBanners> createState() =>
      _StandaloneCollectionBannersState();
}

class _StandaloneCollectionBannersState
    extends State<_StandaloneCollectionBanners> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    final slides = _buildSlides();
    if (slides.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  /// Groups sorted banners into carousel slides.
  List<List<StandaloneCollectionBanner>> _buildSlides() {
    final slides = <List<StandaloneCollectionBanner>>[];
    if (widget.banners.isEmpty) return slides;

    List<StandaloneCollectionBanner> current = [widget.banners.first];
    for (int i = 1; i < widget.banners.length; i++) {
      final b = widget.banners[i];
      if (b.tile == current.first.tile && current.length < b.tile) {
        current.add(b);
      } else {
        slides.add(current);
        current = [b];
      }
    }
    slides.add(current);
    return slides;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    final slides = _buildSlides();
    final screenWidth = MediaQuery.of(context).size.width;
    // Use the tile count of the first slide to determine height
    final firstTile = slides.first.first.tile.clamp(1, 3);
    final bannerHeight = firstTile == 1 ? 220.sp : 160.sp;
    final showDots = slides.length > 1;

    return Padding(
      padding: EdgeInsets.only(top: 8.sp, bottom: showDots ? 4.sp : 8.sp),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: bannerHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, slideIndex) {
                final slideBanners = slides[slideIndex];
                final tileCount = slideBanners.first.tile.clamp(1, 3);
                final gap = 6.sp;
                final totalGap = gap * (tileCount - 1);
                final itemWidth = (screenWidth - 32.sp - totalGap) / tileCount;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.sp),
                  child: Row(
                    children: List.generate(slideBanners.length, (i) {
                      final banner = slideBanners[i];
                      final isVideo = banner.isVideo(isMobile: true);
                      final mediaUrl = banner.getImageUrl(isMobile: true);

                      return Padding(
                        padding: EdgeInsets.only(
                            right: i < slideBanners.length - 1 ? gap : 0),
                        child: GestureDetector(
                          onTap: () {
                            final url = banner.redirectUrl.trim();
                            if (url.isNotEmpty) {
                              widget.onBannerTap?.call(url);
                            } else {
                              widget.onFallbackTap?.call();
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.sp),
                            child: SizedBox(
                              width: itemWidth,
                              height: bannerHeight,
                              child: isVideo
                                  ? _VideoBannerItem(
                                      videoUrl: mediaUrl,
                                      height: bannerHeight,
                                    )
                                  : _BannerItem(
                                      imageUrl: mediaUrl,
                                      height: bannerHeight,
                                    ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),

          // Dot indicators — only shown when there are multiple slides
          if (showDots) ...[
            SizedBox(height: 8.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 3.sp),
                  width: isActive ? 16.sp : 6.sp,
                  height: 6.sp,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.black
                        : Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(3.sp),
                  ),
                );
              }),
            ),
            SizedBox(height: 4.sp),
          ],
        ],
      ),
    );
  }
}

// Video Banner item widget
class _VideoBannerItem extends StatefulWidget {
  final String videoUrl;
  final double height;

  const _VideoBannerItem({
    required this.videoUrl,
    required this.height,
  });

  @override
  State<_VideoBannerItem> createState() => _VideoBannerItemState();
}

class _VideoBannerItemState extends State<_VideoBannerItem>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  // ✅ Keep video player alive to prevent re-initialization
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // ✅ Delayed initialization to prevent simultaneous video loads
    Future.delayed(
        Duration(milliseconds: 100 * _VideoBannerItemState._instanceCount++),
        () {
      if (mounted) {
        _initializeVideo();
      }
    });
  }

  // ✅ Track number of instances to stagger initialization
  static int _instanceCount = 0;

  Future<void> _initializeVideo() async {
    try {
      print("🎬 Initializing video: ${widget.videoUrl}");
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller!.initialize();
      if (mounted) {
        print(
            "✅ Video initialized: size=${_controller!.value.size}, duration=${_controller!.value.duration}");
        _controller!.setLooping(true);
        _controller!.setVolume(0); // Muted to prevent audio overload
        _controller!.play();
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print("❌ Video initialization error: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    if (_hasError) {
      return Container(
        width: double.infinity,
        height: widget.height,
        color: Colors.black.withOpacity(0.04),
        child: const Center(
          child: Icon(
            Icons.videocam_off,
            color: Colors.grey,
            size: 48,
          ),
        ),
      );
    }

    if (_isInitialized &&
        _controller != null &&
        _controller!.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: widget.height,
      color: Colors.black.withOpacity(0.04),
      child: const Center(
        child: LfLogoLoader(size: 32, showGlow: false),
      ),
    );
  }
}

// Banner item widget (non-clickable)
class _BannerItem extends StatelessWidget {
  final String imageUrl;
  final double height;

  const _BannerItem({
    required this.imageUrl,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return imageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: ImageHelper.toWebP(imageUrl),
            width: double.infinity,
            height: height,
            fit: BoxFit.fill,
            // ✅ Add memory limits for collection banners
            maxHeightDiskCache: 600,
            maxWidthDiskCache: 800,
            memCacheHeight: 600,
            memCacheWidth: 800,
            placeholder: (_, __) => Container(
              width: double.infinity,
              height: height,
              color: Colors.black.withOpacity(0.04),
              child: const Center(
                child: LfLogoLoader(size: 32, showGlow: false),
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
          );
  }
}

// ✅ Sortable Collection Section Widget
class _CollectionSection extends StatefulWidget {
  final int collectionId;
  final String title;
  final String subtitle;
  final bool dark;
  final List<Map<String, dynamic>> products;
  final List<StandaloneCollectionBanner> banners;
  final Function(int) onProductTap;
  final VoidCallback onTitleTap;
  final VoidCallback onExploreAll;
  final int seed;

  const _CollectionSection({
    required this.collectionId,
    required this.title,
    required this.subtitle,
    required this.dark,
    required this.products,
    required this.banners,
    required this.onProductTap,
    required this.onTitleTap,
    required this.onExploreAll,
    required this.seed,
  });

  @override
  State<_CollectionSection> createState() => _CollectionSectionState();
}

class _CollectionSectionState extends State<_CollectionSection> {
  String _sortBy = 'none';
  late List<Map<String, dynamic>> _displayProducts;

  @override
  void initState() {
    super.initState();
    _displayProducts = List.from(widget.products);
  }

  void _applySort(String sortType) {
    setState(() {
      _sortBy = sortType;
      _displayProducts = List<Map<String, dynamic>>.from(widget.products);

      if (sortType == 'price_low') {
        _displayProducts.sort((a, b) {
          final priceA = _getLowestPrice(a);
          final priceB = _getLowestPrice(b);
          return priceA.compareTo(priceB);
        });
        print("✅ Sorted LOW to HIGH");
      } else if (sortType == 'price_high') {
        _displayProducts.sort((a, b) {
          final priceA = _getLowestPrice(a);
          final priceB = _getLowestPrice(b);
          return priceB.compareTo(priceA);
        });
        print("✅ Sorted HIGH to LOW");
      } else if (sortType == 'discount') {
        _displayProducts.sort((a, b) {
          final discountA = _getMaxDiscount(a);
          final discountB = _getMaxDiscount(b);
          return discountB.compareTo(discountA);
        });
        print("✅ Sorted by DISCOUNT");
      }

      if (_displayProducts.isNotEmpty) {
        print(
            "   First product: ${_displayProducts.first['title'] ?? _displayProducts.first['name']} - ₹${_getLowestPrice(_displayProducts.first).toInt()}");
      }
    });
  }

  double _getLowestPrice(Map<String, dynamic> product) {
    // Use same logic as _SectionStrip.resolvePricing
    final rawPrice = product['displayPrice'] ??
        product['basePrice'] ??
        product['price'] ??
        product['netAmount'] ??
        product['msp'] ??
        0;
    if (rawPrice is num && rawPrice > 0) {
      return rawPrice.toDouble();
    }
    return double.tryParse(rawPrice?.toString() ?? '0') ?? 0;
  }

  double _getMaxDiscount(Map<String, dynamic> product) {
    // Get price
    final rawPrice = product['displayPrice'] ??
        product['basePrice'] ??
        product['price'] ??
        product['netAmount'] ??
        product['msp'] ??
        0;
    double price = 0;
    if (rawPrice is num && rawPrice > 0) {
      price = rawPrice.toDouble();
    } else {
      price = double.tryParse(rawPrice?.toString() ?? '0') ?? 0;
    }

    // Get MRP
    final rawMrp = product['displayMrp'] ??
        product['mrp'] ??
        product['manufacturingAmount'];
    double mrp = 0;
    if (rawMrp is num && rawMrp > 0) {
      mrp = rawMrp.toDouble();
    } else {
      mrp = double.tryParse(rawMrp?.toString() ?? '0') ?? 0;
    }

    // Use discountPercent if available
    final discountPercent = product['discountPercent'];
    if (discountPercent is num && discountPercent > 0) {
      return discountPercent.toDouble();
    }

    // Calculate discount
    if (mrp > 0 && price < mrp) {
      return ((mrp - price) / mrp) * 100;
    }
    return 0;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.sp)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort By',
                style: TextStyle(
                  fontFamily: "Clash Display Semibold",
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.sp),
              _sortOption('Price: Low to High', 'price_low'),
              _sortOption('Price: High to Low', 'price_high'),
              _sortOption('Discount', 'discount'),
              SizedBox(height: 8.sp),
            ],
          ),
        );
      },
    );
  }

  Widget _sortOption(String label, String value) {
    final isSelected = _sortBy == value;
    return InkWell(
      onTap: () {
        print("🔘 Sort option tapped: $value for ${widget.title}");
        _applySort(value);
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 16.sp),
        margin: EdgeInsets.only(bottom: 8.sp),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(12.sp),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: "Clash Display",
            fontSize: 14.sp,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        "🏗️ Building ${widget.title} - sortBy: $_sortBy, products: ${_displayProducts.length}");
    if (_displayProducts.isNotEmpty) {
      print(
          "   First: ${_displayProducts.first['title'] ?? _displayProducts.first['name']} - ₹${_getLowestPrice(_displayProducts.first).toInt()}");
    }
    return Container(
      color: widget.dark ? Colors.black : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and Sort By button
          Padding(
            padding: EdgeInsets.only(
                left: 16.sp,
                right: 16.sp,
                top: 12.sp, // ✅ Reduced from 12.sp to minimize whitespace
                bottom: 10.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Clickable title
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.onTitleTap,
                        child: Text(
                          widget.title.toUpperCase(),
                          textAlign: TextAlign.left,
                          softWrap: true,
                          style: TextStyle(
                            fontFamily: "Clash Display Semibold",
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                widget.dark ? Colors.white : Colors.black,
                            fontSize: 18.sp,
                            color: widget.dark ? Colors.white : Colors.black,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                    // Sort By button - outline style
                    GestureDetector(
                      onTap: _showSortOptions,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.sp, vertical: 6.sp),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12.sp),
                          border: Border.all(
                            color: widget.dark ? Colors.white : Colors.black,
                            width: 1.5.sp,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sort,
                              size: 14.sp,
                              color: widget.dark ? Colors.white : Colors.black,
                            ),
                            SizedBox(width: 4.sp),
                            Text(
                              'Sort',
                              style: TextStyle(
                                fontFamily: "Clash Display",
                                fontSize: 12.sp,
                                color:
                                    widget.dark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.subtitle.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 6.sp),
                    child: Text(
                      widget.subtitle,
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: widget.dark
                            ? Colors.white.withOpacity(0.85)
                            : Colors.black.withOpacity(0.75),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Banners
          if (widget.banners.isNotEmpty)
            _StandaloneCollectionBanners(
              banners: widget.banners,
              onBannerTap: (redirectUrl) {
                // redirectUrl is non-empty — navigate to it via the product view
                // For now open the collection view as a sensible default
                widget.onTitleTap();
              },
              onFallbackTap: widget.onTitleTap,
            ),

          // Products
          if (_displayProducts.isNotEmpty)
            _SectionStrip(
              key: ValueKey('${widget.collectionId}_$_sortBy'),
              products: _displayProducts,
              dark: widget.dark,
              onProductTap: widget.onProductTap,
              onExploreAll: widget.onExploreAll,
              seed: widget.seed,
              collectionId: widget.collectionId,
              skipShuffle: _sortBy != 'none',
            ),

          // ✅ Consistent bottom padding for all collections
          SizedBox(height: 12.sp),
        ],
      ),
    );
  }
}

class _FeaturedBrandsRow extends StatefulWidget {
  final HomeController homeController;
  final BrandController brandController;
  final FirebaseAnalytics analytics;
  final VoidCallback onPressedViewAll;
  final List<dynamic> brands;

  const _FeaturedBrandsRow({
    required this.homeController,
    required this.brandController,
    required this.analytics,
    required this.onPressedViewAll,
    required this.brands,
  });

  @override
  State<_FeaturedBrandsRow> createState() => _FeaturedBrandsRowState();
}

class _FeaturedBrandsRowState extends State<_FeaturedBrandsRow> {
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;
  bool _isForward = true;
  bool _userScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      // if (!_scrollController.hasClients) return;
      if (!_scrollController.hasClients || _userScrolling) return;

      final max = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;

      if (_isForward) {
        if (current >= max) {
          _isForward = false;
        } else {
          _scrollController.jumpTo(current + 1.5);
        }
      } else {
        if (current <= 0) {
          _isForward = true;
        } else {
          _scrollController.jumpTo(current - 1.5);
        }
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.sp, bottom: 12.sp),
      child: Column(
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
                    widget.onPressedViewAll();
                    await widget.analytics.logEvent(
                      name: 'homepage_featurebrandviewAll',
                      parameters: {'page_name': 'homepage_featurebrandviewAll'},
                    );
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 2.sp, right: 16.sp, left: 20.sp),
                    child: SvgPicture.asset(
                      arrowViewAllImage,
                      height: 12.sp,
                      width: 8.sp,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.sp),
          SizedBox(
            height: 86.sp,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification &&
                    notification.dragDetails != null) {
                  _userScrolling = true;
                } else if (notification is ScrollEndNotification) {
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      _userScrolling = false;
                    }
                  });
                }
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.brands.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (ctx, index) {
                  final brand = widget.brands[index];
                  final logo = (brand["logo"] ?? "").toString().trim();
                  final name = (brand["name"] ?? "").toString().trim();
                  final bgImage =
                      (brand["background_image"] ?? "").toString().trim();

                  return GestureDetector(
                    onTap: () async {
                      widget.brandController.brandbackground.value = bgImage;
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
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color.fromARGB(255, 165, 165, 166),
                                width: 1.sp,
                              ),
                            ),
                            child: ClipOval(
                              child: logo.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: ImageHelper.toWebP(logo),
                                      height: 64.sp,
                                      width: 64.sp,
                                      fit: BoxFit.fill,
                                      maxHeightDiskCache: 150,
                                      maxWidthDiskCache: 150,
                                      memCacheHeight: 150,
                                      memCacheWidth: 150,
                                      fadeInDuration:
                                          const Duration(milliseconds: 300),
                                      placeholder: (_, __) => Container(
                                        color: Colors.black.withOpacity(0.05),
                                      ),
                                      errorWidget: (_, __, ___) => Image.asset(
                                        downloadImage,
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  : Image.asset(
                                      dummyWishlistImage,
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),
                          SizedBox(height: 6.sp),
                          SizedBox(
                            width: 64.sp,
                            child: Text(
                              name.isNotEmpty ? name : 'Unnamed',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Clash Display Regular",
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
          ),
        ],
      ),
    );
  }
}

// ✅ Custom Announcement Marquee with icons and text
class _AnnouncementMarquee extends StatefulWidget {
  final List<Map<String, dynamic>> announcements;

  const _AnnouncementMarquee({required this.announcements});

  @override
  State<_AnnouncementMarquee> createState() => _AnnouncementMarqueeState();
}

class _AnnouncementMarqueeState extends State<_AnnouncementMarquee> {
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollPosition += 1.0; // Scroll speed

      // Reset to start for seamless loop
      if (_scrollController.position.maxScrollExtent > 0 &&
          _scrollPosition >= _scrollController.position.maxScrollExtent) {
        _scrollPosition = 0;
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(_scrollPosition);
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Duplicate announcements for seamless looping
    final items = [...widget.announcements, ...widget.announcements];

    return Container(
      height: 30.sp,
      color: const Color(0xff2D2D2E),
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final announcement = items[index];
          final text = announcement['text']?.toString() ?? '';
          final iconUrl = announcement['iconUrl']?.toString() ?? '';

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.sp),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Separator
                if (index > 0)
                  Padding(
                    padding: EdgeInsets.only(right: 12.sp),
                    child: Text(
                      '|',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12.sp,
                        fontFamily: "Clash Display Regular",
                      ),
                    ),
                  ),
                // Icon
                if (iconUrl.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(right: 6.sp),
                    child: CachedNetworkImage(
                      imageUrl: ImageHelper.toWebP(iconUrl),
                      height: 16.sp,
                      width: 16.sp,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      placeholder: (_, __) => SizedBox(
                        height: 16.sp,
                        width: 16.sp,
                      ),
                    ),
                  ),
                // Text
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontFamily: "Clash Display Regular",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ================================================================
/// ✅ NEWLY LAUNCHED BRANDS SECTION
/// ================================================================
class _NewlyLaunchedBrandsSection extends StatelessWidget {
  final BrandController brandController;
  final FirebaseAnalytics analytics;

  const _NewlyLaunchedBrandsSection({
    required this.brandController,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading state
      if (brandController.isLoadingNewlyLaunched.value) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skeleton header
              Padding(
                padding: EdgeInsets.only(bottom: 12.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14.sp,
                      width: 50.sp,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(4.sp),
                      ),
                    ),
                    SizedBox(height: 6.sp),
                    Container(
                      height: 20.sp,
                      width: 150.sp,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(4.sp),
                      ),
                    ),
                  ],
                ),
              ),
              // Skeleton brand cards
              SizedBox(
                height: 120.sp,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12.sp),
                      child: Container(
                        width: 100.sp,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }

      // Show empty state if no brands
      if (brandController.newlyLaunchedBrands.isEmpty) {
        return const SizedBox.shrink();
      }

      final brands = brandController.newlyLaunchedBrands;
      final currentPage = brandController.newlyLaunchedPage.value;
      final totalPages = brandController.newlyLaunchedTotalPages.value;
      final canGoPrev = currentPage > 1;
      final canGoNext = currentPage < totalPages;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Subtitle + Title + Navigation
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle: "JUST IN"
                const AppText(
                  text: "JUST IN",
                  fontFamily: "Clash Display Regular",
                  color: const Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                // SizedBox(height: 4.sp),
                // Title: "NEWLY LAUNCHED BRANDS"
                Row(
                  children: [
                    const AppText(
                      text: "NEWLY LAUNCHED BRANDS",
                      fontFamily: "Clash Display Semibold",
                      color: blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    const Spacer(),
                    // Navigation buttons
                    _NavCircleButton(
                      icon: Icons.chevron_left,
                      enabled: canGoPrev,
                      onTap: canGoPrev
                          ? () => brandController.prevNewlyLaunchedPage()
                          : null,
                    ),
                    SizedBox(width: 6.sp),
                    _NavCircleButton(
                      icon: Icons.chevron_right,
                      enabled: canGoNext,
                      onTap: canGoNext
                          ? () => brandController.nextNewlyLaunchedPage()
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.sp),

            // Horizontal scrollable brand carousel
            SizedBox(
              height: 140.sp,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  final brand = brands[index];
                  final brandId = brand['id'] is int
                      ? brand['id'] as int
                      : int.tryParse(brand['id']?.toString() ?? '') ?? 0;
                  final brandName = brand['name']?.toString() ?? '';
                  final logoUrl = brand['logo']?.toString() ?? '';

                  return Padding(
                    padding: EdgeInsets.only(right: 12.sp),
                    child: GestureDetector(
                      onTap: () async {
                        // Log analytics event
                        await analytics.logEvent(
                          name: 'newly_launched_brand_tap',
                          parameters: {
                            'brand_id': brandId,
                            'brand_name': brandName,
                            'page': currentPage,
                          },
                        );

                        // Navigate to brand details
                        Get.to(
                          () => AllBrandScreen(
                            id: brandId,
                            screen: 'brand',
                            slug: '',
                          ),
                        );
                      },
                      child: Container(
                        width: 100.sp,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.sp),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Brand logo
                            if (logoUrl.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.all(8.sp),
                                child: CachedNetworkImage(
                                  imageUrl: ImageHelper.toWebP(logoUrl),
                                  height: 60.sp,
                                  width: 80.sp,
                                  fit: BoxFit.contain,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) {
                                    return Container(
                                      height: 60.sp,
                                      width: 80.sp,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.04),
                                        borderRadius:
                                            BorderRadius.circular(4.sp),
                                      ),
                                    );
                                  },
                                  errorWidget: (context, url, error) {
                                    return Container(
                                      height: 60.sp,
                                      width: 80.sp,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.04),
                                        borderRadius:
                                            BorderRadius.circular(4.sp),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 24.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            else
                              Container(
                                height: 60.sp,
                                width: 80.sp,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(4.sp),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.store,
                                    size: 24.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            SizedBox(height: 6.sp),
                            // Brand name
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.sp),
                              child: Text(
                                brandName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Clash Display Regular",
                                  fontSize: 10.sp,
                                  color: blackColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.sp),
          ],
        ),
      );
    });
  }
}
