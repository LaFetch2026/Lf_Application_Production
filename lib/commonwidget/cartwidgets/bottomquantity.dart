// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../app_text.dart';
import '../common_widgets.dart';

class BottomQuantity extends StatefulWidget {
  final Function(int)? onPressed;
  final List qtyList;
  final int stock;
  final String selectedQty;
  final GetxController controller;

  const BottomQuantity({
    Key? key,
    this.onPressed,
    required this.qtyList,
    required this.selectedQty,
    required this.stock,
    required this.controller,
  }) : super(key: key);

  @override
  State<BottomQuantity> createState() => _BottomQuantityState();
}

class _BottomQuantityState extends State<BottomQuantity> {
  String text = "0";
  @override
  void initState() {
    text = widget.selectedQty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: whiteTextColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Select Quantity",
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
                      Get.back();
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 50,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: text == widget.qtyList[index]
                                        ? btnTextColor
                                        : whiteColor,
                                    border: Border.all(
                                      width: 1,
                                      color: btnTextColor,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                width: 35,
                                height: 35,
                                child: Center(
                                  child: AppText(
                                    textAlign: TextAlign.center,
                                    text: widget.qtyList[index],
                                    color: text == widget.qtyList[index]
                                        ? whiteColor
                                        : btnTextColor,
                                    fontSize: 12.sp,
                                    fontFamily: "Franklin Gothic Regular",
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
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
          ],
        ),
      ),
    );
  }
}
