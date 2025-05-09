import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:lafetch/screens/otpverficationscreen.dart';
import 'package:lafetch/screens/userdetails.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class LoginController extends BaseController {
  final phoneNumberLogin = TextEditingController();
  final phoneNumberRegister = TextEditingController();
  final Rx<OtpFieldControllerV2> controller = OtpFieldControllerV2().obs;

  RxInt secondsRemaining = 30.obs;
  RxString number = "".obs;
  RxString otp = "".obs;
  RxString loginError = "".obs;
  RxString otpError = "".obs;
  RxString registerError = "".obs;
  RxBool enableResend = false.obs;
  RxBool isGuest = false.obs;
  RxBool showButton = false.obs;

  Future<dynamic> _makeRequest(String method, String url,
      {Map<String, dynamic>? body}) async {
    final prefs = await SharedPreferences.getInstance();
    final headers = {
      'Accept': 'application/json; charset=UTF-8',
      'Content-Type': 'application/json;charset=UTF-8',
      if (prefs.getString('token') != null)
        'Authorization': "Bearer ${prefs.getString('token')}"
    };

    try {
      final uri = Uri.parse(url);
      late http.Response response;

      if (method == 'POST') {
        response =
            await http.post(uri, headers: headers, body: json.encode(body));
      } else if (method == 'GET') {
        response = await http.get(uri, headers: headers);
      }

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else if (response.statusCode == 400) {
        return responseData;
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
        Get.offAll(() => const LoginScreen(initialTab: 0));
      } else {
        getSnackBar("Request failed");
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

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

  bool _validatePhone(String phone, RxString errorTarget) {
    final pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    final regExp = RegExp(pattern);
    if (phone.isEmpty) {
      errorTarget.value = "Enter Phone Number";
      return false;
    }
    if (phone.length < 10) {
      errorTarget.value = "Enter 10 digit Phone Number";
      return false;
    }
    if (!regExp.hasMatch(phone)) {
      errorTarget.value = "Enter valid Phone Number";
      return false;
    }
    return true;
  }

  bool checkNumbervalidation(String phone) => _validatePhone(phone, loginError);

  bool checkRegistervalidation(String phone) =>
      _validatePhone(phone, registerError);

  Future<void> callRegisterAccount() async {
    showLoading();
    secondsRemaining.value = 30;
    enableResend.value = false;

    final response = await _makeRequest("POST", "${ApiConstants.baseUrl}/login",
        body: {"phone": number.value});

    if (response != null) {
      loginError.value = "";
      registerError.value = "";
      if (response["errors"] != null) {
        loginError.value = response["errors"]["phone"]?[0] ?? "";
        registerError.value = response["errors"]["otp"] ?? "";
      } else {
        Get.to(OTPVerficationScreen(phoneMunber: number.value));
      }
    }
    hideLoading();
  }

  Future<void> callResendOtp(String num) async {
    secondsRemaining.value = 30;
    enableResend.value = false;

    final response = await _makeRequest("POST", "${ApiConstants.baseUrl}/login",
        body: {"phone": num});

    if (response != null) {
      if (response["errors"] != null) {
        otpError.value =
            response["errors"]["phone"]?[0] ?? response["errors"]["otp"] ?? "";
      } else {
        otpError.value = "";
        Get.to(OTPVerficationScreen(phoneMunber: number.value));
      }
    }
  }

  Future<void> callSocailMediaLogin(
      String name, String email, String provider, String providerId) async {
    showLoading();
    secondsRemaining.value = 30;
    enableResend.value = false;

    final response =
        await _makeRequest("POST", "${ApiConstants.baseUrl}/login", body: {
      "email": email,
      "name": name,
      "provider": provider,
      "provider_id": providerId,
    });

    if (response != null) {
      final prefs = await SharedPreferences.getInstance();
      final user = response["data"];
      final token = response["meta"]["access_token"];
      prefs.setString('token', token);
      prefs.setInt('userId', user["id"]);
      if (user["phone"] != null) prefs.setString('phonenumber', user["phone"]);
      if (user["email"] != null) prefs.setString('email', user["email"]);
      if (user["gender"] != null) prefs.setInt('gender', user["gender"]);
      if (user["name"] != null) {
        prefs.setString('name', user["name"]);
        Get.offAll(() => const BottomNavScreen());
      } else {
        Get.off(() => const UserDetailsScreen());
      }
    }
    hideLoading();
  }

  Future<void> callGuestUser() async {
    isGuest.value = true;

    final response =
        await _makeRequest("POST", "${ApiConstants.baseUrl}/login/guest");

    if (response != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', response['meta']['access_token']);
      prefs.setBool("skip", true);
      Get.to(() => const BottomNavScreen());
    }

    isGuest.value = false;
  }

  Future<void> callVerifyOtp(String phone) async {
    showLoading();

    final response = await _makeRequest("POST", "${ApiConstants.baseUrl}/login",
        body: {"phone": phone, "otp": otp.value});

    if (response != null) {
      final prefs = await SharedPreferences.getInstance();
      final user = response["data"];
      final token = response["meta"]["access_token"];

      otpError.value = "";
      prefs.setString('token', token);
      prefs.setInt('userId', user["id"]);
      if (user["phone"] != null) prefs.setString('phonenumber', user["phone"]);
      if (user["email"] != null) prefs.setString('email', user["email"]);
      if (user["gender"] != null) prefs.setInt('gender', user["gender"]);
      prefs.setBool("skip", false);

      if (user["name"] != null) {
        prefs.setString('name', user["name"]);
        Get.offAll(() => const BottomNavScreen());
      } else {
        Get.off(() => const UserDetailsScreen());
      }
    }

    hideLoading();
  }
}
