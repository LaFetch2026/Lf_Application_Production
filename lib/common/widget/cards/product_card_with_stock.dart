// Product Card with Stock Status Integration
// This file demonstrates how to use ProductCard with reactive stock status updates
// from the ProductController.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/product_controller.dart';
import 'product_card.dart';

/// Example 1: Simple reactive ProductCard wrapper for a product ID
/// 
/// Usage:
/// ```dart
/// ProductCardWithStock(
///   productId: 123,
///   imageUrl: 'https://...',
///   title: 'Product Name',
///   brandName: 'Brand',
///   price: 999,
///   mrp: 1299,
///   onTap: () => navigateToDetails(123),
/// )
/// ```
class ProductCardWithStock extends StatelessWidget {
  final int productId;
  final String imageUrl;
  final String title;
  final String brandName;
  final num? price;
  final num? mrp;
  final bool showExpress;
  final VoidCallback? onTap;
  final bool isDark;

  const ProductCardWithStock({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.title,
    this.brandName = '',
    this.price,
    this.mrp,
    this.showExpress = false,
    this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    return Obx(() {
      // Listen to stock status changes for this product
      final isOutOfStock = controller.isProductOutOfStock(productId);

      // Build the appropriate ProductCard variant
      if (isDark) {
        return ProductCard.dark(
          imageUrl: imageUrl,
          title: title,
          brandName: brandName,
          price: price,
          mrp: mrp,
          showExpress: showExpress,
          onTap: onTap,
          isOutOfStock: isOutOfStock,
        );
      } else {
        return ProductCard.light(
          imageUrl: imageUrl,
          title: title,
          brandName: brandName,
          price: price,
          mrp: mrp,
          showExpress: showExpress,
          onTap: onTap,
          isOutOfStock: isOutOfStock,
        );
      }
    });
  }
}

/// Example 2: How to use ProductCard directly with Obx() in a listing screen
/// 
/// This shows the pattern for integrating stock status into existing listing screens.
/// 
/// Usage in a GridView or ListView:
/// ```dart
/// GridView.builder(
///   itemCount: products.length,
///   itemBuilder: (context, index) {
///     final product = products[index];
///     final controller = Get.find<ProductController>();
///     
///     return Obx(() {
///       final isOutOfStock = controller.isProductOutOfStock(product.id);
///       
///       return ProductCard.light(
///         imageUrl: product.imageUrl,
///         title: product.title,
///         brandName: product.brandName,
///         price: product.price,
///         mrp: product.mrp,
///         onTap: () => navigateToDetails(product.id),
///         isOutOfStock: isOutOfStock,
///       );
///     });
///   },
/// )
/// ```

/// Example 3: How to apply filtering in a listing screen
/// 
/// This shows how to filter products based on stock status before displaying them.
/// 
/// Usage:
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   
///   WidgetsBinding.instance.addPostFrameCallback((_) {
///     final controller = Get.find<ProductController>();
///     
///     // Apply filtering to the product list
///     final filteredProducts = controller.filterProductsByStock(productList);
///     
///     // Update the UI with filtered products
///     setState(() {
///       displayedProducts = filteredProducts;
///     });
///   });
/// }
/// ```

/// Example 4: Complete listing screen integration pattern
/// 
/// This demonstrates a complete pattern for integrating stock status filtering
/// and reactive overlay display in a listing screen.
/// 
/// ```dart
/// class MyListingScreen extends StatefulWidget {
///   @override
///   State<MyListingScreen> createState() => _MyListingScreenState();
/// }
/// 
/// class _MyListingScreenState extends State<MyListingScreen> {
///   final productController = Get.find<ProductController>();
///   List<Product> displayedProducts = [];
/// 
///   @override
///   void initState() {
///     super.initState();
///     _loadAndFilterProducts();
///   }
/// 
///   void _loadAndFilterProducts() {
///     // Get all products
///     final allProducts = productController.productList;
///     
///     // Apply stock status filtering
///     final filtered = productController.filterProductsByStock(allProducts);
///     
///     setState(() {
///       displayedProducts = filtered;
///     });
///   }
/// 
///   @override
///   Widget build(BuildContext context) {
///     return GridView.builder(
///       itemCount: displayedProducts.length,
///       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
///         crossAxisCount: 2,
///         childAspectRatio: 0.75,
///       ),
///       itemBuilder: (context, index) {
///         final product = displayedProducts[index];
///         
///         // Wrap in Obx() to listen to stock status changes
///         return Obx(() {
///           final isOutOfStock = productController.isProductOutOfStock(product.id);
///           
///           return ProductCard.light(
///             imageUrl: product.imageUrl,
///             title: product.title,
///             brandName: product.brandName,
///             price: product.price,
///             mrp: product.mrp,
///             onTap: () => navigateToDetails(product.id),
///             isOutOfStock: isOutOfStock,
///           );
///         });
///       },
///     );
///   }
/// }
/// ```
