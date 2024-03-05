// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../utils/constants.dart';

class ProductController extends BaseController {
  RxBool isWishlist = false.obs;
  RxBool isDetails = false.obs;
  dynamic wishlistDetails = "".obs;
  List wishlistList = [].obs;

  getProductData() async {
    isWishlist.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/wishlists"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          wishlistList = responseData;
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
        getSnackBar("get wishlist failed");
      }
    } catch (e) {
      print("error$e");
    }
    isWishlist.value = false;
  }

  getProductDetails(int wishlistId) async {
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/wishlists/$wishlistId"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          wishlistDetails = responseData;
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
        getSnackBar("get wishlist details failed");
      }
    } catch (e) {
      print("error$e");
    }
    isDetails.value = false;
  }

  callCreateWishlist(String name) async {
    showLoading();
    try {
      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/wishlists?name=$name"),
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        getSnackBar("");
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("create wishlist failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  callDeteleWishlist(int wishlistId) async {
    showLoading();
    try {
      var response = await http.delete(
        Uri.parse("${ApiConstants.baseUrl}/wishlists/$wishlistId"),
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        getSnackBar("");
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("delete wishlist failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }
}
