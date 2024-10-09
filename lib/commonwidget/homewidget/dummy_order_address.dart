import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

import '../../utils/constants.dart';

class DummyOrderAddress extends StatelessWidget {
  const DummyOrderAddress({
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
              DummyContainer(height: 20, width: 100),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.sp),
                child: DummyContainer(height: 16, width: 100),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5.sp),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10.sp),
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
                padding: EdgeInsets.symmetric(vertical: 8.sp),
                child: DummyContainer(height: 16, width: 100),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.sp),
                child: DummyContainer(height: 16, width: 100),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.sp),
                child: DummyContainer(height: 16, width: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
