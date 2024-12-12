import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_faqs.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../controller/home_controller.dart';
import '../../utils/constants.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({
    super.key,
  });

  @override
  State<FAQScreen> createState() => FAQScreenState();
}

class FAQScreenState extends State<FAQScreen> {
  final homeController = Get.put(HomeController());

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => homeController.getFaqData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          const BackButtonAppbar(
            text: "FAQs",
            threeDot: false,
            backgroundColor: whiteColor,
            icon: threeDotImage,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => homeController.isFaqs.value
                        ? const DummyFaqs()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              homeController.FaqsList.isNotEmpty
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 10.sp, top: 16.sp),
                                      child: ListView.builder(
                                          primary: false,
                                          shrinkWrap: true,
                                          physics: const ScrollPhysics(),
                                          itemCount:
                                              homeController.FaqsList.length,
                                          padding: EdgeInsets.zero,
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (ctx, index) {
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.sp,
                                                  vertical: 5.sp),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  AppText(
                                                    text: homeController
                                                            .FaqsList[index]
                                                        ["question"],
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w500,
                                                    color: loginText,
                                                    maxLines: 6,
                                                    fontSize: 14,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.sp),
                                                    child: AppText(
                                                      text: homeController
                                                              .FaqsList[index]
                                                          ["answer"],
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: textHintColor,
                                                      maxLines: 20,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                    )
                                  : SizedBox(
                                      height: 50.sp,
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                            "No Question & Answer Found",
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.black,
                                                fontFamily:
                                                    "Franklin Gothic Regular")),
                                      ),
                                    )
                            ],
                          ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
