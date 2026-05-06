// ignore_for_file: avoid_print
//
// Bug Condition Exploration Test — Task 1
// Swipe-Up Animation Controller Crash
//
// PURPOSE: This test MUST FAIL on unfixed code.
// Failure confirms the bug exists:
//   When a user swipes a product up to add it to cart, animation controllers
//   (Tickers) remain active after the SwipeCardState widget is disposed,
//   causing Flutter to throw lifecycle assertion errors:
//   "SwipeCardState#XXXXX(tickers: tracking 1 ticker) was disposed with an active Ticker"
//
// DO NOT fix the code to make this test pass.
// When the fix is applied (Task 3), this test will pass.
//
// Validates: Requirements 1.1, 1.2, 1.3, 1.5, 2.1, 2.2, 2.3, 2.6

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafetch/lf_swipe/models/swipe_product.dart';
import 'package:lafetch/lf_swipe/services/swipe_tracking_service.dart';
import 'package:lafetch/lf_swipe/widgets/swipe_card.dart';

// ---------------------------------------------------------------------------
// Minimal SwipeProduct factory
// ---------------------------------------------------------------------------

SwipeProduct _makeProduct() => const SwipeProduct(
      id: 1,
      productName: 'Test Product',
      brandName: 'Test Brand',
      sellingPrice: 999.0,
      mrp: 1499.0,
      imageUrl: '',
      imageUrls: [],
      category: 'Tops',
      slug: 'test-product',
      isNew: false,
      rating: null,
      numReviews: null,
      sizes: [],
      tags: [],
    );

// ---------------------------------------------------------------------------
// Helper: suppress RenderFlex overflow errors in test environment.
// ---------------------------------------------------------------------------

void _suppressOverflowErrors() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('RenderFlex overflowed')) {
      return;
    }
    originalOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = originalOnError);
}

// ---------------------------------------------------------------------------
// Helper: build a minimal app with a SwipeCard
// ---------------------------------------------------------------------------

