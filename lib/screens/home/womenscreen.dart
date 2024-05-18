import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/home_controller.dart';
import 'package:lafetch/screens/home/women/discountscreen.dart';

import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';

class WomenScreen extends StatefulWidget {
  const WomenScreen({super.key});

  @override
  State<WomenScreen> createState() => _WomenScreenState();
}

class _WomenScreenState extends State<WomenScreen> {
  final homeController = Get.put(HomeController());
  int current = 0;
  PageController pageController = PageController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.listController.addListener(() {
        homeController.fetchMoreTagsData();
        homeController.update();
      });
    });
    homeController.hasnextpage.value = true;
    homeController.loadMore.value = false;
    homeController.istags.value = false;
    homeController.page.value = 1;
    homeController.update();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => homeController.getTagsData());
    super.initState();
  }

  callOnchanged(int index) {
    setState(() {
      current = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: whiteTextColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Obx(
            () => homeController.istags.value
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: homeController.tagsList.length,
                          scrollDirection: Axis.horizontal,
                          controller: homeController.listController,
                          itemBuilder: (ctx, index) {
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      current = index;
                                      homeController.tagId.value =
                                          homeController.tagsList[index]["id"];
                                    });
                                    pageController.animateToPage(
                                      current,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.ease,
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.only(right: 5),
                                    width: 100,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: current == index
                                          ? btnTextColor
                                          : whiteTextColor,
                                      borderRadius: current == index
                                          ? BorderRadius.circular(20)
                                          : BorderRadius.circular(20),
                                      border: current == index
                                          ? Border.all(
                                              color: btnTextColor, width: 1)
                                          : Border.all(
                                              color: textHintColor, width: 1),
                                    ),
                                    child: Center(
                                      child: AppText(
                                        text: homeController.tagsList[index]
                                            ["name"],
                                        color: current == index
                                            ? whiteBorderColor
                                            : textHintColor,
                                        fontSize: 12.sp,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ),
          ),
          Obx(
            () => homeController.istags.value
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Expanded(
                    child: PageView.builder(
                      // itemCount: homeController.tagsList.length,
                      controller: pageController,
                      onPageChanged: callOnchanged,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return DiscountScreen(
                          tagId: homeController.tagId.value,
                        );
                      },
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
