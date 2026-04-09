// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/controllers/product_controller.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/loginscreen.dart';
import '../screens/paymentcheckscreen.dart';
import '../screens/paymentsuccessscreen.dart';
import '../core/services/meta_event_service.dart';
import '../services/cache_manager.dart';
import 'auth_api_client.dart';
import 'base_controller.dart';

class CartController extends BaseController {
  // -------------------- STATE --------------------
  final RxBool isOrder = false.obs;
  final RxBool isCoupan = false.obs;
  final RxBool isPayment = false.obs;
  final RxBool isRemoveCoupan = false.obs;

  final RxList<Map<String, dynamic>> orderList = RxList<Map<String, dynamic>>();
  final RxMap<String, dynamic> cartDetails = <String, dynamic>{}.obs;
  final RxInt cartId = 0.obs;

  final RxString couponError = "".obs;
  final RxString couponText = "Apply Coupon".obs;
  final RxString couponSave = "".obs;

  final couponController = TextEditingController();
  final RxList<dynamic> couponList = <dynamic>[].obs;

  final RxBool isExpress = false.obs;
  final RxInt expressValue = 0.obs;
  final RxInt couponlength = 0.obs;
  final RxDouble lat = 0.0.obs;
  final RxDouble lng = 0.0.obs;
  final RxInt cartTotalValue = 0.obs;

  final RxString qtyText = "".obs;
  final RxString stockErrorText = "".obs;
  final RxString userNumber = "".obs;
  final RxInt qtyProductId = 0.obs;
  final RxList<dynamic> categoryList = <dynamic>[].obs;
  final RxList<dynamic> tagsList = <dynamic>[].obs;
  final RxString addressError = "".obs;

  // ✅ Cart banners state
  final RxList<dynamic> cartBannerList = <dynamic>[].obs;
  final RxBool isLoadingCartBanners = false.obs;

  List<bool> selected = List.generate(50, (i) => false).obs;

  AuthApiClient _ensureClient() {
    try {
      return Get.find<AuthApiClient>();
    } catch (_) {
      print("⚠️ AuthApiClient not found. Registering new instance...");
      return Get.put(AuthApiClient(http.Client()));
    }
  }

  int? _getUserIdFromPrefs(SharedPreferences prefs) {
    return prefs.getInt('userId');
  }

