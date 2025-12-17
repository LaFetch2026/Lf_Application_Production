import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/constants.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readonly;

  // 🔧 New optional props (all default to old behavior)
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType; // e.g. TextInputType.number
  final int? maxLength; // e.g. 6 for PIN
  final TextCapitalization textCapitalization; // default: words (old behavior)
  final Color? fillColor; // default: white (old behavior)

  const TextFieldWidget({
    Key? key,
    required this.controller,
    required this.hint,
    this.readonly = false,
    this.onChanged,
    this.keyboardType,
    this.maxLength,
    this.textCapitalization = TextCapitalization.words,
    this.fillColor,
  }) : super(key: key);

  InputDecoration _decoration(BuildContext context) => InputDecoration(
        filled: true,
        fillColor: fillColor ?? whiteColor,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: productSubtitleColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1),
          borderSide: const BorderSide(color: productSubtitleColor),
        ),
        counterText: "", // hide counter when maxLength is set
        contentPadding: EdgeInsets.symmetric(horizontal: 10.sp),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: searchTextColor),
      );

  TextStyle _textStyleSmall() => TextStyle(
        color: textColor,
        fontSize: 14.sp,
        fontFamily: "Clash Display Regular",
      );

  TextStyle _textStyleLarge() => TextStyle(
        color: textColor,
        fontFamily: "Clash Display Regular",
      );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;

    final field = TextField(
      controller: controller,
      readOnly: readonly,
      onChanged: onChanged,
      maxLines: null, // keep old behavior
      keyboardType: keyboardType ?? TextInputType.multiline,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      style: isSmall ? _textStyleSmall() : _textStyleLarge(),
      decoration: _decoration(context),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: SizedBox(height: 44.sp, child: field),
    );
  }
}
