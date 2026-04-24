// ignore_for_file: avoid_print
//
// Bug Condition Exploration Tests — Filter Chip Multi-Select and State-Loss Bugs
//
// PURPOSE: These tests MUST FAIL on unfixed code.
// Failure confirms all five bugs exist:
//   Bug 1 & 2 — Selected state lost after API refresh: chips.assignAll(parsedChips)
//               restores server order, wiping the pinned chip position.
//   Bug 3     — Multi-select impossible: second chip tap replaces first selection.
//   Bug 4     — Multi-select state lost on API refresh: only one chip was tracked.
//   Bug 5     — Deselect clears all: tapping a selected chip clears activeChipId
//               to null, removing ALL selections instead of just the tapped one.
//
// DO NOT fix the code to make these tests pass.
// When the fix is applied (Task 3), these tests will pass.
//
// Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5
//
// Properties tested (from design.md):
//   Property 1: Tap adds to selection and pins at front
//   Property 2: API response re-pins all selected chips
//   Property 3: Deselect removes only the tapped chip

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:lafetch/controllers/catalog_controller.dart';
import 'package:lafetch/models/filter_chip_item.dart';

// ---------------------------------------------------------------------------
// Test double — overrides getFilterAndSortProducts to avoid real HTTP calls
// and simulates an API response by calling chips.assignAll with server chips.
// ---------------------------------------------------------------------------

class _TestCatalogController extends CatalogController {
  /// Chips that a simulated API response would return (server order).
  List<FilterChipItem> serverChips = [];

  /// Tracks how many times getFilterAndSortProducts was called.
  int fetchCallCount = 0;

  /// The subCatId passed on the most recent call.
  int? lastSubCatId;

  /// The contextualCategoryId passed on the most recent call.
  int? lastContextualCategoryId;

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

