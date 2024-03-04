// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalog/catalogdetails.dart';
import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';

class WomenCatalogScreen extends StatefulWidget {
  final String categorytext;
  const WomenCatalogScreen({super.key, required this.categorytext});

  @override
  State<WomenCatalogScreen> createState() => WomenCatalogScreenState();
}

class WomenCatalogScreenState extends State<WomenCatalogScreen> {
  List<String> items = [
    "New In",
    "Clothing",
    "Accessories",
    "Footwear",
    "Sales Discount",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: AppText(
                text: "Explore Catalog",
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: appbarText,
                fontSize: 25.sp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
              child: AppText(
                text: "For ${widget.categorytext}",
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: textHintColor,
                fontSize: 14.sp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
              child: ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: items.length,
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (ctx, index) {
                    return Column(
                      children: [
                        GestureDetector(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                width: double.infinity,
                                height: 100,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backImage),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      AppText(
                                        text: items[index],
                                        color: whiteBorderColor,
                                        fontSize: 16.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                      const Expanded(
                                        child: SizedBox(
                                          width: 0,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(const CatalogDetailsScreen(
                                            title: "Clothing",
                                          ));
                                        },
                                        child: Image.asset(rightArrowImage,
                                            height: 20,
                                            width: 20,
                                            fit: BoxFit.cover),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
