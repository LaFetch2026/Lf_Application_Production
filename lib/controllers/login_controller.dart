// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/bottomnavscreen.dart';
import '../screens/otpverficationscreen.dart';
import '../screens/userdetails.dart';
import 'base_controller.dart';

class GuestResult {
  final bool ok;
  final String? error;
  const GuestResult.success()
      : ok = true,
        error = null;
  const GuestResult.failure(this.error) : ok = false;
}

class LoginController extends BaseController {
  // ---- UI state / inputs ----
  final phoneNumberLogin = TextEditingController();
  final phoneNumberRegister = TextEditingController();
  final Rx<OtpFieldControllerV2> controller = OtpFieldControllerV2().obs;

  RxInt secondsRemaining = 30.obs;
  RxString number = "".obs;
  RxString loginError = "".obs;
  RxString otpError = "".obs;
  RxString registerError = "".obs;
  RxString otp = "".obs;
  RxBool showButton = false.obs;
  RxBool isGuest = false.obs; // true => guest mode (no token)
  RxBool enableResend = false.obs;
  RxString currentAuthFlowType = "signup".obs;

  // ---- Auth state ----
  final RxString _token = ''.obs;
  String? get token => _token.value.isNotEmpty ? _token.value : null;
  bool get isAuthenticated => token != null;
  bool get isGuestMode => isGuest.value && token == null;

