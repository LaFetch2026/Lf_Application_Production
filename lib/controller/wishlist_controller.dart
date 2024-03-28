// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../screens/wishlist/createboardscreen.dart';
import '../utils/constants.dart';

class WishlistController extends BaseController {
  RxBool isWishlist = false.obs;
  RxBool isDetails = false.obs;
  RxBool isProduct = false.obs;
  dynamic wishlistDetails = "".obs;
  List wishlistList = [].obs;
  List deleteidList = [].obs;
  List productList = [].obs;
  RxInt addItem = 0.obs;
  RxInt productId = 0.obs;
  final boardNameController = TextEditingController();
  List<bool> selected = List.generate(50, (i) => false).obs;
  /*  final List<Map<String, String>> wishlistList = [
    {'id': '1', "name": 'All item'},
    {'id': '2', "name": 'Bag'},
    {'id': '3', "name": 'All Item'},
    {'id': '4', "name": 'Watch'},
  ].obs; */

  /*  @override
  void onInit() async {
    getWishlistData();
    super.onInit();
  } */

  bool checkIdvalidation(int id) {
    if (id == 0) {
      getSnackBar(
        "Select item",
      );
      return false;
    }
    return true;
  }

  getWishlistData() async {
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
        if (responseData["data"] != null) {
          wishlistList = responseData["data"];
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

  getProductData(String type) async {
    isProduct.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/products?type=$type"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          productList = responseData;
          selected.clear();
          deleteidList.clear();
          selected = List.generate(wishlistList.length, (i) => false);
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
        getSnackBar("get product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isProduct.value = false;
  }

  getWishlistDetails(int wishlistId) async {
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
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/wishlists?name=$name"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 201) {
        print(responseData);
        getSnackBar("Board Created");
        Get.to(
          () => const CreateBoardScreen(
            btnText: "Create board",
          ),
        );
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print("create wishlist failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  callUpdateWishlist(String name, int id) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/wishlists/$id?name=$name"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        getSnackBar("Board Updated");
        /*  Get.to(
          () => const CreateBoardScreen(
            btnText: "Create board",
          ),
        ); */
        Get.close(2);
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print("update wishlist failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  callDeleteWishlist(int wishlistId) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.delete(
        Uri.parse("${ApiConstants.baseUrl}/wishlists/$wishlistId"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      if (response.statusCode == 200) {
        getSnackBar("Board deleted");
        getProductData("express");
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print("delete wishlist failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  callAddItemWishlist() async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/products/$productId/wishlist"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      if (response.statusCode == 200) {
        getSnackBar("item added");
        Get.close(2);
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
    hideLoading();
  }
}
