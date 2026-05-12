import 'product_card_model.dart';

/// Collection item model for the new Collections UI
/// Represents a collection section with title, subtitle, and products
class CollectionItemModel {
  final int id;
  final String title;
  final String? subtitle;
  final List<ProductCardModel> products;
  final bool darkTheme;
  final int? catId;

  const CollectionItemModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.products,
    this.darkTheme = false,
    this.catId,
  });

  factory CollectionItemModel.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'] as List<dynamic>?;
    final products = productsJson
            ?.map((e) => ProductCardModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return CollectionItemModel(
      id: json['id'] as int,
      title: json['name'] as String? ?? json['title'] as String? ?? '',
      subtitle: json['desc'] as String?,
      products: products,
      darkTheme: false, // Will be determined by index in the list
      catId: json['catId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'products': products.map((p) => p.toJson()).toList(),
      'darkTheme': darkTheme,
      'catId': catId,
    };
  }

  CollectionItemModel copyWith({
    int? id,
    String? title,
    String? subtitle,
    List<ProductCardModel>? products,
    bool? darkTheme,
    int? catId,
  }) {
    return CollectionItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      products: products ?? this.products,
      darkTheme: darkTheme ?? this.darkTheme,
      catId: catId ?? this.catId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CollectionItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
