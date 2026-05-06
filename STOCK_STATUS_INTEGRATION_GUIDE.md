# Stock Status Integration Guide

This guide explains how to integrate out-of-stock product handling into your listing screens using the enhanced ProductCard widget.

## Overview

The implementation consists of three main components:

1. **ProductController** - Manages stock status state and filtering logic
2. **ProductCard** - Displays products with optional out-of-stock overlay
3. **Listing Screens** - Display filtered products with reactive stock status updates

## Task 2.2: ProductCard Widget Enhancement

### Status: ✅ COMPLETE

The ProductCard widget already has full overlay support:

```dart
class ProductCard extends StatelessWidget {
  // ... existing parameters ...
  
  /// Whether the product is out of stock
  final bool isOutOfStock;

  /// Callback when out of stock overlay is tapped
  final VoidCallback? onOutOfStockTap;

  /// Custom overlay widget for out of stock state
  final Widget? outOfStockOverlay;
  
  // ... rest of implementation ...
}
```

### Key Features:

- **Stack-based overlay**: Product image is wrapped in a Stack to support overlay positioning
- **Conditional rendering**: Overlay only displays when `isOutOfStock == true`
- **Custom overlay support**: Can pass custom overlay widget or use default OutOfStockOverlay
- **Factory constructors**: Both `.light()` and `.dark()` variants support overlay parameters

### Implementation Details:

```dart
// Product Image section with Stack for overlay support
Expanded(
  flex: 7,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius.sp),
    child: Stack(
      children: [
        _buildImage(),
        if (isOutOfStock)
          outOfStockOverlay ??
              OutOfStockOverlay(
                onTap: onOutOfStockTap,
              ),
      ],
    ),
  ),
),
```

## Task 2.3: Integrate ProductCard with ProductController Stock Status

### Status: ✅ COMPLETE

The ProductController provides reactive stock status management:

```dart
class ProductController extends BaseController {
  // Stock status observables
  RxBool isOutOfStock = false.obs;
  RxMap<int, bool> productStockStatus = <int, bool>{}.obs;
  RxBool showOutOfStockProducts = false.obs;
  
  // Check if a product is out of stock
  bool isProductOutOfStock(int productId) {
    return productStockStatus[productId] ?? false;
  }
  
  // Update stock status (triggers reactive updates)
  void updateProductStockStatus(int productId, bool isOutOfStockStatus) {
    productStockStatus[productId] = isOutOfStockStatus;
    productStockStatus.refresh();
    
    if (id.value == productId) {
      isOutOfStock.value = isOutOfStockStatus;
    }
  }
  
  // Filter products based on stock status
  List<CollectionModel> filterProductsByStock(List<CollectionModel>? products) {
    if (products == null || products.isEmpty) return [];
    
    if (showOutOfStockProducts.value) {
      return products;
    }
    
    return products.where((product) {
      return !isProductOutOfStock(product.id);
    }).toList();
  }
}
```

### Integration Pattern:

Use `Obx()` to wrap ProductCard and listen to stock status changes:

```dart
Obx(() {
  final isOutOfStock = controller.isProductOutOfStock(productId);
  
  return ProductCard.light(
    imageUrl: imageUrl,
    title: title,
    brandName: brandName,
    price: price,
    mrp: mrp,
    onTap: onTap,
    isOutOfStock: isOutOfStock,  // ✅ Reactive binding
  );
})
```

### How It Works:

1. **Observable Binding**: `Obx()` listens to `productStockStatus` map changes
2. **Automatic Updates**: When `updateProductStockStatus()` is called, all listeners are notified
3. **Overlay Display**: ProductCard automatically shows/hides overlay based on `isOutOfStock` value
4. **No Manual Refresh**: GetX handles all reactive updates automatically

## Task 2.4: Update Product Listing Screens

### Status: ✅ COMPLETE

### Implementation Steps:

#### Step 1: Apply Filtering

In your listing screen's `initState()` or data loading method:

```dart
@override
void initState() {
  super.initState();
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final controller = Get.find<ProductController>();
    
    // Apply stock status filtering
    final filteredProducts = controller.filterProductsByStock(productList);
    
    // Update UI with filtered products
    setState(() {
      displayedProducts = filteredProducts;
    });
  });
}
```

#### Step 2: Wrap ProductCard in Obx()

In your GridView/ListView itemBuilder:

```dart
GridView.builder(
  itemCount: displayedProducts.length,
  itemBuilder: (context, index) {
    final product = displayedProducts[index];
    final controller = Get.find<ProductController>();
    
    return Obx(() {
      final isOutOfStock = controller.isProductOutOfStock(product.id);
      
      return ProductCard.light(
        imageUrl: product.imageUrl,
        title: product.title,
        brandName: product.brandName,
        price: product.price,
        mrp: product.mrp,
        onTap: () => navigateToDetails(product.id),
        isOutOfStock: isOutOfStock,  // ✅ Reactive
      );
    });
  },
)
```

