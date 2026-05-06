import 'package:flutter/material.dart';
import '../../../core/constant/constants.dart';
import '../../../models/filter_chip_item.dart';

/// A single active filter pill — shown at the front of the chip row.
class ActiveFilterPill {
  final String label;
  final VoidCallback onRemove;

  const ActiveFilterPill({required this.label, required this.onRemove});
}

class FilterChipsRow extends StatelessWidget {
  /// Server-returned chips (fresh from API).
  final List<FilterChipItem> chips;

  /// Selected chip objects stored locally — shown as active pills at the front.
  final List<FilterChipItem> selectedChips;

  /// Kept for backwards compatibility — not used in rendering.
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
    // Dedup: selected chips first, then server chips that aren't already selected
    final selectedIds = selectedChips.map((c) => c.id).toSet();
    final serverChips =
        chips.where((c) => !selectedIds.contains(c.id)).toList();

    final totalCount =
        activeFilters.length + selectedChips.length + serverChips.length;

    if (totalCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: totalCount,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            // 1. Active filter pills
            if (index < activeFilters.length) {
              return _ActivePill(pill: activeFilters[index]);
            }
            final i = index - activeFilters.length;

            // 2. Selected chip pills (always visible, active styling)
            if (i < selectedChips.length) {
              return _ChipItem(
                chip: selectedChips[i],
                isActive: true,
                onTap: onChipTap,
              );
            }

            // 3. Server chips (new suggestions from API)
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
          color: lightPurpleColor,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: lightPurpleColor.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pill.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontFamily: 'ClashDisplay',
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.close, size: 13, color: Colors.white),
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        decoration: BoxDecoration(
          color: isActive ? lightPurpleColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? lightPurpleColor : const Color(0xFFD1D5DB),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: lightPurpleColor.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isActive
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      chip.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: 'ClashDisplay',
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.close, size: 13, color: Colors.white),
                  ],
                )
              : Text(
                  chip.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                    fontFamily: 'ClashDisplay',
                    letterSpacing: 0.1,
                  ),
                ),
        ),
      ),
    );
  }
}
