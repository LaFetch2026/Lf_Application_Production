// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../common/widget/other/common_widget.dart';
import '../controllers/cart_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/profile_controller.dart';
import '../core/constant/constants.dart';
import '../screens/accountscreen.dart';
import '../screens/brandsscreen.dart';
import '../screens/cartscreen.dart';
import '../screens/catalog/women_catalog.dart';
import '../screens/home/women/homescreen.dart';
import '../screens/home/women/dynamic_homescreen.dart';
import '../screens/quickscreen.dart';
import '../screens/loginscreen.dart';
import 'package:geolocator/geolocator.dart';

class BottomNavScreen extends StatefulWidget {
  final int? index;
  const BottomNavScreen({super.key, this.index});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final productController = Get.put(ProductController());
  final cartController = Get.put(CartController());
  late final HomeController homeController;
  bool isGuest = false;
  int _currentIndex = 0;

  // ✅ Lazy loading: Track which tabs have been visited
  final Set<int> _loadedTabs = {};

  // ✅ Cache screens after first load to prevent rebuild
  final Map<int, Widget> _cachedScreens = {};

  // ✅ Video Ad State
  VideoPlayerController? _videoAdController;
  bool _showVideoAd = false;
  bool _videoAdDismissed = false;
  bool _videoAdLoading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index ?? 0;
    homeController = Get.put(HomeController());

    // ✅ Mark initial tab as loaded and build it immediately
    _loadedTabs.add(_currentIndex);
    _buildScreen(_currentIndex);

