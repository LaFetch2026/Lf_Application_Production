import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';

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

  static Future<void> init(BuildContext context) async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Set up deep link listeners
    _setupDeepLinkListeners(context);

    // Initialize SDK
    await _appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
    );
  }

  static void _setupDeepLinkListeners(BuildContext context) {
    // For cold starts (app was terminated)
    _appsflyerSdk.onAppOpenAttribution((res) {
      print('[AppsFlyer] onAppOpenAttribution: $res');
      _handleDeepLink(res, context);
    });

    // For deferred deep linking (app not installed)
    _appsflyerSdk.onInstallConversionData((res) {
      print('[AppsFlyer] onInstallConversionData: $res');
      _handleDeepLink(res, context);
    });

    // For deep links when app is in background (UPDATED METHOD NAME)
    _appsflyerSdk.onDeepLinking((DeepLinkResult deepLinkResult) {
      print('[AppsFlyer] onDeepLinking: $deepLinkResult');
      if (deepLinkResult.status == Status.FOUND) {
        _handleDeepLink(deepLinkResult.deepLink?.clickEvent ?? {}, context);
      }
    });
  }

  static void _handleDeepLink(Map<dynamic, dynamic> data, BuildContext context) {
    try {
      final afDP = data['af_dp'] ?? data['deep_link_value'];
      print('Handling deep link: $afDP');

      if (afDP != null) {
        final uri = Uri.parse(afDP.toString());
        
        if (uri.pathSegments.isNotEmpty) {
          final slug = uri.pathSegments.last;
          
          if (uri.path.contains("product")) {
            Get.offAll(() => ProductDetailsScreen(
                  productId: 0,
                  type: "add",
                  brandName: "",
                  Slug: slug,
                ));
          } 
          else if (uri.path.contains("brand")) {
            Get.offAll(() => AllBrandScreen(
                  screen: "home",
                  id: 0,
                  slug: slug,
                ));
          }
        }
      }
    } catch (e) {
      print('Error handling deep link: $e');
    }
  }
}