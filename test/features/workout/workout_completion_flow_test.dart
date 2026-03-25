import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/core/services/analytics/mock_analytics_service.dart';
import 'package:gymbro_flutter_new/features/auth/data/auth_service.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_providers_shared.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}

class _TestAppConfigNotifier extends AppConfigNotifier {
  @override
  AppConfig build() => const AppConfig();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Workout Completion Flow', () {
    late ProviderContainer container;
    late MockAuthService mockAuthService;
    late MockAnalyticsService mockAnalyticsService;

    setUp(() {
      mockAuthService = MockAuthService();
      mockAnalyticsService = MockAnalyticsService();

      when(() => mockAuthService.currentUser).thenReturn(null);

      container = ProviderContainer(
        overrides: [
          analyticsServiceProvider.overrideWithValue(mockAnalyticsService),
          authServiceProvider.overrideWithValue(mockAuthService),
          appConfigProvider.overrideWith(_TestAppConfigNotifier.new),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('CRITICO: completeWorkout should mark workout as completed', () async {
      // Arrange
      final notifier = container.read(currentWorkoutProvider.notifier);
      notifier.createWorkout('Test Workout');
      final exercise = Exercise(
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        sets: [ExerciseSet(setNumber: 1, weight: 100, reps: 10)],
      );
      final workout = container.read(currentWorkoutProvider);
      expect(workout, isNotNull);

      // Act
      final completedWorkout = workout!
          .addExercise(exercise)
          .startWorkout()
          .completeWorkout();

      // Assert
      expect(completedWorkout.isCompleted, true);
      expect(completedWorkout.endTime, isNotNull);

      // TODO: Verificare salvataggio Firestore
      // TODO: Verificare aggiornamento stats utente
      // TODO: Verificare notifiche generate
    });

    test('should reorder exercises when dropped at end of list', () async {
      final notifier = container.read(currentWorkoutProvider.notifier);
      notifier.createWorkout('Reorder Test');

      notifier.addExercise(
        Exercise(
          id: 'ex-1',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [ExerciseSet(setNumber: 1, weight: 80, reps: 8)],
        ),
      );
      notifier.addExercise(
        Exercise(
          id: 'ex-2',
          name: 'Squat',
          type: ExerciseType.single,
          category: ExerciseCategory.legs,
          sets: [ExerciseSet(setNumber: 1, weight: 100, reps: 5)],
        ),
      );
      notifier.addExercise(
        Exercise(
          id: 'ex-3',
          name: 'Deadlift',
          type: ExerciseType.single,
          category: ExerciseCategory.back,
          sets: [ExerciseSet(setNumber: 1, weight: 120, reps: 5)],
        ),
      );

      notifier.reorderExercises(0, 3);

      final workout = container.read(currentWorkoutProvider);
      expect(workout, isNotNull);
      expect(workout!.exercises.map((e) => e.id).toList(), [
        'ex-2',
        'ex-3',
        'ex-1',
      ]);
    });

    test(
      'CRITICO: workout completion should update user stats atomically',
      () async {
        // TODO: Test transazione Firestore per stats
        // Verifica che aggiornamenti concorrenti non causino perdita dati
      },
    );

    test(
      'CRITICO: should auto-complete routine day if template matches',
      () async {
        // TODO: Test auto-completamento routine
      },
    );

    test('should handle completion errors gracefully', () async {
      // TODO: Test error handling durante salvataggio
    });

    test('should dispose correctly after completion', () async {
      // TODO: Test _isDisposed flag
    });
  });

  group('APRE Auto-Regulation', () {
    test('should calculate APRE weights from history', () async {
      // TODO: Test calcolo APRE
    });

    test('should not recalculate if recent calculations exist', () async {
      // TODO: Test cache APRE
    });

    test('should handle concurrent APRE calculations', () async {
      // TODO: Test _apreCalculationInProgress flag
    });
  });

  group('Exercise Management', () {
    test('should add exercise with APRE if enabled', () async {
      // TODO: Test aggiunta esercizio con APRE
    });

    test('should update exercise without breaking workout state', () async {
      // TODO: Test update esercizio
    });

    test('should reorder exercises correctly', () async {
      // TODO: Test riordino esercizi
    });
  });
}