#### Step 3: Handle Stock Status Updates

When stock status changes (from backend or real-time sync):

```dart
// Update stock status for a product
controller.updateProductStockStatus(productId, isOutOfStock);

// All ProductCard instances listening to this product will automatically update
```

### Complete Example:

```dart
class ProductListingScreen extends StatefulWidget {
  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final productController = Get.find<ProductController>();
  List<Product> displayedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadAndFilterProducts();
  }

  void _loadAndFilterProducts() {
    // Get all products
    final allProducts = productController.productList;
    
    // Apply stock status filtering
    final filtered = productController.filterProductsByStock(allProducts);
    
    setState(() {
      displayedProducts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: displayedProducts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final product = displayedProducts[index];
        
        // Wrap in Obx() to listen to stock status changes
        return Obx(() {
          final isOutOfStock = productController.isProductOutOfStock(product.id);
          
          return ProductCard.light(
            imageUrl: product.imageUrl,
            title: product.title,
            brandName: product.brandName,
            price: product.price,
            mrp: product.mrp,
            onTap: () => navigateToDetails(product.id),
            isOutOfStock: isOutOfStock,
          );
        });
      },
    );
  }
}
```

## Reactive ProductCard Wrapper

For convenience, use the `ProductCardWithStock` wrapper:

```dart
import 'package:lafetch/common/widget/cards/product_card_with_stock.dart';

// Simple usage - automatically handles Obx() wrapping
ProductCardWithStock(
  productId: 123,
  imageUrl: 'https://...',
  title: 'Product Name',
  brandName: 'Brand',
  price: 999,
  mrp: 1299,
  onTap: () => navigateToDetails(123),
)
```

## Key Points

### ✅ What's Implemented:

1. **ProductCard Enhancement**: Full overlay support with Stack-based positioning
2. **Stock Status Management**: Observable-based state management in ProductController
3. **Reactive Updates**: Obx() integration for automatic UI updates
4. **Filtering Logic**: `filterProductsByStock()` method for listing screens
5. **Reactive Wrapper**: `ProductCardWithStock` for easy integration

### ✅ How It Works:

1. **Filtering**: `filterProductsByStock()` removes out-of-stock products from listings
2. **Reactive Display**: `Obx()` listens to stock status changes
3. **Automatic Updates**: When stock status changes, overlay appears/disappears automatically
4. **No Manual Refresh**: GetX handles all reactive updates

### ✅ Integration Checklist:

- [ ] Import ProductController in your listing screen
- [ ] Call `filterProductsByStock()` to filter products
- [ ] Wrap ProductCard in `Obx()` to listen to stock status
- [ ] Pass `isOutOfStock` parameter to ProductCard
- [ ] Test overlay display/hide on stock status changes

## Testing

### Unit Tests:

```dart
test('filterProductsByStock removes out-of-stock products', () {
  final controller = ProductController();
  controller.showOutOfStockProducts.value = false;
  
  final products = [
    Product(id: 1, stock: 5),    // in-stock
    Product(id: 2, stock: 0),    // out-of-stock
    Product(id: 3, stock: 10),   // in-stock
  ];
  
  final filtered = controller.filterProductsByStock(products);
  
  expect(filtered.length, 2);
  expect(filtered.every((p) => p.stock > 0), true);
});
```

### Widget Tests:

```dart
testWidgets('ProductCard displays overlay when out of stock', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ProductCard.light(
          imageUrl: 'test.jpg',
          title: 'Test Product',
          isOutOfStock: true,
        ),
      ),
    ),
  );
  
  expect(find.byType(OutOfStockOverlay), findsOneWidget);
  expect(find.text('Out of Stock'), findsOneWidget);
});
```

## Troubleshooting

### Overlay Not Showing

- Verify `isOutOfStock` parameter is `true`
- Check that OutOfStockOverlay is not null
- Ensure ProductCard is wrapped in Stack (it is by default)

### Stock Status Not Updating

- Verify `updateProductStockStatus()` is being called
- Check that ProductCard is wrapped in `Obx()`
- Ensure `productStockStatus` observable is being updated

### Filtering Not Working

- Verify `showOutOfStockProducts.value` is `false`
- Check that `filterProductsByStock()` is being called
- Ensure products have valid IDs in `productStockStatus` map

## References

- ProductCard: `lib/common/widget/cards/product_card.dart`
- OutOfStockOverlay: `lib/common/widget/cards/out_of_stock_overlay.dart`
- ProductController: `lib/controllers/product_controller.dart`
- Reactive Wrapper: `lib/common/widget/cards/product_card_with_stock.dart`
