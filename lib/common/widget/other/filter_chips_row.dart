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
  final bool isDarkMode;

  const FilterChipsRow({
    super.key,
    required this.chips,
    required this.onChipTap,
    this.selectedChips = const [],
    this.selectedChipIds = const {},
    this.activeFilters = const [],
    this.isDarkMode = false,
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
              return _ActivePill(pill: activeFilters[index], isDarkMode: isDarkMode);
            }
            final i = index - activeFilters.length;

            if (i < selectedChips.length) {
              return _ChipItem(
                chip: selectedChips[i],
                isActive: true,
                onTap: onChipTap,
                isDarkMode: isDarkMode,
              );
            }

            final chip = serverChips[i - selectedChips.length];
            return _ChipItem(chip: chip, isActive: false, onTap: onChipTap, isDarkMode: isDarkMode);
          },
        ),
      ),
    );
  }
}

class _ActivePill extends StatelessWidget {
  final ActiveFilterPill pill;
  final bool isDarkMode;

  const _ActivePill({required this.pill, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pill.onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFFFFFFFF) : blackColor,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                  ? const Color(0xFFFFFFFF).withOpacity(0.2)
                  : blackColor.withOpacity(0.22),
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
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? const Color(0xFF202020) : Colors.white,
                fontFamily: 'InstrumentSans',
                letterSpacing: 0.2,
                height: 1,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.close_rounded,
              size: 12,
              color: isDarkMode 
                  ? const Color(0xFF202020).withOpacity(0.7)
                  : Colors.white70,
            ),
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
  final bool isDarkMode;

  const _ChipItem({
    required this.chip,
    required this.isActive,
    required this.onTap,
    this.isDarkMode = false,
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
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: _getBorderColor(),
            width: 1,
          ),
          boxShadow: _getBoxShadow(),
        ),
        child: Center(
          child: isActive
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      chip.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(),
                        fontFamily: 'InstrumentSans',
                        letterSpacing: 0.2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: _getTextColor().withOpacity(0.7),
                    ),
                  ],
                )
              : Text(
                  chip.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _getTextColor(),
                    fontFamily: 'InstrumentSans',
                    letterSpacing: 0.2,
                    height: 1,
                  ),
                ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isDarkMode) {
      // Dark mode: white when selected, dark gray when not
      return isActive ? const Color(0xFFFFFFFF) : const Color(0xFF202020);
    } else {
      // Light mode: black when selected, light gray when not
      return isActive ? blackColor : const Color(0xFFF9F9FB);
    }
  }

  Color _getBorderColor() {
    if (isDarkMode) {
      // Dark mode: no visible border needed (bg is distinct enough)
      return isActive ? const Color(0xFFFFFFFF) : const Color(0xFF202020);
    } else {
      // Light mode: original styling
      return isActive ? blackColor : const Color(0xFFE5E7EB);
    }
  }

  Color _getTextColor() {
    if (isDarkMode) {
      // Dark mode: dark text when selected, light gray when not
      return isActive ? const Color(0xFF202020) : const Color(0xFFA8A8A8);
    } else {
      // Light mode: white text when selected, gray when not
      return isActive ? Colors.white : const Color(0xFF6B7280);
    }
  }

  List<BoxShadow> _getBoxShadow() {
    if (isDarkMode) {
      // Dark mode: subtle shadow
      return isActive
          ? [
              BoxShadow(
                color: const Color(0xFFFFFFFF).withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ]
          : [];
    } else {
      // Light mode: original shadows
      return isActive
          ? [
              BoxShadow(
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
            ];
    }
  }
}
