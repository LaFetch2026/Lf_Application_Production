// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/bottomnavscreen.dart';
import '../screens/otpverficationscreen.dart';
import '../screens/userdetails.dart';
import 'base_controller.dart';
import 'cart_controller.dart';
import 'home_controller.dart';
import '../services/netcore_service.dart';
import '../services/analytics/analytics_service.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class GuestResult {
  final bool ok;
  final String? error;
  const GuestResult.success()
      : ok = true,
        error = null;
  const GuestResult.failure(this.error) : ok = false;
}

class LoginController extends BaseController {
  // ---- Static Test Credentials for Google Play Review ----
  static const String testPhoneNumber = "+919999999999";
  static const String testOtp = "1234";

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
// Add this in your LoginController
  final resendAttempts = 0.obs;
  final maxResendAttempts = 3;
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

    // 🟢 FIX: Do NOT modify isLoggedIn here — SplashController handles it
    if (t.isNotEmpty) {
      isGuest.value = false; // logged in
    } else {
      isGuest.value = skipped; // guest only if skip==true
    }
  }

  /// Persist token to prefs and update controller state.
  Future<void> setToken(String? newToken) async {
    final prefs = await SharedPreferences.getInstance();

    if (newToken != null && newToken.isNotEmpty) {
      await prefs.setString('token', newToken);
      await prefs.setBool('isLoggedIn', true);
      await prefs.remove('skip');

      _token.value = newToken;
      isGuest.value = false;
    } else {
      // 🟢 FIX: reset token without touching guest/skip flag
      await prefs.remove('token');
      _token.value = '';

      // don't touch skip here
    }
  }

  /// Send pending FCM token to server after successful login.
  Future<void> _sendPendingFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('pending_fcm_token');
      if (fcmToken == null || fcmToken.isEmpty) return;

      final userId = prefs.getInt('userId') ?? 0;
      final authToken = prefs.getString('token')?.trim() ?? '';
      if (userId <= 0 || authToken.isEmpty) return;

      final homeController = Get.find<HomeController>();
      final success = await homeController.sendFcmToken(
        userId: userId,
        token: fcmToken,
        deviceType: Platform.isAndroid ? "android" : "ios",
      );
      if (success) {
        await prefs.remove('pending_fcm_token');
        print('✅ FCM token sent to server after login');
      } else {
        print(
            '⚠️ FCM token send failed after login — will retry on next app start');
      }
    } catch (e) {
      print('⚠️ Failed to send FCM token after login: $e');
    }
  }

  /// Clear all auth/session info for a clean logout.
  Future<void> clearTokenAndSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('phonenumber');
    await prefs.remove('name');

    _token.value = '';
    isGuest.value = false; // explicit logout -> normal state
  }

  Future<void> logout() async {
    showLoading();
    try {
      await clearTokenAndSession();
      // ✅ FIX: Sign out from Google to clear cached account (fixes Android auto-login issue)
      await signOutGoogle();
      // ── Netcore CE: clear user identity on logout ──────────────────────────
      try {
        AnalyticsService.instance.trackSignOut();
      } catch (_) {}
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

  String _getNetcoreIdentity(String? rawPhone, {String? fallback}) {
    final cleaned = rawPhone?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    if (cleaned.isNotEmpty) return cleaned;
    return fallback ?? '';
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

      // ✅ Handle static test credentials for Google Play Review
      if (phoneNumber == testPhoneNumber) {
        number.value = phoneNumber;
        print("🔐 Test Mode: Using static OTP $testOtp for review");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('phonenumber', phoneNumber);
        await prefs.setString('authType', currentAuthFlowType.value);

        hideLoading();
        Get.to(() => OTPVerficationScreen(phoneMunber: phoneNumber));
        getSnackBar("OTP sent successfully!");
        return;
      }

      final endpoint = isLogin ? "sign-in-send-otp" : "sign-up-send-otp";

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/$endpoint"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneNumber}),
      );

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } on FormatException {
        getSnackBar("Server error - please try again later");
        final peekLength =
            response.body.length > 200 ? 200 : response.body.length;
        print(
            "⚠️ Non-JSON response from $endpoint: ${response.body.substring(0, peekLength)}");
        return;
      }

      if (response.statusCode == 200) {
        number.value = phoneNumber;

        final otpFromApi = data["data"]?["otp"] ?? data["otp"];
        if (otpFromApi != null) {
          print("🔐 OTP (Debug Only): $otpFromApi");
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('phonenumber', phoneNumber);
        await prefs.setString('authType', currentAuthFlowType.value);

        Get.to(() => OTPVerficationScreen(phoneMunber: phoneNumber));

        getSnackBar("OTP sent successfully!");
      } else {
        // ✅ Show error only in snackbar, not below text field
        final errorMessage = data['errors']?['phone']?.first ??
            data['message'] ??
            "Error sending OTP";
        getSnackBar(errorMessage);
      }
    } catch (e) {
      getSnackBar("Network error: $e");
      print("Error sending OTP: $e");
    } finally {
      hideLoading();
    }
  }

  Future<bool> callVerifyOtp(String phone, {String? type, int? userId}) async {
    showLoading();
    try {
      otpError.value = "";
      if (!checkOtpValidation(otp.value)) {
        hideLoading();
        return false;
      }

      final isLoginFlow = currentAuthFlowType.value == "login";
      final prefs = await SharedPreferences.getInstance();

      // ✅ Handle static test credentials for Google Play Review
      if (phone == testPhoneNumber && otp.value == testOtp) {
        print("🔐 Test Mode: Verifying with static credentials");

        if (isLoginFlow) {
          // For test login, use a dummy token
          await setToken(
              "test_review_token_${DateTime.now().millisecondsSinceEpoch}");
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('phonenumber', phone);
          await prefs.setString('authType', currentAuthFlowType.value);
          await prefs.setInt('userId', 999999); // Test user ID
          await prefs.setString('name', 'Test Reviewer');

          await prefs.remove('skip');
          isGuest.value = false;

          await _syncGuestCartAfterAuth();

          // Analytics
          await AnalyticsService.instance.trackSignin(method: 'phone');

          hideLoading();
          getSnackBar("OTP verified successfully!");
          Get.offAll(() => const BottomNavScreen());
        } else {
          // For test signup, go to user details screen
          await prefs.setString('phonenumber', phone);
          await prefs.setString('authType', currentAuthFlowType.value);
          await setToken(null);
          await prefs.remove('skip');
          isGuest.value = false;

          hideLoading();
          getSnackBar("OTP verified successfully!");
          Get.offAll(() => const UserDetailsScreen());
        }
        return true;
      }

      // ✅ Show error for wrong OTP on test number
      if (phone == testPhoneNumber && otp.value != testOtp) {
        hideLoading();
        otpError.value = "Invalid OTP";
        getSnackBar("Invalid OTP");
        return false;
      }

      final body = {
        'phone': phone,
        'otp': otp.value,
        if (type != null) 'type': type,
        if (type == null && isLoginFlow) 'type': 'login',
        if (userId != null) 'userId': userId,
      };

      final url = "${ApiConstants.baseUrl}/auth/verify-otp";
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } on FormatException {
        getSnackBar("Server error - please try again later");
        final peekLength =
            response.body.length > 200 ? 200 : response.body.length;
        print(
            "⚠️ Non-JSON response from verify-otp: ${response.body.substring(0, peekLength)}");
        return false;
      }

      if (response.statusCode == 200) {
        final userData = data['data'];

        // updateProfile flow (phone change) — save new token if returned, no navigation
        if (type != null && type != 'login') {
          final newToken = userData?['token'];
          if (newToken != null) {
            await setToken(newToken);
          }
          // Update phone in local prefs
          if (phone.isNotEmpty) {
            await prefs.setString('phonenumber', phone.replaceAll('+91', ''));
          }
          // Do NOT show snackbar here — the calling screen will show the
          // success message AFTER navigating back, so no overlay is open
          // when Get.back() is called.
          return true;
        }

        if (isLoginFlow) {
          final accessToken = userData?['token'];
          if (accessToken == null) {
            getSnackBar("Something went wrong during login.");
            return false;
          }

          await setToken(accessToken);
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('phonenumber', phone);
          await prefs.setString('authType', currentAuthFlowType.value);
          await prefs.setInt('userId', userData?['id'] ?? 0);

          final name = userData?['name'];
          final gender = userData?['gender'];
          final email = userData?['email'];
          if (name != null) await prefs.setString('name', name);
          if (email != null) await prefs.setString('email', email);
          if (gender != null) _mapGenderToPrefs(gender, prefs);

          // Guest mode OFF when logged in
          await prefs.remove('skip');
          isGuest.value = false;

          // 🛒 SYNC GUEST CART after successful login
          await _syncGuestCartAfterAuth();

          // Send pending FCM token to server
          await _sendPendingFcmToken();

          // Analytics
          await AnalyticsService.instance.trackSignin(method: 'phone');

          // ── Netcore CE: identify user after OTP login ──────────────────────
          try {
            final savedPhone = phone;
            final savedEmail = prefs.getString('email') ?? '';
            final netcoreIdentity = _getNetcoreIdentity(
              savedPhone,
              fallback: savedEmail.isNotEmpty
                  ? savedEmail
                  : (userData?['id'] ?? 0).toString(),
            );
            if (netcoreIdentity.isNotEmpty) {
              NetcoreService.instance.identifyUser(netcoreIdentity);
              NetcoreService.instance.loginUser(netcoreIdentity);
              // Update profile with available attributes
              final profileMap = <String, dynamic>{};
              final savedName = prefs.getString('name') ?? '';
              if (savedName.isNotEmpty) {
                final parts = savedName.trim().split(' ');
                profileMap['first_name'] = parts.first;
                if (parts.length > 1) {
                  profileMap['last_name'] = parts.sublist(1).join(' ');
                }
              }
              final savedEmail = prefs.getString('email') ?? '';
              if (savedEmail.isNotEmpty) profileMap['email'] = savedEmail;
              final savedPhone = prefs.getString('phonenumber') ?? '';
              if (savedPhone.isNotEmpty)
                profileMap['phone'] = _getNetcoreIdentity(savedPhone);
              if (profileMap.isNotEmpty) {
                NetcoreService.instance.updateProfile(profileMap);
              }
            }
          } catch (_) {
            // Netcore identity errors must never affect the login flow
          }

          Get.offAll(() => const BottomNavScreen());
        } else {
          await prefs.setString('phonenumber', phone);
          await prefs.setString('authType', currentAuthFlowType.value);

          // user continues signup
          await setToken(null);
          await prefs.remove('skip');
          isGuest.value = false;

          Get.offAll(() => const UserDetailsScreen());
        }

        getSnackBar("OTP verified successfully!");
        return true;
      } else {
        final error = data['errors']?['otp']?.first ??
            data['errors']?['phone']?.first ??
            data['message'] ??
            "OTP verification failed";
        otpError.value = error;
        getSnackBar(error);
        return false;
      }
    } catch (e) {
      print("❌ Exception during OTP verification: $e");
      getSnackBar("Unexpected error during OTP verification.");
      return false;
    } finally {
      hideLoading();
    }
  }

  void _mapGenderToPrefs(String gender, SharedPreferences prefs) {
    final g = gender.toLowerCase();
    int genderId = 0;

    if (g == 'male') {
      genderId = 1;
      prefs.setInt('gender', 1);
      prefs.setInt('selectedGender', 1); // Men tab
    } else if (g == 'female') {
      genderId = 2;
      prefs.setInt('gender', 2);
      prefs.setInt('selectedGender', 2); // Women tab
    } else if (g == 'non-binary') {
      genderId = 3;
      prefs.setInt('gender', 3);
      prefs.setInt('selectedGender', 1); // Default to Men tab
    }

    print(
        "✅ Login: Gender saved - $gender (ID: $genderId, HomeTab: ${prefs.getInt('selectedGender')})");
  }

  Future<bool> callResendOtp(String phone, {String? type, int? userId}) async {
    secondsRemaining.value = 30;
    enableResend.value = false;
    otpError.value = "";
    showLoading();

    try {
      final body = {
        'phone': phone,
        if (userId != null) 'userId': userId,
        if (type != null) 'type': type,
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/resend-otp"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        getSnackBar("OTP sent successfully!");
        return true;
      } else {
        dynamic data;
        try {
          data = jsonDecode(response.body);
        } on FormatException {
          getSnackBar("Server error - please try again later");
          final peekLength =
              response.body.length > 200 ? 200 : response.body.length;
          print(
              "⚠️ Non-JSON response from resend-otp: ${response.body.substring(0, peekLength)}");
          return false;
        }

        final errorMessage = data['errors']?['phone']?.first ??
            data['message'] ??
            "Error sending OTP.";
        otpError.value = errorMessage;
        getSnackBar(errorMessage);
        return false;
      }
    } catch (e) {
      getSnackBar("An error occurred: $e");
      print("Error resending OTP: $e");
      return false;
    } finally {
      hideLoading();
    }
  }

  /// Enter guest mode (no login). Persists `skip=true`
  Future<GuestResult> enterGuestMode() async {
    if (_busyGuestEnter.value) {
      return const GuestResult.failure('Busy');
    }
    _busyGuestEnter.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Do NOT clear token/reset login state
      await prefs.setBool('skip', true);
      isGuest.value = true;

      return const GuestResult.success();
    } catch (e) {
      return GuestResult.failure(e.toString());
    } finally {
      _busyGuestEnter.value = false;
    }
  }

  /// Sync guest cart to server after authentication
  /// This is called automatically after login/signup completes
  Future<void> _syncGuestCartAfterAuth() async {
    try {
      // Check if CartController is registered
      if (Get.isRegistered<CartController>()) {
        final cartController = Get.find<CartController>();
        print("🔄 Attempting to sync guest cart...");
        await cartController.syncGuestCartToServer();
      } else {
        // Register CartController if not already registered
        final cartController = Get.put(CartController());
        print("🔄 Attempting to sync guest cart...");
        await cartController.syncGuestCartToServer();
      }
    } catch (e) {
      print("⚠️ Error syncing guest cart after auth: $e");
      // Don't block the login flow if cart sync fails
    }
  }

  // ----------------- GOOGLE SIGN-IN -----------------

  // Lazy-loaded to avoid accessing before Firebase.initializeApp()
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;

  GoogleSignIn? _googleSignInInstance;
  GoogleSignIn get _googleSignIn => _googleSignInInstance ??= GoogleSignIn(
        serverClientId:
            '598072306679-orm3i1tit1upj3a1rrt984dkf6u7jgpq.apps.googleusercontent.com',
      );

  /// Sign in with Google and authenticate with backend
  Future<bool> signInWithGoogle() async {
    showLoading();
    try {
      // ✅ FIX: Sign out first to force account picker every time (fixes Android auto-login)
      await _googleSignIn.signOut();

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        hideLoading();
        return false;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        getSnackBar("Google sign-in failed. Please try again.");
        hideLoading();
        return false;
      }

      print("✅ Google Sign-In successful: ${firebaseUser.email}");

      final String? googleIdToken = googleAuth.idToken;

      if (googleIdToken == null || googleIdToken.isEmpty) {
        getSnackBar("Failed to get ID token");
        hideLoading();
        return false;
      }

      // Call backend API for social sign-in
      final success = await _socialSignIn(
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? '',
        provider: 'google',
        providerId: firebaseUser.uid,
        idToken: googleIdToken,
      );

      // if (success) {
      //   // Sync guest cart after successful login
      //   await _syncGuestCartAfterAuth();
      //   Get.offAll(() => const BottomNavScreen());
      // }

      if (success) {
        await _syncGuestCartAfterAuth();
        hideLoading(); // ✅ dismiss FIRST
        Get.offAll(() => const BottomNavScreen());
        return true;
      }

      return false;
    } on FirebaseAuthException catch (e, stack) {
      print("❌ Firebase Auth Error: ${e.code} - ${e.message}");
      print("❌ Stack: $stack");
      getSnackBar(e.message ?? "Google sign-in failed.");
      return false;
    } on PlatformException catch (e, stack) {
      print("❌ Platform Error: ${e.code} - ${e.message} - ${e.details}");
      print("❌ Stack: $stack");
      getSnackBar("Google sign-in failed. Please try again.");
      return false;
    } catch (e, stack) {
      print("❌ Google Sign-In Error: $e");
      print("❌ Stack: $stack");
      getSnackBar("An error occurred during Google sign-in.");
      return false;
    } finally {
      hideLoading();
    }
  }

  /// Sign in with Apple and authenticate with backend
  Future<bool> signInWithApple() async {
    showLoading();
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        getSnackBar("Apple sign-in failed. Please try again.");
        hideLoading();
        return false;
      }

      // Apple only gives name on first sign-in, so fall back to email prefix
      final name = appleCredential.givenName != null
          ? '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
              .trim()
          : firebaseUser.displayName ??
              firebaseUser.email?.split('@').first ??
              '';

      final email = appleCredential.email ?? firebaseUser.email ?? '';
      final idToken = appleCredential.identityToken ?? '';

      if (idToken.isEmpty) {
        getSnackBar("Failed to get Apple ID token");
        hideLoading();
        return false;
      }

      final success = await _socialSignIn(
        email: email,
        name: name,
        provider: 'apple',
        providerId: firebaseUser.uid,
        idToken: idToken,
      );

      if (success) {
        await _syncGuestCartAfterAuth();
        hideLoading();
        Get.offAll(() => const BottomNavScreen());
        return true;
      }

      return false;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        hideLoading();
        return false;
      }
      getSnackBar("Apple sign-in failed: ${e.message}");
      return false;
    } on FirebaseAuthException catch (e) {
      getSnackBar(e.message ?? "Apple sign-in failed.");
      return false;
    } catch (e) {
      print("❌ Apple Sign-In Error: $e");
      getSnackBar("An error occurred during Apple sign-in.");
      return false;
    } finally {
      hideLoading();
    }
  }

  /// Call backend API for social sign-in
  Future<bool> _socialSignIn({
    required String email,
    required String name,
    required String provider,
    required String providerId,
    required String idToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/social-sign-in"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': name,
          'provider': provider,
          'providerId': providerId,
          'token': idToken,
        }),
      );

      print("📡 Social Sign-In Response: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } on FormatException {
        getSnackBar("Server error - please try again later");
        final peekLength =
            response.body.length > 200 ? 200 : response.body.length;
        print(
            "⚠️ Non-JSON response from social-sign-in: ${response.body.substring(0, peekLength)}");
        return false;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = data['data'];

        print("🔍 Full userData from Google Sign-In: $userData");
        print("🔍 userId: ${userData?['id']}");
        print("🔍 token: ${userData?['token']}");

        final userInfo = userData?['user'];
        final accessToken = userData?['token'];

        if (accessToken == null) {
          getSnackBar("Authentication failed. Please try again.");
          return false;
        }

        // Save auth data
        final prefs = await SharedPreferences.getInstance();
        await setToken(accessToken);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('loginProvider', provider);
        await prefs.setInt('userId', userData?['id'] ?? 0);
        await prefs.setInt('userId', userInfo?['id'] ?? 0);

        // final userName = userData?['name'] ?? userData?['fullName'] ?? name;
        final userName = userInfo?['fullName'] ?? userInfo?['name'] ?? name;
        final userEmail = userData?['email'] ?? email;
        final gender = userData?['gender'];
        final phone = userData?['phone'];

        if (userName.isNotEmpty) await prefs.setString('name', userName);
        if (userEmail.isNotEmpty) await prefs.setString('email', userEmail);
        if (phone != null) await prefs.setString('phonenumber', phone);
        if (gender != null) _mapGenderToPrefs(gender, prefs);

        // Clear guest mode
        await prefs.remove('skip');
        isGuest.value = false;

        // Send pending FCM token to server
        await _sendPendingFcmToken();

        // Analytics
        await AnalyticsService.instance.trackSignin(method: provider);

        // ── Netcore CE: identify user after social login ───────────────────
        try {
          final savedPhone = prefs.getString('phonenumber') ?? '';
          final savedEmail = prefs.getString('email') ?? '';
          final netcoreIdentity = _getNetcoreIdentity(
            savedPhone,
            fallback: savedEmail.isNotEmpty ? savedEmail : providerId,
          );
          if (netcoreIdentity.isNotEmpty) {
            NetcoreService.instance.identifyUser(netcoreIdentity);
            NetcoreService.instance.loginUser(netcoreIdentity);
            final profileMap = <String, dynamic>{};
            final savedName = prefs.getString('name') ?? '';
            if (savedName.isNotEmpty) {
              final parts = savedName.trim().split(' ');
              profileMap['first_name'] = parts.first;
              if (parts.length > 1) {
                profileMap['last_name'] = parts.sublist(1).join(' ');
              }
            }
            final savedEmail = prefs.getString('email') ?? '';
            if (savedEmail.isNotEmpty) profileMap['email'] = savedEmail;
            if (savedPhone.isNotEmpty)
              profileMap['phone'] = _getNetcoreIdentity(savedPhone);
            if (profileMap.isNotEmpty) {
              NetcoreService.instance.updateProfile(profileMap);
            }
          }
        } catch (_) {
          // Netcore identity errors must never affect the login flow
        }

        getSnackBar("Welcome, $userName!");
        return true;
      } else {
        final errorMessage =
            data['message'] ?? "Social sign-in failed. Please try again.";
        getSnackBar(errorMessage);
        return false;
      }
    } catch (e) {
      print("❌ Social Sign-In API error: $e");
      getSnackBar("Network error during authentication.");
      return false;
    }
  }

  /// Sign out from Google and Firebase
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print("⚠️ Error signing out from Google: $e");
    }
  }
}
