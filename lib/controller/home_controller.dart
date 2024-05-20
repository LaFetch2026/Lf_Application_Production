// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../utils/constants.dart';
import 'package:device_info_plus/device_info_plus.dart';

class HomeController extends BaseController {
  RxBool isBanner1 = false.obs;
  RxBool istags = false.obs;
  RxBool isBanner2 = false.obs;
  RxBool isCategory = false.obs;
  RxString playerId = "".obs;
  RxString fcmToken = "".obs;
  String devicename = "";
  String platform = "";
  List tagsList = [].obs;
  List banner2List = [].obs;
  List banner1List = [].obs;
  List categoryList = [].obs;
  RxInt currentPage = 0.obs;
  Timer? timer;
  RxBool loadMore = false.obs;
  RxBool hasnextpage = true.obs;
  RxInt page = 1.obs;
  RxInt tagId = 0.obs;
  RxInt current = 0.obs;
  ScrollController listController = ScrollController();
  final PageController pageController = PageController(
    initialPage: 0,
  );

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

  getTagsData() async {
    istags.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(Uri.parse("${ApiConstants.baseUrl}/tags"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          tagsList = responseData["data"];
          if (tagsList.isNotEmpty) {
            tagId.value = tagsList[0]["id"];
          }
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get tags failed ${response.statusCode}");
      }
    } catch (e) {
      print("error$e");
    }
    istags.value = false;
  }

  fetchMoreTagsData() async {
    if (hasnextpage.value == true &&
        istags.value == false &&
        loadMore.value == false) {
      loadMore.value = true;
      page.value += 1;
      print(page.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse("${ApiConstants.baseUrl}/tags?page=${page.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              tagsList.addAll(responseData['data']);
            } else {
              hasnextpage.value = false;
            }
          }
        } else if (response.statusCode == 500) {
          getSnackBar("Server Error");
        } else if (response.statusCode == 401) {
          Get.offAll(
            () => const LoginScreen(
              initialTab: 0,
            ),
          );
          getSnackBar("Authentication failed");
        } else {
          getSnackBar("fetch tags failed");
        }
      } catch (e) {
        print("error$e");
      }
      loadMore.value = false;
    }
  }

  getCategoryData() async {
    isCategory.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/categories"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          categoryList = responseData;
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
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

  getBannar1Data() async {
    isBanner1.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/banners?type=1"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          banner1List = responseData;
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get banner failed");
      }
    } catch (e) {
      print("error$e");
    }
    isBanner1.value = false;
  }

  getBannar2Data() async {
    isBanner2.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/banners?type=2"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          banner2List = responseData;
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get banner 2 failed");
      }
    } catch (e) {
      print("error$e");
    }
    isBanner2.value = false;
  }

  void callSendDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "player_id": playerId.value,
        "device_model": devicename,
        "apn_token": fcmToken.value,
        "fcm_token": fcmToken.value,
        "platform": platform,
      };
      var response =
          await http.put(Uri.parse("${ApiConstants.baseUrl}/device-tokens"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                'Content-Type': 'application/json;charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              },
              body: json.encode(sendData));
      if (response.statusCode == 201) {
        print("device token sent");
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
      } else {
        print("device token failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
