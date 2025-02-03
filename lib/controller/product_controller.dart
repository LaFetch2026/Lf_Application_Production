// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/change_address.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../screens/catalog/productlistscreen.dart';
import '../utils/constants.dart';

class ProductController extends BaseController {
  RxBool isProduct = false.obs;
  RxBool isFilter = false.obs;
  RxBool isMostSearch = false.obs;
  RxBool isHomeProduct = false.obs;
  RxBool istags = false.obs;
  RxString errorMsg = "".obs;
  RxBool isCategoryProduct = false.obs;
  RxBool istagsProduct = false.obs;
  RxBool isBannerTag = false.obs;
  RxBool isBrandExpressProduct = false.obs;
  RxBool isExpress = false.obs;
  RxBool isHandPicked = false.obs;
  RxBool isDetails = false.obs;
  RxBool isReview = false.obs;
  RxBool isPincode = false.obs;
  RxBool isReorder = false.obs;
  RxBool showSizeList = true.obs;
  RxBool isBestSeller = false.obs;
  RxBool isFrequentlyBought = false.obs;
  RxInt currentpage = 0.obs;
  RxInt inventoryId = 0.obs;
  RxInt tagId = 0.obs;
  RxInt sizeInventoryId = 0.obs;
  RxInt colorInventoryId = 0.obs;
  RxInt fabricInventoryId = 0.obs;
  dynamic productDetails = "".obs;
  dynamic selectedProductSize = {}.obs;
  dynamic selectedProductColor = {}.obs;
  dynamic brandDetails = "".obs;
  dynamic compositionDetails = "".obs;
  RxString returnPolicyDetails = "".obs;
  RxBool isRecommendations = false.obs;
  List tagsList = [].obs;
  List homeProductList = [].obs;
  List handPickedProductList = [].obs;
  List frequentlyProductList = [].obs;
  List tagProductList = [].obs;
  List productList = [].obs;
  List filterList = [].obs;
  RxString tagname = "We think you might also like".obs;
  List mostSeachList = [].obs;
  List expressProductList = [].obs;
  List productCategoryList = [].obs;
  List productExpressBrandList = [].obs;
  RxInt total = 0.obs;
  RxInt curr = 0.obs;
  RxInt index = 0.obs;
  RxInt current = 50.obs;
  RxInt totalExpress = 0.obs;
  List inventoryList = [].obs;
  List sizeInventoryList = [].obs;
  List colorInventoryList = [].obs;
  List fabricInventoryList = [].obs;
  List reviewList = [].obs;
  List recommendedList = [].obs;
  List bestSellerList = [].obs;
  RxInt totalProductValue = 0.obs;
  final pincodeController = TextEditingController();
  RxBool loadMore = false.obs;
  RxBool hasnextpage = true.obs;
  RxBool homeTagsloadMore = false.obs;
  RxBool homeTagshasnextpage = true.obs;
  RxInt homeTagsPage = 1.obs;
  RxInt categoryFilter = 0.obs;
  RxInt categoryProductGender = 0.obs;
  RxBool filterEnable = false.obs;
  RxBool filterExpressEnable = false.obs;
  RxBool filterProductEnable = false.obs;
  RxInt page = 1.obs;
  RxInt lowPrice = 500.obs;
  RxInt highPrice = 500000.obs;
  ScrollController listController = ScrollController();
  ScrollController handpickedController = ScrollController();
  ScrollController brandProductController = ScrollController();
  ScrollController recentListController = ScrollController();
  RxBool expressLoadMore = false.obs;
  RxBool expressHasnextpage = true.obs;
  RxInt expressPage = 1.obs;
  RxBool handpickedLoadMore = false.obs;
  RxBool handpickedHasnextpage = true.obs;
  RxInt handpickedPage = 1.obs;
  ScrollController expressListController = ScrollController();
  ScrollController categoryProductController = ScrollController();
  ScrollController brandDetailsController = ScrollController();
  RxBool categoryProductLoadMore = false.obs;
  RxBool categoryProductHasnextpage = true.obs;
  RxInt categoryProductPage = 1.obs;
  ScrollController brandExpressProductController = ScrollController();
  RxBool brandExpressLoadMore = false.obs;
  RxBool brandExpressHasnextpage = true.obs;
  RxInt brandExpressPage = 1.obs;
  ScrollController tagsProductController = ScrollController();
  RxBool tagsLoadMore = false.obs;
  RxBool tagsHasnextpage = true.obs;
  RxInt tagsPage = 1.obs;
  ScrollController mostViewController = ScrollController();
  RxBool mostViewLoadMore = false.obs;
  RxBool mostViewHasnextpage = true.obs;
  RxInt mostViewPage = 1.obs;
  ScrollController bannerTagController = ScrollController();
  RxBool bannerTagLoadMore = false.obs;
  RxBool bannerTagHasnextpage = true.obs;
  RxInt bannerTagPage = 1.obs;
  ScrollController frequentlyBoughtController = ScrollController();
  RxBool frequentlyBoughtLoadMore = false.obs;
  RxBool frequentlyBoughtHasnextpage = true.obs;
  RxInt frequentlyBoughtPage = 1.obs;
  ScrollController recommendedController = ScrollController();
  RxBool recommendedLoadMore = false.obs;
  RxBool recommendedHasnextpage = true.obs;
  RxInt recommendedPage = 1.obs;
  ScrollController bestSellerController = ScrollController();
  ScrollController tagsController = ScrollController();
  RxBool bestSellerLoadMore = false.obs;
  RxBool bestSellerHasnextpage = true.obs;
  RxInt bestSellerPage = 1.obs;
  RxBool brandProductLoadMore = false.obs;
  RxBool brandProductHasnextpage = true.obs;
  RxInt brandProductPage = 1.obs;
  List brandProductDetailsList = [].obs;
  RxBool isProductBrand = false.obs;
  RxBool isVideoPlaying = true.obs;
  RxString sortBy = "".obs;
  RxString expressSortBy = "".obs;
  RxString productSortBy = "".obs;
  List brand_ids = [].obs;
  List color_ids = [].obs;
  List size_ids = [].obs;
  List addressList = [].obs;
  List pricelist = [100, 5000].obs;
  RxBool isPrice = true.obs;
  RxInt category_id = 0.obs;
  RxInt totalReview = 0.obs;
  RxInt productImageindex = 0.obs;
  RxInt catalogIndex = 0.obs;
  RxInt brand_id = 0.obs;
  RxBool isEstimateDate = false.obs;
  dynamic getItBy = "".obs;
  RxBool isAddress = false.obs;
  dynamic defaultAddress = "".obs;
  RxBool addToCart = false.obs;
  RxBool isColorimage = false.obs;
  List imageList = [].obs;
  RxBool isExpressDelivery = false.obs;
  RxInt expressValue = 0.obs;
  List productCategory = [].obs;
  List productTags = [].obs;
  List brandProductList = [].obs;
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  RxBool isBrandProduct = false.obs;
  RxBool isBrand = false.obs;
  RxInt id = 0.obs;
  RxBool showAddressList = false.obs;
  RxString addressText = "".obs;
  RxString addressTypeValue = "".obs;
  List<bool> reorderSelected = List.generate(50, (i) => false).obs;
  TextEditingController brandController = TextEditingController();
  TextEditingController branddetailsSearchController = TextEditingController();

