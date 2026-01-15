// Collection Model
class CollectionModel {
  final int id;
  final String name;
  final String? desc;
  final int? vendorId;
  final List<String> displayFor;
  final List<CollectionBanner> banners;
  final List<CollectionProductMap> productMaps;
  final List<Product> products;

  CollectionModel({
    required this.id,
    required this.name,
    this.desc,
    this.vendorId,
    required this.displayFor,
    required this.banners,
    required this.productMaps,
    required this.products,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'] as List<dynamic>?;
    final products = productsJson
            ?.map((e) {
              try {
                return Product.fromJson(e as Map<String, dynamic>);
              } catch (error) {
                print("⚠️ Failed to parse product in collection '${json['name']}': $error");
                return null;
              }
            })
            .whereType<Product>()
            .toList() ??
        [];

    print("📦 Collection '${json['name']}': ${products.length} products parsed (raw: ${productsJson?.length ?? 0})");

    return CollectionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      desc: json['desc'] as String?,
      vendorId: json['vendorId'] as int?,
      displayFor: (json['displayFor'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      banners: (json['banners'] as List<dynamic>?)
              ?.map((e) => CollectionBanner.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      productMaps: (json['productMaps'] as List<dynamic>?)
              ?.map((e) =>
                  CollectionProductMap.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      products: products,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'vendorId': vendorId,
      'displayFor': displayFor,
      'banners': banners.map((e) => e.toJson()).toList(),
      'productMaps': productMaps.map((e) => e.toJson()).toList(),
      'products': products.map((e) => e.toJson()).toList(),
    };
  }

  // Helper method to get banners for specific display type
  List<CollectionBanner> getBannersForDisplay(String displayType) {
    return banners
        .where((banner) => banner.displayFor.contains(displayType))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }
}

// Collection Banner Model
class CollectionBanner {
  final int id;
  final String imageUrl;
  final int position;
  final String redirectUrl;
  final List<String> displayFor;
  final String? mobileImageUrl;

  CollectionBanner({
    required this.id,
    required this.imageUrl,
    required this.position,
    required this.redirectUrl,
    required this.displayFor,
    this.mobileImageUrl,
  });

  factory CollectionBanner.fromJson(Map<String, dynamic> json) {
    return CollectionBanner(
      id: json['id'] as int,
      imageUrl: json['imageUrl'] as String? ?? '',
      position: json['position'] as int? ?? 0,
      redirectUrl: json['redirectUrl'] as String? ?? '',
      displayFor: (json['displayFor'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      mobileImageUrl: json['mobileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'position': position,
      'redirectUrl': redirectUrl,
      'displayFor': displayFor,
      'mobileImageUrl': mobileImageUrl,
    };
  }

  // Helper method to get appropriate image URL based on platform
  String getImageUrl({bool isMobile = true}) {
    if (isMobile && mobileImageUrl != null && mobileImageUrl!.isNotEmpty) {
      return mobileImageUrl!;
    }
    return imageUrl;
  }
}

// Collection Product Map Model
class CollectionProductMap {
  final int id;
  final int productId;
  final int collectionId;
  final String createdAt;
  final String updatedAt;
  final Product? product;

  CollectionProductMap({
    required this.id,
    required this.productId,
    required this.collectionId,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory CollectionProductMap.fromJson(Map<String, dynamic> json) {
    return CollectionProductMap(
      id: json['id'] as int,
      productId: json['productId'] as int,
      collectionId: json['collectionId'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'collectionId': collectionId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'product': product?.toJson(),
    };
  }
}

// Product Model
class Product {
  final int id;
  final String title;
  final String? shortDescription;
  final num basePrice;
  final num? mrp;
  final List<String> imageUrls;
  final String createdAt;
  final ProductBrand brand;

  Product({
    required this.id,
    required this.title,
    this.shortDescription,
    required this.basePrice,
    this.mrp,
    required this.imageUrls,
    required this.createdAt,
    required this.brand,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final imageUrls = (json['imageUrls'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Debug: Log if imageUrls is empty
    if (imageUrls.isEmpty) {
      print("⚠️ Product '${json['title']}' has no imageUrls in JSON");
    }

    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      shortDescription: json['shortDescription'] as String?,
      basePrice: (json['basePrice'] ?? 0) as num,
      mrp: json['mrp'] as num?,
      imageUrls: imageUrls,
      createdAt: json['createdAt'] as String? ?? '',
      brand: json['brand'] != null
          ? ProductBrand.fromJson(json['brand'] as Map<String, dynamic>)
          : ProductBrand(name: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'shortDescription': shortDescription,
      'basePrice': basePrice,
      'mrp': mrp,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'brand': brand.toJson(),
    };
  }

  // Helper method to calculate discount percentage
  int? getDiscountPercentage() {
    if (mrp != null && mrp! > basePrice && basePrice > 0) {
      return (((mrp! - basePrice) / mrp!) * 100).round();
    }
    return null;
  }

  // Helper method to get first image
  String get firstImageUrl =>
      imageUrls.isNotEmpty ? imageUrls.first : '';
}

// Product Brand Model
class ProductBrand {
  final String name;

  ProductBrand({
    required this.name,
  });

  factory ProductBrand.fromJson(Map<String, dynamic> json) {
    return ProductBrand(
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
