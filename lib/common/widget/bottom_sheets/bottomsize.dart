// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/base_controller.dart';
import '../../../core/constant/constants.dart';

import '../other/common_widget.dart';
import '../text/app_text.dart';

class BottomSize extends StatefulWidget {
  final Function(int)? onPressed;
  final VoidCallback onPressedCross;
  final List<Map<String, dynamic>> sizeList;
  final int selectedSizeId;
  final BaseController controller;

  const BottomSize({
    Key? key,
    this.onPressed,
    required this.sizeList,
    required this.selectedSizeId,
    required this.controller,
    required this.onPressedCross,
  }) : super(key: key);

  @override
  State<BottomSize> createState() => BottomSizeState();
}

class BottomSizeState extends State<BottomSize> {
  Map<String, dynamic> selectedProductSize = {};
  int inventoryId = 0;
  @override
  void initState() {
    selectedProductSize["id"] = widget.selectedSizeId;
    inventoryId = widget.selectedSizeId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.sizeList.length > 6 ? 300.sp : 230.sp,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: whiteTextColor,
          /*   borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0.sp),
              topRight: Radius.circular(16.0.sp)), */
        ),
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
                      "Select Size",
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
                      HapticFeedback.lightImpact();
                      widget.onPressedCross.call();
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 10.sp,
                            right: 16.sp,
                            top: 20.sp,
                            bottom: 20.sp),
                        child: SvgPicture.asset(crossSearchImage,
                            // ignore: deprecated_member_use
                            color: loginText,
                            height: 13.sp,
                            width: 13.sp,
                            fit: BoxFit.fill),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
              child: widget.sizeList
                      .where((element) =>
                          int.parse((element['inventories']?[0]
                                      ?['availableStock'] ??
                                  element['availableStock'] ??
                                  element['stock'])
                              .toString()) >
                          0)
                      .toList()
                      .isNotEmpty
                  ? Wrap(
                      direction: Axis.horizontal,
                      spacing: 12.0.sp,
                      runSpacing: 8.0.sp,
                      runAlignment: WrapAlignment.spaceEvenly,
                      children: [
                          for (var i in widget.sizeList.where((element) =>
                              int.parse((element['availableStock'] ??
                                      element['stock'])
                                  .toString()) >
                              0))
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    selectedProductSize = i;
                                    inventoryId = selectedProductSize["id"];
                                    print(inventoryId);
                                    setState(() {});
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: btnTextColor, width: 1),
                                          color: selectedProductSize
                                                      .isNotEmpty &&
                                                  selectedProductSize['id'] ==
                                                      i['id']
                                              ? colorPrimary
                                              : whiteColor),
                                      child: SizedBox(
                                        width: i['product_matrix_size_name']
                                                    .toString() ==
                                                "Free Size"
                                            ? 80.sp
                                            : 40.sp,
                                        height: 40.sp,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: AppText(
                                            text: i['product_matrix_size_name']
                                                .toString(),
                                            fontFamily: "Clash Display Regular",
                                            fontWeight: FontWeight.w400,
                                            color: selectedProductSize
                                                        .isNotEmpty &&
                                                    selectedProductSize['id'] ==
                                                        i['id']
                                                ? whiteColor
                                                : btnTextColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )),
                                ),
                                int.parse((i['inventories']?[0]
                                                    ?['availableStock'] ??
                                                i['availableStock'] ??
                                                i['stock'])
                                            .toString()) >
                                        1
                                    ? const SizedBox()
                                    : Padding(
                                        padding: EdgeInsets.only(top: 8.0.sp),
                                        child: AppText(
                                          text:
                                              '${(i['inventories']?[0]?['availableStock'] ?? i['availableStock'] ?? i['stock']).toString()} left',
                                          fontFamily: "Clash Display Regular",
                                          fontWeight: FontWeight.w400,
                                          color: lightPurpleColor,
                                          fontSize: 11,
                                        ),
                                      )
                              ],
                            ),
                        ])
                  : const AppText(
                      text: 'N/A',
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w400,
                      color: lightPurpleColor,
                      fontSize: 11,
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
                      widget.onPressed?.call(inventoryId);
                    },
                    borderColor: colorPrimary),
              ),
            )
          ],
        ));
  }
}
