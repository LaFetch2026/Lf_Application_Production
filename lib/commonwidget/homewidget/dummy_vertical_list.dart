import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

class DummyVerticalList extends StatelessWidget {
  const DummyVerticalList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 60),
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const ScrollPhysics(),
              itemCount: 5,
              scrollDirection: Axis.vertical,
              itemBuilder: (ctx, index) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        DummyContainer(height: 400, width: double.infinity),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              child: DummyContainer(height: 30, width: 30),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: DummyContainer(height: 26, width: 80),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: DummyContainer(height: 10, width: 50),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: DummyContainer(height: 10, width: 50)),
                    Padding(
                      padding: EdgeInsets.only(top: 10, left: 10, right: 1),
                      child: Row(
                        children: [
                          DummyContainer(height: 10, width: 50),
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: DummyContainer(height: 10, width: 50),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 5, left: 10, right: 10, bottom: 30),
                      child: Row(
                        children: [
                          DummyContainer(height: 14, width: 14),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: DummyContainer(height: 10, width: 50),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
            //  ),
          ),
        ],
      ),
    );
  }
}
