// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/loginscreen.dart';
import 'base_controller.dart';

class OrderController extends BaseController {
  // ---------- UI / State ----------
  RxBool isPlacingOrder = false.obs;
  RxBool isOrderHistory = false.obs;
  RxBool isRequestingCancel = false.obs;
  RxBool isRequestingExchange = false.obs;
  RxBool isRequestingReturn = false.obs;
  RxBool isExchangeHistory = false.obs;
  RxBool isReturnHistory = false.obs;

  RxString apiError = "".obs;
// Inside ProductController
  RxBool isEstimateDate = false.obs;
  RxString estimatedDate = "".obs;
  RxString estimatedDays = "".obs;
  RxString courierName = "".obs;
  // Lists & details
  // List orderHistory = [].obs; // from /order-history/{userId}
  RxList orderHistory = [].obs;

  List exchangeHistory = [].obs; // from /exchange-history/{userId}
  List returnHistory = [].obs; // from /return-history/{userId}

  // Optional review state you had
  RxDouble rating = 0.0.obs;
  final comment = TextEditingController();

  // Search/filter placeholders (kept if your UI binds to them)
  RxString queryText = "".obs;
  RxInt status = 0.obs;

  // ---------- Helpers ----------
  Map<String, String> _headersWithToken(String? token,
      {bool jsonBody = false}) {
    return <String, String>{
      'Accept': 'application/json; charset=UTF-8',
      if (jsonBody) 'Content-Type': 'application/json; charset=UTF-8',
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  bool _handleAuthGuard(int code) {
    if (code == 401) {
      getSnackBar("Authentication failed");
      Get.offAll(() => const LoginScreen(initialTab: 0));
      return true;
    }
    return false;
  }

// Updated initiatePayment method with proper payload structure

  Future<Map<String, dynamic>?> initiatePayment({
    required int userId,
    required int shippingAddressId,
    required List<Map<String, dynamic>> items,
    required num totalMRP,
    required num couponDiscount,
    required num tax,
    required num total,
    required String paymentMethod,
    String? mode,
    int? productId,
    int? variantId,
    int? quantity,
    num? shippingCost,
    String? couponCode,
  }) async {
    isPlacingOrder.value = true;
    apiError.value = "";
    showLoading();

    final prefs = await SharedPreferences.getInstance();

    try {
      // ── STEP 1: Initiate Checkout Session ──────────────────────
      final initiateUri =
          Uri.parse("${ApiConstants.baseUrl}/checkout/initiate");

      final initiateBody = {
        "mode": mode ?? "cart",
        if (productId != null) "productId": productId,
        if (variantId != null) "variantId": variantId,
        if (quantity != null) "quantity": quantity,
        if (couponCode != null && couponCode.isNotEmpty)
          "couponCode": couponCode,
      };

      print("📤 STEP 1 - Initiating checkout:");
      print(jsonEncode(initiateBody));

      final initiateRes = await http.post(
        initiateUri,
        headers: _headersWithToken(prefs.getString('token'), jsonBody: true),
        body: jsonEncode(initiateBody),
      );

      print("📥 Initiate status: ${initiateRes.statusCode}");
      print("📥 Initiate body: ${initiateRes.body}");

      if (_handleAuthGuard(initiateRes.statusCode)) return null;

      if (initiateRes.statusCode != 200 && initiateRes.statusCode != 201) {
        try {
          final error = jsonDecode(initiateRes.body);
          apiError.value = error["message"] ?? "Checkout initiation failed";
        } catch (_) {
          apiError.value =
              "Checkout initiation failed (${initiateRes.statusCode})";
        }
        getSnackBar(apiError.value);
        return null;
      }

      final initiateData = jsonDecode(initiateRes.body);
      final checkoutSessionId = initiateData["data"]?["checkoutSessionId"];

      if (checkoutSessionId == null) {
        getSnackBar("Failed to create checkout session.");
        return null;
      }

      print("✅ Checkout session created: $checkoutSessionId");
      await prefs.setString("checkoutSessionId", checkoutSessionId);

      // ── STEP 2: Set Shipping Address → gets Razorpay Order ID ──
      final setAddressUri =
          Uri.parse("${ApiConstants.baseUrl}/checkout/address");

      final setAddressBody = {
        "checkoutSessionId": checkoutSessionId,
        "addressId": shippingAddressId,
      };

      print("📤 STEP 2 - Setting shipping address:");
      print(jsonEncode(setAddressBody));

      final setAddressRes = await http.post(
        setAddressUri,
        headers: _headersWithToken(prefs.getString('token'), jsonBody: true),
        body: jsonEncode(setAddressBody),
      );

      print("📥 SetAddress status: ${setAddressRes.statusCode}");
      print("📥 SetAddress body: ${setAddressRes.body}");

      if (_handleAuthGuard(setAddressRes.statusCode)) return null;

      if (setAddressRes.statusCode != 200 && setAddressRes.statusCode != 201) {
        try {
          final error = jsonDecode(setAddressRes.body);
          apiError.value = error["message"] ?? "Failed to set shipping address";
        } catch (_) {
          apiError.value =
              "Failed to set shipping address (${setAddressRes.statusCode})";
        }
        getSnackBar(apiError.value);
        return null;
      }

      final setAddressData = jsonDecode(setAddressRes.body);
      final providerOrderId = setAddressData["data"]?["razorpayOrderId"];

      if (providerOrderId == null) {
        getSnackBar("Failed to create payment order. Please try again.");
        return null;
      }

      print("✅ Razorpay order created: $providerOrderId");

      return {
        "providerOrderId": providerOrderId,
        "checkoutSessionId": checkoutSessionId,
      };
    } catch (e) {
      apiError.value = "Network error: ${e.toString()}";
      print("🔥 initiatePayment error: $e");
      getSnackBar("Network error. Please check your internet connection.");
      return null;
    } finally {
      hideLoading();
      isPlacingOrder.value = false;
    }
  }

// ========================================
// HELPER: Build Order Item
// ========================================

  Map<String, dynamic> buildOrderItem({
    required int productId,
    required int variantId,
    required int quantity,
    required num unitPrice,
    required num discount,
    required num total,
    required num tax,
    required num gstAmount,
    required String hsnCode,
    required num gstRate,
    required num statutoryGSTRate,
    required String gstRuleApplied,
  }) {
    return {
      "productId": productId,
      "variantId": variantId,
      "quantity": quantity,
      "unitPrice": unitPrice.round(),
      "discount": discount.round(),
      "total": total.round(),
      "tax": tax.round(),
      "gstAmount": gstAmount.round(),
      "hsnCode": hsnCode,
      "gstRate": gstRate,
      "statutoryGSTRate": statutoryGSTRate,
      "gstRuleApplied": gstRuleApplied,
    };
  }

  Future<bool> confirmPlaceOrder({
    required String providerOrderId,
    required String providerPaymentId,
    required String providerSignature,
  }) async {
    isPlacingOrder.value = true;
    apiError.value = "";
    showLoading();

    final prefs = await SharedPreferences.getInstance();

    try {
      final localCheckoutSessionId = prefs.getString("checkoutSessionId");

      print("🔍 confirmPlaceOrder DEBUG:");
      print("   checkoutSessionId: $localCheckoutSessionId");
      print("   token: ${prefs.getString('token')}");

      if (localCheckoutSessionId == null) {
        print("❌ Missing checkoutSessionId. Cannot confirm order.");
        getSnackBar("Order session missing. Please try again.");
        return false;
      }

      // ✅ Correct endpoint — matches checkoutService.confirmCheckout
      final uri = Uri.parse("${ApiConstants.baseUrl}/checkout/confirm");

      final body = {
        "checkoutSessionId": localCheckoutSessionId,
        "paymentInfo": {
          "providerOrderId": providerOrderId,
          "providerPaymentId": providerPaymentId,
          "providerSignature": providerSignature,
        },
      };

      print("📤 place-order URL: $uri");
      print("📤 place-order body: ${json.encode(body)}");

      final res = await http.post(
        uri,
        headers: _headersWithToken(prefs.getString('token'), jsonBody: true),
        body: json.encode(body),
      );

      print("📥 place-order status: ${res.statusCode}");
      print("📥 place-order body: ${res.body}");

      if (_handleAuthGuard(res.statusCode)) return false;

      if (res.statusCode == 200 || res.statusCode == 201) {
        await prefs.remove("orderId");
        await prefs.remove("checkoutSessionId");
        getSnackBar("Order placed successfully");
        return true;
      } else {
        try {
          final data = json.decode(res.body);
          apiError.value = data["message"] ??
              data["error"] ??
              "Order placement failed (${res.statusCode})";
        } catch (_) {
          apiError.value = "Order placement failed (${res.statusCode})";
        }
        print("❌ confirm failed: ${apiError.value}");
        getSnackBar(apiError.value);
        return false;
      }
    } catch (e) {
      print("🔥 confirmPlaceOrder error: $e");
      apiError.value = "Network error while confirming order";
      getSnackBar("Something went wrong. Please try again.");
      return false;
    } finally {
      hideLoading();
      isPlacingOrder.value = false;
    }
  }

  // ---------- 2) ORDER HISTORY ----------
  /// Calls: GET {{laFetchBaseUrl}}/order-history/{userId}
  Future<void> getOrderHistory(int userId) async {
    isOrderHistory.value = true;
    apiError.value = "";
    final prefs = await SharedPreferences.getInstance();
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/order-history/$userId");
      final res = await http.get(
        uri,
        headers: _headersWithToken(prefs.getString('token')),
      );

      if (_handleAuthGuard(res.statusCode)) return;

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        // Expecting list; adjust if your API wraps it
        orderHistory = (data is List) ? data : (data["data"] ?? []);
      } else {
        apiError.value = "Order history failed (${res.statusCode})";
        print(res.body);
        getSnackBar(apiError.value);
      }
    } catch (e) {
      apiError.value = e.toString();
      print("getOrderHistory error: $e");
      getSnackBar("Failed to load order history");
    } finally {
      isOrderHistory.value = false;
    }
  }

