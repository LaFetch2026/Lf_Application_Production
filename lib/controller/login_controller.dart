// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/otpverficationscreen.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../screens/userdetails.dart';

class LoginController extends BaseController {
  final phoneNumberLogin = TextEditingController();
  final phoneNumberRegister = TextEditingController();
  RxInt secondsRemaining = 30.obs;
  RxString number = "".obs;
  RxString otp = "".obs;
  RxBool otpClear = false.obs;
  RxBool showButton = false.obs;
  RxBool enableResend = false.obs;

  bool checkOtpvalidation(String otpnumber) {
    if (otpnumber.isEmpty) {
      getSnackBar(
        "Enter OTP",
      );
      return false;
    }
    if (otpnumber.length < 4) {
      getSnackBar(
        "The otp field must be 4 digit.",
      );
      return false;
    }
    return true;
  }

  bool checkNumbervalidation(String phone) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(patttern);
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
    if (!regExp.hasMatch(phone)) {
      getSnackBar(
        "Enter valid Phone Number",
      );
      return false;
    }
    return true;
  }

  callRegisterAccount() async {
    showLoading();
    secondsRemaining.value = 30;
    enableResend.value = false;
    try {
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/login"), body: {
        "phone": number.value,
      });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        getSnackBar(responseData['message']);
        Get.to(OTPVerficationScreen(phoneMunber: number.value));
      } else if (response.statusCode == 400) {
        if (responseData['errors']['phone'] != null) {
          getSnackBar(responseData['errors']['phone'][0]);
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("login failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  callResendOtp(String num) async {
    secondsRemaining.value = 30;
    enableResend.value = false;
    try {
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/login"), body: {
        "phone": num,
      });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        getSnackBar(responseData['message']);
        Get.to(OTPVerficationScreen(phoneMunber: number.value));
      } else if (response.statusCode == 400) {
        if (responseData['errors']['phone'] != null) {
          getSnackBar(responseData['errors']['phone'][0]);
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("login failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  callVerifyOtp(String phone) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/login"), body: {
        "phone": phone,
        "otp": otp.value,
      });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        getSnackBar(responseData['message']);
        prefs.setString('token', responseData['meta']['access_token']);
        prefs.setInt('userId', responseData['data']['id']);
        if (responseData['data']['phone'] != null) {
          prefs.setString('phonenumber', responseData['data']['phone']);
        }
        if (responseData['data']['email'] != null) {
          prefs.setString('email', responseData['data']['email']);
        }
        if (responseData['data']['gender'] != null) {
          prefs.setInt('gender', responseData['data']['gender']);
        }
        if (responseData['data']['name'] != null) {
          prefs.setString('name', responseData['data']['name']);
          Get.offAll(
            () => const BottomNavScreen(),
          );
        } else {
          Get.off(
            () => const UserDetailsScreen(),
          );
        }
      } else if (response.statusCode == 400) {
        if (responseData['errors']['otp'] != null) {
          for (var i = 0; i < responseData['errors']['otp'].length; i++) {
            getSnackBar(responseData['errors']['otp'][i]);
          }
        }
        if (responseData['errors']['phone'] != null) {
          getSnackBar(responseData['errors']['phone'][0]);
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("otp failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }
}
