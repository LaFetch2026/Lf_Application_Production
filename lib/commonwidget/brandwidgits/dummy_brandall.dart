import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DummybrandAll extends StatelessWidget {
  const DummybrandAll({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        primary: false,
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 7,
        itemCount: 4,
        itemBuilder: (context, index) {
          double ht = index % 2 == 0 ? 100 : 180;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: ht,
                    width: 156,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        child: Container(
                          height: 10,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
