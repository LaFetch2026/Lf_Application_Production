// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/cartscreen.dart';

import '../screens/loginscreen.dart';
import 'base_controller.dart';

class ProductController extends BaseController {
  RxBool isProduct = false.obs;
  RxBool isFilter = false.obs;
  RxBool isMostSearch = false.obs;
  RxBool isHomeProduct = false.obs;
  RxBool istags = false.obs;
  RxString errorMsg = "".obs;
  RxBool isCategoryProduct = false.obs;
  RxBool istagsProduct = false.obs;
  RxBool isBannerTag = false.obs;
  RxBool isBrandExpressProduct = false.obs;
  RxBool isExpress = false.obs;
  RxBool isHandPicked = false.obs;
  RxBool isDetails = false.obs;
  RxBool isReview = false.obs;
  RxBool isPincode = false.obs;
  RxBool isReorder = false.obs;
  RxBool showSizeList = true.obs;
  RxBool isBestSeller = false.obs;
  RxBool isFrequentlyBought = false.obs;
  RxInt currentpage = 0.obs;
  RxInt inventoryId = 0.obs;
  RxInt tagId = 0.obs;
  RxInt sizeInventoryId = 0.obs;
  RxInt colorInventoryId = 0.obs;
  RxInt fabricInventoryId = 0.obs;
  Map<String, dynamic> productDetails = {};

