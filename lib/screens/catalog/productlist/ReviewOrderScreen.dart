// lib/screens/review_order_screen.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:lafetch/common/widget/bottom_sheets/bottomCoupon.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/common/widget/other/common_widget.dart';
import 'package:lafetch/controllers/order_controller.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/screens/account/saved_address.dart';
import 'package:lafetch/controllers/product_controller.dart';
import 'package:lafetch/screens/orders/order_status_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lafetch/common/widget/bottom_sheets/bottomquantity.dart';

class ReviewOrderScreen extends StatefulWidget {
  final int productId;
  final String title;
  final String brandName;
  final int variantId;
  final String imageUrl;
  final String sizeLabel;
  final int quantity;
  final double price;
  final double mrp;
  final Map<String, dynamic>? initialAddress;
  final String? razorpayOrderId;
  final int maxStock;

  // GST-related fields (from API)
  final String? hsnCode;
  final double? gstRate;
  final double? statutoryGSTRate;
  final String? gstRuleApplied;

  const ReviewOrderScreen({
    super.key,
    required this.productId,
    required this.title,
    required this.variantId,
    required this.brandName,
    required this.imageUrl,
    required this.sizeLabel,
    this.quantity = 1,
    required this.price,
    required this.mrp,
    this.initialAddress,
    this.razorpayOrderId,
    this.maxStock = 10,
    this.hsnCode,
    this.gstRate,
    this.statutoryGSTRate,
    this.gstRuleApplied,
  });

  @override
  State<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  static const String _razorpayKey = ApiConstants.razorPayKey;

  final productController = Get.put(ProductController());
  final orderController = Get.put(OrderController());

  Razorpay? _rzp;
  Map<String, dynamic>? _address;

  // --- coupon state (matches CartScreen semantics) ---
  String _couponCode = "Apply Coupon";
  bool _hasDiscount = false;
  num _couponDiscount = 0;

  // --- quantity state ---
  late int _selectedQuantity;

  // --- totals ---
  double get _totalPrice =>
      (widget.price * (_selectedQuantity <= 0 ? 1 : _selectedQuantity))
          .toDouble();
  final double _delivery = 0; // if you add charges later, UI adapts
  final double _convenience = 0;

  num _asNum(dynamic v) {
    if (v is num) return v;
    return num.tryParse('$v'.replaceAll(',', '').trim()) ?? 0;
  }

  String formatAmount(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString(); // 3558.0 → 3558
    }
    return value.toString(); // 3558.6 → 3558.6
  }

  num _computePayable() {
    print("\n🧮 === COMPUTING PAYABLE AMOUNT ===");

    final num sellingPrice = _totalPricee;
    print("   Step 1 - Selling Price:");
    print("      _totalPrice = price × quantity");
    print("      _totalPrice = ${widget.price} × $_selectedQuantity");
    print("      Selling Price: ₹$sellingPrice");

    // Apply coupon on selling
    final num discountedPrice = sellingPrice - _couponDiscount;
    print("\n   Step 2 - Apply Coupon:");
    print("      Coupon Discount: ₹$_couponDiscount");
    print("      Discounted Price = $sellingPrice - $_couponDiscount");
    print("      Discounted Price: ₹$discountedPrice");

    // Final total = discounted price + delivery + convenience
    final num total = discountedPrice + _delivery + _convenience;
    print("\n   Step 3 - Add Charges:");
    print("      Delivery Charges: ₹$_delivery");
    print("      Convenience Charges: ₹$_convenience");
    print("      Total = $discountedPrice + $_delivery + $_convenience");
    print("      Total: ₹$total");

    final num finalTotal = total < 0 ? 0 : total;
    print("\n   Final Payable: ₹$finalTotal");
    print("   (Capped at 0 if negative)");
    print("=================================\n");

    return finalTotal;
  }

