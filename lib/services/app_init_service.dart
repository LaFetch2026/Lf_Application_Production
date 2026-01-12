// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'api_service.dart';
import 'image_cache_service.dart';
import 'network_service.dart';

/// ================================================================
/// App Initialization Service
/// - Initializes all services in correct order
/// - Ensures services are ready before app starts
/// ================================================================
class AppInitService {
  static bool _initialized = false;

  /// Initialize all services
  static Future<void> initialize() async {
    if (_initialized) {
      print('⚠️ Services already initialized, skipping...');
      return;
    }

    print('🚀 Initializing app services...');

    try {
      // 1. Initialize Network Service first (other services depend on it)
      print('  1️⃣ Initializing NetworkService...');
      Get.put(NetworkService(), permanent: true);
      await Future.delayed(const Duration(milliseconds: 100));

      // 2. Initialize API Service (depends on NetworkService)
      print('  2️⃣ Initializing ApiService...');
      Get.put(ApiService(), permanent: true);

      // 3. Initialize Image Cache Service
      print('  3️⃣ Initializing ImageCacheService...');
      Get.put(ImageCacheService(), permanent: true);

      _initialized = true;
      print('✅ All services initialized successfully!\n');
    } catch (e) {
      print('❌ Error initializing services: $e');
      rethrow;
    }
  }

  /// Check if services are initialized
  static bool get isInitialized => _initialized;

  /// Re-initialize services (useful after logout or app reset)
  static Future<void> reinitialize() async {
    print('🔄 Re-initializing services...');
    _initialized = false;

    // Clear existing services
    if (Get.isRegistered<NetworkService>()) {
      Get.delete<NetworkService>();
    }
    if (Get.isRegistered<ApiService>()) {
      Get.delete<ApiService>();
    }
    if (Get.isRegistered<ImageCacheService>()) {
      Get.delete<ImageCacheService>();
    }

    await initialize();
  }
}
