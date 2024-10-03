import 'package:flutter/material.dart';

class DoubleButton extends StatelessWidget {
  final String firstText;
  final String secondText;
  final double firstFontSize;
  final double secondFontSize;
  final String fontFamily;
  final Color firstTextColor;
  final Color secondTextColor;
  final Color firstBackgroundColor;
  final Color secondBackgroundColor;
  final Color firstBorderColor;
  final Color secondBorderColor;
  final Function? onPressedFirst;
  final Function? onPressedSecond;

  const DoubleButton(
      {Key? key,
      required this.firstText,
      required this.secondText,
      required this.firstTextColor,
      required this.secondTextColor,
      required this.firstBackgroundColor,
      required this.secondBackgroundColor,
      required this.firstBorderColor,
      required this.secondBorderColor,
      this.firstFontSize = 14,
      this.secondFontSize = 14,
      this.fontFamily = "Franklin Gothic",
      this.onPressedFirst,
      this.onPressedSecond})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Center(
                child: SizedBox(
                    width: 160,
                    height: 50,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2))),
                            side: MaterialStateProperty.all(
                              BorderSide(width: 1, color: firstBorderColor),
                            ),
                            elevation: MaterialStateProperty.all(0.0),
                            backgroundColor:
                                MaterialStateProperty.all(firstBackgroundColor),
                            textStyle: MaterialStateProperty.all(TextStyle(
                              color: firstTextColor,
                              fontSize: firstFontSize,
                            ))),
                        onPressed: () {
                          onPressedFirst?.call();
                        },
                        child: Text(
                          firstText,
                          style: TextStyle(
                              color: firstTextColor,
                              fontFamily: fontFamily,
                              fontSize: firstFontSize),
                        ))),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Center(
                child: SizedBox(
                    width: 160,
                    height: 50,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2))),
                            side: MaterialStateProperty.all(BorderSide(
                                color: secondBorderColor,
                                width: 1.0,
                                style: BorderStyle.solid)),
                            elevation: MaterialStateProperty.all(0.0),
                            backgroundColor: MaterialStateProperty.all(
                                secondBackgroundColor),
                            textStyle: MaterialStateProperty.all(TextStyle(
                              color: secondTextColor,
                              fontSize: secondFontSize,
                            ))),
                        onPressed: () {
                          onPressedSecond?.call();
                        },
                        child: Text(
                          secondText,
                          style: TextStyle(
                              fontFamily: fontFamily,
                              color: secondTextColor,
                              fontSize: secondFontSize),
                        ))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
