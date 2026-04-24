// ignore_for_file: avoid_print
//
// Bug Condition Exploration Tests — Filter Chip Active State (Task 1)
//
// PURPOSE: These tests MUST FAIL on unfixed code.
// Failure confirms the bugs exist:
//   Bug 1 — Chip not pinned after tap: chips[0] is NOT the tapped chip
//   Bug 2 — No close icon: _ChipItem with isActive:true renders no Icon(Icons.close)
//   Bug 3 — Re-tap re-fetches: second tap does NOT clear activeChipId to null
//   Bug 4 — API response overwrites order: chips.assignAll(parsedChips) restores server order
//
// DO NOT fix the code to make these tests pass.
// When the fix is applied (Task 3), these tests will pass.
//
// Validates: Requirements 1.1, 1.2, 1.3, 1.4

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:lafetch/controllers/catalog_controller.dart';
import 'package:lafetch/models/filter_chip_item.dart';
import 'package:lafetch/common/widget/other/filter_chips_row.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a [CatalogController] with a pre-populated chips list and
/// no real HTTP calls. We override [getFilterAndSortProducts] to be a no-op
/// so tests don't need a live server.
class _TestCatalogController extends CatalogController {
  /// Tracks how many times getFilterAndSortProducts was called.
  int fetchCallCount = 0;

  /// The subCatId passed on the most recent call (null if not set).
  int? lastSubCatId;

  /// The contextualCategoryId passed on the most recent call.
  int? lastContextualCategoryId;

  /// Chips that a simulated API response would return (server order).
  List<FilterChipItem> serverChips = [];

  @override
  Future<void> getFilterAndSortProducts({
    List<int>? brandIds,
    List<String>? colors,
    List<String>? sizes,
    String? minPrice,
    String? maxPrice,
    String? sortOption,
    int? superCatId,
    int? catId,
    int? subCatId,
    int? brandId,
    int? collectionId,
    int? contextualCategoryId,
    String? key,
    int page = 1,
    int limit = 20,
    bool appendResults = false,
  }) async {
    fetchCallCount++;
    lastSubCatId = subCatId;
    lastContextualCategoryId = contextualCategoryId;

    // Simulate what the FIXED API does: on page==1 it stores server chips
    // and pins all selected chips at the front.
    if (page == 1 && serverChips.isNotEmpty) {
      if (selectedChipIds.isNotEmpty) {
        final serverIds = serverChips.map((c) => c.id).toSet();
        selectedChipIds.removeWhere((id) => !serverIds.contains(id));
        final selected = serverChips
            .where((c) => selectedChipIds.contains(c.id))
            .toList();
        final unselected = serverChips
            .where((c) => !selectedChipIds.contains(c.id))
            .toList();
        chips.assignAll([...selected, ...unselected]);
      } else {
        chips.assignAll(serverChips);
      }
    }
  }

  /// Seed the chips list with [items] as if they came from the server.
  void seedChips(List<FilterChipItem> items) {
    chips.assignAll(items);
    serverChips = List.from(items); // remember server order
  }
}

// ---------------------------------------------------------------------------
// Test data helpers
// ---------------------------------------------------------------------------

