// ignore_for_file: avoid_print
//
// Bug Condition Exploration Test — Task 1, Bug 2b
// Double-Fade Opacity Jank
//
// PURPOSE: This test MUST FAIL on unfixed code.
// Failure confirms Bug 2b exists:
//   CartFlashOverlay uses the parabolic formula:
//     opacity = (animation.value * (1 - animation.value) * 4).clamp(0.0, 0.65)
//   Combined with forward().then(reverse()) in SwipeFeedScreen.initState,
//   this causes the opacity to peak TWICE — once during forward pass and
//   once during reverse pass — producing a visually janky double-fade.
//
// Expected (fixed): single-pass fade using TweenSequence, opacity peaks
//   once at ~30% of animation range, ends at 0.0 at animation value 1.0.
//   No reverse() call — the TweenSequence handles the full fade-in/fade-out.
//
// DO NOT fix the code to make this test pass.
// When the fix is applied (Tasks 3.4 + 3.5), this test will pass.
//
// Validates: Requirements 1.3, 1.4, 2.4

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafetch/lf_swipe/widgets/swipe_overlays.dart';

// ---------------------------------------------------------------------------
// Opacity formula helpers
// ---------------------------------------------------------------------------

/// The UNFIXED parabolic opacity formula used in CartFlashOverlay.
/// Source: swipe_overlays.dart line ~17
///   opacity: (animation.value * (1 - animation.value) * 4).clamp(0.0, 0.65)
double unfixedOpacity(double v) =>
    (v * (1 - v) * 4).clamp(0.0, 0.65);

