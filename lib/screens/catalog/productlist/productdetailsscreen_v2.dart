// ignore_for_file: avoid_print, deprecated_member_use
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/other/common_widget.dart';
import 'package:lafetch/common/widget/other/product_price_display.dart';
import 'package:lafetch/controllers/cart_controller.dart';
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/catalog/productlist/ProductImageScreen.dart';
import 'package:lafetch/screens/catalog/productlist/ReviewOrderScreen.dart';
import 'package:page_indicator_plus/page_indicator_plus.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import '../../../core/services/meta_event_service.dart';
import '../../cartscreen.dart';
import '../../wishlist/boardscreen.dart';
import '../../wishlist/newboardscreen.dart';
import '../../../services/event_tracking_service.dart';
import '../../../common/widget/other/error_shake.dart';
import '../../../widgets/similar_products_carousel.dart';
import '../../../common/widget/newsletter/newsletter_section.dart';

class ProductDetailsScreenV2 extends StatefulWidget {
  final int productId;
  final String type;
  final String brandName;
  final int wishlistProductId;
  final int boardId;
  final String Slug;
  final Color backgroundcolor;
  final String expresshour;
  final int expressValue;

  const ProductDetailsScreenV2({
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
  State<ProductDetailsScreenV2> createState() => _ProductDetailsScreenV2State();
}

class _ProductDetailsScreenV2State extends State<ProductDetailsScreenV2> {
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final cartController = Get.put(CartController());
  final brandController = Get.put(BrandController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final TextEditingController _emailController = TextEditingController();
  Razorpay? _razorpay;

  bool _isForeground = true;
  int _curr = 0;
  int _selectedQuantity = 1;
  bool _addressSelected = false;
  dynamic _addressResult;
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: statusBarColor,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.errorMsg.value = "";
      productController.errorSizeMsg.value = "";
      productController.errorColorMsg.value = "";
      productController.selectedSize.value = "";
      productController.selectedColor.value = "";
      productController.sizeInventoryList.clear();
      productController.colorInventoryList.clear();
      productController.selectedVariants.clear();
      setState(() => _selectedQuantity = 1);
      productController
          .getProductById(widget.productId,
              slug: widget.Slug.isNotEmpty ? widget.Slug : null)
          .then((_) {
        final productId =
            productController.productDetails["id"] as int? ?? widget.productId;
        wishlistController.checkIfWishlisted(productId);
        productController.getProductReviews(productId);
        MetaEventService.instance
            .logViewContent(contentId: productId.toString());
        EventTrackingService.instance.trackView(productId);
      });
    });
  }

