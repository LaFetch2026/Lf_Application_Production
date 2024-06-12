import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import '../../utils/constants.dart';

class DummybrandList extends StatelessWidget {
  const DummybrandList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 10),
      child: ListView.builder(
          primary: false,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemCount: 10,
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return Column(
              children: [
                GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1),
                            border: Border.all(width: 1, color: Colors.white),
                            color: whiteBorderColor),
                        child: const Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  DummyContainer(height: 32, width: 32),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child:
                                        DummyContainer(height: 10, width: 50),
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
            );
          }),
    );
  }
}
