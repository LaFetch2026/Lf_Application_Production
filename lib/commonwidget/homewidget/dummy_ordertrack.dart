import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

class DummyOrderTrack extends StatelessWidget {
  const DummyOrderTrack({
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
                  itemCount: 4,
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (ctx, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const DummyContainer(height: 24, width: 24),
                            index == 3
                                ? const SizedBox(
                                    height: 0,
                                  )
                                : Container(
                                    width: 2,
                                    height: 60,
                                    color: Colors.black.withOpacity(0.04),
                                  )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.sp),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DummyContainer(height: 10, width: 60),
                              Padding(
                                padding: EdgeInsets.only(top: 8.sp),
                                child: DummyContainer(height: 10, width: 60),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  }),
            ),
          ],
        ));
  }
}
