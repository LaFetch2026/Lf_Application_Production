import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      height: 80.sp,
      width: MediaQuery.of(context).size.width,
      color: statusBarColor,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.only(left: 6.sp, right: 16.sp, top: 30.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Image.asset(
                  backWhiteArrow,
                  height: 16.sp,
                  color: homeAppBarColor,
                  width: 16.sp,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Visibility(
                visible: true,
                child: Padding(
                  padding: EdgeInsets.only(left: 25.sp, right: 10.sp),
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
              GestureDetector(
                onTap: () {
                  widget.onPressedHeart?.call();
                },
                child: Obx(
                  () => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: wishlistController.isProductWishlist.value
                          ? DummyContainer(
                              height: 18,
                              width: 18,
                            )
                          : wishlistController.wishListDetails["wishlisted"]
                              ? ImageIcon(
                                  AssetImage(redHeartimage),
                                  color: redColor,
                                  size: 20.sp,
                                )
                              : ImageIcon(
                                  AssetImage(wishlistBottomIcon),
                                  color: homeAppBarColor,
                                  size: 16.sp,
                                )),
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onPressedShare?.call();
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 5.sp),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 3.sp),
                        child: Image.asset(
                          shareNewimage,
                          color: homeAppBarColor,
                          height: 18.sp,
                          width: 18.sp,
                        ),
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
