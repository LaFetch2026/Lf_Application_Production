import 'package:flutter/material.dart';

import '../services/swipe_tracking_service.dart';

/// Enum representing the type of overlay to display.
///
/// - [textFull]: Full text overlay (e.g., "Added to Cart") for the first product
/// - [iconOnly]: Icon-only overlay (e.g., cart or heart icon) for subsequent products
enum OverlayType {
  textFull,
  iconOnly,
}

/// Configuration for overlay animation and display timing.
///
/// Specifies the duration, fade-in/fade-out timings, and animation curve
/// for smooth overlay display.
class OverlayConfig {
  /// Total duration the overlay remains visible (1.5-2.5 seconds)
  final Duration duration;

  /// Duration for fade-in animation (200-400ms)
  final Duration fadeInDuration;

  /// Duration for fade-out animation (200-400ms)
  final Duration fadeOutDuration;

  /// Animation curve for smooth transitions (e.g., easeInOut)
  final Curve curve;

  const OverlayConfig({
    required this.duration,
    required this.fadeInDuration,
    required this.fadeOutDuration,
    required this.curve,
  });
}

/// Manages overlay display logic and tracks first-product state.
///
/// This manager centralizes the logic for determining whether to show
/// full text or icon-only overlays based on product position in the swipe feed.
/// It tracks whether the first product has been shown and provides overlay
/// configuration for animation timing.
class SwipeOverlayManager {
  /// Flag indicating whether the first product overlay has been shown in this session
  bool _firstProductShown = false;

  /// Reset session state when entering/leaving the swipe feed.
  ///
  /// This should be called in [SwipeFeedScreen.initState()] when entering
  /// the swipe feed and in [SwipeFeedScreen.dispose()] when leaving.
  void resetSession() {
    _firstProductShown = false;
  }

  /// Determine the overlay type for a given swipe action.
  ///
  /// Returns [OverlayType.textFull] for the first product (and sets the flag),
  /// then returns [OverlayType.iconOnly] for all subsequent products.
  ///
  /// Parameters:
  ///   - [action]: The swipe action (not currently used, but available for future expansion)
  ///
  /// Returns:
  ///   - [OverlayType.textFull] on first call
  ///   - [OverlayType.iconOnly] on subsequent calls
  OverlayType getOverlayType(SwipeAction action) {
    if (!_firstProductShown) {
      _firstProductShown = true;
      return OverlayType.textFull;
    }
    return OverlayType.iconOnly;
  }

  /// Get overlay configuration for the specified overlay type.
  ///
  /// Returns animation timing and curve configuration for smooth overlay display.
  /// All overlays use the same timing (1.5-2.5 seconds) regardless of type.
  ///
  /// Parameters:
  ///   - [type]: The overlay type (textFull or iconOnly)
  ///
  /// Returns:
  ///   An [OverlayConfig] with:
  ///   - duration: 2000ms (within 1.5-2.5 second range)
  ///   - fadeInDuration: 300ms (within 200-400ms range)
  ///   - fadeOutDuration: 300ms (within 200-400ms range)
  ///   - curve: Curves.easeInOut for smooth transitions
  OverlayConfig getOverlayConfig(OverlayType type) {
    return const OverlayConfig(
      duration: Duration(milliseconds: 2000),
      fadeInDuration: Duration(milliseconds: 300),
      fadeOutDuration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}


