// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../core/constant/constants.dart';
import '../models/recommendation_event.dart';
import '../services/event_tracking_service.dart';

class SwipeProductCard extends StatefulWidget {
  final RecommendationProduct product;
  final bool isTop;
  final double scale;
  final double verticalOffset;
  final void Function(SwipeAction action) onSwiped;

  const SwipeProductCard({
    super.key,
    required this.product,
    required this.isTop,
    required this.scale,
    required this.verticalOffset,
    required this.onSwiped,
  });

  @override
  State<SwipeProductCard> createState() => _SwipeProductCardState();
}

class _SwipeProductCardState extends State<SwipeProductCard>
    with TickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  bool _isFlying = false;
  int _currentImageIndex = 0;

  late final AnimationController _flyController;
  late Animation<Offset> _flyAnimation;

  static const double _horizontalThreshold = 80.0;
  static const double _verticalThreshold = 60.0;
  static const Duration _flyDuration = Duration(milliseconds: 220);

  // Lavender for like, matches lightPurpleColor
  static const Color _likeColor = Color(0xFF988AFF);
  static const Color _nopeColor = Color(0xFFF44336);
  static const Color _saveColor = Color(0xFF988AFF);
  static const Color _pdpColor = Color(0xFF374151);

  @override
  void initState() {
    super.initState();
    _flyController = AnimationController(vsync: this, duration: _flyDuration);
    _flyController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _flyController.dispose();
    super.dispose();
  }

  // ── Gesture helpers ──────────────────────────────────────────────────────

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isFlying) return;
    setState(() => _dragOffset += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isFlying) return;

    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;
    final absDx = dx.abs();
    final absDy = dy.abs();

    if (absDy > absDx) {
      if (dy < -_verticalThreshold) {
        _triggerFlyOff(SwipeAction.swipeUp, const Offset(0, -700));
        return;
      } else if (dy > _verticalThreshold) {
        // Swipe down → open PDP (no fly-off, just navigate)
        setState(() => _dragOffset = Offset.zero);
        widget.onSwiped(SwipeAction.swipeDown);
        return;
      }
    } else {
      if (dx > _horizontalThreshold) {
        _triggerFlyOff(SwipeAction.likeProduct, const Offset(400, 0));
        return;
      } else if (dx < -_horizontalThreshold) {
        _triggerFlyOff(SwipeAction.dislikeProduct, const Offset(-400, 0));
        return;
      }
    }

    setState(() => _dragOffset = Offset.zero);
  }

  void _triggerFlyOff(SwipeAction action, Offset exitOffset) {
    _isFlying = true;
    _flyAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: exitOffset,
    ).animate(CurvedAnimation(parent: _flyController, curve: Curves.easeOut));

    _flyController.forward(from: 0).then((_) {
      widget.onSwiped(action);
    });
  }

  // ── Overlay helpers ──────────────────────────────────────────────────────

  Offset get _effectiveDrag => _isFlying ? _flyAnimation.value : _dragOffset;

  double get _overlayOpacity {
    final dx = _effectiveDrag.dx;
    final dy = _effectiveDrag.dy;
    if (dy.abs() > dx.abs()) {
      return (dy.abs() / _verticalThreshold).clamp(0.0, 1.0);
    }
    return (dx.abs() / _horizontalThreshold).clamp(0.0, 1.0);
  }

  _OverlayInfo? get _activeOverlay {
    final dx = _effectiveDrag.dx;
    final dy = _effectiveDrag.dy;
    if (dy.abs() > dx.abs()) {
      if (dy < -30) return const _OverlayInfo(color: Color(0xFF988AFF), label: '', icon: Icons.bookmark_add_outlined);
      if (dy > 30) return const _OverlayInfo(color: Color(0xFF374151), label: '', icon: Icons.open_in_new);
    } else {
      if (dx > 30) return const _OverlayInfo(color: Color(0xFF988AFF), label: '', icon: Icons.favorite_outline);
      if (dx < -30) return const _OverlayInfo(color: Color(0xFFF44336), label: '', icon: Icons.close);
    }
    return null;
  }

  // ── Price helpers ────────────────────────────────────────────────────────

  String _formatPrice(double value) => NumberFormat.currency(
        locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(value);

  int? get _discountPercent {
    final mrp = widget.product.mrp;
    final price = widget.product.sellingPrice;
    if (mrp != null && mrp > price && mrp > 0) {
      return ((mrp - price) / mrp * 100).round();
    }
    return null;
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final drag = _effectiveDrag;
    final rotationAngle = drag.dx / 300.0;

    Widget card = _buildCard();

    card = Transform.rotate(angle: rotationAngle, child: card);
    card = Transform.translate(
      offset: Offset(0, widget.verticalOffset),
      child: Transform.scale(scale: widget.scale, child: card),
    );

    if (widget.isTop) {
      card = Transform.translate(offset: drag, child: card);
    }

    if (!widget.isTop) return card;

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: card,
    );
  }

  Widget _buildCard() {
    final overlay = _activeOverlay;
    final opacity = _overlayOpacity;
    final discount = _discountPercent;
    final p = widget.product;
    final images = p.imageUrls.isNotEmpty ? p.imageUrls : (p.imageUrl.isNotEmpty ? [p.imageUrl] : <String>[]);

    return Container(
      decoration: BoxDecoration(
        // Grey bg for transparent/missing images
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.sp),
        child: Stack(
          children: [
            // ── Grey background (always present, shows through transparent images) ──
            Positioned.fill(child: Container(color: Colors.grey[200])),

            // ── Product image ──────────────────────────────────────────────
            if (images.isNotEmpty)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: images[_currentImageIndex],
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[200]),
                  errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
                ),
              ),

            // ── Multi-image tap zones (left/right thirds) ──────────────────
            if (images.length > 1 && widget.isTop)
              Positioned.fill(
                child: Row(
                  children: [
                    // Left tap → previous image
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (_currentImageIndex > 0) {
                            setState(() => _currentImageIndex--);
                          }
                        },
                        child: const SizedBox.expand(),
                      ),
                    ),
                    // Right tap → next image
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (_currentImageIndex < images.length - 1) {
                            setState(() => _currentImageIndex++);
                          }
                        },
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Image dots indicator ───────────────────────────────────────
            if (images.length > 1)
              Positioned(
                top: 10.sp,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length.clamp(0, 6), (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 2.sp),
                      width: i == _currentImageIndex ? 16.sp : 5.sp,
                      height: 4.sp,
                      decoration: BoxDecoration(
                        color: i == _currentImageIndex
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2.sp),
                      ),
                    );
                  }),
                ),
              ),

            // ── Bottom gradient ────────────────────────────────────────────
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                height: 200.sp,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xEE000000), Colors.transparent],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),

            // ── Product info ───────────────────────────────────────────────
            Positioned(
              left: 16.sp, right: 56.sp, bottom: 20.sp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (p.brandName.isNotEmpty)
                    Text(
                      p.brandName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Clash Display Semibold',
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                        color: Colors.white70,
                        letterSpacing: 1.0,
                      ),
                    ),
                  SizedBox(height: 2.sp),
                  Text(
                    p.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Clash Display',
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.sp),
                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _formatPrice(p.sellingPrice),
                        style: TextStyle(
                          fontFamily: 'Clash Display Semibold',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                      if (p.mrp != null && p.mrp! > p.sellingPrice) ...[
                        SizedBox(width: 6.sp),
                        Text(
                          _formatPrice(p.mrp!),
                          style: TextStyle(
                            fontFamily: 'Clash Display',
                            fontSize: 12.sp,
                            color: Colors.white54,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.white54,
                          ),
                        ),
                        if (discount != null) ...[
                          SizedBox(width: 5.sp),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 2.sp),
                            decoration: BoxDecoration(
                              color: _likeColor,
                              borderRadius: BorderRadius.circular(4.sp),
                            ),
                            child: Text(
                              '$discount% OFF',
                              style: TextStyle(
                                fontFamily: 'Clash Display Semibold',
                                fontWeight: FontWeight.w600,
                                fontSize: 9.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                  // Category + rating row
                  SizedBox(height: 4.sp),
                  Row(
                    children: [
                      if (p.category.isNotEmpty)
                        Text(
                          p.category,
                          style: TextStyle(
                            fontFamily: 'Clash Display Regular',
                            fontSize: 11.sp,
                            color: Colors.white60,
                          ),
                        ),
                      if (p.category.isNotEmpty && p.rating != null && p.rating! > 0)
                        Text('  ·  ', style: TextStyle(color: Colors.white60, fontSize: 11.sp)),
                      if (p.rating != null && p.rating! > 0) ...[
                        Icon(Icons.star_rounded, color: Colors.amber, size: 13.sp),
                        SizedBox(width: 2.sp),
                        Text(
                          p.rating!.toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: 'Clash Display Regular',
                            fontSize: 11.sp,
                            color: Colors.white70,
                          ),
                        ),
                        if (p.numReviews != null && p.numReviews! > 0)
                          Text(
                            ' (${p.numReviews})',
                            style: TextStyle(
                              fontFamily: 'Clash Display Regular',
                              fontSize: 10.sp,
                              color: Colors.white54,
                            ),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── NEW badge ──────────────────────────────────────────────────
            if (p.isNew)
              Positioned(
                top: images.length > 1 ? 22.sp : 12.sp,
                left: 12.sp,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                  decoration: BoxDecoration(
                    color: _likeColor,
                    borderRadius: BorderRadius.circular(6.sp),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      fontFamily: 'Clash Display Semibold',
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

            // ── Swipe direction overlay (color tint only, no label) ───────
            if (overlay != null && widget.isTop)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: opacity * 0.55,
                    child: Container(
                      decoration: BoxDecoration(
                        // swipe-up uses black tint, others use their color
                        color: overlay.icon == Icons.bookmark_add_outlined
                            ? Colors.black
                            : overlay.color,
                        borderRadius: BorderRadius.circular(16.sp),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OverlayInfo {
  final Color color;
  final String label;
  final IconData icon;
  const _OverlayInfo({required this.color, required this.label, required this.icon});
}
