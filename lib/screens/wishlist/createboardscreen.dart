// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/widget/appbar/backbutton_appbar.dart';
import '../../common/widget/appbar/editboard_appbar.dart';
import '../../common/widget/lists/dummy_grid_list.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/constant/constants.dart';
import '../../common/widget/other/pounce_wrapper.dart';
import '../catalog/productlist/pdp/product_details_screen_v2.dart';

class CreateBoardScreen extends StatefulWidget {
  final String btnText; // "" => Edit mode, otherwise Add mode (button text)
  final int wishlistId; // boardId
  final String type; // "edit" | "addmore" (kept for analytics)
  final int productId; // used in Add mode

  const CreateBoardScreen({
    super.key,
    required this.btnText,
    required this.wishlistId,
    required this.productId,
    required this.type,
  });

  @override
  State<CreateBoardScreen> createState() => CreateBoardScreenState();
}

class CreateBoardScreenState extends State<CreateBoardScreen> {
  final wishlistController = Get.put(WishlistController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final ScrollController _listController = ScrollController();
  List<bool> _selected = [];
  final List<int> _deleteIds = [];
  int _selectedCount = 0;

  bool get _isEditMode => widget.btnText.isEmpty;

  @override
  void initState() {
    super.initState();
    // Load products for this board in EDIT mode
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isEditMode) {
        await wishlistController.fetchBoardProducts(widget.wishlistId);
        setState(() {
          _selected = List<bool>.filled(
            wishlistController.wishListProduct.length,
            false,
          );
          _deleteIds.clear();
          _selectedCount = 0;
        });
      }
    });
  }

  // ---------------- image helpers ----------------
  String _normalizeUrl(String u) {
    if (u.isEmpty) return u;
    if (u.startsWith('//')) return 'https:$u';
    return u; // add a base if your API returns relative paths
  }

  String _firstImage(Map<String, dynamic> product) {
    try {
      // direct fields first
      for (final k in [
        'image',
        'imageUrl',
        'thumbnail',
        'coverImage',
        'primary_image',
        'primaryImage',
      ]) {
        final v = product[k]?.toString() ?? '';
        if (v.trim().isNotEmpty) return _normalizeUrl(v);
      }

      // images list as strings
      final imgsRaw = product['images'];
      if (imgsRaw is List) {
        for (final it in imgsRaw) {
          if (it is String && it.trim().isNotEmpty) {
            return _normalizeUrl(it);
          }
        }
        // images list as maps
        for (final it in imgsRaw) {
          if (it is Map) {
            for (final k in ['name', 'url', 'image', 'src', 'thumbnail']) {
              final v = it[k]?.toString() ?? '';
              if (v.trim().isNotEmpty) return _normalizeUrl(v);
            }
          }
        }
      }
    } catch (_) {}
    return '';
  }

  // ---------------- selection helpers ----------------
  void _toggleSelect(int index, int productId) async {
    final newVal = !_selected[index];
    setState(() {
      _selected[index] = newVal;
      if (newVal) {
        if (!_deleteIds.contains(productId)) _deleteIds.add(productId);
        _selectedCount++;
      } else {
        _deleteIds.removeWhere((id) => id == productId);
        if (_selectedCount > 0) _selectedCount--;
      }
    });

    await analytics.logEvent(
      name: newVal ? 'board_product_selected' : 'board_product_unselected',
      parameters: {
        'page_name':
            newVal ? 'board_product_selected' : 'board_product_unselected'
      },
    );
  }

  Future<void> _confirmDeleteSelected() async {
    if (_deleteIds.isEmpty) {
      getSnackBar("Select product");
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          barrierColor: Colors.black26,
          builder: (_) => showDoubleBtnDailog(
            click1: () => Get.back(result: false),
            click2: () => Get.back(result: true),
            btncolor: colorPrimary,
            text: "Are you sure you want to delete the selected item(s)?",
            btn1Text: "No",
            btn2Text: "Yes",
          ),
        ) ??
        false;

    if (!confirmed) return;

    // Remove each selected product then refresh list
    for (final pid in List<int>.from(_deleteIds)) {
      await wishlistController.removeProductFromBoard(widget.wishlistId, pid);
    }
    await wishlistController.fetchBoardProducts(widget.wishlistId);

    setState(() {
      _selected = List<bool>.filled(
        wishlistController.wishListProduct.length,
        false,
      );
      _deleteIds.clear();
      _selectedCount = 0;
    });

    await analytics.logEvent(
      name: 'delete_board_iconclick',
      parameters: {'page_name': 'delete_board_iconclick'},
    );
  }

  Future<void> _addSingleProductToBoard() async {
    await wishlistController.addProductToBoard(
      widget.wishlistId,
      widget.productId,
    );
    Get.back();
  }

  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          _isEditMode
              ? EditBoardAppbar(
                  text: "Edit Board",
                  onPressedDelete: _confirmDeleteSelected,
                  onPressedShare: () async {
                    await analytics.logEvent(
                      name: 'share_board_iconclick',
                      parameters: {'page_name': 'share_board_iconclick'},
                    );
                  },
                )
              : const BackButtonAppbar(
                  text: "Add items to board",
                  threeDot: false,
                  icon: threeDotImage,
                ),

          // BODY
          _isEditMode
              ? Obx(
                  () => wishlistController.isDetails.value
                      ? const Expanded(child: DummyGridList())
                      : Expanded(
                          child: wishlistController.wishListProduct.isEmpty
                              ? _emptyState()
                              : _editGrid(),
                        ),
                )
              : Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 12.sp),
                      child: AppText(
                        text:
                            "Tap '${widget.btnText}' to add this item to the board.",
                        color: appBarColor,
                        fontFamily: "Clash Display Regular",
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

          // BOTTOM CTA (only in ADD mode)
          if (!_isEditMode)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.sp),
              child: getSingleButton(
                label: widget.btnText,
                textColor: whiteBorderColor,
                controller: wishlistController,
                backgroundColor: colorPrimary,
                onPressed: _addSingleProductToBoard,
                borderColor: colorPrimary,
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- widgets ----------------
  Widget _emptyState() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        child: Center(
          child: Text(
            "oops! Seems like you haven't wishlisted any product.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black,
              fontFamily: "Clash Display Regular",
            ),
          ),
        ),
      );

  Widget _editGrid() {
    return SingleChildScrollView(
      controller: _listController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected count (local)
          Padding(
            padding: EdgeInsets.only(left: 16.sp, right: 16.sp, top: 10.sp),
            child: AppText(
              text: (_selectedCount == 1)
                  ? "1 item selected"
                  : "$_selectedCount items selected",
              color: textHintColor,
              fontSize: 12,
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.w400,
            ),
          ),

          // Grid
          Center(
            child: Padding(
              padding: EdgeInsets.only(left: 16.sp, right: 16.sp, top: 10.sp),
              child: GetBuilder<WishlistController>(
                builder: (value) {
                  final list = value.wishListProduct;
                  // If data length changed (after refresh), normalize selection arrays
                  if (_selected.length != list.length) {
                    _selected = List<bool>.filled(list.length, false);
                    _deleteIds.clear();
                    _selectedCount = 0;
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    crossAxisCount: 2,
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.zero,
                    childAspectRatio: 0.6,
                    physics: const ScrollPhysics(),
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 9,
                    children: List.generate(
                      list.length,
                      (index) {
                        final p = Map<String, dynamic>.from(list[index] as Map);
                        final pid = (p['id'] is int)
                            ? p['id'] as int
                            : int.tryParse('${p['id']}') ?? 0;
                        final brand = (p['brand_name'] ?? '').toString();
                        final name = (p['name'] ?? '').toString();
                        final price = (p['price'] ?? '').toString();
                        final mrp = (p['mrp'] ?? '').toString();
                        final img = _firstImage(p);
                        final isSel = _selected[index];

                        return Column(
                          children: [
                            PounceWrapper(
                              onTap: () async {
                                Get.to(() => ProductDetailsScreenV2(
                                      brandName: brand,
                                      productId: pid,
                                      type: "add",
                                    ));
                                await analytics.logEvent(
                                  name: 'board_product_details',
                                  parameters: {
                                    'page_name': 'board_product_details'
                                  },
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // image + selection knob
                                  Stack(
                                    children: [
                                      Center(
                                        child: (img.isNotEmpty)
                                            ? SizedBox(
                                                height: (MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2) +
                                                    10.sp,
                                                width: (MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2) -
                                                    24,
                                                child: CachedNetworkImage(
                                                  cacheManager: CacheManager(
                                                    Config(
                                                      "customCacheKey",
                                                      stalePeriod:
                                                          const Duration(
                                                              days: 15),
                                                      maxNrOfCacheObjects: 100,
                                                    ),
                                                  ),
                                                  fit: BoxFit.fill,
                                                  imageUrl: img,
                                                  errorWidget: (_, __, ___) =>
                                                      Image.asset(
                                                    downloadImage,
                                                    fit: BoxFit.fill,
                                                    height:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                2) +
                                                            10.sp,
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                2) -
                                                            24,
                                                  ),
                                                ),
                                              )
                                            : Image.asset(
                                                dummyWishlistImage,
                                                height: (MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2) +
                                                    10.sp,
                                                width: (MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2) -
                                                    24,
                                                fit: BoxFit.fill,
                                              ),
                                      ),
                                      // select / deselect tick
                                      Positioned(
                                        right: 16.sp,
                                        top: 10.sp,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _toggleSelect(index, pid),
                                          child: SizedBox(
                                            height: 24.sp,
                                            width: 24.sp,
                                            child: isSel
                                                ? CircleAvatar(
                                                    backgroundColor: whiteColor,
                                                    child: Image.asset(
                                                      blackRightCircleImage,
                                                      height: 24.sp,
                                                      width: 24.sp,
                                                    ),
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: greyBorder,
                                                        width: 1.0.sp,
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const CircleAvatar(
                                                      backgroundColor:
                                                          whiteColor,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // name
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.sp, vertical: 5.sp),
                                    child: AppText(
                                      text: name,
                                      color: nameText,
                                      maxLines: 1,
                                      fontSize: 12,
                                      fontFamily: "Clash Display",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  // brand
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.sp),
                                    child: AppText(
                                      text: brand,
                                      color: nameText,
                                      maxLines: 1,
                                      fontSize: 11,
                                      fontFamily: "Clash Display Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),

                                  // price + mrp
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 10.sp, left: 10.sp, right: 1),
                                    child: Row(
                                      children: [
                                        AppText(
                                          text: "\u{20B9} $price",
                                          color: deepGreytextColor,
                                          maxLines: 2,
                                          fontSize: 11,
                                          fontFamily: "Clash Display",
                                          fontWeight: FontWeight.w400,
                                        ),
                                        if (mrp.isNotEmpty)
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 5.sp),
                                            child: Text(
                                              "\u{20B9} $mrp",
                                              style: TextStyle(
                                                color: textHintColor,
                                                fontSize: 11.sp,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontFamily:
                                                    "Clash Display Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
