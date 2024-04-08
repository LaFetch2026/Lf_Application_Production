// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../app_text.dart';
import '../common_widgets.dart';

class BottomSize extends StatefulWidget {
  final Function? onPressed;
  final List sizeList;
  final String selectedSize;

  const BottomSize({
    Key? key,
    this.onPressed,
    required this.sizeList,
    required this.selectedSize,
  }) : super(key: key);

  @override
  State<BottomSize> createState() => _BottomQuantityState();
}

class _BottomQuantityState extends State<BottomSize> {
  String size = "0";
  @override
  void initState() {
    size = widget.selectedSize;
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
                      Get.back();
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Image.asset(blackCrossImage,
                          height: 12, width: 12, fit: BoxFit.cover),
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
                    itemCount: widget.sizeList.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              size = widget.sizeList[index];
                              print(size);
                              setState(() {});
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: size == widget.sizeList[index]
                                      ? btnTextColor
                                      : whiteColor,
                                  border: Border.all(
                                    width: 1,
                                    color: size == widget.sizeList[index]
                                        ? whiteColor
                                        : btnTextColor,
                                  ),
                                ),
                                width: 48,
                                height: 48,
                                child: Center(
                                  child: AppText(
                                    textAlign: TextAlign.center,
                                    text: widget.sizeList[index],
                                    color: size == widget.sizeList[index]
                                        ? whiteColor
                                        : btnTextColor,
                                    fontSize: 10.sp,
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
                  //   controller: profileController,
                  onPressed: () {},
                  borderColor: colorPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
