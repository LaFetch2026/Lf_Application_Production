// ignore_for_file: avoid_print

import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/models/analytics_models.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';

import '../../common/widget/appbar/backbutton_appbar.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/other/text_field.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/constant/constants.dart';
import '../wishlistscreen.dart';

class NewBoardScreen extends StatefulWidget {
  final String title;
  final String boardName;
  final String hintName;
  final int boardId; // 0 => create, otherwise edit/add-to-existing
  final String btnText; // “Next” / “Save changes”
  final int productId; // used when adding a product to an existing board
  final int categoryId;
  final String screen;

  const NewBoardScreen({
    super.key,
    required this.title,
    required this.boardName,
    required this.hintName,
    required this.boardId,
    required this.btnText,
    required this.productId,
    this.categoryId = 0,
    this.screen = "",
  });

  @override
  State<NewBoardScreen> createState() => _NewBoardScreenState();
}

class _NewBoardScreenState extends State<NewBoardScreen> {
  final WishlistController wishlistController = Get.put(WishlistController());
  final CatalogController catalogController = Get.put(CatalogController());
  final CartController cartController = Get.put(CartController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  bool _submitting = false;

  bool get _isEditTitle =>
      widget.title.toLowerCase().contains('edit') ||
      widget.btnText.toLowerCase().contains('save');

  @override
  void initState() {
    super.initState();
    wishlistController.boardError.value = "";
    wishlistController.boardNameController.text = widget.boardName;
  }

  Future<void> _handlePrimaryAction() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();

    final boardName = wishlistController.boardNameController.text.trim();
    if (!wishlistController.checkIdNamevalidation(boardName)) return;

    _submitting = true;

    // 1) CREATE NEW BOARD
    if (widget.boardId == 0) {
      await wishlistController
          .createBoard(boardName); // shows snackbar + refresh inside

      if (widget.screen == "Bag") {
        Timer(const Duration(milliseconds: 400), () {
          cartController.getCartData();
        });
      }

      await analytics.logEvent(
        name: 'create_board_btnClick',
        parameters: {'page_name': 'create_board_btnClick'},
      );

      // Route to Wishlist (fresh list after create)
      if (!mounted) return;
      Get.off(() => WishlistScreen());
      _submitting = false;
      return;
    }

    // 2) EXISTING BOARD — either RENAME or ADD PRODUCT
    if (_isEditTitle) {
      await wishlistController.renameBoard(widget.boardId, boardName);
      await analytics.logEvent(
        name: 'edit_board_btnClick',
        parameters: {'page_name': 'edit_board_btnClick'},
      );
      if (mounted) Get.back();
      _submitting = false;
      return;
    }

    // Add product to an existing board
    if (widget.productId != 0) {
      final analyticsProduct = AnalyticsProduct(
        prid: widget.productId.toString(),
        image: '',
        prqt: 1,
        productName: '',
        category: '',
        brand: '',
        sellingPrice: 0.0,
        productUrl: '',
        discountedPrice: 0.0,
        stockAvailability: 0,
      );

      await wishlistController.addProductToBoard(
          widget.boardId, analyticsProduct);
      await analytics.logEvent(
        name: 'add_product_to_board_click',
        parameters: {'page_name': 'add_product_to_board_click'},
      );
      if (mounted)
        Get.back(result: {"boardId": widget.boardId, "boardName": boardName});
      _submitting = false;
      return;
    }

    if (mounted) Get.back();
    _submitting = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BackButtonAppbar(
                    text: widget.title,
                    threeDot: false,
                    icon: threeDotImage,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 40.sp),
                    child: TextFieldWidget(
                      hint: widget.hintName,
                      controller: wishlistController.boardNameController,
                    ),
                  ),
                  Obx(
                    () => Padding(
                      padding:
                          EdgeInsets.only(left: 16.sp, right: 5.sp, top: 5.sp),
                      child: AppText(
                        text: wishlistController.boardError.value,
                        fontFamily: "Clash Display Regular",
                        fontWeight: FontWeight.w400,
                        color: lightPurpleColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.sp),
            child: getSingleButton(
              label: widget.btnText,
              textColor: whiteBorderColor,
              backgroundColor: colorPrimary,
              controller: wishlistController,
              onPressed: _handlePrimaryAction,
              borderColor: colorPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
