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

    return Column(
      children: [
        // ✅ Only the collections rows need to be inside Obx
        Obx(() {
          final collections = productController.homeProductList;
          final displayCount = isExpanded.value ? collections.length : 2;
          final visibleCollections = collections.take(displayCount).toList();

          return Column(
            children: List.generate(
              visibleCollections.length,
              (index) => widget.collectionRowBuilder(index),
            ),
          );
        }),

        // ✅ LuxeSection is outside Obx — created once, never destroyed on
        //    parent rebuilds. Its own internal Obx handles luxeList updates.
        LuxeSection(
          onViewAll: () {
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
                  segment: 'luxury',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
