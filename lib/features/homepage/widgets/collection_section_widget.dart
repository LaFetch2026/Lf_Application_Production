import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/collection_item_model.dart';
import 'collection_product_card.dart';

/// Collection section widget based on Figma design
/// - Horizontal scrollable or grid layout of product cards
/// - Section header with title
/// - "View All" button
/// - Consistent spacing and card proportions from Figma
class CollectionSectionWidget extends StatelessWidget {
  final CollectionItemModel collection;
  final VoidCallback? onViewAll;
  final Function(int productId)? onProductTap;
  final Function(int productId)? onAddToBag;
  final Function(int productId)? onFavorite;
  final Set<int> favoriteProductIds;

  const CollectionSectionWidget({
    super.key,
    required this.collection,
    this.onViewAll,
    this.onProductTap,
    this.onAddToBag,
    this.onFavorite,
    this.favoriteProductIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (collection.products.isEmpty) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Container(
        color: collection.darkTheme ? Colors.black : Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Row(
                children: [
                  // Title
                  Expanded(
                    child: Text(
                      collection.title.toUpperCase(),
                      style: TextStyle(
                        fontFamily: "Clash Display Semibold",
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: collection.darkTheme ? Colors.white : Colors.black,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  // View All button
                  if (onViewAll != null)
                    GestureDetector(
                      onTap: onViewAll,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.sp,
                          vertical: 6.sp,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20.sp),
                          border: Border.all(
                            color: collection.darkTheme ? Colors.white : Colors.black,
                            width: 1.sp,
                          ),
                        ),
                        child: Text(
                          "View All",
                          style: TextStyle(
                            fontFamily: "Clash Display",
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: collection.darkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Subtitle if present
            if (collection.subtitle != null && collection.subtitle!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  left: 16.sp,
                  right: 16.sp,
                  top: 6.sp,
                ),
                child: Text(
                  collection.subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Clash Display Regular",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: collection.darkTheme
                        ? Colors.white.withOpacity(0.85)
                        : Colors.black.withOpacity(0.75),
                  ),
                ),
              ),
            SizedBox(height: 12.sp),
            // Product cards - horizontal scroll
            SizedBox(
              height: 280.sp, // Card height based on Figma proportions
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.sp),
                physics: const BouncingScrollPhysics(),
                itemCount: collection.products.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.sp),
                itemBuilder: (context, index) {
                  final product = collection.products[index];
                  final cardWidth = 160.sp; // Card width from Figma

                  return SizedBox(
                    width: cardWidth,
                    child: CollectionProductCard(
                      product: product,
                      onTap: () => onProductTap?.call(product.id),
                      onAddToBag: () => onAddToBag?.call(product.id),
                      onFavorite: () => onFavorite?.call(product.id),
                      isFavorite: favoriteProductIds.contains(product.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
