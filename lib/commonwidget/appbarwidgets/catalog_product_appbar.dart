import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';

class CatalogProductAppbar extends StatelessWidget {
  final Function? onPressedCart;
  final Function? onPressedSearch;

  const CatalogProductAppbar({
    Key? key,
    this.onPressedCart,
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
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(
                  arrowBack,
                  height: 20,
                  width: 20,
                  color: whiteColor,
                ),
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
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
                  onPressedCart?.call();
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 10),
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
