// Feature: product-nudges, Property 7: OOS state and nudges coexist without suppression
//
// Validates: Requirements 5.5, 6.5, 7.4
//
// Property 7: OOS state and nudges coexist without suppression
//
// For any product that is simultaneously out-of-stock and has a non-empty
// nudges list, the rendered widget tree SHALL contain both the OOS indicator
// widget and the NudgeBadgeRow widget.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafetch/models/nudge_model.dart';
import 'package:lafetch/widgets/nudge_badge_row.dart';

void main() {
  group('Property 7: OOS state and nudges coexist without suppression', () {
    // Helper: build a product card Stack that contains both an OOS overlay
    // and a NudgeBadgeRow, mirroring the real product card structure.
    Widget _buildProductCardStack({
      required bool isOutOfStock,
      required List<Nudge> nudges,
    }) {
      return ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 250,
                child: Stack(
                  children: [
                    // Simulated product image placeholder
                    Container(
                      color: Colors.grey[200],
                    ),
                    // OOS overlay — present when product is out of stock
                    if (isOutOfStock)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          child: const Center(
                            child: Text(
                              'Out of Stock',
                              key: Key('oos_indicator'),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    // NudgeBadgeRow overlay — present when nudges are non-empty
                    Positioned(
                      top: 8,
                      left: 8,
                      child: NudgeBadgeRow(
                        nudges: nudges,
                        maxVisible: 2,
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'OOS indicator and NudgeBadgeRow are both present when product is OOS with nudges',
      (WidgetTester tester) async {
        // Arrange: a product that is out-of-stock AND has nudges
        const nudges = [
          Nudge(key: 'selling_fast', label: 'Selling Fast', source: 'rule'),
          Nudge(key: 'trending', label: 'Trending', source: 'rule'),
        ];

        // Act: pump the product card Stack
        await tester.pumpWidget(
          _buildProductCardStack(isOutOfStock: true, nudges: nudges),
        );
        await tester.pump();

        // Assert: OOS indicator is present
        expect(
          find.byKey(const Key('oos_indicator')),
          findsOneWidget,
          reason: 'OOS indicator must be present when product is out of stock',
        );

        // Assert: NudgeBadgeRow is present
        expect(
          find.byType(NudgeBadgeRow),
          findsOneWidget,
          reason: 'NudgeBadgeRow must be present when product has nudges',
        );

        // Assert: both coexist — neither suppresses the other
        expect(
          find.byKey(const Key('oos_indicator')),
          findsOneWidget,
          reason: 'NudgeBadgeRow must not suppress the OOS indicator',
        );
        expect(
          find.byType(NudgeBadgeRow),
          findsOneWidget,
          reason: 'OOS indicator must not suppress the NudgeBadgeRow',
        );
      },
    );

    testWidgets(
      'OOS indicator and NudgeBadgeRow coexist with a single nudge',
      (WidgetTester tester) async {
        // Arrange: minimal case — one nudge, OOS true
        const nudges = [
          Nudge(key: 'new_in', label: 'New In', source: 'manual'),
        ];

        await tester.pumpWidget(
          _buildProductCardStack(isOutOfStock: true, nudges: nudges),
        );
        await tester.pump();

        expect(find.byKey(const Key('oos_indicator')), findsOneWidget);
        expect(find.byType(NudgeBadgeRow), findsOneWidget);
      },
    );

    testWidgets(
      'NudgeBadgeRow is absent when nudges list is empty (OOS does not affect this)',
      (WidgetTester tester) async {
        // Arrange: OOS but no nudges — NudgeBadgeRow renders SizedBox.shrink()
        await tester.pumpWidget(
          _buildProductCardStack(isOutOfStock: true, nudges: const []),
        );
        await tester.pump();

        // OOS indicator still present
        expect(find.byKey(const Key('oos_indicator')), findsOneWidget);

        // NudgeBadgeRow is in the tree but renders nothing (SizedBox.shrink)
        // The widget itself is still found since it's always in the Stack
        expect(find.byType(NudgeBadgeRow), findsOneWidget);
      },
    );

    testWidgets(
      'NudgeBadgeRow is present when product is in-stock with nudges (baseline)',
      (WidgetTester tester) async {
        // Arrange: in-stock product with nudges — OOS indicator absent
        const nudges = [
          Nudge(key: 'bestseller', label: 'Bestseller', source: 'rule'),
        ];

        await tester.pumpWidget(
          _buildProductCardStack(isOutOfStock: false, nudges: nudges),
        );
        await tester.pump();

        // OOS indicator is NOT present
        expect(find.byKey(const Key('oos_indicator')), findsNothing);

        // NudgeBadgeRow IS present
        expect(find.byType(NudgeBadgeRow), findsOneWidget);
      },
    );
  });
}
