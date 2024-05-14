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

class OrderController extends BaseController {
  RxBool isOrder = false.obs;
  RxBool isDetails = false.obs;
  dynamic orderDetails = "".obs;
  RxString queryText = "".obs;
  List orderList = [].obs;
  List deliveriesList = [].obs;
  RxBool loadMore = false.obs;
  RxBool hasnextpage = true.obs;
  RxInt addressId = 0.obs;
  RxInt page = 1.obs;
  RxInt status = 1.obs;
  ScrollController listController = ScrollController();
  final searchController = TextEditingController();
  final List filterList = [
    'Cart',
    'Pending',
    'Confirmed',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
    'Completed',
    'Exchange',
    'Approved',
    'Rejected',
  ].obs;

  final List filterId = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
  ].obs;

  getOrderData() async {
    isOrder.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/orders?status=${status.value}&q=${queryText.value}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          orderList = responseData["data"];
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
        getSnackBar("get order failed ${response.statusCode}");
      }
    } catch (e) {
      print("error$e");
    }
    isOrder.value = false;
  }

  fetchMoreData() async {
    if (hasnextpage.value == true &&
        isOrder.value == false &&
        loadMore.value == false) {
      loadMore.value = true;
      page.value += 1;
      print(page.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/orders?page=${page.value}&status=${status.value}&q=${queryText.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              orderList.addAll(responseData['data']);
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
          getSnackBar("fetch order failed");
        }
      } catch (e) {
        print("error$e");
      }
      loadMore.value = false;
    }
  }

  getOrderDetails(int orderId) async {
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/orders/$orderId"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        if (responseData != null) {
          orderDetails = responseData;
          if (responseData["address"] != null) {
            addressId.value = responseData["address"]["id"];
          }
          if (responseData["deliveries"] != null) {
            deliveriesList = responseData["deliveries"];
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
        getSnackBar("get order details failed");
      }
    } catch (e) {
      print("error$e");
    }
    isDetails.value = false;
  }
}
