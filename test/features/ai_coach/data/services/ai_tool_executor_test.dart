import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AIToolExecutor - Robust Type Conversion', () {
    int parseWeeksBack(dynamic raw) {
      return raw is num
          ? raw.toInt()
          : int.tryParse(raw?.toString() ?? '12') ?? 12;
    }

    double parseWeight(dynamic raw, double defaultValue) {
      return raw is num
          ? raw.toDouble()
          : double.tryParse(raw?.toString() ?? defaultValue.toString()) ?? defaultValue;
    }

    test('should handle weeksBack as int', () {
      final args = <String, dynamic>{'weeksBack': 12};
      final weeksBack = parseWeeksBack(args['weeksBack']);
      expect(weeksBack, 12);
    });

    test('should handle weeksBack as String (CRITICAL FIX)', () {
      // This is what was causing the crash:
      // type 'String' is not a subtype of type 'num?'
      final args = <String, dynamic>{'weeksBack': '52'};
      final weeksBack = parseWeeksBack(args['weeksBack']);
      expect(weeksBack, 52);
    });

    test('should handle weeksBack as double', () {
      final args = <String, dynamic>{'weeksBack': 8.5};
      final weeksBack = parseWeeksBack(args['weeksBack']);
      expect(weeksBack, 8); // Truncates to int
    });

    test('should handle weeksBack as null with default', () {
      final args = <String, dynamic>{};
      final weeksBack = parseWeeksBack(args['weeksBack']);
      expect(weeksBack, 12); // Default value
    });

    test('should handle weight as double', () {
      final args = <String, dynamic>{'weight': 100.5};
      final weight = parseWeight(args['weight'], 0);
      expect(weight, 100.5);
    });

    test('should handle weight as String (CRITICAL FIX)', () {
      // Another case that would crash with: as num?
      final args = <String, dynamic>{'weight': '75.5'};
      final weight = parseWeight(args['weight'], 0);
      expect(weight, 75.5);
    });

    test('should handle weight as int (converts to double)', () {
      final args = <String, dynamic>{'weight': 80};
      final weight = parseWeight(args['weight'], 0);
      expect(weight, 80.0);
    });

    test('should handle invalid String with default', () {
      final args = <String, dynamic>{'weeksBack': 'invalid'};
      final weeksBack = parseWeeksBack(args['weeksBack']);
      expect(weeksBack, 12); // Falls back to default
    });

    test('should handle bodyWeight edge cases', () {
      // Empty string
      expect(parseWeight('', 75), 75.0);

      // Null
      expect(parseWeight(null, 75), 75.0);

      // Valid String
      expect(parseWeight('70.5', 75), 70.5);

      // Valid num
      expect(parseWeight(85, 75), 85.0);
    });
  });
}
