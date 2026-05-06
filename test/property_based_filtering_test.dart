// ignore_for_file: avoid_print
//
// Property-Based Test: Filtering Consistency
//
// PURPOSE: These tests verify that the filtering logic works correctly
// across a wide range of randomly generated product lists with mixed
// stock statuses.
//
// Property 1: Out-of-Stock Products Are Filtered from Listings
// - Generate random product lists with mixed stock statuses (100+ iterations)
// - Verify all filtered results have stock > 0 when setting is disabled
// - Verify all products returned when setting is enabled
//
// **Validates: Requirements 1.1, 1.2**

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lafetch/controllers/product_controller.dart';
import 'package:lafetch/models/collection_model.dart';

void main() {
  group('Property-Based Test: Filtering Consistency', () {
    late ProductController controller;
    late Random random;

    setUp(() {
      Get.testMode = true;
      controller = ProductController();
      random = Random();
    });

    tearDown(() {
      Get.reset();
    });

    // =========================================================================
    // Helper Functions
    // =========================================================================

    /// Generate a random product list with mixed stock statuses
    /// 
    /// Parameters:
    /// - count: number of products to generate
    /// - outOfStockRatio: ratio of out-of-stock products (0.0 to 1.0)
    /// 
    /// Returns: List of CollectionModel with random stock statuses
    List<CollectionModel> generateRandomProductList({
      required int count,
      required double outOfStockRatio,
    }) {
      assert(outOfStockRatio >= 0.0 && outOfStockRatio <= 1.0,
          'outOfStockRatio must be between 0.0 and 1.0');

      final products = <CollectionModel>[];
      final outOfStockCount = (count * outOfStockRatio).toInt();

      // Create all products
      for (int i = 1; i <= count; i++) {
        products.add(
          CollectionModel(
            id: i,
            name: 'Product $i',
            displayFor: ['homepage'],
            banners: [],
            productMaps: [],
            products: [],
          ),
        );
      }

      // Randomly mark some as out of stock
      final outOfStockIndices = <int>{};
      while (outOfStockIndices.length < outOfStockCount) {
        outOfStockIndices.add(random.nextInt(count));
      }

      for (final index in outOfStockIndices) {
        controller.productStockStatus[products[index].id] = true;
      }

      return products;
    }

    /// Verify that all products in the list have stock > 0
    /// (i.e., none are marked as out of stock)
    void verifyAllProductsInStock(List<CollectionModel> products) {
      for (final product in products) {
        final isOutOfStock = controller.isProductOutOfStock(product.id);
        expect(
          isOutOfStock,
          isFalse,
          reason:
              'Product ${product.id} should not be out of stock. '
              'All filtered products must be in stock.',
        );
      }
    }

    /// Verify that the filtered list contains exactly the expected products
    void verifyFilteredListCorrectness(
      List<CollectionModel> originalList,
      List<CollectionModel> filteredList,
    ) {
      // All filtered products must be in the original list
      for (final filtered in filteredList) {
        expect(
          originalList.any((p) => p.id == filtered.id),
          isTrue,
          reason:
              'Filtered product ${filtered.id} must exist in original list.',
        );
      }

      // All in-stock products from original must be in filtered list
      for (final original in originalList) {
        final isOutOfStock = controller.isProductOutOfStock(original.id);
        if (!isOutOfStock) {
          expect(
            filteredList.any((p) => p.id == original.id),
            isTrue,
            reason:
                'In-stock product ${original.id} must be in filtered list.',
          );
        }
      }
    }

    // =========================================================================
    // Property 1: Out-of-Stock Products Are Filtered from Listings
    // When setting is disabled, all filtered results have stock > 0
    // =========================================================================

    test(
      'Property 1a: Filtering with setting disabled removes all out-of-stock '
      'products (100 iterations with varying list sizes)',
      () {
        controller.showOutOfStockProducts.value = false;

        // Run 100 iterations with different random configurations
        for (int iteration = 0; iteration < 100; iteration++) {
          // Clear previous state
          controller.productStockStatus.clear();

          // Generate random list size (10 to 100 products)
          final listSize = 10 + random.nextInt(91);

          // Generate random out-of-stock ratio (0% to 100%)
          final outOfStockRatio = random.nextDouble();

          // Generate random product list
          final products = generateRandomProductList(
            count: listSize,
            outOfStockRatio: outOfStockRatio,
          );

          // Apply filter
          final filtered = controller.filterProductsByStock(products);

          // Verify all filtered products are in stock
          verifyAllProductsInStock(filtered);

          // Verify filtered list correctness
          verifyFilteredListCorrectness(products, filtered);

          print(
            '✓ Iteration $iteration: '
            'Generated $listSize products, '
            'out-of-stock ratio: ${(outOfStockRatio * 100).toStringAsFixed(1)}%, '
            'filtered to ${filtered.length} products',
          );
        }
      },
    );

    test(
      'Property 1b: Filtering with setting disabled maintains product order',
      () {
        controller.showOutOfStockProducts.value = false;

        for (int iteration = 0; iteration < 50; iteration++) {
          controller.productStockStatus.clear();

          final listSize = 20 + random.nextInt(81);
          final outOfStockRatio = random.nextDouble();

          final products = generateRandomProductList(
            count: listSize,
            outOfStockRatio: outOfStockRatio,
          );

          final filtered = controller.filterProductsByStock(products);

          // Verify order is maintained
          for (int i = 0; i < filtered.length - 1; i++) {
            expect(
              filtered[i].id < filtered[i + 1].id,
              isTrue,
              reason:
                  'Filtered products must maintain original order. '
                  'Product ${filtered[i].id} should come before ${filtered[i + 1].id}.',
            );
          }

          print(
            '✓ Iteration $iteration: '
            'Order maintained for $listSize products, '
            'filtered to ${filtered.length}',
          );
        }
      },
    );

    test(
      'Property 1c: Filtering with setting disabled handles edge cases '
      '(all in-stock, all out-of-stock, empty list)',
      () {
        controller.showOutOfStockProducts.value = false;

        // Test 1: All products in stock
        controller.productStockStatus.clear();
        var products = generateRandomProductList(count: 50, outOfStockRatio: 0.0);
        var filtered = controller.filterProductsByStock(products);
        expect(
          filtered.length,
          equals(50),
          reason: 'All in-stock products should be returned.',
        );

        // Test 2: All products out of stock
        controller.productStockStatus.clear();
        products = generateRandomProductList(count: 50, outOfStockRatio: 1.0);
        filtered = controller.filterProductsByStock(products);
        expect(
          filtered.length,
          equals(0),
          reason: 'No products should be returned when all are out of stock.',
        );

        // Test 3: Empty list
        controller.productStockStatus.clear();
        filtered = controller.filterProductsByStock([]);
        expect(
          filtered.length,
          equals(0),
          reason: 'Empty list should return empty result.',
        );

        // Test 4: Null list
        controller.productStockStatus.clear();
        filtered = controller.filterProductsByStock(null);
        expect(
          filtered.length,
          equals(0),
          reason: 'Null list should return empty result.',
        );

        print('✓ All edge cases handled correctly');
      },
    );

    // =========================================================================
    // Property 2: Out-of-Stock Setting Overrides Filter
    // When setting is enabled, all products are returned
    // =========================================================================

    test(
      'Property 2a: Filtering with setting enabled returns all products '
      '(100 iterations with varying list sizes)',
      () {
        controller.showOutOfStockProducts.value = true;

        for (int iteration = 0; iteration < 100; iteration++) {
          controller.productStockStatus.clear();

          final listSize = 10 + random.nextInt(91);
          final outOfStockRatio = random.nextDouble();

          final products = generateRandomProductList(
            count: listSize,
            outOfStockRatio: outOfStockRatio,
          );

          final filtered = controller.filterProductsByStock(products);

          // Verify all products are returned
          expect(
            filtered.length,
            equals(products.length),
            reason:
                'When setting is enabled, all products must be returned. '
                'Expected ${products.length}, got ${filtered.length}.',
          );

          // Verify all original products are in filtered list
          for (final product in products) {
            expect(
              filtered.any((p) => p.id == product.id),
              isTrue,
              reason: 'Product ${product.id} must be in filtered list.',
            );
          }

          print(
            '✓ Iteration $iteration: '
            'Generated $listSize products, '
            'out-of-stock ratio: ${(outOfStockRatio * 100).toStringAsFixed(1)}%, '
            'returned all $listSize products',
          );
        }
      },
    );

    test(
      'Property 2b: Filtering with setting enabled maintains product order',
      () {
        controller.showOutOfStockProducts.value = true;

        for (int iteration = 0; iteration < 50; iteration++) {
          controller.productStockStatus.clear();

          final listSize = 20 + random.nextInt(81);
          final outOfStockRatio = random.nextDouble();

          final products = generateRandomProductList(
            count: listSize,
            outOfStockRatio: outOfStockRatio,
          );

          final filtered = controller.filterProductsByStock(products);

          // Verify order is maintained
          for (int i = 0; i < filtered.length - 1; i++) {
            expect(
              filtered[i].id < filtered[i + 1].id,
              isTrue,
              reason:
                  'Filtered products must maintain original order. '
                  'Product ${filtered[i].id} should come before ${filtered[i + 1].id}.',
            );
          }

          print(
            '✓ Iteration $iteration: '
            'Order maintained for $listSize products, '
            'returned all $listSize',
          );
        }
      },
    );

    test(
      'Property 2c: Filtering with setting enabled handles edge cases',
      () {
        controller.showOutOfStockProducts.value = true;

        // Test 1: All products in stock
        controller.productStockStatus.clear();
        var products = generateRandomProductList(count: 50, outOfStockRatio: 0.0);
        var filtered = controller.filterProductsByStock(products);
        expect(
          filtered.length,
          equals(50),
          reason: 'All products should be returned.',
        );

        // Test 2: All products out of stock
        controller.productStockStatus.clear();
        products = generateRandomProductList(count: 50, outOfStockRatio: 1.0);
        filtered = controller.filterProductsByStock(products);
        expect(
          filtered.length,
          equals(50),
          reason: 'All products should be returned even if all are out of stock.',
        );

        // Test 3: Empty list
        controller.productStockStatus.clear();
        filtered = controller.filterProductsByStock([]);
        expect(
          filtered.length,
          equals(0),
          reason: 'Empty list should return empty result.',
        );

        // Test 4: Null list
        controller.productStockStatus.clear();
        filtered = controller.filterProductsByStock(null);
        expect(
          filtered.length,
          equals(0),
          reason: 'Null list should return empty result.',
        );

        print('✓ All edge cases handled correctly with setting enabled');
      },
    );

    // =========================================================================
    // Property 3: Setting Toggle Consistency
    // Toggling the setting produces consistent results
    // =========================================================================

    test(
      'Property 3: Toggling setting produces consistent results '
      '(50 iterations)',
      () {
        for (int iteration = 0; iteration < 50; iteration++) {
          controller.productStockStatus.clear();

          final listSize = 20 + random.nextInt(81);
          final outOfStockRatio = random.nextDouble();

          final products = generateRandomProductList(
            count: listSize,
            outOfStockRatio: outOfStockRatio,
          );

          // Test 1: Setting disabled
          controller.showOutOfStockProducts.value = false;
          final filteredDisabled = controller.filterProductsByStock(products);

          // Test 2: Setting enabled
          controller.showOutOfStockProducts.value = true;
          final filteredEnabled = controller.filterProductsByStock(products);

          // Test 3: Setting disabled again
          controller.showOutOfStockProducts.value = false;
          final filteredDisabledAgain =
              controller.filterProductsByStock(products);

          // Verify consistency
          expect(
            filteredDisabled.length,
            equals(filteredDisabledAgain.length),
            reason:
                'Disabling setting twice should produce same result. '
                'First: ${filteredDisabled.length}, Second: ${filteredDisabledAgain.length}',
          );

          expect(
            filteredEnabled.length,
            equals(products.length),
            reason: 'Enabling setting should return all products.',
          );

          expect(
            filteredDisabled.length,
            lessThanOrEqualTo(filteredEnabled.length),
            reason:
                'Disabled filter should return fewer or equal products than enabled.',
          );

          print(
            '✓ Iteration $iteration: '
            'Disabled: ${filteredDisabled.length}, '
            'Enabled: ${filteredEnabled.length}, '
            'Disabled again: ${filteredDisabledAgain.length}',
          );
        }
      },
    );

    // =========================================================================
    // Property 4: Stock Status Update Consistency
    // Updating stock status produces consistent filtering results
    // =========================================================================

    test(
      'Property 4: Stock status updates produce consistent results '
      '(50 iterations)',
      () {
        controller.showOutOfStockProducts.value = false;

        for (int iteration = 0; iteration < 50; iteration++) {
          controller.productStockStatus.clear();

          final listSize = 20 + random.nextInt(81);
          final products = generateRandomProductList(
            count: listSize,
            outOfStockRatio: 0.0, // Start with all in stock
          );

          // Initial filter - should return all
          var filtered = controller.filterProductsByStock(products);
          expect(
            filtered.length,
            equals(listSize),
            reason: 'All products should be in stock initially.',
          );

          // Mark random products as out of stock (track unique IDs)
          final outOfStockIds = <int>{};
          final maxOutOfStock = listSize ~/ 2;
          while (outOfStockIds.length < maxOutOfStock) {
            final productId = 1 + random.nextInt(listSize);
            outOfStockIds.add(productId);
          }

          for (final productId in outOfStockIds) {
            controller.productStockStatus[productId] = true;
          }

          // Filter again
          filtered = controller.filterProductsByStock(products);

          // Verify all filtered products are in stock
          verifyAllProductsInStock(filtered);

          // Verify count is correct
          final expectedCount = listSize - outOfStockIds.length;
          expect(
            filtered.length,
            equals(expectedCount),
            reason:
                'Filtered count should equal expected count. '
                'Expected: $expectedCount, Got: ${filtered.length}',
          );

          print(
            '✓ Iteration $iteration: '
            'Marked ${outOfStockIds.length} as out of stock, '
            'filtered to ${filtered.length} products',
          );
        }
      },
    );

    // =========================================================================
    // Property 5: Large List Performance
    // Filtering works correctly and efficiently on large lists
    // =========================================================================

    test(
      'Property 5: Filtering works correctly on large lists (1000+ products)',
      () {
        controller.showOutOfStockProducts.value = false;

        for (int iteration = 0; iteration < 10; iteration++) {
          controller.productStockStatus.clear();

          // Generate large list (1000 to 2000 products)
          final listSize = 1000 + random.nextInt(1001);
          final outOfStockRatio = random.nextDouble();

          final products = generateRandomProductList(
            count: listSize,
            outOfStockRatio: outOfStockRatio,
          );

          // Measure filtering time
          final stopwatch = Stopwatch()..start();
          final filtered = controller.filterProductsByStock(products);
          stopwatch.stop();

          // Verify correctness
          verifyAllProductsInStock(filtered);
          verifyFilteredListCorrectness(products, filtered);

          // Verify performance (should complete in < 500ms)
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(500),
            reason:
                'Filtering $listSize products should complete in < 500ms. '
                'Took ${stopwatch.elapsedMilliseconds}ms.',
          );

          print(
            '✓ Iteration $iteration: '
            'Filtered $listSize products in ${stopwatch.elapsedMilliseconds}ms, '
            'result: ${filtered.length} products',
          );
        }
      },
    );
  });
}
