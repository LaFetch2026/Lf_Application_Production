import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/constants.dart';
import '../services/swipe_tracking_service.dart';

/// The bottom action bar showing Nope / View / Save / Like hint icons.
/// Each icon is tappable as an accessibility fallback for the swipe gestures.
class SwipeHintBar extends StatelessWidget {
  final void Function(SwipeAction action) onAction;

  const SwipeHintBar({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _HintIcon(
            icon: Icons.close_rounded,
            color: Colors.red,
            label: 'Nope',
            onTap: () => onAction(SwipeAction.dislikeProduct),
          ),
          _HintIcon(
            icon: Icons.open_in_new_rounded,
            color: Colors.grey[600]!,
            label: 'View',
            onTap: () => onAction(SwipeAction.swipeDown),
          ),
          _HintIcon(
            icon: Icons.bookmark_add_outlined,
            color: lightPurpleColor,
            label: 'Save',
            onTap: () => onAction(SwipeAction.swipeUp),
          ),
          _HintIcon(
            icon: Icons.favorite_rounded,
            color: lightPurpleColor,
            label: 'Like',
            onTap: () => onAction(SwipeAction.likeProduct),
          ),
        ],
      ),
    );
  }
}

class _HintIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _HintIcon({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 2.sp),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
