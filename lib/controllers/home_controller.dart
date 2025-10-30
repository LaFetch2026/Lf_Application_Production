// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/loginscreen.dart';
import 'base_controller.dart';
import 'package:flutter/foundation.dart';

class HomeController extends BaseController {
  Future<void> _redirectToLoginIfNotGuest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool('skip') ?? false;
      if (!isGuest) {
        // Not in guest mode → redirect to login
        Get.offAll(() => const LoginScreen(initialTab: 0));
      } else {
        // Guest browsing allowed
        debugPrint('🟢 Guest mode active — no login redirect.');
      }
    } catch (e) {
      debugPrint("⚠️ Prefs error in redirect check: $e");
    }
  }

  RxBool isBanner1 = false.obs;
  RxBool isCity = false.obs;
  RxBool isFaqs = false.obs;
  RxBool isBanner2 = false.obs;
  RxBool showGenderList = false.obs;
  RxBool isCategory = false.obs;
  RxBool isBrand = false.obs;
  RxString playerId = "".obs;
  RxString genderText = "Men".obs;
  // RxString fcmToken = "".obs;
  String devicename = "";
  String platform = "";
  RxInt gender_Type = 0.obs;
  List FaqsList = [].obs;
  List brandList = [].obs;
  List banner2List = [].obs;
  List cityList = [].obs;
  List banner1List = [].obs;
  List banner3List = [].obs;
  final RxString brandQuery = ''.obs;

  List bannerTag1Id = [].obs;
  List bannerTag2Id = [].obs;
  List bannerCategory1Id = [].obs;
  List bannerCategory2Id = [].obs;
  List categoryList = [].obs;
  RxInt currentPage = 0.obs;
  RxInt homeGenderValue = 2.obs;
  List banners = [].obs;
  RxString expressHour = "2".obs;
  RxInt cartValue = 0.obs;

  RxBool IsAnimateTag = true.obs;
  RxInt tagId = 0.obs;

  ScrollController tagsController = ScrollController();
  ScrollController discountScreenController = ScrollController();
  List<bool> selected = List.generate(50, (i) => false).obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialGenderTab();
  }

  Future<void> _loadInitialGenderTab() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGender = prefs.getInt('selectedGender') ?? 1; // default to Men

    homeGenderValue.value = savedGender;
    switch (savedGender) {
      case 1:
        genderText.value = "Men";
        break;
      case 2:
        genderText.value = "Women";
        break;
      case 3:
        genderText.value = "Accessories";
        break;
    }

    getBannerData(savedGender);
    getBrandData("home", savedGender);
    getCategoryData(savedGender);
  }

  void getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      devicename = androidInfo.model;
      platform = "Android";
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      devicename = iosInfo.utsname.machine;
      platform = "IOS";
    }
  }

  Future<void> getBannerData(int gender) async {
    isBanner1.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = (prefs.getString('token') ?? '').trim();

      final uri = Uri.parse("${ApiConstants.baseUrl}/banners");
      print("📤 Hitting banners API: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> all = (decoded['data'] as List?) ?? const [];

        // 🔎 Keep only items with category.name matching the tab
        final String expected = _genderLabel(gender); // MEN/WOMEN/ACCESSORIES
        final List<dynamic> filtered = all.where((b) {
          final name =
              (b is Map ? (b['category']?['name'] ?? '') : '').toString();
          return name.toUpperCase() == expected;
        }).toList();

        // ✅ Store into the specific list for that gender
        switch (gender) {
          case 1:
            banner1List = filtered;
            break;
          case 2:
            banner2List = filtered;
            break;
          case 3:
            banner3List = filtered;
            break;
          default:
            banner1List = filtered;
        }

        print("✅ Banners for $expected: ${filtered.length}");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
        _redirectToLoginIfNotGuest();
      } else {
        getSnackBar("Failed to load banners");
      }
    } catch (e, st) {
      print("❌ Banner fetch exception: $e\n$st");
      getSnackBar("An error occurred while loading banners.");
    } finally {
      isBanner1.value = false;
    }
  }

  /// Helper: map gender int → API category name
  String _genderLabel(int gender) {
    switch (gender) {
      case 1:
        return "MEN";
      case 2:
        return "WOMEN";
      case 3:
        return "ACCESSORIES";
      default:
        return "MEN";
    }
  }

  Future<Map<String, dynamic>?> getBannerDetail(int bannerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawToken = (prefs.getString('token') ?? '').trim();

      final uri = Uri.parse("${ApiConstants.baseUrl}/banner/$bannerId");
      print("📤 Hitting banner detail API: $uri");

      final headers = <String, String>{
        'Accept': 'application/json',
        if (rawToken.isNotEmpty) 'Authorization': 'Bearer $rawToken',
      };

      final response = await http.get(uri, headers: headers);

      print("📥 Detail Status: ${response.statusCode}");
      // Body can be large (products list), so don’t always print full

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>?;
        if (data == null) return null;

        // Example: you can read products like this
        final products = (data['products'] as List?) ?? [];
        print("✅ Banner $bannerId products: ${products.length}");

        return data; // contains image/title/category/brand/products…
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
        _redirectToLoginIfNotGuest();
      } else {
        getSnackBar("Failed to load banner details");
      }
    } catch (e, st) {
      print("❌ Banner detail error: $e\n$st");
      getSnackBar("An error occurred while loading banner details.");
    }
    return null;
  }

  Future<void> getBrandData(String type, int gender, {String? query}) async {
    isBrand.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      final base = ApiConstants.baseUrl; // use laFetch host per your API
      final baseUri = Uri.parse(base);

      // Only server-side filter we know: isFeatured=true
      final qp = <String, String>{};
      if (type == "featured") {
        qp["isFeatured"] = "true";
      }

      final uri = baseUri.replace(
        path: baseUri.path.endsWith('/')
            ? '${baseUri.path}brands'
            : '${baseUri.path}/brands',
        queryParameters: qp.isEmpty ? null : qp,
      );

      final headers = <String, String>{
        'Accept': 'application/json; charset=UTF-8'
      };
      final token = prefs.getString('token');
      if (token != null && token.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));
      print("➡️ Brand API URL: $uri");
      print("⬅️ Status Code: ${response.statusCode}");

      if (response.statusCode == 401) {
        getSnackBar("Session expired. Please log in again.");
        _redirectToLoginIfNotGuest();
        return;
      }
      if (response.statusCode != 200) {
        String msg = "Unknown error";
        try {
          final err = json.decode(response.body);
          if (err is Map && err['message'] is String) msg = err['message'];
        } catch (_) {}
        getSnackBar("Failed to fetch brands: $msg");
        return;
      }

      final contentType =
          (response.headers['content-type'] ?? '').toLowerCase();
      if (!contentType.contains('application/json')) {
        getSnackBar("Unexpected response while fetching brands.");
        return;
      }

      final decoded = json.decode(response.body);
      final List<dynamic> rawList = (decoded is Map && decoded['data'] is List)
          ? decoded['data'] as List
          : const [];

      // ✅ Client-side filter using provided query or the controller field
      final q = (query ?? brandQuery.value).trim().toLowerCase();
      final List<Map<String, dynamic>> filtered = (q.isEmpty
              ? rawList
              : rawList.where((b) {
                  final name = (b is Map && b['name'] != null)
                      ? b['name'].toString()
                      : '';
                  return name.toLowerCase().contains(q);
                }))
          .whereType<Map<String, dynamic>>()
          .toList();

      // Group & sort alphabetically
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (final item in filtered) {
        final name = (item['name'] ?? '').toString().trim();
        final key = name.isEmpty ? '#' : name[0].toUpperCase();
        (grouped[key] ??= <Map<String, dynamic>>[]).add(item);
      }

      final sortedGroups = grouped.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      brandList = [];
      for (final g in sortedGroups) {
        g.value.sort((a, b) => (a['name'] ?? '')
            .toString()
            .toLowerCase()
            .compareTo((b['name'] ?? '').toString().toLowerCase()));
        brandList.add({'alphabet': g.key});
        brandList.addAll(g.value);
      }

      selected.clear();
      selected = List<bool>.generate(brandList.length, (_) => false);

      print(
          "✅ Brands loaded: ${filtered.length} | Groups: ${sortedGroups.length}");
    } on TimeoutException {
      print("⏳ Brand API timeout");
      getSnackBar("Brands request timed out. Please try again.");
    } catch (e) {
      print("❌ Error fetching brand data: $e");
      getSnackBar("Something went wrong while fetching brands.");
    } finally {
      isBrand.value = false;
    }
  }

  Future<void> getCategoryData(int genderType) async {
    isCategory.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/categories?type=popular&gender_type=$genderType"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          categoryList = responseData["data"];
        }
      } else if (response.statusCode == 500) {
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get category failed");
      }
    } catch (e) {
      print("error$e");
    }
    isCategory.value = false;
  }

  // void callSendDeviceToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   try {
  //     final Map<String, dynamic> sendData = {
  //       "player_id": playerId.value,
  //       "device_model": devicename,
  //       "apn_token": "some-token",
  //       "fcm_token": fcmToken.value,
  //       "platform": platform,
  //     };
  //     dynamic response;
  //     if (prefs.getString('token') != null) {
  //       response =
  //           await http.put(Uri.parse("${ApiConstants.baseUrl}/device-tokens"),
  //               headers: <String, String>{
  //                 'Accept': 'application/json; charset=UTF-8',
  //                 'Content-Type': 'application/json;charset=UTF-8',
  //                 "Authorization": "Bearer ${prefs.getString('token')} ",
  //               },
  //               body: json.encode(sendData));
  //     }
  //     if (response.statusCode == 201) {
  //       print("device token sent");
  //     } else if (response.statusCode == 500) {
  //     } else if (response.statusCode == 401) {
  //       getSnackBar("Authentication failed");
  //       Get.offAll(
  //         () => const LoginScreen(
  //           initialTab: 0,
  //         ),
  //       );
  //     } else {
  //       print("device token failed");
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  getFaqData() async {
    isFaqs.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(Uri.parse("${ApiConstants.baseUrl}/faqs"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          FaqsList = responseData["data"];
        }
      } else if (response.statusCode == 500) {
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get faqs failed");
      }
    } catch (e) {
      print("error$e");
    }
    isFaqs.value = false;
  }

  Future<void> sendFcmToken({
    required int userId,
    required String token,
    required String deviceType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('fcm_token');
    final authToken = prefs.getString('token')?.trim() ?? '';

    // ✅ Validate auth token before proceeding
    if (authToken.isEmpty) {
      print("⚠️ No auth token available - cannot send FCM token");
      return;
    }

    if (userId <= 0) {
      print("⚠️ Invalid userId - cannot send FCM token");
      return;
    }

    // ✅ Skip API if token already saved locally (same device token)
    if (savedToken == token) {
      print("✅ FCM token already registered locally — skipping API call");
      return;
    }

    final uri = Uri.parse("${ApiConstants.baseUrl}/fcm-token");

    try {
      print("📤 Sending FCM token → $uri");
      print("📤 UserId: $userId, DeviceType: $deviceType");

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          "userId": userId,
          "token": token,
          "deviceType": deviceType,
        }),
      );

      print("📥 FCM Token Status: ${response.statusCode}");
      print("📥 Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Save token locally so we don't hit again
        await prefs.setString('fcm_token', token);
        print("✅ FCM token registered and saved locally");
      } else if (response.statusCode == 409) {
        // ✅ If backend says "already exists", still store it to skip next time
        await prefs.setString('fcm_token', token);
        print(
            "⚠️ Token already exists on server — stored locally to avoid repeat");
      } else if (response.statusCode == 401) {
        print("❌ Authentication failed - auth token may be invalid");
        getSnackBar("Authentication failed");
        _redirectToLoginIfNotGuest();
      } else {
        final decoded = json.decode(response.body);
        getSnackBar(decoded['message'] ?? "Failed to send FCM token");
      }
    } catch (e, st) {
      print("❌ FCM token error: $e\n$st");
      getSnackBar("An error occurred while sending FCM token.");
    }
  }
}
