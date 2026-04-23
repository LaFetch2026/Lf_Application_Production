import 'dart:math' as math;
import 'package:flutter/material.dart';

class LfLogoLoader extends StatefulWidget {
  const LfLogoLoader({
    super.key,
    this.size = 54,
    this.logoAsset = 'assets/images/lafetch_logo.png',
    this.brandColor = Colors.grey,
    // this.brandColor = const Color(0xFFB58CFF),
    this.backgroundColor = Colors.transparent,
    this.showGlow = true,
  });

  final double size;
  final String logoAsset;
  final Color brandColor;

  final Color backgroundColor;
  final bool showGlow;

  @override
  State<LfLogoLoader> createState() => _LfLogoLoaderState();
}

class _LfLogoLoaderState extends State<LfLogoLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: Image.asset(
          widget.logoAsset,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.low,
        ),
        builder: (context, child) {
          // Linear progress → constant-velocity shimmer sweep.
          final double progress = _controller.value;

          // Eased progress → natural breathing feel for pulse + glow.
          final double eased = Curves.easeInOutCubic.transform(progress);

          // Subtle scale breath.
          final double pulse = 0.975 + 0.035 * math.sin(eased * math.pi * 2);

          // abs(sin) mirrors smoothly; glow never snaps at the loop boundary.
          final double glowOpacity = widget.showGlow
              ? 0.10 + 0.08 * math.sin(eased * math.pi * 2).abs()
              : 0.0;

          // Shimmer sweeps from off-screen-left to off-screen-right.
          // Range [-0.35 … 1.35] means it's invisible at t=0 and t=1,
          // and centred at t≈0.5 — no pop-in or pop-out at the loop edge.
          final double shimmerCenter = progress * 1.7 - 0.35;
          const double shimmerHalfWidth = 0.18;

          // Clamp stops so LinearGradient always receives a valid 0..1 range.
          // When shimmerCenter is off either edge all three stops collapse to
          // the same boundary value, making the logo render as solid
          // brandColor — which is correct (shimmer is off-screen).
          final double s1 = (shimmerCenter - shimmerHalfWidth).clamp(0.0, 1.0);
          final double s2 = shimmerCenter.clamp(0.0, 1.0);
          final double s3 = (shimmerCenter + shimmerHalfWidth).clamp(0.0, 1.0);

          return SizedBox(
            width: size * 1.6,
            height: size * 1.6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Soft radial glow ──────────────────────────────────
                if (widget.showGlow)
                  Container(
                    width: size * 1.15,
                    height: size * 1.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.brandColor.withValues(alpha: glowOpacity),
                          widget.brandColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),

                // ── Logo: tint + shimmer in a single ShaderMask pass ──
                //
                // BlendMode.srcIn outputs:
                //   colour  = shader gradient colour
                //   alpha   = child (logo) alpha
                //
                // This means:
                //   • The logo shape clips the gradient naturally — no
                //     separate clipping or second image needed.
                //   • The gradient carries both the brand tint and the
                //     travelling white highlight in one operation.
                Transform.scale(
                  scale: pulse,
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          widget.brandColor,
                          widget.brandColor,
                          // Peak highlight — 75 % blend toward white.
                          Color.lerp(widget.brandColor, Colors.white, 0.75)!,
                          widget.brandColor,
                          widget.brandColor,
                        ],
                        stops: [0.0, s1, s2, s3, 1.0],
                      ).createShader(bounds);
                    },
                    child: child!, // the cached Image.asset from above
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Drop-in centred loader for pull-to-refresh headers, full-screen
/// overlays, and empty-state screens.
class LfLoaderWidget extends StatelessWidget {
  const LfLoaderWidget({
    super.key,
    this.size = 54,
    this.message,
    this.brandColor = const Color(0xFFB58CFF),
  });

  final double size;
  final String? message;
  final Color brandColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LfLogoLoader(
          size: size,
          brandColor: brandColor,
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(
            message!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              color: brandColor.withValues(alpha: 0.9),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/*
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PRECACHE — call once near your app root so the image
  is ready before the first loader frame is painted.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(
      const AssetImage('assets/images/lafetch_logo.png'),
      context,
    );
  }

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  USAGE — pull-to-refresh custom header
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  RefreshIndicator(
    color: Colors.transparent,
    backgroundColor: Colors.transparent,
    onRefresh: _refresh,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [ /* your content */ ],
    ),
  )

  // Inside your custom indicator builder:
  PremiumLogoLoader(
    size: 44,
    logoAsset: 'assets/images/lafetch_logo.png',
    brandColor: lightPurpleColor,
  )

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  USAGE — loading overlay / empty state
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  const PremiumLogoLoaderCenter(
    size: 54,
    message: 'Loading…',
    brandColor: Color(0xFFB58CFF),
  )
*/
