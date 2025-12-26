// lib/screens/review_order_screen.dart
// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/bottom_sheets/bottomCoupon.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/controllers/order_controller.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/screens/account/saved_address.dart';
import 'package:lafetch/controllers/product_controller.dart';
import 'package:lafetch/screens/orders/order_status_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // --- totals ---
  double get _totalPrice =>
      (widget.price * (widget.quantity <= 0 ? 1 : widget.quantity)).toDouble();
  final double _delivery = 0; // if you add charges later, UI adapts
  final double _convenience = 0;

  num _asNum(dynamic v) {
    if (v is num) return v;
    return num.tryParse('$v'.replaceAll(',', '').trim()) ?? 0;
  }

  num _computePayable() {
    final num sellingPrice = _totalPrice;

    // Apply coupon on selling
    final num discountedPrice = sellingPrice - _couponDiscount;

    // Final total = discounted price + delivery + convenience
    final num total = discountedPrice + _delivery + _convenience;

    return total < 0 ? 0 : total;
  }

  @override
  void initState() {
    super.initState();
    _address = widget.initialAddress;

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
  Future<void> _confirmAndPay() async {
    // 1) address
    if (_address == null) {
      await _pickAddress();
      if (_address == null) {
        _snack("Please select a shipping address to continue");
        return;
      }
    }
    final shippingAddressId = _address?['id'];
    if (shippingAddressId == null) {
      _snack("Invalid address selected. Please choose another address.");
      return;
    }

    // 2) user id
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId') ?? prefs.getInt('user_id');
    if (userId == null) {
      _snack("Please login to continue");
      Get.offAllNamed('/login');
      return;
    }

    // 3) product sanity
    if (widget.productId <= 0 || widget.quantity <= 0 || widget.price <= 0) {
      _snack("Invalid product data. Please try again.");
      return;
    }

    // 4) total validation
    final payable = _computePayable();
    if (payable <= 0) {
      _snack("Order total must be greater than zero");
      return;
    }

    // 5) build payload (note: send **final total** in `total`)
    final orderPayload = {
      "userId": userId,
      "shippingAddressId": shippingAddressId,
      "items": [
        {
          "productName": widget.title,
          "productId": widget.productId,
          "variantId": widget.variantId,
          "quantity": widget.quantity,
          "unitPrice": widget.price,
          "total": payable, // final payable for this line
          "sku": "",
          "hsn": ""
        }
      ],
      "totalMRP": widget.mrp,
      "total": payable,
      "paymentMethod": "prepaid",
    };

    // 6) local backup
    await prefs.setString('pending_order_payload', jsonEncode(orderPayload));
    await prefs.setInt('pending_order_total', payable.toInt());
    await prefs.setInt('pending_order_userId', userId);
    await prefs.setInt('pending_order_shippingAddressId', shippingAddressId);

    // 7) initiate payment
    final paymentInitData = await orderController.initiatePayment(orderPayload);
    if (paymentInitData == null) {
      _snack("Failed to initiate payment. Please try again.");
      return;
    }
    final razorpayOrderId = paymentInitData["providerOrderId"];
    if ((razorpayOrderId ?? '').toString().isEmpty) {
      _snack("Unable to start payment (missing Razorpay Order ID).");
      return;
    }

    // 8) open Razorpay with **discounted** amount
    await _openRazorpayCheckout(orderId: razorpayOrderId);
  }

  Future<void> _openRazorpayCheckout({required String orderId}) async {
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
      _snack("Invalid Razorpay Payment Order ID");
      return;
    }

    if (_razorpayKey.isEmpty) {
      print("❌ ERROR: Razorpay key missing!");
      _snack("Payment configuration missing (Key)");
      return;
    }

    if (amountInPaise <= 0) {
      print("❌ ERROR: amount is ZERO → Razorpay cannot open");
      _snack("Invalid payable amount");
      return;
    }

    final options = {
      'key': _razorpayKey,
      'amount': amountInPaise,
      'currency': 'INR',
      'order_id': orderId,
      'name': 'Lafetch',
      'description': '${widget.title} • Qty ${widget.quantity}',
      'prefill': {
        'name': userName.isEmpty ? 'Customer' : userName,
        'email': userEmail.isEmpty ? 'customer@example.com' : userEmail,

        // ONLY PHONE DIGITS for Razorpay
        'contact': phone.isNotEmpty ? phone : '9999999999',
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
      _snack('Unable to start payment: ${e.toString()}');
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
    _snack('External wallet: ${r.walletName}');
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
                    _snack("No coupons available right now");
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
                    color: _hasDiscount ? redColor : btnTextColor,
                    width: 1.sp,
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  _hasDiscount ? "REMOVE" : "SELECT",
                  style: TextStyle(
                    color: _hasDiscount ? redColor : whiteColor,
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
        _snack("Invalid or expired coupon");
        return;
      }

      // Requirements from CartScreen:
      final num total = _asNum(_totalPrice);
      final num minCart = _asNum(coupon['minCartValue']);
      if (total < minCart) {
        _snack(
            "Coupon requires a minimum cart value of ₹${minCart.toStringAsFixed(0)}");
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

      _snack("Coupon '$code' applied successfully");
    } catch (e) {
      print("✗ Error applying coupon: $e");
      _snack("Failed to apply coupon. Please try again.");
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

    _snack("Coupon removed");
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
                    _pill('Qty : ${widget.quantity}'),
                  ],
                ),
                SizedBox(height: 10.sp),
                Row(
                  children: [
                    if (widget.mrp > widget.price)
                      Padding(
                        padding: EdgeInsets.only(right: 8.sp),
                        child: Text(
                          "₹${widget.mrp.toStringAsFixed(0)}",
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
                      text: "₹${widget.price.toStringAsFixed(0)}",
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
    final num subtotal = _totalPrice;
    final num payable = _computePayable();

    // discount on MRP (like Bag screen shows sometimes)
    final num discountOnMrp = (widget.mrp - _totalPrice);
    final bool hasMrpDiscount = discountOnMrp > 0;

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
          SizedBox(height: 10.sp),

          // Total MRP
          _kv("Total MRP", "₹${widget.mrp.toStringAsFixed(2)}"),
// Total MRP
          _kv("Total MRP", "₹${widget.mrp.toStringAsFixed(2)}"),

          // Discount on MRP (if any)
          if (hasMrpDiscount)
            _kvGreen(
                "Discount on MRP", "- ₹${discountOnMrp.toStringAsFixed(2)}"),

          // Subtotal (selling)
          _kv("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),

          // Coupon discount (green)
          if (_couponDiscount > 0)
            _kvGreen(
                "Coupon Discount", "- ₹${_couponDiscount.toStringAsFixed(2)}"),

          // Delivery charges (Free in green)
          Row(
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
                text: _delivery == 0
                    ? "Free"
                    : "₹${_delivery.toStringAsFixed(2)}",
                fontFamily: "Clash Display Regular",
                fontWeight: FontWeight.w600,
                color:
                    _delivery == 0 ? const Color(0xff059669) : homeAppBarColor,
                fontSize: 12,
              ),
            ],
          ),

          Divider(color: colorSecondary, height: 30.sp),

          // TOTAL AMOUNT
          Row(
            children: [
              const AppText(
                text: "TOTAL AMOUNT",
                fontFamily: "Clash Display",
                fontWeight: FontWeight.w700,
                color: blackColor,
                fontSize: 13,
              ),
              const Spacer(),
              AppText(
                text: "₹${payable.toStringAsFixed(2)}",
                fontFamily: "Clash Display",
                fontWeight: FontWeight.w700,
                color: blackColor,
                fontSize: 13,
              ),
            ],
          )
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

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.only(top: 8.sp, bottom: 4.sp),
      child: Row(
        children: [
          const AppText(
            text: "",
            fontFamily: "Clash Display Regular",
            fontWeight: FontWeight.w400,
            color: subtitleColor,
            fontSize: 12,
          ),
          // The key
          Expanded(
            child: AppText(
              text: k,
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontSize: 12,
            ),
          ),
          AppText(
            text: v,
            fontFamily: "Clash Display Regular",
            fontWeight: FontWeight.w400,
            color: homeAppBarColor,
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  Widget _kvGreen(String k, String v) {
    return Padding(
      padding: EdgeInsets.only(top: 8.sp, bottom: 4.sp),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: k,
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontSize: 12,
            ),
          ),
          Text(
            v,
            style: TextStyle(
              color: const Color(0xff059669),
              fontSize: 12.sp,
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.w600,
            ),
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

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
