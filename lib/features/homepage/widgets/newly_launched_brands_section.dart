import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../../controllers/brand_controller.dart';
import '../../../core/utils/image_helper.dart';
import '../../../screens/Brands/allbrandscreen.dart';

/// Newly Launched Brands section widget
/// Displays a horizontal scroll of newly launched brand circles
class NewlyLaunchedBrandsSection extends StatelessWidget {
  final BrandController brandController;
  final FirebaseAnalytics analytics;

  const NewlyLaunchedBrandsSection({
    super.key,
    required this.brandController,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading state
      if (brandController.isLoadingNewlyLaunched.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14.sp,
                      width: 50.sp,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(4.sp),
                      ),
                    ),
                    SizedBox(height: 6.sp),
                    Container(
                      height: 20.sp,
                      width: 150.sp,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(4.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 100.sp,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: EdgeInsets.only(left: 16.sp),
                    child: Container(
                      width: 80.sp,
                      height: 80.sp,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }

      // Show empty state if no brands
      if (brandController.newlyLaunchedBrands.isEmpty) {
        return const SizedBox.shrink();
      }

      final brands = brandController.newlyLaunchedBrands;
      final currentPage = brandController.newlyLaunchedPage.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "JUST IN",
                  style: TextStyle(
                    fontFamily: "Clash Display Regular",
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "NEWLY LAUNCHED BRANDS",
                      style: TextStyle(
                        fontFamily: "Clash Display Semibold",
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12.sp),
          SizedBox(
            height: 110.sp,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final brandId = brand['id'] is int
                    ? brand['id'] as int
                    : int.tryParse(brand['id']?.toString() ?? '') ?? 0;
                final brandName = brand['name']?.toString() ?? '';
                final logoUrl = brand['logo']?.toString() ?? '';

                return GestureDetector(
                  onTap: () async {
                    await analytics.logEvent(
                      name: 'newly_launched_brand_tap',
                      parameters: {
                        'brand_id': brandId,
                        'brand_name': brandName,
                        'page': currentPage,
                      },
                    );
                    Get.to(
                      () => AllBrandScreen(
                        id: brandId,
                        screen: 'brand',
                        slug: '',
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.sp),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 80.sp,
                          width: 80.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: ClipOval(
                            child: logoUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: ImageHelper.toWebP(logoUrl),
                                    height: 72.sp,
                                    width: 72.sp,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: Colors.black.withOpacity(0.04),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: Colors.black.withOpacity(0.04),
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 24.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.black.withOpacity(0.04),
                                    child: Icon(
                                      Icons.store,
                                      size: 24.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 6.sp),
                        SizedBox(
                          width: 80.sp,
                          child: Text(
                            brandName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Clash Display Regular",
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.sp),
        ],
      );
    });
  }
}
