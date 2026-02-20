class ShareLinkGenerator {
  /// Generates a OneLink URL that works with Universal Links (iOS) and App Links (Android).
  /// This URL matches the Associated Domains configured in the app (lafetch.onelink.me).
  static Future<String> generateProductShareLink({
    required int productId,
    required String slug,
    required String brandName,
    required String type,
  }) async {
    // Build OneLink URL with deep link parameters
    // This domain (lafetch.onelink.me) is in Associated Domains, so Universal Links will work
    final Uri link = Uri.https(
      "lafetch.onelink.me",
      "/rxDU",
      {
        "product_id": productId.toString(),
        "slug": slug,
        "brand_name": brandName,
        "type": type,
        "af_dp": "lafetch://product/$productId", // Deep link scheme for app
        "af_channel": "product_share",
        "c": "product_share",
        "deep_link_value": "product_details",
      },
    );

    return link.toString();
  }

  /// Generates a OneLink URL for sharing a wishlist board.
  static Future<String> generateBoardShareLink({
    required int boardId,
    required String boardName,
  }) async {
    final Uri link = Uri.https(
      "lafetch.onelink.me",
      "/rxDU",
      {
        "board_id": boardId.toString(),
        "board_name": boardName,
        "af_dp": "lafetch://board/$boardId",
        "af_channel": "board_share",
        "c": "board_share",
        "deep_link_value": "board_details",
      },
    );
    return link.toString();
  }
}
