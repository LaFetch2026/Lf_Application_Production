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
    required Axis scrollDirection,
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
                  final item = list[index];

                  final id = item["id"];
                  final name = item["name"] ?? "";

                  // ⭐ NEW PRICE FIELDS ⭐
                  final num price = item["displayPrice"] ?? 0;
                  final num? mrp = item["displayMrp"]; // null → hide MRP

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          onPressed?.call(id, name);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(
                            left: 16.sp,
                            right: list.length - 1 == index ? 16.sp : 0.sp,
                          ),
                          width: 136.sp,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ------- IMAGE -------
                              (item["images"] != null &&
                                      item["images"] is List &&
                                      item["images"].isNotEmpty &&
                                      item["images"][0] != null &&
                                      item["images"][0]["name"] != null &&
                                      item["images"][0]["name"].toString().trim().isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(radius.sp),
                                        topRight: Radius.circular(radius.sp),
                                      ),
                                      child: SizedBox(
                                        height: 170.sp,
                                        width: 136.sp,
                                        child: CachedNetworkImage(
                                          cacheManager: CacheManager(Config(
                                            "brandProductImagesCache",
                                            stalePeriod:
                                                const Duration(days: 15),
                                            maxNrOfCacheObjects: 200,
                                          )),
                                          fit: BoxFit.cover,
                                          fadeOutCurve: Curves.ease,
                                          fadeOutDuration:
                                              const Duration(milliseconds: 100),
                                          imageUrl: item["images"][0]["name"].toString(),
                                          placeholder: (context, url) => Container(
                                            height: 170.sp,
                                            width: 136.sp,
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(colorPrimary),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) {
                                            print("❌ [BrandProductList] Image load failed");
                                            print("   URL: $url");
                                            print("   Error: $error");
                                            return Container(
                                              height: 170.sp,
                                              width: 136.sp,
                                              color: Colors.grey[200],
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.image_not_supported,
                                                    size: 40.sp,
                                                    color: Colors.grey[400]
                                                  ),
                                                  SizedBox(height: 4.sp),
                                                  Text(
                                                    'Image not available',
                                                    style: TextStyle(
                                                      fontSize: 9.sp,
                                                      color: Colors.grey[500],
                                                      fontFamily: "Clash Display Regular",
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : Image.asset(
                                      dummyWishlistImage,
                                      height: 170.sp,
                                      width: 136.sp,
                                      fit: BoxFit.cover,
                                    ),

                              // ------- PRODUCT NAME -------
                              Padding(
                                padding: EdgeInsets.only(top: 8.sp),
                                child: AppText(
                                  text: "$name\n",
                                  color: productSubtitleColor,
                                  maxLines: 1,
                                  fontSize: 11,
                                  fontFamily: "Clash Display Regular",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              // ⭐ ------- PRICE SECTION (Updated) ------- ⭐
                              /// PRICE ROW (MRP + Selling Price)
                              Padding(
                                padding: EdgeInsets.only(top: 8.sp),
                                child: Row(
                                  mainAxisAlignment: (item["displayMrp"] == null)
                                      ? MainAxisAlignment
                                          .start // Price alone → normal left alignment
                                      : MainAxisAlignment
                                          .start, // MRP + Price → normal left alignment
                                  children: [
                                    // ---------- MRP ----------
                                    if (item["displayMrp"] != null)
                                      Padding(
                                        padding: EdgeInsets.only(right: 6.sp),
                                        child: Text(
                                          "₹ ${item["displayMrp"]}",
                                          style: TextStyle(
                                            color: searchTextColor,
                                            fontSize: 11.sp,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontFamily: "Clash Display Regular",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),

                                    // ---------- PRICE ----------
                                    Text(
                                      "₹ ${item["displayPrice"] ?? 0}",
                                      style: TextStyle(
                                        color: whiteColor,
                                        fontSize: 11.sp,
                                        fontFamily: "Clash Display",
                                        fontWeight: FontWeight.w500,
                                      ),
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
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
