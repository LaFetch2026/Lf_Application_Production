part of 'product_details_screen_v2.dart';

extension PdpSizeSection on _ProductDetailsScreenV2State {
  Widget _buildSizeColorSection() => Obx(() {
        final hasSizes = productController.sizeInventoryList.isNotEmpty;
        final hasColors = productController.colorInventoryList.isNotEmpty;
        if (!hasSizes && !hasColors) return const SizedBox();
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (hasSizes) ...[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SELECT SIZE',
                          style: TextStyle(
                              fontFamily: "Clash Display",
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp)),
                      GestureDetector(
                        onTap: () {
                          _openSizeChart();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.sp, vertical: 6.sp),
                          decoration: BoxDecoration(
                              border: Border.all(color: lightPurpleColor),
                              borderRadius: BorderRadius.circular(20.sp)),
                          child: Text('Size Chart',
                              style: TextStyle(
                                  fontFamily: "Clash Display Regular",
                                  color: lightPurpleColor,
                                  fontSize: 12.sp)),
                        ),
                      ),
                    ]),
                SizedBox(height: 8.sp),
                GestureDetector(
                  onTap: _showSizeBottomSheet,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.sp, vertical: 14.sp),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: productController.errorSizeMsg.value.isNotEmpty
                              ? deepRed
                              : borderColor),
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            productController.selectedSize.value.isEmpty
                                ? 'Choose size'
                                : productController.selectedSize.value,
                            style: TextStyle(
                                fontFamily: "Clash Display Regular",
                                fontSize: 14.sp,
                                color:
                                    productController.selectedSize.value.isEmpty
                                        ? textHintColor
                                        : blackColor),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              color: blackColor, size: 22.sp),
                        ]),
                  ),
                ),
                if (productController.errorSizeMsg.value.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 6.sp),
                    child: ShakeWidget(
                      trigger: productController.sizeShakeTrigger.value,
                      child: Text(productController.errorSizeMsg.value,
                          style: TextStyle(
                              fontFamily: "Clash Display Regular",
                              fontSize: 12.sp,
                              color: deepRed)),
                    ),
                  ),
                SizedBox(height: 12.sp),
              ],
              if (hasColors &&
                  (!hasSizes ||
                      productController.selectedSize.value.isNotEmpty)) ...[
                Text('SELECT COLOR',
                    style: TextStyle(
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp)),
                SizedBox(height: 8.sp),
                _styledDropdown<String>(
                  value: productController.selectedColor.value.isEmpty
                      ? null
                      : productController.selectedColor.value,
                  hint: 'Choose color',
                  hasError: productController.errorColorMsg.value.isNotEmpty,
                  items: productController.colorInventoryList
                      .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c,
                              style: TextStyle(
                                  fontFamily: "Clash Display Regular",
                                  fontSize: 14.sp))))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      productController.selectedColor.value = v;
                      productController.errorColorMsg.value = "";
                      productController.updateImagesForSelectedColor();
                      if (_pageController.hasClients)
                        _pageController.jumpToPage(0);
                      setState(() => _selectedQuantity = 1);
                    }
                  },
                ),
                if (productController.errorColorMsg.value.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 6.sp),
                    child: ShakeWidget(
                      trigger: productController.colorShakeTrigger.value,
                      child: Text(productController.errorColorMsg.value,
                          style: TextStyle(
                              fontFamily: "Clash Display Regular",
                              fontSize: 12.sp,
                              color: deepRed)),
                    ),
                  ),
              ],
            ]));
      });

  void _showSizeBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.sp))),
        padding: EdgeInsets.fromLTRB(16.sp, 12.sp, 16.sp, 32.sp),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 36.sp,
                      height: 4.sp,
                      decoration: BoxDecoration(
                          color: colorSecondary,
                          borderRadius: BorderRadius.circular(2.sp)))),
              SizedBox(height: 16.sp),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('SELECT SIZE',
                    style: TextStyle(
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp)),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    _openSizeChart();
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
                    decoration: BoxDecoration(
                        border: Border.all(color: lightPurpleColor),
                        borderRadius: BorderRadius.circular(20.sp)),
                    child: Text('Size Chart',
                        style: TextStyle(
                            fontFamily: "Clash Display Regular",
                            color: lightPurpleColor,
                            fontSize: 12.sp)),
                  ),
                ),
              ]),
              SizedBox(height: 16.sp),
              Obx(() => Wrap(
                    spacing: 8.sp,
                    runSpacing: 8.sp,
                    children: productController.sizeInventoryList.map((size) {
                      final isSelected =
                          productController.selectedSize.value == size;
                      final matchingVariant = productController.selectedVariants
                          .firstWhereOrNull((v) => v["size"] == size);
                      final sizeStock = matchingVariant != null
                          ? (matchingVariant["stocks"] as int? ?? 0)
                          : 0;
                      final isOutOfStock =
                          matchingVariant != null && sizeStock <= 0;
                      return GestureDetector(
                        onTap: isOutOfStock
                            ? null
                            : () {
                                productController.selectedSize.value = size;
                                productController.errorSizeMsg.value = "";
                                productController.loadColorsForSize(size);
                                if (_pageController.hasClients)
                                  _pageController.jumpToPage(0);
                                setState(() => _selectedQuantity = 1);
                                Get.back();
                              },
                        child: Opacity(
                          opacity: isOutOfStock ? 0.4 : 1.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.sp, vertical: 12.sp),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: isSelected
                                      ? lightPurpleColor
                                      : Colors.black87,
                                  width: isSelected ? 2 : 1),
                              borderRadius: BorderRadius.circular(8.sp),
                              color: isSelected
                                  ? lightPurpleColor
                                  : Colors.transparent,
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(size.toUpperCase(),
                                      style: TextStyle(
                                          fontFamily: "Clash Display Regular",
                                          fontSize: 13.sp,
                                          color: isSelected
                                              ? whiteColor
                                              : Colors.black87)),
                                  if (matchingVariant != null &&
                                      sizeStock <= 2 &&
                                      sizeStock > 0)
                                    Text('Only $sizeStock left',
                                        style: TextStyle(
                                            fontSize: 9.sp,
                                            color: isSelected
                                                ? whiteColor.withOpacity(0.8)
                                                : lightPurpleColor)),
                                ]),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              SizedBox(height: 8.sp),
            ]),
      ),
    );
  }

  Widget _styledDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    bool hasError = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: hasError ? deepRed : borderColor),
        borderRadius: BorderRadius.circular(12.sp),
        color: whiteColor,
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.sp),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: blackColor, size: 22.sp),
          hint: Text(hint,
              style: TextStyle(
                  fontFamily: "Clash Display Regular",
                  fontSize: 14.sp,
                  color: textHintColor)),
          items: items,
          onChanged: onChanged,
          dropdownColor: whiteColor,
          borderRadius: BorderRadius.circular(12.sp),
          style: TextStyle(
              fontFamily: "Clash Display Regular",
              fontSize: 14.sp,
              color: blackColor),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() => Obx(() {
        final hasSizes = productController.sizeInventoryList.isNotEmpty;
        final hasColors = productController.colorInventoryList.isNotEmpty;
        final sizeSelected = productController.selectedSize.value.isNotEmpty;
        final colorSelected = productController.selectedColor.value.isNotEmpty;

        bool shouldShow = false;
        if (hasSizes && hasColors) {
          shouldShow = sizeSelected && colorSelected;
        } else if (hasSizes) {
          shouldShow = sizeSelected;
        } else if (hasColors) {
          shouldShow = colorSelected;
        } else {
          shouldShow = !productController.isDetails.value;
        }

        if (!shouldShow) return const SizedBox.shrink();

        final variant = productController.getSelectedVariant();
        final maxStock =
            int.tryParse(variant?['stocks']?.toString() ?? '0') ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.sp, horizontal: 16.sp),
              child: Divider(color: colorSecondary),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Text(
                'SELECT QUANTITY',
                style: TextStyle(
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w500,
                    color: blackColor,
                    fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 12.sp),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Row(
                children: [
                  // Decrease button
                  GestureDetector(
                    onTap: () {
                      if (_selectedQuantity > 1) {
                        setState(() => _selectedQuantity--);
                      }
                    },
                    child: Container(
                      width: 36.sp,
                      height: 36.sp,
                      decoration: BoxDecoration(
                        border: Border.all(color: blackColor, width: 1.sp),
                        color: whiteColor,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.remove,
                          color: _selectedQuantity <= 1
                              ? searchTextColor
                              : blackColor,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                  // Quantity display
                  Container(
                    width: 60.sp,
                    height: 36.sp,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: blackColor, width: 1.sp),
                        bottom: BorderSide(color: blackColor, width: 1.sp),
                      ),
                      color: whiteColor,
                    ),
                    child: Center(
                      child: Text(
                        _selectedQuantity.toString(),
                        style: TextStyle(
                            fontFamily: "Clash Display",
                            fontWeight: FontWeight.w600,
                            color: blackColor,
                            fontSize: 14.sp),
                      ),
                    ),
                  ),
                  // Increase button
                  GestureDetector(
                    onTap: () {
                      if (maxStock > 0 && _selectedQuantity < maxStock) {
                        setState(() => _selectedQuantity++);
                      } else if (maxStock > 0) {
                        showAppSnackBar(
                          'Maximum available quantity is $maxStock',
                          type: SnackBarType.warning,
                        );
                      }
                    },
                    child: Container(
                      width: 36.sp,
                      height: 36.sp,
                      decoration: BoxDecoration(
                        border: Border.all(color: blackColor, width: 1.sp),
                        color: whiteColor,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: (maxStock > 0 && _selectedQuantity >= maxStock)
                              ? searchTextColor
                              : blackColor,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.sp),
          ],
        );
      });

  Widget _buildSizeTable(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const Text("No size info");
    final headers = data.first.keys.toList();
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
            decoration: const BoxDecoration(color: Colors.white),
            children: headers
                .map((h) => Padding(
                    padding: EdgeInsets.all(8.sp),
                    child: Text(h.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp))))
                .toList()),
        ...data.map((row) => TableRow(
            decoration: const BoxDecoration(color: Colors.white),
            children: headers
                .map((h) => Padding(
                    padding: EdgeInsets.all(8.sp),
                    child: Text(row[h]?.toString() ?? "-",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.black, fontSize: 12.sp))))
                .toList())),
      ],
    );
  }

  void _openSizeChart() async {
    await productController.fetchSizeChart(
      brandId: productController.productDetails["brand"]?["id"] ?? 0,
      superCatId: productController.productDetails["superCatId"] ?? 0,
      catId: productController.productDetails["catId"] ?? 0,
      subCatId: productController.productDetails["subCatId"] ?? 0,
    );
    final chart = productController.sizeChart;
    final chartData = productController.sizeChartData;
    showDialog(
        context: context,
        builder: (_) => Dialog(
              insetPadding: EdgeInsets.all(16.sp),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.sp)),
              child: Container(
                  padding: EdgeInsets.all(16.sp),
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(chart["title"]?.toString() ?? "Size Chart",
                            style: TextStyle(
                                fontFamily: "Clash Display",
                                fontWeight: FontWeight.w700,
                                fontSize: 18.sp)),
                        SizedBox(height: 14.sp),
                        if (chart["sizeGuideImage"] != null &&
                            chart["sizeGuideImage"].toString().isNotEmpty)
                          _ZoomableImage(imageUrl: chart["sizeGuideImage"])
                        else
                          _buildSizeTable(chartData),
                        SizedBox(height: 18.sp),
                        Center(
                            child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.sp)),
                              minimumSize: Size(180.sp, 48.sp)),
                          child: Text("Close",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Clash Display",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp)),
                        )),
                      ]))),
            ));
  }
}
