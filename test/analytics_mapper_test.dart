import 'package:flutter_test/flutter_test.dart';
import 'package:lafetch/models/analytics_models.dart';
import 'package:lafetch/services/analytics/event_payload_mapper.dart';

void main() {
  group('EventPayloadMapper Tests', () {
    test('mapProduct should return correct map', () {
      final product = AnalyticsProduct(
        prid: '123',
        image: 'img.jpg',
        prqt: 1,
        productName: 'Cool Shirt',
        category: 'Apparel',
        brand: 'LF',
        sellingPrice: 99.99,
        productUrl: '/product/cool-shirt',
        discountedPrice: 89.99,
        stockAvailability: 1,
        variantId: 'v1',
        mrp: 120.0,
      );

      final payload = EventPayloadMapper.mapProduct(product);

      expect(payload['prid'], '123');
      expect(payload['product_name'], 'Cool Shirt');
      expect(payload['selling_price'], 99.99);
      expect(payload['mrp'], 120.0);
    });

    test('mapSignup should return correct map', () {
      final user = AnalyticsUser(fullName: 'John Doe', email: 'john@example.com');
      final payload = EventPayloadMapper.mapSignup(user, method: 'google');

      expect(payload['source'], 'app');
      expect(payload['method'], 'google');
      expect(payload['name'], 'John Doe');
      expect(payload['email'], 'john@example.com');
    });

    test('mapCheckout should exclude orderid and fulfillment_mode', () {
      final order = AnalyticsOrder(
        orderId: 'ORD123',
        totalPrqt: 2,
        sellingAmount: 200.0,
        discountAmt: 20.0,
        amount: 180.0,
        shippingCost: 0.0,
        paymentMode: 'razorpay',
        items: [],
        fulfillmentMode: 'standard',
      );

      final payload = EventPayloadMapper.mapCheckout(order);

      expect(payload.containsKey('orderid'), isFalse);
      expect(payload.containsKey('fulfillment_mode'), isFalse);
      expect(payload['amount'], 180.0);
      expect(payload['payment_mode'], 'razorpay');
    });
  });
}
