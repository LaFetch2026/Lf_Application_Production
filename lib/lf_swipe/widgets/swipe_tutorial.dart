// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Full-screen first-time tutorial overlay.
/// Shows 5 animated steps explaining the swipe gestures.
/// Dismissed via Next/Let's go or Skip. Persisted via SharedPreferences
/// (key managed by SwipeFeedController).
class SwipeTutorialOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  const SwipeTutorialOverlay({super.key, required this.onDismiss});

  @override
  State<SwipeTutorialOverlay> createState() => _SwipeTutorialOverlayState();
}

class _SwipeTutorialOverlayState extends State<SwipeTutorialOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  int _step = 0;

  static const _steps = [
    _Step(
      icon: Icons.swipe_right_rounded,
      color: Color(0xFF988AFF),
      label: 'Swipe right to Like',
      sub: 'Saves to your LF Swipes wishlist board',
    ),
    _Step(
      icon: Icons.swipe_left_rounded,
      color: Color(0xFFF44336),
      label: 'Swipe left to Nope',
      sub: 'Hides this style from your feed',
    ),
    _Step(
      icon: Icons.swipe_up_rounded,
      color: Color(0xFF171717),
      label: 'Swipe up to Add to Cart',
      sub: 'Opens the product so you can pick your size',
    ),
    _Step(
      icon: Icons.swipe_down_rounded,
      color: Color(0xFF374151),
      label: 'Swipe down to View',
      sub: 'Opens the full product page',
    ),
    _Step(
      icon: Icons.touch_app_rounded,
      color: Color(0xFF988AFF),
      label: 'Tap to cycle photos',
      sub: 'Tap left or right on the card to see more images',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _ctrl.reverse().then((_) => widget.onDismiss());
    }
  }

  void _skip() => _ctrl.reverse().then((_) => widget.onDismiss());

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    return FadeTransition(
      opacity: _fade,
      child: GestureDetector(
        onTap: _next,
        child: Container(
          color: Colors.black.withOpacity(0.82),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated icon
                TweenAnimationBuilder<double>(
                  key: ValueKey(_step),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  builder: (_, v, child) => Transform.scale(
                    scale: 0.7 + 0.3 * v,
                    child: Opacity(opacity: v, child: child),
                  ),
                  child: Container(
                    width: 100.sp,
                    height: 100.sp,
                    decoration: BoxDecoration(
                      color: step.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: step.color, width: 2),
                    ),
                    child: Icon(step.icon, color: step.color, size: 48.sp),
                  ),
                ),
                SizedBox(height: 28.sp),
                Text(
                  step.label,
                  style: TextStyle(
                    fontFamily: 'Clash Display Semibold',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.sp),
                Text(
                  step.sub,
                  style: TextStyle(
                    fontFamily: 'Clash Display Regular',
                    fontSize: 15.sp,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.sp),
                // Step dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _steps.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 4.sp),
                      width: i == _step ? 20.sp : 6.sp,
                      height: 6.sp,
                      decoration: BoxDecoration(
                        color: i == _step ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(3.sp),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.sp),
                // Next / Let's go button
                GestureDetector(
                  onTap: _next,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.sp, vertical: 14.sp),
                    decoration: BoxDecoration(
                      color: step.color,
                      borderRadius: BorderRadius.circular(30.sp),
                    ),
                    child: Text(
                      _step < _steps.length - 1 ? 'Next' : "Let's go!",
                      style: TextStyle(
                        fontFamily: 'Clash Display',
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.sp),
                GestureDetector(
                  onTap: _skip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'Clash Display Regular',
                      fontSize: 13.sp,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step {
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
  const _Step({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
  });
}
