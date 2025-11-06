import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/recovery_time_calculator.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';

void main() {
  late RecoveryTimeCalculator calculator;

  setUp(() {
    calculator = RecoveryTimeCalculator();
  });

  group('RecoveryTimeCalculator', () {
    group('calculateRecoveryStatus', () {
      test('should mark PUSH workout as recovered after 48 hours', () {
        final lastWorkout = DateTime.now().subtract(const Duration(hours: 48));

        final status = calculator.calculateRecoveryStatus(
          workoutType: 'PUSH',
          lastWorkoutTime: lastWorkout,
        );

        expect(status.isRecovered, isTrue);
        expect(status.workoutType, 'PUSH');
        expect(status.hoursSinceWorkout, 48);
      });

      test('should mark PUSH workout as NOT recovered after only 24 hours', () {
        final lastWorkout = DateTime.now().subtract(const Duration(hours: 24));

        final status = calculator.calculateRecoveryStatus(
          workoutType: 'PUSH',
          lastWorkoutTime: lastWorkout,
        );

        expect(status.isRecovered, isFalse);
        expect(status.hoursUntilRecovered, greaterThan(0));
      });

      test('should require longer recovery for LEGS (72 hours)', () {
        final lastWorkout = DateTime.now().subtract(const Duration(hours: 60));

        final status = calculator.calculateRecoveryStatus(
          workoutType: 'LEGS',
          lastWorkoutTime: lastWorkout,
        );

        expect(status.isRecovered, isFalse);
        expect(status.workoutType, 'LEGS');
      });

      test('should mark LEGS as recovered after 72 hours', () {
        final lastWorkout = DateTime.now().subtract(const Duration(hours: 72));

        final status = calculator.calculateRecoveryStatus(
          workoutType: 'LEGS',
          lastWorkoutTime: lastWorkout,
        );

        expect(status.isRecovered, isTrue);
      });

      test('should calculate recovery percentage correctly', () {
        // PUSH optimal recovery is 72 hours
        final lastWorkout = DateTime.now().subtract(const Duration(hours: 36));

        final status = calculator.calculateRecoveryStatus(
          workoutType: 'PUSH',
          lastWorkoutTime: lastWorkout,
        );

        // 36 hours out of 72 optimal = 50%
        expect(status.recoveryPercentage, closeTo(0.5, 0.01));
        expect(status.isRecovered, isFalse); // Not yet at minimum 48h
      });

      test('should cap recovery percentage at 1.0', () {
        final lastWorkout = DateTime.now().subtract(const Duration(days: 10));

        final status = calculator.calculateRecoveryStatus(
          workoutType: 'PUSH',
          lastWorkoutTime: lastWorkout,
        );

        expect(status.recoveryPercentage, equals(1.0));
        expect(status.isRecovered, isTrue);
      });

      test('should handle ARMS with shorter recovery time (36 hours min)', () {
        final lastWorkout = DateTime.now().subtract(const Duration(hours: 36));

        final status = calculator.calculateRecoveryStatus(
          workoutType: 'ARMS',
          lastWorkoutTime: lastWorkout,
        );

        expect(status.isRecovered, isTrue);
      });

      test('should handle unknown workout types with default 48 hours', () {
        final lastWorkout = DateTime.now().subtract(const Duration(hours: 48));

        final status = calculator.calculateRecoveryStatus(
          workoutType: 'CUSTOM_WORKOUT',
          lastWorkoutTime: lastWorkout,
        );

        expect(status.isRecovered, isTrue);
      });
    });

    group('calculateAllRecoveryStatuses', () {
      test('should calculate recovery for all workout types in pattern', () {
        final now = DateTime.now();
        final workouts = [
          WorkoutModel(
            id: '1',
            name: 'Push Day',
            startTime: now.subtract(const Duration(hours: 48)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(hours: 48)),
            updatedAt: now.subtract(const Duration(hours: 48)),
          ),
          WorkoutModel(
            id: '2',
            name: 'Pull Day',
            startTime: now.subtract(const Duration(hours: 72)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(hours: 72)),
            updatedAt: now.subtract(const Duration(hours: 72)),
          ),
          WorkoutModel(
            id: '3',
            name: 'Leg Day',
            startTime: now.subtract(const Duration(hours: 24)),
            exercises: const [],
            status: 'completed',
            createdAt: now.subtract(const Duration(hours: 24)),
            updatedAt: now.subtract(const Duration(hours: 24)),
          ),
        ];

        final statuses = calculator.calculateAllRecoveryStatuses(
          workoutTypes: ['PUSH', 'PULL', 'LEGS'],
          recentWorkouts: workouts,
        );

        expect(statuses.length, equals(3));
        expect(statuses['PUSH']!.isRecovered, isTrue); // 48h passed
        expect(statuses['PULL']!.isRecovered, isTrue); // 72h passed
        expect(statuses['LEGS']!.isRecovered, isFalse); // Only 24h, needs 72h
      });

      test('should mark workout as fully recovered if never done', () {
        final statuses = calculator.calculateAllRecoveryStatuses(
          workoutTypes: ['PUSH', 'PULL', 'LEGS'],
          recentWorkouts: [], // No workouts
        );

        expect(statuses.length, equals(3));
        expect(statuses['PUSH']!.isRecovered, isTrue);
        expect(statuses['PUSH']!.recoveryPercentage, equals(1.0));
        expect(statuses['PULL']!.isRecovered, isTrue);
        expect(statuses['LEGS']!.isRecovered, isTrue);
      });
    });

    group('findBestRecoveredWorkout', () {
      test('should find the most recovered workout', () {
        final statuses = {
          'PUSH': const RecoveryStatus(
            isRecovered: true,
            hoursUntilRecovered: 0,
            recoveryPercentage: 0.8,
            workoutType: 'PUSH',
            hoursSinceWorkout: 60,
          ),
          'PULL': const RecoveryStatus(
            isRecovered: true,
            hoursUntilRecovered: 0,
            recoveryPercentage: 1.0,
            workoutType: 'PULL',
            hoursSinceWorkout: 96,
          ),
          'LEGS': const RecoveryStatus(
            isRecovered: false,
            hoursUntilRecovered: 24,
            recoveryPercentage: 0.5,
            workoutType: 'LEGS',
            hoursSinceWorkout: 48,
          ),
        };

        final best = calculator.findBestRecoveredWorkout(recoveryStatuses: statuses);

        expect(best, equals('PULL')); // 100% recovery
      });

      test('should return null if no workouts are recovered', () {
        final statuses = {
          'PUSH': const RecoveryStatus(
            isRecovered: false,
            hoursUntilRecovered: 12,
            recoveryPercentage: 0.4,
            workoutType: 'PUSH',
            hoursSinceWorkout: 36,
          ),
          'PULL': const RecoveryStatus(
            isRecovered: false,
            hoursUntilRecovered: 24,
            recoveryPercentage: 0.3,
            workoutType: 'PULL',
            hoursSinceWorkout: 24,
          ),
        };

        final best = calculator.findBestRecoveredWorkout(recoveryStatuses: statuses);

        expect(best, isNull);
      });

      test('should return null for empty statuses', () {
        final best = calculator.findBestRecoveredWorkout(recoveryStatuses: {});

        expect(best, isNull);
      });
    });

    group('getRecoveryConfidenceBoost', () {
      test('should give +0.15 boost for fully recovered (100%)', () {
        const status = RecoveryStatus(
          isRecovered: true,
          hoursUntilRecovered: 0,
          recoveryPercentage: 1.0,
          workoutType: 'PUSH',
          hoursSinceWorkout: 72,
        );

        final boost = calculator.getRecoveryConfidenceBoost(status);

        expect(boost, equals(0.15));
      });

      test('should give +0.10 boost for well recovered (80-99%)', () {
        const status = RecoveryStatus(
          isRecovered: true,
          hoursUntilRecovered: 0,
          recoveryPercentage: 0.85,
          workoutType: 'PUSH',
          hoursSinceWorkout: 61,
        );

        final boost = calculator.getRecoveryConfidenceBoost(status);

        expect(boost, equals(0.10));
      });

      test('should give +0.05 boost for adequately recovered (60-79%)', () {
        const status = RecoveryStatus(
          isRecovered: true,
          hoursUntilRecovered: 0,
          recoveryPercentage: 0.7,
          workoutType: 'PUSH',
          hoursSinceWorkout: 50,
        );

        final boost = calculator.getRecoveryConfidenceBoost(status);

        expect(boost, equals(0.05));
      });

      test('should give 0 boost for minimally recovered', () {
        const status = RecoveryStatus(
          isRecovered: true,
          hoursUntilRecovered: 0,
          recoveryPercentage: 0.55,
          workoutType: 'PUSH',
          hoursSinceWorkout: 48,
        );

        final boost = calculator.getRecoveryConfidenceBoost(status);

        expect(boost, equals(0.0));
      });

      test('should give -0.10 penalty for under-recovered', () {
        const status = RecoveryStatus(
          isRecovered: false,
          hoursUntilRecovered: 12,
          recoveryPercentage: 0.4,
          workoutType: 'PUSH',
          hoursSinceWorkout: 36,
        );

        final boost = calculator.getRecoveryConfidenceBoost(status);

        expect(boost, equals(-0.10));
      });
    });
  });

  group('RecoveryStatus', () {
    test('description should reflect recovery state', () {
      const fullyRecovered = RecoveryStatus(
        isRecovered: true,
        hoursUntilRecovered: 0,
        recoveryPercentage: 1.0,
        workoutType: 'PUSH',
        hoursSinceWorkout: 72,
      );

      const wellRecovered = RecoveryStatus(
        isRecovered: true,
        hoursUntilRecovered: 0,
        recoveryPercentage: 0.85,
        workoutType: 'PUSH',
        hoursSinceWorkout: 61,
      );

      const recovering = RecoveryStatus(
        isRecovered: false,
        hoursUntilRecovered: 12,
        recoveryPercentage: 0.5,
        workoutType: 'PUSH',
        hoursSinceWorkout: 36,
      );

      expect(fullyRecovered.description, 'Completamente recuperato');
      expect(wellRecovered.description, 'Ben recuperato');
      expect(recovering.description, 'In recupero (12 ore rimanenti)');
    });

    test('emoji should reflect recovery state', () {
      const fullyRecovered = RecoveryStatus(
        isRecovered: true,
        hoursUntilRecovered: 0,
        recoveryPercentage: 1.0,
        workoutType: 'PUSH',
        hoursSinceWorkout: 72,
      );

      const wellRecovered = RecoveryStatus(
        isRecovered: true,
        hoursUntilRecovered: 0,
        recoveryPercentage: 0.85,
        workoutType: 'PUSH',
        hoursSinceWorkout: 61,
      );

      const recovering = RecoveryStatus(
        isRecovered: false,
        hoursUntilRecovered: 12,
        recoveryPercentage: 0.5,
        workoutType: 'PUSH',
        hoursSinceWorkout: 36,
      );

      expect(fullyRecovered.emoji, '💪');
      expect(wellRecovered.emoji, '✅');
      expect(recovering.emoji, '⏳');
    });
  });
}
