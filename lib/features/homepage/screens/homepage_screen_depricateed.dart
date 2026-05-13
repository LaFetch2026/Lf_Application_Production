import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../../common/widget/appbar/home_appbar.dart';
import '../../../common/widget/cards/product_card.dart';
import '../../../common/widget/other/lf_loader_widget.dart';
import '../../../common/widget/other/pounce_wrapper.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/search_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/new_in_controller.dart';
import '../../../controllers/brand_controller.dart';
import '../../../controllers/catalog_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/constant/constants.dart';
import '../../../core/utils/image_helper.dart';
import '../../../models/collection_extensions.dart';
import '../../../models/collection_model.dart';
import '../../../models/nudge_model.dart';
import '../../../screens/Brands/allbrandscreen.dart';
import '../../../screens/Brands/categoryproduct.dart';
import '../../../screens/catalog/productlist/pdp_v2/product_details_screen_v2.dart';
import '../../../screens/cartscreen.dart';
import '../../../screens/loginscreen.dart';
import '../../../screens/searchscreen.dart';
import '../../../screens/wishlistscreen.dart';
import '../../../screens/accountscreen.dart';
import '../../../utils/audio_session_helper.dart';
import '../widgets/new_in_section.dart';
import '../widgets/newly_launched_brands_section.dart';
import '../widgets/shop_by_category_section.dart';
import '../widgets/collection_section_widget.dart';
import '../models/collection_item_model.dart';
import '../models/product_card_model.dart';

/// New modular HomepageScreen
/// Uses feature-first structure with isolated widgets
/// Each section is wrapped in RepaintBoundary for performance
/// Error boundaries provide fallback to legacy implementation
class HomepageScreen extends StatefulWidget {
  final VoidCallback? onPressed;

  const HomepageScreen({
    super.key,
    this.onPressed,
  });

  @override
  State<HomepageScreen> createState() => HomepageScreenState();
}

