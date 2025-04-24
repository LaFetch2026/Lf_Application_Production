import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/loginscreen.dart';
import '../utils/constants.dart';

class SearchScreenController extends BaseController {
  TextEditingController searchController = TextEditingController();
  RxBool isSearchItem = false.obs;
  RxBool isCatalog = false.obs;
  List searchList = [].obs;
  List categoryList = [].obs;
  List suggestedList = [].obs;
  RxBool isRecentSearch = false.obs;
  List recentSearchList = [].obs;
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  List<bool> selected = List.generate(50, (i) => false).obs;
  RxString searchText = "Search for products".obs;

  getSearchData(BuildContext context) async {
    isSearchItem.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/search?q=${searchController.text.toString().trim()}&latitude=${lat.value}&longitude=${lng.value}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["products"] != null &&
            responseData["products"].isNotEmpty) {
          searchList = responseData["products"];
          searchText.value = "Search for products";
        } else {
          searchText.value = "No product found";
          searchList.clear();
          // FocusScope.of(context).unfocus();
        }
        if (responseData["categories"] != null &&
            responseData["categories"].isNotEmpty) {
          categoryList = responseData["categories"];
          searchText.value = "Search for products";
        } else {
          // FocusScope.of(context).unfocus();
          searchText.value = "No product found";
          categoryList.clear();
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get search failed");
      }
    } catch (e) {
      print("error$e");
    }
    isSearchItem.value = false;
  }

  getCatalogData() async {
    isCatalog.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/catalogs?type=suggested"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          suggestedList = responseData["data"];
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get catalog failed");
      }
    } catch (e) {
      print("error$e");
    }
    isCatalog.value = false;
  }

  getRecentSearchData() async {
    isRecentSearch.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/recent-searches?latitude=${lat.value}&longitude=${lng.value}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          recentSearchList = responseData;
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get recent search failed");
      }
    } catch (e) {
      print("error$e");
    }
    isRecentSearch.value = false;
  }

  callDeleteRecent(int id) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.delete(
        Uri.parse("${ApiConstants.baseUrl}/recent-searches/$id"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      if (response.statusCode == 200) {
        selected.clear();
        selected = List.generate(50, (i) => false).obs;
        getRecentSearchData();
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print("delete wishlist failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  callRecentSearch(int productId, String value) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "product_id": productId,
        "search_string": value,
      };
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/recent-searches"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                'Content-Type': 'application/json;charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              },
              body: json.encode(sendData));
      if (response.statusCode == 200) {
        getRecentSearchData();
      } else if (response.statusCode == 201) {
        getRecentSearchData();
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
