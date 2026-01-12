// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';

/// ================================================================
/// Network Service - Monitors connectivity and provides network status
/// ================================================================
class NetworkService extends GetxService {
  // Observable network status
  final RxBool isConnected = true.obs;
  final RxBool isSlowConnection = false.obs;

  Timer? _connectivityTimer;
  DateTime? _lastCheckTime;
  static const Duration _checkInterval = Duration(seconds: 30);

  @override
  void onInit() {
    super.onInit();
    _startMonitoring();
  }

  @override
  void onClose() {
    _connectivityTimer?.cancel();
    super.onClose();
  }

  /// Start periodic connectivity monitoring
  void _startMonitoring() {
    // Initial check
    checkConnectivity();

    // Periodic checks every 30 seconds
    _connectivityTimer = Timer.periodic(_checkInterval, (_) {
      checkConnectivity();
    });
  }

  /// Check network connectivity
  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      isConnected.value = connected;
      _lastCheckTime = DateTime.now();

      if (!connected) {
        print('🔴 No internet connection');
      }

      return connected;
    } on SocketException catch (_) {
      isConnected.value = false;
      _lastCheckTime = DateTime.now();
      print('🔴 No internet connection (SocketException)');
      return false;
    } on TimeoutException catch (_) {
      isSlowConnection.value = true;
      print('⚠️ Slow internet connection detected');
      return true; // Assume connected but slow
    } catch (e) {
      print('❌ Network check error: $e');
      return isConnected.value; // Return last known state
    }
  }

  /// Force immediate connectivity check
  Future<bool> forceCheck() async {
    _connectivityTimer?.cancel();
    final result = await checkConnectivity();
    _startMonitoring();
    return result;
  }

  /// Check if we should verify connectivity (avoid too frequent checks)
  bool shouldCheck() {
    if (_lastCheckTime == null) return true;
    final timeSinceLastCheck = DateTime.now().difference(_lastCheckTime!);
    return timeSinceLastCheck > const Duration(seconds: 10);
  }

  /// Get time since last successful connection check
  String getLastCheckTime() {
    if (_lastCheckTime == null) return 'Never';
    final duration = DateTime.now().difference(_lastCheckTime!);

    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s ago';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else {
      return '${duration.inHours}h ago';
    }
  }
}
