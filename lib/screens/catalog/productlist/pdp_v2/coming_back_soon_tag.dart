import 'package:flutter/material.dart';

/// ComingBackSoonTag displays a badge indicating that an out-of-stock product
/// will be available again in the future.
///
/// **Validates: Requirements 3.1, 3.2, 3.3**
///
/// The tag is positioned absolutely at the top-right corner of the product image
/// with a distinct color (orange/amber) and semi-transparent background.
class ComingBackSoonTag extends StatelessWidget {
  /// Position offset for the tag (typically top-right corner)
  final Offset position;

  /// Whether the tag should be visible
  final bool isVisible;

  /// Optional custom background color
  final Color? backgroundColor;

  /// Optional custom text color
  final Color? textColor;

  /// Optional custom text
  final String text;

  const ComingBackSoonTag({
    Key? key,
    required this.position,
    this.isVisible = true,
    this.backgroundColor,
    this.textColor,
    this.text = 'Coming Back Soon',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: position.dy,
      right: position.dx,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFFF9800).withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Clash Display',
          ),
        ),
      ),
    );
  }
}
