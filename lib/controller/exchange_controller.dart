// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../utils/constants.dart';

class ExchangeController extends BaseController {
  RxBool isDetails = false.obs;
  dynamic productDetails = "".obs;

  getProductDetails(int productId) async {
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/products/$productId"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });

      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          productDetails = responseData;
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
        getSnackBar("get product details failed");
      }
    } catch (e) {
      print("error$e");
    }
    isDetails.value = false;
  }
}
