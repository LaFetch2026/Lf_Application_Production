import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/nudge_model.dart';

/// A pill-shaped badge widget that renders a single [Nudge] with a colour-coded
/// background, an icon, and (in full mode) a text label.
///
/// Set [compact] to `true` to show only the icon (used on product cards).
/// Set [compact] to `false` (the default) to show icon + label (used on PDP).
class NudgeBadge extends StatelessWidget {
  final Nudge nudge;
  final bool compact;

  const NudgeBadge({
    super.key,
    required this.nudge,
    this.compact = false,
  });

  /// Maps a nudge [key] to its designated background colour.
  /// Returns a grey fallback for unrecognised keys.
  static Color _colorFor(String key) {
    switch (key) {
      case 'selling_fast':
        return const Color(0xFFEF4444); // red
      case 'trending':
        return const Color(0xFF8B5CF6); // purple
      case 'new_in':
        return const Color(0xFF10B981); // emerald
      case 'back_in_stock':
        return const Color(0xFF0EA5E9); // sky blue
      case 'bestseller':
        return const Color(0xFFF59E0B); // amber
      default:
        return const Color(0xFF9CA3AF); // grey fallback
    }
  }

  /// Maps a nudge [key] to its designated icon.
  /// Returns a generic label icon for unrecognised keys.
  static IconData _iconFor(String key) {
    switch (key) {
      case 'selling_fast':
        return Icons.local_fire_department;
      case 'trending':
        return Icons.trending_up;
      case 'new_in':
        return Icons.fiber_new;
      case 'back_in_stock':
        return Icons.replay;
      case 'bestseller':
        return Icons.workspace_premium;
      default:
        return Icons.label_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(nudge.key);
    final icon = _iconFor(nudge.key);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 3.sp),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: compact
          ? Icon(icon, size: 12.sp, color: Colors.white)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12.sp, color: Colors.white),
                SizedBox(width: 3.sp),
                Text(
                  nudge.label,
                  style: TextStyle(fontSize: 10.sp, color: Colors.white),
                ),
              ],
            ),
    );
  }
}
