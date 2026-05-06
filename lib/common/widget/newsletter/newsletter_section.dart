import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/newsletter_controller.dart';
import '../../../core/constant/constants.dart';
import 'package:lafetch/common/widget/other/lf_loader_widget.dart';
import '../../../models/newsletter_model.dart';

/// Newsletter Section Widget
/// Shows top 5 newsletters in a grid layout:
/// - First row: 3 newsletters
/// - Second row: 2 newsletters (centered)
class NewsletterSection extends StatelessWidget {
  final String? title;
  final EdgeInsetsGeometry? padding;

  const NewsletterSection({
    super.key,
    this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewsletterController());

    // Fetch newsletters if not already loaded
    if (controller.newsletters.isEmpty && !controller.isLoading.value) {
      controller.getNewsletters();
    }

    return Obx(() {
      // Show nothing while loading or if empty
      if (controller.isLoading.value && controller.newsletters.isEmpty) {
        return const SizedBox.shrink();
      }

      if (controller.newsletters.isEmpty) {
        return const SizedBox.shrink();
      }

      final newsletters = controller.newsletters;

      // Split newsletters: first 3 for row 1, next 2 for row 2
      final row1 = newsletters.take(3).toList();
      final row2 = newsletters.skip(3).take(2).toList();

      return Padding(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            if (title != null && title!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 16.sp),
                child: Text(
                  title!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Clash Display Semibold",
                    color: homeAppBarColor,
                  ),
                ),
              ),

            // Row 1: 3 newsletters
            if (row1.isNotEmpty) _buildRow(context, row1, 3),

            SizedBox(height: 8.sp),

            // Row 2: 2 newsletters (centered)
            if (row2.isNotEmpty) _buildRow(context, row2, 2),

            SizedBox(height: 16.sp),
          ],
        ),
      );
    });
  }

  Widget _buildRow(
      BuildContext context, List<NewsletterModel> items, int itemsInRow) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 16.sp * 2; // Left and right padding
    final spacing = 8.sp;
    final totalSpacing = spacing * (itemsInRow - 1);
    final availableWidth = screenWidth - horizontalPadding - totalSpacing;
    final itemWidth = availableWidth / itemsInRow;
    final itemHeight = itemWidth * 1.2; // Aspect ratio 1:1.2

    // For row 2 with 2 items, center them
    final isSecondRow = itemsInRow == 2;

    return Row(
      mainAxisAlignment:
          isSecondRow ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final newsletter = entry.value;

        return Row(
          children: [
            _NewsletterCard(
              newsletter: newsletter,
              width: itemWidth,
              height: itemHeight,
            ),
            if (index < items.length - 1) SizedBox(width: spacing),
          ],
        );
      }).toList(),
    );
  }
}

/// Individual Newsletter Card
class _NewsletterCard extends StatelessWidget {
  final NewsletterModel newsletter;
  final double width;
  final double height;

  const _NewsletterCard({
    required this.newsletter,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showNewsletterDetail(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.sp),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.sp),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              CachedNetworkImage(
                imageUrl: newsletter.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: const LfLogoLoader(size: 12, showGlow: false),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[500],
                    size: 24.sp,
                  ),
                ),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.3, 0.6, 1.0],
                  ),
                ),
              ),

              // Content Overlay
              Positioned(
                left: 8.sp,
                right: 8.sp,
                bottom: 8.sp,
                child: Text(
                  newsletter.title,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Clash Display Medium",
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewsletterDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewsletterDetailSheet(newsletter: newsletter),
    );
  }
}

/// Newsletter Detail Bottom Sheet
class _NewsletterDetailSheet extends StatelessWidget {
  final NewsletterModel newsletter;

  const _NewsletterDetailSheet({required this.newsletter});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.sp),
              width: 40.sp,
              height: 4.sp,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.sp),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.sp),
                      child: CachedNetworkImage(
                        imageUrl: newsletter.imageUrl,
                        width: double.infinity,
                        height: 200.sp,
                        fit: BoxFit.fill,
                        placeholder: (context, url) => Container(
                          height: 200.sp,
                          color: Colors.grey[300],
                          child: const Center(
                            child: LfLogoLoader(size: 32, showGlow: false),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200.sp,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.sp),

                    // Title
                    Text(
                      newsletter.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Clash Display Semibold",
                        color: homeAppBarColor,
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: 12.sp),

                    // Content
                    Text(
                      newsletter.content,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: "Clash Display Regular",
                        color: greyTextColor,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 24.sp),
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
