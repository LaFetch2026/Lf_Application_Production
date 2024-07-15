// ignore_for_file: avoid_print
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
  RxBool isCity = false.obs;
  RxBool istags = false.obs;
  RxBool isBanner2 = false.obs;
  RxBool isCategory = false.obs;
  RxString playerId = "".obs;
  RxString fcmToken = "".obs;
  String devicename = "";
  String platform = "";
  List tagsList = [].obs;
  List banner2List = [].obs;
  List cityList = [].obs;
  List banner1List = [].obs;
  List bannerTag1Id = [].obs;
  List bannerTag2Id = [].obs;
  List categoryList = [].obs;
  RxInt currentPage = 0.obs;
  List banners = [].obs;
  RxBool loadMore = false.obs;
  RxBool hasnextpage = true.obs;
  RxInt page = 1.obs;
  RxInt tagId = 0.obs;
  RxInt current = 0.obs;
  ScrollController tagsController = ScrollController();

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tagsController.addListener(() {
        fetchMoreTagsData();
        update();
      });
    });
    hasnextpage.value = true;
    loadMore.value = false;
    istags.value = false;
    page.value = 1;
    update();
    WidgetsBinding.instance.addPostFrameCallback((_) => getTagsData());
    super.onInit();
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

  getConfigurationData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/global-configuration"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          prefs.setInt('tagId', responseData['new_arrival_tag_id']);
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
        getSnackBar("get configuration failed ${response.statusCode}");
      }
    } catch (e) {
      print("error$e");
    }
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

  getCitiesData() async {
    isCity.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(Uri.parse("${ApiConstants.baseUrl}/cities"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          cityList = responseData["data"];
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
        getSnackBar("get wishlist failed");
      }
    } catch (e) {
      print("error$e");
    }
    isCity.value = false;
  }

  getCategoryData(int genderType) async {
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
          if (banner1List.isNotEmpty) {
            prefs.setString("bannerImage", jsonEncode(banner1List));
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
