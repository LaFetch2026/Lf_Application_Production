import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:lafetch/controllers/product_controller.dart';
import 'package:lafetch/models/collection_model.dart';

void main() {
  group('ProductController - Stock Status Filtering', () {
    late ProductController controller;

    setUp(() {
      // Initialize GetX bindings
      Get.testMode = true;
      controller = ProductController();
    });

    tearDown(() {
      Get.reset();
    });

    // Helper function to create test products
    List<CollectionModel> createTestProducts({
      required int count,
      required List<int> outOfStockIds,
    }) {
      return List.generate(count, (index) {
        final id = index + 1;
        return CollectionModel(
          id: id,
          name: 'Product $id',
          displayFor: ['homepage'],
          banners: [],
          productMaps: [],
          products: [],
        );
      });
    }

    group('filterProductsByStock - Edge Cases', () {
      test('returns empty list when input is null', () {
        controller.showOutOfStockProducts.value = false;
        final result = controller.filterProductsByStock(null);
        expect(result, isEmpty);
      });

      test('returns empty list when input is empty', () {
        controller.showOutOfStockProducts.value = false;
        final result = controller.filterProductsByStock([]);
        expect(result, isEmpty);
      });

      test('returns all products when input is null and setting is enabled', () {
        controller.showOutOfStockProducts.value = true;
        final result = controller.filterProductsByStock(null);
        expect(result, isEmpty);
      });
    });

    group('filterProductsByStock - Setting Disabled (Filter Out-of-Stock)', () {
      test('filters out products marked as out of stock', () {
        controller.showOutOfStockProducts.value = false;

        // Create test products
        final products = createTestProducts(count: 5, outOfStockIds: [2, 4]);

        // Mark products 2 and 4 as out of stock
        controller.productStockStatus[2] = true;
        controller.productStockStatus[4] = true;

        final filtered = controller.filterProductsByStock(products);

        // Should have 3 products (1, 3, 5)
        expect(filtered.length, 3);
        expect(filtered.map((p) => p.id).toList(), [1, 3, 5]);
      });

      test('returns all products when none are out of stock', () {
        controller.showOutOfStockProducts.value = false;

        final products = createTestProducts(count: 5, outOfStockIds: []);

        final filtered = controller.filterProductsByStock(products);

        expect(filtered.length, 5);
        expect(filtered.map((p) => p.id).toList(), [1, 2, 3, 4, 5]);
      });

      test('returns empty list when all products are out of stock', () {
        controller.showOutOfStockProducts.value = false;

        final products = createTestProducts(count: 5, outOfStockIds: [1, 2, 3, 4, 5]);

        // Mark all products as out of stock
        for (int i = 1; i <= 5; i++) {
          controller.productStockStatus[i] = true;
        }

        final filtered = controller.filterProductsByStock(products);

        expect(filtered.length, 0);
      });

      test('safely handles products with missing stock status (assumes in-stock)', () {
        controller.showOutOfStockProducts.value = false;

        final products = createTestProducts(count: 3, outOfStockIds: []);

        // Only mark product 2 as out of stock
        controller.productStockStatus[2] = true;
        // Products 1 and 3 have no entry in productStockStatus

        final filtered = controller.filterProductsByStock(products);

        // Should have 2 products (1 and 3, assuming in-stock)
        expect(filtered.length, 2);
        expect(filtered.map((p) => p.id).toList(), [1, 3]);
      });

      test('filters correctly with mixed stock statuses', () {
        controller.showOutOfStockProducts.value = false;

        final products = createTestProducts(count: 10, outOfStockIds: []);

        // Mark some products as out of stock
        controller.productStockStatus[1] = true;
        controller.productStockStatus[3] = true;
        controller.productStockStatus[5] = true;
        controller.productStockStatus[7] = true;
        controller.productStockStatus[9] = true;

        final filtered = controller.filterProductsByStock(products);

        // Should have 5 products (2, 4, 6, 8, 10)
        expect(filtered.length, 5);
        expect(filtered.map((p) => p.id).toList(), [2, 4, 6, 8, 10]);
      });
    });

    group('filterProductsByStock - Setting Enabled (Show All)', () {
      test('returns all products when setting is enabled', () {
        controller.showOutOfStockProducts.value = true;

        final products = createTestProducts(count: 5, outOfStockIds: [2, 4]);

        // Mark products 2 and 4 as out of stock
        controller.productStockStatus[2] = true;
        controller.productStockStatus[4] = true;

        final filtered = controller.filterProductsByStock(products);

        // Should return all 5 products
        expect(filtered.length, 5);
        expect(filtered.map((p) => p.id).toList(), [1, 2, 3, 4, 5]);
      });

      test('returns all products even when all are marked out of stock', () {
        controller.showOutOfStockProducts.value = true;

        final products = createTestProducts(count: 5, outOfStockIds: []);

        // Mark all products as out of stock
        for (int i = 1; i <= 5; i++) {
          controller.productStockStatus[i] = true;
        }

        final filtered = controller.filterProductsByStock(products);

        // Should return all 5 products
        expect(filtered.length, 5);
        expect(filtered.map((p) => p.id).toList(), [1, 2, 3, 4, 5]);
      });

      test('returns all products when none are marked out of stock', () {
        controller.showOutOfStockProducts.value = true;

        final products = createTestProducts(count: 5, outOfStockIds: []);

        final filtered = controller.filterProductsByStock(products);

        expect(filtered.length, 5);
        expect(filtered.map((p) => p.id).toList(), [1, 2, 3, 4, 5]);
      });
    });

    group('filterProductsByStock - Reactive Behavior', () {
      test('respects setting changes', () {
        final products = createTestProducts(count: 5, outOfStockIds: []);

        // Mark products 2 and 4 as out of stock
        controller.productStockStatus[2] = true;
        controller.productStockStatus[4] = true;

        // First, setting is disabled - should filter
        controller.showOutOfStockProducts.value = false;
        var filtered = controller.filterProductsByStock(products);
        expect(filtered.length, 3);

        // Now enable setting - should show all
        controller.showOutOfStockProducts.value = true;
        filtered = controller.filterProductsByStock(products);
        expect(filtered.length, 5);

        // Disable again - should filter again
        controller.showOutOfStockProducts.value = false;
        filtered = controller.filterProductsByStock(products);
        expect(filtered.length, 3);
      });

      test('respects stock status changes', () {
        final products = createTestProducts(count: 5, outOfStockIds: []);
        controller.showOutOfStockProducts.value = false;

        // Initially no products are out of stock
        var filtered = controller.filterProductsByStock(products);
        expect(filtered.length, 5);

        // Mark product 2 as out of stock
        controller.productStockStatus[2] = true;
        filtered = controller.filterProductsByStock(products);
        expect(filtered.length, 4);

        // Mark product 4 as out of stock
        controller.productStockStatus[4] = true;
        filtered = controller.filterProductsByStock(products);
        expect(filtered.length, 3);

        // Mark product 2 as back in stock
        controller.productStockStatus[2] = false;
        filtered = controller.filterProductsByStock(products);
        expect(filtered.length, 4);
      });
    });

    group('filterProductsByStock - Large Lists', () {
      test('handles large product lists efficiently', () {
        controller.showOutOfStockProducts.value = false;

        // Create a large list of products
        final products = createTestProducts(count: 1000, outOfStockIds: []);

        // Mark every 10th product as out of stock
        for (int i = 10; i <= 1000; i += 10) {
          controller.productStockStatus[i] = true;
        }

        final filtered = controller.filterProductsByStock(products);

        // Should have 900 products (1000 - 100 out of stock)
        expect(filtered.length, 900);
      });

      test('maintains product order after filtering', () {
        controller.showOutOfStockProducts.value = false;

        final products = createTestProducts(count: 20, outOfStockIds: []);

        // Mark odd-numbered products as out of stock
        for (int i = 1; i <= 20; i += 2) {
          controller.productStockStatus[i] = true;
        }

        final filtered = controller.filterProductsByStock(products);

        // Should have even-numbered products in order
        final expectedIds = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20];
        expect(filtered.map((p) => p.id).toList(), expectedIds);
      });
    });

    group('isProductOutOfStock - Helper Method', () {
      test('returns true for products marked as out of stock', () {
        controller.productStockStatus[1] = true;
        expect(controller.isProductOutOfStock(1), true);
      });

      test('returns false for products marked as in stock', () {
        controller.productStockStatus[1] = false;
        expect(controller.isProductOutOfStock(1), false);
      });

      test('returns false for products with no stock status entry', () {
        // Product 999 has no entry in productStockStatus
        expect(controller.isProductOutOfStock(999), false);
      });
    });
  });
}
