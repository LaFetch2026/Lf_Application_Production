// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../managers/swipe_overlay_manager.dart';
import '../models/swipe_product.dart';
import '../services/swipe_tracking_service.dart';

/// The draggable product card for the swipe feed.
/// Handles gesture detection, tilt, image cycling, overlays, and fly-off animation.
class SwipeCard extends StatefulWidget {
  final SwipeProduct product;
  final bool isTop;
  final double scale;
  final double verticalOffset;
  final void Function(SwipeAction action) onSwiped;

  /// Called by the controller when the swipe-up flow resolves with dismiss or
  /// failure — animates the card back to center gracefully.
  final VoidCallback? onSwipeUpReset;

  /// Called by the controller immediately before removing the card on a
  /// successful add-to-cart — animates the card upward off-screen.
  final VoidCallback? onSwipeUpFlyUp;

  const SwipeCard({
    super.key,
    required this.product,
    required this.isTop,
    required this.scale,
    required this.verticalOffset,
    required this.onSwiped,
    this.onSwipeUpReset,
    this.onSwipeUpFlyUp,
  });

  @override
  State<SwipeCard> createState() => SwipeCardState();
}

class SwipeCardState extends State<SwipeCard> with TickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  bool _isFlying = false;
  // When true, the swipe-up flow is in progress — gestures are suppressed and
  // _dragOffset is held at its current value until the controller resolves.
  bool _swipeUpLocked = false;
  int _currentImageIndex = 0;

  late final AnimationController _flyController;
  Animation<Offset>?
      _flyAnimation; // nullable — only set when _flyOff() is called

  // Used for the spring-back animation on dismiss/failure
  late final AnimationController _resetController;
  Animation<Offset>?
      _resetAnimation; // nullable — only set when resetSwipeUp() is called

  // Overlay animation controller (NEW)
  late final AnimationController _overlayController;

  // Overlay configuration (NEW)
  OverlayConfig? _overlayConfig;

  // Current overlay type to render (NEW)
  OverlayType? _currentOverlayType;

  static const double _horizontalThreshold = 80.0;
  static const double _verticalThreshold = 60.0;
  static const Duration _flyDuration = Duration(milliseconds: 220);
  static const Duration _flyUpDuration = Duration(milliseconds: 300);
  static const Duration _resetDuration = Duration(milliseconds: 420);

  static const Color _likeColor = Color(0xFF988AFF);
  static const Color _nopeColor = Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
    _flyController = AnimationController(vsync: this, duration: _flyDuration);
    _flyController.addListener(() {
      if (mounted) setState(() {});
    });

    _resetController =
        AnimationController(vsync: this, duration: _resetDuration);
    _resetController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize overlay controller (NEW)
    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    print("🗑️ SwipeCardState.dispose() — cleaning up animation controllers");
    _overlayController.dispose();
    _flyController.dispose();
    _resetController.dispose();
    super.dispose();
  }

  // ── Public API (called by SwipeFeedScreen via GlobalKey) ──────────────────

  /// Animate the card upward off-screen (success path).
  /// Called by the controller immediately before removing the card.
  void triggerFlyUp() {
    if (!mounted) return;
    _swipeUpLocked = false;
    final flyUpController = AnimationController(
      vsync: this,
      duration: _flyUpDuration,
    );
    final flyUpAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: const Offset(0, -700),
    ).animate(
        CurvedAnimation(parent: flyUpController, curve: Curves.easeInCubic));
    flyUpController.addListener(() {
      if (mounted) {
        setState(() => _dragOffset = flyUpAnimation.value);
      }
    });
    flyUpController.forward().then((_) {
      if (mounted) {
        flyUpController.dispose();
      } else {
        // Widget was removed before animation completed — dispose immediately
        flyUpController.dispose();
      }
    });
  }

  /// Spring-animate the card back to center (dismiss/failure path).
  /// Called by the controller when the size sheet is dismissed or cart add fails.
  void resetSwipeUp() {
    if (!mounted) return;
    final startOffset = _dragOffset;
    _resetAnimation = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _resetController, curve: Curves.elasticOut));
    _resetController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _dragOffset = Offset.zero;
          _swipeUpLocked = false;
        });
      }
    });
  }

  /// Display overlay with animation (NEW)
  /// Called by the controller to show text or icon overlay after a swipe action.
  void showOverlay(OverlayType type, OverlayConfig config) {
    if (!mounted) return;

    _currentOverlayType = type;
    _overlayConfig = config;
    _overlayController.duration = config.duration;
    _overlayController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _overlayConfig = null;
          _currentOverlayType = null;
        });
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_isFlying || _swipeUpLocked) return;
    setState(() => _dragOffset += d.delta);
  }

  void _onPanEnd(DragEndDetails _) {
    if (_isFlying || _swipeUpLocked) return;
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;

    if (dy.abs() > dx.abs()) {
      if (dy < -_verticalThreshold) {
        // Swipe up: hold the card at its dragged position while the async
        // add-to-cart flow runs. The controller will call triggerFlyUp() on
        // success or resetSwipeUp() on dismiss/failure.
        setState(() => _swipeUpLocked = true);
        widget.onSwiped(SwipeAction.swipeUp);
        return;
      } else if (dy > _verticalThreshold) {
        setState(() => _dragOffset = Offset.zero);
        widget.onSwiped(SwipeAction.swipeDown);
        return;
      }
    } else {
      if (dx > _horizontalThreshold) {
        _flyOff(SwipeAction.likeProduct, const Offset(400, 0));
        return;
      } else if (dx < -_horizontalThreshold) {
        _flyOff(SwipeAction.dislikeProduct, const Offset(-400, 0));
        return;
      }
    }
    setState(() => _dragOffset = Offset.zero);
  }

  void _flyOff(SwipeAction action, Offset exit) {
    _isFlying = true;
    _flyAnimation = Tween<Offset>(begin: _dragOffset, end: exit).animate(
        CurvedAnimation(parent: _flyController, curve: Curves.easeOut));
    _flyController.forward(from: 0).then((_) => widget.onSwiped(action));
  }

  Offset get _drag {
    if (_isFlying && _flyAnimation != null) return _flyAnimation!.value;
    if (_resetController.isAnimating && _resetAnimation != null)
      return _resetAnimation!.value;
    return _dragOffset;
  }

  double get _overlayOpacity {
    final d = _drag;
    if (d.dy.abs() > d.dx.abs()) {
      return (d.dy.abs() / _verticalThreshold).clamp(0.0, 1.0);
    }
    return (d.dx.abs() / _horizontalThreshold).clamp(0.0, 1.0);
  }

  /// Returns the tint color for the current drag direction, or null at rest.
  Color? get _overlayColor {
    final d = _drag;
    if (d.dy.abs() > d.dx.abs()) {
      if (d.dy < -30) return Colors.black; // swipe-up → black tint
      if (d.dy > 30) return const Color(0xFF374151); // swipe-down → dark grey
    } else {
      if (d.dx > 30) return _likeColor; // right → lavender
      if (d.dx < -30) return _nopeColor; // left → red
    }
    return null;
  }

  // ── Price ─────────────────────────────────────────────────────────────────

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
          .format(v);

  int? get _discount {
    final mrp = widget.product.mrp;
    final price = widget.product.sellingPrice;
    if (mrp != null && mrp > price && mrp > 0) {
      return ((mrp - price) / mrp * 100).round();
    }
    return null;
  }

  /// Build the appropriate overlay widget based on type (NEW)
  Widget _buildOverlay() {
    if (_overlayConfig == null || _currentOverlayType == null) {
      return const SizedBox.shrink();
    }

    return switch (_currentOverlayType!) {
      OverlayType.textFull => _buildTextOverlay(),
      OverlayType.iconOnly => _buildIconOverlay(),
    };
  }

  /// Build text overlay widget with fade animation (NEW)
  Widget _buildTextOverlay() {
    return AnimatedBuilder(
      animation: _overlayController,
      builder: (context, child) {
        final progress = _overlayController.value;
        // Fade in for first 50%, fade out for second 50%
        final opacity = progress < 0.5 ? progress * 2 : (1 - progress) * 2;

        return Opacity(
          opacity: opacity.clamp(0, 1),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 14.sp),
              decoration: BoxDecoration(
                color: const Color(0xFF988AFF),
                borderRadius: BorderRadius.circular(30.sp),
              ),
              child: Text(
                'Added to Cart',
                style: TextStyle(
                  fontFamily: 'Clash Display Semibold',
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build icon overlay widget with fade animation (NEW)
  Widget _buildIconOverlay() {
    return AnimatedBuilder(
      animation: _overlayController,
      builder: (context, child) {
        final progress = _overlayController.value;
        // Fade in for first 50%, fade out for second 50%
        final opacity = progress < 0.5 ? progress * 2 : (1 - progress) * 2;

        return Opacity(
          opacity: opacity.clamp(0, 1),
          child: Center(
            child: Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 50.sp,
            ),
          ),
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final drag = _drag;
    final rotation = drag.dx / 300.0;

    Widget card = _buildCardContent();

    card = Transform.rotate(angle: rotation, child: card);
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

  Widget _buildCardContent() {
    final p = widget.product;
    final images = p.imageUrls.isNotEmpty
        ? p.imageUrls
        : (p.imageUrl.isNotEmpty ? [p.imageUrl] : <String>[]);
    final tintColor = _overlayColor;
    final discount = _discount;

    return Container(
      decoration: BoxDecoration(
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
            // Grey bg (always visible behind transparent images)
            Positioned.fill(child: Container(color: Colors.grey[200])),

            // Product image
            if (images.isNotEmpty)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: images[_currentImageIndex],
                  fit: BoxFit.cover,
                  memCacheWidth: 1200,
                  memCacheHeight: 1200,
                  placeholder: (_, __) => Container(color: Colors.grey[200]),
                  errorWidget: (_, __, ___) =>
                      Container(color: Colors.grey[200]),
                ),
              ),

            // Image cycling tap zones (left / right halves)
            if (images.length > 1 && widget.isTop)
              Positioned.fill(
                child: Row(
                  children: [
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

            // Image dot indicator
            if (images.length > 1)
              Positioned(
                top: 10.sp,
                left: 0,
                right: 0,
                child: _ImageDots(
                  count: images.length.clamp(0, 6),
                  current: _currentImageIndex,
                ),
              ),

            // Bottom gradient
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 200.sp,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xEE000000), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Product info
            Positioned(
              left: 16.sp,
              right: 56.sp,
              bottom: 20.sp,
              child: _ProductInfo(
                product: p,
                discount: discount,
                formatPrice: _fmt,
              ),
            ),

            // NEW badge
            if (p.isNew)
              Positioned(
                top: images.length > 1 ? 22.sp : 12.sp,
                left: 12.sp,
                child: _NewBadge(),
              ),

            // Swipe tint overlay (color only, no label)
            if (tintColor != null && widget.isTop)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: _overlayOpacity * 0.55,
                    child: Container(
                      decoration: BoxDecoration(
                        color: tintColor,
                        borderRadius: BorderRadius.circular(16.sp),
                      ),
                    ),
                  ),
                ),
              ),

            // Text/Icon overlay (NEW)
            if (_overlayConfig != null && widget.isTop)
              Positioned.fill(
                child: IgnorePointer(
                  child: _buildOverlay(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ImageDots extends StatelessWidget {
  final int count;
  final int current;
  const _ImageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 2.sp),
          width: i == current ? 16.sp : 5.sp,
          height: 4.sp,
          decoration: BoxDecoration(
            color: i == current ? Colors.white : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(2.sp),
          ),
        );
      }),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final SwipeProduct product;
  final int? discount;
  final String Function(double) formatPrice;

  const _ProductInfo({
    required this.product,
    required this.discount,
    required this.formatPrice,
  });

  static const Color _likeColor = Color(0xFF988AFF);

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand
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
        // Product name
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
              formatPrice(p.sellingPrice),
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
                formatPrice(p.mrp!),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.sp, vertical: 2.sp),
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
        // Category + rating
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
              Text('  ·  ',
                  style: TextStyle(color: Colors.white60, fontSize: 11.sp)),
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
    );
  }
}

class _NewBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
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
    );
  }
}
