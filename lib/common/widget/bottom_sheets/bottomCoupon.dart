import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/cart_controller.dart';
import '../../../core/constant/constants.dart';
import '../text/app_text.dart';

class BottomCoupon extends StatefulWidget {
  final List list;
  final Color backColor;
  final Function(String) onPressed;

  const BottomCoupon({
    super.key,
    required this.list,
    required this.backColor,
    required this.onPressed,
  });

  @override
  State<BottomCoupon> createState() => _BottomCouponState();
}

class _BottomCouponState extends State<BottomCoupon> {
  final controller = Get.put(CartController());
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isLight = widget.backColor == whiteColor;

    return Scaffold(
      backgroundColor: isLight ? whiteColor : homeAppBarColor,
      appBar: AppBar(
        backgroundColor: isLight ? whiteColor : homeAppBarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const AppText(
          text: "APPLY COUPON",
          fontFamily: "Clash Display Semibold",
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border, color: Colors.black87),
          )
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45.sp,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(2.sp),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.sp),
                          child: SvgPicture.asset(
                            couponSvgImage,
                            color: Colors.grey.shade700,
                            height: 18.sp,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller.couponController,
                            decoration: InputDecoration(
                              hintText: "Apply Coupon",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: "Clash Display Regular",
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                SizedBox(
                  height: 45.sp,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 20.sp),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.sp),
                      ),
                    ),
                    onPressed: () {
                      final code = controller.couponController.text.trim();
                      if (code.isNotEmpty) widget.onPressed(code);
                    },
                    child: const Text(
                      "APPLY",
                      style: TextStyle(
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
            child: Row(
              children: [
                const AppText(
                  text: "Available coupons",
                  fontFamily: "Clash Display Semibold",
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 15,
                ),
                const Spacer(),
                AppText(
                  text:
                      "${widget.list.length} ${widget.list.length == 1 ? "coupon" : "coupons"}",
                  fontFamily: "Clash Display Regular",
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ],
            ),
          ),

          // Coupon List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              itemCount: widget.list.length,
              itemBuilder: (context, index) {
                final coupon = widget.list[index];
                final isSelected = selectedIndex == index;

                return Padding(
                  padding: EdgeInsets.only(bottom: 18.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox + Code
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex =
                                isSelected ? null : index; // toggle selection
                          });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (_) {
                                setState(() {
                                  selectedIndex =
                                      isSelected ? null : index; // toggle
                                });
                              },
                              activeColor: Colors.black,
                              side: const BorderSide(color: Colors.grey),
                            ),
                            DottedBorder(
                              color: Colors.grey.shade700,
                              strokeWidth: 1,
                              dashPattern: const [4, 4],
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.sp, vertical: 6.sp),
                                child: AppText(
                                  text: (coupon["code"] ?? "COUPON")
                                      .toString()
                                      .toUpperCase(),
                                  fontFamily: "Clash Display",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Coupon Info
                      Padding(
                        padding: EdgeInsets.only(left: 50.sp, top: 4.sp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // AppText(
                                //   text: "Save ",
                                //   fontFamily: "Clash Display Regular",
                                //   color: Colors.grey.shade700,
                                //   fontSize: 12,
                                // ),
                                // AppText(
                                //   text:
                                //       "₹${coupon["maxDiscountCap"] ?? coupon["discountAmount"] ?? "0"}",
                                //   color: const Color(0xFFB57EDC),
                                //   fontSize: 12,
                                //   fontFamily: "Clash Display Semibold",
                                // ),

                                AppText(
                                  text: coupon["discountType"] ??
                                      "Discount available on this order",
                                  color: const Color(0xFFB57EDC),
                                  fontSize: 12,
                                  fontFamily: "Clash Display Semibold",
                                ),
                              ],
                            ),
                            // SizedBox(height: 4.sp),
                            // AppText(
                            //   text: coupon["discountType"] ??
                            //       "Discount available on this order",
                            //   color: Colors.grey.shade800,
                            //   fontSize: 12,
                            //   fontFamily: "Clash Display Regular",
                            // ),
                            // SizedBox(height: 4.sp),
                            AppText(
                              text:
                                  "Valid until: ${coupon["endDate"]?.toString().split('T').first ?? "-"}",
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontFamily: "Clash Display Regular",
                            ),
                            SizedBox(height: 10.sp),
                            Container(
                              height: 1.sp,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 10.sp),
                            AppText(
                              text:
                                  "Add items worth ₹${coupon["minCartValue"] ?? "0"} for discount",
                              color: Colors.grey.shade800,
                              fontSize: 12,
                              fontFamily: "Clash Display Regular",
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Padding(
                                padding: EdgeInsets.only(top: 4.sp),
                                child: Row(
                                  children: [
                                    Text(
                                      "Browse Collection",
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.black,
                                        fontSize: 12.sp,
                                        fontFamily: "Clash Display Regular",
                                      ),
                                    ),
                                    SizedBox(width: 5.sp),
                                    const Icon(Icons.chevron_right,
                                        size: 14, color: Colors.black),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Bar
          if (selectedIndex != null)
            Container(
              color: const Color(0xffF9FAFB),
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 16.sp),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: "Maximum savings:",
                          color: Colors.grey.shade800,
                          fontSize: 13,
                          fontFamily: "Clash Display Regular",
                        ),
                        AppText(
                          text:
                              "₹${widget.list[selectedIndex!]["maxDiscountCap"] ?? "0"}",
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: "Clash Display Semibold",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 120.sp,
                    height: 45.sp,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.sp)),
                      ),
                      onPressed: () {
                        widget.onPressed
                            .call(widget.list[selectedIndex!]["code"]);
                      },
                      child: const Text(
                        "APPLY",
                        style: TextStyle(
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
