// ignore_for_file: avoid_print
//
// Preservation Tests — Filter Chip Active State (Task 2)
//
// PURPOSE: These tests MUST PASS on unfixed code.
// They lock in baseline behavior that must not regress after the fix.
//
// Preservation requirements covered:
//   3.1 — Server order preserved when no chip is active
//   3.2 — Inactive chip renders with no close icon
//   3.3 — Empty FilterChipsRow collapses to SizedBox.shrink()
//   3.4 — Filter parameters preserved on chip tap
//
// Validates: Requirements 3.1, 3.2, 3.3, 3.4

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:lafetch/controllers/catalog_controller.dart';
import 'package:lafetch/models/filter_chip_item.dart';
import 'package:lafetch/common/widget/other/filter_chips_row.dart';

// ---------------------------------------------------------------------------
// Test helper — reuses the same _TestCatalogController pattern from
// filter_chip_active_state_exploration_test.dart
// ---------------------------------------------------------------------------

/// A [CatalogController] subclass that intercepts [getFilterAndSortProducts]
/// so tests can inspect the parameters passed without making real HTTP calls.
class _TestCatalogController extends CatalogController {
  /// How many times [getFilterAndSortProducts] was called.
  int fetchCallCount = 0;

  // Captured parameters from the most recent call.
  List<int>? capturedBrandIds;
  List<String>? capturedColors;
  List<String>? capturedSizes;
  String? capturedMinPrice;
  String? capturedMaxPrice;
  String? capturedSortOption;
  int? capturedSubCatId;
  int? capturedContextualCategoryId;

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

    // Capture all filter params for assertion.
    capturedBrandIds = brandIds;
    capturedColors = colors;
    capturedSizes = sizes;
    capturedMinPrice = minPrice;
    capturedMaxPrice = maxPrice;
    capturedSortOption = sortOption;
    capturedSubCatId = subCatId;
    capturedContextualCategoryId = contextualCategoryId;

    // Simulate what the real API does on page == 1: replace chips with
    // server-returned order (this is the Bug 4 scenario, but also the
    // normal no-active-chip path we test in Preservation 3.1).
    if (page == 1 && serverChips.isNotEmpty) {
      chips.assignAll(serverChips);
    }
  }

  /// Seed the chips list with [items] as if they came from the server.
  /// Also stores them as the server order so the mock can replay them.
  void seedChips(List<FilterChipItem> items) {
    chips.assignAll(items);
    serverChips = List.from(items);
  }

  /// Simulate calling [getFilterAndSortProducts] with no active chip,
  /// which causes [chips.assignAll(serverChips)] — the normal path.
  void simulateApiResponseWithServerOrder(List<FilterChipItem> serverOrder) {
    chips.assignAll(serverOrder);
  }
}

// ---------------------------------------------------------------------------
// Test data helpers
// ---------------------------------------------------------------------------

