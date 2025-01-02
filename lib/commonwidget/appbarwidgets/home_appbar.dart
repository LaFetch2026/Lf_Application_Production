import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/app_text.dart';
import 'package:lafetch/controller/home_controller.dart';

import '../../utils/constants.dart';

class HomeAppbar extends StatefulWidget {
  final Function? onPressedCart;
  final Function? onPressedSearch;
  final Function? onPressedCatalog;
  final Function? onPressedDropDown;
  final bool showGender;

  const HomeAppbar(
      {Key? key,
      this.onPressedCart,
      this.onPressedCatalog,
      this.onPressedSearch,
      this.showGender = false,
      this.onPressedDropDown})
      : super(key: key);

  @override
  State<HomeAppbar> createState() => _HomeAppbarState();
}

class _HomeAppbarState extends State<HomeAppbar> {
  final homeController = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.sp,
      width: MediaQuery.of(context).size.width,
      color: homeAppBarColor,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.only(left: 16.sp, top: 60.sp, right: 16.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              widget.showGender
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
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.sp),
                              child: ImageIcon(
                                AssetImage(dropdownImage),
                                color: Color(0XFFF3F4F6),
                                size: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.sp),
                    child: Center(
                      child: Image.asset(appNameImage,
                          height: 26.sp, width: 70.sp, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.onPressedSearch?.call();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.sp),
                      child: ImageIcon(
                        AssetImage(searchNewImage),
                        color: Color(0XFFF3F4F6),
                        size: 20.sp,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onPressedCatalog?.call();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.sp),
                      child: ImageIcon(
                        AssetImage(saveIcon),
                        color: Color(0XFFF3F4F6),
                        size: 18.sp,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onPressedCart?.call();
                    },
                    child: Padding(
                        padding: EdgeInsets.only(left: 5.sp),
                        child: ImageIcon(
                          AssetImage(cartNewImage),
                          color: Color(0XFFF3F4F6),
                          size: 18.sp,
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