  dynamic selectedProductSize = {}.obs;
  dynamic selectedProductColor = {}.obs;
  dynamic brandDetails = "".obs;
  dynamic compositionDetails = "".obs;
  RxString returnPolicyDetails = "".obs;
  RxBool isRecommendations = false.obs;
  List tagsList = [].obs;
  List homeProductList = [].obs;
  List handPickedProductList = [].obs;
  List frequentlyProductList = [].obs;
  List tagProductList = [].obs;
  List productList = [].obs;
  List filterList = [].obs;
  RxString tagname = "We think you might also like".obs;
  List mostSeachList = [].obs;
  List expressProductList = [].obs;
  List productCategoryList = [].obs;
  List productExpressBrandList = [].obs;
  RxInt total = 0.obs;
  RxInt curr = 0.obs;
  RxInt index = 0.obs;
  RxInt current = 50.obs;
  RxInt totalExpress = 0.obs;
  List inventoryList = [].obs;
  RxList<Map<String, dynamic>> sizeInventoryList = <Map<String, dynamic>>[].obs;
  List colorInventoryList = [].obs;
  List fabricInventoryList = [].obs;
  List reviewList = [].obs;
  List recommendedList = [].obs;
  List bestSellerList = [].obs;
  RxInt totalProductValue = 0.obs;
  final pincodeController = TextEditingController();
  RxBool loadMore = false.obs;
  RxBool hasnextpage = true.obs;
  RxBool homeTagsloadMore = false.obs;
  RxBool homeTagshasnextpage = true.obs;
  RxInt homeTagsPage = 1.obs;
  RxInt categoryFilter = 0.obs;
  RxInt categoryProductGender = 0.obs;
  RxBool filterEnable = false.obs;
  RxBool filterExpressEnable = false.obs;
  RxBool filterProductEnable = false.obs;
  RxInt page = 1.obs;
  RxInt lowPrice = 500.obs;
  RxInt highPrice = 500000.obs;
  ScrollController listController = ScrollController();
  ScrollController handpickedController = ScrollController();
  ScrollController brandProductController = ScrollController();
  ScrollController recentListController = ScrollController();
  RxBool expressLoadMore = false.obs;
  RxBool expressHasnextpage = true.obs;
  RxInt expressPage = 1.obs;
  RxBool handpickedLoadMore = false.obs;
  RxBool handpickedHasnextpage = true.obs;
  RxInt handpickedPage = 1.obs;
  ScrollController expressListController = ScrollController();
  ScrollController categoryProductController = ScrollController();
  ScrollController brandDetailsController = ScrollController();
  RxInt brandDetailsId = 0.obs;
  RxString brandDetailsScreen = "".obs;
  RxBool categoryProductLoadMore = false.obs;
  RxBool categoryProductHasnextpage = true.obs;
  RxInt categoryProductPage = 1.obs;
  ScrollController brandExpressProductController = ScrollController();
  RxBool brandExpressLoadMore = false.obs;
  RxBool brandExpressHasnextpage = true.obs;
  RxInt brandExpressPage = 1.obs;
  ScrollController tagsProductController = ScrollController();
  RxBool tagsLoadMore = false.obs;
  RxBool tagsHasnextpage = true.obs;
  RxInt tagsPage = 1.obs;
  ScrollController mostViewController = ScrollController();
  RxBool mostViewLoadMore = false.obs;
  RxBool mostViewHasnextpage = true.obs;
  RxInt mostViewPage = 1.obs;
  ScrollController bannerTagController = ScrollController();
  RxBool bannerTagLoadMore = false.obs;
  RxBool bannerTagHasnextpage = true.obs;
  RxInt bannerTagPage = 1.obs;
  ScrollController frequentlyBoughtController = ScrollController();
  RxBool frequentlyBoughtLoadMore = false.obs;
  RxBool frequentlyBoughtHasnextpage = true.obs;
  RxInt frequentlyBoughtPage = 1.obs;
  ScrollController recommendedController = ScrollController();
  RxBool recommendedLoadMore = false.obs;
  RxBool recommendedHasnextpage = true.obs;
  RxInt recommendedPage = 1.obs;
  ScrollController bestSellerController = ScrollController();
  ScrollController tagsController = ScrollController();
  RxBool bestSellerLoadMore = false.obs;
  RxBool bestSellerHasnextpage = true.obs;
  RxInt bestSellerPage = 1.obs;
  RxBool brandProductLoadMore = false.obs;
  RxBool brandProductHasnextpage = true.obs;
  RxInt brandProductPage = 1.obs;
  List brandProductDetailsList = [].obs;
  RxBool isProductBrand = false.obs;
  RxBool isVideoPlaying = true.obs;
  RxString sortBy = "".obs;
  RxString expressSortBy = "".obs;
  RxString productSortBy = "".obs;
  List brand_ids = [].obs;
  List color_ids = [].obs;
  List size_ids = [].obs;
  List addressList = [].obs;
  List pricelist = [100, 5000].obs;
  RxBool isPrice = true.obs;
  RxInt category_id = 0.obs;
  RxInt totalReview = 0.obs;
  RxInt productImageindex = 0.obs;
  RxInt catalogIndex = 0.obs;
  RxInt brand_id = 0.obs;
  RxBool isEstimateDate = false.obs;
  dynamic getItBy = "".obs;
  RxBool isAddress = false.obs;
  dynamic defaultAddress = "".obs;
  RxBool addToCart = false.obs;
  RxBool isColorimage = false.obs;
  List imageList = [].obs;
  RxBool isExpressDelivery = false.obs;
  RxInt expressValue = 0.obs;
  List productCategory = [].obs;
  List productTags = [].obs;
  List brandProductList = [].obs;
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  RxBool isBrandProduct = false.obs;
  RxBool isBrand = false.obs;
  RxInt id = 0.obs;
  RxInt selectedTabCategory = 0.obs;
  RxBool showAddressList = false.obs;
  RxString addressText = "".obs;
  RxString selectedCategoryGender = "".obs;
  RxString addressTypeValue = "".obs;
  RxString errorSizeMsg = "".obs;
  RxString errorColorMsg = "".obs;
  List<bool> reorderSelected = List.generate(50, (i) => false).obs;
  TextEditingController brandController = TextEditingController();
  TextEditingController branddetailsSearchController = TextEditingController();
  RxInt quickProductPage = 1.obs;
  RxBool quickProductLoadMore = false.obs;
  RxBool quickProductHasnextpage = true.obs;
  ScrollController quickProductListController = ScrollController();
  RxBool isExpressBrand = false.obs;
  List expressBrandList = [].obs;
  RxString locationText = "check".obs;
  RxString enableLocationText = "".obs;
  dynamic brandProductdetails = "".obs;
  RxBool isSubmittingReview = false.obs;
  RxBool isFetchingReviews = false.obs;
  int? productsShuffleSeed;

  RxList<dynamic> lafetchexclusiveList = <dynamic>[].obs;
  RxList<dynamic> premiumList = <dynamic>[].obs;
  RxList<dynamic> luxuriousList = <dynamic>[].obs;
  RxList<dynamic> standardList = <dynamic>[].obs;
  final RxBool isCatProducts = false.obs;
  final RxList<Map<String, dynamic>> catProductList =
      <Map<String, dynamic>>[].obs;
  RxBool isCoupons = false.obs;
  RxList<Map<String, dynamic>> couponList = <Map<String, dynamic>>[].obs;
  RxString serviceabilityMessage = "".obs;
  RxBool isServiceable = false.obs;
  RxString courierName = "".obs;
  RxString estimatedDate = "".obs;
  RxString estimatedDays = "".obs;
  final RxDouble averageRating = 0.0.obs;

