import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';

// Helper factories per i test
SetHistoryDetail makeSet({
  int setNumber = 1,
  double weight = 100.0,
  int reps = 10,
  int rpe = 7,
  int? restSeconds,
  String? notes,
  bool isWarmup = false,
  bool isDropSet = false,
  bool isFailure = false,
  double? setDurationMillis,
  DateTime? setStartedAt,
  DateTime? completedAt,
  int? actualReps,
}) {
  return SetHistoryDetail(
    setNumber: setNumber,
    weight: weight,
    reps: reps,
    rpe: rpe,
    restSeconds: restSeconds,
    notes: notes,
    isWarmup: isWarmup,
    isDropSet: isDropSet,
    isFailure: isFailure,
    setDurationMillis: setDurationMillis,
    setStartedAt: setStartedAt,
    completedAt: completedAt,
    actualReps: actualReps,
  );
}

ExerciseHistoryDetail makeExercise({
  String id = 'ex1',
  String name = 'Bench Press',
  String category = 'chest',
  String? notes,
  List<SetHistoryDetail>? sets,
  Map<String, dynamic>? exerciseData,
}) {
  return ExerciseHistoryDetail(
    id: id,
    name: name,
    category: category,
    notes: notes,
    sets: sets ?? [makeSet()],
    exerciseData: exerciseData ?? {},
  );
}

WorkoutHistoryDetail makeWorkout({
  String id = 'workout1',
  String userId = 'user1',
  String name = 'Test Workout',
  String description = 'A test workout',
  DateTime? createdAt,
  DateTime? startedAt,
  DateTime? completedAt,
  DateTime? updatedAt,
  Duration duration = const Duration(minutes: 60),
  List<ExerciseHistoryDetail>? exercises,
  Map<String, dynamic>? metadata,
  String? templateId,
}) {
  final now = DateTime(2024, 1, 15, 10, 0);
  return WorkoutHistoryDetail(
    id: id,
    userId: userId,
    name: name,
    description: description,
    createdAt: createdAt ?? now,
    startedAt: startedAt ?? now,
    completedAt: completedAt ?? now.add(duration),
    updatedAt: updatedAt ?? now,
    duration: duration,
    exercises: exercises ?? [makeExercise()],
    metadata: metadata ?? {},
    templateId: templateId,
  );
}