// Added AutomaticKeepAliveClientMixin and TickerProviderStateMixin for tab persistence and animations
class HomepageScreenState extends State<HomepageScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Using Get.put to register controllers
  final homeController = Get.put(HomeController());
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final searchController = Get.put(SearchScreenController());
  final cartController = Get.put(CartController());
  final brandController = Get.put(BrandController());
  final catalogController = Get.put(CatalogController());
  final profileController = Get.put(ProfileController());
  final newInController = Get.put(NewInController());

  TabController? _genderTabController; // Declared as nullable

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

  // Pagination variables
  int _currentCollectionPage = 1;
  bool _hasMoreCollections = true;
  bool _isLoadingMoreCollections = false;

  Timer? _scrollEndTimer;

  // Keep screen alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Add scroll listener for pagination
    homeController.discountScreenController.addListener(_onScroll);

    // Apply UI styles and fetch data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Reset scroll state after frame
      homeController.isScrolling.value = false;

      try {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: whiteColor,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: whiteColor,
          systemNavigationBarIconBrightness: Brightness.dark,
        ));

        // Fetch gender tabs FIRST
        await homeController.getGenderTabs();
        if (!mounted) return;

        // Check if user is guest
        final prefs = await SharedPreferences.getInstance();
        if (!mounted) return;

        isGuest = prefs.getBool('skip') ?? false;

        // Load saved gender preference or use first tab from API
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
          debugPrint("⚠️ No gender tabs from API, using default");
        }

        // Initialize TabController for animated gender tabs
        if (!mounted) return;
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
        if (!mounted) return;

        final currentGender =
            int.tryParse(homeController.homeGenderValue.value.toString()) ?? 1;

        // Skip loading if data already exists
        final bool hasExistingData = homeController.banner1List.isNotEmpty ||
            homeController.banner2List.isNotEmpty ||
            productController.homeProductList.isNotEmpty;

        // Initialize video controller for active tab only
        final currentGenderId =
            int.tryParse(homeController.homeGenderValue.value.toString()) ?? 1;
        if (_sectionVideoUrls.containsKey(currentGenderId) &&
            !_sectionVideoControllers.containsKey(currentGenderId)) {
          _initSectionVideoController(
              currentGenderId, _sectionVideoUrls[currentGenderId]!);
        }

        if (_dataLoaded && hasExistingData && !_isInitialLoad) {
          debugPrint("✅ Data already loaded, skipping API calls");
          if (newInController.products.isEmpty) {
            newInController.fetchProducts(currentGender);
          } else {
            newInController.isLoading.value = false;
          }
          return;
        }

        // Reset any stuck loading states
        homeController.isBanner1.value = false;

        // Force refresh on initial load
        final bool isFirstLoad = _isInitialLoad;

        // Load home data first, then remaining data
        await homeController.initializeHomeData(currentGender,
            forceRefresh: isFirstLoad);

        if (!mounted) return;

        await Future.wait([
          catalogController.getCatalogData(currentGender,
              forceRefresh: isFirstLoad),
          productController.getHomeProduct(currentGender,
              forceRefresh: isFirstLoad),
          productController.getCollectionBanners(forceRefresh: isFirstLoad),
          productController.fetchLuxuryProducts(forceRefresh: isFirstLoad),
          productController.fetchLuxeProducts(forceRefresh: isFirstLoad),
          brandController.getBrandData("featured", currentGender),
          brandController.getNewlyLaunchedBrands(gender: currentGender),
        ]);

        if (!mounted) return;

        // Fire NEW IN fetch after critical data
        newInController.fetchProducts(currentGender, forceRefresh: isFirstLoad);

        // Mark data as loaded
        _dataLoaded = true;

        // Force update after all data is loaded
        brandController.update();

        // One-time setup calls
        if (_isInitialLoad) {
          homeController.getDeviceName();
          _isInitialLoad = false;
        }

        // Fix hot reload visibility issue
        if (catalogController.catalogByGender[currentGender]?.isNotEmpty ==
            true) {
          catalogController.update();
        }
      } catch (e, stackTrace) {
        debugPrint("❌ Error during home screen initialization: $e");
        debugPrint("Stack trace: $stackTrace");
        if (mounted) {
          getSnackBar("Failed to load some data. Please try refreshing.");
        }
      }
    });
  }

  // Helper to initialize data for a given gender.
  // It checks if data is already loaded to avoid redundant fetches.
  Future<void> _initializeData([int? genderId]) async {
    final currentGenderId = genderId ??
        int.tryParse(homeController.homeGenderValue.value.toString()) ??
        1;

    if (currentGenderId == 0) {
      debugPrint(
          "HomepageScreen: Gender ID is invalid, cannot initialize data.");
      return;
    }

    // Check if data is already loaded for this gender
    if (!homeController.isGenderDataLoaded(currentGenderId)) {
      try {
        // Use Future.wait for concurrent loading of initial data for the current gender
        await Future.wait([
          homeController.initializeHomeData(currentGenderId,
              forceRefresh: false),
          catalogController.getCatalogData(currentGenderId,
              forceRefresh: false),
          brandController.getBrandData("featured", currentGenderId),
        ]);
      } catch (e) {
        debugPrint(
            "HomepageScreen: Error initializing home data for gender $currentGenderId: $e");
        // Optionally, show a user-facing error message.
      }
    }

    // Load NEW IN products specifically for this gender, independent of other data
    try {
      // Ensure newInController fetches products for the current genderId.
      // It's assumed newInController handles its own loading state and reactivity.
      newInController.fetchProducts(currentGenderId, forceRefresh: false);
    } catch (e) {
      debugPrint(
          "HomepageScreen: Error fetching new in products for gender $currentGenderId: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _scrollEndTimer?.cancel();
    _pageController.dispose();
    _genderTabController?.removeListener(_handleTabSelection);
    _genderTabController?.dispose();
    homeController.discountScreenController.removeListener(_onScroll);
    for (final c in _sectionVideoControllers.values) {
      c.dispose();
    }
    _sectionVideoControllers.clear();
    super.dispose();
  }

  // Scroll listener for pagination
  void _onScroll() {
    if (!homeController.discountScreenController.hasClients) return;

    final scrollController = homeController.discountScreenController;
    final scrollPosition = scrollController.position;

    // Trigger when scrolled 80% to the bottom
    if (scrollPosition.pixels >= scrollPosition.maxScrollExtent * 0.8) {
      _loadMoreCollections();
    }
  }

  // Initialize TabController for gender tabs
  void _initGenderTabController(int initialIndex) {
    if (!mounted) return;

    _genderTabController?.dispose();
    if (homeController.genderTabs.isNotEmpty) {
      _genderTabController = TabController(
        length: homeController.genderTabs.length,
        vsync: this,
        initialIndex:
            initialIndex.clamp(0, homeController.genderTabs.length - 1),
      );
      _genderTabController!.addListener(_handleTabSelection);
      if (mounted) setState(() {});
    }
  }

  // Initialize section video controller
  void _initSectionVideoController(int genderId, String videoUrl) {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      controller.initialize().then((_) {
        if (mounted) {
          setState(() {});
          controller.setLooping(true);
          controller.play();
        }
      });
      _sectionVideoControllers[genderId] = controller;
    } catch (e) {
      debugPrint(
          "Error initializing video controller for gender $genderId: $e");
    }
  }

  // Check user connection
  static Future<bool> checkUserConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      getSnackBar("Please turn on internet");
      return false;
    }
  }

  // Show snackbar message
  static void getSnackBar(String message) {
    Get.snackbar(
      "",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Load more collections
  Future<void> _loadMoreCollections() async {
    if (_isLoadingMoreCollections || !_hasMoreCollections) return;

    if (!mounted) return;

    setState(() {
      _isLoadingMoreCollections = true;
    });

    try {
      _currentCollectionPage++;
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      setState(() {
        _isLoadingMoreCollections = false;
      });
    } catch (e) {
      debugPrint("Error loading more collections: $e");
      if (!mounted) return;

      setState(() {
        _isLoadingMoreCollections = false;
      });
    }
  }

  // Force refresh data
  Future<void> forceRefreshData() async {
    setState(() => _isRefreshing = true);
    try {
      debugPrint("🔄 Force refresh triggered");

      final currentGender =
          int.tryParse(homeController.homeGenderValue.value.toString()) ?? 1;

      // Clear loaded tracking to allow fresh API calls
      homeController.clearLoadedGenders();
      productController.clearLoadedTracking();
      catalogController.clearLoadedTracking();
      brandController.clearLoadedTracking();
      newInController.clearCache();

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

  // Static method to clear all cached data (call on logout)
  static void clearCache() {
    debugPrint("🗑️ Clearing HomeScreen cache on logout");
    _isInitialLoad = true;
    _dataLoaded = false;

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
      debugPrint("⚠️ Could not clear controller tracking: $e");
    }
  }

  // Switch section video controller on tab change
  void _switchSectionVideoController(int newGenderId) {
    for (final c in _sectionVideoControllers.values) {
      c.dispose();
    }
    _sectionVideoControllers.clear();

    if (_sectionVideoUrls.containsKey(newGenderId)) {
      _initSectionVideoController(newGenderId, _sectionVideoUrls[newGenderId]!);
    }
  }

  // Get current banner list based on gender
  List<dynamic> _currentBannerList() {
    final currentGender =
        int.tryParse(homeController.homeGenderValue.value.toString()) ?? 1;
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

    // Filter to return ONLY banners with mobileImage
    final filtered = bannerList.where((item) {
      final mobileImage = (item as Map?)?["mobileImage"]?.toString() ?? '';
      return mobileImage.isNotEmpty;
    }).toList();

    return filtered;
  }

  // Check if URL is a video
  bool isVideoUrl(String url) {
    return url.toLowerCase().endsWith('.mp4') ||
        url.toLowerCase().endsWith('.mov') ||
        url.toLowerCase().endsWith('.avi');
  }

  // Get preference value for location
  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble('latitude') != null) {
      productController.lat.value = prefs.getDouble('latitude')!;
      productController.lng.value = prefs.getDouble('longitude')!;
      cartController.lat.value = prefs.getDouble('latitude')!;
      cartController.lng.value = prefs.getDouble('longitude')!;
    }
  }

  // Determine position for geo-location
  determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint("Location not enable");
      getPrefrenceValue();
    } else {
      setState(() {});
      Position position = await Geolocator.getCurrentPosition();
      productController.lat.value = position.latitude;
      productController.lng.value = position.longitude;
      final prefs = await SharedPreferences.getInstance();
      prefs.setDouble("latitude", productController.lat.value);
      prefs.setDouble("longitude", productController.lng.value);
      debugPrint("Location enable ${position.latitude}");
    }
  }

  // Handler for tab selection changes. Updates the selected gender and re-initializes data.
  void _handleTabSelection() {
    if (_genderTabController != null &&
        !_genderTabController!.indexIsChanging) {
      final selectedTabIndex = _genderTabController!.index;
      // Ensure the tab index is valid before accessing genderTabs
      if (selectedTabIndex >= 0 &&
          selectedTabIndex < homeController.genderTabs.length) {
        final selectedTab = homeController.genderTabs[selectedTabIndex];
        final newGenderId = selectedTab['id']?.toString();

        if (newGenderId != null && newGenderId.isNotEmpty) {
          // Update the global gender value and re-initialize data for the new gender
          final genderIdInt = int.tryParse(newGenderId) ?? 0;
          final currentGenderValue =
              int.tryParse(homeController.homeGenderValue.value.toString()) ??
                  0;
          if (currentGenderValue != genderIdInt) {
            homeController.homeGenderValue.value = genderIdInt;
            _initializeData(genderIdInt);
            _switchSectionVideoController(genderIdInt);
          }
        } else {
          debugPrint(
              "HomepageScreen: Selected tab has invalid or empty gender ID at index $selectedTabIndex.");
        }
      } else {
        debugPrint(
            "HomepageScreen: Tab index out of bounds: $selectedTabIndex");
      }
    }
  }

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
                          productController.categoryFilter.value = int.tryParse(
                                  homeController.homeGenderValue.value
                                      .toString()) ??
                              1;
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
                        Get.offAll(() => const LoginScreen(
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
                  // Gender tabs (TabBar)
                  // Wrapped in Obx to react to changes in homeController.genderTabs (e.g., if loaded asynchronously)
                  Obx(() {
                    final tabs = homeController.genderTabs;

                    // If no tabs are available, show a message.
                    if (tabs.isEmpty) {
                      return Container(
                        height: 50.sp,
                        padding: EdgeInsets.symmetric(horizontal: 16.sp),
                        alignment: Alignment.center,
                        child: const Text("No categories available."),
                      );
                    }

                    // If the TabController is not yet initialized (e.g., tabs just became available), show a loader.
                    if (_genderTabController == null) {
                      return Container(
                        height: 50.sp,
                        padding: EdgeInsets.symmetric(horizontal: 16.sp),
                        alignment: Alignment.center,
                        child:
                            const CircularProgressIndicator(), // Loading indicator while controller is being set up
                      );
                    }

                    // If controller is ready and tabs exist, build the TabBar
                    return Container(
                      height: 50.sp,
                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                      child: TabBar(
                        controller:
                            _genderTabController, // Use the initialized controller
                        isScrollable: tabs.length >
                            3, // Enable scrolling if more than 3 tabs
                        tabAlignment: tabs.length > 3
                            ? TabAlignment.start
                            : TabAlignment.fill, // Align tabs
                        indicatorColor:
                            homeAppBarColor, // Styling for the active tab indicator
                        indicatorWeight: 2.sp,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: homeAppBarColor,
                        unselectedLabelColor: searchTextColor,
                        dividerColor: Colors
                            .transparent, // Remove the default divider line
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
                        tabs: tabs.map((tab) {
                          final String genderName =
                              tab['name']?.toString().toUpperCase() ??
                                  'UNKNOWN';
                          return Tab(text: genderName);
                        }).toList(),
                      ),
                    );
                  }),
                  // Main content area, managed by TabBarView
                  Expanded(
                    child: Obx(() {
                      // Ensure tabs and controller are ready before building TabBarView
                      if (homeController.genderTabs.isEmpty ||
                          _genderTabController == null) {
                        return const Center(
                            child:
                                CircularProgressIndicator()); // Loading indicator
                      }

                      return TabBarView(
                        controller: _genderTabController,
                        // physics: const NeverScrollableScrollPhysics(), // Uncomment if you want to disable swipe gestures for tabs
                        children: homeController.genderTabs.map((tab) {
                          final genderId = tab['id']?.toString();
                          // Each child of TabBarView corresponds to a tab.
                          // Render content for this specific gender.
                          if (genderId == null || genderId.isEmpty) {
                            debugPrint(
                                "HomepageScreen: Invalid gender ID found for a tab.");
                            return const Center(
                                child: Text("Invalid Category"));
                          }
                          // Use a FutureBuilder to ensure data is loaded for this tab's content before rendering
                          return _buildTabContent(genderId);
                        }).toList(),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build banner carousel section
  Widget _buildBannerCarousel(String genderId) {
    final currentBannerList = _currentBannerList();

    if (currentBannerList.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 229.sp,
      child: PageView.builder(
        controller: _pageController,
        itemCount: currentBannerList.length,
        itemBuilder: (context, index) {
          final item = currentBannerList[index] as Map?;
          if (item == null) return const SizedBox.shrink();

          final String imageUrl = item["mobileImage"]?.toString().trim() ?? '';
          if (imageUrl.isEmpty) return const SizedBox.shrink();

          final int bannerId = () {
            final v = item["id"];
            if (v is int) return v;
            return int.tryParse(v?.toString() ?? '') ?? 0;
          }();

          return Container(
            key: ValueKey('banner_${genderId}_$bannerId'),
            child: isVideoUrl(imageUrl)
                ? _buildVideoBanner(imageUrl)
                : _buildImageBanner(imageUrl),
          );
        },
      ),
    );
  }

  // Build video banner
  Widget _buildVideoBanner(String videoUrl) {
    return Container(
      height: 229.sp,
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Center(
        child: Text(
          'Video Banner',
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
        ),
      ),
    );
  }

  // Build image banner
  Widget _buildImageBanner(String imageUrl) {
    return CachedNetworkImage(
      cacheManager: CacheManager(
        Config(
          "customCacheKey",
          stalePeriod: const Duration(days: 15),
          maxNrOfCacheObjects: 50,
        ),
      ),
      fit: BoxFit.fill,
      imageUrl: ImageHelper.toWebP(imageUrl),
      height: 229.sp,
      width: MediaQuery.of(context).size.width,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Container(
          height: 229.sp,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Image.asset(
          downloadImage,
          fit: BoxFit.fill,
          height: 229.sp,
          width: MediaQuery.of(context).size.width,
        );
      },
    );
  }

  // Helper to build the scrollable content for each tab within the TabBarView
  Widget _buildTabContent(String genderId) {
    return FutureBuilder<bool>(
      // Use FutureBuilder to conditionally render content after data is deemed loaded.
      future:
          _ensureDataLoaded(genderId), // A helper that checks if data is ready.
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          debugPrint(
              "HomepageScreen: Error in FutureBuilder for gender $genderId: ${snapshot.error}");
          return Center(
              child: Text("Error loading content: ${snapshot.error}"));
        } else if (!snapshot.hasData || !(snapshot.data as bool)) {
          // Data is not considered loaded based on our check.
          return const Center(
              child: Text("Content not available. Please try again."));
        }

        // Data is loaded, render the content for this tab.
        return SingleChildScrollView(
          // Using a shared scroll controller for now. Consider separate ones if per-tab scroll behavior is needed.
          controller: homeController.discountScreenController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Carousel Section
              _buildBannerCarousel(genderId),

              // NEW IN Section
              RepaintBoundary(
                child: NewInSection(
                  newInController:
                      newInController, // Assumes newInController is reactive and handles current genderId.
                ),
              ),
              SizedBox(height: 16.sp),

              // Newly Launched Brands Section
              RepaintBoundary(
                child: Builder(
                  builder: (context) {
                    try {
                      // BrandController should have fetched data for this genderId via _initializeData.
                      return NewlyLaunchedBrandsSection(
                        brandController: brandController,
                        analytics: analytics,
                      );
                    } catch (e, stack) {
                      debugPrint(
                          'HomepageScreen: NewlyLaunchedBrandsSection failed for gender $genderId: $e$stack');
                      return const SizedBox.shrink(); // Graceful fallback
                    }
                  },
                ),
              ),

              // Shop By Category Section
              RepaintBoundary(
                child: Builder(
                  builder: (context) {
                    try {
                      return ShopByCategorySection(
                        catalogController: catalogController,
                        homeController: homeController,
                        analytics: analytics,
                      );
                    } catch (e, stack) {
                      debugPrint(
                          'HomepageScreen: ShopByCategorySection failed for gender $genderId: $e$stack');
                      return const SizedBox.shrink(); // Graceful fallback
                    }
                  },
                ),
              ),

              Divider(
                color: Colors.grey[200],
                height: 1,
                thickness: 4.sp,
              ),
              const SizedBox(height: 12),

              // Collections Section (NEW UI from Figma)
              RepaintBoundary(
                child: Builder(
                  builder: (context) {
                    try {
                      // Pass genderId to _buildCollectionsSection to ensure correct data is fetched/displayed.
                      return _buildCollectionsSection(genderId);
                    } catch (e, stack) {
                      debugPrint(
                          'HomepageScreen: CollectionsSection failed for gender $genderId: $e$stack');
                      return _buildLegacyCollectionsFallback(); // Fallback to legacy or empty state.
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper future to check if data is loaded for a given genderId.
  // This is a basic check and might need refinement based on how controllers manage loading states.
  Future<bool> _ensureDataLoaded(String genderId) async {
    // A small delay to allow reactive updates from controllers to propagate.
    await Future.delayed(const Duration(milliseconds: 100));

    // Check if the main controllers have loaded data for this gender.
    // We assume isGenderDataLoaded() accurately reflects the loaded state.
    return homeController.isGenderDataLoaded(int.tryParse(genderId) ?? 1);
  }

  // Modified to accept genderId and ensure it's used for fetching/displaying data.
  Widget _buildCollectionsSection(String genderId) {
    // Use Obx to react to changes in productController.homeProductList.
    // This assumes productController.homeProductList is an observable (e.g., RxList)
    // and is updated by _initializeData() for the current genderId.
    return Obx(() {
      final collections = productController.homeProductList;

      // If no collections are loaded for this gender, show an empty state or shrink.
      if (collections.isEmpty) {
        debugPrint(
            "HomepageScreen: No collections found for genderId: $genderId");
        return const SizedBox.shrink(); // Or a widget indicating no content
      }

      // Convert product data to CollectionItemModel with alternating dark theme.
      final collectionItems = collections.asMap().entries.map((entry) {
        final index = entry.key;
        final collection = entry.value;
        return CollectionItemModel(
          id: collection.id,
          title: collection.name,
          subtitle: collection.desc,
          products: collection.products
              .map((p) => p
                  .toJson()) // Assuming each product object has a toJson method
              .map((json) => ProductCardModel.fromJson(
                  json)) // Assuming ProductCardModel.fromJson exists
              .toList(),
          darkTheme: index.isEven, // Alternating dark theme for visual variety
          catId: collection.catId,
        );
      }).toList();

      // Render each collection as a widget.
      return Column(
        children: collectionItems.map((collection) {
          return CollectionSectionWidget(
            collection: collection,
            onViewAll: () {
              // Set productController state for navigation to product view.
              productController.collectionId.value = collection.id;
              productController.productSortBy.value = ""; // Reset sorting
              productController.filterProductEnable.value =
                  false; // Reset filtering
              productController.categoryFilter.value = int.tryParse(genderId) ??
                  1; // Set category filter to current gender

              // Navigate to the product view screen.
              Navigator.pushNamed(context, '/product-view');
            },
            onProductTap: (productId) {
              // Navigate to product details screen.
              if (productId != null) {
                Navigator.pushNamed(context, '/product-details',
                    arguments: productId);
              } else {
                debugPrint(
                    "HomepageScreen: Attempted to tap a product with null or empty ID.");
              }
            },
            onAddToBag: (productId) {
              if (productId != null) {
                // Placeholder for adding to cart. Assumes cartController.addToCart exists.
                // For now, show a confirmation snackbar.
                // cartController.addToCart(productId);
                Get.snackbar(
                  "Add to Bag",
                  "Item with ID $productId added to bag!",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withOpacity(0.8),
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                );
              } else {
                debugPrint(
                    "HomepageScreen: Attempted to add null or empty product ID to bag.");
              }
            },
            onFavorite: (productId) {
              if (productId != null) {
                // Placeholder for toggling favorite status. Assumes wishlistController.toggleWishlist exists.
                // For now, show a confirmation snackbar.
                // wishlistController.toggleWishlist(productId);
                Get.snackbar(
                  "Add to Wishlist",
                  "Item with ID $productId added to wishlist!",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue.withOpacity(0.8),
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                );
              } else {
                debugPrint(
                    "HomepageScreen: Attempted to add null or empty product ID to wishlist.");
              }
            },
            // Pass current wishlist IDs for UI updates (e.g., showing liked status).
            // Use RxSet<String>() as a default if wishlistIds.value is null.
            // favoriteProductIds:
            //     wishlistController.wishlistIds.value ?? RxSet<String>(),
          );
        }).toList(),
      );
    });
  }

  // Fallback widget if the new collections UI fails to load.
  Widget _buildLegacyCollectionsFallback() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color:
          Colors.orange.shade100, // A visually distinct background for fallback
      child: const Center(
        child: Text(
          "Could not load new collections UI. Please check your connection or try again later.",
          style: TextStyle(color: Colors.orange),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
