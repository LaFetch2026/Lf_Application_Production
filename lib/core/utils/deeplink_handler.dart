import 'dart:io';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';

import '../../screens/welcomescreen.dart';

class DeepLinkHandler {
  static final AppsflyerSdk _appsflyerSdk = AppsflyerSdk(
    AppsFlyerOptions(
      afDevKey: 'tzivSReYr7ZyuqVbEP6z6d',
      appId: Platform.isIOS ? '6739497338' : 'com.lafetch.customer',
      showDebug: true,
      timeToWaitForATTUserAuthorization: 15,
    ),
  );

  static bool _initialized = false;

  static Future<void> init(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;

    await _appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
    );

    _listen(context);
  }

  static void _listen(BuildContext context) {
    _appsflyerSdk.onDeepLinking((DeepLinkResult result) {
      final data = result.deepLink?.clickEvent ?? {};
      _handleDeepLinkData(data, context);
    });

    _appsflyerSdk.onAppOpenAttribution((data) {
      _handleDeepLinkData(data, context);
    });

    _appsflyerSdk.onInstallConversionData((data) {
      _handleDeepLinkData(data, context);
    });
  }

  static void _handleDeepLinkData(Map data, BuildContext context) {
    try {
      final target = data["target_screen"]?.toString() ?? "";
      final productId = int.tryParse(data["product_id"]?.toString() ?? "0");

      print("🔥 Deep Link Data: $data");

      if (target == "product_details" && productId != null && productId > 0) {
        // redirect to product page
        Get.offAll(() => ProductDetailsScreen(
              productId: productId,
              type: data["type"]?.toString() ?? "",
              brandName: data["brand_name"]?.toString() ?? "",
              Slug: data["slug"]?.toString() ?? "",
            ));
        return;
      }

      // Default fallback → Home screen
      Get.offAll(() => WelcomeScreen());
    } catch (e) {
      print("❌ Deep Link Handling Error: $e");
    }
  }
}
