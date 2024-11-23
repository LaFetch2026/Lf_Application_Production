import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import '../../utils/constants.dart';

class DummybrandList extends StatelessWidget {
  const DummybrandList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(left: 16.sp, right: 16.sp, bottom: 10.sp, top: 10.sp),
      child: AnimationLimiter(
        child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: 10,
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            itemBuilder: (ctx, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 200),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Column(
                      children: [
                        GestureDetector(
                            onTap: () {},
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10.sp),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1.sp),
                                    border: Border.all(
                                        width: 1.sp, color: Colors.white),
                                    color: whiteBorderColor),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.sp, vertical: 10.sp),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          DummyContainer(height: 32, width: 32),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.sp),
                                            child: DummyContainer(
                                                height: 10, width: 50),
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              width: 0,
                                            ),
                                          ),
                                          DummyContainer(height: 20, width: 20),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
