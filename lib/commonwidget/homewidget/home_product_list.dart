import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:lafetch/controller/product_controller.dart';
import '../../utils/constants.dart';
import '../app_text.dart';
import '../common_widgets.dart';

class HomeProductList extends StatelessWidget {
  final List list;
  final int parentIndex;
  final Function(int)? onPressed;

  const HomeProductList(
      {Key? key, required this.list, this.onPressed, required this.parentIndex})
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
                            margin: EdgeInsets.only(
                                left: 16.sp,
                                right: index == list.length - 1 ? 16.sp : 0.sp),
                            width: 136.sp,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                list[index]["images"].isNotEmpty &&
                                        list[index]["images"] != null
                                    ? SizedBox(
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
                                              ? list[index]["images"][0]["name"]
                                              : list[index]["images"][1]
                                                  ["name"],
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            downloadImage,
                                            fit: BoxFit.cover,
                                            height: 170.sp,
                                            width: 136.sp,
                                          ),
                                        ),
                                      )
                                    : Image.asset(dummyWishlistImage,
                                        height: 170.sp,
                                        width: 136.sp,
                                        fit: BoxFit.cover),
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
                                      fontFamily: "Franklin Gothic",
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
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
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
