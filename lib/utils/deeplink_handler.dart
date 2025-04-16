import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';

class DeepLinkHandler {
  static final AppsflyerSdk _appsflyerSdk = AppsflyerSdk(
    AppsFlyerOptions(
      afDevKey: 'tzivSReYr7ZyuqVbEP6z6d',
      appId: '915626513880487', // iOS App ID (no `id`)
      showDebug: true,
    ),
  );

  static Future<void> init(BuildContext context) async {
    _appsflyerSdk.onAppOpenAttribution((res) {
      print('[AppsFlyer] onAppOpenAttribution: $res');
      _handleDeepLink(res, context);
    });

    _appsflyerSdk.onInstallConversionData((res) {
      print('[AppsFlyer] onInstallConversionData: $res');
      _handleDeepLink(res, context);
    });

    await _appsflyerSdk.initSdk();
  }

  static void _handleDeepLink(
      Map<dynamic, dynamic> data, BuildContext context) {
    final afDP = data['af_dp']; // e.g., myapp://product/slug
    if (afDP != null) {
      final uri = Uri.parse(afDP.toString());
      if (uri.pathSegments.isNotEmpty) {
        final slug = uri.pathSegments.last;
        if (uri.path.contains("product")) {
          Get.to(() => ProductDetailsScreen(
                productId: 0,
                type: "add",
                brandName: "",
                Slug: slug,
              ));
        } else {
          Get.to(() => AllBrandScreen(
                screen: "home",
                id: 0,
                slug: slug,
              ));
        }
      }
    }
  }
}
