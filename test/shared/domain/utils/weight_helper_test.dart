/// WeightHelper tests - quick jumps, conversions, formatting, plates.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/utils/weight_helper.dart';

void main() {
  group('WeightHelper.getQuickJumps - kg', () {
    test('at 0 kg', () {
      expect(WeightHelper.getQuickJumps(0, 'kg'), [10, 20, 50, 100]);
    });

    test('0-10 kg', () {
      expect(WeightHelper.getQuickJumps(5, 'kg'), [-10, 20, 50, 100]);
    });

    test('10-20 kg', () {
      expect(WeightHelper.getQuickJumps(15, 'kg'), [-10, 20, 50, 100]);
    });

    test('>20 kg', () {
      expect(WeightHelper.getQuickJumps(80, 'kg'), [-20, -10, 10, 20]);
    });
  });

  group('WeightHelper.getQuickJumps - lbs', () {
    test('at 0 lbs', () {
      expect(WeightHelper.getQuickJumps(0, 'lbs'), [5, 10, 25, 50]);
    });

    test('0-25 lbs', () {
      expect(WeightHelper.getQuickJumps(10, 'lbs'), [-5, 10, 25, 50]);
    });

    test('25-50 lbs', () {
      expect(WeightHelper.getQuickJumps(40, 'lbs'), [-10, 10, 25, 50]);
    });

    test('>50 lbs', () {
      expect(WeightHelper.getQuickJumps(100, 'lbs'), [-25, -10, 10, 25]);
    });
  });

  group('WeightHelper.applyQuickJump', () {
    test('positive jump', () {
      expect(
        WeightHelper.applyQuickJump(
            currentWeight: 50, jump: 10, unit: 'kg'),
        60.0,
      );
    });

    test('negative jump clamped to 0', () {
      expect(
        WeightHelper.applyQuickJump(
            currentWeight: 5, jump: -10, unit: 'kg'),
        0.0,
      );
    });

    test('clamped to max kg (200)', () {
      expect(
        WeightHelper.applyQuickJump(
            currentWeight: 195, jump: 20, unit: 'kg'),
        200.0,
      );
    });

    test('clamped to max lbs (440)', () {
      expect(
        WeightHelper.applyQuickJump(
            currentWeight: 430, jump: 25, unit: 'lbs'),
        440.0,
      );
    });
  });

  group('WeightHelper.indexToWeight', () {
    test('kg: index/4.0', () {
      expect(WeightHelper.indexToWeight(0, 'kg'), 0.0);
      expect(WeightHelper.indexToWeight(4, 'kg'), 1.0);
      expect(WeightHelper.indexToWeight(10, 'kg'), 2.5);
    });

    test('lbs: index/2.0', () {
      expect(WeightHelper.indexToWeight(0, 'lbs'), 0.0);
      expect(WeightHelper.indexToWeight(2, 'lbs'), 1.0);
      expect(WeightHelper.indexToWeight(5, 'lbs'), 2.5);
    });
  });

  group('WeightHelper.weightToIndex', () {
    test('kg: weight*4', () {
      expect(WeightHelper.weightToIndex(0, 'kg'), 0);
      expect(WeightHelper.weightToIndex(1.0, 'kg'), 4);
      expect(WeightHelper.weightToIndex(2.5, 'kg'), 10);
    });

    test('lbs: weight*2', () {
      expect(WeightHelper.weightToIndex(0, 'lbs'), 0);
      expect(WeightHelper.weightToIndex(1.0, 'lbs'), 2);
      expect(WeightHelper.weightToIndex(2.5, 'lbs'), 5);
    });
  });

  group('WeightHelper.formatPickerWeight', () {
    test('zero', () {
      expect(WeightHelper.formatPickerWeight(0, 'kg'), '0');
    });

    test('whole number', () {
      expect(WeightHelper.formatPickerWeight(50, 'kg'), '50');
    });

    test('kg decimal: 2 decimals', () {
      expect(WeightHelper.formatPickerWeight(2.5, 'kg'), '2.50');
    });

    test('lbs decimal: 1 decimal', () {
      expect(WeightHelper.formatPickerWeight(2.5, 'lbs'), '2.5');
    });
  });

  group('WeightHelper.getStandardWeights', () {
    test('kg list starts at 0', () {
      final weights = WeightHelper.getStandardWeights('kg');
      expect(weights.first, 0);
      expect(weights, contains(20.0));
      expect(weights, contains(100.0));
    });

    test('lbs list starts at 0', () {
      final weights = WeightHelper.getStandardWeights('lbs');
      expect(weights.first, 0);
      expect(weights, contains(45.0));
      expect(weights, contains(225.0));
    });
  });

  group('WeightHelper conversions', () {
    test('kgToLbs', () {
      expect(WeightHelper.kgToLbs(1.0), closeTo(2.20462, 0.001));
      expect(WeightHelper.kgToLbs(100), closeTo(220.462, 0.1));
    });

    test('lbsToKg', () {
      expect(WeightHelper.lbsToKg(2.20462), closeTo(1.0, 0.001));
      expect(WeightHelper.lbsToKg(220.462), closeTo(100.0, 0.1));
    });

    test('round trip kg -> lbs -> kg', () {
      const original = 80.0;
      final lbs = WeightHelper.kgToLbs(original);
      final backToKg = WeightHelper.lbsToKg(lbs);
      expect(backToKg, closeTo(original, 0.001));
    });
  });
}
