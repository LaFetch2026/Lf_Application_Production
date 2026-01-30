# Collection Implementation Guide

## Overview

This guide documents the collection data structure, implementation, and issues found in the LA Fetch app.

## Data Structure

### API Endpoint

```
GET /collection-with-products?limit=true&gender={genderId}
```

### Response Structure

```json
{
  "status": 200,
  "message": "Success!",
  "data": [
    {
      "id": 28,
      "name": "Winterwear",
      "desc": "Explore All",
      "vendorId": null,
      "displayFor": ["homepage", "men", "women"],
      "banners": [...],
      "productMaps": [...],
      "products": [...]
    }
  ]
}
```

## Issues Found

### 1. **No Type Safety** ❌

**Current Implementation:**

```dart
List homeProductList = [].obs;  // Raw list without type
final c = collections[index];   // No type checking
final int collectionId = c['id'] is int ? c['id'] : 0;  // Runtime type checking
```

**Issue:** Using raw Maps causes:

- No compile-time type checking
- Risk of runtime errors
- Poor IDE autocomplete support
- Difficult to maintain

**Fix:** Use typed models

```dart
RxList<CollectionModel> homeProductList = <CollectionModel>[].obs;
final collection = collections[index];
final int collectionId = collection.id;  // Type-safe access
```

### 2. **Inconsistent Data Access** ❌

**Current Implementation:**

```dart
// Different ways to access the same data
final name = c['name']?.toString() ?? '';
final List<dynamic> banners = (c['banners'] is List) ? List.from(c['banners'] as List) : [];
final products = (c['products'] as List<dynamic>?)?.whereType<Map<String, dynamic>>().toList() ?? [];
```

**Issue:**

- Multiple patterns for accessing nested data
- Verbose null checks
- Easy to make mistakes

**Fix:** Use model methods

```dart
final name = collection.name;
final banners = collection.bannersFor('men');
final products = collection.products;
```

### 3. **Banner Filtering Logic Scattered** ❌

**Current Implementation:**

```dart
// Banner filtering happens in multiple places
final List<dynamic> banners = (c['banners'] is List) ? List.from(c['banners'] as List) : [];
// Later...
final currentGender = homeController.genderText.value.toLowerCase();
// No consistent filtering by displayFor
```

**Issue:**

- Banner filtering not applied consistently
- May show wrong banners for current gender
- Logic duplicated across the app

**Fix:** Centralized filtering in model

```dart
final banners = collection.bannersFor(currentGender);  // Automatically filtered and sorted
```

### 4. **Missing Error Handling** ❌

**Current Implementation:**

```dart
homeProductList.assignAll(data);  // No validation
```

**Issue:**

- Malformed data can crash the app
- No graceful degradation
- Silent failures

**Fix:** Add validation

```dart
try {
  final collections = CollectionUtils.parseCollections(decoded['data']);
  homeProductList.assignAll(collections);
  print("✅ Loaded ${collections.length} collections");
} catch (e) {
  print("❌ Error parsing collections: $e");
  homeProductList.clear();
}
```

### 5. **Gender Filtering Issues** ⚠️

**Current Issue:**

```dart
// Collections are fetched with gender parameter
// But productList may still contain items not meant for that gender
// No validation of displayFor field
```

**Fix:** Filter collections properly

```dart
final validCollections = CollectionUtils.filterByGender(
  collections,
  genderType
).where((c) => c.hasProducts).toList();
```

### 6. **Image URL Selection** ⚠️

**Current Implementation:**

```dart
final banner = sortedBanners[index];
imageUrl: banner['mobileImageUrl']?.toString() ?? '',
```

**Issue:**

- Doesn't fall back to web image if mobile is null
- Hardcoded platform detection

**Fix:** Use helper method

```dart
final banner = sortedBanners[index];
imageUrl: banner.getImageUrl(isMobile: Platform.isAndroid || Platform.isIOS),
```

## Current Implementation Status

### ✅ Working Features

1. Collections are fetched and displayed correctly
2. Products within collections show properly
3. Banners are displayed with auto-scroll
4. Cache mechanism works
5. Gender-based API calls work

### ⚠️ Issues to Fix

1. Add type safety with models
2. Improve error handling
3. Centralize banner filtering
4. Add proper validation
5. Better null safety

