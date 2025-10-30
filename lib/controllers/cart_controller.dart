// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/loginscreen.dart';
import '../screens/paymentcheckscreen.dart';
import '../screens/paymentsuccessscreen.dart';
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
  Future<void> getCartData() async {
    isOrder.value = true;
    try {
      final client = _ensureClient();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        _clearCartUi();
        return;
      }

      final candidates = <Uri>[
        Uri.parse("${ApiConstants.baseUrl}/cart-items?userId=$userId"),
        Uri.parse("${ApiConstants.baseUrl}/users/$userId/cart-items"),
        Uri.parse("${ApiConstants.baseUrl}/cart-items/$userId"),
      ];

      Map<String, dynamic>? decoded;
      for (final uri in candidates) {
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

      if (decoded == null) {
        _clearCartUi();
        return;
      }

      final dynamic data =
          (decoded is Map ? decoded['data'] : decoded) ?? decoded;
      final List<Map<String, dynamic>> rows = () {
        if (data is List)
          return data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        if (data is Map) return [Map<String, dynamic>.from(data)];
        return <Map<String, dynamic>>[];
      }();

      List<Map<String, dynamic>> normalized = rows.map((m) {
        final prod = (m['product'] ?? const {}) as Map;
        final variant = (m['product_variant'] ?? const {}) as Map;

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
              if (it is String && it.trim().isNotEmpty)
                out.add({"name": it.trim()});
              if (it is Map) {
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

        final product = <String, dynamic>{
          "id": m['productId'] ?? prod['id'],
          "name": (prod['title'] ?? prod['name'] ?? "").toString(),
          "brand_name": (prod['brand'] ?? prod['brand_name'] ?? "").toString(),
          "price": variant['price'] ?? prod['price'] ?? 0,
          "mrp": variant['compareAtPrice'] ?? prod['mrp'] ?? 0,
          "images": wrapImages(prod['imageUrls'] ?? prod['images']),
          "express_delivery": prod['express_delivery'] == true,
          "wishlisted": prod['wishlisted'] == true,
        };

        final stocksRaw = variant['inventoryQuantity'];
        final stocks = (stocksRaw is num)
            ? stocksRaw.toInt()
            : int.tryParse("$stocksRaw") ?? 1;

        final inventory = <String, dynamic>{
          "id": m['variantId'] ?? variant['id'],
          "stocks": stocks,
          "product_matrix_name_size":
              sizeFromOpts(variant['selectedOptions']) ?? "",
        };

        return {
          "product": product,
          "inventory": inventory,
          "quantity": qty,
          "id": m['id'],
          "status": m['status'],
        };
      }).toList();

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

      double total = 0, totalMrp = 0;
      for (final l in normalized) {
        final q = (l['quantity'] ?? 1) as int;
        final s = l['product']?['price'] ?? 0;
        final m = l['product']?['mrp'] ?? 0;
        final selling =
            (s is num) ? s.toDouble() : double.tryParse("$s") ?? 0.0;
        final mrp = (m is num) ? m.toDouble() : double.tryParse("$m") ?? 0.0;
        total += selling * q;
        totalMrp += ((mrp > 0 ? mrp : selling) * q);
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

      // ✅ Restore persisted coupon
      final savedCode = prefs.getString('applied_coupon_code');
      final savedDiscount = prefs.getInt('applied_coupon_discount');
      if (savedCode != null && savedDiscount != null) {
        couponText.value = savedCode;
        cartDetails["coupon_discount"] = savedDiscount;
        cartDetails["discount"] = true;
      }

      debugPrint("🛒 Cart items parsed: ${orderList.length}");
    } catch (e, st) {
      debugPrint("❌ Exception in getCartData: $e\n$st");
      _clearCartUi();
      getSnackBar("Error loading cart");
    } finally {
      isOrder.value = false;
      update();
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
  callAddtoCart(
    int quantity,
    String page,
    int variantId,
    int productId,
    int expressValue,
    int type,
    Color backColor,
    int oldInvertoryId,
  ) async {
    if (page == "quantity" || page == "size") showLoading();
    isExpress.value = true;

    try {
      final client = _ensureClient();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null) {
        getSnackBar("User not found. Please log in.");
        return;
      }

      final payload = {
        "userId": userId,
        "productId": productId,
        "variantId": variantId,
        "quantity": quantity,
      };
      final url = Uri.parse("${ApiConstants.baseUrl}/add-to-cart");
      print("🛰️ POST $url\n➡️ $payload");

      final resp = await client.post(url, body: json.encode(payload));
      final bodyText = resp.body.trim();
      print("🛰️ POST status: ${resp.statusCode}");
      if (resp.statusCode != 200 && resp.statusCode != 201) {
        print("❌ Add-to-cart failed: ${resp.statusCode}\n$bodyText");
        getSnackBar("Add to cart failed");
        return;
      }

      if (bodyText.startsWith('<')) {
        getSnackBar("Unexpected response from server");
        return;
      }

      if (backColor == whiteColor) {
        await getCartData();
      }
    } catch (e) {
      print("❌ Exception in callAddtoCart: $e");
      getSnackBar("Something went wrong.");
    } finally {
      if (page == "quantity" || page == "size") hideLoading();
      isExpress.value = false;
      update();
    }
  }

  // -------------------- DELETE CART ITEM --------------------
  Future<void> callDeleteCart(Color backgroundColor, int productId) async {
    try {
      final client = _ensureClient();
      final prefs = await SharedPreferences.getInstance();
      final userId = _getUserIdFromPrefs(prefs);

      if (userId == null) {
        getSnackBar("User not found. Please log in again.");
        return;
      }

      final resp = await client.delete(
        Uri.parse("${ApiConstants.baseUrl}/cart-item"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "userId": userId,
          "productId": productId,
        }),
      );

      if (resp.statusCode == 200) {
        if (backgroundColor == whiteColor) {
          await getCartData();
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

  // -------------------- PAYMENT FLOW --------------------
  Future<void> callInitiatePayment(int addressId, Razorpay razorpay) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/orders/${cartId.value}/payment"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        final options = {
          'key': ApiConstants.razorPayKey,
          'amount': double.parse(responseData["payment"]["amount"]) * 100,
          'name': 'Lafetch',
          'order_id': responseData["payment"]["transaction_id"],
          'description': 'Lafetch Customer',
          'theme': {'color': '#070707'},
          "prefill": {"contact": userNumber.value},
          'fullscreen': true,
        };
        razorpay.open(options);
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  Future<void> callProcessPayment(
    int cartId,
    String paymentId,
    String orderId,
    String signature,
  ) async {
    isPayment.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      final body = json.encode({
        "razorpay_payment_id": paymentId,
        "razorpay_order_id": orderId,
        "razorpay_signature": signature,
      });
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/orders/$cartId/process-payment"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.to(PaymentSuccessScreen(
          text1: "Order Placed Successfully",
          orderId: cartId,
          text2: "Thank you for placing your order",
          image: orderSucessImage,
        ));
      } else {
        Get.to(PaymentCheckScreen(orderId: cartId));
      }
    } catch (e) {
      print(e.toString());
    }
    isPayment.value = false;
  }

  Future<void> callPaymentStatus(int cartId, Timer timer) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/order/$cartId/check-status"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      if (response.statusCode == 200) {
        timer.cancel();
        Get.off(PaymentSuccessScreen(
          text1: "Order Placed Successfully",
          orderId: cartId,
          text2: "Thank you for placing your order",
          image: orderSucessImage,
        ));
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
