// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../app_text.dart';
import '../common_widgets.dart';

class BottomSize extends StatefulWidget {
  final Function(int)? onPressed;
  final Function onPressedCross;
  final List sizeList;
  final int selectedSizeId;
  final GetxController controller;

  const BottomSize({
    Key? key,
    this.onPressed,
    required this.sizeList,
    required this.selectedSizeId,
    required this.controller,
    required this.onPressedCross,
  }) : super(key: key);

  @override
  State<BottomSize> createState() => _BottomQuantityState();
}

class _BottomQuantityState extends State<BottomSize> {
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
        height: 220,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: whiteTextColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Select Size",
                      style: TextStyle(
                        color: loginText,
                        fontSize: 14.sp,
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onPressedCross.call();
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Image.asset(blackCrossImage,
                          height: 18, width: 18, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: widget.sizeList
                      .where((element) =>
                          int.parse(element['stocks'].toString()) > 0)
                      .toList()
                      .isNotEmpty
                  ? Wrap(
                      direction: Axis.horizontal,
                      spacing: 12.0,
                      runSpacing: 8.0,
                      runAlignment: WrapAlignment.spaceEvenly,
                      children: [
                          for (var i in widget.sizeList.where((element) =>
                              int.parse(element['stocks'].toString()) > 0))
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
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
                                        width: 40,
                                        height: 40,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: AppText(
                                            text: i['product_matrix_size_name']
                                                .toString(),
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                            color: selectedProductSize
                                                        .isNotEmpty &&
                                                    selectedProductSize['id'] ==
                                                        i['id']
                                                ? whiteColor
                                                : btnTextColor,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      )),
                                ),
                                int.parse(i['stocks'].toString()) > 10
                                    ? const SizedBox()
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: AppText(
                                          text:
                                              '${i['stocks'].toString()} left',
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: redColor,
                                          fontSize: 11.sp,
                                        ),
                                      )
                              ],
                            ),
                        ])
                  : AppText(
                      text: 'N/A',
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: redColor,
                      fontSize: 11.sp,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
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
          ],
        ));
  }
}
