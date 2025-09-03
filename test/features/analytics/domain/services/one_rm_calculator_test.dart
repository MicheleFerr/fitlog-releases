import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';
import '../../../../test_helpers/firebase_test_helper.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });
  
  group('OneRMCalculator', () {
    group('Brzycki Formula', () {
      test('should return weight when reps is 1', () {
        expect(OneRMCalculator.calculateBrzycki(100, 1), 100);
      });

      test('should calculate correct 1RM for 5 reps', () {
        final result = OneRMCalculator.calculateBrzycki(100, 5);
        expect(result, closeTo(112.5, 0.1));
      });

      test('should calculate correct 1RM for 10 reps', () {
        final result = OneRMCalculator.calculateBrzycki(100, 10);
        expect(result, closeTo(133.33, 0.1));
      });

      test('should return 0 for invalid inputs', () {
        expect(OneRMCalculator.calculateBrzycki(0, 5), 0);
        expect(OneRMCalculator.calculateBrzycki(100, 0), 0);
        expect(OneRMCalculator.calculateBrzycki(-100, 5), 0);
        expect(OneRMCalculator.calculateBrzycki(100, 37), 0); // Formula limit
      });
    });

    group('Epley Formula', () {
      test('should return weight when reps is 1', () {
        expect(OneRMCalculator.calculateEpley(100, 1), 100);
      });

      test('should calculate correct 1RM for 5 reps', () {
        final result = OneRMCalculator.calculateEpley(100, 5);
        expect(result, closeTo(116.67, 0.1));
      });

      test('should calculate correct 1RM for 10 reps', () {
        final result = OneRMCalculator.calculateEpley(100, 10);
        expect(result, closeTo(133.33, 0.1));
      });

      test('should return 0 for invalid inputs', () {
        expect(OneRMCalculator.calculateEpley(0, 5), 0);
        expect(OneRMCalculator.calculateEpley(100, 0), 0);
        expect(OneRMCalculator.calculateEpley(-100, 5), 0);
      });
    });

    group('Lombardi Formula', () {
      test('should return weight when reps is 1', () {
        expect(OneRMCalculator.calculateLombardi(100, 1), 100);
      });

      test('should calculate 1RM for various reps', () {
        final result5 = OneRMCalculator.calculateLombardi(100, 5);
        final result10 = OneRMCalculator.calculateLombardi(100, 10);
        
        expect(result5, greaterThan(100));
        expect(result10, greaterThan(result5));
      });

      test('should return 0 for invalid inputs', () {
        expect(OneRMCalculator.calculateLombardi(0, 5), 0);
        expect(OneRMCalculator.calculateLombardi(100, 0), 0);
      });
    });

    group('O\'Conner Formula', () {
      test('should return weight when reps is 1', () {
        expect(OneRMCalculator.calculateOConner(100, 1), 100);
      });

      test('should calculate correct 1RM for 5 reps', () {
        final result = OneRMCalculator.calculateOConner(100, 5);
        expect(result, closeTo(112.5, 0.1));
      });

      test('should return 0 for invalid inputs', () {
        expect(OneRMCalculator.calculateOConner(0, 5), 0);
        expect(OneRMCalculator.calculateOConner(100, 0), 0);
      });
    });

    group('Wathan Formula', () {
      test('should return weight when reps is 1', () {
        expect(OneRMCalculator.calculateWathan(100, 1), 100);
      });

      test('should calculate 1RM for various reps', () {
        final result5 = OneRMCalculator.calculateWathan(100, 5);
        final result10 = OneRMCalculator.calculateWathan(100, 10);
        
        expect(result5, greaterThan(100));
        expect(result10, greaterThan(result5));
      });

      test('should return 0 for invalid inputs', () {
        expect(OneRMCalculator.calculateWathan(0, 5), 0);
        expect(OneRMCalculator.calculateWathan(100, 0), 0);
      });
    });

    group('Average Calculation', () {
      test('should return weight when reps is 1', () {
        expect(OneRMCalculator.calculateAverage(100, 1), 100);
      });

      test('should calculate weighted average for low reps (<=5)', () {
        final result = OneRMCalculator.calculateAverage(100, 3);
        expect(result, greaterThan(100));
        expect(result, lessThan(120));
      });

      test('should calculate weighted average for medium reps (6-10)', () {
        final result = OneRMCalculator.calculateAverage(100, 8);
        expect(result, greaterThan(115));
        expect(result, lessThan(140));
      });

      test('should calculate weighted average for high reps (>10)', () {
        final result = OneRMCalculator.calculateAverage(100, 15);
        expect(result, greaterThan(130));
        expect(result, lessThan(200));
      });

      test('should return 0 for invalid inputs', () {
        expect(OneRMCalculator.calculateAverage(0, 5), 0);
        expect(OneRMCalculator.calculateAverage(100, 0), 0);
        expect(OneRMCalculator.calculateAverage(-100, 5), 0);
      });
    });

    group('Weight for Reps Calculation', () {
      test('should return 1RM when target reps is 1', () {
        expect(OneRMCalculator.calculateWeightForReps(100, 1), 100);
      });

      test('should calculate correct weight for 5 reps', () {
        final result = OneRMCalculator.calculateWeightForReps(112.5, 5);
        expect(result, closeTo(100, 0.1));
      });

      test('should calculate correct weight for 10 reps', () {
        final result = OneRMCalculator.calculateWeightForReps(133.33, 10);
        expect(result, closeTo(100, 0.1));
      });

      test('should return 0 for invalid inputs', () {
        expect(OneRMCalculator.calculateWeightForReps(0, 5), 0);
        expect(OneRMCalculator.calculateWeightForReps(100, 0), 0);
        expect(OneRMCalculator.calculateWeightForReps(-100, 5), 0);
      });
    });

    group('Training Percentages', () {
      test('should calculate correct training percentages', () {
        final percentages = OneRMCalculator.calculateTrainingPercentages(100);
        
        expect(percentages['max_strength'], 90);
        expect(percentages['strength'], 85);
        expect(percentages['hypertrophy'], 75);
        expect(percentages['endurance'], 60);
        expect(percentages['warmup'], 50);
      });

      test('should return zeros for invalid 1RM', () {
        final percentages = OneRMCalculator.calculateTrainingPercentages(0);
        
        percentages.forEach((key, value) {
          expect(value, 0);
        });
      });
    });

    group('RPE-based Calculation', () {
      test('should adjust 1RM based on RPE', () {
        // RPE 10 = no reps in reserve
        final rpe10 = OneRMCalculator.calculateWithRPE(100, 5, 10);
        // RPE 8 = 2 reps in reserve
        final rpe8 = OneRMCalculator.calculateWithRPE(100, 5, 8);
        
        expect(rpe8, lessThan(rpe10));
      });

      test('should return 0 for invalid RPE', () {
        expect(OneRMCalculator.calculateWithRPE(100, 5, 5), 0); // RPE too low
        expect(OneRMCalculator.calculateWithRPE(100, 5, 11), 0); // RPE too high
      });

      test('should return 0 for invalid inputs', () {
        expect(OneRMCalculator.calculateWithRPE(0, 5, 8), 0);
        expect(OneRMCalculator.calculateWithRPE(100, 0, 8), 0);
      });
    });

    group('Confidence Interval', () {
      test('should calculate confidence interval', () {
        final interval = OneRMCalculator.calculateConfidenceInterval(100, 5);
        
        expect(interval['lower']!, greaterThan(0));
        expect(interval['average']!, greaterThan(interval['lower']!));
        expect(interval['upper']!, greaterThan(interval['average']!));
      });

      test('should return zeros for invalid inputs', () {
        final interval = OneRMCalculator.calculateConfidenceInterval(0, 5);
        
        expect(interval['lower'], 0);
        expect(interval['average'], 0);
        expect(interval['upper'], 0);
      });
    });

    group('Realistic Lift Validation', () {
      test('should validate realistic 1RM attempts', () {
        // 100kg 1RM
        expect(OneRMCalculator.isRealisticLift(100, 1, 100), true);
        expect(OneRMCalculator.isRealisticLift(103, 1, 100), true); // 3% variance OK
        expect(OneRMCalculator.isRealisticLift(106, 1, 100), false); // Too heavy
      });

      test('should validate realistic multi-rep sets', () {
        // 100kg 1RM
        expect(OneRMCalculator.isRealisticLift(80, 5, 100), true); // 80% for 5 reps OK
        expect(OneRMCalculator.isRealisticLift(90, 5, 100), false); // Too heavy for 5
        expect(OneRMCalculator.isRealisticLift(65, 12, 100), true); // 65% for 12 reps OK
        expect(OneRMCalculator.isRealisticLift(75, 12, 100), false); // Too heavy for 12
      });

      test('should return false for invalid inputs', () {
        expect(OneRMCalculator.isRealisticLift(0, 5, 100), false);
        expect(OneRMCalculator.isRealisticLift(100, 0, 100), false);
        expect(OneRMCalculator.isRealisticLift(100, 5, 0), false);
      });
    });

    group('Extensions', () {
      test('should convert between kg and lbs', () {
        const kg = 100.0;
        final lbs = kg.toLbs();
        expect(lbs, closeTo(220.46, 0.01));
        
        final backToKg = lbs.toKg();
        expect(backToKg, closeTo(kg, 0.01));
      });

      test('should round to nearest plate increment', () {
        expect(100.5.roundToPlate(), 100.0);
        expect(101.5.roundToPlate(), 102.5);
        expect(103.7.roundToPlate(), 102.5);
        expect(104.0.roundToPlate(), 105.0);
        
        // Custom increment
        expect(103.0.roundToPlate(increment: 5.0), 105.0);
        expect(102.0.roundToPlate(increment: 5.0), 100.0);
      });
    });
  });
}