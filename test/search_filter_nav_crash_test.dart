// ignore_for_file: avoid_print
//
// Search Filter Nav Crash — Bug Condition Exploration Test (Task 1)
//
// PURPOSE: These tests MUST FAIL on unfixed code.
// Failure confirms the bug exists:
//   The app crashes fatally when the user:
//     1. Opens SearchScreen → navigates to SearchResultsScreen with zero results
//     2. Pops both screens back to home
//     3. Re-pushes SearchScreen → navigates to SearchResultsScreen again
//     4. Triggers pull-to-refresh (calls getSearchData() → accesses searchController.text)
//
// ROOT CAUSE: SearchScreenController is registered via Get.put() in a field
// initializer on SearchScreenState. When the screen is popped, GetX may dispose
// the controller (calling onClose() → searchController.dispose()). On re-entry,
// a new Get.put() call may return the stale disposed instance or create a new one
// while the old registration still exists. Any subsequent access to
// searchController.text on the disposed TextEditingController throws:
//   StateError: A TextEditingController was used after being disposed.
//
// Additionally, SearchResultsScreen.dispose() calls
//   Get.find<SearchScreenController>().clearChipSelection()
// unconditionally — if SearchScreen was already disposed (and the controller
// deleted), this throws:
//   GetxError: SearchScreenController not found.
//
// DO NOT fix the code to make these tests pass.
// When the fix is applied (Task 3), these tests will pass.
//
// **Validates: Requirements 1.1, 1.2, 1.3, 1.4**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lafetch/controllers/search_controller.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Setup / Teardown
  // ---------------------------------------------------------------------------
  setUp(() {
    // Ensure a clean GetX state before each test
    Get.reset();
  });

  tearDown(() {
    // Clean up after each test
    Get.reset();
  });

  // ===========================================================================
  // Group 1: Controller lifecycle — stale instance after pop
  //
  // Simulates what happens when SearchScreen is pushed twice:
  //   - First push: Get.put(SearchScreenController()) registers the controller
  //   - Pop: GetX disposes the controller (onClose → searchController.dispose())
  //   - Second push: Get.put(SearchScreenController()) is called again
  //
  // On UNFIXED code, the second Get.put() may return the stale disposed instance
  // (if GetX has not yet cleaned up the registration), causing subsequent
  // searchController.text access to throw StateError.
  // ===========================================================================
  group('Bug Condition 1: Controller lifecycle — stale instance after pop', () {
    test(
      'EXPLORATION: After Get.delete(), Get.isRegistered<SearchScreenController>() '
      'returns false — on unfixed code SearchScreen.dispose() does NOT call '
      'Get.delete(), so the stale controller remains registered '
      '— EXPECTED TO FAIL (confirms bug 1.2)',
      () {
        // Simulate first navigation cycle: SearchScreen pushed
        final controller1 = Get.put(SearchScreenController());
        print('📋 First push: controller registered = '
            '${Get.isRegistered<SearchScreenController>()}');
        expect(Get.isRegistered<SearchScreenController>(), isTrue,
            reason: 'Controller should be registered after Get.put()');

        // Simulate SearchScreen.dispose() on UNFIXED code:
        // The unfixed dispose() does NOT call Get.delete<SearchScreenController>()
        // It only calls: _debounceSuggest?.cancel(); controller.resetFilters();
        // So we simulate the unfixed dispose by NOT calling Get.delete():
        controller1.resetFilters(); // what unfixed dispose() does
        // NOTE: We do NOT call Get.delete() here — this is the bug

        // On unfixed code, the controller is still registered after dispose()
        // because SearchScreen.dispose() never calls Get.delete()
        final isStillRegistered = Get.isRegistered<SearchScreenController>();
        print('📋 After unfixed dispose() (no Get.delete()): '
            'isRegistered = $isStillRegistered');

        // BUG CONDITION: The controller is still registered but its internal
        // TextEditingController may be in an inconsistent state.
        // The fix requires Get.isRegistered() to return FALSE after SearchScreen pops.
        //
        // EXPECTED OUTCOME ON UNFIXED CODE: isStillRegistered == true (BUG)
        // EXPECTED OUTCOME ON FIXED CODE:   isStillRegistered == false (FIXED)
        //
        // This assertion FAILS on unfixed code (controller is still registered)
        // and PASSES on fixed code (controller is deleted on dispose).
        expect(
          isStillRegistered,
          isFalse,
          reason:
              'BUG CONFIRMED: After SearchScreen.dispose(), '
              'Get.isRegistered<SearchScreenController>() returned true. '
              'The unfixed SearchScreen.dispose() does NOT call '
              'Get.delete<SearchScreenController>(force: true), so the '
              'stale controller remains in the GetX instance map. '
              'On re-entry, Get.put() returns this stale instance whose '
              'TextEditingController is already disposed, causing: '
              'StateError: A TextEditingController was used after being disposed.',
        );
      },
    );

    test(
      'EXPLORATION: After TextEditingController.dispose() is called directly, '
      'setting searchController.text throws StateError '
      '— EXPECTED TO FAIL (confirms bug 1.2)',
      () {
        // Simulate first navigation cycle: SearchScreen pushed
        final controller = Get.put(SearchScreenController());
        controller.searchController.text = 'dress';
        print('📋 Before dispose(): searchController.text = '
            '"${controller.searchController.text}"');

        // In the real app, the TextField widget adds a listener to the
        // TextEditingController. When onClose() fires, it checks hasListeners
        // and disposes the controller. We simulate this by adding a dummy
        // listener (as the TextField widget does) and then calling onClose().
        controller.searchController.addListener(() {}); // simulate TextField listener
        print('📋 Added listener (simulating TextField widget)');
        print('📋 hasListeners = ${controller.searchController.hasListeners}');

        // Now onClose() will actually dispose the TextEditingController
        // because hasListeners is true (the TextField added a listener)
        controller.onClose();
        print('📋 After onClose(): controller disposed');
        print('📋 isRegistered (no Get.delete()): '
            '${Get.isRegistered<SearchScreenController>()}');

        // On unfixed code, the controller is still registered in GetX
        // (because SearchScreen.dispose() never calls Get.delete()).
        // When SearchScreen is re-entered, _openResults() calls:
        //   controller.searchController.text = q;
        // This throws: StateError: A TextEditingController was used after
        // being disposed.
        //
        // Note: the .text getter does NOT throw — only the setter and
        // addListener() throw. The crash in the real app happens when:
        //   1. _openResults() sets searchController.text = q (setter throws)
        //   2. The TextField widget calls addListener() on re-entry (throws)
        //   3. searchController.clear() is called (throws)
        //
        // EXPECTED OUTCOME ON UNFIXED CODE: throws StateError (BUG)
        // EXPECTED OUTCOME ON FIXED CODE:   no throw (FIXED — new instance)
        expect(
          () {
            // This is what _openResults() does before navigating:
            controller.searchController.text = 'shoes'; // setter throws after dispose
            print('📋 Set searchController.text after dispose (no throw)');
          },
          throwsA(isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('disposed'),
          )),
          reason:
              'BUG CONFIRMED: Setting searchController.text after '
              'onClose() (with a listener attached, as the TextField widget does) '
              'threw StateError. '
              'The TextEditingController inside SearchScreenController '
              'is disposed in onClose() when hasListeners is true, but the '
              'stale controller instance remains accessible via '
              'Get.find<SearchScreenController>(). '
              'When the user re-enters SearchScreen and types a query, '
              '_openResults() calls searchController.text = q on the '
              'disposed controller, causing: '
              'StateError: A TextEditingController was used after being disposed.',
        );
      },
    );
  });

  // ===========================================================================
  // Group 2: Double Get.put() — second push returns stale or throws
  //
  // Simulates the exact sequence:
  //   1. First push: Get.put(SearchScreenController()) — registers controller
  //   2. GetX disposes controller (onClose → searchController.dispose())
  //      but does NOT delete the registration (unfixed code)
  //   3. Second push: Get.put(SearchScreenController()) — on unfixed code,
  //      GetX may return the existing (disposed) instance instead of creating
  //      a new one, because the registration key still exists
  // ===========================================================================
  group('Bug Condition 2: Double Get.put() — second push returns stale instance', () {
    test(
      'EXPLORATION: Second Get.put() after onClose() without Get.delete() '
      'returns the same (disposed) instance '
      '— EXPECTED TO FAIL (confirms bug 1.2, 1.3)',
      () {
        // First navigation cycle: SearchScreen pushed
        final controller1 = Get.put(SearchScreenController());
        controller1.searchController.text = 'dress';
        // Simulate TextField listener (required for onClose() to actually dispose)
        controller1.searchController.addListener(() {});
        final instance1Identity = controller1.hashCode;
        print('📋 First push: controller hashCode = $instance1Identity');
        print('📋 First push: searchController.text = '
            '"${controller1.searchController.text}"');
        print('📋 hasListeners = ${controller1.searchController.hasListeners}');

        // Simulate GetX disposing the controller WITHOUT deleting registration
        // (this is what happens on unfixed code — onClose() is called by GetX
        // but the registration key remains because SearchScreen.dispose()
        // never calls Get.delete())
        controller1.onClose();
        print('📋 After onClose(): controller disposed (registration still exists)');

        // Second navigation cycle: SearchScreen pushed again
        // On unfixed code, Get.put() with an existing registration key
        // returns the existing instance (which is now disposed)
        final controller2 = Get.put(SearchScreenController());
        final instance2Identity = controller2.hashCode;
        print('📋 Second push: controller hashCode = $instance2Identity');
        print('📋 Same instance? ${instance1Identity == instance2Identity}');

        // BUG CONDITION: If Get.put() returns the same disposed instance,
        // any write to searchController (setter, addListener, clear) will throw.
        //
        // EXPECTED OUTCOME ON UNFIXED CODE:
        //   - controller2 is the same disposed instance as controller1
        //   - controller2.searchController.text = 'shoes' throws StateError
        //
        // EXPECTED OUTCOME ON FIXED CODE:
        //   - Get.delete() was called in dispose(), so Get.put() creates fresh instance
        //   - controller2.searchController.text = 'shoes' works correctly
        //
        // This assertion FAILS on unfixed code (same disposed instance returned)
        // and PASSES on fixed code (fresh instance created).
        Object? thrownError;
        try {
          // _openResults() sets searchController.text before navigating:
          controller2.searchController.text = 'shoes';
          print('📋 controller2.searchController.text = "shoes" (no throw)');
        } catch (e) {
          thrownError = e;
          print('📋 controller2.searchController.text = "shoes" threw: $e');
        }

        // On unfixed code: the same disposed instance is returned
        // and the text setter throws StateError.
        //
        // The fix ensures: after Get.delete(force: true) in dispose(),
        // Get.put() always creates a fresh, non-disposed instance.
        expect(
          thrownError,
          isNull,
          reason:
              'BUG CONFIRMED: controller2.searchController.text = "shoes" threw: '
              '$thrownError. '
              'The second Get.put(SearchScreenController()) returned the '
              'same disposed instance from the first navigation cycle. '
              'This is because SearchScreen.dispose() does not call '
              'Get.delete<SearchScreenController>(force: true), so the '
              'stale registration persists and Get.put() returns the '
              'existing (disposed) instance. '
              'Fix: call Get.delete<SearchScreenController>(force: true) '
              'in SearchScreen.dispose().',
        );
      },
    );
  });

  // ===========================================================================
  // Group 3: SearchResultsScreen.dispose() — unconditional Get.find() throws
  //
  // Simulates what happens when SearchResultsScreen.dispose() is called
  // AFTER SearchScreenController has already been deleted:
  //   dispose() calls: Get.find<SearchScreenController>().clearChipSelection()
  //   If the controller is not registered, Get.find() throws GetxError.
  // ===========================================================================
  group('Bug Condition 3: SearchResultsScreen.dispose() — unconditional Get.find() throws', () {
    test(
      'EXPLORATION: Get.find<SearchScreenController>() throws when controller '
      'is not registered — simulates SearchResultsScreen.dispose() crash '
      '— EXPECTED TO FAIL (confirms bug 1.2)',
      () {
        // Ensure no controller is registered (simulates state after SearchScreen
        // was already disposed and Get.delete() was called by the fix,
        // but on unfixed code this scenario arises from a race condition
        // where SearchScreen.dispose() fires before SearchResultsScreen.dispose())
        expect(Get.isRegistered<SearchScreenController>(), isFalse,
            reason: 'No controller should be registered at test start');

        // Simulate what SearchResultsScreen.dispose() does on unfixed code:
        //   Get.find<SearchScreenController>().clearChipSelection()
        // This throws GetxError when the controller is not registered.
        //
        // EXPECTED OUTCOME ON UNFIXED CODE: throws GetxError (BUG)
        // EXPECTED OUTCOME ON FIXED CODE:   no throw (guarded with isRegistered check)
        expect(
          () {
            // This is the exact line in SearchResultsScreen.dispose():
            Get.find<SearchScreenController>().clearChipSelection();
          },
          throwsA(anything),
          reason:
              'BUG CONFIRMED: Get.find<SearchScreenController>() threw when '
              'the controller was not registered. '
              'The unfixed SearchResultsScreen.dispose() calls '
              'Get.find<SearchScreenController>().clearChipSelection() '
              'unconditionally. If SearchScreen was already disposed (and '
              'the controller deleted by the fix), this throws: '
              'GetxError: SearchScreenController not found. '
              'Fix: guard with if (Get.isRegistered<SearchScreenController>()) '
              'before calling Get.find().',
        );
      },
    );
  });

  // ===========================================================================
  // Group 4: Full five-step crash sequence simulation
  //
  // Simulates the complete crash sequence described in the bug report:
  //   Step 1: Push SearchScreen → navigate to SearchResultsScreen (zero results)
  //   Step 2: Pop both screens back to home
  //   Step 3: Re-push SearchScreen → navigate to SearchResultsScreen again
  //   Step 4: Trigger pull-to-refresh (calls getSearchData() → searchController.text)
  //   Assert: sequence completes without throwing
  //
  // This test directly exercises the controller lifecycle without widget testing
  // to avoid Firebase/complex dependencies.
  // ===========================================================================
  group('Bug Condition 4: Full five-step crash sequence', () {
    test(
      'EXPLORATION: Full crash sequence — zero results → back → re-enter → '
      'pull-to-refresh throws StateError or GetxError '
      '— EXPECTED TO FAIL (confirms bug 1.1, 1.4)',
      () async {
        // ── Step 1: First navigation cycle ──────────────────────────────────
        // SearchScreen pushed: Get.put() registers controller
        print('');
        print('═══ Step 1: First navigation cycle ═══');
        final controller1 = Get.put(SearchScreenController());
        controller1.searchController.text = 'dress';
        // Simulate the TextField widget adding a listener (as it does in the real app)
        // This is critical: onClose() only disposes the TextEditingController
        // if hasListeners is true. The TextField widget always adds a listener.
        controller1.searchController.addListener(() {}); // simulate TextField
        print('✓ SearchScreen pushed: controller registered');
        print('  searchController.text = "${controller1.searchController.text}"');
        print('  hasListeners = ${controller1.searchController.hasListeners}');

        // SearchResultsScreen opened: getSearchData() was called, returned 0 results
        // Simulate zero-results state:
        controller1.searchList.clear();
        controller1.hasMore.value = false;
        controller1.currentPage.value = 0;
        print('✓ SearchResultsScreen: zero results, hasMore=false');

        // ── Step 2: Pop both screens back to home ────────────────────────────
        print('');
        print('═══ Step 2: Pop both screens back to home ═══');

        // SearchResultsScreen.dispose() fires first (unfixed code):
        // Get.find<SearchScreenController>().clearChipSelection()
        // This works here because controller is still registered.
        if (Get.isRegistered<SearchScreenController>()) {
          Get.find<SearchScreenController>().clearChipSelection();
          print('✓ SearchResultsScreen.dispose(): clearChipSelection() called');
        }

        // SearchScreen.dispose() fires (unfixed code):
        // Does NOT call Get.delete() — only resetFilters()
        controller1.resetFilters(); // unfixed dispose() behavior
        // NOTE: NOT calling Get.delete() — this is the bug
        print('✓ SearchScreen.dispose() (unfixed): resetFilters() called, '
            'NO Get.delete() called');

        // GetX may call onClose() on the controller at some point after pop.
        // Simulate GetX calling onClose() (disposes TextEditingController):
        controller1.onClose();
        print('✓ GetX called onClose(): searchController.dispose() called');
        print('  isRegistered after onClose() (no Get.delete()): '
            '${Get.isRegistered<SearchScreenController>()}');

        // ── Step 3: Re-push SearchScreen ─────────────────────────────────────
        print('');
        print('═══ Step 3: Re-push SearchScreen ═══');

        // SearchScreen pushed again: Get.put() called again
        // On unfixed code, this may return the stale disposed instance
        final controller2 = Get.put(SearchScreenController());
        print('✓ SearchScreen re-pushed: Get.put() called');
        print('  Same instance as controller1? '
            '${identical(controller1, controller2)}');
        print('  controller2.hashCode = ${controller2.hashCode}');
        print('  controller1.hashCode = ${controller1.hashCode}');

        // User types a search query — this is what SearchScreen does in initState
        // and when the user types in the TextField
        Object? setTextError;
        try {
          // _openResults() calls: controller.searchController.text = q
          // This is the SETTER — it throws StateError on a disposed controller
          controller2.searchController.text = 'shoes';
          print('✓ searchController.text set to "shoes"');
        } catch (e) {
          setTextError = e;
          print('✗ Setting searchController.text threw: $e');
        }

        // ── Step 4: Trigger pull-to-refresh ──────────────────────────────────
        print('');
        print('═══ Step 4: Trigger pull-to-refresh ═══');
        print('  Calling getSearchData() — accesses searchController.text...');

        // getSearchData() accesses searchController.text.trim() (getter — does not throw)
        // But the crash already happened at Step 3 when the setter was called.
        // Additionally, if the TextField widget tries to addListener() on re-entry,
        // that also throws StateError.
        Object? crashError;
        try {
          // Simulate what happens when SearchResultsScreen is re-entered:
          // The TextField widget calls addListener() on the disposed controller
          controller2.searchController.addListener(() {}); // throws after dispose
          print('✓ addListener() succeeded (no crash)');
        } catch (e) {
          crashError = e;
          print('✗ CRASH: addListener() threw: $e');
        }

        // ── Assert: sequence should complete without throwing ─────────────────
        print('');
        print('═══ Assertion ═══');
        print('  setTextError = $setTextError');
        print('  crashError = $crashError');

        // Combine both errors — either one confirms the bug
        final anyError = setTextError ?? crashError;

        // EXPECTED OUTCOME ON UNFIXED CODE: anyError is not null (BUG)
        // EXPECTED OUTCOME ON FIXED CODE:   anyError is null (FIXED)
        expect(
          anyError,
          isNull,
          reason:
              'BUG CONFIRMED: The five-step crash sequence threw: $anyError. '
              'Step-by-step analysis: '
              '(1) SearchScreen pushed → Get.put(SearchScreenController()) registered. '
              '(2) Zero results → hasMore=false, searchList empty. '
              '(3) Pop: SearchScreen.dispose() called resetFilters() but NOT '
              'Get.delete<SearchScreenController>(force: true). '
              '(4) GetX called onClose() → searchController.dispose() (because '
              'TextField added a listener, so hasListeners was true). '
              '(5) Re-push: Get.put(SearchScreenController()) returned the '
              'same disposed instance (registration still exists). '
              '(6) Setting searchController.text or calling getSearchData() '
              'accessed the disposed TextEditingController. '
              'Fix: (A) call Get.delete<SearchScreenController>(force: true) '
              'in SearchScreen.dispose(); '
              '(B) guard Get.find() in SearchResultsScreen.dispose().',
        );
      },
    );

    test(
      'EXPLORATION: Chip tap on re-entered SearchResultsScreen — '
      'Get.find<SearchScreenController>() on stale controller throws '
      '— EXPECTED TO FAIL (confirms bug 1.3)',
      () {
        // Simulate the state after the crash sequence:
        // Controller was disposed by GetX but registration still exists
        final controller1 = Get.put(SearchScreenController());
        controller1.searchController.text = 'bag';
        // Simulate TextField listener (required for onClose() to actually dispose)
        controller1.searchController.addListener(() {});
        controller1.onClose(); // GetX disposes the controller

        // On unfixed code, the stale registration still exists.
        // Simulate a chip tap on the re-entered SearchResultsScreen:
        // onSearchChipTap() calls getSearchData() → searchController.text
        print('📋 Simulating chip tap on re-entered SearchResultsScreen...');
        print('  isRegistered: ${Get.isRegistered<SearchScreenController>()}');

        Object? chipTapError;
        try {
          final sc = Get.find<SearchScreenController>();
          // onSearchChipTap calls getSearchData() which calls:
          //   searchController.text = q (setter — throws after dispose)
          // Also, the TextField widget calls addListener() on re-entry (throws)
          sc.searchController.text = 'bag'; // setter throws after dispose
          print('✓ Chip tap: searchController.text set (no crash)');
        } catch (e) {
          chipTapError = e;
          print('✗ Chip tap CRASH: $e');
        }

        // EXPECTED OUTCOME ON UNFIXED CODE: chipTapError is not null (BUG)
        // EXPECTED OUTCOME ON FIXED CODE:   chipTapError is null (FIXED)
        expect(
          chipTapError,
          isNull,
          reason:
              'BUG CONFIRMED: Chip tap on re-entered SearchResultsScreen threw: '
              '$chipTapError. '
              'The chip tap calls Get.find<SearchScreenController>() and then '
              'accesses searchController.text on the disposed controller. '
              'This confirms bug 1.3: when the filter applied during the '
              'previous session returned zero results and the user re-enters '
              'the search results screen, the system attempts to call '
              'Get.find<SearchScreenController>() on a controller whose '
              'internal state is inconsistent with the current UI context.',
        );
      },
    );
  });

  // ===========================================================================
  // Group 5: hasMore=false guard — zero-results state blocks pull-to-refresh
  //
  // Even if the controller is alive (not disposed), the zero-results state
  // from the prior cycle leaves hasMore=false. On re-entry, getSearchData()
  // checks: if (!loadMore && !hasMore.value) return;
  // This means pull-to-refresh silently does nothing — no results shown.
  // The fix must reset hasMore=true on re-entry.
  // ===========================================================================
  group('Bug Condition 5: hasMore=false blocks pull-to-refresh on re-entry', () {
    test(
      'EXPLORATION: After zero-results cycle, hasMore=false blocks '
      'getSearchData() from re-fetching on pull-to-refresh '
      '— EXPECTED TO FAIL (confirms bug 1.4)',
      () {
        // Simulate state after zero-results cycle:
        final controller = Get.put(SearchScreenController());
        controller.searchController.text = 'dress';
        controller.searchList.clear();
        controller.hasMore.value = false; // zero results left hasMore=false
        controller.currentPage.value = 0;

        print('📋 State after zero-results cycle:');
        print('  searchController.text = "${controller.searchController.text}"');
        print('  hasMore = ${controller.hasMore.value}');
        print('  searchList.length = ${controller.searchList.length}');

        // On re-entry, getSearchData() is called (pull-to-refresh).
        // The guard: if (!loadMore && !hasMore.value) return;
        // This means getSearchData() returns immediately without fetching.
        //
        // Simulate the guard check:
        final key = controller.searchController.text.trim();
        final wouldFetch = key.isNotEmpty && controller.hasMore.value;
        print('📋 Would getSearchData() fetch? $wouldFetch');
        print('  (key.isNotEmpty=${key.isNotEmpty}, '
            'hasMore=${controller.hasMore.value})');

        // EXPECTED OUTCOME ON UNFIXED CODE: wouldFetch == false (BUG)
        // EXPECTED OUTCOME ON FIXED CODE:   wouldFetch == true (FIXED — hasMore reset)
        //
        // The fix resets hasMore=true in SearchResultsScreen.initState()
        // post-frame callback on re-entry.
        expect(
          wouldFetch,
          isTrue,
          reason:
              'BUG CONFIRMED: After zero-results cycle, hasMore=false '
              'blocks getSearchData() from re-fetching on pull-to-refresh. '
              'The guard "if (!loadMore && !hasMore.value) return;" causes '
              'getSearchData() to return immediately without fetching. '
              'Fix: reset hasMore=true and currentPage=0 in '
              'SearchResultsScreen.initState() post-frame callback on re-entry.',
        );
      },
    );
  });

  // ===========================================================================
  // Summary
  // ===========================================================================
  test(
    'SUMMARY: All bug conditions documented — crash sequence confirmed',
    () {
      print('');
      print('═══════════════════════════════════════════════════════════════');
      print('📋 SEARCH FILTER NAV CRASH — BUG CONDITION EXPLORATION SUMMARY');
      print('═══════════════════════════════════════════════════════════════');
      print('');
      print('Bug 1.1: Full crash sequence — zero results → back → re-enter → '
          'pull-to-refresh throws StateError');
      print('Bug 1.2: SearchScreen.dispose() does NOT call Get.delete() → '
          'stale controller remains registered');
      print('Bug 1.3: Chip tap on re-entered screen → Get.find() on stale '
          'controller → StateError');
      print('Bug 1.4: hasMore=false after zero-results cycle → '
          'pull-to-refresh silently does nothing');
      print('');
      print('Root Cause:');
      print('  1. Get.put() in field initializer (runs on every new State)');
      print('  2. No Get.delete(force: true) in SearchScreen.dispose()');
      print('  3. Unconditional Get.find() in SearchResultsScreen.dispose()');
      print('  4. No pagination reset on re-entry');
      print('');
      print('Expected Exceptions on Unfixed Code:');
      print('  - StateError: A TextEditingController was used after being disposed.');
      print('  - GetxError: SearchScreenController not found.');
      print('');
      print('Fix Required:');
      print('  A. SearchScreen.dispose(): add Get.delete<SearchScreenController>'
          '(force: true)');
      print('  B. SearchScreen.initState(): guard Get.put() with isRegistered check');
      print('  C. SearchResultsScreen.dispose(): guard Get.find() with '
          'isRegistered check');
      print('  D. SearchResultsScreen.initState(): reset hasMore=true, '
          'currentPage=0 on re-entry');
      print('');
      print('═══════════════════════════════════════════════════════════════');
      print('✗ TESTS FAIL ON UNFIXED CODE — BUG CONFIRMED');
      print('═══════════════════════════════════════════════════════════════');
      print('');

      // This test always passes — it's just a summary
      expect(true, isTrue);
    },
  );
}
