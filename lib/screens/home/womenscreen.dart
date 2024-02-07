import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/womenwidget/lafetch_card.dart';
import 'package:lafetch/commonwidget/womenwidget/sale_card.dart';

import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';

class WomenScreen extends StatefulWidget {
  const WomenScreen({super.key});

  @override
  State<WomenScreen> createState() => _WomenScreenState();
}

class _WomenScreenState extends State<WomenScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: whiteBorderColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SaleCardWidget(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: double.infinity,
                color: colorSecondary,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16),
              child: AppText(
                text: "Express Delivery",
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w500,
                color: blackColor,
                fontSize: 16.sp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16),
              child: AppText(
                text: "We think you might also like",
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w500,
                color: blackColor,
                fontSize: 16.sp,
              ),
            ),
            const LafetchCardWidget(),
          ],
        ),
      ),
    );
  }
}
