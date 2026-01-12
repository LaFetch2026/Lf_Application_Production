// ignore_for_file: avoid_print

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

/// ================================================================
/// Optimized Image Cache Service for Production
/// - Separate cache managers for different image types
/// - Optimized cache sizes for real devices
/// - Memory-efficient configuration
/// ================================================================
class ImageCacheService extends GetxService {
  // Cache managers for different image types
  late final CacheManager brandLogoCache;
  late final CacheManager productImageCache;
  late final CacheManager brandBannerCache;
  late final CacheManager productThumbnailCache;

  @override
  void onInit() {
    super.onInit();
    _initializeCacheManagers();
  }

  void _initializeCacheManagers() {
    // Brand logos - smaller images, longer cache
    brandLogoCache = CacheManager(
      Config(
        'brandLogosCache',
        stalePeriod: const Duration(days: 30), // Brand logos rarely change
        maxNrOfCacheObjects: 100,
      ),
    );

    // Product images - medium size, moderate cache
    productImageCache = CacheManager(
      Config(
        'productImagesCache',
        stalePeriod: const Duration(days: 15),
        maxNrOfCacheObjects: 200,
      ),
    );

    // Brand banners - larger images, shorter cache
    brandBannerCache = CacheManager(
      Config(
        'brandBannersCache',
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 50, // Banners are larger files
      ),
    );

    // Product thumbnails - smaller images, larger cache
    productThumbnailCache = CacheManager(
      Config(
        'productThumbnailsCache',
        stalePeriod: const Duration(days: 15),
        maxNrOfCacheObjects: 300, // Small files, can cache more
      ),
    );

    print('✅ Image cache managers initialized');
  }

  /// Clear all image caches
  Future<void> clearAllCaches() async {
    await Future.wait([
      brandLogoCache.emptyCache(),
      productImageCache.emptyCache(),
      brandBannerCache.emptyCache(),
      productThumbnailCache.emptyCache(),
    ]);
    print('🗑️ All image caches cleared');
  }

  /// Clear specific cache
  Future<void> clearCache(String cacheType) async {
    switch (cacheType) {
      case 'brandLogos':
        await brandLogoCache.emptyCache();
        break;
      case 'productImages':
        await productImageCache.emptyCache();
        break;
      case 'brandBanners':
        await brandBannerCache.emptyCache();
        break;
      case 'productThumbnails':
        await productThumbnailCache.emptyCache();
        break;
      default:
        print('⚠️ Unknown cache type: $cacheType');
    }
    print('🗑️ Cache cleared: $cacheType');
  }

  /// Get cache statistics (approximate)
  Map<String, dynamic> getCacheStats() {
    return {
      'brandLogos': 'Up to 100 items',
      'productImages': 'Up to 200 items',
      'brandBanners': 'Up to 50 items',
      'productThumbnails': 'Up to 300 items',
      'stalePeriod': {
        'brandLogos': '30 days',
        'productImages': '15 days',
        'brandBanners': '7 days',
        'productThumbnails': '15 days',
      },
    };
  }

  @override
  void onClose() {
    // Cache managers are automatically disposed
    super.onClose();
  }
}
