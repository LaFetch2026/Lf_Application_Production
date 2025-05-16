import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../feature/brand/allbrandscreen.dart';
import '../../feature/misc/quickscreen.dart';
import '../../feature/misc/welcomescreen.dart';
import '../../feature/product/productdetailsscreen.dart';



class DeepLinkHandler {
  static final AppsflyerSdk _appsflyerSdk = AppsflyerSdk(
    AppsFlyerOptions(
      afDevKey: 'tzivSReYr7ZyuqVbEP6z6d',
      appId: _getAppId(), // Dynamically fetch the appId
      showDebug: true,
      timeToWaitForATTUserAuthorization: 15,
    ),
  );

  static bool _isInitialized = false;
  static bool deepLinkHandled = false;

  // Function to dynamically return the correct appId based on platform
  static String _getAppId() {
    if (Platform.isIOS) {
      return '6739497338'; // Replace with your actual iOS App Store ID
    } else if (Platform.isAndroid) {
      return 'com.lafetch.customer'; // Replace with your actual Android package name
    } else {
      throw Exception('Unsupported platform');
    }
  }

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
      final target = payload['target_screen']?.toString() ?? '';

      print('[DeepLinkHandler] Handling deep link payload: $payload');
      deepLinkHandled = true;

      switch (target) {
        case 'product_details':
          final productId =
          int.tryParse(payload['product_id']?.toString() ?? '0');
          final type = payload['type']?.toString() ?? '';
          final brandName = payload['brand_name']?.toString() ?? '';
          final slug = payload['slug']?.toString() ?? '';
          final expressHour = payload['expresshour']?.toString() ?? '0';
          final expressValue =
          int.tryParse(payload['expressValue']?.toString() ?? '0');
          final wishlistProductId =
          int.tryParse(payload['wishlistProductId']?.toString() ?? '0');
          final boardId = int.tryParse(payload['boardId']?.toString() ?? '0');

          if (productId != null && productId > 0 && type.isNotEmpty) {
            Get.offAll(() => ProductDetailsScreen(
              productId: productId,
              type: type,
              brandName: brandName,
            ));
          } else {
            throw 'Invalid or missing product details';
          }
          break;

        case 'brand_page':
          final brandId = int.tryParse(payload['brand_id']?.toString() ?? '0');
          final brandSlug = payload['brand_slug']?.toString() ?? '';
          final screen = payload['screen']?.toString() ?? '';

          if (brandId != null && brandId > 0 && brandSlug.isNotEmpty) {
            Get.offAll(() => AllBrandScreen(
              id: brandId,
              slug: brandSlug,
              screen: screen,
            ));
          } else {
            throw 'Invalid or missing brand data';
          }
          break;

        case 'quick_screen':
          Get.offAll(() => const QuickScreen());
          break;
      }
    } catch (e, stacktrace) {
      print('[DeepLinkHandler] Error: $e');
      print('[DeepLinkHandler] Stacktrace: $stacktrace');
      Get.offAll(() => WelcomeScreen()); // fallback to Home on error
    }
  }
}
