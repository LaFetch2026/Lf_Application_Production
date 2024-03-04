import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';

class MenScreen extends StatefulWidget {
  const MenScreen({super.key});

  @override
  State<MenScreen> createState() => MenScreenState();
}

class MenScreenState extends State<MenScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: whiteTextColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16),
              child: AppText(
                text: "",
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w500,
                color: btnTextColor,
                fontSize: 22.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
