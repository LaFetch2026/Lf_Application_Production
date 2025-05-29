// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/loginscreen.dart';
import 'base_controller.dart';

class BrandController extends BaseController {
  TextEditingController searchController = TextEditingController();
  RxInt page = 1.obs;
  RxBool isMuted = false.obs;

  RxBool loadMore = false.obs;
  RxBool hasnextpage = true.obs;
  ScrollController brandListController = ScrollController();
  RxString queryText = "".obs;
  RxBool isBrand = false.obs;
  List brandList = [].obs;
  RxString brandName = "".obs;
  RxString brandlogo = "".obs;
  RxString brandbackground = "".obs;
  RxInt brandId = 0.obs;
  RxString text = "Expand All".obs;
  RxBool showAllBrand = false.obs;
  RxBool isDetails = false.obs;
  dynamic brandDetails = "".obs;
  RxBool isCategory = false.obs;
  RxBool isProductBrand = false.obs;
  List categoryList = [].obs;
  List brand_category_List = [].obs;
  List brandProductDetailsList = [].obs;
  RxInt selectIndex = 0.obs;
  List<bool> selected = List.generate(50, (i) => false).obs;

  /*  @override
  void onInit() async {
    listController.addListener(() {
      fetchMoreData();
      update();
    });
    super.onInit();
  } */

  getBrandData(String type) async {
    isBrand.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (type == "express") {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/brands?q=${queryText.value}&express_delivery=1"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      } else if (type == "brand") {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/brands?q=${queryText.value}&type=alphabet"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      } else {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/brands?q=${queryText.value}&type=recently-viewed"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      }
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (type == "brand") {
          brandList = responseData;
        } else {
          if (responseData["data"] != null) {
            brandList = responseData["data"];
            print(brandList.length);
            selected.clear();
            selected = List.generate(brandList.length, (i) => false);
          }
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        /*  Get.to(
          () => const LoginScreen(
            initialTab: 0,
          ),
        ); */
        // getSnackBar("Authentication failed");
        print(response..statusCode);
      } else {
        getSnackBar("get brand failed");
      }
    } catch (e) {
      print("error$e");
    }
    isBrand.value = false;
  }

  fetchMoreData(String type) async {
    if (hasnextpage.value == true &&
        isBrand.value == false &&
        loadMore.value == false) {
      loadMore.value = true;
      page.value += 1;
      print(page.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        dynamic response;
        if (type == "express") {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/brands?q=${queryText.value}&page=${page.value}&express_delivery=1"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        } else if (type == "brand") {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/brands?q=${queryText.value}&page=${page.value}&type=alphabet"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        } else {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/brands?q=${queryText.value}&page=${page.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        }
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (type == "brand") {
            if (responseData.isNotEmpty) {
              brandList.addAll(responseData);
            } else {
              hasnextpage.value = false;
            }
          } else {
            if (responseData["data"] != null) {
              if (responseData["data"].isNotEmpty) {
                print(responseData);
                brandList.addAll(responseData['data']);
                print(brandList.length);
                selected.clear();
                selected = List.generate(brandList.length, (i) => false);
              } else {
                hasnextpage.value = false;
              }
            }
          }
        } else if (response.statusCode == 500) {
          getSnackBar("Please try again");
        } else if (response.statusCode == 401) {
          Get.offAll(
            () => const LoginScreen(
              initialTab: 0,
            ),
          );
          getSnackBar("Authentication failed");
        } else {
          getSnackBar("fetch brand failed");
        }
      } catch (e) {
        print("error$e");
      }
      loadMore.value = false;
    }
  }

  getBrandDetails(int id, String slug) async {
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (id != 0) {
        response = await http.get(
            Uri.parse("${ApiConstants.baseUrl}/brand/$id"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      } else {
        response = await http.get(
            Uri.parse("${ApiConstants.baseUrl}/brand/$slug"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      }
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        brand_category_List.clear();
        brandDetails = responseData;
        for (var i = 0; i < responseData["categories"].length; i++) {
          brand_category_List.add(responseData["categories"][i]["id"]);
        }
        getBrandDetailsProduct(responseData["id"], brand_category_List);
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get brand details failed");
      }
    } catch (e) {
      print("error$e");
    }
    isDetails.value = false;
  }

  getBrandDetailsProduct(int brandId, List categoryList) async {
    isProductBrand.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products?brand_id=$brandId&categories_ids[]=${categoryList.join(',')}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          brandProductDetailsList = responseData["data"];
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        print(response.statusCode);
      } else {
        getSnackBar("get brand details product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isProductBrand.value = false;
  }
}
