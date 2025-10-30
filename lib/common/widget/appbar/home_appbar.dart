// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/cart_controller.dart';
import '../../../core/constant/constants.dart';
import '../text/app_text.dart';

class HomeAppbar extends StatefulWidget {
  final Function? onPressedCart;
  final Function? onPressedSearch;
  final Function? onPressedHeart;
  final Function? onPressedDropDown;
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
  }) : super(key: key);

  @override
  State<HomeAppbar> createState() => _HomeAppbarState();
}

class _HomeAppbarState extends State<HomeAppbar> with WidgetsBindingObserver {
  final CartController cartController = Get.put(CartController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ Ensure fresh cart count on first load
    Future.delayed(Duration.zero, () async {
      await cartController.getCartData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Re-fetch when widget becomes active again
    cartController.getCartData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ✅ Refresh when app resumes
    if (state == AppLifecycleState.resumed) {
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
    return Container(
      width: double.infinity,
      color: whiteColor,
      child: Padding(
        padding: EdgeInsets.only(
            left: 16.sp, top: 56.sp, right: 10.sp, bottom: 8.sp),
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
                  fontFamily: "Franklin Gothic Semibold",
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              SvgPicture.asset(
                applogSvgImage,
                height: 28.sp,
                width: 70.sp,
                fit: BoxFit.cover,
              ),

            const Spacer(),

            // ---- ICONS (Search / Wishlist / Cart) ----
            Row(
              children: [
                if (widget.showSearch)
                  InkWell(
                    onTap: () async {
                      await widget.onPressedSearch?.call();
                      // refresh count when returning from search
                      cartController.getCartData();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.sp, vertical: 8.sp),
                      child: SvgPicture.asset(
                        searchSvgImage,
                        height: 18.sp,
                        width: 18.sp,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                InkWell(
                  onTap: () async {
                    await widget.onPressedHeart?.call();
                    cartController.getCartData();
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                    child: SvgPicture.asset(
                      heartSvgImage,
                      height: 18.sp,
                      width: 18.sp,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await widget.onPressedCart?.call();
                    await cartController.getCartData();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: 10.sp, left: 5.sp, top: 8.sp, bottom: 5.sp),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SvgPicture.asset(
                          cartSvgImage,
                          height: 20.sp,
                          width: 20.sp,
                          fit: BoxFit.cover,
                        ),
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
                                  fontFamily: "Franklin Gothic Regular",
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
