import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A semi-transparent overlay widget that displays "Out of Stock" text
/// positioned absolutely over a product image.
///
/// This widget is used in ProductCard to indicate that a product is unavailable.
/// It provides clear visual feedback to users that the product cannot be purchased.
class OutOfStockOverlay extends StatelessWidget {
  /// Optional callback when the overlay is tapped
  final VoidCallback? onTap;

  /// Background color of the overlay (default: semi-transparent dark)
  final Color backgroundColor;

  /// Text color for the "Out of Stock" label
  final Color textColor;

  /// Font size for the "Out of Stock" text
  final double fontSize;

  const OutOfStockOverlay({
    super.key,
    this.onTap,
    this.backgroundColor = Colors.black54,
    this.textColor = Colors.white,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Fill the entire space of the parent (positioned over image)
        width: double.infinity,
        height: double.infinity,
        // Semi-transparent dark background
        color: backgroundColor,
        // Center the text
        child: Center(
          child: Text(
            'Out of Stock',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Clash Display Semibold',
              fontSize: fontSize.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
              // Add slight shadow for better readability
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
