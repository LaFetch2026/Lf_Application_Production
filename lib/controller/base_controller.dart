import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../utils/common_widgets.dart';

enum PageState { DEFAULT, LOADING, ERROR }

extension on Exception {
  String getMessage() {
    Logger().w(this);
    return toString().split(":")[1].trim();
  }
}

abstract class BaseController extends GetxController {
  final logoutController = false.obs;

  //Reload the page
  final _refreshController = false.obs;

  refreshPage(bool refresh) => _refreshController(refresh);

  //Controls page state
  final _pageSateController = PageState.DEFAULT.obs;

  PageState get pageState => _pageSateController.value;

  updatePageState(PageState state) => _pageSateController(state);

  resetPageState() {
    _errorMessageController('');
    _pageSateController(PageState.DEFAULT);
  }

  showLoading() {
    if (pageState == PageState.LOADING) return;
    Logger().w("its triggered");
    updatePageState(PageState.LOADING);
  }

  showLoadingOne() {
    updatePageState(PageState.LOADING);
  }

  showError() => updatePageState(PageState.ERROR);

  hideLoading() {
    resetPageState();
    Logger().w("hide triggered");
  }

  final _messageController = ''.obs;

  String get message => _messageController.value;

  showMessage(String msg) => _messageController(msg);

  final _errorMessageController = ''.obs;

  String get errorMessage => _errorMessageController.value;
//forms
  showErrorMessageInForms(String msg) {
    showError();
    getSnackBar(msg);
    _errorMessageController(msg);
  }

//list error
  showErrorMessage(String msg) {
    showError();
    _errorMessageController(msg);
  }

  final _successMessageController = ''.obs;

  String get successMessage => _messageController.value;

  showSuccessMessage(String msg) => _successMessageController(msg);

  showToast(String messageData) {}

  showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(Get.context!).size.height - 100,
          right: 20,
          left: 20),
    );
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
  }

  @override
  void onClose() {
    // _messageController.close();
    // _refreshController.close();
    // _pageSateController.close();
    super.onClose();
  }
}
