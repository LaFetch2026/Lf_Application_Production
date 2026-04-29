// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/cart_controller.dart';
import '../../../core/constant/constants.dart';
import '../text/app_text.dart';

class HomeAppbar extends StatefulWidget {
  final Function? onPressedCart;
  final Function? onPressedSearch;
  final Function? onPressedHeart;
  final Function? onPressedDropDown;
  final Function? onPressedProfile;
  final Function? onPressedCategories;
  final bool showSearch;
  final String title;

  const HomeAppbar({
    Key? key,
    this.onPressedCart,
    this.onPressedHeart,
    this.onPressedSearch,
    this.showSearch = true,
    this.title = "",
    this.onPressedDropDown,
    this.onPressedProfile,
    this.onPressedCategories,
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

    // ✅ Check guest status and fetch cart only for logged-in users
    Future.delayed(Duration.zero, () async {
      final prefs = await SharedPreferences.getInstance();
      isGuest = prefs.getBool('skip') ?? false;

      if (!isGuest) {
        await cartController.getCartData();
      } else {
        print("👤 Guest user - skipping cart data fetch in appbar");
      }

      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Only re-fetch for logged-in users
    if (!isGuest) {
      cartController.getCartData();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ✅ Refresh when app resumes (only for logged-in users)
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
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      color: whiteColor,
      child: Padding(
        padding: EdgeInsets.only(
            left: 16.sp,
            top: statusBarHeight + 8.sp,
            right: 10.sp,
            bottom: 8.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ---- APP TITLE OR LOGO ----
            if (widget.title.isNotEmpty)
              Container(
                alignment: Alignment.bottomCenter,
                height: 28.sp,
                child: AppText(
                  text: widget.title.toUpperCase(),
                  color: homeAppBarColor,
                  fontSize: 16,
                  textAlign: TextAlign.end,
                  fontFamily: "Clash Display Semibold",
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              SvgPicture.asset(
                applogSvgImage,
                height: 28.sp,
                width: 70.sp,
                fit: BoxFit.fill,
              ),

            const Spacer(),

            // ---- ICONS ----
            Row(
              children: [
                // ✅ Search
                if (widget.showSearch)
                  InkWell(
                    onTap: () async {
                      await widget.onPressedSearch?.call();
                      if (!isGuest) {
                        cartController.getCartData();
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.sp, vertical: 8.sp),
                      // child: SvgPicture.asset(
                      //   searchSvgImage,
                      //   height: 18.sp,
                      //   width: 18.sp,
                      //   fit: BoxFit.fill,
                      // ),
                      child: Icon(
                        Icons.search,
                        size: 20.sp,
                      ),
                    ),
                  ),

                // ✅ Categories icon - optional
                if (widget.onPressedCategories != null)
                  InkWell(
                    onTap: () => widget.onPressedCategories?.call(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.sp, vertical: 8.sp),
                      child: Icon(
                        Icons.grid_view_outlined,
                        size: 20.sp,
                      ),
                    ),
                  ),

                // ✅ Wishlist - Blocked for guests
                InkWell(
                  onTap: () async {
                    await widget.onPressedHeart?.call();
                    if (!isGuest) {
                      cartController.getCartData();
                    }
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                    child: SvgPicture.asset(
                      heartSvgImage,
                      height: 18.sp,
                      width: 18.sp,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                // ✅ Cart - rightmost, primary CTA
                InkWell(
                  onTap: () async {
                    await widget.onPressedCart?.call();
                    if (!isGuest) {
                      await cartController.getCartData();
                    }
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SvgPicture.asset(
                          cartSvgImage,
                          height: 20.sp,
                          width: 20.sp,
                          fit: BoxFit.fill,
                        ),
                        if (!isGuest)
                          Positioned(
                            right: -5.sp,
                            top: 8.sp,
                            child: Obx(() {
                              final count = cartController.cartTotalValue.value;
                              if (count == 0) return const SizedBox.shrink();
                              return Container(
                                padding: EdgeInsets.all(2.sp),
                                constraints: BoxConstraints(
                                  minWidth: 14.sp,
                                  minHeight: 14.sp,
                                ),
                                decoration: const BoxDecoration(
                                  color: homeAppBarColor,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  count.toString(),
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    color: whiteColor,
                                    fontFamily: "Clash Display Regular",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
                // ✅ Profile icon - identity anchor, leftmost
                if (widget.onPressedProfile != null)
                  InkWell(
                    onTap: () => widget.onPressedProfile?.call(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.sp, vertical: 8.sp),
                      child: Icon(
                        Icons.person_outline,
                        size: 24.sp,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
