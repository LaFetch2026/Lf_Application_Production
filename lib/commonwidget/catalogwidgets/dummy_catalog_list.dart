import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/utils/constants.dart';

class DummyCatalogList extends StatelessWidget {
  const DummyCatalogList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
      child: ListView.builder(
          primary: false,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemCount: 5,
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    color: whiteColor,
                    width: double.infinity,
                    height: 145,
                    child: const Column(
                      children: [
                        DummyContainer(
                          height: 100,
                          width: double.infinity,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
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
                        ),
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
