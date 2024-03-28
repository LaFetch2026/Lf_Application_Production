import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const TextFieldWidget({
    Key? key,
    required this.controller,
    required this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: TextField(
          //  textCapitalization: TextCapitalization.words,
          style: const TextStyle(
            color: textColor,
            fontFamily: "Franklin Gothic Regular",
          ),
          controller: controller,
          //  maxLines: 3,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            filled: true,
            fillColor: whiteTextColor,
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
            hintStyle: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
