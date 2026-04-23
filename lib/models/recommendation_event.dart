class UserEvent {
  final String type;
  final int productId;
  final int? variantId;
  final String? orderId;
  final String sessionId;
  final DateTime timestamp;

  UserEvent({
    required this.type,
    required this.productId,
    this.variantId,
    this.orderId,
    required this.sessionId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': type,
        'productId': productId,
        if (variantId != null) 'variantId': variantId,
        if (orderId != null) 'orderId': orderId,
        'sessionId': sessionId,
        'timestamp': timestamp.toIso8601String(),
      };
}

class RecommendationProduct {
  final int id;
  final String slug;
  final String brandName;
  final String productName;
  final double sellingPrice;
  final String imageUrl;

  const RecommendationProduct({
    required this.id,
    required this.slug,
    required this.brandName,
    required this.productName,
    required this.sellingPrice,
    required this.imageUrl,
  });

  factory RecommendationProduct.fromJson(Map<String, dynamic> json) {
    // Support both the guide's field names and the app's existing API field names
    final id = json['id'] ?? json['objectID'] ?? 0;
    final idInt = id is num ? id.toInt() : int.tryParse(id.toString()) ?? 0;
    final brandName = json['brandName'] ??
        json['brand_name'] ??
        (json['brand'] is Map
            ? json['brand']['name']
            : json['brand'] is String
                ? json['brand']
                : null) ??
        '';
    final productName = json['productName'] ?? json['name'] ?? json['title'] ?? '';
    final rawPrice = json['sellingPrice'] ??
            json['basePrice'] ??
            json['price'] ??
            json['netAmount'] ??
            json['msp'] ??
            0;
    final sellingPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice.toString()) ?? 0.0;

    // Image: try multiple shapes
    String imageUrl = '';
    if (json['imageUrl'] is String) {
      imageUrl = json['imageUrl'];
    } else if (json['image'] is String) {
      imageUrl = json['image'];
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      final first = (json['images'] as List).first;
      imageUrl = first is Map
          ? (first['name'] ?? first['src'] ?? first['url'] ?? '').toString()
          : first.toString();
    } else if (json['imageUrls'] is List &&
        (json['imageUrls'] as List).isNotEmpty) {
      imageUrl = (json['imageUrls'] as List).first.toString();
    }

    return RecommendationProduct(
      id: idInt,
      slug: json['slug']?.toString() ?? '',
      brandName: brandName.toString(),
      productName: productName.toString(),
      sellingPrice: sellingPrice,      imageUrl: imageUrl,
    );
  }
}

class ImpressionEvent {
  final int productId;
  final String recommendationType;
  final int position;
  final String sessionId;

  const ImpressionEvent({
    required this.productId,
    this.recommendationType = 'similar',
    required this.position,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'recommendationType': recommendationType,
        'position': position,
        'sessionId': sessionId,
      };
}

class ClickEvent {
  final int productId;
  final String recommendationType;
  final int position;
  final String sessionId;

  const ClickEvent({
    required this.productId,
    this.recommendationType = 'similar',
    required this.position,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'recommendationType': recommendationType,
        'position': position,
        'sessionId': sessionId,
      };
}
