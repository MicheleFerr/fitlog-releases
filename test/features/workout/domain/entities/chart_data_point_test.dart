import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';

void main() {
  group('ChartDataPoint', () {
    final date1 = DateTime(2026, 1, 15);
    final date2 = DateTime(2026, 2, 20);

    group('constructor', () {
      test('creates instance with required fields', () {
        final point = ChartDataPoint(date: date1, value: 85.5);

        expect(point.date, date1);
        expect(point.value, 85.5);
      });

      test('supports zero value', () {
        final point = ChartDataPoint(date: date1, value: 0.0);
        expect(point.value, 0.0);
      });

      test('supports negative value', () {
        final point = ChartDataPoint(date: date1, value: -10.5);
        expect(point.value, -10.5);
      });

      test('supports very large value', () {
        final point = ChartDataPoint(date: date1, value: 999999.99);
        expect(point.value, 999999.99);
      });
    });

    group('equality', () {
      test('two instances with same date and value are equal', () {
        final a = ChartDataPoint(date: date1, value: 100.0);
        final b = ChartDataPoint(date: date1, value: 100.0);

        expect(a, equals(b));
      });

      test('same instance is equal to itself', () {
        final point = ChartDataPoint(date: date1, value: 50.0);
        expect(point, equals(point));
      });

      test('different date means not equal', () {
        final a = ChartDataPoint(date: date1, value: 100.0);
        final b = ChartDataPoint(date: date2, value: 100.0);

        expect(a, isNot(equals(b)));
      });

      test('different value means not equal', () {
        final a = ChartDataPoint(date: date1, value: 100.0);
        final b = ChartDataPoint(date: date1, value: 200.0);

        expect(a, isNot(equals(b)));
      });

      test('different date and value means not equal', () {
        final a = ChartDataPoint(date: date1, value: 100.0);
        final b = ChartDataPoint(date: date2, value: 200.0);

        expect(a, isNot(equals(b)));
      });

      test('not equal to non-ChartDataPoint object', () {
        final point = ChartDataPoint(date: date1, value: 100.0);

        expect(point == 'not a chart point', isFalse);
        expect(point == 42, isFalse);
      });
    });

    group('hashCode', () {
      test('same date and value produce same hashCode', () {
        final a = ChartDataPoint(date: date1, value: 100.0);
        final b = ChartDataPoint(date: date1, value: 100.0);

        expect(a.hashCode, equals(b.hashCode));
      });

      test('different date produces different hashCode', () {
        final a = ChartDataPoint(date: date1, value: 100.0);
        final b = ChartDataPoint(date: date2, value: 100.0);

        expect(a.hashCode, isNot(equals(b.hashCode)));
      });

      test('different value produces different hashCode', () {
        final a = ChartDataPoint(date: date1, value: 100.0);
        final b = ChartDataPoint(date: date1, value: 200.0);

        expect(a.hashCode, isNot(equals(b.hashCode)));
      });

      test('can be used in Set', () {
        final a = ChartDataPoint(date: date1, value: 100.0);
        final b = ChartDataPoint(date: date1, value: 100.0);
        final c = ChartDataPoint(date: date2, value: 200.0);

        final set = {a, b, c};
        expect(set.length, 2);
      });

      test('can be used as Map key', () {
        final a = ChartDataPoint(date: date1, value: 100.0);
        final b = ChartDataPoint(date: date1, value: 100.0);

        final map = {a: 'first'};
        expect(map[b], 'first');
      });
    });

    group('toString', () {
      test('includes date and value', () {
        final point = ChartDataPoint(date: date1, value: 85.5);
        final result = point.toString();

        expect(result, contains('ChartDataPoint'));
        expect(result, contains('date:'));
        expect(result, contains('value:'));
        expect(result, contains('85.5'));
      });

      test('formats correctly', () {
        final point = ChartDataPoint(date: date1, value: 85.5);

        expect(
          point.toString(),
          'ChartDataPoint(date: $date1, value: 85.5)',
        );
      });
    });
  });
}
