// ignore_for_file: avoid_print, deprecated_member_use
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../../../common/widget/appbar/productdetails_appbar.dart';
import '../../../../common/widget/bottom_sheets/bottomwishlist.dart';
import '../../../../common/widget/button/oublebutton_iconnew.dart';
import '../../../../common/widget/lists/dummy_container.dart';
import '../../../../common/widget/lists/dummy_productImage.dart';
import '../../../../common/widget/lists/dummy_productdetails.dart';
import '../../../../common/widget/text/app_space_text.dart';
import '../../../../controllers/brand_controller.dart';
import '../../../../controllers/product_controller.dart';
import '../../../../controllers/wishlist_controller.dart';
import '../../../../core/constant/constants.dart';
import '../../../../core/services/meta_event_service.dart';
import '../../../cartscreen.dart';
import '../../../wishlist/boardscreen.dart';
import '../../../wishlist/newboardscreen.dart';
import '../../../wishlistscreen.dart';
import '../../../../services/event_tracking_service.dart';
import '../../../../common/widget/other/error_shake.dart';
import '../../../../widgets/similar_products_carousel.dart';
import '../../../../common/widget/newsletter/newsletter_section.dart';
import '../../../searchscreen.dart';
import '../../../search_results_screen.dart';
import '../../../bottomnavscreen.dart';
import '../../../../controllers/search_controller.dart';

part 'pdp_zoomable_image.dart';
part 'pdp_image_section.dart';
part 'pdp_info_section.dart';
part 'pdp_size_section.dart';
part 'pdp_delivery_section.dart';
part 'pdp_bottom_section.dart';
part 'pdp_dialogs.dart';

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
  final GlobalKey _similarSectionKey = GlobalKey();
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
  final FocusNode _pincodeFocusNode = FocusNode();

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
        final name = productController.productDetails["name"]?.toString() ?? '';
        final slug =
            productController.productDetails["slug"]?.toString() ?? widget.Slug;
        productController.fetchBreadcrumb(productId,
            fallbackName: name, fallbackSlug: slug);
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
    _pincodeFocusNode.dispose();
    _pageController.dispose();
    _scrollController.dispose();
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

  void _scrollToSimilar() {
    final ctx = _similarSectionKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _showLoading() =>
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);
  void _hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
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
                showAppSnackBar("Please login to view wishlist",
                    type: SnackBarType.error);
                Get.toNamed('/login');
                return;
              }
              Get.to(const WishlistScreen())?.then((_) {
                SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                  statusBarColor: statusBarColor,
                  statusBarIconBrightness: Brightness.dark,
                ));
              });
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
                    _buildBreadcrumb(),
                    _buildImages(),
                    _buildProductInfoAndPrice(),
                    _buildTrustBadges(),
                    _buildDivider(),
                    _buildSizeColorSection(),
                    _buildQuantitySelector(),
                    _buildOfferSection(),
                    _buildDelivery(),
                    _buildActionButtons(),
                    _buildDivider(),
                    _buildSimilarProducts(),
                    _buildProductDetails(),
                    _buildDeliveryPolicies(),
                    _buildDivider(),
                    _buildFAQs(),
                    _buildLFPromises(),
                    _buildTrendingProducts(),
                    // _buildAddReviewButton(),
                    _buildDivider(),
                    _buildReviewSection(),
                    _buildDivider(),
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
}