  bool checkPinvalidation(String pin) {
    if (pin.isEmpty) {
      getSnackBar(
        "Enter Pincode",
      );
      return false;
    }
    if (pin.length < 6) {
      getSnackBar(
        "The pincode must be 6 digit.",
      );
      return false;
    }
    return true;
  }

  bool checkDetailsValidation() {
    bool isValid = true;

    // Reset previous errors
    errorSizeMsg.value = "";
    errorColorMsg.value = "";

    final hasSizes = sizeInventoryList.isNotEmpty;
    final hasColors = colorInventoryList.isNotEmpty;

    // Check size selection
    if (hasSizes) {
      final selectedSize =
          (selectedProductSize is Map && selectedProductSize.isNotEmpty)
              ? selectedProductSize
              : (selectedProductSize is Rx &&
                      (selectedProductSize as Rx).value is Map)
                  ? (selectedProductSize as Rx).value
                  : null;

      if (selectedSize == null || selectedSize.isEmpty) {
        errorSizeMsg.value = "Please select a size.";
        isValid = false;
      }
    }

    // Check color selection
    if (hasColors) {
      final selectedColor =
          (selectedProductColor is Map && selectedProductColor.isNotEmpty)
              ? selectedProductColor
              : (selectedProductColor is Rx &&
                      (selectedProductColor as Rx).value is Map)
                  ? (selectedProductColor as Rx).value
                  : null;

      if (selectedColor == null || selectedColor.isEmpty) {
        errorColorMsg.value = "Please select a color.";
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> getHomeProduct(int gender) async {
    isHomeProduct.value = true;
    homeProductList.clear();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    // Use laFetch base for this API
    final base = ApiConstants.baseUrl; // << make sure this exists
    final uri = Uri.parse("$base/collection-with-products").replace(
      // Keep this only if backend supports gender filtering here.
      // Remove the queryParameters line if it doesn't.
      queryParameters: {'status': '$gender'},
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        // Expect: { status, message, data: [ { id, name, desc?, products: [] }, ... ] }
        final List<Map<String, dynamic>> data =
            (body is Map && body['data'] is List)
                ? List<Map<String, dynamic>>.from(
                    (body['data'] as List).whereType<Map>())
                : <Map<String, dynamic>>[];

        // Ensure products is always a List for the UI
        for (final c in data) {
          if (c['products'] is! List) c['products'] = <dynamic>[];
        }

        // Update reactive list
        homeProductList.assignAll(data);

        // Optional tagname for your loading stub
        tagname.value =
            data.isNotEmpty ? (data.first['name']?.toString() ?? '') : '';

        // Stable shuffle seed for session (declare: int? productsShuffleSeed; in controller)
        productsShuffleSeed ??= DateTime.now().millisecondsSinceEpoch;

        print("Ã¢Å“â€¦ collections loaded: ${homeProductList.length}");
      } else {
        homeProductList.clear();
        print(
            "Ã¢ÂÅ’ collections load failed: ${response.statusCode} ${response.reasonPhrase}");
        // print(response.body); // uncomment to debug server message
      }
    } on TimeoutException {
      homeProductList.clear();
      print("Ã¢ÂÅ’ Request timed out for $uri");
    } catch (e) {
      homeProductList.clear();
      print("Ã¢ÂÅ’ Error fetching collections: $e");
    } finally {
      isHomeProduct.value = false;
    }
  }

  Future<void> getProductByCatId({
    required int gender,
    required int catId,
  }) async {
    isCatProducts.value = true;
    catProductList.clear();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final base = ApiConstants.baseUrl; // <-- laFetch base
    final baseUri = Uri.parse(base);

    // {base}/products?gender=<g>&catId=<id>
    final uri = baseUri.replace(
      path: baseUri.path.endsWith('/')
          ? '${baseUri.path}products'
          : '${baseUri.path}/products',
      queryParameters: {
        'gender': '$gender',
        'catId': '$catId',
      },
    );

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode != 200) {
        catProductList.clear();
        print(
            '✗ getProductByCatId failed: ${res.statusCode} ${res.reasonPhrase}');
        return;
      }

      dynamic decoded;
      try {
        decoded = json.decode(res.body);
      } catch (e) {
        catProductList.clear();
        print('✗ getProductByCatId JSON decode error: $e');
        return;
      }

      // Expect: { status, message, data: [...] }
      final List<Map<String, dynamic>> items =
          (decoded is Map && decoded['data'] is List)
              ? List<Map<String, dynamic>>.from(
                  (decoded['data'] as List).whereType<Map>())
              : <Map<String, dynamic>>[];

      // Normalize nullable arrays so UI is safe
      for (final m in items) {
        m['imageUrls'] ??= <String>[];
        m['tags'] ??= <dynamic>[];
        m['targetGenders'] ??= <dynamic>[];
        m['fabrics'] ??= <dynamic>[];
        m['colorPatterns'] ??= <dynamic>[];
      }

      catProductList.assignAll(items);
      print('✓ getProductByCatId loaded: ${catProductList.length}');
    } on TimeoutException {
      catProductList.clear();
      print('✗ getProductByCatId timeout: $uri');
    } catch (e) {
      catProductList.clear();
      print('✗ getProductByCatId error: $e');
    } finally {
      isCatProducts.value = false;
    }
  }

