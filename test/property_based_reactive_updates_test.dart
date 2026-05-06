// ignore_for_file: avoid_print
//
// Property-Based Test: Reactive Stock Updates
//
// PURPOSE: These tests verify that the UI state updates reactively when
// stock status changes, and that no stale state persists between transitions.
//
// Property 4: Overlay Updates Reactively on Stock Status Change
// - Generate random stock status transitions (in→out, out→in)
// - Verify UI state updates match stock status changes
// - Test 100+ random transitions
// - Verify no stale state persists between transitions
//
// **Validates: Requirements 2.3, 2.4**

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lafetch/controllers/product_controller.dart';
import 'package:lafetch/models/collection_model.dart';

void main() {
  group('Property-Based Test: Reactive Stock Updates', () {
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

    /// Generate a random product with initial stock status
    /// 
    /// Parameters:
    /// - productId: unique identifier for the product
    /// - initiallyOutOfStock: whether product starts as out of stock
    /// 
    /// Returns: CollectionModel with specified stock status
    CollectionModel generateRandomProduct({
      required int productId,
      required bool initiallyOutOfStock,
    }) {
      final product = CollectionModel(
        id: productId,
        name: 'Product $productId',
        displayFor: ['homepage'],
        banners: [],
        productMaps: [],
        products: [],
      );

      // Set initial stock status
      if (initiallyOutOfStock) {
        controller.productStockStatus[productId] = true;
      } else {
        controller.productStockStatus[productId] = false;
      }

      return product;
    }

    /// Generate a random sequence of stock status transitions
    /// 
    /// Parameters:
    /// - productId: the product to generate transitions for
    /// - transitionCount: number of transitions to generate
    /// - initialStatus: starting stock status (true = out of stock)
    /// 
    /// Returns: List of boolean values representing stock status transitions
    List<bool> generateRandomTransitions({
      required int productId,
      required int transitionCount,
      required bool initialStatus,
    }) {
      final transitions = <bool>[initialStatus];

      for (int i = 0; i < transitionCount; i++) {
        // Randomly toggle between in-stock and out-of-stock
        final currentStatus = transitions.last;
        final nextStatus = !currentStatus;
        transitions.add(nextStatus);
      }

      return transitions;
    }

    /// Verify that the observable state matches the expected stock status
    /// 
    /// Parameters:
    /// - productId: the product to verify
    /// - expectedOutOfStock: the expected stock status
    /// - transitionNumber: for error reporting
    void verifyObservableState({
      required int productId,
      required bool expectedOutOfStock,
      required int transitionNumber,
    }) {
      final actualStatus = controller.isProductOutOfStock(productId);

      expect(
        actualStatus,
        equals(expectedOutOfStock),
        reason:
            'Transition $transitionNumber: Product $productId stock status mismatch. '
            'Expected: ${expectedOutOfStock ? "OUT OF STOCK" : "IN STOCK"}, '
            'Got: ${actualStatus ? "OUT OF STOCK" : "IN STOCK"}',
      );
    }

    /// Verify that filtering reflects the current stock status
    /// 
    /// Parameters:
    /// - products: list of products to filter
    /// - expectedInStockCount: expected number of in-stock products after filtering
    /// - transitionNumber: for error reporting
    void verifyFilteringReflectsStatus({
      required List<CollectionModel> products,
      required int expectedInStockCount,
      required int transitionNumber,
    }) {
      controller.showOutOfStockProducts.value = false;
      final filtered = controller.filterProductsByStock(products);

      expect(
        filtered.length,
        equals(expectedInStockCount),
        reason:
            'Transition $transitionNumber: Filtering should return $expectedInStockCount '
            'in-stock products, but got ${filtered.length}',
      );

      // Verify all filtered products are actually in stock
      for (final product in filtered) {
        final isOutOfStock = controller.isProductOutOfStock(product.id);
        expect(
          isOutOfStock,
          isFalse,
          reason:
              'Transition $transitionNumber: Filtered product ${product.id} '
              'should be in stock but is marked as out of stock',
        );
      }
    }

    /// Verify no stale state persists after a transition
    /// 
    /// Parameters:
    /// - productId: the product to verify
    /// - expectedStatus: the expected current status
    /// - previousStatus: the previous status (to detect stale state)
    void verifyNoStaleState({
      required int productId,
      required bool expectedStatus,
      required bool previousStatus,
    }) {
      final currentStatus = controller.isProductOutOfStock(productId);

      expect(
        currentStatus,
        equals(expectedStatus),
        reason:
            'Stale state detected! Product $productId still has previous status '
            '(${previousStatus ? "OUT OF STOCK" : "IN STOCK"}) instead of '
            'current status (${expectedStatus ? "OUT OF STOCK" : "IN STOCK"})',
      );

      expect(
        currentStatus,
        isNot(equals(previousStatus)),
        reason:
            'Stock status did not change for product $productId. '
            'Previous: ${previousStatus ? "OUT OF STOCK" : "IN STOCK"}, '
            'Current: ${currentStatus ? "OUT OF STOCK" : "IN STOCK"}',
      );
    }

    // =========================================================================
    // Property 4a: Single Product Reactive Updates
    // Verify that stock status updates are reflected immediately
    // =========================================================================

    test(
      'Property 4a: Single product reactive updates (100 iterations with '
      'random transitions)',
      () {
        for (int iteration = 0; iteration < 100; iteration++) {
          controller.productStockStatus.clear();

          const productId = 1;
          final initialStatus = random.nextBool();

          // Generate random product
          generateRandomProduct(
            productId: productId,
            initiallyOutOfStock: initialStatus,
          );

          // Generate random transitions (5 to 20 transitions per iteration)
          final transitionCount = 5 + random.nextInt(16);
          final transitions = generateRandomTransitions(
            productId: productId,
            transitionCount: transitionCount,
            initialStatus: initialStatus,
          );

          // Apply each transition and verify state
          for (int transitionIdx = 1; transitionIdx < transitions.length; transitionIdx++) {
            final previousStatus = transitions[transitionIdx - 1];
            final newStatus = transitions[transitionIdx];

            // Update stock status
            controller.updateProductStockStatus(productId, newStatus);

            // Verify observable state matches expected status
            verifyObservableState(
              productId: productId,
              expectedOutOfStock: newStatus,
              transitionNumber: transitionIdx,
            );

            // Verify no stale state persists
            verifyNoStaleState(
              productId: productId,
              expectedStatus: newStatus,
              previousStatus: previousStatus,
            );
          }

          print(
            '✓ Iteration $iteration: '
            'Product $productId underwent $transitionCount transitions, '
            'all state updates verified',
          );
        }
      },
    );

    // =========================================================================
    // Property 4b: Multiple Products Reactive Updates
    // Verify that updates to one product don't affect others
    // =========================================================================

    test(
      'Property 4b: Multiple products reactive updates (50 iterations with '
      'independent transitions)',
      () {
        for (int iteration = 0; iteration < 50; iteration++) {
          controller.productStockStatus.clear();

          // Generate 3-5 random products
          final productCount = 3 + random.nextInt(3);
          final products = <CollectionModel>[];
          final initialStatuses = <int, bool>{};

          for (int i = 1; i <= productCount; i++) {
            final initialStatus = random.nextBool();
            initialStatuses[i] = initialStatus;

            products.add(
              generateRandomProduct(
                productId: i,
                initiallyOutOfStock: initialStatus,
              ),
            );
          }

          // Generate transitions for each product
          final transitionCounts = <int, int>{};
          final allTransitions = <int, List<bool>>{};
          // Track current state of each product (not transition index, but actual state)
          final currentStates = <int, bool>{};

          for (int productId = 1; productId <= productCount; productId++) {
            final transitionCount = 3 + random.nextInt(8);
            transitionCounts[productId] = transitionCount;

            allTransitions[productId] = generateRandomTransitions(
              productId: productId,
              transitionCount: transitionCount,
              initialStatus: initialStatuses[productId]!,
            );
            
            // Initialize current state to initial status
            currentStates[productId] = initialStatuses[productId]!;
          }

          // Apply transitions in random order
          final maxTransitions = transitionCounts.values.reduce((a, b) => a > b ? a : b);

          for (int transitionIdx = 1; transitionIdx < maxTransitions; transitionIdx++) {
            // Randomly select a product to update
            final productId = 1 + random.nextInt(productCount);
            final transitions = allTransitions[productId]!;

            if (transitionIdx < transitions.length) {
              final newStatus = transitions[transitionIdx];

              // Update stock status for this product
              controller.updateProductStockStatus(productId, newStatus);
              
              // Update the current state for this product
              currentStates[productId] = newStatus;

              // Verify this product's state
              verifyObservableState(
                productId: productId,
                expectedOutOfStock: newStatus,
                transitionNumber: transitionIdx,
              );

              // Verify other products' states are not affected
              for (int otherId = 1; otherId <= productCount; otherId++) {
                if (otherId != productId) {
                  final expectedStatus = currentStates[otherId]!;
                  final actualStatus = controller.isProductOutOfStock(otherId);

                  expect(
                    actualStatus,
                    equals(expectedStatus),
                    reason:
                        'Product $otherId state was affected by update to product $productId. '
                        'Expected: ${expectedStatus ? "OUT OF STOCK" : "IN STOCK"}, '
                        'Got: ${actualStatus ? "OUT OF STOCK" : "IN STOCK"}',
                  );
                }
              }
            }
          }

          print(
            '✓ Iteration $iteration: '
            '$productCount products with independent transitions verified',
          );
        }
      },
    );

    // =========================================================================
    // Property 4c: Filtering Reflects Reactive Updates
    // Verify that filtering immediately reflects stock status changes
    // =========================================================================

    test(
      'Property 4c: Filtering reflects reactive updates (50 iterations)',
      () {
        for (int iteration = 0; iteration < 50; iteration++) {
          controller.productStockStatus.clear();

          // Generate random product list
          final productCount = 10 + random.nextInt(41);
          final products = <CollectionModel>[];

          for (int i = 1; i <= productCount; i++) {
            final initialStatus = random.nextBool();
            products.add(
              generateRandomProduct(
                productId: i,
                initiallyOutOfStock: initialStatus,
              ),
            );
          }

          // Count initial in-stock products
          var inStockCount = 0;
          for (int i = 1; i <= productCount; i++) {
            if (!controller.isProductOutOfStock(i)) {
              inStockCount++;
            }
          }

          // Verify initial filtering
          verifyFilteringReflectsStatus(
            products: products,
            expectedInStockCount: inStockCount,
            transitionNumber: 0,
          );

          // Apply random transitions and verify filtering updates
          final transitionCount = 5 + random.nextInt(11);

          for (int transitionIdx = 1; transitionIdx <= transitionCount; transitionIdx++) {
            // Randomly select a product to transition
            final productId = 1 + random.nextInt(productCount);
            final currentStatus = controller.isProductOutOfStock(productId);
            final newStatus = !currentStatus;

            // Update stock status
            controller.updateProductStockStatus(productId, newStatus);

            // Update in-stock count
            if (newStatus) {
              inStockCount--; // Product became out of stock
            } else {
              inStockCount++; // Product became in stock
            }

            // Verify filtering reflects the change
            verifyFilteringReflectsStatus(
              products: products,
              expectedInStockCount: inStockCount,
              transitionNumber: transitionIdx,
            );
          }

          print(
            '✓ Iteration $iteration: '
            '$productCount products with $transitionCount transitions, '
            'filtering verified',
          );
        }
      },
    );

    // =========================================================================
    // Property 4d: Rapid Transitions (Stress Test)
    // Verify that rapid stock status changes don't cause stale state
    // =========================================================================

    test(
      'Property 4d: Rapid transitions stress test (20 iterations with '
      '50+ rapid changes)',
      () {
        for (int iteration = 0; iteration < 20; iteration++) {
          controller.productStockStatus.clear();

          const productId = 1;
          final initialStatus = random.nextBool();

          generateRandomProduct(
            productId: productId,
            initiallyOutOfStock: initialStatus,
          );

          // Apply 50-100 rapid transitions
          final rapidTransitionCount = 50 + random.nextInt(51);
          var currentStatus = initialStatus;

          for (int transitionIdx = 0; transitionIdx < rapidTransitionCount; transitionIdx++) {
            // Toggle status
            currentStatus = !currentStatus;

            // Update stock status
            controller.updateProductStockStatus(productId, currentStatus);

            // Verify state is correct (no stale state)
            final actualStatus = controller.isProductOutOfStock(productId);
            expect(
              actualStatus,
              equals(currentStatus),
              reason:
                  'Rapid transition $transitionIdx: Stale state detected. '
                  'Expected: ${currentStatus ? "OUT OF STOCK" : "IN STOCK"}, '
                  'Got: ${actualStatus ? "OUT OF STOCK" : "IN STOCK"}',
            );
          }

          print(
            '✓ Iteration $iteration: '
            'Product $productId underwent $rapidTransitionCount rapid transitions, '
            'no stale state detected',
          );
        }
      },
    );

    // =========================================================================
    // Property 4e: State Consistency After Transitions
    // Verify that state remains consistent after all transitions complete
    // =========================================================================

    test(
      'Property 4e: State consistency after transitions (50 iterations)',
      () {
        for (int iteration = 0; iteration < 50; iteration++) {
          controller.productStockStatus.clear();

          // Generate 5-10 products
          final productCount = 5 + random.nextInt(6);
          final finalStatuses = <int, bool>{};

          for (int i = 1; i <= productCount; i++) {
            final initialStatus = random.nextBool();
            generateRandomProduct(
              productId: i,
              initiallyOutOfStock: initialStatus,
            );
            finalStatuses[i] = initialStatus;
          }

          // Apply transitions
          final transitionCount = 10 + random.nextInt(21);

          for (int transitionIdx = 0; transitionIdx < transitionCount; transitionIdx++) {
            final productId = 1 + random.nextInt(productCount);
            final newStatus = random.nextBool();

            controller.updateProductStockStatus(productId, newStatus);
            finalStatuses[productId] = newStatus;
          }

          // Verify all products have correct final state
          for (int productId = 1; productId <= productCount; productId++) {
            final expectedStatus = finalStatuses[productId]!;
            final actualStatus = controller.isProductOutOfStock(productId);

            expect(
              actualStatus,
              equals(expectedStatus),
              reason:
                  'Product $productId final state mismatch. '
                  'Expected: ${expectedStatus ? "OUT OF STOCK" : "IN STOCK"}, '
                  'Got: ${actualStatus ? "OUT OF STOCK" : "IN STOCK"}',
            );
          }

          print(
            '✓ Iteration $iteration: '
            '$productCount products with $transitionCount transitions, '
            'final state verified',
          );
        }
      },
    );

    // =========================================================================
    // Property 4f: Observable Map Integrity
    // Verify that the productStockStatus map maintains integrity
    // =========================================================================

    test(
      'Property 4f: Observable map integrity (30 iterations)',
      () {
        for (int iteration = 0; iteration < 30; iteration++) {
          controller.productStockStatus.clear();

          // Generate products and track expected state
          final productCount = 10 + random.nextInt(21);
          final expectedState = <int, bool>{};

          for (int i = 1; i <= productCount; i++) {
            final status = random.nextBool();
            controller.productStockStatus[i] = status;
            expectedState[i] = status;
          }

          // Apply transitions
          final transitionCount = 5 + random.nextInt(11);

          for (int transitionIdx = 0; transitionIdx < transitionCount; transitionIdx++) {
            final productId = 1 + random.nextInt(productCount);
            final newStatus = random.nextBool();

            controller.updateProductStockStatus(productId, newStatus);
            expectedState[productId] = newStatus;
          }

          // Verify map contains all products
          expect(
            controller.productStockStatus.length,
            equals(productCount),
            reason:
                'Observable map should contain $productCount products, '
                'but contains ${controller.productStockStatus.length}',
          );

          // Verify all entries match expected state
          for (final entry in controller.productStockStatus.entries) {
            final productId = entry.key;
            final actualStatus = entry.value;
            final expectedStatus = expectedState[productId]!;

            expect(
              actualStatus,
              equals(expectedStatus),
              reason:
                  'Product $productId map entry mismatch. '
                  'Expected: ${expectedStatus ? "OUT OF STOCK" : "IN STOCK"}, '
                  'Got: ${actualStatus ? "OUT OF STOCK" : "IN STOCK"}',
            );
          }

          print(
            '✓ Iteration $iteration: '
            'Observable map integrity verified for $productCount products',
          );
        }
      },
    );

    // =========================================================================
    // Property 4g: Transition Sequence Validation
    // Verify that transitions follow expected patterns
    // =========================================================================

    test(
      'Property 4g: Transition sequence validation (40 iterations)',
      () {
        for (int iteration = 0; iteration < 40; iteration++) {
          controller.productStockStatus.clear();

          const productId = 1;
          final initialStatus = random.nextBool();

          generateRandomProduct(
            productId: productId,
            initiallyOutOfStock: initialStatus,
          );

          // Generate and apply transitions, tracking the sequence
          final transitionSequence = <bool>[initialStatus];
          final transitionCount = 10 + random.nextInt(21);

          for (int transitionIdx = 0; transitionIdx < transitionCount; transitionIdx++) {
            final currentStatus = transitionSequence.last;
            final newStatus = !currentStatus;

            controller.updateProductStockStatus(productId, newStatus);
            transitionSequence.add(newStatus);

            // Verify current state matches sequence
            final actualStatus = controller.isProductOutOfStock(productId);
            expect(
              actualStatus,
              equals(newStatus),
              reason:
                  'Transition sequence mismatch at index $transitionIdx. '
                  'Expected: ${newStatus ? "OUT OF STOCK" : "IN STOCK"}, '
                  'Got: ${actualStatus ? "OUT OF STOCK" : "IN STOCK"}',
            );
          }

          // Verify final state matches last transition
          final finalStatus = controller.isProductOutOfStock(productId);
          expect(
            finalStatus,
            equals(transitionSequence.last),
            reason:
                'Final state does not match last transition. '
                'Expected: ${transitionSequence.last ? "OUT OF STOCK" : "IN STOCK"}, '
                'Got: ${finalStatus ? "OUT OF STOCK" : "IN STOCK"}',
          );

          print(
            '✓ Iteration $iteration: '
            'Transition sequence validated for $transitionCount transitions',
          );
        }
      },
    );
  });
}
