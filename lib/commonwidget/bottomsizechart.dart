import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';

class BottomSizeChart extends StatefulWidget {
  final String productName;
  final String productSizeChart;
  const BottomSizeChart({
    required this.productSizeChart,
    required this.productName,
    Key? key,
  }) : super(key: key);

  @override
  State<BottomSizeChart> createState() => BottomSizeChartState();
}

class BottomSizeChartState extends State<BottomSizeChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: whiteColor,
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 20,
                      width: 20,
                      margin: EdgeInsets.only(top: 50, right: 20),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        image: DecorationImage(
                            image: AssetImage(blackCrossImage),
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.productName,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 14.sp,
                            decoration: TextDecoration.none,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: SizedBox(
                    height: 400,
                    width: MediaQuery.sizeOf(context).width,
                    child: CachedNetworkImage(
                      cacheManager: CacheManager(Config("customCacheKey",
                          stalePeriod: const Duration(days: 15),
                          maxNrOfCacheObjects: 100)),
                      fit: BoxFit.contain,
                      imageUrl: widget.productSizeChart,
                      errorWidget: (context, url, error) => Image.asset(
                        downloadImage,
                        fit: BoxFit.contain,
                        height: 400,
                        width: MediaQuery.sizeOf(context).width,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
