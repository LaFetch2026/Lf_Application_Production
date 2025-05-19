import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../common/widget/other/common_widget.dart';

enum PageState { DEFAULT, LOADING, ERROR }

extension on Exception {
  String getMessage() {
    Logger().w(this);
    return toString().split(":").length > 1
        ? toString().split(":")[1].trim()
        : toString();
  }
}

abstract class BaseController extends GetxController {
  // Logout state
  final logoutController = false.obs;

  // Reload flag
  final _refreshController = false.obs;

  void refreshPage(bool refresh) => _refreshController(refresh);

  // Page state
  final _pageStateController = PageState.DEFAULT.obs;

  PageState get pageState => _pageStateController.value;

  void updatePageState(PageState state) => _pageStateController(state);

  void resetPageState() {
    _errorMessageController('');
    _pageStateController(PageState.DEFAULT);
  }

  void showLoading() {
    if (pageState == PageState.LOADING) return;
    Logger().w("Loading state triggered");
    updatePageState(PageState.LOADING);
  }

  void showLoadingOne() => updatePageState(PageState.LOADING);

  void showError() => updatePageState(PageState.ERROR);

  void hideLoading() {
    resetPageState();
    Logger().w("Loading state hidden");
  }

  // Success / Error / General Message Observables
  final _messageController = ''.obs;

  String get message => _messageController.value;

  void showMessage(String msg) => _messageController(msg);

  final _errorMessageController = ''.obs;

  String get errorMessage => _errorMessageController.value;

  void showErrorMessageInForms(String msg) {
    showError();
    getSnackBar(msg);
    _errorMessageController(msg);
  }

  void showErrorMessage(String msg) {
    showError();
    _errorMessageController(msg);
  }

  final _successMessageController = ''.obs;

  String get successMessage => _successMessageController.value;

  void showSuccessMessage(String msg) => _successMessageController(msg);

  void showToast(String messageData) {
    // You can implement native toast or use fluttertoast here
  }

  void showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).size.height - 100,
        right: 20,
        left: 20,
      ),
    );
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
  }

  @override
  void onClose() {
    // Clean-up observables if needed
    super.onClose();
  }
}
