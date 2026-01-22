// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/widget/other/common_widget.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/profile_controller.dart';
import '../core/constant/constants.dart';
import '../screens/accountscreen.dart';
import '../screens/brandsscreen.dart';
import '../screens/cartscreen.dart';
import '../screens/catalog/women_catalog.dart';
import '../screens/home/women/homescreen.dart';
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
  bool isGuest = false;
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(onPressed: (index) => _changeTab(index)),
    const BrandsScreen(screen: "home"),
    WomenCatalogScreen(),
    AccountScreen(onPressed: () => _changeTab(2)),
    const QuickScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index ?? 0;

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

  Future<void> _loadGuestFlag() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isGuest = prefs.getBool("skip") ?? false;
    });
  }

  void _changeTab(int index) {
    setState(() => _currentIndex = index);
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

  Future<bool> _handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check service enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showAppSnackBar(
        "Please enable location services",
        type: SnackBarType.error,
      );
      await Geolocator.openLocationSettings();
      return false;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      showAppSnackBar("Location permission denied", type: SnackBarType.error);
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      showAppSnackBar(
        "Location permission permanently denied. Enable from settings.",
        type: SnackBarType.error,
      );
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: _currentIndex == 5
          ? CartScreen(key: UniqueKey(), backgroundcolor: homeAppBarColor)
          : _screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        color: whiteColor,
        height: Platform.isIOS ? 55.sp : 60.sp,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(
              icon: _currentIndex == 0 ? homeSelectedSvgImage : homeSvgImage,
              label: "Home",
              selected: _currentIndex == 0,
              onTap: () {
                _changeTab(0);
                analytics.logEvent(name: 'home_page');
              },
            ),
            _navItem(
              icon: _currentIndex == 1 ? brandSelectedSvgImage : brandSvgImage,
              label: "Brands",
              selected: _currentIndex == 1,
              onTap: () {
                _changeTab(1);
                analytics.logEvent(name: 'brands_page');
              },
            ),
            _navItem(
              icon: _currentIndex == 4 ? quickSelectedSvgImage : quickSvgImage,
              label: "Quick",
              selected: _currentIndex == 4,
              iconSize: 24.sp,
              fixedColor: lightPurpleColor,
              onTap: () async {
                // ✅ Step 1: Ask for location permission
                bool hasPermission = await _handleLocationPermission(context);

                if (hasPermission) {
                  // ✅ Step 2: Try to get location in background
                  try {
                    final pos = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                    );
                    print("📍 Lat: ${pos.latitude}, Lng: ${pos.longitude}");
                  } catch (e) {
                    print("⚠️ Could not get location: $e");
                  }

                  // ✅ Step 3: Show postal code input dialog
                  _showPostalCodeDialog(context);
                }
              },
            ),
            _navItem(
              icon: _currentIndex == 2
                  ? categorySelectedSvgImage
                  : categorySvgImage,
              label: "Category",
              selected: _currentIndex == 2,
              onTap: () {
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
                _changeTab(3);
                analytics.logEvent(name: 'profile_page');
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NEW: Postal Code Input Dialog
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
    final color = fixedColor ?? (selected ? homeAppBarColor : const Color(0xFF9CA3AF));

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(
            top: 10.sp,
            bottom: Platform.isIOS ? 0 : 10.sp,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(icon, height: iconSize ?? 19.sp, color: color),
              SizedBox(height: 6.sp),
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
