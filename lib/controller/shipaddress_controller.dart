import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ShipAddressController extends GetxController {
  RxBool showList = false.obs;
  RxBool onButton = true.obs;
  RxBool isCheck = false.obs;
  final nameController = TextEditingController();
  final pincodeController = TextEditingController();
  final stateController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final localityController = TextEditingController();

  final RxList<String> stateList = [
    'West Bengal',
    'Bihar',
    'Uttar Pradesh',
  ].obs;
}
