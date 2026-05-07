import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controllers/product_controller.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/screens/Brands/categoryproduct.dart';
import 'package:lafetch/screens/catalog/productlist/pdp_v2/product_details_screen_v2.dart';

/// **Task 1.1: LuxeSection Widget**
/// Displays LUXE heading and integrates with ProductController
/// - Uses GetX state management
/// - Integrates with ProductController for data fetching
/// - Adds loading indicator and error handling
/// - Hides section when no products available
/// **Validates: Requirements 1.1, 1.2, 1.3**
class LuxeSection extends StatefulWidget {
  final VoidCallback? onViewAll;

  const LuxeSection({
    this.onViewAll,
    super.key,
  });

  @override
  State<LuxeSection> createState() => _LuxeSectionState();
}

class _LuxeSectionState extends State<LuxeSection> {
  late ProductController productController;

  @override
  void initState() {
    super.initState();
    productController = Get.find<ProductController>();
    // Fetch LUXE products when section is initialized
    _initializeLuxeProducts();
  }

  Future<void> _initializeLuxeProducts() async {
    try {
      await productController.fetchLuxeProducts();

      // If no products from API, try client-side filtering from collections
      if (productController.luxeList.isEmpty) {
        print("⚠️ No LUXE products from API, trying client-side filtering...");

        // Get products from first collection
        if (productController.homeProductList.isNotEmpty) {
          final firstCollection = productController.homeProductList.first;
          final collectionProducts =
              firstCollection.products.map((p) => p.toJson()).toList();

          final filteredLuxe = productController
              .filterLuxeProductsFromCollection(collectionProducts);

          if (filteredLuxe.isNotEmpty) {
            productController.luxeList.assignAll(filteredLuxe.take(8).toList());
            print(
                "✅ Loaded ${productController.luxeList.length} LUXE products from collection");
          }
        }
      }
    } catch (e) {
      print("❌ Error initializing LUXE products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Show loading indicator while fetching
      if (productController.isLuxeLoading.value) {
        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorPrimary),
            ),
          ),
        );
      }

      // ✅ Hide section if no LUXE products available
      if (productController.luxeList.isEmpty) {
        print("⚠️ No LUXE products available - hiding section");
        return const SizedBox.shrink();
      }

      return Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ LUXE Heading (tappable for navigation)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: GestureDetector(
                onTap: () {
                  // Navigate to LUXE category page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryProductScreen(
                        categoryName: 'LUXE',
                        categoryId: 0,
                        brandId: 0,
                        genderType: 0,
                        collectionIds: [],
                        genderName: '',
                        type: 'luxe',
                        screen: 'luxe',
                        categoryList: [],
                        title: 'LUXE',
                        segment: 'luxury', // ✅ Pass segment parameter
                      ),
                    ),
                  );
                },
                child: Text(
                  'LUXE',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            // ✅ LUXE Product List (horizontal scrollable)
            LuxeProductList(
              products: productController.luxeList,
              onViewAll: widget.onViewAll,
            ),
          ],
        ),
      );
    });
  }
}

/// **Task 1.2: LuxeProductList Widget**
/// Horizontal scrollable list with ~8 products
/// - Displays product cards
/// - Adds View All link at end
/// - Implements product card and View All tapping
/// **Validates: Requirements 1.1, 1.2, 1.3**
class LuxeProductList extends StatelessWidget {
  final List<dynamic> products;
  final VoidCallback? onViewAll;

  const LuxeProductList({
    required this.products,
    this.onViewAll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: products.length + 1, // +1 for View All link
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          // ✅ Last item is View All link
          if (index == products.length) {
            return _buildViewAllLink(context);
          }

          final product = products[index];
          return _buildLuxeProductCard(context, product);
        },
      ),
    );
  }

  Widget _buildViewAllLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to LUXE category page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoryProductScreen(
              categoryName: 'LUXE',
              categoryId: 0,
              brandId: 0,
              genderType: 0,
              collectionIds: [],
              genderName: '',
              type: 'luxe',
              screen: 'luxe',
              categoryList: [],
              title: 'LUXE',
              segment: 'luxury', // ✅ Pass segment parameter
            ),
          ),
        );
        onViewAll?.call();
      },
      child: Container(
        width: 150.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD6D4D0), width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Icon(
                Icons.arrow_forward,
                size: 16.sp,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuxeProductCard(BuildContext context, dynamic product) {
    final productId = product['id'] ?? 0;
    final productName = product['name'] ?? product['title'] ?? 'Product';
    final productImage =
        product['image'] ?? product['images']?[0] ?? product['imageUrl'] ?? '';
    final productPrice = product['price'] ??
        product['basePrice'] ??
        product['displayPrice'] ??
        0;
    final productMrp = product['mrp'] ??
        product['compareAtPrice'] ??
        product['displayMrp'] ??
        0;

    return GestureDetector(
      onTap: () {
        // ✅ Navigate to Product Detail Page
        if (productId > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreenV2(
                productId: productId,
                type: "add",
              ),
            ),
          );
        }
      },
      child: Container(
        width: 150.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Product Image with LUXE Badge
            Stack(
              children: [
                Container(
                  height: 150.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.r),
                      topRight: Radius.circular(8.r),
                    ),
                    color: const Color(0xFFF5F5F5),
                  ),
                  child: productImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: productImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFF5F5F5),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFFF5F5F5),
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF5F5F5),
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
                // ✅ LUXE Badge
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'LUXE',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ✅ Product Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name
                    Text(
                      productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    // ✅ Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${_formatPrice(productPrice)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        if (productMrp > 0 && productMrp > productPrice)
                          Text(
                            '₹${_formatPrice(productMrp)}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF999999),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price is num) {
      return price.toInt().toString();
    }
    return price?.toString() ?? '0';
  }
}
