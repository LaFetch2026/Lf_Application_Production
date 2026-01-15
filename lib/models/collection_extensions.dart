import 'collection_model.dart';

/// Extensions for Collection models to add utility methods
extension CollectionModelExtensions on CollectionModel {
  /// Check if collection has products
  bool get hasProducts => products.isNotEmpty;

  /// Get product count
  int get productCount => products.length;

  /// Get banners for a specific gender/display type
  List<CollectionBanner> bannersFor(String displayType) {
    return banners
        .where((banner) => banner.displayFor.contains(displayType.toLowerCase()))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  /// Check if collection should be displayed for specific gender
  bool shouldDisplayFor(String genderType) {
    return displayFor.contains(genderType.toLowerCase());
  }

  /// Get first banner for display type
  CollectionBanner? getFirstBanner(String displayType) {
    final filtered = bannersFor(displayType);
    return filtered.isNotEmpty ? filtered.first : null;
  }
}

extension ProductExtensions on Product {
  /// Check if product has discount
  bool get hasDiscount => mrp != null && mrp! > basePrice;

  /// Get formatted price
  String get formattedPrice => '₹${basePrice.toStringAsFixed(0)}';

  /// Get formatted MRP
  String? get formattedMrp => mrp != null ? '₹${mrp!.toStringAsFixed(0)}' : null;

  /// Get discount text
  String? get discountText {
    final discount = getDiscountPercentage();
    return discount != null ? '$discount% OFF' : null;
  }
}

/// Utility class for collection-related operations
class CollectionUtils {
  /// Filter collections by gender/display type
  static List<CollectionModel> filterByGender(
    List<CollectionModel> collections,
    String genderType,
  ) {
    return collections
        .where((c) => c.shouldDisplayFor(genderType))
        .where((c) => c.hasProducts)
        .toList();
  }

  /// Parse collection list from JSON response
  static List<CollectionModel> parseCollections(dynamic jsonData) {
    if (jsonData == null) return [];

    if (jsonData is List) {
      return jsonData
          .whereType<Map<String, dynamic>>()
          .map((json) {
            try {
              return CollectionModel.fromJson(json);
            } catch (e) {
              // Log error for debugging
              print("⚠️ Error parsing collection '${json['name']}': $e");
              return null;
            }
          })
          .whereType<CollectionModel>()
          .toList();
    }

    return [];
  }

  /// Convert collections back to Map format (for backward compatibility)
  static List<Map<String, dynamic>> toMapList(List<CollectionModel> collections) {
    return collections.map((c) => c.toJson()).toList();
  }
}
