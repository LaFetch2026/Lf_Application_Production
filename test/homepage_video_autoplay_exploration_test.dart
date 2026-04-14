// ignore_for_file: avoid_print
//
// Homepage Video Autoplay Fix — Exploratory Tests (Task 1)
//
// PURPOSE:
//   These tests document the bug condition in _SectionVideoBannerState.didUpdateWidget.
//   Because _SectionVideoBanner and _SectionVideoBannerState are private classes,
//   we test the play/no-play decision logic directly by replicating the exact
//   conditional from the unfixed code.
//
//   Test 1.1 — EXPECTED TO FAIL on unfixed code (confirms the bug exists)
//   Test 1.2 — EXPECTED TO PASS on unfixed code (confirms the gate is the issue)
//
// Validates: Requirements 2.3 (bug condition), 1.1, 1.2, 1.3

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Minimal value objects that mirror VideoPlayerValue fields we care about
// ---------------------------------------------------------------------------

class FakeVideoPlayerValue {
  final bool isInitialized;
  final bool isPlaying;

  const FakeVideoPlayerValue({
    required this.isInitialized,
    required this.isPlaying,
  });
}

class FakeVideoPlayerController {
  final FakeVideoPlayerValue value;
  int playCallCount = 0;

  FakeVideoPlayerController(this.value);

  void play() {
    playCallCount++;
  }
}

// ---------------------------------------------------------------------------
// Replicas of the unfixed and fixed didUpdateWidget play decision
//
// These functions mirror the EXACT conditional logic from homescreen.dart
// so we can assert on the play/no-play outcome without needing the private
// widget class.
// ---------------------------------------------------------------------------

/// UNFIXED logic — mirrors _SectionVideoBannerState.didUpdateWidget as it
/// exists in the current (unfixed) code (~L1720 homescreen.dart):
///
///   if (ctrl != null &&
///       ctrl.value.isInitialized &&
///       _isRouteActive &&
///       _homeController.isHomeTabActive.value &&
///       !ctrl.value.isPlaying) {          // <-- the gate that causes the bug
///     ctrl.play();
///   }
bool unfixedShouldPlay({
  required FakeVideoPlayerController? oldController,
  required FakeVideoPlayerController? newController,
  required bool isRouteActive,
  required bool isHomeTabActive,
}) {
  final ctrl = newController;
  if (ctrl != null &&
      ctrl.value.isInitialized &&
      isRouteActive &&
      isHomeTabActive &&
      !ctrl.value.isPlaying) {
    // unfixed: no special handling for first assignment
    return true;
  }
  return false;
}

