import 'package:flutter/material.dart';
import 'package:lafetch/core/constant/constants.dart';

/// Reusable price display widget for consistent pricing across the app
/// Shows: MRP (strikethrough), Base Price, Discount % (lavender)
class ProductPriceDisplay extends StatelessWidget {
  final num price; // Base/Selling price
  final num? mrp; // Original price (MRP)
  final double fontSize;
  final double? mrpFontSize;
  final double? discountFontSize;
  final FontWeight fontWeight;
  final FontWeight? mrpFontWeight;
  final FontWeight? discountFontWeight;
  final Color? priceColor;
  final Color? mrpColor;
  final Color? discountColor;
  final MainAxisAlignment alignment;
  final CrossAxisAlignment crossAlignment;
  final double spacing;
  final bool showCurrency;
  final bool isVertical; // Stack vertically instead of horizontally

  const ProductPriceDisplay({
    Key? key,
    required this.price,
    this.mrp,
    this.fontSize = 14,
    this.mrpFontSize,
    this.discountFontSize,
    this.fontWeight = FontWeight.w600,
    this.mrpFontWeight,
    this.discountFontWeight,
    this.priceColor,
    this.mrpColor,
    this.discountColor,
    this.alignment = MainAxisAlignment.start,
    this.crossAlignment = CrossAxisAlignment.center,
    this.spacing = 6,
    this.showCurrency = true,
    this.isVertical = false,
  }) : super(key: key);

  /// Calculate discount percentage
  int? _getDiscountPercentage() {
    if (mrp != null && mrp! > price && price > 0) {
      return (((mrp! - price) / mrp!) * 100).round();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final discount = _getDiscountPercentage();
    final currencySymbol = showCurrency ? '\u{20B9}' : '';

    // ✅ Handle case where price is 0 but MRP exists - show only MRP
    if (price == 0 && mrp != null && mrp! > 0) {
      return Text(
        '$currencySymbol${mrp!.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: priceColor ?? deepGreytextColor,
        ),
      );
    }

    // ✅ If price is 0 and no MRP, show nothing
    if (price == 0) {
      return const SizedBox.shrink();
    }

    if (isVertical) {
      // Vertical layout
      return Column(
        crossAxisAlignment: crossAlignment,
        children: [
          // Base Price
          Text(
            '$currencySymbol${price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: "Clash Display Regular",
              fontWeight: fontWeight,
              color: priceColor ?? deepGreytextColor,
            ),
          ),
          // MRP and Discount row
          if (mrp != null && discount != null && discount > 0) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // MRP with strikethrough
                Text(
                  '$currencySymbol${mrp!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: mrpFontSize ?? (fontSize - 2),
                    fontWeight: mrpFontWeight ?? FontWeight.w400,
                    color: mrpColor ?? textHintColor,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: mrpColor ?? textHintColor,
                    fontFamily: "Clash Display Regular",
                  ),
                ),
                SizedBox(width: spacing),
                // Discount %
                Text(
                  '$discount% OFF',
                  style: TextStyle(
                    fontSize: discountFontSize ?? (fontSize - 2),
                    fontWeight: discountFontWeight ?? FontWeight.w500,
                    color: discountColor ?? lightPurpleColor,
                    fontFamily: "Clash Display Regular",
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }

    // Horizontal layout (default)
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        crossAxisAlignment: crossAlignment,
        children: [
          // Base Price
          Text(
            '$currencySymbol${price.toStringAsFixed(0)}',
            style: TextStyle(
              fontFamily: "Clash Display Regular",
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: priceColor ?? deepGreytextColor,
            ),
          ),
          // MRP with strikethrough
          if (mrp != null && discount != null && discount > 0) ...[
            SizedBox(width: spacing),
            Text(
              '$currencySymbol${mrp!.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: mrpFontSize ?? (fontSize - 2),
                fontWeight: mrpFontWeight ?? FontWeight.w400,
                color: mrpColor ?? textHintColor,
                decoration: TextDecoration.lineThrough,
                fontFamily: "Clash Display Regular",
                decorationColor: mrpColor ?? textHintColor,
              ),
            ),
            SizedBox(width: spacing),
            // Discount %
            Text(
              '$discount% OFF',
              style: TextStyle(
                fontSize: discountFontSize ?? (fontSize - 2),
                fontWeight: discountFontWeight ?? FontWeight.w500,
                fontFamily: "Clash Display Regular",
                color: discountColor ?? lightPurpleColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
