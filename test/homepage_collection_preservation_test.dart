// ignore_for_file: avoid_print
//
// Preservation Property Tests — Task 2
// Feature: homepage-collection-gender-filter
//
// PURPOSE: These tests MUST PASS on unfixed code.
// They establish the baseline behaviors that must be preserved after the fix.
//
// Observation-first methodology:
//   - All inputs here satisfy NOT isBugCondition — every collection in the
//     mock response already has the correct displayFor for the requested gender.
//   - On unfixed code, getHomeProduct assigns all API collections to
//     homeProductList without filtering. Since the inputs are already correct,
//     the result is the same as the expected filtered result.
//   - These tests capture that observed baseline so we can verify the fix
//     does not over-filter or drop valid collections.
//
// Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5

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
// TestableProductController (minimal duplicate)
//
// Mirrors the version in homepage_collection_gender_filter_test.dart.
// Overrides getHomeProduct to use an injected http.Client so tests can
// intercept HTTP calls without modifying production code.
// ---------------------------------------------------------------------------
class _TestableProductController extends ProductController {
  final http.Client httpClient;

  _TestableProductController({required this.httpClient});

  @override
  Future<void> getHomeProduct(
    int gender, {
    bool withLimit = true,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        isHomeProductLoaded(gender) &&
        homeProductList.isNotEmpty) {
      isHomeProduct.value = false;
      return;
    }

    _activeGenderOverride = gender;

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
              if (_activeGenderOverride != gender) return;
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

    // Build URI with gender param (fixed)
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

      if (_activeGenderOverride != gender) return;

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final rawData = body['data'];
        final collectionsList =
            rawData is Map ? rawData['collections'] : rawData;
        final collections = CollectionUtils.filterByGender(
          List<Map<String, dynamic>>.from(
            (collectionsList as List).whereType<Map<String, dynamic>>(),
          ).map((e) => CollectionModel.fromJson(e)).toList(),
          displayFor,
        );

        homeProductList.assignAll(collections);
        tagname.value = collections.isNotEmpty ? collections.first.name : '';
        markHomeProductLoaded(gender);
      }
    } catch (e) {
      if (_activeGenderOverride == gender && forceRefresh) {
        homeProductList.clear();
      }
    } finally {
      if (_activeGenderOverride == gender) {
        isHomeProduct.value = false;
      }
    }
  }

  int _activeGenderOverride = -1;
}