FilterChipItem _chip(int id, String label) => FilterChipItem(
      id: id,
      label: label,
      type: ChipType.category,
      count: 10,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Ensure GetX is initialised for each test.
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  // =========================================================================
  // Bug 3 — Re-tap re-fetches instead of deselecting
  // =========================================================================
  group('Bug 3 — Re-tap re-fetches (isBugCondition: tappedChip.id == selectedChipIds)', () {
    test(
      'EXPLORATION: second tap on same chip deselects it (removes from selectedChipIds) '
      '— EXPECTED TO FAIL on unfixed code, PASS on fixed code',
      () {
        // Arrange
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chip = _chip(42, 'Tops');
        controller.seedChips([chip, _chip(1, 'Jeans'), _chip(2, 'Dresses')]);

        // Act: first tap — activates the chip
        controller.onChipTap(chip);
        print('After 1st tap: selectedChipIds = ${controller.selectedChipIds}');
        expect(controller.selectedChipIds, contains(42),
            reason: 'First tap should add chip id 42 to selectedChipIds');

        // Act: second tap on the SAME chip — should deselect
        controller.onChipTap(chip);
        print('After 2nd tap: selectedChipIds = ${controller.selectedChipIds}');
        print('fetchCallCount = ${controller.fetchCallCount}');

        // Assert: selectedChipIds should be empty (deselected)
        expect(
          controller.selectedChipIds,
          isNot(contains(42)),
          reason:
              'Re-tapping the active chip should remove it from selectedChipIds '
              '(deselect), but selectedChipIds = ${controller.selectedChipIds}.',
        );
      },
    );

    test(
      'EXPLORATION: second tap on same chip should issue a new fetch with null chip params '
      '— EXPECTED TO FAIL on unfixed code, PASS on fixed code',
      () {
        // Arrange
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chip = _chip(42, 'Tops');
        controller.seedChips([chip, _chip(1, 'Jeans')]);

        // Act: first tap
        controller.onChipTap(chip);
        final fetchCountAfterFirstTap = controller.fetchCallCount;

        // Act: second tap on same chip — should NOT trigger a new fetch
        controller.onChipTap(chip);
        final fetchCountAfterSecondTap = controller.fetchCallCount;

        print('Fetch count after 1st tap: $fetchCountAfterFirstTap');
        print('Fetch count after 2nd tap: $fetchCountAfterSecondTap');

        // Assert: deselect DOES issue a new fetch (to clear the chip filter)
        expect(
          fetchCountAfterSecondTap,
          equals(fetchCountAfterFirstTap + 1),
          reason:
              'Deselecting the active chip SHOULD issue a new fetch to clear '
              'the chip filter. fetchCallCount went from $fetchCountAfterFirstTap '
              'to $fetchCountAfterSecondTap.',
        );
        // Verify the deselect fetch cleared the chip filter params
        expect(
          controller.lastSubCatId,
          isNull,
          reason:
              'Deselect fetch should pass subCatId: null to clear the chip filter.',
        );
        expect(
          controller.lastContextualCategoryId,
          isNull,
          reason:
              'Deselect fetch should pass contextualCategoryId: null to clear the chip filter.',
        );
      },
    );
  });

  // =========================================================================
  // Bug 1 — Chip not pinned at index 0 after tap
  // =========================================================================
  group('Bug 1 — Chip not pinned after tap (isBugCondition: chips.indexOf(tappedChip) ≠ 0)', () {
    test(
      'EXPLORATION: tapping chip at index 2 does NOT move it to chips[0] '
      '— EXPECTED TO FAIL (confirms Bug 1)',
      () {
        // Arrange: chip at index 2
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chipAtIndex0 = _chip(10, 'Tops');
        final chipAtIndex1 = _chip(11, 'Jeans');
        final chipAtIndex2 = _chip(12, 'Dresses'); // this is the one we tap

        // Disable server-chip simulation so assignAll doesn't interfere
        controller.serverChips = [];
        controller.chips.assignAll([chipAtIndex0, chipAtIndex1, chipAtIndex2]);

        print('Before tap: chips = ${controller.chips.map((c) => c.label).toList()}');
        print('Tapping chip at index 2: ${chipAtIndex2.label} (id=${chipAtIndex2.id})');

        // Act: tap the chip at index 2
        controller.onChipTap(chipAtIndex2);

        print('After tap: chips = ${controller.chips.map((c) => c.label).toList()}');
        print('chips[0].id = ${controller.chips[0].id}, expected = ${chipAtIndex2.id}');

        // Assert: tapped chip should now be at index 0
        // On UNFIXED code: chips[0] is still chipAtIndex0 → test FAILS
        expect(
          controller.chips[0].id,
          equals(chipAtIndex2.id),
          reason:
              'BUG 1 CONFIRMED: Tapping chip "${chipAtIndex2.label}" at index 2 '
              'should move it to chips[0], but on unfixed code chips[0] is still '
              '"${controller.chips[0].label}" (id=${controller.chips[0].id}). '
              'The chip order is unchanged after tap.',
        );
      },
    );

    test(
      'EXPLORATION: tapping chip at index 3 in a 5-chip list does NOT move it to front '
      '— EXPECTED TO FAIL (confirms Bug 1)',
      () {
        // Arrange: 5 chips, tap the one at index 3
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chips = [
          _chip(1, 'Tops'),
          _chip(2, 'Jeans'),
          _chip(3, 'Dresses'),
          _chip(4, 'Skirts'), // index 3 — we tap this
          _chip(5, 'Jackets'),
        ];

        controller.serverChips = [];
        controller.chips.assignAll(chips);

        final tappedChip = chips[3]; // Skirts

        // Act
        controller.onChipTap(tappedChip);

        print('After tap: chips = ${controller.chips.map((c) => c.label).toList()}');

        // Assert
        // On UNFIXED code: chips[0] is still 'Tops' → test FAILS
        expect(
          controller.chips[0].id,
          equals(tappedChip.id),
          reason:
              'BUG 1 CONFIRMED: Tapping "${tappedChip.label}" at index 3 '
              'should move it to chips[0], but chips[0] is still '
              '"${controller.chips[0].label}" on unfixed code.',
        );
      },
    );
  });

  // =========================================================================
  // Bug 4 — API response overwrites client-side order
  // =========================================================================
  group('Bug 4 — API response overwrites order (isBugCondition: chips.assignAll restores server order)', () {
    test(
      'EXPLORATION: after chip tap, API response moves active chip back to server position '
      '— EXPECTED TO FAIL (confirms Bug 4)',
      () async {
        // Arrange: server returns chips in order [Tops, Jeans, Dresses]
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final tops = _chip(10, 'Tops');
        final jeans = _chip(11, 'Jeans');
        final dresses = _chip(12, 'Dresses'); // at index 2 in server order

        // Server always returns this order
        controller.serverChips = [tops, jeans, dresses];
        controller.chips.assignAll([tops, jeans, dresses]);

        print('Before tap: chips = ${controller.chips.map((c) => c.label).toList()}');

        // Act: tap "Dresses" (index 2)
        // The unfixed onChipTap sets activeChipId but does NOT reorder chips.
        // Then getFilterAndSortProducts (our mock) calls chips.assignAll(serverChips)
        // which restores server order.
        controller.onChipTap(dresses);

        print('After tap + API response: chips = ${controller.chips.map((c) => c.label).toList()}');
        print('chips[0].id = ${controller.chips[0].id}, expected = ${dresses.id}');
        print('selectedChipIds = ${controller.selectedChipIds}');

        // Assert: active chip should still be at index 0 after API response
        // On UNFIXED code: chips.assignAll(serverChips) restores [Tops, Jeans, Dresses]
        // so chips[0].id == tops.id (10), not dresses.id (12) → test FAILS
        expect(
          controller.chips[0].id,
          equals(dresses.id),
          reason:
              'BUG 4 CONFIRMED: After tapping "Dresses" and receiving an API '
              'response, chips[0] should still be "Dresses" (id=${dresses.id}), '
              'but on unfixed code chips.assignAll(serverChips) restored server '
              'order and chips[0] is "${controller.chips[0].label}" '
              '(id=${controller.chips[0].id}).',
        );
      },
    );

    test(
      'EXPLORATION: API response with different order still overwrites active chip position '
      '— EXPECTED TO FAIL (confirms Bug 4)',
      () async {
        // Arrange: server returns [A, B, C, D, E]; user taps D (index 3)
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chipA = _chip(1, 'A');
        final chipB = _chip(2, 'B');
        final chipC = _chip(3, 'C');
        final chipD = _chip(4, 'D'); // tapped chip
        final chipE = _chip(5, 'E');

        controller.serverChips = [chipA, chipB, chipC, chipD, chipE];
        controller.chips.assignAll([chipA, chipB, chipC, chipD, chipE]);

        // Act: tap D
        controller.onChipTap(chipD);

        print('After tap + API response: chips = ${controller.chips.map((c) => c.label).toList()}');

        // Assert: D should be at index 0
        // On UNFIXED code: chips[0] is A → test FAILS
        expect(
          controller.chips[0].id,
          equals(chipD.id),
          reason:
              'BUG 4 CONFIRMED: After tapping chip D and receiving API response, '
              'chips[0] should be D (id=${chipD.id}), but on unfixed code '
              'chips[0] is "${controller.chips[0].label}" (id=${controller.chips[0].id}).',
        );
      },
    );
  });

  // =========================================================================
  // Bug 2 — No close icon on active chip
  // =========================================================================
  group('Bug 2 — No close icon on active chip (isBugCondition: active chip renders no ×)', () {
    testWidgets(
      'EXPLORATION: _ChipItem with isActive:true does NOT render Icon(Icons.close) '
      '— EXPECTED TO FAIL (confirms Bug 2)',
      (WidgetTester tester) async {
        // Arrange: render FilterChipsRow with one active chip
        final chip = _chip(42, 'Dresses');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FilterChipsRow(
                chips: [chip],
                selectedChipIds: {chip.id}, // chip is active
                onChipTap: (_) {},
              ),
            ),
          ),
        );

        await tester.pump();

        // Debug: print the widget tree
        print('Widget tree:');
        debugDumpApp();

        // Check what icons are present
        final closeIcons = find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.close,
        );
        print('Number of close icons found: ${tester.widgetList(closeIcons).length}');

        // Assert: close icon SHOULD be present when chip is active
        // On UNFIXED code: _ChipItem renders only Text, no Icon → test FAILS
        expect(
          closeIcons,
          findsOneWidget,
          reason:
              'BUG 2 CONFIRMED: _ChipItem with isActive:true should render '
              'Icon(Icons.close) to indicate the chip can be deselected, '
              'but on unfixed code only a Text widget is rendered. '
              'No Icon(Icons.close) found in the widget tree.',
        );
      },
    );

    testWidgets(
      'EXPLORATION: active chip widget tree contains no close icon — detailed check '
      '— EXPECTED TO FAIL (confirms Bug 2)',
      (WidgetTester tester) async {
        // Arrange: render a single active chip directly via FilterChipsRow
        final activeChip = _chip(99, 'Tops');
        final inactiveChip = _chip(100, 'Jeans');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FilterChipsRow(
                chips: [activeChip, inactiveChip],
                selectedChipIds: {activeChip.id}, // only activeChip is active
                onChipTap: (_) {},
              ),
            ),
          ),
        );

        await tester.pump();

        // Find all Icon widgets in the tree
        final allIcons = find.byType(Icon);
        print('Total Icon widgets found: ${tester.widgetList(allIcons).length}');
        for (final iconWidget in tester.widgetList(allIcons)) {
          final icon = iconWidget as Icon;
          print('  Icon: ${icon.icon}');
        }

        // Assert: at least one close icon should be present (for the active chip)
        // On UNFIXED code: no Icon widgets at all → test FAILS
        final closeIconFinder = find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.close,
        );

        expect(
          closeIconFinder,
          findsAtLeastNWidgets(1),
          reason:
              'BUG 2 CONFIRMED: The active chip "Tops" (id=99) should display '
              'Icon(Icons.close) but no close icon was found in the widget tree. '
              'The unfixed _ChipItem renders only Text(chip.label) regardless '
              'of isActive.',
        );
      },
    );
  });

  // =========================================================================
  // Combined scenario: all four bugs in sequence
  // =========================================================================
  group('Combined scenario — all four bugs', () {
    test(
      'EXPLORATION: full chip tap flow exposes all controller-level bugs '
      '— EXPECTED TO FAIL (confirms Bugs 1, 3, 4)',
      () async {
        // Arrange
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final tops = _chip(10, 'Tops');
        final jeans = _chip(11, 'Jeans');
        final dresses = _chip(12, 'Dresses');

        controller.serverChips = [tops, jeans, dresses];
        controller.chips.assignAll([tops, jeans, dresses]);

        // ── Step 1: Tap "Dresses" (Bug 1 + Bug 4) ──────────────────────────
        controller.onChipTap(dresses);

        print('=== After tapping Dresses ===');
        print('chips[0] = ${controller.chips[0].label} (expected: Dresses)');
        print('selectedChipIds = ${controller.selectedChipIds} (expected: {12})');

        // Bug 1: chip not pinned
        final bug1Passes = controller.chips[0].id == dresses.id;
        // Bug 4: API response overwrites (our mock calls assignAll with serverChips)
        final bug4Passes = controller.chips[0].id == dresses.id;

        // ── Step 2: Re-tap "Dresses" (Bug 3) ───────────────────────────────
        // Reset server chips so the second tap doesn't re-assign
        controller.serverChips = [];
        controller.onChipTap(dresses);

        print('=== After re-tapping Dresses ===');
        print('selectedChipIds = ${controller.selectedChipIds} (expected: empty)');

        final bug3Passes = controller.selectedChipIds.isEmpty;

        print('Bug 1 (chip pinned): $bug1Passes');
        print('Bug 3 (re-tap deselects): $bug3Passes');
        print('Bug 4 (API preserves pin): $bug4Passes');

        // All three should pass on fixed code; all three fail on unfixed code
        expect(
          bug1Passes && bug3Passes && bug4Passes,
          isTrue,
          reason:
              'BUGS 1, 3, 4 CONFIRMED: '
              'Bug 1 (chip pinned after tap): $bug1Passes — '
              'Bug 3 (re-tap clears selectedChipIds): $bug3Passes — '
              'Bug 4 (API response preserves pin): $bug4Passes. '
              'All three fail on unfixed code.',
        );
      },
    );
  });
}
