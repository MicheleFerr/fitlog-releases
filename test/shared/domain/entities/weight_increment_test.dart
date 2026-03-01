/// WeightIncrement value object tests - validation, computed, formatting.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/weight_increment.dart';

void main() {
  group('WeightIncrement', () {
    test('isValid for positive values <= 50', () {
      expect(const WeightIncrement(2.5).isValid, isTrue);
      expect(const WeightIncrement(50).isValid, isTrue);
      expect(const WeightIncrement(0).isValid, isFalse);
      expect(const WeightIncrement(-1).isValid, isFalse);
      expect(const WeightIncrement(51).isValid, isFalse);
    });

    test('isFractional for values < 1', () {
      expect(const WeightIncrement(0.5).isFractional, isTrue);
      expect(const WeightIncrement(0.25).isFractional, isTrue);
      expect(const WeightIncrement(1.0).isFractional, isFalse);
      expect(const WeightIncrement(2.5).isFractional, isFalse);
    });

    test('isMicroloading for values < 2.5', () {
      expect(const WeightIncrement(0.5).isMicroloading, isTrue);
      expect(const WeightIncrement(1.25).isMicroloading, isTrue);
      expect(const WeightIncrement(2.5).isMicroloading, isFalse);
      expect(const WeightIncrement(5.0).isMicroloading, isFalse);
    });

    test('format integer values', () {
      expect(const WeightIncrement(5.0).format('kg'), '5kg');
      expect(const WeightIncrement(10.0).format('lbs'), '10lbs');
    });

    test('format decimal values', () {
      expect(const WeightIncrement(2.5).format('kg'), '2.50kg');
      expect(const WeightIncrement(1.25).format('kg'), '1.25kg');
    });

    test('equality', () {
      expect(const WeightIncrement(2.5), equals(const WeightIncrement(2.5)));
      expect(
        const WeightIncrement(2.5),
        isNot(equals(const WeightIncrement(5.0))),
      );
    });

    test('hashCode', () {
      expect(
        const WeightIncrement(2.5).hashCode,
        equals(const WeightIncrement(2.5).hashCode),
      );
    });

    test('toString', () {
      expect(const WeightIncrement(2.5).toString(), 'WeightIncrement(2.5)');
    });

    test('predefined kg increments', () {
      expect(WeightIncrement.standardKgIncrements.length, 6);
      expect(WeightIncrement.kg_0_5.value, 0.5);
      expect(WeightIncrement.kg_10_0.value, 10.0);
    });

    test('predefined lbs increments', () {
      expect(WeightIncrement.standardLbsIncrements.length, 5);
      expect(WeightIncrement.lbs_1_0.value, 1.0);
      expect(WeightIncrement.lbs_25_0.value, 25.0);
    });
  });
}
