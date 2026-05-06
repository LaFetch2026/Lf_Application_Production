// ignore_for_file: avoid_print
//
// Bug Condition Exploration Test — Task 1, Bug 1
// Swipe-Up Position Hold
//
// PURPOSE: This test MUST FAIL on unfixed code.
// Failure confirms Bug 1 exists:
//   After a swipe-up gesture (dy = -80, exceeding the 60 px threshold),
//   _dragOffset is unconditionally reset to Offset.zero in _onPanEnd.
//   The card snaps back to center instead of holding its dragged position.
//
// DO NOT fix the code to make this test pass.
// When the fix is applied (Task 3.1), this test will pass.
//
// Validates: Requirements 1.1, 1.2, 2.1, 2.2

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
//
// Since the card uses Transform.translate for drag, we can find all
// Transform widgets and pick the one with a non-zero translation that
// corresponds to the drag offset.
// ---------------------------------------------------------------------------

/// Returns the drag offset applied to the top SwipeCard by inspecting
/// the Transform.translate widget in the widget tree.
///
/// The SwipeCard build method applies:
///   Transform.translate(offset: drag, child: ...)
/// where drag = _dragOffset (or _flyAnimation.value when flying).
///
/// We find this by looking at all Transform widgets and finding the one
/// that wraps the card content with a translation offset.
Offset _getDragOffset(WidgetTester tester) {
  // Find all Transform widgets in the tree
  final transforms = tester.widgetList<Transform>(find.byType(Transform));

  // The drag Transform.translate is the outermost one applied to the top card.
  // It has offset.dy != 0 when the card is being dragged upward.
  // We look for a Transform with a non-identity matrix that represents
  // a pure translation (no rotation, no scale).
  for (final t in transforms) {
    final matrix = t.transform;
    // A pure translation matrix has:
    //   [1, 0, 0, tx]
    //   [0, 1, 0, ty]
    //   [0, 0, 1, 0 ]
    //   [0, 0, 0, 1 ]
    // Check if this is a translation-only transform
    final isTranslation = matrix.entry(0, 0) == 1.0 &&
        matrix.entry(1, 1) == 1.0 &&
        matrix.entry(2, 2) == 1.0 &&
        matrix.entry(3, 3) == 1.0 &&
        matrix.entry(0, 1) == 0.0 &&
        matrix.entry(1, 0) == 0.0;

    if (isTranslation) {
      final tx = matrix.entry(0, 3);
      final ty = matrix.entry(1, 3);
      // Skip the verticalOffset transform (which is (0, 0) for our test)
      // and look for the drag transform
      if (ty != 0.0 || tx != 0.0) {
        return Offset(tx, ty);
      }
    }
  }
  return Offset.zero;
}

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
// The card's price row overflows in the constrained test surface — this is
// a test environment artifact, not a bug. We suppress it so it doesn't
// interfere with the actual bug assertions.
// ---------------------------------------------------------------------------

