// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'cartscreen.dart';
import 'searchscreen.dart';
import 'wishlist/boardscreen.dart';
import 'wishlist/newboardscreen.dart';

import '../common/widget/appbar/productlist_appbar.dart';
import '../common/widget/button/singlebtn.dart';
import '../common/widget/lists/dummy_wishlist_list.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../core/constant/constants.dart';

class WishlistScreen extends StatefulWidget {
  final Function? onPressed;

  const WishlistScreen({this.onPressed, super.key});

  @override
  State<WishlistScreen> createState() => WishlistScreenState();
}

class WishlistScreenState extends State<WishlistScreen> {
  final wishlistController = Get.put(WishlistController());
  final cartController = Get.put(CartController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        systemNavigationBarColor: statusBarColor,
      ));

      // reset/paging flags for a fresh load
      wishlistController.hasnextpage.value = true;
      wishlistController.loadMore.value = false;
      wishlistController.isWishlist.value = false;
      wishlistController.page.value = 1;

      // new API: fetch all boards for the user
      wishlistController.listBoardsForUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          ProductAppbar(
            text: "Wishlist",
            onPressedSearch: () async {
              Get.to(() => SearchScreen())?.then((_) => setState(() {}));
              analytics.logEvent(
                name: "search_page",
                parameters: {"page_name": "search_page"},
              );
            },
            isHandPicked: true,
            isWishlist: false,
            onPressedCart: () async {
              Get.to(() => CartScreen())?.then((_) {
                setState(() {
                  cartController.getCartData();
                });
              });
              analytics.logEvent(
                name: "cart_page",
                parameters: {"page_name": "cart_page"},
              );
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: wishlistController.wishlistListController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(top: 20.sp, left: 16.sp, right: 16.sp),
                    child: AppText(
                      text: "Wishlist",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: blackColor,
                      fontSize: 25,
                    ),
                  ),
                  Obx(() {
                    if (wishlistController.isWishlist.value) {
                      return const DummyWishlistList();
                    } else if (wishlistController.wishlistList.isEmpty) {
                      return _buildEmptyWishlist(context);
                    } else {
                      return _buildWishlistGrid(context);
                    }
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Empty State ----------
  Widget _buildEmptyWishlist(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.sp, left: 16.sp, right: 16.sp),
          child: _buildNewBoardRow(),
        ),
        SizedBox(height: 50.sp),
        Image.asset(emptyBoxImage, height: 160.sp, width: 196.sp),
        Padding(
          padding: EdgeInsets.only(top: 40.sp, left: 16.sp, right: 16.sp),
          child: AppText(
            text: "Your Wishlist is empty",
            fontFamily: "Franklin Gothic",
            fontWeight: FontWeight.w500,
            color: colorPrimary,
            fontSize: 22,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: 20.sp, left: 16.sp, right: 16.sp, bottom: 20.sp),
          child: AppText(
            text:
                "Add products to your wishlist, review them anytime and easily move to cart",
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.w400,
            maxLines: 2,
            textAlign: TextAlign.center,
            color: nameText,
            fontSize: 14,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.sp),
          child: SingleButton(
            label: "Continue Shopping",
            textColor: btnTextColor,
            backgroundColor: whiteColor,
            onPressed: () {
              widget.onPressed?.call();
            },
            borderColor: btnTextColor,
          ),
        ),
      ],
    );
  }

  // ---------- Boards Grid ----------
  Widget _buildWishlistGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.sp, left: 16.sp, right: 16.sp),
          child: _buildNewBoardRow(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.zero,
            childAspectRatio: 0.7,
            physics:
                const NeverScrollableScrollPhysics(), // ✅ prevent nested scroll conflict
            crossAxisSpacing: 5,
            mainAxisSpacing: 0,
            children: List.generate(
              wishlistController.wishlistList.length,
              (index) {
                final item = Map<String, dynamic>.from(
                    wishlistController.wishlistList[index] as Map);

                final boardName = (item["name"] ?? "").toString();
                final boardId = item["id"];
                final count =
                    int.tryParse((item["productCount"] ?? '0').toString()) ?? 0;

                final coverUrl = _boardCoverFromItem(item);

                return GestureDetector(
                  onTap: () async {
                    await Get.to(() => BoardScreen(
                          boardName: boardName,
                          boardId: boardId is int
                              ? boardId
                              : int.tryParse('$boardId') ?? 0,
                          productId: 0,
                        ));
                    // refresh boards after coming back
                    wishlistController.hasnextpage.value = true;
                    wishlistController.loadMore.value = false;
                    wishlistController.isWishlist.value = false;
                    wishlistController.page.value = 1;
                    wishlistController.listBoardsForUser();

                    await analytics.logEvent(
                      name: 'wishlist_click',
                      parameters: {'page_name': 'wishlist_click'},
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0.sp),
                          child: (coverUrl != null && coverUrl.isNotEmpty)
                              ? SizedBox(
                                  height:
                                      (MediaQuery.of(context).size.width / 2) -
                                          24.sp,
                                  width:
                                      (MediaQuery.of(context).size.width / 2) -
                                          24.sp,
                                  child: CachedNetworkImage(
                                    cacheManager: CacheManager(
                                      Config(
                                        "wishlistBoardCovers",
                                        stalePeriod: const Duration(days: 15),
                                        maxNrOfCacheObjects: 120,
                                      ),
                                    ),
                                    fit: BoxFit.cover,
                                    imageUrl: coverUrl,
                                    placeholder: (_, __) => Container(
                                      color: const Color(0xFFEFF1F3),
                                    ),
                                    errorWidget: (_, __, ___) => Image.asset(
                                      dummyWishlistImage,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  dummyWishlistImage,
                                  height:
                                      (MediaQuery.of(context).size.width / 2) -
                                          24.sp,
                                  width:
                                      (MediaQuery.of(context).size.width / 2) -
                                          24.sp,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.sp, vertical: 5.sp),
                          child: AppText(
                            text: boardName,
                            color: blackColor,
                            fontSize: 16,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.sp),
                          child: AppText(
                            text: "$count ${count == 1 ? 'item' : 'items'}",
                            color: textHintColor,
                            fontSize: 12,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        wishlistController.loadMore.value
            ? const DummyWishlistList()
            : const SizedBox(height: 0),
      ],
    );
  }

  // ---------- Helpers ----------
  bool _isImageUrl(String? u) {
    if (u == null || u.trim().isEmpty) return false;
    final p = Uri.tryParse(u)?.path.toLowerCase() ?? u.toLowerCase();
    return p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.png') ||
        p.endsWith('.webp') ||
        p.endsWith('.gif');
  }

  String _normalizeUrl(String u) {
    if (u.startsWith('//')) return 'https:$u';
    return u;
  }

  String? _firstImageFromProduct(Map<String, dynamic> p) {
    final iu = p['imageUrls'];
    if (iu is List) {
      for (final x in iu) {
        if (x is String && _isImageUrl(x)) return _normalizeUrl(x);
      }
      if (iu.isNotEmpty && iu.first is String) {
        return _normalizeUrl(iu.first as String);
      }
    }

    final imgs = p['images'];
    if (imgs is List) {
      for (final it in imgs) {
        if (it is String && _isImageUrl(it)) return _normalizeUrl(it);
        if (it is Map) {
          for (final k in const ['name', 'url', 'image', 'src', 'thumbnail']) {
            final v = (it[k] ?? '').toString();
            if (v.isNotEmpty && _isImageUrl(v)) return _normalizeUrl(v);
          }
        }
      }
    }
    return null;
  }

// Replace your existing _boardCoverFromItem method with this updated version
// that prioritizes the last product's image

  String? _boardCoverFromItem(Map<String, dynamic> item) {
    // First check explicit cover fields
    for (final k in const ['cover', 'coverImage', 'image', 'thumbnail']) {
      final v = (item[k] ?? '').toString();
      if (_isImageUrl(v)) return _normalizeUrl(v);
    }

    // Check for lastProduct or recentProduct first (PRIORITY)
    for (final key in const ['lastProduct', 'recentProduct']) {
      if (item[key] is Map) {
        final u =
            _firstImageFromProduct(Map<String, dynamic>.from(item[key] as Map));
        if (u != null && u.isNotEmpty) return u;
      }
    }

    // Check products array - USE LAST PRODUCT instead of first
    final products = item['products'];
    if (products is List && products.isNotEmpty) {
      final last =
          products.last; // Changed from products.first to products.last
      Map<String, dynamic>? prod;

      if (last is Map) {
        if (last['product'] is Map) {
          prod = Map<String, dynamic>.from(last['product'] as Map);
        } else {
          prod = Map<String, dynamic>.from(last);
        }
      }

      if (prod != null) {
        final u = _firstImageFromProduct(prod);
        if (u != null && u.isNotEmpty) return u;
      }
    }

    return null;
  }

  // ---------- Header Row ("New Board") ----------
  Widget _buildNewBoardRow() {
    return GestureDetector(
      onTap: () async {
        final result = await Get.to(() => const NewBoardScreen(
              title: "New Board",
              boardId: 0,
              productId: 0,
              hintName: "Name of the Board",
              boardName: "",
              btnText: "Next",
            ));

        if (result != null && result is Map<String, dynamic>) {
          final boardId = result["boardId"];
          final boardName = result["boardName"];

          if (boardId != null && boardName != null) {
            Get.off(() => BoardScreen(
                  boardId:
                      boardId is int ? boardId : int.tryParse('$boardId') ?? 0,
                  boardName: boardName.toString(),
                  productId: 0,
                ));
          }
        }

        wishlistController.hasnextpage.value = true;
        wishlistController.loadMore.value = false;
        wishlistController.isWishlist.value = false;
        wishlistController.page.value = 1;
        wishlistController.listBoardsForUser();

        await analytics.logEvent(
          name: 'create_board',
          parameters: {'page_name': 'create_board'},
        );
      },
      child: Row(
        children: [
          AppText(
            text: wishlistController.totalBoard.value == 1
                ? "${wishlistController.totalBoard.value} board"
                : "${wishlistController.totalBoard.value} boards",
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.w400,
            color: textHintColor,
            fontSize: 12,
          ),
          const Expanded(child: SizedBox()),
          Icon(Icons.add, color: blackColor, size: 16.sp),
          Padding(
            padding: EdgeInsets.only(left: 5.sp),
            child: AppText(
              text: "New Board",
              color: blackColor,
              fontSize: 12,
              fontFamily: "Franklin Gothic Bold",
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
