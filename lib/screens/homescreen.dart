// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalogscreen.dart';
import 'package:lafetch/screens/home/womenscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../commonwidget/app_text.dart';
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
  @override
  void initState() {
    homeController.getDeviceName();
    initPlatformState();
    super.initState();
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

    /*  OneSignal.Notifications.addPermissionObserver((state) {
      print("Has permission $state");
    });

    OneSignal.Notifications.addClickListener((event) {
      print('NOTIFICATION CLICK LISTENER CALLED WITH EVENT: $event');
      setState(() {
        print("data ${event.notification.additionalData}");
        if (event.notification.additionalData != null) {
          print(event.notification.additionalData?["page"]);
        }
      });
    }); */
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: whiteTextColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAppbar(
              onPressedSearch: () {
                Get.to(const SearchScreen());
              },
              onPressedCatalog: () {
                Get.to(const CatalogScreen());
              },
              onPressedCart: () {
                Get.to(const CartScreen());
              },
            ),
            Container(
              height: 55,
              width: MediaQuery.of(context).size.width,
              color: colorPrimary,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
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
                      ),
                    ],
                  ),
                )
              ]),
            ),
            PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Align(
                alignment: Alignment.topCenter,
                child: TabBar(
                    isScrollable: false,
                    indicatorColor: btnTextColor,
                    unselectedLabelColor: textHintColor,
                    labelColor: btnTextColor,
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
            Container(
              width: double.infinity,
              color: lightText,
              height: 1,
            ),
            const Expanded(
              child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    WomenScreen(),
                    WomenScreen(),
                    WomenScreen(),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