FilterChipItem _chip(int id, String label, {ChipType type = ChipType.category}) =>
    FilterChipItem(id: id, label: label, type: type, count: 10);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  // =========================================================================
  // Preservation 3.4 — Filter parameter preservation on chip tap
  // =========================================================================
  group('Preservation 3.4 — Filter parameters preserved on chip tap', () {
    test(
      'PRESERVATION: brandIds are passed unchanged when tapping an inactive chip',
      () {
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chip = _chip(42, 'Tops');
        controller.seedChips([chip, _chip(1, 'Jeans')]);

        // Pre-populate the stored filter state using the test-only setter.
        controller.setLastParamsForTest(brandIds: [10, 20, 30]);

        // Reset capture so we only see the onChipTap call.
        controller.fetchCallCount = 0;
        controller.capturedBrandIds = null;

        // Act: tap an inactive chip.
        controller.onChipTap(chip);

        // Assert: brandIds must be forwarded unchanged.
        expect(
          controller.capturedBrandIds,
          equals([10, 20, 30]),
          reason:
              'PRESERVATION 3.4: brandIds passed to getFilterAndSortProducts '
              'must be identical to those stored from the previous call.',
        );
      },
    );

    test(
      'PRESERVATION: colors are passed unchanged when tapping an inactive chip',
      () {
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chip = _chip(42, 'Tops');
        controller.seedChips([chip]);

        controller.setLastParamsForTest(colors: ['red', 'blue', 'green']);
        controller.fetchCallCount = 0;
        controller.capturedColors = null;

        controller.onChipTap(chip);

        expect(
          controller.capturedColors,
          equals(['red', 'blue', 'green']),
          reason: 'PRESERVATION 3.4: colors must be forwarded unchanged.',
        );
      },
    );

    test(
      'PRESERVATION: sizes are passed unchanged when tapping an inactive chip',
      () {
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chip = _chip(42, 'Tops');
        controller.seedChips([chip]);

        controller.setLastParamsForTest(sizes: ['S', 'M', 'L', 'XL']);
        controller.fetchCallCount = 0;
        controller.capturedSizes = null;

        controller.onChipTap(chip);

        expect(
          controller.capturedSizes,
          equals(['S', 'M', 'L', 'XL']),
          reason: 'PRESERVATION 3.4: sizes must be forwarded unchanged.',
        );
      },
    );

    test(
      'PRESERVATION: price range (minPrice, maxPrice) is passed unchanged when tapping an inactive chip',
      () {
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chip = _chip(42, 'Tops');
        controller.seedChips([chip]);

        controller.setLastParamsForTest(minPrice: '500', maxPrice: '2000');
        controller.fetchCallCount = 0;
        controller.capturedMinPrice = null;
        controller.capturedMaxPrice = null;

        controller.onChipTap(chip);

        expect(
          controller.capturedMinPrice,
          equals('500'),
          reason: 'PRESERVATION 3.4: minPrice must be forwarded unchanged.',
        );
        expect(
          controller.capturedMaxPrice,
          equals('2000'),
          reason: 'PRESERVATION 3.4: maxPrice must be forwarded unchanged.',
        );
      },
    );

    test(
      'PRESERVATION: sortOption is passed unchanged when tapping an inactive chip',
      () {
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chip = _chip(42, 'Tops');
        controller.seedChips([chip]);

        controller.setLastParamsForTest(sortOption: 'price_asc');
        controller.fetchCallCount = 0;
        controller.capturedSortOption = null;

        controller.onChipTap(chip);

        expect(
          controller.capturedSortOption,
          equals('price_asc'),
          reason: 'PRESERVATION 3.4: sortOption must be forwarded unchanged.',
        );
      },
    );

    test(
      'PRESERVATION: all filter params together are passed unchanged on chip tap',
      () {
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chip = _chip(55, 'Dresses');
        controller.seedChips([chip, _chip(1, 'Tops')]);

        // Set all filter params via the test-only setter.
        controller.setLastParamsForTest(
          brandIds: [5, 6],
          colors: ['black', 'white'],
          sizes: ['M', 'L'],
          minPrice: '100',
          maxPrice: '5000',
          sortOption: 'newest',
        );

        // Reset capture counters.
        controller.fetchCallCount = 0;
        controller.capturedBrandIds = null;
        controller.capturedColors = null;
        controller.capturedSizes = null;
        controller.capturedMinPrice = null;
        controller.capturedMaxPrice = null;
        controller.capturedSortOption = null;

        // Tap an inactive chip.
        controller.onChipTap(chip);

        expect(controller.capturedBrandIds, equals([5, 6]),
            reason: 'brandIds must be preserved');
        expect(controller.capturedColors, equals(['black', 'white']),
            reason: 'colors must be preserved');
        expect(controller.capturedSizes, equals(['M', 'L']),
            reason: 'sizes must be preserved');
        expect(controller.capturedMinPrice, equals('100'),
            reason: 'minPrice must be preserved');
        expect(controller.capturedMaxPrice, equals('5000'),
            reason: 'maxPrice must be preserved');
        expect(controller.capturedSortOption, equals('newest'),
            reason: 'sortOption must be preserved');
      },
    );

    test(
      'PRESERVATION: null filter params remain null on chip tap (no filters active)',
      () {
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chip = _chip(10, 'Tops');
        controller.seedChips([chip]);

        // No filters set — all _last* fields remain null.
        controller.fetchCallCount = 0;

        controller.onChipTap(chip);

        expect(controller.capturedBrandIds, isNull,
            reason: 'null brandIds must stay null');
        expect(controller.capturedColors, isNull,
            reason: 'null colors must stay null');
        expect(controller.capturedSizes, isNull,
            reason: 'null sizes must stay null');
        expect(controller.capturedMinPrice, isNull,
            reason: 'null minPrice must stay null');
        expect(controller.capturedMaxPrice, isNull,
            reason: 'null maxPrice must stay null');
        expect(controller.capturedSortOption, isNull,
            reason: 'null sortOption must stay null');
      },
    );

    test(
      'PRESERVATION: category chip tap sets subCatId to chip.id and clears contextualCategoryId',
      () {
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chip = _chip(42, 'Tops', type: ChipType.category);
        controller.seedChips([chip]);

        controller.onChipTap(chip);

        expect(controller.capturedSubCatId, equals(42),
            reason: 'category chip tap must set subCatId to chip.id');
        expect(controller.capturedContextualCategoryId, isNull,
            reason: 'category chip tap must clear contextualCategoryId');
      },
    );

    test(
      'PRESERVATION: contextual chip tap sets contextualCategoryId to chip.id and clears subCatId',
      () {
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final chip = _chip(77, 'Summer', type: ChipType.contextual);
        controller.seedChips([chip]);

        controller.onChipTap(chip);

        expect(controller.capturedContextualCategoryId, equals(77),
            reason: 'contextual chip tap must set contextualCategoryId to chip.id');
        expect(controller.capturedSubCatId, isNull,
            reason: 'contextual chip tap must clear subCatId');
      },
    );
  });

  // =========================================================================
  // Preservation 3.2 — Inactive chip renders with no close icon
  // =========================================================================
  group('Preservation 3.2 — Inactive chip renders with no close icon', () {
    testWidgets(
      'PRESERVATION: _ChipItem with isActive:false has no Icon(Icons.close)',
      (WidgetTester tester) async {
        final chip = _chip(1, 'Tops');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FilterChipsRow(
                chips: [chip],
                activeChipId: null, // no chip is active
                onChipTap: (_) {},
              ),
            ),
          ),
        );

        await tester.pump();

        final closeIcons = find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.close,
        );

        expect(
          closeIcons,
          findsNothing,
          reason:
              'PRESERVATION 3.2: An inactive chip must NOT render '
              'Icon(Icons.close). The unfixed code renders only Text.',
        );
      },
    );

    testWidgets(
      'PRESERVATION: multiple inactive chips — none has a close icon',
      (WidgetTester tester) async {
        final chips = [
          _chip(1, 'Tops'),
          _chip(2, 'Jeans'),
          _chip(3, 'Dresses'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FilterChipsRow(
                chips: chips,
                activeChipId: null,
                onChipTap: (_) {},
              ),
            ),
          ),
        );

        await tester.pump();

        final closeIcons = find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.close,
        );

        expect(
          closeIcons,
          findsNothing,
          reason:
              'PRESERVATION 3.2: None of the inactive chips should render '
              'Icon(Icons.close).',
        );
      },
    );

    testWidgets(
      'PRESERVATION: chip with a different activeChipId renders no close icon',
      (WidgetTester tester) async {
        // chip id=1 is inactive because activeChipId=99 (a different chip)
        final chip = _chip(1, 'Tops');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FilterChipsRow(
                chips: [chip],
                activeChipId: 99, // different chip is active
                onChipTap: (_) {},
              ),
            ),
          ),
        );

        await tester.pump();

        final closeIcons = find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.close,
        );

        // The active chip (id=99) is not in the chips list, so no close icon
        // should appear for chip id=1 (which is inactive).
        expect(
          closeIcons,
          findsNothing,
          reason:
              'PRESERVATION 3.2: chip id=1 is inactive (activeChipId=99) '
              'and must NOT render Icon(Icons.close).',
        );
      },
    );
  });

  // =========================================================================
  // Preservation 3.3 — Empty FilterChipsRow collapses to SizedBox.shrink()
  // =========================================================================
  group('Preservation 3.3 — Empty row collapses to SizedBox.shrink()', () {
    testWidgets(
      'PRESERVATION: empty chips + empty activeFilters returns SizedBox.shrink()',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FilterChipsRow(
                chips: const [],
                activeChipId: null,
                onChipTap: (_) {},
                activeFilters: const [],
              ),
            ),
          ),
        );

        await tester.pump();

        // The widget should render a SizedBox.shrink() — zero size.
        final sizedBoxes = find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox &&
              (widget.width == null || widget.width == 0) &&
              (widget.height == null || widget.height == 0),
        );

        expect(
          sizedBoxes,
          findsAtLeastNWidgets(1),
          reason:
              'PRESERVATION 3.3: FilterChipsRow with empty chips and empty '
              'activeFilters must collapse to SizedBox.shrink() (zero size).',
        );
      },
    );

    testWidgets(
      'PRESERVATION: empty chips + empty activeFilters has zero render size',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FilterChipsRow(
                chips: const [],
                activeChipId: null,
                onChipTap: (_) {},
                activeFilters: const [],
              ),
            ),
          ),
        );

        await tester.pump();

        // Find the FilterChipsRow widget and check its render size.
        final filterChipsRowFinder = find.byType(FilterChipsRow);
        expect(filterChipsRowFinder, findsOneWidget);

        final renderBox = tester.renderObject(filterChipsRowFinder) as RenderBox;
        expect(
          renderBox.size.height,
          equals(0.0),
          reason:
              'PRESERVATION 3.3: FilterChipsRow with no chips and no active '
              'filters must have zero height.',
        );
        expect(
          renderBox.size.width,
          equals(0.0),
          reason:
              'PRESERVATION 3.3: FilterChipsRow with no chips and no active '
              'filters must have zero width.',
        );
      },
    );

    testWidgets(
      'PRESERVATION: non-empty chips list does NOT collapse',
      (WidgetTester tester) async {
        // Sanity check: when chips are present, the row should be visible.
        final chip = _chip(1, 'Tops');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FilterChipsRow(
                chips: [chip],
                activeChipId: null,
                onChipTap: (_) {},
              ),
            ),
          ),
        );

        await tester.pump();

        final filterChipsRowFinder = find.byType(FilterChipsRow);
        final renderBox = tester.renderObject(filterChipsRowFinder) as RenderBox;

        expect(
          renderBox.size.height,
          greaterThan(0.0),
          reason:
              'PRESERVATION 3.3: FilterChipsRow with chips must have '
              'non-zero height.',
        );
      },
    );
  });

  // =========================================================================
  // Preservation 3.1 — Server order preserved when no chip is active
  // =========================================================================
  group('Preservation 3.1 — Server order preserved when activeChipId is null', () {
    test(
      'PRESERVATION: chips.assignAll(serverChips) stores chips in server order '
      'when activeChipId is null',
      () {
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final tops = _chip(10, 'Tops');
        final jeans = _chip(11, 'Jeans');
        final dresses = _chip(12, 'Dresses');

        // activeChipId is null (default) — no chip is active.
        expect(controller.activeChipId.value, isNull);

        // Simulate an API response that returns chips in server order.
        controller.simulateApiResponseWithServerOrder([tops, jeans, dresses]);

        // Assert: chips are stored in the exact server-returned order.
        expect(controller.chips.length, equals(3));
        expect(controller.chips[0].id, equals(tops.id),
            reason: 'chips[0] should be Tops (server order)');
        expect(controller.chips[1].id, equals(jeans.id),
            reason: 'chips[1] should be Jeans (server order)');
        expect(controller.chips[2].id, equals(dresses.id),
            reason: 'chips[2] should be Dresses (server order)');
      },
    );

    test(
      'PRESERVATION: server order is preserved for a 5-chip list when no chip is active',
      () {
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final serverOrder = [
          _chip(1, 'A'),
          _chip(2, 'B'),
          _chip(3, 'C'),
          _chip(4, 'D'),
          _chip(5, 'E'),
        ];

        expect(controller.activeChipId.value, isNull);

        controller.simulateApiResponseWithServerOrder(serverOrder);

        for (int i = 0; i < serverOrder.length; i++) {
          expect(
            controller.chips[i].id,
            equals(serverOrder[i].id),
            reason:
                'PRESERVATION 3.1: chips[$i] should be ${serverOrder[i].label} '
                '(server order) when no chip is active.',
          );
        }
      },
    );

    test(
      'PRESERVATION: getFilterAndSortProducts with no active chip stores chips in server order',
      () async {
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final tops = _chip(10, 'Tops');
        final jeans = _chip(11, 'Jeans');
        final dresses = _chip(12, 'Dresses');

        // Server returns chips in this order.
        controller.serverChips = [tops, jeans, dresses];

        // No active chip.
        expect(controller.activeChipId.value, isNull);

        // Trigger a fetch (simulated — our mock calls chips.assignAll(serverChips)).
        await controller.getFilterAndSortProducts(page: 1);

        // Assert: chips are in server order.
        expect(controller.chips.length, equals(3));
        expect(controller.chips[0].id, equals(tops.id),
            reason: 'chips[0] should be Tops');
        expect(controller.chips[1].id, equals(jeans.id),
            reason: 'chips[1] should be Jeans');
        expect(controller.chips[2].id, equals(dresses.id),
            reason: 'chips[2] should be Dresses');
      },
    );

    test(
      'PRESERVATION: single chip list is stored in server order when no chip is active',
      () {
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final only = _chip(99, 'OnlyChip');

        expect(controller.activeChipId.value, isNull);

        controller.simulateApiResponseWithServerOrder([only]);

        expect(controller.chips.length, equals(1));
        expect(controller.chips[0].id, equals(only.id));
      },
    );
  });
}
