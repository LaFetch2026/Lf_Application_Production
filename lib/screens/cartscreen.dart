import 'dart:io' show Platform;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
import '../core/services/meta_event_service.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../core/constant/constants.dart';
import '../common/widget/newsletter/newsletter_section.dart';
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

  // Promo code text controller (manual entry)
  final TextEditingController _promoCodeController = TextEditingController();

  // --- Promo Code state (manual entry) ---
  String _promoCode = "";
  bool _hasPromo = false;
  num _promoDiscount = 0;

  // --- Coupon state (from available coupons list) ---
  String _couponCode = "";
  bool _hasCoupon = false;
  num _couponDiscount = 0;

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

    // Cleanup both promo and coupon
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('applied_promo_code');
    await prefs.remove('applied_promo_discount');
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

  String formatAmount(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString(); // 3558.0 → 3558
    }
    return value.toString(); // 3558.6 → 3558.6
  }

  num _computeCartTotalInRupees() {
    final num total = _asNum(controller.cartDetails["total"]);

    // ✅ Use both promo and coupon discounts from local state
    final num totalDiscount = _promoDiscount + _couponDiscount;

    final num deliveryCharges =
        _asNum(controller.cartDetails["shipping_cost"]) +
            _asNum(controller.cartDetails["express_delivery_charges"]);

    // 🧮 Final payable = selling total - (promo + coupon) + delivery
    final num finalPayable = (total - totalDiscount) + deliveryCharges;
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

// ================= UPDATED _handleCheckout in CartScreen =================

  Future<void> _handleCheckout() async {
    try {
      print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🛒 CART CHECKOUT - START");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      // ✅ Step 1: Validate address
      print("\n📍 STEP 1: Validating Address");
      final address =
          controller.cartDetails["address"] ?? _pendingSelectedAddress;
      print("   Cart address: ${controller.cartDetails["address"]}");
      print("   Pending address: $_pendingSelectedAddress");
      print("   Selected address: $address");

      if (address == null) {
        print("   ❌ No address selected");
        _handleAddressSelection();
        showAppSnackBar("Please select a shipping address to continue",
            type: SnackBarType.error);
        return;
      }

      final shippingAddressId = address["id"];
      print("   ✅ Address ID: $shippingAddressId");

      if (shippingAddressId == null) {
        print("   ❌ Invalid address ID");
        showAppSnackBar(
            "Invalid address selected. Please choose another address.",
            type: SnackBarType.error);
        return;
      }

      // ✅ Step 2: Validate user ID
      print("\n👤 STEP 2: Validating User ID");
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId') ?? prefs.getInt('user_id');
      print("   userId from prefs: $userId");

      if (userId == null) {
        print("   ❌ No user ID found");
        showAppSnackBar("Please login to continue", type: SnackBarType.error);
        Get.offAllNamed('/login');
        return;
      }
      print("   ✅ User authenticated: userId=$userId");

      // ✅ Step 3: Validate cart total
      print("\n💰 STEP 3: Validating Cart Total");
      final totalAmount = _computeCartTotalInRupees();
      print("   Cart total: ₹$totalAmount");

      if (totalAmount <= 0) {
        print("   ❌ Invalid cart total");
        showAppSnackBar("Cart total must be greater than zero",
            type: SnackBarType.error);
        return;
      }
      print("   ✅ Cart total valid");

      // Meta: InitiateCheckout
      MetaEventService.instance.logInitiateCheckout(totalPrice: totalAmount.toDouble());


      // ✅ Step 4: Build items array with GST calculations
      print("\n📦 STEP 4: Building Items Array");
      print("   Number of items in cart: ${controller.orderList.length}");
      final List<Map<String, dynamic>> items = [];
      num totalGst = 0;

      // ✅ Calculate total discount (promo + coupon)
      final num totalDiscount = _promoDiscount + _couponDiscount;
      print("   Promo Discount: ₹$_promoDiscount");
      print("   Coupon Discount: ₹$_couponDiscount");
      print("   Total Discount: ₹$totalDiscount");

      for (int i = 0; i < controller.orderList.length; i++) {
        final item = controller.orderList[i];
        print("\n   🔸 Item ${i + 1}:");
        final product = Map<String, dynamic>.from(item["product"] ?? {});
        final inventory = Map<String, dynamic>.from(item["inventory"] ?? {});

        final num unitPrice = _asNum(product["price"]); // Price WITH GST
        final int quantity = item["quantity"] ?? 1;
        const num discount = 0;

        final int productId = product["id"];
        final int variantId = inventory["id"];

        print("      Product ID: $productId");
        print("      Variant ID: $variantId");
        print("      Unit Price: ₹$unitPrice (includes GST)");
        print("      Quantity: $quantity");

        // ========================================
        // 🔍 EXTRACT GST DATA (with fallback to product API)
        // ========================================
        String hsnCode = "";
        num gstRate = 0;
        num statutoryGSTRate = 0;
        String gstRuleApplied = "";
        num basePrice = 0; // Price WITHOUT GST

        // Try to get from cart data (check both formats)
        hsnCode = (product["hsn_code"] ??
                product["hsnCode"] ??
                inventory["hsn_code"] ??
                inventory["hsnCode"] ??
                "")
            .toString();

        gstRate = _asNum(product["gst_rate"] ??
            product["gstRate"] ??
            inventory["gst_rate"] ??
            inventory["gstRate"]);

        statutoryGSTRate = _asNum(product["statutory_gst_rate"] ??
            product["statutoryGSTRate"] ??
            inventory["statutory_gst_rate"] ??
            inventory["statutoryGSTRate"] ??
            gstRate);

        gstRuleApplied = (product["gst_rule"] ??
                product["gstRule"] ??
                inventory["gst_rule"] ??
                inventory["gstRule"] ??
                "")
            .toString();

        basePrice = _asNum(product["base_price"] ??
            product["basePrice"] ??
            inventory["base_price"] ??
            inventory["basePrice"]);

        // ⚠️ If critical GST data is missing, fetch from ProductController memory or API
        if (hsnCode.isEmpty || gstRate == 0) {
          print(
              "      ⚠️ Missing GST data in cart, checking ProductController memory...");

          // 🔥 MEMORY-FIRST APPROACH (like Buy Now)
          // Check if product is already loaded in ProductController
          if (productController.productDetails.isNotEmpty &&
              productController.productDetails['id'] == productId) {
            print("      ✅ Found product in memory, extracting GST data...");

            final cachedProduct = productController.productDetails;
            final variants = cachedProduct["variants"];

            if (variants is List && variants.isNotEmpty) {
              // Find matching variant by ID
              final matchingVariant = variants.firstWhere(
                (v) => v["id"] == variantId,
                orElse: () => {},
              );

              if (matchingVariant.isNotEmpty) {
                hsnCode = (matchingVariant["hsnCode"] ??
                        matchingVariant["hsn_code"] ??
                        "")
                    .toString();

                gstRate = _asNum(
                    matchingVariant["gstRate"] ?? matchingVariant["gst_rate"]);

                statutoryGSTRate = _asNum(matchingVariant["statutoryGSTRate"] ??
                    matchingVariant["statutory_gst_rate"] ??
                    gstRate);

                gstRuleApplied = (matchingVariant["gstRule"] ??
                        matchingVariant["gst_rule"] ??
                        matchingVariant["gstRuleApplied"] ??
                        "")
                    .toString();

                basePrice = _asNum(matchingVariant["basePrice"] ??
                    matchingVariant["base_price"]);

                print("      ✅ Extracted GST from memory:");
                print("         HSN: $hsnCode");
                print("         GST Rate: $gstRate");
                print("         Statutory Rate: $statutoryGSTRate");
                print("         Base Price: $basePrice");
              }
            }
          }

          // 🔄 FALLBACK: If still missing, try fetching from API
          if (hsnCode.isEmpty || gstRate == 0) {
            print("      ⚠️ Not in memory, fetching from product API...");
            try {
              final productDetails =
                  await productController.fetchProductDetails(productId);

              if (productDetails != null) {
                // Handle both direct response and wrapped response
                final data = productDetails["data"] ?? productDetails;
                final variants = data["variants"];

                if (variants is List && variants.isNotEmpty) {
                  final matchingVariant = variants.firstWhere(
                    (v) => v["id"] == variantId,
                    orElse: () => {},
                  );

                  if (matchingVariant.isNotEmpty) {
                    hsnCode = (matchingVariant["hsnCode"] ??
                            matchingVariant["hsn_code"] ??
                            data["hsnCode"] ??
                            data["hsn_code"] ??
                            "")
                        .toString();

                    gstRate = _asNum(matchingVariant["gstRate"] ??
                        matchingVariant["gst_rate"]);

                    statutoryGSTRate = _asNum(
                        matchingVariant["statutoryGSTRate"] ??
                            matchingVariant["statutory_gst_rate"] ??
                            gstRate);

                    gstRuleApplied = (matchingVariant["gstRule"] ??
                            matchingVariant["gst_rule"] ??
                            matchingVariant["gstRuleApplied"] ??
                            "")
                        .toString();

                    basePrice = _asNum(matchingVariant["basePrice"] ??
                        matchingVariant["base_price"]);

                    print("      ✅ Fetched GST data from API");
                  } else {
                    print(
                        "      ⚠️ Variant $variantId not found in API response");
                  }
                } else {
                  print("      ⚠️ No variants in API response");
                }
              }
            } catch (e) {
              print("      ❌ Failed to fetch GST data from API: $e");
            }
          }
        }

        print("      HSN Code: $hsnCode");
        print("      GST Rate: $gstRate%");
        print("      Base Price: ₹$basePrice");
        print("      Statutory GST Rate: $statutoryGSTRate%");
        print("      GST Rule: $gstRuleApplied");

        // ========================================
        // 🧮 CALCULATE GST AMOUNT
        // ========================================
        // Important: unitPrice INCLUDES GST, so we need to extract GST portion
        num gstAmount = 0;

        if (basePrice > 0) {
          // If we have basePrice (without GST), calculate GST as difference
          gstAmount = (unitPrice - basePrice) * quantity;
          print("      GST Amount (from base price): ₹$gstAmount");
        } else if (gstRate > 0) {
          // Extract GST from price that includes GST
          // Formula: gstAmount = price * (gstRate / (100 + gstRate))
          gstAmount = (unitPrice * quantity) * (gstRate / (100 + gstRate));
          print("      GST Amount (extracted): ₹$gstAmount");
        } else {
          print("      ⚠️ No GST rate available, setting GST to 0");
        }

        totalGst += gstAmount;

        // ========================================
        // 🧮 ITEM TOTAL
        // ========================================
        // Item total = (unitPrice * quantity) - discount
        // Note: GST is already included in unitPrice, so DON'T add it again
        final num itemTotal = (unitPrice * quantity) - discount;

        print("      GST Amount: ₹${gstAmount.toStringAsFixed(2)}");
        print("      Item Total: ₹${itemTotal.toStringAsFixed(2)}");

        // ========================================
        // ✅ BUILD ORDER ITEM
        // ========================================
        items.add(orderController.buildOrderItem(
          productId: productId,
          variantId: variantId,
          quantity: quantity,
          unitPrice: unitPrice, // Price WITH GST
          discount: discount,
          total: itemTotal, // unitPrice * quantity - discount
          tax: 0, // Keep as 0 (GST is sent separately in gstAmount)
          gstAmount: gstAmount,
          hsnCode: hsnCode,
          gstRate: gstRate,
          statutoryGSTRate: statutoryGSTRate,
          gstRuleApplied:
              gstRuleApplied.isEmpty ? "VALUE_BASED" : gstRuleApplied,
        ));
      }

      print("\n   ✅ Built ${items.length} items for payment");
      print("   Total GST: ₹${totalGst.toStringAsFixed(2)}");

      // ✅ Step 5: Call initiate-payment API with named parameters
      print("\n💳 STEP 5: Initiating Payment");
      print("   Calling orderController.initiatePayment with:");
      print("   • userId: $userId");
      print("   • shippingAddressId: $shippingAddressId");
      print("   • items count: ${items.length}");
      print("   • totalMRP: ${_asNum(controller.cartDetails["total_mrp"])}");
      print("   • promoDiscount: $_promoDiscount");
      print("   • couponDiscount: $_couponDiscount");
      print("   • totalDiscount: $totalDiscount");
      print("   • tax: $totalGst");
      print("   • total: $totalAmount");
      print("   • paymentMethod: prepaid");

      final paymentInitData = await orderController.initiatePayment(
        userId: userId,
        shippingAddressId: shippingAddressId,
        items: items,
        totalMRP: _asNum(controller.cartDetails["total_mrp"]),
        couponDiscount: totalDiscount, // Total of promo + coupon
        tax: totalGst,
        total: totalAmount,
        paymentMethod: "prepaid",
      );

      if (paymentInitData == null) {
        print("   ❌ Payment initiation failed - null response");
        showAppSnackBar("Failed to initiate payment. Please try again.",
            type: SnackBarType.error);
        return;
      }

      print("   ✅ Payment initiation successful");
      print("   Response: $paymentInitData");

      final razorpayOrderId = paymentInitData["providerOrderId"];
      print("   Razorpay Order ID: $razorpayOrderId");

      if (razorpayOrderId == null || razorpayOrderId.isEmpty) {
        print("   ❌ Missing or empty Razorpay Order ID");
        showAppSnackBar("Unable to start payment (missing Razorpay Order ID).",
            type: SnackBarType.error);
        return;
      }

      // ✅ Step 6: Open Razorpay checkout
      print("\n🎯 STEP 6: Opening Razorpay Checkout");
      print("   Razorpay Order ID: $razorpayOrderId");
      print("   Amount: ₹$totalAmount");
      print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("✅ CART CHECKOUT - COMPLETE, Opening Razorpay...");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

      await _openRazorpayCheckout(orderId: razorpayOrderId);
    } catch (e) {
      print("🔥 Checkout error: $e");
      showAppSnackBar("Something went wrong. Please try again.",
          type: SnackBarType.error);
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

  Future<void> _openRazorpayCheckout({String? orderId}) async {
    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("💳 OPENING RAZORPAY CHECKOUT");
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

    // Validate order ID
    if (orderId == null || orderId.isEmpty) {
      print("❌ ERROR: Order ID is null or empty");
      showAppSnackBar(
          "Payment could not be started. Missing Razorpay Order ID.",
          type: SnackBarType.error);
      return;
    }
    print("✅ Order ID: $orderId");

    // Validate Razorpay key
    if (_razorpayKey.isEmpty) {
      print("❌ ERROR: Razorpay key is empty");
      showAppSnackBar("Payment configuration error. Please contact support.",
          type: SnackBarType.error);
      return;
    }
    print("✅ Razorpay Key: ${_razorpayKey.substring(0, 10)}...");

    // Calculate amount
    final num cartTotalInRupees = _computeCartTotalInRupees();
    final int amountInPaise = (cartTotalInRupees * 100).round();
    print("💰 Amount: ₹$cartTotalInRupees (${amountInPaise} paise)");

    if (amountInPaise <= 0) {
      print("❌ ERROR: Invalid amount (must be > 0)");
      showAppSnackBar("Invalid payment amount", type: SnackBarType.error);
      return;
    }

    // Get user details
    final prefs = await SharedPreferences.getInstance();
    final String userName = (prefs.getString('user_name') ?? '').trim();
    final String userEmail = (prefs.getString('email') ?? '').trim();
    final String rawPhone = (prefs.getString('phonenumber') ??
            prefs.getString('phone_number') ??
            '')
        .trim();

    final String phone = _sanitizeIndianPhone(rawPhone);

    print("\n👤 User Details:");
    print("   Name: ${userName.isEmpty ? 'Customer (default)' : userName}");
    print(
        "   Email: ${userEmail.isEmpty ? 'customer@example.com (default)' : userEmail}");
    print("   Raw Phone: $rawPhone");
    print("   Sanitized Phone: $phone");
    print(
        "   Final Contact: ${phone.length == 10 ? '+91$phone' : '+919999999999'}");

    // Build Razorpay options
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

    print("\n📦 Razorpay Options:");
    print("   ${options.toString()}");

    print("\n🚀 Attempting to open Razorpay...");
    try {
      // Meta: AddPaymentInfo
      MetaEventService.instance.logAddPaymentInfo();
      _razorpay.open(options);
      print("✅ Razorpay.open() called successfully");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    } catch (e) {
      print("❌ Razorpay.open() failed with error: $e");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
      showAppSnackBar('Unable to start payment: $e', type: SnackBarType.error);
    }
  }

  // ---------- Lifecycle ----------

  @override
  void initState() {
    super.initState();
    debugPrint("🔍🔍🔍 CartScreen initState() called");

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
    debugPrint("🔍 getPreferenceValue() called");
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString("phonenumber");

    // ✅ Restore saved promo code
    final savedPromoCode = prefs.getString('applied_promo_code');
    final savedPromoDiscount = prefs.getInt('applied_promo_discount');

    // ✅ Restore saved coupon
    final savedCouponCode = prefs.getString('applied_coupon_code');
    final savedCouponDiscount = prefs.getInt('applied_coupon_discount');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint("🔍 PostFrameCallback executing");
      if (!mounted) {
        debugPrint("⚠️ Widget not mounted, returning");
        return;
      }

      if (phone != null) {
        controller.userNumber.value = phone;
      }

      // ✅ Restore promo code state if exists
      if (savedPromoCode != null && savedPromoDiscount != null) {
        setState(() {
          _promoCode = savedPromoCode;
          _promoDiscount = savedPromoDiscount;
          _hasPromo = true;
          _promoCodeController.text = savedPromoCode;
        });
        debugPrint("✓ Restored promo: $_promoCode (₹$_promoDiscount)");
      }

      // ✅ Restore coupon state if exists
      if (savedCouponCode != null && savedCouponDiscount != null) {
        setState(() {
          _couponCode = savedCouponCode;
          _couponDiscount = savedCouponDiscount;
          _hasCoupon = true;
        });
        debugPrint("✓ Restored coupon: $_couponCode (₹$_couponDiscount)");
      }

      // 🛒 Check if user is guest or logged in
      debugPrint("🔍 Checking if user is guest...");
      final isGuest = await controller.isGuestUser();
      debugPrint("🔍 isGuest = $isGuest");

      if (isGuest) {
        // Guest user - load guest cart from local storage
        debugPrint("🎭 Guest user detected, loading guest cart");
        await controller.loadGuestCartForDisplay();
      } else {
        // Logged in user - load cart from server
        debugPrint("👤 Logged in user, loading server cart");
        if (widget.backgroundcolor == whiteColor) {
          controller.getCartData();
        } else {
          // controller.getExpressCartData();
        }
      }

      // ✅ Load cart banners for both guest and logged-in users
      debugPrint("🎯 Loading cart banners");
      await controller.getCartBanners();
    });
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    _razorpay.clear(); // remove listeners & cleanup
    super.dispose();
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.backgroundcolor != homeAppBarColor,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && widget.backgroundcolor == homeAppBarColor) {
          Get.offAll(() => const BottomNavScreen(index: 0));
        }
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
                                                  "Clash Display Semibold",
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
                                                          "Clash Display Regular",
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

                                    // Newsletter Section
                                    const NewsletterSection(
                                      title: "NEWS LETTERS",
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
                Map<String, dynamic>.from(item["product"] ?? const {});
            final inventory =
                Map<String, dynamic>.from(item["inventory"] ?? const {});
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
                          color: lightPurpleColor,
                          fontSize: 10,
                          maxLines: 1,
                          fontFamily: "Clash Display",
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
    // 🔥 Priority: show variant image if available
    final item = controller.orderList[index];
    final variant = item["product_variant"] ?? {};
    final String? colorImage = variant["imageSrc"];

    // Decide which image to show
    final String finalImage = (colorImage != null && colorImage.isNotEmpty)
        ? colorImage
        : (imgUrl ?? "");

    return GestureDetector(
      onTap: () => _navigateToProductDetails(index),
      child: Opacity(
        opacity: outOfStock ? 0.5 : 1,
        child: SizedBox(
          height: 130.sp,
          width: 100.sp,
          child: CachedNetworkImage(
            cacheManager: CacheManager(
              Config(
                "customCacheKey",
                stalePeriod: const Duration(days: 15),
                maxNrOfCacheObjects: 100,
              ),
            ),
            fit: BoxFit.fill,
            imageUrl: finalImage,
            errorWidget: (_, __, ___) => Image.asset(
              downloadImage,
              height: 130.sp,
              width: 100.sp,
              fit: BoxFit.fill,
            ),
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
                fontFamily: "Clash Display",
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
                  fontFamily: "Clash Display Regular",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Opacity(
            opacity: outOfStock ? 0.5 : 1,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.sp),
              child: Wrap(
                spacing: 8.sp,
                runSpacing: 8.sp, // prevents overflow
                children: [
                  Builder(
                    builder: (_) {
                      final variant = item["product_variant"] ?? {};
                      final selectedOptions = variant["selectedOptions"] ?? [];

                      String sizeName = "";
                      String colorName = "";

                      if (selectedOptions is List) {
                        for (final o in selectedOptions) {
                          final name =
                              o["name"]?.toString().toLowerCase() ?? "";
                          final value = o["value"]?.toString() ?? "";
                          if (name == "size") sizeName = value;
                          if (name == "color") colorName = value;
                        }
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // -----------------------------
                          // SIZE BOX
                          // -----------------------------
                          if (sizeName.isNotEmpty)
                            Container(
                              height: 30.sp,
                              padding: EdgeInsets.symmetric(horizontal: 10.sp),
                              alignment: Alignment.center,
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
                              child: AppText(
                                text: "Size : $sizeName",
                                color: titleColor,
                                fontSize: 10,
                                fontFamily: "Clash Display Regular",
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  // Builder(
                  //   builder: (_) {
                  //     final variant = item["product_variant"] ?? {};
                  //     final selectedOptions = variant["selectedOptions"] ?? [];

                  //     String colorName = "";

                  //     if (selectedOptions is List) {
                  //       for (final o in selectedOptions) {
                  //         final name =
                  //             o["name"]?.toString().toLowerCase() ?? "";
                  //         if (name == "color") colorName = o["value"] ?? "";
                  //       }
                  //     }

                  //     return Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         if (colorName.isNotEmpty)
                  //           Container(
                  //             height: 30.sp,
                  //             padding: EdgeInsets.symmetric(horizontal: 10.sp),
                  //             alignment: Alignment.center,
                  //             decoration: BoxDecoration(
                  //               color: widget.backgroundcolor == whiteColor
                  //                   ? const Color(0xffF3F4F6)
                  //                   : const Color(0xFFDFDBFF),
                  //               border: Border.all(
                  //                 width: 1,
                  //                 color: widget.backgroundcolor == whiteColor
                  //                     ? const Color(0xFFE5E7EB)
                  //                     : titleColor,
                  //               ),
                  //             ),
                  //             child: AppText(
                  //               text: "Color : $colorName",
                  //               color: titleColor,
                  //               fontSize: 10,
                  //               fontFamily: "Clash Display Regular",
                  //             ),
                  //           ),
                  //       ],
                  //     );
                  //   },
                  // ),

                  // -----------------------------
                  // QTY BOX - NOW TAPPABLE
                  // -----------------------------
                  GestureDetector(
                    onTap: () => _showQuantityModal(item, index),
                    child: Container(
                      height: 30.sp,
                      padding: EdgeInsets.symmetric(horizontal: 10.sp),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            text: "Qty : ${item["quantity"] ?? "0"}",
                            color: titleColor,
                            fontSize: 10,
                            fontFamily: "Clash Display Regular",
                          ),
                          SizedBox(width: 6.sp),
                          SvgPicture.asset(
                            dropdownSvgImage,
                            colorFilter: const ColorFilter.mode(
                                titleColor, BlendMode.srcIn),
                            height: 5.sp,
                            width: 8.sp,
                          ),
                        ],
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
                        color: lightPurpleColor,
                        fontSize: 12,
                        maxLines: 3,
                        fontFamily: "Clash Display Regular",
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
                  // MRP (Strikethrough)
                  Visibility(
                    visible: product["mrp"] != null &&
                        product["price"] != null &&
                        _asNum(product["mrp"]) > _asNum(product["price"]),
                    child: Padding(
                      padding: EdgeInsets.only(right: 10.sp),
                      child: Text(
                        "₹${product["mrp"]}", // ✅ exact API value
                        style: TextStyle(
                          color: widget.backgroundcolor == whiteColor
                              ? lightText
                              : searchTextColor,
                          fontSize: 12.sp,
                          decoration: TextDecoration.lineThrough,
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Selling Price
                  Padding(
                    padding: EdgeInsets.only(right: 6.sp),
                    child: Text(
                      "₹${product["price"]}", // ✅ exact API value
                      style: TextStyle(
                        color: widget.backgroundcolor == whiteColor
                            ? nameText
                            : whiteColor,
                        fontSize: 12.sp,
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Discount Chip
                  if (product["mrp"] != null &&
                      product["price"] != null &&
                      _asNum(product["mrp"]) > _asNum(product["price"]))
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 181, 172, 248),
                        borderRadius: BorderRadius.circular(20.sp),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.sp, vertical: 4.sp),
                        child: Text(
                          "${_calculateDiscountPercentage(product)}% OFF",
                          // ✅ exact % (no rounding unless you want)
                          style: const TextStyle(
                            color: homeAppBarColor,
                            fontSize: 12,
                            fontFamily: "Clash Display",
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
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _buildOutOfStockActions(Map item, int index) {
    final product = Map<String, dynamic>.from(item["product"] ?? {});
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
    final deliveryCharges = _asNum(controller.cartDetails["shipping_cost"]) +
        _asNum(controller.cartDetails["express_delivery_charges"]);

    // Discount on MRP = MRP - selling price
    final discountOnMrp = totalMrp - sellingTotal;

    // ✅ Final Total = selling - (promo + coupon) + delivery
    final totalDiscount = _promoDiscount + _couponDiscount;
    final finalTotal = (sellingTotal - totalDiscount) + deliveryCharges;

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
                fontFamily: "Clash Display",
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

            // Total MRP
            _buildPriceRow(
              "Total MRP",
              "₹${formatAmount(totalMrp)}",
              false,
            ),

            // Discount on MRP
            if (discountOnMrp > 0)
              _buildPriceRow(
                "Discount on MRP",
                "- ₹${formatAmount(discountOnMrp)}",
                false,
              ),

            if (discountOnMrp > 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.sp),
                child: Container(
                  width: double.infinity,
                  color: colorSecondary,
                  height: 0.5.sp,
                ),
              ),

            // Subtotal (Selling Price)
            Padding(
              padding: EdgeInsets.only(top: 12.sp),
              child: Row(
                children: [
                  AppText(
                    text: "Subtotal",
                    fontFamily: "Clash Display Regular",
                    fontWeight: FontWeight.w400,
                    color: widget.backgroundcolor == whiteColor
                        ? subtitleColor
                        : productSubtitleColor,
                    fontSize: 12,
                  ),
                  const Spacer(),
                  AppText(
                    text: "₹${formatAmount(sellingTotal)}",
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w500,
                    color: widget.backgroundcolor == whiteColor
                        ? homeAppBarColor
                        : whiteColor,
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
                    AppText(
                      text: "Promo Code Discount",
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w400,
                      color: widget.backgroundcolor == whiteColor
                          ? subtitleColor
                          : productSubtitleColor,
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
                    AppText(
                      text: "Coupon Discount",
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w400,
                      color: widget.backgroundcolor == whiteColor
                          ? subtitleColor
                          : productSubtitleColor,
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

            // Delivery Charges
            Padding(
              padding: EdgeInsets.only(top: 12.sp),
              child: Row(
                children: [
                  AppText(
                    text: "Delivery Charges",
                    fontFamily: "Clash Display Regular",
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
                        : "+ ₹${formatAmount(deliveryCharges)}",
                    fontFamily: "Clash Display Regular",
                    fontWeight: FontWeight.w400,
                    color: deliveryCharges == 0
                        ? lightPurpleColor
                        : (widget.backgroundcolor == whiteColor
                            ? homeAppBarColor
                            : whiteColor),
                    fontSize: 12,
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp),
              child: Container(
                width: double.infinity,
                color: colorSecondary,
                height: 1.5.sp,
              ),
            ),

            // FINAL TOTAL
            Row(
              children: [
                AppText(
                  text: "TOTAL AMOUNT",
                  fontFamily: "Clash Display",
                  fontWeight: FontWeight.w500,
                  color: widget.backgroundcolor == whiteColor
                      ? colorPrimary
                      : whiteColor,
                  fontSize: 15,
                ),
                const Spacer(),
                AppText(
                  text: "₹${formatAmount(finalTotal)}",
                  fontFamily: "Clash Display",
                  fontWeight: FontWeight.w500,
                  color: widget.backgroundcolor == whiteColor
                      ? colorPrimary
                      : whiteColor,
                  fontSize: 15,
                ),
              ],
            ),

            // ✅ Cart Banners Section
            _buildCartBannersSection(),

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
      padding: EdgeInsets.symmetric(vertical: 16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Section 1: Manual Promo Code Entry
          AppText(
            text: "HAVE A PROMO CODE?",
            fontFamily: "Clash Display",
            fontWeight: FontWeight.w500,
            color: widget.backgroundcolor == whiteColor
                ? homeAppBarColor
                : whiteColor,
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
                        color: widget.backgroundcolor == whiteColor
                            ? subtitleColor
                            : productSubtitleColor,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8.sp),
                    ),
                    style: TextStyle(
                      fontFamily: "Clash Display Regular",
                      fontSize: 14.sp,
                      color: widget.backgroundcolor == whiteColor
                          ? titleColor
                          : whiteColor,
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
                      backgroundColor: _hasPromo
                          ? Colors.transparent
                          : (widget.backgroundcolor == whiteColor
                              ? homeAppBarColor
                              : Colors.transparent),
                      side: BorderSide(
                        color: _hasPromo
                            ? lightPurpleColor
                            : (widget.backgroundcolor == whiteColor
                                ? btnTextColor
                                : whiteColor),
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

          // ✅ Divider
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.sp),
            child: Row(
              children: [
                Expanded(
                    child: Divider(color: colorSecondary, thickness: 1.sp)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: AppText(
                    text: "OR",
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w500,
                    color: widget.backgroundcolor == whiteColor
                        ? subtitleColor
                        : productSubtitleColor,
                    fontSize: 12,
                  ),
                ),
                Expanded(
                    child: Divider(color: colorSecondary, thickness: 1.sp)),
              ],
            ),
          ),

          // ✅ Section 2: Select from Available Coupons
          AppText(
            text: "SELECT FROM AVAILABLE COUPONS",
            fontFamily: "Clash Display",
            fontWeight: FontWeight.w500,
            color: widget.backgroundcolor == whiteColor
                ? homeAppBarColor
                : whiteColor,
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
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.backgroundcolor == whiteColor
                    ? whiteColor
                    : Colors.grey[850],
                border: Border.all(
                  color: widget.backgroundcolor == whiteColor
                      ? homeAppBarColor
                      : whiteColor,
                  width: 1.sp,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.sp),
              child: Row(
                children: [
                  SvgPicture.asset(
                    couponSvgImage,
                    colorFilter: ColorFilter.mode(
                      widget.backgroundcolor == whiteColor
                          ? homeAppBarColor
                          : whiteColor,
                      BlendMode.srcIn,
                    ),
                    height: 20.sp,
                    width: 20.sp,
                  ),
                  SizedBox(width: 10.sp),
                  Expanded(
                    child: AppText(
                      text: "View all available coupons",
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w500,
                      color: widget.backgroundcolor == whiteColor
                          ? titleColor
                          : whiteColor,
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14.sp,
                    color: widget.backgroundcolor == whiteColor
                        ? titleColor
                        : whiteColor,
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

  Future<void> _applyPromoCode(String code) async {
    try {
      print("\n🎟️ ═══════════════════════════════════════════════════");
      print("🎟️ APPLYING PROMO CODE - CartScreen");
      print("🎟️ ═══════════════════════════════════════════════════");
      print("   Code: $code");

      // ✅ Calculate cart total (selling price before discount)
      final num cartTotal = _asNum(controller.cartDetails["total"]);
      print("   Cart Total (Selling Price): ₹$cartTotal");

      // ✅ Call API to validate promo code
      final promoData = await productController.validatePromoCode(
        code: code,
        cartTotal: cartTotal,
      );

      if (promoData == null) {
        print("   ❌ Promo validation failed");
        print("🎟️ ═══════════════════════════════════════════════════\n");
        // Error message already shown by validatePromoCode
        return;
      }

      // ✅ Extract data from API response
      final String promoType = promoData['promoType'] ?? '';
      final num discountValue = _asNum(promoData['discountValue']);
      final num maxDiscountCap = _asNum(promoData['maxDiscountCap']);
      final num minCartValue = _asNum(promoData['minCartValue']);
      final bool freeShipping = promoData['freeShipping'] ?? false;

      print("   ✅ Promo Data Received:");
      print("      Promo Type: $promoType");
      print("      Discount Value: $discountValue");
      print("      Max Discount Cap: $maxDiscountCap");
      print("      Min Cart Value: $minCartValue");
      print("      Free Shipping: $freeShipping");

      // ✅ Calculate final discount
      num finalDiscount = 0;

      if (promoType == 'percentage_discount') {
        // Percentage discount
        finalDiscount = (cartTotal * discountValue / 100);
        print("   📊 Calculating percentage discount:");
        print("      Formula: cartTotal × discountValue / 100");
        print("      Calculation: $cartTotal × $discountValue / 100");
        print("      Discount: ₹$finalDiscount");
      } else if (promoType == 'flat_discount') {
        // Flat discount
        finalDiscount = discountValue;
        print("   📊 Applying flat discount:");
        print("      Discount: ₹$finalDiscount");
      } else {
        print("   ⚠️ Unknown promo type: $promoType");
        showAppSnackBar("Invalid promo type", type: SnackBarType.error);
        print("🎟️ ══════════════��════════════════════════════════════\n");
        return;
      }

      // ✅ Apply max discount cap
      if (maxDiscountCap > 0 && finalDiscount > maxDiscountCap) {
        print("   🛑 Discount capped:");
        print("      Original Discount: ₹$finalDiscount");
        print("      Max Cap: ₹$maxDiscountCap");
        finalDiscount = maxDiscountCap;
        print("      Final Discount: ₹$finalDiscount");
      }

      // ✅ Round to nearest rupee
      finalDiscount = finalDiscount.round();
      print("   💰 Final Discount (rounded): ₹$finalDiscount");

      // ✅ Update local state
      setState(() {
        _promoCode = code.toUpperCase();
        _promoDiscount = finalDiscount;
        _hasPromo = true;
      });

      // ✅ Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('applied_promo_code', code.toUpperCase());
      await prefs.setInt('applied_promo_discount', finalDiscount.toInt());

      print("   ✅ Promo code applied successfully!");
      print("   💾 Saved to SharedPreferences");
      print("🎟️ ═══════════════════════════════════════════════════\n");

      // ✅ Show success message
      showAppSnackBar(
        "Promo '$code' applied! You saved ₹$finalDiscount",
        type: SnackBarType.success,
      );
    } catch (e, stackTrace) {
      print("   ❌ Error applying promo: $e");
      print("   Stack trace: $stackTrace");
      print("🎟️ ═══════════════════════════════════════════════════\n");
      showAppSnackBar(
        "Failed to apply promo code. Please try again.",
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _applyCoupon(String code) async {
    try {
      print("\n🎁 ═══════════════════════════════════════════════════");
      print("🎁 APPLYING COUPON (LOCAL) - CartScreen");
      print("🎁 ═══════════════════════════════════════════════════");
      print("   Code: $code");

      // ✅ Find coupon from already loaded couponList
      final couponData = productController.couponList.firstWhere(
        (c) =>
            (c['code']?.toString().toUpperCase() ?? '') == code.toUpperCase(),
        orElse: () => {},
      );

      if (couponData.isEmpty) {
        print("   ❌ Coupon not found in local list");
        print("🎁 ═══════════════════════════════════════════════════\n");
        showAppSnackBar("Coupon not found", type: SnackBarType.error);
        return;
      }

      // ✅ Calculate cart total
      final num cartTotal = _asNum(controller.cartDetails["total"]);
      print("   Cart Total: ₹$cartTotal");

      // ✅ Validate minimum cart value
      final num minCartValue = _asNum(couponData['minCartValue']);
      if (minCartValue > 0 && cartTotal < minCartValue) {
        print("   ❌ Min cart value not met: ₹$minCartValue");
        print("🎁 ═══════════════════════════════════════════════════\n");
        showAppSnackBar(
          "Minimum cart value ₹$minCartValue required for this coupon",
          type: SnackBarType.warning,
        );
        return;
      }

      // ✅ Parse discount type (e.g., "25% off" or "500")
      final String discountType = couponData['discountType']?.toString() ?? '';
      print("   Discount Type: $discountType");

      num finalDiscount = 0;

      if (discountType.contains('%')) {
        // Percentage discount - extract number from "25% off"
        final RegExp percentRegex = RegExp(r'(\d+(?:\.\d+)?)');
        final match = percentRegex.firstMatch(discountType);

        if (match != null) {
          final num percentage = num.parse(match.group(1)!);
          finalDiscount = (cartTotal * percentage / 100);
          print("   📊 Percentage discount: $percentage%");
          print(
              "      Calculation: $cartTotal × $percentage / 100 = ₹$finalDiscount");
        }
      } else {
        // Flat discount - extract number from "500"
        final RegExp flatRegex = RegExp(r'(\d+(?:\.\d+)?)');
        final match = flatRegex.firstMatch(discountType);

        if (match != null) {
          finalDiscount = num.parse(match.group(1)!);
          print("   📊 Flat discount: ₹$finalDiscount");
        }
      }

      // ✅ Apply max discount cap if specified
      final num maxDiscountCap = _asNum(couponData['maxDiscountCap']);
      if (maxDiscountCap > 0 && finalDiscount > maxDiscountCap) {
        print("   🛑 Discount capped: ₹$finalDiscount → ₹$maxDiscountCap");
        finalDiscount = maxDiscountCap;
      }

      // ✅ Round to nearest rupee
      finalDiscount = finalDiscount.round();
      print("   💰 Final Discount: ₹$finalDiscount");

      // ✅ Update local state
      setState(() {
        _couponCode = code.toUpperCase();
        _couponDiscount = finalDiscount;
        _hasCoupon = true;
      });

      // ✅ Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('applied_coupon_code', code.toUpperCase());
      await prefs.setInt('applied_coupon_discount', finalDiscount.toInt());

      print("   ✅ Coupon applied successfully!");
      print("   💾 Saved to SharedPreferences");
      print("🎁 ═══════════════════════════════════════════════════\n");

      // ✅ Show success message with coupon name
      final String couponName = couponData['couponName']?.toString() ?? code;
      showAppSnackBar(
        "$couponName applied! You saved ₹$finalDiscount",
        type: SnackBarType.success,
      );
    } catch (e, stackTrace) {
      print("   ❌ Error applying coupon: $e");
      print("   Stack trace: $stackTrace");
      print("🎁 ═══════════════════════════════════════════════════\n");
      showAppSnackBar(
        "Failed to apply coupon. Please try again.",
        type: SnackBarType.error,
      );
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

    showAppSnackBar("Coupon removed", type: SnackBarType.success);

    // ✅ will instantly update all Obx UI
    controller.update();
  }

// ---------- Price Row (Lavender discount values) ----------

  Widget _buildPriceRow(String label, String value, bool hasIcon) {
    final bool isDiscountRow =
        label.toLowerCase().contains("discount") && !label.contains("Delivery");

    final Color valueColor = isDiscountRow
        ? const Color(0xFF988AFF)
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
                    fontFamily: "Clash Display Regular",
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
            fontFamily: "Clash Display Regular",
            fontWeight: FontWeight.w400,
            color: valueColor,
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  /// ✅ Cart Banners Section - Shows banners after order details
  Widget _buildCartBannersSection() {
    return Obx(() {
      // Show loading state
      if (controller.isLoadingCartBanners.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.sp),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          ),
        );
      }

      // If no banners, don't show anything
      if (controller.cartBannerList.isEmpty) {
        return const SizedBox.shrink();
      }

      // Show banners
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banners list
            ...controller.cartBannerList.map((banner) {
              final bannerMap = banner as Map<String, dynamic>;
              final String imageUrl =
                  bannerMap['mobileImage']?.toString().trim() ?? '';
              final int bannerId = bannerMap['id'] is int
                  ? bannerMap['id']
                  : int.tryParse(bannerMap['id']?.toString() ?? '') ?? 0;

              // Skip if no image
              if (imageUrl.isEmpty) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () async {
                  // Handle banner tap - you can navigate to products or category
                  debugPrint("🎯 Cart banner tapped: $bannerId");
                  // Add navigation logic here if needed
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.sp),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 180.sp,
                    width: double.infinity,
                    fit: BoxFit.fill,
                    cacheManager: CacheManager(
                      Config(
                        "cartBannersCache",
                        stalePeriod: const Duration(days: 7),
                        maxNrOfCacheObjects: 30,
                      ),
                    ),
                    placeholder: (context, url) => Container(
                      height: 180.sp,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180.sp,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey.withOpacity(0.5),
                        size: 40.sp,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyCart() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Center(
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
              fontFamily: "Clash Display Regular",
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
                    fontFamily: "Clash Display Regular",
                    fontWeight: FontWeight.w400,
                    color: lightPurpleColor,
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
                        fontFamily: "Clash Display",
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
                        fontFamily: "Clash Display",
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
                      fit: BoxFit.fill,
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
    // Get bottom safe area padding for devices with navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return FutureBuilder<bool>(
      future: controller.isGuestUser(),
      builder: (context, snapshot) {
        final isGuest = snapshot.data ?? false;

        return GestureDetector(
          onTap: isGuest ? _handleGuestSignUp : _handleCheckout,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(bottom: bottomPadding),
            color: widget.backgroundcolor == whiteColor
                ? homeAppBarColor
                : lightPurpleColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16.sp, bottom: 16.sp),
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
                                isGuest
                                    ? "SIGN UP TO PROCEED"
                                    : (controller.cartDetails["address"] ==
                                                null &&
                                            _pendingSelectedAddress == null
                                        ? "PROCEED TO CHECKOUT"
                                        : "PROCEED TO PAY"),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white,
                                  fontFamily: 'Clash Display',
                                ),
                              ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Handle guest user trying to checkout - redirect to signup
  Future<void> _handleGuestSignUp() async {
    final guestCartCount = await controller.getGuestCartCount();

    if (guestCartCount == 0) {
      showAppSnackBar("Your cart is empty", type: SnackBarType.info);
      return;
    }

    // Show a message explaining cart will be saved
    showAppSnackBar("Sign up to save your cart and checkout",
        type: SnackBarType.info);

    // Navigate to login/signup screen
    await analytics.logEvent(
      name: 'guest_cart_signup_clicked',
      parameters: <String, Object>{
        'guest_cart_items': guestCartCount,
      },
    );

    Get.to(() => const LoginScreen(initialTab: 0));
  }

  // Show quantity selection modal for cart items
  void _showQuantityModal(Map item, int index) async {
    final product = Map<String, dynamic>.from(item["product"] ?? const {});
    final inventory = Map<String, dynamic>.from(item["inventory"] ?? const {});
    final currentQuantity = item["quantity"] ?? 1;
    final productId = product["id"];
    final variantId = inventory["id"];

    // Get available stock from inventory
    int availableStock = _asNum(inventory["stocks"]).toInt();

    // Check if product is out of stock
    if (availableStock == 0) {
      showAppSnackBar("This item is out of stock", type: SnackBarType.error);
      return;
    }

    // Fetch fresh stock data from product API for accuracy
    try {
      debugPrint(
          "🔍 Fetching fresh stock for product $productId, variant $variantId");
      final productDetails =
          await productController.fetchProductDetails(productId);

      if (productDetails != null && productDetails["variants"] != null) {
        final variants = List<Map<String, dynamic>>.from(
            (productDetails["variants"] as List).whereType<Map>());

        // Find matching variant
        final matchingVariant = variants.firstWhere(
          (v) => v["id"] == variantId,
          orElse: () => {},
        );

        if (matchingVariant.isNotEmpty) {
          final inv = matchingVariant["inventory"];
          final freshStock =
              inv != null ? (inv["availableStock"] ?? inv["stocks"] ?? 0) : 0;

          if (freshStock > 0) {
            availableStock = freshStock;
            debugPrint("✅ Fresh stock for variant $variantId: $availableStock");
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ Failed to fetch fresh stock, using cart value: $e");
      // Continue with inventory["stocks"] value
    }

    if (!mounted) return;

    if (availableStock == 0) {
      showAppSnackBar("This item is out of stock", type: SnackBarType.error);
      return;
    }

    // Allow user to select up to available inventory
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
              selectedQty: "$currentQuantity",
              stock: maxQty,
              controller: controller,
              onPressed: (newQty) async {
                Navigator.pop(ctx);
                if (newQty != currentQuantity) {
                  // Validate quantity before updating
                  if (newQty > availableStock) {
                    showAppSnackBar(
                        "Only $availableStock units available in stock",
                        type: SnackBarType.error);
                    return;
                  }

                  // Update quantity by removing and re-adding with new quantity
                  await _updateCartItemQuantity(
                    productId: productId,
                    variantId: variantId,
                    newQuantity: newQty,
                  );
                }
              },
            ),
          ],
        );
      },
    );

    await analytics.logEvent(
      name: 'cart_quantity_modal_opened',
      parameters: <String, Object>{
        'product_id': productId,
        'current_quantity': currentQuantity,
      },
    );
  }

  // Update cart item quantity
  Future<void> _updateCartItemQuantity({
    required int productId,
    required int variantId,
    required int newQuantity,
  }) async {
    try {
      final isGuest = await controller.isGuestUser();

      if (isGuest) {
        // For guest users: directly update in local storage
        // Note: addToCartUniversal handles showLoading() internally for page="quantity"
        debugPrint("🎭 Guest user: Updating quantity in local cart");

        await controller.addToCartUniversal(
          quantity: newQuantity,
          page: "quantity",
          variantId: variantId,
          productId: productId,
          expressValue: 0,
          type: 1,
          backColor: widget.backgroundcolor,
          oldInventoryId: 0,
        );

        // Refresh guest cart display
        await controller.loadGuestCartForDisplay();
        showAppSnackBar("Quantity updated to $newQuantity",
            type: SnackBarType.success);
      } else {
        // For logged-in users: use the new update-cart-quantity API
        controller.showLoading();
        debugPrint("👤 Logged-in user: Updating quantity via API");

        final success = await controller.updateCartQuantity(
          productId: productId,
          variantId: variantId,
          quantity: newQuantity,
        );

        if (success) {
          debugPrint("✅ Quantity updated successfully");

          // Refresh cart data to show updated quantity
          await controller.getCartData();

          // Verify the quantity was actually updated
          final updatedItem = controller.orderList.firstWhere(
            (item) => item['product']['id'] == productId,
            orElse: () => {},
          );
          if (updatedItem.isNotEmpty) {
            debugPrint(
                "🔍 After refresh - Quantity in cart: ${updatedItem['quantity']}");
          }

          controller.hideLoading();
          showAppSnackBar("Quantity updated to $newQuantity",
              type: SnackBarType.success);
        } else {
          controller.hideLoading();
          showAppSnackBar("Failed to update quantity",
              type: SnackBarType.error);
        }
      }

      await analytics.logEvent(
        name: 'cart_quantity_updated',
        parameters: <String, Object>{
          'product_id': productId,
          'new_quantity': newQuantity,
        },
      );
    } catch (e) {
      // Only hide loading if we're in logged-in flow (guest flow doesn't call showLoading here)
      final isGuest = await controller.isGuestUser();
      if (!isGuest) {
        controller.hideLoading();
      }
      debugPrint("❌ Error updating quantity: $e");
      showAppSnackBar("Failed to update quantity. Please try again.",
          type: SnackBarType.error);
    }
  }

  Widget _buildStockError() {
    return Padding(
      padding: EdgeInsets.only(top: 20.sp, bottom: 30.sp, left: 16.sp),
      child: Text(
        controller.stockErrorText.value,
        style: TextStyle(
          fontSize: 13.sp,
          color: lightPurpleColor,
          fontFamily: 'Clash Display',
        ),
      ),
    );
  }

  // ---------- Helpers ----------

  String _calculateDiscountPercentage(Map product) {
    final mrp = _asNum(product["mrp"]);
    final price = _asNum(product["price"]);

    if (mrp <= 0 || price <= 0 || mrp <= price) return "0";

    final discount = ((mrp - price) / mrp) * 100;
    return discount.toStringAsFixed(2); // 🔹 keep exact (2 decimals)
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

  void _showRemoveDialog(Map item) async {
    final productId = (item["product"]["id"] is num)
        ? (item["product"]["id"] as num).toInt()
        : int.tryParse("${item["product"]["id"]}") ?? 0;

    // Extract variantId from inventory or product_variant
    final inventory = item["inventory"] ?? {};
    final variantId = (inventory["id"] is num)
        ? (inventory["id"] as num).toInt()
        : int.tryParse("${inventory["id"]}") ?? 0;

    showDialog(
      barrierColor: Colors.black26,
      context: context,
      builder: (context) {
        return showDoubleBtnDailog(
          click1: () => Get.back(),
          click2: () async {
            Get.back();
            await controller.deleteFromCartUniversal(
                widget.backgroundcolor, productId,
                variantId: variantId);
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
    final product = Map<String, dynamic>.from(item["product"] ?? {});
    final productId = (product["id"] is num)
        ? (product["id"] as num).toInt()
        : int.tryParse("${product["id"]}") ?? 0;

    // Extract variantId from inventory
    final inventory = item["inventory"] ?? {};
    final variantId = (inventory["id"] is num)
        ? (inventory["id"] as num).toInt()
        : int.tryParse("${inventory["id"]}") ?? 0;

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
            await controller.deleteFromCartUniversal(
                widget.backgroundcolor, productId,
                variantId: variantId);
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