  @override
  void dispose() {
    try {
      _razorpay?.clear();
    } catch (_) {}
    _emailController.dispose();
    super.dispose();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  bool _isImageUrl(String url) {
    final p = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.png') ||
        p.endsWith('.webp') ||
        p.endsWith('.gif');
  }

  List<String> _imagesOnly() {
    if (productController.currentDisplayImages.isNotEmpty) {
      final imgs = productController.currentDisplayImages
          .where((u) => u.isNotEmpty && _isImageUrl(u))
          .toList();
      if (imgs.isNotEmpty) return imgs;
    }
    if (productController.imageList.isNotEmpty) {
      final imgs = productController.imageList
          .map((e) => (e['name']?.toString() ?? '').trim())
          .where((u) => u.isNotEmpty && _isImageUrl(u))
          .toList();
      if (imgs.isNotEmpty) return imgs;
    }
    final imageUrls = productController.productDetails['imageUrls'];
    if (imageUrls is List && imageUrls.isNotEmpty) {
      return imageUrls
          .map((u) => u.toString().trim())
          .where((u) => u.isNotEmpty && _isImageUrl(u))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> _pd() {
    final raw = productController.productDetails;
    if (raw is Map) return Map<String, dynamic>.from(raw as Map);
    return {};
  }

  String _brandText() {
    final m = _pd();
    return ((m['brand_name'] ??
                (m['brand'] is Map ? m['brand']['name'] : null) ??
                widget.brandName) ??
            "")
        .toString();
  }

  String _titleText() {
    final m = _pd();
    return (m['name'] ?? m['title'] ?? "").toString();
  }

  double? _extractDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  Future<String> _shareLink() async {
    final id = productController.productDetails["id"] ?? widget.productId;
    final slug = productController.productDetails["slug"] ?? "";
    return Uri.https("lafetch.onelink.me", "/rxDU", {
      "product_id": id.toString(),
      "slug": slug.toString(),
      "af_dp": "productdetails",
      "af_channel": "product_share",
      "c": "product_share",
    }).toString();
  }

  void _showLoading() =>
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);
  void _hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  // ── buy now ───────────────────────────────────────────────────────────────

  Future<void> _onBuyNow({required bool isCartFlow}) async {
    if (!productController.checkDetailsValidation()) return;
    final variant = productController.getSelectedVariant();
    if (variant == null) {
      showAppSnackBar('Please select size and color', type: SnackBarType.error);
      return;
    }
    final variantId = variant['id'] as int;
    final stock = int.tryParse((variant['inventories']?[0]?['availableStock'] ??
                    variant['availableStock'] ??
                    variant['stocks'] ??
                    variant['stock'])
                ?.toString() ??
            '0') ??
        0;
    if (stock <= 0) {
      showAppSnackBar('Selected variant is out of stock',
          type: SnackBarType.error);
      return;
    }
    final firstImg = _imagesOnly().isNotEmpty ? _imagesOnly().first : '';
    final sizeLabel =
        "${productController.selectedSize.value}${productController.selectedColor.value.isNotEmpty ? ' / ${productController.selectedColor.value}' : ''}";
    _showLoading();
    String? hsnCode;
    double? gstRate;
    double? statutoryGSTRate;
    String? gstRuleApplied;
    final pd = productController.productDetails;
    if (pd.isNotEmpty && pd["variants"] != null) {
      final variants = List<Map<String, dynamic>>.from(
          (pd["variants"] as List).whereType<Map>());
      final mv = variants.firstWhereOrNull((v) => v["id"] == variantId) ?? {};
      if (mv.isNotEmpty) {
        hsnCode = mv["hsn_code"]?.toString() ?? mv["hsnCode"]?.toString();
        gstRate = _extractDouble(mv["gst_rate"] ?? mv["gstRate"]);
        statutoryGSTRate = _extractDouble(mv["statutory_gst_rate"] ??
            mv["statutoryGSTRate"] ??
            mv["gst_rate"] ??
            mv["gstRate"]);
        gstRuleApplied =
            mv["gst_rule"]?.toString() ?? mv["gstRule"]?.toString();
      }
      if (hsnCode == null || hsnCode.isEmpty || gstRate == null) {
        hsnCode ??= pd["hsn_code"]?.toString() ?? pd["hsnCode"]?.toString();
        gstRate ??= _extractDouble(pd["gst_rate"] ?? pd["gstRate"]);
        statutoryGSTRate ??= _extractDouble(
                pd["statutory_gst_rate"] ?? pd["statutoryGSTRate"]) ??
            gstRate;
        gstRuleApplied ??=
            pd["gst_rule"]?.toString() ?? pd["gstRule"]?.toString();
      }
    }
    _hideLoading();
    hsnCode ??= "";
    gstRate ??= 0.0;
    statutoryGSTRate ??= gstRate;
    gstRuleApplied ??= "VALUE_BASED";
    Get.to(() => ReviewOrderScreen(
          productId: widget.productId,
          variantId: variantId,
          title: _titleText(),
          brandName: _brandText(),
          imageUrl: firstImg,
          sizeLabel: sizeLabel,
          quantity: _selectedQuantity,
          price: (productController.getDisplayPrice() * _selectedQuantity)
              .toDouble(),
          mrp: (productController.getDisplayMrp() * _selectedQuantity)
              .toDouble(),
          maxStock: stock,
          initialAddress:
              _addressSelected ? _addressResult as Map<String, dynamic>? : null,
          hsnCode: hsnCode,
          gstRate: gstRate,
          statutoryGSTRate: statutoryGSTRate,
          gstRuleApplied: gstRuleApplied,
        ));
  }

  // ── trust badge sheet ─────────────────────────────────────────────────────

  void _showBadgeSheet(String key) {
    final Map<String, Map<String, dynamic>> info = {
      'buyer': {
        'title': 'Buyer Protection',
        'icon': Icons.verified_outlined,
        'body':
            'Your purchase is fully protected. If your order does not arrive or is not as described, we will make it right with a full refund or replacement.'
      },
      'auth': {
        'title': 'Authenticity Guaranteed',
        'icon': Icons.security_outlined,
        'body':
            'Every product on LaFetch is verified for authenticity by our expert team. We source only from trusted sellers and brands.'
      },
      'returns': {
        'title': 'Easy Returns',
        'icon': Icons.local_shipping_outlined,
        'body':
            'Not happy with your purchase? Return it within 7 days of delivery. We will pick it up from your doorstep at no extra cost.'
      },
      'exchange': {
        'title': 'Exchange Policy',
        'icon': Icons.swap_horiz_outlined,
        'isImage': true
      },
    };
    final data = info[key]!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.sp))),
        padding: EdgeInsets.fromLTRB(20.sp, 12.sp, 20.sp, 32.sp),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 36.sp,
                      height: 4.sp,
                      decoration: BoxDecoration(
                          color: colorSecondary,
                          borderRadius: BorderRadius.circular(2.sp)))),
              SizedBox(height: 16.sp),
              Row(children: [
                Icon(data['icon'] as IconData, size: 22.sp),
                SizedBox(width: 10.sp),
                Text(data['title'] as String,
                    style: TextStyle(
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp)),
              ]),
              SizedBox(height: 16.sp),
              if (data['isImage'] == true)
                Container(
                    width: double.infinity,
                    height: 200.sp,
                    color: colorSecondary,
                    child: Center(
                        child: Text('Exchange Policy Image Placeholder',
                            style: TextStyle(color: subtitleColor))))
              else
                Text(data['body'] as String,
                    style: TextStyle(
                        fontFamily: "Clash Display Regular",
                        fontSize: 13.sp,
                        color: subtitleColor,
                        height: 1.6)),
              SizedBox(height: 8.sp),
            ]),
      ),
    );
  }

  // ── size chart ────────────────────────────────────────────────────────────

  void _openSizeChart() async {
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
        builder: (_) => Dialog(
              insetPadding: EdgeInsets.all(16.sp),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.sp)),
              child: Container(
                  padding: EdgeInsets.all(16.sp),
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(chart["title"]?.toString() ?? "Size Chart",
                            style: TextStyle(
                                fontFamily: "Clash Display",
                                fontWeight: FontWeight.w700,
                                fontSize: 18.sp)),
                        SizedBox(height: 14.sp),
                        if (chart["sizeGuideImage"] != null &&
                            chart["sizeGuideImage"].toString().isNotEmpty)
                          _ZoomableImage(imageUrl: chart["sizeGuideImage"])
                        else
                          _buildSizeTable(chartData),
                        SizedBox(height: 18.sp),
                        Center(
                            child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.sp)),
                              minimumSize: Size(180.sp, 48.sp)),
                          child: Text("Close",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Clash Display",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp)),
                        )),
                      ]))),
            ));
  }

  Widget _buildSizeTable(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const Text("No size info");
    final headers = data.first.keys.toList();
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
            decoration: const BoxDecoration(color: Colors.white),
            children: headers
                .map((h) => Padding(
                    padding: EdgeInsets.all(8.sp),
                    child: Text(h.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp))))
                .toList()),
        ...data.map((row) => TableRow(
            decoration: const BoxDecoration(color: Colors.white),
            children: headers
                .map((h) => Padding(
                    padding: EdgeInsets.all(8.sp),
                    child: Text(row[h]?.toString() ?? "-",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.black, fontSize: 12.sp))))
                .toList())),
      ],
    );
  }

  // ── add review ────────────────────────────────────────────────────────────

  void _showAddReviewModal() {
    _selectedRating = 0;
    final localCtrl = TextEditingController();
    final firstImg = _imagesOnly().isNotEmpty ? _imagesOnly().first : '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
          builder: (ctx, ss) => Container(
                height: MediaQuery.of(ctx).size.height * 0.85,
                decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.sp))),
                child: Column(children: [
                  Container(
                      margin: EdgeInsets.only(top: 12.sp),
                      width: 40.sp,
                      height: 4.sp,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.sp))),
                  Padding(
                      padding: EdgeInsets.all(16.sp),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('WRITE A REVIEW',
                                style: TextStyle(
                                    fontFamily: "Clash Display",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18.sp)),
                            IconButton(
                                icon: Icon(Icons.close, size: 24.sp),
                                onPressed: () => Get.back()),
                          ])),
                  Divider(color: colorSecondary, height: 1),
                  Expanded(
                      child: SingleChildScrollView(
                          padding: EdgeInsets.all(16.sp),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(12.sp),
                                    color: colorSecondary,
                                    child: Row(children: [
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                          child: firstImg.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: firstImg,
                                                  width: 80.sp,
                                                  height: 80.sp,
                                                  fit: BoxFit.cover,
                                                  errorWidget: (_, __, ___) =>
                                                      Image.asset(
                                                          dummyWishlistImage,
                                                          width: 80.sp,
                                                          height: 80.sp,
                                                          fit: BoxFit.cover))
                                              : Image.asset(dummyWishlistImage,
                                                  width: 80.sp,
                                                  height: 80.sp,
                                                  fit: BoxFit.cover)),
                                      SizedBox(width: 12.sp),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Text(_brandText().toUpperCase(),
                                                style: TextStyle(
                                                    fontFamily: "Clash Display",
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12.sp,
                                                    color: blackColor)),
                                            SizedBox(height: 4.sp),
                                            Text(_titleText(),
                                                style: TextStyle(
                                                    fontFamily:
                                                        "Clash Display Regular",
                                                    fontSize: 12.sp,
                                                    color: subtitleColor),
                                                maxLines: 3,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ])),
                                    ])),
                                SizedBox(height: 24.sp),
                                Text('Rate this product',
                                    style: TextStyle(
                                        fontFamily: "Clash Display",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp)),
                                SizedBox(height: 12.sp),
                                Row(
                                    children: List.generate(
                                        5,
                                        (i) => GestureDetector(
                                              onTap: () => ss(() =>
                                                  _selectedRating = i + 1),
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 8.sp),
                                                  child: Icon(
                                                      i < _selectedRating
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      size: 36.sp,
                                                      color: const Color(
                                                          0xFFFFB800))),
                                            ))),
                                SizedBox(height: 24.sp),
                                Text('Write your review',
                                    style: TextStyle(
                                        fontFamily: "Clash Display",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp)),
                                SizedBox(height: 12.sp),
                                TextField(
                                    controller: localCtrl,
                                    maxLines: 6,
                                    maxLength: 500,
                                    decoration: InputDecoration(
                                      hintText: 'Share your thoughts...',
                                      counterText: "",
                                      filled: true,
                                      fillColor: colorSecondary,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                          borderSide: BorderSide.none),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                          borderSide: BorderSide.none),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                          borderSide: BorderSide(
                                              color: lightPurpleColor,
                                              width: 1.sp)),
                                      contentPadding: EdgeInsets.all(12.sp),
                                    ),
                                    style: TextStyle(
                                        fontFamily: "Clash Display Regular",
                                        fontSize: 13.sp,
                                        color: blackColor)),
                                SizedBox(height: 24.sp),
                              ]))),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(color: whiteColor, boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2))
                    ]),
                    child: Obx(() {
                      final submitting =
                          productController.isSubmittingReview.value;
                      return ElevatedButton(
                        onPressed: submitting
                            ? null
                            : () async {
                                if (_selectedRating == 0) {
                                  showAppSnackBar('Please select a rating',
                                      type: SnackBarType.error);
                                  return;
                                }
                                if (localCtrl.text.trim().isEmpty) {
                                  showAppSnackBar('Please write a review',
                                      type: SnackBarType.error);
                                  return;
                                }
                                final nav = Navigator.of(ctx);
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final userId = prefs.getInt('userId') ?? 0;
                                if (userId == 0) {
                                  showAppSnackBar(
                                      'Please login to submit a review',
                                      type: SnackBarType.error);
                                  return;
                                }
                                var variant =
                                    productController.getSelectedVariant();
                                if (variant == null &&
                                    productController
                                        .selectedVariants.isNotEmpty)
                                  variant =
                                      productController.selectedVariants.first;
                                final variantId = variant?['id'] ?? 0;
                                if (variantId == 0) {
                                  showAppSnackBar('Please select a size first',
                                      type: SnackBarType.error);
                                  return;
                                }
                                final success =
                                    await productController.submitProductReview(
                                        userId: userId,
                                        productId: widget.productId,
                                        orderItemId: 0,
                                        variantId: variantId,
                                        rating: _selectedRating,
                                        comment: localCtrl.text.trim());
                                if (success) {
                                  nav.pop();
                                  await productController
                                      .getProductReviews(widget.productId);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                submitting ? Colors.grey : blackColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.sp)),
                            minimumSize: Size(double.infinity, 48.sp),
                            elevation: 0),
                        child: Text(
                            submitting ? 'SUBMITTING...' : 'SUBMIT REVIEW',
                            style: TextStyle(
                                fontFamily: "Clash Display",
                                fontWeight: FontWeight.w600,
                                color: whiteColor,
                                fontSize: 14.sp,
                                letterSpacing: 0.5)),
                      );
                    }),
                  ),
                ]),
              )),
    ).then((_) => localCtrl.dispose());
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AddToCartAnimation(
      cartKey: cartKey,
      height: 25.sp,
      width: 25.sp,
      opacity: 0.80,
      dragAnimation: const DragToCartAnimationOptions(rotation: true),
      createAddToCartAnimation: (fn) => runAddToCartAnimation = fn,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: whiteColor,
        body: Column(children: [
          ProductdetailsAppbar(
            productId:
                productController.productDetails["id"] ?? widget.productId,
            type: productController.productDetails["type"]?.toString() ?? "",
            brandName:
                productController.productDetails["brand_name"]?.toString() ??
                    "",
            slug: productController.productDetails["slug"]?.toString() ?? "",
            dark: false,
            onPressedHeart: () async {
              final prefs = await SharedPreferences.getInstance();
              if (prefs.getBool('skip') ?? false) {
                showAppSnackBar("Please login to add to wishlist",
                    type: SnackBarType.error);
                Get.toNamed('/login');
                return;
              }
              final firstImg = productController.imageList.isNotEmpty
                  ? (productController.imageList.first['name']?.toString() ??
                      '')
                  : '';
              final productId =
                  (productController.productDetails["id"] as int?) ??
                      widget.productId;
              scaffoldKey.currentState?.showBottomSheet((ctx) => BottomWishlist(
                    controller: wishlistController,
                    wishlistList: wishlistController.wishlistList,
                    productImage: firstImg,
                    onPressedBoard: () {
                      Get.back();
                      Get.to(() => NewBoardScreen(
                          title: "New Board",
                          boardName: "",
                          hintName: "Enter board name",
                          boardId: 0,
                          btnText: "Next",
                          productId: productId,
                          categoryId: 0,
                          screen: ""));
                    },
                    onPressed: (boardId) async {
                      final price =
                          ((productController.productDetails['lfMsp'] ?? 0)
                                  as num)
                              .toDouble();
                      await wishlistController
                          .addProductToBoard(boardId, productId, price: price);
                      Get.back();
                      final boardName = wishlistController.wishlistList
                              .firstWhere((b) => b['id'] == boardId,
                                  orElse: () => {'name': 'Board'})['name']
                              ?.toString() ??
                          'Board';
                      Get.to(() => BoardScreen(
                          boardName: boardName,
                          boardId: boardId,
                          productId: productId));
                    },
                  ));
            },
            onPressedShare: () async {
              final box = context.findRenderObject() as RenderBox?;
              final origin = box != null
                  ? box.localToGlobal(Offset.zero) & box.size
                  : null;
              try {
                final link = await _shareLink();
                final title = _titleText();
                Share.share(
                    title.isNotEmpty
                        ? "Check out $title on LaFetch!\n$link"
                        : "Check this product on LaFetch!\n$link",
                    sharePositionOrigin: origin);
              } catch (_) {
                Share.share(_titleText().isNotEmpty
                    ? _titleText()
                    : "Check this product");
              }
            },
            onPressedCart: () async {
              final prefs = await SharedPreferences.getInstance();
              if (prefs.getBool('skip') ?? false) {
                showAppSnackBar("Please login to view cart",
                    type: SnackBarType.error);
                Get.toNamed('/login');
                return;
              }
              Get.to(const CartScreen());
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              behavior: HitTestBehavior.opaque,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImages(),
                    _buildProductInfo(),
                    _buildTrustBadges(),
                    _buildSizeColorSection(),
                    _buildOfferSection(),
                    _buildPriceAndDelivery(),
                    _buildActionButtons(),
                    _buildSimilarProducts(),
                    _buildDeliveryPolicies(),
                    _buildLFNote(),
                    _buildFAQs(),
                    _buildLFPromises(),
                    _buildTrendingProducts(),
                    _buildNewsletter(),
                    SizedBox(height: 20.sp),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── section builders ──────────────────────────────────────────────────────

  Widget _buildImages() => Obx(() {
        if (_isForeground && productController.isDetails.value)
          return const DummyProductImage();
        final imgs = _imagesOnly();
        return Column(children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.54,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) {
                _curr = i;
              },
              itemCount: imgs.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () {
                  final gallery =
                      imgs.map((u) => {'name': u, 'isVideo': false}).toList();
                  Get.to(() => ProductImage_Screen(curr: i, list: gallery));
                },
                child: Hero(
                    tag: imgs[i],
                    child: CachedNetworkImage(
                      cacheManager: CacheManager(Config("customCacheKey",
                          stalePeriod: const Duration(days: 15),
                          maxNrOfCacheObjects: 100)),
                      fit: BoxFit.cover,
                      imageUrl: imgs[i],
                      width: double.infinity,
                      height: double.infinity,
                      progressIndicatorBuilder: (_, __, ___) => DummyContainer(
                          height: MediaQuery.of(context).size.height * 0.54,
                          width: MediaQuery.of(context).size.width),
                      errorWidget: (_, __, ___) =>
                          Image.asset(downloadImage, fit: BoxFit.cover),
                    )),
              ),
            ),
          ),
          if (imgs.length > 1)
            Padding(
              padding: EdgeInsets.only(top: 8.sp),
              child: PageIndicator(
                controller: _pageController,
                count: imgs.length,
                size: 5.0.sp,
                activeColor: Colors.black,
                color: const Color(0xffE5E7EB),
                layout: PageIndicatorLayout.WARM,
                scale: 0.6,
                space: 6.sp,
              ),
            ),
        ]);
      });

  Widget _buildProductInfo() => Obx(() {
        if (_isForeground && productController.isDetails.value)
          return const DummyProductDetails();
        return Padding(
            padding: EdgeInsets.only(
                left: 16.sp, right: 12.sp, top: 8.sp, bottom: 4.sp),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Text(_titleText(),
                      style: TextStyle(
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp)),
                ),
                if (productController.brandDetails != null &&
                    productController.brandDetails != "")
                  GestureDetector(
                    onTap: () async {
                      final brandId = productController.productDetails["brand"]
                              ?["id"] as int? ??
                          0;
                      if (brandId > 0)
                        Get.to(() => AllBrandScreen(
                            id: brandId,
                            screen: 'brand',
                            slug:
                                '${productController.productDetails["brand"]?["slug"] ?? ''}'));
                    },
                    child: Container(
                      color: const Color(0xFFDFDBFF),
                      padding: EdgeInsets.only(
                          left: 10.sp, right: 8.sp, top: 6.sp, bottom: 6.sp),
                      child: Row(children: [
                        Text('View Brand'.toUpperCase(),
                            style: TextStyle(
                                fontFamily: "Clash Display",
                                fontWeight: FontWeight.w500,
                                color: homeAppBarColor,
                                fontSize: 10.sp)),
                        SizedBox(width: 4.sp),
                        ImageIcon(AssetImage(linkArrowImage), size: 16.sp),
                      ]),
                    ),
                  ),
              ]),
              SizedBox(height: 4.sp),
              if (_brandText().isNotEmpty)
                Text(_brandText().toUpperCase(),
                    style: TextStyle(
                        fontFamily: "Clash Display Regular",
                        fontSize: 14.sp,
                        color: subtitleColor)),
            ]));
      });

  Widget _buildTrustBadges() => Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: Wrap(
        spacing: 8.sp,
        runSpacing: 8.sp,
        children: [
          _trustChip(Icons.verified_outlined, 'Buyer Protection',
              () => _showBadgeSheet('buyer')),
          _trustChip(Icons.security_outlined, 'Authenticity Guaranteed',
              () => _showBadgeSheet('auth')),
          _trustChip(Icons.local_shipping_outlined, 'Easy Returns',
              () => _showBadgeSheet('returns')),
          _trustChip(Icons.swap_horiz_outlined, 'Exchange Policy',
              () => _showBadgeSheet('exchange')),
        ],
      ));

  Widget _trustChip(IconData ic, String lbl, VoidCallback tap) =>
      GestureDetector(
          onTap: tap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 7.sp),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(20.sp),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(ic, size: 14.sp, color: blackColor),
              SizedBox(width: 5.sp),
              Text(lbl,
                  style: TextStyle(
                      fontFamily: "Clash Display Regular",
                      fontSize: 11.sp,
                      color: blackColor)),
              SizedBox(width: 5.sp),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 8.sp, color: blackColor),
            ]),
          ));

  Widget _buildSizeColorSection() => Obx(() {
        final hasSizes = productController.sizeInventoryList.isNotEmpty;
        final hasColors = productController.colorInventoryList.isNotEmpty;
        if (!hasSizes && !hasColors) return const SizedBox();
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (hasSizes) ...[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SELECT SIZE',
                          style: TextStyle(
                              fontFamily: "Clash Display",
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp)),
                    ]),
                SizedBox(height: 8.sp),
                GestureDetector(
                  onTap: _showSizeBottomSheet,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.sp, vertical: 14.sp),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: productController.errorSizeMsg.value.isNotEmpty
                              ? deepRed
                              : borderColor),
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            productController.selectedSize.value.isEmpty
                                ? 'Choose size'
                                : productController.selectedSize.value,
                            style: TextStyle(
                                fontFamily: "Clash Display Regular",
                                fontSize: 14.sp,
                                color:
                                    productController.selectedSize.value.isEmpty
                                        ? textHintColor
                                        : blackColor),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              color: blackColor, size: 22.sp),
                        ]),
                  ),
                ),
                if (productController.errorSizeMsg.value.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 6.sp),
                    child: ShakeWidget(
                      trigger: productController.sizeShakeTrigger.value,
                      child: Text(productController.errorSizeMsg.value,
                          style: TextStyle(
                              fontFamily: "Clash Display Regular",
                              fontSize: 12.sp,
                              color: deepRed)),
                    ),
                  ),
                SizedBox(height: 12.sp),
              ],
              if (hasColors &&
                  (!hasSizes ||
                      productController.selectedSize.value.isNotEmpty)) ...[
                Text('SELECT COLOR',
                    style: TextStyle(
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp)),
                SizedBox(height: 8.sp),
                _styledDropdown<String>(
                  value: productController.selectedColor.value.isEmpty
                      ? null
                      : productController.selectedColor.value,
                  hint: 'Choose color',
                  hasError: productController.errorColorMsg.value.isNotEmpty,
                  items: productController.colorInventoryList
                      .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c,
                              style: TextStyle(
                                  fontFamily: "Clash Display Regular",
                                  fontSize: 14.sp))))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      productController.selectedColor.value = v;
                      productController.errorColorMsg.value = "";
                      productController.updateImagesForSelectedColor();
                      if (_pageController.hasClients)
                        _pageController.jumpToPage(0);
                      setState(() => _selectedQuantity = 1);
                    }
                  },
                ),
                if (productController.errorColorMsg.value.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 6.sp),
                    child: ShakeWidget(
                      trigger: productController.colorShakeTrigger.value,
                      child: Text(productController.errorColorMsg.value,
                          style: TextStyle(
                              fontFamily: "Clash Display Regular",
                              fontSize: 12.sp,
                              color: deepRed)),
                    ),
                  ),
              ],
            ]));
      });

  void _showSizeBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.sp))),
        padding: EdgeInsets.fromLTRB(16.sp, 12.sp, 16.sp, 32.sp),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 36.sp,
                      height: 4.sp,
                      decoration: BoxDecoration(
                          color: colorSecondary,
                          borderRadius: BorderRadius.circular(2.sp)))),
              SizedBox(height: 16.sp),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('SELECT SIZE',
                    style: TextStyle(
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp)),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    _openSizeChart();
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
                    decoration: BoxDecoration(
                        border: Border.all(color: lightPurpleColor),
                        borderRadius: BorderRadius.circular(20.sp)),
                    child: Text('Size Chart',
                        style: TextStyle(
                            fontFamily: "Clash Display Regular",
                            color: lightPurpleColor,
                            fontSize: 12.sp)),
                  ),
                ),
              ]),
              SizedBox(height: 16.sp),
              Obx(() => Wrap(
                    spacing: 8.sp,
                    runSpacing: 8.sp,
                    children: productController.sizeInventoryList.map((size) {
                      final isSelected =
                          productController.selectedSize.value == size;
                      final matchingVariant = productController.selectedVariants
                          .firstWhereOrNull((v) => v["size"] == size);
                      final sizeStock = matchingVariant != null
                          ? (matchingVariant["stocks"] as int? ?? 0)
                          : 0;
                      final isOutOfStock =
                          matchingVariant != null && sizeStock <= 0;
                      return GestureDetector(
                        onTap: isOutOfStock
                            ? null
                            : () {
                                productController.selectedSize.value = size;
                                productController.errorSizeMsg.value = "";
                                productController.loadColorsForSize(size);
                                if (_pageController.hasClients)
                                  _pageController.jumpToPage(0);
                                setState(() => _selectedQuantity = 1);
                                Get.back();
                              },
                        child: Opacity(
                          opacity: isOutOfStock ? 0.4 : 1.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.sp, vertical: 12.sp),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: isSelected
                                      ? lightPurpleColor
                                      : Colors.black87,
                                  width: isSelected ? 2 : 1),
                              borderRadius: BorderRadius.circular(8.sp),
                              color: isSelected
                                  ? lightPurpleColor
                                  : Colors.transparent,
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(size.toUpperCase(),
                                      style: TextStyle(
                                          fontFamily: "Clash Display Regular",
                                          fontSize: 13.sp,
                                          color: isSelected
                                              ? whiteColor
                                              : Colors.black87)),
                                  if (matchingVariant != null &&
                                      sizeStock <= 2 &&
                                      sizeStock > 0)
                                    Text('Only $sizeStock left',
                                        style: TextStyle(
                                            fontSize: 9.sp,
                                            color: isSelected
                                                ? whiteColor.withOpacity(0.8)
                                                : lightPurpleColor)),
                                ]),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              SizedBox(height: 8.sp),
            ]),
      ),
    );
  }

  Widget _styledDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    bool hasError = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: hasError ? deepRed : borderColor),
        borderRadius: BorderRadius.circular(12.sp),
        color: whiteColor,
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.sp),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: blackColor, size: 22.sp),
          hint: Text(hint,
              style: TextStyle(
                  fontFamily: "Clash Display Regular",
                  fontSize: 14.sp,
                  color: textHintColor)),
          items: items,
          onChanged: onChanged,
          dropdownColor: whiteColor,
          borderRadius: BorderRadius.circular(12.sp),
          style: TextStyle(
              fontFamily: "Clash Display Regular",
              fontSize: 14.sp,
              color: blackColor),
        ),
      ),
    );
  }

  Widget _buildOfferSection() => const SizedBox();

  Widget _buildPriceAndDelivery() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Obx(() => ProductPriceDisplay(
              price: productController.getDisplayPrice(),
              mrp: productController.getDisplayMrp() >
                      productController.getDisplayPrice()
                  ? productController.getDisplayMrp()
                  : null,
              fontSize: 18,
              mrpFontSize: 16,
              discountFontSize: 12,
              fontWeight: FontWeight.w600,
              priceColor: blackColor,
              mrpColor: searchTextColor,
              spacing: 10,
            )),
        Text('Price inclusive of all taxes',
            style: TextStyle(color: lightPurpleColor, fontSize: 12.sp)),
        SizedBox(height: 16.sp),
        AppSpacingText(
          text: 'Delivery Options'.toUpperCase(),
          fontFamily: "Clash Display Regular",
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontSize: 12,
        ),
        SizedBox(height: 12.sp),
        SizedBox(
          height: 44.sp,
          child: TextField(
            controller: productController.pincodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: whiteColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.sp),
              hintText: "Enter pincode",
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: textHintColor,
                fontFamily: "Clash Display",
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: borderColor),
                borderRadius: BorderRadius.circular(4.sp),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: borderColor),
                borderRadius: BorderRadius.circular(4.sp),
              ),
              suffixIcon: TextButton(
                onPressed: () async {
                  final pin = productController.pincodeController.text.trim();
                  if (!productController.checkPinvalidation(pin)) {
                    productController.serviceabilityMessage.value =
                        "Enter valid pincode";
                    return;
                  }

                  final variant = productController.getSelectedVariant();
                  if (variant == null) {
                    final hasSizes =
                        productController.sizeInventoryList.isNotEmpty;
                    final hasColors =
                        productController.colorInventoryList.isNotEmpty;
                    final sizeSelected =
                        productController.selectedSize.value.isNotEmpty;
                    final colorSelected =
                        productController.selectedColor.value.isNotEmpty;

                    String errorMsg = "Please select ";
                    if (hasSizes && !sizeSelected) {
                      errorMsg += "size";
                      if (hasColors) errorMsg += " and color";
                    } else if (hasColors && !colorSelected) {
                      errorMsg += "color";
                    } else {
                      errorMsg = "Product variant not available";
                    }

                    productController.serviceabilityMessage.value = errorMsg;
                    return;
                  }

                  final variantId = variant['id'] as int? ?? 0;
                  if (variantId == 0) {
                    productController.serviceabilityMessage.value =
                        "Invalid variant selected";
                    return;
                  }

                  productController.serviceabilityMessage.value = "";
                  productController.isServiceable.value = false;
                  productController.courierName.value = "";
                  productController.estimatedDate.value = "";
                  productController.estimatedDays.value = "";

                  final result = await productController.checkServiceability(
                    variantId: variantId,
                    deliveryPostalCode: pin,
                  );

                  if (result != null && result["data"] is Map) {
                    final data = result["data"];
                    productController.courierName.value =
                        data["courier"]?.toString() ?? "";
                    productController.estimatedDate.value =
                        data["estimatedDate"]?.toString() ?? "";
                    productController.estimatedDays.value =
                        data["estimatedDays"]?.toString() ?? "";
                    productController.isServiceable.value = true;
                    productController.serviceabilityMessage.value =
                        "Delivery by ${productController.estimatedDate.value} (${productController.estimatedDays.value} Days)";
                  } else {
                    productController.serviceabilityMessage.value =
                        "Service not available for this pincode";
                  }
                },
                child: Text(
                  "Check",
                  style: TextStyle(
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w600,
                    color: lightPurpleColor,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.sp),
        Obx(() {
          if (productController.serviceabilityMessage.value.isEmpty) {
            return const SizedBox();
          }
          final isSuccess = productController.isServiceable.value;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: isSuccess ? Colors.green : const Color(0xFFD63333),
                size: 16.sp,
              ),
              SizedBox(width: 8.sp),
              Expanded(
                child: Text(
                  productController.serviceabilityMessage.value,
                  style: TextStyle(
                    fontFamily: "Clash Display Regular",
                    fontSize: 12.sp,
                    color: isSuccess ? Colors.green : const Color(0xFFD63333),
                  ),
                ),
              ),
            ],
          );
        }),
      ]),
    );
  }

  Widget _buildActionButtons() => Obx(() {
        if (productController.isDetails.value) return const SizedBox();
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48.sp,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!productController.checkDetailsValidation()) return;
                    final variant = productController.getSelectedVariant();
                    if (variant == null) {
                      showAppSnackBar('Please select size and color',
                          type: SnackBarType.error);
                      return;
                    }
                    final variantId = variant['id'] as int;
                    final variantPrice =
                        ((variant['lfMsp'] ?? variant['price'] ?? 0) as num)
                            .toDouble();
                    await cartController.addToCartUniversal(
                        quantity: _selectedQuantity,
                        page: "addproduct",
                        variantId: variantId,
                        productId: widget.productId,
                        expressValue: widget.expressValue,
                        type: 1,
                        backColor: whiteColor,
                        oldInventoryId: variantId,
                        price: variantPrice);
                    EventTrackingService.instance
                        .trackAddToCart(widget.productId, variantId);
                    setState(() => _selectedQuantity = 1);
                    await analytics.logEvent(
                        name: 'productDetails_btnaddtocart',
                        parameters: {
                          'page_name': 'productDetails_btnaddtocart'
                        });
                    await Future.delayed(const Duration(milliseconds: 300));
                    Get.to(const CartScreen())?.then((_) =>
                        productController.getProductById(widget.productId));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blackColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.sp)),
                    elevation: 0,
                  ),
                  child: Text('ADD TO BAG',
                      style: TextStyle(
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w600,
                          color: whiteColor,
                          fontSize: 13.sp)),
                ),
              ),
              SizedBox(height: 12.sp),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48.sp,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _onBuyNow(isCartFlow: false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: whiteColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.sp),
                              side: BorderSide(color: blackColor, width: 2.sp)),
                          elevation: 0,
                        ),
                        child: Text('BUY NOW',
                            style: TextStyle(
                                fontFamily: "Clash Display",
                                fontWeight: FontWeight.w600,
                                color: blackColor,
                                fontSize: 13.sp)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.sp),
                  GestureDetector(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      if (prefs.getBool('skip') ?? false) {
                        showAppSnackBar("Please login to add to wishlist",
                            type: SnackBarType.error);
                        Get.toNamed('/login');
                        return;
                      }
                      final firstImg = productController.imageList.isNotEmpty
                          ? (productController.imageList.first['name']
                                  ?.toString() ??
                              '')
                          : '';
                      final productId =
                          (productController.productDetails["id"] as int?) ??
                              widget.productId;
                      scaffoldKey.currentState
                          ?.showBottomSheet((ctx) => BottomWishlist(
                                controller: wishlistController,
                                wishlistList: wishlistController.wishlistList,
                                productImage: firstImg,
                                onPressedBoard: () {
                                  Get.back();
                                  Get.to(() => NewBoardScreen(
                                      title: "New Board",
                                      boardName: "",
                                      hintName: "Enter board name",
                                      boardId: 0,
                                      btnText: "Next",
                                      productId: productId,
                                      categoryId: 0,
                                      screen: ""));
                                },
                                onPressed: (boardId) async {
                                  final price = ((productController
                                              .productDetails['lfMsp'] ??
                                          0) as num)
                                      .toDouble();
                                  await wishlistController.addProductToBoard(
                                      boardId, productId,
                                      price: price);
                                  Get.back();
                                  final boardName = wishlistController
                                          .wishlistList
                                          .firstWhere((b) => b['id'] == boardId,
                                              orElse: () =>
                                                  {'name': 'Board'})['name']
                                          ?.toString() ??
                                      'Board';
                                  Get.to(() => BoardScreen(
                                      boardName: boardName,
                                      boardId: boardId,
                                      productId: productId));
                                },
                              ));
                    },
                    child: Container(
                      height: 48.sp,
                      width: 48.sp,
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(40.sp),
                        border: Border.all(color: blackColor, width: 1.sp),
                      ),
                      child: Center(
                        child: Obx(() {
                          final isWishlisted =
                              wishlistController.isWishlisted.value;
                          return Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isWishlisted
                                ? const Color(0xFFD63333)
                                : blackColor,
                            size: 20.sp,
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      });

  Widget _buildDeliveryExchangePlaceholder() => Padding(
      padding: EdgeInsets.all(16.sp),
      child: Container(
          height: 150.sp,
          color: colorSecondary,
          child: const Center(
              child: Text('Delivery & Exchange Image Placeholder',
                  style: TextStyle(color: subtitleColor)))));

  Widget _buildSimilarProducts() => SimilarProductsCarousel(
      productId: widget.productId,
      showTrending: false,
      onNavigating: () => setState(() => _isForeground = false));

  Widget _buildDeliveryPolicies() => Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: ExpansionTile(
          title: const Text('Delivery & Services Policies'),
          children: [
            Padding(
                padding: EdgeInsets.all(12.sp),
                child: const Text(
                    'Free delivery on orders above ₹999\n7-day return policy\nCash on delivery available\nSecure payments'))
          ]));

  Widget _buildLFNote() => Obx(() {
        if (productController.isDetails.value) return const SizedBox();
        final desc =
            productController.productDetails['description']?.toString() ?? '';
        if (desc.isEmpty) return const SizedBox();
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child: ExpansionTile(title: const Text('LF Note'), children: [
              Padding(padding: EdgeInsets.all(12.sp), child: Text(desc))
            ]));
      });

  Widget _buildFAQs() => Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.sp),
      child: Column(children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: 12.sp),
            child: Text('FAQs',
                style: TextStyle(
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp))),
        const ExpansionTile(
            shape: Border(),
            title: Text(
              'What is your return policy?',
              style: TextStyle(fontFamily: "Clash Display"),
            ),
            children: [
              Text(
                '7-day return policy from delivery date',
                style: TextStyle(fontFamily: "Clash Display"),
              )
            ]),
        const ExpansionTile(
            shape: Border(),
            title: Text(
              'How long does shipping take?',
              style: TextStyle(fontFamily: "Clash Display"),
            ),
            children: [
              Text(
                '3-5 business days for standard delivery',
                style: TextStyle(fontFamily: "Clash Display"),
              )
            ]),
        const ExpansionTile(
            shape: Border(),
            title: Text(
              'Do you ship internationally?',
              style: TextStyle(fontFamily: "Clash Display"),
            ),
            children: [
              Text(
                'Currently we ship within India only',
                style: TextStyle(fontFamily: "Clash Display"),
              )
            ]),
        const ExpansionTile(
            shape: Border(),
            title: Text(
              'Are products authentic?',
              style: TextStyle(fontFamily: "Clash Display"),
            ),
            children: [
              Text(
                'Yes, all products are 100% authentic and verified',
                style: TextStyle(fontFamily: "Clash Display"),
              )
            ]),
      ]));

  Widget _buildLFPromises() => Container(
      margin: EdgeInsets.all(16.sp),
      padding: EdgeInsets.all(16.sp),
      color: colorSecondary,
      child: Column(children: [
        Text('LF Promises',
            style: TextStyle(
                fontFamily: "Clash Display",
                fontWeight: FontWeight.w600,
                fontSize: 16.sp)),
        SizedBox(height: 12.sp),
        const Text(
            '✓ 100% Authentic Products\n✓ Secure Payments\n✓ Fast Delivery\n✓ Easy Returns\n✓ 24/7 Customer Support'),
      ]));

  Widget _buildTrendingProducts() => SimilarProductsCarousel(
      productId: widget.productId,
      showSimilar: false,
      onNavigating: () => setState(() => _isForeground = false));

  Widget _buildNewsletter() => const NewsletterSection(title: "NEWS LETTERS");
}

// ── zoomable image widget ─────────────────────────────────────────────────────

class _ZoomableImage extends StatefulWidget {
  final String imageUrl;
  const _ZoomableImage({required this.imageUrl});
  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final TransformationController _ctrl = TransformationController();
  void _reset() => _ctrl.value = Matrix4.identity();
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onScaleEnd: (_) => _reset(),
          child: InteractiveViewer(
            transformationController: _ctrl,
            minScale: 1.0,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              width: double.infinity,
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.black.withOpacity(0.06),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            color: Colors.grey.withOpacity(0.5), size: 48),
                        const SizedBox(height: 8),
                        const Text("Size guide image unavailable",
                            style: TextStyle(color: Colors.grey, fontSize: 12))
                      ])),
            ),
          ),
        ),
      );
}
