import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/usecases/detect_personal_records_usecase.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';

// ---------------------------------------------------------------------------
// Test fixture helpers
// ---------------------------------------------------------------------------

ExerciseSet buildSet({
  int setNumber = 1,
  double? weight,
  int? reps,
  int? actualReps,
  bool isCompleted = true,
  bool isWarmup = false,
  int? rpe,
}) {
  return ExerciseSet(
    setNumber: setNumber,
    weight: weight,
    reps: reps,
    actualReps: actualReps,
    isCompleted: isCompleted,
    isWarmup: isWarmup,
    rpe: rpe,
  );
}

Exercise buildExercise({
  String id = 'bench-press',
  String name = 'Bench Press',
  List<ExerciseSet>? sets,
}) {
  return Exercise(
    id: id,
    name: name,
    type: ExerciseType.single,
    category: ExerciseCategory.chest,
    sets: sets ?? [],
  );
}

Workout buildWorkout({List<Exercise>? exercises}) {
  final now = DateTime.now();
  return Workout(
    id: 'workout-1',
    name: 'Test Workout',
    exercises: exercises ?? [],
    createdAt: now,
    updatedAt: now,
  );
}

/// Seeds an existing PR into fakeFirestore for the given user+exercise.
Future<void> seedExistingPR(
  FakeFirebaseFirestore fakeFirestore, {
  required String userId,
  required String exerciseId,
  required String exerciseName,
  required PRType type,
  required double value,
  Map<String, dynamic>? metadata,
}) async {
  await fakeFirestore.collection('personalRecords').add({
    'userId': userId,
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'type': type.name,
    'value': value,
    'previousValue': null,
    'achievedAt': Timestamp.fromDate(DateTime.now()),
    'metadata': metadata ?? {},
  });
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const userId = 'user-1';
  const exerciseId = 'bench-press';
  const exerciseName = 'Bench Press';

  late FakeFirebaseFirestore fakeFirestore;
  late PRTracker prTracker;
  late DetectPersonalRecordsUseCase useCase;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    prTracker = PRTracker(firestore: fakeFirestore);
    useCase = DetectPersonalRecordsUseCase(prTracker);
  });

  // -------------------------------------------------------------------------
  // execute() — detect PRs across entire workout
  // -------------------------------------------------------------------------

  group('DetectPersonalRecordsUseCase.execute()', () {
    test('returns empty list for workout with no exercises', () async {
      final result = await useCase.execute(userId, buildWorkout());
      expect(result, isEmpty);
    });

    test('returns empty list when all sets are incomplete', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(weight: 100, reps: 5, isCompleted: false),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));
      expect(result, isEmpty);
    });

    test('detects weight PR when no previous record exists', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 5, actualReps: 5, isCompleted: true),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      final weightPRs = result.where((pr) => pr.type == PRType.weight).toList();
      expect(weightPRs, isNotEmpty);
      expect(weightPRs.first.newValue, equals(100.0));
      expect(weightPRs.first.previousValue, isNull);
    });

    test('does not detect PR when weight equals existing record', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.weight, value: 100.0,
      );
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 5, actualReps: 5, isCompleted: true),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      final weightPRs = result.where((pr) => pr.type == PRType.weight).toList();
      expect(weightPRs, isEmpty);
    });

    test('detects weight PR when new weight exceeds existing record', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.weight, value: 100.0,
      );
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 105, reps: 5, actualReps: 5, isCompleted: true),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      final weightPRs = result.where((pr) => pr.type == PRType.weight).toList();
      expect(weightPRs, isNotEmpty);
      expect(weightPRs.first.newValue, equals(105.0));
      expect(weightPRs.first.previousValue, equals(100.0));
    });

    test('skips warmup sets for PR detection', () async {
      // Warmup set has much higher weight — should not trigger a PR at 200kg
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 200, reps: 5, actualReps: 5,
              isCompleted: true, isWarmup: true),
          buildSet(setNumber: 2, weight: 100, reps: 5, actualReps: 5,
              isCompleted: true, isWarmup: false),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      // Only working set (100kg) should trigger weight PR
      final weightPRs = result.where((pr) => pr.type == PRType.weight).toList();
      expect(weightPRs.every((pr) => pr.newValue <= 100.0), isTrue);
    });

    test('detects PRs across multiple exercises in a workout', () async {
      final squat = buildExercise(
        id: 'squat', name: 'Squat',
        sets: [
          buildSet(setNumber: 1, weight: 150, reps: 5, actualReps: 5, isCompleted: true),
        ],
      );
      final deadlift = buildExercise(
        id: 'deadlift', name: 'Deadlift',
        sets: [
          buildSet(setNumber: 1, weight: 180, reps: 3, actualReps: 3, isCompleted: true),
        ],
      );
      final result = await useCase.execute(
        userId,
        buildWorkout(exercises: [squat, deadlift]),
      );

      final exerciseIds = result.map((pr) => pr.exerciseId).toSet();
      expect(exerciseIds, containsAll(['squat', 'deadlift']));
    });

    test('detects volume PR for exercise with completed working sets', () async {
      // volume = weight * reps: 100 * 8 + 100 * 8 = 1600
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 8, actualReps: 8, isCompleted: true),
          buildSet(setNumber: 2, weight: 100, reps: 8, actualReps: 8, isCompleted: true),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      final volumePRs = result.where((pr) => pr.type == PRType.volume).toList();
      expect(volumePRs, isNotEmpty);
      expect(volumePRs.first.newValue, equals(1600.0));
    });

    test('detects totalSets PR when set count exceeds existing record', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.totalSets, value: 2.0,
      );
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 80, reps: 10, actualReps: 10, isCompleted: true),
          buildSet(setNumber: 2, weight: 80, reps: 10, actualReps: 10, isCompleted: true),
          buildSet(setNumber: 3, weight: 80, reps: 10, actualReps: 10, isCompleted: true),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      final setsPRs = result.where((pr) => pr.type == PRType.totalSets).toList();
      expect(setsPRs, isNotEmpty);
      expect(setsPRs.first.newValue, equals(3.0));
    });
  });

  // -------------------------------------------------------------------------
  // executeForSet() — detect PRs for a single set completion
  // -------------------------------------------------------------------------

  group('DetectPersonalRecordsUseCase.executeForSet()', () {
    test('returns empty list for warmup set', () async {
      final exercise = buildExercise();
      final warmupSet = buildSet(
        setNumber: 1, weight: 200, reps: 5, actualReps: 5,
        isCompleted: true, isWarmup: true,
      );
      final result = await useCase.executeForSet(userId, exercise, warmupSet);
      expect(result, isEmpty);
    });

    test('returns empty list when weight is zero', () async {
      final exercise = buildExercise();
      final zeroWeightSet = buildSet(
        setNumber: 1, weight: 0, reps: 10, actualReps: 10, isCompleted: true,
      );
      final result = await useCase.executeForSet(userId, exercise, zeroWeightSet);
      expect(result, isEmpty);
    });

    test('returns empty list when weight is null', () async {
      final exercise = buildExercise();
      final noWeightSet = buildSet(
        setNumber: 1, reps: 10, actualReps: 10, isCompleted: true,
      );
      final result = await useCase.executeForSet(userId, exercise, noWeightSet);
      expect(result, isEmpty);
    });

    test('detects weight PR when no prior records exist', () async {
      final exercise = buildExercise();
      final set = buildSet(setNumber: 1, weight: 100, reps: 5, actualReps: 5);
      final result = await useCase.executeForSet(userId, exercise, set);

      final weightPR = result.where((pr) => pr.type == PRType.weight).toList();
      expect(weightPR, isNotEmpty);
      expect(weightPR.first.newValue, equals(100.0));
      expect(weightPR.first.exerciseId, equals(exercise.id));
      expect(weightPR.first.exerciseName, equals(exercise.name));
    });

    test('does not detect weight PR when weight is below existing record', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.weight, value: 100.0,
      );
      final exercise = buildExercise();
      final set = buildSet(setNumber: 1, weight: 90, reps: 5, actualReps: 5);
      final result = await useCase.executeForSet(userId, exercise, set);

      final weightPR = result.where((pr) => pr.type == PRType.weight).toList();
      expect(weightPR, isEmpty);
    });

    test('detects reps PR when more reps done at same weight', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.reps, value: 10.0,
        metadata: {'weight': 100.0},
      );
      final exercise = buildExercise();
      final set = buildSet(setNumber: 1, weight: 100, reps: 12, actualReps: 12);
      final result = await useCase.executeForSet(userId, exercise, set);

      final repsPR = result.where((pr) => pr.type == PRType.reps).toList();
      expect(repsPR, isNotEmpty);
      expect(repsPR.first.newValue, equals(12.0));
    });

    test('does not detect reps PR when fewer reps at same weight', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.reps, value: 10.0,
        metadata: {'weight': 100.0},
      );
      final exercise = buildExercise();
      final set = buildSet(setNumber: 1, weight: 100, reps: 8, actualReps: 8);
      final result = await useCase.executeForSet(userId, exercise, set);

      final repsPR = result.where((pr) => pr.type == PRType.reps).toList();
      expect(repsPR, isEmpty);
    });

    test('does not detect reps PR when weight is lower than existing record weight', () async {
      // Existing: 10 reps at 100kg. New: 15 reps at 80kg → weight < currentWeight → no PR
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.reps, value: 10.0,
        metadata: {'weight': 100.0},
      );
      final exercise = buildExercise();
      final set = buildSet(setNumber: 1, weight: 80, reps: 15, actualReps: 15);
      final result = await useCase.executeForSet(userId, exercise, set);

      final repsPR = result.where((pr) => pr.type == PRType.reps).toList();
      expect(repsPR, isEmpty);
    });

    test('detects reps PR when higher weight with same reps count', () async {
      // Existing: 10 reps at 100kg. New: 10 reps at 110kg → higher weight → PR
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.reps, value: 10.0,
        metadata: {'weight': 100.0},
      );
      final exercise = buildExercise();
      final set = buildSet(setNumber: 1, weight: 110, reps: 10, actualReps: 10);
      final result = await useCase.executeForSet(userId, exercise, set);

      final repsPR = result.where((pr) => pr.type == PRType.reps).toList();
      expect(repsPR, isNotEmpty);
    });

    test('detects 1RM PR when estimated 1RM exceeds existing record', () async {
      // 100kg x 5 reps → estimated 1RM ~112kg, existing is 100kg
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.oneRM, value: 100.0,
      );
      final exercise = buildExercise();
      final set = buildSet(setNumber: 1, weight: 100, reps: 5, actualReps: 5);
      final result = await useCase.executeForSet(userId, exercise, set);

      final oneRMPR = result.where((pr) => pr.type == PRType.oneRM).toList();
      expect(oneRMPR, isNotEmpty);
      expect(oneRMPR.first.newValue, greaterThan(100.0));
    });

    test('does not detect 1RM PR when estimated 1RM is below existing record', () async {
      // 60kg x 5 reps → estimated 1RM ~67kg, existing is 200kg
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.oneRM, value: 200.0,
      );
      final exercise = buildExercise();
      final set = buildSet(setNumber: 1, weight: 60, reps: 5, actualReps: 5);
      final result = await useCase.executeForSet(userId, exercise, set);

      final oneRMPR = result.where((pr) => pr.type == PRType.oneRM).toList();
      expect(oneRMPR, isEmpty);
    });

    test('uses actualReps over reps for 1RM calculation when available', () async {
      // actualReps = 8 should be used rather than target reps = 5
      final exercise = buildExercise();
      final set = buildSet(
        setNumber: 1, weight: 100, reps: 5, actualReps: 8, isCompleted: true,
      );
      final result = await useCase.executeForSet(userId, exercise, set);

      final oneRMPRs = result.where((pr) => pr.type == PRType.oneRM).toList();
      expect(oneRMPRs, isNotEmpty);
      // Context should reflect actual reps = 8
      expect(oneRMPRs.first.context['reps'], equals(8));
    });

    test('returns empty when reps and actualReps are both zero/null', () async {
      final exercise = buildExercise();
      final set = buildSet(setNumber: 1, weight: 100);
      final result = await useCase.executeForSet(userId, exercise, set);

      final oneRMPR = result.where((pr) => pr.type == PRType.oneRM).toList();
      expect(oneRMPR, isEmpty);
    });

    test('PersonalRecordAchieved contains correct exerciseId and exerciseName', () async {
      final exercise = buildExercise(id: 'ex-123', name: 'Overhead Press');
      final set = buildSet(setNumber: 1, weight: 80, reps: 6, actualReps: 6);
      final result = await useCase.executeForSet(userId, exercise, set);

      for (final pr in result) {
        expect(pr.exerciseId, equals('ex-123'));
        expect(pr.exerciseName, equals('Overhead Press'));
      }
    });

    test('weight PR context map contains expected keys', () async {
      final exercise = buildExercise();
      final set = buildSet(
        setNumber: 2, weight: 100, reps: 5, actualReps: 6, rpe: 8,
      );
      final result = await useCase.executeForSet(userId, exercise, set);

      final weightPR = result.firstWhere((pr) => pr.type == PRType.weight);
      expect(weightPR.context.containsKey('reps'), isTrue);
      expect(weightPR.context.containsKey('actualReps'), isTrue);
      expect(weightPR.context.containsKey('rpe'), isTrue);
      expect(weightPR.context.containsKey('setNumber'), isTrue);
      expect(weightPR.context['setNumber'], equals(2));
    });

    test('weight PR achievedAt is set to a recent datetime', () async {
      final exercise = buildExercise();
      final set = buildSet(setNumber: 1, weight: 100, reps: 5, actualReps: 5);
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final result = await useCase.executeForSet(userId, exercise, set);

      final weightPR = result.firstWhere((pr) => pr.type == PRType.weight);
      expect(weightPR.achievedAt.isAfter(before), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // getPRPredictions() — predictions for incomplete sets
  // -------------------------------------------------------------------------

  group('DetectPersonalRecordsUseCase.getPRPredictions()', () {
    test('returns empty list when no sets exist', () async {
      final exercise = buildExercise(sets: []);
      final result = await useCase.getPRPredictions(userId, exercise);
      expect(result, isEmpty);
    });

    test('returns empty list when all sets are completed', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 5, actualReps: 5, isCompleted: true),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);
      expect(result, isEmpty);
    });

    test('predicts weight PR for incomplete set with no prior record', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 5, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final weightPredictions = result.where((p) => p.type == PRType.weight).toList();
      expect(weightPredictions, isNotEmpty);
      expect(weightPredictions.first.predictedValue, equals(100.0));
      expect(weightPredictions.first.currentRecord, isNull);
    });

    test('does not predict weight PR when planned weight equals existing record', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.weight, value: 100.0,
      );
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 5, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final weightPredictions = result.where((p) => p.type == PRType.weight).toList();
      expect(weightPredictions, isEmpty);
    });

    test('predicts weight PR when planned weight exceeds existing record', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.weight, value: 100.0,
      );
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 110, reps: 5, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final weightPredictions = result.where((p) => p.type == PRType.weight).toList();
      expect(weightPredictions, isNotEmpty);
      expect(weightPredictions.first.currentRecord, equals(100.0));
    });

    test('predicts 1RM PR for incomplete set', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 5, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final oneRMPredictions = result.where((p) => p.type == PRType.oneRM).toList();
      expect(oneRMPredictions, isNotEmpty);
      expect(oneRMPredictions.first.predictedValue, greaterThan(100.0));
    });

    test('does not predict 1RM PR when estimated value is below existing record', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.oneRM, value: 500.0,
      );
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 60, reps: 5, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final oneRMPredictions = result.where((p) => p.type == PRType.oneRM).toList();
      expect(oneRMPredictions, isEmpty);
    });

    test('skips incomplete set with zero weight', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 0, reps: 10, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);
      expect(result, isEmpty);
    });

    test('skips incomplete set with null weight', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, reps: 10, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);
      expect(result, isEmpty);
    });

    test('skips incomplete set with zero reps', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);
      expect(result, isEmpty);
    });

    test('PRPrediction setIndex corresponds to position in exercise.sets', () async {
      final exercise = buildExercise(
        sets: [
          // index 0: completed
          buildSet(setNumber: 1, weight: 80, reps: 8, isCompleted: true),
          // index 1: incomplete → should generate predictions
          buildSet(setNumber: 2, weight: 100, reps: 5, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      // The only incomplete set is at index 1
      for (final prediction in result) {
        expect(prediction.setIndex, equals(1));
      }
    });
  });

  // -------------------------------------------------------------------------
  // PRPrediction — entity properties
  // -------------------------------------------------------------------------

  group('PRPrediction properties', () {
    test('improvementPercentage is 100 when currentRecord is null', () {
      const prediction = PRPrediction(
        type: PRType.weight,
        predictedValue: 110.0,
        currentRecord: null,
        confidence: 0.9,
        setIndex: 0,
      );
      expect(prediction.improvementPercentage, equals(100));
    });

    test('improvementPercentage is 100 when currentRecord is zero', () {
      const prediction = PRPrediction(
        type: PRType.weight,
        predictedValue: 110.0,
        currentRecord: 0,
        confidence: 0.9,
        setIndex: 0,
      );
      expect(prediction.improvementPercentage, equals(100));
    });

    test('improvementPercentage calculates correctly with positive values', () {
      const prediction = PRPrediction(
        type: PRType.weight,
        predictedValue: 110.0,
        currentRecord: 100.0,
        confidence: 0.9,
        setIndex: 0,
      );
      expect(prediction.improvementPercentage, closeTo(10.0, 0.001));
    });

    test('isSignificant is true when improvementPercentage > 2.5', () {
      const prediction = PRPrediction(
        type: PRType.weight,
        predictedValue: 110.0,
        currentRecord: 100.0,
        confidence: 0.9,
        setIndex: 0,
      );
      expect(prediction.isSignificant, isTrue);
    });

    test('isSignificant is false when improvementPercentage <= 2.5', () {
      const prediction = PRPrediction(
        type: PRType.weight,
        predictedValue: 102.0,
        currentRecord: 100.0,
        confidence: 0.9,
        setIndex: 0,
      );
      expect(prediction.isSignificant, isFalse);
    });

    test('confidenceLevel is "High" for confidence >= 0.8', () {
      const prediction = PRPrediction(
        type: PRType.weight,
        predictedValue: 100.0,
        confidence: 0.8,
        setIndex: 0,
      );
      expect(prediction.confidenceLevel, equals('High'));
    });

    test('confidenceLevel is "High" for confidence = 0.9', () {
      const prediction = PRPrediction(
        type: PRType.weight,
        predictedValue: 100.0,
        confidence: 0.9,
        setIndex: 0,
      );
      expect(prediction.confidenceLevel, equals('High'));
    });

    test('confidenceLevel is "Medium" for confidence in [0.6, 0.8)', () {
      const prediction = PRPrediction(
        type: PRType.weight,
        predictedValue: 100.0,
        confidence: 0.7,
        setIndex: 0,
      );
      expect(prediction.confidenceLevel, equals('Medium'));
    });

    test('confidenceLevel is "Low" for confidence in [0.4, 0.6)', () {
      const prediction = PRPrediction(
        type: PRType.weight,
        predictedValue: 100.0,
        confidence: 0.5,
        setIndex: 0,
      );
      expect(prediction.confidenceLevel, equals('Low'));
    });

    test('confidenceLevel is "Very Low" for confidence < 0.4', () {
      const prediction = PRPrediction(
        type: PRType.weight,
        predictedValue: 100.0,
        confidence: 0.2,
        setIndex: 0,
      );
      expect(prediction.confidenceLevel, equals('Very Low'));
    });
  });

  // -------------------------------------------------------------------------
  // PersonalRecordAchieved — entity properties
  // -------------------------------------------------------------------------

  group('PersonalRecordAchieved properties', () {
    test('improvementPercentage is 100 when previousValue is null', () {
      final pr = PersonalRecordAchieved(
        exerciseId: 'ex-1',
        exerciseName: 'Squat',
        type: PRType.weight,
        newValue: 100.0,
        achievedAt: DateTime.now(),
      );
      expect(pr.improvementPercentage, equals(100));
    });

    test('improvementPercentage is 100 when previousValue is zero', () {
      final pr = PersonalRecordAchieved(
        exerciseId: 'ex-1',
        exerciseName: 'Squat',
        type: PRType.weight,
        newValue: 100.0,
        previousValue: 0,
        achievedAt: DateTime.now(),
      );
      expect(pr.improvementPercentage, equals(100));
    });

    test('improvementPercentage calculates correctly', () {
      final pr = PersonalRecordAchieved(
        exerciseId: 'ex-1',
        exerciseName: 'Squat',
        type: PRType.weight,
        newValue: 110.0,
        previousValue: 100.0,
        achievedAt: DateTime.now(),
      );
      expect(pr.improvementPercentage, closeTo(10.0, 0.001));
    });

    test('isSignificant is true when improvement > 2.5%', () {
      final pr = PersonalRecordAchieved(
        exerciseId: 'ex-1',
        exerciseName: 'Squat',
        type: PRType.weight,
        newValue: 110.0,
        previousValue: 100.0,
        achievedAt: DateTime.now(),
      );
      expect(pr.isSignificant, isTrue);
    });

    test('isSignificant is false when improvement <= 2.5%', () {
      final pr = PersonalRecordAchieved(
        exerciseId: 'ex-1',
        exerciseName: 'Squat',
        type: PRType.weight,
        newValue: 102.0,
        previousValue: 100.0,
        achievedAt: DateTime.now(),
      );
      expect(pr.isSignificant, isFalse);
    });

    test('formattedImprovement has + prefix with percentage', () {
      final pr = PersonalRecordAchieved(
        exerciseId: 'ex-1',
        exerciseName: 'Squat',
        type: PRType.weight,
        newValue: 110.0,
        previousValue: 100.0,
        achievedAt: DateTime.now(),
      );
      expect(pr.formattedImprovement, startsWith('+'));
      expect(pr.formattedImprovement, contains('%'));
    });

    test('typeDescription returns correct string for each PRType', () {
      final types = {
        PRType.weight: 'Max Weight',
        PRType.reps: 'Max Reps',
        PRType.volume: 'Volume PR',
        PRType.oneRM: '1RM Est.',
        PRType.totalSets: 'Most Sets',
        PRType.duration: 'Endurance',
      };

      for (final entry in types.entries) {
        final pr = PersonalRecordAchieved(
          exerciseId: 'ex-1',
          exerciseName: 'Test',
          type: entry.key,
          newValue: 100.0,
          achievedAt: DateTime.now(),
        );
        expect(pr.typeDescription, equals(entry.value),
            reason: 'PRType.${entry.key.name} should have description "${entry.value}"');
      }
    });
  });

  // -------------------------------------------------------------------------
  // Confidence levels — tested via getPRPredictions()
  // -------------------------------------------------------------------------

  group('PR confidence levels via getPRPredictions()', () {
    test('confidence is High (0.9) for first-ever weight PR (no existing record)', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 5, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final weightPred = result.where((p) => p.type == PRType.weight).first;
      expect(weightPred.confidence, closeTo(0.9, 0.001));
    });

    test('confidence is 0.8 for moderate improvement (>5% but <=10%)', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.weight, value: 100.0,
      );
      final exercise = buildExercise(
        sets: [
          // 107 vs 100 = 7% improvement → confidence 0.8
          buildSet(setNumber: 1, weight: 107, reps: 5, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final weightPred = result.where((p) => p.type == PRType.weight).first;
      expect(weightPred.confidence, closeTo(0.8, 0.001));
    });

    test('confidence is 0.6 for improvement >10% but <=20%', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.weight, value: 100.0,
      );
      final exercise = buildExercise(
        sets: [
          // 115 vs 100 = 15% improvement → confidence 0.6
          buildSet(setNumber: 1, weight: 115, reps: 5, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final weightPred = result.where((p) => p.type == PRType.weight).first;
      expect(weightPred.confidence, closeTo(0.6, 0.001));
    });

    test('confidence is 0.3 for very large improvement (>20%)', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.weight, value: 100.0,
      );
      final exercise = buildExercise(
        sets: [
          // 130 vs 100 = 30% improvement → confidence 0.3
          buildSet(setNumber: 1, weight: 130, reps: 5, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final weightPred = result.where((p) => p.type == PRType.weight).first;
      expect(weightPred.confidence, closeTo(0.3, 0.001));
    });

    test('1RM confidence is 0.9 for low rep range (<=3 reps)', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 150, reps: 3, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final oneRMPred = result.where((p) => p.type == PRType.oneRM).first;
      expect(oneRMPred.confidence, closeTo(0.9, 0.001));
    });

    test('1RM confidence is 0.8 for moderate rep range (4-6 reps)', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 120, reps: 6, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final oneRMPred = result.where((p) => p.type == PRType.oneRM).first;
      expect(oneRMPred.confidence, closeTo(0.8, 0.001));
    });

    test('1RM confidence is 0.6 for rep range 7-10', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 10, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final oneRMPred = result.where((p) => p.type == PRType.oneRM).first;
      expect(oneRMPred.confidence, closeTo(0.6, 0.001));
    });

    test('1RM confidence is 0.4 for rep range 11-15', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 80, reps: 15, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final oneRMPred = result.where((p) => p.type == PRType.oneRM).first;
      expect(oneRMPred.confidence, closeTo(0.4, 0.001));
    });

    test('1RM confidence is 0.2 for high rep count (>15 reps)', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 60, reps: 20, isCompleted: false),
        ],
      );
      final result = await useCase.getPRPredictions(userId, exercise);

      final oneRMPred = result.where((p) => p.type == PRType.oneRM).first;
      expect(oneRMPred.confidence, closeTo(0.2, 0.001));
    });
  });

  // -------------------------------------------------------------------------
  // Volume PR edge cases (via execute())
  // -------------------------------------------------------------------------

  group('Volume PR detection edge cases', () {
    test('volume PR not detected when only warmup sets are completed', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 60, reps: 10, actualReps: 10,
              isCompleted: true, isWarmup: true),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      final volumePRs = result.where((pr) => pr.type == PRType.volume).toList();
      expect(volumePRs, isEmpty);
    });

    test('volume PR not detected when total volume does not exceed existing record', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.volume, value: 2000.0,
      );
      // 2 sets x 100kg x 5 reps = 1000 total volume (< 2000)
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 5, actualReps: 5, isCompleted: true),
          buildSet(setNumber: 2, weight: 100, reps: 5, actualReps: 5, isCompleted: true),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      final volumePRs = result.where((pr) => pr.type == PRType.volume).toList();
      expect(volumePRs, isEmpty);
    });

    test('volume PR context contains sets count, averageWeight, totalReps', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 5, actualReps: 5, isCompleted: true),
          buildSet(setNumber: 2, weight: 100, reps: 5, actualReps: 5, isCompleted: true),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      final volumePR = result.firstWhere((pr) => pr.type == PRType.volume);
      expect(volumePR.context.containsKey('sets'), isTrue);
      expect(volumePR.context.containsKey('averageWeight'), isTrue);
      expect(volumePR.context.containsKey('totalReps'), isTrue);
      expect(volumePR.context['sets'], equals(2));
    });

    test('volume PR averageWeight is computed correctly', () async {
      // 2 sets: 100kg and 80kg → avg = 90kg
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 5, actualReps: 5, isCompleted: true),
          buildSet(setNumber: 2, weight: 80, reps: 5, actualReps: 5, isCompleted: true),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      final volumePR = result.firstWhere((pr) => pr.type == PRType.volume);
      expect(volumePR.context['averageWeight'], closeTo(90.0, 0.001));
    });
  });

  // -------------------------------------------------------------------------
  // TotalSets PR edge cases (via execute())
  // -------------------------------------------------------------------------

  group('TotalSets PR detection edge cases', () {
    test('totalSets PR detected for first time completing any sets', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 5, actualReps: 5, isCompleted: true),
          buildSet(setNumber: 2, weight: 100, reps: 5, actualReps: 5, isCompleted: true),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      final setsPRs = result.where((pr) => pr.type == PRType.totalSets).toList();
      expect(setsPRs, isNotEmpty);
      expect(setsPRs.first.newValue, equals(2.0));
    });

    test('totalSets context includes totalVolume', () async {
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 5, actualReps: 5, isCompleted: true),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      final setsPR = result.firstWhere((pr) => pr.type == PRType.totalSets);
      expect(setsPR.context.containsKey('totalVolume'), isTrue);
    });

    test('totalSets PR not detected when same count as existing record', () async {
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.totalSets, value: 2.0,
      );
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 100, reps: 5, actualReps: 5, isCompleted: true),
          buildSet(setNumber: 2, weight: 100, reps: 5, actualReps: 5, isCompleted: true),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      final setsPRs = result.where((pr) => pr.type == PRType.totalSets).toList();
      expect(setsPRs, isEmpty);
    });

    test('totalSets warmup sets excluded from count', () async {
      // 1 warmup + 1 working set → only 1 working set counted
      await seedExistingPR(
        fakeFirestore,
        userId: userId, exerciseId: exerciseId, exerciseName: exerciseName,
        type: PRType.totalSets, value: 1.0,
      );
      final exercise = buildExercise(
        sets: [
          buildSet(setNumber: 1, weight: 60, reps: 10, actualReps: 10,
              isCompleted: true, isWarmup: true),
          buildSet(setNumber: 2, weight: 100, reps: 5, actualReps: 5,
              isCompleted: true, isWarmup: false),
        ],
      );
      final result = await useCase.execute(userId, buildWorkout(exercises: [exercise]));

      // Only 1 working set, existing record is 1 → no new totalSets PR
      final setsPRs = result.where((pr) => pr.type == PRType.totalSets).toList();
      expect(setsPRs, isEmpty);
    });
  });
}
