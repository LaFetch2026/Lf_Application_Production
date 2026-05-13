import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/image_helper.dart';

enum PremiumProductCardTheme { light, dark }

/// Reusable premium product card for condensed/full usage.
/// Designed to support both light and dark visual treatments.
class PremiumProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String brand;
  final num price;
  final num mrp;

  /// When set from API (e.g. `discountPercent`), shown even if mrp maths differ.
  final int? discountPercent;
  final PremiumProductCardTheme theme;
  final bool condensed;
  final bool showWishlist;
  final bool showAdd;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onTap;

  const PremiumProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.brand,
    required this.price,
    required this.mrp,
    this.discountPercent,
    this.theme = PremiumProductCardTheme.light,
    this.condensed = false,
    this.showWishlist = false,
    this.showAdd = false,
    this.onWishlistTap,
    this.onAddTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = theme == PremiumProductCardTheme.dark;
    final Color cardBg = isDark ? const Color(0xFF11131A) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF353535);
    final Color brandColor =
        isDark ? const Color(0xFFC9CDD7) : const Color(0xFF9B9494);
    final Color mrpColor =
        isDark ? const Color(0xFFA2A7B2) : const Color(0xFF353535);
    final Color discountColor =
        isDark ? const Color(0xFFA8AFD8) : const Color(0xFFA3A7C9);

    final double imageHeight = condensed ? 168.sp : 188.sp;
    final double titleSize = condensed ? 14.sp : 17.sp;
    final double brandSize = condensed ? 8.sp : 11.sp;
    final double priceSize = condensed ? 12.sp : 18.sp;
    final double mrpSize = condensed ? 16.sp : 12.sp;
    final double discountSize = condensed ? 8.sp : 11.sp;

    final int computedDiscount =
        (mrp > price && mrp > 0) ? (((mrp - price) / mrp) * 100).round() : 0;
    final int? apiDiscount = discountPercent != null && discountPercent! > 0
        ? discountPercent
        : null;
    final int effectiveDiscount =
        apiDiscount ?? (computedDiscount > 0 ? computedDiscount : 0);
    final bool showMrpStrike = mrp > price && mrp > 0;
    final bool showOffLabel = effectiveDiscount > 0;

    String _formatPrice(num value) {
      final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      );
      return formatter.format(value);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.sp), //IDHAR
                  topRight: Radius.circular(10.sp)),
              child: SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(child: _CardImage(imageUrl: imageUrl)),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 90.sp,
                        height: 90.sp,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8.sp),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            stops: const [0.0, 0.25, 0.26, 1.0],
                            colors: [
                              Colors.white.withValues(alpha: 0.75),
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.05),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (showWishlist)
                      Positioned(
                        top: 8.sp,
                        right: 8.sp,
                        child: _CircleIconButton(
                          icon: Icons.favorite_border,
                          iconColor: const Color(0xFFEAA3B4),
                          onTap: onWishlistTap,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.sp, 7.sp, 10.sp, 0.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'InstrumentSans',
                            fontWeight: FontWeight.w600,
                            fontSize: titleSize,
                            color: titleColor,
                            height: 1.6,
                          ),
                        ),
                      ),
                      if (showAdd)
                        Padding(
                          padding: EdgeInsets.only(left: 8.sp),
                          child: _CircleIconButton(
                            icon: Icons.add,
                            iconColor:
                                isDark ? Colors.white : const Color(0xFF32343B),
                            borderColor: isDark
                                ? Colors.white.withValues(alpha: 0.35)
                                : const Color(0xFFE2E5ED),
                            onTap: onAddTap,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'InstrumentSans',
                      fontWeight: FontWeight.bold,
                      fontSize: brandSize,
                      color: brandColor,
                      height: 0.8,
                    ),
                  ),
                  Wrap(
                    spacing: 7.sp,
                    runSpacing: 4.sp,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _formatPrice(price),
                        // _formatPrice(${price.toStringAsFixed(0)}),
                        style: TextStyle(
                          fontFamily: 'InstrumentSans',
                          fontWeight: FontWeight.w600,
                          fontSize: priceSize,
                          color: titleColor,
                        ),
                      ),
                      if (showMrpStrike)
                        Text(
                          "₹${mrp.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontFamily: 'InstrumentSans',
                            fontWeight: FontWeight.w400,
                            fontSize: 10.sp,
                            color: mrpColor,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: mrpColor,
                          ),
                        ),
                      if (showOffLabel)
                        Text(
                          "(${effectiveDiscount}% off)",
                          style: TextStyle(
                            fontFamily: 'InstrumentSans',
                            fontWeight: FontWeight.w500,
                            fontSize: discountSize,
                            color: discountColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.icon,
    required this.iconColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26.sp,
        height: 26.sp,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(
              color: borderColor ?? const Color(0xFFE2E5ED), width: 1),
        ),
        child: Icon(icon, size: 16.sp, color: iconColor),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  final String imageUrl;
  const _CardImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.black.withOpacity(0.05),
        child: Icon(Icons.image_outlined,
            color: Colors.grey.withOpacity(0.6), size: 28.sp),
      );
    }

    return CachedNetworkImage(
      imageUrl: ImageHelper.toWebP(imageUrl),
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: Colors.black.withOpacity(0.04)),
      errorWidget: (_, __, ___) => Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.black.withOpacity(0.05),
          child: Icon(Icons.broken_image_outlined,
              size: 24.sp, color: Colors.grey.withOpacity(0.6)),
        ),
      ),
    );
  }
}
