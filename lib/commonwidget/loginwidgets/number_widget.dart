import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class NumberWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool readonly;

  const NumberWidget({
    Key? key,
    required this.controller,
    required this.readonly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
      child: SizedBox(
        height: 44.sp,
        width: double.infinity,
        child: TextField(
          controller: controller,
          readOnly: readonly,
          keyboardType: TextInputType.number,
          maxLength: 10,
          style: const TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            isDense: true,
            fillColor: whiteTextColor,
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.sp),
              borderSide: const BorderSide(color: borderColor),
            ),
            /*   errorText: isValidate
                                                      ? 'Please enter number'
                                                      : null, */
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 8.sp),
              child: SizedBox(
                width: 50.sp,
                child: Row(
                  children: [
                    AppText(
                      text: "+91",
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w500,
                      color: greyTextColor,
                      fontSize: 14,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.sp),
                      child: Container(
                        width: 1.sp,
                        color: textHintColor,
                        height: 20.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            counterText: "",
            //  contentPadding: EdgeInsets.zero,
            hintText: "Mobile Number",
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: textHintColor,
              fontFamily: "Franklin Gothic Regular",
            ),
          ),
        ),
      ),
    );
  }
}