  // -------------------- GET CART DATA --------------------
  Future<void> getCartData({bool forceRefresh = false}) async {
    isOrder.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      print("👤 userId in getCartData: $userId");

      if (userId == null) {
        _clearCartUi();
        return;
      }

      final cacheKey = 'cart_data_$userId';

      // Try to load from cache first (shorter duration for cart - 2 minutes)
      if (!forceRefresh) {
        final cached = await CacheManager.get(
          key: cacheKey,
          maxAge: const Duration(minutes: 2), // Shorter cache for cart
        );

        if (cached != null && cached is Map) {
          final cachedData = Map<String, dynamic>.from(cached);
          _restoreCartFromCache(cachedData);
          print("✅ Cart data loaded from cache for user: $userId");
          isOrder.value = false;
          return;
        }
      }

      final client = _ensureClient();

      final candidates = <Uri>[
        Uri.parse("${ApiConstants.baseUrl}/cart-items?userId=$userId"),
        Uri.parse("${ApiConstants.baseUrl}/users/$userId/cart-items"),
        Uri.parse("${ApiConstants.baseUrl}/cart-items/$userId"),
      ];

      Map<String, dynamic>? decoded;
      for (final uri in candidates) {
        print("🌐 Trying cart URL: $uri");
        final resp = await client.get(uri);
        final body = resp.body.trim();
        final looksLikeHtml = body.startsWith('<') ||
            body.toLowerCase().contains('<!doctype html');

        if (resp.statusCode == 200 && !looksLikeHtml) {
          decoded = json.decode(body) as dynamic;
          break;
        }

        if (resp.statusCode == 401) {
          getSnackBar("Session expired. Please login again.");
          Get.offAll(() => const LoginScreen(initialTab: 0));
          return;
        }
      }

      print("🔍 decoded is null: ${decoded == null}");
      if (decoded == null) {
        _clearCartUi();
        return;
      }

      final dynamic rawData =
          (decoded is Map ? decoded['data'] : decoded) ?? decoded;

// ✅ Handle nested structure: data.items OR data as list OR data as flat list
      final List<Map<String, dynamic>> rows = () {
        // New API: { data: { cart: {...}, items: [...] } }
        if (rawData is Map && rawData['items'] is List) {
          return (rawData['items'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        // Old API: { data: [...] }
        if (rawData is List) {
          return rawData
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        // Single item: { data: {...} }
        if (rawData is Map) return [Map<String, dynamic>.from(rawData)];
        return <Map<String, dynamic>>[];
      }();

// ✅ Also extract cart-level totals if available
      final cartMeta = (rawData is Map ? rawData['cart'] : null) as Map?;

      List<Map<String, dynamic>> normalized = rows.map((m) {
        final prod = (m['product'] ?? const {}) as Map;
        final pricing = (m['pricing'] ?? const {}) as Map;

        // ⭐ CORRECT product_variant block
        final rawVariant = (m['product_variant'] ?? const {}) as Map;

        final productVariant = {
          "id": rawVariant['id'],
          "price": rawVariant['price'], // base variant price
          "unitPrice": pricing['unitPrice'], // ⭐ NEW (GST-inclusive)
          "title": rawVariant['title'],
          "imageSrc": rawVariant['imageSrc'],
          "selectedOptions": rawVariant['selectedOptions'] ?? [],
        };

        // ⭐ Image wrapper
        List<Map<String, dynamic>> wrapImages(dynamic imgs) {
          final out = <Map<String, dynamic>>[];
          if (imgs == null) return out;
          if (imgs is String && imgs.trim().isNotEmpty)
            return [
              {"name": imgs.trim()}
            ];

          if (imgs is List) {
            for (final it in imgs) {
              if (it == null) continue;
              if (it is String && it.trim().isNotEmpty) {
                out.add({"name": it.trim()});
              } else if (it is Map) {
                final mm = Map<String, dynamic>.from(it);
                final val =
                    (mm["name"] ?? mm["url"] ?? mm["image"] ?? mm["src"] ?? "")
                        .toString();
                if (val.isNotEmpty) out.add({"name": val});
              }
            }
          }
          return out;
        }

        // ⭐ Extract size from selectedOptions
        String? sizeFromOpts(dynamic so) {
          if (so is List) {
            for (final it in so) {
              if (it is Map &&
                  (it['name']?.toString().toLowerCase() == 'size')) {
                final v = it['value']?.toString();
                if (v != null && v.isNotEmpty) return v;
              }
            }
          }
          return null;
        }

        final qty = (m['quantity'] is num)
            ? (m['quantity'] as num).toInt()
            : int.tryParse("${m['quantity']}") ?? 1;

        // ⭐ FINAL product map
        final product = <String, dynamic>{
          "id": m['productId'] ?? prod['id'],
          "name": (prod['title'] ?? prod['name'] ?? "").toString(),
          "brand_name": (prod['brand'] ?? prod['brand_name'] ?? "").toString(),
          "price":
              pricing['unitPrice'] ?? rawVariant['price'] ?? prod['price'] ?? 0,
          "mrp": rawVariant['compareAtPrice'] ?? prod['mrp'] ?? 0,
          "images": wrapImages(prod['imageUrls'] ?? prod['images']),
          "express_delivery": prod['express_delivery'] == true,
          "wishlisted": prod['wishlisted'] == true,
        };

        // ⭐ Inventory & size
        final stocksRaw = rawVariant['inventoryQuantity'];
        final stocks = (stocksRaw is num)
            ? stocksRaw.toInt()
            : int.tryParse("$stocksRaw") ?? 1;

        final inventory = <String, dynamic>{
          "id": m['variantId'] ?? rawVariant['id'],
          "stocks": stocks,
          "product_matrix_name_size":
              sizeFromOpts(rawVariant['selectedOptions']) ?? "",
        };

        // ⭐ Return everything including product_variant (CRITICAL!)
        return {
          "product": product,
          "inventory": inventory,
          "product_variant": productVariant,
          "quantity": qty,
          "id": m['id'],
          "status": m['status'],
        };
      }).toList();
      print("🔍 rows count: ${rows.length}");
      print("🔍 normalized after filter: ${normalized.length}");

      // ⭐ Filter invalid items
      normalized = normalized.where((row) {
        final p = row['product'] as Map?;
        final id = p?['id'];
        final nm = (p?['name'] ?? "").toString().trim();
        return id != null && nm.isNotEmpty;
      }).toList();

      if (normalized.isEmpty) {
        _clearCartUi();
        return;
      }

      orderList.assignAll(normalized);

      // ⭐ Compute totals
      double total = 0, totalMrp = 0;
      for (final l in normalized) {
        final q = (l['quantity'] ?? 1) as int;
        final s = l['product']?['price'] ?? 0;
        final m = l['product']?['mrp'] ?? 0;
        final selling =
            (s is num) ? s.toDouble() : double.tryParse("$s") ?? 0.0;
        final mrpVal = (m is num) ? m.toDouble() : double.tryParse("$m") ?? 0.0;

        total += selling * q;
        totalMrp += ((mrpVal > 0 ? mrpVal : selling) * q);
      }

      cartDetails.assignAll({
        "id": (rows.isNotEmpty
            ? (rows.first['cartId'] ?? rows.first['id'] ?? 0)
            : 0),
        "total": total.toStringAsFixed(2),
        "total_mrp": totalMrp.toStringAsFixed(2),
        "total_tax": cartDetails["total_tax"] ?? "0",
        "shipping_cost": cartDetails["shipping_cost"] ?? "0",
        "express_delivery_charges":
            cartDetails["express_delivery_charges"] ?? "0",
        "convenience_fee": cartDetails["convenience_fee"] ?? "0",
        "coupon_discount": cartDetails["coupon_discount"] ?? "0.00",
        "discount": cartDetails["discount"],
        "address": cartDetails["address"],
      });

      stockErrorText.value =
          orderList.any((i) => (i["inventory"]?["stocks"] ?? 1) == 0)
              ? "Few items are unavailable for checkout"
              : "";

      cartId.value = (cartDetails["id"] ?? 0) is int
          ? (cartDetails["id"] ?? 0)
          : int.tryParse("${cartDetails["id"]}") ?? 0;

      cartTotalValue.value = orderList.length;

      // ⭐ Restore persisted coupon
      final savedCode = prefs.getString('applied_coupon_code');
      final savedDiscount = prefs.getInt('applied_coupon_discount');

      if (savedCode != null && savedDiscount != null) {
        couponText.value = savedCode;
        cartDetails["coupon_discount"] = savedDiscount;
        cartDetails["discount"] = true;
      }

      // ✅ Cache the cart data
      await _cacheCartData(userId);

      debugPrint("🛒 Cart items parsed: ${orderList.length}");
    } catch (e, st) {
      debugPrint("❌ Exception in getCartData: $e\n$st");
      _clearCartUi();
      getSnackBar("check your network connection");
    } finally {
      isOrder.value = false;
      update();
    }
  }

  /// Cache cart data for quick access
  Future<void> _cacheCartData(int userId) async {
    try {
      final cacheData = {
        'orderList': orderList.toList(),
        'cartDetails': Map<String, dynamic>.from(cartDetails),
        'stockErrorText': stockErrorText.value,
        'cartId': cartId.value,
        'cartTotalValue': cartTotalValue.value,
      };
      await CacheManager.save(
        key: 'cart_data_$userId',
        data: cacheData,
        duration: const Duration(minutes: 2),
      );
    } catch (e) {
      print("⚠️ Failed to cache cart data: $e");
    }
  }

  /// Restore cart from cache
  void _restoreCartFromCache(Map<String, dynamic> cached) {
    try {
      if (cached['orderList'] != null && cached['orderList'] is List) {
        orderList.assignAll(List<Map<String, dynamic>>.from(
            (cached['orderList'] as List).whereType<Map>()));
      }

      if (cached['cartDetails'] != null && cached['cartDetails'] is Map) {
        cartDetails.assignAll(Map<String, dynamic>.from(cached['cartDetails']));
      }

      stockErrorText.value = cached['stockErrorText']?.toString() ?? '';
      cartId.value = cached['cartId'] ?? 0;
      cartTotalValue.value = cached['cartTotalValue'] ?? 0;

      update();
    } catch (e) {
      print("⚠️ Failed to restore cart from cache: $e");
    }
  }

  void _clearCartUi() {
    orderList.assignAll(const []);
    cartDetails.assignAll({
      "id": 0,
      "total": "0.00",
      "total_mrp": "0.00",
      "total_tax": "0",
      "shipping_cost": "0",
      "express_delivery_charges": "0",
      "convenience_fee": "0",
      "coupon_discount": "0.00",
      "discount": null,
      "address": null,
    });
    stockErrorText.value = "";
    couponText.value = "Apply Coupon";
    couponSave.value = "";
    cartId.value = 0;
    cartTotalValue.value = 0;
  }

  // -------------------- ADD TO CART --------------------
  Future<bool> callAddtoCart(
    int quantity,
    String page,
    int variantId,
    int productId,
    int expressValue,
    int type,
    Color backColor,
    int oldInventoryId, {
    double price = 0.0,
  }) async {
    if (page == "quantity" || page == "size") showLoading();
    isExpress.value = true;
    try {
      final client = _ensureClient();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null) {
        getSnackBar("User not found. Please log in.");
        return false;
      }

      int finalVariantId = variantId;
      final productController = Get.isRegistered<ProductController>()
          ? Get.find<ProductController>()
          : Get.put(ProductController());
      final selectedVariant = productController.getSelectedVariant();
      if (finalVariantId == 0 && selectedVariant != null) {
        finalVariantId = selectedVariant["id"];
        print("⚠️ Auto-fix: Using selected variant → $finalVariantId");
      }
      if (finalVariantId == 0) {
        print("❌ ERROR: variantId is still 0 → Add to cart blocked");
        getSnackBar("Please select size or color first.");
        return false;
      }
      print("🧩 FINAL VARIANT ID → $finalVariantId");

      final payload = {
        "userId": userId,
        "productId": productId,
        "variantId": finalVariantId,
        "quantity": quantity,
        "cartType": "ECOM"
      };
      final url = Uri.parse("${ApiConstants.baseUrl}/add-to-cart");
      print("🛰️ POST $url");
      print("➡️ Payload: $payload");

      final resp = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );
      print("🛰️ POST status: ${resp.statusCode}");
      final bodyText = resp.body.trim();

      if (resp.statusCode != 200 && resp.statusCode != 201) {
        print("❌ Add-to-cart failed: ${resp.statusCode}");
        print(bodyText);
        try {
          final errBody = json.decode(bodyText);
          final msg = errBody['message']?.toString() ?? 'Add to cart failed';
          getSnackBar(msg);
        } catch (_) {
          getSnackBar("Add to cart failed");
        }
        return false;
      }

      if (bodyText.startsWith('<')) {
        getSnackBar("Unexpected response from server");
        return false;
      }

      print("🛒 Added to cart successfully!");
      getSnackBar("Added to cart");
      MetaEventService.instance.logAddToCart(
        contentId: productId.toString(),
        price: price,
      );
      await CacheManager.invalidateCartCache(userId: userId);
      await getCartData(forceRefresh: true);
      return true;
    } catch (e) {
      print("❌ Exception in callAddtoCart: $e");
      getSnackBar("Something went wrong.");
      return false;
    } finally {
      if (page == "quantity" || page == "size") hideLoading();
      isExpress.value = false;
      update();
    }
  }

  // -------------------- UPDATE CART QUANTITY --------------------
  Future<bool> updateCartQuantity({
    required int productId,
    required int variantId,
    required int quantity,
  }) async {
    try {
      final client = _ensureClient();
      final prefs = await SharedPreferences.getInstance();
      final userId = _getUserIdFromPrefs(prefs);

      if (userId == null) {
        getSnackBar("User not found. Please log in again.");
        return false;
      }

      final payload = {
        "userId": userId,
        "productId": productId,
        "variantId": variantId,
        "quantity": quantity,
      };

      final url = Uri.parse("${ApiConstants.baseUrl}/cart/update-quantity");
      print("🛰️ PUT $url");
      print("➡️ Payload: $payload");

      final resp = await client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print("🛰️ Response status: ${resp.statusCode}");

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        print("✅ Cart quantity updated successfully");

        // ✅ Invalidate cart cache to fetch fresh data
        await CacheManager.invalidateCartCache(userId: userId);

        return true;
      } else if (resp.statusCode == 401) {
        getSnackBar("Unauthorized. Please log in again.");
        return false;
      } else {
        print("❌ Update quantity failed: ${resp.statusCode}");
        print("Response: ${resp.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception in updateCartQuantity: $e");
      return false;
    }
  }

  // -------------------- DELETE CART ITEM --------------------
  Future<void> callDeleteCart(Color backgroundColor, int productId,
      {int? variantId}) async {
    try {
      final client = _ensureClient();
      final prefs = await SharedPreferences.getInstance();
      final userId = _getUserIdFromPrefs(prefs);

      if (userId == null) {
        getSnackBar("User not found. Please log in again.");
        return;
      }

      final payload = {
        "userId": userId,
        "productId": productId,
      };

      // Add variantId if provided (required by new backend API)
      if (variantId != null) {
        payload["variantId"] = variantId;
      }

      print("🗑️ DELETE cart-item: $payload");

      final resp = await client.delete(
        Uri.parse("${ApiConstants.baseUrl}/cart-item"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (resp.statusCode == 200) {
        print("✅ Item deleted successfully from cart");

        // ✅ Invalidate cart cache to fetch fresh data
        await CacheManager.invalidateCartCache(userId: userId);

        if (backgroundColor == whiteColor) {
          await getCartData(forceRefresh: true);
        }
      } else if (resp.statusCode == 401) {
        getSnackBar("Unauthorized. Please log in again.");
      } else {
        getSnackBar("Failed to remove item.");
      }
    } catch (e) {
      print("❌ Exception in callDeleteCart: $e");
      getSnackBar("Failed to delete cart item.");
    }
  }

  // ==================== GUEST CART FUNCTIONS ====================
  // These functions handle cart operations for users who are not logged in.
  // Cart items are stored locally in SharedPreferences and synced after login.

  /// Check if user is in guest mode
  Future<bool> isGuestUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final token = prefs.getString('token');
    final skip = prefs.getBool('skip') ?? false;

    // Guest user if no userId/token OR skip flag is true
    return (userId == null || token == null || token.isEmpty) || skip;
  }

  /// Add item to guest cart (local storage) with complete product details
  Future<void> addToGuestCart({
    required int productId,
    required int variantId,
    required int quantity,
    Map<String, dynamic>? productDetails,
    Map<String, dynamic>? variantDetails,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing guest cart
      final cartJson = prefs.getString('guest_cart') ?? '[]';
      List<dynamic> guestCart = json.decode(cartJson);

      // Check if product+variant already exists
      final existingIndex = guestCart.indexWhere((item) =>
          item['productId'] == productId && item['variantId'] == variantId);

      if (existingIndex != -1) {
        // Update quantity and details
        guestCart[existingIndex]['quantity'] = quantity;
        if (productDetails != null) {
          guestCart[existingIndex]['product'] = productDetails;
        }
        if (variantDetails != null) {
          guestCart[existingIndex]['variant'] = variantDetails;
        }
        print("🛒 Guest Cart: Updated quantity for product $productId");
      } else {
        // Add new item with complete details
        guestCart.add({
          'productId': productId,
          'variantId': variantId,
          'quantity': quantity,
          'product': productDetails,
          'variant': variantDetails,
        });
        print("🛒 Guest Cart: Added product $productId to guest cart");
      }

      // Save back to SharedPreferences
      await prefs.setString('guest_cart', json.encode(guestCart));

      // Update cart count
      cartTotalValue.value = guestCart.length;

      getSnackBar("Added to cart");
      print("✅ Guest cart saved: ${guestCart.length} items");
    } catch (e) {
      print("❌ Error adding to guest cart: $e");
      getSnackBar("Failed to add item to cart");
    }
  }

  /// Get guest cart items from local storage
  Future<List<Map<String, dynamic>>> getGuestCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('guest_cart') ?? '[]';
      List<dynamic> guestCart = json.decode(cartJson);

      return guestCart.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print("❌ Error getting guest cart: $e");
      return [];
    }
  }

