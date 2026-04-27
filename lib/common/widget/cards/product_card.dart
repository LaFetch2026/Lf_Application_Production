// Reusable Product Card Widget - Consistent product display across all screens
// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/constants.dart';
import '../../../core/utils/image_helper.dart';
import '../../../models/nudge_model.dart';
import '../../../widgets/nudge_badge_row.dart';
import '../other/pounce_wrapper.dart';
import '../other/product_price_display.dart';

/// A reusable product card widget that displays product image, title, brand, and price
/// in a consistent frame across all screens.
class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String brandName;
  final num? price;
  final num? mrp;
  final bool showExpress;
  final VoidCallback? onTap;

  /// Card background color - use for dark/light themes
  final Color backgroundColor;

  /// Text color for product title
  final Color titleColor;

  /// Text color for brand name
  final Color brandColor;

  /// Text color for price
  final Color priceColor;

  /// Text color for MRP (crossed out price)
  final Color mrpColor;

  /// Text color for discount percentage
  final Color discountColor;

  /// Border radius for the card
  final double borderRadius;

  /// Whether to show border around the card
  final bool showBorder;

  /// Border color if showBorder is true
  final Color borderColor;

  /// Image aspect ratio (width/height)
  final double imageAspectRatio;

  /// Card padding
  final EdgeInsets padding;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.brandName = '',
    this.price,
    this.mrp,
    this.showExpress = false,
    this.onTap,
    this.backgroundColor = const Color(0xFFF3F1F1),
    this.titleColor = blackColor,
    this.brandColor = const Color(0xFF6B7280),
    this.priceColor = blackColor,
    this.mrpColor = const Color(0xFF9CA3AF),
    this.discountColor = const Color(0xFF9575CD),
    this.borderRadius = 8.0,
    this.showBorder = false,
    this.borderColor = const Color(0xFFE5E7EB),
    this.imageAspectRatio = 0.75,
    this.padding = const EdgeInsets.all(8.0),
  });

  /// Factory constructor for dark themed cards (used in home screen collections)
  factory ProductCard.dark({
    required String imageUrl,
    required String title,
    String brandName = '',
    num? price,
    num? mrp,
    bool showExpress = false,
    VoidCallback? onTap,
  }) {
    return ProductCard(
      imageUrl: imageUrl,
      title: title,
      brandName: brandName,
      price: price,
      mrp: mrp,
      showExpress: showExpress,
      onTap: onTap,
      backgroundColor: const Color.fromARGB(255, 47, 47, 47),
      titleColor: Colors.white,
      brandColor: Colors.white.withOpacity(0.85),
      priceColor: Colors.white,
      mrpColor: const Color(0xFF9CA3AF),
      discountColor: lightPurpleColor,
    );
  }

  /// Factory constructor for light themed cards (default)
  factory ProductCard.light({
    required String imageUrl,
    required String title,
    String brandName = '',
    num? price,
    num? mrp,
    bool showExpress = false,
    VoidCallback? onTap,
  }) {
    return ProductCard(
      imageUrl: imageUrl,
      title: title,
      brandName: brandName,
      price: price,
      mrp: mrp,
      showExpress: showExpress,
      onTap: onTap,
      backgroundColor: const Color(0xFFF3F1F1),
      titleColor: blackColor,
      brandColor: const Color(0xFF6B7280),
      priceColor: blackColor,
      mrpColor: const Color(0xFF9CA3AF),
      discountColor: const Color(0xFF9575CD),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PounceWrapper(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius.sp),
          border: showBorder ? Border.all(color: borderColor, width: 1) : null,
        ),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius.sp),
                  child: _buildImage(),
                ),
              ),

              SizedBox(height: 6.sp),

              // Product Info Section
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Product Title
                    Text(
                      title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "Clash Display Semibold",
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),

                    // Brand Name
                    if (brandName.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 2.sp),
                        child: Text(
                          brandName.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "Clash Display Regular",
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w400,
                            color: brandColor,
                          ),
                        ),
                      ),

                    // Price Section
                    if (price != null && price! > 0)
                      Padding(
                        padding: EdgeInsets.only(top: 4.sp),
                        child: _buildPriceRow(),
                      ),

                    // Express Delivery Badge
                    if (showExpress)
                      Padding(
                        padding: EdgeInsets.only(top: 2.sp),
                        child: Row(
                          children: [
                            ImageIcon(
                              const AssetImage(truckImage),
                              color: expressText,
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.sp),
                            Text(
                              "Express",
                              style: TextStyle(
                                color: expressText,
                                fontSize: 9.sp,
                                fontFamily: "Clash Display Regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.06),
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.withOpacity(0.5),
          size: 40.sp,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: ImageHelper.toWebP(imageUrl),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      maxHeightDiskCache: 400,
      maxWidthDiskCache: 400,
      memCacheHeight: 400,
      memCacheWidth: 400,
      cacheManager: CacheManager(
        Config(
          "productCardCache",
          stalePeriod: const Duration(days: 15),
          maxNrOfCacheObjects: 100,
        ),
      ),
      placeholder: (context, url) => Container(
        color: Colors.black.withOpacity(0.04),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.black.withOpacity(0.06),
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.grey.withOpacity(0.5),
          size: 40.sp,
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    final numPrice = price is num ? price! : 0;
    final numMrp = mrp is num ? mrp! : 0;

    // Calculate discount percentage
    int? discountPercent;
    if (numPrice > 0 && numMrp > numPrice) {
      discountPercent = (((numMrp - numPrice) / numMrp) * 100).round();
    }

    return Wrap(
      spacing: 4.sp,
      runSpacing: 2.sp,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Selling Price
        Text(
          "₹${numPrice.toStringAsFixed(0)}",
          style: TextStyle(
            fontFamily: "Clash Display Semibold",
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: priceColor,
          ),
        ),

        // MRP (crossed out) - only show if greater than selling price
        if (numMrp > 0 && numMrp > numPrice)
          Text(
            "₹${numMrp.toStringAsFixed(0)}",
            style: TextStyle(
              color: mrpColor,
              fontSize: 9.sp,
              decoration: TextDecoration.lineThrough,
              decorationColor: mrpColor,
              fontFamily: "Clash Display Regular",
            ),
          ),

        // Discount percentage
        if (discountPercent != null && discountPercent > 0)
          Text(
            "$discountPercent% OFF",
            style: TextStyle(
              fontSize: 8.sp,
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w600,
              color: discountColor,
            ),
          ),
      ],
    );
  }
}

/// A grid-based product card for use in GridView layouts
/// This version uses dynamic sizing based on content
class ProductGridCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String brandName;
  final num? price;
  final num? mrp;
  final bool showExpress;
  final VoidCallback? onTap;
  final Color backgroundColor;

  /// Image height - defaults to 160.sp for compact cards
  final double? imageHeight;

  /// Optional nudge badges to display on the top-left of the product image
  final List<Nudge> nudges;

  const ProductGridCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.brandName = '',
    this.price,
    this.mrp,
    this.showExpress = false,
    this.onTap,
    this.backgroundColor = const Color(0xFFF3F1F1),
    this.imageHeight,
    this.nudges = const [],
  });

  @override
  Widget build(BuildContext context) {
    final double imgHeight = imageHeight ?? 160.sp;

    return PounceWrapper(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(6.sp),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Image - fixed height for consistency
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.sp),
                    child: SizedBox(
                      height: imgHeight,
                      width: double.infinity,
                      child: _buildImage(),
                    ),
                  ),

                  SizedBox(height: 6.sp),

                  // Product Title
                  Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "Clash Display Semibold",
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                    ),
                  ),

                  // Brand Name
                  if (brandName.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 2.sp),
                      child: Text(
                        brandName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: "Clash Display Regular",
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),

                  // Price Row
                  Padding(
                    padding: EdgeInsets.only(top: 4.sp),
                    child: _buildPriceSection(),
                  ),

                  // Express Badge
                  if (showExpress)
                    Padding(
                      padding: EdgeInsets.only(top: 3.sp),
                      child: Row(
                        children: [
                          ImageIcon(
                            AssetImage(truckImage),
                            color: expressText,
                            size: 12.sp,
                          ),
                          SizedBox(width: 4.sp),
                          Text(
                            "Express",
                            style: TextStyle(
                              color: expressText,
                              fontSize: 10.sp,
                              fontFamily: "Clash Display Regular",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (nudges.isNotEmpty)
            Positioned(
              top: 6.sp,
              left: 6.sp,
              child: NudgeBadgeRow(
                nudges: nudges,
                maxVisible: 2,
                isExpanded: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.black.withOpacity(0.06),
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.withOpacity(0.5),
          size: 40.sp,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: ImageHelper.toWebP(imageUrl),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheManager: CacheManager(
        Config(
          "productGridCache",
          stalePeriod: const Duration(days: 15),
          maxNrOfCacheObjects: 100,
        ),
      ),
      placeholder: (context, url) => Container(
        color: Colors.black.withOpacity(0.06),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.black.withOpacity(0.06),
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.grey.withOpacity(0.5),
          size: 35.sp,
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    final numPrice = price is num ? price! : 0;
    final numMrp = mrp is num ? mrp! : 0;

    // Case 1: Price is 0 or null - show only MRP (not crossed)
    if (numPrice == 0 && numMrp > 0) {
      return Text(
        "₹ ${numMrp.toStringAsFixed(0)}",
        style: TextStyle(
          fontFamily: "Clash Display Semibold",
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: blackColor,
        ),
      );
    }

    // Case 2: Both price and MRP exist, price < MRP - show with discount
    if (numPrice > 0) {
      return ProductPriceDisplay(
        price: numPrice,
        mrp: numMrp > numPrice ? numMrp : null,
        fontSize: 11,
        mrpFontSize: 10,
        discountFontSize: 9,
        fontWeight: FontWeight.w700,
        priceColor: blackColor,
        mrpColor: const Color(0xFF9CA3AF),
        discountColor: const Color(0xFF9575CD),
        spacing: 4,
      );
    }

    // Case 3: No valid price
    return Text(
      "Price not available",
      style: TextStyle(
        fontFamily: "Clash Display Regular",
        fontSize: 10.sp,
        color: const Color(0xFF6B7280),
      ),
    );
  }
}
