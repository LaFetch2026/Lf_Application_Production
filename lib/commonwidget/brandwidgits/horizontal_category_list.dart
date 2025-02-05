import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../utils/constants.dart';
import '../app_text.dart';
import '../common_widgets.dart';

class HorizontalCategoryList extends StatelessWidget {
  final Function(int, String)? onPressed;
  final List list;
  final Function(int, int)? onPressedHeart;

  const HorizontalCategoryList({
    Key? key,
    this.onPressed,
    this.onPressedHeart,
    required this.list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 250.sp,
          child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        onPressed?.call(
                            list[index]["id"], list[index]["brand_name"]);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(left: 16.sp),
                        width: 136.sp,
                        height: 250.sp,
                        child: Container(
                          color: whiteColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  /*  list[index]["images"].isNotEmpty &&
                                          list[index]["images"] != null
                                      ? SizedBox(
                                          width: 136.sp,
                                          height: 170.sp,
                                          child: CachedNetworkImage(
                                            cacheManager: CacheManager(Config(
                                                "customCacheKey",
                                                stalePeriod:
                                                    const Duration(days: 15),
                                                maxNrOfCacheObjects: 100)),
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
                                              width: 136.sp,
                                              height: 170.sp,
                                            ),
                                          ),
                                        )
                                      : */
                                  Image.asset(dummyWishlistImage,
                                      width: 136.sp,
                                      height: 170.sp,
                                      fit: BoxFit.cover),
                                  Visibility(
                                    visible:
                                        list[index]["aggregated_rating"] != 0
                                            ? true
                                            : false,
                                    child: Positioned(
                                        bottom: 10.sp,
                                        right: 8.sp,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0.sp),
                                          height: 24.sp,
                                          width: 47.sp,
                                          decoration: BoxDecoration(
                                              color: const Color(0x80FFFFFF),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(80.sp))),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2.sp),
                                                child: Image.asset(
                                                  ratingImage,
                                                  height: 10.sp,
                                                  width: 10.sp,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 1.sp, left: 2.sp),
                                                child: AppText(
                                                  text: list[index]
                                                          ["aggregated_rating"]
                                                      .toString(),
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                  color: homeAppBarColor,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),

                                  /*  GestureDetector(
                                    onTap: () {
                                      onPressedHeart?.call(
                                          list[index]["id"], index);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.sp, vertical: 10.sp),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: InkWell(
                                          child: SizedBox(
                                            height: 24.sp,
                                            width: 24.sp,
                                            child: CircleAvatar(
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
                                                      color: bottomnavBack,
                                                      width: 18.sp,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ), */
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 8.sp, left: 1.sp, right: 1.sp),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 116.sp,
                                      child: AppText(
                                        text: "${list[index]["brand_name"]}"
                                            .toUpperCase(),
                                        color: homeAppBarColor,
                                        maxLines: 1,
                                        fontSize: 13,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        onPressedHeart?.call(
                                            list[index]["id"], index);
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2.sp),
                                        child: list[index]["wishlisted"]
                                            ? SvgPicture.asset(redHeartSvgImage,
                                                // ignore: deprecated_member_use
                                                color: redColor,
                                                height: 12.sp,
                                                width: 12.sp,
                                                fit: BoxFit.cover)
                                            : SvgPicture.asset(heartSvgImage,
                                                height: 12.sp,
                                                width: 12.sp,
                                                fit: BoxFit.cover),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 4.sp, left: 1.sp, right: 1.sp),
                                child: AppText(
                                  text: "${list[index]["name"]}",
                                  color: appBarColor,
                                  maxLines: 1,
                                  fontSize: 11,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 8.sp, left: 1.sp, right: 1.sp),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Visibility(
                                      visible: list[index]["mrp"] != null
                                          ? true
                                          : false,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 4.sp),
                                        child: Text(
                                          "\u{20B9} ${list[index]["mrp"]}",
                                          style: TextStyle(
                                            color: subtitleColor,
                                            fontSize: 11.sp,
                                            decoration:
                                                TextDecoration.lineThrough,
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
                                      color: homeAppBarColor,
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
                    ),
                  ],
                );
              }),
        ),
      ],
    );
  }
}
