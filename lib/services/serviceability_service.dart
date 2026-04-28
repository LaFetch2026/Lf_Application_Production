import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Model carrying the structured outcome of a serviceability check for the cart.
class ServiceabilityResult {
  final bool isServiceable;
  final List<int> nonServiceableVariantIds;
  final List<String> nonServiceableItemNames;

  const ServiceabilityResult({
    required this.isServiceable,
    required this.nonServiceableVariantIds,
    required this.nonServiceableItemNames,
  });

  /// True when the overall result is non-serviceable and there are failing variants.
  bool get isTotalFailure =>
      !isServiceable && nonServiceableVariantIds.isNotEmpty;

  /// True when some but not all items are non-serviceable.
  bool get isPartialFailure =>
      !isServiceable && nonServiceableVariantIds.isNotEmpty;
}

/// Standalone service for checking delivery serviceability via the LaFetch API.
class ServiceabilityService {
  static const String _endpoint =
      'https://lfapi.la-fetch.com/api/check-serviceability';
  static const int _timeoutSeconds = 10;

  final http.Client _client;

  ServiceabilityService([http.Client? client])
      : _client = client ?? http.Client();

  /// Check a single (postalCode, variantId) pair.
  ///
  /// Returns `true` only when the API responds with HTTP 200 and the response
  /// body contains a truthy `serviceable` field. Returns `false` on any
  /// non-200 status, timeout, network error, or malformed response.
  Future<bool> checkOne(String postalCode, int variantId) async {
    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'deliveryPostalCode': postalCode,
              'variantId': variantId,
            }),
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode != 200) {
        debugPrint(
          'ServiceabilityService: non-200 status ${response.statusCode} '
          'for postalCode=$postalCode variantId=$variantId',
        );
        return false;
      }

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;

      // Support both response shapes:
      //   { "serviceable": true }
      //   { "data": { "serviceable": true } }
      final dynamic topLevel = body['serviceable'];
      if (topLevel != null) {
        return topLevel == true;
      }

      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) {
        return data['serviceable'] == true;
      }

      return false;
    } on TimeoutException catch (e) {
      debugPrint(
        'ServiceabilityService: timeout for postalCode=$postalCode '
        'variantId=$variantId — $e',
      );
      return false;
    } on SocketException catch (e) {
      debugPrint(
        'ServiceabilityService: socket error for postalCode=$postalCode '
        'variantId=$variantId — $e',
      );
      return false;
    } catch (e) {
      debugPrint(
        'ServiceabilityService: unexpected error for postalCode=$postalCode '
        'variantId=$variantId — $e',
      );
      return false;
    }
  }

  /// Check all [variantIds] in the cart against [postalCode].
  ///
  /// Returns a [ServiceabilityResult] aggregating all individual checks.
  /// Returns a fully serviceable result immediately when [variantIds] is empty.
  Future<ServiceabilityResult> checkCart({
    required String postalCode,
    required List<int> variantIds,
    required Map<int, String> variantIdToName,
  }) async {
    if (variantIds.isEmpty) {
      return const ServiceabilityResult(
        isServiceable: true,
        nonServiceableVariantIds: [],
        nonServiceableItemNames: [],
      );
    }

    final List<int> failingIds = [];
    final List<String> failingNames = [];

    for (final variantId in variantIds) {
      final serviceable = await checkOne(postalCode, variantId);
      if (!serviceable) {
        failingIds.add(variantId);
        final name = variantIdToName[variantId];
        if (name != null && name.isNotEmpty) {
          failingNames.add(name);
        }
      }
    }

    return ServiceabilityResult(
      isServiceable: failingIds.isEmpty,
      nonServiceableVariantIds: failingIds,
      nonServiceableItemNames: failingNames,
    );
  }
}
