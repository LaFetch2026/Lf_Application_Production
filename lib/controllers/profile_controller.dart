// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../common/widget/other/common_widget.dart';
import '../common/widget/other/confirmdelete.dart';
import '../core/constant/constants.dart';
import '../screens/bottomnavscreen.dart';
import '../screens/loginscreen.dart';
import '../screens/home/women/homescreen.dart';
import 'auth_api_client.dart';
import 'base_controller.dart';
import 'cart_controller.dart';

class ProfileController extends BaseController {
  RxBool showList = false.obs;
  RxBool isProfile = false.obs;
  RxBool isEditNumber = true.obs;
  RxBool isAddress = false.obs;
  RxBool isPhoneNumber = false.obs;
  RxString queryText = "".obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final gerderController = TextEditingController();
  final phoneController = TextEditingController();

  RxString nameError = "".obs;
  RxString phoneError = "".obs;
  RxString emailError = "".obs;
  RxString genderError = "".obs;

  RxInt genderId = 0.obs;
  RxList<dynamic> addressList = <dynamic>[].obs;
  Rxn<Map<String, dynamic>> defaultAddress = Rxn<Map<String, dynamic>>();
  Rxn<Map<String, dynamic>> profileDetails = Rxn<Map<String, dynamic>>();

  RxBool isOrder = false.obs;
  RxBool isOffer = false.obs;
  RxBool isPermotion = true.obs;
  RxInt orderValue = 0.obs;
  RxInt offerValue = 0.obs;
  RxInt permotionValue = 0.obs;

  final RxList<String> genderList = [
    'Male',
    'Female',
    'Non-Binary',
  ].obs;

  late final AuthApiClient _apiClient;
  bool _isDisposed = false; // Track if controller is disposed

  @override
  void onInit() {
    super.onInit();
    _apiClient = AuthApiClient(http.Client());
    _loadProfileFromPrefs();
  }

  @override
  void onClose() {
    _isDisposed = true; // Mark as disposed before disposing controllers
    nameController.dispose();
    emailController.dispose();
    gerderController.dispose();
    phoneController.dispose();
    _apiClient.close();
    super.onClose();
  }

  Future<void> _loadProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ Safety check: Don't update controllers if already disposed
    if (_isDisposed) return;

    nameController.text = prefs.getString('name') ?? '';
    emailController.text = prefs.getString('email') ?? '';
    phoneController.text =
        (prefs.getString('phonenumber') ?? '').replaceAll("+91", '');

    final storedGenderId = prefs.getInt('gender');
    if (storedGenderId != null) {
      genderId.value = storedGenderId;
      gerderController.text =
          genderList[(storedGenderId - 1).clamp(0, genderList.length - 1)];
    }

    isOrder.value = prefs.getBool('order_notification_enabled') ?? false;
    isOffer.value = prefs.getBool('offer_notification_enabled') ?? false;
    isPermotion.value =
        prefs.getBool('promotional_notification_enabled') ?? true;

    orderValue.value = isOrder.value ? 1 : 0;
    offerValue.value = isOffer.value ? 1 : 0;
    permotionValue.value = isPermotion.value ? 1 : 0;