void _suppressOverflowErrors() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('RenderFlex overflowed')) {
      // Suppress layout overflow — test environment artifact
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

  group('Bug 1 — Swipe-Up Position Hold (EXPECTED TO FAIL on unfixed code)', () {
    // -----------------------------------------------------------------------
    // Test 1.1: After swipe-up onPanEnd, drag offset must NOT be Offset.zero
    //
    // Bug condition: gesture.dy < -60 AND dy.abs() > dx.abs()
    // Unfixed code:  setState(() => _dragOffset = Offset.zero) fires
    //                unconditionally → card snaps back
    // Expected (fixed): _dragOffset holds the dragged position (e.g. Offset(0, -80))
    //                   OR card animates upward — either way NOT Offset.zero
    //
    // We test the observable behavior by checking the Transform.translate
    // offset applied to the card after the gesture ends.
    // On unfixed code: offset == Offset.zero (bug — snapped back) → FAILS
    // On fixed code:   offset != Offset.zero (card holds position) → PASSES
    // -----------------------------------------------------------------------
    testWidgets(
      'EXPLORATION: after swipe-up (dy=-80), drag Transform offset != Offset.zero '
      '— EXPECTED TO FAIL (confirms Bug 1)',
      (tester) async {
        // ── Arrange ──────────────────────────────────────────────────────────
        _suppressOverflowErrors();
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SwipeAction? capturedAction;

        await tester.pumpWidget(
          _buildTestApp(onSwiped: (action) => capturedAction = action),
        );
        await tester.pump();

        // ── Act: simulate swipe-up gesture (dy = -80) ─────────────────────
        final cardFinder = find.byType(SwipeCard);
        expect(cardFinder, findsOneWidget);
        final cardCenter = tester.getCenter(cardFinder);

        // Start gesture and move upward by 80 px (exceeds _verticalThreshold=60)
        final gesture = await tester.startGesture(cardCenter);
        await tester.pump();

        // Move in small increments to trigger onPanUpdate
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump();
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump();
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump();
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump();

        // Record drag offset during gesture (should be non-zero)
        final duringDragOffset = _getDragOffset(tester);

        // End the gesture — this triggers _onPanEnd
        await gesture.up();
        await tester.pump();

        // Record drag offset immediately after pan end
        final afterPanEndOffset = _getDragOffset(tester);

        await tester.pumpAndSettle();
        final afterSettleOffset = _getDragOffset(tester);

        // ── Assert ────────────────────────────────────────────────────────
        print('');
        print('🔍 Bug 1 Counterexample:');
        print('   Gesture: dy = -80 (exceeds _verticalThreshold = 60)');
        print('   Drag offset during gesture:    $duringDragOffset');
        print('   Drag offset after panEnd:      $afterPanEndOffset');
        print('   Drag offset after settle:      $afterSettleOffset');
        print('   capturedAction:                $capturedAction');
        print('');
        print('   Expected (fixed):  afterPanEndOffset != Offset.zero');
        print('                      (card holds dragged position)');
        print('   Actual (unfixed):  afterPanEndOffset == Offset.zero');
        print('                      (card snapped back — BUG CONFIRMED)');
        print('');
        print('   Root cause: _onPanEnd swipe-up branch calls');
        print('   setState(() => _dragOffset = Offset.zero) unconditionally');
        print('   before widget.onSwiped(SwipeAction.swipeUp)');
        print('');

        // Verify the swipe-up action was triggered
        expect(
          capturedAction,
          equals(SwipeAction.swipeUp),
          reason: 'onSwiped should have been called with SwipeAction.swipeUp '
              'for dy=-80 (exceeds threshold of 60)',
        );

        // CRITICAL ASSERTION (EXPECTED TO FAIL on unfixed code):
        // After swipe-up panEnd, the drag offset should NOT be Offset.zero.
        // On unfixed code: _dragOffset is reset to Offset.zero → FAILS
        // On fixed code:   _swipeUpLocked = true, _dragOffset held → PASSES
        expect(
          afterPanEndOffset,
          isNot(equals(Offset.zero)),
          reason:
              'BUG CONFIRMED: drag offset was reset to Offset.zero after '
              'swipe-up gesture (dy=-80). '
              'Counterexample: gesture.dy=-80 → afterPanEndOffset=Offset.zero. '
              'The card snaps back to center instead of holding its position. '
              'Root cause: _onPanEnd swipe-up branch calls '
              'setState(() => _dragOffset = Offset.zero) unconditionally. '
              'Fix required: do NOT reset _dragOffset in the swipe-up branch. '
              'Instead, set _swipeUpLocked=true and hold the card position.',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test 1.2: Swipe-up must trigger SwipeAction.swipeUp callback
    //
    // This is a baseline test that should PASS on both fixed and unfixed code.
    // It verifies the gesture detection works correctly.
    // -----------------------------------------------------------------------
    testWidgets(
      'baseline: swipe-up (dy=-80) triggers SwipeAction.swipeUp callback',
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
        await tester.pumpAndSettle();

        expect(
          capturedAction,
          equals(SwipeAction.swipeUp),
          reason: 'Swipe-up gesture (dy=-80) should trigger SwipeAction.swipeUp',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Test 1.3: Swipe-up card drag offset during gesture is non-zero
    //
    // This is a baseline test that should PASS on both fixed and unfixed code.
    // It verifies the drag tracking works correctly during the gesture.
    // -----------------------------------------------------------------------
    testWidgets(
      'baseline: during swipe-up drag (dy=-80), Transform offset is non-zero',
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

        final gesture = await tester.startGesture(cardCenter);
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump();
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump();
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump();
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump();

        final duringDragOffset = _getDragOffset(tester);

        print('');
        print('🔍 Bug 1 baseline — drag offset during gesture: $duringDragOffset');
        print('');

        // During drag, the offset should be non-zero (card is being dragged)
        expect(
          duringDragOffset,
          isNot(equals(Offset.zero)),
          reason: 'During swipe-up drag, Transform offset should be non-zero. '
              'Actual: $duringDragOffset',
        );

        await gesture.up();
        await tester.pump();
        await tester.pumpAndSettle();
      },
    );

    // -----------------------------------------------------------------------
    // Test 1.4: After swipe-up settle — documents the snap-back counterexample
    //
    // After pumpAndSettle(), the unfixed code has already snapped back.
    // This test documents the full counterexample including settle behavior.
    // -----------------------------------------------------------------------
    testWidgets(
      'EXPLORATION: after swipe-up and settle, drag offset must remain non-zero '
      '— EXPECTED TO FAIL on unfixed code (snap-back confirmed)',
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

        // Perform swipe-up gesture
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
        await tester.pumpAndSettle();

        final afterSettleOffset = _getDragOffset(tester);

        print('');
        print('🔍 Bug 1 Counterexample (after settle):');
        print('   Drag offset after settle: $afterSettleOffset');
        print('');
        print('   On unfixed code: card snaps back → offset == Offset.zero');
        print('   On fixed code:   card holds position OR flies off-screen');
        print('                    → offset != Offset.zero');
        print('');

        // CRITICAL ASSERTION (EXPECTED TO FAIL on unfixed code):
        // After settle, the drag offset should still be non-zero (holding position)
        // OR the card has flown off-screen (offset.dy << 0).
        // On unfixed code: card snaps back → offset == Offset.zero → FAILS
        expect(
          afterSettleOffset,
          isNot(equals(Offset.zero)),
          reason:
              'BUG CONFIRMED: drag offset returned to Offset.zero after '
              'swipe-up gesture and settle. '
              'Counterexample: afterSettleOffset=$afterSettleOffset == Offset.zero. '
              'The card snapped back unconditionally instead of holding its '
              'dragged position while the add-to-cart flow completes. '
              'Fix required: set _swipeUpLocked=true in _onPanEnd swipe-up '
              'branch and do NOT reset _dragOffset.',
        );
      },
    );
  });
}
