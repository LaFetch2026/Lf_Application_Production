// Reactive Product Card - Integrates ProductCard with ProductController stock status
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/product_controller.dart';
import '../../../models/collection_model.dart';
import 'product_card.dart';

/// A reactive wrapper around ProductCard that listens to stock status changes
/// from the ProductController and updates the overlay display accordingly.
///
/// This widget automatically:
/// - Listens to stock status changes via Obx()
/// - Passes isOutOfStock parameter to ProductCard
/// - Displays/hides overlay reactively
/// - Handles product navigation
class ReactiveProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool isDark;

  const ReactiveProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    return Obx(() {
      // Listen to stock status changes for this product
      final isOutOfStock = controller.isProductOutOfStock(product.id);

      // Build the appropriate ProductCard variant
      if (isDark) {
        return ProductCard.dark(
          imageUrl: product.firstImageUrl,
          title: product.title,
          brandName: product.brand.name,
          price: product.basePrice,
          mrp: product.mrp,
          onTap: onTap,
          isOutOfStock: isOutOfStock,
        );
      } else {
        return ProductCard.light(
          imageUrl: product.firstImageUrl,
          title: product.title,
          brandName: product.brand.name,
          price: product.basePrice,
          mrp: product.mrp,
          onTap: onTap,
          isOutOfStock: isOutOfStock,
        );
      }
    });
  }
}
