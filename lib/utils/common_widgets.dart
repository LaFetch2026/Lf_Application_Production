import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lafetch/utils/constants.dart';

getSnackBar(message, {SnackPosition? snackPosition}) {
  return Get.snackbar(
    '',
    message,
    titleText: Container(),
    duration: const Duration(seconds: 2),
    snackPosition: snackPosition ?? SnackPosition.TOP,
    backgroundColor: colorSecondary,
    colorText: colorPrimary,
  );
}
