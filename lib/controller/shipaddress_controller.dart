// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../commonwidget/common_widgets.dart';
import '../screens/loginscreen.dart';
import '../screens/paymentscreen.dart';
import '../utils/constants.dart';

class ShipAddressController extends BaseController {
  RxBool showList = false.obs;
  RxBool onButton = false.obs;
  RxBool isCheck = false.obs;
  RxInt defaultBilling = 0.obs;
  RxInt defaultShipping = 0.obs;
  RxString type = "".obs;
  RxString phonenumber = "".obs;
  List cityList = [].obs;
  RxInt cityId = 0.obs;
  final nameController = TextEditingController();
  final pincodeController = TextEditingController();
  final stateController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final localityController = TextEditingController();
  bool checkvalidation(String phone) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(patttern);
    if (nameController.text.toString().trim().isEmpty) {
      getSnackBar("Enter Name");
      return false;
    }
    if (phone.isEmpty) {
      getSnackBar("Enter Phone Number");
      return false;
    }
    if (phone.length < 10) {
      getSnackBar(
        "Enter 10 digit Phone Number",
      );
      return false;
    }
    if (!regExp.hasMatch(phone)) {
      getSnackBar(
        "Enter valid Phone Number",
      );
      return false;
    }
    if (pincodeController.text.toString().trim().isEmpty) {
      getSnackBar(
        "Enter Pincode",
      );
      return false;
    }
    if (pincodeController.text.toString().trim().length < 6) {
      getSnackBar(
        "The pincode must be 6 digit.",
      );
      return false;
    }
    if (addressController.text.toString().trim().isEmpty) {
      getSnackBar("Enter Address");
      return false;
    }
    if (localityController.text.toString().trim().isEmpty) {
      getSnackBar("Enter Locality");
      return false;
    }
    /*   if (cityController.text.toString().trim().isEmpty) {
      getSnackBar("Enter City");
      return false;
    } */
    if (stateController.text.toString().trim().isEmpty) {
      getSnackBar("Select City");
      return false;
    }
    if (type.value.isEmpty) {
      getSnackBar("Select Address Type");
      return false;
    }
    return true;
  }

  getCitiesData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(Uri.parse("${ApiConstants.baseUrl}/cities"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          cityList = responseData["data"];
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
  }

  callSaveAddress() async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "name": nameController.text.toString().trim(),
        "phone": phonenumber.value,
        "city_id": cityId.value,
        "type": type.value,
        "address": addressController.text.toString().trim(),
        "zip": pincodeController.text.toString().trim(),
        "locality": localityController.text.toString().trim(),
        "default_billing": defaultBilling.value,
        "default_shipping": defaultShipping.value,
      };
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/addresses"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                'Content-Type': 'application/json;charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              },
              body: json.encode(sendData));
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        Get.to(const PaymentScreen());
      } else if (response.statusCode == 201) {
        print(responseData);
        Get.to(const PaymentScreen());
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
    hideLoading();
  }
}
