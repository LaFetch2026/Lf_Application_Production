/// Thrown when the server returns HTTP 410 Gone, indicating the checkout
/// session has hard-expired and can no longer be used for payment.
class SessionExpiredException implements Exception {
  final String message;

  const SessionExpiredException([
    this.message = 'Your session has expired. Please start checkout again.',
  ]);

  @override
  String toString() => 'SessionExpiredException: $message';
}