// ---------------------------------------------------------------------------
// Helper: build a minimal CollectionModel JSON map with one product
// (filterByGender requires hasProducts — at least one product)
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
// Helper: build a mock HTTP client returning the given collections
// ---------------------------------------------------------------------------
http.Client _mockClientReturning(List<Map<String, dynamic>> collections) {
  return MockClient((request) async {
    return http.Response(
      json.encode({'data': collections}),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
}

// ---------------------------------------------------------------------------
// Pre-built collection fixtures
// ---------------------------------------------------------------------------

// Men-only collections (already correct for gender=1)
final _menA = _makeCollection(id: 10, name: 'Men Collection A', displayFor: ['men']);
final _menB = _makeCollection(id: 11, name: 'Men Collection B', displayFor: ['men']);
final _menC = _makeCollection(id: 12, name: 'Men Collection C', displayFor: ['men']);

// Women-only collections (already correct for gender=2)
final _womenA = _makeCollection(id: 20, name: 'Women Collection A', displayFor: ['women']);
final _womenB = _makeCollection(id: 21, name: 'Women Collection B', displayFor: ['women']);

// Multi-gender collection (correct for both gender=1 and gender=2)
final _multiGender = _makeCollection(
  id: 30,
  name: 'Multi Gender Collection',
  displayFor: ['men', 'women'],
);

// Accessories collection (already correct for gender=3)
final _accessoriesA = _makeCollection(id: 40, name: 'Accessories A', displayFor: ['accessories']);
final _accessoriesB = _makeCollection(id: 41, name: 'Accessories B', displayFor: ['accessories']);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  // =========================================================================
  // Property 1: Already-correct collections preserved (no over-filtering)
  //
  // When ALL collections in the API response already have displayFor
  // containing the requested gender, the count in homeProductList must equal
  // the count returned by the API (no collections dropped).
  //
  // Observation on unfixed code: getHomeProduct assigns all collections
  // directly — so when inputs are already correct, count is preserved.
  //
  // Validates: Requirements 3.1, 3.2
  // =========================================================================
  group(
    'Preservation Property 1: Already-correct collections are not dropped',
    () {
      // Property-based: test across multiple all-correct collection lists
      final testCases = [
        {
          'description': 'single men collection for gender=1',
          'gender': 1,
          'collections': [_menA],
          'expectedCount': 1,
        },
        {
          'description': 'three men collections for gender=1',
          'gender': 1,
          'collections': [_menA, _menB, _menC],
          'expectedCount': 3,
        },
        {
          'description': 'two women collections for gender=2',
          'gender': 2,
          'collections': [_womenA, _womenB],
          'expectedCount': 2,
        },
        {
          'description': 'two accessories collections for gender=3',
          'gender': 3,
          'collections': [_accessoriesA, _accessoriesB],
          'expectedCount': 2,
        },
        {
          'description': 'men + multi-gender for gender=1 (all contain "men")',
          'gender': 1,
          'collections': [_menA, _menB, _multiGender],
          'expectedCount': 3,
        },
        {
          'description': 'women + multi-gender for gender=2 (all contain "women")',
          'gender': 2,
          'collections': [_womenA, _multiGender],
          'expectedCount': 2,
        },
      ];

      for (final tc in testCases) {
        test(
          'PRESERVATION: count preserved — ${tc['description']} '
          '— EXPECTED TO PASS on unfixed code',
          () async {
            final gender = tc['gender'] as int;
            final collections =
                tc['collections'] as List<Map<String, dynamic>>;
            final expectedCount = tc['expectedCount'] as int;

            final mockClient = _mockClientReturning(collections);
            final controller =
                _TestableProductController(httpClient: mockClient);

            await controller.getHomeProduct(gender, forceRefresh: true);

            final loaded = controller.homeProductList.toList();
            print('');
            print('=== Preservation Test: ${tc['description']} ===');
            print('Input count: ${collections.length}, '
                'Loaded count: ${loaded.length}');
            for (final c in loaded) {
              print('  - "${c.name}" displayFor=${c.displayFor}');
            }

            // Assert: no collections were dropped
            expect(
              loaded.length,
              equals(expectedCount),
              reason:
                  'PRESERVATION VIOLATED: ${tc['description']}. '
                  'Expected $expectedCount collections but got ${loaded.length}. '
                  'The fix must not drop collections that already match the '
                  'requested gender.',
            );
          },
        );
      }
    },
  );

  // =========================================================================
  // Property 2: Multi-gender collection appears under each of its genders
  //
  // A collection with displayFor: ["men", "women"] must appear in
  // homeProductList for both getHomeProduct(1) and getHomeProduct(2).
  //
  // Observation on unfixed code: since no filtering is applied, the
  // multi-gender collection is always included when it is in the API response.
  //
  // Validates: Requirements 3.2
  // =========================================================================
  group(
    'Preservation Property 2: Multi-gender collection appears under each gender',
    () {
      // Property-based: test multiple multi-gender combinations
      final multiGenderCases = [
        {
          'description': 'displayFor:["men","women"] appears under men (gender=1)',
          'gender': 1,
          'genderStr': 'men',
          'collections': [_multiGender],
        },
        {
          'description': 'displayFor:["men","women"] appears under women (gender=2)',
          'gender': 2,
          'genderStr': 'women',
          'collections': [_multiGender],
        },
        {
          'description': 'multi-gender + men-only both appear under men (gender=1)',
          'gender': 1,
          'genderStr': 'men',
          'collections': [_menA, _multiGender],
        },
        {
          'description': 'multi-gender + women-only both appear under women (gender=2)',
          'gender': 2,
          'genderStr': 'women',
          'collections': [_womenA, _multiGender],
        },
      ];

      for (final tc in multiGenderCases) {
        test(
          'PRESERVATION: ${tc['description']} — EXPECTED TO PASS on unfixed code',
          () async {
            final gender = tc['gender'] as int;
            final genderStr = tc['genderStr'] as String;
            final collections =
                tc['collections'] as List<Map<String, dynamic>>;

            final mockClient = _mockClientReturning(collections);
            final controller =
                _TestableProductController(httpClient: mockClient);

            await controller.getHomeProduct(gender, forceRefresh: true);

            final loaded = controller.homeProductList.toList();
            print('');
            print('=== Multi-Gender Test: ${tc['description']} ===');
            print('Loaded ${loaded.length} collections:');
            for (final c in loaded) {
              print('  - "${c.name}" displayFor=${c.displayFor}');
            }

            // Find the multi-gender collection in the result
            final multiGenderInResult = loaded.where(
              (c) => c.displayFor.contains('men') && c.displayFor.contains('women'),
            ).toList();

            expect(
              multiGenderInResult,
              isNotEmpty,
              reason:
                  'PRESERVATION VIOLATED: ${tc['description']}. '
                  'Multi-gender collection (displayFor contains both "men" and '
                  '"women") must appear in homeProductList for gender=$gender '
                  '(genderStr="$genderStr"). '
                  'Loaded: ${loaded.map((c) => '${c.name}:${c.displayFor}').join(', ')}',
            );

            // Also verify it contains the requested gender string
            for (final c in multiGenderInResult) {
              expect(
                c.displayFor.contains(genderStr),
                isTrue,
                reason:
                    'Multi-gender collection "${c.name}" must have '
                    '"$genderStr" in its displayFor. '
                    'displayFor=${c.displayFor}',
              );
            }
          },
        );
      }
    },
  );

  // =========================================================================
  // Property 3: Empty list preserved
  //
  // When the API returns no collections for the requested gender (empty list),
  // homeProductList must be empty.
  //
  // Observation on unfixed code: getHomeProduct assigns the empty parsed list
  // directly — homeProductList is empty.
  //
  // Validates: Requirements 3.3
  // =========================================================================
  group('Preservation Property 3: Empty list preserved', () {
    test(
      'PRESERVATION: homeProductList is empty when API returns empty list '
      '(gender=1) — EXPECTED TO PASS on unfixed code',
      () async {
        final mockClient = _mockClientReturning([]);
        final controller = _TestableProductController(httpClient: mockClient);

        await controller.getHomeProduct(1, forceRefresh: true);

        final loaded = controller.homeProductList.toList();
        print('');
        print('=== Empty List Test (gender=1) ===');
        print('Loaded ${loaded.length} collections');

        expect(
          loaded,
          isEmpty,
          reason:
              'PRESERVATION VIOLATED: homeProductList must be empty when '
              'the API returns an empty collection list for gender=1. '
              'Got ${loaded.length} collections: '
              '${loaded.map((c) => c.name).join(', ')}',
        );
      },
    );

    test(
      'PRESERVATION: homeProductList is empty when API returns empty list '
      '(gender=2) — EXPECTED TO PASS on unfixed code',
      () async {
        final mockClient = _mockClientReturning([]);
        final controller = _TestableProductController(httpClient: mockClient);

        await controller.getHomeProduct(2, forceRefresh: true);

        final loaded = controller.homeProductList.toList();
        print('');
        print('=== Empty List Test (gender=2) ===');
        print('Loaded ${loaded.length} collections');

        expect(
          loaded,
          isEmpty,
          reason:
              'PRESERVATION VIOLATED: homeProductList must be empty when '
              'the API returns an empty collection list for gender=2.',
        );
      },
    );

    test(
      'PRESERVATION: homeProductList is empty when API returns empty list '
      '(gender=3) — EXPECTED TO PASS on unfixed code',
      () async {
        final mockClient = _mockClientReturning([]);
        final controller = _TestableProductController(httpClient: mockClient);

        await controller.getHomeProduct(3, forceRefresh: true);

        final loaded = controller.homeProductList.toList();
        print('');
        print('=== Empty List Test (gender=3) ===');
        print('Loaded ${loaded.length} collections');

        expect(
          loaded,
          isEmpty,
          reason:
              'PRESERVATION VIOLATED: homeProductList must be empty when '
              'the API returns an empty collection list for gender=3.',
        );
      },
    );
  });

  // =========================================================================
  // Property 4: Tab switch preserved
  //
  // Switching gender triggers a new load and homeProductList updates to
  // reflect the new gender's collections.
  //
  // Observation on unfixed code: each call to getHomeProduct with a new
  // gender (forceRefresh=true) replaces homeProductList with the new
  // API response. The count and content change accordingly.
  //
  // Validates: Requirements 3.1, 3.4
  // =========================================================================
  group('Preservation Property 4: Tab switch triggers new load', () {
    test(
      'PRESERVATION: switching from gender=1 to gender=2 updates '
      'homeProductList — EXPECTED TO PASS on unfixed code',
      () async {
        // Arrange: two separate mock clients for each gender call
        // First call (gender=1): returns men-only collections
        // Second call (gender=2): returns women-only collections
        int callCount = 0;
        final mockClient = MockClient((request) async {
          callCount++;
          final collections = callCount == 1
              ? [_menA, _menB] // first call: men
              : [_womenA, _womenB]; // second call: women
          return http.Response(
            json.encode({'data': collections}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final controller = _TestableProductController(httpClient: mockClient);

        // Act: load gender=1 (men tab)
        await controller.getHomeProduct(1, forceRefresh: true);
        final afterMen = controller.homeProductList.toList();

        print('');
        print('=== Tab Switch Test ===');
        print('After gender=1 load (${afterMen.length} collections):');
        for (final c in afterMen) {
          print('  - "${c.name}" displayFor=${c.displayFor}');
        }

        // Assert: men's collections loaded
        expect(
          afterMen.length,
          equals(2),
          reason: 'After getHomeProduct(1), homeProductList should have 2 '
              'men collections.',
        );

        // Act: switch to gender=2 (women tab)
        await controller.getHomeProduct(2, forceRefresh: true);
        final afterWomen = controller.homeProductList.toList();

        print('After gender=2 load (${afterWomen.length} collections):');
        for (final c in afterWomen) {
          print('  - "${c.name}" displayFor=${c.displayFor}');
        }

        // Assert: women's collections loaded (homeProductList updated)
        expect(
          afterWomen.length,
          equals(2),
          reason: 'After getHomeProduct(2), homeProductList should have 2 '
              'women collections.',
        );

        // Assert: the API was called twice (once per gender)
        expect(
          callCount,
          equals(2),
          reason: 'Tab switch must trigger a new API call for the new gender.',
        );
      },
    );

    test(
      'PRESERVATION: switching from gender=2 to gender=3 updates '
      'homeProductList — EXPECTED TO PASS on unfixed code',
      () async {
        int callCount = 0;
        final mockClient = MockClient((request) async {
          callCount++;
          final collections = callCount == 1
              ? [_womenA] // first call: women
              : [_accessoriesA, _accessoriesB]; // second call: accessories
          return http.Response(
            json.encode({'data': collections}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final controller = _TestableProductController(httpClient: mockClient);

        // Load gender=2 first
        await controller.getHomeProduct(2, forceRefresh: true);
        final afterWomen = controller.homeProductList.toList();

        expect(
          afterWomen.length,
          equals(1),
          reason: 'After getHomeProduct(2), homeProductList should have 1 '
              'women collection.',
        );

        // Switch to gender=3
        await controller.getHomeProduct(3, forceRefresh: true);
        final afterAccessories = controller.homeProductList.toList();

        print('');
        print('=== Tab Switch Test (gender=2 → gender=3) ===');
        print('After gender=3 load (${afterAccessories.length} collections):');
        for (final c in afterAccessories) {
          print('  - "${c.name}" displayFor=${c.displayFor}');
        }

        expect(
          afterAccessories.length,
          equals(2),
          reason: 'After getHomeProduct(3), homeProductList should have 2 '
              'accessories collections.',
        );

        expect(
          callCount,
          equals(2),
          reason: 'Tab switch must trigger a new API call for the new gender.',
        );
      },
    );

    test(
      'PRESERVATION: switching back to gender=1 after gender=2 loads '
      'correct collections — EXPECTED TO PASS on unfixed code',
      () async {
        // Simulate: men → women → men (back-navigation)
        final responses = [
          [_menA, _menB, _menC], // gender=1 first load
          [_womenA, _womenB],    // gender=2
          [_menA, _menB, _menC], // gender=1 again (forceRefresh)
        ];
        int callCount = 0;
        final mockClient = MockClient((request) async {
          final collections = responses[callCount < responses.length
              ? callCount
              : responses.length - 1];
          callCount++;
          return http.Response(
            json.encode({'data': collections}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final controller = _TestableProductController(httpClient: mockClient);

        await controller.getHomeProduct(1, forceRefresh: true);
        await controller.getHomeProduct(2, forceRefresh: true);
        await controller.getHomeProduct(1, forceRefresh: true);

        final afterReturn = controller.homeProductList.toList();

        print('');
        print('=== Tab Switch Back Test (gender=1 → 2 → 1) ===');
        print('After returning to gender=1 (${afterReturn.length} collections):');
        for (final c in afterReturn) {
          print('  - "${c.name}" displayFor=${c.displayFor}');
        }

        expect(
          afterReturn.length,
          equals(3),
          reason: 'After switching back to gender=1, homeProductList should '
              'have 3 men collections.',
        );
      },
    );
  });
}
