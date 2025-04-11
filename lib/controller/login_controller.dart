// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/otpverficationscreen.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../screens/userdetails.dart';

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
      /*  getSnackBar(
        "Enter OTP",
      ); */
      otpError.value = "Enter OTP";
      return false;
    }
    if (otpnumber.length < 4) {
      /*  getSnackBar(
        "The otp field must be 4 digit.",
      ); */
      otpError.value = "The otp field must be 4 digit.";
      return false;
    }
    return true;
  }

  bool checkNumbervalidation(String phone) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(patttern);
    if (phone.isEmpty) {
      /*  getSnackBar(
        "Enter Phone Number",
      ); */
      loginError.value = "Enter Phone Number";
      return false;
    }
    if (phone.length < 10) {
      /*  getSnackBar(
        "Enter 10 digit Phone Number",
      ); */
      loginError.value = "Enter 10 digit Phone Number";
      return false;
    }
    if (!regExp.hasMatch(phone)) {
      /* getSnackBar(
        "Enter valid Phone Number",
      ); */
      loginError.value = "Enter valid Phone Number";
      return false;
    }
    return true;
  }

  bool checkRegistervalidation(String phone) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(patttern);
    if (phone.isEmpty) {
      /*  getSnackBar(
        "Enter Phone Number",
      ); */
      registerError.value = "Enter Phone Number";
      return false;
    }
    if (phone.length < 10) {
      /*  getSnackBar(
        "Enter 10 digit Phone Number",
      ); */
      registerError.value = "Enter 10 digit Phone Number";
      return false;
    }
    if (!regExp.hasMatch(phone)) {
      /*   getSnackBar(
        "Enter valid Phone Number",
      ); */
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
      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/login"),
        body: {
          "phone": number.value,
        },
      );

      var responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(responseData);

        // Check and print the token
        if (responseData.containsKey('token')) {
          print("Token: ${responseData['token']}");
        }

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
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("login failed");
      }
    } catch (e) {
      print("Exception: ${e.toString()}");
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
        // getSnackBar(responseData['message']);
        Get.to(OTPVerficationScreen(
          phoneMunber: number.value,
        ));
      } else if (response.statusCode == 201) {
        print(responseData);
        otpError.value = "";
        //  getSnackBar(responseData['message']);
        Get.to(OTPVerficationScreen(
          phoneMunber: number.value,
        ));
      } else if (response.statusCode == 400) {
        if (responseData['errors']['phone'] != null) {
          //getSnackBar(responseData['errors']['phone'][0]);
          otpError.value = responseData['errors']['phone'][0];
        }
        if (responseData['errors']['otp'] != null) {
          // getSnackBar(responseData['errors']['otp']);
          otpError.value = responseData['errors']['otp'];
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("resend otp failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  callSocailMediaLogin(
      String name, String email, String provider, String providerId) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    secondsRemaining.value = 30;
    enableResend.value = false;
    try {
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/login"), body: {
        "email": email,
        "name": name,
        "provider": provider,
        "provider_id": providerId,
      });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        // getSnackBar(responseData['message']);
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
      } else if (response.statusCode == 201) {
        print(responseData);
        //  getSnackBar(responseData['message']);
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
        if (responseData['errors']['email'] != null) {
          getSnackBar(responseData['errors']['email'][0]);
          GoogleSignIn googleSignIn = GoogleSignIn();
          googleSignIn.signOut();
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
    }
    hideLoading();
  }

  callGuestUser() async {
    isGuest.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/login/guest"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
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
          print(responseData);
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        // getSnackBar("Authentication failed");
      } else {
        getSnackBar("guest failed");
      }
    } catch (e) {
      print(e.toString());
    }
    isGuest.value = false;
  }

  callVerifyOtp(String phone) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "phone": phone,
        "otp": otp.value,
      };
      var response = await http.post(Uri.parse("${ApiConstants.baseUrl}/login"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
          body: json.encode(sendData));
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        // getSnackBar(responseData['message']);
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
        //  getSnackBar(responseData['message']);
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
            // getSnackBar(responseData['errors']['otp'][i]);
            otpError.value = responseData['errors']['otp'][i];
          }
        }
        if (responseData['errors']['phone'] != null) {
          // getSnackBar(responseData['errors']['phone'][0]);
          otpError.value = responseData['errors']['phone'][0];
        }
        if (responseData['errors']['otp'] != null) {
          //  getSnackBar(responseData['errors']['otp']);
          otpError.value = responseData['errors']['otp'];
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
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

/*   callSocailMediaVerifyOtp(
      String phone, String name, String email, String provider) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/login"), body: {
        "phone": phone,
        "otp": otp.value,
        "email": email,
        "name": name,
        "provider": provider,
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
        getSnackBar("Please try again");
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
 */
}
