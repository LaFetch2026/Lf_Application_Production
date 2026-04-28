import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../common/widget/other/lf_loader_widget.dart';
import '../core/constant/constants.dart';
import '../models/recommendation_event.dart';
import '../services/event_tracking_service.dart';
import '../services/swipe_feed_service.dart';
import '../widgets/swipe_product_card.dart';

class SwipeFeedScreen extends StatefulWidget {
  const SwipeFeedScreen({super.key});

  @override
  State<SwipeFeedScreen> createState() => _SwipeFeedScreenState();
}

class _SwipeFeedScreenState extends State<SwipeFeedScreen> {
  List<RecommendationProduct> _cards = [];
  bool _isFetching = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchBatch();
  }

  Future<void> _fetchBatch() async {
    if (_isFetching) return;
    final wasEmpty = _cards.isEmpty;
    setState(() {
      _isFetching = true;
      _hasError = false;
    });

    try {
      final results = await SwipeFeedService.instance.fetchBatch();
      if (mounted) {
        setState(() {
          _cards = [..._cards, ...results];
          _isFetching = false;
          if (wasEmpty && results.isEmpty) {
            _hasError = true;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isFetching = false;
        });
      }
    }
  }

  void _maybePrefetch() {
    if (_cards.length <= 3 && !_isFetching) {
      _fetchBatch();
    }
  }

  void _onCardSwiped(SwipeAction action, RecommendationProduct product) {
    EventTrackingService.instance.trackSwipe(action, product.id);
    setState(() => _cards.removeAt(0));
    _maybePrefetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'LF Swipe',
          style: TextStyle(
            fontFamily: 'Clash Display Semibold',
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: homeAppBarColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildHintBar(),
    );
  }

  Widget _buildBody() {
    // Loading state
    if (_cards.isEmpty && _isFetching) {
      return Center(
        child: LfLogoLoader(
          size: 48,
          brandColor: Colors.grey[200]!,
          showGlow: false,
        ),
      );
    }

    // Error state
    if (_cards.isEmpty && _hasError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LfLogoLoader(
                size: 48,
                brandColor: Colors.grey[200]!,
                showGlow: false,
              ),
              SizedBox(height: 20.sp),
              Text(
                'Could not load feed',
                style: TextStyle(
                  fontFamily: 'Clash Display Semibold',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: homeAppBarColor,
                ),
              ),
              SizedBox(height: 6.sp),
              Text(
                'Check your connection and try again',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Clash Display Regular',
                  fontSize: 13.sp,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 24.sp),
              GestureDetector(
                onTap: _fetchBatch,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.sp, vertical: 14.sp),
                  decoration: BoxDecoration(
                    color: homeAppBarColor,
                    borderRadius: BorderRadius.circular(30.sp),
                  ),
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      fontFamily: 'Clash Display',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Exhausted state
    if (_cards.isEmpty && !_isFetching && !_hasError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "You've seen it all! 🎉",
                style: TextStyle(
                  fontFamily: 'Clash Display Semibold',
                  fontWeight: FontWeight.w600,
                  fontSize: 22.sp,
                  color: homeAppBarColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.sp),
              Text(
                'Check back later for new arrivals',
                style: TextStyle(
                  fontFamily: 'Clash Display Regular',
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.sp),
              GestureDetector(
                onTap: _fetchBatch,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.sp, vertical: 14.sp),
                  decoration: BoxDecoration(
                    color: homeAppBarColor,
                    borderRadius: BorderRadius.circular(30.sp),
                  ),
                  child: Text(
                    'Refresh',
                    style: TextStyle(
                      fontFamily: 'Clash Display',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Card stack
    final visibleCards = _cards.take(3).toList();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: Stack(
        children: [
          for (int i = visibleCards.length - 1; i >= 0; i--)
            _buildCardAtIndex(i, visibleCards[i]),
        ],
      ),
    );
  }

  Widget _buildCardAtIndex(int index, RecommendationProduct product) {
    const configs = [
      (scale: 1.00, verticalOffset: 0.0, isTop: true),
      (scale: 0.96, verticalOffset: 10.0, isTop: false),
      (scale: 0.92, verticalOffset: 20.0, isTop: false),
    ];

    final config = configs[index];

    return SwipeProductCard(
      key: ValueKey(product.id),
      product: product,
      isTop: config.isTop,
      scale: config.scale,
      verticalOffset: config.verticalOffset,
      onSwiped: (action) => _onCardSwiped(action, product),
    );
  }

  Widget _buildHintBar() {
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildHintIcon(
            icon: Icons.close,
            color: Colors.red,
            label: 'Nope',
            action: SwipeAction.dislikeProduct,
          ),
          _buildHintIcon(
            icon: Icons.arrow_downward,
            color: Colors.grey,
            label: 'Skip',
            action: SwipeAction.swipeDown,
          ),
          _buildHintIcon(
            icon: Icons.arrow_upward,
            color: const Color(0xFF988AFF),
            label: 'Save',
            action: SwipeAction.swipeUp,
          ),
          _buildHintIcon(
            icon: Icons.favorite,
            color: Colors.green,
            label: 'Like',
            action: SwipeAction.likeProduct,
          ),
        ],
      ),
    );
  }

  Widget _buildHintIcon({
    required IconData icon,
    required Color color,
    required String label,
    required SwipeAction action,
  }) {
    return GestureDetector(
      onTap: () {
        if (_cards.isNotEmpty) {
          _onCardSwiped(action, _cards.first);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 2.sp),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
