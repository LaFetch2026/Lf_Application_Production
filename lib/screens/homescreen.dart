// ignore_for_file: avoid_print

import 'dart:async';

//import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalogscreen.dart';
import 'package:lafetch/screens/home/womenscreen.dart';
import 'package:lafetch/screens/orderdetailsscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../commonwidget/appbarwidgets/home_appbar.dart';
import '../controller/home_controller.dart';
import '../utils/constants.dart';
import 'cartscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final homeController = Get.put(HomeController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  String? city;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.cityList.clear();
      getPrefrenceValue();
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => homeController.getCitiesData());
    /* WidgetsBinding.instance
        .addPostFrameCallback((_) => homeController.getTagsData(3)); */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.getDeviceName();
    });
    initPlatformState();
    super.initState();
  }

  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('city') != null) {
      city = prefs.getString('city')!;
    }
  }

  Future savePrefrenceValue(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('city', value);
  }

  Future<void> initPlatformState() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("ee370d7a-1d35-45bb-8f86-09e43c87c15a");
    OneSignal.Notifications.clearAll();
    OneSignal.User.pushSubscription.addObserver((state) {
      print(OneSignal.User.pushSubscription.optedIn);
      print("player id${OneSignal.User.pushSubscription.id}");
      print("token${OneSignal.User.pushSubscription.token}");
      homeController.playerId.value =
          OneSignal.User.pushSubscription.id.toString();
      homeController.fcmToken.value =
          OneSignal.User.pushSubscription.token.toString();
      if (homeController.playerId.value.isNotEmpty) {
        homeController.callSendDeviceToken();
      }
    });

    OneSignal.Notifications.addPermissionObserver((state) {
      print("Has permission $state");
    });

    OneSignal.Notifications.addClickListener((event) {
      print('NOTIFICATION CLICK LISTENER CALLED WITH EVENT: $event');
      setState(() {
        print("data ${event.notification.additionalData}");
        if (event.notification.additionalData != null) {
          if (event.notification.additionalData?["page"] == "order") {
            Get.to(OrderDetailsScreen(
              orderId: event.notification.additionalData?["id"],
            ));
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAppbar(
              onPressedSearch: () async {
                Get.to(const SearchScreen());
                await analytics.logEvent(
                  name: 'search_page',
                  parameters: <String, Object>{
                    'page_name': 'search_page',
                  },
                );
              },
              onPressedCatalog: () async {
                Get.to(const CatalogScreen());
                await analytics.logEvent(
                  name: 'catalog_page',
                  parameters: <String, Object>{
                    'page_name': 'catalog_page',
                  },
                );
              },
              onPressedCart: () async {
                Get.to(const CartScreen());
                await analytics.logEvent(
                  name: 'cart_page',
                  parameters: <String, Object>{
                    'page_name': 'cart_page',
                  },
                );
              },
            ),
            /*    Container(
                height: 55.sp,
                width: MediaQuery.of(context).size.width,
                color: colorPrimary,
                child: Obx(
                  () => homeController.isCity.value
                      ? Padding(
                          padding: EdgeInsets.all(40.0.sp),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                              left: 16.sp,
                              right: 16.sp,
                              top: 5.sp,
                              bottom: 10.sp),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              /*  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: ImageIcon(
                        AssetImage(locationIcon),
                        color: colorSecondary,
                        size: 20,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: AppText(
                        text: "Select Your Location",
                        fontFamily: "Franklin Gothic Regular",
                        maxLines: 2,
                        fontWeight: FontWeight.w500,
                        color: colorSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    const ImageIcon(
                      AssetImage(whiteDropDown),
                      color: colorSecondary,
                      size: 24,
                    ), */
                              SizedBox(
                                height: 40.sp,
                                width: 180.sp,
                                child: DropdownButtonFormField2(
                                  value: city,
                                  decoration: InputDecoration(
                                    filled: true,
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: colorPrimary)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1),
                                      borderSide:
                                          const BorderSide(color: colorPrimary),
                                    ),
                                    isDense: true,
                                    prefixIconConstraints: BoxConstraints(
                                        minWidth: 20.sp, maxHeight: 20.sp),
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.only(right: 6.sp),
                                      child: ImageIcon(
                                        AssetImage(locationIcon),
                                        color: colorSecondary,
                                        size: 20.sp,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    hintText: 'Select Your Location',
                                    hintStyle: TextStyle(
                                        fontSize: 12.sp,
                                        color: colorSecondary,
                                        fontFamily: "Franklin Gothic Regular"),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  isExpanded: true,
                                  items: homeController.cityList
                                      .map((item) => DropdownMenuItem<String>(
                                            value: item["name"],
                                            child: Text(
                                              item["name"],
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: colorSecondary,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select Types.';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    city = value;
                                    savePrefrenceValue(city!);
                                  },
                                  onSaved: (value) async {
                                    await analytics.logEvent(
                                      name: 'location_home_page',
                                      parameters: <String, Object>{
                                        'page_name': 'location_home_page',
                                      },
                                    );
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: 60.sp,
                                    padding: EdgeInsets.only(right: 10.sp),
                                  ),
                                  iconStyleData: IconStyleData(
                                    icon: ImageIcon(
                                      AssetImage(whiteDropDown),
                                      color: colorSecondary,
                                      size: 8.sp,
                                    ),
                                    iconSize: 16,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200.sp,
                                    decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(4.sp),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                )),
            */
            Stack(
              children: [
                PreferredSize(
                  preferredSize: const Size.fromHeight(40),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TabBar(
                        isScrollable: false,
                        indicatorColor: btnTextColor,
                        unselectedLabelColor: textHintColor,
                        labelColor: btnTextColor,
                        onTap: (value) async {
                          String type;
                          if (value == 0) {
                            type = "Women";
                            //  homeController.getTagsData(3);
                          } else if (value == 1) {
                            type = "Men";
                            //  homeController.getTagsData(2);
                          } else {
                            type = "Kids";
                            //  homeController.getTagsData(1);
                          }
                          await analytics.logEvent(
                            name: '$type home_page',
                            parameters: <String, Object>{
                              'page_name': '$type home_page',
                            },
                          );
                        },
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 3,
                        tabs: [
                          Tab(
                              child: Text(
                            "Women",
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w400),
                          )),
                          Tab(
                              child: Text(
                            "Men",
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w400),
                          )),
                          Tab(
                              child: Text(
                            "Kids",
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w400),
                          ))
                        ]),
                  ),
                ),
/*                 Container(
                  height: 150,
                  width: 200,
                  margin: const EdgeInsets.only(left: 16),
                  color: Colors.amber,
                ), */
              ],
            ),
            Container(
              width: double.infinity,
              color: lightText,
              height: 1.sp,
            ),
            const Expanded(
              child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    WomenScreen(
                      genderType: 3,
                    ),
                    WomenScreen(
                      genderType: 2,
                    ),
                    WomenScreen(
                      genderType: 1,
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
