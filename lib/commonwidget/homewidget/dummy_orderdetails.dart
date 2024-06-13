import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/utils/constants.dart';

class DummyOrderDetails extends StatelessWidget {
  const DummyOrderDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: DummyContainer(
              height: 10,
              width: 50,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: 1,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                itemBuilder: (ctx, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        Container(
                          color: whiteColor,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: DummyContainer(
                                              height: 85,
                                              width: 70,
                                            )),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 5, left: 12),
                                                child: DummyContainer(
                                                  height: 10,
                                                  width: 70,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 5,
                                                    left: 12,
                                                    top: 5,
                                                    bottom: 5),
                                                child: DummyContainer(
                                                  height: 10,
                                                  width: 70,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 5,
                                                    left: 12,
                                                    top: 5,
                                                    bottom: 5),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 10),
                                                      child: DummyContainer(
                                                        height: 10,
                                                        width: 50,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10),
                                                        child: DummyContainer(
                                                          height: 10,
                                                          width: 50,
                                                        ),
                                                      ),
                                                    ),
                                                    DummyContainer(
                                                      height: 10,
                                                      width: 50,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ]),
                          ),
                        )
                      ],
                    ),
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              color: whiteColor,
              child: const Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DummyContainer(height: 10, width: 60),
                    ),
                    DummyContainer(height: 10, width: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
