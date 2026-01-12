// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../common/widget/other/common_widget.dart';
import '../screens/loginscreen.dart';
import 'network_service.dart';

/// ================================================================
/// Optimized API Service for Production
/// - Automatic retry logic
/// - Network connectivity checks
/// - Request caching
/// - Proper error handling
/// - Request debouncing
/// ================================================================
class ApiService extends GetxService {
  final NetworkService _networkService = Get.find<NetworkService>();

  // Request cache to prevent duplicate calls
  final Map<String, _CachedResponse> _responseCache = {};
  final Map<String, DateTime> _lastRequestTime = {};

  // Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration requestTimeout = Duration(seconds: 20);
  static const Duration cacheValidity = Duration(minutes: 5);
  static const Duration debounceDuration = Duration(milliseconds: 500);

  /// Execute HTTP GET request with retry logic and caching
  Future<http.Response?> get(
    String url, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    bool useCache = true,
    bool showErrorSnackbar = true,
  }) async {
    return _executeWithRetry(
      () => _getRequest(url, queryParams: queryParams, headers: headers),
      url: url,
      useCache: useCache,
      showErrorSnackbar: showErrorSnackbar,
    );
  }

  /// Execute HTTP POST request with retry logic
  Future<http.Response?> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool showErrorSnackbar = true,
  }) async {
    return _executeWithRetry(
      () => _postRequest(url, body: body, headers: headers),
      url: url,
      useCache: false, // Never cache POST requests
      showErrorSnackbar: showErrorSnackbar,
    );
  }

  /// Internal GET request
  Future<http.Response> _getRequest(
    String url, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final finalUri = queryParams != null && queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams)
        : uri;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final finalHeaders = {
      'Accept': 'application/json; charset=UTF-8',
      'Content-Type': 'application/json; charset=UTF-8',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    print('➡️ GET $finalUri');
    return await http.get(finalUri, headers: finalHeaders).timeout(requestTimeout);
  }

  /// Internal POST request
  Future<http.Response> _postRequest(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final finalHeaders = {
      'Accept': 'application/json; charset=UTF-8',
      'Content-Type': 'application/json; charset=UTF-8',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    print('➡️ POST $uri');
    return await http
        .post(
          uri,
          headers: finalHeaders,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(requestTimeout);
  }

  /// Execute request with retry logic and caching
  Future<http.Response?> _executeWithRetry(
    Future<http.Response> Function() request, {
    required String url,
    required bool useCache,
    required bool showErrorSnackbar,
    int retryCount = 0,
  }) async {
    // 1. Check for request debouncing
    if (!_shouldMakeRequest(url)) {
      print('⏸️ Request debounced: $url');
      return _getCachedResponse(url);
    }

    // 2. Check cache
    if (useCache) {
      final cached = _getCachedResponse(url);
      if (cached != null) {
        print('✅ Using cached response for: $url');
        return cached;
      }
    }

    // 3. Check network connectivity
    if (!_networkService.isConnected.value) {
      final connected = await _networkService.checkConnectivity();
      if (!connected) {
        if (showErrorSnackbar) {
          showAppSnackBar('No internet connection. Please check your network.');
        }
        print('🔴 No internet - skipping request: $url');
        return null;
      }
    }

    try {
      // 4. Execute request
      _lastRequestTime[url] = DateTime.now();
      final response = await request();

      print('⬅️ ${response.statusCode} $url');

      // 5. Handle response
      if (response.statusCode == 200) {
        // Cache successful response
        if (useCache) {
          _cacheResponse(url, response);
        }
        return response;
      } else if (response.statusCode == 401) {
        // Handle unauthorized
        if (showErrorSnackbar) {
          showAppSnackBar('Session expired. Please log in again.');
        }
        Get.offAll(() => const LoginScreen(initialTab: 0));
        return null;
      } else if (response.statusCode >= 500 && retryCount < maxRetries) {
        // Retry on server errors
        print('⚠️ Server error (${response.statusCode}) - Retry ${retryCount + 1}/$maxRetries');
        await Future.delayed(retryDelay * (retryCount + 1));
        return _executeWithRetry(
          request,
          url: url,
          useCache: useCache,
          showErrorSnackbar: showErrorSnackbar,
          retryCount: retryCount + 1,
        );
      } else {
        // Handle other errors
        String errorMsg = 'Request failed (${response.statusCode})';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            errorMsg = decoded['message'].toString();
          }
        } catch (_) {}

        if (showErrorSnackbar) {
          showAppSnackBar(errorMsg);
        }
        print('❌ $errorMsg: $url');
        return response; // Return response for caller to handle
      }
    } on TimeoutException catch (_) {
      if (retryCount < maxRetries) {
        print('⏱️ Timeout - Retry ${retryCount + 1}/$maxRetries: $url');
        await Future.delayed(retryDelay * (retryCount + 1));
        return _executeWithRetry(
          request,
          url: url,
          useCache: useCache,
          showErrorSnackbar: showErrorSnackbar,
          retryCount: retryCount + 1,
        );
      } else {
        if (showErrorSnackbar) {
          showAppSnackBar('Request timed out. Please try again.');
        }
        print('❌ Timeout after $maxRetries retries: $url');
        return null;
      }
    } on SocketException catch (_) {
      // Network error - check connectivity and retry
      final connected = await _networkService.checkConnectivity();
      if (connected && retryCount < maxRetries) {
        print('🔄 Network error - Retry ${retryCount + 1}/$maxRetries: $url');
        await Future.delayed(retryDelay * (retryCount + 1));
        return _executeWithRetry(
          request,
          url: url,
          useCache: useCache,
          showErrorSnackbar: showErrorSnackbar,
          retryCount: retryCount + 1,
        );
      } else {
        if (showErrorSnackbar) {
          showAppSnackBar('No internet connection. Please check your network.');
        }
        print('🔴 Network error: $url');
        return null;
      }
    } catch (e) {
      print('❌ Request error: $e');
      if (showErrorSnackbar) {
        showAppSnackBar('Something went wrong. Please try again.');
      }
      return null;
    }
  }

  /// Check if request should be made (debouncing)
  bool _shouldMakeRequest(String url) {
    final lastTime = _lastRequestTime[url];
    if (lastTime == null) return true;

    final timeSinceLastRequest = DateTime.now().difference(lastTime);
    return timeSinceLastRequest > debounceDuration;
  }

  /// Cache response
  void _cacheResponse(String url, http.Response response) {
    _responseCache[url] = _CachedResponse(
      response: response,
      timestamp: DateTime.now(),
    );

    // Clean old cache entries (keep only last 50)
    if (_responseCache.length > 50) {
      final sortedKeys = _responseCache.keys.toList()
        ..sort((a, b) {
          final aTime = _responseCache[a]!.timestamp;
          final bTime = _responseCache[b]!.timestamp;
          return aTime.compareTo(bTime);
        });

      // Remove oldest 10 entries
      for (var i = 0; i < 10; i++) {
        _responseCache.remove(sortedKeys[i]);
      }
    }
  }

  /// Get cached response if valid
  http.Response? _getCachedResponse(String url) {
    final cached = _responseCache[url];
    if (cached == null) return null;

    final age = DateTime.now().difference(cached.timestamp);
    if (age > cacheValidity) {
      _responseCache.remove(url);
      return null;
    }

    return cached.response;
  }

  /// Clear all caches
  void clearCache() {
    _responseCache.clear();
    _lastRequestTime.clear();
    print('🗑️ API cache cleared');
  }

  /// Clear specific URL from cache
  void clearCacheForUrl(String url) {
    _responseCache.remove(url);
    _lastRequestTime.remove(url);
    print('🗑️ Cache cleared for: $url');
  }

  /// Get cache statistics (for debugging)
  Map<String, dynamic> getCacheStats() {
    return {
      'cached_responses': _responseCache.length,
      'tracked_requests': _lastRequestTime.length,
      'oldest_cache': _responseCache.isEmpty
          ? 'N/A'
          : _responseCache.values
              .map((c) => c.timestamp)
              .reduce((a, b) => a.isBefore(b) ? a : b)
              .toString(),
    };
  }
}

/// Internal class to store cached responses
class _CachedResponse {
  final http.Response response;
  final DateTime timestamp;

  _CachedResponse({required this.response, required this.timestamp});
}
