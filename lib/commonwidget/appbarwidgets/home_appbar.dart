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
      color: blackColor,
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
                      child: Row(
                        children: [
                          Obx(
                            () => AppText(
                              text: "${homeController.genderText.value}"
                                  .toUpperCase(),
                              fontFamily: "Franklin Gothic",
                              fontWeight: FontWeight.w400,
                              color: whiteColor,
                              fontSize: 13,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.sp),
                            child: ImageIcon(
                              AssetImage(dropdownImage),
                              color: whiteColor,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.sp),
                child: Center(
                  child: Image.asset(appNameImage,
                      height: 28.sp, width: 70.sp, fit: BoxFit.cover),
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onPressedSearch?.call();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.sp),
                  child: ImageIcon(
                    AssetImage(searchNewImage),
                    color: whiteColor,
                    size: 20.sp,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onPressedCatalog?.call();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.sp),
                  child: ImageIcon(
                    AssetImage(saveIcon),
                    color: whiteColor,
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
                    child: /* SizedBox(
                    height: 28.sp,
                    width: 28.sp,
                    child: CircleAvatar(
                      backgroundColor: whiteColor,
                      child: ImageIcon(
                        AssetImage(cartImage),
                        color: colorPrimary,
                        size: 20.sp,
                      ),
                    ),
                  ), */
                        ImageIcon(
                      AssetImage(cartNewImage),
                      color: whiteColor,
                      size: 20.sp,
                    )),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
