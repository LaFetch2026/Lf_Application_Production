import 'dart:async';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

class ShareLinkGenerator {
  static late final AppsflyerSdk _af;

  static Future<void> init() async {
    final AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey: "tzivSReYr7ZyuqVbEP6z6d",
      appId: "6739497338",
      showDebug: true,
      timeToWaitForATTUserAuthorization: 15,
    );

    _af = AppsflyerSdk(options);
    await _af.initSdk();
  }

  static Future<String> generateProductShareLink({
    required int productId,
    required String slug,
    required String brandName,
    required String type,
  }) async {
    Completer<String> completer = Completer<String>();

    final params = AppsFlyerInviteLinkParams(
      campaign: "product_share",
      channel: "app_share",
      referrerName: "lafetch_user",
      baseDeepLink: "lafetch://product/$productId",
      customParams: {
        "product_id": productId.toString(),
        "slug": slug,
        "brand_name": brandName,
        "type": type,
        "deep_link_value": "product_details",
      },
    );

    _af.generateInviteLink(
      params,
      (result) {
        try {
          final url = result["payload"]["userInviteURL"]?.toString() ?? "";
          completer.complete(url);
        } catch (e) {
          completer.completeError("Invalid success response");
        }
      },
      (error) {
        completer.completeError("AppsFlyer Link Error: $error");
      },
    );

    return completer.future;
  }
}
