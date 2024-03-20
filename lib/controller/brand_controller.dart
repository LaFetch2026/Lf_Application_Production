// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../utils/constants.dart';

class BrandController extends BaseController {
  TextEditingController searchController = TextEditingController();
  int page = 1;
  RxBool loadMore = false.obs;
  RxBool hasnextpage = true.obs;
  ScrollController listController = ScrollController();
  RxString queryText = "".obs;
  RxBool isBrand = false.obs;
  List brandList = [].obs;
  RxString brandName = "".obs;
  RxString text = "Expand All".obs;
  RxBool showAllBrand = false.obs;
  RxBool isCategory = false.obs;
  List categoryList = [].obs;
  List<String> childItem = [
    "Salwar Suits",
    "Printed",
    "Clothing Clothing Clothing",
    "Duffle bags",
    "Tuxedos Tuxedos Tuxedos",
  ].obs;
  List<bool> selected = List.generate(50, (i) => false).obs;

  @override
  void onInit() async {
    listController.addListener(() {
      fetchMoreData();
      update();
    });
    super.onInit();
  }

  getBrandData() async {
    isBrand.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/brands?q=$queryText"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          brandList = responseData["data"];
          selected.clear();
          selected = List.generate(brandList.length, (i) => false);
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
        getSnackBar("get brand failed");
      }
    } catch (e) {
      print("error$e");
    }
    isBrand.value = false;
  }

  fetchMoreData() async {
    if (hasnextpage.value == true &&
        isBrand.value == false &&
        loadMore.value == false) {
      loadMore.value = true;
      page += 1;
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse("${ApiConstants.baseUrl}/brands?q=$queryText&page=$page"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              brandList.addAll(responseData['data']);
            } else {
              hasnextpage.value = false;
            }
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
          getSnackBar("fetch brand failed");
        }
      } catch (e) {
        print("error$e");
      }
      loadMore.value = false;
    }
  }

  getCategoryData(int id) async {
    isCategory.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/categories?brand_id=$id"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          categoryList = responseData;
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
        getSnackBar("get category failed");
      }
    } catch (e) {
      print("error$e");
    }
    isCategory.value = false;
  }
}