    // Status bar setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: statusBarColor,
      ));
    });

    _loadGuestFlag();

    // ✅ Fetch video ad
    // _fetchVideoAd();

    // Only initialize profile for logged-in users
    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      final isGuestUser = prefs.getBool("skip") ?? false;

      if (!isGuestUser) {
        try {
          final profileController = Get.find<ProfileController>();
          await profileController.safeInitProfile();
        } catch (e) {
          print("⚠️ Profile initialization error: $e");
        }
      } else {
        print(
            "👤 Guest user detected - skipping profile, cart, and wishlist initialization");
      }
    });
  }

  @override
  void dispose() {
    _videoAdController?.dispose();
    super.dispose();
  }

  // ✅ Fetch video ad from API
  Future<void> _fetchVideoAd() async {
    print("🎬 _fetchVideoAd called");
    if (_videoAdDismissed || _videoAdLoading) {
      print(
          "🎬 Skipping - dismissed: $_videoAdDismissed, loading: $_videoAdLoading");
      return;
    }

    setState(() => _videoAdLoading = true);

    try {
      final url = '${ApiConstants.baseUrl}/video-ad?status=true';
      print("🎬 Fetching video ad from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print("🎬 Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 200 &&
            data['data'] != null &&
            (data['data'] as List).isNotEmpty) {
          final videoData = data['data'][0];
          final videoUrl = videoData['mobileVideoURL'] as String?;
          print("🎬 Video URL: $videoUrl");

          if (videoUrl != null && videoUrl.isNotEmpty) {
            _initializeVideoPlayer(videoUrl);
          } else {
            print("🎬 Video URL is null or empty");
          }
        } else {
          print("🎬 No video data in response");
        }
      } else {
        print("🎬 Response status not 200: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Video ad fetch error: $e");
    } finally {
      if (mounted) {
        setState(() => _videoAdLoading = false);
      }
    }
  }

  // ✅ Initialize video player
  void _initializeVideoPlayer(String videoUrl) {
    print("🎬 Initializing video player with URL: $videoUrl");
    _videoAdController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        print("🎬 Video initialized! Size: ${_videoAdController?.value.size}");
        if (mounted && !_videoAdDismissed) {
          setState(() => _showVideoAd = true);
          print("🎬 _showVideoAd set to TRUE");
          _videoAdController?.setLooping(true);
          _videoAdController?.setVolume(0); // Muted by default
          _videoAdController?.play();
        }
      }).catchError((e) {
        print("⚠️ Video player init error: $e");
      });
  }

  // ✅ Dismiss video ad
  void _dismissVideoAd() {
    setState(() {
      _showVideoAd = false;
      _videoAdDismissed = true;
    });
    _videoAdController?.pause();
    _videoAdController?.dispose();
    _videoAdController = null;
  }

  Future<void> _loadGuestFlag() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isGuest = prefs.getBool("skip") ?? false;
    });
  }

  void _changeTab(int index) {
    // Reset scroll state when switching tabs
    homeController.isScrolling.value = false;
    homeController.isBottomNavVisible.value = true;

    // ✅ Build screen before changing tab to ensure it's cached
    if (!_loadedTabs.contains(index)) {
      _buildScreen(index);
    }

    // ✅ Mark tab as loaded when switching to it
    _loadedTabs.add(index);
    // ✅ Update home tab active state (for video auto-pause)
    homeController.isHomeTabActive.value = (index == 0);
    setState(() => _currentIndex = index);
  }

  // ✅ Build screen only when needed (lazy loading)
  Widget _buildScreen(int index) {
    // Return cached screen if already built
    if (_cachedScreens.containsKey(index)) {
      return _cachedScreens[index]!;
    }

    // Build and cache the screen
    Widget screen;
    switch (index) {
      case 0:
        screen = DynamicHomeScreen(onPressed: (i) => _changeTab(i));
        break;
      case 1:
        screen = const BrandsScreen(screen: "home");
        break;
      case 2:
        screen = WomenCatalogScreen();
        break;
      case 3:
        screen = AccountScreen(onPressed: () => _changeTab(2));
        break;
      case 4:
        screen = const QuickScreen();
        break;
      default:
        screen = const SizedBox.shrink();
    }

    _cachedScreens[index] = screen;
    return screen;
  }

  void _handleProtectedNavigation(VoidCallback onAllowed) {
    if (isGuest) {
      showAppSnackBar("Please sign in to access your profile",
          type: SnackBarType.info);
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.to(() => const LoginScreen(initialTab: 0));
      });
    } else {
      onAllowed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomNavHeight = 55.sp + MediaQuery.of(context).padding.bottom;

    // Debug video state
    print(
        "🎬 BUILD - showVideoAd: $_showVideoAd, controller: ${_videoAdController != null}, initialized: ${_videoAdController?.value.isInitialized}");

    return Stack(
      children: [
        Scaffold(
          backgroundColor: whiteColor,
          extendBody: true,
          // ✅ Lazy loading: Only build screens when visited, then keep them cached
          body: _currentIndex == 5
              ? CartScreen(key: UniqueKey(), backgroundcolor: homeAppBarColor)
              : IndexedStack(
                  index: _currentIndex,
                  children: [
                    _cachedScreens.containsKey(0)
                        ? _cachedScreens[0]!
                        : const SizedBox.shrink(),
                    _cachedScreens.containsKey(1)
                        ? _cachedScreens[1]!
                        : const SizedBox.shrink(),
                    _cachedScreens.containsKey(2)
                        ? _cachedScreens[2]!
                        : const SizedBox.shrink(),
                    _cachedScreens.containsKey(3)
                        ? _cachedScreens[3]!
                        : const SizedBox.shrink(),
                    _cachedScreens.containsKey(4)
                        ? _cachedScreens[4]!
                        : const SizedBox.shrink(),
                  ],
                ),
          // bottomNavigationBar: Container(
          //   padding: EdgeInsets.only(
          //     bottom: MediaQuery.of(context).padding.bottom,
          //   ),
          //   decoration: BoxDecoration(
          //     color: whiteColor,
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.1),
          //         blurRadius: 8,
          //         offset: const Offset(0, -2),
          //       ),
          //     ],
          //   ),
          //   height: 55.sp + MediaQuery.of(context).padding.bottom,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          // _navItem(
          //   icon:
          //       _currentIndex == 0 ? homeSelectedSvgImage : homeSvgImage,
          //   label: "Home",
          //   selected: _currentIndex == 0,
          //   onTap: () {
          //     HapticFeedback.lightImpact();
          //     _changeTab(0);
          //     analytics.logEvent(name: 'home_page');
          //   },
          // ),
          // _navItem(
          //   icon: _currentIndex == 1
          //       ? brandSelectedSvgImage
          //       : brandSvgImage,
          //   label: "Brands",
          //   selected: _currentIndex == 1,
          //   onTap: () {
          //     HapticFeedback.lightImpact();
          //     _changeTab(1);
          //     analytics.logEvent(name: 'brands_page');
          //   },
          // ),
          // _navItem(
          //   icon: _currentIndex == 4
          //       ? quickSelectedSvgImage
          //       : quickSvgImage,
          //   label: "Quick",
          //   selected: _currentIndex == 4,
          //   iconSize: 24.sp,
          //   fixedColor: lightPurpleColor,
          //   onTap: () {
          //     HapticFeedback.lightImpact();
          //     // Show location choice dialog immediately
          //     _showLocationChoiceDialog(context);
          //   },
          // ),
          // _navItem(
          //   icon: _currentIndex == 2
          //       ? categorySelectedSvgImage
          //       : categorySvgImage,
          //   label: "Category",
          //   selected: _currentIndex == 2,
          //   onTap: () {
          //     HapticFeedback.lightImpact();
          //     _changeTab(2);
          //     analytics.logEvent(name: 'category_page');
          //   },
          // ),
          // _navItem(
          //   icon: _currentIndex == 3
          //       ? profileSelectedSvgImage
          //       : profileSvgImage,
          //   label: "Profile",
          //   selected: _currentIndex == 3,
          //   onTap: () => _handleProtectedNavigation(() {
          //     HapticFeedback.lightImpact();
          //     _changeTab(3);
          //     analytics.logEvent(name: 'profile_page');
          //   }),
          // ),
          //   ],
          // ),
          // ),
          bottomNavigationBar: Obx(() {
            final isVisible = homeController.isBottomNavVisible.value;

            return AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              offset: isVisible ? const Offset(0, 0) : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isVisible ? 1 : 0,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  height: 55.sp + MediaQuery.of(context).padding.bottom,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(
                        icon: _currentIndex == 0
                            ? homeSelectedSvgImage
                            : homeSvgImage,
                        label: "Home",
                        selected: _currentIndex == 0,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _changeTab(0);
                          analytics.logEvent(name: 'home_page');
                        },
                      ),
                      _navItem(
                        icon: _currentIndex == 1
                            ? brandSelectedSvgImage
                            : brandSvgImage,
                        label: "Brands",
                        selected: _currentIndex == 1,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _changeTab(1);
                          analytics.logEvent(name: 'brands_page');
                        },
                      ),
                      _navItem(
                        icon: _currentIndex == 4
                            ? quickSelectedSvgImage
                            : quickSvgImage,
                        label: "Quick",
                        selected: _currentIndex == 4,
                        iconSize: 24.sp,
                        fixedColor: lightPurpleColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          // Show location choice dialog immediately
                          _showLocationChoiceDialog(context);
                        },
                      ),
                      _navItem(
                        icon: _currentIndex == 2
                            ? categorySelectedSvgImage
                            : categorySvgImage,
                        label: "Category",
                        selected: _currentIndex == 2,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _changeTab(2);
                          analytics.logEvent(name: 'category_page');
                        },
                      ),
                      _navItem(
                        icon: _currentIndex == 3
                            ? profileSelectedSvgImage
                            : profileSvgImage,
                        label: "Profile",
                        selected: _currentIndex == 3,
                        onTap: () => _handleProtectedNavigation(() {
                          HapticFeedback.lightImpact();
                          _changeTab(3);
                          analytics.logEvent(name: 'profile_page');
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),

        // ✅ Video Ad Widget - Bottom Left (overlays on top of everything)
        if (_showVideoAd &&
            _videoAdController != null &&
            _videoAdController!.value.isInitialized)
          Positioned(
            left: 12.sp,
            bottom: bottomNavHeight + 12.sp,
            child: Container(
              width: screenWidth * 0.28,
              height: screenHeight * 0.22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.sp),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Video Player
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.sp),
                    child: SizedBox(
                      width: screenWidth * 0.28,
                      height: screenHeight * 0.22,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: SizedBox(
                          width: _videoAdController!.value.size.width,
                          height: _videoAdController!.value.size.height,
                          child: VideoPlayer(_videoAdController!),
                        ),
                      ),
                    ),
                  ),
                  // Close Button - Top Right
                  Positioned(
                    top: 4.sp,
                    right: 4.sp,
                    child: GestureDetector(
                      onTap: _dismissVideoAd,
                      child: Container(
                        width: 20.sp,
                        height: 20.sp,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ✅ Location Choice Dialog - User chooses between postal code or live location
  void _showLocationChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sp),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 20.sp),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Choose Location Method",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.sp),

                // Subtitle
                Text(
                  "How would you like to verify your location?",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                    fontFamily: "Clash Display Regular",
                  ),
                ),
                SizedBox(height: 24.sp),

                // Option 1: Use Live Location
                GestureDetector(
                  onTap: () async {
                    Get.back(); // Close dialog first
                    await _handleLiveLocationOption(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        vertical: 14.sp, horizontal: 16.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.sp),
                      color: homeAppBarColor,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.my_location,
                            color: Colors.white, size: 20.sp),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Use Live Location",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontFamily: "Clash Display",
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2.sp),
                              Text(
                                "Automatically detect your location",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11.sp,
                                  fontFamily: "Clash Display Regular",
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.white, size: 16.sp),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.sp),

                // Option 2: Enter Postal Code
                GestureDetector(
                  onTap: () {
                    Get.back(); // Close this dialog
                    _showPostalCodeDialog(context); // Show postal code dialog
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        vertical: 14.sp, horizontal: 16.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.sp),
                      border: Border.all(color: Colors.grey[300]!),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.pin_drop_outlined,
                            color: Colors.grey[700], size: 20.sp),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Enter Postal Code",
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 14.sp,
                                  fontFamily: "Clash Display",
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2.sp),
                              Text(
                                "Manually enter your 6-digit postal code",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 11.sp,
                                  fontFamily: "Clash Display Regular",
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.grey[400], size: 16.sp),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.sp),

                // Cancel Button
                Center(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Handle live location option
  Future<void> _handleLiveLocationOption(BuildContext context) async {
    if (!mounted) return;

    // 1. First check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showAppSnackBar(
        "Please enable location services",
        type: SnackBarType.error,
      );
      await Geolocator.openLocationSettings();
      return;
    }

    // 2. Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    // 3. Request permission if denied (this triggers the system popup)
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // ❌ user pressed "Don't allow"
    if (permission == LocationPermission.denied) {
      showAppSnackBar(
        "Location permission denied",
        type: SnackBarType.error,
      );
      return;
    }

    // ❌ permanently denied
    if (permission == LocationPermission.deniedForever) {
      showAppSnackBar(
        "Enable location permission from app settings",
        type: SnackBarType.error,
      );
      await Geolocator.openAppSettings();
      return;
    }

    // ✅ permission allowed
    // 🚫 NO LOADING
    // 🚫 NO LOCATION FETCH

    _showOutOfAreaDialog(context);
  }

  // ✅ Postal Code Input Dialog
  void _showPostalCodeDialog(BuildContext context) {
    final TextEditingController postalController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sp),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 20.sp),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Enter Your Postal Code",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.sp),

                // Subtitle
                Text(
                  "We need your postal code to check service availability in your area.",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                    fontFamily: "Clash Display Regular",
                  ),
                ),
                SizedBox(height: 20.sp),

                // Input Field
                TextField(
                  controller: postalController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: "Enter 6-digit postal code",
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: "Clash Display Regular",
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                      borderSide:
                          const BorderSide(color: homeAppBarColor, width: 2),
                    ),
                    counterText: "",
                  ),
                ),
                SizedBox(height: 24.sp),

                // Buttons Row
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.sp),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.sp),
                            border: Border.all(color: Colors.grey[300]!),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14.sp,
                                fontFamily: "Clash Display",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.sp),

                    // Submit Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          String postalCode = postalController.text.trim();

                          if (postalCode.isEmpty) {
                            showAppSnackBar(
                              "Please enter postal code",
                              type: SnackBarType.error,
                            );
                            return;
                          }

                          if (postalCode.length != 6) {
                            showAppSnackBar(
                              "Postal code must be 6 digits",
                              type: SnackBarType.error,
                            );
                            return;
                          }

                          // Close postal code dialog
                          Get.back();

                          // ✅ Show "out of area" dialog
                          _showOutOfAreaDialog(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.sp),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.sp),
                            color: homeAppBarColor,
                          ),
                          child: Center(
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontFamily: "Clash Display",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ UPDATED: "Out of Area" Dialog
  void _showOutOfAreaDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sp),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 12.sp),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.sp),
              gradient: const LinearGradient(
                colors: [Color(0xFF5B5399), Color(0xFF171717)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 32.sp, horizontal: 20.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 64.sp,
                  height: 40.sp,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: Center(
                    child: Image.asset(
                      bagLogoImage,
                      width: 48.sp,
                      height: 48.sp,
                      fit: BoxFit.fill,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 24.sp),

                // Title Text
                const Text(
                  "Currently out of your area's league.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6.sp),

                // Subtitle Text
                Text(
                  "Manifest LaFetch harder.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontFamily: "Clash Display Regular",
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 28.sp),

                // OK Button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.sp),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      color: Colors.transparent,
                    ),
                    child: const Center(
                      child: Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Reusable bottom nav item
  Widget _navItem({
    required String icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    double? iconSize,
    Color? fixedColor,
  }) {
    final color =
        fixedColor ?? (selected ? homeAppBarColor : const Color(0xFF9CA3AF));

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(
            top: 8.sp,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(icon, height: iconSize ?? 19.sp, color: color),
              SizedBox(height: 4.sp),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10.sp,
                  fontFamily: "Clash Display",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
