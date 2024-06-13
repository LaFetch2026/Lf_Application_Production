import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/home_controller.dart';
import 'package:lafetch/screens/home/women/discountscreen.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/homewidget/dummy_product_list.dart';
import '../../utils/constants.dart';

class WomenScreen extends StatelessWidget {
  const WomenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    PageController pageController = PageController();

    callOnchanged(int index) {
      homeController.current.value = index;
      homeController.update();
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      color: whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Obx(
            () => homeController.istags.value
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 16, bottom: 10, right: 16),
                    child: SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: 5,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 100,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }),
                    ))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: GetBuilder<HomeController>(
                          builder: (value) => ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: homeController.tagsList.length,
                              scrollDirection: Axis.horizontal,
                              controller: homeController.tagsController,
                              itemBuilder: (ctx, index) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        homeController.current.value = index;
                                        homeController.tagId.value =
                                            homeController.tagsList[index]
                                                ["id"];
                                        pageController.animateToPage(
                                          homeController.current.value,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          curve: Curves.ease,
                                        );
                                        homeController.update();
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.only(right: 5),
                                        width: 100,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: homeController.current.value ==
                                                  index
                                              ? btnTextColor
                                              : whiteColor,
                                          borderRadius:
                                              homeController.current.value ==
                                                      index
                                                  ? BorderRadius.circular(20)
                                                  : BorderRadius.circular(20),
                                          border:
                                              homeController.current.value ==
                                                      index
                                                  ? Border.all(
                                                      color: btnTextColor,
                                                      width: 1)
                                                  : Border.all(
                                                      color: textHintColor,
                                                      width: 1),
                                        ),
                                        child: Center(
                                          child: AppText(
                                            text: homeController.tagsList[index]
                                                ["name"],
                                            color:
                                                homeController.current.value ==
                                                        index
                                                    ? whiteColor
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
                        )),
                  ),
          ),
          Obx(
            () => homeController.istags.value
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, bottom: 10, right: 16),
                              child: SizedBox(
                                height: 210,
                                width: double.infinity,
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: 5,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (ctx, index) {
                                      return Container(
                                        height: 210,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.04),
                                        ),
                                      );
                                    }),
                              )),
                          const DummyProductList(
                              text: "6 hour Express Delivery")
                        ],
                      ),
                    ),
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
