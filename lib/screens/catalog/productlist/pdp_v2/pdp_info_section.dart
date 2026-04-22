part of 'product_details_screen_v2.dart';

extension PdpInfoSection on _ProductDetailsScreenV2State {
  Widget _buildProductInfoAndPrice() => Obx(() {
        if (_isForeground && productController.isDetails.value) {
          return const DummyProductDetails();
        }
        return Padding(
            padding: EdgeInsets.only(
                left: 16.sp, right: 12.sp, top: 8.sp, bottom: 4.sp),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_titleText(),
                  style: TextStyle(
                      fontFamily: "Clash Display",
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp)),
              SizedBox(height: 4.sp),
              if (_brandText().isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    final brandId = productController.productDetails["brand"]
                            ?["id"] as int? ??
                        0;
                    if (brandId > 0) {
                      Get.to(() => AllBrandScreen(
                          id: brandId,
                          screen: 'brand',
                          slug:
                              '${productController.productDetails["brand"]?["slug"] ?? ''}'));
                    }
                  },
                  child: Text(_brandText().toUpperCase(),
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontFamily: "Clash Display Regular",
                          fontSize: 14.sp,
                          color: subtitleColor)),
                ),
              SizedBox(height: 4.sp),
              Obx(() => ProductPriceDisplay(
                    price: productController.getDisplayPrice(),
                    mrp: productController.getDisplayMrp() >
                            productController.getDisplayPrice()
                        ? productController.getDisplayMrp()
                        : null,
                    fontSize: 18,
                    mrpFontSize: 16,
                    discountFontSize: 12,
                    fontWeight: FontWeight.bold,
                    priceColor: blackColor,
                    mrpColor: searchTextColor,
                    spacing: 10,
                  )),
              Text('Price inclusive of all taxes',
                  style: TextStyle(color: lightPurpleColor, fontSize: 10.sp)),
            ]));
      });

  Widget _buildTrustBadges() => Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: Wrap(
        spacing: 8.sp,
        runSpacing: 8.sp,
        children: [
          _trustChip(Icons.verified_outlined, 'Buyer Protection',
              () => _showBadgeSheet('buyer')),
          _trustChip(Icons.security_outlined, 'LaFetch Verified',
              () => _showBadgeSheet('auth')),
          _trustChip(Icons.local_shipping_outlined, 'Quick Delivery',
              () => _showBadgeSheet('returns')),
          _trustChip(Icons.assignment_return_outlined, 'Easy Returns',
              () => _showBadgeSheet('returns')),
          _trustChip(Icons.swap_horiz_outlined, 'Exchange Policy',
              () => _showBadgeSheet('exchange')),
        ],
      ));

  Widget _trustChip(IconData ic, String lbl, VoidCallback tap) =>
      GestureDetector(
          onTap: tap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(20.sp),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(ic, size: 14.sp, color: blackColor),
              SizedBox(width: 5.sp),
              Text(lbl,
                  style: TextStyle(
                      fontFamily: "Clash Display Regular",
                      fontSize: 11.sp,
                      color: blackColor)),
              SizedBox(width: 5.sp),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 8.sp, color: blackColor),
            ]),
          ));
}
