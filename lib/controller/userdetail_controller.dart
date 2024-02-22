import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UserDetailsController extends GetxController {
  RxBool showList = false.obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final gerderController = TextEditingController();

  final RxList<String> genderList = [
    'Male',
    'Female',
    'Non-Binary',
  ].obs;
}