  bool checkPinvalidation(String pin) {
    if (pin.isEmpty) {
      getSnackBar(
        "Enter Pincode",
      );
      return false;
    }
    if (pin.length < 6) {
      getSnackBar(
        "The pincode must be 6 digit.",
      );
      return false;
    }
    return true;
  }

  bool checkDetailsValidation() {
    if (sizeInventoryId.value == 0 && sizeInventoryList.isNotEmpty) {
      getSnackBar(
        "Select Size",
      );
      return false;
    }
    if (colorInventoryId.value == 0 && colorInventoryList.isNotEmpty) {
      getSnackBar(
        "Select color",
      );
      return false;
    }
    /*  if (fabricInventoryId.value == 0 && fabricInventoryList.isNotEmpty) {
      getSnackBar(
        "Select fabric",
      );
      return false;
    } */
    return true;
  }

  getHomeProduct(int gender) async {
    isHomeProduct.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/tags/sections?gender_type=$gender"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData.isNotEmpty) {
          homeProductList = responseData;
        } else {
          homeProductList = [];
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        /* Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed"); */
        print(response.statusCode);
      } else {
        getSnackBar("get home product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isHomeProduct.value = false;
  }

  getBrandProductData() async {
    isBrand.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;

      response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/brands/products?q=${brandController.text.toString().trim()}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });

      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          brandProductList = responseData;
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
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

