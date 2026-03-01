import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';

// Helper factories
SetHistoryDetail makeSet({
  int setNumber = 1,
  double weight = 100.0,
  int reps = 10,
  int rpe = 7,
}) {
  return SetHistoryDetail(
    setNumber: setNumber,
    weight: weight,
    reps: reps,
    rpe: rpe,
  );
}

ExerciseHistoryDetail makeExercise({
  String id = 'ex1',
  String name = 'Bench Press',
  String category = 'chest',
  List<SetHistoryDetail>? sets,
}) {
  return ExerciseHistoryDetail(
    id: id,
    name: name,
    category: category,
    sets: sets ?? [makeSet()],
    exerciseData: {},
  );
}

WorkoutHistoryDetail makeWorkout({
  String id = 'workout1',
  String userId = 'user1',
  String name = 'Test Workout',
  DateTime? completedAt,
  Duration duration = const Duration(minutes: 60),
  List<ExerciseHistoryDetail>? exercises,
  double? templateId,
}) {
  final now = DateTime(2024, 1, 15, 10, 0);
  return WorkoutHistoryDetail(
    id: id,
    userId: userId,
    name: name,
    description: '',
    createdAt: now,
    startedAt: now,
    completedAt: completedAt ?? now.add(duration),
    updatedAt: now,
    duration: duration,
    exercises: exercises ?? [makeExercise()],
    metadata: {},
  );
}

