import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/controller/wishlist_controller.dart';
import '../../utils/constants.dart';

class ProductdetailsAppbar extends StatefulWidget {
  final Function? onPressedShare;
  final Function? onPressedHeart;

  const ProductdetailsAppbar({
    this.onPressedShare,
    this.onPressedHeart,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductdetailsAppbar> createState() => _ProductdetailsAppbarState();
}

class _ProductdetailsAppbarState extends State<ProductdetailsAppbar> {
  final wishlistController = Get.put(WishlistController());

  @override
  Widget build(BuildContext context) {
    return Container(
      //  height: Platform.isAndroid ? 80.sp : 90.sp,
      width: MediaQuery.of(context).size.width,
      color: statusBarColor,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.only(right: 10.sp, top: 56.sp, bottom: 8.sp
              // top: Platform.isAndroid ? 30.sp : 40.sp
              ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  padding:
                      EdgeInsets.only(left: 16.sp, right: 12.sp, bottom: 4.sp),
                  child: SvgPicture.asset(arrowBack,
                      height: 15.sp, width: 15.sp, fit: BoxFit.cover),
                ),
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Visibility(
                visible: true,
                child: Padding(
                  padding: EdgeInsets.only(left: 40.sp, right: 10.sp),
                  child: Image.asset(
                    lafetchLogoImage,
                    color: homeAppBarColor,
                    height: 25.sp,
                    width: 20.sp,
                  ),
                ),
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              InkWell(
                onTap: () {
                  widget.onPressedHeart?.call();
                },
                child: Obx(
                  () => Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.sp, vertical: 8.sp),
                      child: wishlistController.isProductWishlist.value
                          ? DummyContainer(
                              height: 18,
                              width: 18,
                            )
                          : wishlistController.wishListDetails["wishlisted"]
                              ? SvgPicture.asset(redHeartSvgImage,
                                  height: 18.sp,
                                  width: 18.sp,
                                  fit: BoxFit.cover)
                              : SvgPicture.asset(heartSvgImage,
                                  height: 18.sp,
                                  width: 18.sp,
                                  fit: BoxFit.cover)),
                ),
              ),
              InkWell(
                onTap: () {
                  widget.onPressedShare?.call();
                },
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 3.sp),
                        child: SvgPicture.asset(shareSvgImage,
                            height: 18.sp, width: 18.sp, fit: BoxFit.cover),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
