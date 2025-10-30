// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/loginscreen.dart';
import 'base_controller.dart';

class CatalogController extends BaseController {
  RxBool isCatalog = false.obs;
  RxBool isCatalogCategory = false.obs;
  List catalogList = [].obs;
  List catagoryList = [].obs;
  RxBool isCategory = false.obs;
  RxString categoryName = "Men".obs;
  RxInt selectCategoryGender = 2.obs;
  List categoryProductList = [].obs;

  Future<void> getCatalogData(int gender) async {
    isCatalog.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      final url = Uri.parse(
          "${ApiConstants.baseUrl}/categories?gender=$gender&type=category");
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': "Bearer ${prefs.getString('token')}",
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData["data"] != null) {
        catalogList = responseData["data"];
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again later");
      } else {
        getSnackBar(responseData["message"] ?? "Failed to fetch categories");
      }
    } catch (e) {
      print("getCatalogData error: $e");
      getSnackBar("Something went wrong");
    }

    isCatalog.value = false;
  }

  getCatagoryData(int type) async {
    isCatalogCategory.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/catalogs?gender_type=$type"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          catagoryList = responseData["data"];
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
        getSnackBar("get catalog failed");
      }
    } catch (e) {
      print("error$e");
    }
    isCatalogCategory.value = false;
  }

  Future<void> getCategoryProductData(int categoryId, int type) async {
    // 'type' kept in the signature to avoid changing call sites (ignored here)
    isCategory.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/products")
          .replace(queryParameters: {"catId": categoryId.toString()});

      final response = await http.get(
        uri,
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // API shape: { status, message, data: [ ...products ] }
        final List data =
            (decoded["data"] is List) ? decoded["data"] : const [];
        categoryProductList = data.whereType<Map<String, dynamic>>().toList();
        // print(categoryProductList); // optional
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      } else if (response.statusCode == 500) {
      } else {
        getSnackBar("Failed to load products");
      }
    } catch (e) {
      print("getCategoryProductData error: $e");
      getSnackBar("Something went wrong");
    } finally {
      isCategory.value = false;
    }
  }

  callAddProductToWishlist(
    int wishlistId,
    int id,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/products/$id/wishlist/$wishlistId"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseData["wishlisted"]) {
          Get.close(1);
        }
      } else if (response.statusCode == 500) {
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("item add failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
