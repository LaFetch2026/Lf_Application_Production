import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/constants.dart';
import 'app_text.dart';



class NumberWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool readonly;
  final bool login;
  final Color fillColor;
  final Function onPressedLogin;

  const NumberWidget({
    Key? key,
    required this.controller,
    required this.readonly,
    this.fillColor = whiteTextColor,
    required this.login,
    required this.onPressedLogin,
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
          onChanged: (value) {
            if (value.length == 10 && login == true) {
              onPressedLogin.call();
            }
          },
          style: const TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            isDense: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0.sp),
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.sp),
                borderSide: BorderSide(color: productSubtitleColor)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0.sp),
              borderSide: const BorderSide(color: productSubtitleColor),
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
                      color: subtitleColor,
                      fontSize: 14,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.sp),
                      child: Container(
                        width: 1.sp,
                        color: subtitleColor,
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
              color: searchTextColor,
              fontFamily: "Franklin Gothic Regular",
            ),
          ),
        ),
      ),
    );
  }
}
