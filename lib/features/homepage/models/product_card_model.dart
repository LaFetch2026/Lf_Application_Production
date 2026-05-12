import '../../../models/nudge_model.dart';

/// Product card model for the new Collections UI
/// Based on Figma design: image ~70% height, product name, brand, price, discount
class ProductCardModel {
  final int id;
  final String title;
  final String brand;
  final String imageUrl;
  final num price;
  final num? mrp;
  final int? discountPercentage;
  final bool isOutOfStock;
  final List<Nudge>? nudges;

  const ProductCardModel({
    required this.id,
    required this.title,
    required this.brand,
    required this.imageUrl,
    required this.price,
    this.mrp,
    this.discountPercentage,
    this.isOutOfStock = false,
    this.nudges,
  });

  factory ProductCardModel.fromJson(Map<String, dynamic> json) {
    // Extract price with fallbacks
    final rawPrice = json['displayPrice'] ??
        json['basePrice'] ??
        json['price'] ??
        json['netAmount'] ??
        json['msp'] ??
        0;
    final num price = rawPrice is num
        ? rawPrice
        : num.tryParse(rawPrice?.toString() ?? '0') ?? 0;

    // Extract MRP with fallbacks
    final rawMrp =
        json['displayMrp'] ?? json['mrp'] ?? json['manufacturingAmount'];
    num? mrp;
    if (rawMrp is num && rawMrp > 0) {
      mrp = rawMrp;
    } else {
      final parsed = num.tryParse(rawMrp?.toString() ?? '0');
      mrp = (parsed != null && parsed > 0) ? parsed : null;
    }

    // Calculate discount if not provided
    int? discountPercent = json['discountPercent'] as int?;
    if (discountPercent == null && mrp != null && mrp > price && mrp > 0) {
      discountPercent = (((mrp - price) / mrp) * 100).round();
    }

    // Extract brand name
    final brand = json['brand'] is Map
        ? (json['brand'] as Map)['name']?.toString() ?? ''
        : json['brand_name']?.toString() ?? json['brandName']?.toString() ?? '';

    // Extract image URL
    String imageUrl = '';
    if (json['imageUrls'] is List && (json['imageUrls'] as List).isNotEmpty) {
      imageUrl = json['imageUrls'][0].toString();
    }

    return ProductCardModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      brand: brand,
      imageUrl: imageUrl,
      price: price,
      mrp: mrp,
      discountPercentage: discountPercent,
      isOutOfStock: json['stock'] == 0 || json['isOutOfStock'] == true,
      nudges: (json['nudges'] as List<dynamic>?)
          ?.map((e) => Nudge.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'brand': brand,
      'imageUrl': imageUrl,
      'price': price,
      'mrp': mrp,
      'discountPercentage': discountPercentage,
      'isOutOfStock': isOutOfStock,
      'nudges': nudges,
    };
  }

  ProductCardModel copyWith({
    int? id,
    String? title,
    String? brand,
    String? imageUrl,
    num? price,
    num? mrp,
    int? discountPercentage,
    bool? isOutOfStock,
    List<Nudge>? nudges,
  }) {
    return ProductCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      nudges: nudges ?? this.nudges,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductCardModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
