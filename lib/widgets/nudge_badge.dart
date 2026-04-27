import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/nudge_model.dart';

class NudgeBadge extends StatelessWidget {
  final Nudge nudge;
  final bool showText;

  const NudgeBadge({
    super.key,
    required this.nudge,
    this.showText = true,
  });

  static _NudgeStyle _styleFor(String key) {
    switch (key) {
      case 'selling_fast':
        return const _NudgeStyle(
          gradient:
              LinearGradient(colors: [Color(0xFFE88080), Color(0xFFD95656)]),
          icon: Icons.bolt,
        );
      case 'trending':
        return const _NudgeStyle(
          gradient:
              LinearGradient(colors: [Color(0xFFB8B0FF), Color(0xFF988AFF)]),
          icon: Icons.trending_up,
        );
      case 'new_in':
        return const _NudgeStyle(
          gradient:
              LinearGradient(colors: [Color(0xFFD4D0FF), Color(0xFF7268BF)]),
          icon: Icons.flare,
        );
      case 'back_in_stock':
        return const _NudgeStyle(
          gradient:
              LinearGradient(colors: [Color(0xFF8B85C1), Color(0xFF404662)]),
          icon: Icons.inventory_2,
        );
      case 'bestseller':
        return const _NudgeStyle(
          gradient:
              LinearGradient(colors: [Color(0xFFD4A843), Color(0xFF9A7209)]),
          icon: Icons.military_tech,
        );
      default:
        return const _NudgeStyle(
          gradient:
              LinearGradient(colors: [Color(0xFFD6D4D0), Color(0xFF9CA3AF)]),
          icon: Icons.sell,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(nudge.key);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        gradient: style.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: style.gradient.colors.first.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: showText ? 10.sp : 11.sp, color: Colors.white),
          if (showText) ...[
            SizedBox(width: 4.sp),
            Text(
              nudge.label.toUpperCase(),
              style: TextStyle(
                fontSize: 9.sp,
                color: Colors.white,
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NudgeStyle {
  final LinearGradient gradient;
  final IconData icon;

  const _NudgeStyle({required this.gradient, required this.icon});
}
