import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

class DummyGridList extends StatelessWidget {
  const DummyGridList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 90),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.zero,
        childAspectRatio: 0.5,
        physics: const ScrollPhysics(),
        crossAxisSpacing: 5,
        mainAxisSpacing: 0,
        children: List.generate(
          6,
          (index) {
            return const Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Center(
                          child: DummyContainer(
                            height: 190,
                            width: 152,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 22, vertical: 10),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              child: DummyContainer(
                                height: 24,
                                width: 24,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 22, vertical: 10),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: DummyContainer(
                              height: 26,
                              width: 80,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: DummyContainer(
                        height: 10,
                        width: 50,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: DummyContainer(
                        height: 10,
                        width: 50,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10, left: 10, right: 1),
                      child: Row(
                        children: [
                          DummyContainer(
                            height: 10,
                            width: 50,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: DummyContainer(
                              height: 10,
                              width: 50,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: Row(
                        children: [
                          DummyContainer(
                            height: 14,
                            width: 14,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: DummyContainer(
                              height: 10,
                              width: 50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
