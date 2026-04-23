import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../controllers/cart_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constant/constants.dart';

class ProductdetailsAppbar extends StatefulWidget {
  final int productId; // NEW
  final String type; // NEW
  final String brandName; // NEW
  final String slug; // NEW

  final Function? onPressedShare;
  final Function? onPressedHeart;
  final Function? onPressedCart;
  final bool dark;

  const ProductdetailsAppbar({
    required this.productId,
    required this.type,
    required this.brandName,
    required this.slug,
    this.onPressedShare,
    this.onPressedHeart,
    this.onPressedCart,
    this.dark = false,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductdetailsAppbar> createState() => _ProductdetailsAppbarState();
}

class _ProductdetailsAppbarState extends State<ProductdetailsAppbar> {
  final wishlistController = Get.put(WishlistController());
  final productController = Get.put(ProductController());
  final cartController = Get.put(CartController());
  bool isGuest = false;

  @override
  void initState() {
    super.initState();
    // Check guest status and fetch cart only for logged-in users
    Future.delayed(Duration.zero, () async {
      final prefs = await SharedPreferences.getInstance();
      isGuest = prefs.getBool('skip') ?? false;

      if (!isGuest) {
        await cartController.getCartData();
      }

      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final iconColor = widget.dark ? Colors.white : Colors.black;

    return Container(
      width: MediaQuery.of(context).size.width,
      color: statusBarColor,
      child: Padding(
        padding: EdgeInsets.only(
            left: 16.sp,
            top: statusBarHeight + 8.sp,
            right: 10.sp,
            bottom: 8.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // BACK BUTTON
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.back(),
              child: Padding(
                padding: EdgeInsets.only(right: 12.sp, bottom: 4.sp),
                child: SvgPicture.asset(
                  arrowBack,
                  height: 15.sp,
                  width: 15.sp,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
            ),

            const Expanded(child: SizedBox()),

            // CENTER LOGO
            Padding(
              padding: EdgeInsets.only(left: 30.sp),
              child: GestureDetector(
                onTap: () => Get.offAll(() => const BottomNavScreen(index: 0)),
                child: Image.asset(
                  lafetchLogoImage,
                  color: homeAppBarColor,
                  height: 25.sp,
                  width: 20.sp,
                ),
              ),
            ),

            const Expanded(child: SizedBox()),

            // HEART ICON
            InkWell(
              onTap: () => widget.onPressedHeart?.call(),
              child: Obx(
                () => Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                  child: wishlistController.isWishlisted.value
                      ? SvgPicture.asset(
                          redHeartSvgImage,
                          height: 18.sp,
                          width: 18.sp,
                        )
                      : SvgPicture.asset(
                          heartSvgImage,
                          height: 18.sp,
                          width: 18.sp,
                          colorFilter:
                              ColorFilter.mode(iconColor, BlendMode.srcIn),
                        ),
                ),
              ),
            ),

            // CART ICON
            InkWell(
              onTap: () async {
                await widget.onPressedCart?.call();
                if (!isGuest) {
                  await cartController.getCartData();
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(
                      cartSvgImage,
                      height: 18.sp,
                      width: 18.sp,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),

                    // Only show badge for logged-in users
                    if (!isGuest)
                      Positioned(
                        right: -5.sp,
                        top: 6.sp,
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
          ],
        ),
      ),
    );
  }
}
