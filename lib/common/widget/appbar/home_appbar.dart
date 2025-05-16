import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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

  const HomeAppbar(
      {Key? key,
        this.onPressedCart,
        this.onPressedHeart,
        this.onPressedSearch,
        this.showSearch = true,
        this.title = "",
        this.onPressedDropDown})
      : super(key: key);

  @override
  State<HomeAppbar> createState() => _HomeAppbarState();
}

class _HomeAppbarState extends State<HomeAppbar> {
  // final homeController = Get.put(HomeController());
  final controller = Get.put(CartController());
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 100.sp,
      width: MediaQuery.of(context).size.width,
      color: whiteColor,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.only(
              left: 16.sp, top: 56.sp, right: 10.sp, bottom: 8.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              /*  widget.showGender
                  ? GestureDetector(
                      onTap: () {
                        widget.onPressedDropDown?.call();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 20.sp),
                        child: Row(
                          children: [
                            Obx(
                              () => AppText(
                                text: "${homeController.genderText.value}"
                                    .toUpperCase(),
                                fontFamily: "Franklin Gothic Bold",
                                fontWeight: FontWeight.w700,
                                color: Color(0XFFF3F4F6),
                                fontSize: 13,
                              ),
                            ),
                            Obx(() => Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 2.sp),
                                  child: ImageIcon(
                                    AssetImage(
                                        homeController.showGenderList.value
                                            ? upArrowIcon
                                            : dropdownImage),
                                    color: Color(0XFFF3F4F6),
                                    size: 14.sp,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ), */
              Visibility(
                visible: widget.title == "" ? false : true,
                child: Container(
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
                ),
              ),
              Visibility(
                visible: widget.title == "" ? true : false,
                child: SvgPicture.asset(applogSvgImage,
                    height: 28.sp, width: 70.sp, fit: BoxFit.cover),
              ),
              Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.sp),
                child: Row(
                  children: [
                    Visibility(
                      visible: widget.showSearch,
                      child: InkWell(
                        onTap: () {
                          widget.onPressedSearch?.call();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.sp, vertical: 8.sp),
                          child: SvgPicture.asset(searchSvgImage,
                              height: 18.sp, width: 18.sp, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.onPressedHeart?.call();
                      },
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.sp, vertical: 8.sp),
                          child: SvgPicture.asset(heartSvgImage,
                              height: 18.sp, width: 18.sp, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.onPressedCart?.call();
                      },
                      child: Container(
                        // margin: EdgeInsets.only(left: 2.sp),
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: 10.sp,
                              left: 5.sp,
                              top: 8.sp,
                              bottom: 5.sp),
                          child: Stack(
                            children: [
                              Padding(
                                  padding:
                                  EdgeInsets.only(bottom: 3.sp, left: 5.sp),
                                  child: SvgPicture.asset(cartSvgImage,
                                      height: 18.sp,
                                      width: 18.sp,
                                      fit: BoxFit.cover)),
                              Obx(() => controller.cartTotalValue.value != 0
                                  ? Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 10.sp,
                                  height: 10.sp,
                                  child: Padding(
                                    padding: EdgeInsets.all(0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: homeAppBarColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          controller.cartTotalValue.value
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 8,
                                              color: whiteColor,
                                              fontFamily:
                                              "Libre Franklin Regular",
                                              fontWeight:
                                              FontWeight.w400),
                                        ),
                                      ), // inner content
                                    ),
                                  ),
                                ),
                              )
                                  : SizedBox(
                                height: 0,
                              ))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
