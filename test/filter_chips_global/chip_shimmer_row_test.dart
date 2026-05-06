// Feature: filter-chips-global, Task 1.1: Unit tests for ChipShimmerRow
//
// Validates: Requirements 3.2, 3.3
//
// Verifies that ChipShimmerRow:
//   - renders with a fixed height of 36 px
//   - contains exactly 4 shimmer placeholder items

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lafetch/common/widget/other/chip_shimmer_row.dart';

void main() {
  Widget buildTestWidget() {
    return const MaterialApp(
      home: Scaffold(
        body: ChipShimmerRow(),
      ),
    );
  }

  group('ChipShimmerRow', () {
    testWidgets('renders with a fixed height of 36 px', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // The outermost SizedBox constrains height to 36
      final sizedBoxFinder = find.descendant(
        of: find.byType(ChipShimmerRow),
        matching: find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 36,
        ),
      );
      expect(
        sizedBoxFinder,
        findsAtLeastNWidgets(1),
        reason: 'ChipShimmerRow must have a SizedBox with height 36',
      );
    });

    testWidgets('contains exactly 4 Shimmer.fromColors placeholders',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Each placeholder is wrapped in a Shimmer widget
      final shimmerFinder = find.descendant(
        of: find.byType(ChipShimmerRow),
        matching: find.byType(Shimmer),
      );
      expect(
        shimmerFinder,
        findsNWidgets(4),
        reason: 'ChipShimmerRow must render exactly 4 shimmer placeholders',
      );
    });

    testWidgets('each placeholder is pill-shaped (borderRadius 999)',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Each shimmer child is a Container with circular border radius
      final pillFinder = find.descendant(
        of: find.byType(ChipShimmerRow),
        matching: find.byWidgetPredicate((widget) {
          if (widget is Container) {
            final decoration = widget.decoration;
            if (decoration is BoxDecoration) {
              final radius = decoration.borderRadius;
              return radius == BorderRadius.circular(999);
            }
          }
          return false;
        }),
      );
      expect(
        pillFinder,
        findsNWidgets(4),
        reason: 'Each placeholder must be pill-shaped with borderRadius 999',
      );
    });

    testWidgets('uses horizontal scroll direction', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final listViewFinder = find.descendant(
        of: find.byType(ChipShimmerRow),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is ListView &&
              widget.scrollDirection == Axis.horizontal,
        ),
      );
      expect(
        listViewFinder,
        findsOneWidget,
        reason: 'ChipShimmerRow must use a horizontal ListView',
      );
    });
  });
}
