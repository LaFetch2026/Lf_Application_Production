// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Smart cache manager for API responses with persistent storage
///
/// Features:
/// - Persistent caching using SharedPreferences
/// - Timestamp-based expiration
/// - Cache invalidation support
/// - Memory-efficient JSON storage
class CacheManager {
  static const String _prefix = 'cache_';
  static const String _timestampSuffix = '_timestamp';

  /// Default cache duration: 30 minutes
  static const Duration defaultCacheDuration = Duration(minutes: 30);

  /// Save data to cache with timestamp
  static Future<void> save({
    required String key,
    required dynamic data,
    Duration? duration,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_prefix$key';
      final timestampKey = '$cacheKey$_timestampSuffix';

      // Store data as JSON string
      final jsonString = json.encode(data);
      await prefs.setString(cacheKey, jsonString);

      // Store timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(timestampKey, timestamp);

      print('✅ Cache saved: $key (${jsonString.length} bytes)');
    } catch (e) {
      print('❌ Cache save error for $key: $e');
    }
  }

  /// Get data from cache if valid
  /// Returns null if cache is expired or doesn't exist
  static Future<dynamic> get({
    required String key,
    Duration? maxAge,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_prefix$key';
      final timestampKey = '$cacheKey$_timestampSuffix';

      // Check if cache exists
      final jsonString = prefs.getString(cacheKey);
      if (jsonString == null) {
        print('⚠️ Cache miss: $key (not found)');
        return null;
      }

      // Check timestamp
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null) {
        print('⚠️ Cache miss: $key (no timestamp)');
        await clear(key); // Clean up invalid cache
        return null;
      }

      // Check expiration
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAgeMs = (maxAge ?? defaultCacheDuration).inMilliseconds;

      if (age > maxAgeMs) {
        print('⚠️ Cache expired: $key (${Duration(milliseconds: age).inMinutes} min old)');
        await clear(key);
        return null;
      }

      // Parse and return data
      final data = json.decode(jsonString);
      final ageMinutes = Duration(milliseconds: age).inMinutes;
      print('✅ Cache hit: $key ($ageMinutes min old)');
      return data;
    } catch (e) {
      print('❌ Cache get error for $key: $e');
      await clear(key); // Clean up corrupted cache
      return null;
    }
  }

  /// Clear specific cache key
  static Future<void> clear(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_prefix$key';
      final timestampKey = '$cacheKey$_timestampSuffix';

      await prefs.remove(cacheKey);
      await prefs.remove(timestampKey);
      print('🗑️ Cache cleared: $key');
    } catch (e) {
      print('❌ Cache clear error for $key: $e');
    }
  }

  /// Clear all cache entries
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      int count = 0;
      for (final key in keys) {
        if (key.startsWith(_prefix)) {
          await prefs.remove(key);
          count++;
        }
      }

      print('🗑️ All cache cleared ($count items)');
    } catch (e) {
      print('❌ Cache clearAll error: $e');
    }
  }

  /// Check if cache is valid (exists and not expired)
  static Future<bool> isValid({
    required String key,
    Duration? maxAge,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_prefix$key';
      final timestampKey = '$cacheKey$_timestampSuffix';

      if (!prefs.containsKey(cacheKey)) return false;

      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null) return false;

      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAgeMs = (maxAge ?? defaultCacheDuration).inMilliseconds;

      return age <= maxAgeMs;
    } catch (e) {
      print('❌ Cache isValid error for $key: $e');
      return false;
    }
  }

  /// Get cache age in minutes
  static Future<int?> getAgeMinutes(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampKey = '$_prefix$key$_timestampSuffix';

      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null) return null;

      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      return Duration(milliseconds: age).inMinutes;
    } catch (e) {
      return null;
    }
  }

  /// Invalidate cache for specific gender-based data
  static Future<void> invalidateGenderCache(int gender) async {
    await clear('banners_$gender');
    await clear('categories_$gender');
    await clear('brands_$gender');
    await clear('home_products_$gender');
    print('🗑️ Gender cache invalidated for gender: $gender');
  }

  /// Invalidate cart cache for all users or specific user
  static Future<void> invalidateCartCache({int? userId}) async {
    try {
      if (userId != null) {
        // Clear cache for specific user
        await clear('cart_data_$userId');
        print('🗑️ Cart cache invalidated for user: $userId');
      } else {
        // Clear all cart caches
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();

        int count = 0;
        for (final key in keys) {
          if (key.startsWith('${_prefix}cart_data_')) {
            await prefs.remove(key);
            count++;
          }
        }
        print('🗑️ All cart caches invalidated ($count users)');
      }
    } catch (e) {
      print('❌ Cart cache invalidation error: $e');
    }
  }

  /// Invalidate product cache
  static Future<void> invalidateProductCache() async {
    // Clear all product-related caches
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith('${_prefix}product_') ||
          key.startsWith('${_prefix}home_products_')) {
        await prefs.remove(key);
      }
    }
    print('🗑️ Product cache invalidated');
  }

  /// Invalidate wishlist cache
  static Future<void> invalidateWishlistCache() async {
    await clear('wishlist_data');
    print('🗑️ Wishlist cache invalidated');
  }

  /// Invalidate profile cache
  static Future<void> invalidateProfileCache() async {
    await clear('profile_data');
    print('🗑️ Profile cache invalidated');
  }
}
