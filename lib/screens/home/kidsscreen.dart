import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';

class KidsScreen extends StatefulWidget {
  const KidsScreen({super.key});

  @override
  State<KidsScreen> createState() => KidsScreenState();
}

class KidsScreenState extends State<KidsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: whiteBorderColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16),
              child: AppText(
                text: "3",
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
