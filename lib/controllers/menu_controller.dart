// ignore_for_file: avoid_print

import 'package:get/get.dart';
import '../models/menu_item_model.dart';
import '../services/cache_manager.dart';
import '../services/menu_service.dart';

class MenuController extends GetxController {
  static const _cacheKey = 'dynamic_menu_v2';

  final RxList<MenuItem> menuItems = <MenuItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  final MenuService _service = MenuService();

  @override
  void onInit() {
    super.onInit();
    // Always force-refresh on init to ensure we get the latest menu from server.
    // The menu rarely changes but when it does (e.g. new TEST tab added),
    // we must not serve stale cached data.
    fetchMenu(forceRefresh: true);
  }

  Future<void> fetchMenu({bool forceRefresh = false}) async {
    if (isLoading.value) return;

    // Always set loading = true FIRST so observers see it before we do anything
    isLoading.value = true;
    hasError.value = false;

    try {
      // Try cache (skip on forceRefresh)
      if (!forceRefresh) {
        try {
          final cached = await CacheManager.get(
            key: _cacheKey,
            maxAge: const Duration(minutes: 30),
          );
          if (cached != null && cached is List && cached.isNotEmpty) {
            final items = cached
                .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
                .toList();
            if (items.isNotEmpty) {
              menuItems.assignAll(items);
              print('✅ Menu loaded from cache: ${items.length} root items');
              return; // isLoading set to false in finally
            }
          }
        } catch (e) {
          print('⚠️ Menu cache read failed, fetching from API: $e');
        }
      }

      // Fetch from API
      final items = await _service.getMenu();
      menuItems.assignAll(items);

      // Cache the result
      if (items.isNotEmpty) {
        final raw = items.map((m) => _menuToJson(m)).toList();
        await CacheManager.save(key: _cacheKey, data: raw);
      }

      print('✅ Menu fetched from API: ${items.length} root items');
    } catch (e) {
      print('❌ Menu fetch error: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _menuToJson(MenuItem m) {
    return {
      'id': m.id,
      'label': m.label,
      'type': m.type,
      'refId': m.refId,
      'link': m.link,
      'sortOrder': m.sortOrder,
      'isVisible': m.isVisible,
      'image': m.image,
      'banner': m.banner,
      'children': m.children.map(_menuToJson).toList(),
    };
  }
}
