part of 'product_details_screen_v2.dart';

extension PdpDeliverySection on _ProductDetailsScreenV2State {
  Widget _buildDelivery() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppSpacingText(
          text: 'Delivery Options'.toUpperCase(),
          fontFamily: "Clash Display",
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontSize: 14,
        ),
        SizedBox(height: 12.sp),
        SizedBox(
          height: 44.sp,
          child: TextField(
            controller: productController.pincodeController,
            focusNode: _pincodeFocusNode,
            autofocus: false,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: whiteColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.sp),
              hintText: "Enter pincode",
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: textHintColor,
                fontFamily: "Clash Display",
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: borderColor),
                borderRadius: BorderRadius.circular(4.sp),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: borderColor),
                borderRadius: BorderRadius.circular(4.sp),
              ),
              suffixIcon: TextButton(
                onPressed: () async {
                  final pin = productController.pincodeController.text.trim();
                  if (!productController.checkPinvalidation(pin)) {
                    productController.serviceabilityMessage.value =
                        "Enter valid pincode";
                    return;
                  }

                  final variant = productController.getSelectedVariant();
                  if (variant == null) {
                    final hasSizes =
                        productController.sizeInventoryList.isNotEmpty;
                    final hasColors =
                        productController.colorInventoryList.isNotEmpty;
                    final sizeSelected =
                        productController.selectedSize.value.isNotEmpty;
                    final colorSelected =
                        productController.selectedColor.value.isNotEmpty;

                    String errorMsg = "Please select ";
                    if (hasSizes && !sizeSelected) {
                      errorMsg += "size";
                      if (hasColors) errorMsg += " and color";
                    } else if (hasColors && !colorSelected) {
                      errorMsg += "color";
                    } else {
                      errorMsg = "Product variant not available";
                    }

                    productController.serviceabilityMessage.value = errorMsg;
                    return;
                  }

                  final variantId = variant['id'] as int? ?? 0;
                  if (variantId == 0) {
                    productController.serviceabilityMessage.value =
                        "Invalid variant selected";
                    return;
                  }

                  productController.serviceabilityMessage.value = "";
                  productController.isServiceable.value = false;
                  productController.courierName.value = "";
                  productController.estimatedDate.value = "";
                  productController.estimatedDays.value = "";

                  final result = await productController.checkServiceability(
                    variantId: variantId,
                    deliveryPostalCode: pin,
                  );

                  if (result != null && result["data"] is Map) {
                    final data = result["data"];
                    productController.courierName.value =
                        data["courier"]?.toString() ?? "";
                    productController.estimatedDate.value =
                        data["estimatedDate"]?.toString() ?? "";
                    productController.estimatedDays.value =
                        data["estimatedDays"]?.toString() ?? "";
                    productController.isServiceable.value = true;
                    productController.serviceabilityMessage.value =
                        "Delivery by ${productController.estimatedDate.value} (${productController.estimatedDays.value} Days)";
                  } else {
                    productController.serviceabilityMessage.value =
                        "Service not available for this pincode";
                  }
                },
                child: Text(
                  "Check",
                  style: TextStyle(
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w600,
                    color: lightPurpleColor,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.sp),
        Obx(() {
          if (productController.serviceabilityMessage.value.isEmpty) {
            return const SizedBox();
          }
          final isSuccess = productController.isServiceable.value;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: isSuccess ? Colors.green : const Color(0xFFD63333),
                size: 16.sp,
              ),
              SizedBox(width: 8.sp),
              Expanded(
                child: Text(
                  productController.serviceabilityMessage.value,
                  style: TextStyle(
                    fontFamily: "Clash Display Regular",
                    fontSize: 12.sp,
                    color: isSuccess ? Colors.green : const Color(0xFFD63333),
                  ),
                ),
              ),
            ],
          );
        }),
      ]),
    );
  }

  Widget _buildActionButtons() => Obx(() {
        if (productController.isDetails.value) return const SizedBox();
        final bottomInset = MediaQuery.of(context).padding.bottom;
        
        // ✅ Phase 3.7 & 3.8: Get button states based on stock status
        final addToBagState = OutOfStockButtonState.addToCart(
          isOutOfStock: productController.isOutOfStock.value,
        );
        final buyNowState = OutOfStockButtonState.buyNow(
          isOutOfStock: productController.isOutOfStock.value,
        );
        
        return Padding(
          padding: EdgeInsets.only(
            left: 16.sp,
            right: 16.sp,
            top: 8.sp,
            bottom: 8.sp + bottomInset,
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48.sp,
                child: ElevatedButton(
                  onPressed: addToBagState.isDisabled ? null : () async {
                    if (!productController.checkDetailsValidation()) return;
                    final variant = productController.getSelectedVariant();
                    if (variant == null) {
                      showAppSnackBar('Please select size and color',
                          type: SnackBarType.error);
                      return;
                    }
                    final variantId = variant['id'] as int;
                    final variantPrice =
                        ((variant['lfMsp'] ?? variant['price'] ?? 0) as num)
                            .toDouble();
                    await cartController.addToCartUniversal(
                        quantity: _selectedQuantity,
                        page: "addproduct",
                        variantId: variantId,
                        productId: widget.productId,
                        expressValue: widget.expressValue,
                        type: 1,
                        backColor: whiteColor,
                        oldInventoryId: variantId,
                        price: variantPrice);
                    EventTrackingService.instance
                        .trackAddToCart(widget.productId, variantId);
                    setState(() => _selectedQuantity = 1);
                    await analytics.logEvent(
                        name: 'productDetails_btnaddtocart',
                        parameters: {
                          'page_name': 'productDetails_btnaddtocart'
                        });
                    await Future.delayed(const Duration(milliseconds: 300));
                    Get.to(const CartScreen())?.then((_) =>
                        productController.getProductById(widget.productId));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: addToBagState.backgroundColor,
                    side: BorderSide(
                      color: addToBagState.borderColor ?? blackColor,
                      width: 2.sp,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.sp)),
                    elevation: 0,
                  ),
                  child: Opacity(
                    opacity: addToBagState.opacity,
                    child: Text(addToBagState.label,
                        style: TextStyle(
                            fontFamily: "Clash Display",
                            fontWeight: FontWeight.w600,
                            color: addToBagState.textColor,
                            fontSize: 13.sp)),
                  ),
                ),
              ),
              SizedBox(height: 12.sp),
              // ✅ Phase 3.8: Hide Buy Now button when out of stock
              if (buyNowState.isVisible)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48.sp,
                        child: ElevatedButton(
                          onPressed: buyNowState.isDisabled ? null : () async {
                            await _onBuyNow(isCartFlow: false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buyNowState.backgroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.sp),
                                side: BorderSide(
                                  color: buyNowState.borderColor ?? blackColor,
                                  width: 2.sp,
                                )),
                            elevation: 0,
                          ),
                          child: Opacity(
                            opacity: buyNowState.opacity,
                            child: Text(buyNowState.label,
                                style: TextStyle(
                                    fontFamily: "Clash Display",
                                    fontWeight: FontWeight.w600,
                                    color: buyNowState.textColor,
                                    fontSize: 13.sp)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      });

  Widget _buildOfferSection() => const SizedBox();
}
