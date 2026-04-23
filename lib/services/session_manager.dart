import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SessionManager extends GetxService {
  static SessionManager get instance => Get.find();

  static const _keySessionId = 'session_id';
  static const _keySessionExpiry = 'session_expiry';
  static const _sessionDurationDays = 30;

  String? _sessionId;

  /// Must be called once before [getSessionId] is used.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedId = prefs.getString(_keySessionId);
      final expiryMs = prefs.getInt(_keySessionExpiry);

      if (storedId != null && expiryMs != null && !_isExpired(expiryMs)) {
        _sessionId = storedId;
        debugPrint('[SessionManager] Reusing existing session: $_sessionId');
      } else {
        await _generateAndPersist(prefs);
      }
    } catch (e) {
      debugPrint('[SessionManager] init error: $e — using in-memory fallback');
      _sessionId = const Uuid().v4();
    }
  }

  /// Returns the current session ID synchronously.
  /// Throws [StateError] if [init] has not been called.
  String getSessionId() {
    if (_sessionId == null) {
      throw StateError('SessionManager.init() must be called before getSessionId()');
    }
    return _sessionId!;
  }

  Future<void> _generateAndPersist(SharedPreferences prefs) async {
    _sessionId = const Uuid().v4();
    final expiryMs = DateTime.now()
        .add(const Duration(days: _sessionDurationDays))
        .millisecondsSinceEpoch;
    await prefs.setString(_keySessionId, _sessionId!);
    await prefs.setInt(_keySessionExpiry, expiryMs);
    debugPrint('[SessionManager] New session created: $_sessionId');
  }

  bool _isExpired(int expiryMs) =>
      DateTime.now().millisecondsSinceEpoch >= expiryMs;
}
