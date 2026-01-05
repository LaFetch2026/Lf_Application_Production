// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/base_controller.dart';
import '../../../core/constant/constants.dart';

import '../other/common_widget.dart';
import '../text/app_text.dart';

class BottomQuantity extends StatefulWidget {
  final Function(int)? onPressed;
  final List<String> qtyList;
  final int stock;
  final String selectedQty;
  final BaseController controller;

  const BottomQuantity({
    Key? key,
    this.onPressed,
    required this.qtyList,
    required this.selectedQty,
    required this.stock,
    required this.controller,
  }) : super(key: key);

  @override
  State<BottomQuantity> createState() => BottomQuantityState();
}

class BottomQuantityState extends State<BottomQuantity> {
  String text = "0";
  @override
  void initState() {
    text = widget.selectedQty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230.sp,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: whiteTextColor,
        /*   borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0.sp),
            topRight: Radius.circular(16.0.sp)), */
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.sp),
              child: Center(
                child: Image.asset(
                  handleImage,
                  height: 7.sp,
                  width: 80.sp,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.sp),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Select Quantity",
                      style: TextStyle(
                        color: loginText,
                        fontSize: 14.sp,
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.sp, vertical: 10.sp),
                        child: SvgPicture.asset(crossSearchImage,
                            // ignore: deprecated_member_use
                            color: loginText,
                            height: 13.sp,
                            width: 13.sp,
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
              child: SizedBox(
                width: double.infinity,
                height: 50.sp,
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.stock,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              text = widget.qtyList[index];
                              print(text);
                              setState(() {});
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.sp),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: text == widget.qtyList[index]
                                        ? btnTextColor
                                        : whiteColor,
                                    border: Border.all(
                                      width: 1,
                                      color: btnTextColor,
                                    ),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.sp))),
                                width: 35.sp,
                                height: 35.sp,
                                child: Center(
                                  child: AppText(
                                    textAlign: TextAlign.center,
                                    text: widget.qtyList[index],
                                    color: text == widget.qtyList[index]
                                        ? whiteColor
                                        : btnTextColor,
                                    fontSize: 12,
                                    fontFamily: "Clash Display Regular",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ),
            Obx(
              () => Padding(
                padding: EdgeInsets.symmetric(vertical: 10.sp),
                child: getSingleButton(
                    label: "Done",
                    textColor: whiteBorderColor,
                    backgroundColor: colorPrimary,
                    controller: widget.controller,
                    onPressed: () {
                      widget.onPressed?.call(int.parse(text));
                    },
                    borderColor: colorPrimary),
              ),
            )
          ],
        ),
      ),
    );
  }
}