  /// Remove item from guest cart
  Future<void> removeFromGuestCart(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('guest_cart') ?? '[]';
      List<dynamic> guestCart = json.decode(cartJson);

      // Remove item
      guestCart.removeWhere((item) => item['productId'] == productId);

      // Save back
      await prefs.setString('guest_cart', json.encode(guestCart));

      // Update cart count
      cartTotalValue.value = guestCart.length;

      print("🗑️ Guest Cart: Removed product $productId from local storage");
      print("📦 Guest Cart: ${guestCart.length} items remaining");
      getSnackBar("Item removed from cart");
    } catch (e) {
      print("❌ Error removing from guest cart: $e");
      getSnackBar("Failed to remove item");
    }
  }

  /// Get guest cart count
  Future<int> getGuestCartCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('guest_cart') ?? '[]';
      List<dynamic> guestCart = json.decode(cartJson);
      return guestCart.length;
    } catch (e) {
      print("❌ Error getting guest cart count: $e");
      return 0;
    }
  }

  /// Clear guest cart (used after sync)
  Future<void> clearGuestCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('guest_cart');
      cartTotalValue.value = 0;
      print("🧹 Guest cart cleared");
    } catch (e) {
      print("❌ Error clearing guest cart: $e");
    }
  }

  /// Sync guest cart to server after login/signup
  /// This function is called automatically after successful authentication
  Future<bool> syncGuestCartToServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        print("⚠️ Cannot sync: userId not found");
        return false;
      }

      // Get guest cart items
      final guestCartItems = await getGuestCartItems();

      if (guestCartItems.isEmpty) {
        print("ℹ️ No guest cart items to sync");
        return true;
      }

      print(
          "🔄 Syncing ${guestCartItems.length} guest cart items to server...");

      // Prepare payload for sync API
      final payload = {
        "userId": userId,
        "items": guestCartItems
            .map((item) => {
                  "productId": item['productId'],
                  "variantId": item['variantId'],
                  "quantity": item['quantity'] ?? 1,
                })
            .toList(),
      };

      final client = _ensureClient();
      final url = Uri.parse("${ApiConstants.baseUrl}/cart/sync");

      print("🛰️ POST $url");
      print("➡️ Payload: ${json.encode(payload)}");

      final response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      print("🛰️ Sync response status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Guest cart synced successfully!");

        // Clear guest cart after successful sync
        await clearGuestCart();

        // Fetch the updated cart from server
        await getCartData();

        getSnackBar("Cart items synced successfully");
        return true;
      } else {
        print("❌ Cart sync failed: ${response.statusCode}");
        print("Response: ${response.body}");

        // Don't clear guest cart if sync failed
        getSnackBar("Failed to sync cart items");
        return false;
      }
    } catch (e, st) {
      print("❌ Exception in syncGuestCartToServer: $e\n$st");
      getSnackBar("Error syncing cart items");
      return false;
    }
  }

  // Wrapper for add to cart that handles both guest and logged-in users

  Future<bool> addToCartUniversal({
    required int quantity,
    required String page,
    required int variantId,
    required int productId,
    required int expressValue,
    required int type,
    required Color backColor,
    required int oldInventoryId,
    double price = 0.0,
  }) async {
    final isGuest = await isGuestUser();

    if (isGuest) {
      print("🎭 User is guest, adding to local cart");
      if (page == "quantity" || page == "size") showLoading();
      try {
        int finalVariantId = variantId;
        if (finalVariantId == 0) {
          final productController = Get.isRegistered<ProductController>()
              ? Get.find<ProductController>()
              : Get.put(ProductController());
          final selectedVariant = productController.getSelectedVariant();
          if (selectedVariant != null) {
            finalVariantId = selectedVariant["id"];
          } else {
            getSnackBar("Please select size or color first.");
            return false;
          }
        }

        final productController = Get.isRegistered<ProductController>()
            ? Get.find<ProductController>()
            : null;
        Map<String, dynamic>? productDetails;
        Map<String, dynamic>? variantDetails;

        if (productController != null &&
            productController.productDetails.isNotEmpty) {
          try {
            final currentProduct = Map<String, dynamic>.from(
                json.decode(json.encode(productController.productDetails)));
            productDetails = {
              'id': currentProduct['id'],
              'title': currentProduct['title'] ?? '',
              'imageUrls': currentProduct['imageUrls'] ?? [],
              'brandId': currentProduct['brandId'],
              'brand': currentProduct['brand'],
            };
            final variants = currentProduct['variants'] as List? ?? [];
            final variant = variants.firstWhere(
              (v) => v['id'] == finalVariantId,
              orElse: () => null,
            );
            if (variant != null) {
              variantDetails = {
                'id': variant['id'],
                'size': variant['size'],
                'color': variant['color'],
                'lfMsp': variant['lfMsp'] ?? currentProduct['lfMsp'],
                'price': variant['price'] ?? currentProduct['lfMsp'],
                'mrp': variant['mrp'] ?? currentProduct['mrp'],
                'compareAtPrice':
                    variant['compareAtPrice'] ?? currentProduct['mrp'],
                'inventory': variant['inventory'],
              };
              print(
                  "💾 Storing variant for guest cart: id=${variant['id']}, lfMsp=${variantDetails!['lfMsp']}, price=${variantDetails['price']}, mrp=${variantDetails['mrp']}");
            }
          } catch (e) {
            print('⚠️ Error extracting product details: $e');
          }
        }

        await addToGuestCart(
          productId: productId,
          variantId: finalVariantId,
          quantity: quantity,
          productDetails: productDetails,
          variantDetails: variantDetails,
        );
        return true;
      } catch (e) {
        print("❌ Error in guest add to cart: $e");
        return false;
      } finally {
        if (page == "quantity" || page == "size") hideLoading();
      }
    } else {
      print("👤 User is logged in, adding to server cart");
      return await callAddtoCart(
        quantity,
        page,
        variantId,
        productId,
        expressValue,
        type,
        backColor,
        oldInventoryId,
        price: price,
      );
    }
  }

  /// Wrapper for delete cart that handles both guest and logged-in users
  Future<void> deleteFromCartUniversal(Color backgroundColor, int productId,
      {int? variantId}) async {
    final isGuest = await isGuestUser();

    if (isGuest) {
      print("🎭 User is guest, removing from local cart");
      await removeFromGuestCart(productId);

      // Reload guest cart UI if on cart screen
      if (backgroundColor == whiteColor) {
        await loadGuestCartForDisplay();
      }
    } else {
      print("👤 User is logged in, removing from server cart");
      await callDeleteCart(backgroundColor, productId, variantId: variantId);
    }
  }

  /// Load guest cart for display in cart screen (fetch fresh data from API for real-time stock)
  Future<void> loadGuestCartForDisplay() async {
    isOrder.value = true;
    try {
      final guestCartItems = await getGuestCartItems();

      if (guestCartItems.isEmpty) {
        print("📦 Guest cart is empty");
        _clearCartUi();
        return;
      }

      print("📦 Loading ${guestCartItems.length} guest cart items for display");

      final client = _ensureClient();

      // Transform guest cart items to match orderList format
      List<Map<String, dynamic>> cartProducts = [];

      for (var item in guestCartItems) {
        try {
          final productId = item['productId'];
          final variantId = item['variantId'];
          final quantity = item['quantity'] ?? 1;

          if (productId == null || variantId == null) {
            print("⚠️ Skipping item without productId or variantId");
            continue;
          }

          // Fetch fresh product data from API for real-time stock information
          final url = Uri.parse("${ApiConstants.baseUrl}/products/$productId");
          print("🌐 Fetching product data for guest cart: $url");

          Map<String, dynamic>? product;
          Map<String, dynamic>? variant;

          try {
            final response = await client.get(url);

            if (response.statusCode == 200) {
              final productData = json.decode(response.body);
              product = productData is Map && productData['data'] != null
                  ? (productData['data'] as Map<String, dynamic>)
                  : (productData as Map<String, dynamic>?);

              if (product != null) {
                // Find the specific variant
                final variants = product['variants'] as List? ?? [];
                variant = variants.firstWhere(
                  (v) => v['id'] == variantId,
                  orElse: () => null,
                ) as Map<String, dynamic>?;
              }
            }
          } catch (e) {
            print("⚠️ API error fetching product $productId: $e");
          }

          // Fallback to stored data if API fails or returns no data
          if (product == null || variant == null) {
            print("📦 Using stored data as fallback for product $productId");
            final storedProduct = item['product'] as Map<String, dynamic>?;
            final storedVariant = item['variant'] as Map<String, dynamic>?;

            if (storedProduct != null && storedVariant != null) {
              product = storedProduct;
              variant = storedVariant;
            } else {
              print(
                  "⚠️ No stored data available for product $productId, skipping");
              continue;
            }
          }

          if (product == null || variant == null) {
            print("⚠️ Could not load product $productId");
            continue;
          }

          // Parse price values safely
          num parsePrice(dynamic value) {
            if (value == null) return 0;
            if (value is num) return value;
            if (value is String) return num.tryParse(value) ?? 0;
            return 0;
          }

          // Image wrapper function (same as logged-in cart)
          List<Map<String, dynamic>> wrapImages(dynamic imgs) {
            final out = <Map<String, dynamic>>[];
            if (imgs == null) return out;
            if (imgs is String && imgs.trim().isNotEmpty)
              return [
                {"name": imgs.trim()}
              ];

            if (imgs is List) {
              for (final it in imgs) {
                if (it == null) continue;
                if (it is String && it.trim().isNotEmpty) {
                  out.add({"name": it.trim()});
                } else if (it is Map) {
                  final mm = Map<String, dynamic>.from(it);
                  final val = (mm["name"] ??
                          mm["url"] ??
                          mm["image"] ??
                          mm["src"] ??
                          "")
                      .toString();
                  if (val.isNotEmpty) out.add({"name": val});
                }
              }
            }
            return out;
          }

          // Extract brand name - handle both string and object formats
          String getBrandName(dynamic brand) {
            if (brand == null) return '';
            if (brand is String) return brand;
            if (brand is Map) {
              return (brand['name'] ?? brand['title'] ?? '').toString();
            }
            return brand.toString();
          }

          // Get price from variant - try multiple sources
          // Priority:
          // 1. Stored variant fields (lfMsp, price)
          // 2. API variant fields (price, lfMsp)
          // 3. API product-level fields (lfMsp, msp)
          final variantPrice = parsePrice(variant['lfMsp'] ??
              variant['price'] ??
              product['lfMsp'] ??
              product['msp'] ??
              variant['sellingPrice'] ??
              0);

          // Get MRP from variant or product level
          final variantMrp = parsePrice(variant['mrp'] ??
              variant['compareAtPrice'] ??
              product['mrp'] ??
              variant['originalPrice'] ??
              variantPrice);

          // Debug: Log what fields are available in variant
          print(
              "🔍 Variant $variantId fields: lfMsp=${variant['lfMsp']}, price=${variant['price']}, mrp=${variant['mrp']}");
          print(
              "🔍 Product-level: lfMsp=${product['lfMsp']}, msp=${product['msp']}, mrp=${product['mrp']}");
          print("💵 Computed prices: selling=$variantPrice, mrp=$variantMrp");

          // Transform to match the format expected by cartscreen (EXACTLY like logged-in cart)
          final transformedProduct = {
            'id': product['id'] ?? productId,
            'name': (product['title'] ?? product['name'] ?? '').toString(),
            'brand_name':
                '', // Empty to match logged-in cart UI (only shows product name)
            'price': variantPrice,
            'mrp': variantMrp,
            'images': wrapImages(product['imageUrls'] ?? product['images']),
            'express_delivery': product['express_delivery'] == true,
            'wishlisted': product['wishlisted'] == true,
          };

          // Get REAL stock from backend (fresh data!)
          // Try multiple possible field names for inventory (prioritize inventoryQuantity to match logged-in flow)
          dynamic invValue = variant['inventoryQuantity'] ??
              variant['inventory'] ??
              variant['stock'] ??
              variant['stocks'];

          int stock = 0;
          if (invValue != null) {
            // If inventory is an object (like from stored data), extract the stock value
            if (invValue is Map) {
              invValue = invValue['availableStock'] ??
                  invValue['stock'] ??
                  invValue['stocks'] ??
                  invValue['inventoryQuantity'];
            }

            if (invValue is int) {
              stock = invValue;
            } else if (invValue is num) {
              stock = invValue.toInt();
            } else if (invValue is String) {
              stock = int.tryParse(invValue) ?? 0;
            } else {
              // Sometimes stock might be negative, treat as 0
              stock = 0;
            }
          }

          // Ensure stock is at least 1 if variant exists (prevent false "out of stock")
          if (stock == 0) {
            print(
                "⚠️ Stock is 0 for variant $variantId, checking if this is an error...");
            // If the variant exists in the API response, assume at least 1 in stock
            // This prevents false "OUT OF STOCK" errors when API doesn't return inventory data
            stock = 1;
          }

          print(
              "📊 Product: ${product['title']}, Variant: $variantId, Stock: $stock (raw: $invValue)");
          print(
              "💰 Price: ${transformedProduct['price']}, MRP: ${transformedProduct['mrp']}");
          print(
              "🏷️ Name: ${transformedProduct['name']}, Brand: ${transformedProduct['brand_name']}");
          print("🖼️ Images: ${transformedProduct['images']}");

          final transformedInventory = {
            'id': variant['id'] ?? variantId,
            'stocks': stock, // Use real stock from backend
            'product_matrix_name_size': variant['size']?.toString() ?? '',
          };

          final transformedVariant = {
            'id': variant['id'] ?? variantId,
            'price': variantPrice, // Use the already computed price
            'title': '${product['title'] ?? ''} - ${variant['size'] ?? ''}',
            'imageSrc': '',
            'selectedOptions': [
              if (variant['size'] != null &&
                  variant['size'].toString().isNotEmpty)
                {'name': 'size', 'value': variant['size'].toString()},
              if (variant['color'] != null &&
                  variant['color'].toString().isNotEmpty)
                {'name': 'color', 'value': variant['color'].toString()},
            ],
          };

          cartProducts.add({
            'id': 0, // Guest cart items don't have cart item IDs
            'quantity': quantity,
            'product': transformedProduct,
            'inventory': transformedInventory,
            'product_variant': transformedVariant,
            'status': 'active',
          });
          print(
              "✅ Loaded product: ${transformedProduct['name']} (Stock: $stock)");
        } catch (e) {
          print("⚠️ Error loading cart item: $e");
          continue;
        }
      }

      print("📊 Total products loaded: ${cartProducts.length}");

      if (cartProducts.isNotEmpty) {
        // Populate orderList with guest cart products
        orderList.value = cartProducts;
        cartTotalValue.value = cartProducts.length;

        // Calculate totals
        num totalPrice = 0;
        num totalMrp = 0;
        for (var item in cartProducts) {
          final quantity = item['quantity'] ?? 1;
          final price = item['product']['price'] ?? 0;
          final mrp = item['product']['mrp'] ?? 0;
          totalPrice += price * quantity;
          totalMrp += (mrp > 0 ? mrp : price) * quantity;
        }

        // Update cart details
        cartDetails.value = {
          'id': 0,
          'total': totalPrice.toStringAsFixed(2),
          'total_mrp': totalMrp.toStringAsFixed(2),
          'total_tax': '0',
          'shipping_cost': '0',
          'express_delivery_charges': '0',
          'convenience_fee': '0',
          'coupon_discount': '0.00',
          'discount': null,
          'address': null,
        };

        print(
            "✅ Guest cart loaded: ${cartProducts.length} products, total: ₹$totalPrice");
        print("📦 OrderList updated with ${orderList.length} items");
      } else {
        print("⚠️ No valid products found in guest cart");
        _clearCartUi();
      }
    } catch (e, st) {
      print("❌ Exception in loadGuestCartForDisplay: $e\n$st");
      _clearCartUi();
    } finally {
      isOrder.value = false;
      update();
    }
  }

  /// Fetch cart banners from API
  /// Endpoint: /banners?isCartBanner=true
  Future<void> getCartBanners({bool forceRefresh = false}) async {
    final cacheKey = 'cart_banners';

    // ✅ Set loading state
    isLoadingCartBanners.value = true;

    try {
      // 🔹 Try cache first
      if (!forceRefresh) {
        final cached = await CacheManager.get(key: cacheKey);
        if (cached != null) {
          cartBannerList.assignAll(cached as List<dynamic>);
          print("✅ Cart banners loaded from cache: ${cartBannerList.length}");
          isLoadingCartBanners.value = false;
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final token = (prefs.getString('token') ?? '').trim();

      // ✅ Cart banners API with isCartBanner=true query
      final uri = Uri.parse("${ApiConstants.baseUrl}/banners")
          .replace(queryParameters: {'isCartBanner': 'true'});

      print("📤 Hitting cart banners API: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("📥 Cart Banner Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> all = (decoded['data'] as List?) ?? const [];

        print("📊 Total cart banners from API: ${all.length}");

        // ✅ Filter only active banners with mobileImage
        final List<dynamic> filtered = all.where((b) {
          if (b is! Map) return false;

          final isActive = b['isActive'] == true;
          final mobileImage = (b['mobileImage']?.toString() ?? '').trim();
          final hasImage = mobileImage.isNotEmpty;

          print("🔎 Cart Banner: isActive=$isActive, hasImage=$hasImage");

          return isActive && hasImage;
        }).toList();

        print("✅ Filtered cart banners: ${filtered.length}");

        // ✅ Cache filtered data
        await CacheManager.save(key: cacheKey, data: filtered);

        // ✅ Update UI list
        cartBannerList.assignAll(filtered);

        print("✅ Cart banners updated successfully");
      } else if (response.statusCode == 401) {
        print("⚠️ Cart banners auth failed");
      } else {
        print("⚠️ Cart banners fetch failed: ${response.statusCode}");
      }
    } catch (e, st) {
      print("❌ Cart banner fetch exception: $e\n$st");
    } finally {
      isLoadingCartBanners.value = false;
    }
  }
}
