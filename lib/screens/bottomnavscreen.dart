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
                _changeTab(4);
                analytics.logEvent(name: 'quick_page');
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
