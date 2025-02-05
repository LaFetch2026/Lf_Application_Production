// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../utils/constants.dart';

class CatalogController extends BaseController {
  RxBool isCatalog = false.obs;
  List catalogList = [].obs;
  RxBool isCategory = false.obs;
  List categoryProductList = [].obs;

  getCatalogData(int type) async {
    isCatalog.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/catalogs?gender_type=$type"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          catalogList = responseData["data"];
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
        getSnackBar("get catalog failed");
      }
    } catch (e) {
      print("error$e");
    }
    isCatalog.value = false;
  }

  getCategoryProductData(int catalogId) async {
    isCategory.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/catalogs/$catalogId"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["categories"] != null) {
          print(responseData);
          categoryProductList = responseData["categories"];
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

  callAddProductToWishlist(
    int wishlistId,
    int id,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/products/$id/wishlist/$wishlistId"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseData["wishlisted"]) {
          Get.close(1);
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("item add failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
