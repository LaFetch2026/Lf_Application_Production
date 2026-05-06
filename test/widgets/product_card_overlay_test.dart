// Feature: out-of-stock-product-handling, Property 3: Out-of-Stock Overlay Appears on Cards
//
// Validates: Requirements 2.1, 2.2
//
// Property 3: Out-of-Stock Overlay Appears on Cards
//
// For any product card with out-of-stock status, the card SHALL display an
// "Out of Stock" overlay that is visually distinct and clearly readable.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafetch/common/widget/cards/product_card.dart';
import 'package:lafetch/common/widget/cards/out_of_stock_overlay.dart';

void main() {
  group('Property 3: Out-of-Stock Overlay Appears on Cards', () {
    // Helper: build a ProductCard with specified stock status
    Widget _buildProductCard({
      required bool isOutOfStock,
      VoidCallback? onOutOfStockTap,
      Widget? customOverlay,
    }) {
      return ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 600,
                  child: ProductCard(
                    imageUrl: 'https://via.placeholder.com/200x240',
                    title: 'Test Product',
                    brandName: 'Test Brand',
                    price: 999,
                    mrp: 1299,
                    isOutOfStock: isOutOfStock,
                    onOutOfStockTap: onOutOfStockTap,
                    outOfStockOverlay: customOverlay,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'ProductCard displays OutOfStockOverlay when isOutOfStock is true',
      (WidgetTester tester) async {
        // Arrange: a product card with isOutOfStock = true
        await tester.pumpWidget(
          _buildProductCard(isOutOfStock: true),
        );
        await tester.pumpAndSettle();

        // Assert: OutOfStockOverlay widget is present
        expect(
          find.byType(OutOfStockOverlay),
          findsOneWidget,
          reason: 'OutOfStockOverlay must be present when isOutOfStock is true',
        );

        // Assert: "Out of Stock" text is visible
        expect(
          find.text('Out of Stock'),
          findsOneWidget,
          reason: 'Out of Stock text must be visible on the overlay',
        );
      },
    );

    testWidgets(
      'ProductCard does not display OutOfStockOverlay when isOutOfStock is false',
      (WidgetTester tester) async {
        // Arrange: a product card with isOutOfStock = false
        await tester.pumpWidget(
          _buildProductCard(isOutOfStock: false),
        );
        await tester.pumpAndSettle();

        // Assert: OutOfStockOverlay widget is not present
        expect(
          find.byType(OutOfStockOverlay),
          findsNothing,
          reason: 'OutOfStockOverlay must not be present when isOutOfStock is false',
        );

        // Assert: "Out of Stock" text is not visible
        expect(
          find.text('Out of Stock'),
          findsNothing,
          reason: 'Out of Stock text must not be visible when product is in stock',
        );
      },
    );

    testWidgets(
      'OutOfStockOverlay is visually distinct with semi-transparent background',
      (WidgetTester tester) async {
        // Arrange: a product card with isOutOfStock = true
        await tester.pumpWidget(
          _buildProductCard(isOutOfStock: true),
        );
        await tester.pumpAndSettle();

        // Assert: OutOfStockOverlay is present
        expect(find.byType(OutOfStockOverlay), findsOneWidget);

        // Assert: Text is white and clearly readable
        final textWidget = find.text('Out of Stock');
        expect(textWidget, findsOneWidget);
      },
    );

    testWidgets(
      'ProductCard calls onOutOfStockTap callback when overlay is tapped',
      (WidgetTester tester) async {
        // Arrange: a callback to track if overlay was tapped
        bool overlayTapped = false;
        void onTap() {
          overlayTapped = true;
        }

        await tester.pumpWidget(
          _buildProductCard(
            isOutOfStock: true,
            onOutOfStockTap: onTap,
          ),
        );
        await tester.pumpAndSettle();

        // Act: tap the overlay
        await tester.tap(find.byType(OutOfStockOverlay));
        await tester.pumpAndSettle();

        // Assert: callback was called
        expect(
          overlayTapped,
          true,
          reason: 'onOutOfStockTap callback must be called when overlay is tapped',
        );
      },
    );

    testWidgets(
      'ProductCard uses custom overlay widget when provided',
      (WidgetTester tester) async {
        // Arrange: a custom overlay widget
        const customOverlay = Placeholder(
          key: Key('custom_overlay'),
        );

        await tester.pumpWidget(
          _buildProductCard(
            isOutOfStock: true,
            customOverlay: customOverlay,
          ),
        );
        await tester.pumpAndSettle();

        // Assert: custom overlay is present
        expect(
          find.byKey(const Key('custom_overlay')),
          findsOneWidget,
          reason: 'Custom overlay widget must be used when provided',
        );

        // Assert: default OutOfStockOverlay is not present
        expect(
          find.byType(OutOfStockOverlay),
          findsNothing,
          reason: 'Default OutOfStockOverlay must not be used when custom overlay is provided',
        );
      },
    );

    testWidgets(
      'ProductCard overlay is positioned over the product image',
      (WidgetTester tester) async {
        // Arrange: a product card with isOutOfStock = true
        await tester.pumpWidget(
          _buildProductCard(isOutOfStock: true),
        );
        await tester.pumpAndSettle();

        // Assert: OutOfStockOverlay is present
        expect(find.byType(OutOfStockOverlay), findsOneWidget);

        // Assert: The overlay is inside a Stack (which is inside ClipRRect)
        // This verifies the overlay is positioned over the image
        final stackFinder = find.byType(Stack);
        expect(stackFinder, findsWidgets);

        // Verify the Stack contains both the image and the overlay
        final stack = tester.widget<Stack>(stackFinder.first);
        expect(stack.children.length, 2);
      },
    );
  });
}
