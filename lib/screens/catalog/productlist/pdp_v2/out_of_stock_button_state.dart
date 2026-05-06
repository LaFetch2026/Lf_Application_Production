import 'package:flutter/material.dart';

/// OutOfStockButtonState represents the visual and functional state of action buttons
/// when a product is out of stock.
///
/// **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 6.1, 6.2, 6.3, 6.4**
///
/// This model encapsulates all the properties needed to render buttons correctly
/// based on the product's stock status.
class OutOfStockButtonState {
  /// Whether the button should be disabled (not interactive)
  final bool isDisabled;

  /// The text label to display on the button
  final String label;

  /// The background color of the button
  final Color backgroundColor;

  /// The text color of the button
  final Color textColor;

  /// Whether the button should be visible
  final bool isVisible;

  /// Optional border color for the button
  final Color? borderColor;

  /// Optional opacity level for the button
  final double opacity;

  const OutOfStockButtonState({
    required this.isDisabled,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.isVisible,
    this.borderColor,
    this.opacity = 1.0,
  });

  /// Factory constructor to create button state based on stock status
  ///
  /// When [isOutOfStock] is true:
  /// - Button is disabled
  /// - Label is "Out of Stock"
  /// - Background is greyed out
  /// - Text color is grey
  /// - Opacity is reduced
  ///
  /// When [isOutOfStock] is false:
  /// - Button is enabled
  /// - Label is the provided [normalLabel]
  /// - Colors are normal
  /// - Opacity is full
  factory OutOfStockButtonState.fromStockStatus({
    required bool isOutOfStock,
    required String normalLabel,
    required Color normalBackgroundColor,
    required Color normalTextColor,
    Color? normalBorderColor,
  }) {
    if (isOutOfStock) {
      return OutOfStockButtonState(
        isDisabled: true,
        label: 'Out of Stock',
        backgroundColor: Colors.grey[300] ?? Colors.grey,
        textColor: Colors.grey[600] ?? Colors.grey,
        isVisible: true,
        borderColor: Colors.grey[400],
        opacity: 0.6,
      );
    }

    return OutOfStockButtonState(
      isDisabled: false,
      label: normalLabel,
      backgroundColor: normalBackgroundColor,
      textColor: normalTextColor,
      isVisible: true,
      borderColor: normalBorderColor,
      opacity: 1.0,
    );
  }

  /// Factory constructor for "Add to Cart" button state
  factory OutOfStockButtonState.addToCart({required bool isOutOfStock}) {
    return OutOfStockButtonState.fromStockStatus(
      isOutOfStock: isOutOfStock,
      normalLabel: 'ADD TO BAG',
      normalBackgroundColor: Colors.white,
      normalTextColor: const Color(0xFF1A1A1A),
      normalBorderColor: const Color(0xFF1A1A1A),
    );
  }

  /// Factory constructor for "Buy Now" button state
  factory OutOfStockButtonState.buyNow({required bool isOutOfStock}) {
    return OutOfStockButtonState.fromStockStatus(
      isOutOfStock: isOutOfStock,
      normalLabel: 'BUY NOW',
      normalBackgroundColor: const Color(0xFF1A1A1A),
      normalTextColor: Colors.white,
    );
  }

  @override
  String toString() =>
      'OutOfStockButtonState(disabled: $isDisabled, label: $label, visible: $isVisible)';
}
