import 'package:flutter/material.dart';
import '../../../core/constant/constants.dart';
import '../../../models/filter_chip_item.dart';

class FilterChipsRow extends StatelessWidget {
  final List<FilterChipItem> chips;

  /// The id of the currently active chip (if any).
  /// A chip is considered active when its [FilterChipItem.id] matches this value.
  final int? activeChipId;

  final void Function(FilterChipItem chip) onChipTap;

  const FilterChipsRow({
    super.key,
    required this.chips,
    required this.onChipTap,
    this.activeChipId,
  });

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final isActive = chip.id == activeChipId;

          return GestureDetector(
            onTap: () => onChipTap(chip),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? lightPurpleColor : whiteColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isActive ? lightPurpleColor : greyBorder,
                ),
              ),
              child: Text(
                chip.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isActive ? whiteColor : greyTextColor,
                  fontFamily: 'ClashDisplay',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
