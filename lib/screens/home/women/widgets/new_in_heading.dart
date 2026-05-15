import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NewInHeading extends StatefulWidget {
  final String asset;
  final double height;

  const NewInHeading({
    super.key,
    required this.asset,
    required this.height,
  });

  @override
  State<NewInHeading> createState() => NewInHeadingState();
}

class NewInHeadingState extends State<NewInHeading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // tweak scroll speed here
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hoisted once — never rebuilt during animation
    final svgChild = SvgPicture.asset(
      widget.asset,
      height: widget.height,
      fit: BoxFit.contain,
    );

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerWidth = constraints.maxWidth;

          return ClipRect(
            child: SizedBox(
              width: containerWidth,
              height: widget.height,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // ── Seamless marquee ──────────────────────────────
                  // Two copies scroll together. When copy-1 exits left,
                  // copy-2 is already filling the gap — zero visual jump.
                  AnimatedBuilder(
                    animation: _controller,
                    child: svgChild, // child hoisted: SVG decoded once
                    builder: (context, child) {
                      final dx = _controller.value * containerWidth;
                      return Stack(
                        children: [
                          // Copy 1: 0 → -containerWidth
                          Transform.translate(
                            offset: Offset(-dx, 0),
                            child: child,
                          ),
                          // Copy 2: containerWidth → 0
                          Transform.translate(
                            offset: Offset(containerWidth - dx, 0),
                            child: child,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DotMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final hPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..strokeWidth = 0.8;

    for (double y = 0; y < size.height; y += 2.5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hPaint);
    }

    final vPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 3.0) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), vPaint);
    }

    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant DotMatrixPainter oldDelegate) => false;
}
