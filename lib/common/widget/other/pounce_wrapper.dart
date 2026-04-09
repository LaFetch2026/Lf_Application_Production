import 'package:flutter/material.dart';

class PounceWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;

  const PounceWrapper({
    Key? key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.96,
    this.duration = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  State<PounceWrapper> createState() => _PounceWrapperState();
}

class _PounceWrapperState extends State<PounceWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutQuad,
          reverseCurve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapCancel: _onTapCancel,
        onTap: () {
          if (widget.onTap != null) {
            // A tiny delay ensures the scale animation paints to the screen before
            // synchronous heavy operations like page navigation lock the main thread.
            Future.delayed(const Duration(milliseconds: 60), () {
              if (mounted) widget.onTap!();
            });
          }
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: RepaintBoundary(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
