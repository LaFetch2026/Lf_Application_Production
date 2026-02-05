import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/constant/constants.dart';

class ShopWishlistAppbar extends StatefulWidget {
  final Function? onPressedheart;
  final Function? onPressedCart;
  final Function? onPressedBackButton;
  final bool hideIcon;

  const ShopWishlistAppbar({
    Key? key,
    this.onPressedheart,
    this.onPressedCart,
    this.onPressedBackButton,
    this.hideIcon = true,
  }) : super(key: key);

  @override
  State<ShopWishlistAppbar> createState() => ShopWishlistAppbarState();
}

class ShopWishlistAppbarState extends State<ShopWishlistAppbar> {
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: MediaQuery.of(context).size.width,
      color: statusBarColor,
      child: Padding(
        padding: EdgeInsets.only(
            left: 16.sp, top: statusBarHeight + 8.sp, right: 10.sp, bottom: 16.sp),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Visibility(
              visible: widget.hideIcon ? true : false,
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  child: SvgPicture.asset(arrowBack,
                      height: 15.sp, width: 15.sp, fit: BoxFit.fill),
                  onTap: () {
                    widget.onPressedBackButton?.call();
                  },
                ),
              ),
            ),
            const Expanded(
              child: SizedBox(
                height: 0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30.sp),
              child: Image.asset(
                lafetchLogoImage,
                color: homeAppBarColor,
                height: 25.sp,
                width: 20.sp,
              ),
            ),
            Visibility(
              visible: widget.hideIcon ? false : true,
              child: SizedBox(
                width: 40.sp,
              ),
            ),
            const Expanded(
              child: SizedBox(
                height: 0,
              ),
            ),
            Visibility(
              visible: widget.hideIcon ? true : false,
              child: InkWell(
                onTap: () {
                  widget.onPressedheart?.call();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp),
                  child: SvgPicture.asset(heartSvgImage,
                      height: 18.sp, width: 18.sp, fit: BoxFit.fill),
                ),
              ),
            ),
            Visibility(
              visible: widget.hideIcon ? true : false,
              child: InkWell(
                onTap: () {
                  widget.onPressedCart?.call();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 3.sp),
                    child: SvgPicture.asset(cartSvgImage,
                        height: 18.sp, width: 18.sp, fit: BoxFit.fill),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