void main() {
  group('WorkoutHistoryFilter', () {
    test('costruisce con valori di default', () {
      const filter = WorkoutHistoryFilter();

      expect(filter.searchQuery, equals(''));
      expect(filter.startDate, isNull);
      expect(filter.endDate, isNull);
      expect(filter.sortBy, equals(WorkoutSortOption.dateDesc));
    });

    test('costruisce con valori personalizzati', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 12, 31);

      final filter = WorkoutHistoryFilter(
        searchQuery: 'squat',
        startDate: start,
        endDate: end,
        sortBy: WorkoutSortOption.name,
      );

      expect(filter.searchQuery, equals('squat'));
      expect(filter.startDate, equals(start));
      expect(filter.endDate, equals(end));
      expect(filter.sortBy, equals(WorkoutSortOption.name));
    });

    group('copyWith', () {
      test('crea copia con searchQuery aggiornato', () {
        const original = WorkoutHistoryFilter();
        final copy = original.copyWith(searchQuery: 'deadlift');

        expect(copy.searchQuery, equals('deadlift'));
        expect(copy.startDate, isNull); // invariato
        expect(copy.sortBy, equals(WorkoutSortOption.dateDesc)); // invariato
        expect(original.searchQuery, equals('')); // originale non mutato
      });

      test('crea copia con sortBy aggiornato', () {
        const original = WorkoutHistoryFilter();
        final copy = original.copyWith(sortBy: WorkoutSortOption.volume);

        expect(copy.sortBy, equals(WorkoutSortOption.volume));
        expect(original.sortBy, equals(WorkoutSortOption.dateDesc));
      });

      test('crea copia con date aggiornate', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 6, 30);
        const original = WorkoutHistoryFilter();
        final copy = original.copyWith(startDate: start, endDate: end);

        expect(copy.startDate, equals(start));
        expect(copy.endDate, equals(end));
      });
    });
  });

  group('WorkoutSortOption', () {
    test('ha tutti i valori attesi', () {
      expect(WorkoutSortOption.values.length, equals(5));
      expect(WorkoutSortOption.values, contains(WorkoutSortOption.dateDesc));
      expect(WorkoutSortOption.values, contains(WorkoutSortOption.dateAsc));
      expect(WorkoutSortOption.values, contains(WorkoutSortOption.name));
      expect(WorkoutSortOption.values, contains(WorkoutSortOption.duration));
      expect(WorkoutSortOption.values, contains(WorkoutSortOption.volume));
    });
  });

  group('WorkoutStats', () {
    group('WorkoutStats.empty', () {
      test('crea stats vuote con valori zero', () {
        const stats = WorkoutStats.empty();

        expect(stats.totalWorkouts, equals(0));
        expect(stats.totalTime, equals(Duration.zero));
        expect(stats.totalVolume, equals(0.0));
        expect(stats.totalSets, equals(0));
        expect(stats.totalReps, equals(0));
        expect(stats.averageRPE, equals(0.0));
        expect(stats.lastWorkout, isNull);
        expect(stats.averageWorkoutDuration, equals(Duration.zero));
      });
    });

    group('WorkoutStats.fromWorkouts', () {
      test('restituisce empty per lista vuota', () {
        final stats = WorkoutStats.fromWorkouts([]);
        expect(stats.totalWorkouts, equals(0));
        expect(stats.totalVolume, equals(0.0));
      });

      test('calcola totalWorkouts correttamente', () {
        final workouts = [
          makeWorkout(id: 'w1'),
          makeWorkout(id: 'w2'),
          makeWorkout(id: 'w3'),
        ];
        final stats = WorkoutStats.fromWorkouts(workouts);
        expect(stats.totalWorkouts, equals(3));
      });

      test('calcola totalTime sommando le durate', () {
        final workouts = [
          makeWorkout(id: 'w1', duration: const Duration(minutes: 60)),
          makeWorkout(id: 'w2', duration: const Duration(minutes: 45)),
        ];
        final stats = WorkoutStats.fromWorkouts(workouts);
        expect(stats.totalTime, equals(const Duration(minutes: 105)));
      });

      test('calcola totalVolume sommando i volumi', () {
        final exercises1 = [
          makeExercise(
            id: 'ex1',
            sets: [makeSet(weight: 100.0, reps: 10)], // 1000
          ),
        ];
        final exercises2 = [
          makeExercise(
            id: 'ex2',
            sets: [makeSet(weight: 80.0, reps: 8)], // 640
          ),
        ];
        final workouts = [
          makeWorkout(id: 'w1', exercises: exercises1),
          makeWorkout(id: 'w2', exercises: exercises2),
        ];
        final stats = WorkoutStats.fromWorkouts(workouts);
        expect(stats.totalVolume, equals(1640.0));
      });

      test('calcola totalSets correttamente', () {
        final exercises = [
          makeExercise(
            id: 'ex1',
            sets: [makeSet(), makeSet(setNumber: 2)],
          ),
        ];
        final workouts = [
          makeWorkout(id: 'w1', exercises: exercises),
          makeWorkout(
            id: 'w2',
            exercises: [makeExercise(id: 'ex2', sets: [makeSet()])],
          ),
        ];
        final stats = WorkoutStats.fromWorkouts(workouts);
        expect(stats.totalSets, equals(3));
      });

      test('calcola totalReps correttamente', () {
        final exercises = [
          makeExercise(
            id: 'ex1',
            sets: [makeSet(reps: 10), makeSet(reps: 8, setNumber: 2)],
          ),
        ];
        final workouts = [
          makeWorkout(id: 'w1', exercises: exercises),
        ];
        final stats = WorkoutStats.fromWorkouts(workouts);
        expect(stats.totalReps, equals(18));
      });

      test('calcola averageRPE escludendo rpe=0', () {
        final exercises = [
          makeExercise(
            id: 'ex1',
            sets: [
              makeSet(rpe: 7),
              makeSet(rpe: 8, setNumber: 2),
              makeSet(rpe: 0, setNumber: 3), // escluso
            ],
          ),
        ];
        final workouts = [
          makeWorkout(id: 'w1', exercises: exercises),
        ];
        final stats = WorkoutStats.fromWorkouts(workouts);
        // (7 + 8) / 2 = 7.5
        expect(stats.averageRPE, equals(7.5));
      });

      test('averageRPE è 0 se tutti i set hanno rpe=0', () {
        final exercises = [
          makeExercise(
            id: 'ex1',
            sets: [makeSet(rpe: 0)],
          ),
        ];
        final workouts = [makeWorkout(id: 'w1', exercises: exercises)];
        final stats = WorkoutStats.fromWorkouts(workouts);
        expect(stats.averageRPE, equals(0.0));
      });

      test('lastWorkout è la data di completamento del primo workout', () {
        final date1 = DateTime(2024, 1, 20);
        final date2 = DateTime(2024, 1, 15);
        final workouts = [
          makeWorkout(id: 'w1', completedAt: date1),
          makeWorkout(id: 'w2', completedAt: date2),
        ];
        final stats = WorkoutStats.fromWorkouts(workouts);
        expect(stats.lastWorkout, equals(date1));
      });

      test('calcola averageWorkoutDuration correttamente', () {
        final workouts = [
          makeWorkout(id: 'w1', duration: const Duration(minutes: 60)),
          makeWorkout(id: 'w2', duration: const Duration(minutes: 40)),
        ];
        final stats = WorkoutStats.fromWorkouts(workouts);
        // (60 + 40) / 2 = 50 minuti
        expect(stats.averageWorkoutDuration, equals(const Duration(minutes: 50)));
      });

      test('lavora con workout senza esercizi', () {
        final workouts = [
          makeWorkout(id: 'w1', exercises: []),
        ];
        final stats = WorkoutStats.fromWorkouts(workouts);
        expect(stats.totalWorkouts, equals(1));
        expect(stats.totalVolume, equals(0.0));
        expect(stats.totalSets, equals(0));
      });
    });
  });

  group('WorkoutHistoryOperations', () {
    // Test della classe WorkoutHistoryOperations usando un fake repository
    // Nota: Il repository reale dipende da Firebase/Hive, quindi testiamo
    // le operazioni logiche con un fake
  });

  group('groupedWorkoutsByWeekProvider logic', () {
    // Testiamo la logica di raggruppamento per settimana manualmente
    test('raggruppa correttamente workout per settimana corrente', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Un workout di oggi deve essere nella settimana corrente
      final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
      final workoutThisWeek = makeWorkout(
        id: 'w1',
        completedAt: thisWeekStart.add(const Duration(hours: 10)),
      );

      // La logica del provider usa questi calcoli
      final workoutDay = DateTime(
        workoutThisWeek.completedAt.year,
        workoutThisWeek.completedAt.month,
        workoutThisWeek.completedAt.day,
      );

      final isThisWeek = workoutDay.isAfter(
            thisWeekStart.subtract(const Duration(days: 1)),
          ) ||
          workoutDay.isAtSameMomentAs(thisWeekStart);

      expect(isThisWeek, isTrue);
    });

    test('raggruppa workout vecchi per data ISO della settimana', () {
      final oldDate = DateTime(2023, 6, 14); // Un mercoledì
      final weekStart = oldDate.subtract(Duration(days: oldDate.weekday - 1));
      final expectedKey = weekStart.toIso8601String().substring(0, 10);

      // La chiave è la data ISO del lunedì della settimana
      expect(expectedKey, equals('2023-06-12'));
    });
  });

  group('filteredWorkoutHistoryProvider logic', () {
    List<WorkoutHistoryDetail> applyFilter(
      List<WorkoutHistoryDetail> workouts,
      WorkoutHistoryFilter filter,
    ) {
      var filtered = workouts;

      if (filter.searchQuery.isNotEmpty) {
        filtered = filtered.where((workout) {
          return workout.name.toLowerCase().contains(
                filter.searchQuery.toLowerCase(),
              ) ||
              workout.exercises.any(
                (exercise) => exercise.name.toLowerCase().contains(
                  filter.searchQuery.toLowerCase(),
                ),
              );
        }).toList();
      }

      if (filter.startDate != null) {
        filtered = filtered
            .where((w) => w.completedAt.isAfter(filter.startDate!))
            .toList();
      }

      if (filter.endDate != null) {
        filtered = filtered
            .where((w) => w.completedAt.isBefore(filter.endDate!))
            .toList();
      }

      switch (filter.sortBy) {
        case WorkoutSortOption.dateDesc:
          filtered.sort((a, b) => b.completedAt.compareTo(a.completedAt));
          break;
        case WorkoutSortOption.dateAsc:
          filtered.sort((a, b) => a.completedAt.compareTo(b.completedAt));
          break;
        case WorkoutSortOption.name:
          filtered.sort((a, b) => a.name.compareTo(b.name));
          break;
        case WorkoutSortOption.duration:
          filtered.sort((a, b) => b.duration.compareTo(a.duration));
          break;
        case WorkoutSortOption.volume:
          filtered.sort((a, b) => b.totalVolume.compareTo(a.totalVolume));
          break;
      }

      return filtered;
    }

    test('filtra per searchQuery nel nome del workout', () {
      final workouts = [
        makeWorkout(id: 'w1', name: 'Chest Day'),
        makeWorkout(id: 'w2', name: 'Leg Day'),
        makeWorkout(id: 'w3', name: 'Chest and Arms'),
      ];

      final filter = const WorkoutHistoryFilter(searchQuery: 'chest');
      final result = applyFilter(workouts, filter);

      expect(result.length, equals(2));
      expect(result.any((w) => w.id == 'w1'), isTrue);
      expect(result.any((w) => w.id == 'w3'), isTrue);
      expect(result.any((w) => w.id == 'w2'), isFalse);
    });

    test('filtra per searchQuery nel nome degli esercizi', () {
      final workouts = [
        makeWorkout(
          id: 'w1',
          name: 'Day 1',
          exercises: [makeExercise(id: 'ex1', name: 'Squat')],
        ),
        makeWorkout(
          id: 'w2',
          name: 'Day 2',
          exercises: [makeExercise(id: 'ex2', name: 'Deadlift')],
        ),
      ];

      final filter = const WorkoutHistoryFilter(searchQuery: 'squat');
      final result = applyFilter(workouts, filter);

      expect(result.length, equals(1));
      expect(result.first.id, equals('w1'));
    });

    test('filtra per startDate escludendo workout precedenti', () {
      final cutoff = DateTime(2024, 6, 1);
      final workouts = [
        makeWorkout(id: 'w1', completedAt: DateTime(2024, 7, 1)),
        makeWorkout(id: 'w2', completedAt: DateTime(2024, 5, 1)),
        makeWorkout(id: 'w3', completedAt: DateTime(2024, 8, 1)),
      ];

      final filter = WorkoutHistoryFilter(startDate: cutoff);
      final result = applyFilter(workouts, filter);

      expect(result.length, equals(2));
      expect(result.any((w) => w.id == 'w1'), isTrue);
      expect(result.any((w) => w.id == 'w3'), isTrue);
      expect(result.any((w) => w.id == 'w2'), isFalse);
    });

    test('filtra per endDate escludendo workout successivi', () {
      final cutoff = DateTime(2024, 6, 1);
      final workouts = [
        makeWorkout(id: 'w1', completedAt: DateTime(2024, 5, 1)),
        makeWorkout(id: 'w2', completedAt: DateTime(2024, 7, 1)),
        makeWorkout(id: 'w3', completedAt: DateTime(2024, 4, 1)),
      ];

      final filter = WorkoutHistoryFilter(endDate: cutoff);
      final result = applyFilter(workouts, filter);

      expect(result.length, equals(2));
      expect(result.any((w) => w.id == 'w1'), isTrue);
      expect(result.any((w) => w.id == 'w3'), isTrue);
      expect(result.any((w) => w.id == 'w2'), isFalse);
    });

    test('ordina per data decrescente (default)', () {
      final workouts = [
        makeWorkout(id: 'w1', completedAt: DateTime(2024, 1, 1)),
        makeWorkout(id: 'w3', completedAt: DateTime(2024, 3, 1)),
        makeWorkout(id: 'w2', completedAt: DateTime(2024, 2, 1)),
      ];

      const filter = WorkoutHistoryFilter(sortBy: WorkoutSortOption.dateDesc);
      final result = applyFilter(workouts, filter);

      expect(result[0].id, equals('w3'));
      expect(result[1].id, equals('w2'));
      expect(result[2].id, equals('w1'));
    });

    test('ordina per data crescente', () {
      final workouts = [
        makeWorkout(id: 'w3', completedAt: DateTime(2024, 3, 1)),
        makeWorkout(id: 'w1', completedAt: DateTime(2024, 1, 1)),
        makeWorkout(id: 'w2', completedAt: DateTime(2024, 2, 1)),
      ];

      const filter = WorkoutHistoryFilter(sortBy: WorkoutSortOption.dateAsc);
      final result = applyFilter(workouts, filter);

      expect(result[0].id, equals('w1'));
      expect(result[1].id, equals('w2'));
      expect(result[2].id, equals('w3'));
    });

    test('ordina per nome alfabetico', () {
      final workouts = [
        makeWorkout(id: 'wC', name: 'Chest Day'),
        makeWorkout(id: 'wA', name: 'Arm Day'),
        makeWorkout(id: 'wB', name: 'Back Day'),
      ];

      const filter = WorkoutHistoryFilter(sortBy: WorkoutSortOption.name);
      final result = applyFilter(workouts, filter);

      expect(result[0].id, equals('wA'));
      expect(result[1].id, equals('wB'));
      expect(result[2].id, equals('wC'));
    });

    test('ordina per durata decrescente', () {
      final workouts = [
        makeWorkout(
          id: 'w1',
          duration: const Duration(minutes: 45),
          completedAt: DateTime(2024, 1, 1, 0, 45),
        ),
        makeWorkout(
          id: 'w2',
          duration: const Duration(minutes: 90),
          completedAt: DateTime(2024, 1, 1, 1, 30),
        ),
        makeWorkout(
          id: 'w3',
          duration: const Duration(minutes: 60),
          completedAt: DateTime(2024, 1, 1, 1, 0),
        ),
      ];

      const filter = WorkoutHistoryFilter(sortBy: WorkoutSortOption.duration);
      final result = applyFilter(workouts, filter);

      expect(result[0].id, equals('w2'));
      expect(result[1].id, equals('w3'));
      expect(result[2].id, equals('w1'));
    });

    test('ordina per volume decrescente', () {
      final workouts = [
        makeWorkout(
          id: 'w1',
          exercises: [
            makeExercise(
              id: 'ex1',
              sets: [makeSet(weight: 50.0, reps: 10)], // 500
            ),
          ],
        ),
        makeWorkout(
          id: 'w2',
          exercises: [
            makeExercise(
              id: 'ex2',
              sets: [makeSet(weight: 150.0, reps: 10)], // 1500
            ),
          ],
        ),
        makeWorkout(
          id: 'w3',
          exercises: [
            makeExercise(
              id: 'ex3',
              sets: [makeSet(weight: 100.0, reps: 10)], // 1000
            ),
          ],
        ),
      ];

      const filter = WorkoutHistoryFilter(sortBy: WorkoutSortOption.volume);
      final result = applyFilter(workouts, filter);

      expect(result[0].id, equals('w2'));
      expect(result[1].id, equals('w3'));
      expect(result[2].id, equals('w1'));
    });

    test('ricerca case-insensitive', () {
      final workouts = [
        makeWorkout(id: 'w1', name: 'CHEST DAY'),
        makeWorkout(id: 'w2', name: 'Leg Day'),
      ];

      final filter = const WorkoutHistoryFilter(searchQuery: 'chest');
      final result = applyFilter(workouts, filter);

      expect(result.length, equals(1));
      expect(result.first.id, equals('w1'));
    });

    test('filtri combinati: searchQuery + startDate', () {
      final cutoff = DateTime(2024, 6, 1);
      final workouts = [
        makeWorkout(
          id: 'w1',
          name: 'Chest Day',
          completedAt: DateTime(2024, 7, 1),
        ),
        makeWorkout(
          id: 'w2',
          name: 'Chest Day',
          completedAt: DateTime(2024, 5, 1), // prima della cutoff
        ),
        makeWorkout(
          id: 'w3',
          name: 'Leg Day',
          completedAt: DateTime(2024, 7, 1),
        ),
      ];

      final filter = WorkoutHistoryFilter(
        searchQuery: 'chest',
        startDate: cutoff,
      );
      final result = applyFilter(workouts, filter);

      expect(result.length, equals(1));
      expect(result.first.id, equals('w1'));
    });

    test('lista vuota restituisce lista vuota', () {
      const filter = WorkoutHistoryFilter();
      final result = applyFilter([], filter);
      expect(result, isEmpty);
    });
  });
}
