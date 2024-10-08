import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

class DummyReview extends StatelessWidget {
  const DummyReview({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const DummyContainer(height: 10, width: 60),
            Padding(
              padding: EdgeInsets.only(bottom: 20.sp, top: 30.sp),
              child: ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: 1,
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (ctx, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            DummyContainer(height: 14, width: 14),
                            DummyContainer(height: 14, width: 80),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0.sp),
                            child: DummyContainer(height: 14, width: 80)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            DummyContainer(height: 14, width: 50),
                            DummyContainer(height: 14, width: 16),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.sp,
                              ),
                              child: DummyContainer(height: 14, width: 80),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0.sp),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DummyContainer(height: 14, width: 80),
                              DummyContainer(height: 14, width: 80),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ));
  }
}
