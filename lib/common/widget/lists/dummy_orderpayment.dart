import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/constants.dart';
import 'dummy_container.dart';


class DummyOrderPayment extends StatelessWidget {
  const DummyOrderPayment({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.sp),
      child: Container(
        color: whiteColor,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 16.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 5.sp),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DummyContainer(height: 16, width: 100),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.sp),
                      child: DummyContainer(height: 16, width: 100),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.sp),
                child: Row(
                  children: [
                    DummyContainer(height: 16, width: 100),
                    DummyContainer(height: 16, width: 100),
                    Expanded(
                      flex: 1,
                      child: DummyContainer(height: 16, width: 100),
                    ),
                    DummyContainer(height: 16, width: 100),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.sp),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: DummyContainer(height: 16, width: 100),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: DummyContainer(height: 16, width: 100),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4.sp, left: 4.sp),
                      child: DummyContainer(height: 16, width: 100),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
