// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../utils/constants.dart';

class ReviewController extends BaseController {
  RxDouble rating = 0.0.obs;
  final comment = TextEditingController();

  bool checkReviewValidation() {
    if (rating.value == 0.0) {
      getSnackBar(
        "Rate the product",
      );
      return false;
    }
    if (comment.text.toString().trim().isEmpty) {
      getSnackBar(
        "Enter Review",
      );
      return false;
    }
    return true;
  }

  callAddReview(int id, int orderId) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "comment": comment.text.toString().trim(),
        "rating": rating.value,
        "order_id": orderId
      };
      var response = await http.put(
          Uri.parse("${ApiConstants.baseUrl}/products/$id/reviews"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
          body: json.encode(sendData));
      if (response.statusCode == 200) {
        getSnackBar("Review added");
        print(response.body);
        Get.close(1);
      } else if (response.statusCode == 201) {
        getSnackBar("Review added");
        print(response.body);
        Get.close(1);
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }
}
