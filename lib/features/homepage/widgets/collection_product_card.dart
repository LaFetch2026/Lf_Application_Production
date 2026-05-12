import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/widget/other/pounce_wrapper.dart';
import '../../../core/utils/image_helper.dart';
import '../../../widgets/nudge_badge_row.dart';
import '../models/product_card_model.dart';

/// New product card design based on Figma
/// - Image takes ~70% of card height
/// - Product name (bold, large)
/// - Subtle brand label (smaller, lighter)
/// - Price with discount
/// - Add-to-bag button (circular with +)
/// - Heart icon (favorite)
/// - Rounded corners
class CollectionProductCard extends StatelessWidget {
  final ProductCardModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToBag;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const CollectionProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToBag,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: PounceWrapper(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.sp),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section (~70% of card height)
              Expanded(
                flex: 7,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12.sp),
                      ),
                      child: _buildImage(),
                    ),
                    // Favorite button (heart icon)
                    if (onFavorite != null)
                      Positioned(
                        top: 8.sp,
                        right: 8.sp,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onFavorite!();
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.sp),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18.sp,
                              color: isFavorite ? Colors.red : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    // Nudge badges
                    if (product.nudges != null && product.nudges!.isNotEmpty)
                      Positioned(
                        top: 8.sp,
                        left: 8.sp,
                        child: NudgeBadgeRow(
                          nudges: product.nudges!,
                          maxVisible: 2,
                          isExpanded: true,
                        ),
                      ),
                  ],
                ),
              ),
              // Content section (~30% of card height)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Product name (bold, large)
                      Text(
                        product.title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: "Clash Display Semibold",
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      // Brand label (subtle)
                      if (product.brand.isNotEmpty)
                        Text(
                          product.brand.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "Clash Display Regular",
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                            height: 1.2,
                          ),
                        ),
                      // Price row
                      _buildPriceRow(),
                    ],
                  ),
                ),
              ),
              // Add-to-bag button (circular with +)
              if (onAddToBag != null)
                Positioned(
                  bottom: 8.sp,
                  right: 8.sp,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onAddToBag!();
                    },
                    child: Container(
                      width: 36.sp,
                      height: 36.sp,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (product.imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.04),
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.withOpacity(0.5),
          size: 40.sp,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: ImageHelper.toWebP(product.imageUrl),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      maxHeightDiskCache: 500,
      maxWidthDiskCache: 500,
      memCacheHeight: 500,
      memCacheWidth: 500,
      cacheManager: CacheManager(
        Config(
          "collectionProductCardCache",
          stalePeriod: const Duration(days: 15),
          maxNrOfCacheObjects: 100,
        ),
      ),
      placeholder: (context, url) => Container(
        color: Colors.black.withOpacity(0.04),
        child: Center(
          child: Container(
            width: 20.sp,
            height: 20.sp,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.sp),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.black.withOpacity(0.04),
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.grey.withOpacity(0.5),
          size: 40.sp,
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    final numPrice = product.price;
    final numMrp = product.mrp;
    final discount = product.discountPercentage;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current price (bold)
        Text(
          "₹${numPrice.toInt()}",
          style: TextStyle(
            fontFamily: "Clash Display Semibold",
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        // MRP (struck through, lighter)
        if (numMrp != null && numMrp > numPrice) ...[
          SizedBox(width: 6.sp),
          Text(
            "₹${numMrp.toInt()}",
            style: TextStyle(
              fontFamily: "Clash Display Regular",
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black38,
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.black38,
            ),
          ),
        ],
        // Discount percentage
        if (discount != null && discount > 0) ...[
          SizedBox(width: 6.sp),
          Text(
            "($discount% off)",
            style: TextStyle(
              fontFamily: "Clash Display",
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9575CD),
            ),
          ),
        ],
      ],
    );
  }
}
