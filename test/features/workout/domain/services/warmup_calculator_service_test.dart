import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/warmup_calculator_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  late WarmupCalculatorService service;

  setUp(() {
    service = WarmupCalculatorService();
  });

  group('WarmupCalculatorService', () {
    // =========================================================================
    // V1: calculateWarmupSets
    // =========================================================================
    group('calculateWarmupSets (V1)', () {
      group('zero and negative weight', () {
        test('returns empty list for zero weight', () {
          final sets = service.calculateWarmupSets(0, isBarbell: true);
          expect(sets, isEmpty);
        });

        test('returns empty list for negative weight', () {
          final sets = service.calculateWarmupSets(-10, isBarbell: true);
          expect(sets, isEmpty);
        });
      });

      group('light weight protocol (<40kg)', () {
        test(
          'barbell with target >= 1.5x barbell returns empty bar set',
          () {
            // 35kg >= 20*1.5=30
            final sets = service.calculateWarmupSets(35, isBarbell: true);
            expect(sets.length, 1);
            expect(sets[0].weight, 20.0);
            expect(sets[0].reps, 10);
            expect(sets[0].percentage, 0);
          },
        );

        test(
          'barbell with target < 1.5x barbell returns 50% warmup',
          () {
            // 25kg < 20*1.5=30 -> non-barbell path
            final sets = service.calculateWarmupSets(25, isBarbell: true);
            expect(sets.length, 1);
            // 50% of 25 = 12.5 -> rounded to nearest 2.5 = 12.5
            expect(sets[0].percentage, 50);
          },
        );

        test('non-barbell returns 50% warmup', () {
          final sets = service.calculateWarmupSets(30, isBarbell: false);
          expect(sets.length, 1);
          expect(sets[0].percentage, 50);
          // 50% of 30 = 15 -> rounded
          expect(sets[0].reps, 10);
        });

        test('very light dumbbell weight', () {
          final sets = service.calculateWarmupSets(10, isBarbell: false);
          expect(sets.length, 1);
          // 50% of 10 = 5
          expect(sets[0].percentage, 50);
        });
      });

      group('medium weight protocol (40-80kg)', () {
        test('barbell 60kg returns 3 sets', () {
          final sets = service.calculateWarmupSets(60, isBarbell: true);
          expect(sets.length, 3);
          // Set 1: empty bar
          expect(sets[0].weight, 20.0);
          expect(sets[0].reps, 10);
          expect(sets[0].percentage, 0);
          // Set 2: 50%
          expect(sets[1].percentage, 50);
          expect(sets[1].reps, 8);
          // Set 3: 80%
          expect(sets[2].percentage, 80);
          expect(sets[2].reps, 3);
        });

        test('non-barbell 50kg returns 2 sets', () {
          final sets = service.calculateWarmupSets(50, isBarbell: false);
          expect(sets.length, 2);
          // Set 1: 50%
          expect(sets[0].percentage, 50);
          expect(sets[0].reps, 10);
          // Set 2: 80%
          expect(sets[1].percentage, 80);
          expect(sets[1].reps, 3);
        });

        test('boundary at 40kg barbell', () {
          final sets = service.calculateWarmupSets(40, isBarbell: true);
          expect(sets.length, 3);
          expect(sets[0].weight, 20.0); // empty bar
        });

        test('boundary at 79kg barbell', () {
          final sets = service.calculateWarmupSets(79, isBarbell: true);
          expect(sets.length, 3);
        });
      });

      group('heavy weight protocol (80-120kg)', () {
        test('barbell 100kg returns 4 sets', () {
          final sets = service.calculateWarmupSets(100, isBarbell: true);
          expect(sets.length, 4);
          // Set 1: empty bar
          expect(sets[0].weight, 20.0);
          expect(sets[0].reps, 10);
          // Set 2: 40%
          expect(sets[1].percentage, 40);
          expect(sets[1].reps, 8);
          // Set 3: 60%
          expect(sets[2].percentage, 60);
          expect(sets[2].reps, 5);
          // Set 4: 80%
          expect(sets[3].percentage, 80);
          expect(sets[3].reps, 3);
        });

        test('non-barbell 100kg returns 3 sets (no bar set)', () {
          final sets = service.calculateWarmupSets(100, isBarbell: false);
          expect(sets.length, 3);
          expect(sets[0].percentage, 40);
          expect(sets[1].percentage, 60);
          expect(sets[2].percentage, 80);
        });

        test('boundary at 80kg', () {
          final sets = service.calculateWarmupSets(80, isBarbell: true);
          expect(sets.length, 4);
        });

        test('boundary at 119kg', () {
          final sets = service.calculateWarmupSets(119, isBarbell: true);
          expect(sets.length, 4);
        });
      });

      group('very heavy weight protocol (>=120kg)', () {
        test('barbell 140kg returns 5 sets', () {
          final sets = service.calculateWarmupSets(140, isBarbell: true);
          expect(sets.length, 5);
          // Set 1: empty bar
          expect(sets[0].weight, 20.0);
          expect(sets[0].reps, 10);
          // Set 2: 40%
          expect(sets[1].percentage, 40);
          expect(sets[1].reps, 8);
          // Set 3: 55%
          expect(sets[2].percentage, 55);
          expect(sets[2].reps, 6);
          // Set 4: 70%
          expect(sets[3].percentage, 70);
          expect(sets[3].reps, 4);
          // Set 5: 80%
          expect(sets[4].percentage, 80);
          expect(sets[4].reps, 2);
        });

        test('non-barbell 150kg returns 4 sets (no bar set)', () {
          final sets = service.calculateWarmupSets(150, isBarbell: false);
          expect(sets.length, 4);
          expect(sets[0].percentage, 40);
          expect(sets[1].percentage, 55);
          expect(sets[2].percentage, 70);
          expect(sets[3].percentage, 80);
        });

        test('boundary at 120kg', () {
          final sets = service.calculateWarmupSets(120, isBarbell: true);
          expect(sets.length, 5);
        });

        test('very heavy 200kg barbell', () {
          final sets = service.calculateWarmupSets(200, isBarbell: true);
          expect(sets.length, 5);
          // 80% of 200 = 160
          expect(sets[4].percentage, 80);
        });
      });

      group('custom available plates', () {
        test('custom plates affect rounding', () {
          final sets = service.calculateWarmupSets(
            60,
            isBarbell: true,
            availablePlates: [20.0, 10.0, 5.0],
          );
          expect(sets.isNotEmpty, isTrue);
          // All weights should be achievable with these plates
          for (final s in sets) {
            expect(s.weight, greaterThan(0));
          }
        });
      });
    });

    // =========================================================================
    // V2: calculateWarmupSetsV2
    // =========================================================================
    group('calculateWarmupSetsV2', () {
      group('zero and negative weight', () {
        test('returns empty list for zero weight', () {
          final sets = service.calculateWarmupSetsV2(
            0,
            isBarbell: true,
          );
          expect(sets, isEmpty);
        });

        test('returns empty list for negative weight', () {
          final sets = service.calculateWarmupSetsV2(
            -5,
            isBarbell: true,
          );
          expect(sets, isEmpty);
        });
      });

      group('alreadyWarm context', () {
        test('returns empty list regardless of weight', () {
          final sets = service.calculateWarmupSetsV2(
            100,
            warmupContext: WarmupContext.alreadyWarm,
            isBarbell: true,
          );
          expect(sets, isEmpty);
        });

        test('returns empty for light weight too', () {
          final sets = service.calculateWarmupSetsV2(
            20,
            warmupContext: WarmupContext.alreadyWarm,
            isBarbell: false,
          );
          expect(sets, isEmpty);
        });
      });

      group('subsequent context', () {
        test('returns single set at 55%', () {
          final sets = service.calculateWarmupSetsV2(
            100,
            warmupContext: WarmupContext.subsequent,
            isBarbell: true,
          );
          expect(sets.length, 1);
          expect(sets[0].percentage, 55);
          expect(sets[0].reps, 4);
        });

        test('barbell clamps minimum to barbell weight', () {
          // 55% of 30 = 16.5, clamped to 20 (barbell weight)
          final sets = service.calculateWarmupSetsV2(
            30,
            warmupContext: WarmupContext.subsequent,
            isBarbell: true,
          );
          expect(sets.length, 1);
          expect(sets[0].weight, greaterThanOrEqualTo(20.0));
        });

        test('non-barbell does not clamp to barbell weight', () {
          // 55% of 20 = 11 -> rounded
          final sets = service.calculateWarmupSetsV2(
            20,
            warmupContext: WarmupContext.subsequent,
            isBarbell: false,
          );
          expect(sets.length, 1);
          expect(sets[0].percentage, 55);
        });

        test('subsequent for heavy weight still single set', () {
          final sets = service.calculateWarmupSetsV2(
            200,
            warmupContext: WarmupContext.subsequent,
            isBarbell: true,
          );
          expect(sets.length, 1);
          expect(sets[0].percentage, 55);
        });
      });

      group('firstCompound context - light (<40kg)', () {
        test(
          'barbell with target >= 1.5x barbell returns bar set',
          () {
            final sets = service.calculateWarmupSetsV2(
              35,
              warmupContext: WarmupContext.firstCompound,
              isBarbell: true,
            );
            expect(sets.length, 1);
            expect(sets[0].weight, 20.0);
            expect(sets[0].reps, 5);
            expect(sets[0].percentage, 0);
          },
        );

        test('non-barbell returns 50% set', () {
          final sets = service.calculateWarmupSetsV2(
            30,
            warmupContext: WarmupContext.firstCompound,
            isBarbell: false,
          );
          expect(sets.length, 1);
          expect(sets[0].percentage, 50);
          expect(sets[0].reps, 5);
        });
      });

      group('firstCompound context - medium (40-80kg)', () {
        test('barbell returns 3 sets: bar, 60%, 80%', () {
          final sets = service.calculateWarmupSetsV2(
            60,
            warmupContext: WarmupContext.firstCompound,
            isBarbell: true,
          );
          expect(sets.length, 3);
          expect(sets[0].weight, 20.0);
          expect(sets[0].reps, 5);
          expect(sets[1].percentage, 60);
          expect(sets[1].reps, 3);
          expect(sets[2].percentage, 80);
          expect(sets[2].reps, 2);
        });

        test('non-barbell returns 3 sets: 40%, 60%, 80%', () {
          final sets = service.calculateWarmupSetsV2(
            60,
            warmupContext: WarmupContext.firstCompound,
            isBarbell: false,
          );
          expect(sets.length, 3);
          expect(sets[0].percentage, 40);
          expect(sets[0].reps, 5);
          expect(sets[1].percentage, 60);
          expect(sets[1].reps, 3);
          expect(sets[2].percentage, 80);
          expect(sets[2].reps, 2);
        });
      });

      group('firstCompound context - heavy (80-120kg)', () {
        test('barbell returns 4 sets: bar, 50%, 70%, 85%', () {
          final sets = service.calculateWarmupSetsV2(
            100,
            warmupContext: WarmupContext.firstCompound,
            isBarbell: true,
          );
          expect(sets.length, 4);
          expect(sets[0].weight, 20.0);
          expect(sets[0].reps, 5);
          expect(sets[1].percentage, 50);
          expect(sets[1].reps, 3);
          expect(sets[2].percentage, 70);
          expect(sets[2].reps, 2);
          expect(sets[3].percentage, 85);
          expect(sets[3].reps, 1);
        });

        test('non-barbell 100kg returns 3 sets (no bar)', () {
          final sets = service.calculateWarmupSetsV2(
            100,
            warmupContext: WarmupContext.firstCompound,
            isBarbell: false,
          );
          expect(sets.length, 3);
          expect(sets[0].percentage, 50);
          expect(sets[1].percentage, 70);
          expect(sets[2].percentage, 85);
        });
      });

      group('firstCompound context - very heavy (>=120kg)', () {
        test('barbell returns 5 sets: bar, 40%, 60%, 75%, 85%', () {
          final sets = service.calculateWarmupSetsV2(
            150,
            warmupContext: WarmupContext.firstCompound,
            isBarbell: true,
          );
          expect(sets.length, 5);
          expect(sets[0].weight, 20.0);
          expect(sets[0].reps, 5);
          expect(sets[1].percentage, 40);
          expect(sets[1].reps, 3);
          expect(sets[2].percentage, 60);
          expect(sets[2].reps, 2);
          expect(sets[3].percentage, 75);
          expect(sets[3].reps, 1);
          expect(sets[4].percentage, 85);
          expect(sets[4].reps, 1);
        });

        test('non-barbell 140kg returns 4 sets', () {
          final sets = service.calculateWarmupSetsV2(
            140,
            warmupContext: WarmupContext.firstCompound,
            isBarbell: false,
          );
          expect(sets.length, 4);
          expect(sets[0].percentage, 40);
          expect(sets[1].percentage, 60);
          expect(sets[2].percentage, 75);
          expect(sets[3].percentage, 85);
        });
      });

      group('default context is firstCompound', () {
        test('no context specified defaults to firstCompound', () {
          final sets = service.calculateWarmupSetsV2(
            100,
            isBarbell: true,
          );
          // Should get full protocol (4 sets for 80-120kg)
          expect(sets.length, 4);
        });
      });
    });

    // =========================================================================
    // determineContext
    // =========================================================================
    group('determineContext', () {
      test('returns alreadyWarm for direct match', () {
        final context = WarmupCalculatorService.determineContext(
          ExerciseCategory.chest,
          {ExerciseCategory.chest},
        );
        expect(context, WarmupContext.alreadyWarm);
      });

      test('returns subsequent for synergistic match (chest->shoulders)', () {
        // Chest trains shoulders synergistically
        final context = WarmupCalculatorService.determineContext(
          ExerciseCategory.shoulders,
          {ExerciseCategory.chest},
        );
        expect(context, WarmupContext.subsequent);
      });

      test('returns subsequent for synergistic match (chest->arms)', () {
        final context = WarmupCalculatorService.determineContext(
          ExerciseCategory.arms,
          {ExerciseCategory.chest},
        );
        expect(context, WarmupContext.subsequent);
      });

      test('returns subsequent for synergistic match (back->arms)', () {
        final context = WarmupCalculatorService.determineContext(
          ExerciseCategory.arms,
          {ExerciseCategory.back},
        );
        expect(context, WarmupContext.subsequent);
      });

      test('returns subsequent for synergistic match (back->shoulders)', () {
        final context = WarmupCalculatorService.determineContext(
          ExerciseCategory.shoulders,
          {ExerciseCategory.back},
        );
        expect(context, WarmupContext.subsequent);
      });

      test('returns subsequent for synergistic match (shoulders->arms)', () {
        final context = WarmupCalculatorService.determineContext(
          ExerciseCategory.arms,
          {ExerciseCategory.shoulders},
        );
        expect(context, WarmupContext.subsequent);
      });

      test('returns subsequent for synergistic match (shoulders->chest)', () {
        final context = WarmupCalculatorService.determineContext(
          ExerciseCategory.chest,
          {ExerciseCategory.shoulders},
        );
        expect(context, WarmupContext.subsequent);
      });

      test('returns subsequent for synergistic match (legs->abs)', () {
        final context = WarmupCalculatorService.determineContext(
          ExerciseCategory.abs,
          {ExerciseCategory.legs},
        );
        expect(context, WarmupContext.subsequent);
      });

      test('returns firstCompound for no match', () {
        final context = WarmupCalculatorService.determineContext(
          ExerciseCategory.chest,
          {ExerciseCategory.legs},
        );
        expect(context, WarmupContext.firstCompound);
      });

      test('returns firstCompound for empty trained set', () {
        final context = WarmupCalculatorService.determineContext(
          ExerciseCategory.chest,
          {},
        );
        expect(context, WarmupContext.firstCompound);
      });

      test('direct match takes priority over synergistic', () {
        // Chest is both directly trained AND synergistic via shoulders
        final context = WarmupCalculatorService.determineContext(
          ExerciseCategory.chest,
          {ExerciseCategory.chest, ExerciseCategory.shoulders},
        );
        expect(context, WarmupContext.alreadyWarm);
      });

      test('legs does not warm up chest (no synergy)', () {
        final context = WarmupCalculatorService.determineContext(
          ExerciseCategory.chest,
          {ExerciseCategory.legs},
        );
        expect(context, WarmupContext.firstCompound);
      });

      test('cardio has no synergistic categories', () {
        final context = WarmupCalculatorService.determineContext(
          ExerciseCategory.cardio,
          {ExerciseCategory.chest, ExerciseCategory.back, ExerciseCategory.legs},
        );
        expect(context, WarmupContext.firstCompound);
      });
    });

    // =========================================================================
    // isLikelyBarbellExercise
    // =========================================================================
    group('isLikelyBarbellExercise', () {
      group('explicit barbell indicators', () {
        test('detects "barbell" in name', () {
          expect(service.isLikelyBarbellExercise('Barbell Curl'), isTrue);
        });

        test('detects "bar " in name', () {
          expect(service.isLikelyBarbellExercise('Bar Dip'), isTrue);
        });

        test('detects " bb" in name', () {
          expect(service.isLikelyBarbellExercise('Close Grip BB Press'), isTrue);
        });

        test('detects "bilanciere" (Italian)', () {
          expect(service.isLikelyBarbellExercise('Curl Bilanciere'), isTrue);
        });
      });

      group('compound lift patterns', () {
        test('detects squat', () {
          expect(service.isLikelyBarbellExercise('Back Squat'), isTrue);
        });

        test('detects bench', () {
          expect(service.isLikelyBarbellExercise('Bench Press'), isTrue);
        });

        test('detects deadlift', () {
          expect(service.isLikelyBarbellExercise('Deadlift'), isTrue);
        });

        test('detects press', () {
          expect(service.isLikelyBarbellExercise('Overhead Press'), isTrue);
        });

        test('detects row', () {
          expect(service.isLikelyBarbellExercise('Pendlay Row'), isTrue);
        });

        test('detects clean', () {
          expect(service.isLikelyBarbellExercise('Power Clean'), isTrue);
        });

        test('detects snatch', () {
          expect(service.isLikelyBarbellExercise('Olympic Snatch'), isTrue);
        });

        test('detects jerk', () {
          expect(service.isLikelyBarbellExercise('Push Jerk'), isTrue);
        });

        test('detects thruster', () {
          expect(service.isLikelyBarbellExercise('Barbell Thruster'), isTrue);
        });
      });

      group('Italian exercise names', () {
        test('detects panca (bench)', () {
          expect(service.isLikelyBarbellExercise('Panca Piana'), isTrue);
        });

        test('detects stacco (deadlift)', () {
          expect(service.isLikelyBarbellExercise('Stacco da Terra'), isTrue);
        });

        test('detects rematore (row)', () {
          expect(service.isLikelyBarbellExercise('Rematore'), isTrue);
        });
      });

      group('non-barbell exercises', () {
        test('dumbbell is not barbell', () {
          expect(
            service.isLikelyBarbellExercise('Dumbbell Press'),
            isFalse,
          );
        });

        test('db is not barbell', () {
          expect(service.isLikelyBarbellExercise('DB Curl'), isFalse);
        });

        test('cable is not barbell', () {
          expect(service.isLikelyBarbellExercise('Cable Fly'), isFalse);
        });

        test('machine is not barbell', () {
          expect(
            service.isLikelyBarbellExercise('Machine Press'),
            isFalse,
          );
        });

        test('smith is not barbell', () {
          expect(
            service.isLikelyBarbellExercise('Smith Machine Squat'),
            isFalse,
          );
        });

        test('manubrio is not barbell (Italian dumbbell)', () {
          expect(
            service.isLikelyBarbellExercise('Curl Manubrio'),
            isFalse,
          );
        });

        test('cavo is not barbell (Italian cable)', () {
          expect(
            service.isLikelyBarbellExercise('Croci al Cavo'),
            isFalse,
          );
        });

        test('macchina is not barbell (Italian machine)', () {
          expect(
            service.isLikelyBarbellExercise('Chest Press Macchina'),
            isFalse,
          );
        });
      });

      group('edge cases', () {
        test('non-barbell indicator takes priority', () {
          // "Dumbbell Bench Press" - has both dumbbell and bench
          expect(
            service.isLikelyBarbellExercise('Dumbbell Bench Press'),
            isFalse,
          );
        });

        test('case insensitive', () {
          expect(service.isLikelyBarbellExercise('BARBELL CURL'), isTrue);
          expect(service.isLikelyBarbellExercise('dumbbell curl'), isFalse);
        });

        test('unknown exercise returns false', () {
          expect(service.isLikelyBarbellExercise('Plank'), isFalse);
        });

        test('empty string returns false', () {
          expect(service.isLikelyBarbellExercise(''), isFalse);
        });
      });
    });

    // =========================================================================
    // isBarbellByAttrezzatura
    // =========================================================================
    group('isBarbellByAttrezzatura', () {
      test('null returns false', () {
        expect(service.isBarbellByAttrezzatura(null), isFalse);
      });

      test('empty string returns false', () {
        expect(service.isBarbellByAttrezzatura(''), isFalse);
      });

      test('"bilanciere" returns true', () {
        expect(service.isBarbellByAttrezzatura('Bilanciere'), isTrue);
      });

      test('"barbell" returns true', () {
        expect(service.isBarbellByAttrezzatura('Barbell'), isTrue);
      });

      test('"olympic barbell" returns true', () {
        expect(service.isBarbellByAttrezzatura('Olympic Barbell'), isTrue);
      });

      test('"ez bar" returns true', () {
        expect(service.isBarbellByAttrezzatura('EZ Bar'), isTrue);
      });

      test('"trap bar" returns true', () {
        expect(service.isBarbellByAttrezzatura('Trap Bar'), isTrue);
      });

      test('"manubrio" (dumbbell) returns false', () {
        expect(service.isBarbellByAttrezzatura('Manubrio'), isFalse);
      });

      test('"machine" returns false', () {
        expect(service.isBarbellByAttrezzatura('Machine'), isFalse);
      });

      test('"cable" returns false', () {
        expect(service.isBarbellByAttrezzatura('Cable'), isFalse);
      });

      test('case insensitive matching', () {
        expect(service.isBarbellByAttrezzatura('BILANCIERE'), isTrue);
        expect(service.isBarbellByAttrezzatura('barbell'), isTrue);
      });
    });

    // =========================================================================
    // roundToAvailablePlates
    // =========================================================================
    group('roundToAvailablePlates', () {
      test('rounds to nearest 2.5 with default plates', () {
        // Default smallest = 1.25, increment = 2.5
        expect(service.roundToAvailablePlates(47.3), 47.5);
        expect(service.roundToAvailablePlates(46.2), 45.0);
        expect(service.roundToAvailablePlates(50.0), 50.0);
      });

      test('rounds to nearest 5.0 with only large plates', () {
        // Smallest plate 5.0 -> increment = 5.0
        final result = service.roundToAvailablePlates(
          47.3,
          availablePlates: [25.0, 20.0, 15.0, 10.0, 5.0],
        );
        expect(result, 45.0);
      });

      test('handles zero weight', () {
        expect(service.roundToAvailablePlates(0), 0.0);
      });

      test('handles exact weight', () {
        expect(service.roundToAvailablePlates(50.0), 50.0);
      });

      test('custom plates with microplates', () {
        final result = service.roundToAvailablePlates(
          33.7,
          availablePlates: [20.0, 10.0, 5.0, 2.5, 1.25, 0.5],
        );
        // Smallest = 0.5, which is <= 2.5, so increment = 2.5
        expect(result, 32.5);
      });
    });

    // =========================================================================
    // calculatePlatesPerSide
    // =========================================================================
    group('calculatePlatesPerSide', () {
      test('100kg total returns correct plate distribution', () {
        // 100 - 20 = 80, per side = 40
        // 25 + 15 = 40
        final plates = service.calculatePlatesPerSide(100);
        expect(plates[25.0], 1);
        expect(plates[15.0], 1);
      });

      test('just barbell weight returns empty map', () {
        final plates = service.calculatePlatesPerSide(20);
        expect(plates, isEmpty);
      });

      test('weight less than barbell returns empty map', () {
        final plates = service.calculatePlatesPerSide(15);
        expect(plates, isEmpty);
      });

      test('custom barbell weight', () {
        // 50 - 15 = 35, per side = 17.5
        // 15 + 2.5 = 17.5
        final plates = service.calculatePlatesPerSide(50, barbellWeight: 15);
        expect(plates[15.0], 1);
        expect(plates[2.5], 1);
      });

      test('large weight uses multiple same plates', () {
        // 220 - 20 = 200, per side = 100
        // 4x25 = 100
        final plates = service.calculatePlatesPerSide(220);
        expect(plates[25.0], 4);
      });

      test('custom available plates', () {
        // 60 - 20 = 40, per side = 20
        // Only have 10kg plates: 2x10 = 20
        final plates = service.calculatePlatesPerSide(
          60,
          availablePlates: [10.0],
        );
        expect(plates[10.0], 2);
      });

      test('zero total weight returns empty map', () {
        final plates = service.calculatePlatesPerSide(0);
        expect(plates, isEmpty);
      });
    });
  });

  // ===========================================================================
  // WarmupSet
  // ===========================================================================
  group('WarmupSet', () {
    test('stores weight, reps, and percentage', () {
      const set = WarmupSet(weight: 60.0, reps: 5, percentage: 50);
      expect(set.weight, 60.0);
      expect(set.reps, 5);
      expect(set.percentage, 50);
    });
  });

  // ===========================================================================
  // WarmupContext enum
  // ===========================================================================
  group('WarmupContext enum', () {
    test('has all expected values', () {
      expect(WarmupContext.values.length, 3);
      expect(WarmupContext.values, contains(WarmupContext.firstCompound));
      expect(WarmupContext.values, contains(WarmupContext.subsequent));
      expect(WarmupContext.values, contains(WarmupContext.alreadyWarm));
    });
  });
}
