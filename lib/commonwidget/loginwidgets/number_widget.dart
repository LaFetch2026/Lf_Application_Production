import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';
import '../theme_helper.dart';

class NumberWidget extends StatelessWidget {
  final TextEditingController controller;

  const NumberWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: ThemeHelper().inputBoxDecorationShaddow(),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 10,
          style: const TextStyle(color: textColor),
          decoration: InputDecoration(
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1),
              borderSide: const BorderSide(color: borderColor),
            ),
            /*   errorText: isValidate
                                                      ? 'Please enter number'
                                                      : null, */
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 50,
                child: Row(
                  children: [
                    AppText(
                      text: "+91",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: greyTextColor,
                      fontSize: 14.sp,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        width: 1,
                        color: textHintColor,
                        height: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            counterText: "",
            hintText: "Mobile Number",
            hintStyle: const TextStyle(
              fontSize: 14,
              color: textHintColor,
              fontFamily: "Franklin Gothic Regular",
            ),
          ),
        ),
      ),
    );
  }
}
