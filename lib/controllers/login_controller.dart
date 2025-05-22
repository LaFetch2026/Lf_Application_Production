import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Internal imports
import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../feature/auth/otpverficationscreen.dart';
import '../feature/auth/userdetails.dart';
import '../feature/profile/bottomnavscreen.dart';
import 'base_controller.dart';

class LoginController extends BaseController {
  final phoneNumberLogin = TextEditingController();
  final phoneNumberRegister = TextEditingController();
  RxInt secondsRemaining = 30.obs;
  RxString number = "".obs;
  RxString loginError = "".obs;
  RxString otpError = "".obs;
  RxString registerError = "".obs;
  RxString otp = "".obs;
  RxBool showButton = false.obs;
  RxBool isGuest = false.obs;
  RxBool enableResend = false.obs;
  final Rx<OtpFieldControllerV2> controller = OtpFieldControllerV2().obs;
  RxBool isSignIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      Get.offAll(() => const BottomNavScreen());
    }
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
    return checkNumbervalidation(phone); // Same validation logic
  }

  Future<void> callRegisterAccount() async {
    isSignIn.value = false;
    showLoading();
    secondsRemaining.value = 30;
    enableResend.value = false;

    try {
      final phoneNumber =
          number.value.startsWith("+91") ? number.value : "+91${number.value}";

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/sign-up-send-otp"),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "phone": phoneNumber,
        }),
      );

      final responseData = json.decode(response.body);
      print("Register API response: $responseData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        loginError.value = "";
        registerError.value = "";
        Get.to(() => OTPVerficationScreen(
              phoneMunber: phoneNumber,
            ));
      } else if (response.statusCode == 400) {
        final error = responseData['errors']?['phone']?[0];
        if (error != null) {
          loginError.value = error;
          registerError.value = error;
        } else {
          getSnackBar("Invalid phone number or already registered.");
        }
      } else {
        getSnackBar("Registration failed. Please try again.");
        print("Unexpected status: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception in callRegisterAccount: $e");
      getSnackBar("Something went wrong. Please check your internet.");
    } finally {
      hideLoading();
    }
  }

  callResendOtp(String num) async {
    secondsRemaining.value = 30;
    enableResend.value = false;
    try {
      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/resend-otp"),
        body: {"phone": num},
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        otpError.value = "";
        Get.to(OTPVerficationScreen(phoneMunber: number.value));
      } else {
        getSnackBar("Resend OTP failed");
      }
    } catch (e) {
      print(e.toString());
    } finally {
      hideLoading();
    }
  }

  callVerifyOtp(String phone) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "phone": phone,
        "otp": otp.value,
      };

      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/verify-otp"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(sendData),
      );

      var responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = responseData['data'];
        final accessToken = responseData['token'];
        if (accessToken != null) prefs.setString('token', accessToken);
        if (data != null) {
          prefs.setInt('userId', data['id']);
          prefs.setString('name', data['fullName']);
          prefs.setString('email', data['email']);
          prefs.setString('phonenumber', data['phone']);
          if (data['gender'] != null) {
            prefs.setInt('gender', data['gender']);
          }
          Get.offAll(() => const BottomNavScreen());
        } else {
          isSignIn.value
              ? Get.offAll(() => const BottomNavScreen())
              : Get.off(() => const UserDetailsScreen());
        }
      } else {
        getSnackBar("OTP verification failed.");
      }
    } catch (e) {
      print("❌ Exception in callVerifyOtp: $e");
      getSnackBar("Something went wrong.");
    } finally {
      hideLoading();
    }
  }

  Future<void> callUpdateUserProfile(
      String fullName, String email, String gender, String phone) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();

    try {
      final Map<String, dynamic> body = {
        "fullName": fullName,
        "email": email,
        "phone": phone,
        "type": "signup"
      };
      if (gender.isNotEmpty) body['gender'] = gender;

      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/auth/update-user-profile"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      var responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = responseData['data'];
        final accessToken = data['token'];
        final refreshToken = data['refreshToken'];

        if (accessToken != null) prefs.setString('token', accessToken);
        if (refreshToken != null) prefs.setString('refreshToken', refreshToken);

        prefs.setInt('userId', data['id']);
        prefs.setString('name', data['fullName']);
        prefs.setString('email', data['email']);
        prefs.setString('phonenumber', data['phone']);
        if (data['gender'] != null) {
          prefs.setInt('gender', data['gender']);
        }
        Get.offAll(() => const BottomNavScreen());
      } else {
        getSnackBar("Failed to update profile.");
      }
    } catch (e) {
      print("❌ Error updating profile: $e");
      getSnackBar("Something went wrong.");
    } finally {
      hideLoading();
    }
  }

  Future<void> callRefreshToken() async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null || refreshToken.isEmpty) {
      getSnackBar("No refresh token found.");
      hideLoading();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/refresh-token"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({"refreshToken": refreshToken}),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final newAccessToken = responseData['token'];
        if (newAccessToken != null) {
          prefs.setString('token', newAccessToken);
          getSnackBar("Token refreshed successfully");
        } else {
          getSnackBar("Failed to refresh token: No token returned");
        }
      } else {
        getSnackBar("Token refresh failed");
      }
    } catch (e) {
      print("❌ Error refreshing token: $e");
      getSnackBar("Something went wrong while refreshing token.");
    } finally {
      hideLoading();
    }
  }

  // New functions for sign in
  callSignInSendOtp(String phone) async {
    isSignIn.value = true; //set the value to true for sign in process
    showLoading();
    secondsRemaining.value = 30;
    enableResend.value = false;
    try {
      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/sign-in-send-otp"),
        body: {
          "phone": number.value.startsWith("+91")
              ? number.value
              : "+91${number.value}",
        },
      );

      print('${number.value}');
      var responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        loginError.value = "";
        final formattedPhone = phone.startsWith("+91") ? phone : "+91$phone";
        Get.to(OTPVerficationScreen(phoneMunber: formattedPhone));
        // Use the passed phone number
        hideLoading(); // Hide loading here after navigation
      } else if (response.statusCode == 400) {
        if (responseData['errors']['phone'] != null) {
          loginError.value = responseData['errors']['phone'][0];
        }
        if (responseData['errors']['otp'] != null) {
          loginError.value = responseData['errors']['otp'];
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("login failed");
      }
    } catch (e) {
      print(e.toString());
    } finally {
      hideLoading();
    }
  }

  callSignInVerifyOtp(String phone) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final String verificationType =
          isSignIn.value ? "login" : "signup"; // Determine type based on flow

      final formattedPhone =
          number.value.startsWith("+91") ? number.value : "+91${number.value}";

      final Map<String, dynamic> sendData = {
        "phone": formattedPhone,
        "otp": otp.value,
        "type": verificationType,
      };

      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/verify-otp"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(sendData),
      );

      var responseData = json.decode(response.body);
      print("📥 Sign In OTP Verification Response: $responseData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        otpError.value = "";
        final data = responseData['data'];
        if (data != null) {
          final accessToken = responseData['token'];
          if (accessToken != null) {
            prefs.setString('token', accessToken);
          }
          prefs.setInt('userId', data['id']);
          prefs.setString('name', data['fullName']);
          prefs.setString('email', data['email']);
          prefs.setString('phonenumber', data['phone']);
          if (data['gender'] != null) {
            prefs.setInt('gender', data['gender']);
          }
          await Get.offAll(
              () => const BottomNavScreen()); // Go to BottomNavScreen
          hideLoading(); // Hide loading here after navigation
        } else {
          await Get.offAll(() => const BottomNavScreen()); //  Go to home screen
          hideLoading(); // Hide loading here after navigation
        }
      } else if (response.statusCode == 400) {
        if (responseData['errors'] != null) {
          if (responseData['errors']['otp'] != null &&
              responseData['errors']['otp'].isNotEmpty) {
            otpError.value = responseData['errors']['otp'][0];
          }
          if (responseData['errors']['phone'] != null &&
              responseData['errors']['phone'].isNotEmpty) {
            otpError.value = responseData['errors']['phone'][0];
          }
        }
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error. Please try again.");
      } else {
        getSnackBar("OTP verification failed. Try again.");
      }
    } catch (e) {
      print("❌ Exception in callSignInVerifyOtp: $e");
      getSnackBar("Something went wrong. Please try again.");
    } finally {
      if (pageState ==
          PageState.LOADING) // only hide if still loading, and not error
        hideLoading();
    }
  }

  callGuestUser() async {
    isGuest.value = true;
    final prefs = await SharedPreferences.getInstance(); // Define prefs here
    try {
      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/login/guest"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        prefs.setString('token', responseData['meta']['access_token']);
        prefs.setBool("skip", true);
        Get.to(() => const BottomNavScreen());
      } else if (response.statusCode == 400) {
        print(responseData);
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else {
        getSnackBar("guest failed");
      }
    } catch (e) {
      print(e.toString());
    } finally {
      hideLoading();
    }
  }
}
