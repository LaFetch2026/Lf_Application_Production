part of 'product_details_screen_v2.dart';

// ── zoomable image widget ─────────────────────────────────────────────────────

class _ZoomableImage extends StatefulWidget {
  final String imageUrl;
  const _ZoomableImage({required this.imageUrl});
  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  final TransformationController _ctrl = TransformationController();
  late final AnimationController _nudgeCtrl;
  late final Animation<Matrix4> _nudgeAnim;

  @override
  void initState() {
    super.initState();
    _nudgeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // Nudge: zoom to 1.15x at centre, then snap back
    final zoomed = Matrix4.identity()..scale(1.15);
    _nudgeAnim = Matrix4Tween(begin: Matrix4.identity(), end: zoomed).animate(
      CurvedAnimation(
        parent: _nudgeCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    )..addListener(() => _ctrl.value = _nudgeAnim.value);

    // Fire once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nudgeCtrl.forward().then((_) => _nudgeCtrl.reverse());
    });
  }

  void _reset() => _ctrl.value = Matrix4.identity();

  @override
  void dispose() {
    _nudgeCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onScaleEnd: (_) => _reset(),
          child: InteractiveViewer(
            transformationController: _ctrl,
            minScale: 1.0,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              width: double.infinity,
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.black.withOpacity(0.06),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            color: Colors.grey.withOpacity(0.5), size: 48),
                        const SizedBox(height: 8),
                        const Text("Size guide image unavailable",
                            style: TextStyle(color: Colors.grey, fontSize: 12))
                      ])),
            ),
          ),
        ),
      );
}
