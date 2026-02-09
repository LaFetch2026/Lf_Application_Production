/// Image helper utility for optimizing image loading performance
/// Provides URL sanitization and validation

class ImageHelper {
  ImageHelper._();

  /// Sanitize image URL - trims whitespace, returns empty string if null
  static String toWebP(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    return imageUrl.trim();
  }

  /// Check if an image URL is valid and non-empty
  static bool isValidImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final trimmed = url.trim();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  /// Check if URL is a video
  static bool isVideoUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.m3u8') ||
        lower.contains('/video/');
  }
}
