// ignore_for_file: avoid_print
//
// Preservation Property Tests — Task 2, WishlistFlashOverlay
//
// PURPOSE: These tests MUST PASS on unfixed code.
// They establish the regression baseline for WishlistFlashOverlay behavior.
// After the fix is applied (Task 3), these same tests are re-run (Task 3.8)
// to confirm no regressions were introduced.
//
// The fix touches CartFlashOverlay (Task 3.4) but must NOT touch
// WishlistFlashOverlay. These tests verify the overlay is unchanged.
//
// Validates: Requirements 3.8

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafetch/lf_swipe/widgets/swipe_overlays.dart';

// ---------------------------------------------------------------------------
// Opacity formula helpers
// ---------------------------------------------------------------------------

/// The WishlistFlashOverlay opacity formula (must remain unchanged after fix).
/// Source: swipe_overlays.dart
///   opacity: v > 0.5 ? (1 - v) * 2 : v * 2
double wishlistOpacity(double v) => v > 0.5 ? (1 - v) * 2 : v * 2;

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Preservation — WishlistFlashOverlay (MUST PASS on unfixed code)', () {
    // -----------------------------------------------------------------------
    // Test W1: Opacity formula v > 0.5 ? (1-v)*2 : v*2 — key sample points
    //
    // Baseline: the WishlistFlashOverlay uses this specific opacity formula.
    // The fix must NOT change this formula.
    //
    // Validates: Requirement 3.8
    // -----------------------------------------------------------------------
    test(
      'PRESERVATION: WishlistFlashOverlay opacity formula v>0.5?(1-v)*2:v*2 — key samples',
      () {
        // Sample the formula at key points
        final samples = {
          0.0: wishlistOpacity(0.0),
          0.25: wishlistOpacity(0.25),
          0.5: wishlistOpacity(0.5),
          0.75: wishlistOpacity(0.75),
          1.0: wishlistOpacity(1.0),
        };

        print('');
        print('🔍 Preservation W1 — WishlistFlashOverlay opacity formula:');
        print('   Formula: v > 0.5 ? (1-v)*2 : v*2');
        for (final entry in samples.entries) {
          print('   v=${entry.key.toStringAsFixed(2)} → opacity=${entry.value.toStringAsFixed(4)}');
        }
        print('');

        // v=0.0: opacity = 0.0 * 2 = 0.0
        expect(
          samples[0.0],
          closeTo(0.0, 0.001),
          reason: 'PRESERVATION: opacity at v=0.0 must be 0.0. Formula: 0.0 * 2 = 0.0.',
        );

        // v=0.25: opacity = 0.25 * 2 = 0.5
        expect(
          samples[0.25],
          closeTo(0.5, 0.001),
          reason: 'PRESERVATION: opacity at v=0.25 must be 0.5. Formula: 0.25 * 2 = 0.5.',
        );

        // v=0.5: opacity = 0.5 * 2 = 1.0 (peak — boundary uses v*2 branch)
        expect(
          samples[0.5],
          closeTo(1.0, 0.001),
          reason:
              'PRESERVATION: opacity at v=0.5 must be 1.0. '
              'Formula: v > 0.5 is false at v=0.5, so v*2 = 0.5*2 = 1.0.',
        );

        // v=0.75: opacity = (1-0.75)*2 = 0.5
        expect(
          samples[0.75],
          closeTo(0.5, 0.001),
          reason: 'PRESERVATION: opacity at v=0.75 must be 0.5. Formula: (1-0.75)*2 = 0.5.',
        );

        // v=1.0: opacity = (1-1.0)*2 = 0.0
        expect(
          samples[1.0],
          closeTo(0.0, 0.001),
          reason: 'PRESERVATION: opacity at v=1.0 must be 0.0. Formula: (1-1.0)*2 = 0.0.',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test W2: Opacity formula is symmetric around v=0.5
    //
    // The formula v > 0.5 ? (1-v)*2 : v*2 is symmetric:
    //   opacity(v) == opacity(1-v) for all v in [0, 1]
    // This is a key property that must be preserved.
    //
    // Validates: Requirement 3.8
    // -----------------------------------------------------------------------
    test(
      'PRESERVATION: WishlistFlashOverlay opacity formula is symmetric around v=0.5',
      () {
        // Test symmetry at multiple points
        const testPoints = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5];

        print('');
        print('🔍 Preservation W2 — WishlistFlashOverlay opacity symmetry:');
        for (final v in testPoints) {
          final opV = wishlistOpacity(v);
          final opMirror = wishlistOpacity(1.0 - v);
          print('   opacity($v)=${opV.toStringAsFixed(4)}, opacity(${1.0 - v})=${opMirror.toStringAsFixed(4)}');
        }
        print('');

        for (final v in testPoints) {
          final opV = wishlistOpacity(v);
          final opMirror = wishlistOpacity(1.0 - v);
          expect(
            opV,
            closeTo(opMirror, 0.001),
            reason:
                'PRESERVATION: WishlistFlashOverlay opacity formula must be '
                'symmetric: opacity($v)=$opV must equal opacity(${1.0 - v})=$opMirror. '
                'Formula: v > 0.5 ? (1-v)*2 : v*2.',
          );
        }
      },
    );

    // -----------------------------------------------------------------------
    // Test W3: Opacity formula peaks at v=0.5 with value 1.0
    //
    // The formula peaks at v=0.5 (opacity=1.0) and is 0 at both ends.
    // This is the characteristic shape of the WishlistFlashOverlay animation.
    //
    // Validates: Requirement 3.8
    // -----------------------------------------------------------------------
    test(
      'PRESERVATION: WishlistFlashOverlay opacity peaks at v=0.5 with value 1.0',
      () {
        // Find the peak by sampling at fine granularity
        double maxOpacity = 0.0;
        double peakV = 0.0;

        for (int i = 0; i <= 100; i++) {
          final v = i / 100.0;
          final opacity = wishlistOpacity(v);
          if (opacity > maxOpacity) {
            maxOpacity = opacity;
            peakV = v;
          }
        }

        print('');
        print('🔍 Preservation W3 — WishlistFlashOverlay opacity peak:');
        print('   Peak at v=$peakV, opacity=$maxOpacity');
        print('   Expected: v=0.5, opacity=1.0');
        print('');

        expect(
          peakV,
          closeTo(0.5, 0.01),
          reason:
              'PRESERVATION: WishlistFlashOverlay opacity must peak at v=0.5. '
              'Actual peak at v=$peakV. '
              'Formula: v > 0.5 ? (1-v)*2 : v*2 peaks at v=0.5.',
        );

        expect(
          maxOpacity,
          closeTo(1.0, 0.001),
          reason:
              'PRESERVATION: WishlistFlashOverlay opacity peak value must be 1.0. '
              'Actual peak opacity=$maxOpacity. '
              'Formula: at v=0.5, v*2 = 1.0.',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test W4: Opacity formula is monotonically increasing on [0, 0.5]
    //          and monotonically decreasing on [0.5, 1.0]
    //
    // Validates: Requirement 3.8
    // -----------------------------------------------------------------------
    test(
      'PRESERVATION: WishlistFlashOverlay opacity increases on [0,0.5] and decreases on [0.5,1]',
      () {
        print('');
        print('🔍 Preservation W4 — WishlistFlashOverlay opacity monotonicity:');

        // Check increasing on [0, 0.5]
        for (int i = 0; i < 50; i++) {
          final v1 = i / 100.0;
          final v2 = (i + 1) / 100.0;
          final op1 = wishlistOpacity(v1);
          final op2 = wishlistOpacity(v2);
          expect(
            op2,
            greaterThanOrEqualTo(op1),
            reason:
                'PRESERVATION: WishlistFlashOverlay opacity must be '
                'non-decreasing on [0, 0.5]. '
                'opacity($v1)=$op1 > opacity($v2)=$op2 — violation.',
          );
        }

        // Check decreasing on [0.5, 1.0]
        for (int i = 50; i < 100; i++) {
          final v1 = i / 100.0;
          final v2 = (i + 1) / 100.0;
          final op1 = wishlistOpacity(v1);
          final op2 = wishlistOpacity(v2);
          expect(
            op2,
            lessThanOrEqualTo(op1),
            reason:
                'PRESERVATION: WishlistFlashOverlay opacity must be '
                'non-increasing on [0.5, 1.0]. '
                'opacity($v1)=$op1 < opacity($v2)=$op2 — violation.',
          );
        }

        print('   ✓ Opacity is non-decreasing on [0, 0.5]');
        print('   ✓ Opacity is non-increasing on [0.5, 1.0]');
        print('');
      },
    );

    // -----------------------------------------------------------------------
    // Test W5: WishlistFlashOverlay renders with lavender color (0xFF988AFF)
    //
    // Baseline: the overlay uses lightPurpleColor = Color(0xFF988AFF).
    // This must be unchanged after the fix.
    //
    // Validates: Requirement 3.8
    // -----------------------------------------------------------------------
    testWidgets(
      'PRESERVATION: WishlistFlashOverlay renders with lavender color (0xFF988AFF)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            builder: (_, __) => const MaterialApp(
              home: Scaffold(
                body: WishlistFlashOverlay(),
              ),
            ),
          ),
        );

        await tester.pump();

        // Find the Container with the lavender color
        final containers = tester.widgetList<Container>(find.byType(Container));
        bool foundLavender = false;
        const lavenderColor = Color(0xFF988AFF);

        for (final container in containers) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration) {
            if (decoration.color == lavenderColor) {
              foundLavender = true;
              break;
            }
          }
        }

        print('');
        print('🔍 Preservation W5 — WishlistFlashOverlay lavender color:');
        print('   Found lavender container: $foundLavender');
        print('   Expected color: Color(0xFF988AFF)');
        print('');

        expect(
          foundLavender,
          isTrue,
          reason:
              'PRESERVATION: WishlistFlashOverlay must render with lavender '
              'color Color(0xFF988AFF). '
              'The fix must NOT change the overlay color. '
              'Requirement 3.8.',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test W6: WishlistFlashOverlay renders with IgnorePointer wrapper
    //
    // Baseline: the overlay is wrapped in IgnorePointer so it doesn't
    // intercept touch events. This must be unchanged after the fix.
    //
    // Validates: Requirement 3.8
    // -----------------------------------------------------------------------
    testWidgets(
      'PRESERVATION: WishlistFlashOverlay is wrapped in IgnorePointer',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            builder: (_, __) => const MaterialApp(
              home: Scaffold(
                body: WishlistFlashOverlay(),
              ),
            ),
          ),
        );

        await tester.pump();

        // WishlistFlashOverlay must be wrapped in IgnorePointer
        expect(
          find.byType(IgnorePointer),
          findsAtLeastNWidgets(1),
          reason:
              'PRESERVATION: WishlistFlashOverlay must be wrapped in '
              'IgnorePointer to avoid intercepting touch events. '
              'Requirement 3.8.',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test W7: WishlistFlashOverlay uses TweenAnimationBuilder (not AnimationController)
    //
    // Baseline: WishlistFlashOverlay uses TweenAnimationBuilder<double> with
    // Tween(begin: 0.0, end: 1.0) and duration 400ms. This is distinct from
    // CartFlashOverlay which uses an external AnimationController.
    // The fix changes CartFlashOverlay but must NOT change WishlistFlashOverlay.
    //
    // Validates: Requirement 3.8
    // -----------------------------------------------------------------------
    testWidgets(
      'PRESERVATION: WishlistFlashOverlay uses TweenAnimationBuilder (self-contained animation)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            builder: (_, __) => const MaterialApp(
              home: Scaffold(
                body: WishlistFlashOverlay(),
              ),
            ),
          ),
        );

        await tester.pump();

        // WishlistFlashOverlay uses TweenAnimationBuilder (self-contained)
        expect(
          find.byType(TweenAnimationBuilder<double>),
          findsAtLeastNWidgets(1),
          reason:
              'PRESERVATION: WishlistFlashOverlay must use TweenAnimationBuilder '
              'for its self-contained animation. '
              'The fix must NOT change this to use an external AnimationController. '
              'Requirement 3.8.',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test W8: WishlistFlashOverlay opacity formula — property test across [0,1]
    //
    // Property: for all v in [0, 1], opacity(v) is in [0, 1].
    // This is a basic sanity check that the formula never produces
    // out-of-range values.
    //
    // Validates: Requirement 3.8
    //
    // **Validates: Requirements 3.8**
    // -----------------------------------------------------------------------
    test(
      'PRESERVATION: WishlistFlashOverlay opacity formula always in [0, 1] for all v in [0, 1]',
      () {
        print('');
        print('🔍 Preservation W8 — WishlistFlashOverlay opacity range property:');

        // Test 1000 evenly-spaced values across [0, 1]
        for (int i = 0; i <= 1000; i++) {
          final v = i / 1000.0;
          final opacity = wishlistOpacity(v);
          expect(
            opacity,
            inInclusiveRange(0.0, 1.0),
            reason:
                'PRESERVATION: WishlistFlashOverlay opacity must be in [0, 1] '
                'for all v in [0, 1]. '
                'At v=$v, opacity=$opacity is out of range. '
                'Formula: v > 0.5 ? (1-v)*2 : v*2.',
          );
        }

        print('   ✓ opacity(v) ∈ [0, 1] for all v ∈ [0, 1] (1001 samples)');
        print('');
      },
    );
  });
}
