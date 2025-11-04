// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/cupertino.dart';
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
  List orderHistory = [].obs; // from /order-history/{userId}
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

  Future<bool> placeOrder(Map<String, dynamic> payload) async {
    isPlacingOrder.value = true;
    apiError.value = "";
    showLoading();

    final prefs = await SharedPreferences.getInstance();

    try {
      // ✅ Validate required fields before making API call
      if (payload["userId"] == null) {
        apiError.value = "User ID is required";
        getSnackBar("Please login to place order");
        print("❌ userId is null");
        return false;
      }

      if (payload["shippingAddressId"] == null) {
        apiError.value = "Shipping address is required";
        getSnackBar("Please select a shipping address");
        print("❌ shippingAddressId is null");
        return false;
      }

      if (payload["items"] == null || (payload["items"] as List).isEmpty) {
        apiError.value = "Cart is empty";
        getSnackBar("Please add items to cart");
        print("❌ items is null or empty");
        return false;
      }

      final uri = Uri.parse("${ApiConstants.baseUrl}/place-order");

      // ✅ Construct payload matching the required structure
      final updatedPayload = {
        "userId": payload["userId"],
        "shippingAddressId": payload["shippingAddressId"],
        "items": (payload["items"] as List).map((item) {
          return {
            "productName": item["productName"] ?? "",
            "productId": item["productId"],
            "variantId": item["variantId"],
            "quantity": item["quantity"] ?? 1,
            "unitPrice": item["unitPrice"] ?? 0.0,
            "total": item["total"] ?? 0.0,
            "sku": item["sku"] ?? "",
            "hsn": item["hsn"] ?? "",
          };
        }).toList(),
        "totalMRP": payload["totalMRP"] ?? 0.0,
        "total": payload["total"] ?? 0.0,
        "paymentMethod": payload["paymentMethod"] ?? "prepaid",
        "paymentInfo": {
          "providerPaymentId":
              payload["paymentInfo"]?["providerPaymentId"] ?? "",
          "providerOrderId": payload["paymentInfo"]?["providerOrderId"] ?? "",
          "providerSignature":
              payload["paymentInfo"]?["providerSignature"] ?? "",
        },
      };

      print("📤 Placing order with payload:");
      print("   userId: ${updatedPayload['userId']}");
      print("   shippingAddressId: ${updatedPayload['shippingAddressId']}");
      print("   items count: ${(updatedPayload['items'] as List).length}");
      print("   paymentMethod: ${updatedPayload['paymentMethod']}");

      final res = await http.post(
        uri,
        headers: _headersWithToken(prefs.getString('token'), jsonBody: true),
        body: json.encode(updatedPayload),
      );

      print("📥 Response status: ${res.statusCode}");
      print("📥 Response body: ${res.body}");

      // Handle token expiry, unauthorized, etc.
      if (_handleAuthGuard(res.statusCode)) return false;

      if (res.statusCode == 200 || res.statusCode == 201) {
        final responseData = json.decode(res.body);
        getSnackBar("Order placed successfully");
        print("✅ Order placed successfully: $responseData");
        return true;
      } else {
        // Parse error message from response if available
        try {
          final errorData = json.decode(res.body);
          apiError.value = errorData['message'] ??
              errorData['error'] ??
              "Place order failed (${res.statusCode})";
        } catch (e) {
          apiError.value = "Place order failed (${res.statusCode})";
        }

        print("❌ Order placement failed: ${res.body}");
        getSnackBar(apiError.value);
        return false;
      }
    } catch (e) {
      apiError.value = "Network error: ${e.toString()}";
      print("❌ placeOrder error: $e");
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
  /// Body:
  /// {
  ///   "userId": 2,
  ///   "orderItemId": 1,
  ///   "reason": "..."
  /// }
  Future<bool> requestCancel({
    required int userId,
    required int orderItemId,
    required String reason,
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
      };

      final res = await http.post(
        uri,
        headers: _headersWithToken(prefs.getString('token'), jsonBody: true),
        body: json.encode(body),
      );

      if (_handleAuthGuard(res.statusCode)) return false;

      if (res.statusCode == 200 || res.statusCode == 201) {
        getSnackBar("Cancellation requested");
        return true;
      } else {
        apiError.value = "Cancel request failed (${res.statusCode})";
        print(res.body);
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

  // ---------- 4) REQUEST EXCHANGE ----------
  /// Calls: POST {{laFetchBaseUrl}}/request-exchange
  /// Body:
  /// {
  ///   "orderItemId": 1,
  ///   "userId": 2,
  ///   "newVariantId": 2,
  ///   "reason": "size not fit"
  /// }
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
  /// Calls: POST {{laFetchBaseUrl}}/request-return
  /// Body:
  /// {
  ///   "orderItemId": 1,
  ///   "userId": 2,
  ///   "reason": "test"
  /// }
  Future<bool> requestReturn({
    required int orderItemId,
    required int userId,
    required String reason,
  }) async {
    isRequestingReturn.value = true;
    apiError.value = "";
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/request-return");
      final body = {
        "orderItemId": orderItemId,
        "userId": userId,
        "reason": reason,
      };

      final res = await http.post(
        uri,
        headers: _headersWithToken(prefs.getString('token'), jsonBody: true),
        body: json.encode(body),
      );

      if (_handleAuthGuard(res.statusCode)) return false;

      if (res.statusCode == 200 || res.statusCode == 201) {
        getSnackBar("Return requested");
        return true;
      } else {
        apiError.value = "Return request failed (${res.statusCode})";
        print(res.body);
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

  Future<void> checkServiceability(int variantId, String postalCode) async {
    isEstimateDate.value = true;

    try {
      print(
          "🚚 Checking serviceability for variantId: $variantId, pincode: $postalCode");

      final uri = Uri.parse("${ApiConstants.baseUrl}/check-serviceability");
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "variantId": variantId,
          "deliveryPostalCode": postalCode,
        }),
      );

      print("📥 Response status: ${res.statusCode}");
      print("📥 Response body: ${res.body}");

      if (res.statusCode == 200) {
        final responseData = json.decode(res.body);
        final data = responseData["data"];

        if (data != null) {
          estimatedDate.value = data["estimatedDate"] ?? "";
          estimatedDays.value = data["estimatedDays"] ?? "";
          courierName.value = data["courier"] ?? "";

          print("✅ Serviceable location:");
          print("   📦 Estimated Date: ${estimatedDate.value}");
          print("   ⏱️ Estimated Days: ${estimatedDays.value}");
          print("   🚚 Courier: ${courierName.value}");
        } else {
          print("⚠️ Response has no data field.");
          estimatedDate.value = "";
          estimatedDays.value = "";
          courierName.value = "";
        }
      } else {
        print("❌ Serviceability check failed (${res.statusCode})");
        estimatedDate.value = "";
        estimatedDays.value = "";
        courierName.value = "";
      }
    } catch (e) {
      print("🔥 Error fetching serviceability: $e");
      estimatedDate.value = "";
      estimatedDays.value = "";
      courierName.value = "";
    } finally {
      isEstimateDate.value = false;
    }
  }
}
