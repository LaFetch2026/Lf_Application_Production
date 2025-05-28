import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:lafetch/common/widget/other/common_widget.dart';
import 'package:lafetch/common/widget/text/app_text.dart';

import 'package:lafetch/controllers/product_controller.dart';
import 'package:lafetch/core/constant/constants.dart';


class BrandProductList extends StatelessWidget {
  final List list;
  final Function(int, String)? onPressed;
  final double radius;

  const BrandProductList({
    Key? key,
    required this.list,
    this.radius = 8.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.sp, bottom: 16.sp),
          child: SizedBox(
            width: double.infinity,
            height: 220.sp,
            child: GetBuilder<ProductController>(
              builder: (value) => ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            onPressed?.call(
                                list[index]["id"], list[index]["name"]);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(
                                left: 16.sp,
                                right: list.length - 1 == index ? 16.sp : 0.sp),
                            width: 136.sp,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                list[index]["images"].isNotEmpty &&
                                        list[index]["images"] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(radius.sp),
                                            topRight:
                                                Radius.circular(radius.sp)),
                                        child: Container(
                                          height: 170.sp,
                                          width: 136.sp,
                                          child: CachedNetworkImage(
                                            cacheManager: CacheManager(Config(
                                                "customCacheKey",
                                                stalePeriod:
                                                    const Duration(days: 15),
                                                maxNrOfCacheObjects: 100)),
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
                                              height: 170.sp,
                                              width: 136.sp,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Image.asset(dummyWishlistImage,
                                        height: 170.sp,
                                        width: 136.sp,
                                        fit: BoxFit.cover),
                                Padding(
                                  padding: EdgeInsets.only(top: 8.sp),
                                  child: AppText(
                                    text: "${list[index]["name"]}\n",
                                    color: productSubtitleColor,
                                    maxLines: 1,
                                    fontSize: 11,
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8.sp),
                                  child: Row(
                                    mainAxisAlignment: radius == 0
                                        ? MainAxisAlignment.center
                                        : MainAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible: list[index]["mrp"] != null
                                            ? true
                                            : false,
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 6.sp),
                                          child: Text(
                                            "\u{20B9} ${list[index]["mrp"] ?? ""}",
                                            style: TextStyle(
                                              color: searchTextColor,
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
                                        color: whiteColor,
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
            ),
          ),
        ),
      ],
    );
  }
}
