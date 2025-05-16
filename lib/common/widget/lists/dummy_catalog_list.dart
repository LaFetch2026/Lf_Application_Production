import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/constants.dart';
import 'dummy_container.dart';


class DummyCatalogList extends StatelessWidget {
  const DummyCatalogList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.sp, right: 16.sp, top: 10.sp),
      child: ListView.builder(
          primary: false,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemCount: 3,
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10.sp),
                  child: Container(
                    color: whiteColor,
                    width: double.infinity,
                    height: 100.sp,
                    child: Column(
                      children: [
                        DummyContainer(
                          height: 100,
                          width: double.infinity,
                        ),
                        /*   Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.sp, vertical: 10.sp),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                DummyContainer(
                                  height: 10,
                                  width: 60,
                                ),
                                Expanded(
                                  child: SizedBox(
                                    width: 0,
                                  ),
                                ),
                                DummyContainer(
                                  height: 20,
                                  width: 20,
                                ),
                              ],
                            ),
                          ),
                        ), */
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
