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
import 'package:lafetch/common/widget/newsletter/newsletter_section.dart';
import 'package:lafetch/controllers/order_controller.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/screens/account/saved_address.dart';
import 'package:lafetch/controllers/product_controller.dart';
import 'package:lafetch/screens/orders/order_status_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lafetch/common/widget/bottom_sheets/bottomquantity.dart';
import 'package:lafetch/common/widget/bottom_sheets/missing_contact_bottom_sheet.dart';

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

  // --- Promo Code state (manual entry) ---
  final TextEditingController _promoCodeController = TextEditingController();
  String _promoCode = "";
  bool _hasPromo = false;
  num _promoDiscount = 0;

  // --- Coupon state (from available coupons list) ---
  String _couponCode = "";
  bool _hasCoupon = false;
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

    // Apply promo + coupon discounts
    final num totalDiscount = _promoDiscount + _couponDiscount;
    final num discountedPrice = sellingPrice - totalDiscount;
    print("\n   Step 2 - Apply Discounts:");
    print("      Promo Discount: ₹$_promoDiscount");
    print("      Coupon Discount: ₹$_couponDiscount");
    print("      Total Discount: ₹$totalDiscount");
    print("      Discounted Price = $sellingPrice - $totalDiscount");
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

    // Restore promo code
    final savedPromoCode = prefs.getString('applied_promo_code');
    final savedPromoDiscount = prefs.getInt('applied_promo_discount');
    if (savedPromoCode != null &&
        savedPromoDiscount != null &&
        savedPromoDiscount > 0) {
      setState(() {
        _promoCode = savedPromoCode;
        _promoDiscount = savedPromoDiscount;
        _hasPromo = true;
        _promoCodeController.text = savedPromoCode;
      });
      print("✓ Restored promo: $_promoCode (₹$_promoDiscount)");
    }

    // Restore coupon
    final savedCouponCode = prefs.getString('applied_coupon_code');
    final savedCouponDiscount = prefs.getInt('applied_coupon_discount');
    if (savedCouponCode != null &&
        savedCouponDiscount != null &&
        savedCouponDiscount > 0) {
      setState(() {
        _couponCode = savedCouponCode;
        _couponDiscount = savedCouponDiscount;
        _hasCoupon = true;
      });
      print("✓ Restored coupon: $_couponCode (₹$_couponDiscount)");
    }
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
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

    // 2.5) contact gate — ensure email and phone are present
    final String _gateEmail = (prefs.getString('email') ?? '').trim();
    final String _gatePhone = (prefs.getString('phonenumber') ??
            prefs.getString('phone_number') ??
            '')
        .trim();
    final bool _emailMissing = _gateEmail.isEmpty;
    final bool _phoneMissing = _gatePhone.isEmpty;

    if (_emailMissing || _phoneMissing) {
      print(
          "   ⚠️ Missing contact info — emailMissing=$_emailMissing, phoneMissing=$_phoneMissing");
      if (!mounted) return;
      final result = await showModalBottomSheet<Map<String, dynamic>?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MissingContactBottomSheet(
          needsEmail: _emailMissing,
          needsPhone: _phoneMissing,
        ),
      );
      if (result == null) {
        print("   ❌ User dismissed contact bottom sheet");
        showAppSnackBar("Please provide your contact details to continue",
            type: SnackBarType.error);
        return;
      }
      print("   ✅ Contact details collected: $result");
    }

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
    print("   🎟️ Promo Code Details:");
    print("      Promo Code: ${_hasPromo ? _promoCode : 'None'}");
    print("      Promo Discount: ₹$_promoDiscount");
    print("");
    print("   🎫 Coupon Details:");
    print("      Coupon Code: ${_hasCoupon ? _couponCode : 'None'}");
    print("      Coupon Discount: ₹$_couponDiscount");
    print("      Total Savings: ₹${_promoDiscount + _couponDiscount}");

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
    // ✅ Calculate total discount (promo + coupon)
    final num totalDiscount = _promoDiscount + _couponDiscount;

    print("      userId: $userId");
    print("      shippingAddressId: $shippingAddressId");
    print("      items count: ${[orderItem].length}");
    print("      totalMRP: ${widget.mrp}");
    print("      promoDiscount: $_promoDiscount");
    print("      couponDiscount: $_couponDiscount");
    print("      totalDiscount: $totalDiscount");
    print("      tax: $gstAmount");
    print("      total: $payable");
    print("      paymentMethod: prepaid");

    final paymentInitData = await orderController.initiatePayment(
      userId: userId,
      shippingAddressId: shippingAddressId,
      items: [orderItem],
      totalMRP: widget.mrp.round(),
      couponDiscount: totalDiscount, // Total of promo + coupon
      tax: gstAmount,
      total: payable,
      paymentMethod: "prepaid",
      mode: "direct",
      productId: widget.productId,
      variantId: widget.variantId,
      quantity: _selectedQuantity,
      shippingCost: 0,
      couponCode: _hasCoupon ? _couponCode : (_hasPromo ? _promoCode : null),
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
    print("🎉 Razorpay Payment SUCCESS - Payment ID: ${r.paymentId}");

    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('pending_order_userId');
    final int? shippingAddressId =
        prefs.getInt('pending_order_shippingAddressId');

    // Show success screen immediately
    Get.offAll(() => const OrderStatusScreen(status: 'success'));

    // Try to confirm in background
    if (userId != null && shippingAddressId != null) {
      try {
        final bool confirmed = await orderController.confirmPlaceOrder(
          providerOrderId: r.orderId ?? '',
          providerPaymentId: r.paymentId ?? '',
          providerSignature: r.signature ?? '',
        );

        if (!confirmed) {
          print("⚠️ Backend confirmation failed for payment: ${r.paymentId}");
        }
      } catch (e) {
        print("⚠️ confirmPlaceOrder exception: $e");
      }
    }

    // Cleanup
    await prefs.remove('pending_order_userId');
    await prefs.remove('pending_order_shippingAddressId');
    await prefs.remove('pending_order_payload');
    await prefs.remove('pending_order_total');
    // remove coupon/promo keys too...
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

  // ================= Coupon/Promo Code Section =================
  Widget _buildCouponSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.sp, horizontal: 16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Section 1: Manual Promo Code Entry
          const AppText(
            text: "HAVE A PROMO CODE?",
            fontFamily: "Clash Display",
            fontWeight: FontWeight.w500,
            color: homeAppBarColor,
            fontSize: 12,
          ),
          SizedBox(height: 8.sp),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1.sp),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoCodeController,
                    decoration: InputDecoration(
                      hintText: "Enter promo code",
                      hintStyle: TextStyle(
                        fontFamily: "Clash Display Regular",
                        fontSize: 14.sp,
                        color: subtitleColor,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8.sp),
                    ),
                    style: TextStyle(
                      fontFamily: "Clash Display Regular",
                      fontSize: 14.sp,
                      color: titleColor,
                      fontWeight: FontWeight.w500,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    enabled: !_hasPromo,
                  ),
                ),
                SizedBox(width: 8.sp),
                SizedBox(
                  width: 80.sp,
                  height: 32.sp,
                  child: ElevatedButton(
                    onPressed: _hasPromo
                        ? _removePromoCode
                        : () {
                            final code = _promoCodeController.text.trim();
                            if (code.isEmpty) {
                              showAppSnackBar("Please enter a promo code",
                                  type: SnackBarType.warning);
                              return;
                            }
                            _applyPromoCode(code);
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          _hasPromo ? Colors.transparent : homeAppBarColor,
                      side: BorderSide(
                        color: _hasPromo ? lightPurpleColor : btnTextColor,
                        width: 1.sp,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      _hasPromo ? "REMOVE" : "APPLY",
                      style: TextStyle(
                        color: _hasPromo ? lightPurpleColor : whiteColor,
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

          // ✅ Show applied promo info
          if (_hasPromo)
            Padding(
              padding: EdgeInsets.only(top: 8.sp),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: lightPurpleColor, size: 16),
                  SizedBox(width: 6.sp),
                  Expanded(
                    child: AppText(
                      text:
                          "$_promoCode applied! You saved ₹${formatAmount(_promoDiscount)}",
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w500,
                      color: lightPurpleColor,
                      fontSize: 12,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),

          // ✅ Divider with OR
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.sp),
            child: Row(
              children: [
                Expanded(
                    child: Divider(color: colorSecondary, thickness: 1.sp)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: const AppText(
                    text: "OR",
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                    fontSize: 12,
                  ),
                ),
                Expanded(
                    child: Divider(color: colorSecondary, thickness: 1.sp)),
              ],
            ),
          ),

          // ✅ Section 2: Select from Available Coupons
          const AppText(
            text: "SELECT FROM AVAILABLE COUPONS",
            fontFamily: "Clash Display",
            fontWeight: FontWeight.w500,
            color: homeAppBarColor,
            fontSize: 12,
          ),
          SizedBox(height: 8.sp),
          GestureDetector(
            onTap: () async {
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (ctx) {
                  return FractionallySizedBox(
                    heightFactor: 0.7,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: BottomCoupon(
                        list: productController.couponList,
                        backColor: whiteColor,
                        onPressed: (code) {
                          Navigator.pop(ctx);
                          // Don't fill promo code field - this is a separate coupon!
                          _applyCoupon(code);
                        },
                      ),
                    ),
                  );
                },
              );
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: whiteColor,
                border: Border.all(
                  color: homeAppBarColor,
                  width: 1.sp,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.sp),
              child: Row(
                children: [
                  SvgPicture.asset(
                    couponSvgImage,
                    color: homeAppBarColor,
                    height: 20.sp,
                    width: 20.sp,
                  ),
                  SizedBox(width: 10.sp),
                  Expanded(
                    child: AppText(
                      text: "View all available coupons",
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14.sp,
                    color: titleColor,
                  ),
                ],
              ),
            ),
          ),

          // ✅ Show applied coupon info
          if (_hasCoupon)
            Padding(
              padding: EdgeInsets.only(top: 12.sp),
              child: Container(
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: const Color(0xffEFF6FF),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: lightPurpleColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: lightPurpleColor, size: 18),
                    SizedBox(width: 8.sp),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: "Coupon: $_couponCode",
                            fontFamily: "Clash Display",
                            fontWeight: FontWeight.w600,
                            color: lightPurpleColor,
                            fontSize: 13,
                          ),
                          AppText(
                            text: "You saved ₹${formatAmount(_couponDiscount)}",
                            fontFamily: "Clash Display Regular",
                            fontWeight: FontWeight.w500,
                            color: lightPurpleColor,
                            fontSize: 11,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    GestureDetector(
                      onTap: _removeCoupon,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.sp, vertical: 4.sp),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: lightPurpleColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const AppText(
                          text: "REMOVE",
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w600,
                          color: lightPurpleColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ Apply Promo Code (Manual Entry)
  Future<void> _applyPromoCode(String code) async {
    try {
      print("\n🎟️ ═══════════════════════════════════════════════════");
      print("🎟️ APPLYING PROMO CODE - ReviewOrderScreen");
      print("🎟️ ═══════════════════════════════════════════════════");
      print("   Code: $code");

      final num cartTotal = _totalPrice;
      print("   Cart Total: ₹$cartTotal");

      final promoData = await productController.validatePromoCode(
        code: code,
        cartTotal: cartTotal,
      );

      if (promoData == null) {
        print("   ❌ Promo validation failed");
        print("🎟️ ═══════════════════════════════════════════════════\n");
        return;
      }

      final String promoType = promoData['promoType'] ?? '';
      final num discountValue = _asNum(promoData['discountValue']);
      final num maxDiscountCap = _asNum(promoData['maxDiscountCap']);

      num finalDiscount = 0;
      if (promoType == 'percentage_discount') {
        finalDiscount = (cartTotal * discountValue / 100);
      } else if (promoType == 'flat_discount') {
        finalDiscount = discountValue;
      }

      if (maxDiscountCap > 0 && finalDiscount > maxDiscountCap) {
        finalDiscount = maxDiscountCap;
      }
      finalDiscount = finalDiscount.round();

      setState(() {
        _promoCode = code.toUpperCase();
        _promoDiscount = finalDiscount;
        _hasPromo = true;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('applied_promo_code', code.toUpperCase());
      await prefs.setInt('applied_promo_discount', finalDiscount.toInt());

      print("   ✅ Promo applied: $_promoCode (₹$finalDiscount)");
      print("🎟️ ═══════════════════════════════════════════════════\n");

      showAppSnackBar(
        "Promo '$code' applied! You saved ₹$finalDiscount",
        type: SnackBarType.success,
      );
    } catch (e) {
      print("   ❌ Error: $e");
      showAppSnackBar(
        "Failed to apply promo code",
        type: SnackBarType.error,
      );
    }
  }

  // ✅ Apply Coupon (from Available Coupons List - Bottom Sheet)
  // This is SEPARATE from promo code manual entry
  // User can have BOTH promo code + coupon applied simultaneously
  // ✅ No API call - coupon data is already loaded from /coupons API
  Future<void> _applyCoupon(String code) async {
    try {
      print("\n🎫 ═══════════════════════════════════════════════════");
      print("🎫 APPLYING COUPON FROM LIST - ReviewOrderScreen");
      print("🎫 ═══════════════════════════════════════════════════");
      print("   Code: $code");
      print("   Source: Bottom Sheet - Available Coupons (Local Calculation)");

      final num cartTotal = _totalPrice;
      print("   Cart Total: ₹$cartTotal");

      // ✅ Find coupon data from already loaded couponList (no API call needed)
      final couponData = productController.couponList.firstWhere(
        (c) =>
            (c['code']?.toString().toUpperCase() ?? '') == code.toUpperCase(),
        orElse: () => {},
      );

      if (couponData.isEmpty) {
        print("   ❌ Coupon not found in list");
        print("🎫 ═══════════════════════════════════════════════════\n");
        showAppSnackBar("Coupon not found", type: SnackBarType.error);
        return;
      }

      print("   ✅ Coupon Data Found:");
      print("      Code: ${couponData['code']}");
      print("      Name: ${couponData['name']}");
      print("      Discount Type: ${couponData['discountType']}");
      print("      Min Cart Value: ${couponData['minCartValue']}");
      print("      Max Discount Cap: ${couponData['maxDiscountCap']}");

      // ✅ Validate minimum cart value
      final num minCartValue = _asNum(couponData['minCartValue']);
      if (cartTotal < minCartValue) {
        print("   ❌ Cart value too low");
        print("      Required: ₹$minCartValue, Current: ₹$cartTotal");
        print("🎫 ═══════════════════════════════════════════════════\n");
        showAppSnackBar(
          "Minimum cart value of ₹${minCartValue.toStringAsFixed(0)} required",
          type: SnackBarType.warning,
        );
        return;
      }

      // ✅ Parse discount type (e.g., "25% off", "500", "25%")
      final String discountTypeStr =
          (couponData['discountType'] ?? '').toString().toLowerCase();
      final num maxDiscountCap = _asNum(couponData['maxDiscountCap']);

      num finalDiscount = 0;

      if (discountTypeStr.contains('%')) {
        // Percentage discount - extract number
        final percent =
            num.tryParse(discountTypeStr.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                0;
        finalDiscount = (cartTotal * percent / 100);
        print("   📊 Percentage Discount:");
        print("      Percentage: $percent%");
        print("      Calculation: $cartTotal × $percent / 100");
        print("      Discount: ₹$finalDiscount");
      } else {
        // Flat discount - extract number
        finalDiscount =
            num.tryParse(discountTypeStr.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                0;
        print("   📊 Flat Discount:");
        print("      Discount: ₹$finalDiscount");
      }

      // ✅ Apply max discount cap
      if (maxDiscountCap > 0 && finalDiscount > maxDiscountCap) {
        print("   🛑 Discount capped:");
        print("      Original: ₹$finalDiscount");
        print("      Max Cap: ₹$maxDiscountCap");
        finalDiscount = maxDiscountCap;
      }

      finalDiscount = finalDiscount.round();
      print("   💰 Final Discount: ₹$finalDiscount");

      setState(() {
        _couponCode = code.toUpperCase();
        _couponDiscount = finalDiscount;
        _hasCoupon = true;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('applied_coupon_code', code.toUpperCase());
      await prefs.setInt('applied_coupon_discount', finalDiscount.toInt());

      print("   ✅ Coupon applied successfully!");
      print("   💾 Saved to SharedPreferences");
      print("🎫 ═══════════════════════════════════════════════════\n");

      showAppSnackBar(
        "Coupon '${couponData['name'] ?? code}' applied! You saved ₹$finalDiscount",
        type: SnackBarType.success,
      );
    } catch (e, stackTrace) {
      print("   ❌ Error: $e");
      print("   Stack trace: $stackTrace");
      print("🎫 ═══════════════════════════════════════════════════\n");
      showAppSnackBar(
        "Failed to apply coupon",
        type: SnackBarType.error,
      );
    }
  }

  // ✅ Remove Promo Code
  Future<void> _removePromoCode() async {
    setState(() {
      _promoCode = "";
      _promoDiscount = 0;
      _hasPromo = false;
      _promoCodeController.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('applied_promo_code');
    await prefs.remove('applied_promo_discount');

    showAppSnackBar("Promo code removed", type: SnackBarType.info);
  }

  // ✅ Remove Coupon
  Future<void> _removeCoupon() async {
    setState(() {
      _couponCode = "";
      _couponDiscount = 0;
      _hasCoupon = false;
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
                const NewsletterSection(
                  title: "NEWS LETTERS",
                ),
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
              fit: BoxFit.fill,
              errorWidget: (_, __, ___) =>
                  Image.asset(dummyWishlistImage, fit: BoxFit.fill),
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

          // ✅ Promo Code Discount (only show if applied)
          if (_promoDiscount > 0)
            Padding(
              padding: EdgeInsets.only(top: 12.sp),
              child: Row(
                children: [
                  const AppText(
                    text: "Promo Code Discount",
                    fontFamily: "Clash Display Regular",
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                    fontSize: 12,
                  ),
                  const Spacer(),
                  AppText(
                    text: "- ₹${formatAmount(_promoDiscount)}",
                    fontFamily: "Clash Display Regular",
                    fontWeight: FontWeight.w400,
                    color: lightPurpleColor,
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
                    color: lightPurpleColor,
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
                  color: _delivery == 0 ? lightPurpleColor : homeAppBarColor,
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
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkoutCta() {
    // Get bottom safe area padding for devices with navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: _confirmAndPay,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 20.sp, bottom: 20.sp + bottomPadding),
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

    final Color valueColor = isDiscountRow ? lightPurpleColor : homeAppBarColor;

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
                        ? lightPurpleColor
                        : lightPurpleColor,
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
