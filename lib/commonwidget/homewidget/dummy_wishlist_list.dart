import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

class DummyWishlistList extends StatelessWidget {
  const DummyWishlistList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.zero,
        childAspectRatio: 0.7,
        physics: const ScrollPhysics(),
        crossAxisSpacing: 5,
        mainAxisSpacing: 0,
        children: List.generate(
          6,
          (index) {
            return Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: const DummyContainer(height: 156, width: 156),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: DummyContainer(height: 10, width: 50),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: DummyContainer(height: 10, width: 50),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
