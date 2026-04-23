part of 'product_details_screen_v2.dart';

extension PdpDialogs on _ProductDetailsScreenV2State {
  void _showBadgeSheet(String key) {
    final Map<String, Map<String, dynamic>> info = {
      'buyer': {
        'title': 'Buyer Protection',
        'icon': Icons.verified_outlined,
        'body':
            'Your purchase is fully protected. If your order does not arrive or is not as described, we will make it right with a replacement or refund if applicable.',
      },
      'auth': {
        'title': 'LaFetch Verified',
        'icon': Icons.security_outlined,
        'body':
            'Every product on LaFetch is sourced directly from trusted brands and verified sellers.',
      },
      'delivery': {
        'title': 'Quick Delivery',
        'icon': Icons.local_shipping_outlined,
        'body':
            'Get your products delivered quickly and safely to your doorstep.',
      },
      'returns': {
        'title': 'Easy Returns',
        'icon': Icons.assignment_return_outlined,
        'body':
            'Not happy with your purchase? Return it within 7 days of delivery. We will pick it up from your doorstep at no extra cost.',
      },
      'exchange': {
        'title': 'Exchange Policy',
        'icon': Icons.swap_horiz_outlined,
        'isImage': true,
        'image': 'assets/images/exchange_policy.png',
      },
    };

    final bool isImage = info[key]?['isImage'] == true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        /// 🔥 IMAGE SHEET (unchanged)
        if (isImage) {
          final data = info[key]!;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20.sp)),
                  child: Image.asset(
                    data['image'] as String,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: -40.sp,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(sheetContext),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 12,
                              spreadRadius: 1,
                              color: Colors.black.withOpacity(0.08),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        /// 🔥 TEXT SHEET (fixed)
        String selectedKey = key;

        return StatefulBuilder(
          builder: (context, setState) {
            final data = info[selectedKey]!;

            /// 👇 dynamic badge list (excludes exchange automatically)
            final textBadges = info.entries
                .where((e) => e.value['isImage'] != true)
                .map((e) => e.key)
                .toList();

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarDividerColor: Colors.transparent,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20.sp)),
                    ),
                    padding: EdgeInsets.fromLTRB(16.sp, 28.sp, 16.sp, 24.sp),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🔥 DYNAMIC CHIPS
                        Row(
                          children: textBadges.map((badgeKey) {
                            final badge = info[badgeKey]!;
                            final bool isSelected = badgeKey == selectedKey;

                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    selectedKey = badgeKey;
                                  });
                                },
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.sp),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 52.sp,
                                        height: 52.sp,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.grey.shade400,
                                            width: 1.2,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    blurRadius: 10,
                                                    color: Colors.black
                                                        .withOpacity(0.12),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Icon(
                                          badge['icon'] as IconData,
                                          size: 22.sp,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 6.sp),
                                      Text(
                                        badge['title'] as String,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: "Clash Display Regular",
                                          fontSize: 10.sp,
                                          color: Colors.black,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 20.sp),

                        /// 🔥 TITLE
                        Row(
                          children: [
                            Icon(data['icon'] as IconData, size: 22.sp),
                            SizedBox(width: 10.sp),
                            Expanded(
                              child: Text(
                                data['title'] as String,
                                style: TextStyle(
                                  fontFamily: "Clash Display",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.sp),

                        /// 🔥 BODY
                        Text(
                          data['body'] as String,
                          style: TextStyle(
                            fontFamily: "Clash Display Regular",
                            fontSize: 13.sp,
                            color: subtitleColor,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ❌ CLOSE BUTTON
                  Positioned(
                    top: -40.sp,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: whiteColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 12,
                                spreadRadius: 1,
                                color: Colors.black.withOpacity(0.08),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddReviewModal() {
    _selectedRating = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewBottomSheet(
        firstImg: _imagesOnly().isNotEmpty ? _imagesOnly().first : '',
        brandText: _brandText(),
        titleText: _titleText(),
        selectedRating: _selectedRating,
        onRatingChanged: (r) => _selectedRating = r,
        productController: productController,
        productId: widget.productId,
      ),
    );
  }

  // void _showAddReviewModal() {
  //   _selectedRating = 0;
  //   final localCtrl = TextEditingController();
  //   final firstImg = _imagesOnly().isNotEmpty ? _imagesOnly().first : '';
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) => StatefulBuilder(
  //         builder: (ctx, ss) => Container(
  //               height: MediaQuery.of(ctx).size.height * 0.85,
  //               decoration: BoxDecoration(
  //                   color: whiteColor,
  //                   borderRadius:
  //                       BorderRadius.vertical(top: Radius.circular(20.sp))),
  //               child: Column(children: [
  //                 Container(
  //                     margin: EdgeInsets.only(top: 12.sp),
  //                     width: 40.sp,
  //                     height: 4.sp,
  //                     decoration: BoxDecoration(
  //                         color: Colors.grey.shade300,
  //                         borderRadius: BorderRadius.circular(2.sp))),
  //                 Padding(
  //                     padding: EdgeInsets.all(16.sp),
  //                     child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Text('WRITE A REVIEW',
  //                               style: TextStyle(
  //                                   fontFamily: "Clash Display",
  //                                   fontWeight: FontWeight.w600,
  //                                   fontSize: 18.sp)),
  //                           IconButton(
  //                               icon: Icon(Icons.close, size: 24.sp),
  //                               onPressed: () => Get.back()),
  //                         ])),
  //                 const Divider(color: colorSecondary, height: 1),
  //                 Expanded(
  //                     child: SingleChildScrollView(
  //                         padding: EdgeInsets.all(16.sp),
  //                         child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Container(
  //                                   padding: EdgeInsets.all(12.sp),
  //                                   color: colorSecondary,
  //                                   child: Row(children: [
  //                                     ClipRRect(
  //                                         borderRadius:
  //                                             BorderRadius.circular(8.sp),
  //                                         child: firstImg.isNotEmpty
  //                                             ? CachedNetworkImage(
  //                                                 imageUrl: firstImg,
  //                                                 width: 80.sp,
  //                                                 height: 80.sp,
  //                                                 fit: BoxFit.cover,
  //                                                 errorWidget: (_, __, ___) =>
  //                                                     Image.asset(
  //                                                         dummyWishlistImage,
  //                                                         width: 80.sp,
  //                                                         height: 80.sp,
  //                                                         fit: BoxFit.cover))
  //                                             : Image.asset(dummyWishlistImage,
  //                                                 width: 80.sp,
  //                                                 height: 80.sp,
  //                                                 fit: BoxFit.cover)),
  //                                     SizedBox(width: 12.sp),
  //                                     Expanded(
  //                                         child: Column(
  //                                             crossAxisAlignment:
  //                                                 CrossAxisAlignment.start,
  //                                             children: [
  //                                           Text(_brandText().toUpperCase(),
  //                                               style: TextStyle(
  //                                                   fontFamily: "Clash Display",
  //                                                   fontWeight: FontWeight.w600,
  //                                                   fontSize: 12.sp,
  //                                                   color: blackColor)),
  //                                           SizedBox(height: 4.sp),
  //                                           Text(_titleText(),
  //                                               style: TextStyle(
  //                                                   fontFamily:
  //                                                       "Clash Display Regular",
  //                                                   fontSize: 12.sp,
  //                                                   color: subtitleColor),
  //                                               maxLines: 3,
  //                                               overflow:
  //                                                   TextOverflow.ellipsis),
  //                                         ])),
  //                                   ])),
  //                               SizedBox(height: 24.sp),
  //                               Text('Rate this product',
  //                                   style: TextStyle(
  //                                       fontFamily: "Clash Display",
  //                                       fontWeight: FontWeight.w600,
  //                                       fontSize: 14.sp)),
  //                               SizedBox(height: 12.sp),
  //                               Row(
  //                                   children: List.generate(
  //                                       5,
  //                                       (i) => GestureDetector(
  //                                             onTap: () => ss(() =>
  //                                                 _selectedRating = i + 1),
  //                                             child: Padding(
  //                                                 padding: EdgeInsets.only(
  //                                                     right: 8.sp),
  //                                                 child: Icon(
  //                                                     i < _selectedRating
  //                                                         ? Icons.star
  //                                                         : Icons.star_border,
  //                                                     size: 36.sp,
  //                                                     color: const Color(
  //                                                         0xFFFFB800))),
  //                                           ))),
  //                               SizedBox(height: 24.sp),
  //                               Text('Write your review',
  //                                   style: TextStyle(
  //                                       fontFamily: "Clash Display",
  //                                       fontWeight: FontWeight.w600,
  //                                       fontSize: 14.sp)),
  //                               SizedBox(height: 12.sp),
  //                               TextField(
  //                                   controller: localCtrl,
  //                                   maxLines: 6,
  //                                   maxLength: 500,
  //                                   decoration: InputDecoration(
  //                                     hintText: 'Share your thoughts...',
  //                                     counterText: "",
  //                                     filled: true,
  //                                     fillColor: colorSecondary,
  //                                     border: OutlineInputBorder(
  //                                         borderRadius:
  //                                             BorderRadius.circular(8.sp),
  //                                         borderSide: BorderSide.none),
  //                                     enabledBorder: OutlineInputBorder(
  //                                         borderRadius:
  //                                             BorderRadius.circular(8.sp),
  //                                         borderSide: BorderSide.none),
  //                                     focusedBorder: OutlineInputBorder(
  //                                         borderRadius:
  //                                             BorderRadius.circular(8.sp),
  //                                         borderSide: BorderSide(
  //                                             color: lightPurpleColor,
  //                                             width: 1.sp)),
  //                                     contentPadding: EdgeInsets.all(12.sp),
  //                                   ),
  //                                   style: TextStyle(
  //                                       fontFamily: "Clash Display Regular",
  //                                       fontSize: 13.sp,
  //                                       color: blackColor)),
  //                               SizedBox(height: 24.sp),
  //                             ]))),
  //                 Container(
  //                   width: double.infinity,
  //                   padding: EdgeInsets.all(16.sp),
  //                   decoration: BoxDecoration(color: whiteColor, boxShadow: [
  //                     BoxShadow(
  //                         color: Colors.black.withOpacity(0.05),
  //                         blurRadius: 10,
  //                         offset: const Offset(0, -2))
  //                   ]),
  //                   child: Obx(() {
  //                     final submitting =
  //                         productController.isSubmittingReview.value;
  //                     return ElevatedButton(
  //                       onPressed: submitting
  //                           ? null
  //                           : () async {
  //                               if (_selectedRating == 0) {
  //                                 showAppSnackBar('Please select a rating',
  //                                     type: SnackBarType.error);
  //                                 return;
  //                               }
  //                               if (localCtrl.text.trim().isEmpty) {
  //                                 showAppSnackBar('Please write a review',
  //                                     type: SnackBarType.error);
  //                                 return;
  //                               }
  //                               final nav = Navigator.of(ctx);
  //                               final prefs =
  //                                   await SharedPreferences.getInstance();
  //                               final userId = prefs.getInt('userId') ?? 0;
  //                               if (userId == 0) {
  //                                 showAppSnackBar(
  //                                     'Please login to submit a review',
  //                                     type: SnackBarType.error);
  //                                 return;
  //                               }
  //                               var variant =
  //                                   productController.getSelectedVariant();
  //                               if (variant == null &&
  //                                   productController
  //                                       .selectedVariants.isNotEmpty)
  //                                 variant =
  //                                     productController.selectedVariants.first;
  //                               final variantId = variant?['id'] ?? 0;
  //                               if (variantId == 0) {
  //                                 showAppSnackBar('Please select a size first',
  //                                     type: SnackBarType.error);
  //                                 return;
  //                               }
  //                               final success =
  //                                   await productController.submitProductReview(
  //                                       userId: userId,
  //                                       productId: widget.productId,
  //                                       orderItemId: 0,
  //                                       variantId: variantId,
  //                                       rating: _selectedRating,
  //                                       comment: localCtrl.text.trim());
  //                               if (success) {
  //                                 nav.pop();
  //                                 await productController
  //                                     .getProductReviews(widget.productId);
  //                               }
  //                             },
  //                       style: ElevatedButton.styleFrom(
  //                           backgroundColor:
  //                               submitting ? Colors.grey : blackColor,
  //                           shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(4.sp)),
  //                           minimumSize: Size(double.infinity, 48.sp),
  //                           elevation: 0),
  //                       child: Text(
  //                           submitting ? 'SUBMITTING...' : 'SUBMIT REVIEW',
  //                           style: TextStyle(
  //                               fontFamily: "Clash Display",
  //                               fontWeight: FontWeight.w600,
  //                               color: whiteColor,
  //                               fontSize: 14.sp,
  //                               letterSpacing: 0.5)),
  //                     );
  //                   }),
  //                 ),
  //               ]),
  //             )),
  //   ).then((_) => localCtrl.dispose());
  // }

  Future<void> _onBuyNow({required bool isCartFlow}) async {
    if (!productController.checkDetailsValidation()) return;
    final variant = productController.getSelectedVariant();
    if (variant == null) {
      showAppSnackBar('Please select size and color', type: SnackBarType.error);
      return;
    }
    final variantId = variant['id'] as int;
    final stock = int.tryParse((variant['inventories']?[0]?['availableStock'] ??
                    variant['availableStock'] ??
                    variant['stocks'] ??
                    variant['stock'])
                ?.toString() ??
            '0') ??
        0;
    if (stock <= 0) {
      showAppSnackBar('Selected variant is out of stock',
          type: SnackBarType.error);
      return;
    }
    final firstImg = _imagesOnly().isNotEmpty ? _imagesOnly().first : '';
    final sizeLabel =
        "${productController.selectedSize.value}${productController.selectedColor.value.isNotEmpty ? ' / ${productController.selectedColor.value}' : ''}";
    _showLoading();
    String? hsnCode;
    double? gstRate;
    double? statutoryGSTRate;
    String? gstRuleApplied;
    final pd = productController.productDetails;
    if (pd.isNotEmpty && pd["variants"] != null) {
      final variants = List<Map<String, dynamic>>.from(
          (pd["variants"] as List).whereType<Map>());
      final mv = variants.firstWhereOrNull((v) => v["id"] == variantId) ?? {};
      if (mv.isNotEmpty) {
        hsnCode = mv["hsn_code"]?.toString() ?? mv["hsnCode"]?.toString();
        gstRate = _extractDouble(mv["gst_rate"] ?? mv["gstRate"]);
        statutoryGSTRate = _extractDouble(mv["statutory_gst_rate"] ??
            mv["statutoryGSTRate"] ??
            mv["gst_rate"] ??
            mv["gstRate"]);
        gstRuleApplied =
            mv["gst_rule"]?.toString() ?? mv["gstRule"]?.toString();
      }
      if (hsnCode == null || hsnCode.isEmpty || gstRate == null) {
        hsnCode ??= pd["hsn_code"]?.toString() ?? pd["hsnCode"]?.toString();
        gstRate ??= _extractDouble(pd["gst_rate"] ?? pd["gstRate"]);
        statutoryGSTRate ??= _extractDouble(
                pd["statutory_gst_rate"] ?? pd["statutoryGSTRate"]) ??
            gstRate;
        gstRuleApplied ??=
            pd["gst_rule"]?.toString() ?? pd["gstRule"]?.toString();
      }
    }
    _hideLoading();
    hsnCode ??= "";
    gstRate ??= 0.0;
    statutoryGSTRate ??= gstRate;
    gstRuleApplied ??= "VALUE_BASED";
    Get.to(() => ReviewOrderScreen(
          productId: widget.productId,
          variantId: variantId,
          title: _titleText(),
          brandName: _brandText(),
          imageUrl: firstImg,
          sizeLabel: sizeLabel,
          quantity: _selectedQuantity,
          price: (productController.getDisplayPrice() * _selectedQuantity)
              .toDouble(),
          mrp: (productController.getDisplayMrp() * _selectedQuantity)
              .toDouble(),
          maxStock: stock,
          initialAddress:
              _addressSelected ? _addressResult as Map<String, dynamic>? : null,
          hsnCode: hsnCode,
          gstRate: gstRate,
          statutoryGSTRate: statutoryGSTRate,
          gstRuleApplied: gstRuleApplied,
        ));
  }
}

class _ReviewBottomSheet extends StatefulWidget {
  final String firstImg;
  final String brandText;
  final String titleText;
  final int selectedRating;
  final ValueChanged<int> onRatingChanged;
  final ProductController productController;
  final int productId;

  const _ReviewBottomSheet({
    required this.firstImg,
    required this.brandText,
    required this.titleText,
    required this.selectedRating,
    required this.onRatingChanged,
    required this.productController,
    required this.productId,
  });

  @override
  State<_ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<_ReviewBottomSheet> {
  late int _rating;
  bool _submitting = false;
  final TextEditingController _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rating = widget.selectedRating;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _setRating(int r) {
    if (!mounted) return;
    setState(() => _rating = r);
    widget.onRatingChanged(r);
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      showAppSnackBar('Please select a rating', type: SnackBarType.error);
      return;
    }
    if (_ctrl.text.trim().isEmpty) {
      showAppSnackBar('Please write a review', type: SnackBarType.error);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    if (userId == 0) {
      showAppSnackBar('Please login to submit a review',
          type: SnackBarType.error);
      return;
    }
    var variant = widget.productController.getSelectedVariant();
    if (variant == null &&
        widget.productController.selectedVariants.isNotEmpty) {
      variant = widget.productController.selectedVariants.first;
    }
    final variantId = variant?['id'] ?? 0;
    if (variantId == 0) {
      showAppSnackBar('Please select a size first', type: SnackBarType.error);
      return;
    }

    if (!mounted) return;
    setState(() => _submitting = true);

    final success = await widget.productController.submitProductReview(
      userId: userId,
      productId: widget.productId,
      orderItemId: 0,
      variantId: variantId,
      rating: _rating,
      comment: _ctrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      await widget.productController.getProductReviews(widget.productId);
    } else {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp))),
      child: Column(children: [
        Container(
            margin: EdgeInsets.only(top: 12.sp),
            width: 40.sp,
            height: 4.sp,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.sp))),
        Padding(
            padding: EdgeInsets.all(16.sp),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('WRITE A REVIEW',
                      style: TextStyle(
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp)),
                  IconButton(
                      icon: Icon(Icons.close, size: 24.sp),
                      onPressed: () => Get.back()),
                ])),
        const Divider(color: colorSecondary, height: 1),
        Expanded(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.all(12.sp),
                          color: colorSecondary,
                          child: Row(children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(8.sp),
                                child: widget.firstImg.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: widget.firstImg,
                                        width: 80.sp,
                                        height: 80.sp,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) =>
                                            Image.asset(dummyWishlistImage,
                                                width: 80.sp,
                                                height: 80.sp,
                                                fit: BoxFit.cover))
                                    : Image.asset(dummyWishlistImage,
                                        width: 80.sp,
                                        height: 80.sp,
                                        fit: BoxFit.cover)),
                            SizedBox(width: 12.sp),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(widget.brandText.toUpperCase(),
                                      style: TextStyle(
                                          fontFamily: "Clash Display",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.sp,
                                          color: blackColor)),
                                  SizedBox(height: 4.sp),
                                  Text(widget.titleText,
                                      style: TextStyle(
                                          fontFamily: "Clash Display Regular",
                                          fontSize: 12.sp,
                                          color: subtitleColor),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis),
                                ])),
                          ])),
                      SizedBox(height: 24.sp),
                      Text('Rate this product',
                          style: TextStyle(
                              fontFamily: "Clash Display",
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp)),
                      SizedBox(height: 12.sp),
                      Row(
                          children: List.generate(
                              5,
                              (i) => GestureDetector(
                                    onTap: () => _setRating(i + 1),
                                    child: Padding(
                                        padding: EdgeInsets.only(right: 8.sp),
                                        child: Icon(
                                            i < _rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 36.sp,
                                            color: const Color(0xFFFFB800))),
                                  ))),
                      SizedBox(height: 24.sp),
                      Text('Write your review',
                          style: TextStyle(
                              fontFamily: "Clash Display",
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp)),
                      SizedBox(height: 12.sp),
                      TextField(
                          controller: _ctrl,
                          maxLines: 6,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText: 'Share your thoughts...',
                            counterText: "",
                            filled: true,
                            fillColor: colorSecondary,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.sp),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.sp),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.sp),
                                borderSide: BorderSide(
                                    color: lightPurpleColor, width: 1.sp)),
                            contentPadding: EdgeInsets.all(12.sp),
                          ),
                          style: TextStyle(
                              fontFamily: "Clash Display Regular",
                              fontSize: 13.sp,
                              color: blackColor)),
                      SizedBox(height: 24.sp),
                    ]))),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(color: whiteColor, boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2))
          ]),
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
                backgroundColor: _submitting ? Colors.grey : blackColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.sp)),
                minimumSize: Size(double.infinity, 48.sp),
                elevation: 0),
            child: Text(_submitting ? 'SUBMITTING...' : 'SUBMIT REVIEW',
                style: TextStyle(
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w600,
                    color: whiteColor,
                    fontSize: 14.sp,
                    letterSpacing: 0.5)),
          ),
        ),
      ]),
    );
  }
}
