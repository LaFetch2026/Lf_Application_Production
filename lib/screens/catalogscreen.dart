// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/appbarwidgets/catalog_appbar.dart';
import 'package:lafetch/screens/catalog/women_catalog.dart';
import '../utils/constants.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => CatalogScreenState();
}

class CatalogScreenState extends State<CatalogScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: whiteTextColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CatalogAppbar(
                text: "Catalog",
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
                height: 600,
                child: TabBarView(children: [
                  WomenCatalogScreen(),
                  WomenCatalogScreen(),
                  WomenCatalogScreen(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