  getProductData(String type) async {
    isProduct.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products?type=$type&latitude=${lat.value}&longitude=${lng.value}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          productList = responseData["data"];
          hasnextpage.value = true;
          loadMore.value = false;
          isProduct.value = false;
          page.value = 1;
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
        getSnackBar("get product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isProduct.value = false;
  }

  fetchMoreData(String type) async {
    if (hasnextpage.value == true &&
        isProduct.value == false &&
        loadMore.value == false) {
      loadMore.value = true;
      page.value += 1;
      print(page.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?type=$type&page=${page.value}&latitude=${lat.value}&longitude=${lng.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              productList.addAll(responseData['data']);
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
          getSnackBar("fetch product failed");
        }
      } catch (e) {
        print("error$e");
      }
      loadMore.value = false;
    }
  }

  getFrequentlyProductData(String type, int productId) async {
    isFrequentlyBought.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products?type=$type&except_product_id=$productId&latitude=${lat.value}&longitude=${lng.value}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          frequentlyProductList = responseData["data"];
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
        getSnackBar("get frequently product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isFrequentlyBought.value = false;
  }

  fetchFrequentlyMoreData(String type, int productId) async {
    if (frequentlyBoughtHasnextpage.value == true &&
        isFrequentlyBought.value == false &&
        frequentlyBoughtLoadMore.value == false) {
      frequentlyBoughtLoadMore.value = true;
      frequentlyBoughtPage.value += 1;
      print(frequentlyBoughtPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?type=$type&page=${frequentlyBoughtPage.value}&except_product_id=$productId&latitude=${lat.value}&longitude=${lng.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              frequentlyProductList.addAll(responseData['data']);
            } else {
              frequentlyBoughtHasnextpage.value = false;
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
          getSnackBar("fetch frequently product failed");
        }
      } catch (e) {
        print("error$e");
      }
      frequentlyBoughtLoadMore.value = false;
    }
  }

  getHandPickedProduct(
      String handpickSortBy, bool filter, bool enableFilter, int tagId) async {
    isHandPicked.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      if (prefs.getInt('gender') != null && categoryFilter.value == 0) {
        int id = prefs.getInt('gender')!;
        if (id == 1) {
          categoryFilter.value = 3;
        } else if (id == 2) {
          categoryFilter.value = 2;
        } else {
          categoryFilter.value = 1;
        }
      }
      dynamic response;
      String colorString = color_ids.join(',');
      String sizeString = size_ids.join(',');
      String brandString = brand_ids.join(',');
      if (handpickSortBy.isNotEmpty) {
        if (filter) {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?type=handpicked&sort_by=$handpickSortBy&tag_ids[]=${tagId == 0 ? "" : tagId}&gender_type=${categoryFilter.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        } else {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?type=handpicked&sort_by=$handpickSortBy&tag_ids[]=${tagId == 0 ? "" : tagId}&gender_type=${categoryFilter.value}&latitude=${lat.value}&longitude=${lng.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        }
      } else {
        if (filter) {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?type=handpicked&tag_ids[]=${tagId == 0 ? "" : tagId}&gender_type=${categoryFilter.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        } else {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?type=handpicked&tag_ids[]=${tagId == 0 ? "" : tagId}&gender_type=${categoryFilter.value}&latitude=${lat.value}&longitude=${lng.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        }
      }
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        handPickedProductList.clear();
        if (responseData["data"] != null) {
          handPickedProductList = responseData["data"];
          totalProductValue.value = responseData["meta"]["total"];
          handpickedHasnextpage.value = true;
          handpickedLoadMore.value = false;
          isHandPicked.value = false;
          handpickedPage.value = 1;
          if (enableFilter) {
            Get.back();
          }
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        /* Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed"); */
        print(response.statusCode);
      } else {
        getSnackBar("get product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isHandPicked.value = false;
  }

  fetchMoreHandPickedProduct(
      String handpickSortBy, bool filter, int tagId) async {
    if (handpickedHasnextpage.value == true &&
        isHandPicked.value == false &&
        handpickedLoadMore.value == false) {
      handpickedLoadMore.value = true;
      handpickedPage.value += 1;
      print(handpickedPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        dynamic response;
        String colorString = color_ids.join(',');
        String sizeString = size_ids.join(',');
        String brandString = brand_ids.join(',');
        if (handpickSortBy.isNotEmpty) {
          if (filter) {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=handpicked&page=${handpickedPage.value}&tag_ids[]=${tagId == 0 ? "" : tagId}&gender_type=${categoryFilter.value}&sort_by=$handpickSortBy&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          } else {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=handpicked&page=${handpickedPage.value}&tag_ids[]=${tagId == 0 ? "" : tagId}&gender_type=${categoryFilter.value}&sort_by=$handpickSortBy&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          }
        } else {
          if (filter) {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=handpicked&page=${handpickedPage.value}&tag_ids[]=${tagId == 0 ? "" : tagId}&gender_type=${categoryFilter.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          } else {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=handpicked&page=${handpickedPage.value}&tag_ids[]=${tagId == 0 ? "" : tagId}&gender_type=${categoryFilter.value}&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          }
        }
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              handPickedProductList.addAll(responseData['data']);
            } else {
              handpickedHasnextpage.value = false;
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
          getSnackBar("fetch hand picked product failed");
        }
      } catch (e) {
        print("error$e");
      }
      handpickedLoadMore.value = false;
    }
  }

  getBrandDetailsProduct(
      String sortBy, bool filter, bool enableFilter, int brandId) async {
    isProductBrand.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      if (prefs.getInt('gender') != null && categoryFilter.value == 0) {
        int id = prefs.getInt('gender')!;
        if (id == 1) {
          categoryFilter.value = 3;
        } else if (id == 2) {
          categoryFilter.value = 2;
        } else {
          categoryFilter.value = 1;
        }
      }
      dynamic response;
      String colorString = color_ids.join(',');
      String sizeString = size_ids.join(',');
      String brandString = brand_ids.join(',');
      if (sortBy.isNotEmpty) {
        if (filter) {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?type=all&sort_by=$sortBy&q=${branddetailsSearchController.text.toString().trim()}&brand_id[]=${brandId == 0 ? "" : brandId}&gender_type=${categoryFilter.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        } else {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?type=all&sort_by=$sortBy&q=${branddetailsSearchController.text.toString().trim()}&brand_id[]=${brandId == 0 ? "" : brandId}&gender_type=${categoryFilter.value}&latitude=${lat.value}&longitude=${lng.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        }
      } else {
        if (filter) {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?type=all&q=${branddetailsSearchController.text.toString().trim()}&brand_id[]=${brandId == 0 ? "" : brandId}&gender_type=${categoryFilter.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        } else {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?type=all&brand_id[]=${brandId == 0 ? "" : brandId}&q=${branddetailsSearchController.text.toString().trim()}&gender_type=${categoryFilter.value}&latitude=${lat.value}&longitude=${lng.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        }
      }
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        handPickedProductList.clear();
        if (responseData["data"] != null) {
          brandProductDetailsList = responseData["data"];
          brandProductHasnextpage.value = true;
          brandProductLoadMore.value = false;
          isProductBrand.value = false;
          brandProductPage.value = 1;
          if (enableFilter) {
            Get.back();
          }
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        /* Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed"); */
        print(response.statusCode);
      } else {
        getSnackBar("get brand details failed");
      }
    } catch (e) {
      print("error$e");
    }
    isProductBrand.value = false;
  }

  fetchMoreBrandDetails(String sortBy, bool filter, int brandId) async {
    if (brandProductHasnextpage.value == true &&
        isProductBrand.value == false &&
        brandProductLoadMore.value == false) {
      brandProductLoadMore.value = true;
      brandProductPage.value += 1;
      print(brandProductPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        dynamic response;
        String colorString = color_ids.join(',');
        String sizeString = size_ids.join(',');
        String brandString = brand_ids.join(',');
        if (sortBy.isNotEmpty) {
          if (filter) {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=all&page=${brandProductPage.value}&brand_id[]=${brandId == 0 ? "" : brandId}&gender_type=${categoryFilter.value}&sort_by=$sortBy&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          } else {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=all&page=${brandProductPage.value}&brand_id[]=${brandId == 0 ? "" : brandId}&gender_type=${categoryFilter.value}&sort_by=$sortBy&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          }
        } else {
          if (filter) {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=all&page=${brandProductPage.value}&brand_id[]=${brandId == 0 ? "" : brandId}&gender_type=${categoryFilter.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          } else {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=all&page=${brandProductPage.value}&brand_id[]=${brandId == 0 ? "" : brandId}&gender_type=${categoryFilter.value}&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          }
        }
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              brandProductDetailsList.addAll(responseData['data']);
            } else {
              brandProductHasnextpage.value = false;
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
          getSnackBar("fetch brand details product failed");
        }
      } catch (e) {
        print("error$e");
      }
      brandProductLoadMore.value = false;
    }
  }

  getTagsProductData(int tagId, int genderType, int brandId) async {
    istagsProduct.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (genderType != 0) {
        response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products?tag_ids[]=${tagId == 0 ? "" : tagId}&gender_type=$genderType&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
        );
      } else {
        response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products?tag_ids[]=${tagId == 0 ? "" : tagId}&brand_id=$brandId&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
        );
      }

      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          tagProductList = responseData["data"];
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        /*  Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed"); */
        print(response.statusCode);
      } else {
        getSnackBar("get tag product failed");
      }
    } catch (e) {
      print("error$e");
    }
    istagsProduct.value = false;
  }

  fetchMoreTagsProductData(int tagId, int genderType, int brandId) async {
    if (tagsHasnextpage.value == true &&
        istagsProduct.value == false &&
        tagsLoadMore.value == false) {
      tagsLoadMore.value = true;
      tagsPage.value += 1;
      print(page.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        dynamic response;
        if (genderType != 0) {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?tag_ids[]=$tagId&page=${tagsPage.value}&gender_type=$genderType&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        } else {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?tag_ids[]=$tagId&page=${tagsPage.value}&brand_id=$brandId&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        }

        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              tagProductList.addAll(responseData['data']);
            } else {
              tagsHasnextpage.value = false;
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
          getSnackBar("fetch tag product failed");
        }
      } catch (e) {
        print("error$e");
      }
      tagsLoadMore.value = false;
    }
  }

  getTagsBannerData(
    List list,
    List categoryList,
    int genderType,
    String sory_by,
    bool filter,
    bool filterButton,
  ) async {
    isCategoryProduct.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (categoryList.isNotEmpty) {
        String colorString = color_ids.join(',');
        String sizeString = size_ids.join(',');
        String brandString = brand_ids.join(',');
        if (sory_by.isNotEmpty) {
          if (filter) {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?tag_ids[]=${list.join(',')}&categories_ids[]=${categoryList.join(',')}&sort_by=$sory_by&gender_type=$genderType&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          } else {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?tag_ids[]=${list.join(',')}&categories_ids[]=${categoryList.join(',')}&sort_by=$sory_by&gender_type=$genderType&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          }
        } else {
          if (filter) {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?tag_ids[]=${list.join(',')}&categories_ids[]=${categoryList.join(',')}&gender_type=$genderType&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          } else {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?tag_ids[]=${list.join(',')}&categories_ids[]=${categoryList.join(',')}&gender_type=$genderType&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          }
        }
        /*   response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products?tag_ids[]=${list.join(',')}&categories_ids[]=${categoryList.join(',')}&latitude=${lat.value}&longitude=${lng.value}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
        ); */
      } else {
        String colorString = color_ids.join(',');
        String sizeString = size_ids.join(',');
        String brandString = brand_ids.join(',');
        if (sory_by.isNotEmpty) {
          if (filter) {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?tag_ids[]=${list.join(',')}&sort_by=$sory_by&gender_type=$genderType&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          } else {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?tag_ids[]=${list.join(',')}&sort_by=$sory_by&gender_type=$genderType&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          }
        } else {
          if (filter) {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?tag_ids[]=${list.join(',')}&gender_type=$genderType&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          } else {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?tag_ids[]=${list.join(',')}&gender_type=$genderType&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          }
        }
        /* response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products?tag_ids[]=${list.join(',')}&gender_type=$genderType&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
        ); */
      }

      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          productCategoryList = responseData["data"];
          total.value = responseData["meta"]["total"];
          isCategoryProduct.value = false;
          bannerTagHasnextpage.value = true;
          bannerTagLoadMore.value = false;
          bannerTagPage.value = 1;

          if (filterButton) {
            Get.back();
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
        getSnackBar("get banner tag product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isCategoryProduct.value = false;
  }

  fetchMoreBannerTagProductData(List list, List categoryList, int genderType,
      String sory_by, bool filter) async {
    if (bannerTagHasnextpage.value == true &&
        isCategoryProduct.value == false &&
        bannerTagLoadMore.value == false) {
      bannerTagLoadMore.value = true;
      bannerTagPage.value += 1;
      print(bannerTagPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        dynamic response;
        /*  if (categoryList.isNotEmpty) {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?page=${bannerTagPage.value}&tag_ids[]=${list.join(',')}&categories_ids[]=${categoryList.join(',')}&latitude=${lat.value}&longitude=${lng.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        } else {
          response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?tag_ids[]=${list.join(',')}&gender_type=$genderType&page=${bannerTagPage.value}&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            },
          );
        } */
        if (categoryList.isNotEmpty) {
          String colorString = color_ids.join(',');
          String sizeString = size_ids.join(',');
          String brandString = brand_ids.join(',');
          if (sory_by.isNotEmpty) {
            if (filter) {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?page=${bannerTagPage.value}&tag_ids[]=${list.join(',')}&categories_ids[]=${categoryList.join(',')}&sort_by=$sory_by&gender_type=$genderType&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            } else {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?page=${bannerTagPage.value}&tag_ids[]=${list.join(',')}&categories_ids[]=${categoryList.join(',')}&sort_by=$sory_by&gender_type=$genderType&latitude=${lat.value}&longitude=${lng.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            }
          } else {
            if (filter) {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?page=${bannerTagPage.value}&tag_ids[]=${list.join(',')}&categories_ids[]=${categoryList.join(',')}&gender_type=$genderType&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            } else {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?page=${bannerTagPage.value}&tag_ids[]=${list.join(',')}&categories_ids[]=${categoryList.join(',')}&gender_type=$genderType&latitude=${lat.value}&longitude=${lng.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            }
          }
        } else {
          String colorString = color_ids.join(',');
          String sizeString = size_ids.join(',');
          String brandString = brand_ids.join(',');
          if (sory_by.isNotEmpty) {
            if (filter) {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?page=${bannerTagPage.value}&tag_ids[]=${list.join(',')}&sort_by=$sory_by&gender_type=$genderType&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            } else {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?page=${bannerTagPage.value}&tag_ids[]=${list.join(',')}&sort_by=$sory_by&gender_type=$genderType&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            }
          } else {
            if (filter) {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?page=${bannerTagPage.value}&tag_ids[]=${list.join(',')}&gender_type=$genderType&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            } else {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?page=${bannerTagPage.value}&tag_ids[]=${list.join(',')}&gender_type=$genderType&latitude=${lat.value}&longitude=${lng.value}&type=recently-viewed"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            }
          }
        }
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              productCategoryList.addAll(responseData['data']);
            } else {
              bannerTagHasnextpage.value = false;
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
          getSnackBar("fetch banner tag product failed");
        }
      } catch (e) {
        print("error$e");
      }
      bannerTagLoadMore.value = false;
    }
  }

  getExpressProductData(int tagid, int genderType) async {
    isExpress.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (genderType != 0) {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?type=express&gender_type=$genderType&tag_ids[]=${tagid == 0 ? "" : tagId}&latitude=${lat.value}&longitude=${lng.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      } else {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?type=express&tag_ids[]=${tagid == 0 ? "" : tagId}&latitude=${lat.value}&longitude=${lng.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      }

      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          expressProductList = responseData["data"];
          totalExpress.value = responseData["meta"]["total"];
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
        getSnackBar("get product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isExpress.value = false;
  }

  fetchExpressMoreData(int tagid, int genderType) async {
    if (expressHasnextpage.value == true &&
        isExpress.value == false &&
        expressLoadMore.value == false) {
      expressLoadMore.value = true;
      expressPage.value += 1;
      print(expressPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        dynamic response;
        if (genderType != 0) {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?type=express&page=${expressPage.value}&gender_type=$genderType&tag_ids[]=$tagid&latitude=${lat.value}&longitude=${lng.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        } else {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?type=express&page=${expressPage.value}&tag_ids[]=$tagid&latitude=${lat.value}&longitude=${lng.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        }

        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              expressProductList.addAll(responseData['data']);
            } else {
              expressHasnextpage.value = false;
            }
          }
        } else if (response.statusCode == 500) {
          getSnackBar("Server Error");
        } else if (response.statusCode == 401) {
          Get.to(
            () => const LoginScreen(
              initialTab: 0,
            ),
          );
          // getSnackBar("Authentication failed");
        } else {
          getSnackBar("fetch express product failed");
        }
      } catch (e) {
        print("error$e");
      }
      expressLoadMore.value = false;
    }
  }

  getBestSellerProductData(int brandId) async {
    isBestSeller.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products-best-seller?brand_id=$brandId&latitude=${lat.value}&longitude=${lng.value}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          bestSellerList = responseData;
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
        getSnackBar("get best seller product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isBestSeller.value = false;
  }

  /*  fetchBestSellerData() async {
    if (bestSellerHasnextpage.value == true &&
        isBestSeller.value == false &&
        bestSellerLoadMore.value == false) {
      bestSellerLoadMore.value = true;
      bestSellerPage.value += 1;
      print(bestSellerPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/best-seller-products?page=${bestSellerPage.value}&brand_id=$brandId"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              bestSellerList.addAll(responseData['data']);
            } else {
              bestSellerHasnextpage.value = false;
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
          getSnackBar("fetch best sellerproduct failed");
        }
      } catch (e) {
        print("error$e");
      }
      bestSellerLoadMore.value = false;
    }
  }
 */
  getFilterData(String type) async {
    isFilter.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products-filter-paramters?type=$type"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          filterList = responseData;
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
        getSnackBar("get filter failed");
      }
    } catch (e) {
      print("error$e");
    }
    isFilter.value = false;
  }

  getBrandExpressProductData(
      int brandId, String expressSort, bool filter) async {
    isBrandExpressProduct.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (brandId != 0) {
        String colorString = color_ids.join(',');
        String sizeString = size_ids.join(',');
        String brandString = brand_ids.join(',');
        if (expressSort.isNotEmpty) {
          if (filter) {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=express&brand_id=$brandId&sort_by=$expressSort&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          } else {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=express&brand_id=$brandId&sort_by=$expressSort&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          }
        } else {
          if (filter) {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=express&brand_id=$brandId&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          } else {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=express&brand_id=$brandId&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          }
        }
      } else {
        String colorString = color_ids.join(',');
        String sizeString = size_ids.join(',');
        String brandString = brand_ids.join(',');
        if (expressSort.isNotEmpty) {
          if (filter) {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=express&sort_by=$expressSort&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          } else {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=express&sort_by=$expressSort&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          }
        } else {
          if (filter) {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=express&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          } else {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?type=express&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          }
        }
      }
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"].isNotEmpty) {
          productExpressBrandList = responseData["data"];
        } else {
          productExpressBrandList.clear();
        }
        if (filter) {
          Get.back();
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        /*  Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed"); */
        print(response..statusCode);
      } else {
        getSnackBar("get product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isBrandExpressProduct.value = false;
  }

  fetchBrandExpressMoreData(String expressSort, bool filter) async {
    if (brandExpressHasnextpage.value == true &&
        isBrandExpressProduct.value == false &&
        brandExpressLoadMore.value == false) {
      brandExpressLoadMore.value = true;
      brandExpressPage.value += 1;
      print(brandExpressPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        dynamic response;
        if (brand_id.value != 0) {
          String colorString = color_ids.join(',');
          String sizeString = size_ids.join(',');
          String brandString = brand_ids.join(',');
          if (expressSort.isNotEmpty) {
            if (filter) {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?type=express&brand_id=${brand_id.value}&page=${brandExpressPage.value}&sort_by=$expressSort&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            } else {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?type=express&brand_id=${brand_id.value}&page=${brandExpressPage.value}&sort_by=$expressSort&latitude=${lat.value}&longitude=${lng.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            }
          } else {
            if (filter) {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?type=express&brand_id=${brand_id.value}&page=${brandExpressPage.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            } else {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?type=express&brand_id=${brand_id.value}&page=${brandExpressPage.value}&latitude=${lat.value}&longitude=${lng.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            }
          }
        } else {
          String colorString = color_ids.join(',');
          String sizeString = size_ids.join(',');
          String brandString = brand_ids.join(',');
          if (expressSort.isNotEmpty) {
            if (filter) {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?type=express&page=${brandExpressPage.value}&sort_by=$expressSort&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            } else {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?type=express&page=${brandExpressPage.value}&sort_by=$expressSort&latitude=${lat.value}&longitude=${lng.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            }
          } else {
            if (filter) {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?type=express&page=${brandExpressPage.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            } else {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?type=express&page=${brandExpressPage.value}&latitude=${lat.value}&longitude=${lng.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            }
          }
        }

        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              productExpressBrandList.addAll(responseData['data']);
            } else {
              brandExpressHasnextpage.value = false;
            }
          }
        } else if (response.statusCode == 500) {
          getSnackBar("Server Error");
        } else if (response.statusCode == 401) {
          /*  Get.offAll(
            () => const LoginScreen(
              initialTab: 0,
            ),
          );
          getSnackBar("Authentication failed"); */
          print(response..statusCode);
        } else {
          getSnackBar("fetch category product failed");
        }
      } catch (e) {
        print("error$e");
      }
      brandExpressLoadMore.value = false;
    }
  }

  getProductByCategoryData(
    int categoryId,
    int brandId,
    String value,
    List categoryList,
    String sort_By,
    int gendertype,
    bool filter,
    int catalogId,
    bool filterButton,
    String type,
  ) async {
    isCategoryProduct.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (type == "catalog") {
        if (brandId != 0) {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?category_id=$categoryId&brand_id=$brandId&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        } else {
          if (categoryId == 0) {
            String colorString = color_ids.join(',');
            String sizeString = size_ids.join(',');
            String brandString = brand_ids.join(',');
            if (sort_By.isEmpty) {
              if (filter) {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?catalog_id=$catalogId&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              } else {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?catalog_id=$catalogId&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              }
            } else {
              if (filter) {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?catalog_id=$catalogId&sort_by=$sort_By&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              } else {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?catalog_id=$catalogId&sort_by=$sort_By&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              }
            }
          } else {
            String colorString = color_ids.join(',');
            String sizeString = size_ids.join(',');
            String brandString = brand_ids.join(',');
            if (sort_By.isEmpty) {
              if (filter) {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?category_id=$categoryId&gender_type=$gendertype&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              } else {
                var uri = Uri.parse(
                    "${ApiConstants.baseUrl}/products?category_id=$categoryId&gender_type=$gendertype&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list");
                response = await http.get(uri, headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
              }
            } else {
              if (filter) {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?category_id=$categoryId&sort_by=$sort_By&gender_type=$gendertype&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              } else {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?category_id=$categoryId&sort_by=$sort_By&gender_type=$gendertype&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              }
            }
          }
        }
      } else {
        if (brandId != 0) {
          String colorString = color_ids.join(',');
          String sizeString = size_ids.join(',');
          String brandString = brand_ids.join(',');
          if (sort_By.isEmpty) {
            if (filter) {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?category_id=$categoryId&brand_id=$brandId&latitude=${lat.value}&longitude=${lng.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            } else {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?category_id=$categoryId&brand_id=$brandId&latitude=${lat.value}&longitude=${lng.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            }
          } else {
            if (filter) {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?category_id=$categoryId&sort_by=$sort_By&brand_id=$brandId&latitude=${lat.value}&longitude=${lng.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            } else {
              response = await http.get(
                  Uri.parse(
                      "${ApiConstants.baseUrl}/products?category_id=$categoryId&brand_id=$brandId&latitude=${lat.value}&longitude=${lng.value}&sort_by=$sort_By"),
                  headers: <String, String>{
                    'Accept': 'application/json; charset=UTF-8',
                    "Authorization": "Bearer ${prefs.getString('token')} ",
                  });
            }
          }
        } else {
          if (categoryId == 0) {
            String colorString = color_ids.join(',');
            String sizeString = size_ids.join(',');
            String brandString = brand_ids.join(',');
            if (sort_By.isEmpty) {
              if (filter) {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?catalog_id=$catalogId&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              } else {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?catalog_id=$catalogId&latitude=${lat.value}&longitude=${lng.value}"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              }
            } else {
              if (filter) {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?catalog_id=$catalogId&sort_by=$sort_By&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              } else {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?catalog_id=$catalogId&sort_by=$sort_By&latitude=${lat.value}&longitude=${lng.value}"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              }
            }
          } else {
            String colorString = color_ids.join(',');
            String sizeString = size_ids.join(',');
            String brandString = brand_ids.join(',');
            if (sort_By.isEmpty) {
              if (filter) {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?category_id=$categoryId&gender_type=$gendertype&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              } else {
                var uri = Uri.parse(
                    "${ApiConstants.baseUrl}/products?category_id=$categoryId&gender_type=$gendertype&latitude=${lat.value}&longitude=${lng.value}");
                response = await http.get(uri, headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
              }
            } else {
              if (filter) {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?category_id=$categoryId&sort_by=$sort_By&gender_type=$gendertype&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              } else {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?category_id=$categoryId&sort_by=$sort_By&gender_type=$gendertype&latitude=${lat.value}&longitude=${lng.value}"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              }
            }
          }
        }
      }

      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          productCategoryList = responseData["data"];
          total.value = responseData["meta"]["total"];
          categoryProductHasnextpage.value = true;
          categoryProductLoadMore.value = false;
          categoryProductPage.value = 1;
          isCategoryProduct.value = false;
          if (value == "Product Vertical") {
            List<String> nameList = [];
            List<int> idList = [];
            for (var i = 0; i < categoryList.length; i++) {
              nameList.add(categoryList[i]["name"]);
              idList.add(categoryList[i]["id"]);
            }
            size_ids.clear();
            color_ids.clear();
            brand_ids.clear();
            Get.to(ProductListScreen(
              tabTextList: nameList,
              idList: idList,
              genderType: gendertype,
              catalogId: catalogId,
              initailIndex: catalogIndex.value,
            ))?.then((value) {
              id.value = 0;
              update();
            });
          }
          if (filterButton) {
            Get.back();
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
        getSnackBar("get product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isCategoryProduct.value = false;
  }

  fetchCategoryProductMoreData(int brandId, String sort_By, int gendertype,
      bool filter, String type) async {
    if (categoryProductHasnextpage.value == true &&
        isCategoryProduct.value == false &&
        categoryProductLoadMore.value == false) {
      categoryProductLoadMore.value = true;
      categoryProductPage.value += 1;
      print(categoryProductPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        dynamic response;
        if (type == "catalog") {
          if (brandId != 0) {
            String colorString = color_ids.join(',');
            String sizeString = size_ids.join(',');
            String brandString = brand_ids.join(',');
            if (sort_By.isEmpty) {
              if (filter) {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&page=${categoryProductPage.value}&brand_id=$brandId&latitude=${lat.value}&longitude=${lng.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&screen=catalog product list"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              } else {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&page=${categoryProductPage.value}&brand_id=$brandId&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              }
            } else {
              if (filter) {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&page=${categoryProductPage.value}&sort_by=$sort_By&brand_id=$brandId&latitude=${lat.value}&longitude=${lng.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&screen=catalog product list"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              } else {
                response = await http.get(
                    Uri.parse(
                        "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&page=${categoryProductPage.value}&brand_id=$brandId&latitude=${lat.value}&longitude=${lng.value}&sort_by=$sort_By&screen=catalog product list"),
                    headers: <String, String>{
                      'Accept': 'application/json; charset=UTF-8',
                      "Authorization": "Bearer ${prefs.getString('token')} ",
                    });
              }
            }
            /*  response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&brand_id=$brandId&page=${categoryProductPage.value}&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                }); */
          } else {
            if (category_id == 0) {
              String colorString = color_ids.join(',');
              String sizeString = size_ids.join(',');
              String brandString = brand_ids.join(',');
              if (sort_By.isEmpty) {
                if (filter) {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?type=relevant&gender_type=$gendertype&page=${categoryProductPage.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                } else {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?type=relevant&page=${categoryProductPage.value}&gender_type=$gendertype&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                }
              } else {
                if (filter) {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?type=relevant&sort_by=$sort_By&gender_type=$gendertype&page=${categoryProductPage.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                } else {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?type=relevant&page=${categoryProductPage.value}&sort_by=$sort_By&gender_type=$gendertype&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                }
              }
            } else {
              String colorString = color_ids.join(',');
              String sizeString = size_ids.join(',');
              String brandString = brand_ids.join(',');
              if (sort_By.isEmpty) {
                if (filter) {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&gender_type=$gendertype&page=${categoryProductPage.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                } else {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&page=${categoryProductPage.value}&gender_type=$gendertype&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                }
              } else {
                if (filter) {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&sort_by=$sort_By&gender_type=$gendertype&page=${categoryProductPage.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                } else {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&page=${categoryProductPage.value}&sort_by=$sort_By&gender_type=$gendertype&latitude=${lat.value}&longitude=${lng.value}&screen=catalog product list"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                }
              }
            }
          }
        } else {
          if (brandId != 0) {
            response = await http.get(
                Uri.parse(
                    "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&brand_id=$brandId&page=${categoryProductPage.value}&latitude=${lat.value}&longitude=${lng.value}"),
                headers: <String, String>{
                  'Accept': 'application/json; charset=UTF-8',
                  "Authorization": "Bearer ${prefs.getString('token')} ",
                });
          } else {
            if (category_id == 0) {
              String colorString = color_ids.join(',');
              String sizeString = size_ids.join(',');
              String brandString = brand_ids.join(',');
              if (sort_By.isEmpty) {
                if (filter) {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?type=relevant&gender_type=$gendertype&page=${categoryProductPage.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                } else {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?type=relevant&page=${categoryProductPage.value}&gender_type=$gendertype&latitude=${lat.value}&longitude=${lng.value}"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                }
              } else {
                if (filter) {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?type=relevant&sort_by=$sort_By&gender_type=$gendertype&page=${categoryProductPage.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                } else {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?type=relevant&page=${categoryProductPage.value}&sort_by=$sort_By&gender_type=$gendertype&latitude=${lat.value}&longitude=${lng.value}"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                }
              }
            } else {
              String colorString = color_ids.join(',');
              String sizeString = size_ids.join(',');
              String brandString = brand_ids.join(',');
              if (sort_By.isEmpty) {
                if (filter) {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&gender_type=$gendertype&page=${categoryProductPage.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                } else {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&page=${categoryProductPage.value}&gender_type=$gendertype&latitude=${lat.value}&longitude=${lng.value}"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                }
              } else {
                if (filter) {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&sort_by=$sort_By&gender_type=$gendertype&page=${categoryProductPage.value}&color_ids[]=${color_ids.isEmpty ? "" : colorString}&size_ids[]=${size_ids.isEmpty ? "" : sizeString}&brand_ids[]=${brand_ids.isEmpty ? "" : brandString}&price_range[]=${lowPrice.value}&price_range[]=${highPrice.value}&latitude=${lat.value}&longitude=${lng.value}"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                } else {
                  response = await http.get(
                      Uri.parse(
                          "${ApiConstants.baseUrl}/products?category_id=${category_id.value}&page=${categoryProductPage.value}&sort_by=$sort_By&gender_type=$gendertype&latitude=${lat.value}&longitude=${lng.value}"),
                      headers: <String, String>{
                        'Accept': 'application/json; charset=UTF-8',
                        "Authorization": "Bearer ${prefs.getString('token')} ",
                      });
                }
              }
            }
          }
        }

        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              productCategoryList.addAll(responseData['data']);
            } else {
              categoryProductHasnextpage.value = false;
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
          getSnackBar("fetch category product failed");
        }
      } catch (e) {
        print("error$e");
      }
      categoryProductLoadMore.value = false;
    }
  }

  getMostViewProductData() async {
    isMostSearch.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      /*  var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/products?type=most-searched"), */
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/categories?type=most-searched"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          mostSeachList = responseData;
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
        getSnackBar("get most search product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isMostSearch.value = false;
  }

  fetchMostSearchMoreData() async {
    if (mostViewHasnextpage.value == true &&
        isMostSearch.value == false &&
        mostViewLoadMore.value == false) {
      mostViewLoadMore.value = true;
      mostViewPage.value += 1;
      print(mostViewPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?type=most-searched&page=${mostViewPage.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              mostSeachList.addAll(responseData['data']);
            } else {
              mostViewHasnextpage.value = false;
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
          getSnackBar("fetch most search product failed");
        }
      } catch (e) {
        print("error$e");
      }
      mostViewLoadMore.value = false;
    }
  }

  getProductDetails(int productId, String slug) async {
    isDetails.value = true;
    isEstimateDate.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (productId != 0) {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products/$productId?type=relevant&latitude=${lat.value}&longitude=${lng.value}&count=1"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      } else {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products/$slug?type=relevant&latitude=${lat.value}&longitude=${lng.value}&count=1"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      }

      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          productDetails = responseData;
          if (productDetails["estimated_delivery_by"] != null) {
            getItBy = productDetails["estimated_delivery_by"];
            print("move${productDetails["estimated_delivery_by"]}");
          }
          if (responseData["reviews"] != null) {
            totalReview.value = responseData["reviews"].length;
          }
          if (responseData["brand"] != null) {
            brandDetails = responseData["brand"];
          }
          if (responseData["composition"] != null) {
            compositionDetails = responseData["composition"];
          }
          if (responseData["return_policy"] != null) {
            returnPolicyDetails.value = responseData["return_policy"];
          }
          if (responseData["express_delivery"] == true) {
            isExpressDelivery.value = true;
            expressValue.value = 1;
          }
          print(
              'Product Details====>${productDetails["images"]} ${responseData["express_delivery"]}');
          sizeInventoryList = responseData["new_inventories"];
          colorInventoryList.clear();
          if (sizeInventoryList.length == 1) {
            if (sizeInventoryList[0]["product_matrix_size_name"] == "") {
              showSizeList.value = false;
              sizeInventoryId.value = responseData["default_inventory_id"];
              selectedProductSize = sizeInventoryList[0];
              colorInventoryList =
                  sizeInventoryList[0]["product_matrix_available_colors"];
              if (sizeInventoryList[0]["product_matrix_available_colors"]
                      .length ==
                  1) {
                selectedProductColor =
                    sizeInventoryList[0]["product_matrix_available_colors"][0];
                colorInventoryId.value = responseData["default_inventory_id"];
              }
            } else {
              showSizeList.value = true;
              if (sizeInventoryList[0]["product_matrix_available_colors"]
                      .length ==
                  1) {
                showSizeList.value = true;
                sizeInventoryId.value = responseData["default_inventory_id"];
                colorInventoryId.value = responseData["default_inventory_id"];
                selectedProductSize = sizeInventoryList[0];
                colorInventoryList =
                    sizeInventoryList[0]["product_matrix_available_colors"];
                selectedProductColor =
                    sizeInventoryList[0]["product_matrix_available_colors"][0];
              } else {
                showSizeList.value = true;
              }
            }
          } else {
            showSizeList.value = true;
          }
          getProductImage(responseData["default_inventory_id"]);

          //  inventoryList = responseData["inventories"];
          // colorInventoryList = responseData["inventories"]["color"];
          /*  sizeInventoryList = inventoryList
              .where((i) =>
                  i['product_matrix']['product_matrix_group']['name'] == 'Size')
              .toList();

          colorInventoryList = inventoryList
              .where((i) =>
                  i['product_matrix']['product_matrix_group']['name'] ==
                  'Color')
              .toList();

          fabricInventoryList = inventoryList
              .where((i) =>
                  i['product_matrix']['product_matrix_group']['name'] ==
                  'Fabric')
              .toList(); */
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        /*  Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed"); */
        print(response.statusCode);
      } else {
        getSnackBar("get product details failed");
      }
    } catch (e) {
      print("error$e");
    }
    isDetails.value = false;
    isEstimateDate.value = false;
  }

  getEstimateDate(int id, String zip) async {
    isEstimateDate.value = true;
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products/$id/estimated-delivery?zip=$zip"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        getItBy = responseData;
      } else if (response.statusCode == 400) {
        if (responseData["errors"]["zip"].isNotEmpty) {
          getSnackBar("Invalid Pincode");
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
        getSnackBar("get estimate delivery failed");
      }
    } catch (e) {
      print("error$e");
    }
    isEstimateDate.value = false;
    isDetails.value = false;
  }

  getDefaultAddressData(int id, BuildContext cntx) async {
    isAddress.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (id == 0) {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/addresses?latitude=${lat.value}&longitude=${lng.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      } else {
        response = await http.get(
            Uri.parse("${ApiConstants.baseUrl}/addresses"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      }
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          if (responseData.isNotEmpty) {
            addressList = responseData;
            for (var i = 0; i < responseData.length; i++) {
              if (responseData[i]["default_shipping"]) {
                defaultAddress = responseData[i];
                addressText.value =
                    "${responseData[i]["zip"]}, ${responseData[i]["address"]}";
                addressTypeValue.value = responseData[i]["type"];
              }
            }
            if (id == 0 && addressText.value == "") {
              /*  addressText.value =
                  "${responseData[0]["zip"]}, ${responseData[0]["address"]}";
              addressTypeValue.value = responseData[0]["type"]; */
              showModalBottomSheet(
                context: cntx,
                isScrollControlled: true,
                constraints: BoxConstraints(
                  maxWidth: double.infinity,
                  maxHeight: 450.sp,
                ),
                builder: (ctx) {
                  return ChangeAddressScreen(
                    cartId: 0,
                  );
                },
              );
            }
            if (id != 0) {
              getEstimateDate(id, defaultAddress["zip"]);
            }
          }
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        /*  Get.to(
          () => const LoginScreen(
            initialTab: 0,
          ),
        ); */
        // getSnackBar("Authentication failed");
        print(response..statusCode);
      } else {
        getSnackBar("get product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isAddress.value = false;
  }

  getProductReview(int productId) async {
    isReview.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/products/$productId/reviews"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          reviewList = responseData["data"];
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
        getSnackBar("get product review failed");
      }
    } catch (e) {
      print("error$e");
    }
    isReview.value = false;
  }

  getProductImage(int inventoryId) async {
    isColorimage.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products/product-images-based-color?inventory_id=$inventoryId"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          imageList = responseData;
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
        getSnackBar("get product review failed");
      }
    } catch (e) {
      print("error$e");
    }
    isColorimage.value = false;
  }

  getProductRecommendations(int productId) async {
    isRecommendations.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products/$productId/recommendations?except_product_id=$productId&latitude=${lat.value}&longitude=${lng.value}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          recommendedList = responseData["data"];
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
        getSnackBar("get product recommendation failed");
      }
    } catch (e) {
      print("error$e");
    }
    isRecommendations.value = false;
  }

  fetchMoreRecommendedProductData(int productId) async {
    if (recommendedHasnextpage.value == true &&
        isRecommendations.value == false &&
        recommendedLoadMore.value == false) {
      recommendedLoadMore.value = true;
      recommendedPage.value += 1;
      print(recommendedPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products/$productId/recommendations?except_product_id=$productId&page=${recommendedPage.value}&latitude=${lat.value}&longitude=${lng.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              recommendedList.addAll(responseData['data']);
            } else {
              recommendedHasnextpage.value = false;
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
          getSnackBar("fetch recommended product failed");
        }
      } catch (e) {
        print("error$e");
      }
      recommendedLoadMore.value = false;
    }
  }

  getCheckPincode(String pin) async {
    isPincode.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/general/check-pincode?pincode=$pin"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          getSnackBar(responseData["name"]);
        }
      } else if (response.statusCode == 400) {
        if (responseData['errors']['pincode'] != null) {
          getSnackBar(responseData['errors']['pincode'][0]);
        }
      } else if (response.statusCode == 404) {
        getSnackBar(responseData["message"]);
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
        getSnackBar("get pincode failed");
      }
    } catch (e) {
      print("error$e");
    }
    isPincode.value = false;
  }

  callAddtoCart(int quantity, String type) async {
    showLoading();
    isReorder.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "quantity": quantity,
        "inventory_id": sizeInventoryId.value,
        "express_delivery": expressValue.value,
      };
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/orders"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                'Content-Type': 'application/json;charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              },
              body: json.encode(sendData));
      if (response.statusCode == 200) {
        addToCart.value = true;
        if (type == "reorder") {
          Get.to(CartScreen());
          reorderSelected.clear();
          reorderSelected = List.generate(50, (i) => false).obs;
        } /*  else {
          getSnackBar("Product added to cart");
        } */
        if (type == "buy now") {
          Get.to(CartScreen());
        }
      } else if (response.statusCode == 201) {
      } else if (response.statusCode == 400) {
        var responseData = json.decode(response.body);
        errorMsg.value = responseData["message"];
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
    isReorder.value = false;
  }

  callAddProductToWishlist(
      int wishlistId,
      String type,
      int id,
      int categoryId,
      int brandId,
      List list,
      List categoryList,
      int existId,
      int genderType,
      int catalogId) async {
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
        print("abc$type");
        if (responseData["wishlisted"]) {
          Get.close(1);
          // getSnackBar("product added to the wishlist");
        } else {
          //  getSnackBar("product removed from the wishlist");
        }
        if (type == "product") {
          getProductData("relevant");
        } else if (type == "category") {
          /*  getProductByCategoryData(categoryId, brandId, "", [], sortBy.value,
              genderType, filterEnable.value, catalogId, false, "catalog"); */
        } else if (type == "handpicked") {
          /* categoryFilter.value = genderType;
          getHandPickedProduct(
              productSortBy.value, filterProductEnable.value, false); */
        } else if (type == "category product") {
          /*   getProductByCategoryData(categoryId, brandId, "", [], sortBy.value,
              genderType, filterEnable.value, catalogId, false, ""); */
        } else if (type == "tags") {
          getTagsProductData(prefs.getInt('tagId')!, 0, brandId);
          getBestSellerProductData(brandId);
        } else if (type == "brand") {
          /*  getBrandExpressProductData(
              brandId, expressSortBy.value, filterExpressEnable.value); */
        } else if (type == "bannerTag") {
          /*  getTagsBannerData(list, categoryList, genderType, sortBy.value,
              filterEnable.value, false); */
        } else if (type == "frequently") {
          getFrequentlyProductData("frequently-bought", existId);
          getProductRecommendations(existId);
        } else if (type == "seller") {
          getBestSellerProductData(brandId);
          getTagsProductData(prefs.getInt('tagId')!, 0, brandId);
        } else {
          getProductRecommendations(existId);
          getFrequentlyProductData("frequently-bought", existId);
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("item add failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void callReviewVote(int reviewId, int vote, int productId) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/products/$reviewId/vote"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      if (response.statusCode == 200) {
        if (vote == 1) {
          getSnackBar("Thanks for voting");
        }
        getProductReview(productId);
      } else if (response.statusCode == 201) {
        if (vote == 1) {
          getSnackBar("Thanks for voting");
        }
        getProductReview(productId);
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
        print("vote review failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getTagsData(int genderType) async {
    istags.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/tags?gender_type=$genderType"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          tagsList = responseData["data"];
          if (tagsList.isNotEmpty) {
            // tagId.value = tagsList[0]["id"];
            tagProductList.clear();
            expressProductList.clear();
            // getExpressProductData(0, genderType);
            getTagsProductData(0, genderType, 0);
            getHandPickedProduct("", false, false, 0);
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

  fetchMoreTagsData(int genderType) async {
    if (homeTagshasnextpage.value == true &&
        istags.value == false &&
        homeTagsloadMore.value == false) {
      homeTagsloadMore.value = true;
      homeTagsPage.value += 1;
      print(homeTagsPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/tags?page=${homeTagsPage.value}&gender_type=$genderType"),
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
              homeTagshasnextpage.value = false;
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
      homeTagsloadMore.value = false;
    }
  }

  callSaveAddress(
      String screenType,
      int addressId,
      String name,
      String phone,
      String city,
      String type,
      String address,
      String zip,
      String locality,
      String state,
      double lat,
      double lng,
      BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "name": name,
        "phone": phone,
        "city": city,
        "type": type,
        "address": address,
        "zip": zip,
        "locality": locality,
        "state": state,
        "default_shipping": 1,
        "latitude": lat,
        "longitude": lng
      };
      var response = await http.post(
          Uri.parse("${ApiConstants.baseUrl}/addresses/$addressId"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
          body: json.encode(sendData));
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        if (screenType == "change address") {
          getDefaultAddressData(0, context);
          Get.back();
          getBrandExpressProductData(
              brand_id.value, expressSortBy.value, filterExpressEnable.value);
        }
        if (screenType == "express") {
          getBrandExpressProductData(
              brand_id.value, expressSortBy.value, filterExpressEnable.value);
        }
        if (screenType == "") {
          Get.back();
        }
      } else if (response.statusCode == 201) {
        print(responseData);
        if (screenType == "change address") {
          getDefaultAddressData(0, context);
          Get.back();
          getBrandExpressProductData(
              brand_id.value, expressSortBy.value, filterExpressEnable.value);
        }
        if (screenType == "express") {
          getBrandExpressProductData(
              brand_id.value, expressSortBy.value, filterExpressEnable.value);
        }
        if (screenType == "") {
          Get.back();
        }
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        // getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
