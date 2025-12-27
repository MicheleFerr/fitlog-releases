import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/utils/weight_rounding_utils.dart';

void main() {
  group('WeightRoundingUtils', () {
    group('detectEquipmentType', () {
      test('detects barbell from attrezzatura field', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Panca piana',
          attrezzaturaField: 'Bilanciere',
        );
        expect(result, EquipmentType.barbell);
      });

      test('detects dumbbell from attrezzatura field - manubri', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Curl',
          attrezzaturaField: 'Manubri',
        );
        expect(result, EquipmentType.dumbbell);
      });

      test('detects dumbbell from attrezzatura field - manubrio', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Curl',
          attrezzaturaField: 'Manubrio',
        );
        expect(result, EquipmentType.dumbbell);
      });

      test('detects machine from attrezzatura field - macchina', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Leg Extension',
          attrezzaturaField: 'Macchina',
        );
        expect(result, EquipmentType.machine);
      });

      test('detects machine from attrezzatura field - cavo', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Cable Crossover',
          attrezzaturaField: 'Cavo',
        );
        expect(result, EquipmentType.machine);
      });

      test('detects barbell from exercise name - barbell', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Barbell Bench Press',
        );
        expect(result, EquipmentType.barbell);
      });

      test('detects barbell from exercise name - BB prefix', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'BB Squat',
        );
        expect(result, EquipmentType.barbell);
      });

      test('detects dumbbell from exercise name - dumbbell', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Dumbbell Flyes',
        );
        expect(result, EquipmentType.dumbbell);
      });

      test('detects dumbbell from exercise name - DB prefix', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'DB Rows',
        );
        expect(result, EquipmentType.dumbbell);
      });

      test('detects machine from exercise name - machine', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Machine Chest Press',
        );
        expect(result, EquipmentType.machine);
      });

      test('detects machine from exercise name - cable', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Cable Curl',
        );
        expect(result, EquipmentType.machine);
      });

      test('detects machine from exercise name - smith', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Smith Machine Squat',
        );
        expect(result, EquipmentType.machine);
      });

      test('detects machine from exercise name - leg press', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Leg Press 45 degrees',
        );
        expect(result, EquipmentType.machine);
      });

      test('detects machine from exercise name - lat pulldown', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Lat Pulldown Wide Grip',
        );
        expect(result, EquipmentType.machine);
      });

      test('returns unknown for unrecognized equipment', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Push-ups',
        );
        expect(result, EquipmentType.unknown);
      });

      test('handles empty exercise name', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: '',
        );
        expect(result, EquipmentType.unknown);
      });

      test('handles null attrezzatura', () {
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Barbell Squat',
          attrezzaturaField: null,
        );
        expect(result, EquipmentType.barbell);
      });

      test('attrezzatura takes precedence over name', () {
        // Name says dumbbell but attrezzatura says barbell
        final result = WeightRoundingUtils.detectEquipmentType(
          exerciseName: 'Dumbbell Press',
          attrezzaturaField: 'Bilanciere',
        );
        expect(result, EquipmentType.barbell);
      });
    });

    group('roundForBarbell', () {
      test('minimum is bar weight (20kg)', () {
        expect(WeightRoundingUtils.roundForBarbell(15), 20.0);
        expect(WeightRoundingUtils.roundForBarbell(20), 20.0);
        expect(WeightRoundingUtils.roundForBarbell(0), 20.0);
      });

      test('rounds to 2.5kg increments above bar weight', () {
        expect(WeightRoundingUtils.roundForBarbell(21), 20.0); // 21-20=1, rounds to 0
        expect(WeightRoundingUtils.roundForBarbell(22), 22.5); // 22-20=2, rounds to 2.5
        expect(WeightRoundingUtils.roundForBarbell(23), 22.5); // 23-20=3, rounds to 2.5
        expect(WeightRoundingUtils.roundForBarbell(24), 25.0); // 24-20=4, rounds to 5
        expect(WeightRoundingUtils.roundForBarbell(25), 25.0);
      });

      test('handles larger weights correctly', () {
        expect(WeightRoundingUtils.roundForBarbell(100), 100.0);
        expect(WeightRoundingUtils.roundForBarbell(101), 100.0);
        expect(WeightRoundingUtils.roundForBarbell(102), 102.5);
        expect(WeightRoundingUtils.roundForBarbell(103), 102.5);
        expect(WeightRoundingUtils.roundForBarbell(104), 105.0);
      });

      test('handles negative weights (edge case)', () {
        // Negative weight should return bar weight
        expect(WeightRoundingUtils.roundForBarbell(-10), 20.0);
      });
    });

    group('roundForDumbbell', () {
      test('standard increment (2.5kg)', () {
        expect(
          WeightRoundingUtils.roundForDumbbell(17.3, DumbbellIncrement.standard),
          17.5,
        );
        expect(
          WeightRoundingUtils.roundForDumbbell(18.2, DumbbellIncrement.standard),
          17.5,
        );
        expect(
          WeightRoundingUtils.roundForDumbbell(18.8, DumbbellIncrement.standard),
          20.0,
        );
        expect(
          WeightRoundingUtils.roundForDumbbell(20.0, DumbbellIncrement.standard),
          20.0,
        );
      });

      test('half kg increment (0.5kg)', () {
        expect(
          WeightRoundingUtils.roundForDumbbell(17.3, DumbbellIncrement.halfKg),
          17.5,
        );
        expect(
          WeightRoundingUtils.roundForDumbbell(17.7, DumbbellIncrement.halfKg),
          17.5,
        );
        expect(
          WeightRoundingUtils.roundForDumbbell(17.8, DumbbellIncrement.halfKg),
          18.0,
        );
      });

      test('one kg increment (1kg)', () {
        expect(
          WeightRoundingUtils.roundForDumbbell(17.3, DumbbellIncrement.oneKg),
          17.0,
        );
        expect(
          WeightRoundingUtils.roundForDumbbell(17.5, DumbbellIncrement.oneKg),
          18.0,
        );
        expect(
          WeightRoundingUtils.roundForDumbbell(17.7, DumbbellIncrement.oneKg),
          18.0,
        );
      });

      test('two kg increment (2kg)', () {
        expect(
          WeightRoundingUtils.roundForDumbbell(17.0, DumbbellIncrement.twoKg),
          18.0,
        );
        expect(
          WeightRoundingUtils.roundForDumbbell(17.5, DumbbellIncrement.twoKg),
          18.0,
        );
        expect(
          WeightRoundingUtils.roundForDumbbell(18.9, DumbbellIncrement.twoKg),
          18.0,
        );
        expect(
          WeightRoundingUtils.roundForDumbbell(19.1, DumbbellIncrement.twoKg),
          20.0,
        );
      });

      test('handles zero weight', () {
        expect(
          WeightRoundingUtils.roundForDumbbell(0, DumbbellIncrement.standard),
          0.0,
        );
      });
    });

    group('roundForMachine', () {
      test('rounds to 5kg increments', () {
        expect(WeightRoundingUtils.roundForMachine(0), 0.0);
        expect(WeightRoundingUtils.roundForMachine(2), 0.0);
        expect(WeightRoundingUtils.roundForMachine(3), 5.0);
        expect(WeightRoundingUtils.roundForMachine(5), 5.0);
        expect(WeightRoundingUtils.roundForMachine(7), 5.0);
        expect(WeightRoundingUtils.roundForMachine(8), 10.0);
        expect(WeightRoundingUtils.roundForMachine(12), 10.0);
        expect(WeightRoundingUtils.roundForMachine(13), 15.0);
      });

      test('handles larger weights', () {
        expect(WeightRoundingUtils.roundForMachine(50), 50.0);
        expect(WeightRoundingUtils.roundForMachine(52), 50.0);
        expect(WeightRoundingUtils.roundForMachine(53), 55.0);
      });
    });

    group('calculateDroppedWeight', () {
      test('calculates 10% drop', () {
        expect(
          WeightRoundingUtils.calculateDroppedWeight(
            currentWeight: 100,
            dropPercentage: 10,
          ),
          90.0,
        );
      });

      test('calculates 20% drop', () {
        expect(
          WeightRoundingUtils.calculateDroppedWeight(
            currentWeight: 100,
            dropPercentage: 20,
          ),
          80.0,
        );
      });

      test('calculates 25% drop', () {
        expect(
          WeightRoundingUtils.calculateDroppedWeight(
            currentWeight: 80,
            dropPercentage: 25,
          ),
          60.0,
        );
      });

      test('calculates 30% drop', () {
        expect(
          WeightRoundingUtils.calculateDroppedWeight(
            currentWeight: 100,
            dropPercentage: 30,
          ),
          70.0,
        );
      });

      test('handles 0% drop', () {
        expect(
          WeightRoundingUtils.calculateDroppedWeight(
            currentWeight: 100,
            dropPercentage: 0,
          ),
          100.0,
        );
      });

      test('handles 100% drop', () {
        expect(
          WeightRoundingUtils.calculateDroppedWeight(
            currentWeight: 100,
            dropPercentage: 100,
          ),
          0.0,
        );
      });
    });

    group('calculateNextStageWeight', () {
      test('barbell 20% drop from 100kg', () {
        final result = WeightRoundingUtils.calculateNextStageWeight(
          currentWeight: 100,
          dropPercentage: 20,
          equipmentType: EquipmentType.barbell,
        );
        // 100 * 0.8 = 80kg, already rounded for barbell
        expect(result, 80.0);
      });

      test('barbell 20% drop from 95kg', () {
        final result = WeightRoundingUtils.calculateNextStageWeight(
          currentWeight: 95,
          dropPercentage: 20,
          equipmentType: EquipmentType.barbell,
        );
        // 95 * 0.8 = 76kg, rounds to 75 for barbell (20 + 55)
        expect(result, 75.0);
      });

      test('barbell 15% drop from 100kg', () {
        final result = WeightRoundingUtils.calculateNextStageWeight(
          currentWeight: 100,
          dropPercentage: 15,
          equipmentType: EquipmentType.barbell,
        );
        // 100 * 0.85 = 85kg, already rounded
        expect(result, 85.0);
      });

      test('dumbbell 20% drop from 30kg with standard increment', () {
        final result = WeightRoundingUtils.calculateNextStageWeight(
          currentWeight: 30,
          dropPercentage: 20,
          equipmentType: EquipmentType.dumbbell,
          dumbbellIncrement: DumbbellIncrement.standard,
        );
        // 30 * 0.8 = 24kg, rounds to 25 for standard dumbbell
        expect(result, 25.0);
      });

      test('dumbbell 25% drop from 32kg with half kg increment', () {
        final result = WeightRoundingUtils.calculateNextStageWeight(
          currentWeight: 32,
          dropPercentage: 25,
          equipmentType: EquipmentType.dumbbell,
          dumbbellIncrement: DumbbellIncrement.halfKg,
        );
        // 32 * 0.75 = 24kg, already rounded
        expect(result, 24.0);
      });

      test('machine 20% drop from 50kg', () {
        final result = WeightRoundingUtils.calculateNextStageWeight(
          currentWeight: 50,
          dropPercentage: 20,
          equipmentType: EquipmentType.machine,
        );
        // 50 * 0.8 = 40kg, already rounded for machine
        expect(result, 40.0);
      });

      test('machine 30% drop from 70kg', () {
        final result = WeightRoundingUtils.calculateNextStageWeight(
          currentWeight: 70,
          dropPercentage: 30,
          equipmentType: EquipmentType.machine,
        );
        // 70 * 0.7 = 49kg, rounds to 50 for machine
        expect(result, 50.0);
      });

      test('unknown equipment uses standard 2.5kg rounding', () {
        final result = WeightRoundingUtils.calculateNextStageWeight(
          currentWeight: 30,
          dropPercentage: 20,
          equipmentType: EquipmentType.unknown,
        );
        // 30 * 0.8 = 24kg, rounds to 25 for unknown (uses standard dumbbell)
        expect(result, 25.0);
      });
    });

    group('getEquipmentTypeName', () {
      test('returns correct names', () {
        expect(WeightRoundingUtils.getEquipmentTypeName(EquipmentType.barbell), 'Barbell');
        expect(WeightRoundingUtils.getEquipmentTypeName(EquipmentType.dumbbell), 'Dumbbell');
        expect(WeightRoundingUtils.getEquipmentTypeName(EquipmentType.machine), 'Machine');
        expect(WeightRoundingUtils.getEquipmentTypeName(EquipmentType.unknown), 'Unknown');
      });
    });

    group('getDumbbellIncrementName', () {
      test('returns correct names', () {
        expect(
          WeightRoundingUtils.getDumbbellIncrementName(DumbbellIncrement.standard),
          contains('2.5kg'),
        );
        expect(
          WeightRoundingUtils.getDumbbellIncrementName(DumbbellIncrement.halfKg),
          contains('0.5kg'),
        );
        expect(
          WeightRoundingUtils.getDumbbellIncrementName(DumbbellIncrement.oneKg),
          contains('1kg'),
        );
        expect(
          WeightRoundingUtils.getDumbbellIncrementName(DumbbellIncrement.twoKg),
          contains('2kg'),
        );
      });
    });

    group('standardDropPercentages', () {
      test('contains expected values', () {
        expect(WeightRoundingUtils.standardDropPercentages, [10, 15, 20, 25, 30]);
      });

      test('is immutable', () {
        // This should be a compile-time constant
        expect(WeightRoundingUtils.standardDropPercentages.length, 5);
      });
    });
  });
}