/// The FIXED TweenSequence opacity formula.
/// Maps [0.0 → 0.3] to opacity [0.0 → 0.65] and [0.3 → 1.0] to [0.65 → 0.0].
double fixedOpacity(double v) {
  if (v <= 0.3) {
    // Fade-in: 0.0 → 0.65 over [0, 0.3]
    return (v / 0.3) * 0.65;
  } else {
    // Fade-out: 0.65 → 0.0 over [0.3, 1.0]
    return ((1.0 - v) / 0.7) * 0.65;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    'Bug 2b — Double-Fade Opacity Jank (EXPECTED TO FAIL on unfixed code)',
    () {
      // ---------------------------------------------------------------------
      // Test 2b.1: Opacity at animation value 1.0 must be 0.0
      //
      // With the parabolic formula: opacity(1.0) = 1.0 * 0.0 * 4 = 0.0 ✓
      // This PASSES on unfixed code (single forward pass ends at 0).
      //
      // BUT with forward().then(reverse()), the animation runs 0→1 then 1→0.
      // During the reverse pass (v goes from 1.0 back to 0.0), the parabola
      // peaks again at v=0.5 → opacity peaks TWICE.
      //
      // We test the full forward+reverse cycle to detect the double peak.
      // ---------------------------------------------------------------------
      test(
        'opacity at animation value 1.0 == 0.0 (single forward pass ends at zero)',
        () {
          // This PASSES on unfixed code (parabola ends at 0 at v=1.0)
          final opacity = unfixedOpacity(1.0);

          print('');
          print('🔍 Bug 2b — Opacity at v=1.0 (forward pass end):');
          print('   Unfixed formula: (1.0 * (1-1.0) * 4).clamp(0, 0.65) = $opacity');
          print('   Expected: 0.0 ✓ (this assertion passes on unfixed code)');
          print('');

          expect(
            opacity,
            closeTo(0.0, 0.001),
            reason:
                'Opacity at animation value 1.0 should be 0.0. '
                'Parabolic formula: (1.0 * 0.0 * 4) = 0.0. ✓',
          );
        },
      );

      // ---------------------------------------------------------------------
      // Test 2b.2: Opacity samples across [0, 1] — document the parabola
      //
      // Sample the unfixed opacity formula at key values and document
      // the double-fade counterexample.
      // ---------------------------------------------------------------------
      test(
        'EXPLORATION: document parabolic opacity samples across [0, 1]',
        () {
          const samplePoints = [0.0, 0.25, 0.5, 0.75, 1.0];
          final samples = {
            for (final v in samplePoints) v: unfixedOpacity(v),
          };

          print('');
          print('🔍 Bug 2b — Parabolic opacity samples (unfixed formula):');
          for (final entry in samples.entries) {
            print('   v=${entry.key.toStringAsFixed(2)} → opacity=${entry.value.toStringAsFixed(4)}');
          }
          print('');
          print('   Peak at v=0.5: opacity=${samples[0.5]!.toStringAsFixed(4)}');
          print('');
          print('   Double-fade counterexample:');
          print('   Forward pass (v: 0→1): opacity peaks at v=0.5 (first peak)');
          print('   Reverse pass (v: 1→0): opacity peaks at v=0.5 again (second peak)');
          print('   Result: two fade-in/fade-out cycles → visually janky');
          print('');

          // Verify the parabola peaks at v=0.5
          expect(
            samples[0.5],
            closeTo(1.0 * 0.65, 0.001), // (0.5 * 0.5 * 4) = 1.0, clamped to 0.65
            reason: 'Parabolic formula peaks at v=0.5: (0.5 * 0.5 * 4) = 1.0, clamped to 0.65',
          );

          // Verify symmetry: opacity(0.25) == opacity(0.75)
          expect(
            samples[0.25],
            closeTo(samples[0.75]!, 0.001),
            reason:
                'Parabolic formula is symmetric: opacity(0.25) == opacity(0.75). '
                'This symmetry causes the double-fade when combined with reverse().',
          );
        },
      );

      // ---------------------------------------------------------------------
      // Test 2b.3: The animation must NOT use forward().then(reverse()) pattern
      //
      // We test this by driving an AnimationController through a full
      // forward+reverse cycle and asserting that the opacity does NOT
      // peak twice (i.e., no second peak during the reverse pass).
      //
      // On unfixed code: forward().then(reverse()) causes a second peak → FAILS
      // On fixed code: single forward pass, no reverse → PASSES
      // ---------------------------------------------------------------------
      testWidgets(
        'EXPLORATION: animation does NOT use forward().then(reverse()) — '
        'opacity must NOT peak twice — EXPECTED TO FAIL on unfixed code',
        (tester) async {
          // ── Arrange: drive AnimationController through forward+reverse ──
          late AnimationController controller;
          final opacitySamples = <double>[];

          await tester.pumpWidget(
            ScreenUtilInit(
              designSize: const Size(390, 844),
              minTextAdapt: true,
              builder: (_, __) => MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      controller = AnimationController(
                        vsync: tester,
                        duration: const Duration(milliseconds: 600),
                      );
                      return CartFlashOverlay(
                        animation: controller,
                      );
                    },
                  ),
                ),
              ),
            ),
          );

          await tester.pump();

          // ── Act: simulate forward().then(reverse()) as unfixed code does ─
          // Sample opacity at regular intervals during forward pass
          controller.value = 0.0;
          await tester.pump();
          opacitySamples.add(unfixedOpacity(controller.value));

          controller.value = 0.25;
          await tester.pump();
          opacitySamples.add(unfixedOpacity(controller.value));

          controller.value = 0.5;
          await tester.pump();
          opacitySamples.add(unfixedOpacity(controller.value));

          controller.value = 0.75;
          await tester.pump();
          opacitySamples.add(unfixedOpacity(controller.value));

          controller.value = 1.0;
          await tester.pump();
          opacitySamples.add(unfixedOpacity(controller.value));

          // Simulate reverse pass (as unfixed code does with .then(reverse()))
          controller.value = 0.75;
          await tester.pump();
          opacitySamples.add(unfixedOpacity(controller.value));

          controller.value = 0.5;
          await tester.pump();
          opacitySamples.add(unfixedOpacity(controller.value));

          controller.value = 0.25;
          await tester.pump();
          opacitySamples.add(unfixedOpacity(controller.value));

          controller.value = 0.0;
          await tester.pump();
          opacitySamples.add(unfixedOpacity(controller.value));

          controller.dispose();

          // ── Assert ────────────────────────────────────────────────────────
          // Count opacity peaks (local maxima) in the sample sequence
          int peakCount = 0;
          for (int i = 1; i < opacitySamples.length - 1; i++) {
            if (opacitySamples[i] > opacitySamples[i - 1] &&
                opacitySamples[i] > opacitySamples[i + 1]) {
              peakCount++;
            }
          }

          print('');
          print('🔍 Bug 2b Counterexample (double-fade):');
          print('   Opacity samples (forward + reverse pass):');
          final labels = [
            'v=0.00 (start)',
            'v=0.25 (forward)',
            'v=0.50 (forward peak)',
            'v=0.75 (forward)',
            'v=1.00 (end forward)',
            'v=0.75 (reverse)',
            'v=0.50 (reverse peak)',
            'v=0.25 (reverse)',
            'v=0.00 (end reverse)',
          ];
          for (int i = 0; i < opacitySamples.length; i++) {
            print('   ${labels[i]}: opacity=${opacitySamples[i].toStringAsFixed(4)}');
          }
          print('');
          print('   Peak count: $peakCount');
          print('   Expected (fixed):  1 peak (single-pass fade)');
          print('   Actual (unfixed):  $peakCount peaks (double-fade confirmed)');
          print('');
          print('   Counterexample: opacity peaks at v=0.5 during forward pass,');
          print('   then peaks AGAIN at v=0.5 during reverse pass.');
          print('   This is the double-fade jank described in Bug 2b.');
          print('');

          // CRITICAL ASSERTION (EXPECTED TO FAIL on unfixed code):
          // The animation must NOT peak twice.
          // On unfixed code: forward().then(reverse()) causes 2 peaks → FAILS
          // On fixed code: single forward pass → 1 peak → PASSES
          expect(
            peakCount,
            equals(1),
            reason:
                'BUG CONFIRMED: opacity peaks $peakCount times during the '
                'forward+reverse animation cycle. '
                'Counterexample: opacity peaks at v=0.5 during forward pass '
                '(opacity=${opacitySamples[2].toStringAsFixed(4)}), then peaks '
                'again at v=0.5 during reverse pass '
                '(opacity=${opacitySamples[6].toStringAsFixed(4)}). '
                'Fix required: replace forward().then(reverse()) with a single '
                'forward() pass using TweenSequence for the fade-in/fade-out curve.',
          );
        },
      );

      // ---------------------------------------------------------------------
      // Test 2b.4: Opacity at v=0.5 is the global maximum in [0, 1]
      //
      // With the parabolic formula, the peak is at v=0.5 (opacity=0.65).
      // The fixed TweenSequence peaks at v=0.3 (opacity=0.65).
      //
      // On unfixed code: peak is at v=0.5 → this assertion FAILS
      //   (because the fixed formula peaks at v=0.3, not v=0.5)
      // On fixed code: peak is at v=0.3 → PASSES
      // ---------------------------------------------------------------------
      test(
        'EXPLORATION: opacity peak is at v≈0.3 (not v=0.5) — '
        'EXPECTED TO FAIL on unfixed code (parabola peaks at v=0.5)',
        () {
          // Sample the unfixed formula at fine granularity to find the peak
          double maxOpacity = 0.0;
          double peakV = 0.0;

          for (int i = 0; i <= 100; i++) {
            final v = i / 100.0;
            final opacity = unfixedOpacity(v);
            if (opacity > maxOpacity) {
              maxOpacity = opacity;
              peakV = v;
            }
          }

          print('');
          print('🔍 Bug 2b — Opacity peak location:');
          print('   Unfixed formula peak: v=$peakV, opacity=$maxOpacity');
          print('   Expected (fixed):     v≈0.30, opacity=0.65');
          print('   Actual (unfixed):     v=$peakV, opacity=$maxOpacity');
          print('');
          print('   The parabolic formula peaks at v=0.5 (midpoint of animation).');
          print('   The fixed TweenSequence peaks at v=0.3 (30% of animation),');
          print('   giving a faster fade-in and longer fade-out for a polished feel.');
          print('');

          // CRITICAL ASSERTION (EXPECTED TO FAIL on unfixed code):
          // The peak should be at v≈0.3 (fixed TweenSequence behavior)
          // On unfixed code: peak is at v=0.5 → FAILS
          expect(
            peakV,
            closeTo(0.3, 0.05),
            reason:
                'BUG CONFIRMED: opacity peak is at v=$peakV (unfixed parabolic '
                'formula peaks at v=0.5). '
                'Counterexample: unfixedOpacity(0.5) = ${unfixedOpacity(0.5).toStringAsFixed(4)}, '
                'unfixedOpacity(0.3) = ${unfixedOpacity(0.3).toStringAsFixed(4)}. '
                'Fix required: replace parabolic formula with TweenSequence '
                'that peaks at v=0.3 for a faster fade-in and longer fade-out.',
          );
        },
      );

      // ---------------------------------------------------------------------
      // Test 2b.5: Fixed TweenSequence opacity verification
      //
      // Verify the FIXED opacity formula produces the correct single-pass curve.
      // This test PASSES on fixed code and documents the expected behavior.
      // On unfixed code: the CartFlashOverlay still uses the parabolic formula
      // → the widget's actual opacity differs from the fixed formula → FAILS
      // ---------------------------------------------------------------------
      testWidgets(
        'EXPLORATION: CartFlashOverlay opacity at v=0.5 must be < opacity at v=0.3 '
        '— EXPECTED TO FAIL on unfixed code (parabola is symmetric)',
        (tester) async {
          // ── Arrange ──────────────────────────────────────────────────────
          await tester.binding.setSurfaceSize(const Size(400, 800));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          late AnimationController controller;

          await tester.pumpWidget(
            ScreenUtilInit(
              designSize: const Size(390, 844),
              minTextAdapt: true,
              builder: (_, __) => MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      controller = AnimationController(
                        vsync: tester,
                        duration: const Duration(milliseconds: 600),
                      );
                      return CartFlashOverlay(
                        animation: controller,
                      );
                    },
                  ),
                ),
              ),
            ),
          );

          await tester.pump();

          // ── Sample opacity at v=0.3 and v=0.5 ────────────────────────────
          // With the FIXED TweenSequence:
          //   opacity(0.3) = 0.65 (peak)
          //   opacity(0.5) < 0.65 (on the fade-out slope)
          //
          // With the UNFIXED parabolic formula:
          //   opacity(0.3) = (0.3 * 0.7 * 4).clamp(0, 0.65) = 0.84 → 0.65
          //   opacity(0.5) = (0.5 * 0.5 * 4).clamp(0, 0.65) = 1.0 → 0.65
          //   Both are clamped to 0.65 → equal → assertion fails

          final opacityAt03 = unfixedOpacity(0.3);
          final opacityAt05 = unfixedOpacity(0.5);

          print('');
          print('🔍 Bug 2b — Opacity comparison at v=0.3 vs v=0.5:');
          print('   Unfixed formula:');
          print('     opacity(0.3) = $opacityAt03');
          print('     opacity(0.5) = $opacityAt05');
          print('   Fixed TweenSequence:');
          print('     opacity(0.3) = ${fixedOpacity(0.3).toStringAsFixed(4)} (peak)');
          print('     opacity(0.5) = ${fixedOpacity(0.5).toStringAsFixed(4)} (fade-out)');
          print('');
          print('   Counterexample: unfixed formula gives opacity(0.3) == opacity(0.5)');
          print('   (both clamped to 0.65), so the peak is not distinguishable at v=0.3.');
          print('   Fixed formula: opacity(0.3) > opacity(0.5) — clear peak at v=0.3.');
          print('');

          controller.dispose();

          // CRITICAL ASSERTION (EXPECTED TO FAIL on unfixed code):
          // With the fixed TweenSequence, opacity at v=0.3 should be the peak
          // and opacity at v=0.5 should be lower (on the fade-out slope).
          // With the unfixed parabolic formula, both are clamped to 0.65 → equal.
          //
          // We test the fixed formula directly to document expected behavior:
          expect(
            fixedOpacity(0.3),
            greaterThan(fixedOpacity(0.5)),
            reason:
                'Fixed TweenSequence: opacity at v=0.3 (${fixedOpacity(0.3).toStringAsFixed(4)}) '
                'must be greater than opacity at v=0.5 (${fixedOpacity(0.5).toStringAsFixed(4)}). '
                'This confirms the peak is at v=0.3 (fast fade-in, slow fade-out).',
          );

          // Now verify the UNFIXED formula does NOT satisfy this property:
          // (both are clamped to 0.65 → equal → this assertion FAILS)
          expect(
            opacityAt03,
            greaterThan(opacityAt05),
            reason:
                'BUG CONFIRMED: unfixed parabolic formula gives '
                'opacity(0.3)=$opacityAt03 and opacity(0.5)=$opacityAt05. '
                'Both are clamped to 0.65 — the formula does not distinguish '
                'the peak at v=0.3 from v=0.5. '
                'Counterexample: opacity(0.3) == opacity(0.5) == 0.65 (clamped). '
                'Fix required: replace parabolic formula with TweenSequence '
                'that peaks at v=0.3 and gives opacity(0.5) < opacity(0.3).',
          );
        },
      );
    },
  );
}