## Implementation Guide

### Step 1: Update ProductController

**Add model import:**

```dart
import '../models/collection_model.dart';
import '../models/collection_extensions.dart';
```

**Update observable:**

```dart
// OLD
List homeProductList = [].obs;

// NEW
RxList<CollectionModel> homeProductList = <CollectionModel>[].obs;
```

**Update getHomeProduct method:**

```dart
Future<void> getHomeProduct(
  int gender, {
  bool withLimit = true,
  bool forceRefresh = false,
}) async {
  final displayFor = gender == 1
      ? 'men'
      : gender == 2
          ? 'women'
          : 'accessories';

  final cacheKey = 'home_products_v3_${displayFor}_${withLimit ? "limited" : "all"}';

  if (!forceRefresh) {
    final cached = await CacheManager.get(key: cacheKey);
    if (cached != null && cached is List) {
      try {
        final collections = cached
            .whereType<Map<String, dynamic>>()
            .map((json) => CollectionModel.fromJson(json))
            .toList();

        homeProductList.assignAll(collections);

        if (homeProductList.isNotEmpty) {
          tagname.value = homeProductList.first.name;
        }
        return;
      } catch (e) {
        print("⚠️ Error parsing cached collections: $e");
      }
    }
  }

  isHomeProduct.value = true;
  homeProductList.clear();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final base = ApiConstants.baseUrl;

  final uri = Uri.parse("$base/collection-with-products").replace(
    queryParameters: {
      if (withLimit) 'limit': 'true',
      'gender': gender.toString(),
    },
  );

  try {
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json; charset=UTF-8',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      // ✅ Parse with models
      final collections = CollectionUtils.parseCollections(body['data']);

      // ✅ Filter by gender and products
      final validCollections = CollectionUtils.filterByGender(
        collections,
        displayFor,
      );

      homeProductList.assignAll(validCollections);

      // ✅ Cache as JSON
      await CacheManager.save(
        key: cacheKey,
        data: validCollections.map((c) => c.toJson()).toList(),
      );

      tagname.value = validCollections.isNotEmpty ? validCollections.first.name : '';

      print("✅ Loaded ${validCollections.length} collections for $displayFor");
    } else {
      homeProductList.clear();
      print("❌ API Error: ${response.statusCode}");
    }
  } catch (e, stackTrace) {
    print("check your network connection");
    print("Stack trace: $stackTrace");
    homeProductList.clear();
  } finally {
    isHomeProduct.value = false;
  }
}
```

### Step 2: Update HomeScreen

**Update collection rendering:**

```dart
// OLD
final c = collections[index];
final int collectionId = c['id'] is int ? c['id'] : int.tryParse(c['id']?.toString() ?? '') ?? 0;
final String title = c['name']?.toString() ?? '';

// NEW
final collection = collections[index];
final int collectionId = collection.id;
final String title = collection.name;
```

**Update banner access:**

```dart
// OLD
final List<dynamic> banners = (c['banners'] is List) ? List.from(c['banners'] as List) : [];

// NEW
final currentGender = homeController.genderText.value.toLowerCase();
final banners = collection.bannersFor(currentGender);
```

**Update product access:**

```dart
// OLD
final List<Map<String, dynamic>> products = (c['products'] as List<dynamic>?)
    ?.whereType<Map<String, dynamic>>()
    .toList() ?? [];

// NEW
final products = collection.products;
```

## Testing Checklist

- [ ] Collections load correctly for each gender
- [ ] Only relevant banners show for current gender
- [ ] Products display properly
- [ ] Cache works (test offline mode)
- [ ] Error handling works (test with bad data)
- [ ] Gender switching updates collections
- [ ] Banner auto-scroll works
- [ ] Tapping products navigates correctly
- [ ] No runtime type errors

## Migration Strategy

1. ✅ Create models (done)
2. ✅ Create extensions (done)
3. Update ProductController to use models
4. Update HomeScreen to use typed collections
5. Test thoroughly
6. Remove old Map-based code

## Notes

- Keep backward compatibility during migration
- Models include helper methods for common operations
- Extensions provide additional utility without bloating main models
- Error handling is improved with try-catch blocks
- Caching works with both old and new format
