import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:lafetch/controller/product_controller.dart';
import '../../utils/constants.dart';
import '../app_text.dart';
import '../common_widgets.dart';

class DemoProductList extends StatelessWidget {
  final String text;
  final String text1;
  final double height;
  final bool visibleheart;
  final bool visibleViewAll;
  final List list;
  final String fontFamily;
  final Color textColor;
  final double leftPadding;
  final ScrollController controller;
  final Function(int, String)? onPressed;
  final Function? onPressedExpress;
  final Function? onPressedViewAll;
  final Function(int, int)? onPressedHeart;
  final bool visibleSubtitle;

  const DemoProductList(
      {Key? key,
      required this.text,
      this.text1 = "",
      required this.height,
      required this.list,
      this.visibleViewAll = false,
      this.visibleSubtitle = false,
      this.textColor = blackColor,
      this.leftPadding = 16,
      this.visibleheart = false,
      this.fontFamily = "Franklin Gothic",
      required this.controller,
      this.onPressed,
      this.onPressedViewAll,
      this.onPressedHeart,
      this.onPressedExpress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.sp, left: leftPadding.sp),
              child: AppText(
                text: text,
                fontFamily: "Franklin Gothic Semibold",
                color: blackColor,
                fontSize: 18,
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 0,
              ),
            ),
            visibleViewAll
                ? GestureDetector(
                    onTap: () {
                      onPressedViewAll?.call();
                    },
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 12.sp,
                            right: 12.sp,
                            left: 16.sp,
                            bottom: 2.sp),
                        child: Image.asset(
                          rightBlackArrow,
                          height: 30.sp,
                          width: 30.sp,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 0,
                  ),
          ],
        ),
        visibleSubtitle
            ? Padding(
                padding: EdgeInsets.only(left: leftPadding.sp),
                child: AppText(
                  text: text1,
                  fontFamily: "Franklin Gothic Regular",
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                ),
              )
            : SizedBox(
                height: 0,
              ),
        Padding(
          padding:
              EdgeInsets.only(left: leftPadding.sp, top: 16.sp, bottom: 16.sp),
          child: SizedBox(
            width: double.infinity,
            height: height,
            child: PrimaryScrollController(
                controller: controller,
                scrollDirection: Axis.horizontal,
                child: GetBuilder<ProductController>(
                  builder: (value) => ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      controller: controller,
                      physics: const BouncingScrollPhysics(),
                      itemCount: visibleViewAll
                          ? list.length > 5
                              ? 5
                              : list.length
                          : list.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (ctx, index) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                onPressed?.call(list[index]["id"],
                                    list[index]["brand_name"]);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.only(right: 5.sp),
                                width: 122.sp,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(children: [
                                      list[index]["images"].isNotEmpty &&
                                              list[index]["images"] != null
                                          ? SizedBox(
                                              height: 150.sp,
                                              width: 122.sp,
                                              child: CachedNetworkImage(
                                                cacheManager: CacheManager(
                                                    Config("customCacheKey",
                                                        stalePeriod:
                                                            const Duration(
                                                                days: 15),
                                                        maxNrOfCacheObjects:
                                                            100)),
                                                fit: BoxFit.cover,
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
                                                  fit: BoxFit.cover,
                                                  height: 150.sp,
                                                  width: 122.sp,
                                                ),
                                              ),
                                            )
                                          : Image.asset(dummyWishlistImage,
                                              height: 150.sp,
                                              width: 122.sp,
                                              fit: BoxFit.cover),
                                      GestureDetector(
                                        onTap: () {
                                          onPressedHeart?.call(
                                              list[index]["id"], index);
                                        },
                                        child: Visibility(
                                          visible: visibleheart,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.sp,
                                                vertical: 10.sp),
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: InkWell(
                                                child: SizedBox(
                                                  height: 24.sp,
                                                  width: 24.sp,
                                                  child: CircleAvatar(
                                                      // radius: 12.0.sp,
                                                      backgroundColor:
                                                          whiteColor,
                                                      child: list[index]
                                                              ["wishlisted"]
                                                          ? Image.asset(
                                                              wishlistSelectImage,
                                                              height: 18.sp,
                                                              width: 18.sp,
                                                            )
                                                          : Image.asset(
                                                              heartImage,
                                                              height: 18.sp,
                                                              width: 18.sp,
                                                            )),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.sp, vertical: 5.sp),
                                      child: AppText(
                                        text: "${list[index]["brand_name"]}\n"
                                            .toUpperCase(),
                                        color: nameText,
                                        maxLines: 1,
                                        fontSize: 13,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.sp, vertical: 2.sp),
                                      child: AppText(
                                        text: "${list[index]["name"]}\n",
                                        color: Color(0xFF6B7280),
                                        maxLines: 1,
                                        fontSize: 11,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 8.sp, left: 4.sp, right: 3.sp),
                                      child: Row(
                                        children: [
                                          Visibility(
                                            visible: list[index]["mrp"] != null
                                                ? true
                                                : false,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(right: 5.sp),
                                              child: Text(
                                                "\u{20B9} ${list[index]["mrp"] ?? ""}",
                                                style: TextStyle(
                                                  color: textHintColor,
                                                  fontSize: 11.sp,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                          AppText(
                                            text:
                                                "\u{20B9} ${list[index]["price"] ?? ""}",
                                            color: deepGreytextColor,
                                            maxLines: 2,
                                            fontSize: 11,
                                            fontFamily: "Franklin Gothic",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                )),
          ),
        ),
      ],
    );
  }
}