Widget _buildTestApp({
  required void Function(SwipeAction action) onSwiped,
  required VoidCallback? onSwipeUpFlyUp,
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (_, __) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 390,
            height: 700,
            child: SwipeCard(
              product: _makeProduct(),
              isTop: true,
              scale: 1.0,
              verticalOffset: 0.0,
              onSwiped: onSwiped,
              onSwipeUpFlyUp: onSwipeUpFlyUp,
            ),
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    'Animation Controller Crash — Swipe-Up Animation Completes Without Crash '
    '(EXPECTED TO FAIL on unfixed code)',
    () {
      // -----------------------------------------------------------------------
      // Test 1: triggerFlyUp() animation completes without FlutterError
      //
      // Bug condition: When triggerFlyUp() is called, a temporary
      // flyUpController is created and animated. If the controller is not
      // disposed after the animation completes, the Ticker remains active
      // and attempts to update the disposed widget, causing:
      // "SwipeCardState#XXXXX(tickers: tracking 1 ticker) was disposed with an active Ticker"
      //
      // Expected (fixed): Animation completes without throwing FlutterError
      // Actual (unfixed): FlutterError thrown about active Ticker
      // -----------------------------------------------------------------------
      testWidgets(
        'EXPLORATION: triggerFlyUp() animation completes without FlutterError '
        '— EXPECTED TO FAIL (confirms animation controller crash)',
        (tester) async {
          _suppressOverflowErrors();
          await tester.binding.setSurfaceSize(const Size(400, 800));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          FlutterError? caughtError;
          final originalOnError = FlutterError.onError;

          // Capture any FlutterError that occurs during the test
          FlutterError.onError = (FlutterErrorDetails details) {
            caughtError = details.exception as FlutterError?;
            print('🔴 FlutterError caught: ${details.exceptionAsString()}');
            originalOnError?.call(details);
          };

          addTearDown(() => FlutterError.onError = originalOnError);

          SwipeCardState? cardState;

          await tester.pumpWidget(
            _buildTestApp(
              onSwiped: (_) {},
              onSwipeUpFlyUp: null,
            ),
          );
          await tester.pump();

          // Get the SwipeCardState instance
          final cardFinder = find.byType(SwipeCard);
          expect(cardFinder, findsOneWidget);

          final state = tester.state<SwipeCardState>(cardFinder);
          cardState = state;

          print('');
          print('🔍 Animation Controller Crash Counterexample:');
          print('   Triggering triggerFlyUp() animation...');
          print('');

          // Trigger the fly-up animation
          cardState?.triggerFlyUp();
          await tester.pump();

          // Wait for the animation to complete (300ms duration + buffer)
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          print('   Animation completed.');
          print('   Checking for FlutterError about active Ticker...');
          print('');

          // ── Assert ────────────────────────────────────────────────────────
          if (caughtError != null) {
            print('🔴 BUG CONFIRMED: FlutterError thrown during animation:');
            print('   ${caughtError.toString()}');
            print('');
            print('   Root cause: Animation controller not disposed after animation completes');
            print('   Expected: No FlutterError thrown');
            print('   Actual: FlutterError about active Ticker');
            print('');
          }

          // CRITICAL ASSERTION (EXPECTED TO FAIL on unfixed code):
          // No FlutterError should be thrown during the animation
          expect(
            caughtError,
            isNull,
            reason:
                'BUG CONFIRMED: FlutterError thrown during swipe-up animation. '
                'Counterexample: triggerFlyUp() animation causes '
                '"disposed with an active Ticker" error. '
                'Root cause: Temporary flyUpController not disposed after animation completes, '
                'or animation listeners call setState() on unmounted widget. '
                'Fix required: Dispose temporary flyUpController in .then() callback, '
                'and add mounted checks before setState() calls.',
          );
        },
      );

      // -----------------------------------------------------------------------
      // Test 2: resetSwipeUp() animation completes without FlutterError
      //
      // Similar to Test 1, but for the resetSwipeUp() animation.
      // The _resetController should be properly disposed and not throw errors.
      // -----------------------------------------------------------------------
      testWidgets(
        'EXPLORATION: resetSwipeUp() animation completes without FlutterError '
        '— EXPECTED TO FAIL on unfixed code',
        (tester) async {
          _suppressOverflowErrors();
          await tester.binding.setSurfaceSize(const Size(400, 800));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          FlutterError? caughtError;
          final originalOnError = FlutterError.onError;

          FlutterError.onError = (FlutterErrorDetails details) {
            caughtError = details.exception as FlutterError?;
            print('🔴 FlutterError caught: ${details.exceptionAsString()}');
            originalOnError?.call(details);
          };

          addTearDown(() => FlutterError.onError = originalOnError);

          SwipeCardState? cardState;

          await tester.pumpWidget(
            _buildTestApp(
              onSwiped: (_) {},
              onSwipeUpFlyUp: null,
            ),
          );
          await tester.pump();

          final cardFinder = find.byType(SwipeCard);
          final state = tester.state<SwipeCardState>(cardFinder);
          cardState = state;

          print('');
          print('🔍 Reset Animation Controller Crash Counterexample:');
          print('   Triggering resetSwipeUp() animation...');
          print('');

          // Trigger the reset animation
          cardState?.resetSwipeUp();
          await tester.pump();

          // Wait for the animation to complete (420ms duration + buffer)
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          print('   Animation completed.');
          print('   Checking for FlutterError about active Ticker...');
          print('');

          // ── Assert ────────────────────────────────────────────────────────
          if (caughtError != null) {
            print('🔴 BUG CONFIRMED: FlutterError thrown during reset animation:');
            print('   ${caughtError.toString()}');
            print('');
            print('   Root cause: Reset animation controller not properly disposed');
            print('   Expected: No FlutterError thrown');
            print('   Actual: FlutterError about active Ticker');
            print('');
          }

          // CRITICAL ASSERTION (EXPECTED TO FAIL on unfixed code):
          // No FlutterError should be thrown during the reset animation
          expect(
            caughtError,
            isNull,
            reason:
                'BUG CONFIRMED: FlutterError thrown during resetSwipeUp() animation. '
                'Counterexample: resetSwipeUp() animation causes '
                '"disposed with an active Ticker" error. '
                'Root cause: _resetController not properly disposed, '
                'or animation listeners call setState() on unmounted widget. '
                'Fix required: Ensure _resetController is disposed in dispose() method, '
                'and add mounted checks before setState() calls in listeners.',
          );
        },
      );

      // -----------------------------------------------------------------------
      // Test 3: Widget disposal with active animation doesn't crash
      //
      // Verify that when the widget is disposed while an animation is running,
      // no FlutterError is thrown about active Tickers.
      // -----------------------------------------------------------------------
      testWidgets(
        'EXPLORATION: widget disposal with active animation completes without FlutterError '
        '— EXPECTED TO FAIL on unfixed code',
        (tester) async {
          _suppressOverflowErrors();
          await tester.binding.setSurfaceSize(const Size(400, 800));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          FlutterError? caughtError;
          final originalOnError = FlutterError.onError;

          FlutterError.onError = (FlutterErrorDetails details) {
            caughtError = details.exception as FlutterError?;
            print('🔴 FlutterError caught: ${details.exceptionAsString()}');
            originalOnError?.call(details);
          };

          addTearDown(() => FlutterError.onError = originalOnError);

          SwipeCardState? cardState;

          await tester.pumpWidget(
            _buildTestApp(
              onSwiped: (_) {},
              onSwipeUpFlyUp: null,
            ),
          );
          await tester.pump();

          final cardFinder = find.byType(SwipeCard);
          final state = tester.state<SwipeCardState>(cardFinder);
          cardState = state;

          print('');
          print('🔍 Widget Disposal with Active Animation Counterexample:');
          print('   Triggering triggerFlyUp() animation...');
          print('');

          // Trigger the fly-up animation
          cardState?.triggerFlyUp();
          await tester.pump();

          print('   Removing widget before animation completes...');
          // Remove the widget before animation completes
          await tester.pumpWidget(
            ScreenUtilInit(
              designSize: const Size(390, 844),
              minTextAdapt: true,
              builder: (_, __) => const MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Text('Widget removed'),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          // Wait for the animation to fire its listener on the unmounted widget
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          print('   Animation listener fired on unmounted widget.');
          print('   Checking for FlutterError about active Ticker...');
          print('');

          // ── Assert ────────────────────────────────────────────────────────
          if (caughtError != null) {
            print('🔴 BUG CONFIRMED: FlutterError thrown when widget is disposed:');
            print('   ${caughtError.toString()}');
            print('');
            print('   Root cause: Animation controllers not disposed before widget removal');
            print('   Expected: No FlutterError thrown');
            print('   Actual: FlutterError about active Ticker');
            print('');
          }

          // CRITICAL ASSERTION (EXPECTED TO FAIL on unfixed code):
          // No FlutterError should be thrown when the widget is disposed
          expect(
            caughtError,
            isNull,
            reason:
                'BUG CONFIRMED: FlutterError thrown when widget is disposed. '
                'Counterexample: After triggerFlyUp() animation and widget removal, '
                '"disposed with an active Ticker" error occurs. '
                'Root cause: Animation controllers (_flyController, _resetController, '
                'or temporary flyUpController) not disposed before widget is removed. '
                'Fix required: Call dispose() on all animation controllers in '
                'SwipeCardState.dispose() method.',
          );
        },
      );
    },
  );
}
