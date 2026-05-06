import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lafetch/common/widget/other/lf_loader_widget.dart';

/// GreyscaleImageWrapper applies greyscale and opacity effects to product images
/// when the product is out of stock.
///
/// **Validates: Requirements 4.1, 4.2, 4.3**
///
/// When [isOutOfStock] is true:
/// - Applies a greyscale ColorFilter to the image
/// - Reduces opacity to [opacity] (default: 0.6)
///
/// When [isOutOfStock] is false:
/// - No effects are applied
/// - Image displays normally
class GreyscaleImageWrapper extends StatelessWidget {
  /// The URL of the image to display
  final String imageUrl;

  /// Whether the product is out of stock
  final bool isOutOfStock;

  /// Opacity level when out of stock (0.0 - 1.0, default: 0.6)
  final double opacity;

  /// Optional callback when image is tapped
  final VoidCallback? onTap;

  /// Optional fit parameter for the image
  final BoxFit fit;

  /// Optional height for the image
  final double? height;

  /// Optional width for the image
  final double? width;

  const GreyscaleImageWrapper({
    Key? key,
    required this.imageUrl,
    required this.isOutOfStock,
    this.opacity = 0.6,
    this.onTap,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
  })  : assert(opacity >= 0.0 && opacity <= 1.0,
            'Opacity must be between 0.0 and 1.0'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build the base image widget
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      height: height,
      width: width,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          // child: CircularProgressIndicator(),
          child: LfLoaderWidget(
            size: 28,
            brandColor: Colors.grey,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.error),
      ),
    );

    // Apply greyscale and opacity effects if out of stock
    if (isOutOfStock) {
      imageWidget = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          // Greyscale matrix: converts RGB to grayscale
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: Opacity(
          opacity: opacity,
          child: imageWidget,
        ),
      );
    }

    // Wrap with GestureDetector if onTap callback is provided
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
