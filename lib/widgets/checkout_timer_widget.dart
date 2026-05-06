// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../common/widget/text/app_text.dart';
import '../core/constant/constants.dart';
import '../models/checkout_session.dart';
import '../services/api_service.dart';

/// A countdown timer widget that polls GET /checkout/session/:id every 30 seconds
/// and displays the time remaining before the session expires.
///
/// When the session soft-expires, a warning banner is shown.
/// When the timer reaches zero, the [onExpired] callback is fired.
class CheckoutTimerWidget extends StatefulWidget {
  final String checkoutSessionId;
  final VoidCallback onExpired;

  const CheckoutTimerWidget({
    super.key,
    required this.checkoutSessionId,
    required this.onExpired,
  });

  @override
  State<CheckoutTimerWidget> createState() => _CheckoutTimerWidgetState();
}

class _CheckoutTimerWidgetState extends State<CheckoutTimerWidget> {
  int _remainingMs = 0;
  bool _softExpired = false;
  Timer? _ticker;
  Timer? _poller;
  int _tickCount = 0;

  @override
  void initState() {
    super.initState();
    _pollSession(); // Initial poll
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _poller?.cancel();
    super.dispose();
  }

  /// Start the 1-second tick timer
  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingMs > 0) {
        setState(() {
          _remainingMs = (_remainingMs - 1000).clamp(0, double.maxFinite.toInt());
        });

        if (_remainingMs <= 0) {
          _ticker?.cancel();
          widget.onExpired();
        }
      }

      _tickCount++;
      // Poll every 30 ticks (30 seconds)
      if (_tickCount % 30 == 0) {
        _pollSession();
      }
    });
  }

  /// Poll GET /checkout/session/:id to refresh timeRemainingMs and softExpired
  Future<void> _pollSession() async {
    try {
      final apiService = Get.find<ApiService>();
      final uri = '${ApiConstants.baseUrl}/checkout/session/${widget.checkoutSessionId}';

      final response = await apiService.get(
        uri,
        useCache: false,
        showErrorSnackbar: false,
      );

      if (response == null || response.statusCode != 200) {
        print('⚠️ CheckoutTimerWidget: session poll failed (${response?.statusCode})');
        return;
      }

      final data = jsonDecode(response.body);
      final session = CheckoutSession.fromJson(data['data'] ?? data);

      setState(() {
        _remainingMs = session.timeRemainingMs;
        _softExpired = session.softExpired;
      });

      print('✅ CheckoutTimerWidget: polled session, ${_remainingMs}ms remaining, softExpired=$_softExpired');
    } catch (e) {
      print('❌ CheckoutTimerWidget: poll error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide widget when timer is zero or not yet loaded
    if (_remainingMs <= 0) {
      return const SizedBox.shrink();
    }

    final minutes = (_remainingMs ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((_remainingMs % 60000) ~/ 1000).toString().padLeft(2, '0');

    return Container(
      color: whiteColor,
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_softExpired)
            Container(
              padding: EdgeInsets.all(8.sp),
              margin: EdgeInsets.only(bottom: 8.sp),
              decoration: BoxDecoration(
                color: lightYellow,
                borderRadius: BorderRadius.circular(4.sp),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: deeptYellow, size: 16.sp),
                  SizedBox(width: 8.sp),
                  Expanded(
                    child: AppText(
                      text: 'Session expiring soon — complete your payment now',
                      fontFamily: 'Clash Display Regular',
                      fontWeight: FontWeight.w400,
                      color: deeptYellow,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Icon(Icons.timer_outlined, color: greyTextColor, size: 16.sp),
              SizedBox(width: 8.sp),
              AppText(
                text: 'Time remaining: ',
                fontFamily: 'Clash Display Regular',
                fontWeight: FontWeight.w400,
                color: greyTextColor,
                fontSize: 12,
              ),
              AppText(
                text: '$minutes:$seconds',
                fontFamily: 'Clash Display',
                fontWeight: FontWeight.w500,
                color: loginText,
                fontSize: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
