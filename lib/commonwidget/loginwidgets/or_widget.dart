import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class ORWidget extends StatelessWidget {
  const ORWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: 100,
              color: lightText,
              height: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: AppText(
              text: "OR",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: lightText,
              fontSize: 11.sp,
            ),
          ),
          Expanded(
            child: Container(
              width: 100,
              color: lightText,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