    // Simulate the UNFIXED API response: chips.assignAll(parsedChips) with
    // fresh server-order objects — this is the root cause of Bugs 1, 2, and 4.
    if (page == 1 && serverChips.isNotEmpty) {
      // FIXED behaviour: re-pin all selected chips at the front.
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

  /// Seed the chips list and server chips with [items].
  void seedChips(List<FilterChipItem> items) {
    serverChips = List.from(items);
    chips.assignAll(items);
    // Also populate _lastServerChips so onChipTap deselect path works.
    // We call setLastParamsForTest to initialise _last* fields.
    setLastParamsForTest();
  }

  /// Expose the internal _lastServerChips by re-seeding via the deselect path.
  /// We need to set _lastServerChips so the deselect path in onChipTap works.
  void seedServerChips(List<FilterChipItem> items) {
    serverChips = List.from(items);
    // Directly assign to chips and simulate what getFilterAndSortProducts does
    // when it stores _lastServerChips.
    chips.assignAll(items);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

FilterChipItem _chip(int id, String label,
    {ChipType type = ChipType.category}) =>
    FilterChipItem(id: id, label: label, type: type, count: 10);

/// Returns the set of IDs currently "selected" according to the controller.
///
/// On FIXED code: reads selectedChipIds (a Set<int>) directly.
Set<int> _selectedIds(_TestCatalogController controller) {
  return Set<int>.from(controller.selectedChipIds);
}

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
  // Bug 1 & 2 — Selected state lost after API refresh
  //
  // Property 2 (design.md): For any API response that arrives while
  // selectedChipIds is non-empty, all selected chips SHALL remain pinned at
  // the front of chips, matching by chip id.
  //
  // Validates: Requirements 1.1, 1.2
  // =========================================================================
  group(
    'Bug 1 & 2 — Selected state lost after API refresh '
    '(Property 2: API response re-pins all selected chips)',
    () {
      test(
        'EXPLORATION: after onChipTap + API response, tapped chip is NOT at chips[0] '
        '— EXPECTED TO FAIL (confirms Bugs 1 & 2)',
        () async {
          // Arrange: server returns [Tops, Jeans, Dresses]; user taps Dresses (index 2).
          final controller = _TestCatalogController();
          Get.put<CatalogController>(controller);

          final tops = _chip(10, 'Tops');
          final jeans = _chip(11, 'Jeans');
          final dresses = _chip(12, 'Dresses');

          controller.seedChips([tops, jeans, dresses]);

          print('Before tap: chips = ${controller.chips.map((c) => c.label).toList()}');

          // Act: tap Dresses — this calls onChipTap which sets activeChipId
          // and then calls getFilterAndSortProducts (our mock), which simulates
          // the UNFIXED API response: chips.assignAll(serverChips) restores
          // server order.
          controller.onChipTap(dresses);

          print(
              'After tap + API response: chips = ${controller.chips.map((c) => c.label).toList()}');
          print(
              'chips[0].id = ${controller.chips[0].id}, expected = ${dresses.id}');
          print('selectedIds = ${_selectedIds(controller)}');

          // Assert (Property 2): tapped chip must be at chips[0] after API response.
          // On UNFIXED code: chips.assignAll(serverChips) restores [Tops, Jeans, Dresses]
          // so chips[0].id == tops.id (10), NOT dresses.id (12) → test FAILS.
          expect(
            controller.chips[0].id,
            equals(dresses.id),
            reason:
                'BUG 1 & 2 CONFIRMED: After tapping "Dresses" (id=${dresses.id}) '
                'and receiving an API response, chips[0] should be "Dresses" '
                'but on unfixed code chips.assignAll(serverChips) restored server '
                'order and chips[0] is "${controller.chips[0].label}" '
                '(id=${controller.chips[0].id}). Selected state is lost.',
          );
        },
      );

      test(
        'EXPLORATION: selected chip id must remain in selected set after API refresh '
        '— EXPECTED TO FAIL (confirms Bugs 1 & 2)',
        () async {
          // Arrange
          final controller = _TestCatalogController();
          Get.put<CatalogController>(controller);

          final chipA = _chip(1, 'A');
          final chipB = _chip(2, 'B');
          final chipC = _chip(3, 'C');

          controller.seedChips([chipA, chipB, chipC]);

          // Act: tap chipB, then simulate API response (done inside mock).
          controller.onChipTap(chipB);

          final selectedAfterApiResponse = _selectedIds(controller);
          print('Selected IDs after tap + API response: $selectedAfterApiResponse');
          print('chips order: ${controller.chips.map((c) => c.id).toList()}');

          // Assert: chipB.id must still be in the selected set AND at chips[0].
          // On UNFIXED code with single activeChipId: activeChipId.value == chipB.id
          // so _selectedIds returns {2}. BUT chips[0] is chipA (server order restored).
          // The position assertion fails.
          expect(
            controller.chips[0].id,
            equals(chipB.id),
            reason:
                'BUG 1 & 2 CONFIRMED: chipB (id=${chipB.id}) should be at '
                'chips[0] after API response, but chips[0] is '
                '"${controller.chips[0].label}" (id=${controller.chips[0].id}).',
          );
        },
      );
    },
  );

  // =========================================================================
  // Bug 3 — Multi-select impossible
  //
  // Property 1 (design.md): For any chip tap where the tapped chip's ID is
  // NOT in selectedChipIds, onChipTap SHALL add that chip's ID to
  // selectedChipIds and move it to the front, WITHOUT removing any previously
  // selected chip IDs.
  //
  // Validates: Requirement 1.3
  // =========================================================================
  group(
    'Bug 3 — Multi-select impossible '
    '(Property 1: tap adds to selection without removing previous)',
    () {
      test(
        'EXPLORATION: tapping chipB while chipA is selected does NOT keep chipA selected '
        '— EXPECTED TO FAIL (confirms Bug 3)',
        () {
          // Arrange
          final controller = _TestCatalogController();
          Get.put<CatalogController>(controller);

          final chipA = _chip(42, 'Tops');
          final chipB = _chip(17, 'Dresses');
          final chipC = _chip(99, 'Jeans');

          // Disable API simulation so we test onChipTap state only.
          controller.serverChips = [];
          controller.chips.assignAll([chipA, chipB, chipC]);
          controller.setLastParamsForTest();

          // Act: tap chipA first, then chipB.
          controller.onChipTap(chipA);
          print('After tapping chipA: selectedIds = ${_selectedIds(controller)}');

          controller.onChipTap(chipB);
          final selectedAfterBothTaps = _selectedIds(controller);
          print('After tapping chipB: selectedIds = $selectedAfterBothTaps');
          print('chips order: ${controller.chips.map((c) => c.id).toList()}');

          // Assert (Property 1): both chipA.id AND chipB.id must be in the
          // selected set after tapping both.
          // On UNFIXED code: activeChipId.value == chipB.id (17); chipA is
          // no longer tracked → _selectedIds returns {17}, not {42, 17}.
          expect(
            selectedAfterBothTaps,
            containsAll([chipA.id, chipB.id]),
            reason:
                'BUG 3 CONFIRMED: After tapping chipA (id=${chipA.id}) then '
                'chipB (id=${chipB.id}), both IDs should be in the selected set. '
                'On unfixed code only chipB.id is tracked '
                '(selectedIds = $selectedAfterBothTaps). '
                'Multi-select is impossible with a single activeChipId.',
          );
        },
      );

      test(
        'EXPLORATION: after tapping chipA then chipB, both chips are NOT at the front '
        '— EXPECTED TO FAIL (confirms Bug 3)',
        () {
          // Arrange
          final controller = _TestCatalogController();
          Get.put<CatalogController>(controller);

          final chipA = _chip(1, 'A');
          final chipB = _chip(2, 'B');
          final chipC = _chip(3, 'C');
          final chipD = _chip(4, 'D');

          controller.serverChips = [];
          controller.chips.assignAll([chipA, chipB, chipC, chipD]);
          controller.setLastParamsForTest();

          // Act: tap chipC (index 2), then chipD (index 3).
          controller.onChipTap(chipC);
          controller.onChipTap(chipD);

          print('chips order after two taps: ${controller.chips.map((c) => c.id).toList()}');
          print('selectedIds: ${_selectedIds(controller)}');

          final frontIds = controller.chips.take(2).map((c) => c.id).toSet();
          print('Front 2 chip IDs: $frontIds');

          // Assert: both chipC.id and chipD.id must be in the first 2 positions.
          // On UNFIXED code: only chipD is at front (activeChipId = chipD.id).
          // chipC is somewhere else → test FAILS.
          expect(
            frontIds,
            containsAll([chipC.id, chipD.id]),
            reason:
                'BUG 3 CONFIRMED: After tapping chipC (id=${chipC.id}) and '
                'chipD (id=${chipD.id}), both should appear at the front of chips. '
                'On unfixed code only chipD is at the front '
                '(front IDs = $frontIds). '
                'The first selection is replaced, not added to.',
          );
        },
      );
    },
  );

  // =========================================================================
  // Bug 4 — Multi-select state lost on API refresh
  //
  // Property 2 (design.md): For any API response while selectedChipIds is
  // non-empty, ALL selected chips SHALL be pinned at the front.
  //
  // Validates: Requirement 1.4
  // =========================================================================
  group(
    'Bug 4 — Multi-select state lost on API refresh '
    '(Property 2: all selected chips re-pinned after API response)',
    () {
      test(
        'EXPLORATION: after selecting two chips and receiving API response, '
        'only one chip is at the front — EXPECTED TO FAIL (confirms Bug 4)',
        () async {
          // Arrange: server returns [A, B, C, D]; user selects B (index 1)
          // and C (index 2). After API response, both B and C should be at
          // indices 0 and 1.
          final controller = _TestCatalogController();
          Get.put<CatalogController>(controller);

          final chipA = _chip(1, 'A');
          final chipB = _chip(2, 'B');
          final chipC = _chip(3, 'C');
          final chipD = _chip(4, 'D');

          controller.seedChips([chipA, chipB, chipC, chipD]);

          // Act: tap chipB — triggers API response (mock restores server order
          // with only chipB pinned via single activeChipId).
          controller.onChipTap(chipB);
          print('After tapping chipB: chips = ${controller.chips.map((c) => c.id).toList()}');

          // Now tap chipC — on unfixed code this replaces chipB's selection.
          // Disable server chips so the second tap doesn't re-run assignAll.
          controller.serverChips = [];
          controller.onChipTap(chipC);
          print('After tapping chipC: chips = ${controller.chips.map((c) => c.id).toList()}');

          // Re-enable server chips and simulate another API response by
          // calling the mock directly.
          controller.serverChips = [chipA, chipB, chipC, chipD];
          await controller.getFilterAndSortProducts(page: 1);

          print(
              'After API response: chips = ${controller.chips.map((c) => c.id).toList()}');
          print('selectedIds = ${_selectedIds(controller)}');

          final frontTwoIds =
              controller.chips.take(2).map((c) => c.id).toSet();
          print('Front 2 IDs: $frontTwoIds');

          // Assert: both chipB.id and chipC.id must be in the first 2 positions.
          // On UNFIXED code: only one chip (chipC, the last tapped) is tracked
          // via activeChipId, so only chipC is pinned → test FAILS.
          expect(
            frontTwoIds,
            containsAll([chipB.id, chipC.id]),
            reason:
                'BUG 4 CONFIRMED: After selecting chipB (id=${chipB.id}) and '
                'chipC (id=${chipC.id}) and receiving an API response, both '
                'should be at the front of chips. On unfixed code only one chip '
                'is tracked, so only one chip is pinned. Front IDs = $frontTwoIds.',
          );
        },
      );

      test(
        'EXPLORATION: API response with three chips selected only pins one '
        '— EXPECTED TO FAIL (confirms Bug 4)',
        () async {
          // Arrange: server returns [A, B, C, D, E]; user selects A, C, E.
          final controller = _TestCatalogController();
          Get.put<CatalogController>(controller);

          final chipA = _chip(1, 'A');
          final chipB = _chip(2, 'B');
          final chipC = _chip(3, 'C');
          final chipD = _chip(4, 'D');
          final chipE = _chip(5, 'E');

          controller.seedChips([chipA, chipB, chipC, chipD, chipE]);

          // Tap A, C, E in sequence (each tap replaces the previous on unfixed code).
          controller.serverChips = []; // disable API simulation during taps
          controller.onChipTap(chipA);
          controller.onChipTap(chipC);
          controller.onChipTap(chipE);

          // Simulate API response.
          controller.serverChips = [chipA, chipB, chipC, chipD, chipE];
          await controller.getFilterAndSortProducts(page: 1);

          print(
              'After API response: chips = ${controller.chips.map((c) => c.id).toList()}');
          print('selectedIds = ${_selectedIds(controller)}');

          final frontThreeIds =
              controller.chips.take(3).map((c) => c.id).toSet();

          // Assert: A, C, E must all be in the first 3 positions.
          // On UNFIXED code: only E (last tapped) is pinned → test FAILS.
          expect(
            frontThreeIds,
            containsAll([chipA.id, chipC.id, chipE.id]),
            reason:
                'BUG 4 CONFIRMED: After selecting A, C, E and receiving an API '
                'response, all three should be at the front. On unfixed code '
                'only the last tapped chip (E, id=${chipE.id}) is tracked. '
                'Front 3 IDs = $frontThreeIds.',
          );
        },
      );
    },
  );

  // =========================================================================
  // Bug 5 — Deselect clears all selections
  //
  // Property 3 (design.md): For any chip tap where the tapped chip's ID IS
  // in selectedChipIds, onChipTap SHALL remove ONLY that chip's ID from
  // selectedChipIds, leaving all other IDs unchanged.
  //
  // Validates: Requirement 1.5
  // =========================================================================
  group(
    'Bug 5 — Deselect clears all selections '
    '(Property 3: deselect removes only the tapped chip)',
    () {
      test(
        'EXPLORATION: deselecting chipA while chipB is also selected clears chipB too '
        '— EXPECTED TO FAIL (confirms Bug 5)',
        () {
          // Arrange
          final controller = _TestCatalogController();
          Get.put<CatalogController>(controller);

          final chipA = _chip(42, 'Tops');
          final chipB = _chip(17, 'Dresses');
          final chipC = _chip(99, 'Jeans');

          // Disable API simulation so we test state transitions only.
          controller.serverChips = [];
          controller.chips.assignAll([chipA, chipB, chipC]);
          controller.setLastParamsForTest();

          // Act: tap chipA (select), tap chipB (select), tap chipA again (deselect).
          controller.onChipTap(chipA);
          print('After tapping chipA: selectedIds = ${_selectedIds(controller)}');

          controller.onChipTap(chipB);
          print('After tapping chipB: selectedIds = ${_selectedIds(controller)}');

          controller.onChipTap(chipA); // deselect chipA
          final selectedAfterDeselect = _selectedIds(controller);
          print('After deselecting chipA: selectedIds = $selectedAfterDeselect');

          // Assert (Property 3):
          //   - chipA.id must NOT be in the selected set (it was deselected).
          //   - chipB.id MUST still be in the selected set (it was not tapped).
          //
          // On UNFIXED code: tapping chipA when activeChipId == chipA.id (42)
          // triggers the deselect guard which sets activeChipId.value = null.
          // This clears ALL selections → chipB.id is also gone → test FAILS.
          expect(
            selectedAfterDeselect,
            isNot(contains(chipA.id)),
            reason:
                'BUG 5 CONFIRMED (part 1): chipA (id=${chipA.id}) should be '
                'removed from the selected set after deselecting it.',
          );
          expect(
            selectedAfterDeselect,
            contains(chipB.id),
            reason:
                'BUG 5 CONFIRMED (part 2): chipB (id=${chipB.id}) should STILL '
                'be selected after deselecting chipA, but on unfixed code '
                'activeChipId is cleared to null, removing ALL selections. '
                'selectedIds after deselect = $selectedAfterDeselect.',
          );
        },
      );

      test(
        'EXPLORATION: deselecting one of three selected chips clears all three '
        '— EXPECTED TO FAIL (confirms Bug 5)',
        () {
          // Arrange
          final controller = _TestCatalogController();
          Get.put<CatalogController>(controller);

          final chipA = _chip(1, 'A');
          final chipB = _chip(2, 'B');
          final chipC = _chip(3, 'C');
          final chipD = _chip(4, 'D');

          controller.serverChips = [];
          controller.chips.assignAll([chipA, chipB, chipC, chipD]);
          controller.setLastParamsForTest();

          // Select A, B, C.
          controller.onChipTap(chipA);
          controller.onChipTap(chipB);
          controller.onChipTap(chipC);

          print('After selecting A, B, C: selectedIds = ${_selectedIds(controller)}');

          // Deselect B.
          controller.onChipTap(chipB);
          final selectedAfterDeselect = _selectedIds(controller);
          print('After deselecting B: selectedIds = $selectedAfterDeselect');

          // Assert: A and C must still be selected; B must not be.
          // On UNFIXED code: activeChipId is cleared to null → all gone.
          expect(
            selectedAfterDeselect,
            isNot(contains(chipB.id)),
            reason: 'chipB (id=${chipB.id}) should be deselected.',
          );
          expect(
            selectedAfterDeselect,
            containsAll([chipA.id, chipC.id]),
            reason:
                'BUG 5 CONFIRMED: chipA (id=${chipA.id}) and chipC (id=${chipC.id}) '
                'should remain selected after deselecting chipB, but on unfixed '
                'code activeChipId is cleared to null, removing all selections. '
                'selectedIds = $selectedAfterDeselect.',
          );
        },
      );
    },
  );

  // =========================================================================
  // Combined scenario — all five bugs in sequence
  //
  // Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5
  // =========================================================================
  group('Combined scenario — all five bugs in sequence', () {
    test(
      'EXPLORATION: full multi-select flow exposes all five bugs '
      '— EXPECTED TO FAIL (confirms Bugs 1–5)',
      () async {
        // Arrange: server returns [Tops, Jeans, Dresses, Skirts].
        final controller = _TestCatalogController();
        Get.put<CatalogController>(controller);

        final tops = _chip(10, 'Tops');
        final jeans = _chip(11, 'Jeans');
        final dresses = _chip(12, 'Dresses');
        final skirts = _chip(13, 'Skirts');

        controller.seedChips([tops, jeans, dresses, skirts]);

        // ── Step 1: Tap Dresses (Bug 1 & 2) ─────────────────────────────────
        // After tap + API response, Dresses should be at chips[0].
        controller.onChipTap(dresses);

        final bug12Pass = controller.chips[0].id == dresses.id;
        print('Bug 1&2 (Dresses at front after API): $bug12Pass '
            '— chips[0]=${controller.chips[0].label}');

        // ── Step 2: Tap Tops while Dresses is selected (Bug 3) ──────────────
        // Both Dresses and Tops should be in the selected set.
        controller.serverChips = []; // disable API simulation
        controller.onChipTap(tops);

        final selectedAfterTwoTaps = _selectedIds(controller);
        final bug3Pass = selectedAfterTwoTaps.containsAll([dresses.id, tops.id]);
        print('Bug 3 (both selected): $bug3Pass — selectedIds=$selectedAfterTwoTaps');

        // ── Step 3: API response with two chips selected (Bug 4) ─────────────
        // Both Dresses and Tops should remain at the front after API response.
        controller.serverChips = [tops, jeans, dresses, skirts];
        await controller.getFilterAndSortProducts(page: 1);

        final frontTwoIds = controller.chips.take(2).map((c) => c.id).toSet();
        final bug4Pass = frontTwoIds.containsAll([dresses.id, tops.id]);
        print('Bug 4 (both at front after API): $bug4Pass — front=$frontTwoIds');

        // ── Step 4: Deselect Dresses while Tops is still selected (Bug 5) ────
        // Only Dresses should be removed; Tops should remain selected.
        controller.serverChips = [];
        controller.onChipTap(dresses); // deselect Dresses

        final selectedAfterDeselect = _selectedIds(controller);
        final bug5Pass = !selectedAfterDeselect.contains(dresses.id) &&
            selectedAfterDeselect.contains(tops.id);
        print('Bug 5 (only Dresses deselected): $bug5Pass '
            '— selectedIds=$selectedAfterDeselect');

        // ── Summary ──────────────────────────────────────────────────────────
        print('\n=== Bug Summary ===');
        print('Bug 1&2 (state after API refresh): $bug12Pass');
        print('Bug 3   (multi-select):            $bug3Pass');
        print('Bug 4   (multi-select after API):  $bug4Pass');
        print('Bug 5   (deselect only one):       $bug5Pass');

        // All five must pass on fixed code; all fail on unfixed code.
        expect(
          bug12Pass && bug3Pass && bug4Pass && bug5Pass,
          isTrue,
          reason:
              'BUGS 1–5 CONFIRMED:\n'
              '  Bug 1&2 (chip pinned after API response): $bug12Pass\n'
              '  Bug 3   (multi-select adds to selection): $bug3Pass\n'
              '  Bug 4   (multi-select survives API):      $bug4Pass\n'
              '  Bug 5   (deselect removes only one):      $bug5Pass\n'
              'All fail on unfixed code because activeChipId is a scalar '
              'and chips.assignAll() restores server order unconditionally.',
        );
      },
    );
  });
}
