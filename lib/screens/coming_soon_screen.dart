import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constant/constants.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 96.sp,
                  height: 96.sp,
                  decoration: BoxDecoration(
                    color: homeAppBarColor,
                    borderRadius: BorderRadius.circular(24.sp),
                  ),
                  child: Icon(
                    Icons.movie_creation_outlined,
                    color: Colors.white,
                    size: 48.sp,
                  ),
                ),
                SizedBox(height: 28.sp),

                // Small label
                Text(
                  'Studio',
                  style: TextStyle(
                    fontFamily: 'Clash Display Regular',
                    fontSize: 13.sp,
                    color: Colors.grey[500],
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 8.sp),

                // Main heading
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontFamily: 'Clash Display',
                    fontWeight: FontWeight.w700,
                    fontSize: 32.sp,
                    color: homeAppBarColor,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.sp),

                // Subtitle
                Text(
                  'Short-form video content is on its way.\nStay tuned.',
                  style: TextStyle(
                    fontFamily: 'Clash Display Regular',
                    fontSize: 15.sp,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.sp),

                // Notify Me button
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "We'll let you know!",
                          style: TextStyle(
                            fontFamily: 'Clash Display Regular',
                            fontSize: 14.sp,
                          ),
                        ),
                        backgroundColor: homeAppBarColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.sp,
                      vertical: 14.sp,
                    ),
                    decoration: BoxDecoration(
                      color: homeAppBarColor,
                      borderRadius: BorderRadius.circular(30.sp),
                    ),
                    child: Text(
                      'Notify Me',
                      style: TextStyle(
                        fontFamily: 'Clash Display',
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