  // ---------- 3) REQUEST CANCEL ----------
  /// Calls: POST {{laFetchBaseUrl}}/request-cancel

  Future<bool> requestCancel({
    required int userId,
    required int orderItemId,
    required String reason,
    required String shipRocketId,
  }) async {
    isRequestingCancel.value = true;
    apiError.value = "";
    showLoading();

    final prefs = await SharedPreferences.getInstance();
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/request-cancel");
      final body = {
        "userId": userId,
        "orderItemId": orderItemId,
        "reason": reason,
        "shipRocketId": shipRocketId,
      };

      final res = await http.post(
        uri,
        headers: _headersWithToken(prefs.getString('token'), jsonBody: true),
        body: json.encode(body),
      );

      if (_handleAuthGuard(res.statusCode)) return false;

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = json.decode(res.body);
        final message = data['message'] ?? "Order cancelled successfully!";
        getSnackBar(message);
        return true;
      } else {
        apiError.value = "Cancel request failed (${res.statusCode})";
        print("API Error Response: ${res.body}");
        getSnackBar(apiError.value);
        return false;
      }
    } catch (e) {
      apiError.value = e.toString();
      print("requestCancel error: $e");
      getSnackBar("Failed to request cancellation");
      return false;
    } finally {
      hideLoading();
      isRequestingCancel.value = false;
    }
  }

  // ---------- 4) REQUEST x ----------
  /// Calls: POST {{laFetchBaseUrl}}/request-exchange

  Future<bool> requestExchange({
    required int orderItemId,
    required int userId,
    required int newVariantId,
    required String reason,
  }) async {
    isRequestingExchange.value = true;
    apiError.value = "";
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/request-exchange");
      final body = {
        "orderItemId": orderItemId,
        "userId": userId,
        "newVariantId": newVariantId,
        "reason": reason,
      };

      final res = await http.post(
        uri,
        headers: _headersWithToken(prefs.getString('token'), jsonBody: true),
        body: json.encode(body),
      );

      if (_handleAuthGuard(res.statusCode)) return false;

      if (res.statusCode == 200 || res.statusCode == 201) {
        getSnackBar("Exchange requested");
        return true;
      } else {
        apiError.value = "Exchange request failed (${res.statusCode})";
        print(res.body);
        getSnackBar(apiError.value);
        return false;
      }
    } catch (e) {
      apiError.value = e.toString();
      print("requestExchange error: $e");
      getSnackBar("Failed to request exchange");
      return false;
    } finally {
      hideLoading();
      isRequestingExchange.value = false;
    }
  }

  // ---------- 5) EXCHANGE HISTORY ----------
  /// Calls: GET {{laFetchBaseUrl}}/exchange-history/{userId}
  Future<void> getExchangeHistory(int userId) async {
    isExchangeHistory.value = true;
    apiError.value = "";
    final prefs = await SharedPreferences.getInstance();
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/exchange-history/$userId");
      final res = await http.get(
        uri,
        headers: _headersWithToken(prefs.getString('token')),
      );

      if (_handleAuthGuard(res.statusCode)) return;

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        exchangeHistory = (data is List) ? data : (data["data"] ?? []);
      } else {
        apiError.value = "Exchange history failed (${res.statusCode})";
        print(res.body);
        getSnackBar(apiError.value);
      }
    } catch (e) {
      apiError.value = e.toString();
      print("getExchangeHistory error: $e");
      getSnackBar("Failed to load exchange history");
    } finally {
      isExchangeHistory.value = false;
    }
  }

  // ---------- 6) REQUEST RETURN ----------

  Future<bool> requestReturn({
    required int orderItemId,
    required int userId,
    required String reason,
    required int addressId,
    required String shipRocketId,
  }) async {
    isRequestingReturn.value = true;
    apiError.value = "";
    showLoading();

    final prefs = await SharedPreferences.getInstance();

    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/request-return");

      /// MATCH EXACT API BODY ❗
      final body = {
        "orderItemId": orderItemId,
        "userId": userId,
        "reason": reason,
        "addressId": addressId,
        "shipRocketId": shipRocketId,
      };

      final res = await http.post(
        uri,
        headers: _headersWithToken(prefs.getString('token'), jsonBody: true),
        body: json.encode(body),
      );

      if (_handleAuthGuard(res.statusCode)) return false;

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = json.decode(res.body);
        getSnackBar(
            data['message'] ?? "Return request submitted successfully!");
        print("Return Response: ${res.body}");
        return true;
      } else {
        apiError.value = "Return request failed (${res.statusCode})";
        print("API Error Response: ${res.body}");
        getSnackBar(apiError.value);
        return false;
      }
    } catch (e) {
      apiError.value = e.toString();
      print("requestReturn error: $e");
      getSnackBar("Failed to request return");
      return false;
    } finally {
      hideLoading();
      isRequestingReturn.value = false;
    }
  }

  // ---------- 7) RETURN HISTORY ----------
  /// Calls: GET {{laFetchBaseUrl}}/return-history/{userId}
  Future<void> getReturnHistory(int userId) async {
    isReturnHistory.value = true;
    apiError.value = "";
    final prefs = await SharedPreferences.getInstance();
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/return-history/$userId");
      final res = await http.get(
        uri,
        headers: _headersWithToken(prefs.getString('token')),
      );

      if (_handleAuthGuard(res.statusCode)) return;

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        returnHistory = (data is List) ? data : (data["data"] ?? []);
      } else {
        apiError.value = "Return history failed (${res.statusCode})";
        print(res.body);
        getSnackBar(apiError.value);
      }
    } catch (e) {
      apiError.value = e.toString();
      print("getReturnHistory error: $e");
      getSnackBar("Failed to load return history");
    } finally {
      isReturnHistory.value = false;
    }
  }

  // ---------- Optional: simple validators reused from your old code ----------
  bool checkReviewValidation() {
    if (rating.value == 0.0) {
      getSnackBar("Rate the product");
      return false;
    }
    if (comment.text.toString().trim().isEmpty) {
      getSnackBar("Enter Review");
      return false;
    }
    return true;
  }

  // ---------- 8) GET ORDER HISTORY (by userId) ----------
  /// Calls: GET {{laFetchBaseUrl}}/order-history/{userId}
  Future<void> getOrderHistoryByUser(int userId) async {
    isOrderHistory.value = true;
    apiError.value = "";
    showLoading();

    final prefs = await SharedPreferences.getInstance();

    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/order-history/$userId");
      print("📦 Fetching order history for userId: $userId");

      final res = await http.get(
        uri,
        headers: _headersWithToken(prefs.getString('token')),
      );

      print("📥 Response status: ${res.statusCode}");
      print("📥 Response body: ${res.body}");

      if (_handleAuthGuard(res.statusCode)) return;

      if (res.statusCode == 200) {
        final body = json.decode(res.body);

        // if (body["status"] == 200 && body["data"] != null) {
        if ((body["status"] == 200 || body["status"].toString() == "200") &&
            body["data"] != null) {
          final List<dynamic> dataList = body["data"];

          // ✅ Sort by status-specific date
          dataList.sort((a, b) {
            DateTime parseDate(dynamic item) {
              final status = item["status"]?.toString().toLowerCase() ?? "";

              String? dateStr;

              if (status == "cancelled") {
                dateStr = item["cancelledAt"];
              } else if (status == "delivered") {
                dateStr = item["deliveredAt"];
              } else if (status == "returned") {
                dateStr = item["returnedAt"];
              } else if (item["order"]?["orderedAt"] != null) {
                dateStr = item["order"]["orderedAt"];
              } else {
                dateStr = item["createdAt"];
              }

              if (dateStr == null) return DateTime(1970);
              return DateTime.tryParse(dateStr) ?? DateTime(1970);
            }

            return parseDate(b).compareTo(parseDate(a)); // DESC
          });

          // orderHistory = dataList;
          orderHistory.assignAll(dataList);

          print(
              "✅ Order history loaded & sorted (${orderHistory.length} items)");
        } else {
          apiError.value = body["message"] ?? "No order history found";
          getSnackBar(apiError.value);
        }
      } else {
        apiError.value =
            "Failed to fetch order history (${res.statusCode}) — ${res.reasonPhrase}";
        getSnackBar(apiError.value);
      }
    } catch (e) {
      apiError.value = e.toString();
      print("🔥 getOrderHistoryByUser error: $e");
      getSnackBar("Failed to load order history");
    } finally {
      hideLoading();
      isOrderHistory.value = false;
    }
  }

  // ---------- 9) VIEW SINGLE ORDER HISTORY (by orderId) ----------
  /// Calls: GET {{laFetchBaseUrl}}/view-order-history/{orderId}
  Future<Map<String, dynamic>?> viewOrderHistoryById(int orderId) async {
    apiError.value = "";
    showLoading();

    final prefs = await SharedPreferences.getInstance();
    try {
      final uri =
          Uri.parse("${ApiConstants.baseUrl}/view-order-history/$orderId");
      print("📦 Viewing order details for orderId: $orderId");

      final res = await http.get(
        uri,
        headers: _headersWithToken(prefs.getString('token')),
      );

      print("📥 Response status: ${res.statusCode}");
      print("📥 Response body: ${res.body}");

      if (_handleAuthGuard(res.statusCode)) return null;

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final details = (data is Map) ? (data["data"] ?? data) : {};
        print("✅ Order details loaded successfully");
        return details;
      } else {
        apiError.value = "Failed to fetch order details (${res.statusCode})";
        print("❌ ${res.body}");
        getSnackBar(apiError.value);
        return null;
      }
    } catch (e) {
      apiError.value = e.toString();
      print("🔥 viewOrderHistoryById error: $e");
      getSnackBar("Failed to load order details");
      return null;
    } finally {
      hideLoading();
    }
  }
}
