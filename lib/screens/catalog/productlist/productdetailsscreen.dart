// ignore_for_file: avoid_print, deprecated_member_use

import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/controllers/cart_controller.dart';
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/catalog/productlist/ProductImageScreen.dart';
import 'package:lafetch/screens/catalog/productlist/ReviewOrderScreen.dart';
import 'package:page_indicator_plus/page_indicator_plus.dart';
import 'package:share_plus/share_plus.dart';
// ✅ Razorpay import
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../common/widget/appbar/productdetails_appbar.dart';
import '../../../common/widget/bottom_sheets/bottomwishlist.dart';
import '../../../common/widget/button/oublebutton_iconnew.dart';
import '../../../common/widget/lists/dummy_container.dart';
import '../../../common/widget/lists/dummy_productImage.dart';
import '../../../common/widget/lists/dummy_productdetails.dart';
import '../../../common/widget/text/app_space_text.dart';
import '../../../controllers/brand_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constant/constants.dart';
import '../../../core/utils/analytics_helper.dart';
import '../../cartscreen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final String type;
  final String brandName;
  final int wishlistProductId;
  final int boardId;
  final String Slug;
  final Color backgroundcolor;
  final String expresshour;
  final int expressValue;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.backgroundcolor = whiteColor,
    this.brandName = "",
    required this.type,
    this.boardId = 0,
    this.Slug = "",
    this.expresshour = "0",
    this.expressValue = 0,
    this.wishlistProductId = 0,
  });

  @override
  State<ProductDetailsScreen> createState() => ProductDetailsScreenState();
}

class ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController controller = PageController();
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final brandController = Get.put(BrandController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool _didEnsureSize = false;

  int _curr = 0;
  int commentId = 0;
  int reviewHelpfulId = 0;
  Map<String, dynamic> selectedProductFabric = {};
  final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  var cartQuantityItems = 0;
  final GlobalKey widgetKey = GlobalKey();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  RegExp regExp = RegExp("");
  final PageController _pageController = PageController(initialPage: 0);
  final ScrollController _scrollController = ScrollController();

  // --- spacing scale (use instead of raw 12.sp/18.sp/etc.) ---
  final double gXS = 4.sp; // micro
  final double gS = 6.sp; // small
  final double gM = 8.sp; // medium
  final double gL = 12.sp; // large

  // ---------- helpers ----------
  final cartController =
      Get.put(CartController()); // ensures controller is available

  // ===================== BUY NOW + RAZORPAY STATE =====================
  // Your LIVE Razorpay key
  static const String _razorpayKey = "rzp_live_rhkxLWkaUrRAHO";

  // Razorpay instance
  Razorpay? _razorpay;

  // Set to true when user picked an address in SavedAddressScreen
  bool _addressSelected = false;

  // Optionally keep whatever the address screen returns (Map/true/etc.)
  dynamic _addressResult;

  bool _isImageUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }

  /// Images-only list from API items (strings)
  List<String> _imagesOnly() {
    return productController.imageList
        .map((e) => (e['name']?.toString() ?? '').trim())
        .where((u) => u.isNotEmpty && _isImageUrl(u))
        .toList();
  }

  int _imageCount() => _imagesOnly().length;

  void _ensureSelectedSize() {
    if (_selSize() != null) return;

    final variants = productController.sizeInventoryList;
    if (variants.isEmpty) return;

    Map<String, dynamic>? firstInStock;
    for (final v in variants) {
      final q = int.tryParse(v['stocks']?.toString() ?? '0') ?? 0;
      if (q > 0) {
        firstInStock = v;
        break;
      }
    }
    firstInStock ??= variants.first;

    _setSelectedSize(firstInStock!);
  }

  Map<String, dynamic>? _selSize() {
    final s = productController.selectedProductSize;

    if (s is RxMap) {
      final value = s.value;
      return value.isEmpty ? null : Map<String, dynamic>.from(value);
    }

    if (s is Rx) {
      final value = s.value;
      if (value is Map && value.isNotEmpty) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    }

    if (s is Map && s.isNotEmpty) {
      return Map<String, dynamic>.from(s);
    }

    return null;
  }

  int _colorIdOf(Map c) {
    final key = (c['id'] ?? c['color_code'] ?? c['name'] ?? '').toString();
    return key.hashCode;
  }

  void _setSelectedSize(Map<String, dynamic> v) {
    try {
      if (productController.selectedProductSize is RxMap) {
        (productController.selectedProductSize as RxMap).assignAll(v);
      } else if (productController.selectedProductSize is Rx) {
        (productController.selectedProductSize as dynamic).value = v;
      } else {
        productController.selectedProductSize = v;
      }
    } catch (e) {
      print("Error setting selected size: $e");
      productController.selectedProductSize = v;
    }

    final idRaw = v['id'];
    productController.sizeInventoryId.value =
        (idRaw is int) ? idRaw : int.tryParse(idRaw?.toString() ?? '0') ?? 0;

    final colors = (v['product_matrix_available_colors'] is List)
        ? List<Map<String, dynamic>>.from(
            (v['product_matrix_available_colors'] as List).whereType<Map>())
        : <Map<String, dynamic>>[];

    productController.colorInventoryList.assignAll(colors);

    if (colors.isNotEmpty) {
      final first = colors.first;
      try {
        (productController.selectedProductColor as dynamic).value = first;
      } catch (_) {
        productController.selectedProductColor = first;
      }
      productController.colorInventoryId.value = _colorIdOf(first);
    } else {
      productController.colorInventoryId.value = 0;
      try {
        (productController.selectedProductColor as dynamic).value = {};
      } catch (_) {
        productController.selectedProductColor = {};
      }
    }

    productController.productImageindex.value = 0;
    productController.colorInventoryId.refresh();

    setState(() {});
  }

  Map<String, dynamic> _pd() {
    final raw = productController.productDetails;
    if (raw is Map) return Map<String, dynamic>.from(raw as Map);
    try {
      final val = (raw as dynamic).value;
      if (val is Map) return Map<String, dynamic>.from(val as Map);
    } catch (_) {}
    return <String, dynamic>{};
  }

  /// price from selected variant, else productDetails['price'/'basePrice']
  num _displayPrice() {
    final sel = _selSize();
    if (sel != null && sel['price'] is num) return sel['price'] as num;

    final m = productController.productDetails;
    final v =
        m['price'] ?? m['msp'] ?? m['lfMsp'] ?? m['mrp'] ?? m['basePrice'];
    if (v is num) return v;
    return num.tryParse(v?.toString() ?? '') ?? 0;
  }

  /// MRP/compare at
  num _displayMrp() {
    final sel = _selSize();
    final cap = sel?['compareAtPrice'];
    if (cap is num && cap > 0) return cap;
    final mrp = productController.productDetails['mrp'];
    return (mrp is num && mrp > 0) ? mrp : 0;
  }

  String _discountPctStr() {
    final price = _displayPrice();
    final mrp = _displayMrp();
    if (mrp > price && mrp > 0) {
      final pct = ((mrp - price) / mrp) * 100.0;
      return "${pct.toStringAsFixed(0)}%";
    }
    return "0%";
  }

  int _totalStockCount() {
    return productController.sizeInventoryList.fold<int>(
      0,
      (sum, v) {
        final q = int.tryParse(v['stocks']?.toString() ?? '0') ?? 0;
        return sum + q;
      },
    );
  }

  String _brandText() {
    final m = _pd();
    final b1 = m['brand_name'];
    final b2 = (m['brand'] is Map ? m['brand']['name'] : null);
    final b3 = widget.brandName;
    return (b1 ?? b2 ?? b3 ?? "").toString();
  }

  String _titleText() {
    final m = _pd();
    return (m['name'] ?? m['title'] ?? "").toString();
  }

  // Product Logger Helper Method
  void _logBuyNowAction({
    String action = "BUY NOW",
    bool isCartFlow = false,
  }) {
    print("=== $action CLICKED ===");
    print("Action Type: ${isCartFlow ? 'From Cart Flow' : 'Direct Purchase'}");
    print("Product ID: ${widget.productId}");
    print("Product Name: ${_titleText()}");
    print("Brand Name: ${_brandText()}");
    final selectedSize = _selSize();
    if (selectedSize != null) {
      print("Selected Size: ${selectedSize}");
      print(
          "Selected Size Label: ${selectedSize['product_matrix_size_name'] ?? selectedSize['title'] ?? 'Unknown'}");
    } else {
      print("Selected Size: null (No size selected)");
    }
    print("Selected Color: ${productController.selectedProductColor}");
    print("Price: ₹${_displayPrice().toStringAsFixed(0)}");
    print("MRP: ₹${_displayMrp().toStringAsFixed(0)}");
    print("Discount: ${_discountPctStr()}");
    print("Size Inventory ID: ${productController.sizeInventoryId.value}");
    print("Color Inventory ID: ${productController.colorInventoryId.value}");
    print("Express Value: ${widget.expressValue}");
    print("Express Hour: ${widget.expresshour}");
    print("Background Color: ${widget.backgroundcolor}");
    print("Type: ${widget.type}");
    print("Slug: ${widget.Slug}");
    print("Board ID: ${widget.boardId}");
    print("Wishlist Product ID: ${widget.wishlistProductId}");
    print("Total Stock: ${_totalStockCount()}");
    print("Has Sizes: ${_hasSizes()}");
    print("Has Colors: ${_hasColors()}");
    print("Product Details Keys: ${_pd().keys.toList()}");
    print("Timestamp: ${DateTime.now()}");
    print("${"=" * (action.length + 20)}");
  }

  // ===================== RAZORPAY FLOW =====================

  Future<void> _onBuyNowPressed({required bool isCartFlow}) async {
    // ✅ Step 1: Validate size/color etc.
    if (!productController.checkDetailsValidation()) return;

    _logBuyNowAction(action: "BUY NOW", isCartFlow: isCartFlow);

    // ✅ Step 2: Extract selected size/variant info
    final _sel = _selSize(); // your selected variant map
    final sizeLabel =
        (_sel?['product_matrix_size_name'] ?? _sel?['title'] ?? '');

    // ✅ Step 3: Get variantId safely
    final int variantId = (_sel?['id'] ??
        _sel?['variantId'] ??
        productController.selectedProductSize?['id'] ??
        0) as int;

    if (variantId <= 0) {
      print("❌ Missing variantId in selected product: $_sel");
      return;
    }

    // ✅ Step 4: Choose image
    final firstImg = productController.imageList.isNotEmpty
        ? (productController.imageList.first['name']?.toString() ?? '')
        : '';

    // ✅ Step 5: Navigate to ReviewOrderScreen with variantId
    Get.to(() => ReviewOrderScreen(
          productId: widget.productId,
          variantId: variantId, // ✅ CRITICAL: pass variantId
          title: _titleText(),
          brandName: _brandText(),
          imageUrl: _imagesOnly().isNotEmpty ? _imagesOnly().first : firstImg,
          sizeLabel: sizeLabel,
          quantity: 1,
          price: _displayPrice().toDouble(),
          mrp: _displayMrp().toDouble(),
          initialAddress:
              _addressSelected ? _addressResult as Map<String, dynamic>? : null,
        ));
  }

  // Razorpay callbacks
  void _onPaymentSuccess(PaymentSuccessResponse r) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment successful')),
    );
    // TODO: verify with backend if you're using Orders API (recommended)
    // Get.off(() => OrderSuccessScreen(...));
  }

  void _onPaymentError(PaymentFailureResponse r) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${r.message ?? r.code}')),
    );
  }

  void _onExternalWallet(ExternalWalletResponse r) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet: ${r.walletName}')),
    );
  }

  // ===================== /RAZORPAY FLOW =====================

  // ---------- IMAGES UI ----------

  List<Widget> getListForPageView() {
    final imagesOnly = _imagesOnly();

    if (imagesOnly.isEmpty) {
      return [Image.asset(dummyWishlistImage, fit: BoxFit.cover)];
    }

    final List<Widget> list = [];
    for (var i = 0; i < imagesOnly.length; i++) {
      final url = imagesOnly[i];

      list.add(
        GestureDetector(
          onTap: () {
            final imagesOnly = _imagesOnly();
            final gallery =
                imagesOnly.map((u) => {'name': u, 'isVideo': false}).toList();
            final safeIndex = (i >= 0 && i < gallery.length) ? i : 0;
            Get.to(() => ProductImage_Screen(curr: safeIndex, list: gallery));
          },
          child: Hero(
            tag: url,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0,
              color: colorSecondary,
              child: CachedNetworkImage(
                cacheManager: CacheManager(
                  Config(
                    "customCacheKey",
                    stalePeriod: Duration(days: 15),
                    maxNrOfCacheObjects: 100,
                  ),
                ),
                fit: BoxFit.cover, // ✅ Changed to cover
                imageUrl: url,
                width: double.infinity,
                height: double.infinity,
                progressIndicatorBuilder: (context, url, _) => DummyContainer(
                  height: MediaQuery.of(context).size.height * 0.54,
                  width: MediaQuery.of(context).size.width,
                ),
                errorWidget: (context, url, error) =>
                    Image.asset(downloadImage, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      );
    }

    return list;
  }

  bool _hasSizes() {
    final list = productController.sizeInventoryList;
    if (list.isEmpty) return false;
    for (final e in list) {
      final n = int.tryParse((e['stocks'] ?? '0').toString()) ?? 0;
      if (n > 0) return true;
    }
    return false;
  }

  SizedBox getListForProductSize() {
    int _asInt(dynamic x) =>
        x is int ? x : int.tryParse(x?.toString() ?? '0') ?? 0;

    String _sizeLabel(Map m) {
      final a = m['product_matrix_size_name'];
      final b = m['title'];
      String c = '';
      final so = m['selectedOptions'];
      if (so is List) {
        for (final o in so.whereType<Map>()) {
          if ((o['name']?.toString().toLowerCase() ?? '') == 'size') {
            c = o['value']?.toString() ?? '';
            break;
          }
        }
      }
      return (a ?? b ?? c ?? '').toString();
    }

    final variants = productController.sizeInventoryList
        .where((v) => v['product_matrix_size_name'] != null)
        .toList()
      ..sort((a, b) {
        const sizeOrder = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];

        final aLabel =
            (a['product_matrix_size_name'] ?? '').toString().toUpperCase();
        final bLabel =
            (b['product_matrix_size_name'] ?? '').toString().toUpperCase();
        final aIndex = sizeOrder.indexOf(aLabel);
        final bIndex = sizeOrder.indexOf(bLabel);
        return (aIndex == -1 ? 99 : aIndex)
            .compareTo(bIndex == -1 ? 99 : bIndex);
      });

    if (variants.isEmpty) return const SizedBox.shrink();

    int selectedId = productController.sizeInventoryId.value;
    if (selectedId == 0) {
      try {
        final s = productController.selectedProductSize;
        if (s is Map) {
          selectedId = _asInt(s['id']);
        } else if (s is Rx && s.value is Map) {
          selectedId = _asInt((s.value as Map)['id']);
        }
      } catch (_) {}
    }

    if (selectedId == 0 && variants.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setSelectedSize(variants.first);
        setState(() {});
      });
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: gL, vertical: 6),
        child: Wrap(
          spacing: gM,
          runSpacing: gS,
          children: [
            for (final raw in variants)
              Builder(builder: (_) {
                final i = raw as Map;
                final id = _asInt(i['id']);
                final isSelected = (id == selectedId);
                final label = _sizeLabel(i).toUpperCase();
                final isFree = label == 'FREE SIZE';
                final stock = int.tryParse(i['stocks']?.toString() ?? '0') ?? 0;
                final isOutOfStock = stock <= 0;

                return Opacity(
                  opacity: isOutOfStock ? 0.4 : 1.0, // blur effect
                  child: IgnorePointer(
                    ignoring: isOutOfStock, // disable tap
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            _setSelectedSize(Map<String, dynamic>.from(i));
                            _curr = 0;
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: widget.backgroundcolor == whiteColor
                                    ? btnTextColor
                                    : searchTextColor,
                                width: 1.sp,
                              ),
                              color: isSelected
                                  ? (widget.backgroundcolor == whiteColor
                                      ? colorPrimary
                                      : lightPurpleColor)
                                  : (widget.backgroundcolor == whiteColor
                                      ? whiteColor
                                      : homeAppBarColor),
                            ),
                            child: SizedBox(
                              width: isFree ? 70.sp : 44.sp,
                              height: 42.sp,
                              child: Center(
                                child: AppSpacingText(
                                  text: label,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: isSelected
                                      ? whiteColor
                                      : (widget.backgroundcolor == whiteColor
                                          ? btnTextColor
                                          : searchTextColor),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (stock <= 1 && stock > 0)
                          Padding(
                            padding: EdgeInsets.only(top: 0),
                            child: AppSpacingText(
                              text: 'Only $stock left',
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: redColor,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  bool _hasColors() {
    final list = productController.colorInventoryList;
    if (list.isEmpty) return false;
    for (final e in list) {
      final n =
          int.tryParse((e is Map ? e['stocks'] : null)?.toString() ?? '0') ?? 0;
      if (n > 0) return true;
    }
    return false;
  }

  SizedBox getListForProductColor() {
    Color _parse(dynamic raw) {
      String s = (raw?.toString() ?? '').trim();
      if (s.isEmpty) return const Color(0xFF000000);
      if (s.startsWith('#')) s = s.substring(1);
      if (s.startsWith('0x') || s.startsWith('0X')) s = s.substring(2);
      if (s.length == 6) s = 'FF$s';
      final v = int.tryParse(s, radix: 16);
      return v == null ? const Color(0xFF000000) : Color(v);
    }

    final colors = productController.colorInventoryList;
    if (colors.isEmpty) return const SizedBox.shrink();

    final selectedId = productController.colorInventoryId.value;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: gL, vertical: 0),
        child: Wrap(
          spacing: gM,
          runSpacing: gS,
          children: [
            for (final c in colors)
              GestureDetector(
                onTap: () {
                  try {
                    (productController.selectedProductColor as dynamic).value =
                        c;
                  } catch (_) {
                    productController.selectedProductColor = c;
                  }
                  productController.colorInventoryId.value = (c is Map)
                      ? (c['id']?.hashCode ?? _parse(c['color_code']).value)
                      : 0;
                  setState(() {});
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 38.sp,
                          width: 38.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: searchTextColor, width: 1),
                            color: _parse((c as Map)['color_code']),
                          ),
                        ),
                        if ((c is Map
                                ? c['id']?.hashCode ??
                                    _parse(c['color_code']).value
                                : 0) ==
                            selectedId)
                          CircleAvatar(
                            radius: 10.sp,
                            backgroundColor: Colors.white.withOpacity(0.85),
                            child: Icon(Icons.check,
                                size: 14.sp, color: homeAppBarColor),
                          ),
                      ],
                    ),
                    SizedBox(height: gXS),
                    AppSpacingText(
                      text: '${(c as Map)['name']?.toString() ?? ''}'
                          .toUpperCase(),
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w500,
                      color: widget.backgroundcolor == whiteColor
                          ? blackColor
                          : whiteColor,
                      fontSize: 10,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: widget.backgroundcolor == whiteColor
            ? statusBarColor
            : homeAppBarColor,
        statusBarIconBrightness: widget.backgroundcolor == whiteColor
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: widget.backgroundcolor == whiteColor
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: widget.backgroundcolor == whiteColor
            ? statusBarColor
            : homeAppBarColor,
      ),
    );
  }

  @override
  void initState() {
    setStatusBarColor();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.errorMsg.value = "";
      productController.brandDetails = "";
      productController.defaultAddress = "";
      productController.pincodeController.clear();
      productController.sizeInventoryId.value = 0;
      productController.productImageindex.value = 0;
      productController.colorInventoryId.value = 0;
      productController.addToCart.value = false;
      productController.showSizeList.value = true;
      _didEnsureSize = false;

      try {
        (productController.selectedProductSize as dynamic).value = null;
      } catch (_) {
        productController.selectedProductSize = null;
      }
      try {
        (productController.selectedProductColor as dynamic).value = null;
      } catch (_) {
        productController.selectedProductColor = null;
      }

      productController.isExpressDelivery.value = false;
      productController.expressValue.value = widget.expressValue;
      productController.errorSizeMsg.value = "";
      productController.errorColorMsg.value = "";

      // Load product details
      productController.getProductById(widget.productId).then((_) {
        final productId =
            productController.productDetails["id"] as int? ?? widget.productId;

        // Check if wishlisted
        wishlistController.checkIfWishlisted(productId);

        // ✅ NEW: Load reviews for this product
        productController.getProductReviews(productId);
      });
    });

    // Load wishlist boards data
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());

    // Razorpay listeners
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    super.initState();
  }

  void _openSizeChartDialog() async {
    await productController.fetchSizeChart(
      brandId: productController.productDetails["brand"]?["id"] ?? 0,
      superCatId: productController.productDetails["superCatId"] ?? 0,
      catId: productController.productDetails["catId"] ?? 0,
      subCatId: productController.productDetails["subCatId"] ?? 0,
    );

    final chart = productController.sizeChart;
    final chartData = productController.sizeChartData;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(16.sp),
          backgroundColor: Colors.white, // ⭐ light purple color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Container(
            padding: EdgeInsets.all(16.sp),
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ---------- Title ----------
                  Text(
                    chart["title"]?.toString() ?? "Size Chart",
                    style: TextStyle(
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 14.sp),

                  /// ---------- Prefer Image ----------
                  if (chart["sizeGuideImage"] != null &&
                      chart["sizeGuideImage"].toString().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.sp),
                      child: CachedNetworkImage(
                        imageUrl: chart["sizeGuideImage"],
                        width: double.infinity,
                        height: 300.sp,
                        fit: BoxFit.contain,
                      ),
                    )
                  else
                    _buildSizeTable(chartData),

                  SizedBox(height: 18.sp),

                  /// Close Button
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // ⭐ Proper dark button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        minimumSize: Size(180.sp, 48.sp),
                      ),
                      child: Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    try {
      _razorpay?.clear();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AddToCartAnimation(
      cartKey: cartKey,
      height: 25.sp,
      width: 25.sp,
      opacity: 0.80,
      dragAnimation: const DragToCartAnimationOptions(rotation: true),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: widget.backgroundcolor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: widget.backgroundcolor == whiteColor,
              child: ProductdetailsAppbar(
                dark: false,
                onPressedHeart: () async {
                  final firstImg = productController.imageList.isNotEmpty
                      ? (productController.imageList.first['name']
                              ?.toString() ??
                          '')
                      : '';

                  final productId =
                      (productController.productDetails["id"] as int?) ??
                          widget.productId;

                  scaffoldKey.currentState
                      ?.showBottomSheet((context) => BottomWishlist(
                            controller: wishlistController,
                            wishlistList: wishlistController.wishlistList,
                            productImage: firstImg,
                            onPressedBoard: () {/* open create board screen */},
                            onPressed: (boardId) async {
                              await wishlistController.addProductToBoard(
                                  boardId, productId);

                              // Close bottom sheet
                              Get.back();

                              // AnalyticsHelper.logAddToWishlist(
                              //   productId: productId.toString(),
                              //   contentType: 'product',
                              //   value: _displayPrice().toDouble(),
                              // );
                            },
                          ));
                },
                onPressedShare: () async {
                  final t = _titleText();
                  Share.share(t.isNotEmpty ? t : "Check this product");
                  await analytics.logEvent(
                    name: 'share_product',
                    parameters: <String, Object>{'page_name': 'share_product'},
                  );
                },
              ),
            ),

            // Visibility(
            //   visible: widget.backgroundcolor == blackColor,
            //   child: Container(height: 1.sp, color: dividerColor),
            // ),

            // ================= BODY =================
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Stack(
                  children: [
                    Visibility(
                      visible: widget.backgroundcolor != whiteColor,
                      child: Positioned(
                        top: 0,
                        right: 0,
                        child: Image.asset(quickBackCircle,
                            height: 250.sp, width: 300.sp),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: widget.backgroundcolor != whiteColor,
                          child: Padding(
                            padding: EdgeInsets.only(left: 2.sp, top: 0.sp),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: SvgPicture.asset(
                                    arrowBack,
                                    color: whiteColor,
                                    height: 15.sp,
                                    width: 15.sp,
                                    fit: BoxFit.cover,
                                  ),
                                  onPressed: () => Get.back(),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width - 80.sp,
                                  child: AppSpacingText(
                                    text: widget.brandName.toUpperCase(),
                                    color: whiteColor,
                                    fontSize: 16,
                                    maxLines: 1,
                                    fontFamily: "Franklin Gothic Semibold",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ---------- IMAGES ----------
                        Obx(
                          () => productController.isDetails.value
                              ? const DummyProductImage()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image Container with Rating Badge - FULL WIDTH
                                    Stack(
                                      children: [
                                        // PageView for Images - NO PADDING
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.54,
                                          child: PageView(
                                            controller: _pageController,
                                            allowImplicitScrolling: true,
                                            scrollDirection: Axis.horizontal,
                                            onPageChanged: (number) {
                                              _curr = number;
                                              setState(() {});
                                            },
                                            children: getListForPageView(),
                                          ),
                                        ),
                                        // Rating Badge - Bottom Right (positioned over image)
                                        Positioned(
                                          bottom: 12.sp,
                                          right: 12.sp,
                                          child: Obx(() {
                                            final avgRating = productController
                                                .averageRating.value;

                                            if (avgRating <= 0)
                                              return const SizedBox
                                                  .shrink(); // hide if no rating

                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.sp,
                                                  vertical: 5.sp),
                                              decoration: BoxDecoration(
                                                color: whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        16.sp),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.15),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color:
                                                        const Color(0xFFFFA500),
                                                    size: 14.sp,
                                                  ),
                                                  SizedBox(width: 3.sp),
                                                  Text(
                                                    avgRating
                                                        .toStringAsFixed(1),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: blackColor,
                                                      fontSize: 13.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    // Page Indicator Dots
                                    _imageCount() <= 1
                                        ? const SizedBox.shrink()
                                        : Padding(
                                            padding: EdgeInsets.only(
                                              left: gL,
                                              right: gL,
                                              top: gS,
                                            ),
                                            child: Center(
                                              child: PageIndicator(
                                                controller: _pageController,
                                                count: _imageCount(),
                                                size: 5.0.sp,
                                                activeColor:
                                                    widget.backgroundcolor ==
                                                            whiteColor
                                                        ? Colors.black
                                                        : whiteColor,
                                                color: widget.backgroundcolor ==
                                                        whiteColor
                                                    ? const Color(0xffE5E7EB)
                                                    : subtitleColor,
                                                layout:
                                                    PageIndicatorLayout.WARM,
                                                scale: 0.6,
                                                space: gS,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                        ),
                        // ---------- DETAILS ----------
                        Obx(() {
                          final loading = productController.isDetails.value;

                          if (!loading && !_didEnsureSize) {
                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _ensureSelectedSize());
                            _didEnsureSize = true;
                          }

                          if (loading) return const DummyProductDetails();

                          final showSizes = _hasSizes();
                          final showColors = _hasColors();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 12.sp, right: 12.sp),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: AppSpacingText(
                                        text: _brandText().isNotEmpty
                                            ? "${_brandText()}\n".toUpperCase()
                                            : "",
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                        color:
                                            widget.backgroundcolor == whiteColor
                                                ? blackColor
                                                : whiteColor,
                                        maxLines: 1,
                                        fontSize: 16,
                                      ),
                                    ),
                                    (productController.brandDetails != null &&
                                            productController.brandDetails !=
                                                "")
                                        ? GestureDetector(
                                            onTap: () async {
                                              await analytics.logEvent(
                                                name:
                                                    'productdetails_explorebrand',
                                                parameters: <String, Object>{
                                                  'page_name':
                                                      'productdetails_explorebrand'
                                                },
                                              );
                                              brandController.brandbackground
                                                  .value = productController
                                                      .brandDetails[
                                                  "background_image"];
                                              Navigator.of(context)
                                                  .push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AllBrandScreen(
                                                        id: productController
                                                            .brandDetails["id"],
                                                        screen: "search",
                                                        slug: "",
                                                      ),
                                                    ),
                                                  )
                                                  .then((_) =>
                                                      setStatusBarColor());
                                            },
                                            child: Container(
                                              color: const Color(0xFFDFDBFF),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10.sp, right: 8.sp),
                                                child: Row(
                                                  children: [
                                                    AppSpacingText(
                                                      text: 'View Brand \n'
                                                          .toUpperCase(),
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: homeAppBarColor,
                                                      maxLines: 1,
                                                      fontSize: 10,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.sp),
                                                      child: ImageIcon(
                                                          AssetImage(
                                                              linkArrowImage),
                                                          size: 16.sp),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(height: 0),
                                  ],
                                ),
                              ),

                              Visibility(
                                visible: _titleText().isNotEmpty,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.sp),
                                  child: AppSpacingText(
                                    text: _titleText(),
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: widget.backgroundcolor == whiteColor
                                        ? subtitleColor
                                        : productSubtitleColor,
                                    maxLines: 2,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(
                                    top: 8.0.sp, left: 12.sp, right: 12.sp),
                                child: Row(
                                  children: [
                                    Builder(builder: (_) {
                                      final p = _displayPrice();
                                      final m = _displayMrp();
                                      return (m > p && m > 0)
                                          ? Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10.sp),
                                              child: Text(
                                                "₹ ${m.toStringAsFixed(0)}",
                                                style: TextStyle(
                                                  color: searchTextColor,
                                                  letterSpacing: 0.65,
                                                  fontSize: 16.sp,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink();
                                    }),
                                    Padding(
                                      padding: EdgeInsets.only(right: 10.0.sp),
                                      child: AppSpacingText(
                                        text:
                                            "₹ ${_displayPrice().toStringAsFixed(0)}",
                                        color:
                                            widget.backgroundcolor == whiteColor
                                                ? nameText
                                                : whiteColor,
                                        fontSize: 16,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Builder(builder: (_) {
                                      final disc = _discountPctStr();
                                      return (disc != "0%")
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xffA7F3D0),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 8.sp, right: 8.sp),
                                                child: AppSpacingText(
                                                  text: "$disc OFF",
                                                  color:
                                                      widget.backgroundcolor ==
                                                              whiteColor
                                                          ? expressText
                                                          : homeAppBarColor,
                                                  fontSize: 12,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink();
                                    }),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(
                                    top: 8.sp, left: 12.sp, right: 16.sp),
                                child: AppSpacingText(
                                  text: "Price inclusive of all taxes",
                                  color: widget.backgroundcolor == whiteColor
                                      ? subtitleColor
                                      : searchTextColor,
                                  fontSize: 12,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),

                              // ---------- SIZES ----------
                              _hasSizes()
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 16.0.sp,
                                              left: 12.sp,
                                              right: 12.sp),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              AppSpacingText(
                                                text:
                                                    'Select size'.toUpperCase(),
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w500,
                                                color: widget.backgroundcolor ==
                                                        whiteColor
                                                    ? blackColor
                                                    : productSubtitleColor,
                                                fontSize: 16,
                                              ),

                                              /// ⭐⭐⭐ View Size Chart Button
                                              GestureDetector(
                                                onTap: _openSizeChartDialog,
                                                child: Text(
                                                  "View Size Chart",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w600,
                                                    color: colorPrimary,
                                                    fontSize: 13.sp,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (productController
                                            .errorSizeMsg.value.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 8.0.sp, left: 12.sp),
                                            child: AppSpacingText(
                                              text: productController
                                                  .errorSizeMsg.value,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                              color: redColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        getListForProductSize(),
                                      ],
                                    )
                                  : const SizedBox(height: 0),

                              // ---------- COLORS ----------
                              (productController
                                          .colorInventoryList.isNotEmpty &&
                                      _hasColors())
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14.0, horizontal: 12),
                                          child: Divider(
                                              color: widget.backgroundcolor ==
                                                      whiteColor
                                                  ? colorSecondary
                                                  : titleColor),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 0.0.sp,
                                              left: 12.sp,
                                              right: 12.sp),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              AppSpacingText(
                                                text: 'Select Color'
                                                    .toUpperCase(),
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w500,
                                                color: widget.backgroundcolor ==
                                                        whiteColor
                                                    ? blackColor
                                                    : productSubtitleColor,
                                                fontSize: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (productController
                                            .errorColorMsg.value.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10.0.sp, left: 12.sp),
                                            child: AppSpacingText(
                                              text: productController
                                                  .errorColorMsg.value,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                              color: redColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        getListForProductColor(),
                                      ],
                                    )
                                  : const SizedBox(height: 0),
                            ],
                          );
                        }),

                        Visibility(
                          visible: widget.backgroundcolor == whiteColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Title
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 12.sp, top: 16.sp),
                                child: AppSpacingText(
                                  text: 'Delivery Options'.toUpperCase(),
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w600,
                                  color: appBarColor,
                                  fontSize: 12,
                                ),
                              ),

                              /// Pincode Field
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 12.sp, left: 12.sp, right: 12.sp),
                                child: SizedBox(
                                  height: 44.sp,
                                  child: TextField(
                                    controller:
                                        productController.pincodeController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      filled: true,
                                      fillColor: whiteColor,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.sp),
                                      hintText: "Enter pincode",
                                      hintStyle: TextStyle(
                                        fontSize: 14.sp,
                                        color: textHintColor,
                                        fontFamily: "Franklin Gothic",
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: borderColor),
                                        borderRadius:
                                            BorderRadius.circular(4.sp),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: borderColor),
                                        borderRadius:
                                            BorderRadius.circular(4.sp),
                                      ),
                                      suffixIcon: Obx(
                                        () => TextButton(
                                          onPressed: () async {
                                            final pin = productController
                                                .pincodeController.text
                                                .trim();

                                            if (productController
                                                .checkPinvalidation(pin)) {
                                              productController
                                                  .serviceabilityMessage
                                                  .value = "";
                                              productController
                                                  .isServiceable.value = false;
                                              productController
                                                  .courierName.value = "";
                                              productController
                                                  .estimatedDate.value = "";
                                              productController
                                                  .estimatedDays.value = "";

                                              final result =
                                                  await productController
                                                      .checkServiceability(
                                                variantId: productController
                                                    .sizeInventoryId.value,
                                                deliveryPostalCode: pin,
                                              );

                                              if (result != null) {
                                                final data = result["data"];
                                                if (data != null &&
                                                    data is Map) {
                                                  final date =
                                                      data["estimatedDate"]
                                                              ?.toString() ??
                                                          "";
                                                  final days =
                                                      data["estimatedDays"]
                                                              ?.toString() ??
                                                          "";
                                                  final courier =
                                                      data["courier"]
                                                              ?.toString() ??
                                                          "";

                                                  productController.courierName
                                                      .value = courier;
                                                  productController
                                                      .estimatedDate
                                                      .value = date;
                                                  productController
                                                      .estimatedDays
                                                      .value = days;
                                                  productController
                                                      .isServiceable
                                                      .value = true;

                                                  // ✅ Show proper delivery info
                                                  productController
                                                          .serviceabilityMessage
                                                          .value =
                                                      "Delivery by $date ($days Days)";
                                                } else {
                                                  productController
                                                      .isServiceable
                                                      .value = false;
                                                  productController
                                                          .serviceabilityMessage
                                                          .value =
                                                      "Service not available for this pincode";
                                                }
                                              }

                                              FocusScope.of(context).unfocus();
                                              await analytics.logEvent(
                                                name:
                                                    'check_pincode_productdetails',
                                                parameters: <String, Object>{
                                                  'page_name':
                                                      'check_pincode_productdetails'
                                                },
                                              );
                                            }
                                          },
                                          child: productController
                                                  .isEstimateDate.value
                                              ? const SizedBox(
                                                  height: 14,
                                                  width: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                )
                                              : Container(
                                                  color: blackColor,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12.sp,
                                                      vertical: 8.sp),
                                                  child: const AppSpacingText(
                                                    text: "CHECK",
                                                    textAlign: TextAlign.center,
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w600,
                                                    color: whiteColor,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: blackColor,
                                      fontSize: 16.sp,
                                      fontFamily: "Franklin Gothic",
                                    ),
                                  ),
                                ),
                              ),

                              Obx(() {
                                final msg = productController
                                    .serviceabilityMessage.value;
                                final isOk =
                                    productController.isServiceable.value;

                                if (msg.isEmpty) return const SizedBox.shrink();

                                return Padding(
                                  padding: EdgeInsets.only(
                                      left: 12.sp, right: 12.sp, top: 10.sp),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isOk
                                            ? Icons.check_circle_outline
                                            : Icons.error_outline,
                                        color: isOk ? Colors.green : Colors.red,
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 8.sp),
                                      Expanded(
                                        child: AppSpacingText(
                                          text: msg,
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w500,
                                          color: isOk
                                              ? Colors.green.shade700
                                              : Colors.red,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                            ],
                          ),
                        ),

                        // ------- collapsibles (description / composition / returns / brand) -------
                        Obx(
                          () => productController.isDetails.value
                              ? const SizedBox(height: 0)
                              : _collapsiblesSection(),
                        ),

                        Obx(
                          () => productController.isDetails.value
                              ? const SizedBox(height: 0)
                              : _ratingsAndReviewsSection(), // <-- Add this call
                        ),

                        Padding(
                          padding: EdgeInsets.all(8.0.sp),
                          child: Divider(
                              color: widget.backgroundcolor == whiteColor
                                  ? colorSecondary
                                  : titleColor),
                        ),

                        Obx(
                          () => productController.errorMsg.value.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      left: 16.sp,
                                      right: 16.sp,
                                      top: 16.sp,
                                      bottom: 16.sp),
                                  child: AppSpacingText(
                                    text: productController.errorMsg.value,
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: deepRed,
                                    maxLines: 5,
                                    fontSize: 12,
                                  ),
                                )
                              : const SizedBox(height: 0),
                        ),
                        SizedBox(height: 20.sp),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ================= BOTTOM BAR =================
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 2.sp),
              child: Obx(() {
                if (productController.isDetails.value) {
                  return const SizedBox(height: 0);
                }

                final totalStock = _totalStockCount();
                if (totalStock == 1) {
                  return SizedBox(
                    height: 50.sp,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8.0.sp),
                          child: SvgPicture.asset(
                            cartSvgImage,
                            color: widget.backgroundcolor == whiteColor
                                ? homeAppBarColor
                                : productSubtitleColor,
                            height: 18.sp,
                            width: 18.sp,
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          height: 18.sp,
                          child: AppSpacingText(
                            text: "Out of stock".toUpperCase(),
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w500,
                            color: widget.backgroundcolor == whiteColor
                                ? homeAppBarColor
                                : productSubtitleColor,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final isInCartFlow = productController.addToCart.value;

                return isInCartFlow
                    ? DoubleButtonIconNew(
                        lineColor: widget.backgroundcolor == whiteColor
                            ? dividerColor
                            : titleColor,
                        firstText: "Go to BAG".toUpperCase(),
                        secondText: "Buy Now".toUpperCase(),
                        onPressedFirst: () async {
                          final pid = (productController.productDetails["id"] ??
                                  widget.productId)
                              .toString();
                          final price = _displayPrice().toDouble();

                          Get.to(CartScreen(
                                  backgroundcolor: widget.backgroundcolor))
                              ?.then((_) {
                            productController.getProductById(widget.productId);
                          });

                          await analytics.logEvent(
                            name: 'productDetails_btnGotocart',
                            parameters: {
                              'page_name': 'productDetails_btnGotocart'
                            },
                          );

                          // AnalyticsHelper.logAddToCart(
                          //   productId: pid,
                          //   contentType: 'product',
                          //   value: price,
                          // );

                          productController.addToCart.value = false;

                          _scrollController.animateTo(
                            MediaQuery.of(context).size.height / 2.sp + 150.sp,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                          );
                        },
                        onPressedSecond: () async {
                          await _onBuyNowPressed(isCartFlow: true);
                          _scrollController.animateTo(
                            MediaQuery.of(context).size.height / 2.sp + 150.sp,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                          );
                        },
                        controller: productController,
                      )
                    : DoubleButtonIconNew(
                        lineColor: widget.backgroundcolor == whiteColor
                            ? dividerColor
                            : titleColor,
                        firstText: widget.type == "add"
                            ? "Add to bag".toUpperCase()
                            : "Move to bag".toUpperCase(),
                        secondText: "Buy Now".toUpperCase(),
                        onPressedFirst: () async {
                          if (widget.type == "add") {
                            if (productController.checkDetailsValidation()) {
                              await cartController.callAddtoCart(
                                1,
                                "addproduct",
                                productController.sizeInventoryId.value,
                                widget.productId,
                                (widget.expressValue ?? 0),
                                1,
                                widget.backgroundcolor,
                                productController.sizeInventoryId.value,
                              );
                              productController.addToCart.value = true;
                            }
                          } else {
                            if (productController.checkDetailsValidation()) {
                              wishlistController.callMovetoCart(
                                widget.boardId.toString(),
                                widget.wishlistProductId.toString(),
                                productController.sizeInventoryId.value
                                    .toString(),
                                1,
                              );
                              productController.addToCart.value = true;
                            }
                          }

                          _scrollController.animateTo(
                            MediaQuery.of(context).size.height / 2.sp + 150.sp,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                          );

                          await analytics.logEvent(
                            name: 'productDetails_btnaddtocart',
                            parameters: {
                              'page_name': 'productDetails_btnaddtocart'
                            },
                          );
                        },
                        onPressedSecond: () async {
                          await _onBuyNowPressed(isCartFlow: false);
                          _scrollController.animateTo(
                            MediaQuery.of(context).size.height / 2.sp + 150.sp,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                          );
                        },
                        controller: productController,
                      );
              }),
            )
          ],
        ),
      ),
    );
  }

  // ---------- tiny helpers to keep build() tidy ----------

  Widget _collapsiblesSection() {
    return Padding(
      padding: EdgeInsets.only(top: 20.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Builder(builder: (_) {
            final desc = (productController.productDetails['description'] ?? "")
                .toString();
            if (desc.isEmpty) return const SizedBox(height: 0);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: Divider(
                    color: widget.backgroundcolor == whiteColor
                        ? colorSecondary
                        : titleColor,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      collapsedIconColor: widget.backgroundcolor == whiteColor
                          ? appBarColor
                          : whiteColor,
                      iconColor: widget.backgroundcolor == whiteColor
                          ? appBarColor
                          : whiteColor,
                      title: AppSpacingText(
                        text: 'More Details',
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w500,
                        color: widget.backgroundcolor == whiteColor
                            ? colorPrimary
                            : productSubtitleColor,
                        fontSize: 16,
                      ),
                      tilePadding: EdgeInsets.all(0.sp),
                      childrenPadding: EdgeInsets.symmetric(vertical: 4.0.sp),
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: AppSpacingText(
                            text: desc,
                            fontFamily: "Franklin Gothic Regular",
                            maxLines: 20,
                            fontWeight: FontWeight.w500,
                            color: widget.backgroundcolor == whiteColor
                                ? colorPrimary
                                : productSubtitleColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),

          if (productController.compositionDetails != null &&
              productController.compositionDetails != "")
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: Divider(
                    color: widget.backgroundcolor == whiteColor
                        ? colorSecondary
                        : titleColor,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      collapsedIconColor: widget.backgroundcolor == whiteColor
                          ? appBarColor
                          : whiteColor,
                      iconColor: widget.backgroundcolor == whiteColor
                          ? appBarColor
                          : whiteColor,
                      title: AppSpacingText(
                        text: 'Composition & Care',
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w500,
                        color: widget.backgroundcolor == whiteColor
                            ? colorPrimary
                            : productSubtitleColor,
                        fontSize: 16,
                      ),
                      tilePadding: EdgeInsets.all(0.sp),
                      childrenPadding: EdgeInsets.symmetric(vertical: 4.0.sp),
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: AppSpacingText(
                            text: (productController
                                        .compositionDetails["description"] ??
                                    "")
                                .toString(),
                            fontFamily: "Franklin Gothic Regular",
                            maxLines: 20,
                            fontWeight: FontWeight.w500,
                            color: widget.backgroundcolor == whiteColor
                                ? colorPrimary
                                : productSubtitleColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          if (productController.returnPolicyDetails.value.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: Divider(
                    color: widget.backgroundcolor == whiteColor
                        ? colorSecondary
                        : titleColor,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      collapsedIconColor: widget.backgroundcolor == whiteColor
                          ? appBarColor
                          : whiteColor,
                      iconColor: widget.backgroundcolor == whiteColor
                          ? appBarColor
                          : whiteColor,
                      title: AppSpacingText(
                        text: 'Delivery & Returns',
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w500,
                        color: widget.backgroundcolor == whiteColor
                            ? colorPrimary
                            : productSubtitleColor,
                        fontSize: 16,
                      ),
                      tilePadding: EdgeInsets.all(0.sp),
                      childrenPadding: EdgeInsets.symmetric(vertical: 4.0.sp),
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: AppSpacingText(
                            text: productController.returnPolicyDetails.value,
                            fontFamily: "Franklin Gothic Regular",
                            maxLines: 20,
                            fontWeight: FontWeight.w500,
                            color: widget.backgroundcolor == whiteColor
                                ? colorPrimary
                                : productSubtitleColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          if (productController.brandDetails != null &&
              productController.brandDetails != "")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: Divider(
                    color: widget.backgroundcolor == whiteColor
                        ? colorSecondary
                        : titleColor,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      collapsedIconColor: widget.backgroundcolor == whiteColor
                          ? appBarColor
                          : whiteColor,
                      iconColor: widget.backgroundcolor == whiteColor
                          ? appBarColor
                          : whiteColor,
                      title: AppSpacingText(
                        text: 'About the Brand',
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w500,
                        color: widget.backgroundcolor == whiteColor
                            ? colorPrimary
                            : productSubtitleColor,
                        fontSize: 16,
                      ),
                      tilePadding: EdgeInsets.all(0.sp),
                      childrenPadding: EdgeInsets.symmetric(vertical: 4.0.sp),
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: AppSpacingText(
                            text: (productController
                                        .brandDetails["description"] ??
                                    "")
                                .toString(),
                            fontFamily: "Franklin Gothic Regular",
                            maxLines: 20,
                            fontWeight: FontWeight.w500,
                            color: widget.backgroundcolor == whiteColor
                                ? colorPrimary
                                : productSubtitleColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSizeTable(List<Map<String, dynamic>> chartData) {
    if (chartData.isEmpty)
      return Text("No size info", style: TextStyle(color: Colors.black));

    final headers = chartData.first.keys.toList();

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        /// ---------- Header Row ----------
        TableRow(
          decoration: BoxDecoration(color: Colors.white),
          children: headers.map((h) {
            return Padding(
              padding: EdgeInsets.all(8.sp),
              child: Text(
                h.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black, // ⭐ BLACK
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            );
          }).toList(),
        ),

        /// ---------- Values ----------
        ...chartData.map((row) {
          return TableRow(
            decoration: BoxDecoration(color: Colors.white),
            children: headers.map((h) {
              return Padding(
                padding: EdgeInsets.all(8.sp),
                child: Text(
                  row[h]?.toString() ?? "-",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black, // ⭐ BLACK
                    fontSize: 12.sp,
                  ),
                ),
              );
            }).toList(),
          );
        })
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: EdgeInsets.all(8.sp),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: "Franklin Gothic",
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8.sp),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: "Franklin Gothic Regular",
          fontSize: 12.sp,
        ),
      ),
    );
  }

// Add this Widget method to your ProductDetailsScreenState class

  Widget _ratingsAndReviewsSection() {
    return Obx(() {
      final reviews = productController.reviewList;
      final totalReviews = productController.totalReview.value;
      final isLoading = productController.isFetchingReviews.value;

      // ✅ Compute average rating dynamically
      double avgRating = 0;
      if (reviews.isNotEmpty) {
        final sum = reviews.fold<double>(
          0.0,
          (prev, review) =>
              prev + ((review['rating'] as num?)?.toDouble() ?? 0),
        );
        avgRating = sum / reviews.length;
      }

      // ✅ Hide section if no reviews and not loading
      if (!isLoading && reviews.isEmpty && totalReviews == 0) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Header ----------
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 16.sp),
            child: AppSpacingText(
              text: 'RATINGS & REVIEWS',
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w600,
              color: widget.backgroundcolor == whiteColor
                  ? blackColor
                  : whiteColor,
              fontSize: 16,
            ),
          ),

          // ---------- Average Rating + Count ----------
          Padding(
            padding: EdgeInsets.only(left: 12.sp, right: 12.sp, bottom: 12.sp),
            child: Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B67A),
                    borderRadius: BorderRadius.circular(4.sp),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: whiteColor, size: 14.sp),
                      SizedBox(width: 4.sp),
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w700,
                          color: whiteColor,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.sp),
                Text(
                  '$totalReviews ${totalReviews == 1 ? "Review" : "Reviews"}',
                  style: TextStyle(
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: widget.backgroundcolor == whiteColor
                        ? subtitleColor
                        : searchTextColor,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),

          // ---------- Loader ----------
          if (isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.sp),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // ---------- Review List ----------
          if (!isLoading && reviews.isNotEmpty)
            ...reviews.take(3).map((review) {
              final user = review['user'] ?? {};
              final variant = review['product_variant'] ?? {};

              final userName =
                  (user['fullName'] ?? user['name'] ?? 'Anonymous').toString();
              final comment = (review['comment'] ?? '').toString();
              final rating = (review['rating'] as num?)?.toInt() ?? 0;
              final createdAt = review['createdAt'] ?? '';
              final variantTitle = variant['title']?.toString();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReviewItem(
                    name: userName.toUpperCase(),
                    date: _formatReviewDate(createdAt),
                    rating: rating,
                    review:
                        comment.isNotEmpty ? comment : "No comment provided",
                    variant:
                        variantTitle != null ? "Size: $variantTitle" : null,
                  ),
                  if (review != reviews.take(3).last)
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.sp, vertical: 8.sp),
                      child: Divider(
                        color: widget.backgroundcolor == whiteColor
                            ? colorSecondary
                            : titleColor,
                        height: 1,
                      ),
                    ),
                ],
              );
            }).toList(),

          // ---------- No Reviews Message ----------
          if (!isLoading && reviews.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.sp, horizontal: 12.sp),
              child: Center(
                child: AppSpacingText(
                  text: 'No reviews yet. Be the first to review!',
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: widget.backgroundcolor == whiteColor
                      ? subtitleColor
                      : searchTextColor,
                  fontSize: 13,
                ),
              ),
            ),

          // ---------- See All ----------
          if (!isLoading && reviews.length > 3)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 16.sp),
              child: Center(
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to full review page
                    print('Navigate to all reviews - Total: $totalReviews');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 32.sp, vertical: 12.sp),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.backgroundcolor == whiteColor
                            ? blackColor
                            : whiteColor,
                        width: 1.sp,
                      ),
                    ),
                    child: Text(
                      'SEE ALL REVIEWS ($totalReviews)',
                      style: TextStyle(
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w500,
                        color: widget.backgroundcolor == whiteColor
                            ? blackColor
                            : whiteColor,
                        fontSize: 13.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildReviewItem({
    required String name,
    required String date,
    required int rating,
    required String review,
    String? variant,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  color: nameText,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  fontSize: 11.sp,
                  color: subtitleColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 4.sp),

          // Stars
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                size: 14.sp,
                color: const Color(0xFFFFB800),
              ),
            ),
          ),

          SizedBox(height: 6.sp),

          // Variant info
          if (variant != null)
            Text(
              variant,
              style: TextStyle(
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
                color: subtitleColor,
              ),
            ),

          SizedBox(height: 4.sp),

          // Review text
          Text(
            review,
            style: TextStyle(
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              color: nameText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatReviewDate(dynamic dateValue) {
    if (dateValue == null) return '';

    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return '';
      }

      final months = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC'
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      print('Error formatting date: $e');
      return '';
    }
  }
}
