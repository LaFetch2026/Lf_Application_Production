// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalogscreen.dart';
import 'package:lafetch/screens/home/kidsscreen.dart';
import 'package:lafetch/screens/home/menscreen.dart';
import 'package:lafetch/screens/home/womenscreen.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/home_appbar.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
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
              onPressedCatalog: () {
                Get.to(const CatalogScreen());
              },
            ),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              color: colorPrimary,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
            const SizedBox(
              height: 500,
              child: TabBarView(children: [
                WomenScreen(),
                MenScreen(),
                KidsScreen(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
