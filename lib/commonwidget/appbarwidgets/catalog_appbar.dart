import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class CatalogAppbar extends StatelessWidget {
  final Function? onPressed;
  final String text;

  const CatalogAppbar({
    Key? key,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      color: whiteBorderColor,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 40, right: 16),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(backArrowImage,
                    height: 16, width: 10, fit: BoxFit.cover),
              ),
              const SizedBox(
                width: 10,
              ),
              AppText(
                text: text,
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: appbarText,
                fontSize: 22.sp,
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: ImageIcon(
                  AssetImage(searchImage),
                  color: textHintColor,
                  size: 20,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: ImageIcon(
                  AssetImage(cartImage),
                  color: textHintColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
