part of 'product_details_screen_v2.dart';

extension PdpBottomSection on _ProductDetailsScreenV2State {
  Widget _buildSimilarProducts() => SimilarProductsCarousel(
      key: _similarSectionKey,
      productId: widget.productId,
      showTrending: false,
      onNavigating: () => setState(() => _isForeground = false));

  Widget _buildProductDetails() {
    return Obx(() {
      if (productController.isDetails.value) return const SizedBox();

      final desc =
          productController.productDetails['description']?.toString() ?? '';
      if (desc.isEmpty) return const SizedBox();

      final lines = desc.split('\n').where((e) => e.trim().isNotEmpty).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExpansionTile(
            splashColor: Colors.transparent,
            shape: const Border(),
            collapsedShape: const Border(),
            tilePadding: EdgeInsets.symmetric(horizontal: 12.sp),
            childrenPadding: EdgeInsets.only(
              left: 12.sp,
              right: 12.sp,
              bottom: 12.sp,
            ),
            initiallyExpanded: true,
            title: const Text(
              'Product details',
              style: TextStyle(fontFamily: "Clash Display"),
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lines.map((line) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 6.sp),
                    child: Text(
                      line.trim(),
                      style: const TextStyle(
                        height: 1.4,
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.sp),
            child: Divider(
              color: Colors.grey[200],
              height: 1,
              thickness: 1.2,
            ),
          ),
          _buildDeliveryPolicies(),
        ],
      );
    });
  }

  Widget _buildDeliveryPolicies() {
    return ExpansionTile(
      splashColor: Colors.transparent,
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: EdgeInsets.symmetric(horizontal: 12.sp),
      childrenPadding: EdgeInsets.only(
        left: 12.sp,
        right: 12.sp,
        bottom: 12.sp,
      ),
      title: const Text(
        'Delivery & Services Policies',
        style: TextStyle(fontFamily: "Clash Display"),
      ),
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            '•  Free delivery on orders above ₹2000\n'
            '•  7-day return policy\n'
            '•  Secure payments',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildDeliveryPolicies() => ExpansionTile(
  //       splashColor: Colors.transparent,
  //       shape: const Border(),
  //       title: const Text(
  //         'Delivery & Services Policies',
  //         style: TextStyle(fontFamily: "Clash Display"),
  //       ),
  //       children: [
  //         Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 12.sp),
  //           child: const SizedBox(
  //             width: double.infinity,
  //             child: Text(
  //               '•  Free delivery on orders above ₹2000\n•  7-day return policy\n•  Secure payments',
  //               textAlign: TextAlign.left,
  //               style: TextStyle(
  //                   fontFamily: "Clash Display",
  //                   fontWeight: FontWeight.w400,
  //                   color: Colors.grey),
  //             ),
  //           ),
  //         ),
  //       ],
  //     );

  Widget _buildFAQs() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FAQs',
              style: TextStyle(
                fontFamily: "Clash Display",
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 4.sp),
            _faqItem(
              'What is LaFetch\u2019s return and exchange policy?',
              'Return or exchange requests must be initiated within 7 calendar days of delivery. To be eligible, products must be unused, unworn, unwashed, and returned with all original tags, packaging, and accessories intact.',
            ),
            Divider(
              color: Colors.grey[200],
              height: 1,
              thickness: 2,
            ),
            _faqItem(
              'What if the product does not fit me properly?',
              'Customers may request an exchange for size or fit concerns within 7 calendar days of delivery.',
            ),
            Divider(
              color: Colors.grey[200],
              height: 1,
              thickness: 2,
            ),
            _faqItem(
              'How long does standard delivery take?',
              'Standard delivery typically takes 3\u20137 business days.',
            ),
            Divider(
              color: Colors.grey[200],
              height: 1,
              thickness: 2,
            ),
            _faqItem(
              'What if I receive a damaged or incorrect product?',
              'If you receive a damaged, defective, or incorrect product, you are eligible to request a return or exchange. Please contact customer support and share relevant proof such as images or videos.',
            ),
            Divider(
              color: Colors.grey[200],
              height: 1,
              thickness: 2,
            ),
            _faqItem(
              'Is Cash on Delivery (COD) available?',
              'According to the platform\u2019s Terms of Use, COD is not available as of now.',
            ),
            Divider(
              color: Colors.grey[200],
              height: 1,
              thickness: 2,
            ),
            _faqItem(
              'Can I cancel or modify my order after placing it?',
              'Standard orders can be cancelled prior to dispatch. Once shipped, they must follow the return process. MTO products can only be cancelled within 2 hours of placement.',
            ),
            Divider(
              color: Colors.grey[200],
              height: 1,
              thickness: 2,
            ),
            _faqItem(
              'Are there any shipping charges?',
              'Shipping charges, if applicable, are shown at checkout. Some promotions may offer free shipping.',
            ),
          ],
        ),
      );

