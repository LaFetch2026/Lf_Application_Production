// ignore_for_file: avoid_print

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:smartech_base/smartech_base.dart';
import 'package:smartech_push/smartech_push.dart';

/// NetcoreService — thin GetX singleton that wraps every Netcore CE SDK call.
///
/// Design principles:
/// - All public methods are fire-and-forget (void / Future<T> with default).
/// - Every SDK call is guarded by [_initialised] and wrapped in try-catch.
/// - Failures are logged to Crashlytics in release mode and debugPrint in debug.
/// - The calling code is never aware of a Netcore failure.
class NetcoreService extends GetxService {
  // ── Singleton accessor ────────────────────────────────────────────────────
  static NetcoreService get instance => Get.find<NetcoreService>();

  // ── Internal state ────────────────────────────────────────────────────────
  bool _initialised = false;

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Initialise the Netcore CE Dart-side SDK.
  ///
  /// The native SDK is already initialised by MyApplication (Android) /
  /// AppDelegate (iOS). This method marks the service as ready so all
  /// subsequent calls are allowed through.
  Future<void> init() async {
    try {
      // No Dart-side initSDK call needed — native layer handles initialisation.
      // We just mark the service as ready.
      _initialised = true;
      debugPrint('✅ NetcoreService: ready');
    } catch (e, stack) {
      _initialised = false;
      debugPrint('❌ NetcoreService: init failed — $e');
      _recordError(e, stack);
    }
  }

  /// Register the deeplink handler.
  ///
  /// Must be called after [init()]. The callback receives the deeplink URL
  /// string from a notification tap and routes via GetX.
  void registerDeeplinkHandler() {
    if (!_initialised) return;
    try {
      // Signature: (String? source, String? deeplink, Map? payload, Map? customPayload)
      Smartech().onHandleDeeplink(
        (String? smtDeeplinkSource,
            String? smtDeeplink,
            Map<dynamic, dynamic>? smtPayload,
            Map<dynamic, dynamic>? smtCustomPayload) {
          if (smtDeeplink != null && smtDeeplink.isNotEmpty) {
            debugPrint('🔗 NetcoreService: deeplink received — $smtDeeplink');
            Get.toNamed(smtDeeplink);
          }
        },
      );
    } catch (e, stack) {
      debugPrint('❌ NetcoreService: registerDeeplinkHandler failed — $e');
      _recordError(e, stack);
    }
  }

  // ── Identity ──────────────────────────────────────────────────────────────

  /// Set the user identity (must be called before [loginUser]).
  void identifyUser(String userId) {
    if (!_initialised || userId.isEmpty) return;
    try {
      Smartech().setUserIdentity(userId);
    } catch (e, stack) {
      _recordError(e, stack);
    }
  }

  /// Notify Netcore that the user has logged in.
  void loginUser(String userId) {
    if (!_initialised || userId.isEmpty) return;
    try {
      Smartech().login(userId);
    } catch (e, stack) {
      _recordError(e, stack);
    }
  }

  /// Notify Netcore that the user has logged out and clear the identity.
  void logoutUser() {
    if (!_initialised) return;
    try {
      Smartech().logoutAndClearUserIdentity(true);
    } catch (e, stack) {
      _recordError(e, stack);
    }
  }

  /// Update the user's profile attributes in Netcore.
  ///
  /// [attributes] must use Netcore-supported value types:
  /// String, int, double, or a date string in "yyyy-MM-dd" format.
  void updateProfile(Map<String, dynamic> attributes) {
    if (!_initialised || attributes.isEmpty) return;
    try {
      Smartech().updateUserProfile(attributes);
    } catch (e, stack) {
      _recordError(e, stack);
    }
  }

  // ── Event tracking ────────────────────────────────────────────────────────

  /// Track a custom event.
  ///
  /// This is additive — it must always be called AFTER the existing
  /// EventTrackingService / MetaEventService calls, never replacing them.
  void trackEvent(String eventName, Map<String, dynamic> payload) {
    if (!_initialised) return;
    try {
      Smartech().trackEvent(eventName, payload);
    } catch (e, stack) {
      _recordError(e, stack);
    }
  }

  // ── Push token ────────────────────────────────────────────────────────────

  /// Forward the FCM device token to Netcore.
  ///
  /// Called alongside the existing SharedPreferences token storage — not
  /// replacing it.
  void setDevicePushToken(String token) {
    if (!_initialised || token.isEmpty) return;
    try {
      SmartechPush().setDevicePushToken(token);
    } catch (e, stack) {
      _recordError(e, stack);
    }
  }

  // ── Opt controls ──────────────────────────────────────────────────────────

  /// Opt in (true) or out (false) of all Netcore event tracking.
  void optTracking(bool opt) {
    if (!_initialised) return;
    try {
      Smartech().optTracking(opt);
    } catch (e, stack) {
      _recordError(e, stack);
    }
  }

  /// Opt in (true) or out (false) of Netcore push notifications.
  /// Lives on SmartechPush, not Smartech.
  void optPushNotification(bool opt) {
    if (!_initialised) return;
    try {
      SmartechPush().optPushNotification(opt);
    } catch (e, stack) {
      _recordError(e, stack);
    }
  }

  /// Opt in (true) or out (false) of Netcore in-app messages.
  void optInAppMessage(bool opt) {
    if (!_initialised) return;
    try {
      Smartech().optInAppMessage(opt);
    } catch (e, stack) {
      _recordError(e, stack);
    }
  }

  /// Returns whether the user has opted in to tracking.
  /// Returns false on error or when not initialised.
  Future<bool> hasOptedTracking() async {
    if (!_initialised) return false;
    try {
      return await Smartech().hasOptedTracking() ?? false;
    } catch (e, stack) {
      _recordError(e, stack);
      return false;
    }
  }

  /// Returns whether the user has opted in to push notifications.
  /// Returns false on error or when not initialised.
  /// Lives on SmartechPush, not Smartech.
  Future<bool> hasOptedPushNotification() async {
    if (!_initialised) return false;
    try {
      return await SmartechPush().hasOptedPushNotification() ?? false;
    } catch (e, stack) {
      _recordError(e, stack);
      return false;
    }
  }

  /// Returns whether the user has opted in to in-app messages.
  /// Returns false on error or when not initialised.
  Future<bool> hasOptedInAppMessage() async {
    if (!_initialised) return false;
    try {
      return await Smartech().hasOptedInAppMessage() ?? false;
    } catch (e, stack) {
      _recordError(e, stack);
      return false;
    }
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  void _recordError(Object e, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('❌ NetcoreService error: $e');
    } else {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
    }
  }
}
