import 'nudge_model.dart';

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
  final double? mrp;
  final bool isNew;
  final String imageUrl;
  final List<String> imageUrls; // all product images
  final List<Nudge> nudges;
  final String category;
  final double? rating;
  final int? numReviews;
  final List<String> sizes;
  final List<String> tags;

  const RecommendationProduct({
    required this.id,
    required this.slug,
    required this.brandName,
    required this.productName,
    required this.sellingPrice,
    this.mrp,
    this.isNew = false,
    required this.imageUrl,
    this.imageUrls = const [],
    this.nudges = const [],
    this.category = '',
    this.rating,
    this.numReviews,
    this.sizes = const [],
    this.tags = const [],
  });

  factory RecommendationProduct.fromJson(Map<String, dynamic> json) {
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

    // All image URLs
    List<String> imageUrls = [];
    if (json['imageUrls'] is List) {
      imageUrls = (json['imageUrls'] as List)
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Primary image
    String imageUrl = '';
    if (imageUrls.isNotEmpty) {
      imageUrl = imageUrls.first;
    } else if (json['imageUrl'] is String) {
      imageUrl = json['imageUrl'];
    } else if (json['image'] is String) {
      imageUrl = json['image'];
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      final first = (json['images'] as List).first;
      imageUrl = first is Map
          ? (first['name'] ?? first['src'] ?? first['url'] ?? '').toString()
          : first.toString();
    }
    if (imageUrls.isEmpty && imageUrl.isNotEmpty) {
      imageUrls = [imageUrl];
    }

    final rawMrp = json['mrp'] ?? json['compareAtPrice'];
    final mrp = rawMrp is num
        ? rawMrp.toDouble()
        : rawMrp != null
            ? double.tryParse(rawMrp.toString())
            : null;

    final isNew = json['isNew'] == true ||
        json['is_new'] == true ||
        (json['nudges'] is List &&
            (json['nudges'] as List).any((n) =>
                n is Map && n['key'] == 'new_in'));

    // Rating
    final rawRating = json['rating'];
    final rating = rawRating is num ? rawRating.toDouble() : null;

    // numReviews
    final rawReviews = json['numReviews'] ?? json['num_reviews'];
    final numReviews = rawReviews is num ? rawReviews.toInt() : null;

    // Sizes
    List<String> sizes = [];
    if (json['sizes'] is List) {
      sizes = (json['sizes'] as List)
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Tags
    List<String> tags = [];
    if (json['tags'] is List) {
      tags = (json['tags'] as List)
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return RecommendationProduct(
      id: idInt,
      slug: json['slug']?.toString() ?? '',
      brandName: brandName.toString(),
      productName: productName.toString(),
      sellingPrice: sellingPrice,
      mrp: mrp,
      isNew: isNew,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      nudges: (json['nudges'] as List<dynamic>?)?.map((e) => Nudge.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      category: json['category']?.toString() ?? '',
      rating: rating,
      numReviews: numReviews,
      sizes: sizes,
      tags: tags,
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
