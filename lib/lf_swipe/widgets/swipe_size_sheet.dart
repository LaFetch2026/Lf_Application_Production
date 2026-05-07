// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/widget/other/lf_loader_widget.dart';
import '../../controllers/cart_controller.dart';
import '../../core/constant/constants.dart';
import '../models/swipe_product.dart';
import '../services/swipe_cart_service.dart';

/// Result returned by the size sheet.
enum SwipeSizeResult {
  added,
  noSizes,
  dismissed,
  error,
  wishlisted, // user tapped "Add to Wishlist" from the out-of-stock sheet
}

/// Shows a size-picker bottom sheet pre-populated with variants from the
/// SELECT_VARIANT response. No network call is made here — the controller
/// already has the variants.
///
/// Calls POST /swipe/action/confirm when the user taps a chip.
/// Returns [SwipeSizeResult.added] on success, [SwipeSizeResult.dismissed] otherwise.
Future<SwipeSizeResult> showSwipeSizeSheet(
  BuildContext context,
  SwipeProduct product, {
  List<SwipeVariant> variants = const [],
  Map<String, List<String>> options = const {},
}) async {
  // If no variants were provided, nothing to show
  if (variants.isEmpty) {
    return SwipeSizeResult.noSizes;
  }

  final sizes = _uniqueSizes(variants);
  final colors = _uniqueColors(variants);
  final hasOptions = sizes.isNotEmpty || colors.isNotEmpty;

  if (!hasOptions) {
    return SwipeSizeResult.noSizes;
  }

  if (!context.mounted) return SwipeSizeResult.dismissed;

  final result = await showModalBottomSheet<SwipeSizeResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (_) => _SwipeSizeSheet(
      product: product,
      variants: variants,
      sizes: sizes,
      colors: colors,
    ),
  );

  return result ?? SwipeSizeResult.dismissed;
}

List<String> _uniqueSizes(List<SwipeVariant> variants) {
  final seen = <String>{};
  return variants
      .map((v) => v.size)
      .where((s) => s.isNotEmpty && seen.add(s))
      .toList();
}

List<String> _uniqueColors(List<SwipeVariant> variants) {
  final seen = <String>{};
  return variants
      .map((v) => v.color)
      .where((c) => c.isNotEmpty && seen.add(c))
      .toList();
}

// ─────────────────────────────────────────────────────────────────────────────

class _SwipeSizeSheet extends StatefulWidget {
  final SwipeProduct product;
  final List<SwipeVariant> variants;
  final List<String> sizes;
  final List<String> colors;

  const _SwipeSizeSheet({
    required this.product,
    required this.variants,
    required this.sizes,
    required this.colors,
  });

  @override
  State<_SwipeSizeSheet> createState() => _SwipeSizeSheetState();
}

class _SwipeSizeSheetState extends State<_SwipeSizeSheet> {
  bool _adding = false;
  String? _error;
  String? _selectedColor;

  bool get _hasColors => widget.colors.isNotEmpty;
  bool get _hasSizes => widget.sizes.isNotEmpty;

  bool _sizeInStock(String size) => widget.variants.any((v) =>
      v.size == size &&
      v.inStock &&
      (_selectedColor == null || v.color == _selectedColor));

  bool _colorInStock(String color) =>
      widget.variants.any((v) => v.color == color && v.inStock);

  SwipeVariant? _variantFor(String size) => widget.variants.firstWhereOrNull(
        (v) =>
            v.size == size &&
            v.inStock &&
            (_selectedColor == null || v.color == _selectedColor),
      );

  /// Called when user taps an in-stock size chip.
  /// Calls POST /swipe/action/confirm and closes on success.
  Future<void> _onSizeTapped(String size) async {
    if (_adding) return;

    final variant = _variantFor(size);
    if (variant == null) return;

    setState(() {
      _adding = true;
      _error = null;
    });

    final success = await SwipeCartService.confirmVariant(
      productId: widget.product.id,
      variantId: variant.id,
    );

    if (!mounted) return;

    if (success) {
      try {
        Get.find<CartController>().getCartData(forceRefresh: true);
      } catch (_) {}
      Navigator.of(context).pop(SwipeSizeResult.added);
    } else {
      setState(() {
        _adding = false;
        _error = 'Could not add to cart. Try again.';
      });
    }
  }

  /// Called when user taps a color chip (only relevant when no sizes exist).
  Future<void> _onColorTapped(String color) async {
    if (_adding) return;

    // If sizes also exist, just filter — don't add yet
    if (_hasSizes) {
      setState(() => _selectedColor = _selectedColor == color ? null : color);
      return;
    }

    // Color-only product → confirm immediately
    final variant = widget.variants.firstWhereOrNull(
      (v) => v.color == color && v.inStock,
    );
    if (variant == null) return;

    setState(() {
      _adding = true;
      _error = null;
    });

    final success = await SwipeCartService.confirmVariant(
      productId: widget.product.id,
      variantId: variant.id,
    );

    if (!mounted) return;

    if (success) {
      try {
        Get.find<CartController>().getCartData(forceRefresh: true);
      } catch (_) {}
      Navigator.of(context).pop(SwipeSizeResult.added);
    } else {
      setState(() {
        _adding = false;
        _error = 'Could not add to cart. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 28.sp,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.sp, bottom: 16.sp),
              width: 36.sp,
              height: 4.sp,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.sp),
              ),
            ),
          ),