  Widget _faqItem(String title, String body) {
    return SizedBox(
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          splashColor: Colors.transparent,
          tilePadding: EdgeInsets.symmetric(vertical: 4.sp),
          childrenPadding: EdgeInsets.only(bottom: 8.sp),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: "Clash Display",
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.sp),
              child: Text(
                body,
                style: TextStyle(
                  fontFamily: "Clash Display Regular",
                  fontSize: 12.5.sp,
                  height: 1.5,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLFPromises() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          width: double.infinity,
          child: Image.asset("assets/images/lf_promises.png"),
        ),
      );

  Widget _buildReviewSection() => Obx(() {
        final reviews = productController.reviewList;
        final isLoading = productController.isFetchingReviews.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.sp, 8.sp, 16.sp, 4.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reviews',
                    style: TextStyle(
                      fontFamily: "Clash Display",
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  if (reviews.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: Colors.amber, size: 16.sp),
                        SizedBox(width: 4.sp),
                        Text(
                          productController.averageRating.value
                              .toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: "Clash Display",
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                        Text(
                          '  (${productController.totalReview.value})',
                          style: TextStyle(
                            fontFamily: "Clash Display",
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────
            if (isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.sp),
                child: const Center(
                    child: LfLoaderWidget(
                  size: 48,
                  brandColor: Colors.grey,
                )),
              )
            else if (reviews.isEmpty)
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_outline_rounded,
                        size: 40.sp, color: Colors.grey.shade300),
                    Text(
                      'No reviews yet. Be the first to share your thoughts!',
                      style: TextStyle(
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.sp, vertical: 4.sp),
                itemCount: reviews.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.grey[200],
                  height: 1,
                  thickness: 1.5,
                ),
                itemBuilder: (_, i) => _buildReviewItem(reviews[i]),
              ),

            // ── Always-visible button ────────────────────────────────
            _buildAddReviewButton(),
          ],
        );
      });

  Widget _buildReviewItem(dynamic review) {
    final rating = (review['rating'] as num?)?.toInt() ?? 0;
    final comment = review['comment']?.toString() ?? '';
    final userName = review['user']?['name']?.toString() ??
        review['userName']?.toString() ??
        'Anonymous';
    final createdAt = review['createdAt']?.toString() ?? '';
    String dateLabel = '';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        dateLabel = '${dt.day} ${_monthName(dt.month)} ${dt.year}';
      } catch (_) {}
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Star rating
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(
                          i < rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14.sp,
                          color: Colors.amber,
                        )),
              ),
              const Spacer(),
              if (dateLabel.isNotEmpty)
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontFamily: "Clash Display",
                    fontSize: 11.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: 6.sp),
            Text(
              comment,
              style: TextStyle(
                fontFamily: "Clash Display",
                fontWeight: FontWeight.w400,
                fontSize: 13.sp,
                height: 1.45,
                color: Colors.grey.shade700,
              ),
            ),
          ],
          SizedBox(height: 4.sp),
          Text(
            '— $userName',
            style: TextStyle(
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w600,
              fontSize: 11.5.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];

  Widget _buildAddReviewButton() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
        child: GestureDetector(
          onTap: _showAddReviewModal,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.sp),
            decoration: BoxDecoration(
              border: Border.all(color: blackColor, width: 1.5),
              borderRadius: BorderRadius.circular(40.sp),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(Icons.star_border_rounded, size: 18.sp, color: blackColor),
                SizedBox(width: 8.sp),
                Text(
                  'WRITE US A REVIEW',
                  style: TextStyle(
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: blackColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildTrendingProducts() => TrendingNowSection(
      productId: widget.productId,
      onNavigating: () => setState(() => _isForeground = false));

  Widget _buildNewsletter() =>
      const NewsletterSection(title: "LF NEWS LETTERS");

  Widget _buildDivider({double? height}) {
    return Column(
      children: [
        SizedBox(height: height ?? 10.sp),
        Divider(
          color: Colors.grey[200],
          height: 1,
          thickness: 4.0,
        ),
        SizedBox(height: height ?? 20.sp),
      ],
    );
  }
}
