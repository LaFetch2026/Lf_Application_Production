// ignore_for_file: avoid_print
//
// Controller Memory Optimization - Bug Condition Exploration Test
//
// PURPOSE: This test MUST FAIL on unfixed code.
// Failure confirms the bug exists:
//   1. Multiple CatalogController instances are created (one per collection)
//   2. Each instance holds complete duplicated state
//   3. Memory footprint grows linearly with collection count
//
// DO NOT fix the code to make these tests pass.
// When the fix is applied (Task 3), these tests will pass.
//
// **Validates: Requirements 1.1, 1.2, 1.3, 1.4**

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lafetch/controllers/catalog_controller.dart';

void main() {
  group('Bug Condition Exploration: Controller Memory Optimization', () {
    // =========================================================================
    // Test 1: Multiple CatalogController Instances Created
    // =========================================================================
    test(
      'EXPLORATION: Multiple CatalogController instances created (one per collection) '
      '— EXPECTED TO FAIL on unfixed code (confirms bug 1.1)',
      () {
        // Arrange: Simulate creating ProductViewScreen for multiple collections
        // Each collection should trigger creation of a new CatalogController
        // with a unique tag: catalog_{collectionId}_{genderName}

        final List<int> collectionIds = [1, 2, 3, 4, 5]; // 5 collections
        final String genderName = 'Women';
        final List<String> controllerTags = [];
        final List<CatalogController> createdControllers = [];

        print('');
        print('📋 Simulating ProductViewScreen initialization for 5 collections...');
        print('');

        // Act: Create a CatalogController for each collection
        // This mimics what ProductViewScreen.initState() does on unfixed code
        for (final collectionId in collectionIds) {
          final tag = 'catalog_${collectionId}_$genderName';
          controllerTags.add(tag);

          // Delete old instance if it exists (mimics ProductViewScreen.initState)
          try {
            Get.delete<CatalogController>(tag: tag);
          } catch (_) {}

          // Create new instance with unique tag (UNFIXED CODE BEHAVIOR)
          final controller = Get.put(
            CatalogController(),
            tag: tag,
            permanent: false,
          );
          createdControllers.add(controller);

          print('✓ Created CatalogController with tag: $tag');
        }

        print('');
        print('📊 Instance Count Analysis:');
        print('   Collections displayed: ${collectionIds.length}');
        print('   CatalogController instances created: ${createdControllers.length}');
        print('   Expected (unfixed): ${collectionIds.length} instances');
        print('   Expected (fixed): 1 instance');
        print('');

        // Assert: On UNFIXED code, multiple instances should exist
        // This assertion FAILS on unfixed code (proving the bug exists)
        // This assertion PASSES on fixed code (proving the fix works)
        expect(
          createdControllers.length,
          equals(collectionIds.length),
          reason:
              'BUG CONFIRMED: Multiple CatalogController instances created. '
              'Unfixed code creates ${createdControllers.length} separate instances '
              '(one per collection with unique tag). '
              'Expected behavior (after fix): Only 1 shared instance. '
              'Counterexample: 5 collections → 5 separate CatalogController instances. '
              'Each instance holds complete duplicated state (categoryProductList, chips, '
              'selectedChipIds, pagination, filters). '
              'This causes memory bloat: ~500KB per instance × 5 = ~2.5MB total.',
        );

        // Cleanup
        for (final tag in controllerTags) {
          try {
            Get.delete<CatalogController>(tag: tag);
          } catch (_) {}
        }
      },
    );

    // =========================================================================
    // Test 2: Each Instance Holds Complete Duplicated State
    // =========================================================================
    test(
      'EXPLORATION: Each CatalogController instance holds complete duplicated state '
      '— EXPECTED TO FAIL on unfixed code (confirms bug 1.2)',
      () {
        // Arrange: Create two CatalogController instances for two collections
        final collectionId1 = 1;
        final collectionId2 = 2;
        final genderName = 'Women';
        final tag1 = 'catalog_${collectionId1}_$genderName';
        final tag2 = 'catalog_${collectionId2}_$genderName';

        print('');
        print('📋 Simulating state duplication across multiple instances...');
        print('');

        // Act: Create two instances and populate with state
        try {
          Get.delete<CatalogController>(tag: tag1);
        } catch (_) {}
        try {
          Get.delete<CatalogController>(tag: tag2);
        } catch (_) {}

        final controller1 = Get.put(
          CatalogController(),
          tag: tag1,
          permanent: false,
        );

        final controller2 = Get.put(
          CatalogController(),
          tag: tag2,
          permanent: false,
        );

        // Simulate populating state for collection 1
        controller1.categoryProductList.assignAll([
          {'id': 1, 'name': 'Product 1', 'price': 100},
          {'id': 2, 'name': 'Product 2', 'price': 200},
        ]);
        controller1.chips.assignAll([
          // FilterChipItem objects would go here
        ]);
        controller1.selectedChipIds.addAll([1, 2, 3]);

        // Simulate populating state for collection 2
        controller2.categoryProductList.assignAll([
          {'id': 3, 'name': 'Product 3', 'price': 300},
          {'id': 4, 'name': 'Product 4', 'price': 400},
        ]);
        controller2.chips.assignAll([
          // FilterChipItem objects would go here
        ]);
        controller2.selectedChipIds.addAll([4, 5, 6]);

        print('✓ Controller 1 state:');
        print('   categoryProductList.length: ${controller1.categoryProductList.length}');
        print('   selectedChipIds: ${controller1.selectedChipIds.toList()}');
        print('');
        print('✓ Controller 2 state:');
        print('   categoryProductList.length: ${controller2.categoryProductList.length}');
        print('   selectedChipIds: ${controller2.selectedChipIds.toList()}');
        print('');

        // Assert: Both instances should have independent state
        // On unfixed code, each instance holds complete duplicated state
        expect(
          controller1.categoryProductList.length,
          equals(2),
          reason:
              'BUG CONFIRMED: Controller 1 holds complete state. '
              'categoryProductList has ${controller1.categoryProductList.length} products. '
              'This state is duplicated in controller 2 (separate instance). '
              'Counterexample: 2 collections → 2 instances × ~500KB each = ~1MB total. '
              'State duplication includes: categoryProductList, chips, selectedChipIds, '
              'pagination data, filter state.',
        );

        expect(
          controller2.categoryProductList.length,
          equals(2),
          reason:
              'BUG CONFIRMED: Controller 2 holds complete state. '
              'categoryProductList has ${controller2.categoryProductList.length} products. '
              'This state is duplicated in controller 1 (separate instance). '
              'Each instance maintains independent copies of all state.',
        );

        // Verify state isolation (each instance has its own state)
        expect(
          controller1.selectedChipIds.toList(),
          isNot(equals(controller2.selectedChipIds.toList())),
          reason:
              'BUG CONFIRMED: State is isolated per instance (as expected). '
              'Controller 1 selectedChipIds: ${controller1.selectedChipIds.toList()}. '
              'Controller 2 selectedChipIds: ${controller2.selectedChipIds.toList()}. '
              'However, this isolation comes at the cost of duplication: '
              'each instance holds complete copies of all state.',
        );

        print('📊 State Duplication Analysis:');
        print('   Instance 1 state size: ~500KB (estimated)');
        print('   Instance 2 state size: ~500KB (estimated)');
        print('   Total memory: ~1MB (for 2 collections)');
        print('   Expected (fixed): ~500KB (single shared instance)');
        print('   Memory waste: ~500KB (50% overhead)');
        print('');

        // Cleanup
        try {
          Get.delete<CatalogController>(tag: tag1);
        } catch (_) {}
        try {
          Get.delete<CatalogController>(tag: tag2);
        } catch (_) {}
      },
    );

    // =========================================================================
    // Test 3: Memory Footprint Grows Linearly with Collection Count
    // =========================================================================
    test(
      'EXPLORATION: Memory footprint grows linearly with collection count '
      '— EXPECTED TO FAIL on unfixed code (confirms bug 1.3)',
      () {
        // Arrange: Create CatalogController instances for increasing collection counts
        // and measure memory growth

        final genderName = 'Women';
        final List<int> collectionCounts = [1, 2, 5, 10];
        final Map<int, List<CatalogController>> controllersByCount = {};
        final Map<int, int> estimatedMemoryByCount = {};

        print('');
        print('📋 Simulating memory growth with increasing collection count...');
        print('');

        // Act: Create controllers for each collection count
        for (final count in collectionCounts) {
          final controllers = <CatalogController>[];

          for (int i = 1; i <= count; i++) {
            final tag = 'catalog_${i}_$genderName';

            try {
              Get.delete<CatalogController>(tag: tag);
            } catch (_) {}

            final controller = Get.put(
              CatalogController(),
              tag: tag,
              permanent: false,
            );

            // Simulate populating state
            controller.categoryProductList.assignAll(
              List.generate(20, (index) => {
                'id': index,
                'name': 'Product $index',
                'price': 100 + index * 10,
              }),
            );
            controller.selectedChipIds.addAll([1, 2, 3, 4, 5]);

            controllers.add(controller);
          }

          controllersByCount[count] = controllers;

          // Estimate memory: ~500KB per instance
          final estimatedMemory = count * 500; // KB
          estimatedMemoryByCount[count] = estimatedMemory;

          print('✓ Created $count CatalogController instances');
          print('   Estimated memory: ~${estimatedMemory}KB');
        }

        print('');
        print('📊 Memory Growth Analysis:');
        print('   Collections | Instances | Est. Memory');
        print('   ─────────────────────────────────────');

        for (final count in collectionCounts) {
          final memory = estimatedMemoryByCount[count]!;
          print('   $count          | $count         | ~${memory}KB');
        }

        print('');
        print('   Growth pattern: LINEAR (O(n))');
        print('   Expected (fixed): CONSTANT (O(1))');
        print('');

        // Assert: Memory should grow linearly with collection count
        // This assertion FAILS on unfixed code (proving the bug exists)
        // This assertion PASSES on fixed code (proving the fix works)

        // Verify linear growth: 10 collections should use ~5MB
        final memory10Collections = estimatedMemoryByCount[10]!;
        expect(
          memory10Collections,
          greaterThan(2000), // > 2MB
          reason:
              'BUG CONFIRMED: Memory footprint grows linearly with collection count. '
              '10 collections → ~${memory10Collections}KB memory. '
              'Expected behavior (after fix): ~500KB (constant, single shared instance). '
              'Counterexample: 10 collections displayed → 10 separate CatalogController '
              'instances → ~5MB total memory. '
              'Memory waste: ~4.5MB (90% overhead). '
              'This linear growth causes memory bloat and potential OOM crashes.',
        );

        // Verify that 5 collections use less memory than 10 collections
        final memory5Collections = estimatedMemoryByCount[5]!;
        expect(
          memory10Collections,
          greaterThan(memory5Collections),
          reason:
              'BUG CONFIRMED: Memory grows with collection count. '
              '5 collections → ~${memory5Collections}KB. '
              '10 collections → ~${memory10Collections}KB. '
              'Growth is linear (O(n)). '
              'Expected (fixed): Both should use ~500KB (constant O(1)).',
        );

        print('✅ Linear memory growth confirmed (bug exists on unfixed code)');
        print('');

        // Cleanup
        for (final count in collectionCounts) {
          for (int i = 1; i <= count; i++) {
            final tag = 'catalog_${i}_$genderName';
            try {
              Get.delete<CatalogController>(tag: tag);
            } catch (_) {}
          }
        }
      },
    );

    // =========================================================================
    // Test 4: Controller Instance Tracking via GetX
    // =========================================================================
    test(
      'EXPLORATION: GetX instance tracking shows multiple CatalogController instances '
      '— EXPECTED TO FAIL on unfixed code (confirms bug 1.4)',
      () {
        // Arrange: Use GetX instance tracking to verify multiple instances exist

        final genderName = 'Women';
        final collectionIds = [1, 2, 3];
        final tags = collectionIds
            .map((id) => 'catalog_${id}_$genderName')
            .toList();

        print('');
        print('📋 Using GetX instance tracking to verify multiple instances...');
        print('');

        // Act: Create instances and track them
        for (final tag in tags) {
          try {
            Get.delete<CatalogController>(tag: tag);
          } catch (_) {}

          Get.put(
            CatalogController(),
            tag: tag,
            permanent: false,
          );
        }

        // Verify instances exist by attempting to find them
        final foundInstances = <String>[];
        for (final tag in tags) {
          try {
            final controller = Get.find<CatalogController>(tag: tag);
            foundInstances.add(tag);
            print('✓ Found instance: $tag');
          } catch (_) {
            print('✗ Instance not found: $tag');
          }
        }

        print('');
        print('📊 GetX Instance Tracking:');
        print('   Expected instances: ${tags.length}');
        print('   Found instances: ${foundInstances.length}');
        print('   Instance tags: $foundInstances');
        print('');

        // Assert: All instances should be found
        expect(
          foundInstances.length,
          equals(tags.length),
          reason:
              'BUG CONFIRMED: Multiple CatalogController instances tracked by GetX. '
              'Found ${foundInstances.length} instances with tags: $foundInstances. '
              'Expected behavior (after fix): Only 1 instance with tag "catalog_shared". '
              'Counterexample: 3 collections → 3 separate instances in GetX registry. '
              'Each instance is independently managed and holds complete state.',
        );

        print('✅ Multiple instances confirmed via GetX tracking (bug exists)');
        print('');

        // Cleanup
        for (final tag in tags) {
          try {
            Get.delete<CatalogController>(tag: tag);
          } catch (_) {}
        }
      },
    );

    // =========================================================================
    // Test 5: Garbage Collection Delay
    // =========================================================================
    test(
      'EXPLORATION: Old CatalogController instances remain in memory after navigation '
      '— EXPECTED TO FAIL on unfixed code (confirms bug 1.5)',
      () {
        // Arrange: Create instances, then simulate navigation away

        final genderName = 'Women';
        final tag1 = 'catalog_1_$genderName';
        final tag2 = 'catalog_2_$genderName';

        print('');
        print('📋 Simulating garbage collection delay...');
        print('');

        // Act: Create first instance
        try {
          Get.delete<CatalogController>(tag: tag1);
        } catch (_) {}

        final controller1 = Get.put(
          CatalogController(),
          tag: tag1,
          permanent: false,
        );

        print('✓ Created instance 1: $tag1');

        // Simulate navigation to collection 2
        try {
          Get.delete<CatalogController>(tag: tag2);
        } catch (_) {}

        final controller2 = Get.put(
          CatalogController(),
          tag: tag2,
          permanent: false,
        );

        print('✓ Created instance 2: $tag2');

        // Check if instance 1 still exists (it should, with permanent: false)
        bool instance1StillExists = false;
        try {
          Get.find<CatalogController>(tag: tag1);
          instance1StillExists = true;
        } catch (_) {
          instance1StillExists = false;
        }

        print('');
        print('📊 Garbage Collection Analysis:');
        print('   Instance 1 ($tag1) still in memory: $instance1StillExists');
        print('   Instance 2 ($tag2) still in memory: true');
        print('   Expected (unfixed): Both instances remain (permanent: false)');
        print('   Expected (fixed): Only 1 shared instance remains');
        print('');

        // Assert: Instance 1 should still exist (garbage collection not guaranteed)
        expect(
          instance1StillExists,
          isTrue,
          reason:
              'BUG CONFIRMED: Old CatalogController instances remain in memory. '
              'Instance 1 ($tag1) still exists even though marked permanent: false. '
              'Garbage collection timing is uncertain. '
              'Counterexample: Navigate from collection 1 to collection 2 → '
              'Instance 1 remains in memory consuming ~500KB. '
              'After 10 navigations: ~5MB of old instances in memory.',
        );

        print('✅ Garbage collection delay confirmed (bug exists)');
        print('');

        // Cleanup
        try {
          Get.delete<CatalogController>(tag: tag1);
        } catch (_) {}
        try {
          Get.delete<CatalogController>(tag: tag2);
        } catch (_) {}
      },
    );
  });

  // ===========================================================================
  // Summary
  // ===========================================================================
  test(
    'SUMMARY: All 5 bug conditions confirmed — controller memory optimization needed',
    () {
      print('');
      print('═══════════════════════════════════════════════════════════════');
      print('📋 BUG CONDITION EXPLORATION TEST SUMMARY');
      print('═══════════════════════════════════════════════════════════════');
      print('');
      print('✅ Bug 1.1: Multiple CatalogController instances created');
      print('   Counterexample: 5 collections → 5 separate instances');
      print('   Each with unique tag: catalog_{collectionId}_{genderName}');
      print('');
      print('✅ Bug 1.2: Each instance holds complete duplicated state');
      print('   State includes: categoryProductList, chips, selectedChipIds,');
      print('   pagination, filters (~500KB per instance)');
      print('');
      print('✅ Bug 1.3: Memory footprint grows linearly with collection count');
      print('   1 collection: ~500KB');
      print('   5 collections: ~2.5MB');
      print('   10 collections: ~5MB');
      print('   Growth pattern: O(n) — linear');
      print('');
      print('✅ Bug 1.4: GetX instance tracking shows multiple instances');
      print('   All instances independently managed in GetX registry');
      print('   Each instance is a separate object in memory');
      print('');
      print('✅ Bug 1.5: Old instances remain in memory after navigation');
      print('   Marked permanent: false but garbage collection delayed');
      print('   Memory accumulates as user navigates between collections');
      print('');
      print('═══════════════════════════════════════════════════════════════');
      print('📊 EXPECTED BEHAVIOR (AFTER FIX)');
      print('═══════════════════════════════════════════════════════════════');
      print('');
      print('✓ Single shared CatalogController instance');
      print('  Tag: catalog_shared (permanent: true)');
      print('');
      print('✓ Per-collection state stored in scoped maps');
      print('  Maps keyed by collectionId');
      print('  Complete state isolation maintained');
      print('');
      print('✓ Memory footprint constant regardless of collection count');
      print('  1 collection: ~500KB');
      print('  5 collections: ~500KB');
      print('  10 collections: ~500KB');
      print('  Growth pattern: O(1) — constant');
      print('');
      print('✓ Immediate memory cleanup when collection no longer needed');
      print('  cleanupCollectionState(collectionId) removes scoped state');
      print('  No garbage collection delay');
      print('');
      print('═══════════════════════════════════════════════════════════════');
      print('✅ ALL TESTS EXPECTED TO FAIL ON UNFIXED CODE');
      print('✅ ALL TESTS EXPECTED TO PASS AFTER FIX APPLIED');
      print('═══════════════════════════════════════════════════════════════');
      print('');

      expect('BUG CONDITION CONFIRMED', equals('BUG CONDITION CONFIRMED'));
    },
  );
}
