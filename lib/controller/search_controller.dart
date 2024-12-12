// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../screens/loginscreen.dart';
import '../utils/constants.dart';

class SearchScreenController extends BaseController {
  TextEditingController searchController = TextEditingController();
  RxBool isSearchItem = false.obs;
  List searchList = [].obs;
  List categoryList = [].obs;
  RxBool isRecentSearch = false.obs;
  List recentSearchList = [].obs;
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  RxString searchText = "Search for products".obs;

  getSearchData() async {
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
        }
        if (responseData["categories"] != null &&
            responseData["categories"].isNotEmpty) {
          categoryList = responseData["categories"];
          searchText.value = "Search for products";
        } else {
          searchText.value = "No product found";
          categoryList.clear();
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
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
        getSnackBar("Server Error");
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
        getSnackBar("Server Error");
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
