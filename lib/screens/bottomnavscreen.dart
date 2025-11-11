// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // Init profile safely
    Future.microtask(() async {
      try {
        final profileController = Get.find<ProfileController>();
        await profileController.safeInitProfile();
      } catch (_) {}
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
      // Get.to(() => const LoginScreen(initialTab: 0, hideBack: true));
    } else {
      onAllowed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: _currentIndex == 5
          ? const CartScreen(backgroundcolor: homeAppBarColor)
          : _screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        color: whiteColor,
        height: Platform.isIOS ? 50.sp : 60.sp,
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
              onTap: () {
                _showQuickDialog(context);
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

  void _showQuickDialog(BuildContext context) {
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
                // ⚡ Lightning-like custom icon using Flutter’s built-in shapes
                Container(
                  width: 64.sp,
                  height: 40.sp,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: Center(
                    child: Image.asset(
                      bagLogoImage, // ✅ constant from your constants.dart
                      width: 48.sp,
                      height: 48.sp,
                      fit: BoxFit.contain,
                      color: Colors.white, // makes it white-tinted if needed
                    ),
                  ),
                ),

                SizedBox(height: 24.sp),

                // 🟣 Title Text
                const Text(
                  "Brace yourself.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: "Franklin Gothic",
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 6.sp),

                // 🟣 Subtitle Text
                Text(
                  "Arriving sooner than expected",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 28.sp),

                // ✅ DONE Button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.sp),
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(8.sp),
                      border: Border.all(color: Colors.white, width: 1),
                      color: Colors.transparent,
                    ),
                    child: const Center(
                      child: Text(
                        "DONE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: "Franklin Gothic",
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
  }) {
    final color = selected ? homeAppBarColor : const Color(0xFF9CA3AF);

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
              SvgPicture.asset(icon, height: 20.sp, color: color),
              SizedBox(height: 6.sp),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10.sp,
                  fontFamily: "Franklin Gothic",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