  Future<void> getProductById(int id) async {
    isDetails.value = true; // loader on
    try {
      errorMsg.value = "";
      productDetails = <String, dynamic>{};
      imageList.clear();
      sizeInventoryList.clear();
      colorInventoryList.clear();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final base = ApiConstants.baseUrl;
      final uri = Uri.parse('$base/product/$id');

      final resp = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (resp.statusCode == 200) {
        final decoded = json.decode(resp.body);

        if (decoded is! Map || decoded['data'] is! Map) {
          errorMsg.value = 'Unexpected product payload.';
          return;
        }

        final Map<String, dynamic> data =
            Map<String, dynamic>.from(decoded['data'] as Map);

        // ---------- Helpers ----------
        num _num(dynamic v) =>
            (v is num) ? v : num.tryParse(v?.toString() ?? '') ?? 0;
        String _str(dynamic v) => (v ?? '').toString();
        List<String> _strList(dynamic v) => (v is List)
            ? v
                .map((e) => e?.toString() ?? '')
                .where((s) => s.isNotEmpty)
                .toList()
            : const <String>[];

        // ---------- Base price & MRP ----------
        final productLevelPrice = _num(data['price'] ??
            data['msp'] ??
            data['lfMsp'] ??
            data['mrp'] ??
            data['basePrice']);
        final productLevelMrp = _num(data['mrp']);

        // ---------- Variants ----------
        final List<Map<String, dynamic>> variants = (data['variants'] is List)
            ? List<Map<String, dynamic>>.from(
                (data['variants'] as List).whereType<Map>())
            : <Map<String, dynamic>>[];

        // Derive prices
        final variantPrices = variants
            .map((v) => _num(v['price']).toDouble())
            .where((p) => p > 0)
            .toList();
        final variantMrps = variants
            .map((v) => _num(v['compareAtPrice']).toDouble())
            .where((p) => p > 0)
            .toList();

        double displayPrice =
            productLevelPrice > 0 ? productLevelPrice.toDouble() : 0;
        double displayMrp =
            productLevelMrp > 0 ? productLevelMrp.toDouble() : 0;

        if (displayPrice <= 0 && variantPrices.isNotEmpty) {
          displayPrice = variantPrices.first;
        }
        if (displayMrp <= 0 && variantMrps.isNotEmpty) {
          displayMrp = variantMrps.first;
        }

        // ---------- Totals / discount ----------
        final discountPct = (displayMrp > 0 && displayPrice < displayMrp)
            ? '${(((displayMrp - displayPrice) / displayMrp) * 100).toStringAsFixed(0)}%'
            : '0%';

        final rating = _num(data['rating']);
        final hasCOD = data['hasCOD'] == true;
        final hasExchange = data['hasExchange'] == true;
        final exchangeDays = _num(data['exchangeDays']).toInt();

        // ---------- Product Details ----------
        productDetails = {
          'id': data['id'],
          'type': _str(data['type']),
          'title': _str(data['title']),
          'description': _str(data['description']),
          'tags': _strList(data['tags']),
          'imageUrls': _strList(data['imageUrls']),
          'brand': data['brand'],
          'hasExchange': hasExchange,
          'exchangeDays': exchangeDays,
          'hasCOD': hasCOD,
          'brand_name':
              (data['brand'] is Map ? _str(data['brand']['name']) : ''),
          'name': _str(data['name'] ?? data['title']),
          'price': displayPrice,
          'mrp': displayMrp,
          'discount_percentage': discountPct,
          'aggregated_rating': rating,
          'has_cod': hasCOD,
          'has_exchange': hasExchange,
          'exchange_days': exchangeDays,
          'total_stock_count': variants.length,
          'cart_inventory_ids': <int>[],
          'share_link': '',
        };

        // ---------- Gallery ----------
        final imgs = _strList(data['imageUrls']);
        imageList.assignAll(imgs.map((u) => {'name': u}).toList());

        // ---------- Sizes ----------
        sizeInventoryList.assignAll(
          variants.map((v) {
            final vPrice = _num(v['price']).toDouble();
            final vMrp = _num(v['compareAtPrice']).toDouble();

            // extract size name
            String sizeLabel = '';
            if (v['selectedOptions'] is List) {
              for (final opt in v['selectedOptions']) {
                if (opt is Map &&
                    opt['name'].toString().toLowerCase() == 'size') {
                  sizeLabel = opt['value']?.toString() ?? '';
                  break;
                }
              }
            }

            // ✅ pick availableStock from nested inventory object
            final inventory = v['inventory'] is Map
                ? Map<String, dynamic>.from(v['inventory'])
                : <String, dynamic>{};
            final availableStock =
                _num(inventory['availableStock']).toInt(); // real stock

            return {
              'id': v['id'] ?? v['shopifyVariantId'] ?? 0,
              'product_matrix_size_name': sizeLabel,
              'stocks': availableStock, // ✅ REAL STOCK VALUE
              'price': vPrice,
              'compareAtPrice': vMrp,
              'product_matrix_available_colors': <Map<String, dynamic>>[],
              'selectedOptions': v['selectedOptions'] ?? [],
            };
          }).toList(),
        );

        // Debug print
        print("==== Variant Stock Summary ====");
        for (final v in sizeInventoryList) {
          print("${v['product_matrix_size_name']} => stocks: ${v['stocks']}");
        }

        // ---------- Default size selection ----------
        if (sizeInventoryId.value == 0 && sizeInventoryList.isNotEmpty) {
          final firstInStock = sizeInventoryList.firstWhere(
            (e) => (_num(e['stocks']) > 0),
            orElse: () => sizeInventoryList.first,
          );

          sizeInventoryId.value =
              int.tryParse(firstInStock['id']?.toString() ?? '0') ?? 0;
          try {
            (selectedProductSize as dynamic).value = firstInStock;
          } catch (_) {
            selectedProductSize = firstInStock;
          }
        }

        colorInventoryList.clear();
      } else if (resp.statusCode == 404) {
        errorMsg.value = 'Product not found.';
      } else if (resp.statusCode == 401) {
        errorMsg.value = 'Session expired. Please login again.';
      } else {
        try {
          final err = json.decode(resp.body);
          errorMsg.value = (err is Map && err['message'] != null)
              ? err['message'].toString()
              : 'Failed: ${resp.statusCode}';
        } catch (_) {
          errorMsg.value = 'Failed to load product. (${resp.statusCode})';
        }
      }
    } catch (e) {
      errorMsg.value = 'Error fetching product: $e';
    } finally {
      isDetails.value = false; // loader off
      update(); // refresh UI
    }
  }

