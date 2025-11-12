import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lafetch/common/widget/bottom_sheets/bottomCoupon.dart';
import 'package:lafetch/controllers/order_controller.dart';
import 'package:lafetch/screens/account/saved_address.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/change_address.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:lafetch/screens/orders/order_status_screen.dart';
import 'package:lafetch/screens/paymentcheckscreen.dart';
import 'package:lafetch/screens/paymentsuccessscreen.dart';
import 'package:lafetch/screens/wishlist/newboardscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/widget/appbar/cart_appbar.dart';
import '../common/widget/bottom_sheets/bottomCharges.dart';
import '../common/widget/bottom_sheets/bottomquantity.dart';
import '../common/widget/bottom_sheets/bottomwishlist.dart';
import '../common/widget/bottom_sheets/cartbottom.dart';
import '../common/widget/bottom_sheets/totaltaxCharges.dart';
import '../common/widget/button/doubleiconbtn.dart';
import '../common/widget/lists/dummy_container.dart';
import '../common/widget/lists/dummy_order_list.dart';
import '../common/widget/lists/dummyblack_orderlist.dart';
import '../common/widget/other/cartwidgets.dart';
import '../common/widget/other/common_widget.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/base_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../core/constant/constants.dart';
import 'catalog/productlist/productdetailsscreen.dart';

class CartScreen extends StatefulWidget {
  final Color backgroundcolor;

  const CartScreen({super.key, this.backgroundcolor = whiteColor});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final controller = Get.put(CartController());
  final profileController = Get.put(ProfileController());
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final orderController = Get.put(OrderController());

  List<String> qtyList = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // ⚠️ Use build-time config; do not hardcode live key in production.
  static const String _razorpayKey = ApiConstants.razorPayKey;

  late Razorpay _razorpay;

  /// Holds an address chosen in SavedAddressScreen before backend attach.
  Map<String, dynamic>? _pendingSelectedAddress;

  // ---------- Utilities ----------

  String? _firstImageUrl(dynamic product) {
    if (product is! Map) return null;
    final images = product["images"];
    if (images == null) return null;

    if (images is String) return images.isNotEmpty ? images : null;

    if (images is List) {
      for (final it in images) {
        if (it == null) continue;
        if (it is String && it.isNotEmpty) return it;
        if (it is Map) {
          final url =
              (it["name"] ?? it["url"] ?? it["image"] ?? it["src"])?.toString();
          if (url != null && url.isNotEmpty) return url;
        }
      }
    }
    return null;
  }

  num _asNum(dynamic v) {
    if (v is num) return v;
    return num.tryParse('$v'.replaceAll(',', '').trim()) ?? 0;
  }

  // ---------- Razorpay Handlers ----------

  void _onPaymentSuccess(PaymentSuccessResponse r) async {
    print("✅ Payment Successful!");
    print("Payment ID: ${r.paymentId}");
    print("Order ID: ${r.orderId}");
    print("Signature: ${r.signature}");

    // Show Success Screen instantly
    Get.offAll(() => const OrderStatusScreen(status: 'success'),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 400));

    // Confirm order in background
    try {
      await orderController.confirmPlaceOrder(
        providerOrderId: r.orderId ?? '',
        providerPaymentId: r.paymentId ?? '',
        providerSignature: r.signature ?? '',
      );
      print("✅ confirmPlaceOrder called successfully");
    } catch (e) {
      print("⚠️ confirmPlaceOrder failed: $e");
    }

