// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/home_appbar.dart';
import '../utils/constants.dart';
import 'catalogscreen.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => BrandsScreenState();
}

class BrandsScreenState extends State<BrandsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAppbar(
              onPressedCatalog: () {
                Get.to(const CatalogScreen());
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 70, left: 16, right: 16),
              child: AppText(
                text: "Brands",
                fontFamily: "Franklin Gothic",
                maxLines: 2,
                fontWeight: FontWeight.w500,
                color: blackColor,
                fontSize: 28.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