  Future<void> getProductData(int gender) async {
    isProduct.value = true;
    final prefs = await SharedPreferences.getInstance();

    productList.clear(); // Ã¢Å“â€¦ Clear previous products

    final List<String> section = [
      'lafetch-exclusive',
      'premium',
      'luxurious',
      'standard',
    ];

    try {
      for (String collectionType in section) {
        final response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products?gender=$gender&collectionType=$collectionType?status=1"),
          headers: {
            'Accept': 'application/json; charset=UTF-8',
            'Authorization': "Bearer ${prefs.getString('token') ?? ''}",
          },
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData["data"] != null) {
            productList.addAll(responseData["data"]);
          }
        } else if (response.statusCode == 500) {
          getSnackBar("Server error, please try again");
        } else if (response.statusCode == 401) {
          Get.offAll(() => const LoginScreen(initialTab: 0));
          getSnackBar("Authentication failed");
          break;
        } else {
          getSnackBar("Failed to load products for $collectionType");
        }
      }

      hasnextpage.value = true;
      loadMore.value = false;
      page.value = 1;
    } catch (e) {
      print("Error fetching products: $e");
      getSnackBar("Something went wrong.");
    } finally {
      isProduct.value = false;
    }
  }

  getFilterData(String type) async {
    isFilter.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products-filter-paramters?type=$type"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          filterList = responseData;
        }
      } else if (response.statusCode == 500) {
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get filter failed");
      }
    } catch (e) {
      print("error$e");
    }
    isFilter.value = false;
  }

  getEstimateDate(int id, String zip) async {
    isEstimateDate.value = true;
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products/$id/estimated-delivery?zip=$zip"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        getItBy = responseData;
      } else if (response.statusCode == 400) {
        if (responseData["errors"]["zip"].isNotEmpty) {
          getSnackBar("Invalid Pincode");
        }
      } else if (response.statusCode == 500) {
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get estimate delivery failed");
      }
    } catch (e) {
      print("error$e");
    }
    isEstimateDate.value = false;
    isDetails.value = false;
  }

  callAddtoCart(int quantity, String type, Color background, int productId,
      bool showloader) async {
    if (showloader) {
      showLoading();
    }
    isReorder.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "quantity": quantity,
        "inventory_id": sizeInventoryId.value,
        "express_delivery": expressValue.value,
      };
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/orders"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                'Content-Type': 'application/json;charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              },
              body: json.encode(sendData));
      if (response.statusCode == 200) {
        addToCart.value = true;
        errorColorMsg.value = "";
        errorSizeMsg.value = "";
        if (type == "reorder") {
          Get.to(CartScreen());
          reorderSelected.clear();
          reorderSelected = List.generate(50, (i) => false).obs;
        }
        /*  else {
          getSnackBar("Product added to cart");
        } */
        if (type == "buy now") {
          Get.to(CartScreen(
            backgroundcolor: background,
          ))?.then(
            (value) {
              addToCart.value = false;
            },
          );
        }
      } else if (response.statusCode == 201) {
      } else if (response.statusCode == 400) {
        var responseData = json.decode(response.body);
        errorMsg.value = responseData["message"];
      } else if (response.statusCode == 500) {
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
    isReorder.value = false;
  }

  callAddProductToWishlist(
      int wishlistId,
      String type,
      int id,
      int categoryId,
      int brandId,
      List list,
      List categoryList,
      int existId,
      int genderType,
      int catalogId) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/products/$id/wishlist/$wishlistId"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("abc$type");
        if (responseData["wishlisted"]) {
          Get.close(1);
          // getSnackBar("product added to the wishlist");
        } else {
          //  getSnackBar("product removed from the wishlist");
        }
        if (type == "product") {
          final prefs = await SharedPreferences.getInstance();
          int gender = prefs.getInt("gender") ?? 3;
          getProductData(gender);
        } else if (type == "category") {
          /*  getProductByCategoryData(categoryId, brandId, "", [], sortBy.value,
              genderType, filterEnable.value, catalogId, false, "catalog"); */
        } else if (type == "handpicked") {
          /* categoryFilter.value = genderType;
          getHandPickedProduct(
              productSortBy.value, filterProductEnable.value, false); */
        } else if (type == "category product") {
          /*   getProductByCategoryData(categoryId, brandId, "", [], sortBy.value,
              genderType, filterEnable.value, catalogId, false, ""); */
        } else if (type == "tags") {
          // getBestSellerProductData(brandId);
        } else if (type == "brand") {
          /*  getBrandExpressProductData(
              brandId, expressSortBy.value, filterExpressEnable.value); */
        } else if (type == "bannerTag") {
          /*  getTagsBannerData(list, categoryList, genderType, sortBy.value,
              filterEnable.value, false); */
        } else if (type == "frequently") {
          // getProductRecommendations(existId);
        } else if (type == "seller") {
        } else {
          // getProductRecommendations(existId);
        }
      } else if (response.statusCode == 500) {
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("item add failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  callSaveAddress(
      String screenType,
      int addressId,
      String name,
      String phone,
      String city,
      String type,
      String address,
      String zip,
      String locality,
      String state,
      double lat,
      double lng,
      BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "name": name,
        "phone": phone,
        "city": city,
        "type": type,
        "address": address,
        "zip": zip,
        "locality": locality,
        "state": state,
        "default_shipping": 1,
        "latitude": lat,
        "longitude": lng
      };
      var response = await http.post(
          Uri.parse("${ApiConstants.baseUrl}/addresses/$addressId"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
          body: json.encode(sendData));
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        if (screenType == "change address") {
          Get.back();
          /* getBrandExpressProductData(
              brand_id.value, expressSortBy.value, filterExpressEnable.value); */

          FocusScope.of(context).unfocus();
        }
        if (screenType == "express") {
          // getBrandExpressProductData(
          //     brand_id.value, expressSortBy.value, filterExpressEnable.value);
        }
        if (screenType == "") {
          Get.back();
        }
      } else if (response.statusCode == 201) {
        print(responseData);
        if (screenType == "change address") {
          Get.back();
          // getBrandExpressProductData(
          //     brand_id.value, expressSortBy.value, filterExpressEnable.value);
        }
        if (screenType == "express") {
          // getBrandExpressProductData(
          //     brand_id.value, expressSortBy.value, filterExpressEnable.value);
        }
        if (screenType == "") {
          Get.back();
        }
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
      } else if (response.statusCode == 401) {
        // getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> submitProductReview({
    required int userId,
    required int orderItemId,
    required int variantId,
    required int rating,
    required String comment,
  }) async {
    isSubmittingReview.value = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      getSnackBar("Please login to submit a review");
      isSubmittingReview.value = false;
      return false;
    }

    try {
      final Map<String, dynamic> sendData = {
        "userId": userId,
        "orderItemId": orderItemId,
        "variantId": variantId,
        "rating": rating,
        "comment": comment,
      };

      final response = await http
          .post(
            Uri.parse("${ApiConstants.baseUrl}/review"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              'Content-Type': 'application/json;charset=UTF-8',
              "Authorization": "Bearer $token",
            },
            body: json.encode(sendData),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print("✓ Review submitted successfully: $responseData");
        getSnackBar(responseData["message"] ?? "Review submitted successfully");

        // Optionally refresh product reviews
        final variant = responseData["data"]?["product_variant"];
        if (variant != null && variant["productId"] != null) {
          await getProductReviews(variant["productId"]);
        }

        return true;
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        final errorMessage = responseData["message"] ?? "Invalid review data";
        getSnackBar(errorMessage);
        print("✗ Review submission failed: $errorMessage");
        return false;
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
        return false;
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again later");
        return false;
      } else {
        getSnackBar("Failed to submit review (${response.statusCode})");
        print("✗ Review submission failed: ${response.statusCode}");
        return false;
      }
    } on TimeoutException {
      getSnackBar("Request timeout. Please try again.");
      print("✗ Review submission timeout");
      return false;
    } catch (e, s) {
      getSnackBar("Error submitting review");
      print("✗ Error submitting review: $e\n$s");
      return false;
    } finally {
      isSubmittingReview.value = false;
    }
  }

  Future<void> getProductReviews(
    int productId, {
    int page = 1,
    int limit = 10,
  }) async {
    isFetchingReviews.value = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final queryParams = {
        'productId': productId.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse("${ApiConstants.baseUrl}/reviews")
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': "Bearer $token",
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is! Map || responseData['data'] == null) {
          reviewList.clear();
          totalReview.value = 0;
          averageRating.value = 0.0;
          print("✓ No reviews found for product $productId");
          return;
        }

        final List<dynamic> reviews = responseData['data'] as List<dynamic>;

        // ✅ Update review list
        reviewList.assignAll(reviews);
        totalReview.value = reviews.length;

        // ✅ Calculate average rating
        if (reviews.isNotEmpty) {
          final totalRating = reviews.fold<double>(
            0.0,
            (sum, review) =>
                sum + ((review['rating'] as num?)?.toDouble() ?? 0.0),
          );
          averageRating.value = totalRating / reviews.length;
        } else {
          averageRating.value = 0.0;
        }

        print(
            "✓ Reviews loaded: ${reviews.length} | Avg Rating: ${averageRating.value.toStringAsFixed(1)}");
      } else if (response.statusCode == 404) {
        reviewList.clear();
        totalReview.value = 0;
        averageRating.value = 0.0;
        print("✓ No reviews found (404) for product $productId");
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Session expired. Please log in again.");
      } else if (response.statusCode >= 500) {
        getSnackBar("Server error. Please try again later.");
        print("✗ Server error fetching reviews: ${response.statusCode}");
      } else {
        getSnackBar("Failed to load reviews (${response.statusCode})");
        print("✗ Unexpected response: ${response.statusCode}");
      }
    } on TimeoutException {
      getSnackBar("Request timed out. Please try again.");
      print("✗ Reviews fetch timeout");
    } catch (e, s) {
      print("✗ Error fetching reviews: $e\n$s");
      getSnackBar("Error loading reviews");
    } finally {
      isFetchingReviews.value = false;
    }
  }

  Future<void> loadMoreReviews(int productId, int currentPage) async {
    if (isFetchingReviews.value) return;

    final nextPage = currentPage + 1;

    isFetchingReviews.value = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final queryParams = {
        'productId': productId.toString(),
        'page': nextPage.toString(),
        'limit': '10',
      };

      final uri = Uri.parse("${ApiConstants.baseUrl}/reviews")
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': "Bearer $token",
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData != null) {
          List newReviews = [];

          if (responseData is Map) {
            if (responseData["data"] != null) {
              newReviews = responseData["data"];
            } else if (responseData["reviews"] != null) {
              newReviews = responseData["reviews"];
            }
          } else if (responseData is List) {
            newReviews = responseData;
          }

          if (newReviews.isNotEmpty) {
            reviewList.addAll(newReviews);
            print("✓ Loaded ${newReviews.length} more reviews");
          } else {
            print("✓ No more reviews to load");
          }
        }
      }
    } on TimeoutException {
      print("✗ Load more reviews timeout");
    } catch (e) {
      print("✗ Error loading more reviews: $e");
    } finally {
      isFetchingReviews.value = false;
    }
  }

  /// ✅ Fetch available coupons from API
  Future<void> getCoupons() async {
    isCoupons.value = true;
    couponList.clear();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse("${ApiConstants.baseUrl}/coupons");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      print("Response: ${response.statusCode} => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);

        if (decoded is Map && decoded['data'] is List) {
          final List<Map<String, dynamic>> data =
              List<Map<String, dynamic>>.from(decoded['data']);
          couponList.assignAll(data);
          print("✓ Coupons loaded: ${couponList.length}");
        } else {
          print("✗ Unexpected response: ${response.body}");
          getSnackBar("Unexpected response from coupons API");
        }
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      } else if (response.statusCode == 404) {
        couponList.clear();
        getSnackBar("No coupons available");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error while fetching coupons");
      } else {
        getSnackBar("Unexpected error: ${response.statusCode}");
      }
    } on TimeoutException {
      getSnackBar("Request timed out while fetching coupons");
    } catch (e, stacktrace) {
      print("✗ Error fetching coupons: $e\n$stacktrace");
      getSnackBar("Error loading coupons");
    } finally {
      isCoupons.value = false;
    }
  }

  Future<Map?> checkServiceability({
    required int variantId,
    required String deliveryPostalCode,
  }) async {
    isEstimateDate.value = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final uri = Uri.parse("${ApiConstants.baseUrl}/check-serviceability");

    try {
      final body = {
        "variantId": variantId,
        "deliveryPostalCode": deliveryPostalCode,
      };

      final response = await http
          .post(
            uri,
            headers: {
              'Accept': 'application/json; charset=UTF-8',
              'Content-Type': 'application/json; charset=UTF-8',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 20));

      print("🔹 Response Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data['data'] != null && data['data'] is Map) {
          final delivery = data['data'];
          final date = delivery['estimatedDate']?.toString() ?? "";
          final days = delivery['estimatedDays']?.toString() ?? "";

          estimatedDate.value = date;
          estimatedDays.value = days;
          isServiceable.value = true;

          // ✅ Only show delivery info
          serviceabilityMessage.value = "Delivery by $date ($days Days)";

          print("✅ Showing: ${serviceabilityMessage.value}");
          return data;
        } else {
          isServiceable.value = false;
          serviceabilityMessage.value =
              "Service not available for this pincode";
        }
      } else {
        isServiceable.value = false;
        serviceabilityMessage.value = "Failed to check serviceability";
      }
    } catch (e) {
      print("💥 checkServiceability error: $e");
      isServiceable.value = false;
      serviceabilityMessage.value = "Error checking serviceability";
    } finally {
      isEstimateDate.value = false;
    }

    return null;
  }
}
