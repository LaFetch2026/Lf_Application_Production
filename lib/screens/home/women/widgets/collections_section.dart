import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controllers/product_controller.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/screens/home/women/widgets/luxe_section.dart';
import 'package:lafetch/screens/Brands/categoryproduct.dart';

class CollectionsSection extends StatefulWidget {
  final int gender;
  final Widget Function(int) collectionRowBuilder;

  const CollectionsSection({
    required this.gender,
    required this.collectionRowBuilder,
    super.key,
  });

  @override
  State<CollectionsSection> createState() => _CollectionsSectionState();
}

class _CollectionsSectionState extends State<CollectionsSection> {
  late RxBool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = false.obs;
  }

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();

    return Obx(() {
      final collections = productController.homeProductList;
      final displayCount = isExpanded.value ? collections.length : 2;
      final visibleCollections = collections.take(displayCount).toList();

      return Column(
        children: [
          // Collections Rows
          ...List.generate(
            visibleCollections.length,
            (index) => widget.collectionRowBuilder(index),
          ),

          // // View All Button
          // if (collections.length > 2)
          //   Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          //     child: GestureDetector(
          //       onTap: () {
          //         isExpanded.value = !isExpanded.value;
          //       },
          //       child: Container(
          //         width: double.infinity,
          //         padding: EdgeInsets.symmetric(vertical: 12.h),
          //         decoration: BoxDecoration(
          //           border: Border.all(color: const Color(0xFFD6D4D0)),
          //           borderRadius: BorderRadius.circular(8.r),
          //           color: Colors.white,
          //         ),
          //         child: Center(
          //           child: Text(
          //             isExpanded.value ? 'View Less' : 'View All',
          //             style: TextStyle(
          //               fontSize: 14.sp,
          //               fontWeight: FontWeight.w600,
          //               color: colorPrimary,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),

          // LUXE Section
          LuxeSection(
            onViewAll: () {
              // Navigate to LUXE category page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryProductScreen(
                    categoryName: 'LUXE',
                    categoryId: 0,
                    brandId: 0,
                    genderType: 0,
                    collectionIds: [],
                    genderName: '',
                    type: 'luxe',
                    screen: 'luxe',
                    categoryList: [],
                    title: 'LUXE',
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}
