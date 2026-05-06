import 'package:flutter/material.dart';

/// Enum representing price segment tiers for products
enum PriceSegment {
  affordable,
  premium,
  luxury,
  luxe,
}

extension PriceSegmentExtension on PriceSegment {
  /// Get the API parameter value for this segment
  String get apiValue {
    switch (this) {
      case PriceSegment.affordable:
        return 'affordable';
      case PriceSegment.premium:
        return 'premium';
      case PriceSegment.luxury:
        return 'luxury';
      case PriceSegment.luxe:
        return 'luxe';
    }
  }

  /// Get the display name for this segment
  String get displayName {
    switch (this) {
      case PriceSegment.affordable:
        return 'Affordable';
      case PriceSegment.premium:
        return 'Premium';
      case PriceSegment.luxury:
        return 'Luxury';
      case PriceSegment.luxe:
        return 'LUXE';
    }
  }

  /// Get the indicator color for this segment
  Color get indicatorColor {
    switch (this) {
      case PriceSegment.luxe:
        return const Color(0xFF9C27B0); // Purple
      case PriceSegment.luxury:
        return const Color(0xFFFFD700); // Gold
      case PriceSegment.premium:
        return const Color(0xFFC0C0C0); // Silver
      case PriceSegment.affordable:
        return const Color(0xFF808080); // Gray
    }
  }

  /// Get the background color for this segment (for LUXE view)
  Color get backgroundColor {
    switch (this) {
      case PriceSegment.luxe:
        return const Color(0xFF000000); // Black
      default:
        return const Color(0xFFFAF8FC); // Default light background
    }
  }

  /// Get the text color for this segment
  Color get textColor {
    switch (this) {
      case PriceSegment.luxe:
        return const Color(0xFFFFFFFF); // White text on black
      default:
        return const Color(0xFF46413B); // Default text color
    }
  }

  /// Parse a string to PriceSegment enum
  static PriceSegment? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'affordable':
        return PriceSegment.affordable;
      case 'premium':
        return PriceSegment.premium;
      case 'luxury':
        return PriceSegment.luxury;
      case 'luxe':
        return PriceSegment.luxe;
      default:
        return null;
    }
  }
}
