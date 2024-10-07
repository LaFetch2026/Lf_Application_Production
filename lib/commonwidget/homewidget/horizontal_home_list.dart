import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:lafetch/controller/product_controller.dart';
import '../../utils/constants.dart';
import '../app_text.dart';
import '../common_widgets.dart';

class HorizontalHomeList extends StatelessWidget {
  final String text;
  final double height;
  final bool visibleExpress;
  final bool visibleheart;
  final List list;
  final String fontFamily;
  final Color textColor;
  final double leftPadding;
  final ScrollController controller;
  final Function(int)? onPressed;
  final Function? onPressedExpress;
  final Function(int, int)? onPressedHeart;

  const HorizontalHomeList(
      {Key? key,
      required this.text,
      required this.height,
      required this.visibleExpress,
      required this.list,
      this.textColor = blackColor,
      this.leftPadding = 16,
      this.visibleheart = false,
      this.fontFamily = "Franklin Gothic",
      required this.controller,
      this.onPressed,
      this.onPressedHeart,
      this.onPressedExpress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.sp, left: leftPadding.sp),
          child: AppText(
            text: text,
            fontFamily: fontFamily,
            color: textColor,
            fontSize: 16,
          ),
        ),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: leftPadding.sp, vertical: 16),
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
                      itemCount: list.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (ctx, index) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                onPressed?.call(list[index]["id"]);
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
                                      Visibility(
                                        visible: visibleheart,
                                        child: Positioned(
                                          right: 0,
                                          child: IconButton(
                                            icon: CircleAvatar(
                                                radius: 12.0,
                                                backgroundColor: whiteColor,
                                                child: list[index]["wishlisted"]
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
                                            onPressed: () {
                                              onPressedHeart?.call(
                                                  list[index]["id"], index);
                                            },
                                          ),
                                        ),
                                      ),
                                    ]),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.sp, vertical: 5.sp),
                                      child: AppText(
                                        text: "${list[index]["name"]}\n",
                                        color: nameText,
                                        maxLines: 2,
                                        fontSize: 11,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 10.sp, left: 10.sp, right: 1.sp),
                                      child: Row(
                                        children: [
                                          AppText(
                                            text:
                                                "\u{20B9} ${list[index]["price"] ?? ""}",
                                            color: deepGreytextColor,
                                            maxLines: 2,
                                            fontSize: 11,
                                            fontFamily: "Franklin Gothic",
                                            fontWeight: FontWeight.w500,
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 5.sp),
                                            child: Text(
                                              "\u{20B9} ${list[index]["mrp"] ?? ""}",
                                              style: TextStyle(
                                                color: textHintColor,
                                                fontSize: 11.sp,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: visibleExpress,
                                      child: GestureDetector(
                                          onTap: () {
                                            onPressedExpress?.call();
                                          },
                                          child: list[index]["express_delivery"]
                                              ? Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10.sp,
                                                      left: 10.sp,
                                                      right: 10.sp),
                                                  child: Row(
                                                    children: [
                                                      ImageIcon(
                                                        AssetImage(truckImage),
                                                        color: expressText,
                                                        size: 14.sp,
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    5.sp),
                                                        child: AppText(
                                                          text: "Express",
                                                          color: expressText,
                                                          maxLines: 2,
                                                          fontSize: 11,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : SizedBox(
                                                  height: 0,
                                                )),
                                    )
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
