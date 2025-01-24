import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Image.asset(
                    backWhiteArrow,
                    height: 16.sp,
                    width: 16.sp,
                    color: homeAppBarColor,
                  ),
                  onPressed: () {
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
                padding: EdgeInsets.only(left: 5.sp),
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
              GestureDetector(
                onTap: () {
                  widget.onPressedheart?.call();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ImageIcon(
                    AssetImage(wishlistBottomIcon),
                    color: homeAppBarColor,
                    size: 20.sp,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onPressedCart?.call();
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 5.sp),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 3.sp),
                    child: Image.asset(
                      cartNewImage,
                      color: homeAppBarColor,
                      height: 20.sp,
                      width: 20.sp,
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