/// FIXED logic — mirrors the corrected didUpdateWidget:
///
///   if (ctrl != null && ctrl.value.isInitialized && _isRouteActive && isHomeTabActive) {
///     if (oldWidget.controller == null || !ctrl.value.isPlaying) {
///       ctrl.play();
///     }
///   }
bool fixedShouldPlay({
  required FakeVideoPlayerController? oldController,
  required FakeVideoPlayerController? newController,
  required bool isRouteActive,
  required bool isHomeTabActive,
}) {
  final ctrl = newController;
  if (ctrl != null &&
      ctrl.value.isInitialized &&
      isRouteActive &&
      isHomeTabActive) {
    // fixed: first assignment always plays, swap only plays if not already playing
    if (oldController == null || !ctrl.value.isPlaying) {
      return true;
    }
  }
  return false;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Exploration Tests — Bug Condition in didUpdateWidget (unfixed code)',
      () {
    // =========================================================================
    // Test 1.1 — EXPECTED TO FAIL on unfixed code
    //
    // Scenario: _SectionVideoBanner receives its first controller (null → ctrl)
    // and the controller is already playing (because _initSectionVideoController
    // called .play() before setState).
    //
    // On unfixed code: !ctrl.value.isPlaying == false → play() is SKIPPED
    // Expected: play() IS called (video should autoplay on first load)
    // Result on unfixed code: FAIL — confirms the bug
    // =========================================================================
    test(
      '1.1 EXPLORATION: first assignment with already-playing controller '
      '— play() should be called — EXPECTED TO FAIL on unfixed code',
      () {
        // Arrange: simulate _initSectionVideoController calling .play() before setState
        // oldWidget.controller == null (first build had null controller)
        // newWidget.controller is initialized AND already playing
        final oldController = null; // first build: null
        final newController = FakeVideoPlayerController(
          const FakeVideoPlayerValue(isInitialized: true, isPlaying: true),
        );
        const isRouteActive = true;
        const isHomeTabActive = true;

        // Act: apply the UNFIXED decision logic
        final shouldPlay = unfixedShouldPlay(
          oldController: oldController,
          newController: newController,
          isRouteActive: isRouteActive,
          isHomeTabActive: isHomeTabActive,
        );

        // Document what the unfixed code does
        print('');
        print('=== Test 1.1: First assignment, controller already playing ===');
        print('  oldController: null (first build)');
        print('  newController.isInitialized: ${newController.value.isInitialized}');
        print('  newController.isPlaying: ${newController.value.isPlaying}');
        print('  isRouteActive: $isRouteActive');
        print('  isHomeTabActive: $isHomeTabActive');
        print('');
        print('  UNFIXED gate: !ctrl.value.isPlaying == ${!newController.value.isPlaying}');
        print('  UNFIXED shouldPlay: $shouldPlay');
        print('');
        if (!shouldPlay) {
          print('  ❌ BUG CONFIRMED: play() is NOT called on first assignment');
          print('     because !ctrl.value.isPlaying == false skips the call.');
          print('     The video will appear frozen on first load.');
          print('     Counterexample: {isPlaying: true, isInitialized: true,');
          print('       oldController: null, isRouteActive: true, isHomeTabActive: true}');
          print('       => unfixedShouldPlay returns false (play() skipped)');
        } else {
          print('  ✅ play() IS called (unexpected on unfixed code)');
        }

        // Assert: play() SHOULD be called — this FAILS on unfixed code
        // because the !isPlaying gate evaluates to false and skips the call.
        expect(
          shouldPlay,
          isTrue,
          reason:
              'BUG CONFIRMED: On first controller assignment (null → initialized+playing), '
              'the unfixed didUpdateWidget does NOT call play() because '
              '!ctrl.value.isPlaying == false. '
              'Counterexample: {oldController: null, isInitialized: true, '
              'isPlaying: true, isRouteActive: true, isHomeTabActive: true} '
              '=> unfixedShouldPlay returns false. '
              'The video is frozen on first load. '
              'Fix: detect oldWidget.controller == null and call play() unconditionally.',
        );
      },
    );

    // =========================================================================
    // Test 1.2 — EXPECTED TO PASS on unfixed code
    //
    // Scenario: _SectionVideoBanner receives its first controller (null → ctrl)
    // but the controller is NOT yet playing (isPlaying == false).
    //
    // On unfixed code: !ctrl.value.isPlaying == true → play() IS called
    // This confirms the !isPlaying gate is the discriminating factor:
    // the bug only manifests when the controller is already playing.
    // =========================================================================
    test(
      '1.2 EXPLORATION: first assignment with not-yet-playing controller '
      '— play() should be called — EXPECTED TO PASS on unfixed code',
      () {
        // Arrange: controller is initialized but NOT yet playing
        // (isPlaying == false — the gate allows play() through)
        final oldController = null; // first build: null
        final newController = FakeVideoPlayerController(
          const FakeVideoPlayerValue(isInitialized: true, isPlaying: false),
        );
        const isRouteActive = true;
        const isHomeTabActive = true;

        // Act: apply the UNFIXED decision logic
        final shouldPlay = unfixedShouldPlay(
          oldController: oldController,
          newController: newController,
          isRouteActive: isRouteActive,
          isHomeTabActive: isHomeTabActive,
        );

        // Document what the unfixed code does
        print('');
        print('=== Test 1.2: First assignment, controller NOT yet playing ===');
        print('  oldController: null (first build)');
        print('  newController.isInitialized: ${newController.value.isInitialized}');
        print('  newController.isPlaying: ${newController.value.isPlaying}');
        print('  isRouteActive: $isRouteActive');
        print('  isHomeTabActive: $isHomeTabActive');
        print('');
        print('  UNFIXED gate: !ctrl.value.isPlaying == ${!newController.value.isPlaying}');
        print('  UNFIXED shouldPlay: $shouldPlay');
        print('');
        if (shouldPlay) {
          print('  ✅ play() IS called — gate allows it through when isPlaying==false');
          print('     This confirms the !isPlaying gate is the discriminating factor.');
          print('     The bug only fires when _initSectionVideoController has already');
          print('     called .play() before setState (making isPlaying==true).');
        } else {
          print('  ❌ Unexpected: play() NOT called even when isPlaying==false');
        }

        // Assert: play() SHOULD be called — this PASSES on unfixed code
        // because !ctrl.value.isPlaying == true allows the call through.
        // This confirms the gate is the discriminating factor.
        expect(
          shouldPlay,
          isTrue,
          reason:
              'GATE CONFIRMED: When isPlaying==false, the unfixed !isPlaying gate '
              'allows play() through. This confirms the gate is the discriminating '
              'factor: the bug only fires when _initSectionVideoController has '
              'already called .play() before setState (isPlaying==true). '
              'Input: {oldController: null, isInitialized: true, isPlaying: false, '
              'isRouteActive: true, isHomeTabActive: true} '
              '=> unfixedShouldPlay returns true.',
        );
      },
    );

    // =========================================================================
    // Additional documentation: side-by-side comparison of unfixed vs fixed
    // =========================================================================
    test(
      '1.3 DOCUMENTATION: unfixed vs fixed — first assignment already-playing '
      '— shows the exact difference',
      () {
        // This test always passes — it documents the counterexample
        final newController = FakeVideoPlayerController(
          const FakeVideoPlayerValue(isInitialized: true, isPlaying: true),
        );

        final unfixed = unfixedShouldPlay(
          oldController: null,
          newController: newController,
          isRouteActive: true,
          isHomeTabActive: true,
        );

        final fixed = fixedShouldPlay(
          oldController: null,
          newController: newController,
          isRouteActive: true,
          isHomeTabActive: true,
        );

        print('');
        print('=== Counterexample Documentation ===');
        print('  Input: {oldController: null, isInitialized: true,');
        print('          isPlaying: true, isRouteActive: true, isHomeTabActive: true}');
        print('');
        print('  UNFIXED shouldPlay: $unfixed  ← BUG: play() skipped');
        print('  FIXED   shouldPlay: $fixed   ← CORRECT: play() called');
        print('');
        print('  Root cause: !ctrl.value.isPlaying == false on first assignment');
        print('  because _initSectionVideoController called .play() before setState.');
        print('  Fix: add (oldWidget.controller == null ||) before !ctrl.value.isPlaying');

        // Unfixed skips play, fixed calls play — document the difference
        expect(unfixed, isFalse,
            reason:
                'Counterexample confirmed: unfixed code skips play() when '
                'isPlaying==true on first assignment. '
                'Input: {null → initialized+playing, route active, tab active}');
        expect(fixed, isTrue,
            reason:
                'Fix verified: fixed code calls play() on first assignment '
                'regardless of isPlaying state.');
      },
    );
  });
}
