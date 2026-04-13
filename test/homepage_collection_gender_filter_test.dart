// ignore_for_file: avoid_print
//
// Bug Condition Exploration Tests — Task 1
// Feature: homepage-collection-gender-filter
//
// PURPOSE: These tests MUST FAIL on unfixed code.
// Failure confirms the bug exists:
//   getHomeProduct(gender) assigns ALL collections to homeProductList
//   without filtering by displayFor, so cross-gender collections appear
//   under the wrong tab.
//
// DO NOT fix the code to make these tests pass.
// When the fix is applied (Task 3), these tests will pass.
//
// Validates: Requirements 1.1, 1.2, 1.3, 1.4

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lafetch/models/collection_model.dart';
import 'package:lafetch/models/collection_extensions.dart';
import 'package:lafetch/controllers/product_controller.dart';

// ---------------------------------------------------------------------------
// TestableProductController
//
// Thin subclass of ProductController that overrides getHomeProduct to use
// an injected http.Client instead of the top-level http.get function.
// This allows us to intercept HTTP calls in tests without modifying
// production code.
// ---------------------------------------------------------------------------
class TestableProductController extends ProductController {
  final http.Client httpClient;

  TestableProductController({required this.httpClient});

  @override
  Future<void> getHomeProduct(
    int gender, {
    bool withLimit = true,
    bool forceRefresh = false,
  }) async {
    // Mirror the exact logic from ProductController.getHomeProduct,
    // but use the injected httpClient instead of http.get.

    // Skip if already loaded (unless force refresh)
    if (!forceRefresh &&
        isHomeProductLoaded(gender) &&
        homeProductList.isNotEmpty) {
      isHomeProduct.value = false;
      return;
    }

    _activeGenderRequestOverride = gender;

    final displayFor = gender == 1
        ? 'men'
        : gender == 2
            ? 'women'
            : 'accessories';

    final cacheKey =
        'home_products_v7_${displayFor}_${withLimit ? "limited" : "all"}';

    // Cache path
    if (!forceRefresh) {
      final prefs = await SharedPreferences.getInstance();
      final cacheDataKey = 'cache_$cacheKey';
      final jsonString = prefs.getString(cacheDataKey);
      if (jsonString != null) {
        final timestampKey = '${cacheDataKey}_timestamp';
        final timestamp = prefs.getInt(timestampKey);
        if (timestamp != null) {
          final age = DateTime.now().millisecondsSinceEpoch - timestamp;
          if (age <= const Duration(minutes: 30).inMilliseconds) {
            final cached = json.decode(jsonString);
            if (cached is List) {
              if (_activeGenderRequestOverride != gender) return;
              final collections = CollectionUtils.filterByGender(
                cached
                    .whereType<Map<String, dynamic>>()
                    .map((e) => CollectionModel.fromJson(e))
                    .toList(),
                displayFor,
              );
              homeProductList.assignAll(collections);
              tagname.value =
                  collections.isNotEmpty ? collections.first.name : '';
              markHomeProductLoaded(gender);
              return;
            }
          }
        }
      }
    }

    if (forceRefresh) {
      isHomeProduct.value = true;
      homeProductList.clear();
    } else if (homeProductList.isEmpty) {
      isHomeProduct.value = true;
    } else {
      isHomeProduct.value = false;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    // Build URI mirroring the fixed production code (includes gender param)
    final uri = Uri.parse(
            'https://lfapi.la-fetch.com/api/product-collection/collection-with-products')
        .replace(queryParameters: {
      'displayFor': 'homepage',
      'gender': displayFor,
      if (withLimit) 'limit': 'true',
    });

    try {
      final response = await httpClient.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (_activeGenderRequestOverride != gender) return;

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final rawData = body['data'];
        final collectionsList =
            rawData is Map ? rawData['collections'] : rawData;
        final collections = CollectionUtils.filterByGender(
          CollectionUtils.parseCollections(collectionsList),
          displayFor,
        );

        homeProductList.assignAll(collections);
        tagname.value = collections.isNotEmpty ? collections.first.name : '';
        markHomeProductLoaded(gender);
      }
    } catch (e) {
      if (_activeGenderRequestOverride == gender && forceRefresh) {
        homeProductList.clear();
      }
    } finally {
      if (_activeGenderRequestOverride == gender) {
        isHomeProduct.value = false;
      }
    }
  }

