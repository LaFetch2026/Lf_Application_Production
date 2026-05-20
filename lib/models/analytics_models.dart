class AnalyticsProduct {
  final String prid;
  final String image;
  final int prqt;
  final String productName;
  final String category;
  final String brand;
  final double sellingPrice;
  final String productUrl;
  final double discountedPrice;
  final int stockAvailability;
  final String? variantId;
  final double? mrp;

  AnalyticsProduct({
    required this.prid,
    required this.image,
    required this.prqt,
    required this.productName,
    required this.category,
    required this.brand,
    required this.sellingPrice,
    required this.productUrl,
    required this.discountedPrice,
    required this.stockAvailability,
    this.variantId,
    this.mrp,
  });

  Map<String, dynamic> toMap() {
    return {
      'prid': prid,
      'image': image,
      'prqt': prqt,
      'product_name': productName,
      'category': category,
      'brand': brand,
      'selling_price': sellingPrice,
      'product_url': productUrl,
      'discounted_price': discountedPrice,
      'stock_availability': stockAvailability,
      if (variantId != null) 'variant_id': variantId,
      if (mrp != null) 'mrp': mrp,
    };
  }
}

class AnalyticsUser {
  final String? fullName;
  final String? email;
  final String? mobile;
  final String? gender;
  final String? lastLoginSource;
  final double? lastPurchaseAmt;
  final String? lastPurchaseDate;

  AnalyticsUser({
    this.fullName,
    this.email,
    this.mobile,
    this.gender,
    this.lastLoginSource,
    this.lastPurchaseAmt,
    this.lastPurchaseDate,
  });

  Map<String, String> toUserAttributes() {
    return {
      if (email != null) 'EMAIL': email!,
      if (mobile != null) 'MOBILE': mobile!,
      if (fullName != null) ...{
        'FIRST_NAME': fullName!.split(' ').first,
        'LAST_NAME': fullName!.contains(' ') ? fullName!.split(' ').last : '',
      },
      if (gender != null) 'GENDER': gender!,
      if (lastLoginSource != null) 'LAST_LOGIN_SOURCE': lastLoginSource!,
      if (lastPurchaseAmt != null) 'LAST_PURCHASE_AMT': lastPurchaseAmt!.toString(),
      if (lastPurchaseDate != null) 'LAST_PURCHASE_DATE': lastPurchaseDate!,
    };
  }
}

class AnalyticsOrder {
  final String? orderId;
  final int totalPrqt;
  final double sellingAmount; // Total MRP
  final double discountAmt;
  final double amount; // Final Payable
  final double shippingCost;
  final String paymentMode;
  final String? couponCode;
  final List<AnalyticsProduct> items;
  final String source;
  final String? fulfillmentMode;

  AnalyticsOrder({
    this.orderId,
    required this.totalPrqt,
    required this.sellingAmount,
    required this.discountAmt,
    required this.amount,
    required this.shippingCost,
    required this.paymentMode,
    this.couponCode,
    required this.items,
    this.source = 'app',
    this.fulfillmentMode,
  });

  Map<String, dynamic> toMap() {
    return {
      if (orderId != null) 'orderid': orderId,
      'total_prqt': totalPrqt,
      'selling_amount': sellingAmount,
      'discount_amt': discountAmt,
      'amount': amount,
      'shipping_cost': shippingCost,
      'payment_mode': paymentMode,
      if (couponCode != null) 'coupon_code': couponCode,
      'source': source,
      if (fulfillmentMode != null) 'fulfillment_mode': fulfillmentMode,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}
