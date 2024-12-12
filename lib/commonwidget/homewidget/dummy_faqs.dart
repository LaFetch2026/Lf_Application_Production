import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

class DummyFaqs extends StatelessWidget {
  const DummyFaqs({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.sp, top: 16.sp),
          child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: 2,
              padding: EdgeInsets.zero,
              scrollDirection: Axis.vertical,
              itemBuilder: (ctx, index) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.sp, vertical: 5.sp),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DummyContainer(height: 16, width: double.infinity),
                      Padding(
                        padding: EdgeInsets.only(top: 5.sp),
                        child:
                            DummyContainer(height: 16, width: double.infinity),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.sp),
                        child:
                            DummyContainer(height: 16, width: double.infinity),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5.sp),
                        child:
                            DummyContainer(height: 16, width: double.infinity),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5.sp),
                        child:
                            DummyContainer(height: 16, width: double.infinity),
                      ),
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }
}
