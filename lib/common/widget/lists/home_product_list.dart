// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../controllers/product_controller.dart';
import '../../../core/constant/constants.dart';
import '../other/common_widget.dart';
import '../other/product_price_display.dart';
import '../text/app_text.dart';

class HomeProductList extends StatelessWidget {
  final List list;
  final int parentIndex;
  final Function(int)? onPressed;
  final Function()? onPressedExplore;

  const HomeProductList(
      {Key? key,
      required this.list,
      this.onPressed,
      required this.parentIndex,
      this.onPressedExplore,
      required int parentInde})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.sp, bottom: 32.sp),
          child: SizedBox(
            width: double.infinity,
            height: 220.sp,
            child: GetBuilder<ProductController>(
              builder: (value) => ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length >= 4 ? 4 : list.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onPressed?.call(list[index]["id"]);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(
                                left: 16.sp,
                                right: index == list.length - 1 ? 16.sp : 0.sp),
                            width: 136.sp,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    list[index]["images"].isNotEmpty &&
                                            list[index]["images"] != null
                                        ? ImageFiltered(
                                            imageFilter: ImageFilter.blur(
                                                sigmaX: list.length >= 4 &&
                                                        index == 3
                                                    ? 1
                                                    : 0,
                                                sigmaY: list.length >= 4 &&
                                                        index == 3
                                                    ? 1
                                                    : 0),
                                            child: SizedBox(
                                              height: 170.sp,
                                              width: 136.sp,
                                              child: CachedNetworkImage(
                                                cacheManager: CacheManager(
                                                    Config("customCacheKey",
                                                        stalePeriod:
                                                            const Duration(
                                                                days: 15),
                                                        maxNrOfCacheObjects:
                                                            100)),
                                                fit: BoxFit.fill,
                                                fadeOutCurve: Curves.ease,
                                                fadeOutDuration:
                                                    Duration(milliseconds: 100),
                                                imageUrl: isImage(list[index]
                                                        ["images"][0]["name"])
                                                    ? list[index]["images"][0]
                                                        ["name"]
                                                    : list[index]["images"][1]
                                                        ["name"],
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  downloadImage,
                                                  fit: BoxFit.fill,
                                                  height: 170.sp,
                                                  width: 136.sp,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Image.asset(dummyWishlistImage,
                                            height: 170.sp,
                                            width: 136.sp,
                                            fit: BoxFit.fill),
                                    Visibility(
                                      visible: list.length >= 4 && index == 3
                                          ? true
                                          : false,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 60.sp),
                                        child: InkWell(
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            onPressedExplore?.call();
                                          },
                                          child: Container(
                                            height: 28.sp,
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.all(12.sp),
                                            decoration: BoxDecoration(
                                                color:
                                                    whiteColor.withOpacity(0.5),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20.sp))),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.sp),
                                              child: AppText(
                                                text:
                                                    "Explore All".toUpperCase(),
                                                color: homeAppBarColor,
                                                fontSize: 13,
                                                fontFamily: "Clash Display",
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8.sp),
                                  child: Center(
                                    child: AppText(
                                      text: "${list[index]["brand_name"]}\n"
                                          .toUpperCase(),
                                      color: parentIndex % 2 == 0
                                          ? whiteColor
                                          : blackColor,
                                      maxLines: 1,
                                      fontSize: 13,
                                      fontFamily: "Clash Display",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 4.sp),
                                  child: Center(
                                    child: AppText(
                                      text: "${list[index]["name"]}\n",
                                      color: parentIndex % 2 == 0
                                          ? productSubtitleColor
                                          : subtitleColor,
                                      maxLines: 1,
                                      fontSize: 11,
                                      fontFamily: "Clash Display Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                // Price Display
                                Padding(
                                  padding: EdgeInsets.only(top: 4.sp),
                                  child: Center(
                                    child: ProductPriceDisplay(
                                      price: list[index]["displayPrice"] ??
                                          list[index]["basePrice"] ??
                                          list[index]["price"] ??
                                          0,
                                      mrp: list[index]["displayMrp"] ??
                                          list[index]["mrp"],
                                      fontSize: 12,
                                      mrpFontSize: 10,
                                      discountFontSize: 10,
                                      priceColor: parentIndex % 2 == 0
                                          ? whiteColor
                                          : deepGreytextColor,
                                      mrpColor: parentIndex % 2 == 0
                                          ? productSubtitleColor
                                          : textHintColor,
                                      spacing: 4,
                                      isVertical: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ),
        ),
      ],
    );
  }
}
