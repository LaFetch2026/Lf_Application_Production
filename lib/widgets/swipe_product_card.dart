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

  late final AnimationController _flyController;
  late Animation<Offset> _flyAnimation;

  static const double _horizontalThreshold = 80.0;
  static const double _verticalThreshold = 60.0;
  static const Duration _flyDuration = Duration(milliseconds: 220);

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

    // Direction priority: |dy| > |dx| → vertical, else horizontal
    if (absDy > absDx) {
      if (dy < -_verticalThreshold) {
        _triggerFlyOff(SwipeAction.swipeUp, const Offset(0, -700));
        return;
      } else if (dy > _verticalThreshold) {
        _triggerFlyOff(SwipeAction.swipeDown, const Offset(0, 700));
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

    // Sub-threshold: snap back
    setState(() => _dragOffset = Offset.zero);
  }

  void _triggerFlyOff(SwipeAction action, Offset exitOffset) {
    _isFlying = true;
    _flyAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: exitOffset,
    ).animate(CurvedAnimation(
      parent: _flyController,
      curve: Curves.easeOut,
    ));

    _flyController.forward(from: 0).then((_) {
      widget.onSwiped(action);
    });
  }

  // ── Overlay helpers ──────────────────────────────────────────────────────

  Offset get _effectiveDrag =>
      _isFlying ? _flyAnimation.value : _dragOffset;

  double get _overlayOpacity {
    final dx = _effectiveDrag.dx;
    final dy = _effectiveDrag.dy;
    final absDx = dx.abs();
    final absDy = dy.abs();

    if (absDy > absDx) {
      return (absDy / _verticalThreshold).clamp(0.0, 1.0);
    } else {
      return (absDx / _horizontalThreshold).clamp(0.0, 1.0);
    }
  }

  _OverlayInfo? get _activeOverlay {
    final dx = _effectiveDrag.dx;
    final dy = _effectiveDrag.dy;
    final absDx = dx.abs();
    final absDy = dy.abs();

    if (absDy > absDx) {
      if (dy < -30) {
        return const _OverlayInfo(
          color: Color(0xFF988AFF),
          label: 'SAVE ⬆',
        );
      } else if (dy > 30) {
        return const _OverlayInfo(
          color: Color(0xFF9E9E9E),
          label: 'SKIP ↓',
        );
      }
    } else {
      if (dx > 30) {
        return const _OverlayInfo(
          color: Color(0xFF4CAF50),
          label: 'LIKE ❤️',
        );
      } else if (dx < -30) {
        return const _OverlayInfo(
          color: Color(0xFFF44336),
          label: 'NOPE ✕',
        );
      }
    }
    return null;
  }

  // ── Price helpers ────────────────────────────────────────────────────────

  String _formatPrice(double value) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(value);
  }

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

    // Apply tilt rotation
    card = Transform.rotate(
      angle: rotationAngle,
      child: card,
    );

    // Apply scale + vertical offset for stack depth
    card = Transform.translate(
      offset: Offset(0, widget.verticalOffset),
      child: Transform.scale(
        scale: widget.scale,
        child: card,
      ),
    );

    // Apply drag translation (only for top card)
    if (widget.isTop) {
      card = Transform.translate(
        offset: drag,
        child: card,
      );
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.sp),
      child: Stack(
        children: [
          // ── Product image ──────────────────────────────────────────────
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: widget.product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: colorSecondary),
              errorWidget: (_, __, ___) => Container(
                color: colorSecondary,
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 48.sp,
                ),
              ),
            ),
          ),

          // ── Bottom gradient overlay ────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 180.sp,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xDD000000),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Product info ───────────────────────────────────────────────
          Positioned(
            left: 16.sp,
            right: 16.sp,
            bottom: 20.sp,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand name
                if (widget.product.brandName.isNotEmpty)
                  Text(
                    widget.product.brandName.toUpperCase(),
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
                // Product name
                Text(
                  widget.product.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Clash Display',
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.sp),
                // Price row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _formatPrice(widget.product.sellingPrice),
                      style: TextStyle(
                        fontFamily: 'Clash Display Semibold',
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                    if (widget.product.mrp != null &&
                        widget.product.mrp! > widget.product.sellingPrice) ...[
                      SizedBox(width: 8.sp),
                      Text(
                        _formatPrice(widget.product.mrp!),
                        style: TextStyle(
                          fontFamily: 'Clash Display',
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,
                          color: Colors.white54,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.white54,
                        ),
                      ),
                      if (discount != null) ...[
                        SizedBox(width: 6.sp),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.sp, vertical: 2.sp),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
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
              ],
            ),
          ),

          // ── NEW badge ──────────────────────────────────────────────────
          if (widget.product.isNew)
            Positioned(
              top: 12.sp,
              left: 12.sp,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                decoration: BoxDecoration(
                  color: const Color(0xFF988AFF),
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

          // ── Swipe direction overlay ────────────────────────────────────
          if (overlay != null && widget.isTop)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: opacity,
                duration: Duration.zero,
                child: Container(
                  decoration: BoxDecoration(
                    color: overlay.color.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(16.sp),
                  ),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.sp, vertical: 10.sp),
                      decoration: BoxDecoration(
                        color: overlay.color,
                        borderRadius: BorderRadius.circular(8.sp),
                        boxShadow: [
                          BoxShadow(
                            color: overlay.color.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        overlay.label,
                        style: TextStyle(
                          fontFamily: 'Clash Display Semibold',
                          fontWeight: FontWeight.w700,
                          fontSize: 22.sp,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OverlayInfo {
  final Color color;
  final String label;
  const _OverlayInfo({required this.color, required this.label});
}
