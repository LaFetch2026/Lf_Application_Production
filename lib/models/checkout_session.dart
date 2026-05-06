// ignore_for_file: avoid_print

/// Represents the lifecycle state of a checkout session on the server.
enum CheckoutStatus {
  pending,
  paymentInitiated,
  completed,
  expired,
  cancelled;

  /// Returns true when the session is still actionable (can proceed to payment).
  bool get isActive =>
      this == CheckoutStatus.pending ||
      this == CheckoutStatus.paymentInitiated;

  /// Parses a server-side status string to a [CheckoutStatus].
  /// Unknown strings map to [CheckoutStatus.pending] (fail-open).
  static CheckoutStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PAYMENT_INITIATED':
        return CheckoutStatus.paymentInitiated;
      case 'COMPLETED':
        return CheckoutStatus.completed;
      case 'EXPIRED':
        return CheckoutStatus.expired;
      case 'CANCELLED':
        return CheckoutStatus.cancelled;
      case 'PENDING':
      default:
        return CheckoutStatus.pending;
    }
  }
}

/// Represents a checkout session returned by GET /checkout/session/:id.
class CheckoutSession {
  final String checkoutSessionId;
  final CheckoutStatus status;

  /// Milliseconds remaining until the session hard-expires.
  /// Defaults to 0 if absent or null in the server response.
  final int timeRemainingMs;

  /// True when the session is in the soft-expiry grace window.
  /// Defaults to false if absent or null in the server response.
  final bool softExpired;

  const CheckoutSession({
    required this.checkoutSessionId,
    required this.status,
    this.timeRemainingMs = 0,
    this.softExpired = false,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      checkoutSessionId: json['checkoutSessionId'] as String? ?? '',
      status: CheckoutStatus.fromString(
        (json['status'] as String?) ?? 'PENDING',
      ),
      timeRemainingMs: (json['timeRemainingMs'] as int?) ?? 0,
      softExpired: (json['softExpired'] as bool?) ?? false,
    );
  }
}
