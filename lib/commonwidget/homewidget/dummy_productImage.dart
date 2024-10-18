import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

class DummyProductImage extends StatelessWidget {
  const DummyProductImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.sp),
                  child: DummyContainer(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.7,
                  )),
              Positioned(
                bottom: 30.sp,
                right: 16.sp,
                child: DummyContainer(
                  width: MediaQuery.of(context).size.width,
                  height: 30.sp,
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 12.sp,
        ),
      ],
    );
  }
}