  // Guard to avoid double guest-enter
  final RxBool _busyGuestEnter = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTokenFromPrefs(); // keep auth/guest state in sync on startup
  }

  /// Load token & guest flag from SharedPreferences.
  Future<void> _loadTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('token') ?? '';
    final skipped = prefs.getBool('skip') ?? false;

    _token.value = t;

    if (t.isNotEmpty) {
      isGuest.value = false;
      await prefs.setBool('isLoggedIn', true);
    } else {
      isGuest.value = skipped;
      await prefs.setBool('isLoggedIn', false);
    }
  }

  /// Persist token to prefs and update controller state.
  Future<void> setToken(String? newToken) async {
    final prefs = await SharedPreferences.getInstance();
    if (newToken != null && newToken.isNotEmpty) {
      await prefs.setString('token', newToken);
      await prefs.setBool('isLoggedIn', true);
      await prefs.remove('skip'); // authenticated user isn't a guest
      _token.value = newToken;
      isGuest.value = false;
    } else {
      await prefs.remove('token');
      await prefs.setBool('isLoggedIn', false);
      _token.value = '';
      // leave isGuest as-is; caller decides
    }
  }

  /// Clear all auth/session info for a clean logout.
  Future<void> clearTokenAndSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.setBool('isLoggedIn', false);
    _token.value = '';
    isGuest.value = false; // explicit logout -> neutral state
  }

  Future<void> logout() async {
    showLoading();
    try {
      await clearTokenAndSession();
      getSnackBar("You have been logged out successfully.");
      Get.offAllNamed('/welcome');
    } catch (e) {
      print("Error during logout: $e");
      getSnackBar("An error occurred during logout.");
    } finally {
      hideLoading();
    }
  }

  // ----------------- VALIDATION -----------------

  bool checkOtpValidation(String otpNumber) {
    if (otpNumber.isEmpty) {
      otpError.value = "Enter OTP";
      return false;
    }
    if (otpNumber.length < 4) {
      otpError.value = "The OTP field must be 4 digits.";
      return false;
    }
    return true;
  }

  bool checkNumberValidation(String phone) {
    final regExp = RegExp(r'^[0-9]{10,12}$');
    if (phone.isEmpty) {
      loginError.value = "Enter Phone Number";
      return false;
    }
    if (!regExp.hasMatch(phone)) {
      loginError.value = "Enter valid Phone Number";
      return false;
    }
    return true;
  }

  // ----------------- OTP FLOWS -----------------

  Future<void> callSendOtp({
    required String phoneNumber,
    required bool isLogin,
  }) async {
    showLoading();
    try {
      loginError.value = "";
      registerError.value = "";
      secondsRemaining.value = 30;
      enableResend.value = false;

      currentAuthFlowType.value = isLogin ? "login" : "signup";
      final endpoint = isLogin ? "sign-in-send-otp" : "sign-up-send-otp";

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/$endpoint"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneNumber}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        number.value = phoneNumber;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('phonenumber', phoneNumber);
        await prefs.setString('authType', currentAuthFlowType.value);
        Get.to(() => OTPVerficationScreen(phoneMunber: phoneNumber));
        getSnackBar("OTP sent successfully!");
      } else {
        final errorField = isLogin ? loginError : registerError;
        errorField.value = data['errors']?['phone']?.first ??
            data['message'] ??
            "Error sending OTP";
        getSnackBar(errorField.value);
      }
    } catch (e) {
      getSnackBar("Network error: $e");
      print("Error sending OTP: $e");
    } finally {
      hideLoading();
    }
  }

  Future<void> callVerifyOtp(String phone) async {
    showLoading();
    try {
      otpError.value = "";
      if (!checkOtpValidation(otp.value)) {
        hideLoading();
        return;
      }

      final isLoginFlow = currentAuthFlowType.value == "login";
      final body = {
        'phone': phone,
        'otp': otp.value,
        if (isLoginFlow) 'type': 'login',
      };

      final url = "${ApiConstants.baseUrl}/auth/verify-otp";
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      if (response.statusCode == 200) {
        final userData = data['data'];

        if (isLoginFlow) {
          final accessToken = userData?['token'];
          if (accessToken == null) {
            getSnackBar("Something went wrong during login.");
            return;
          }

          // Persist token & update state
          await setToken(accessToken);
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('phonenumber', phone);
          await prefs.setString('authType', currentAuthFlowType.value);
          await prefs.setInt('userId', userData?['id'] ?? 0);

          // Optional profile fields
          final name = userData?['name'];
          final gender = userData?['gender'];
          final email = userData?['email'];
          if (name != null) await prefs.setString('name', name);
          if (email != null) await prefs.setString('email', email);
          if (gender != null) _mapGenderToPrefs(gender, prefs);

          // Clear guest marker once authenticated
          await prefs.remove('skip');
          isGuest.value = false;

          Get.offAll(() => const BottomNavScreen());
        } else {
          // Signup flow → go to details (no token yet)
          await prefs.setString('phonenumber', phone);
          await prefs.setString('authType', currentAuthFlowType.value);

          // Make sure we are NOT considered logged in or guest here
          await setToken(null);
          await prefs.remove('skip');
          isGuest.value = false;

          Get.offAll(() => const UserDetailsScreen());
        }

        getSnackBar("OTP verified successfully!");
      } else {
        final error = data['errors']?['otp']?.first ??
            data['message'] ??
            "OTP verification failed";
        otpError.value = error;
        getSnackBar(error);
      }
    } catch (e) {
      print("❌ Exception during OTP verification: $e");
      getSnackBar("Unexpected error during OTP verification.");
    } finally {
      hideLoading();
    }
  }

  void _mapGenderToPrefs(String gender, SharedPreferences prefs) {
    final g = gender.toLowerCase();
    if (g == 'male') prefs.setInt('gender', 1);
    if (g == 'female') prefs.setInt('gender', 2);
    if (g == 'non-binary') prefs.setInt('gender', 3);
  }

  Future<void> callResendOtp(String phone) async {
    secondsRemaining.value = 30;
    enableResend.value = false;
    otpError.value = "";
    showLoading();

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/resend-otp"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        getSnackBar("OTP resent successfully!");
      } else {
        final data = jsonDecode(response.body);
        final errorMessage = data['errors']?['phone']?.first ??
            data['message'] ??
            "Error during OTP resend.";
        otpError.value = errorMessage;
        getSnackBar(errorMessage);
      }
    } catch (e) {
      getSnackBar("An error occurred: $e");
      print("Error resending OTP: $e");
    } finally {
      hideLoading();
    }
  }

  /// Enter guest mode (no login). Persists `skip=true`, clears token,
  /// and marks controller state accordingly.
  Future<GuestResult> enterGuestMode() async {
    if (_busyGuestEnter.value) {
      return const GuestResult.failure('Busy');
    }
    _busyGuestEnter.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear any existing auth token/session
      await setToken(null);
      await prefs.setBool('isLoggedIn', false);

      // Mark this device/session as "skipped login"
      await prefs.setBool('skip', true);

      // Reflect in controller state
      isGuest.value = true;

      return const GuestResult.success();
    } catch (e) {
      return GuestResult.failure(e.toString());
    } finally {
      _busyGuestEnter.value = false;
    }
  }
}
