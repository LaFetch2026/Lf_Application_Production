// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../common/widget/other/confirmdelete.dart';
import '../core/constant/constants.dart';
import '../screens/bottomnavscreen.dart';
import '../screens/loginscreen.dart';
import 'base_controller.dart';

class ProfileController extends BaseController {
  RxBool showList = false.obs;
  RxBool isProfile = false.obs;
  RxBool isEditNumber = true.obs;
  RxBool isAddress = false.obs;
  RxBool isPhoneNumber = false.obs;
  RxInt genderId = 0.obs;
  dynamic defaultAddress = "".obs;
  RxString queryText = "".obs;
  List addressList = [].obs;
  dynamic profileDetails = "".obs;
  RxBool isOrder = false.obs;
  RxBool isOffer = false.obs;
  RxBool isPermotion = true.obs;
  RxInt orderValue = 0.obs;
  RxInt offerValue = 0.obs;
  RxInt permotionValue = 0.obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final gerderController = TextEditingController();
  final phoneController = TextEditingController();
  RxString nameError = "".obs;
  RxString phoneError = "".obs;
  RxString emailError = "".obs;
  RxString genderError = "".obs;

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
      // getSnackBar("Enter Name");
      nameError.value = "Enter Name";
      return false;
    }
    if (phone.isEmpty) {
      /*  getSnackBar(
        "Enter Phone Number",
      ); */
      nameError.value = "";
      phoneError.value = "Enter Phone Number";
      return false;
    }
    if (phone.length < 10) {
      /*  getSnackBar(
        "Enter 10 digit Phone Number",
      ); */
      nameError.value = "";
      phoneError.value = "Enter 10 digit Phone Number";
      return false;
    }
    if (!regExPhone.hasMatch(phone)) {
      /*  getSnackBar(
        "Enter valid Phone Number",
      ); */
      nameError.value = "";
      phoneError.value = "Enter valid Phone Number";
      return false;
    }
    if (email.isEmpty) {
      //getSnackBar("Enter Email");
      nameError.value = "";
      phoneError.value = "";
      emailError.value = "Enter Email";
      return false;
    }
    if (!regExp.hasMatch(email)) {
      // getSnackBar("Enter Valid Email Id");
      nameError.value = "";
      phoneError.value = "";
      emailError.value = "Enter Valid Email Id";
      return false;
    }
    if (gender == 0) {
      // getSnackBar("Select Gender");
      nameError.value = "";
      phoneError.value = "";
      emailError.value = "";
      genderError.value = "Select Gender";
      return false;
    }
    nameError.value = "";
    phoneError.value = "";
    genderError.value = "";
    emailError.value = "";
    return true;
  }

  bool checkUservalidation(String name, String email, int gender) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(p);

    if (name.isEmpty) {
      // getSnackBar("Enter Name");
      nameError.value = "Enter Name";
      return false;
    }
    if (email.isEmpty) {
      // getSnackBar("Enter Email");
      nameError.value = "";
      emailError.value = "Enter Email";
      return false;
    }
    if (!regExp.hasMatch(email)) {
      //  getSnackBar("Enter Valid Email Id");
      nameError.value = "";
      emailError.value = "Enter Valid Email Id";
      return false;
    }
    if (gender == 0) {
      // getSnackBar("Select Gender");
      nameError.value = "";
      emailError.value = "";
      genderError.value = "Select Gender";
      return false;
    }
    nameError.value = "";
    emailError.value = "";
    genderError.value = "";
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
          if (responseData['phone'] != null) {
            prefs.setString('phone_number', responseData['phone']);
          }
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        /*  Get.to(
          () => const LoginScreen(
            initialTab: 0,
          ),
        ); */
        //getSnackBar("Authentication failed");
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
            // getSnackBar("Profile updated");
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
            if (responseData['data']['phone'] != null) {
              prefs.setString('phone_number', responseData['data']['phone']);
            }
            isPhoneNumber.value = false;
            Get.close(1);
          } else {
            if (check == false) {
              isPhoneNumber.value = true;
              // getSnackBar("Enter Otp");
              phoneError.value = "Enter OTP";
            } else {
              if (responseData['data']['email'] != null) {
                prefs.setString('email', responseData['data']['email']);
              }
              if (responseData['data']['gender'] != null) {
                prefs.setInt('gender', responseData['data']['gender']);
              }
              if (responseData['data']['name'] != null) {
                prefs.setString('name', responseData['data']['name']);
              }
              if (responseData['data']['phone'] != null) {
                prefs.setString('phone_number', responseData['data']['phone']);
              }
              //  getSnackBar("Profile updated");
              Get.close(1);
            }
          }
        } else {
          // getSnackBar("Profile updated");
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
          if (responseData['data']['phone'] != null) {
            prefs.setString('phone_number', responseData['data']['phone']);
          }
          Get.offAll(
            () => const BottomNavScreen(),
          );
        }
      } else if (response.statusCode == 400) {
        print(response.body);

        if (responseData['errors']['phone'] != null) {
          //getSnackBar(responseData['errors']['phone']);
          phoneError.value = responseData['errors']['phone'];
        }
        if (responseData['errors']['otp'] != null) {
          for (var i = 0; i < responseData['errors']['otp'].length; i++) {
            // getSnackBar(responseData['errors']['otp'][i]);
            phoneError.value = responseData['errors']['otp'][i];
          }
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
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
          Uri.parse(
              "${ApiConstants.baseUrl}/addresses?address=${queryText.value}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          addressList = responseData;
          print(addressList);
          if (addressList.isNotEmpty) {
            for (var i = 0; i < addressList.length; i++) {
              if (addressList[i]["default_shipping"]) {
                defaultAddress = addressList[i];
              }
            }
          }
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
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
        // getSnackBar("Address removed");
        getAddressData();
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print("delete address failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  callNotificationSetting() async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic sendData = {
        "order_notification_enabled": orderValue.value,
        "offer_notification_enabled": offerValue.value,
        "promotional_notification_enabled": permotionValue.value,
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
        getProfileData();
        Get.back();
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("notification failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
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
        GoogleSignIn googleSignIn = GoogleSignIn();
        googleSignIn.signOut();
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
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

  void callDeleteAccount() async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.post(
          Uri.parse("${ApiConstants.baseUrl}/account-deletion"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      if (response.statusCode == 200) {
        Get.off(
          () => const ConfirmDeleteScreen(),
        );
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 400) {
        var responseData = json.decode(response.body);
        print(responseData);
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
      } else {
        getSnackBar("account delete failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }
}
