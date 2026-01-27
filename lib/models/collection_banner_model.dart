// Standalone Collection Banner Model (from /collection-banners API)
class StandaloneCollectionBanner {
  final int id;
  final int collectionId;
  final String imageUrl;
  final String redirectUrl;
  final bool isActive;
  final int? position;
  final List<String> displayFor;
  final String? mobileImageUrl;
  final int tile;
  final String createdAt;
  final String updatedAt;

  StandaloneCollectionBanner({
    required this.id,
    required this.collectionId,
    required this.imageUrl,
    required this.redirectUrl,
    required this.isActive,
    this.position,
    required this.displayFor,
    this.mobileImageUrl,
    this.tile = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StandaloneCollectionBanner.fromJson(Map<String, dynamic> json) {
    return StandaloneCollectionBanner(
      id: json['id'] as int,
      collectionId: json['collectionId'] as int,
      imageUrl: json['imageUrl'] as String? ?? '',
      redirectUrl: json['redirectUrl'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      position: json['position'] as int?,
      displayFor: (json['displayFor'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .toList() ??
          [],
      mobileImageUrl: json['mobileImageUrl'] as String?,
      tile: json['tile'] as int? ?? 1,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'imageUrl': imageUrl,
      'redirectUrl': redirectUrl,
      'isActive': isActive,
      'position': position,
      'displayFor': displayFor,
      'mobileImageUrl': mobileImageUrl,
      'tile': tile,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Get appropriate image URL based on platform
  String getImageUrl({bool isMobile = true}) {
    if (isMobile && mobileImageUrl != null && mobileImageUrl!.isNotEmpty) {
      return mobileImageUrl!;
    }
    return imageUrl;
  }

  /// Check if the media URL is a video
  bool isVideo({bool isMobile = true}) {
    final url = getImageUrl(isMobile: isMobile).toLowerCase();
    return url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.webm');
  }

  /// Check if banner should display for specific gender/type
  bool shouldDisplayFor(String type) {
    return displayFor.contains(type.toLowerCase());
  }
}

/// Utility class for banner operations
class CollectionBannerUtils {
  /// Parse banners from JSON response
  static List<StandaloneCollectionBanner> parseBanners(dynamic jsonData) {
    if (jsonData == null) return [];

    if (jsonData is List) {
      return jsonData
          .whereType<Map<String, dynamic>>()
          .map((json) {
            try {
              return StandaloneCollectionBanner.fromJson(json);
            } catch (e) {
              print("⚠️ Error parsing banner ${json['id']}: $e");
              return null;
            }
          })
          .whereType<StandaloneCollectionBanner>()
          .toList();
    }

    return [];
  }

  /// Filter banners by collection ID and display type
  static List<StandaloneCollectionBanner> filterBannersForCollection(
    List<StandaloneCollectionBanner> allBanners,
    int collectionId,
    String displayType,
  ) {
    print("🔍 Filtering banners for collectionId: $collectionId, displayType: $displayType");
    print("📦 Total banners available: ${allBanners.length}");

    final filtered = allBanners
        .where((banner) {
          final matches = banner.collectionId == collectionId &&
              banner.isActive &&
              banner.shouldDisplayFor(displayType);
          if (banner.collectionId == collectionId) {
            print("📌 Banner ${banner.id}: collectionId=${banner.collectionId}, isActive=${banner.isActive}, displayFor=${banner.displayFor}, isVideo=${banner.isVideo()}, matches=$matches");
          }
          return matches;
        })
        .toList()
      ..sort((a, b) {
        // Sort by position, nulls last
        if (a.position == null && b.position == null) return 0;
        if (a.position == null) return 1;
        if (b.position == null) return -1;
        return a.position!.compareTo(b.position!);
      });

    print("✅ Filtered banners count: ${filtered.length}");
    return filtered;
  }
}
