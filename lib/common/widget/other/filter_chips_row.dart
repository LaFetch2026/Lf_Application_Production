import 'package:flutter/material.dart';
import '../../../core/constant/constants.dart';
import '../../../models/filter_chip_item.dart';

class ActiveFilterPill {
  final String label;
  final VoidCallback onRemove;

  const ActiveFilterPill({required this.label, required this.onRemove});
}

class FilterChipsRow extends StatelessWidget {
  final List<FilterChipItem> chips;
  final List<FilterChipItem> selectedChips;
  final Set<int> selectedChipIds;
  final void Function(FilterChipItem chip) onChipTap;
  final List<ActiveFilterPill> activeFilters;

  const FilterChipsRow({
    super.key,
    required this.chips,
    required this.onChipTap,
    this.selectedChips = const [],
    this.selectedChipIds = const {},
    this.activeFilters = const [],
  });

  @override
  Widget build(BuildContext context) {
    final selectedIds = selectedChips.map((c) => c.id).toSet();
    final serverChips =
        chips.where((c) => !selectedIds.contains(c.id)).toList();

    final totalCount =
        activeFilters.length + selectedChips.length + serverChips.length;

    if (totalCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: totalCount,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            if (index < activeFilters.length) {
              return _ActivePill(pill: activeFilters[index]);
            }
            final i = index - activeFilters.length;

            if (i < selectedChips.length) {
              return _ChipItem(
                chip: selectedChips[i],
                isActive: true,
                onTap: onChipTap,
              );
            }

            final chip = serverChips[i - selectedChips.length];
            return _ChipItem(chip: chip, isActive: false, onTap: onChipTap);
          },
        ),
      ),
    );
  }
}

class _ActivePill extends StatelessWidget {
  final ActiveFilterPill pill;

  const _ActivePill({required this.pill});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pill.onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          // color: lightPurpleColor,
          color: blackColor,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              // color: lightPurpleColor.withOpacity(0.22),
              color: blackColor.withOpacity(0.22),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              pill.label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'InstrumentSans',
                letterSpacing: 0.2,
                height: 1,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.close_rounded, size: 12, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _ChipItem extends StatelessWidget {
  final FilterChipItem chip;
  final bool isActive;
  final void Function(FilterChipItem) onTap;

  const _ChipItem({
    required this.chip,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(chip),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          // color: isActive ? lightPurpleColor : const Color(0xFFF9F9FB),
          color: isActive ? blackColor : const Color(0xFFF9F9FB),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            // color: isActive ? lightPurpleColor : const Color(0xFFE5E7EB),
            color: isActive ? blackColor : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    // color: lightPurpleColor.withOpacity(0.2),
                    color: blackColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Center(
          child: isActive
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      chip.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'InstrumentSans',
                        letterSpacing: 0.2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: Colors.white70,
                    ),
                  ],
                )
              : Text(
                  chip.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                    fontFamily: 'InstrumentSans',
                    letterSpacing: 0.2,
                    height: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