    // ✅ For Google Sign-In users, set profile details from local storage
    final loginProvider = prefs.getString('loginProvider');
    if (loginProvider == 'google') {
      profileDetails.value = {
        'fullName': prefs.getString('name') ?? '',
        'email': prefs.getString('email') ?? '',
        'phone': prefs.getString('phonenumber') ?? '',
        'photoUrl': prefs.getString('photoUrl') ?? '',
        'provider': 'google',
      };
    }
  }

  bool validateBasicProfileFields() {
    nameError.value = "";
    emailError.value = "";
    genderError.value = "";

    if (nameController.text.trim().isEmpty) {
      nameError.value = "Enter Full Name";
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      emailError.value = "Enter Email Address";
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      emailError.value = "Enter a valid Email ID";
      return false;
    }
    if (genderId.value == 0) {
      genderError.value = "Select Gender";
      return false;
    }
    return true;
  }

  bool validatePhoneNumber(String phone) {
    phoneError.value = "";
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExPhone = RegExp(pattern);

    if (phone.isEmpty) {
      phoneError.value = "Enter Phone Number";
      return false;
    }
    if (phone.length < 10) {
      phoneError.value = "Enter 10 digit Phone Number";
      return false;
    }
    if (!regExPhone.hasMatch(phone)) {
      phoneError.value = "Enter valid Phone Number";
      return false;
    }
    return true;
  }

  String _getGenderString(int id) {
    switch (id) {
      case 1:
        return "male";
      case 2:
        return "female";
      case 3:
        return "non-binary";
      default:
        return "";
    }
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = (await SharedPreferences.getInstance()).getString('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> safeInitProfile({bool redirectIfMissing = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final token = prefs.getString('token');
    final loginProvider = prefs.getString('loginProvider');

    // ✅ For Google Sign-In users without backend userId, use local data
    if (loginProvider == 'google' && token != null && token.isNotEmpty) {
      debugPrint("✅ safeInitProfile(): Google user - using local data");
      await _loadProfileFromPrefs();
      return;
    }

    // If there's no session, optionally redirect to Welcome/Login
    if (userId == null || token == null || token.isEmpty) {
      debugPrint("⚠️ safeInitProfile(): no valid session.");
      if (redirectIfMissing) {
        await prefs.clear();
        HomeScreenState.clearCache(); // ✅ Clear cache on session invalidation
        Get.offAll(() => const LoginScreen(initialTab: 0));
      }
      return;
    }

    // We have something that looks like a session → verify with server
    await getProfileData();
  }

  Future<void> getProfileData() async {
    isProfile.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final loginProvider = prefs.getString('loginProvider');

      // ✅ For Google Sign-In users without backend userId, use local data
      if (loginProvider == 'google' && userId == null) {
        debugPrint("✅ Google user - loading profile from local storage");
        await _loadProfileFromPrefs();
        isProfile.value = false;
        return;
      }

      if (userId == null) {
        debugPrint("⚠️ Skipping profile fetch: userId not found in prefs.");
        return;
      }

      debugPrint("📦 Loaded userId from prefs: $userId");

      final headers = await _authHeaders();
      final resp = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/profile/user-profile/$userId"),
        headers: headers,
      );

      if (resp.statusCode == 401) {
        getSnackBar("Session expired. Please login again.");
        await prefs.clear(); // ✅ make sure next launch sees no session
        HomeScreenState.clearCache(); // ✅ Clear cache on session expiration
        Get.offAll(() => const LoginScreen(initialTab: 0));
        return;
      }

      if (resp.statusCode == 404) {
        debugPrint("❌ 404 - User not found.");
        getSnackBar("Your account no longer exists. Please log in.");
        await prefs.clear(); // ✅ clear stale session
        HomeScreenState.clearCache(); // ✅ Clear cache on account deletion
        Get.offAll(() => const LoginScreen(initialTab: 0));
        return;
      }

      if (resp.statusCode != 200) {
        debugPrint(
            "❌ Error fetching profile (${resp.statusCode}): ${resp.body}");
        try {
          final error = jsonDecode(resp.body);
          getSnackBar(
              "Failed: ${error['message'] ?? 'Error ${resp.statusCode}'}");
        } catch (_) {
          getSnackBar("Failed to fetch profile. Try again later.");
        }
        return;
      }

      Map<String, dynamic> data;
      try {
        data = json.decode(resp.body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint("❌ JSON parsing failed: $e");
        getSnackBar("Invalid response format from server.");
        return;
      }

      final userData = data['data'];
      if (userData is! Map<String, dynamic>) {
        debugPrint("⚠️ Unexpected data format in profile response: $data");
        getSnackBar("Unexpected profile format received.");
        return;
      }

      debugPrint("✅ Profile fetch success: $userData");

      // ✅ Safety check: Don't update controllers if already disposed
      if (_isDisposed) {
        debugPrint("⚠️ Controller disposed, skipping profile update");
        return;
      }

      nameController.text = userData['fullName'] ?? '';
      emailController.text = userData['email'] ?? '';
      phoneController.text = (userData['phone'] ?? '').replaceAll("+91", "");

      final gender = userData['gender']?.toLowerCase();
      switch (gender) {
        case 'male':
          genderId.value = 1;
          break;
        case 'female':
          genderId.value = 2;
          break;
        case 'non-binary':
          genderId.value = 3;
          break;
        default:
          genderId.value = 0;
      }

      await prefs.setString('name', nameController.text);
      await prefs.setString('email', emailController.text);
      await prefs.setString('phonenumber', phoneController.text);
      await prefs.setInt('gender', genderId.value);

      // ✅ Map user's gender to home screen tab gender for existing users
      // 1=Male→Men(1), 2=Female→Women(2), 3=Non-binary→Men(1)
      int homeScreenGender = genderId.value;
      if (homeScreenGender == 3) {
        homeScreenGender = 1; // Non-binary defaults to Men tab
      }
      if (homeScreenGender > 0) {
        await prefs.setInt('selectedGender', homeScreenGender);
      }

      profileDetails.value = userData;
    } catch (e, st) {
      debugPrint("❌ Fetch error: $e\n$st");
      // ✅ Only show error if not disposed (prevents errors after navigation)
      if (!_isDisposed) {
        getSnackBar("Error fetching profile: ${e.toString()}");
      }
    } finally {
      isProfile.value = false;
    }
  }

  Future<void> updateBasicProfile({required bool isInitialSetup}) async {
    if (!validateBasicProfileFields()) return;
    showLoading();

    try {
      final prefs = await SharedPreferences.getInstance();

      final rawPhone = phoneController.text.trim().isNotEmpty
          ? phoneController.text.trim()
          : prefs.getString('phonenumber') ?? '';

      final phoneWithCode =
          rawPhone.startsWith('+91') ? rawPhone : '+91$rawPhone';

      final Map<String, dynamic> sendData = {
        "fullName": nameController.text.trim(),
        "email": emailController.text.trim(),
        "gender": _getGenderString(genderId.value),
        "phone": phoneWithCode,
        "type": "signup", // Add this as per your request payload
      };

      debugPrint(
          "➡️ Sending to /auth/update-user-profile: ${json.encode(sendData)}");

      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/auth/update-user-profile"),
        headers: headers,
        body: json.encode(sendData),
      );

      debugPrint("⬅️ Status: ${response.statusCode}");
      debugPrint("⬅️ Response: ${response.body}");

      if (response.statusCode == 401) {
        getSnackBar("Session expired. Please login again.");
        Get.offAll(() => const LoginScreen(initialTab: 0));
        return;
      }

      if (response.body.isEmpty) {
        getSnackBar("Empty response from server.");
        return;
      }

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = data['data'];

        if (userData is Map<String, dynamic>) {
          final fullName = userData['fullName'] ?? nameController.text.trim();
          final email = userData['email'] ?? emailController.text.trim();
          final displayPhone =
              userData['phone']?.toString().replaceAll("+91", "") ??
                  phoneWithCode.replaceAll("+91", "");
          final userId = userData['id'];
          final role = userData['role'];
          final token = userData['token'];
          final refreshToken = userData['refreshToken'];

          await prefs.setString('name', fullName);
          await prefs.setString('email', email);
          await prefs.setString('phonenumber', displayPhone);
          await prefs.setInt('gender', genderId.value);

          // ✅ Map user's gender to home screen tab gender
          // 1=Male→Men(1), 2=Female→Women(2), 3=Non-binary→Men(1)
          int homeScreenGender = genderId.value;
          if (homeScreenGender == 3) {
            homeScreenGender = 1; // Non-binary defaults to Men tab
          }
          await prefs.setInt('selectedGender', homeScreenGender);

          if (userId != null) {
            await prefs.setInt('userId', userId);
            debugPrint("✅ userId saved: $userId");
          }

          if (role != null) await prefs.setInt('role', role);
          if (token != null) await prefs.setString('token', token);
          if (refreshToken != null)
            await prefs.setString('refreshToken', refreshToken);
        } else {
          debugPrint("⚠️ Invalid or missing 'data' in response.");
          getSnackBar("Profile updated, but user info is missing.");
          return;
        }

        getSnackBar("Profile updated successfully!");

        await getProfileData();

        // 🛒 SYNC GUEST CART after signup completion
        if (isInitialSetup) {
          await _syncGuestCartAfterSignup();
          Get.offAll(() => const BottomNavScreen());
        }
        // Don't navigate back here - let the calling screen handle navigation
      } else if (response.statusCode == 400) {
        _handleProfileUpdateErrors(data);
      } else {
        getSnackBar(
            "Profile update failed: ${data['message'] ?? 'Unknown error'}");
      }
    } catch (e, st) {
      debugPrint("❌ Profile update error: $e\n$st");
      getSnackBar("An error occurred during profile update.");
    } finally {
      hideLoading();
    }
  }

  /// Updates user's phone number, potentially requiring OTP verification.
  Future<void> updatePhoneNumberWithOtp(
      {required String phone, String? otp}) async {
    if (!validatePhoneNumber(phone)) {
      return;
    }

    showLoading();
    try {
      final Map<String, dynamic> sendData = {
        "phone": phone,
        if (otp != null && otp.isNotEmpty)
          "otp": otp, // Include OTP if provided
      };

      // Use _apiClient.put to the general profile endpoint
      var response = await _apiClient.put(
        Uri.parse("${ApiConstants.baseUrl}/profile"),
        body: json.encode(sendData),
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print("Phone Number Update Success: $responseData");
        getSnackBar("Phone number updated successfully!");
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('phonenumber', responseData['data']['phone'] ?? phone);
        isPhoneNumber.value = false; // Assuming this hides OTP input in UI
        await getProfileData(); // Refresh profile data
        // Don't navigate back here - let the calling screen handle navigation
      } else if (response.statusCode == 400) {
        _handleProfileUpdateErrors(responseData);
      } else {
        getSnackBar(
            "Phone number update failed: ${responseData['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Error updating phone number: $e");
      getSnackBar("An error occurred: ${e.toString()}");
    } finally {
      hideLoading();
    }
  }

  /// Fetches user addresses using the provided query text.
  Future<void> getAddressData() async {
    try {
      isAddress.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('userId');

      if (userId == null) {
        getSnackBar("User not logged in.");
        return;
      }

      final uri =
          Uri.parse('${ApiConstants.baseUrl}/profile/addresses/$userId');

      final headers = <String, String>{
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final resp = await http.get(uri, headers: headers);

      if (resp.statusCode == 200) {
        Map<String, dynamic> body;
        try {
          body = json.decode(resp.body) as Map<String, dynamic>;
        } catch (e) {
          debugPrint("getAddressData() JSON parse error: $e");
          getSnackBar("Failed to read addresses. Please try again.");
          return;
        }

        final List<dynamic> data = (body['data'] as List?) ?? const [];

        // Normalize to what the UI expects.
        // Backend keys: id, userId, cityId, line1, line2, postalCode, isDefaultAddress, latitude, longitude, ...
        final List<Map<String, dynamic>> normalized =
            data.map<Map<String, dynamic>>((a) {
          final cityId = a['cityId'] ?? 0;
          return {
            'id': a['id'] ?? 0,
            'type': (a['type'] ?? '').toString(), // backend may not send it
            'address': (a['line1'] ?? '').toString(),
            'locality': (a['line2'] ?? '').toString(),
            'city': {'id': cityId, 'name': (a['cityName'] ?? '').toString()},
            'zip': (a['postalCode'] ?? '').toString(),
            'default_shipping': a['isDefaultAddress'] == true,
            'latitude': (a['latitude'] ?? '0').toString(),
            'longitude': (a['longitude'] ?? '0').toString(),
            // Optional fields your UI sometimes reads:
            'name': (a['name'] ?? '').toString(),
            'phone': (a['phone'] ?? '').toString(),
          };
        }).toList();

        addressList
          ..clear()
          ..addAll(normalized);
      } else if (resp.statusCode == 401) {
        getSnackBar("Session expired. Please login again.");
        Get.offAll(() => const LoginScreen(initialTab: 0));
      } else {
        // Don’t decode (likely HTML). Log a small preview.
        final preview = resp.body.isNotEmpty
            ? resp.body.substring(0, resp.body.length.clamp(0, 200))
            : '<empty>';
        debugPrint(
            "getAddressData() non-200 ${resp.statusCode} body: $preview");
        getSnackBar("Failed to fetch addresses (HTTP ${resp.statusCode}).");
      }
    } catch (e) {
      debugPrint("Error fetching addresses: $e");
      getSnackBar("Error fetching addresses.");
    } finally {
      isAddress.value = false;
    }
  }

  /// Removes an address by its ID.
  Future<void> callRemoveAddress(int addressId) async {
    showLoading();
    try {
      // Use _apiClient.delete
      var response = await _apiClient.delete(
        Uri.parse("${ApiConstants.baseUrl}/addresses/$addressId"),
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        getSnackBar("Address removed successfully!");
        getAddressData(); // Refresh the list
      } else {
        getSnackBar(
            "Failed to remove address: ${responseData['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Error removing address: $e");
      getSnackBar("An error occurred: ${e.toString()}");
    } finally {
      hideLoading();
    }
  }

  /// Updates user notification settings on the backend.
  Future<void> callNotificationSetting() async {
    showLoading();
    try {
      dynamic sendData = {
        "order_notification_enabled": orderValue.value,
        "offer_notification_enabled": offerValue.value,
        "promotional_notification_enabled": permotionValue.value,
      };

      // Use _apiClient.put
      var response = await _apiClient.put(
        Uri.parse("${ApiConstants.baseUrl}/profile"),
        body: json.encode(sendData),
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print("Notification settings updated: $responseData");
        getSnackBar("Notification settings updated successfully!");
        // Update local prefs for quick access (if not fetching full profile every time)
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('order_notification_enabled', orderValue.value == 1);
        prefs.setBool('offer_notification_enabled', offerValue.value == 1);
        prefs.setBool(
            'promotional_notification_enabled', permotionValue.value == 1);
        getProfileData(); // Refresh profile to get updated settings
        Get.back();
      } else {
        getSnackBar(
            "Failed to update notification settings: ${responseData['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Error updating notification settings: $e");
      getSnackBar("An error occurred: ${e.toString()}");
    } finally {
      hideLoading();
    }
  }

  /// Logs out the user from the application by invalidating the current session.
  /// Clears local data and redirects to login screen.
  Future<void> callLogout() async {
    showLoading();

    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');

    // If we don't have a userId, clean locally and route to login.
    if (userId == null) {
      getSnackBar("User ID not found. Logging out locally.");
      try {
        await _localLogoutCleanup(prefs);
      } finally {
        hideLoading();
        Get.offAll(() => const LoginScreen(initialTab: 0));
      }
      return;
    }

    try {
      final base = ApiConstants.baseUrl; // ensure this has no trailing spaces
      final url = Uri.parse('$base/auth/sign-out/$userId');

      final response = await http
          .post(
            url,
            // headers: {'Authorization': 'Bearer ${prefs.getString('token')}'},
          )
          .timeout(const Duration(seconds: 12));

      Map<String, dynamic>? responseData;
      try {
        // Only parse JSON if there's a body
        if (response.body.isNotEmpty) {
          responseData = json.decode(response.body) as Map<String, dynamic>?;
        }
      } catch (_) {
        // Body wasn’t valid JSON; ignore
        responseData = null;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint("✅ Logout successful: ${responseData ?? 'no body'}");
        getSnackBar("Logged out successfully!");
      } else {
        final serverMsg = responseData?['message'] ?? 'Unknown error';
        getSnackBar(
            "Logout failed on server ($serverMsg). Logging out locally.");
      }
    } on TimeoutException {
      getSnackBar("Logout request timed out. Logging out locally.");
    } catch (e) {
      debugPrint("❌ Error during logout API call: $e");
      getSnackBar("An error occurred during logout. Logging out locally.");
    } finally {
      try {
        await _localLogoutCleanup(prefs);
      } finally {
        hideLoading();
        Get.offAll(() => const LoginScreen(initialTab: 0));
      }
    }
  }

  Future<void> _localLogoutCleanup(SharedPreferences prefs) async {
    // Clear local session/preferences
    await prefs.clear();

    // ✅ Clear HomeScreen static cache to force fresh data on next login
    HomeScreenState.clearCache();
  }

  /// Initiates the account deletion process for the current user.
  /// Uses DELETE method to /auth/delete-account/{userId}.
  void callDeleteAccount() async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId == null) {
      getSnackBar(
          "User ID not found for account deletion. Please log in again.");
      hideLoading();
      Get.offAll(() => const LoginScreen(initialTab: 0));
      return;
    }

    try {
      final url =
          Uri.parse("${ApiConstants.baseUrl}/auth/delete-account/$userId");
      final headers = await _authHeaders();
      final response = await http.post(url, headers: headers);

      debugPrint("🗑️ Delete account response status: ${response.statusCode}");
      debugPrint("🗑️ Delete account response body: ${response.body}");

      if (response.statusCode == 200) {
        Map<String, dynamic>? responseData;
        try {
          responseData = json.decode(response.body);
        } catch (_) {}

        getSnackBar(responseData?['message'] ?? "Account deleted successfully!");
        await prefs.clear();
        HomeScreenState.clearCache();

        Get.offAll(() => const ConfirmDeleteScreen());
      } else if (response.statusCode == 401) {
        getSnackBar("Session expired. Please login again.");
        await prefs.clear();
        HomeScreenState.clearCache();
        Get.offAll(() => const LoginScreen(initialTab: 0));
      } else if (response.statusCode == 400) {
        Map<String, dynamic>? responseData;
        try {
          responseData = json.decode(response.body);
        } catch (_) {}
        getSnackBar(
            "Account deletion failed: ${responseData?['message'] ?? responseData?['errors']?.values.first[0] ?? 'Bad request.'}");
      } else {
        Map<String, dynamic>? responseData;
        try {
          responseData = json.decode(response.body);
        } catch (_) {}
        getSnackBar(
            "Account deletion failed: ${responseData?['message'] ?? 'Error ${response.statusCode}'}");
      }
    } catch (e) {
      print("❌ Error deleting account: $e");
      getSnackBar("An error occurred. Please check your network connection.");
    } finally {
      hideLoading();
    }
  }

  // --- Helper for handling common profile update API errors ---
  /// Handles and displays specific validation errors from profile update API responses.
  void _handleProfileUpdateErrors(Map<String, dynamic> responseData) {
    if (responseData['errors'] != null) {
      if (responseData['errors']['fullName'] != null) {
        // Changed 'name' to 'fullName'
        nameError.value = responseData['errors']['fullName'][0];
      }
      if (responseData['errors']['email'] != null) {
        emailError.value = responseData['errors']['email'][0];
      }
      if (responseData['errors']['gender'] != null) {
        genderError.value = responseData['errors']['gender'][0];
      }
      if (responseData['errors']['phone'] != null) {
        phoneError.value = responseData['errors']['phone'][0];
      }
      if (responseData['errors']['otp'] != null) {
        phoneError.value = responseData['errors']['otp']
            [0]; // Assuming OTP errors are shown under phone field
      }
      if (responseData['message'] == null && responseData['errors'].isEmpty) {
        // Fallback for generic 400 if no specific field errors
        getSnackBar("Invalid input. Please check your details.");
      }
    } else if (responseData['message'] != null) {
      getSnackBar(responseData['message']);
    } else {
      getSnackBar("An error occurred during profile update.");
    }
  }

  /// Sync guest cart to server after signup completion
  /// This is called automatically after user completes signup with profile details
  Future<void> _syncGuestCartAfterSignup() async {
    try {
      // Check if CartController is registered
      if (Get.isRegistered<CartController>()) {
        final cartController = Get.find<CartController>();
        print("🔄 Attempting to sync guest cart after signup...");
        await cartController.syncGuestCartToServer();
      } else {
        // Register CartController if not already registered
        final cartController = Get.put(CartController());
        print("🔄 Attempting to sync guest cart after signup...");
        await cartController.syncGuestCartToServer();
      }
    } catch (e) {
      print("⚠️ Error syncing guest cart after signup: $e");
      // Don't block the signup flow if cart sync fails
    }
  }
}
