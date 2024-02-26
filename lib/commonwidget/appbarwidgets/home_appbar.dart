import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class HomeAppbar extends StatelessWidget {
  final Function? onPressedCart;
  final Function? onPressedSearch;
  final Function? onPressedCatalog;

  const HomeAppbar({
    Key? key,
    this.onPressedCart,
    this.onPressedCatalog,
    this.onPressedSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      color: colorPrimary,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 40, right: 16),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(appNameImage,
                  height: 28, width: 70, fit: BoxFit.cover),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              GestureDetector(
                onTap: () {
                  onPressedSearch?.call();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: ImageIcon(
                    AssetImage(searchImage),
                    color: textHintColor,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  onPressedCatalog?.call();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: ImageIcon(
                    AssetImage(saveIcon),
                    color: textHintColor,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  onPressedCart?.call();
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child: CircleAvatar(
                      backgroundColor: whiteColor,
                      child: ImageIcon(
                        AssetImage(cartImage),
                        color: colorPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
