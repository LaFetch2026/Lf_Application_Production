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

  getSearchData() async {
    isSearchItem.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/search?q=${searchController.text.toString().trim()}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["products"] != null) {
          searchList = responseData["products"];
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
}
