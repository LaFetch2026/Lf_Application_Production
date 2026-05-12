import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/widget/text/app_text.dart';
import '../../../controllers/catalog_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../core/utils/image_helper.dart';
import '../../../screens/Brands/categoryproduct.dart';

/// Shop By Category section widget
/// Displays a horizontal scroll of category cards
class ShopByCategorySection extends StatelessWidget {
  final CatalogController catalogController;
  final HomeController homeController;
  final FirebaseAnalytics analytics;

  const ShopByCategorySection({
    super.key,
    required this.catalogController,
    required this.homeController,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final gender = homeController.homeGenderValue.value;
    final cats = List<Map<String, dynamic>>.from(
      catalogController.catalogByGender[gender] ?? [],
    );

    // Loading guard — show shimmer while catalog data is being fetched
    if (catalogController.isCatalog.value == true) {
      return const _ShopByCategoryShimmer();
    }

    // Empty guard — render nothing when there are no categories
    if (cats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Padding(
            padding: EdgeInsets.only(left: 16.sp, top: 12.sp, bottom: 12.sp),
            child: const AppText(
              text: "SHOP BY CATEGORY",
              fontFamily: "Clash Display Semibold",
              fontWeight: FontWeight.w400,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          // Horizontal scrollable row of category cards — no scrollbar indicator
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding:
                  EdgeInsets.only(left: 16.sp, right: 16.sp, bottom: 12.sp),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cats
                    .map((catalog) => _CategoryCard(
                          catalog: catalog,
                          homeController: homeController,
                          catalogController: catalogController,
                          analytics: analytics,
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single tappable category card rendered inside ShopByCategorySection.
///
/// Displays the category image (via CachedNetworkImage with disk/memory
/// cache limits) and the category name in uppercase below it.  Tapping the
/// card calls catalogController.getSubCategoryProducts and then navigates
/// to CategoryProductScreen with the correct gender context.
class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> catalog;
  final HomeController homeController;
  final CatalogController catalogController;
  final FirebaseAnalytics analytics;

  const _CategoryCard({
    required this.catalog,
    required this.homeController,
    required this.catalogController,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final categoryId = catalog['id'];
    final categoryName = (catalog['name'] ?? 'Category').toString();
    final imageUrl = catalog['image']?.toString() ?? '';

    return GestureDetector(
      onTap: () async {
        await catalogController.getSubCategoryProducts(categoryId);

        Get.to(
          () => CategoryProductScreen(
            categoryName: categoryName,
            screen: 'category',
            genderName: homeController.genderText.value,
            categoryId: categoryId,
            brandId: 0,
            genderType: homeController.homeGenderValue.value,
            categoryList: const [],
            collectionIds: const [],
            type: '',
            title: '',
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category image container
            Container(
              width: 100.sp,
              height: 120.sp,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 235, 233, 233),
                borderRadius: BorderRadius.circular(16.sp),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.sp),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: ImageHelper.toWebP(imageUrl),
                        fit: BoxFit.cover,
                        maxWidthDiskCache: 300,
                        maxHeightDiskCache: 300,
                        memCacheWidth: 300,
                        memCacheHeight: 300,
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.black.withOpacity(0.04),
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.withOpacity(0.5),
                            size: 32.sp,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.black.withOpacity(0.04),
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey.withOpacity(0.5),
                          size: 32.sp,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 8.sp),

            // Category name in uppercase
            SizedBox(
              width: 100.sp,
              child: AppText(
                text: (catalog['name'] ?? '').toString().toUpperCase(),
                color: Colors.black,
                fontSize: 12.sp,
                maxLines: 2,
                textAlign: TextAlign.center,
                fontFamily: 'Clash Display',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A shimmer placeholder that matches the height and card dimensions of the
/// loaded ShopByCategorySection row.
///
/// Shown while CatalogController.isCatalog is `true` (i.e. while the
/// category list is being fetched from the network).
class _ShopByCategoryShimmer extends StatelessWidget {
  const _ShopByCategoryShimmer();

  @override
  Widget build(BuildContext context) {
    // Total row height: image (120.sp) + gap (8.sp) + label area (~40.sp)
    final double rowHeight = 168.sp;

    return SizedBox(
      height: rowHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(left: 16.sp),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              children: List.generate(5, (index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100.sp,
                        height: 120.sp,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.sp),
                        ),
                      ),
                      SizedBox(height: 8.sp),
                      Container(
                        width: 80.sp,
                        height: 12.sp,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.sp),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
