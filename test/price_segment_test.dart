import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafetch/models/price_segment.dart';

void main() {
  group('PriceSegment Enum Tests', () {
    test('PriceSegment.luxe has correct apiValue', () {
      expect(PriceSegment.luxe.apiValue, equals('luxe'));
    });

    test('PriceSegment.luxury has correct apiValue', () {
      expect(PriceSegment.luxury.apiValue, equals('luxury'));
    });

    test('PriceSegment.premium has correct apiValue', () {
      expect(PriceSegment.premium.apiValue, equals('premium'));
    });

    test('PriceSegment.affordable has correct apiValue', () {
      expect(PriceSegment.affordable.apiValue, equals('affordable'));
    });

    test('PriceSegment.luxe has correct displayName', () {
      expect(PriceSegment.luxe.displayName, equals('LUXE'));
    });

    test('PriceSegment.luxury has correct displayName', () {
      expect(PriceSegment.luxury.displayName, equals('Luxury'));
    });

    test('PriceSegment.luxe has purple indicator color', () {
      expect(
        PriceSegment.luxe.indicatorColor,
        equals(const Color(0xFF9C27B0)),
      );
    });

    test('PriceSegment.luxe has black background color', () {
      expect(
        PriceSegment.luxe.backgroundColor,
        equals(const Color(0xFF000000)),
      );
    });

    test('PriceSegment.luxe has white text color', () {
      expect(
        PriceSegment.luxe.textColor,
        equals(const Color(0xFFFFFFFF)),
      );
    });

    test('fromString parses luxe correctly', () {
      expect(
        PriceSegmentExtension.fromString('luxe'),
        equals(PriceSegment.luxe),
      );
    });

    test('fromString parses luxury correctly', () {
      expect(
        PriceSegmentExtension.fromString('luxury'),
        equals(PriceSegment.luxury),
      );
    });

    test('fromString returns null for invalid value', () {
      expect(
        PriceSegmentExtension.fromString('invalid'),
        isNull,
      );
    });

    test('fromString is case-insensitive', () {
      expect(
        PriceSegmentExtension.fromString('LUXE'),
        equals(PriceSegment.luxe),
      );
    });

    test('All price segments have valid apiValues', () {
      final segments = [
        PriceSegment.affordable,
        PriceSegment.premium,
        PriceSegment.luxury,
        PriceSegment.luxe,
      ];

      for (final segment in segments) {
        expect(segment.apiValue, isNotEmpty);
        expect(segment.displayName, isNotEmpty);
        expect(segment.indicatorColor, isNotNull);
        expect(segment.backgroundColor, isNotNull);
        expect(segment.textColor, isNotNull);
      }
    });
  });
}
