import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../commonwidget/common_widgets.dart';
import '../controller/base_controller.dart';
import '../screens/loginscreen.dart';
import '../utils/constants.dart';

class SearchScreenController extends BaseController {
  final searchController = TextEditingController();

  RxBool isSearchItem = false.obs;
  RxBool isCatalog = false.obs;
  RxBool isRecentSearch = false.obs;

  RxString searchText = "Search for products".obs;
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;

  List searchList = [].obs;
  List categoryList = [].obs;
  List suggestedList = [].obs;
  List recentSearchList = [].obs;
  List<bool> selected = List.generate(50, (_) => false).obs;

  Future<dynamic> _makeRequest(String method, String url,
      {Map<String, dynamic>? body}) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final headers = {
        'Accept': 'application/json; charset=UTF-8',
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization': "Bearer ${prefs.getString('token') ?? ''}",
      };

      http.Response response;
      if (method == "GET") {
        response = await http.get(Uri.parse(url), headers: headers);
      } else if (method == "POST") {
        response = await http.post(Uri.parse(url),
            headers: headers, body: json.encode(body));
      } else if (method == "DELETE") {
        response = await http.delete(Uri.parse(url), headers: headers);
      } else {
        throw Exception("Unsupported HTTP method");
      }

      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("Something went wrong (${response.statusCode})");
      }
    } catch (e) {
      print("Request error: $e");
    }
    return null;
  }

  Future<void> getSearchData(BuildContext context) async {
    isSearchItem.value = true;
    final url =
        "${ApiConstants.baseUrl}/search?q=${searchController.text.trim()}&latitude=${lat.value}&longitude=${lng.value}";
    final data = await _makeRequest("GET", url);

    if (data != null) {
      searchList.clear();
      categoryList.clear();

      if (data["products"] != null && data["products"].isNotEmpty) {
        searchList.addAll(data["products"]);
        searchText.value = "Search for products";
      } else {
        searchText.value = "No product found";
      }

      if (data["categories"] != null && data["categories"].isNotEmpty) {
        categoryList.addAll(data["categories"]);
      }
    }
    isSearchItem.value = false;
  }

  Future<void> getCatalogData() async {
    isCatalog.value = true;
    final url = "${ApiConstants.baseUrl}/catalogs?type=suggested";
    final data = await _makeRequest("GET", url);

    if (data != null && data["data"] != null) {
      suggestedList.clear();
      suggestedList.addAll(data["data"]);
    }

    isCatalog.value = false;
  }

  Future<void> getRecentSearchData() async {
    isRecentSearch.value = true;
    final url =
        "${ApiConstants.baseUrl}/recent-searches?latitude=${lat.value}&longitude=${lng.value}";
    final data = await _makeRequest("GET", url);

    if (data != null) {
      recentSearchList.clear();
      recentSearchList.addAll(data);
    }

    isRecentSearch.value = false;
  }

  Future<void> callDeleteRecent(int id) async {
    showLoading();
    final url = "${ApiConstants.baseUrl}/recent-searches/$id";
    final result = await _makeRequest("DELETE", url);

    if (result != null) {
      selected.clear();
      selected.addAll(List.generate(50, (_) => false));
      await getRecentSearchData();
    }

    hideLoading();
  }

  Future<void> callRecentSearch(int productId, String value) async {
    final url = "${ApiConstants.baseUrl}/recent-searches";
    final body = {
      "product_id": productId,
      "search_string": value,
    };
    final result = await _makeRequest("POST", url, body: body);

    if (result != null) {
      await getRecentSearchData();
    }
  }
}
