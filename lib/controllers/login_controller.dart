// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart'; // Ensure this path is correct
import '../core/constant/constants.dart'; // Ensure this path is correct
import '../screens/bottomnavscreen.dart'; // Ensure this path is correct
// Import your login screen if it's not already imported
import '../screens/loginscreen.dart'; // **Add this import, adjust path if needed**
import '../screens/otpverficationscreen.dart'; // Ensure this path is correct
import '../screens/userdetails.dart'; // Ensure this path is correct
import 'base_controller.dart'; // Ensure this path is correct

class LoginController extends BaseController {
  final phoneNumberLogin = TextEditingController();
  final phoneNumberRegister = TextEditingController();
  RxInt secondsRemaining = 30.obs;
  RxString number = "".obs;
  RxString loginError = "".obs;
  RxString otpError = "".obs;
  RxString registerError = "".obs;
  RxString otp = "".obs;

  // RxBool otpClear = false.obs;
  RxBool showButton = false.obs;
  RxBool isGuest = false.obs;
  RxBool enableResend = false.obs;
  final Rx<OtpFieldControllerV2> controller = OtpFieldControllerV2().obs;

  bool checkOtpvalidation(String otpnumber) {
    if (otpnumber.isEmpty) {
      otpError.value = "Enter OTP";
      return false;
    }
    if (otpnumber.length < 4) {
      otpError.value = "The otp field must be 4 digit.";
      return false;
    }
    return true;
  }

  bool checkNumbervalidation(String phone) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(patttern);
    if (phone.isEmpty) {
      loginError.value = "Enter Phone Number";
      return false;
    }
    if (phone.length < 10) {
      loginError.value = "Enter 10 digit Phone Number";
      return false;
    }
    if (!regExp.hasMatch(phone)) {
      loginError.value = "Enter valid Phone Number";
      return false;
    }
    return true;
  }

  bool checkRegistervalidation(String phone) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(patttern);
    if (phone.isEmpty) {
      registerError.value = "Enter Phone Number";
      return false;
    }
    if (phone.length < 10) {
      registerError.value = "Enter 10 digit Phone Number";
      return false;
    }
    if (!regExp.hasMatch(phone)) {
      registerError.value = "Enter valid Phone Number";
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
        loginError.value = "";
        registerError.value = "";
        Get.to(OTPVerficationScreen(
          phoneMunber: number.value,
        ));
      } else if (response.statusCode == 201) {
        print(responseData);
        loginError.value = "";
        registerError.value = "";
        Get.to(OTPVerficationScreen(
          phoneMunber: number.value,
        ));
      } else if (response.statusCode == 400) {
        if (responseData['errors']['phone'] != null) {
          loginError.value = responseData['errors']['phone'][0];
          registerError.value = responseData['errors']['phone'][0];
        }
        if (responseData['errors']['otp'] != null) {
          loginError.value = responseData['errors']['otp'];
          registerError.value = responseData['errors']['otp'];
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        // This 401 is less common for initial registration/login but handled for completeness
        getSnackBar("Authentication failed. Please try again.");
      } else {
        getSnackBar("Login failed");
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
        otpError.value = "";
        Get.to(OTPVerficationScreen(
          phoneMunber: number.value,
        ));
      } else if (response.statusCode == 201) {
        print(responseData);
        otpError.value = "";
        Get.to(OTPVerficationScreen(
          phoneMunber: number.value,
        ));
      } else if (response.statusCode == 400) {
        if (responseData['errors']['phone'] != null) {
          otpError.value = responseData['errors']['phone'][0];
        }
        if (responseData['errors']['otp'] != null) {
          otpError.value = responseData['errors']['otp'];
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else {
        getSnackBar("Resend OTP failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  callGuestUser() async {
    isGuest.value = true;
    final prefs = await SharedPreferences.getInstance();

    // **Check for token before making the call**
    String? token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      getSnackBar("No guest session found. Please try again or log in.");
      // If there's no token, we can't proceed as a guest with this specific API
      // Redirect to login if a guest token is required and missing
      Get.offAll(() => const LoginScreen(
            initialTab: 1,
          ));
      isGuest.value = false;
      return;
    }

    try {
      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/login/guest"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          // **FIX: Removed trailing space from Authorization header**
          "Authorization": "Bearer $token",
        },
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        prefs.setString('token', responseData['meta']['access_token']);
        prefs.setBool("skip", true);
        Get.to(
          () => const BottomNavScreen(),
        );
      } else if (response.statusCode == 201) {
        print(responseData);
        prefs.setString('token', responseData['meta']['access_token']);
        prefs.setBool("skip", true);
        Get.to(
          () => const BottomNavScreen(),
        );
      } else if (response.statusCode == 400) {
        if (responseData['errors']['otp'] != null) {
          print(responseData); // Log specific errors if any
          getSnackBar(responseData['errors']['otp'][0]); // Show message
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        // **Enhanced 401 handling**
        getSnackBar(
            "Your guest session has expired. Please log in or try as guest again.");
        await prefs.clear(); // Clear all stored data
        Get.offAll(() => const LoginScreen(
              initialTab: 1,
            )); // Go to login screen
      } else {
        getSnackBar("Guest login failed");
      }
    } catch (e) {
      print(e.toString());
      getSnackBar("Network error for guest login. Please try again.");
    }
    isGuest.value = false;
  }

  callVerifyOtp(String phone) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();

    // **Check for token before making the call**
    String? token = prefs.getString('token');
    // For OTP verification, it's possible a token isn't strictly needed if it's the first login.
    // However, if the API expects it even for OTP verification, keep this check.
    // If your backend allows OTP verification without a prior token (e.g., for new users),
    // you might remove this check for this specific `callVerifyOtp` function.
    // For now, keeping it assuming the backend might expect *some* form of authentication for `/login`.
    if (token == null || token.isEmpty) {
      // If no token, maybe this is a new user's first OTP verification.
      // If your backend handles this, this check might not be needed for THIS specific API call.
      // However, for authenticated APIs, this pattern is good.
      // For OTP, if it's a new user, they won't have a token.
      // So, you might remove the token check for this specific API call if it's for initial OTP verification.
      // Let's assume for now it *might* be for re-verification, hence a token could exist.
      // If it's for *initial* verification, remove this 'if' block.
      // For existing users re-verifying, this check is good.
    }

    try {
      final Map<String, dynamic> sendData = {
        "phone": phone,
        "otp": otp.value,
      };
      var response = await http.post(Uri.parse("${ApiConstants.baseUrl}/login"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            // **FIX: Removed trailing space from Authorization header**
            "Authorization": "Bearer ${token ?? ''}",
            // Use token if exists, else empty string
          },
          body: json.encode(sendData));
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        otpError.value = "";
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
        prefs.setBool("skip", false);
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
      } else if (response.statusCode == 201) {
        print(responseData);
        otpError.value = "";
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
        prefs.setBool("skip", false);
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
            otpError.value = responseData['errors']['otp'][i];
          }
        }
        if (responseData['errors']['phone'] != null) {
          otpError.value = responseData['errors']['phone'][0];
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        // **Enhanced 401 handling**
        getSnackBar(
            "Authentication failed. Please verify your OTP again or your session has expired.");
        await prefs.clear(); // Clear all stored data
        Get.offAll(() => const LoginScreen(
              initialTab: 1,
            )); // Go to login screen
      } else {
        getSnackBar("OTP verification failed");
      }
    } catch (e) {
      print(e.toString());
      getSnackBar("Network error during OTP verification. Please try again.");
    }
    hideLoading();
  }
}
