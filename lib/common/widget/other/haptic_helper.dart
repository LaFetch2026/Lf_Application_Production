import 'package:flutter/services.dart';

/// Haptic feedback helper for the app.
/// Call these methods on tap/click events for tactile feedback.
class Haptic {
  /// Light haptic feedback - use for most taps
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback - use for important actions
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback - use for significant actions
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click - use for selection changes
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate - standard vibration
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}