          // Product summary row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.sp),
                  child: widget.product.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.product.imageUrl,
                          width: 52.sp,
                          height: 52.sp,
                          fit: BoxFit.cover,
                          memCacheWidth: 200,
                          memCacheHeight: 200,
                          errorWidget: (_, __, ___) => Container(
                              width: 52.sp,
                              height: 52.sp,
                              color: Colors.grey[200]),
                        )
                      : Container(
                          width: 52.sp, height: 52.sp, color: Colors.grey[200]),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.product.brandName.isNotEmpty)
                        Text(
                          widget.product.brandName.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Clash Display Semibold',
                            fontSize: 10.sp,
                            color: Colors.grey[500],
                            letterSpacing: 0.8,
                          ),
                        ),
                      Text(
                        widget.product.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Clash Display',
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                          color: homeAppBarColor,
                        ),
                      ),
                      Text(
                        '₹${widget.product.sellingPrice.toInt()}',
                        style: TextStyle(
                          fontFamily: 'Clash Display Semibold',
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          color: homeAppBarColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 18.sp),
          Divider(height: 1, color: Colors.grey[100]),
          SizedBox(height: 16.sp),

          // Adding spinner — shown immediately when user taps a chip
          if (_adding)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.sp),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  builder: (_, opacity, child) => Opacity(
                    opacity: opacity,
                    child: child,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LfLogoLoader(
                          size: 36, brandColor: Colors.grey, showGlow: false),
                      SizedBox(height: 10.sp),
                      Text(
                        'Adding to cart…',
                        style: TextStyle(
                          fontFamily: 'Clash Display Regular',
                          fontSize: 12.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            // Instruction label
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.sp),
              child: Text(
                _hasSizes
                    ? 'Tap your size to add to cart'
                    : 'Tap your colour to add to cart',
                style: TextStyle(
                  fontFamily: 'Clash Display Semibold',
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  color: homeAppBarColor,
                ),
              ),
            ),
            SizedBox(height: 12.sp),

            // Color chips (shown above sizes when both exist, as a filter)
            if (_hasColors) ...[
              if (_hasSizes)
                Padding(
                  padding: EdgeInsets.only(left: 20.sp, bottom: 6.sp),
                  child: Text(
                    'Colour${_selectedColor != null ? ': $_selectedColor' : ''}',
                    style: TextStyle(
                      fontFamily: 'Clash Display Regular',
                      fontSize: 11.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.sp),
                child: Wrap(
                  spacing: 8.sp,
                  runSpacing: 8.sp,
                  children: widget.colors.map((color) {
                    final inStock = _colorInStock(color);
                    final selected = _selectedColor == color;
                    return _SizeChip(
                      label: color,
                      selected: selected,
                      inStock: inStock,
                      // Color chips: tap to filter (if sizes exist) or add directly
                      onTap: inStock ? () => _onColorTapped(color) : null,
                    );
                  }).toList(),
                ),
              ),
              if (_hasSizes) SizedBox(height: 14.sp),
            ],

            // Size chips — tap = add to cart immediately
            if (_hasSizes) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.sp),
                child: Wrap(
                  spacing: 8.sp,
                  runSpacing: 8.sp,
                  children: widget.sizes.map((size) {
                    final inStock = _sizeInStock(size);
                    return _SizeChip(
                      label: size,
                      selected: false, // no persistent selection — tap = add
                      inStock: inStock,
                      onTap: inStock ? () => _onSizeTapped(size) : null,
                    );
                  }).toList(),
                ),
              ),
            ],

            // Error message
            if (_error != null) ...[
              SizedBox(height: 10.sp),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.sp),
                child: Text(
                  _error!,
                  style: TextStyle(
                    fontFamily: 'Clash Display Regular',
                    fontSize: 12.sp,
                    color: Colors.red[400],
                  ),
                ),
              ),
            ],
          ],

          SizedBox(height: 4.sp),
        ],
      ),
    );
  }
}

// ── Size chip ─────────────────────────────────────────────────────────────────

class _SizeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool inStock;
  final VoidCallback? onTap;

  const _SizeChip({
    required this.label,
    required this.selected,
    required this.inStock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 9.sp),
        decoration: BoxDecoration(
          color: selected
              ? homeAppBarColor
              : inStock
                  ? Colors.white
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(
            color: selected
                ? homeAppBarColor
                : inStock
                    ? Colors.grey[300]!
                    : Colors.grey[200]!,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Clash Display',
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                color: selected
                    ? Colors.white
                    : inStock
                        ? homeAppBarColor
                        : Colors.grey[400],
              ),
            ),
            if (!inStock)
              Positioned.fill(
                child: CustomPaint(painter: _StrikethroughPainter()),
              ),
          ],
        ),
      ),
    );
  }
}

class _StrikethroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      Paint()
        ..color = Colors.grey[400]!
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
