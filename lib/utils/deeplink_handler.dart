import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/loginscreen.dart';

import '../screens/Brands/allbrandscreen.dart';
import '../screens/catalog/productlist/productdetailsscreen.dart';

class DeepLinkHandler {
  static final AppsflyerSdk _appsflyerSdk = AppsflyerSdk(
    AppsFlyerOptions(
      afDevKey: 'tzivSReYr7ZyuqVbEP6z6d',
      appId: '915626513880487',
      showDebug: true,
      timeToWaitForATTUserAuthorization: 15,
    ),
  );

  static bool _isInitialized = false;
  static bool deepLinkHandled = false;

  static Future<void> init(BuildContext context) async {
    if (_isInitialized) return;
    _isInitialized = true;

    await _appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
    );

    _setupDeepLinkListeners(context);
  }

  static void _setupDeepLinkListeners(BuildContext context) {
    _appsflyerSdk.onAppOpenAttribution((res) {
      print('[AppsFlyer] onAppOpenAttribution: $res');
      if (_isValidDeepLink(res)) _handleDeepLink(res, context);
    });

    _appsflyerSdk.onInstallConversionData((res) {
      print('[AppsFlyer] onInstallConversionData: $res');
      if (_isValidDeepLink(res)) _handleDeepLink(res, context);
    });

    _appsflyerSdk.onDeepLinking((DeepLinkResult result) {
      print('[AppsFlyer] onDeepLinking: $result');
      final data = result.deepLink?.clickEvent ?? {};
      if (result.status == Status.FOUND && _isValidDeepLink(data)) {
        _handleDeepLink(data, context);
      }
    });
  }

  static bool _isValidDeepLink(Map<dynamic, dynamic> data) {
    print('[DeepLinkHandler] Full Data: $data');

    final payload =
        data['payload'] ?? data; // handle AppsFlyer's nested structure
    final deepLinkValue = payload['deep_link_value'];
    final slug = payload['slug'];
    final brand = payload['brand'];

    return (deepLinkValue != null && deepLinkValue.toString().isNotEmpty) ||
        (slug != null && slug.toString().isNotEmpty) ||
        (brand != null && brand.toString().isNotEmpty);
  }

  static void _handleDeepLink(
      Map<dynamic, dynamic> data, BuildContext context) {
    try {
      final payload = data['payload'] ?? data;

      print('[DeepLinkHandler] Handling deep link payload: $payload');

      final productId = int.tryParse(payload['product_id']?.toString() ?? '0');
      final type = payload['type']?.toString() ?? '';
      final brandName = payload['brand_name']?.toString() ?? '';
      final slug = payload['slug']?.toString() ?? '';
      final expressHour = payload['expresshour']?.toString() ?? '0';
      final expressValue =
          int.tryParse(payload['expressValue']?.toString() ?? '0');
      final wishlistProductId =
          int.tryParse(payload['wishlistProductId']?.toString() ?? '0');
      final boardId = int.tryParse(payload['boardId']?.toString() ?? '0');

      final brandId = int.tryParse(payload['brand_id']?.toString() ?? '0');
      final brandSlug = payload['brand_slug']?.toString() ?? '';
      final screen = payload['screen']?.toString() ?? '';

      if (productId != null && productId > 0 && type.isNotEmpty) {
        deepLinkHandled = true;
        Get.offAll(() => ProductDetailsScreen(
              productId: productId,
              type: type,
              brandName: brandName,
              Slug: slug,
              expresshour: expressHour,
              expressValue: expressValue ?? 0,
              wishlistProductId: wishlistProductId ?? 0,
              boardId: boardId ?? 0,
            ));
      } else if (brandId != null && brandId > 0 && brandSlug.isNotEmpty) {
        deepLinkHandled = true;
        Get.offAll(() => AllBrandScreen(
              id: brandId,
              slug: brandSlug,
              screen: screen,
            ));
      } else {
        print('[DeepLinkHandler] No target screen found. Navigating to Login.');
        Get.offAll(() => LoginScreen(initialTab: 0));
      }
    } catch (e) {
      print('Error handling deep link: $e');
    }
  }
}