    // Cleanup
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('applied_coupon_code');
    await prefs.remove('applied_coupon_discount');
  }

  void _onPaymentError(PaymentFailureResponse r) {
    print("❌ Razorpay Payment Error: ${r.code} → ${r.message}");
    Get.offAll(() => const OrderStatusScreen(status: 'failed'),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 400));
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    Get.to(const PaymentSuccessScreen(
      text1: "Uh-oh something went wrong!",
      orderId: 0,
      text2: "Thank you for placing your order",
      image: errorImage,
    ));
  }

  num _computeCartTotalInRupees() {
    final num total = _asNum(controller.cartDetails["total"]);
    final num couponDiscount =
        _asNum(controller.cartDetails["coupon_discount"]);
    final num deliveryCharges =
        _asNum(controller.cartDetails["shipping_cost"]) +
            _asNum(controller.cartDetails["express_delivery_charges"]);

    // 🧮 Final payable = selling total - coupon + delivery
    final num finalPayable = (total - couponDiscount) + deliveryCharges;
    return finalPayable < 0 ? 0 : finalPayable;
  }

  Future<void> _debugPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();

    print('=== PHONE DEBUG ===');
    print('phone_number from prefs: ${prefs.getString('phone_number')}');
    print('controller.userNumber.value: ${controller.userNumber.value}');

    // Check all keys in SharedPreferences
    print('All SharedPreferences keys:');
    prefs.getKeys().forEach((key) {
      if (key.toLowerCase().contains('phone') ||
          key.toLowerCase().contains('mobile') ||
          key.toLowerCase().contains('contact')) {
        print('  $key: ${prefs.get(key)}');
      }
    });
    print('==================');
  }

  Future<void> _handleCheckout() async {
    try {
      // ✅ Step 1: Validate address
      final address =
          controller.cartDetails["address"] ?? _pendingSelectedAddress;
      if (address == null) {
        _handleAddressSelection();
        getSnackBar("Please select a shipping address to continue");
        return;
      }

      final shippingAddressId = address["id"];
      if (shippingAddressId == null) {
        getSnackBar("Invalid address selected. Please choose another address.");
        return;
      }

      // ✅ Step 2: Validate user ID
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId') ?? prefs.getInt('user_id');
      if (userId == null) {
        getSnackBar("Please login to continue");
        Get.offAllNamed('/login');
        return;
      }

      // ✅ Step 3: Validate cart total
      final totalAmount = _computeCartTotalInRupees();
      if (totalAmount <= 0) {
        getSnackBar("Cart total must be greater than zero");
        return;
      }

      // ✅ Step 4: Build payload for initiate-payment
      final List<Map<String, dynamic>> items = [];
      for (final item in controller.orderList) {
        final product = (item["product"] ?? {}) as Map<String, dynamic>;
        final inventory = (item["inventory"] ?? {}) as Map<String, dynamic>;

        items.add({
          "productName": product["name"] ?? "",
          "productId": product["id"],
          "variantId": inventory["id"],
          "quantity": item["quantity"] ?? 1,
          "unitPrice": _asNum(product["price"]),
          "total": _asNum(product["price"]) * _asNum(item["quantity"]),
          "sku": "",
          "hsn": "",
        });
      }

      final orderPayload = {
        "userId": userId,
        "shippingAddressId": shippingAddressId,
        "items": items,
        "totalMRP": _asNum(controller.cartDetails["total_mrp"]),
        "total": totalAmount,
        "paymentMethod": "prepaid",
      };

      // ✅ Step 5: Call initiate-payment API
      final paymentInitData =
          await orderController.initiatePayment(orderPayload);
      if (paymentInitData == null) {
        getSnackBar("Failed to initiate payment. Please try again.");
        return;
      }

      final razorpayOrderId = paymentInitData["providerOrderId"];
      if (razorpayOrderId == null || razorpayOrderId.isEmpty) {
        getSnackBar("Unable to start payment (missing Razorpay Order ID).");
        return;
      }

      print("✅ Payment initiated. Razorpay Order ID: $razorpayOrderId");

      // ✅ Step 6: Open Razorpay checkout
      await _openRazorpayCheckout(orderId: razorpayOrderId);
    } catch (e) {
      print("🔥 Checkout error: $e");
      getSnackBar("Something went wrong. Please try again.");
    }
  }

  String _sanitizeIndianPhone(String? raw) {
    if (raw == null || raw.isEmpty) return '';

    // Remove all non-digits
    final digits = raw.replaceAll(RegExp(r'\D'), '');

    // If starts with 91, remove it
    String cleanDigits = digits;
    if (digits.startsWith('91') && digits.length > 10) {
      cleanDigits = digits.substring(2);
    }

    // Return last 10 digits
    return cleanDigits.length >= 10
        ? cleanDigits.substring(cleanDigits.length - 10)
        : cleanDigits;
  }

  bool _hasValidPhone(String? raw) {
    final sanitized = _sanitizeIndianPhone(raw);
    return sanitized.length == 10;
  }

  Future<void> _openRazorpayCheckout({String? orderId}) async {
    if (orderId == null || orderId.isEmpty) {
      getSnackBar("Payment could not be started. Missing Razorpay Order ID.");
      return;
    }

    // ✅ Now includes coupon discount automatically
    final num cartTotalInRupees = _computeCartTotalInRupees();
    final int amountInPaise = (cartTotalInRupees * 100).round();

    print("🧾 Razorpay payable (after coupon): ₹$cartTotalInRupees");

    final prefs = await SharedPreferences.getInstance();
    final String userName = (prefs.getString('user_name') ?? '').trim();
    final String userEmail = (prefs.getString('email') ?? '').trim();
    final String rawPhone = (prefs.getString('phonenumber') ??
            prefs.getString('phone_number') ??
            '')
        .trim();

    final String phone = _sanitizeIndianPhone(rawPhone);

    final options = {
      'key': _razorpayKey,
      'amount': amountInPaise,
      'currency': 'INR',
      'order_id': orderId,
      'name': 'Lafetch',
      'description': 'Cart Payment',
      'prefill': {
        'name': userName.isEmpty ? 'Customer' : userName,
        'email': userEmail.isEmpty ? 'customer@example.com' : userEmail,
        'contact': phone.length == 10 ? '+91$phone' : '+919999999999',
      },
      'theme': {'color': '#070707'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('🔥 Razorpay open error: $e');
      getSnackBar('Unable to start payment: $e');
    }
  }

  // ---------- Lifecycle ----------

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.qtyProductId.value = 0;
      controller.qtyText.value = "";
      controller.stockErrorText.value = "";
      controller.couponList.clear();
      controller.selected.clear();
      controller.selected = List.generate(50, (i) => false).obs;
      controller.addressError.value = "";
      controller.userNumber.value = "";

      // ✅ DON'T reset coupon text if it already exists
      // controller.couponText.value stays as is

      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: widget.backgroundcolor == whiteColor
            ? statusBarColor
            : homeAppBarColor,
        systemNavigationBarColor: widget.backgroundcolor == whiteColor
            ? Colors.transparent
            : homeAppBarColor,
      ));
    });

    getPreferenceValue();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
  }

  Future<void> getPreferenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString("phonenumber");

    final skip = prefs.getBool("skip") == true;

    // ✅ Restore saved coupon
    final savedCouponCode = prefs.getString('applied_coupon_code');
    final savedCouponDiscount = prefs.getInt('applied_coupon_discount');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (phone != null) {
        controller.userNumber.value = phone;
      }

      // ✅ Restore coupon state if exists
      if (savedCouponCode != null && savedCouponDiscount != null) {
        controller.couponText.value = savedCouponCode;
        controller.cartDetails["coupon_discount"] = savedCouponDiscount;
        controller.cartDetails["discount"] = true;
      } else {
        // Only reset if no saved coupon
        controller.couponText.value = "Apply Coupon";
      }

      if (skip) {
        Get.to(() => const LoginScreen(initialTab: 0, hideBack: true));
        return;
      }

      if (widget.backgroundcolor == whiteColor) {
        controller.getCartData();
      } else {
        // controller.getExpressCartData();
      }
    });
  }

  @override
  void dispose() {
    _razorpay.clear(); // remove listeners & cleanup
    super.dispose();
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.backgroundcolor == homeAppBarColor) {
          Get.offAll(const BottomNavScreen(index: 0));
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: widget.backgroundcolor,
        key: scaffoldKey,
        body: Stack(
          children: [
            Obx(
              () => controller.isPayment.value
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: whiteColor,
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      children: [
                        // App Bar (light theme)
                        Visibility(
                          visible: widget.backgroundcolor == whiteColor,
                          child: CartAppbar(
                            text: "Bag",
                            onPressedWishlist: () async {
                              Get.to(WishlistScreen());
                              await analytics.logEvent(
                                name: 'wishlist_page',
                                parameters: <String, Object>{
                                  'page_name': 'wishlist_page',
                                },
                              );
                            },
                          ),
                        ),

                        // Divider
                        Visibility(
                          visible: widget.backgroundcolor == whiteColor,
                          child: Container(
                            color: dividerColor,
                            height: 1.sp,
                          ),
                        ),

                        // Main Content
                        Expanded(
                          child: SingleChildScrollView(
                            child: Stack(
                              children: [
                                // Dark theme background decoration
                                Visibility(
                                  visible: widget.backgroundcolor != whiteColor,
                                  child: Positioned(
                                    top: 0,
                                    right: 0,
                                    child: ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black,
                                            Colors.transparent
                                          ],
                                          stops: [0.1, 1.0],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: Image.asset(
                                        quickBackCircle,
                                        height: 250.sp,
                                        width: 300.sp,
                                      ),
                                    ),
                                  ),
                                ),

                                Column(
                                  children: [
                                    // Dark theme header
                                    Visibility(
                                      visible:
                                          widget.backgroundcolor != whiteColor,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(top: 50.sp),
                                            child: Center(
                                              child: Image.asset(
                                                bagLogoImage,
                                                height: 33.sp,
                                                width: 17.sp,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 28.sp, left: 16.sp),
                                            child: const AppText(
                                              text: "BAG",
                                              fontFamily:
                                                  "Franklin Gothic Semibold",
                                              fontWeight: FontWeight.w600,
                                              color: whiteColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 1.sp, left: 16.sp),
                                            child: Obx(
                                              () => controller.isOrder.value
                                                  ? const DummyContainer(
                                                      height: 8, width: 50)
                                                  : AppText(
                                                      text: controller.orderList
                                                                  .length ==
                                                              1
                                                          ? "${controller.orderList.length} Product"
                                                          : "${controller.orderList.length} Products",
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          productSubtitleColor,
                                                      fontSize: 10,
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Cart Items List
                                    Obx(
                                      () => controller.isOrder.value
                                          ? widget.backgroundcolor == whiteColor
                                              ? const DummyOrderList(size: 3)
                                              : const DummyBlackOrderList(
                                                  size: 3)
                                          : controller.orderList.isNotEmpty
                                              ? _buildCartItemsList()
                                              : _buildEmptyCart(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Section (Address & Checkout)
                        Obx(
                          () => !controller.isOrder.value &&
                                  controller.orderList.isNotEmpty
                              ? _buildBottomSection()
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemsList() {
    final items = List<Map<String, dynamic>>.from(controller.orderList);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          key: ValueKey(
              items.map((e) => e['id'] ?? e['product']?['id']).join(',')),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, index) {
            final item = items[index];
            final product =
                (item["product"] ?? const {}) as Map<String, dynamic>;
            final inventory =
                (item["inventory"] ?? const {}) as Map<String, dynamic>;
            final imgUrl = _firstImageUrl(product);
            final outOfStock = _asNum(inventory["stocks"]).toInt() == 0;

            return KeyedSubtree(
              key: ValueKey(item['id'] ?? '${product['id']}_$index'),
              child: Padding(
                padding: EdgeInsets.only(left: 16.sp, right: 16.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 16.sp),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductImage(
                              product, imgUrl, outOfStock, index),
                          _buildProductDetails(
                              product, inventory, item, index, outOfStock),
                          _buildRemoveButton(item, index),
                        ],
                      ),
                    ),
                    if (outOfStock)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.sp, vertical: 8.sp),
                        child: const AppText(
                          text: "OUT OF STOCK",
                          color: redColor,
                          fontSize: 10,
                          maxLines: 1,
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    if (outOfStock) _buildOutOfStockActions(item, index),
                    Padding(
                      padding: EdgeInsets.only(top: 16.sp),
                      child: Container(
                        width: double.infinity,
                        color: widget.backgroundcolor == whiteColor
                            ? colorSecondary
                            : titleColor,
                        height: 1.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildProductImage(
      Map product, String? imgUrl, bool outOfStock, int index) {
    return GestureDetector(
      onTap: () => _navigateToProductDetails(index),
      child: Opacity(
        opacity: outOfStock ? 0.5 : 1,
        child: SizedBox(
          height: 130.sp,
          width: 100.sp,
          child: imgUrl != null
              ? CachedNetworkImage(
                  cacheManager: CacheManager(
                    Config(
                      "customCacheKey",
                      stalePeriod: const Duration(days: 15),
                      maxNrOfCacheObjects: 100,
                    ),
                  ),
                  fit: BoxFit.cover,
                  imageUrl: imgUrl,
                  errorWidget: (context, url, error) => Image.asset(
                    downloadImage,
                    fit: BoxFit.cover,
                    height: 130.sp,
                    width: 100.sp,
                  ),
                )
              : Image.asset(
                  dummyWishlistImage,
                  height: 130.sp,
                  width: 100.sp,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _buildProductDetails(
      Map product, Map inventory, Map item, int index, bool outOfStock) {
    return Padding(
      padding: EdgeInsets.only(left: 12.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          GestureDetector(
            onTap: () => _navigateToProductDetails(index),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 165.sp,
              child: AppText(
                text: (product["brand_name"] ?? "").toString().toUpperCase(),
                maxLines: 1,
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: widget.backgroundcolor == whiteColor
                    ? (outOfStock ? blackColor.withOpacity(0.3) : blackColor)
                    : whiteColor,
              ),
            ),
          ),

          // Product Name
          GestureDetector(
            onTap: () => _navigateToProductDetails(index),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 165.sp,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.sp),
                child: AppText(
                  text: Bidi.stripHtmlIfNeeded(product["name"] ?? ""),
                  color: widget.backgroundcolor == whiteColor
                      ? (outOfStock
                          ? subtitleColor.withOpacity(0.5)
                          : subtitleColor)
                      : productSubtitleColor,
                  maxLines: 1,
                  fontSize: 14,
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          Opacity(
            opacity: outOfStock ? 0.5 : 1,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.sp),
              child: Row(
                children: [
                  // 👇 Size box shown as non-clickable (disabled)
                  if (inventory["product_matrix_name_size"] != null &&
                      inventory["product_matrix_name_size"]
                          .toString()
                          .isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 5.sp, bottom: 5.sp),
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.backgroundcolor == whiteColor
                              ? const Color(0xffF3F4F6)
                              : const Color(0xFFDFDBFF),
                          border: Border.all(
                            width: 1,
                            color: widget.backgroundcolor == whiteColor
                                ? const Color(0xFFE5E7EB)
                                : titleColor,
                          ),
                        ),
                        height: 30.sp,
                        width: 85.sp,
                        alignment: Alignment.center,
                        child: AppText(
                          text:
                              "Size : ${inventory["product_matrix_name_size"].toString()}",
                          color: titleColor,
                          fontSize: 10,
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                  // 👇 Only this (Qty) can be changed
                  GestureDetector(
                    onTap: () => _showQuantityBottomSheet(index),
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 10.sp, top: 5.sp, bottom: 5.sp),
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.backgroundcolor == whiteColor
                              ? const Color(0xffF3F4F6)
                              : const Color(0xFFDFDBFF),
                          border: Border.all(
                            width: 1,
                            color: widget.backgroundcolor == whiteColor
                                ? const Color(0xFFE5E7EB)
                                : titleColor,
                          ),
                        ),
                        height: 30.sp,
                        width: 85.sp,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.sp, horizontal: 8.sp),
                              child: AppText(
                                text: "Qty : ${item["quantity"] ?? "0"}",
                                color: titleColor,
                                fontSize: 10,
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 2.sp, top: 2.sp, right: 2.sp),
                              child: SvgPicture.asset(
                                dropdownSvgImage,
                                color: titleColor,
                                height: 5.sp,
                                width: 8.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Qty error
          Obx(
            () => product["id"] == controller.qtyProductId.value
                ? SizedBox(
                    width: MediaQuery.of(context).size.width - 165.sp,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.sp),
                      child: AppText(
                        text: controller.qtyText.value,
                        color: deepRed,
                        fontSize: 12,
                        maxLines: 3,
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Prices
          Opacity(
            opacity: outOfStock ? 0.5 : 1,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.sp),
              child: Row(
                children: [
                  // MRP
                  Visibility(
                    visible: product["mrp"] != null &&
                        product["mrp"] != product["price"] &&
                        _asNum(product["mrp"]) > _asNum(product["price"]),
                    child: Padding(
                      padding: EdgeInsets.only(right: 10.sp),
                      child: Text(
                        "₹${product["mrp"] ?? "0"}",
                        style: TextStyle(
                          color: widget.backgroundcolor == whiteColor
                              ? lightText
                              : searchTextColor,
                          fontSize: 12.sp,
                          decoration: TextDecoration.lineThrough,
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Selling
                  Padding(
                    padding: EdgeInsets.only(right: 6.sp),
                    child: Text(
                      "₹${product["price"] ?? "0"}",
                      style: TextStyle(
                        color: widget.backgroundcolor == whiteColor
                            ? nameText
                            : whiteColor,
                        fontSize: 12.sp,
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Discount chip
                  if (_asNum(product["mrp"]) > _asNum(product["price"]))
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffA7F3D0),
                        borderRadius: BorderRadius.all(Radius.circular(20.sp)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.sp, vertical: 4.sp),
                        child: Text(
                          "${_calculateDiscountPercentage(product)} OFF",
                          style: const TextStyle(
                            color: homeAppBarColor,
                            fontSize: 12,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildRemoveButton(Map item, int index) {
    return GestureDetector(
      onTap: () => _showRemoveDialog(item),
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 6.sp),
        child: SvgPicture.asset(
          crossSearchImage,
          color: widget.backgroundcolor == whiteColor
              ? homeAppBarColor
              : whiteColor,
          height: 9.sp,
          width: 9.sp,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildOutOfStockActions(Map item, int index) {
    final product = (item["product"] ?? {}) as Map<String, dynamic>;
    final isWishlisted = product["wishlisted"] == true;

    return Padding(
      padding: EdgeInsets.only(top: 8.sp),
      child: DoubleIconButton(
        firstText: "REMOVE",
        secondText: "WISHLIST",
        firstTextColor: homeAppBarColor,
        secondTextColor: whiteColor,
        firstBackgroundColor: whiteColor,
        secondBackgroundColor: homeAppBarColor,
        firstBorderColor: homeAppBarColor,
        secondBorderColor: widget.backgroundcolor == whiteColor
            ? homeAppBarColor
            : lightPurpleColor,
        firstIcon: crossSearchImage,
        secondIcon: isWishlisted ? redHeartSvgImage : heartSvgImage,
        onPressedFirst: () => _showRemoveDialog(item),
        onPressedSecond: () => _handleWishlistAction(item, isWishlisted),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final totalMrp = _asNum(controller.cartDetails["total_mrp"]);
    final sellingTotal = _asNum(controller.cartDetails["total"]);
    final couponDiscount = _asNum(controller.cartDetails["coupon_discount"]);
    final deliveryCharges = _asNum(controller.cartDetails["shipping_cost"]) +
        _asNum(controller.cartDetails["express_delivery_charges"]);

    // Discount on MRP = difference between MRP and selling price
    final discountOnMrp = totalMrp - sellingTotal;

    // Final amount = selling price - coupon discount + delivery charges
    final finalTotal = (sellingTotal - couponDiscount) + deliveryCharges;

    return Container(
      color: widget.backgroundcolor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coupon Section
            _buildCouponSection(),

            Padding(
              padding: EdgeInsets.only(top: 24.sp),
              child: AppText(
                text: "ORDER DETAILS",
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w500,
                color: widget.backgroundcolor == whiteColor
                    ? homeAppBarColor
                    : whiteColor,
                fontSize: 14,
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp),
              child: Container(
                width: double.infinity,
                color: colorSecondary,
                height: 1.sp,
              ),
            ),

            // 🟣 Total MRP
            _buildPriceRow(
              "Total MRP",
              "₹${totalMrp.toStringAsFixed(0)}",
              false,
            ),

            // 🟢 Discount on MRP (Green with minus sign)
            if (discountOnMrp > 0)
              _buildPriceRow(
                "Discount on MRP",
                "- ₹${discountOnMrp.toStringAsFixed(0)}",
                false,
              ),

            // Divider before Subtotal
            if (discountOnMrp > 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.sp),
                child: Container(
                  width: double.infinity,
                  color: colorSecondary,
                  height: 0.5.sp,
                ),
              ),

            // 🔵 Subtotal (Selling Price)
            Padding(
              padding: EdgeInsets.only(top: 12.sp),
              child: Row(
                children: [
                  AppText(
                    text: "Subtotal",
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: widget.backgroundcolor == whiteColor
                        ? subtitleColor
                        : productSubtitleColor,
                    fontSize: 12,
                  ),
                  const Spacer(),
                  AppText(
                    text: "₹${sellingTotal.toStringAsFixed(0)}",
                    fontFamily: "Franklin Gothic",
                    fontWeight: FontWeight.w500,
                    color: widget.backgroundcolor == whiteColor
                        ? homeAppBarColor
                        : whiteColor,
                    fontSize: 12,
                  ),
                ],
              ),
            ),

            // 🟡 Coupon Discount (ALWAYS SHOW IF > 0)
            if (couponDiscount > 0)
              Padding(
                padding: EdgeInsets.only(top: 12.sp),
                child: Row(
                  children: [
                    AppText(
                      text: "Coupon Discount",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: widget.backgroundcolor == whiteColor
                          ? subtitleColor
                          : productSubtitleColor,
                      fontSize: 12,
                    ),
                    const Spacer(),
                    AppText(
                      text: "- ₹${couponDiscount.toStringAsFixed(0)}",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff059669), // Green color
                      fontSize: 12,
                    ),
                  ],
                ),
              ),

            // 🟠 Delivery Charges
            Padding(
              padding: EdgeInsets.only(top: 12.sp),
              child: Row(
                children: [
                  AppText(
                    text: "Delivery Charges",
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: widget.backgroundcolor == whiteColor
                        ? subtitleColor
                        : productSubtitleColor,
                    fontSize: 12,
                  ),
                  const Spacer(),
                  AppText(
                    text: deliveryCharges == 0
                        ? "Free"
                        : "+ ₹${deliveryCharges.toStringAsFixed(0)}",
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: deliveryCharges == 0
                        ? const Color(0xff059669) // Green for Free
                        : (widget.backgroundcolor == whiteColor
                            ? homeAppBarColor
                            : whiteColor),
                    fontSize: 12,
                  ),
                ],
              ),
            ),

            // Divider before Total
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp),
              child: Container(
                width: double.infinity,
                color: colorSecondary,
                height: 1.5.sp,
              ),
            ),

            // 🔵 Final Total
            Row(
              children: [
                AppText(
                  text: "TOTAL AMOUNT",
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w500,
                  color: widget.backgroundcolor == whiteColor
                      ? colorPrimary
                      : whiteColor,
                  fontSize: 15,
                ),
                const Spacer(),
                AppText(
                  text: "₹${finalTotal.toStringAsFixed(0)}",
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w500,
                  color: widget.backgroundcolor == whiteColor
                      ? colorPrimary
                      : whiteColor,
                  fontSize: 15,
                ),
              ],
            ),

            SizedBox(height: 30.sp),
            Cartbottom(backgroundColor: widget.backgroundcolor),
            SizedBox(height: 40.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.sp),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.sp),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        child: Obx(() {
          final bool hasDiscount = controller.cartDetails["discount"] == true;
          final String couponText = controller.couponText.value;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                couponSvgImage,
                color: widget.backgroundcolor == whiteColor
                    ? titleColor
                    : productSubtitleColor,
                height: 20.sp,
                width: 20.sp,
              ),
              SizedBox(width: 8.sp),
              Expanded(
                child: Text(
                  couponText,
                  style: TextStyle(
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w500,
                    color: widget.backgroundcolor == whiteColor
                        ? titleColor
                        : productSubtitleColor,
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
                    if (hasDiscount) {
                      await _removeAppliedCoupon();
                      return;
                    }

                    // ✅ Always fetch live coupons before showing bottom sheet
                    await productController.getCoupons();

                    if (productController.couponList.isEmpty) {
                      getSnackBar("No coupons available right now");
                      return;
                    }

                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (ctx) {
                        return FractionallySizedBox(
                          heightFactor: 0.7, // 👈 Only covers 70% of the screen
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: BottomCoupon(
                              list: productController.couponList,
                              backColor: widget.backgroundcolor,
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
                    backgroundColor: hasDiscount
                        ? Colors.transparent
                        : (widget.backgroundcolor == whiteColor
                            ? homeAppBarColor
                            : Colors.transparent),
                    side: BorderSide(
                      color: hasDiscount
                          ? redColor
                          : (widget.backgroundcolor == whiteColor
                              ? btnTextColor
                              : Colors.transparent),
                      width: 1.sp,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    hasDiscount ? "REMOVE" : "SELECT",
                    style: TextStyle(
                      color: hasDiscount ? redColor : whiteColor,
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
        getSnackBar("Invalid or expired coupon");
        return;
      }

      final num total = _asNum(controller.cartDetails["total"]);
      final num minCart = _asNum(coupon['minCartValue']);
      if (total < minCart) {
        getSnackBar(
            "Coupon requires a minimum cart value of ₹${minCart.toStringAsFixed(0)}");
        return;
      }

      // Parse discount
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

      // Cap discount
      final maxDiscount = _asNum(coupon['maxDiscountCap']);
      if (maxDiscount > 0 && discountValue > maxDiscount) {
        discountValue = maxDiscount;
      }

      // Update state
      controller.couponText.value = code;
      controller.cartDetails["coupon_discount"] = discountValue;
      controller.cartDetails["discount"] = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('applied_coupon_code', code);
      await prefs.setInt('applied_coupon_discount', discountValue.toInt());

      getSnackBar("Coupon '$code' applied successfully");
      controller.update();
    } catch (e) {
      print("✗ Error applying coupon: $e");
      getSnackBar("Failed to apply coupon. Please try again.");
    }
  }

// ---------- Remove Applied Coupon (Reactive) ----------
  Future<void> _removeAppliedCoupon() async {
    controller.couponText.value = "Apply Coupon";
    controller.couponSave.value = "0";
    controller.cartDetails["discount"] = false;
    controller.cartDetails["coupon_discount"] = 0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('applied_coupon_code');
    await prefs.remove('applied_coupon_discount');

    getSnackBar("Coupon removed");

    // ✅ will instantly update all Obx UI
    controller.update();
  }

// ---------- Price Row (Green discount values) ----------

  Widget _buildPriceRow(String label, String value, bool hasIcon) {
    final bool isDiscountRow =
        label.toLowerCase().contains("discount") && !label.contains("Delivery");

    final Color valueColor = isDiscountRow
        ? const Color(0xff059669)
        : widget.backgroundcolor == whiteColor
            ? homeAppBarColor
            : whiteColor;

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
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: widget.backgroundcolor == whiteColor
                        ? subtitleColor
                        : productSubtitleColor,
                    fontSize: 12,
                    maxLines: 1,
                    // overflow: TextOverflow.ellipsis, // ❌ Remove this line
                  ),
                ),
                if (hasIcon &&
                    (label == "Total Price" || label == "Convenience Fee"))
                  Padding(
                    padding: EdgeInsets.only(left: 4.sp),
                    child: GestureDetector(
                      onTap: () => _showInfoBottomSheet(label),
                      child: SvgPicture.asset(
                        questionSvgImage,
                        height: 15.sp,
                        width: 15.sp,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.sp),
          AppText(
            text: value,
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.w400,
            color: valueColor,
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Padding(
      padding: EdgeInsets.only(top: 60.sp),
      child: CartWidget(
        image: shopBagImage,
        backColor: widget.backgroundcolor,
        text1: "There is still room for more",
        onPressed: () => Get.offAll(const BottomNavScreen(index: 0)),
        text2:
            "Looking for items you previously saved?\nSign in to pick up where you left out",
        btntext: "Continue Shopping",
        visible: true,
      ),
    );
  }

  Widget sizeWidget(List orderList, int index) {
    double width = 100.sp;
    final String? size = (orderList[index]?["inventory"]
            ?["product_matrix_name_size"])
        ?.toString();

    if (["XS", "S", "M", "L", "XL", "XXL", "XXXL"].contains(size)) {
      width = 85.sp;
    }

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundcolor == whiteColor
            ? const Color(0xffF3F4F6)
            : const Color(0xFFDFDBFF),
        border: Border.all(
          width: 1,
          color: widget.backgroundcolor == whiteColor
              ? const Color(0xFFE5E7EB)
              : titleColor,
        ),
      ),
      height: 30.sp,
      width: width,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 8.sp, right: 5.sp, top: 5.sp, bottom: 5.sp),
            child: AppText(
              text: "Size : ${size ?? ""}",
              color: titleColor,
              fontSize: 10,
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 2.sp, top: 2.sp, right: 2.sp),
            child: SvgPicture.asset(
              dropdownSvgImage,
              color: titleColor,
              height: 5.sp,
              width: 8.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => controller.addressError.value.isNotEmpty
              ? Padding(
                  padding:
                      EdgeInsets.only(left: 20.sp, right: 20.sp, top: 10.sp),
                  child: AppText(
                    text: controller.addressError.value,
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: redColor,
                    fontSize: 12,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        GestureDetector(
          onTap: () => _handleAddressSelection(),
          child: Container(
            color: widget.backgroundcolor == whiteColor
                ? lightgreyColor
                : homeAppBarColor,
            margin: EdgeInsets.only(top: 10.sp),
            height: 40.sp,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Row(
                children: [
                  Obx(() {
                    if (controller.isOrder.value) {
                      return const SizedBox(width: 0);
                    }
                    final hasAnyAddress =
                        controller.cartDetails["address"] != null ||
                            _pendingSelectedAddress != null;
                    return Text(
                      hasAnyAddress ? "DELIVERING IN " : "",
                      style: TextStyle(
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w500,
                        color: searchTextColor,
                        fontSize: 14.sp,
                      ),
                    );
                  }),
                  Obx(() {
                    if (controller.isOrder.value) {
                      return const DummyContainer(height: 10, width: 100);
                    }
                    final cartAddr = controller.cartDetails["address"];
                    String label;
                    if (cartAddr != null) {
                      label =
                          "${cartAddr["type"] ?? ""} ${cartAddr["zip"] ?? ""}"
                              .toUpperCase();
                    } else if (_pendingSelectedAddress != null) {
                      label =
                          "${_pendingSelectedAddress!["name"] ?? "ADDRESS"} ${_pendingSelectedAddress!["pincode"] ?? ""}"
                              .toUpperCase();
                    } else {
                      label = "Select Shipping Address";
                    }
                    return Text(
                      label,
                      style: TextStyle(
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w500,
                        color: widget.backgroundcolor == whiteColor
                            ? titleColor
                            : lightgreyColor,
                        fontSize: 14.sp,
                      ),
                    );
                  }),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(left: 2.sp, right: 5.sp),
                    child: Image.asset(
                      rightArrowImage,
                      color: widget.backgroundcolor == whiteColor
                          ? titleColor
                          : lightgreyColor,
                      height: 16.sp,
                      width: 16.sp,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(
          () => controller.stockErrorText.value.isEmpty
              ? _buildCheckoutButton()
              : _buildStockError(),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return GestureDetector(
      onTap: _handleCheckout,
      child: Container(
        width: double.infinity,
        height: widget.backgroundcolor == whiteColor ? 70.sp : 50.sp,
        color: widget.backgroundcolor == whiteColor
            ? homeAppBarColor
            : lightPurpleColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16.sp),
              child: Obx(
                () => controller.isOrder.value
                    ? const SizedBox.shrink()
                    : (controller.pageState == PageState.LOADING)
                        ? Center(
                            child: Transform.scale(
                              scale: 0.5.sp,
                              child: const CircularProgressIndicator(
                                  color: whiteColor),
                            ),
                          )
                        : Text(
                            controller.cartDetails["address"] == null &&
                                    _pendingSelectedAddress == null
                                ? "PROCEED TO CHECKOUT"
                                : "PROCEED TO PAY",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white,
                              fontFamily: 'Franklin Gothic',
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockError() {
    return Padding(
      padding: EdgeInsets.only(top: 20.sp, bottom: 30.sp, left: 16.sp),
      child: Text(
        controller.stockErrorText.value,
        style: TextStyle(
          fontSize: 13.sp,
          color: redColor,
          fontFamily: 'Franklin Gothic',
        ),
      ),
    );
  }

  // ---------- Helpers ----------

  String _calculateDiscountPercentage(Map product) {
    final mrp = _asNum(product["mrp"]);
    final price = _asNum(product["price"]);
    if (mrp > price && mrp > 0) {
      final discount = ((mrp - price) / mrp * 100).round();
      return "$discount%";
    }
    return "0%";
  }

  void _navigateToProductDetails(int index) async {
    final item = controller.orderList[index];
    final product = item["product"];

    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (BuildContext context) => ProductDetailsScreen(
            productId: product["id"],
            brandName: product["brand_name"] ?? "",
            backgroundcolor: widget.backgroundcolor,
            type: "add",
            expressValue: widget.backgroundcolor == whiteColor ? 0 : 1,
          ),
        ))
        .then((_) {});

    await analytics.logEvent(
      name: 'cart_product_details',
      parameters: <String, Object>{'page_name': 'cart_product_details'},
    );
  }

  void _showQuantityBottomSheet(int index) async {
    final item = controller.orderList[index];
    if (item["inventory"]["stocks"] == 0) return;

    if (item["product"]["express_delivery"] == true) {
      controller.qtyProductId.value = item["product"]["id"];
      controller.qtyText.value =
          "For express delivery product, quantity cant be updated.";
      controller.update();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: double.infinity,
        maxHeight: 230.sp,
      ),
      builder: (ctx) {
        return BottomQuantity(
          qtyList: qtyList,
          selectedQty: item["quantity"].toString(),
          controller: controller,
          stock: item["inventory"]["stocks"] > 10
              ? qtyList.length
              : item["inventory"]["stocks"],
          onPressed: (quantity) {
            controller.callAddtoCart(
              quantity,
              "quantity",
              item["inventory"]["id"],
              item["product"]["id"],
              item["product"]["express_delivery"] ? 1 : 0,
              1,
              widget.backgroundcolor,
              item["inventory"]["id"],
            );
          },
        );
      },
    );

    await analytics.logEvent(
      name: 'cart_product_updateqtyClick',
      parameters: <String, Object>{'page_name': 'cart_product_updateqtyClick'},
    );

    controller.qtyProductId.value = 0;
    controller.qtyText.value = "";
    controller.update();
  }

  void _showRemoveDialog(Map item) async {
    final productId = (item["product"]["id"] is num)
        ? (item["product"]["id"] as num).toInt()
        : int.tryParse("${item["product"]["id"]}") ?? 0;

    showDialog(
      barrierColor: Colors.black26,
      context: context,
      builder: (context) {
        return showDoubleBtnDailog(
          click1: () => Get.back(),
          click2: () async {
            Get.back();
            await controller.callDeleteCart(widget.backgroundcolor, productId);
          },
          btncolor: colorPrimary,
          text: "Are you sure you want to remove this item?",
          btn1Text: "Cancel",
          btn2Text: "Remove",
        );
      },
    );

    await analytics.logEvent(
      name: 'cart_product_removeClick',
      parameters: <String, Object>{'page_name': 'cart_product_removeClick'},
    );
  }

  void _handleWishlistAction(Map item, bool isWishlisted) async {
    final product = (item["product"] ?? {}) as Map<String, dynamic>;
    final productId = (product["id"] is num)
        ? (product["id"] as num).toInt()
        : int.tryParse("${product["id"]}") ?? 0;

    if (isWishlisted) {
      final wishlistId = product["wishlist_id"];
      wishlistController.addProductToBoard(wishlistId, productId);
      await controller.getCartData();

      await analytics.logEvent(
        name: 'cart_wishlist_remove',
        parameters: <String, Object>{'page_name': 'cart_wishlist_remove'},
      );
    } else {
      final preview = _firstImageUrl(product) ?? "";

      scaffoldKey.currentState?.showBottomSheet(
        (context) => BottomWishlist(
          controller: wishlistController,
          onPressedBoard: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                  builder: (context) => NewBoardScreen(
                    title: "New Board",
                    boardId: 0,
                    screen: "Bag",
                    productId: productId,
                    hintName: "Name of the Board",
                    boardName: "",
                    btnText: "Next",
                  ),
                ))
                .then((_) {});
          },
          productImage: preview,
          onPressed: (boardId) async {
            wishlistController.addProductToBoard(boardId, productId);
            await controller.callDeleteCart(widget.backgroundcolor, productId);
          },
          wishlistList: wishlistController.wishlistList,
        ),
      );

      await analytics.logEvent(
        name: 'cart_wishlist_add',
        parameters: <String, Object>{'page_name': 'cart_wishlist_add'},
      );
    }
  }

  void _showInfoBottomSheet(String label) {
    if (label == "Total Price") {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints(
          maxWidth: double.infinity,
          maxHeight: 220.sp,
        ),
        builder: (ctx) {
          return TotalTaxcharges(
            total: "₹${controller.cartDetails["total"] ?? "0"}",
            tax: "₹${controller.cartDetails["total_tax"] ?? "0"}",
            title: "Tax & Charges",
            price: "₹${controller.cartDetails["total_mrp"] ?? "0"}",
          );
        },
      );
    } else if (label == "Convenience Fee") {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints(
          maxWidth: double.infinity,
          maxHeight: 220.sp,
        ),
        builder: (ctx) {
          return const BottomCharges(
            text:
                "This fee covers the costs of our convenient online shopping services, including secure payment processing, 24/7 customer support, and fast order processing. It helps us offer you a hassle-free shopping experience from the comfort of your home.",
            title: "Convenience Fee",
          );
        },
      );
    }
  }

  // Open SavedAddress when no address; else ChangeAddress
  void _handleAddressSelection() async {
    if (controller.cartDetails["address"] != null) {
      final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ChangeAddressScreen(
            cartId: controller.cartDetails["id"],
          ),
        ),
      );

      if (changed == true) {}

      await analytics.logEvent(
        name: 'cart_changeAddressclick',
        parameters: <String, Object>{'page_name': 'cart_changeAddressclick'},
      );
      return;
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SavedAddressScreen(type: ''),
      ),
    );

    if (result is Map) {
      setState(() {
        _pendingSelectedAddress = Map<String, dynamic>.from(result);
        controller.addressError.value = "";
      });
    } else if (result == true) {}
  }
}
