import 'package:appsflyer_sdk/appsflyer_sdk.dart';

class ShareLinkGenerator {
  static Future<String> createProductShareLink({
    required int productId,
    required String productName,
    required String type,
    String brandName = "",
  }) async {
    try {
      final sdk = AppsflyerSdk(
        AppsFlyerOptions(
          afDevKey: 'tzivSReYr7ZyuqVbEP6z6d',
          appId: '6739497338',
          showDebug: true,
        ),
      );

      await sdk.initSdk();

      /// 📌 Build params EXACTLY as your SDK requires
      final params = AppsFlyerInviteLinkParams(
        channel: "share_product",
        campaign: "product_$productId",
        referrerName: "lafetch_user",
        baseDeepLink: "product", // Your SDK supports this
        brandDomain: "", // Optional
        customParams: {
          "product_id": productId.toString(),
          "product_name": productName,
          "type": type,
          "brand_name": brandName,
        },
      );

      String generatedLink = "";

      /// 📌 Your SDK method signature:
      /// void generateInviteLink(AppsFlyerInviteLinkParams?, Function success, Function error)
      sdk.generateInviteLink(
        params,
        (dynamic link) {
          print("✓ Generated AF Link: $link");
          generatedLink = link?.toString() ?? "";
        },
        (dynamic error) {
          print("✗ AF Link Error: $error");
        },
      );

      /// SDK uses callback → delay to wait for async
      await Future.delayed(const Duration(milliseconds: 300));

      return generatedLink;
    } catch (e) {
      print("AF Exception: $e");
      return "";
    }
  }
}
