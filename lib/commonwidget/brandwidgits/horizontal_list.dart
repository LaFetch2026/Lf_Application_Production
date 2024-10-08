import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/constants.dart';
import '../app_text.dart';
import '../common_widgets.dart';

class HorizontalBrandList extends StatelessWidget {
  final String text;
  final Function(int)? onPressed;
  final List list;
  final ScrollController controller;
  final Function? onPressedExpress;
  final Function(int, int)? onPressedHeart;

  const HorizontalBrandList({
    Key? key,
    required this.text,
    this.onPressed,
    this.onPressedHeart,
    this.onPressedExpress,
    required this.controller,
    required this.list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.sp, left: 16.sp),
          child: AppText(
            text: text,
            fontFamily: "Franklin Gothic",
            fontWeight: FontWeight.w500,
            color: whiteBorderColor,
            fontSize: 16,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
          child: SizedBox(
            width: double.infinity,
            height: 250.sp,
            child: PrimaryScrollController(
              controller: controller,
              scrollDirection: Axis.horizontal,
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  controller: controller,
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
                            height: 250.sp,
                            child: Container(
                              color: whiteBorderColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
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
                                                /*  progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                                ), */
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
                                                  backgroundColor: whiteColor,
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
                                                          color: bottomnavBack,
                                                          width: 18.sp,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                          padding: EdgeInsets.only(left: 5.sp),
                                          child: Text(
                                            "\u{20B9} ${list[index]["mrp"]}",
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
                                  list[index]["express_delivery"]
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              top: 10.sp,
                                              left: 10.sp,
                                              right: 10.sp,
                                              bottom: 5.sp),
                                          child: Row(
                                            children: [
                                              ImageIcon(
                                                AssetImage(truckImage),
                                                color: expressText,
                                                size: 14.sp,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  onPressedExpress!.call();
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5.sp),
                                                  child: AppText(
                                                    text: "Express",
                                                    color: expressText,
                                                    maxLines: 2,
                                                    fontSize: 11,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0,
                                        )
                                ],
                              ),
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
