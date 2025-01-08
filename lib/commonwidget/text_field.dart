import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/constants.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readonly;

  const TextFieldWidget({
    Key? key,
    required this.controller,
    required this.hint,
    this.readonly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 600
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child: SizedBox(
              height: 44.sp,
              child: TextField(
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.sp,
                  fontFamily: "Franklin Gothic Regular",
                ),
                controller: controller,
                readOnly: readonly,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: whiteColor,
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  counterText: "",
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.sp),
                  hintText: hint,
                  hintStyle: TextStyle(fontSize: 14.sp, color: subtitleColor),
                ),
              ),
            ),
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child: SizedBox(
              height: 44.sp,
              child: TextField(
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  color: textColor,
                  fontFamily: "Franklin Gothic Regular",
                ),
                controller: controller,
                readOnly: readonly,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: whiteColor,
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  counterText: "",
                  hintText: hint,
                  hintStyle: TextStyle(fontSize: 14.sp, color: subtitleColor),
                ),
              ),
            ),
          );
  }
}