void main() {
  group('SetHistoryDetail', () {
    group('costruttore', () {
      test('crea istanza con tutti i campi richiesti', () {
        const set = SetHistoryDetail(
          setNumber: 1,
          weight: 100.0,
          reps: 10,
          rpe: 7,
        );

        expect(set.setNumber, equals(1));
        expect(set.weight, equals(100.0));
        expect(set.reps, equals(10));
        expect(set.rpe, equals(7));
        expect(set.isWarmup, isFalse);
        expect(set.isDropSet, isFalse);
        expect(set.isFailure, isFalse);
        expect(set.restSeconds, isNull);
        expect(set.notes, isNull);
        expect(set.setDurationMillis, isNull);
        expect(set.actualReps, isNull);
      });

      test('crea istanza con tutti i campi opzionali', () {
        final startTime = DateTime(2024, 1, 15, 10, 0);
        final endTime = DateTime(2024, 1, 15, 10, 1);
        final set = SetHistoryDetail(
          setNumber: 2,
          weight: 80.0,
          reps: 12,
          rpe: 6,
          restSeconds: 90,
          notes: 'Felt strong',
          isWarmup: true,
          isDropSet: false,
          isFailure: false,
          setDurationMillis: 30000.0,
          setStartedAt: startTime,
          completedAt: endTime,
          actualReps: 11,
        );

        expect(set.restSeconds, equals(90));
        expect(set.notes, equals('Felt strong'));
        expect(set.isWarmup, isTrue);
        expect(set.setDurationMillis, equals(30000.0));
        expect(set.setStartedAt, equals(startTime));
        expect(set.completedAt, equals(endTime));
        expect(set.actualReps, equals(11));
      });
    });

    group('fromMap', () {
      test('parsa mappa completa correttamente', () {
        final now = DateTime(2024, 1, 15, 10, 0);
        final map = {
          'setNumber': 1,
          'weight': 100.0,
          'reps': 10,
          'rpe': 7,
          'restSeconds': 90,
          'notes': 'Good set',
          'isWarmup': false,
          'isDropSet': false,
          'isFailure': false,
          'setDurationMillis': 25000.0,
          'setStartedAt': now.toIso8601String(),
          'completedAt': now.add(const Duration(seconds: 25)).toIso8601String(),
          'actualReps': 10,
        };

        final set = SetHistoryDetail.fromMap(map);

        expect(set.setNumber, equals(1));
        expect(set.weight, equals(100.0));
        expect(set.reps, equals(10));
        expect(set.rpe, equals(7));
        expect(set.restSeconds, equals(90));
        expect(set.notes, equals('Good set'));
        expect(set.isWarmup, isFalse);
        expect(set.setDurationMillis, equals(25000.0));
        expect(set.actualReps, equals(10));
      });

      test('usa valori di default per campi mancanti', () {
        final set = SetHistoryDetail.fromMap({});

        expect(set.setNumber, equals(0));
        expect(set.weight, equals(0.0));
        expect(set.reps, equals(0));
        expect(set.rpe, equals(0));
        expect(set.restSeconds, isNull);
        expect(set.notes, isNull);
        expect(set.isWarmup, isFalse);
        expect(set.setDurationMillis, isNull);
        expect(set.actualReps, isNull);
      });
    });

    group('toMap', () {
      test('serializza correttamente tutti i campi', () {
        final set = makeSet(
          setNumber: 3,
          weight: 90.0,
          reps: 8,
          rpe: 8,
          restSeconds: 120,
          notes: 'Heavy',
          isWarmup: false,
          isDropSet: true,
          isFailure: false,
        );

        final map = set.toMap();

        expect(map['setNumber'], equals(3));
        expect(map['weight'], equals(90.0));
        expect(map['reps'], equals(8));
        expect(map['rpe'], equals(8));
        expect(map['restSeconds'], equals(120));
        expect(map['notes'], equals('Heavy'));
        expect(map['isDropSet'], isTrue);
      });

      test('round-trip fromMap -> toMap preserva i dati', () {
        final now = DateTime(2024, 1, 15, 10, 0);
        final originalMap = {
          'setNumber': 2,
          'weight': 75.5,
          'reps': 12,
          'rpe': 6,
          'restSeconds': 60,
          'notes': null,
          'isWarmup': false,
          'isDropSet': false,
          'isFailure': false,
          'setDurationMillis': null,
          'setStartedAt': now.toIso8601String(),
          'completedAt': null,
          'actualReps': null,
        };

        final set = SetHistoryDetail.fromMap(originalMap);
        final resultMap = set.toMap();

        expect(resultMap['setNumber'], equals(2));
        expect(resultMap['weight'], equals(75.5));
        expect(resultMap['reps'], equals(12));
        expect(resultMap['rpe'], equals(6));
      });
    });

    group('proprietà calcolate', () {
      test('volume con peso è weight * reps', () {
        const set = SetHistoryDetail(
          setNumber: 1,
          weight: 100.0,
          reps: 10,
          rpe: 7,
        );
        expect(set.volume, equals(1000.0));
      });

      test('volume senza peso (bodyweight) è reps come double', () {
        const set = SetHistoryDetail(
          setNumber: 1,
          weight: 0.0,
          reps: 15,
          rpe: 7,
        );
        expect(set.volume, equals(15.0));
      });

      test('estimated1RM con 1 rep è il peso', () {
        const set = SetHistoryDetail(
          setNumber: 1,
          weight: 200.0,
          reps: 1,
          rpe: 10,
        );
        expect(set.estimated1RM, equals(200.0));
      });

      test('estimated1RM con più reps usa formula Epley', () {
        const set = SetHistoryDetail(
          setNumber: 1,
          weight: 100.0,
          reps: 10,
          rpe: 8,
        );
        // Epley: weight * (1 + reps/30) = 100 * (1 + 10/30) ≈ 133.33
        expect(set.estimated1RM, closeTo(133.33, 0.01));
      });
    });

    group('copyWith', () {
      test('crea nuova istanza con campi aggiornati', () {
        const original = SetHistoryDetail(
          setNumber: 1,
          weight: 100.0,
          reps: 10,
          rpe: 7,
        );

        final copy = original.copyWith(weight: 110.0, reps: 8);

        expect(copy.weight, equals(110.0));
        expect(copy.reps, equals(8));
        expect(copy.setNumber, equals(1)); // invariato
        expect(copy.rpe, equals(7)); // invariato
        expect(original.weight, equals(100.0)); // originale non mutato
      });

      test('conserva campi opzionali se non specificati', () {
        final set = makeSet(notes: 'Test note', restSeconds: 90);
        final copy = set.copyWith(weight: 120.0);

        expect(copy.notes, equals('Test note'));
        expect(copy.restSeconds, equals(90));
      });
    });

    group('toExerciseSet', () {
      test('converte correttamente in ExerciseSet', () {
        const set = SetHistoryDetail(
          setNumber: 1,
          weight: 100.0,
          reps: 10,
          rpe: 7,
          isWarmup: true,
          actualReps: 9,
        );

        final exerciseSet = set.toExerciseSet();

        expect(exerciseSet.setNumber, equals(1));
        expect(exerciseSet.weight, equals(100.0));
        expect(exerciseSet.reps, equals(10));
        expect(exerciseSet.rpe, equals(7));
        expect(exerciseSet.isWarmup, isTrue);
        expect(exerciseSet.isCompleted, isTrue);
        expect(exerciseSet.actualReps, equals(9));
      });

      test('usa reps come actualReps quando actualReps è null', () {
        const set = SetHistoryDetail(
          setNumber: 1,
          weight: 80.0,
          reps: 12,
          rpe: 6,
        );

        final exerciseSet = set.toExerciseSet();
        expect(exerciseSet.actualReps, equals(12));
      });
    });
  });

  group('ExerciseHistoryDetail', () {
    group('fromMap', () {
      test('parsa mappa senza exerciseData', () {
        final map = {
          'id': 'ex1',
          'name': 'Squat',
          'category': 'legs',
          'notes': null,
          'sets': [
            {'setNumber': 1, 'weight': 100.0, 'reps': 5, 'rpe': 8},
          ],
          'exerciseData': <String, dynamic>{},
        };

        final exercise = ExerciseHistoryDetail.fromMap(map);

        expect(exercise.id, equals('ex1'));
        expect(exercise.name, equals('Squat'));
        expect(exercise.category, equals('legs'));
        expect(exercise.sets.length, equals(1));
      });

      test('parsa mappa con exerciseData e normalizza muscoli legacy', () {
        final map = {
          'id': 'ex2',
          'name': 'Deadlift',
          'category': 'back',
          'sets': [],
          'exerciseData': {
            'focus': ['FEMOR', 'GLUT'], // vecchi nomi
            'muscoliSecondari': ['LOMBAR'],
          },
        };

        final exercise = ExerciseHistoryDetail.fromMap(map);

        // I muscoli legacy vengono normalizzati
        final focus = exercise.exerciseData['focus'] as List;
        expect(focus, contains('FEMO')); // FEMOR -> FEMO
        expect(focus, contains('GLUT')); // GLUT rimane invariato

        final secondary = exercise.exerciseData['muscoliSecondari'] as List;
        expect(secondary, contains('LOMB')); // LOMBAR -> LOMB
      });

      test('parsa exerciseData con muscoli in formato stringa CSV', () {
        final map = {
          'id': 'ex3',
          'name': 'Curl',
          'category': 'arms',
          'sets': [],
          'exerciseData': {
            'focus': 'BIC, TRIC', // stringa CSV invece di lista
          },
        };

        final exercise = ExerciseHistoryDetail.fromMap(map);
        final focus = exercise.exerciseData['focus'] as List;
        expect(focus, contains('BICI')); // BIC -> BICI
        expect(focus, contains('TRIC'));
      });

      test('usa valori di default per campi mancanti', () {
        final exercise = ExerciseHistoryDetail.fromMap({'id': 'test'});

        expect(exercise.id, equals('test'));
        expect(exercise.name, equals(''));
        expect(exercise.category, equals(''));
        expect(exercise.sets, isEmpty);
        expect(exercise.notes, isNull);
      });
    });

    group('toMap', () {
      test('serializza correttamente', () {
        final exercise = makeExercise(
          id: 'ex1',
          name: 'Push Up',
          category: 'chest',
          notes: 'Bodyweight',
        );

        final map = exercise.toMap();

        expect(map['id'], equals('ex1'));
        expect(map['name'], equals('Push Up'));
        expect(map['category'], equals('chest'));
        expect(map['notes'], equals('Bodyweight'));
        expect(map['sets'], isA<List>());
      });
    });

    group('proprietà calcolate', () {
      test('totalVolume somma volume di tutti i set', () {
        final sets = [
          makeSet(weight: 100.0, reps: 10), // 1000
          makeSet(weight: 80.0, reps: 8), // 640
        ];
        final exercise = makeExercise(sets: sets);

        expect(exercise.totalVolume, equals(1640.0));
      });

      test('totalVolume è 0 senza set', () {
        final exercise = makeExercise(sets: []);
        expect(exercise.totalVolume, equals(0.0));
      });

      test('totalReps somma reps di tutti i set', () {
        final sets = [makeSet(reps: 10), makeSet(reps: 8), makeSet(reps: 6)];
        final exercise = makeExercise(sets: sets);
        expect(exercise.totalReps, equals(24));
      });

      test('maxWeight restituisce il peso massimo', () {
        final sets = [
          makeSet(weight: 80.0),
          makeSet(weight: 100.0),
          makeSet(weight: 90.0),
        ];
        final exercise = makeExercise(sets: sets);
        expect(exercise.maxWeight, equals(100.0));
      });

      test('maxWeight è 0 senza set', () {
        final exercise = makeExercise(sets: []);
        expect(exercise.maxWeight, equals(0.0));
      });

      test('averageRPE calcola media corretta', () {
        final sets = [makeSet(rpe: 6), makeSet(rpe: 8), makeSet(rpe: 7)];
        final exercise = makeExercise(sets: sets);
        expect(exercise.averageRPE, closeTo(7.0, 0.01));
      });

      test('averageRPE esclude set senza RPE (rpe=0)', () {
        final sets = [
          makeSet(rpe: 0), // Escluso
          makeSet(rpe: 8),
          makeSet(rpe: 6),
        ];
        final exercise = makeExercise(sets: sets);
        expect(exercise.averageRPE, equals(7.0));
      });

      test('averageRPE è 0 se nessun set ha RPE', () {
        final sets = [makeSet(rpe: 0), makeSet(rpe: 0)];
        final exercise = makeExercise(sets: sets);
        expect(exercise.averageRPE, equals(0.0));
      });
    });

    group('copyWith', () {
      test('crea copia con campi aggiornati', () {
        final original = makeExercise(name: 'Squat', category: 'legs');
        final copy = original.copyWith(name: 'Box Squat');

        expect(copy.name, equals('Box Squat'));
        expect(copy.category, equals('legs')); // invariato
        expect(original.name, equals('Squat')); // originale invariato
      });
    });

    group('toExercise', () {
      test('converte in Exercise con categoria corretta', () {
        final exercise = makeExercise(category: 'chest');
        final result = exercise.toExercise();

        expect(result.id, equals('ex1'));
        expect(result.name, equals('Bench Press'));
        // Category 'chest' deve matchare ExerciseCategory
        expect(result.category.name.toLowerCase(), equals('chest'));
      });

      test('usa ExerciseCategory.other per categoria sconosciuta', () {
        final exercise = makeExercise(category: 'unknown_category_xyz');
        final result = exercise.toExercise();
        expect(result.category.name.toLowerCase(), equals('other'));
      });
    });
  });

  group('WorkoutHistoryDetail', () {
    group('costruttore e factory', () {
      test('crea istanza con tutti i campi richiesti', () {
        final workout = makeWorkout();

        expect(workout.id, equals('workout1'));
        expect(workout.userId, equals('user1'));
        expect(workout.name, equals('Test Workout'));
        expect(workout.exercises.length, equals(1));
        expect(workout.duration, equals(const Duration(minutes: 60)));
        expect(workout.templateId, isNull);
      });

      test('factory empty crea workout vuoto con id specificato', () {
        final workout = WorkoutHistoryDetail.empty(id: 'empty_workout');

        expect(workout.id, equals('empty_workout'));
        expect(workout.userId, equals(''));
        expect(workout.name, equals(''));
        expect(workout.exercises, isEmpty);
        expect(workout.duration, equals(Duration.zero));
        expect(workout.metadata, isEmpty);
      });
    });

    group('fromMap e toMap', () {
      test('round-trip serializzazione preserva i dati', () {
        final original = makeWorkout(
          id: 'test_id',
          userId: 'test_user',
          name: 'My Workout',
          description: 'Description',
          templateId: 'template_123',
        );

        final map = original.toMap();
        final restored = WorkoutHistoryDetail.fromMap(map);

        expect(restored.id, equals('test_id'));
        expect(restored.userId, equals('test_user'));
        expect(restored.name, equals('My Workout'));
        expect(restored.description, equals('Description'));
        expect(restored.templateId, equals('template_123'));
        expect(restored.exercises.length, equals(1));
      });

      test('toMap include tutti i campi obbligatori', () {
        final workout = makeWorkout();
        final map = workout.toMap();

        expect(map.containsKey('id'), isTrue);
        expect(map.containsKey('userId'), isTrue);
        expect(map.containsKey('name'), isTrue);
        expect(map.containsKey('description'), isTrue);
        expect(map.containsKey('createdAt'), isTrue);
        expect(map.containsKey('startedAt'), isTrue);
        expect(map.containsKey('completedAt'), isTrue);
        expect(map.containsKey('updatedAt'), isTrue);
        expect(map.containsKey('durationMinutes'), isTrue);
        expect(map.containsKey('exercises'), isTrue);
        expect(map.containsKey('metadata'), isTrue);
        expect(map.containsKey('templateId'), isTrue);
      });

      test('fromMap usa valori di default per campi mancanti', () {
        final workout = WorkoutHistoryDetail.fromMap({'id': 'test'});

        expect(workout.id, equals('test'));
        expect(workout.name, equals('Unknown Workout'));
        expect(workout.userId, equals(''));
        expect(workout.exercises, isEmpty);
      });

      test(
        'durationMinutes viene serializzato/deserializzato correttamente',
        () {
          final workout = makeWorkout(duration: const Duration(minutes: 75));
          final map = workout.toMap();

          expect(map['durationMinutes'], equals(75));

          final restored = WorkoutHistoryDetail.fromMap(map);
          expect(restored.duration.inMinutes, equals(75));
        },
      );

      test('fromMap supporta alias legacy startTime/endTime e _userId', () {
        final restored = WorkoutHistoryDetail.fromMap({
          'id': 'legacy_workout',
          '_userId': 'legacy_user',
          'name': 'Legacy Workout',
          'createdAt': '2024-01-10T09:00:00.000',
          'startTime': '2024-01-10T09:05:00.000',
          'endTime': '2024-01-10T10:20:00.000',
        });

        expect(restored.userId, equals('legacy_user'));
        expect(
          restored.startedAt,
          equals(DateTime.parse('2024-01-10T09:05:00.000')),
        );
        expect(
          restored.completedAt,
          equals(DateTime.parse('2024-01-10T10:20:00.000')),
        );
        expect(restored.duration.inMinutes, equals(75));
      });

      test('SetHistoryDetail.fromMap supporta valori DateTime legacy', () {
        final startedAt = DateTime(2024, 1, 10, 9, 0);
        final completedAt = DateTime(2024, 1, 10, 9, 0, 30);

        final restored = SetHistoryDetail.fromMap({
          'setNumber': 1,
          'weight': 50.0,
          'reps': 8,
          'rpe': 7,
          'setStartedAt': startedAt,
          'completedAt': completedAt,
          'actualReps': 7.0,
        });

        expect(restored.setStartedAt, equals(startedAt));
        expect(restored.completedAt, equals(completedAt));
        expect(restored.actualReps, equals(7));
      });
    });

    group('proprietà calcolate', () {
      test('totalVolume somma volume di tutti gli esercizi', () {
        final exercises = [
          makeExercise(
            id: 'ex1',
            sets: [makeSet(weight: 100.0, reps: 10)], // 1000
          ),
          makeExercise(
            id: 'ex2',
            sets: [makeSet(weight: 80.0, reps: 8)], // 640
          ),
        ];
        final workout = makeWorkout(exercises: exercises);

        expect(workout.totalVolume, equals(1640.0));
      });

      test('totalVolume è 0 senza esercizi', () {
        final workout = makeWorkout(exercises: []);
        expect(workout.totalVolume, equals(0.0));
      });

      test('totalSets conta tutti i set di tutti gli esercizi', () {
        final exercises = [
          makeExercise(
            id: 'ex1',
            sets: [makeSet(), makeSet(setNumber: 2), makeSet(setNumber: 3)],
          ),
          makeExercise(id: 'ex2', sets: [makeSet(), makeSet(setNumber: 2)]),
        ];
        final workout = makeWorkout(exercises: exercises);
        expect(workout.totalSets, equals(5));
      });

      test('totalReps somma le reps di tutti gli esercizi', () {
        final exercises = [
          makeExercise(id: 'ex1', sets: [makeSet(reps: 10), makeSet(reps: 8)]),
          makeExercise(id: 'ex2', sets: [makeSet(reps: 12)]),
        ];
        final workout = makeWorkout(exercises: exercises);
        expect(workout.totalReps, equals(30));
      });

      test('averageRPE calcola media di tutti i set con RPE > 0', () {
        final exercises = [
          makeExercise(id: 'ex1', sets: [makeSet(rpe: 7), makeSet(rpe: 8)]),
          makeExercise(
            id: 'ex2',
            sets: [makeSet(rpe: 0), makeSet(rpe: 9)], // rpe 0 escluso
          ),
        ];
        final workout = makeWorkout(exercises: exercises);
        // (7 + 8 + 9) / 3 = 8.0
        expect(workout.averageRPE, equals(8.0));
      });

      test('averageRPE è 0 se nessun set ha RPE', () {
        final exercises = [
          makeExercise(id: 'ex1', sets: [makeSet(rpe: 0)]),
        ];
        final workout = makeWorkout(exercises: exercises);
        expect(workout.averageRPE, equals(0.0));
      });

      test('averageRPE è 0 senza esercizi', () {
        final workout = makeWorkout(exercises: []);
        expect(workout.averageRPE, equals(0.0));
      });
    });

    group('equality e hashCode', () {
      test('due workout con stesso id sono uguali', () {
        final workout1 = makeWorkout(id: 'same_id', name: 'Workout A');
        final workout2 = makeWorkout(id: 'same_id', name: 'Workout B');

        expect(workout1, equals(workout2));
        expect(workout1.hashCode, equals(workout2.hashCode));
      });

      test('due workout con id diversi non sono uguali', () {
        final workout1 = makeWorkout(id: 'id_1');
        final workout2 = makeWorkout(id: 'id_2');

        expect(workout1, isNot(equals(workout2)));
      });
    });

    group('copyWith', () {
      test('crea copia con campi aggiornati', () {
        final original = makeWorkout(name: 'Original', templateId: 'tmpl1');
        final copy = original.copyWith(name: 'Updated');

        expect(copy.name, equals('Updated'));
        expect(copy.id, equals('workout1')); // invariato
        expect(copy.templateId, equals('tmpl1')); // invariato
        expect(original.name, equals('Original')); // originale non mutato
      });

      test('aggiorna updatedAt automaticamente', () {
        final now = DateTime(2024, 1, 15);
        final original = makeWorkout(updatedAt: now);
        final copy = original.copyWith(name: 'New Name');

        // updatedAt aggiornato a DateTime.now() in copyWith
        expect(copy.updatedAt, isNot(equals(now)));
      });
    });

    group('toWorkout', () {
      test('converte in Workout con status completed', () {
        final workout = makeWorkout(id: 'w1', name: 'Test');
        final result = workout.toWorkout();

        expect(result.id, equals('w1'));
        expect(result.name, equals('Test'));
        expect(result.status, equals(WorkoutStatus.completed));
      });

      test('include gli esercizi convertiti', () {
        final exercises = [
          makeExercise(id: 'ex1', name: 'Squat'),
          makeExercise(id: 'ex2', name: 'Deadlift'),
        ];
        final workout = makeWorkout(exercises: exercises);
        final result = workout.toWorkout();

        expect(result.exercises.length, equals(2));
      });
    });
  });
}
