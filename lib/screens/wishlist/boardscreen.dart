// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/share_link_generator.dart';
import '../wishlistscreen.dart';
import '../../common/widget/appbar/backbutton_appbar.dart';
import '../../common/widget/bottom_sheets/bottomsheetboard.dart';
import '../../common/widget/lists/dummy_grid_list.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/constant/constants.dart';
import '../../common/widget/other/pounce_wrapper.dart';
import '../catalog/productlist/pdp_v2/product_details_screen_v2.dart';
import 'createboardscreen.dart';
import 'newboardscreen.dart';

class BoardScreen extends StatefulWidget {
  final String boardName;
  final int boardId;
  final int productId;

  const BoardScreen({
    super.key,
    required this.boardName,
    required this.boardId,
    required this.productId,
  });

  @override
  State<BoardScreen> createState() => BoardScreenState();
}

class BoardScreenState extends State<BoardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final wishlistController = Get.put(WishlistController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  bool isDrawer = false;
  PersistentBottomSheetController? _sheet;

  @override
  void initState() {
    super.initState();
    wishlistController.wishListProduct.clear();
    wishlistController.boardProducts.clear();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => wishlistController.getWishlistDetails(widget.boardId, 1),
    );
  }

  // ---------- Bottom sheet helpers ----------
  void _openSheet() {
    if (_sheet != null) return;
    final st = scaffoldKey.currentState;
    if (st == null) return;

    isDrawer = true;
    setState(() {});

    _sheet = st.showBottomSheet(
      (context) => BottomSheetBoard(
        onPressedShare: () async {
          // Capture render-box position before the sheet is dismissed,
          // so iOS has a valid non-zero sharePositionOrigin for the popover.
          final box =
              scaffoldKey.currentContext?.findRenderObject() as RenderBox?;
          final shareOrigin =
              box != null ? box.localToGlobal(Offset.zero) & box.size : null;

          _closeSheet();
          final link = await ShareLinkGenerator.generateBoardShareLink(
            boardId: widget.boardId,
            boardName: widget.boardName,
          );
          Share.share(
            "Check out my wishlist board on Lafetch:\n$link",
            sharePositionOrigin: shareOrigin,
          );
          await analytics.logEvent(
            name: 'board_share_click',
            parameters: {'page_name': 'board_share_click'},
          );
        },
        onPressedEdit: () async {
          _closeSheet();
          Get.to(() => CreateBoardScreen(
                btnText: "",
                wishlistId: widget.boardId,
                type: "edit",
                productId: widget.productId,
              ));
          await analytics.logEvent(
            name: 'board_edit_click',
            parameters: {'page_name': 'board_edit_click'},
          );
        },
        onPressedAddItem: () async {
          _closeSheet();
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateBoardScreen(
                btnText: "Add",
                type: "addmore",
                wishlistId: widget.boardId,
                productId: widget.productId,
              ),
            ),
          );
          await wishlistController.getWishlistDetails(widget.boardId, 1);
          await analytics.logEvent(
            name: 'board_additem_click',
            parameters: {'page_name': 'board_additem_click'},
          );
        },
        // DELETE BOARD (not product)
        onPressedDelete: () async {
          _closeSheet();
          final confirmed = await showDialog<bool>(
                context: context,
                barrierColor: Colors.black26,
                builder: (_) => showDoubleBtnDailog(
                  click1: () => Get.back(result: false), // No
                  click2: () => Get.back(result: true), // Yes
                  btncolor: colorPrimary,
                  text: "Are you sure you want to delete the board?",
                  btn1Text: "No",
                  btn2Text: "Yes",
                ),
              ) ??
              false;

          if (confirmed) {
            final ok = await wishlistController.deleteBoard(widget.boardId);
            if (ok) {
              await wishlistController.fetchBoards();
              if (!mounted) return;
              Get.offAll(() => const WishlistScreen());
            }
          }

          await analytics.logEvent(
            name: 'board_delete_click',
            parameters: {'page_name': 'board_delete_click'},
          );
        },
        onPressedRename: () async {
          _closeSheet();
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NewBoardScreen(
                title: "Edit Board Name",
                hintName: "",
                productId: 0,
                boardId: widget.boardId,
                boardName: widget.boardName,
                btnText: "Save changes",
              ),
            ),
          );
          await wishlistController.getWishlistDetails(widget.boardId, 1);
          await analytics.logEvent(
            name: 'board_rename_click',
            parameters: {'page_name': 'board_rename_click'},
          );
        },
      ),
    );

    _sheet?.closed.whenComplete(() {
      _sheet = null;
      if (mounted) {
        isDrawer = false;
        setState(() {});
      }
    });
  }

  void _closeSheet() {
    final s = _sheet;
    if (s != null) {
      try {
        s.close();
      } catch (_) {}
    }
    _sheet = null;
    isDrawer = false;
    if (mounted) setState(() {});
  }

  // ---------- helpers ----------
  num _asNum(dynamic v) {
    if (v is num) return v;
    return num.tryParse('$v'.replaceAll(',', '').trim()) ?? 0;
  }

  String _normalizeUrl(String u) {
    if (u.isEmpty) return u;
    if (u.startsWith('//')) return 'https:$u';
    return u;
  }

  /// Return the first image we can use. Supports:
  /// `images` (List<String|Map>) and `imageUrls` from your API.
  String _firstImage(Map<String, dynamic> product) {
    // imageUrls from backend
    final iu = product['imageUrls'];
    if (iu is List && iu.isNotEmpty) {
      final u = '${iu.first}';
      if (u.trim().isNotEmpty) return _normalizeUrl(u);
    }

    // direct fields
    for (final k in [
      'image',
      'imageUrl',
      'thumbnail',
      'coverImage',
      'primary_image',
      'primaryImage'
    ]) {
      final v = product[k]?.toString() ?? '';
      if (v.trim().isNotEmpty) return _normalizeUrl(v);
    }

    // images array
    final imgs = product['images'];
    if (imgs is List) {
      for (final it in imgs) {
        if (it is String && it.trim().isNotEmpty) return _normalizeUrl(it);
      }
      for (final it in imgs) {
        if (it is Map) {
          for (final k in ['name', 'url', 'image', 'src', 'thumbnail']) {
            final v = it[k]?.toString() ?? '';
            if (v.trim().isNotEmpty) return _normalizeUrl(v);
          }
        }
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isDrawer) _closeSheet();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: isDrawer ? const Color(0xF2F7F7F5) : whiteColor,
        body: Column(
          children: [
            BackButtonAppbar(
              text: "Board",
              threeDot: true,
              icon: threeDotImage,
              backgroundColor: isDrawer ? const Color(0xF2F7F7F5) : whiteColor,
              onPressedThreeDot: _openSheet,
              onPressedShare: () async {
                final box = scaffoldKey.currentContext?.findRenderObject()
                    as RenderBox?;
                final shareOrigin = box != null
                    ? box.localToGlobal(Offset.zero) & box.size
                    : null;
                final link = await ShareLinkGenerator.generateBoardShareLink(
                  boardId: widget.boardId,
                  boardName: widget.boardName,
                );
                Share.share(
                  "Check out my wishlist board on Lafetch:\n$link",
                  sharePositionOrigin: shareOrigin,
                );
                await analytics.logEvent(
                  name: 'board_share_click',
                  parameters: {'page_name': 'board_share_click'},
                );
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Padding(
                      padding: EdgeInsets.only(
                          left: 16.sp, right: 16.sp, top: 10.sp),
                      child: AppText(
                        text: widget.boardName,
                        color: blackColor,
                        fontSize: 25,
                        fontFamily: "Clash Display Regular",
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    // Count + Grid
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: 16.sp, right: 16.sp, top: 0.sp),
                            child: AppText(
                              text: wishlistController.wishListProduct.isEmpty
                                  ? ""
                                  : wishlistController.wishListProduct.length ==
                                          1
                                      ? "1 item"
                                      : "${wishlistController.wishListProduct.length} items",
                              color: textHintColor,
                              fontSize: 12,
                              fontFamily: "Clash Display Regular",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          wishlistController.isDetails.value
                              ? const DummyGridList()
                              : wishlistController.wishListProduct.isNotEmpty
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.sp, vertical: 10.sp),
                                      child: GetBuilder<WishlistController>(
                                        builder: (ctrl) => GridView.count(
                                          shrinkWrap: true,
                                          crossAxisCount: 2,
                                          scrollDirection: Axis.vertical,
                                          padding: EdgeInsets.zero,
                                          childAspectRatio: 0.5,
                                          physics: const ScrollPhysics(),
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 0,
                                          children: List.generate(
                                            ctrl.wishListProduct.length,
                                            (index) {
                                              // Accept either product map or {id, product:{...}}
                                              final raw =
                                                  Map<String, dynamic>.from(
                                                ctrl.wishListProduct[index]
                                                    as Map,
                                              );
                                              final product =
                                                  Map<String, dynamic>.from(
                                                (raw['product'] is Map)
                                                    ? raw['product'] as Map
                                                    : raw,
                                              );

                                              final pid = (product['id'] is int)
                                                  ? product['id'] as int
                                                  : int.tryParse(
                                                          '${product['id']}') ??
                                                      0;

                                              // Availability: only unavailable if API explicitly marks it
                                              final bool isUnavailable = (product[
                                                          'is_deleted'] ==
                                                      true) ||
                                                  (product['inventory']
                                                          is Map &&
                                                      ((product['inventory']
                                                                  ['stocks'] ??
                                                              1) ==
                                                          0));

                                              final rawBrand =
                                                  product['brand_name'] ??
                                                      product['brand'];
                                              final brand = rawBrand is Map
                                                  ? (rawBrand['name'] ?? '')
                                                      .toString()
                                                  : (rawBrand ?? '').toString();
                                              final name = (product['name'] ??
                                                      product['title'] ??
                                                      '')
                                                  .toString();

                                              final num priceNum = _asNum(
                                                  product['price'] ??
                                                      product['basePrice'] ??
                                                      product['sellingAmount']);
                                              final num mrpNum = _asNum(product[
                                                      'mrp'] ??
                                                  product['compareAtPrice']);

                                              final String price = priceNum == 0
                                                  ? ''
                                                  : priceNum.toStringAsFixed(0);
                                              final String mrp = (mrpNum >
                                                          priceNum &&
                                                      mrpNum > 0)
                                                  ? mrpNum.toStringAsFixed(0)
                                                  : '';

                                              final cover =
                                                  _firstImage(product);

                                              return PounceWrapper(
                                                onTap: () async {
                                                  Get.to(() =>
                                                      ProductDetailsScreenV2(
                                                        brandName: brand,
                                                        productId: pid,
                                                        type: "add",
                                                      ));
                                                  await analytics.logEvent(
                                                    name:
                                                        'board_product_details',
                                                    parameters: {
                                                      'page_name':
                                                          'board_product_details'
                                                    },
                                                  );
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Image + remove
                                                    Stack(
                                                      children: [
                                                        Center(
                                                          child:
                                                              (cover.isNotEmpty)
                                                                  ? SizedBox(
                                                                      height: (MediaQuery.of(context).size.width /
                                                                              2) +
                                                                          10.sp,
                                                                      width: (MediaQuery.of(context).size.width /
                                                                              2) -
                                                                          24,
                                                                      child:
                                                                          CachedNetworkImage(
                                                                        cacheManager:
                                                                            CacheManager(
                                                                          Config(
                                                                            "customCacheKey",
                                                                            stalePeriod:
                                                                                const Duration(days: 15),
                                                                            maxNrOfCacheObjects:
                                                                                100,
                                                                          ),
                                                                        ),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        imageUrl:
                                                                            cover,
                                                                        errorWidget: (_,
                                                                                __,
                                                                                ___) =>
                                                                            Image.asset(
                                                                          downloadImage,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          height:
                                                                              (MediaQuery.of(context).size.width / 2) + 10.sp,
                                                                          width:
                                                                              (MediaQuery.of(context).size.width / 2) - 24,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Image.asset(
                                                                      dummyWishlistImage,
                                                                      height: (MediaQuery.of(context).size.width /
                                                                              2) +
                                                                          10.sp,
                                                                      width: (MediaQuery.of(context).size.width /
                                                                              2) -
                                                                          24,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                        ),
                                                        // Sold out overlay
                                                        if (isUnavailable)
                                                          Positioned.fill(
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .black
                                                                    .withValues(
                                                                        alpha:
                                                                            0.35),
                                                              ),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  horizontal:
                                                                      10.sp,
                                                                  vertical:
                                                                      4.sp,
                                                                ),
                                                                color: Colors
                                                                    .white
                                                                    .withValues(
                                                                        alpha:
                                                                            0.85),
                                                                child: Text(
                                                                  "Sold Out",
                                                                  style:
                                                                      TextStyle(
                                                                    color:
                                                                        colorPrimary,
                                                                    fontSize:
                                                                        11.sp,
                                                                    fontFamily:
                                                                        "Clash Display Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        // Per-item remove (product)
                                                        Positioned(
                                                          right: 12.sp,
                                                          top: 12.sp,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () async {
                                                              if (isDrawer) {
                                                                _closeSheet();
                                                                return;
                                                              }
                                                              final confirmed =
                                                                  await showDialog<
                                                                          bool>(
                                                                        context:
                                                                            context,
                                                                        barrierColor:
                                                                            Colors.black26,
                                                                        builder:
                                                                            (context) =>
                                                                                showDoubleBtnDailog(
                                                                          click1: () =>
                                                                              Get.back(result: false),
                                                                          click2: () =>
                                                                              Get.back(result: true),
                                                                          btncolor:
                                                                              colorPrimary,
                                                                          text:
                                                                              "Remove this from wishlist?",
                                                                          btn1Text:
                                                                              "No",
                                                                          btn2Text:
                                                                              "Yes",
                                                                        ),
                                                                      ) ??
                                                                      false;

                                                              if (confirmed) {
                                                                await wishlistController
                                                                    .removeProductFromBoard(
                                                                  widget
                                                                      .boardId,
                                                                  pid,
                                                                );
                                                                await wishlistController
                                                                    .fetchBoardProducts(
                                                                        widget
                                                                            .boardId);
                                                              }

                                                              await analytics
                                                                  .logEvent(
                                                                name:
                                                                    'remove_product_fromwishlistClick',
                                                                parameters: {
                                                                  'page_name':
                                                                      'remove_product_fromwishlistClick'
                                                                },
                                                              );
                                                            },
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  whiteColor,
                                                              radius: 12.sp,
                                                              child:
                                                                  Image.asset(
                                                                whiteCrossCircleImage,
                                                                height: 24.sp,
                                                                width: 24.sp,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    // Name
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.sp,
                                                              vertical: 5.sp),
                                                      child: AppText(
                                                        text: name,
                                                        color: nameText,
                                                        maxLines: 1,
                                                        fontSize: 12,
                                                        fontFamily:
                                                            "Clash Display",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),

                                                    // Brand
                                                    if (brand.isNotEmpty)
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.sp),
                                                        child: AppText(
                                                          text: brand,
                                                          color: nameText,
                                                          maxLines: 1,
                                                          fontSize: 11,
                                                          fontFamily:
                                                              "Clash Display Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),

                                                    // Price + MRP
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.sp,
                                                          left: 10.sp,
                                                          right: 1.sp),
                                                      child: Row(
                                                        children: [
                                                          if (price.isNotEmpty)
                                                            AppText(
                                                              text:
                                                                  "\u{20B9} $price",
                                                              color:
                                                                  deepGreytextColor,
                                                              maxLines: 2,
                                                              fontSize: 11,
                                                              fontFamily:
                                                                  "Clash Display",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          if (mrp.isNotEmpty)
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          5.sp),
                                                              child: Text(
                                                                "\u{20B9} $mrp",
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      textHintColor,
                                                                  fontSize:
                                                                      11.sp,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                  fontFamily:
                                                                      "Clash Display Regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),

                                                    SizedBox(height: 8.sp),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          top: 40.sp,
                                          left: 12.sp,
                                          right: 12.sp),
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
                                    ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
