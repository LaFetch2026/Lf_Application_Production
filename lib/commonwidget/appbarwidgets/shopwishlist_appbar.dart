import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../utils/constants.dart';

class ShopWishlistAppbar extends StatefulWidget {
  final Function? onPressedheart;
  final Function? onPressedCart;
  final Function? onPressedBackButton;

  const ShopWishlistAppbar({
    Key? key,
    this.onPressedheart,
    this.onPressedCart,
    this.onPressedBackButton,
  }) : super(key: key);

  @override
  State<ShopWishlistAppbar> createState() => ShopWishlistAppbarState();
}

class ShopWishlistAppbarState extends State<ShopWishlistAppbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: statusBarColor,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.only(
              left: 16.sp, right: 10.sp, top: 56.sp, bottom: 16.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  child: SvgPicture.asset(arrowBack,
                      height: 15.sp, width: 15.sp, fit: BoxFit.cover),
                  onTap: () {
                    widget.onPressedBackButton?.call();
                  },
                ),
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.sp),
                child: Image.asset(
                  lafetchLogoImage,
                  color: homeAppBarColor,
                  height: 25.sp,
                  width: 20.sp,
                ),
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              InkWell(
                onTap: () {
                  widget.onPressedheart?.call();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp),
                  child: ImageIcon(
                    AssetImage(wishlistBottomIcon),
                    color: homeAppBarColor,
                    size: 16.sp,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  widget.onPressedCart?.call();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 3.sp),
                    child: Image.asset(
                      cartNewImage,
                      color: homeAppBarColor,
                      height: 16.sp,
                      width: 16.sp,
                    ),
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
