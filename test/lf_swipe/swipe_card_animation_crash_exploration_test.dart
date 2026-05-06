// ignore_for_file: avoid_print
//
// Bug Condition Exploration Test — Task 1, Animation Controller Lifecycle Crash
// Swipe-Up Animation Completes Without Crash
//
// PURPOSE: This test MUST FAIL on unfixed code.
// Failure confirms the animation controller lifecycle bug exists:
//   When a swipe-up gesture is performed and the card is removed from the tree
//   during the animation, animation controllers remain active with pending Tickers.
//   These Tickers attempt to update the disposed widget, causing Flutter to throw
//   lifecycle assertion errors like:
//   - "SwipeCardState#XXXXX(tickers: tracking 1 ticker) was disposed with an active Ticker"
//   - "Failed assertion: line 5340 pos 12: '_lifecycleState != _ElementLifecycle.defunct'"
//   - "setState() called after dispose()"
//
// DO NOT fix the code to make this test pass.
// When the fix is applied (Task 3), this test will pass.
//
// Validates: Requirements 2.1, 2.2, 2.3, 2.6

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
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    'Animation Controller Lifecycle Crash — Swipe-Up Animation (EXPECTED TO FAIL on unfixed code)',
    () {
      // -----------------------------------------------------------------------
      // Test 1.1: Swipe-up animation completes without FlutterError
      //
      // Bug condition: When triggerFlyUp() is called, a temporary flyUpController
      // is created and animated. If this controller is not properly disposed after
      // the animation completes, or if animation listeners call setState() on an
      // unmounted widget, Flutter will throw lifecycle errors.
      //
      // Expected (fixed): Animation completes without throwing any FlutterError
      // Actual (unfixed): FlutterError thrown with "disposed with an active Ticker"
      //
      // Validates: Requirements 2.1, 2.2, 2.3, 2.6
      // -----------------------------------------------------------------------
      testWidgets(
        'EXPLORATION: triggerFlyUp() animation completes without FlutterError '
        '— EXPECTED TO FAIL on unfixed code (confirms animation controller leak)',
        (tester) async {
          _suppressOverflowErrors();
          await tester.binding.setSurfaceSize(const Size(400, 800));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          String? caughtErrorMessage;
          final originalOnError = FlutterError.onError;

          // Capture any FlutterErrors that occur during the test
          FlutterError.onError = (FlutterErrorDetails details) {
            final errorStr = details.exceptionAsString();
            // Only capture lifecycle-related errors, not layout overflow
            if (errorStr.contains('Ticker') ||
                errorStr.contains('disposed') ||
                errorStr.contains('setState') ||
                errorStr.contains('defunct')) {
              caughtErrorMessage = errorStr;
              print('🔴 FlutterError caught: $errorStr');
            }
          };
          addTearDown(() => FlutterError.onError = originalOnError);

          bool swipeUpTriggered = false;
          final cardKey = GlobalKey<SwipeCardState>();

          await tester.pumpWidget(
            ScreenUtilInit(
              designSize: const Size(390, 844),
              minTextAdapt: true,
              builder: (_, __) => MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: 390,
                      height: 700,
                      child: SwipeCard(
                        key: cardKey,
                        product: _makeProduct(),
                        isTop: true,
                        scale: 1.0,
                        verticalOffset: 0.0,
                        onSwiped: (action) {
                          if (action == SwipeAction.swipeUp) {
                            swipeUpTriggered = true;
                          }
                        },
                        onSwipeUpFlyUp: () {
                          // Simulate the controller calling triggerFlyUp() on success
                          cardKey.currentState?.triggerFlyUp();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          // ── Act: Simulate swipe-up gesture ────────────────────────────────
          final cardFinder = find.byType(SwipeCard);
          expect(cardFinder, findsOneWidget);
          final cardCenter = tester.getCenter(cardFinder);

          // Perform swipe-up gesture (dy = -80, exceeds threshold of 60)
          final gesture = await tester.startGesture(cardCenter);
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump();
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump();
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump();
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump();
          await gesture.up();
          await tester.pump();

          // Verify swipe-up was triggered
          expect(
            swipeUpTriggered,
            isTrue,
            reason: 'Swipe-up gesture (dy=-80) should trigger SwipeAction.swipeUp',
          );

          // ── Act: Trigger the fly-up animation ────────────────────────────
          cardKey.currentState?.triggerFlyUp();
          await tester.pump();

          // ── Act: Let the animation run for a bit ─────────────────────────
          // The fly-up animation duration is 300ms. We pump several frames
          // to let the animation progress.
          for (int i = 0; i < 5; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }

          // ── Assert ────────────────────────────────────────────────────────
          print('');
          print('🔍 Animation Controller Lifecycle Crash Counterexample:');
          print('   Gesture: swipe-up (dy = -80)');
          print('   Action: triggerFlyUp() called');
          print('   Animation duration: 300ms');
          print('   FlutterError caught: $caughtErrorMessage');
          print('');
          print('   Expected (fixed):  No FlutterError thrown');
          print('   Actual (unfixed):  FlutterError thrown with:');
          print('                      "disposed with an active Ticker"');
          print('                      OR "setState() called after dispose()"');
          print('');
          print('   Root causes:');
          print('   1. Animation controllers not disposed in dispose()');
          print('   2. Temporary flyUpController not disposed after animation');
          print('   3. Animation listeners call setState() without mounted check');
          print('   4. Animation callbacks not cancelled when widget removed');
          print('');

          // CRITICAL ASSERTION (EXPECTED TO FAIL on unfixed code):
          // No FlutterError should be thrown when the animation completes.
          expect(
            caughtErrorMessage,
            isNull,
            reason:
                'BUG CONFIRMED: FlutterError thrown during swipe-up animation. '
                'Counterexample: triggerFlyUp() animation. '
                'Error: $caughtErrorMessage. '
                'The animation controller is not properly disposed, leaving '
                'active Tickers that attempt to update the disposed widget. '
                'Root causes: '
                '1. Animation controllers (_flyController, _resetController) '
                '   not disposed in dispose() method. '
                '2. Temporary flyUpController in triggerFlyUp() not disposed '
                '   after animation completes. '
                '3. Animation listeners call setState() without checking mounted. '
                '4. Animation callbacks not cancelled when widget is removed. '
                'Fix required: '
                '1. Add _flyController.dispose() and _resetController.dispose() '
                '   in dispose() method. '
                '2. Ensure temporary flyUpController is disposed in .then() '
                '   callback after forward(). '
                '3. Add mounted checks before setState() in all listeners. '
                '4. Add mounted checks in animation completion callbacks.',
          );
        },
      );

      // -----------------------------------------------------------------------
      // Test 1.2: Reset animation completes without FlutterError
      //
      // Bug condition: When resetSwipeUp() is called, the _resetController
      // animation runs. The animation listener will try to call setState()
      // on the widget, and if the widget is disposed, it will cause a FlutterError.
      //
      // Expected (fixed): Animation completes without throwing any FlutterError
      // Actual (unfixed): FlutterError thrown with "setState() called after dispose()"
      //
      // Validates: Requirements 2.4, 2.6
      // -----------------------------------------------------------------------
      testWidgets(
        'EXPLORATION: resetSwipeUp() animation completes without FlutterError '
        '— EXPECTED TO FAIL on unfixed code (confirms reset animation listener leak)',
        (tester) async {
          _suppressOverflowErrors();
          await tester.binding.setSurfaceSize(const Size(400, 800));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          String? caughtErrorMessage;
          final originalOnError = FlutterError.onError;

          FlutterError.onError = (FlutterErrorDetails details) {
            final errorStr = details.exceptionAsString();
            if (errorStr.contains('Ticker') ||
                errorStr.contains('disposed') ||
                errorStr.contains('setState') ||
                errorStr.contains('defunct')) {
              caughtErrorMessage = errorStr;
              print('🔴 FlutterError caught: $errorStr');
            }
          };
          addTearDown(() => FlutterError.onError = originalOnError);

          bool swipeUpTriggered = false;
          final cardKey = GlobalKey<SwipeCardState>();

          await tester.pumpWidget(
            ScreenUtilInit(
              designSize: const Size(390, 844),
              minTextAdapt: true,
              builder: (_, __) => MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: 390,
                      height: 700,
                      child: SwipeCard(
                        key: cardKey,
                        product: _makeProduct(),
                        isTop: true,
                        scale: 1.0,
                        verticalOffset: 0.0,
                        onSwiped: (action) {
                          if (action == SwipeAction.swipeUp) {
                            swipeUpTriggered = true;
                          }
                        },
                        onSwipeUpReset: () {
                          // Simulate the controller calling resetSwipeUp() on dismiss
                          cardKey.currentState?.resetSwipeUp();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          // ── Act: Simulate swipe-up gesture ────────────────────────────────
          final cardFinder = find.byType(SwipeCard);
          final cardCenter = tester.getCenter(cardFinder);

          final gesture = await tester.startGesture(cardCenter);
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump();
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump();
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump();
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump();
          await gesture.up();
          await tester.pump();

          expect(swipeUpTriggered, isTrue);

          // ── Act: Trigger the reset animation ─────────────────────────────
          cardKey.currentState?.resetSwipeUp();
          await tester.pump();

          // ── Act: Let the animation run for a bit ─────────────────────────
          // The reset animation duration is 420ms. We pump several frames.
          for (int i = 0; i < 5; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }

          // ── Assert ────────────────────────────────────────────────────────
          print('');
          print('🔍 Reset Animation Listener Lifecycle Crash Counterexample:');
          print('   Gesture: swipe-up (dy = -80)');
          print('   Action: resetSwipeUp() called');
          print('   Animation duration: 420ms');
          print('   FlutterError caught: $caughtErrorMessage');
          print('');
          print('   Expected (fixed):  No FlutterError thrown');
          print('   Actual (unfixed):  FlutterError thrown with:');
          print('                      "setState() called after dispose()"');
          print('');
          print('   Root cause:');
          print('   _resetController listener calls setState() without mounted check');
          print('');

          expect(
            caughtErrorMessage,
            isNull,
            reason:
                'BUG CONFIRMED: FlutterError thrown during resetSwipeUp() animation. '
                'Counterexample: resetSwipeUp() animation. '
                'Error: $caughtErrorMessage. '
                'The _resetController listener calls setState() without checking '
                'if the widget is mounted. '
                'Fix required: Add mounted check in _resetController listener.',
          );
        },
      );

      // -----------------------------------------------------------------------
      // Test 1.3: Animation controllers are properly disposed
      //
      // This test verifies that animation controllers are disposed by checking
      // that the dispose() method is called and no Tickers remain active.
      //
      // Expected (fixed): Animation controllers disposed, no active Tickers
      // Actual (unfixed): Animation controllers not disposed, Tickers active
      //
      // Validates: Requirements 2.2, 2.3
      // -----------------------------------------------------------------------
      testWidgets(
        'EXPLORATION: animation controllers are disposed after widget removal '
        '— EXPECTED TO FAIL on unfixed code (confirms controller not disposed)',
        (tester) async {
          _suppressOverflowErrors();
          await tester.binding.setSurfaceSize(const Size(400, 800));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          String? caughtErrorMessage;
          final originalOnError = FlutterError.onError;

          FlutterError.onError = (FlutterErrorDetails details) {
            final errorStr = details.exceptionAsString();
            if (errorStr.contains('Ticker') ||
                errorStr.contains('disposed') ||
                errorStr.contains('setState') ||
                errorStr.contains('defunct')) {
              caughtErrorMessage = errorStr;
              print('🔴 FlutterError caught: $errorStr');
            }
          };
          addTearDown(() => FlutterError.onError = originalOnError);

          bool showCard = true;
          final cardKey = GlobalKey<SwipeCardState>();

          await tester.pumpWidget(
            StatefulBuilder(
              builder: (context, setState) => ScreenUtilInit(
                designSize: const Size(390, 844),
                minTextAdapt: true,
                builder: (_, __) => MaterialApp(
                  home: Scaffold(
                    body: Center(
                      child: SizedBox(
                        width: 390,
                        height: 700,
                        child: showCard
                            ? SwipeCard(
                                key: cardKey,
                                product: _makeProduct(),
                                isTop: true,
                                scale: 1.0,
                                verticalOffset: 0.0,
                                onSwiped: (_) {},
                                onSwipeUpFlyUp: () {
                                  cardKey.currentState?.triggerFlyUp();
                                  // Remove card after triggering animation
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () => setState(() => showCard = false),
                                  );
                                },
                              )
                            : Container(color: Colors.grey[200]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          // ── Act: Simulate swipe-up gesture ────────────────────────────────
          final cardFinder = find.byType(SwipeCard);
          final cardCenter = tester.getCenter(cardFinder);

          final gesture = await tester.startGesture(cardCenter);
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump();
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump();
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump();
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump();
          await gesture.up();
          await tester.pump();

          // ── Act: Let animations and widget removal complete ──────────────
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // ── Assert ────────────────────────────────────────────────────────
          print('');
          print('🔍 Animation Controller Disposal Counterexample:');
          print('   Gesture: swipe-up (dy = -80)');
          print('   Action: triggerFlyUp() called, then card removed');
          print('   FlutterError caught: $caughtErrorMessage');
          print('');
          print('   Expected (fixed):  No FlutterError thrown');
          print('   Actual (unfixed):  FlutterError thrown with:');
          print('                      "disposed with an active Ticker"');
          print('');
          print('   Root cause:');
          print('   Animation controllers not disposed in dispose() method');
          print('');

          expect(
            caughtErrorMessage,
            isNull,
            reason:
                'BUG CONFIRMED: FlutterError thrown when card is removed. '
                'Counterexample: triggerFlyUp() animation with card removal. '
                'Error: $caughtErrorMessage. '
                'Animation controllers are not disposed when the widget is removed. '
                'Fix required: Add dispose() calls for animation controllers.',
          );
        },
      );
    },
  );
}
