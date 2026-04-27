import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lafetch/controllers/search_controller.dart';

void main() {
  setUp(() { Get.reset(); });
  tearDown(() { Get.reset(); });

  test('debug chip tap - direct dispose', () {
    final controller1 = Get.put(SearchScreenController());
    controller1.searchController.text = 'bag';
    controller1.searchController.addListener(() {});
    print('hasListeners before dispose: ${controller1.searchController.hasListeners}');
    
    // Call dispose directly (not via onClose)
    controller1.searchController.dispose();
    print('after direct dispose');
    
    try {
      controller1.searchController.text = 'bag';
      print('setter succeeded (no throw)');
    } catch (e) {
      print('setter threw: $e');
    }
  });
  
  test('debug chip tap - via onClose', () {
    final controller1 = Get.put(SearchScreenController());
    controller1.searchController.text = 'bag';
    controller1.searchController.addListener(() {});
    print('hasListeners before onClose: ${controller1.searchController.hasListeners}');
    
    // Call onClose (which should call dispose if hasListeners)
    controller1.onClose();
    print('after onClose');
    print('hasListeners after onClose: ${controller1.searchController.hasListeners}');
    
    try {
      controller1.searchController.text = 'bag';
      print('setter succeeded (no throw)');
    } catch (e) {
      print('setter threw: $e');
    }
  });
}
