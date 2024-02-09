// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../commonwidget/app_text.dart';
import '../utils/constants.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => CatalogScreenState();
}

class CatalogScreenState extends State<CatalogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              color: whiteBorderColor,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 40, right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(backArrowImage,
                          height: 20, width: 20, fit: BoxFit.cover),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: AppText(
                          text: "Catalog",
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                          color: appbarText,
                          fontSize: 16.sp,
                        ),
                      ),
                      const Expanded(
                        child: SizedBox(
                          height: 0,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: ImageIcon(
                          AssetImage(searchImage),
                          color: textHintColor,
                          size: 20,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: ImageIcon(
                          AssetImage(cartImage),
                          color: textHintColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 70, left: 16, right: 16),
              child: AppText(
                text: "Catalog",
                fontFamily: "Franklin Gothic",
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
