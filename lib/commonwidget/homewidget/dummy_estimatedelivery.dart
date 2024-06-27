import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class DummyEstimateDelivery extends StatelessWidget {
  const DummyEstimateDelivery({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 20),
          child: AppText(
            text: "Delivery Estimates",
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.w400,
            color: blackColor,
            fontSize: 16.sp,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 5),
          child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: 3,
              padding: EdgeInsets.zero,
              scrollDirection: Axis.vertical,
              itemBuilder: (ctx, index) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DummyContainer(
                          height: 60,
                          width: 50,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: DummyContainer(
                            height: 16,
                            width: 80,
                          ),
                        ),
                        DummyContainer(
                          height: 16,
                          width: 80,
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
