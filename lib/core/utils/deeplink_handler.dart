import 'dart:io';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';


class DeepLinkHandler {
  static AppsflyerSdk? _appsflyerSdk;
  static bool _initialized = false;
  static bool _listenersRegistered = false;

  static Future<void> init() async {
    // Skip if already initialized (prevents duplicate listeners on hot restart)
    if (_initialized && _appsflyerSdk != null) {
      print("🔗 DeepLinkHandler already initialized, skipping...");
      return;
    }

    _appsflyerSdk = AppsflyerSdk(
      AppsFlyerOptions(
        afDevKey: 'tzivSReYr7ZyuqVbEP6z6d',
        appId: Platform.isIOS ? '6739497338' : 'com.lafetch.customer',
        showDebug: true,
        timeToWaitForATTUserAuthorization: 15,
      ),
    );

    _initialized = true;

    await _appsflyerSdk!.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
    );

    if (!_listenersRegistered) {
      _listenersRegistered = true;
      _listen();
    }
  }

  static void _listen() {
    final sdk = _appsflyerSdk;
    if (sdk == null) return;

    sdk.onDeepLinking((DeepLinkResult result) {
      print("🔗 onDeepLinking triggered");
      print("🔗 DeepLink status: ${result.status}");
      print("🔗 DeepLink error: ${result.error}");

      final deepLink = result.deepLink;
      if (deepLink != null) {
        print("🔗 DeepLink clickEvent: ${deepLink.clickEvent}");
        print("🔗 DeepLink deepLinkValue: ${deepLink.deepLinkValue}");

        // Try to get parameters directly from deepLink
        final productId = deepLink.getStringValue("product_id");
        final slug = deepLink.getStringValue("slug");
        final brandName = deepLink.getStringValue("brand_name");
        final type = deepLink.getStringValue("type");
        final deepLinkValue = deepLink.deepLinkValue ?? deepLink.getStringValue("deep_link_value");

        print("🔗 Extracted: productId=$productId, slug=$slug, deepLinkValue=$deepLinkValue");

        _handleDeepLinkDataFromOneLink(
          productId: productId,
          slug: slug,
          brandName: brandName,
          type: type,
          deepLinkValue: deepLinkValue,
        );
      } else {
        print("🔗 DeepLink is null, using clickEvent fallback");
        _handleDeepLinkData(result.deepLink?.clickEvent ?? {});
      }
    });

    sdk.onAppOpenAttribution((data) {
      print("📱 onAppOpenAttribution: $data");
      _handleDeepLinkData(data);
    });

    sdk.onInstallConversionData((data) {
      print("📲 onInstallConversionData: $data");
      // Don't process install conversion data - it's for analytics only
      print("📲 Skipping navigation for install conversion data");
    });
  }

  static void _handleDeepLinkDataFromOneLink({
    String? productId,
    String? slug,
    String? brandName,
    String? type,
    String? deepLinkValue,
  }) {
    try {
      final parsedProductId = int.tryParse(productId ?? "0");

      print("🎯 Parsed productId: $parsedProductId, deepLinkValue: $deepLinkValue");

      if (parsedProductId != null && parsedProductId > 0) {
        print("✅ Navigating to ProductDetailsScreen with productId: $parsedProductId");
        // Check if already on ProductDetailsScreen - replace it
        if (Get.currentRoute == '/ProductDetailsScreen') {
          Get.off(() => ProductDetailsScreen(
                productId: parsedProductId,
                type: type ?? "",
                brandName: brandName ?? "",
                Slug: slug ?? "",
              ));
        } else {
          Get.to(() => ProductDetailsScreen(
                productId: parsedProductId,
                type: type ?? "",
                brandName: brandName ?? "",
                Slug: slug ?? "",
              ));
        }
        return;
      }

      print("⚠️ No valid productId, going to BottomNavScreen");
      Get.offAll(() => const BottomNavScreen());
    } catch (e) {
      print("❌ Deep Link Handling Error: $e");
      Get.offAll(() => const BottomNavScreen());
    }
  }

  static void _handleDeepLinkData(Map data) {
    try {
      // Extract payload if nested (AppsFlyer wraps data in payload)
      final Map payload = data["payload"] is Map ? data["payload"] : data;

      // Check both target_screen and deep_link_value for compatibility
      final target = payload["target_screen"]?.toString() ?? "";
      final deepLinkValue = payload["deep_link_value"]?.toString() ?? "";
      final productId = int.tryParse(payload["product_id"]?.toString() ?? "0");
      final slug = payload["slug"]?.toString() ?? "";
      final brandName = payload["brand_name"]?.toString() ?? "";
      final type = payload["type"]?.toString() ?? "";

      print("🔥 Deep Link Data: $data");
      print("📦 Payload: $payload");
      print("🎯 Target: $target, DeepLinkValue: $deepLinkValue, ProductId: $productId");

      // Navigate to product details if product_id is valid
      // Check both target_screen and deep_link_value for the trigger
      final isProductLink = target == "product_details" ||
          deepLinkValue == "product_details" ||
          (productId != null && productId > 0);

      if (isProductLink && productId != null && productId > 0) {
        // Navigate directly to product screen first
        print("✅ Navigating to ProductDetailsScreen with productId: $productId");
        Get.to(() => ProductDetailsScreen(
              productId: productId,
              type: type,
              brandName: brandName,
              Slug: slug,
            ));
        return;
      }

      // Default fallback → Home screen
      Get.offAll(() => const BottomNavScreen());
    } catch (e) {
      print("❌ Deep Link Handling Error: $e");
    }
  }
}
