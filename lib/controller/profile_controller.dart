// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../screens/bottomnavscreen.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';

import '../screens/loginscreen.dart';

class ProfileController extends BaseController {
  RxBool showList = false.obs;
  RxBool isProfile = false.obs;
  RxBool isEditNumber = true.obs;
  RxBool isAddress = false.obs;
  RxBool isPhoneNumber = false.obs;
  RxInt genderId = 0.obs;
  List addressList = [].obs;
  dynamic profileDetails = "".obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final gerderController = TextEditingController();
  final phoneController = TextEditingController();

  final RxList<String> genderList = [
    'Male',
    'Female',
    'Non-Binary',
  ].obs;

  bool checkvalidation(String name, String phone, String email, int gender) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(p);
    RegExp regExPhone = RegExp(patttern);
    if (name.isEmpty) {
      getSnackBar("Enter Name");
      return false;
    }
    if (phone.isEmpty) {
      getSnackBar(
        "Enter Phone Number",
      );
      return false;
    }
    if (phone.length < 10) {
      getSnackBar(
        "Enter 10 digit Phone Number",
      );
      return false;
    }
    if (!regExPhone.hasMatch(phone)) {
      getSnackBar(
        "Enter valid Phone Number",
      );
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

  bool checkUservalidation(String name, String email, int gender) {
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

  getProfileData() async {
    isProfile.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/profile"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          profileDetails = responseData;
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
    isProfile.value = false;
  }

  callupdateProfile(String type, String phone, String otp, bool check) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic sendData;
      if (type == "user" && otp.isEmpty) {
        sendData = {
          "name": nameController.text.toString().trim(),
          "email": emailController.text.toString().trim(),
          "gender": genderId.value,
        };
      } else if (type == "edit" && check == true && otp.isEmpty) {
        sendData = {
          "name": nameController.text.toString().trim(),
          "email": emailController.text.toString().trim(),
          "gender": genderId.value,
        };
      } else if (type == "edit" && otp.isNotEmpty) {
        sendData = {
          "name": nameController.text.toString().trim(),
          "email": emailController.text.toString().trim(),
          "gender": genderId.value,
          "phone": phone,
          "otp": otp
        };
      } else {
        sendData = {
          "name": nameController.text.toString().trim(),
          "email": emailController.text.toString().trim(),
          "gender": genderId.value,
          "phone": phone,
        };
      }

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
        if (type == "edit") {
          if (otp.isNotEmpty) {
            getSnackBar("Profile updated");
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
            isPhoneNumber.value = false;
            Get.close(1);
          } else {
            if (check == false) {
              isPhoneNumber.value = true;
              getSnackBar("Enter Otp");
            } else {
              getSnackBar("Profile updated");
              Get.close(1);
            }
          }
        } else {
          getSnackBar("Profile updated");
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
          Get.offAll(
            () => const BottomNavScreen(),
          );
        }
      } else if (response.statusCode == 400) {
        print(response.body);

        if (responseData['errors']['phone'] != null) {
          getSnackBar(responseData['errors']['phone']);
        }
        if (responseData['errors']['otp'] != null) {
          for (var i = 0; i < responseData['errors']['otp'].length; i++) {
            getSnackBar(responseData['errors']['otp'][i]);
          }
        }
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

  getAddressData() async {
    isAddress.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/addresses"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          addressList = responseData;
          print(addressList);
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
    isAddress.value = false;
  }

  callRemoveAddress(int addressId) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.delete(
        Uri.parse("${ApiConstants.baseUrl}/addresses/$addressId"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      if (response.statusCode == 200) {
        getSnackBar("Address removed");
        getAddressData();
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print("delete address failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void callLogout() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.post(
          Uri.parse("${ApiConstants.baseUrl}/logout"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
      } else {
        getSnackBar("logout failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
