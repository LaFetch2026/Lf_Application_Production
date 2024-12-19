import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/brandwidgits/dummy_brand_list.dart';
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
    homeController.selected.clear();
    homeController.selected = List.generate(50, (i) => false);
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
                        ? const DummybrandList(
                            size: 2,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              homeController.FaqsList.isNotEmpty
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          left: 16.sp,
                                          right: 16.sp,
                                          bottom: 10.sp,
                                          top: 10.sp),
                                      child: GetBuilder<HomeController>(
                                        builder: (value) => ListView.builder(
                                            primary: false,
                                            shrinkWrap: true,
                                            physics: const ScrollPhysics(),
                                            itemCount: value.FaqsList.length,
                                            padding: EdgeInsets.zero,
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (ctx, index) {
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10.sp),
                                                    child: Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(1),
                                                          border: Border.all(
                                                              width: 1,
                                                              color: value.selected[
                                                                      index]
                                                                  ? greyTextColor
                                                                  : whiteBorderColor),
                                                          color:
                                                              whiteBorderColor),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10.sp,
                                                                    vertical:
                                                                        10.sp),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10.sp),
                                                                    child:
                                                                        AppText(
                                                                      text: value.FaqsList[index]
                                                                              [
                                                                              "question"] ??
                                                                          "",
                                                                      color:
                                                                          colorPrimary,
                                                                      maxLines:
                                                                          8,
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          "Franklin Gothic Regular",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    value.selected[
                                                                        index] = !value
                                                                            .selected[
                                                                        index];
                                                                    value
                                                                        .update();
                                                                  },
                                                                  child: Image.asset(
                                                                      value.selected[
                                                                              index]
                                                                          ? upArrowIcon
                                                                          : downArrowImage,
                                                                      height:
                                                                          20.sp,
                                                                      width:
                                                                          20.sp,
                                                                      fit: BoxFit
                                                                          .cover),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          value.selected[index]
                                                              ? Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.sp,
                                                                      horizontal:
                                                                          16.sp),
                                                                  child:
                                                                      AppText(
                                                                    text: value.FaqsList[
                                                                            index]
                                                                        [
                                                                        "answer"],
                                                                    fontFamily:
                                                                        "Franklin Gothic Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color:
                                                                        textHintColor,
                                                                    maxLines:
                                                                        20,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                )
                                                              : const SizedBox(
                                                                  height: 0,
                                                                )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                      ),
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