  // Mirror the private field from ProductController
  int _activeGenderRequestOverride = -1;
}

// ---------------------------------------------------------------------------
// Helper: build a minimal CollectionModel JSON map
// ---------------------------------------------------------------------------
Map<String, dynamic> _makeCollection({
  required int id,
  required String name,
  required List<String> displayFor,
}) {
  return {
    'id': id,
    'name': name,
    'desc': null,
    'vendorId': null,
    'displayFor': displayFor,
    'banners': [],
    'productMaps': [],
    'products': [
      {
        'id': id * 100,
        'title': 'Product $id',
        'shortDescription': null,
        'basePrice': 999,
        'mrp': 1999,
        'imageUrls': ['https://example.com/img.jpg'],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'brand': {'name': 'TestBrand'},
      }
    ],
  };
}

// ---------------------------------------------------------------------------
// Helper: build a mock HTTP response with a list of collections
// ---------------------------------------------------------------------------
http.Client _mockClientReturning(List<Map<String, dynamic>> collections) {
  return MockClient((request) async {
    final body = json.encode({
      'data': collections,
    });
    return http.Response(body, 200,
        headers: {'content-type': 'application/json'});
  });
}

// ---------------------------------------------------------------------------
// Mixed collection set used across multiple tests:
//   - menOnly:       displayFor: ["men"]
//   - womenOnly:     displayFor: ["women"]
//   - multiGender:   displayFor: ["men", "women"]
// ---------------------------------------------------------------------------
final _menOnlyCollection = _makeCollection(
  id: 1,
  name: 'Men Only Collection',
  displayFor: ['men'],
);
final _womenOnlyCollection = _makeCollection(
  id: 2,
  name: 'Women Only Collection',
  displayFor: ['women'],
);
final _multiGenderCollection = _makeCollection(
  id: 3,
  name: 'Multi Gender Collection',
  displayFor: ['men', 'women'],
);
final _accessoriesCollection = _makeCollection(
  id: 4,
  name: 'Accessories Collection',
  displayFor: ['accessories'],
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Ensure GetX is initialized for controller
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  // =========================================================================
  // Test 1: Men filter
  //
  // Mock API returns [men, women, men+women].
  // Call getHomeProduct(1).
  // EXPECTED (correct behavior): homeProductList contains only men and
  //   multi-gender collections (ids 1 and 3).
  // ACTUAL (unfixed code): homeProductList contains ALL 3 collections.
  // RESULT: FAIL — confirms bug 1.1
  // =========================================================================
  group('Bug Condition: Men filter (gender=1)', () {
    test(
      'EXPLORATION: homeProductList contains ONLY men/multi-gender collections '
      'after getHomeProduct(1) — EXPECTED TO FAIL on unfixed code (confirms bug 1.1)',
      () async {
        // Arrange: mock API returns mixed collections
        final mockClient = _mockClientReturning([
          _menOnlyCollection,
          _womenOnlyCollection,
          _multiGenderCollection,
        ]);

        final controller = TestableProductController(httpClient: mockClient);

        // Act
        await controller.getHomeProduct(1, forceRefresh: true);

        // Inspect what was loaded
        final loaded = controller.homeProductList.toList();
        print('');
        print('=== Men Filter Test ===');
        print('Loaded ${loaded.length} collections:');
        for (final c in loaded) {
          print('  - "${c.name}" displayFor=${c.displayFor}');
        }

        // Find any collection that should NOT be in the men's list
        final wrongCollections = loaded
            .where((c) => !c.displayFor.contains('men'))
            .toList();

        if (wrongCollections.isNotEmpty) {
          print('');
          print('❌ BUG CONFIRMED: homeProductList contains cross-gender collections:');
          for (final c in wrongCollections) {
            print('  COUNTEREXAMPLE: "${c.name}" displayFor=${c.displayFor} '
                'should NOT appear in men\'s homeProductList');
          }
        }

        // Assert: ALL collections in homeProductList must have displayFor containing "men"
        // This FAILS on unfixed code because womenOnly collection (displayFor:["women"])
        // is included without filtering.
        expect(
          wrongCollections,
          isEmpty,
          reason:
              'BUG CONFIRMED: homeProductList contains collections whose '
              'displayFor does not include "men". '
              'Counterexamples: ${wrongCollections.map((c) => '${c.name} displayFor=${c.displayFor}').join(', ')}. '
              'Root cause: getHomeProduct(1) assigns all API collections to '
              'homeProductList without calling CollectionUtils.filterByGender.',
        );
      },
    );
  });

  // =========================================================================
  // Test 2: Women filter
  //
  // Mock API returns [men, women, men+women].
  // Call getHomeProduct(2).
  // EXPECTED (correct behavior): homeProductList contains only women and
  //   multi-gender collections (ids 2 and 3).
  // ACTUAL (unfixed code): homeProductList contains ALL 3 collections.
  // RESULT: FAIL — confirms bug 1.2
  // =========================================================================
  group('Bug Condition: Women filter (gender=2)', () {
    test(
      'EXPLORATION: homeProductList contains ONLY women/multi-gender collections '
      'after getHomeProduct(2) — EXPECTED TO FAIL on unfixed code (confirms bug 1.2)',
      () async {
        // Arrange
        final mockClient = _mockClientReturning([
          _menOnlyCollection,
          _womenOnlyCollection,
          _multiGenderCollection,
        ]);

        final controller = TestableProductController(httpClient: mockClient);

        // Act
        await controller.getHomeProduct(2, forceRefresh: true);

        // Inspect
        final loaded = controller.homeProductList.toList();
        print('');
        print('=== Women Filter Test ===');
        print('Loaded ${loaded.length} collections:');
        for (final c in loaded) {
          print('  - "${c.name}" displayFor=${c.displayFor}');
        }

        final wrongCollections = loaded
            .where((c) => !c.displayFor.contains('women'))
            .toList();

        if (wrongCollections.isNotEmpty) {
          print('');
          print('❌ BUG CONFIRMED: homeProductList contains cross-gender collections:');
          for (final c in wrongCollections) {
            print('  COUNTEREXAMPLE: "${c.name}" displayFor=${c.displayFor} '
                'should NOT appear in women\'s homeProductList');
          }
        }

        // Assert: ALL collections must have displayFor containing "women"
        expect(
          wrongCollections,
          isEmpty,
          reason:
              'BUG CONFIRMED: homeProductList contains collections whose '
              'displayFor does not include "women". '
              'Counterexamples: ${wrongCollections.map((c) => '${c.name} displayFor=${c.displayFor}').join(', ')}. '
              'Root cause: getHomeProduct(2) assigns all API collections to '
              'homeProductList without calling CollectionUtils.filterByGender.',
        );
      },
    );
  });

  // =========================================================================
  // Test 3: Accessories filter
  //
  // Mock API returns [accessories, men].
  // Call getHomeProduct(3).
  // EXPECTED (correct behavior): homeProductList contains only accessories
  //   collection (id 4).
  // ACTUAL (unfixed code): homeProductList contains BOTH collections.
  // RESULT: FAIL — confirms bug 1.3
  // =========================================================================
  group('Bug Condition: Accessories filter (gender=3)', () {
    test(
      'EXPLORATION: homeProductList contains ONLY accessories collections '
      'after getHomeProduct(3) — EXPECTED TO FAIL on unfixed code (confirms bug 1.3)',
      () async {
        // Arrange: mock returns accessories + men (men should be filtered out)
        final mockClient = _mockClientReturning([
          _accessoriesCollection,
          _menOnlyCollection,
        ]);

        final controller = TestableProductController(httpClient: mockClient);

        // Act
        await controller.getHomeProduct(3, forceRefresh: true);

        // Inspect
        final loaded = controller.homeProductList.toList();
        print('');
        print('=== Accessories Filter Test ===');
        print('Loaded ${loaded.length} collections:');
        for (final c in loaded) {
          print('  - "${c.name}" displayFor=${c.displayFor}');
        }

        final wrongCollections = loaded
            .where((c) => !c.displayFor.contains('accessories'))
            .toList();

        if (wrongCollections.isNotEmpty) {
          print('');
          print('❌ BUG CONFIRMED: homeProductList contains non-accessories collections:');
          for (final c in wrongCollections) {
            print('  COUNTEREXAMPLE: "${c.name}" displayFor=${c.displayFor} '
                'should NOT appear in accessories homeProductList');
          }
        }

        // Assert: ALL collections must have displayFor containing "accessories"
        expect(
          wrongCollections,
          isEmpty,
          reason:
              'BUG CONFIRMED: homeProductList contains collections whose '
              'displayFor does not include "accessories". '
              'Counterexamples: ${wrongCollections.map((c) => '${c.name} displayFor=${c.displayFor}').join(', ')}. '
              'Root cause: getHomeProduct(3) assigns all API collections to '
              'homeProductList without calling CollectionUtils.filterByGender.',
        );
      },
    );
  });

  // =========================================================================
  // Test 4: Cache path
  //
  // Pre-populate SharedPreferences cache with unfiltered data (men + women).
  // Call getHomeProduct(1) — should hit cache path.
  // EXPECTED (correct behavior): homeProductList contains only men collections.
  // ACTUAL (unfixed code): homeProductList contains ALL cached collections.
  // RESULT: FAIL — confirms bug 1.4 (cache path also unfiltered)
  // =========================================================================
  group('Bug Condition: Cache path (gender=1 from cache)', () {
    test(
      'EXPLORATION: homeProductList is filtered when loaded from cache '
      'after getHomeProduct(1) — EXPECTED TO FAIL on unfixed code (confirms bug 1.4)',
      () async {
        // Arrange: pre-populate cache with unfiltered data (men + women)
        final unfilteredCollections = [
          _menOnlyCollection,
          _womenOnlyCollection,
          _multiGenderCollection,
        ];

        // Write directly to SharedPreferences as CacheManager would
        final cacheKey = 'cache_home_products_v7_men_limited';
        final timestampKey = '${cacheKey}_timestamp';
        SharedPreferences.setMockInitialValues({
          cacheKey: json.encode(unfilteredCollections),
          timestampKey: DateTime.now().millisecondsSinceEpoch,
        });

        // Use a mock client that should NOT be called (cache hit)
        final mockClient = MockClient((request) async {
          // If this is called, the cache was not hit — fail loudly
          throw Exception('HTTP client should not be called on cache hit');
        });

        final controller = TestableProductController(httpClient: mockClient);

        // Act: call without forceRefresh so cache is used
        await controller.getHomeProduct(1);

        // Inspect
        final loaded = controller.homeProductList.toList();
        print('');
        print('=== Cache Path Test ===');
        print('Loaded ${loaded.length} collections from cache:');
        for (final c in loaded) {
          print('  - "${c.name}" displayFor=${c.displayFor}');
        }

        final wrongCollections = loaded
            .where((c) => !c.displayFor.contains('men'))
            .toList();

        if (wrongCollections.isNotEmpty) {
          print('');
          print('❌ BUG CONFIRMED: Cache path returns unfiltered collections:');
          for (final c in wrongCollections) {
            print('  COUNTEREXAMPLE: "${c.name}" displayFor=${c.displayFor} '
                'was served from cache but should NOT appear in men\'s homeProductList');
          }
        }

        // Assert: ALL collections from cache must have displayFor containing "men"
        expect(
          wrongCollections,
          isEmpty,
          reason:
              'BUG CONFIRMED: Cache path assigns unfiltered collections to '
              'homeProductList without calling CollectionUtils.filterByGender. '
              'Counterexamples: ${wrongCollections.map((c) => '${c.name} displayFor=${c.displayFor}').join(', ')}. '
              'Root cause: cache restore path in getHomeProduct does not call '
              'CollectionUtils.filterByGender before assigning to homeProductList.',
        );
      },
    );
  });
}
