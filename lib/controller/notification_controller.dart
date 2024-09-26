// ignore_for_file: avoid_print
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';

class NotificationController extends BaseController {
  RxBool isOrder = false.obs;
  RxBool isOffer = false.obs;
  RxBool isPermotion = true.obs;
  RxInt orderValue = 0.obs;
  RxInt offerValue = 0.obs;
  RxInt permotionValue = 0.obs;
}
