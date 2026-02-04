// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constant/constants.dart';
import '../models/newsletter_model.dart';
import 'base_controller.dart';

class NewsletterController extends BaseController {
  RxBool isLoading = false.obs;
  RxList<NewsletterModel> newsletters = <NewsletterModel>[].obs;

  // Request deduplication flag
  bool _isRequestInProgress = false;

  // Cache duration in milliseconds (5 minutes)
  static const int _cacheDuration = 5 * 60 * 1000;
  DateTime? _lastFetchTime;

  /// Fetch newsletters from API
  Future<void> getNewsletters({bool forceRefresh = false}) async {
    // Prevent concurrent duplicate requests
    if (_isRequestInProgress) {
      print('Newsletter request already in progress, skipping...');
      return;
    }

    // Check cache validity (unless force refresh)
    if (!forceRefresh && _lastFetchTime != null && newsletters.isNotEmpty) {
      final timeSinceLastFetch =
          DateTime.now().difference(_lastFetchTime!).inMilliseconds;
      if (timeSinceLastFetch < _cacheDuration) {
        print('Using cached newsletters data');
        return;
      }
    }

    _isRequestInProgress = true;
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/newsletters'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body['status'] == 200 && body['data'] != null) {
          final List<dynamic> data = body['data'] as List<dynamic>;

          // Parse newsletters and filter only active ones
          final List<NewsletterModel> parsedNewsletters = data
              .map((e) => NewsletterModel.fromJson(e as Map<String, dynamic>))
              .where((n) => n.isActive)
              .toList();

          // Take top 5 newsletters
          newsletters.value = parsedNewsletters.take(5).toList();
          _lastFetchTime = DateTime.now();

          print('Fetched ${newsletters.length} newsletters');
        } else {
          print('Newsletter API returned error: ${body['message']}');
        }
      } else if (response.statusCode == 401) {
        print('Newsletter API: Unauthorized');
      } else {
        print('Newsletter API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching newsletters: $e');
    } finally {
      isLoading.value = false;
      _isRequestInProgress = false;
    }
  }

  /// Clear cache and fetch fresh data
  Future<void> refreshNewsletters() async {
    _lastFetchTime = null;
    await getNewsletters(forceRefresh: true);
  }
}
