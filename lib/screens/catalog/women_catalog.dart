// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/catalog_controller.dart';
import 'package:lafetch/screens/catalog/catalogdetails.dart';
import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';

class WomenCatalogScreen extends StatefulWidget {
  final String categorytext;
  final int type;
  const WomenCatalogScreen(
      {super.key, required this.categorytext, required this.type});

  @override
  State<WomenCatalogScreen> createState() => WomenCatalogScreenState();
}

class WomenCatalogScreenState extends State<WomenCatalogScreen> {
  final controller = Get.put(CatalogController());

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getCatalogData(widget.type));
    super.initState();
  }

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
            Obx(() => controller.isCatalog.value
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : controller.catalogList.isNotEmpty
                    ? Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 10),
                        child: ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: controller.catalogList.length,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (ctx, index) {
                              return Column(
                                children: [
                                  GestureDetector(
                                      onTap: () {},
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                AppText(
                                                  text: controller.catalogList[
                                                          index]["name"] ??
                                                      "",
                                                  color: whiteBorderColor,
                                                  fontSize: 16.sp,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                const Expanded(
                                                  child: SizedBox(
                                                    width: 0,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Get.to(
                                                        const CatalogDetailsScreen(
                                                      title: "Clothing",
                                                    ));
                                                  },
                                                  child: Image.asset(
                                                      rightArrowImage,
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
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: const Center(
                          child: Text("No Catolog Found",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontFamily: "Franklin Gothic Regular")),
                        ),
                      ))
          ],
        ),
      ),
    );
  }
}
