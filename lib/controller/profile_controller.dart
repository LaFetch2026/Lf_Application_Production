// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../screens/bottomnavscreen.dart';
import '../utils/common_widgets.dart';

class ProfileController extends BaseController {
  RxBool showList = false.obs;
  RxInt genderId = 0.obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final gerderController = TextEditingController();
  final phoneController = TextEditingController();

  final RxList<String> genderList = [
    'Male',
    'Female',
    'Non-Binary',
  ].obs;

  bool checkvalidation(String name, String email, int gender) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(p);
    if (name.isEmpty) {
      getSnackBar("Enter Name");
      return false;
    }
    if (email.isEmpty) {
      getSnackBar("Enter Email");
      return false;
    }
    if (!regExp.hasMatch(email)) {
      getSnackBar("Enter Valid Email Id");
      return false;
    }
    if (gender == 0) {
      getSnackBar("Select Gender");
      return false;
    }
    return true;
  }

  callupdateProfile() async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "name": nameController.text.toString().trim(),
        "email": emailController.text.toString().trim(),
        "gender": genderId.value,
      };
      var response =
          await http.put(Uri.parse("${ApiConstants.baseUrl}/profile"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                'Content-Type': 'application/json;charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              },
              body: json.encode(sendData));
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        if (responseData['data']['email'] != null) {
          prefs.setString('email', responseData['data']['email']);
        }
        if (responseData['data']['gender'] != null) {
          prefs.setInt('gender', responseData['data']['gender']);
        }
        if (responseData['data']['name'] != null) {
          prefs.setString('name', responseData['data']['name']);
        }
        Get.to(
          () => const BottomNavScreen(),
        );
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("profile update failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }
}
