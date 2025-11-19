import 'dart:async';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

class ShareLinkGenerator {
  static final AppsflyerSdk _af = AppsflyerSdk(null);

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
        "deep_link_value": "product_details"
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
