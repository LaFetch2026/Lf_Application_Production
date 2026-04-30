// ignore_for_file: avoid_print
//
// Preservation Property Tests — Task 2, Non-Swipe-Up Gestures
//
// PURPOSE: These tests MUST PASS on unfixed code.
// They establish the regression baseline for non-swipe-up gesture behavior.
// After the fix is applied (Task 3), these same tests are re-run (Task 3.8)
// to confirm no regressions were introduced.
//
// Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8

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
// Helper: build a minimal app with a SwipeCard
// ---------------------------------------------------------------------------

Widget _buildTestApp({
  required void Function(SwipeAction action) onSwiped,
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
            ),
          ),
        ),
      ),
    ),
  );
}

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
// Helper: extract the drag-translation offset from the widget tree.
//
// SwipeCard renders as:
//   Transform.translate(offset: drag)   ← outermost for top card
//     Transform.translate(offset: Offset(0, verticalOffset))
//       Transform.scale(scale: scale)
//         Transform.rotate(angle: rotation)
//           [card content]
//
// We find the outermost Transform.translate (the drag one) by looking for
// the Transform widget whose offset is NOT (0, verticalOffset) and NOT
// a rotation/scale transform.
// ---------------------------------------------------------------------------

Offset _getDragOffset(WidgetTester tester) {
  final transforms = tester.widgetList<Transform>(find.byType(Transform));

  for (final t in transforms) {
    final matrix = t.transform;
    final isTranslation = matrix.entry(0, 0) == 1.0 &&
        matrix.entry(1, 1) == 1.0 &&
        matrix.entry(2, 2) == 1.0 &&
        matrix.entry(3, 3) == 1.0 &&
        matrix.entry(0, 1) == 0.0 &&
        matrix.entry(1, 0) == 0.0;

    if (isTranslation) {
      final tx = matrix.entry(0, 3);
      final ty = matrix.entry(1, 3);
      if (ty != 0.0 || tx != 0.0) {
        return Offset(tx, ty);
      }
    }
  }
  return Offset.zero;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Preservation — Non-Swipe-Up Gestures (MUST PASS on unfixed code)', () {
    // -----------------------------------------------------------------------
    // Test P1: Left swipe (dx < -80) triggers SwipeAction.dislikeProduct
    //
    // Baseline: left swipe fires _flyOff with SwipeAction.dislikeProduct.
    // This behavior must be unchanged after the fix.
    //
    // Validates: Requirement 3.1
    // -----------------------------------------------------------------------
    testWidgets(
      'PRESERVATION: left swipe (dx=-100) triggers SwipeAction.dislikeProduct',
      (tester) async {
        _suppressOverflowErrors();
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SwipeAction? capturedAction;

        await tester.pumpWidget(
          _buildTestApp(onSwiped: (action) => capturedAction = action),
        );
        await tester.pump();

        final cardFinder = find.byType(SwipeCard);
        expect(cardFinder, findsOneWidget);
        final cardCenter = tester.getCenter(cardFinder);

        // Simulate left swipe: dx = -100 (exceeds _horizontalThreshold = 80)
        // dy = 0 so horizontal is dominant
        final gesture = await tester.startGesture(cardCenter);
        await tester.pump();

        // Move left in increments
        await gesture.moveBy(const Offset(-25, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(-25, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(-25, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(-25, 0));
        await tester.pump();

        // End gesture — triggers _onPanEnd → _flyOff(dislikeProduct, Offset(-400, 0))
        await gesture.up();
        await tester.pump();
        await tester.pumpAndSettle();

        print('');
        print('🔍 Preservation P1 — Left swipe:');
        print('   capturedAction: $capturedAction');
        print('   Expected: SwipeAction.dislikeProduct');
        print('');

        // PRESERVATION ASSERTION: must pass on both unfixed and fixed code
        expect(
          capturedAction,
          equals(SwipeAction.dislikeProduct),
          reason:
              'PRESERVATION: left swipe (dx=-100) must trigger '
              'SwipeAction.dislikeProduct via _flyOff. '
              'This behavior must be unchanged after the fix. '
              'Requirement 3.1.',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test P2: Right swipe (dx > 80) triggers SwipeAction.likeProduct
    //
    // Baseline: right swipe fires _flyOff with SwipeAction.likeProduct.
    // This behavior must be unchanged after the fix.
    //
    // Validates: Requirement 3.2
    // -----------------------------------------------------------------------
    testWidgets(
      'PRESERVATION: right swipe (dx=100) triggers SwipeAction.likeProduct',
      (tester) async {
        _suppressOverflowErrors();
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SwipeAction? capturedAction;

        await tester.pumpWidget(
          _buildTestApp(onSwiped: (action) => capturedAction = action),
        );
        await tester.pump();

        final cardFinder = find.byType(SwipeCard);
        expect(cardFinder, findsOneWidget);
        final cardCenter = tester.getCenter(cardFinder);

        // Simulate right swipe: dx = 100 (exceeds _horizontalThreshold = 80)
        final gesture = await tester.startGesture(cardCenter);
        await tester.pump();

        await gesture.moveBy(const Offset(25, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(25, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(25, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(25, 0));
        await tester.pump();

        await gesture.up();
        await tester.pump();
        await tester.pumpAndSettle();

        print('');
        print('🔍 Preservation P2 — Right swipe:');
        print('   capturedAction: $capturedAction');
        print('   Expected: SwipeAction.likeProduct');
        print('');

        // PRESERVATION ASSERTION
        expect(
          capturedAction,
          equals(SwipeAction.likeProduct),
          reason:
              'PRESERVATION: right swipe (dx=100) must trigger '
              'SwipeAction.likeProduct via _flyOff. '
              'This behavior must be unchanged after the fix. '
              'Requirement 3.2.',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test P3: Left swipe card exits left — drag offset is negative x after fly-off
    //
    // Baseline: after left swipe, the card's Transform offset has negative dx
    // (card is flying off to the left). This confirms _flyOff is animating
    // the card in the correct direction.
    //
    // Validates: Requirement 3.1
    // -----------------------------------------------------------------------
    testWidgets(
      'PRESERVATION: left swipe card exits left — drag offset dx < 0 during fly-off',
      (tester) async {
        _suppressOverflowErrors();
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _buildTestApp(onSwiped: (_) {}),
        );
        await tester.pump();

        final cardFinder = find.byType(SwipeCard);
        final cardCenter = tester.getCenter(cardFinder);

        // Simulate left swipe
        final gesture = await tester.startGesture(cardCenter);
        await gesture.moveBy(const Offset(-25, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(-25, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(-25, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(-25, 0));
        await tester.pump();

        await gesture.up();
        // Pump a single frame to capture the fly-off animation in progress
        await tester.pump(const Duration(milliseconds: 50));

        final flyingOffset = _getDragOffset(tester);

        print('');
        print('🔍 Preservation P3 — Left swipe card exits left:');
        print('   flyingOffset: $flyingOffset');
        print('   Expected: dx < 0 (card moving left)');
        print('');

        // PRESERVATION ASSERTION: card must be moving left
        expect(
          flyingOffset.dx,
          lessThan(0),
          reason:
              'PRESERVATION: after left swipe, card must exit to the left '
              '(drag offset dx < 0 during fly-off animation). '
              'Actual flyingOffset: $flyingOffset. '
              'Requirement 3.1.',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test P4: Swipe-down (dy > 60, vertical dominant) resets _dragOffset to zero
    //
    // Baseline: swipe-down snaps the card back to center (Offset.zero).
    // This behavior must be unchanged after the fix.
    //
    // Validates: Requirement 3.3
    // -----------------------------------------------------------------------
    testWidgets(
      'PRESERVATION: swipe-down (dy=80) resets dragOffset to Offset.zero',
      (tester) async {
        _suppressOverflowErrors();
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SwipeAction? capturedAction;

        await tester.pumpWidget(
          _buildTestApp(onSwiped: (action) => capturedAction = action),
        );
        await tester.pump();

        final cardFinder = find.byType(SwipeCard);
        final cardCenter = tester.getCenter(cardFinder);

        // Simulate swipe-down: dy = +80 (exceeds _verticalThreshold = 60)
        // dy.abs() > dx.abs() so vertical is dominant
        final gesture = await tester.startGesture(cardCenter);
        await tester.pump();

        await gesture.moveBy(const Offset(0, 20));
        await tester.pump();
        await gesture.moveBy(const Offset(0, 20));
        await tester.pump();
        await gesture.moveBy(const Offset(0, 20));
        await tester.pump();
        await gesture.moveBy(const Offset(0, 20));
        await tester.pump();

        await gesture.up();
        await tester.pump();
        await tester.pumpAndSettle();

        final afterOffset = _getDragOffset(tester);

        print('');
        print('🔍 Preservation P4 — Swipe-down:');
        print('   afterOffset: $afterOffset');
        print('   capturedAction: $capturedAction');
        print('   Expected: afterOffset == Offset.zero, action == swipeDown');
        print('');

        // PRESERVATION ASSERTION: drag offset must reset to zero
        expect(
          afterOffset,
          equals(Offset.zero),
          reason:
              'PRESERVATION: swipe-down (dy=80) must reset _dragOffset to '
              'Offset.zero. Card must snap back to center. '
              'Actual afterOffset: $afterOffset. '
              'Requirement 3.3.',
        );

        // PRESERVATION ASSERTION: swipeDown action must be called
        expect(
          capturedAction,
          equals(SwipeAction.swipeDown),
          reason:
              'PRESERVATION: swipe-down (dy=80) must trigger '
              'SwipeAction.swipeDown callback. '
              'Actual capturedAction: $capturedAction. '
              'Requirement 3.3.',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test P5: No-gesture pan release (below thresholds) resets to Offset.zero
    //
    // Baseline: when the user releases a pan gesture that doesn't exceed any
    // threshold, the card snaps back to center (Offset.zero) and no action
    // is called. This behavior must be unchanged after the fix.
    //
    // Validates: Requirement 3.4 (card stays in stack, gestures re-enabled)
    // -----------------------------------------------------------------------
    testWidgets(
      'PRESERVATION: no-gesture pan release (dx=20, dy=20) resets to Offset.zero, no action called',
      (tester) async {
        _suppressOverflowErrors();
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SwipeAction? capturedAction;

        await tester.pumpWidget(
          _buildTestApp(onSwiped: (action) => capturedAction = action),
        );
        await tester.pump();

        final cardFinder = find.byType(SwipeCard);
        final cardCenter = tester.getCenter(cardFinder);

        // Simulate a small pan that doesn't exceed any threshold
        // dx = 20 < 80 (horizontal threshold)
        // dy = 20 < 60 (vertical threshold)
        final gesture = await tester.startGesture(cardCenter);
        await tester.pump();

        await gesture.moveBy(const Offset(10, 10));
        await tester.pump();
        await gesture.moveBy(const Offset(10, 10));
        await tester.pump();

        await gesture.up();
        await tester.pump();
        await tester.pumpAndSettle();

        final afterOffset = _getDragOffset(tester);

        print('');
        print('🔍 Preservation P5 — No-gesture pan release:');
        print('   afterOffset: $afterOffset');
        print('   capturedAction: $capturedAction');
        print('   Expected: afterOffset == Offset.zero, no action called');
        print('');

        // PRESERVATION ASSERTION: drag offset must reset to zero
        expect(
          afterOffset,
          equals(Offset.zero),
          reason:
              'PRESERVATION: pan release below thresholds (dx=20, dy=20) must '
              'reset _dragOffset to Offset.zero. '
              'Actual afterOffset: $afterOffset. '
              'Requirement 3.4.',
        );

        // PRESERVATION ASSERTION: no action should be called
        expect(
          capturedAction,
          isNull,
          reason:
              'PRESERVATION: pan release below thresholds must NOT trigger '
              'any SwipeAction callback. '
              'Actual capturedAction: $capturedAction. '
              'Requirement 3.4.',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test P6: Horizontal swipe (dx > 80) does NOT trigger swipeUp
    //
    // Baseline: when dx.abs() > dy.abs() and dx > 80, the card flies off
    // horizontally — NOT treated as a swipe-up. The _swipeUpLocked flag
    // (added by the fix) must never be set for horizontal swipes.
    //
    // Validates: Requirement 3.1, 3.2 (horizontal swipes unchanged)
    // -----------------------------------------------------------------------
    testWidgets(
      'PRESERVATION: right swipe (dx=100, dy=0) does NOT trigger swipeUp',
      (tester) async {
        _suppressOverflowErrors();
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SwipeAction? capturedAction;

        await tester.pumpWidget(
          _buildTestApp(onSwiped: (action) => capturedAction = action),
        );
        await tester.pump();

        final cardFinder = find.byType(SwipeCard);
        final cardCenter = tester.getCenter(cardFinder);

        // Pure horizontal right swipe
        final gesture = await tester.startGesture(cardCenter);
        await gesture.moveBy(const Offset(25, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(25, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(25, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(25, 0));
        await tester.pump();

        await gesture.up();
        await tester.pump();
        await tester.pumpAndSettle();

        print('');
        print('🔍 Preservation P6 — Right swipe does not trigger swipeUp:');
        print('   capturedAction: $capturedAction');
        print('   Expected: SwipeAction.likeProduct (NOT swipeUp)');
        print('');

        expect(
          capturedAction,
          isNot(equals(SwipeAction.swipeUp)),
          reason:
              'PRESERVATION: right swipe (dx=100) must NOT trigger swipeUp. '
              'Actual capturedAction: $capturedAction. '
              'Requirement 3.2.',
        );

        expect(
          capturedAction,
          equals(SwipeAction.likeProduct),
          reason:
              'PRESERVATION: right swipe (dx=100) must trigger likeProduct. '
              'Actual capturedAction: $capturedAction. '
              'Requirement 3.2.',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test P7: Diagonal swipe where dx.abs() > dy.abs() and dx > 80
    //          is treated as horizontal (likeProduct), not swipeUp
    //
    // Baseline: when horizontal component dominates, the card flies off
    // horizontally even if there is a vertical component.
    //
    // Validates: Requirement 3.2
    // -----------------------------------------------------------------------
    testWidgets(
      'PRESERVATION: diagonal swipe (dx=100, dy=-40) with horizontal dominant → likeProduct',
      (tester) async {
        _suppressOverflowErrors();
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SwipeAction? capturedAction;

        await tester.pumpWidget(
          _buildTestApp(onSwiped: (action) => capturedAction = action),
        );
        await tester.pump();

        final cardFinder = find.byType(SwipeCard);
        final cardCenter = tester.getCenter(cardFinder);

        // Diagonal: dx=100, dy=-40 → dx.abs() > dy.abs() → horizontal dominant
        final gesture = await tester.startGesture(cardCenter);
        await gesture.moveBy(const Offset(25, -10));
        await tester.pump();
        await gesture.moveBy(const Offset(25, -10));
        await tester.pump();
        await gesture.moveBy(const Offset(25, -10));
        await tester.pump();
        await gesture.moveBy(const Offset(25, -10));
        await tester.pump();

        await gesture.up();
        await tester.pump();
        await tester.pumpAndSettle();

        print('');
        print('🔍 Preservation P7 — Diagonal swipe (horizontal dominant):');
        print('   capturedAction: $capturedAction');
        print('   Expected: SwipeAction.likeProduct');
        print('');

        expect(
          capturedAction,
          equals(SwipeAction.likeProduct),
          reason:
              'PRESERVATION: diagonal swipe (dx=100, dy=-40) with horizontal '
              'dominant must trigger likeProduct, not swipeUp. '
              'Actual capturedAction: $capturedAction. '
              'Requirement 3.2.',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test P8: Swipe-down below threshold (dy=30) does NOT trigger swipeDown
    //
    // Baseline: a small downward pan that doesn't exceed the vertical threshold
    // (60 px) must not trigger swipeDown — card snaps back to center.
    //
    // Validates: Requirement 3.3
    // -----------------------------------------------------------------------
    testWidgets(
      'PRESERVATION: small downward pan (dy=30) below threshold → no action, resets to zero',
      (tester) async {
        _suppressOverflowErrors();
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SwipeAction? capturedAction;

        await tester.pumpWidget(
          _buildTestApp(onSwiped: (action) => capturedAction = action),
        );
        await tester.pump();

        final cardFinder = find.byType(SwipeCard);
        final cardCenter = tester.getCenter(cardFinder);

        // dy = 30 < 60 (vertical threshold) — should not trigger swipeDown
        final gesture = await tester.startGesture(cardCenter);
        await gesture.moveBy(const Offset(0, 15));
        await tester.pump();
        await gesture.moveBy(const Offset(0, 15));
        await tester.pump();

        await gesture.up();
        await tester.pump();
        await tester.pumpAndSettle();

        final afterOffset = _getDragOffset(tester);

        print('');
        print('🔍 Preservation P8 — Small downward pan below threshold:');
        print('   afterOffset: $afterOffset');
        print('   capturedAction: $capturedAction');
        print('   Expected: Offset.zero, no action');
        print('');

        expect(
          afterOffset,
          equals(Offset.zero),
          reason:
              'PRESERVATION: small downward pan (dy=30) below threshold must '
              'reset to Offset.zero. Actual: $afterOffset.',
        );

        expect(
          capturedAction,
          isNull,
          reason:
              'PRESERVATION: small downward pan (dy=30) below threshold must '
              'NOT trigger any action. Actual: $capturedAction.',
        );
      },
    );
  });
}