// Also add debug logging to _totalPrice getter
  double get _totalPricee {
    final price = widget.price;
    final quantity = _selectedQuantity <= 0 ? 1 : _selectedQuantity;
    final total = (price * quantity).toDouble();

    print("📊 _totalPrice getter:");
    print("   price: ₹$price");
    print("   quantity: $quantity");
    print("   total: ₹$total");

    return total;
  }

  @override
  void initState() {
    super.initState();
    _address = widget.initialAddress;
    _selectedQuantity = widget.quantity;

    _rzp = Razorpay();
    _rzp!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _rzp!.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _rzp!.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    // Load available coupons + restore persisted coupon state (like CartScreen)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await productController.getCoupons();
      await _restoreCouponFromPrefs();
    });
  }

  Future<void> _restoreCouponFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('applied_coupon_code');
    final savedDiscount = prefs.getInt('applied_coupon_discount');
    if (savedCode != null && savedDiscount != null && savedDiscount > 0) {
      setState(() {
        _couponCode = savedCode;
        _couponDiscount = savedDiscount;
        _hasDiscount = true;
      });
    }
  }

  @override
  void dispose() {
    try {
      _rzp?.clear();
    } catch (_) {}
    super.dispose();
  }

  // ================= Address =================
  Future<void> _pickAddress() async {
    final result = await Get.to(() => const SavedAddressScreen(type: 'select'));
    if (result is Map) {
      setState(() => _address = Map<String, dynamic>.from(result));
    }
  }

  // ================= Checkout flow =================
