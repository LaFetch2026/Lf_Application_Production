// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomsortby.dart';
import 'package:lafetch/screens/catalog/productlist/producthorizontal.dart';
import 'package:lafetch/screens/catalog/productlist/productvertical.dart';
import '../../../commonwidget/app_text.dart';
import '../../../commonwidget/doublebtn.dart';
import '../../../utils/constants.dart';

class ViewProductScreen extends StatefulWidget {
  const ViewProductScreen({super.key});

  @override
  State<ViewProductScreen> createState() => ViewProductScreenState();
}

class ViewProductScreenState extends State<ViewProductScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: whiteBorderColor,
        body: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 16),
                        child: AppText(
                          text: "Tops, T-shirts & Shirts",
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                          color: blackColor,
                          fontSize: 22.sp,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              AppText(
                                text: "30 items",
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: textHintColor,
                                fontSize: 12.sp,
                              ),
                              const Expanded(
                                child: SizedBox(
                                  width: 0,
                                ),
                              ),
                              const SizedBox(
                                width: 100,
                                child: PreferredSize(
                                  preferredSize: Size.fromHeight(40),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: TabBar(
                                        isScrollable: false,
                                        indicatorColor: btnTextColor,
                                        unselectedLabelColor: textHintColor,
                                        labelColor: btnTextColor,
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        indicatorWeight: 2,
                                        tabs: [
                                          Tab(
                                            child: ImageIcon(
                                              AssetImage(outlineImage),
                                              size: 14,
                                            ),
                                          ),
                                          Tab(
                                            child: ImageIcon(
                                              AssetImage(menuImage),
                                              size: 14,
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 500,
                        child: TabBarView(children: [
                          ProductVerticalScreen(),
                          ProductHorizontalScreen(),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
              DoubleButton(
                firstText: "Sort By",
                secondText: "Filters",
                firstTextColor: deepGreytextColor,
                secondTextColor: deepGreytextColor,
                firstBackgroundColor: whiteBorderColor,
                secondBackgroundColor: whiteBorderColor,
                firstBorderColor: deepGreytextColor,
                secondBorderColor: deepGreytextColor,
                onPressedFirst: () {
                  scaffoldKey.currentState
                      ?.showBottomSheet((context) => const BottomSortBy());
                },
                onPressedSecond: () {
                  /*  Get.to(
                                  () => const LoginScreen(),
                                ); */
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
