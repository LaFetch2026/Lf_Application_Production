// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/appbar/homepage_search_placeholder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/cart_controller.dart';
import '../../../core/constant/constants.dart';
import '../text/app_text.dart';

class HomeAppbar extends StatefulWidget {
  final VoidCallback? onPressedCart;
  final VoidCallback? onPressedSearch;
  final VoidCallback? onPressedHeart;
  final VoidCallback? onPressedDropDown;
  final VoidCallback? onPressedProfile;
  final VoidCallback? onPressedCategories;
  final bool showSearch;
  final bool showBack;
  final bool isSearchCollapsed;
  final bool useGradient;
  final Widget? bottom;
  final String title;
  final String searchPlaceholder;
  final double scrollOffset; // For glassmorphism effect
  final bool isTransparent; // Control transparency

  const HomeAppbar({
    Key? key,
    this.onPressedCart,
    this.onPressedHeart,
    this.onPressedSearch,
    this.showSearch = true,
    this.showBack = false,
    this.isSearchCollapsed = false,
    this.useGradient = false,
    this.bottom,
    this.title = "",
    this.searchPlaceholder = "Search for products",
    this.onPressedDropDown,
    this.onPressedProfile,
    this.onPressedCategories,
    this.scrollOffset = 0.0,
    this.isTransparent = false,
  }) : super(key: key);

  @override
  State<HomeAppbar> createState() => _HomeAppbarState();
}

class _HomeAppbarState extends State<HomeAppbar> with WidgetsBindingObserver {
  final CartController cartController = Get.put(CartController());
  bool isGuest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    isGuest = prefs.getBool('skip') ?? false;
    if (!isGuest) cartController.getCartData();
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !isGuest) {
      cartController.getCartData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool collapsed = widget.isSearchCollapsed;

    return AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        // color: Colors.white.withValues(alpha: 0),
        color: Colors.white.withValues(alpha: collapsed ? 0.75 : 0.0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.sp),
          bottomRight: Radius.circular(12.sp),
        ),
        border: Border(
          bottom: BorderSide(
            // color: Colors.white.withValues(alpha: 0.2),
            color: Colors.white.withValues(alpha: collapsed ? 0.2 : 0.0),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
              left: 14.sp, right: 14.sp, top: 10.sp, bottom: 10.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showBack ||
                  widget.title.isNotEmpty ||
                  widget.onPressedCategories != null)
                Row(
                  children: [
                    if (widget.showBack)
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: EdgeInsets.only(right: 8.sp),
                          child: Icon(Icons.arrow_back_ios,
                              size: 16.sp, color: homeAppBarIconColor),
                        ),
                      ),
                    if (widget.title.isNotEmpty)
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          height: 28.sp,
                          child: AppText(
                            text: widget.title.toUpperCase(),
                            color: homeAppBarIconColor,
                            fontSize: 16,
                            textAlign: TextAlign.start,
                            fontFamily: "Clash Display Semibold",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      SvgPicture.asset(applogoCondensed,
                          height: 28.sp, width: 70.sp, fit: BoxFit.fill),
                    const Spacer(),
                    if (widget.onPressedCategories != null)
                      InkWell(
                        onTap: () => widget.onPressedCategories?.call(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.sp, vertical: 8.sp),
                          child: Icon(Icons.grid_view_outlined,
                              size: 20.sp, color: homeAppBarIconColor),
                        ),
                      ),
                  ],
                ),
              if (widget.showBack || widget.title.isNotEmpty)
                SizedBox(height: 8.sp),
              if (widget.showSearch)
                HomeSearchBar(
                  collapsed: collapsed,
                  placeholder: widget.searchPlaceholder,
                  onSearchTap: () {
                    widget.onPressedSearch?.call();
                    if (!isGuest) cartController.getCartData();
                  },
                  onCartTap: () {
                    widget.onPressedCart?.call();
                    if (!isGuest) cartController.getCartData();
                  },
                  onHeartTap: () {
                    widget.onPressedHeart?.call();
                    if (!isGuest) cartController.getCartData();
                  },
                  onProfileTap: widget.onPressedProfile,
                ),
              if (widget.bottom != null)
                ClipRect(
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    heightFactor: collapsed ? 0.0 : 1.0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: collapsed ? 0.0 : 1.0,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.sp),
                        child: widget.bottom!,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppbarIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const AppbarIconButton({super.key, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // color:
          //     Colors.white.withValues(alpha: 0.35), // was 0.10, too invisible
          borderRadius: BorderRadius.circular(102),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 17.3,
              offset: Offset.zero,
            ),
          ],
        ),
        padding: EdgeInsets.all(6.sp), // symmetric is cleaner
        child: child,
      ),
    );
  }
}
