// ignore_for_file: avoid_print
//
// Unit Test — SearchScreen Category Section Visibility Toggle (Task 6.1)
//
// PURPOSE: Verify that the category section is shown when the query is empty
// and hidden when the query is non-empty.
//
// Validates: Requirements 1.1, 1.7

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:lafetch/controllers/catalog_controller.dart';
import 'package:lafetch/controllers/home_controller.dart';
import 'package:lafetch/controllers/search_controller.dart';
import 'package:lafetch/screens/searchscreen.dart';

// ---------------------------------------------------------------------------
// Stub controllers — override API calls so tests run without network
// ---------------------------------------------------------------------------

class _StubCatalogController extends CatalogController {
  @override
  Future<void> getCatalogData(int gender, {bool forceRefresh = false}) async {
    // No-op: don't make real HTTP calls in tests
  }

  @override
  Future<void> getSubCategoryProducts(int catId) async {
    // No-op
  }
}

class _StubHomeController extends HomeController {
  _StubHomeController() {
    // Pre-populate genderTabs so SearchScreen doesn't need to fetch them
    genderTabs.assignAll([
      {'id': 1, 'name': 'Men'},
      {'id': 2, 'name': 'Women'},
    ]);
  }

  @override
  Future<void> getGenderTabs() async {
    // No-op
  }
}

class _StubSearchController extends SearchScreenController {
  @override
  Future<void> getProductSuggestions() async {
    // No-op
  }

  @override
  Future<void> getSearchData({bool loadMore = false}) async {
    // No-op
  }
}

// ---------------------------------------------------------------------------
// Helper: wrap SearchScreen in the minimal widget tree it needs
// ---------------------------------------------------------------------------

Widget _buildTestApp() {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (_, __) => GetMaterialApp(
      home: const SearchScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    // Mock SharedPreferences so HomeController.onInit doesn't throw
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{};
        }
        return null;
      },
    );

    Get.reset();
    // Register stub controllers before SearchScreen's initState runs
    Get.put<HomeController>(_StubHomeController());
    Get.put<CatalogController>(_StubCatalogController());
    Get.put<SearchScreenController>(_StubSearchController());
  });

  tearDown(() {
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      null,
    );
  });

  group('SearchScreen — category section visibility toggle', () {
    testWidgets(
      '6.1a: Category section is present when query is empty',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildTestApp());
        // Allow initState and first frame to settle
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // When query is empty, the category section should be visible.
        // We identify it by the "No Categories Found" text (catalogList is
        // empty in tests) or by the DummyCatalogList shimmer.
        // Either way, the category section widget is in the tree.
        // The gender chip row uses the tab names from genderTabs.
        expect(
          find.text('MEN'),
          findsOneWidget,
          reason:
              'Requirement 1.1: Category section (gender chips) must be '
              'visible when the search query is empty.',
        );
        expect(
          find.text('WOMEN'),
          findsOneWidget,
          reason:
              'Requirement 1.1: All gender tabs must be rendered when query '
              'is empty.',
        );
      },
    );

    testWidgets(
      '6.1b: Category section is absent when query is non-empty',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildTestApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Type a non-empty query into the search field
        await tester.enterText(
          find.byType(TextField),
          'dress',
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Gender chips must no longer be visible
        expect(
          find.text('MEN'),
          findsNothing,
          reason:
              'Requirement 1.7: Category section must be hidden when the '
              'search query is non-empty.',
        );
        expect(
          find.text('WOMEN'),
          findsNothing,
          reason:
              'Requirement 1.7: Category section must be hidden when the '
              'search query is non-empty.',
        );
      },
    );

    testWidgets(
      '6.1c: Category section reappears after clearing the query',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildTestApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Enter a query
        await tester.enterText(find.byType(TextField), 'shirt');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify category section is hidden
        expect(find.text('MEN'), findsNothing);

        // Clear the query
        await tester.enterText(find.byType(TextField), '');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Category section should reappear
        expect(
          find.text('MEN'),
          findsOneWidget,
          reason:
              'Requirement 1.1: Category section must reappear when the '
              'query is cleared back to empty.',
        );
      },
    );
  });
}
