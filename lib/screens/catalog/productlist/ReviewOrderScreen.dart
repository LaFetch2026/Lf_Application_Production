// lib/screens/review_order_screen.dart
// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/bottom_sheets/bottomCoupon.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/screens/account/saved_address.dart';
import 'package:lafetch/controllers/product_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ReviewOrderScreen extends StatefulWidget {
  final int productId;
  final String title;
  final String brandName;
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
  static const String _razorpayKey = "rzp_live_rhkxLWkaUrRAHO";

  final productController = Get.put(ProductController());

  Razorpay? _rzp;
  Map<String, dynamic>? _address;

  RxString couponText = "Apply Coupon".obs;
  RxBool hasDiscount = false.obs;
  double couponDiscount = 0;

  double get _totalPrice =>
      widget.price * (widget.quantity <= 0 ? 1 : widget.quantity);
  double get _delivery => 0;
  double get _convenience => 0;
  double get _billTotal =>
      _totalPrice - couponDiscount + _delivery + _convenience;

  @override
  void initState() {
    super.initState();
    _address = widget.initialAddress;

    _rzp = Razorpay();
    _rzp!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _rzp!.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _rzp!.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    // Load coupons on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await productController.getCoupons();
    });
  }

  @override
  void dispose() {
    try {
      _rzp?.clear();
    } catch (_) {}
    super.dispose();
  }

  // =========================================================
  // Address
  // =========================================================
  Future<void> _pickAddress() async {
    final result = await Get.to(() => const SavedAddressScreen(type: 'select'));
    if (result is Map) {
      setState(() => _address = Map<String, dynamic>.from(result));
    }
  }

  Future<void> _confirmAndPay() async {
    if (_address == null) {
      await _pickAddress();
      if (_address == null) return;
    }
    await _openRazorpayCheckout(orderId: widget.razorpayOrderId);
  }

  Future<void> _openRazorpayCheckout({String? orderId}) async {
    final num cartTotalInRupees = _billTotal;
    final int amountInPaise = (cartTotalInRupees * 100).round();

    final prefs = await SharedPreferences.getInstance();
    final String userName = (prefs.getString('user_name') ?? '').trim();
    final String userEmail = (prefs.getString('email') ?? '').trim();
    final String rawPhone =
        (prefs.getString('phonenumber') ?? '').trim(); // ✅ consistent key

    final String phone = _sanitizeIndianPhone(rawPhone);

    final options = <String, dynamic>{
      'key': _razorpayKey,
      'amount': amountInPaise,
      'currency': 'INR',
      if (orderId != null && orderId.isNotEmpty) 'order_id': orderId,
      'name': 'Lafetch',
      'description': '${widget.title} • Qty ${widget.quantity}',
      'prefill': <String, dynamic>{
        if (userName.isNotEmpty) 'name': userName,
        if (userEmail.isNotEmpty) 'email': userEmail,
        'contact': phone.length == 10 ? '+91$phone' : '+919999999999',
      },
      'theme': {'color': '#070707'},
      'notes': {
        'product_id': widget.productId.toString(),
        if (_address != null) 'address': _prettyAddress(_address!),
      },
    };

    try {
      _rzp?.open(options);
    } catch (e) {
      print('Razorpay error: $e');
      _snack('Unable to start payment: $e');
    }
  }

  // =========================================================
  // Coupon Section (Live API Integration)
  // =========================================================
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
        child: Obx(() {
          return Row(
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
                  couponText.value,
                  style: TextStyle(
                    fontFamily: "Franklin Gothic Regular",
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
                    if (hasDiscount.value) {
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
                      builder: (ctx) {
                        return BottomCoupon(
                          list: productController.couponList,
                          backColor: whiteColor,
                          onPressed: (code) {
                            Navigator.pop(ctx);
                            _applyCoupon(code);
                          },
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: hasDiscount.value
                        ? Colors.transparent
                        : homeAppBarColor,
                    side: BorderSide(
                      color: hasDiscount.value ? redColor : btnTextColor,
                      width: 1.sp,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    hasDiscount.value ? "REMOVE" : "SELECT",
                    style: TextStyle(
                      color: hasDiscount.value ? redColor : whiteColor,
                      fontSize: 12.sp,
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
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

      num discountValue = 0;
      final type = (coupon['type'] ?? '').toString().toLowerCase();
      final num total = _totalPrice;

      if (type == 'percentage') {
        final discountPercent =
            num.tryParse(coupon['discount']?.toString() ?? '0') ?? 0;
        discountValue = (total * (discountPercent / 100)).round();
      } else if (type == 'flat') {
        discountValue =
            num.tryParse(coupon['discount']?.toString() ?? '0') ?? 0;
      }

      final maxDiscount =
          num.tryParse(coupon['max_discount']?.toString() ?? '0') ?? 0;
      if (maxDiscount > 0 && discountValue > maxDiscount) {
        discountValue = maxDiscount;
      }

      setState(() {
        couponDiscount = discountValue.toDouble();
      });
      couponText.value = code;
      hasDiscount.value = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('applied_coupon_code', code);
      await prefs.setInt('applied_coupon_discount', discountValue.toInt());

      _snack("Coupon '$code' applied successfully");
    } catch (e) {
      print("✗ Error applying coupon: $e");
      _snack("Failed to apply coupon. Please try again.");
    }
  }

  void _removeAppliedCoupon() async {
    couponText.value = "Apply Coupon";
    hasDiscount.value = false;
    couponDiscount = 0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('applied_coupon_code');
    await prefs.remove('applied_coupon_discount');

    _snack("Coupon removed");
    setState(() {});
  }

  // =========================================================
  // Razorpay Handlers
  // =========================================================
  void _onPaymentSuccess(PaymentSuccessResponse r) {
    _snack('Payment successful');
  }

  void _onPaymentError(PaymentFailureResponse r) {
    _snack('Payment failed: ${r.message ?? r.code}');
  }

  void _onExternalWallet(ExternalWalletResponse r) {
    _snack('External wallet: ${r.walletName}');
  }

  // =========================================================
  // UI
  // =========================================================
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
          fontFamily: "Franklin Gothic",
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
                  fontFamily: "Franklin Gothic",
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
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    AppText(
                      text: "₹${widget.price.toStringAsFixed(0)}",
                      fontFamily: "Franklin Gothic",
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            text: "ORDER DETAILS",
            fontFamily: "Franklin Gothic",
            fontWeight: FontWeight.w500,
            color: homeAppBarColor,
            fontSize: 14,
          ),
          SizedBox(height: 10.sp),
          _kv("Total Price", "₹${_totalPrice.toStringAsFixed(2)}"),
          if (couponDiscount > 0)
            _kv("Coupon Discount", "- ₹${couponDiscount.toStringAsFixed(2)}"),
          _kv("Delivery Charges", "₹${_delivery.toStringAsFixed(2)}"),
          _kv("Convenience Fee", "₹${_convenience.toStringAsFixed(2)}"),
          Divider(color: colorSecondary, height: 30.sp),
          _kv("Total Payable", "₹${_billTotal.toStringAsFixed(2)}"),
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
                fontFamily: "Franklin Gothic",
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
          fontFamily: "Franklin Gothic",
          fontWeight: FontWeight.w500,
          color: whiteColor,
          fontSize: 13,
        ),
      ),
    );
  }

  static String _prettyAddress(Map<String, dynamic> a) {
    final parts = <String>[
      a['full']?.toString() ??
          [
            a['name'],
            a['line1'] ?? a['address'],
            a['city'],
            a['state'],
            a['pincode'] ?? a['zip']
          ].where((e) => (e?.toString().trim() ?? '').isNotEmpty).join(', ')
    ].where((e) => (e?.toString().trim() ?? '').isNotEmpty).toList();
    return parts.join(', ');
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.only(top: 8.sp, bottom: 4.sp),
      child: Row(
        children: [
          AppText(
            text: k,
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.w400,
            color: subtitleColor,
            fontSize: 12,
          ),
          const Spacer(),
          AppText(
            text: v,
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.w400,
            color: homeAppBarColor,
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
        fontFamily: "Franklin Gothic Regular",
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