// ================= UPDATED _confirmAndPay in ReviewOrderScreen =================

  Future<void> _confirmAndPay() async {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("🚀 CONFIRM AND PAY - START");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    // 1) address
    print("\n📍 STEP 1: Validating Address");
    print(
        "   Current address: ${_address != null ? 'Selected' : 'Not selected'}");

    if (_address == null) {
      print("   ⚠️ No address selected, prompting user...");
      await _pickAddress();
      if (_address == null) {
        print("   ❌ User did not select address");
        showAppSnackBar("Please select a shipping address to continue",
            type: SnackBarType.error);
        return;
      }
    }

    final shippingAddressId = _address?['id'];
    print("   ✅ Address ID: $shippingAddressId");
    print("   📦 Full Address: $_address");

    if (shippingAddressId == null) {
      print("   ❌ Invalid address ID");
      showAppSnackBar(
          "Invalid address selected. Please choose another address.",
          type: SnackBarType.error);
      return;
    }

    // 2) user id
    print("\n👤 STEP 2: Validating User ID");
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId') ?? prefs.getInt('user_id');
    print("   User ID: $userId");

    if (userId == null) {
      print("   ❌ No user ID found, redirecting to login");
      showAppSnackBar("Please login to continue", type: SnackBarType.error);
      Get.offAllNamed('/login');
      return;
    }
    print("   ✅ User authenticated");

    // 3) product sanity
    print("\n📦 STEP 3: Validating Product Data");
    print("   Product ID: ${widget.productId}");
    print("   Variant ID: ${widget.variantId}");
    print("   Quantity: $_selectedQuantity");
    print("   Price: ${widget.price}");

    if (widget.productId <= 0 || _selectedQuantity <= 0 || widget.price <= 0) {
      print("   ❌ Invalid product data");
      showAppSnackBar("Invalid product data. Please try again.",
          type: SnackBarType.error);
      return;
    }
    print("   ✅ Product data valid");

    // 4) total validation
    print("\n💰 STEP 4: Calculating Totals");
    final payable = _computePayable();
    print("   Payable Amount: ₹$payable");

    if (payable <= 0) {
      print("   ❌ Invalid payable amount");
      showAppSnackBar("Order total must be greater than zero",
          type: SnackBarType.error);
      return;
    }
    print("   ✅ Payable amount valid");

    // 5) build payload with GST calculations
    print("\n📊 STEP 5: Building Order Payload");
    print("   ─────────────────────────────────");

    final num unitPrice = widget.price;
    const num discount = 0;
    final num gstRate = widget.gstRate ?? 0;

    print("   📌 Widget Data:");
    print("      Product ID: ${widget.productId}");
    print("      Variant ID: ${widget.variantId}");
    print("      Title: ${widget.title}");
    print("      Brand: ${widget.brandName}");
    print("      Size Label: ${widget.sizeLabel}");
    print("      Unit Price: ₹$unitPrice");
    print("      MRP: ₹${widget.mrp}");
    print("      Quantity: $_selectedQuantity");
    print("      Max Stock: ${widget.maxStock}");
    print("");
    print("   📌 GST Data from Widget:");
    print("      HSN Code: ${widget.hsnCode}");
    print("      GST Rate: ${widget.gstRate}%");
    print("      Statutory GST Rate: ${widget.statutoryGSTRate}%");
    print("      GST Rule Applied: ${widget.gstRuleApplied}");
    print("");
    print("   🧮 GST Calculation:");
    print("      Formula: (unitPrice × quantity × gstRate / 100)");
    print(
        "      Calculation: ($unitPrice × $_selectedQuantity × $gstRate / 100)");

    final num gstAmount = ((unitPrice * _selectedQuantity) * gstRate / 100);
    print("      GST Amount: ₹$gstAmount");
    print("");
    print("   💵 Item Total Calculation:");
    print("      Formula: (unitPrice × quantity) + gstAmount - discount");
    print(
        "      Calculation: ($unitPrice × $_selectedQuantity) + $gstAmount - $discount");

    final num itemTotal =
        (unitPrice * _selectedQuantity) + gstAmount - discount;
    print("      Item Total: ₹$itemTotal");
    print("");
    print("   🎟️ Coupon Details:");
    print("      Coupon Code: $_couponCode");
    print("      Coupon Discount: ₹$_couponDiscount");
    print("      Has Discount: $_hasDiscount");

    // ✅ Create item using helper method
    print("\n   📦 Creating Order Item...");
    final orderItem = orderController.buildOrderItem(
      productId: widget.productId,
      variantId: widget.variantId,
      quantity: _selectedQuantity,
      unitPrice: unitPrice,
      discount: discount,
      total: itemTotal,
      tax: 0, // Keep as 0 (GST is separate)
      gstAmount: gstAmount,
      hsnCode: widget.hsnCode ?? "",
      gstRate: gstRate,
      statutoryGSTRate: widget.statutoryGSTRate ?? gstRate,
      gstRuleApplied: widget.gstRuleApplied ?? "",
    );

    print("   ✅ Order Item Created:");
    print(jsonEncode(orderItem));

    // 6) local backup
    print("\n💾 STEP 6: Creating Order Payload & Local Backup");
    final orderPayload = {
      "userId": userId,
      "shippingAddressId": shippingAddressId,
      "items": [orderItem],
      "totalMRP": widget.mrp,
      "couponDiscount": _couponDiscount,
      "tax": gstAmount,
      "total": payable,
      "paymentMethod": "prepaid",
    };

    print("   📋 Complete Order Payload:");
    print("   ─────────────────────────────────");
    print(jsonEncode(orderPayload));
    print("   ─────────────────────────────────");
    print("");
    print("   💾 Saving to SharedPreferences...");

    await prefs.setString('pending_order_payload', jsonEncode(orderPayload));
    await prefs.setInt('pending_order_total', payable.toInt());
    await prefs.setInt('pending_order_userId', userId);
    await prefs.setInt('pending_order_shippingAddressId', shippingAddressId);

    print("   ✅ Local backup saved");

    // 7) ✅ Call initiate payment with named parameters
    print("\n💳 STEP 7: Initiating Payment");
    print("   Calling orderController.initiatePayment...");
    print("   Parameters:");
    print("      userId: $userId");
    print("      shippingAddressId: $shippingAddressId");
    print("      items count: ${[orderItem].length}");
    print("      totalMRP: ${widget.mrp}");
    print("      couponDiscount: $_couponDiscount");
    print("      tax: $gstAmount");
    print("      total: $payable");
    print("      paymentMethod: prepaid");

    final paymentInitData = await orderController.initiatePayment(
      userId: userId,
      shippingAddressId: shippingAddressId,
      items: [orderItem],
      totalMRP: widget.mrp,
      couponDiscount: _couponDiscount,
      tax: gstAmount,
      total: payable,
      paymentMethod: "prepaid",
    );

    print("\n   📥 Payment Init Response:");
    if (paymentInitData == null) {
      print("   ❌ Response is NULL");
      showAppSnackBar("Failed to initiate payment. Please try again.",
          type: SnackBarType.error);
      return;
    }

    print("   ✅ Response received:");
    print(jsonEncode(paymentInitData));

    final razorpayOrderId = paymentInitData["providerOrderId"];
    print("\n   🔑 Razorpay Order ID: $razorpayOrderId");

    if ((razorpayOrderId ?? '').toString().isEmpty) {
      print("   ❌ Razorpay Order ID is empty");
      showAppSnackBar("Unable to start payment (missing Razorpay Order ID).",
          type: SnackBarType.error);
      return;
    }

    print("   ✅ Razorpay Order ID valid");

    // 8) open Razorpay with discounted amount
    print("\n🎯 STEP 8: Opening Razorpay Checkout");
    print("   Razorpay Order ID: $razorpayOrderId");
    print("   Amount: ₹$payable");

    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("✅ CONFIRM AND PAY - COMPLETE, Opening Razorpay...");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

    await _openRazorpayCheckout(orderId: razorpayOrderId);
  }

  Future<void> _openRazorpayCheckout({required String orderId}) async {
    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("💳 OPENING RAZORPAY CHECKOUT (Review Order)");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    // ⚠️ Check if running on iOS Simulator
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        if (!iosInfo.isPhysicalDevice) {
          print("⚠️  RUNNING ON iOS SIMULATOR");
          print("⚠️  Razorpay does NOT work on iOS simulators!");
          print("⚠️  Please test on a REAL iOS device.");
          print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

          if (!mounted) return;

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('⚠️ iOS Simulator Detected'),
              content: Text(
                'Razorpay payment gateway does NOT work on iOS simulators.\n\n'
                'To test payments:\n'
                '• Use a REAL iPhone/iPad device\n'
                '• Or test on Android emulator\n\n'
                'Your order has been initiated successfully.\n'
                'Order ID: $orderId\n\n'
                'On a real device, the Razorpay payment window will open here.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Navigate to pending status for testing
                    Get.offAll(
                        () => const OrderStatusScreen(status: 'pending'));
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }
        print("✅ Running on REAL iOS device");
      }
    } catch (e) {
      print("⚠️  Device detection failed: $e (continuing anyway...)");
    }

    final num cartTotalInRupees = _computePayable();
    final int amountInPaise = (cartTotalInRupees * 100).round();

    final prefs = await SharedPreferences.getInstance();
    final String userName = (prefs.getString('user_name') ?? '').trim();
    final String userEmail = (prefs.getString('email') ?? '').trim();
    final String rawPhone = (prefs.getString('phonenumber') ?? '').trim();
    final String phone = _sanitizeIndianPhone(rawPhone);

    // ---------------------- DEBUG PRINTS ----------------------
    print("--------------- RAZORPAY DEBUG ---------------");
    print("Razorpay Key        : $_razorpayKey");
    print("Razorpay Order ID   : $orderId");
    print("Cart Total (₹)      : $cartTotalInRupees");
    print("Amount in Paise     : $amountInPaise");
    print("User Name           : $userName");
    print("User Email          : $userEmail");
    print("Raw Phone           : $rawPhone");
    print("Final Phone Digits  : $phone");
    print("----------------------------------------------");

    if (orderId.isEmpty) {
      print("❌ ERROR: orderId is EMPTY → Cannot open Razorpay");
      showAppSnackBar("Invalid Razorpay Payment Order ID",
          type: SnackBarType.error);
      return;
    }

    if (_razorpayKey.isEmpty) {
      print("❌ ERROR: Razorpay key missing!");
      showAppSnackBar("Payment configuration missing (Key)",
          type: SnackBarType.error);
      return;
    }

    if (amountInPaise <= 0) {
      print("❌ ERROR: amount is ZERO → Razorpay cannot open");
      showAppSnackBar("Invalid payable amount", type: SnackBarType.error);
      return;
    }

    final options = {
      'key': _razorpayKey,
      'amount': amountInPaise,
      'currency': 'INR',
      'order_id': orderId,
      'name': 'Lafetch',
      'description': '${widget.title} • Qty $_selectedQuantity',
      'prefill': {
        'name': userName.isEmpty ? 'Customer' : userName,
        'email': userEmail.isEmpty ? 'customer@example.com' : userEmail,
        // ✅ Add +91 prefix for Razorpay (10 digits only)
        'contact': phone.length == 10 ? '+91$phone' : '+919999999999',
      },
      'theme': {'color': '#070707'},
    };

    print("Razorpay Options → $options");
    print("------------------------------------------------");

    try {
      _rzp?.open(options);
      print("✔ Razorpay checkout opened successfully!");
    } catch (e) {
      print("❌ ERROR opening Razorpay → $e");
      showAppSnackBar('Unable to start payment: ${e.toString()}',
          type: SnackBarType.error);
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse r) async {
    try {
      final result = await orderController.confirmPlaceOrder(
        providerOrderId: r.orderId ?? '',
        providerPaymentId: r.paymentId ?? '',
        providerSignature: r.signature ?? '',
      );

      if (result == true) {
        // Navigate ONLY after order is confirmed
        Get.offAll(
          () => const OrderStatusScreen(status: 'success'),
          transition: Transition.fadeIn,
          duration: Duration(milliseconds: 400),
        );
      } else {
        // If API failed → show failed screen
        Get.offAll(
          () => const OrderStatusScreen(status: 'failed'),
          transition: Transition.fadeIn,
          duration: Duration(milliseconds: 400),
        );
      }
    } catch (e) {
      print("Order confirmation failed: $e");
      Get.offAll(
        () => const OrderStatusScreen(status: 'failed'),
        transition: Transition.fadeIn,
        duration: Duration(milliseconds: 400),
      );
    }

    // Cleanup local cache AFTER navigation
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_order_payload');
    await prefs.remove('pending_order_total');
    await prefs.remove('pending_order_userId');
    await prefs.remove('pending_order_shippingAddressId');
    await prefs.remove('applied_coupon_code');
    await prefs.remove('applied_coupon_discount');
  }

  void _onPaymentError(PaymentFailureResponse r) {
    Get.offAll(
        () => const OrderStatusScreen(
              status: 'failed',
            ),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 400));
  }

  void _onExternalWallet(ExternalWalletResponse r) {
    showAppSnackBar('External wallet: ${r.walletName}',
        type: SnackBarType.info);
  }

  // ================= Coupon section (CartScreen rules) =================
  Widget _buildCouponSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.sp, horizontal: 16.sp),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.sp),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              couponSvgImage,
              color: titleColor,
              height: 20.sp,
              width: 20.sp,
            ),
            SizedBox(width: 8.sp),
            Expanded(
              child: Text(
                _couponCode,
                style: TextStyle(
                  fontFamily: "Clash Display Regular",
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                  fontSize: 14.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.sp),
            SizedBox(
              width: 90.sp,
              height: 30.sp,
              child: ElevatedButton(
                onPressed: () async {
                  if (_hasDiscount) {
                    _removeAppliedCoupon();
                    return;
                  }

                  await productController.getCoupons();
                  if (productController.couponList.isEmpty) {
                    showAppSnackBar("No coupons available right now",
                        type: SnackBarType.info);
                    return;
                  }

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (ctx) {
                      return FractionallySizedBox(
                        heightFactor: 0.7,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: BottomCoupon(
                            list: productController.couponList,
                            backColor: whiteColor,
                            onPressed: (code) {
                              Navigator.pop(ctx);
                              _applyCoupon(code);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      _hasDiscount ? Colors.transparent : homeAppBarColor,
                  side: BorderSide(
                    color: _hasDiscount ? lightPurpleColor : btnTextColor,
                    width: 1.sp,
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  _hasDiscount ? "REMOVE" : "SELECT",
                  style: TextStyle(
                    color: _hasDiscount ? lightPurpleColor : whiteColor,
                    fontSize: 12.sp,
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyCoupon(String code) async {
    try {
      if (productController.couponList.isEmpty) {
        await productController.getCoupons();
      }

      final coupon = productController.couponList.firstWhere(
        (c) =>
            (c['code']?.toString().toUpperCase() ?? '') == code.toUpperCase(),
        orElse: () => {},
      );

      if (coupon.isEmpty) {
        showAppSnackBar("Invalid or expired coupon", type: SnackBarType.error);
        return;
      }

      // Requirements from CartScreen:
      final num total = _asNum(_totalPrice);
      final num minCart = _asNum(coupon['minCartValue']);
      if (total < minCart) {
        showAppSnackBar(
            "Coupon requires a minimum cart value of ₹${minCart.toStringAsFixed(0)}",
            type: SnackBarType.warning);
        return;
      }

      // discountType examples: "10%" or "500"
      final discountType =
          (coupon['discountType'] ?? '').toString().toLowerCase();
      num discountValue = 0;
      if (discountType.contains('%')) {
        final percent =
            num.tryParse(discountType.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        discountValue = (total * percent / 100).round();
      } else {
        discountValue =
            num.tryParse(discountType.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      }

      // Cap
      final maxDiscount = _asNum(coupon['maxDiscountCap']);
      if (maxDiscount > 0 && discountValue > maxDiscount) {
        discountValue = maxDiscount;
      }

      setState(() {
        _couponCode = code;
        _couponDiscount = discountValue;
        _hasDiscount = discountValue > 0;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('applied_coupon_code', code);
      await prefs.setInt('applied_coupon_discount', discountValue.toInt());

      showAppSnackBar("Coupon '$code' applied successfully",
          type: SnackBarType.success);
    } catch (e) {
      print("✗ Error applying coupon: $e");
      showAppSnackBar("Failed to apply coupon. Please try again.",
          type: SnackBarType.error);
    }
  }

  Future<void> _removeAppliedCoupon() async {
    setState(() {
      _couponCode = "Apply Coupon";
      _couponDiscount = 0;
      _hasDiscount = false;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('applied_coupon_code');
    await prefs.remove('applied_coupon_discount');

    showAppSnackBar("Coupon removed", type: SnackBarType.success);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const AppText(
          text: "REVIEW ORDER",
          fontFamily: "Clash Display",
          fontWeight: FontWeight.w700,
          color: blackColor,
          fontSize: 16,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: 12.sp),
              children: [
                _buildProductRow(),
                _buildCouponSection(),
                _buildOrderDetails(),
              ],
            ),
          ),
          _addressStrip(),
          _checkoutCta(),
        ],
      ),
    );
  }

  Widget _buildProductRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.sp,
            height: 140.sp,
            child: CachedNetworkImage(
              cacheManager: CacheManager(
                Config("reviewCache",
                    stalePeriod: const Duration(days: 15),
                    maxNrOfCacheObjects: 100),
              ),
              imageUrl: widget.imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Image.asset(dummyWishlistImage, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 12.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: widget.title,
                  maxLines: 2,
                  fontFamily: "Clash Display",
                  fontWeight: FontWeight.w600,
                  color: nameText,
                  fontSize: 16,
                ),
                SizedBox(height: 8.sp),
                Row(
                  children: [
                    _pill(
                        'Size : ${widget.sizeLabel.isEmpty ? "-" : widget.sizeLabel}'),
                    SizedBox(width: 8.sp),
                    GestureDetector(
                      onTap: _showQuantityModal,
                      child: _pillWithIcon('Qty : $_selectedQuantity'),
                    ),
                  ],
                ),
                SizedBox(height: 10.sp),
                Row(
                  children: [
                    if (widget.mrp > widget.price)
                      Padding(
                        padding: EdgeInsets.only(right: 8.sp),
                        child: Text(
                          "₹${formatAmount(widget.mrp)}",
                          style: TextStyle(
                            color: searchTextColor,
                            fontSize: 12.sp,
                            decoration: TextDecoration.lineThrough,
                            fontFamily: "Clash Display",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    AppText(
                      text: "₹${formatAmount(widget.price)}",
                      fontFamily: "Clash Display",
                      fontWeight: FontWeight.w700,
                      color: nameText,
                      fontSize: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    // Calculate totals like CartScreen
    final num totalMrp = widget.mrp * _selectedQuantity;
    final num sellingTotal = _totalPrice;
    final num discountOnMrp = totalMrp - sellingTotal;

    // Apply coupon discount
    final num afterCoupon = sellingTotal - _couponDiscount;

    // Add delivery charges
    final num payable = afterCoupon + _delivery + _convenience;
    final num finalPayable = payable < 0 ? 0 : payable;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            text: "ORDER DETAILS",
            fontFamily: "Clash Display",
            fontWeight: FontWeight.w500,
            color: homeAppBarColor,
            fontSize: 14,
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.sp),
            child: Container(
              width: double.infinity,
              color: colorSecondary,
              height: 1.sp,
            ),
          ),

          // ✅ Total MRP (only show if discount exists)
          if (discountOnMrp > 0)
            _buildPriceRow(
              "Total MRP",
              "₹${formatAmount(totalMrp)}",
              false,
            ),

          // ✅ Discount on MRP (only show if discount exists)
          if (discountOnMrp > 0)
            _buildPriceRow(
              "Discount on MRP",
              "- ₹${formatAmount(discountOnMrp)}",
              false,
            ),

          // Divider after MRP discount
          if (discountOnMrp > 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp),
              child: Container(
                width: double.infinity,
                color: colorSecondary,
                height: 0.5.sp,
              ),
            ),

          // ✅ Subtotal (Selling Price) - always show
          Padding(
            padding: EdgeInsets.only(top: discountOnMrp > 0 ? 12.sp : 0),
            child: Row(
              children: [
                const AppText(
                  text: "Subtotal",
                  fontFamily: "Clash Display Regular",
                  fontWeight: FontWeight.w400,
                  color: subtitleColor,
                  fontSize: 12,
                ),
                const Spacer(),
                AppText(
                  text: "₹${formatAmount(sellingTotal)}",
                  fontFamily: "Clash Display",
                  fontWeight: FontWeight.w500,
                  color: homeAppBarColor,
                  fontSize: 12,
                ),
              ],
            ),
          ),

          // ✅ Coupon Discount (only show if applied)
          if (_couponDiscount > 0)
            Padding(
              padding: EdgeInsets.only(top: 12.sp),
              child: Row(
                children: [
                  const AppText(
                    text: "Coupon Discount",
                    fontFamily: "Clash Display Regular",
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                    fontSize: 12,
                  ),
                  const Spacer(),
                  AppText(
                    text: "- ₹${formatAmount(_couponDiscount)}",
                    fontFamily: "Clash Display Regular",
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff059669),
                    fontSize: 12,
                  ),
                ],
              ),
            ),

          // ✅ Delivery Charges
          Padding(
            padding: EdgeInsets.only(top: 12.sp),
            child: Row(
              children: [
                const AppText(
                  text: "Delivery Charges",
                  fontFamily: "Clash Display Regular",
                  fontWeight: FontWeight.w400,
                  color: subtitleColor,
                  fontSize: 12,
                ),
                const Spacer(),
                AppText(
                  text:
                      _delivery == 0 ? "Free" : "+ ₹${formatAmount(_delivery)}",
                  fontFamily: "Clash Display Regular",
                  fontWeight: FontWeight.w400,
                  color: _delivery == 0
                      ? const Color(0xff059669)
                      : homeAppBarColor,
                  fontSize: 12,
                ),
              ],
            ),
          ),

          // Divider before total
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.sp),
            child: Container(
              width: double.infinity,
              color: colorSecondary,
              height: 1.5.sp,
            ),
          ),

          // ✅ FINAL TOTAL AMOUNT
          Row(
            children: [
              const AppText(
                text: "TOTAL AMOUNT",
                fontFamily: "Clash Display",
                fontWeight: FontWeight.w500,
                color: colorPrimary,
                fontSize: 15,
              ),
              const Spacer(),
              AppText(
                text: "₹${formatAmount(finalPayable)}",
                fontFamily: "Clash Display",
                fontWeight: FontWeight.w500,
                color: colorPrimary,
                fontSize: 15,
              ),
            ],
          ),

          SizedBox(height: 30.sp),
        ],
      ),
    );
  }

  Widget _addressStrip() {
    return GestureDetector(
      onTap: _pickAddress,
      child: Container(
        color: lightgreyColor,
        height: 40.sp,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: Row(
            children: [
              AppText(
                text: _address == null
                    ? "Select Shipping Address"
                    : "DELIVERING IN ${(_address?['pincode'] ?? _address?['zip'] ?? '').toString().toUpperCase()}",
                fontFamily: "Clash Display",
                fontWeight: FontWeight.w500,
                color: titleColor,
                fontSize: 14,
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(left: 2.sp, right: 5.sp),
                child: Image.asset(
                  rightArrowImage,
                  color: titleColor,
                  height: 16.sp,
                  width: 16.sp,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkoutCta() {
    return GestureDetector(
      onTap: _confirmAndPay,
      child: Container(
        width: double.infinity,
        height: 70.sp,
        color: homeAppBarColor,
        alignment: Alignment.center,
        child: const AppText(
          text: "CONFIRM AND PAY",
          fontFamily: "Clash Display",
          fontWeight: FontWeight.w500,
          color: whiteColor,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool hasIcon) {
    final bool isDiscountRow =
        label.toLowerCase().contains("discount") && !label.contains("Delivery");

    final Color valueColor =
        isDiscountRow ? const Color(0xff059669) : homeAppBarColor;

    return Padding(
      padding: EdgeInsets.only(top: 12.sp),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: AppText(
                    text: label,
                    fontFamily: "Clash Display Regular",
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                    fontSize: 12,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.sp),
          AppText(
            text: value,
            fontFamily: "Clash Display Regular",
            fontWeight: FontWeight.w400,
            color: valueColor,
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      height: 30.sp,
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
      decoration: BoxDecoration(
        color: const Color(0xffF3F4F6),
        border: Border.all(width: 1, color: const Color(0xFFE5E7EB)),
      ),
      child: AppText(
        text: text,
        fontFamily: "Clash Display Regular",
        fontWeight: FontWeight.w400,
        color: titleColor,
        fontSize: 10,
      ),
    );
  }

  Widget _pillWithIcon(String text) {
    return Container(
      height: 30.sp,
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
      decoration: BoxDecoration(
        color: const Color(0xffF3F4F6),
        border: Border.all(width: 1, color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: text,
            fontFamily: "Clash Display Regular",
            fontWeight: FontWeight.w400,
            color: titleColor,
            fontSize: 10,
          ),
          SizedBox(width: 6.sp),
          SvgPicture.asset(
            dropdownSvgImage,
            colorFilter: const ColorFilter.mode(titleColor, BlendMode.srcIn),
            height: 5.sp,
            width: 8.sp,
          ),
        ],
      ),
    );
  }

  void _showQuantityModal() async {
    // ✅ Fetch fresh stock data from product API for accuracy
    int availableStock = widget.maxStock; // Initial value

    try {
      debugPrint(
          "🔍 Fetching fresh stock for product ${widget.productId}, variant ${widget.variantId}");
      final productDetails =
          await productController.fetchProductDetails(widget.productId);

      if (productDetails != null && productDetails["variants"] != null) {
        final variants = List<Map<String, dynamic>>.from(
            (productDetails["variants"] as List).whereType<Map>());

        // Find matching variant
        final matchingVariant = variants.firstWhere(
          (v) => v["id"] == widget.variantId,
          orElse: () => {},
        );

        if (matchingVariant.isNotEmpty) {
          final inv = matchingVariant["inventory"];
          final freshStock = inv != null ? (inv["availableStock"] ?? 0) : 0;

          if (freshStock > 0) {
            availableStock = freshStock;
            debugPrint(
                "✅ Fresh stock for variant ${widget.variantId}: $availableStock");
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ Failed to fetch fresh stock, using initial value: $e");
      // Continue with widget.maxStock
    }

    if (!mounted) return;

    if (availableStock == 0) {
      showAppSnackBar("This item is out of stock", type: SnackBarType.error);
      return;
    }

    // ✅ Allow user to select up to available inventory (no artificial limit)
    final int maxQty = availableStock;
    final List<String> qtyList = List.generate(maxQty, (i) => "${i + 1}");

    // Show stock info to user
    final String stockMessage = availableStock <= 5
        ? "Only $availableStock left in stock"
        : "$availableStock available";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stock indicator
            if (availableStock <= 10)
              Container(
                margin: EdgeInsets.only(bottom: 8.sp),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                decoration: BoxDecoration(
                  color: availableStock <= 5
                      ? Colors.red.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                child: Text(
                  stockMessage,
                  style: TextStyle(
                    color: availableStock <= 5
                        ? Colors.red.shade800
                        : Colors.orange.shade800,
                    fontSize: 12.sp,
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            BottomQuantity(
              qtyList: qtyList,
              selectedQty: "$_selectedQuantity",
              stock: maxQty,
              controller: productController,
              onPressed: (newQty) async {
                Navigator.pop(ctx);
                if (newQty != _selectedQuantity) {
                  // ✅ Validate quantity before updating
                  if (newQty > availableStock) {
                    showAppSnackBar(
                        "Only $availableStock units available in stock",
                        type: SnackBarType.error);
                    return;
                  }

                  setState(() {
                    _selectedQuantity = newQty;
                  });

                  // ✅ Only update local quantity - Buy Now is independent of cart
                  // No need to sync with cart as this is a direct purchase flow
                  showAppSnackBar("Quantity updated to $newQty",
                      type: SnackBarType.success);
                }
              },
            ),
          ],
        );
      },
    );
  }

  String _sanitizeIndianPhone(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    String cleanDigits = digits;
    if (digits.startsWith('91') && digits.length > 10) {
      cleanDigits = digits.substring(2);
    }
    return cleanDigits.length >= 10
        ? cleanDigits.substring(cleanDigits.length - 10)
        : cleanDigits;
  }
}
