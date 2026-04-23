import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lafetch/core/constant/constants.dart';

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
  final bool isVertical;

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

  String _formatPrice(num value) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: showCurrency ? '₹' : '',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  int? _getDiscountPercentage() {
    if (mrp != null && mrp! > price && price > 0) {
      return (((mrp! - price) / mrp!) * 100).round();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final discount = _getDiscountPercentage();

    if (price == 0 && mrp != null && mrp! > 0) {
      return Text(
        _formatPrice(mrp!),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: priceColor ?? deepGreytextColor,
        ),
      );
    }

    if (price == 0) {
      return const SizedBox.shrink();
    }

    if (isVertical) {
      return Column(
        crossAxisAlignment: crossAlignment,
        children: [
          Text(
            _formatPrice(price),
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: "Clash Display Regular",
              fontWeight: fontWeight,
              color: priceColor ?? deepGreytextColor,
            ),
          ),
          if (mrp != null && discount != null && discount > 0) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _formatPrice(mrp!),
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

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        // Baseline alignment keeps price, MRP and OFF text on the same visual line
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            _formatPrice(price),
            style: TextStyle(
              fontFamily: "Clash Display Regular",
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: priceColor ?? deepGreytextColor,
            ),
          ),
          if (mrp != null && discount != null && discount > 0) ...[
            SizedBox(width: spacing),
            Text(
              _formatPrice(mrp!),
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
