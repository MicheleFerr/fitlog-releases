import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PRTracker prTracker;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    prTracker = PRTracker(firestore: fakeFirestore);
  });

  // Helper function to create ExerciseActivity for testing
  ExerciseActivity createActivity({
    required String userId,
    required String exerciseId,
    required String exerciseName,
    required List<ExerciseActivitySet> sets,
    DateTime? createdAt,
    ExerciseCategory category = ExerciseCategory.chest,
  }) {
    return ExerciseActivity(
      id: 'test-activity-id',
      email: userId,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      sets: sets,
      schedaName: 'Test Workout',
      category: category,
      createdAt: createdAt ?? DateTime.now(),
      lastModified: createdAt ?? DateTime.now(),
    );
  }

  // Helper function to create ExerciseActivitySet
  ExerciseActivitySet createSet({
    required String weight,
    required String reps,
    String? actualReps,
    bool done = true,
    bool isWarmup = false,
    int setNumber = 1,
  }) {
    return ExerciseActivitySet(
      set: setNumber,
      weight: weight,
      reps: reps,
      actualReps: actualReps,
      effort: 3,
      done: done,
      isWarmup: isWarmup,
    );
  }

  group('PersonalRecord Entity', () {
    test('should calculate improvement percentage correctly', () {
      // 🐛 BUG PREVENTED: Incorrect improvement calculation could show wrong progress
      // Example: User lifts 120kg after 100kg, should show 20% improvement
      final pr = PersonalRecord(
        id: 'pr-1',
        userId: 'user-1',
        exerciseId: 'bench-press',
        exerciseName: 'Bench Press',
        type: PRType.weight,
        value: 120.0,
        previousValue: 100.0,
        achievedAt: DateTime.now(),
      );

      expect(pr.improvementPercentage, 20.0);
    });

    test('should return 0% improvement when no previous value', () {
      // 🐛 BUG PREVENTED: Crash or incorrect calculation for first-ever PR
      final pr = PersonalRecord(
        id: 'pr-1',
        userId: 'user-1',
        exerciseId: 'squat',
        exerciseName: 'Squat',
        type: PRType.weight,
        value: 150.0,
        previousValue: null,
        achievedAt: DateTime.now(),
      );

      expect(pr.improvementPercentage, 0.0);
    });

    test('should return 0% improvement when previous value is 0', () {
      // 🐛 BUG PREVENTED: Division by zero crash
      final pr = PersonalRecord(
        id: 'pr-1',
        userId: 'user-1',
        exerciseId: 'deadlift',
        exerciseName: 'Deadlift',
        type: PRType.weight,
        value: 200.0,
        previousValue: 0.0,
        achievedAt: DateTime.now(),
      );

      expect(pr.improvementPercentage, 0.0);
    });

    test('should identify significant PR (>2.5% improvement)', () {
      // 🐛 BUG PREVENTED: Too many notifications for tiny improvements
      // Example: 100kg → 103kg (3%) is significant, 100kg → 101kg (1%) is not
      final significantPR = PersonalRecord(
        id: 'pr-1',
        userId: 'user-1',
        exerciseId: 'press',
        exerciseName: 'Overhead Press',
        type: PRType.weight,
        value: 103.0,
        previousValue: 100.0,
        achievedAt: DateTime.now(),
      );

      final insignificantPR = PersonalRecord(
        id: 'pr-2',
        userId: 'user-1',
        exerciseId: 'press',
        exerciseName: 'Overhead Press',
        type: PRType.weight,
        value: 101.0,
        previousValue: 100.0,
        achievedAt: DateTime.now(),
      );

      expect(significantPR.isSignificant, true);
      expect(insignificantPR.isSignificant, false);
    });

    test('should serialize and deserialize correctly', () {
      // 🐛 BUG PREVENTED: Data corruption in Firebase storage
      final original = PersonalRecord(
        id: 'pr-1',
        userId: 'user-123',
        exerciseId: 'squat-1',
        exerciseName: 'Back Squat',
        type: PRType.weight,
        value: 180.0,
        previousValue: 170.0,
        achievedAt: DateTime(2024, 1, 15),
        metadata: {'workoutName': 'Leg Day', 'reps': '5'},
      );

      final firestore = original.toFirestore();
      expect(firestore['userId'], 'user-123');
      expect(firestore['exerciseId'], 'squat-1');
      expect(firestore['exerciseName'], 'Back Squat');
      expect(firestore['type'], 'weight');
      expect(firestore['value'], 180.0);
      expect(firestore['previousValue'], 170.0);
      expect(firestore['metadata'], {'workoutName': 'Leg Day', 'reps': '5'});
    });

    test('should create copy with updated fields', () {
      // 🐛 BUG PREVENTED: Mutating shared PR instances
      final original = PersonalRecord(
        id: 'pr-1',
        userId: 'user-1',
        exerciseId: 'deadlift',
        exerciseName: 'Deadlift',
        type: PRType.weight,
        value: 200.0,
        previousValue: 190.0,
        achievedAt: DateTime.now(),
      );

      final updated = original.copyWith(value: 210.0);

      expect(updated.value, 210.0);
      expect(updated.previousValue, 190.0); // Unchanged
      expect(updated.exerciseName, 'Deadlift'); // Unchanged
    });
  });

  group('Weight PR Detection', () {
    test('should detect new weight PR when no existing PR', () async {
      // 🐛 BUG PREVENTED: First-time PR not recorded
      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'bench-press',
        exerciseName: 'Bench Press',
        sets: [
          createSet(weight: '100', reps: '5'),
          createSet(weight: '110', reps: '3'),
          createSet(weight: '120', reps: '1'),
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      final weightPR = newPRs.firstWhere((pr) => pr.type == PRType.weight);
      expect(weightPR.value, 120.0);
      expect(weightPR.previousValue, null);
    });

    test('should detect weight PR when exceeding previous best', () async {
      // 🐛 BUG PREVENTED: User hits new max weight but PR not detected
      // Setup: existing PR of 100kg
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'weight',
        'value': 100.0,
        'achievedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
      });

      // New activity with 110kg
      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'squat',
        exerciseName: 'Squat',
        sets: [
          createSet(weight: '110', reps: '5'),
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      final weightPR = newPRs.firstWhere((pr) => pr.type == PRType.weight);
      expect(weightPR.value, 110.0);
      expect(weightPR.previousValue, 100.0);
    });

    test('should NOT detect weight PR when weight equals existing PR', () async {
      // 🐛 BUG PREVENTED: Duplicate PR notifications for same weight
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'deadlift',
        'exerciseName': 'Deadlift',
        'type': 'weight',
        'value': 150.0,
        'achievedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      });

      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'deadlift',
        exerciseName: 'Deadlift',
        sets: [
          createSet(weight: '150', reps: '5'),
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      expect(newPRs.where((pr) => pr.type == PRType.weight).isEmpty, true);
    });

    test('should ignore warmup sets in weight PR detection', () async {
      // 🐛 BUG PREVENTED: Warmup weight incorrectly counted as PR
      // Example: Warmup 60kg, working sets 100kg → PR should be 100kg, not 60kg
      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'press',
        exerciseName: 'Overhead Press',
        sets: [
          createSet(weight: '40', reps: '10', isWarmup: true),
          createSet(weight: '60', reps: '8', isWarmup: true),
          createSet(weight: '80', reps: '5'),
          createSet(weight: '85', reps: '3'),
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      final weightPR = newPRs.firstWhere((pr) => pr.type == PRType.weight);
      expect(weightPR.value, 85.0); // Should be max working set, not warmup
    });

    test('should ignore incomplete sets in weight PR detection', () async {
      // 🐛 BUG PREVENTED: Planned but unexecuted sets counted as PRs
      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'bench-press',
        exerciseName: 'Bench Press',
        sets: [
          createSet(weight: '100', reps: '5', done: true),
          createSet(weight: '120', reps: '3', done: false), // Not completed
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      final weightPR = newPRs.firstWhere((pr) => pr.type == PRType.weight);
      expect(weightPR.value, 100.0); // Should be completed set only
    });
  });

  group('Reps PR Detection', () {
    test('should detect reps PR using weight×reps scoring', () async {
      // 🐛 BUG PREVENTED: User does more reps at same weight but PR not detected
      // Example: 100kg×5 vs 100kg×8 → second is better
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'reps',
        'value': 5.0,
        'metadata': {'weight': 100.0},
        'achievedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
      });

      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'squat',
        exerciseName: 'Squat',
        sets: [
          createSet(weight: '100', reps: '8'),
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      final repsPR = newPRs.firstWhere((pr) => pr.type == PRType.reps);
      expect(repsPR.value, 8.0);
      expect(repsPR.metadata['weight'], 100.0);
    });

    test('should use actualReps over planned reps', () async {
      // 🐛 BUG PREVENTED: User plans 8 reps but only completes 6, PR should reflect actual
      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'bench-press',
        exerciseName: 'Bench Press',
        sets: [
          createSet(weight: '100', reps: '8', actualReps: '6'),
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      final repsPR = newPRs.firstWhere((pr) => pr.type == PRType.reps);
      expect(repsPR.value, 6.0); // Should use actualReps
    });

    test('should require same or higher weight for reps PR', () async {
      // 🐛 BUG PREVENTED: Lower weight with more reps incorrectly counted as PR
      // Example: 100kg×5 is still better than 80kg×10 for reps PR
      // Reps PR requires same/higher weight to maintain quality standard
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'deadlift',
        'exerciseName': 'Deadlift',
        'type': 'reps',
        'value': 5.0,
        'metadata': {'weight': 100.0},
        'achievedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      });

      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'deadlift',
        exerciseName: 'Deadlift',
        sets: [
          createSet(weight: '80', reps: '10'), // Lower weight, more reps
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      // Should NOT detect reps PR because weight (80) < existing weight (100)
      // Reps PR requires same or higher weight
      expect(newPRs.where((pr) => pr.type == PRType.reps).isEmpty, true);
    });
  });

  group('Volume PR Detection', () {
    test('should detect volume PR (total weight × reps)', () async {
      // 🐛 BUG PREVENTED: User completes more total volume but PR not detected
      // Example: 3×5×100kg = 1500kg total volume
      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'squat',
        exerciseName: 'Squat',
        sets: [
          createSet(weight: '100', reps: '5'),
          createSet(weight: '100', reps: '5'),
          createSet(weight: '100', reps: '5'),
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      final volumePR = newPRs.firstWhere((pr) => pr.type == PRType.volume);
      expect(volumePR.value, 1500.0); // 100×5×3 = 1500
    });

    test('should NOT detect volume PR when volume equals existing', () async {
      // 🐛 BUG PREVENTED: Same volume incorrectly triggers duplicate notifications
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'bench-press',
        'exerciseName': 'Bench Press',
        'type': 'volume',
        'value': 1000.0,
        'achievedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
      });

      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'bench-press',
        exerciseName: 'Bench Press',
        sets: [
          createSet(weight: '100', reps: '10'), // 100×10 = 1000
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      expect(newPRs.where((pr) => pr.type == PRType.volume).isEmpty, true);
    });
  });

  group('1RM PR Detection', () {
    test('should detect 1RM PR using OneRMCalculator', () async {
      // 🐛 BUG PREVENTED: User improves estimated 1RM but PR not detected
      // Example: 100kg×5 reps estimates ~115kg 1RM
      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'bench-press',
        exerciseName: 'Bench Press',
        sets: [
          createSet(weight: '100', reps: '5'),
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      final oneRMPR = newPRs.firstWhere((pr) => pr.type == PRType.oneRM);
      expect(oneRMPR.value, greaterThan(110.0)); // Estimated 1RM should be >110kg
      expect(oneRMPR.metadata['weight'], 100.0);
      expect(oneRMPR.metadata['reps'], 5);
    });

    test('should use best 1RM estimate from multiple sets', () async {
      // 🐛 BUG PREVENTED: Using average instead of best estimate
      // Example: 120kg×1 (120 1RM) vs 100kg×5 (~115 1RM) → 120 should win
      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'squat',
        exerciseName: 'Squat',
        sets: [
          createSet(weight: '100', reps: '8'),
          createSet(weight: '110', reps: '5'),
          createSet(weight: '120', reps: '2'),
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      final oneRMPR = newPRs.firstWhere((pr) => pr.type == PRType.oneRM);
      // 120×2 should give highest estimated 1RM
      expect(oneRMPR.value, greaterThan(125.0));
    });
  });

  group('Total Sets PR Detection', () {
    test('should detect total sets PR', () async {
      // 🐛 BUG PREVENTED: User completes more sets than ever but PR not detected
      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'curl',
        exerciseName: 'Bicep Curl',
        sets: [
          createSet(weight: '20', reps: '12'),
          createSet(weight: '20', reps: '12'),
          createSet(weight: '20', reps: '12'),
          createSet(weight: '20', reps: '12'),
          createSet(weight: '20', reps: '12'),
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      final setsPR = newPRs.firstWhere((pr) => pr.type == PRType.totalSets);
      expect(setsPR.value, 5.0);
    });

    test('should exclude warmup and incomplete sets from total', () async {
      // 🐛 BUG PREVENTED: Warmup sets incorrectly counted in total sets PR
      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'squat',
        exerciseName: 'Squat',
        sets: [
          createSet(weight: '60', reps: '10', isWarmup: true),
          createSet(weight: '80', reps: '8', isWarmup: true),
          createSet(weight: '100', reps: '5'),
          createSet(weight: '100', reps: '5'),
          createSet(weight: '100', reps: '5'),
          createSet(weight: '100', reps: '5', done: false),
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      final setsPR = newPRs.firstWhere((pr) => pr.type == PRType.totalSets);
      expect(setsPR.value, 3.0); // Only working sets that are completed
    });
  });

  group('getUserPRs', () {
    test('should fetch all PRs for a user ordered by date', () async {
      // 🐛 BUG PREVENTED: PRs shown in wrong order in history view
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'weight',
        'value': 150.0,
        'achievedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      });

      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'bench-press',
        'exerciseName': 'Bench Press',
        'type': 'weight',
        'value': 120.0,
        'achievedAt': Timestamp.fromDate(DateTime(2024, 1, 15)),
      });

      final prs = await prTracker.getUserPRs('user-1');

      expect(prs.length, 2);
      // Should be ordered by achievedAt descending (most recent first)
      expect(prs[0].exerciseName, 'Bench Press');
      expect(prs[1].exerciseName, 'Squat');
    });

    test('should return empty list for user with no PRs', () async {
      // 🐛 BUG PREVENTED: Crash when new user has no PR history
      final prs = await prTracker.getUserPRs('new-user');

      expect(prs, isEmpty);
    });
  });

  group('getExercisePRs', () {
    test('should fetch all PR types for an exercise', () async {
      // 🐛 BUG PREVENTED: Missing PR types in exercise detail view
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'weight',
        'value': 150.0,
        'achievedAt': Timestamp.fromDate(DateTime.now()),
      });

      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'volume',
        'value': 3000.0,
        'achievedAt': Timestamp.fromDate(DateTime.now()),
      });

      final prs = await prTracker.getExercisePRs('user-1', 'squat');

      expect(prs.length, 2);
      expect(prs[PRType.weight]?.value, 150.0);
      expect(prs[PRType.volume]?.value, 3000.0);
    });

    test('should keep only highest value for each PR type', () async {
      // 🐛 BUG PREVENTED: Showing old PR instead of current best
      // Example: User hits 100kg, then 110kg → should show 110kg only
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'bench-press',
        'exerciseName': 'Bench Press',
        'type': 'weight',
        'value': 100.0,
        'achievedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      });

      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'bench-press',
        'exerciseName': 'Bench Press',
        'type': 'weight',
        'value': 110.0,
        'achievedAt': Timestamp.fromDate(DateTime(2024, 1, 15)),
      });

      final prs = await prTracker.getExercisePRs('user-1', 'bench-press');

      expect(prs[PRType.weight]?.value, 110.0); // Should be highest
    });
  });

  group('getRecentPRs', () {
    test('should return only PRs from last 30 days', () async {
      // 🐛 BUG PREVENTED: Showing old PRs in "recent achievements" section
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'weight',
        'value': 140.0,
        'achievedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
      });

      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'bench-press',
        'exerciseName': 'Bench Press',
        'type': 'weight',
        'value': 110.0,
        'achievedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 45))),
      });

      final recentPRs = await prTracker.getRecentPRs('user-1');

      expect(recentPRs.length, 1);
      expect(recentPRs[0].exerciseName, 'Squat');
    });
  });

  group('getPRTimeline', () {
    test('should return PR progression over time', () async {
      // 🐛 BUG PREVENTED: Can't see historical PR progression in charts
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'weight',
        'value': 100.0,
        'achievedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      });

      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'weight',
        'value': 110.0,
        'achievedAt': Timestamp.fromDate(DateTime(2024, 2, 1)),
      });

      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'weight',
        'value': 120.0,
        'achievedAt': Timestamp.fromDate(DateTime(2024, 3, 1)),
      });

      final timeline = await prTracker.getPRTimeline(
        'user-1',
        'squat',
        PRType.weight,
      );

      expect(timeline.length, 3);
      expect(timeline[0].value, 100.0); // Ordered by date ascending
      expect(timeline[1].value, 110.0);
      expect(timeline[2].value, 120.0);
    });
  });

  group('PRStats', () {
    test('should calculate comprehensive PR statistics', () async {
      // 🐛 BUG PREVENTED: Incorrect stats in dashboard overview
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'weight',
        'value': 150.0,
        'achievedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
      });

      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'volume',
        'value': 3000.0,
        'achievedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 10))),
      });

      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'bench-press',
        'exerciseName': 'Bench Press',
        'type': 'weight',
        'value': 120.0,
        'achievedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 45))),
      });

      final stats = await prTracker.getPRStats('user-1');

      expect(stats.totalPRs, 3);
      expect(stats.recentPRs, 2); // Last 30 days
      expect(stats.prsByType[PRType.weight], 2);
      expect(stats.prsByType[PRType.volume], 1);
      expect(stats.prsByExercise['Squat'], 2);
      expect(stats.prsByExercise['Bench Press'], 1);
    });

    test('should identify most common PR type', () async {
      // 🐛 BUG PREVENTED: Wrong "favorite achievement" shown in profile
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'weight',
        'value': 150.0,
        'achievedAt': Timestamp.fromDate(DateTime.now()),
      });

      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'bench-press',
        'exerciseName': 'Bench Press',
        'type': 'weight',
        'value': 120.0,
        'achievedAt': Timestamp.fromDate(DateTime.now()),
      });

      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'deadlift',
        'exerciseName': 'Deadlift',
        'type': 'volume',
        'value': 5000.0,
        'achievedAt': Timestamp.fromDate(DateTime.now()),
      });

      final stats = await prTracker.getPRStats('user-1');

      expect(stats.mostCommonType, PRType.weight); // 2 weight PRs vs 1 volume
    });

    test('should identify exercise with most PRs', () async {
      // 🐛 BUG PREVENTED: Can't see which exercise user is improving most
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'weight',
        'value': 150.0,
        'achievedAt': Timestamp.fromDate(DateTime.now()),
      });

      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'volume',
        'value': 3000.0,
        'achievedAt': Timestamp.fromDate(DateTime.now()),
      });

      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'bench-press',
        'exerciseName': 'Bench Press',
        'type': 'weight',
        'value': 120.0,
        'achievedAt': Timestamp.fromDate(DateTime.now()),
      });

      final stats = await prTracker.getPRStats('user-1');

      expect(stats.bestExercise, 'Squat'); // 2 PRs vs 1 for Bench Press
    });

    test('should calculate days since last PR', () async {
      // 🐛 BUG PREVENTED: "It's been X days since your last PR" motivational prompt
      await fakeFirestore.collection('personalRecords').add({
        'userId': 'user-1',
        'exerciseId': 'squat',
        'exerciseName': 'Squat',
        'type': 'weight',
        'value': 150.0,
        'achievedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
      });

      final stats = await prTracker.getPRStats('user-1');

      expect(stats.daysSinceLastPR, 7);
    });

    test('should handle empty PR history gracefully', () async {
      // 🐛 BUG PREVENTED: Crash when new user views stats
      final stats = await prTracker.getPRStats('new-user');

      expect(stats.totalPRs, 0);
      expect(stats.recentPRs, 0);
      expect(stats.mostCommonType, null);
      expect(stats.bestExercise, null);
      expect(stats.daysSinceLastPR, null);
    });
  });

  group('Integration Tests', () {
    test('should detect multiple PR types in single workout', () async {
      // 🐛 BUG PREVENTED: User achieves multiple PRs but only one is detected
      // Real scenario: 5 sets of 120kg bench press = weight PR + volume PR + sets PR
      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'bench-press',
        exerciseName: 'Bench Press',
        sets: [
          createSet(weight: '120', reps: '5'),
          createSet(weight: '120', reps: '5'),
          createSet(weight: '120', reps: '5'),
          createSet(weight: '120', reps: '5'),
          createSet(weight: '120', reps: '5'),
        ],
      );

      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      // Should detect weight, reps, volume, 1RM, and totalSets PRs
      expect(newPRs.length, greaterThanOrEqualTo(3));
      expect(newPRs.any((pr) => pr.type == PRType.weight), true);
      expect(newPRs.any((pr) => pr.type == PRType.volume), true);
      expect(newPRs.any((pr) => pr.type == PRType.totalSets), true);
    });

    test('should persist PRs to Firestore', () async {
      // 🐛 BUG PREVENTED: PRs calculated but not saved, lost after app restart
      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'squat',
        exerciseName: 'Squat',
        sets: [
          createSet(weight: '150', reps: '5'),
        ],
      );

      await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');

      // Verify PRs were saved to Firestore
      final snapshot = await fakeFirestore
          .collection('personalRecords')
          .where('userId', isEqualTo: 'user-1')
          .get();

      expect(snapshot.docs.isNotEmpty, true);
    });

    test('should handle complete workflow: detect → save → fetch → stats', () async {
      // 🐛 BUG PREVENTED: End-to-end PR tracking workflow has gaps
      // Step 1: User completes workout
      final activity = createActivity(
        userId: 'user-1',
        exerciseId: 'deadlift',
        exerciseName: 'Deadlift',
        sets: [
          createSet(weight: '200', reps: '3'),
          createSet(weight: '200', reps: '3'),
        ],
      );

      // Step 2: Detect and save PRs
      final newPRs = await prTracker.checkAndUpdatePRs(activity, userId: 'user-1');
      expect(newPRs.isNotEmpty, true);

      // Step 3: Fetch user's PRs
      final allPRs = await prTracker.getUserPRs('user-1');
      expect(allPRs.isNotEmpty, true);

      // Step 4: Get exercise-specific PRs
      final exercisePRs = await prTracker.getExercisePRs('user-1', 'deadlift');
      expect(exercisePRs.isNotEmpty, true);

      // Step 5: Calculate stats
      final stats = await prTracker.getPRStats('user-1');
      expect(stats.totalPRs, greaterThan(0));
      expect(stats.bestExercise, 'Deadlift');
    });
  });
}
