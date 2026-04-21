part of 'product_details_screen_v2.dart';

extension PdpImageSection on _ProductDetailsScreenV2State {
  Future<void> _navigateToCrumb(String name) async {
    if (name.isEmpty) return;

    // "Home" goes straight to the homepage — no search
    if (name.toLowerCase() == 'home') {
      Get.offAll(() => const BottomNavScreen(index: 0));
      return;
    }

    // All other crumbs: run the search, then land on results
    final searchCtrl = Get.put(SearchScreenController());
    searchCtrl.searchController.text = name;
    searchCtrl.resetFilters();

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    await searchCtrl.getSearchData();

    if (Get.isDialogOpen ?? false) Get.back();

    final items = searchCtrl.searchList;
    if (items.isEmpty) {
      showAppSnackBar("No products found for '$name'", type: SnackBarType.info);
      return;
    }

    Get.to(() => SearchResultsScreen(
          searchQuery: name,
          searchResults: items,
        ));
  }

  Widget _buildBreadcrumb() => Obx(() {
        if (productController.isBreadcrumbLoading.value) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 6.sp),
            child: const DummyContainer(height: 20, width: 200),
          );
        }
        final crumbs = productController.breadcrumbList;
        final List<Widget> children = [];
        for (int i = 0; i < crumbs.length; i++) {
          if (i > 0) {
            children.add(Text(
              ' › ',
              style: TextStyle(
                fontFamily: "Clash Display Regular",
                fontSize: 12.sp,
                color: subtitleColor,
              ),
            ));
          }
          final crumb = crumbs[i];
          final crumbName = crumb['name']?.toString() ?? '';
          final displayName = crumbName.length > 12
              ? '${crumbName.substring(0, 12)}…'
              : crumbName;
          children.add(GestureDetector(
            onTap: () => _navigateToCrumb(crumbName),
            child: Text(
              displayName,
              style: TextStyle(
                fontFamily: "Clash Display Regular",
                fontSize: 12.sp,
                color: subtitleColor,
              ),
            ),
          ));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 6.sp),
          child: Row(children: children),
        );
      });

  Widget _buildThumb(List<String> imgs, int i, bool isActive,
      {double? size, EdgeInsets margin = EdgeInsets.zero}) {
    return GestureDetector(
      onTap: () => _pageController.animateToPage(i,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: size ?? 56.sp,
        width: size,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.sp),
          border: Border.all(
            color: isActive ? blackColor : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.sp),
          child: Opacity(
            opacity: isActive ? 1.0 : 0.55,
            child: CachedNetworkImage(imageUrl: imgs[i], fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildImages() => Obx(() {
        if (_isForeground && productController.isDetails.value) {
          return const DummyProductImage();
        }
        final imgs = _imagesOnly();
        return Column(children: [
          Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.54,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) {
                    setState(() => _curr = i);
                  },
                  itemCount: imgs.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () {
                      final gallery = imgs
                          .map((u) => {'name': u, 'isVideo': false})
                          .toList();
                      Get.to(() => ProductImage_Screen(curr: i, list: gallery));
                    },
                    child: Hero(
                        tag: imgs[i],
                        child: CachedNetworkImage(
                          cacheManager: CacheManager(Config("customCacheKey",
                              stalePeriod: const Duration(days: 15),
                              maxNrOfCacheObjects: 100)),
                          fit: BoxFit.cover,
                          imageUrl: imgs[i],
                          width: double.infinity,
                          height: double.infinity,
                          progressIndicatorBuilder: (_, __, ___) =>
                              DummyContainer(
                                  height:
                                      MediaQuery.of(context).size.height * 0.54,
                                  width: MediaQuery.of(context).size.width),
                          errorWidget: (_, __, ___) =>
                              Image.asset(downloadImage, fit: BoxFit.cover),
                        )),
                  ),
                ),
              ),
              // Wishlist overlay — bottom right
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    if (prefs.getBool('skip') ?? false) {
                      showAppSnackBar("Please login to add to wishlist",
                          type: SnackBarType.error);
                      Get.toNamed('/login');
                      return;
                    }
                    final productId =
                        (productController.productDetails["id"] as int?) ??
                            widget.productId;

                    if (wishlistController.isWishlisted.value) {
                      // --- REMOVE from wishlist ---
                      int boardId = 0;
                      for (final board in wishlistController.wishlistList) {
                        final bId = board['id'] as int? ?? 0;
                        if (bId == 0) continue;
                        final products = await wishlistController
                            .fetchBoardProducts(bId, silent: true);
                        final found = products.any((p) {
                          final prod = p['product'] as Map<String, dynamic>?;
                          return prod?['id']?.toString() ==
                              productId.toString();
                        });
                        if (found) {
                          boardId = bId;
                          break;
                        }
                      }
                      if (boardId != 0) {
                        await wishlistController.removeProductFromBoard(
                            boardId, productId);
                      } else {
                        wishlistController.isWishlisted.value = false;
                        wishlistController.wishListDetails["wishlisted"] =
                            false;
                      }
                    } else {
                      // --- ADD to wishlist ---
                      final firstImg = productController.imageList.isNotEmpty
                          ? (productController.imageList.first['name']
                                  ?.toString() ??
                              '')
                          : '';
                      scaffoldKey.currentState
                          ?.showBottomSheet((ctx) => BottomWishlist(
                                controller: wishlistController,
                                wishlistList: wishlistController.wishlistList,
                                productImage: firstImg,
                                onPressedBoard: () {
                                  Get.back();
                                  Get.to(() => NewBoardScreen(
                                      title: "New Board",
                                      boardName: "",
                                      hintName: "Enter board name",
                                      boardId: 0,
                                      btnText: "Next",
                                      productId: productId,
                                      categoryId: 0,
                                      screen: ""));
                                },
                                onPressed: (boardId) async {
                                  final price = ((productController
                                              .productDetails['lfMsp'] ??
                                          0) as num)
                                      .toDouble();
                                  await wishlistController.addProductToBoard(
                                      boardId, productId,
                                      price: price);
                                  Get.back();
                                  final boardName = wishlistController
                                          .wishlistList
                                          .firstWhere((b) => b['id'] == boardId,
                                              orElse: () =>
                                                  {'name': 'Board'})['name']
                                          ?.toString() ??
                                      'Board';
                                  Get.to(() => BoardScreen(
                                      boardName: boardName,
                                      boardId: boardId,
                                      productId: productId));
                                },
                              ));
                    }
                  },
                  child: Container(
                    height: 40.sp,
                    width: 40.sp,
                    decoration: BoxDecoration(
                      color: whiteColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          color: Colors.black.withOpacity(0.12),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Obx(() => Icon(
                            wishlistController.isWishlisted.value
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: wishlistController.isWishlisted.value
                                ? const Color(0xFFD63333)
                                : blackColor,
                            size: 20.sp,
                          )),
                    ),
                  ),
                ),
              ),
              // See Similar pill — top right, left of share button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _scrollToSimilar,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.sp, vertical: 10.sp),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          color: Colors.black.withOpacity(0.12),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 18.sp, color: blackColor),
                      ],
                    ),
                  ),
                ),
              ),
              // Share overlay — top right
              Positioned(
                top: 10,
                right: 60,
                child: GestureDetector(
                  onTap: () async {
                    try {
                      final link = await _shareLink();
                      final title = _titleText();
                      Share.share(
                        title.isNotEmpty
                            ? "Check out $title on LaFetch!\n$link"
                            : "Check this product on LaFetch!\n$link",
                      );
                    } catch (_) {
                      Share.share(_titleText().isNotEmpty
                          ? _titleText()
                          : "Check this product");
                    }
                  },
                  child: Container(
                    height: 40.sp,
                    width: 40.sp,
                    decoration: BoxDecoration(
                      color: whiteColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          color: Colors.black.withOpacity(0.12),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        shareSvgImage,
                        height: 18.sp,
                        width: 18.sp,
                        colorFilter: const ColorFilter.mode(
                            Colors.black, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (imgs.length > 1)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
              child: imgs.length <= 3
                  // 2-3 images: spread evenly across the width
                  ? Row(
                      children: List.generate(imgs.length, (i) {
                        final isActive = i == _curr;
                        return Expanded(
                          child: _buildThumb(imgs, i, isActive,
                              margin: i < imgs.length - 1
                                  ? EdgeInsets.only(right: 4.sp)
                                  : EdgeInsets.zero),
                        );
                      }),
                    )
                  // 4+ images: fixed 56sp squares, scrollable
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(imgs.length, (i) {
                          final isActive = i == _curr;
                          return _buildThumb(imgs, i, isActive,
                              size: 56.sp,
                              margin: EdgeInsets.only(
                                  right: i < imgs.length - 1 ? 4.sp : 0));
                        }),
                      ),
                    ),
            ),
        ]);
      });
}
