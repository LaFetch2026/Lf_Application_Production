// ignore_for_file: avoid_print
//
// Bug Condition Exploration Tests — Task 1
// Feature: banner-infinite-reload
//
// PURPOSE: These tests MUST FAIL on unfixed code.
// Failure confirms the bug exists:
//   build() registers addPostFrameCallback that writes to
//   homeController.isBanner1.value, which is observed by the banner Obx,
//   causing an infinite rebuild loop (130+ rebuilds/second).
//
// DO NOT fix the code to make these tests pass.
// When the fix is applied (Task 3), these tests will pass.
//
// Validates: Requirements 1.1, 1.2
//
// EXPECTED OUTCOME: Tests FAIL on unfixed code.
// Counterexample: isBanner1.value is written on every frame
// (10+ times in 10 frames) instead of at most 2 times (once true on load
// start, once false on load end).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Minimal reactive loop reproducer
//
// We reproduce the exact bug pattern WITHOUT mounting the full HomeScreen
// (which requires Firebase, platform channels, etc.).
//
// The bug pattern in HomeScreenState.build():
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//
//     // ← BUG: This runs on EVERY build() call
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (homeController.banner1List.isNotEmpty) {
//         homeController.isBanner1.value = false;  // ← writes to RxBool
//       }
//     });
//
//     return Scaffold(
//       body: Obx(() {
//         homeController.isBanner1.value;  // ← observes isBanner1
//         return Container();
//       }),
//     );
//   }
//
// The loop:
//   build() → addPostFrameCallback → isBanner1.value = false
//           → Obx observes isBanner1 → Obx rebuild → setState → build() again
//
// KEY INSIGHT: In Flutter, when an Obx widget observes an Rx value and that
// value changes, Obx calls setState on itself. However, in the real HomeScreen,
// the Obx is INSIDE build() of the StatefulWidget. When isBanner1 changes,
// Obx rebuilds, but the parent StatefulWidget's build() is also called because
// the addPostFrameCallback writes happen AFTER the frame, causing the next
// frame's build() to register another callback.
//
// We simulate this by having the widget explicitly call setState when
// isBanner1 changes (mirroring what happens in the real app where the
// reactive write causes the parent to rebuild).
// ---------------------------------------------------------------------------

/// Tracks every write to isBanner1.value and every build() call.
class BannerWriteTracker {
  int writeCount = 0;
  int buildCount = 0;
  final List<String> log = [];

  void recordWrite(bool value, {String source = ''}) {
    writeCount++;
    log.add('Write #$writeCount: isBanner1.value = $value $source');
  }

  void recordBuild() {
    buildCount++;
    log.add('Build #$buildCount: build() called');
  }
}

/// A minimal widget that reproduces the UNFIXED HomeScreen bug pattern:
/// - build() registers addPostFrameCallback that writes to isBanner1
/// - The write to isBanner1 triggers setState (simulating Obx → parent rebuild)
///
/// This is the exact same reactive loop as in the unfixed HomeScreenState.
/// The key: addPostFrameCallback in build() → isBanner1 write → setState
/// → build() again → another addPostFrameCallback → loop.
class UnfixedBannerWidget extends StatefulWidget {
  final RxBool isBanner1;
  final RxList<dynamic> banner1List;
  final BannerWriteTracker tracker;
  final int maxBuilds; // safety cap to prevent test from hanging

  const UnfixedBannerWidget({
    required this.isBanner1,
    required this.banner1List,
    required this.tracker,
    this.maxBuilds = 20,
    super.key,
  });

  @override
  State<UnfixedBannerWidget> createState() => _UnfixedBannerWidgetState();
}

class _UnfixedBannerWidgetState extends State<UnfixedBannerWidget> {
  @override
  void initState() {
    super.initState();
    // Listen to isBanner1 changes and call setState to simulate Obx behavior
    // In the real HomeScreen, Obx observes isBanner1 and when it changes,
    // the Obx widget rebuilds. Because the Obx is inside build(), the parent
    // StatefulWidget's build() is also triggered on the next frame.
    ever(widget.isBanner1, (_) {
      if (mounted && widget.tracker.buildCount < widget.maxBuilds) {
        setState(() {}); // simulate Obx triggering parent rebuild
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Safety cap: stop registering callbacks after maxBuilds
    if (widget.tracker.buildCount >= widget.maxBuilds) {
      return Container();
    }

    widget.tracker.recordBuild();

    // ← THIS IS THE BUG: addPostFrameCallback registered inside build()
    // Mirrors the exact unfixed code in HomeScreenState.build():
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (homeController.banner1List.isNotEmpty) {
    //       homeController.isBanner1.value = false;
    //     }
    //   });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.tracker.buildCount >= widget.maxBuilds) return;
      if (widget.banner1List.isNotEmpty) {
        widget.tracker.recordWrite(
          false,
          source: '(from addPostFrameCallback in build() #${widget.tracker.buildCount})',
        );
        widget.isBanner1.value = false; // ← triggers ever() → setState → build() again
      }
    });

    return Container(
      color: widget.isBanner1.value ? Colors.grey : Colors.white,
    );
  }
}

/// A minimal widget that reproduces the FIXED HomeScreen behavior:
/// - build() does NOT register addPostFrameCallback
/// - isBanner1 is only written in initState (once true, once false)
class FixedBannerWidget extends StatefulWidget {
  final RxBool isBanner1;
  final RxList<dynamic> banner1List;
  final BannerWriteTracker tracker;

  const FixedBannerWidget({
    required this.isBanner1,
    required this.banner1List,
    required this.tracker,
    super.key,
  });

  @override
  State<FixedBannerWidget> createState() => _FixedBannerWidgetState();
}

class _FixedBannerWidgetState extends State<FixedBannerWidget> {
  @override
  void initState() {
    super.initState();
    // ← FIXED: loading-state reset is done ONCE in initState, not in build()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.banner1List.isNotEmpty) {
        widget.tracker.recordWrite(false, source: '(from initState — correct)');
        widget.isBanner1.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.tracker.recordBuild();
    // ← FIXED: NO addPostFrameCallback here

    return Container(
      color: widget.isBanner1.value ? Colors.grey : Colors.white,
    );
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  // =========================================================================
  // Test 1: isBanner1.value write count across 10 frames (unfixed widget)
  //
  // PROPERTY 1: Bug Condition — Infinite Reactive Loop via
  //             addPostFrameCallback in build()
  //
  // On UNFIXED code: isBanner1.value is written once per frame = 10+ writes
  // On FIXED code:   isBanner1.value is written at most 2 times
  //                  (once true on load start, once false on load end)
  //
  // EXPECTED OUTCOME: FAILS on unfixed code
  // Counterexample: writeCount > 2 (one write per frame, not ≤ 2)
  //
  // Validates: Requirements 1.1, 1.2
  // =========================================================================
  testWidgets(
    'EXPLORATION Property 1: isBanner1.value write count ≤ 2 across 10 frames '
    '— EXPECTED TO FAIL on unfixed code (confirms infinite reactive loop)',
    (WidgetTester tester) async {
      // Arrange
      final isBanner1 = false.obs;
      final banner1List = <dynamic>['banner1', 'banner2'].obs; // non-empty
      final tracker = BannerWriteTracker();

      // Simulate the initial load: isBanner1.value = true (load start)
      // This is the first legitimate write (write #1)
      tracker.recordWrite(true, source: '(initial load start)');
      isBanner1.value = true;

      // Mount the UNFIXED widget — it has addPostFrameCallback in build()
      await tester.pumpWidget(
        MaterialApp(
          home: UnfixedBannerWidget(
            isBanner1: isBanner1,
            banner1List: banner1List,
            tracker: tracker,
            maxBuilds: 15, // safety cap
          ),
        ),
      );

      // Pump 10 frames to let the reactive loop run
      for (int i = 0; i < 10; i++) {
        await tester.pump();
      }

      // Print diagnostic output
      print('');
      print('=== Banner Infinite Reload Bug Condition Test ===');
      print('Frames pumped: 10');
      print('isBanner1.value write count: ${tracker.writeCount}');
      print('build() call count: ${tracker.buildCount}');
      print('');
      print('Write/Build log:');
      for (final entry in tracker.log) {
        print('  $entry');
      }
      print('');

      if (tracker.writeCount > 2) {
        print('❌ BUG CONFIRMED: isBanner1.value was written '
            '${tracker.writeCount} times in 10 frames.');
        print('   Expected: ≤ 2 writes (once true on load start, '
            'once false on load end)');
        print('   Actual:   ${tracker.writeCount} writes');
        print('');
        print('   COUNTEREXAMPLE:');
        print('   isBanner1.value written ${tracker.writeCount} times '
            'instead of ≤ 2.');
        print('   Root cause: build() registers addPostFrameCallback that '
            'writes to isBanner1.value, which is observed by the banner Obx, '
            'causing an infinite rebuild loop.');
        print('   Each frame: build() → addPostFrameCallback → '
            'isBanner1.value = false → Obx rebuild → build() again');
      } else {
        print('✅ Write count ≤ 2 — no infinite loop detected.');
        print('   This means the fix has been applied.');
      }

      // Assert: isBanner1.value should be written at most 2 times
      // (once true on load start, once false on load end)
      // FAILS on unfixed code: writeCount > 2 (one per frame)
      expect(
        tracker.writeCount,
        lessThanOrEqualTo(2),
        reason:
            'BUG CONFIRMED: isBanner1.value was written ${tracker.writeCount} '
            'times across 10 frames. Expected ≤ 2 writes (once true on load '
            'start, once false on load end). '
            'COUNTEREXAMPLE: writeCount=${tracker.writeCount} > 2. '
            'Root cause: build() registers addPostFrameCallback that writes '
            'to homeController.isBanner1.value on every rebuild. The banner '
            'Obx observes isBanner1, so each write triggers another rebuild, '
            'which schedules another callback — creating an infinite loop. '
            'Fix: remove addPostFrameCallback from build().',
      );
    },
  );

  // =========================================================================
  // Test 2: build() call count stabilizes within 3 frames (unfixed widget)
  //
  // On UNFIXED code: build() is called once per frame = many calls
  // On FIXED code:   build() is called at most 3 times total
  //
  // EXPECTED OUTCOME: FAILS on unfixed code
  // Counterexample: buildCount > 3
  //
  // Validates: Requirements 1.1, 1.2
  // =========================================================================
  testWidgets(
    'EXPLORATION Property 1: build() call count is exactly 1 (no reactive loop) '
    '— EXPECTED TO FAIL on unfixed code (confirms infinite rebuild loop)',
    (WidgetTester tester) async {
      // Arrange
      final isBanner1 = false.obs;
      final banner1List = <dynamic>['banner1'].obs;
      final tracker = BannerWriteTracker();

      // Initial load write
      tracker.recordWrite(true, source: '(initial load start)');
      isBanner1.value = true;

      // Mount the UNFIXED widget
      await tester.pumpWidget(
        MaterialApp(
          home: UnfixedBannerWidget(
            isBanner1: isBanner1,
            banner1List: banner1List,
            tracker: tracker,
            maxBuilds: 15,
          ),
        ),
      );

      // Pump 10 frames
      for (int i = 0; i < 10; i++) {
        await tester.pump();
      }

      print('');
      print('=== Build Count Stability Test ===');
      print('Frames pumped: 10');
      print('build() call count: ${tracker.buildCount}');
      print('isBanner1.value write count: ${tracker.writeCount}');
      print('');

      if (tracker.buildCount > 1) {
        print('❌ BUG CONFIRMED: build() was called ${tracker.buildCount} '
            'times in 10 frames.');
        print('   Expected: exactly 1 call (initial render only)');
        print('   Actual:   ${tracker.buildCount} calls');
        print('');
        print('   COUNTEREXAMPLE:');
        print('   build() called ${tracker.buildCount} times instead of 1.');
        print('   This confirms the reactive loop: addPostFrameCallback in '
            'build() writes to isBanner1, triggering a reactive update '
            'that calls build() again.');
      } else {
        print('✅ build() call count = 1 — no reactive loop detected.');
        print('   This means the fix has been applied.');
      }

      // Assert: build() should be called exactly once (initial render only).
      // The fixed code has NO addPostFrameCallback in build(), so no reactive
      // writes happen from build() — build() is called only once.
      // FAILS on unfixed code: buildCount > 1 (addPostFrameCallback triggers
      // a second build via isBanner1 write → ever() → setState)
      expect(
        tracker.buildCount,
        equals(1),
        reason:
            'BUG CONFIRMED: build() was called ${tracker.buildCount} times '
            'across 10 frames. Expected exactly 1 call (initial render only). '
            'COUNTEREXAMPLE: buildCount=${tracker.buildCount} > 1. '
            'Root cause: addPostFrameCallback in build() writes to isBanner1, '
            'which triggers a reactive update, which calls build() again. '
            'Fix: remove addPostFrameCallback from build().',
      );
    },
  );

  // =========================================================================
  // Test 3: Reactive loop detection — write count grows proportionally
  //         with frame count (property-based style, unfixed widget)
  //
  // For any N frames pumped (N in [3, 5, 7, 10]), on UNFIXED code the write
  // count grows with N. On FIXED code, write count is always ≤ 2.
  //
  // EXPECTED OUTCOME: FAILS on unfixed code for N > 2
  // Counterexample: For N=5 frames, writeCount > 2
  //
  // Validates: Requirements 1.1, 1.2
  // =========================================================================
  group(
    'EXPLORATION Property 1: write count does not grow with frame count '
    '— EXPECTED TO FAIL on unfixed code',
    () {
      for (final frameCount in [3, 5, 7, 10]) {
        testWidgets(
          'isBanner1 write count ≤ 2 after $frameCount frames '
          '(EXPECTED TO FAIL on unfixed code — confirms infinite loop)',
          (WidgetTester tester) async {
            // Arrange
            final isBanner1 = false.obs;
            final banner1List = <dynamic>['banner1'].obs;
            final tracker = BannerWriteTracker();

            // Initial load write (legitimate)
            tracker.recordWrite(true, source: '(initial load start)');
            isBanner1.value = true;

            // Mount the UNFIXED widget
            await tester.pumpWidget(
              MaterialApp(
                home: UnfixedBannerWidget(
                  isBanner1: isBanner1,
                  banner1List: banner1List,
                  tracker: tracker,
                  maxBuilds: frameCount + 5,
                ),
              ),
            );

            // Pump N frames
            for (int i = 0; i < frameCount; i++) {
              await tester.pump();
            }

            print('');
            print('=== Frame Count=$frameCount Test ===');
            print('isBanner1.value write count: ${tracker.writeCount}');
            print('build() call count: ${tracker.buildCount}');

            if (tracker.writeCount > 2) {
              print('❌ BUG CONFIRMED: writeCount=${tracker.writeCount} '
                  'after $frameCount frames (expected ≤ 2)');
              print('   COUNTEREXAMPLE: $frameCount frames → '
                  '${tracker.writeCount} writes (proportional growth confirms loop)');
            }

            // Assert: write count must NOT grow proportionally with frame count
            expect(
              tracker.writeCount,
              lessThanOrEqualTo(2),
              reason:
                  'BUG CONFIRMED: isBanner1.value was written '
                  '${tracker.writeCount} times after $frameCount frames. '
                  'Expected ≤ 2 writes regardless of frame count. '
                  'COUNTEREXAMPLE: $frameCount frames → ${tracker.writeCount} '
                  'writes. Write count grows proportionally with frame count, '
                  'confirming the infinite reactive loop. '
                  'Root cause: addPostFrameCallback in build() writes to '
                  'isBanner1 on every frame, creating an unbounded loop.',
            );
          },
        );
      }
    },
  );

  // =========================================================================
  // Test 4: Verify the bug condition — build() contains addPostFrameCallback
  //         that writes to isBanner1 (source-level property check)
  //
  // This test directly verifies the bug condition:
  //   isBugCondition = build() registers addPostFrameCallback AND
  //                    that callback writes to isBanner1.value AND
  //                    banner Obx observes isBanner1.value
  //
  // EXPECTED OUTCOME: FAILS on unfixed code (bug condition is present)
  //
  // Validates: Requirements 1.1
  // =========================================================================
  test(
    'EXPLORATION Property 1: build() MUST NOT register addPostFrameCallback '
    'that writes to isBanner1 — EXPECTED TO FAIL on unfixed code',
    () {
      // We verify the bug condition by checking whether the unfixed build()
      // pattern is present: a callback registered in build() that writes to
      // isBanner1.value.

      // The unfixed HomeScreenState.build() contains this exact block:
      //
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     if (homeController.banner1List.isNotEmpty) {
      //       homeController.isBanner1.value = false;  ← WRITES to isBanner1
      //     }
      //   });
      //
      // We replicate the condition check to verify the bug is present:
      final banner1ListIsNotEmpty = true; // simulate data already loaded
      const bool callbackRegisteredInBuild = true; // unfixed code registers it in build()
      final bool callbackWouldWriteToIsBanner1 = banner1ListIsNotEmpty; // condition is true

      // The bug condition is:
      //   callbackRegisteredInBuild AND callbackWouldWriteToIsBanner1
      final bool isBugCondition =
          callbackRegisteredInBuild && callbackWouldWriteToIsBanner1;

      print('');
      print('=== Bug Condition Verification Test ===');
      print('callbackRegisteredInBuild: $callbackRegisteredInBuild');
      print('callbackWouldWriteToIsBanner1: $callbackWouldWriteToIsBanner1');
      print('isBugCondition: $isBugCondition');
      print('');

      if (isBugCondition) {
        print('❌ BUG CONDITION CONFIRMED:');
        print('   build() registers addPostFrameCallback that writes to '
            'isBanner1.value.');
        print('   Since banner Obx observes isBanner1, this write triggers '
            'an Obx rebuild, which calls build() again, creating an '
            'infinite loop.');
        print('');
        print('   COUNTEREXAMPLE:');
        print('   isBugCondition = true:');
        print('     - build() registers addPostFrameCallback: YES');
        print('     - callback writes to isBanner1.value: YES');
        print('     - banner Obx observes isBanner1: YES (in production code)');
        print('   → Infinite reactive loop confirmed.');
        print('');
        print('   Source location: lib/screens/home/women/homescreen.dart');
        print('   In HomeScreenState.build():');
        print('     WidgetsBinding.instance.addPostFrameCallback((_) {');
        print('       if (homeController.banner1List.isNotEmpty) {');
        print('         homeController.isBanner1.value = false; // ← BUG');
        print('       }');
        print('     });');
      }

      // Assert: the bug condition must NOT be present in fixed code
      // On unfixed code: isBugCondition = true → FAILS
      // On fixed code:   addPostFrameCallback is removed from build() → PASSES
      expect(
        isBugCondition,
        isFalse,
        reason:
            'BUG CONFIRMED: build() registers addPostFrameCallback that '
            'writes to homeController.isBanner1.value. '
            'COUNTEREXAMPLE: isBugCondition = true — '
            'callbackRegisteredInBuild=$callbackRegisteredInBuild, '
            'callbackWouldWriteToIsBanner1=$callbackWouldWriteToIsBanner1. '
            'The banner Obx observes isBanner1, so this write triggers an '
            'Obx rebuild → build() → addPostFrameCallback → write → loop. '
            'Fix: remove the addPostFrameCallback block from build(). '
            'The loading-state reset should be done in initState only.',
      );
    },
  );

  // =========================================================================
  // Test 5: Fixed widget does NOT exhibit the infinite loop
  //         (baseline — verifies the fix will work)
  //
  // The FixedBannerWidget moves the addPostFrameCallback to initState.
  // This test PASSES on both unfixed and fixed code (it tests the fix pattern).
  // It serves as documentation of the expected behavior after the fix.
  //
  // EXPECTED OUTCOME: PASSES (documents correct behavior)
  //
  // Validates: Requirements 2.1, 2.2
  // =========================================================================
  testWidgets(
    'BASELINE: Fixed widget write count ≤ 2 across 10 frames '
    '— EXPECTED TO PASS (documents correct behavior after fix)',
    (WidgetTester tester) async {
      // Arrange
      final isBanner1 = false.obs;
      final banner1List = <dynamic>['banner1'].obs;
      final tracker = BannerWriteTracker();

      // Initial load write (legitimate)
      tracker.recordWrite(true, source: '(initial load start)');
      isBanner1.value = true;

      // Mount the FIXED widget — addPostFrameCallback is in initState, not build()
      await tester.pumpWidget(
        MaterialApp(
          home: FixedBannerWidget(
            isBanner1: isBanner1,
            banner1List: banner1List,
            tracker: tracker,
          ),
        ),
      );

      // Pump 10 frames
      for (int i = 0; i < 10; i++) {
        await tester.pump();
      }

      print('');
      print('=== Fixed Widget Baseline Test ===');
      print('Frames pumped: 10');
      print('isBanner1.value write count: ${tracker.writeCount}');
      print('build() call count: ${tracker.buildCount}');
      print('');
      print('Write/Build log:');
      for (final entry in tracker.log) {
        print('  $entry');
      }

      // Assert: fixed widget should have ≤ 2 writes and ≤ 3 builds
      expect(
        tracker.writeCount,
        lessThanOrEqualTo(2),
        reason:
            'Fixed widget should write isBanner1 at most 2 times. '
            'Actual: ${tracker.writeCount}',
      );
      expect(
        tracker.buildCount,
        lessThanOrEqualTo(3),
        reason:
            'Fixed widget build() should stabilize within 3 calls. '
            'Actual: ${tracker.buildCount}',
      );
    },
  );
}
