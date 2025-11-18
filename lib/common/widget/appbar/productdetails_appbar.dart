import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/core/utils/share_link_generator.dart';
import 'package:share_plus/share_plus.dart';

import '../../../controllers/product_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constant/constants.dart';

class ProductdetailsAppbar extends StatefulWidget {
  final Function? onPressedShare;
  final Function? onPressedHeart;
  final bool dark; // <-- set true if background is dark

  const ProductdetailsAppbar({
    this.onPressedShare,
    this.onPressedHeart,
    this.dark = false,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductdetailsAppbar> createState() => _ProductdetailsAppbarState();
}

class _ProductdetailsAppbarState extends State<ProductdetailsAppbar> {
  final wishlistController = Get.put(WishlistController());
  final productController = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    final iconColor =
        widget.dark ? Colors.white : Colors.black; // auto-pick color

    return Container(
      width: MediaQuery.of(context).size.width,
      color: statusBarColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: 10.sp,
              top: 56.sp,
              bottom: 8.sp,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // back
                InkWell(
                  onTap: () => Get.back(),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 16.sp, right: 12.sp, bottom: 4.sp),
                    child: SvgPicture.asset(
                      arrowBack,
                      height: 15.sp,
                      width: 15.sp,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                ),

                const Expanded(child: SizedBox.shrink()),

                // logo
                Padding(
                  padding: EdgeInsets.only(left: 40.sp, right: 10.sp),
                  child: Image.asset(
                    lafetchLogoImage,
                    color: homeAppBarColor,
                    height: 25.sp,
                    width: 20.sp,
                  ),
                ),

                const Expanded(child: SizedBox.shrink()),

                // heart
                // Replace this section in ProductdetailsAppbar
                InkWell(
                  onTap: () => widget.onPressedHeart?.call(),
                  child: Obx(
                    () {
                      // Remove the isLoading check, just show the icon
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.sp, vertical: 8.sp),
                        child: wishlistController.isWishlisted.value
                            ? SvgPicture.asset(
                                redHeartSvgImage,
                                height: 18.sp,
                                width: 18.sp,
                                fit: BoxFit.cover,
                              )
                            : SvgPicture.asset(
                                heartSvgImage,
                                height: 18.sp,
                                width: 18.sp,
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                    iconColor, BlendMode.srcIn),
                              ),
                      );
                    },
                  ),
                ),

                // share
                InkWell(
                  onTap: () async {
                    final p = productController.productDetails;

                    if (p.isEmpty) {
                      Get.snackbar("Error", "Product not loaded yet");
                      return;
                    }

                    final link =
                        await ShareLinkGenerator.createProductShareLink(
                      productId: p["id"] ?? 0,
                      productName: p["title"] ?? "",
                      type: p["type"] ?? "",
                      brandName: p["brand_name"] ?? "",
                    );

                    if (link.isEmpty) {
                      Get.snackbar("Error", "Unable to generate link");
                      return;
                    }

                    Share.share("$link\n\n${p["title"]}");
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 3.sp),
                      child: SvgPicture.asset(
                        shareSvgImage,
                        height: 18.sp,
                        width: 18.sp,
                        fit: BoxFit.cover,
                        colorFilter:
                            ColorFilter.mode(iconColor, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
