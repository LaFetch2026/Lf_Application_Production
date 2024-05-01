import 'package:flutter/material.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
