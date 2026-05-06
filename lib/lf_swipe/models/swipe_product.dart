import '../../models/nudge_model.dart';

/// The product model used exclusively within the lf_swipe module.
///
/// Mirrors the fields returned by `GET /api/recommendations?type=swipe`
/// and supports multiple API response shapes (Algolia hits, backend enriched,
/// legacy field names).
class SwipeProduct {
  final int id;
  final String slug;
  final String brandName;
  final String productName;
  final double sellingPrice;
  final double? mrp;
  final bool isNew;

  /// Primary image URL (first of imageUrls, or the single image field).
  final String imageUrl;

  /// All available product images for cycling.
  final List<String> imageUrls;

  final List<Nudge> nudges;
  final String category;
  final double? rating;
  final int? numReviews;
  final List<String> sizes;
  final List<String> tags;

  /// Gender tags from Algolia — e.g. ["men"], ["women"], [] for unisex.
  final List<String> gender;

  const SwipeProduct({
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
    this.gender = const [],
  });

  factory SwipeProduct.fromJson(Map<String, dynamic> json) {
    // ── ID ──────────────────────────────────────────────────────────────────
    final rawId = json['id'] ?? json['objectID'] ?? 0;
    final id = rawId is num
        ? rawId.toInt()
        : int.tryParse(rawId.toString()) ?? 0;

    // ── Brand ────────────────────────────────────────────────────────────────
    final brandName = (json['brandName'] ??
            json['brand_name'] ??
            (json['brand'] is Map
                ? json['brand']['name']
                : json['brand'] is String
                    ? json['brand']
                    : null) ??
            '')
        .toString();

    // ── Product name ─────────────────────────────────────────────────────────
    final productName =
        (json['productName'] ?? json['name'] ?? json['title'] ?? '')
            .toString();

    // ── Price ─────────────────────────────────────────────────────────────────
    final rawPrice = json['sellingPrice'] ??
        json['basePrice'] ??
        json['price'] ??
        json['netAmount'] ??
        json['msp'] ??
        0;
    final sellingPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice.toString()) ?? 0.0;

    // ── Images ────────────────────────────────────────────────────────────────
    List<String> imageUrls = [];
    if (json['imageUrls'] is List) {
      imageUrls = (json['imageUrls'] as List)
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    String imageUrl = '';
    if (imageUrls.isNotEmpty) {
      imageUrl = imageUrls.first;
    } else if (json['imageUrl'] is String && (json['imageUrl'] as String).isNotEmpty) {
      imageUrl = json['imageUrl'] as String;
    } else if (json['image'] is String && (json['image'] as String).isNotEmpty) {
      imageUrl = json['image'] as String;
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      final first = (json['images'] as List).first;
      imageUrl = first is Map
          ? (first['name'] ?? first['src'] ?? first['url'] ?? '').toString()
          : first.toString();
    }
    if (imageUrls.isEmpty && imageUrl.isNotEmpty) {
      imageUrls = [imageUrl];
    }

    // ── MRP ───────────────────────────────────────────────────────────────────
    final rawMrp = json['mrp'] ?? json['compareAtPrice'];
    final mrp = rawMrp is num
        ? rawMrp.toDouble()
        : rawMrp != null
            ? double.tryParse(rawMrp.toString())
            : null;

    // ── isNew ─────────────────────────────────────────────────────────────────
    final isNew = json['isNew'] == true ||
        json['is_new'] == true ||
        (json['nudges'] is List &&
            (json['nudges'] as List)
                .any((n) => n is Map && n['key'] == 'new_in'));

    // ── Rating ────────────────────────────────────────────────────────────────
    final rawRating = json['rating'];
    final rating = rawRating is num ? rawRating.toDouble() : null;

    // ── Reviews ───────────────────────────────────────────────────────────────
    final rawReviews = json['numReviews'] ?? json['num_reviews'];
    final numReviews = rawReviews is num ? rawReviews.toInt() : null;

    // ── Sizes ─────────────────────────────────────────────────────────────────
    final sizes = json['sizes'] is List
        ? (json['sizes'] as List)
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];

    // ── Tags ──────────────────────────────────────────────────────────────────
    final tags = json['tags'] is List
        ? (json['tags'] as List)
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];

    // ── Gender ────────────────────────────────────────────────────────────────
    // Algolia stores gender as an array: ["men"], ["women"], or []
    final gender = json['gender'] is List
        ? (json['gender'] as List)
            .map((e) => e?.toString().toLowerCase() ?? '')
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];

    // ── Nudges ────────────────────────────────────────────────────────────────
    final nudges = (json['nudges'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(Nudge.fromJson)
            .toList() ??
        [];

    return SwipeProduct(
      id: id,
      slug: json['slug']?.toString() ?? '',
      brandName: brandName,
      productName: productName,
      sellingPrice: sellingPrice,
      mrp: mrp,
      isNew: isNew,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      nudges: nudges,
      category: json['category']?.toString() ?? '',
      rating: rating,
      numReviews: numReviews,
      sizes: sizes,
      tags: tags,
      gender: gender,
    );
  }
}
