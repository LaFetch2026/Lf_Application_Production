import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/nudge_model.dart';
import 'nudge_badge.dart';

/// A horizontally scrollable row of [NudgeBadge] widgets.
///
/// Renders up to [maxVisible] badges from [nudges]. Returns [SizedBox.shrink]
/// when [nudges] is empty. Pass [compact] to control whether each child badge
/// shows icon-only (`true`) or icon + label (`false`).
class NudgeBadgeRow extends StatelessWidget {
  final List<Nudge> nudges;
  final int maxVisible;
  final bool compact;

  const NudgeBadgeRow({
    super.key,
    required this.nudges,
    this.maxVisible = 3,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (nudges.isEmpty) return const SizedBox.shrink();

    final visible = nudges.take(maxVisible).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: visible
            .map(
              (n) => Padding(
                padding: EdgeInsets.only(right: 4.sp),
                child: NudgeBadge(nudge: n, compact: compact),
              ),
            )
            .toList(),
      ),
    );
  }
}
