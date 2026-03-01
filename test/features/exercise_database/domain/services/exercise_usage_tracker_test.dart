/// Unit tests for ExerciseUsageTracker
///
/// Strategy:
/// - Initialize Hive with a temp directory before tests.
/// - Call ExerciseUsageTracker().initialize() once in setUpAll.
/// - Use resetAllUsage() + box.clear() in tearDown to isolate tests.
/// - Cover: incrementUsage, decrementUsage, removeExercise, getBoost,
///   getBatchBoosts, getUserUsageCounts, getTopUsedExercises,
///   getRecentlyUsedExercises, resetAllUsage, clearOnLogout, dispose.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_usage_model.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_usage_tracker.dart';

void main() {
  late ExerciseUsageTracker tracker;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock flutter_secure_storage (required by HiveBoxManagerEnhanced)
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (methodCall) async {
        switch (methodCall.method) {
          case 'read':
            return null;
          case 'write':
          case 'delete':
          case 'deleteAll':
            return null;
          case 'readAll':
            return <String, String>{};
          case 'containsKey':
            return false;
          default:
            return null;
        }
      },
    );

    Hive.init('./test/hive_test');

    // Initialize HiveBoxManagerEnhanced (required by ExerciseUsageTracker)
    await HiveBoxManagerEnhanced.initialize();

    // Register adapter if not already done
    if (!Hive.isAdapterRegistered(30)) {
      Hive.registerAdapter(ExerciseUsageModelAdapter());
    }

    tracker = ExerciseUsageTracker();
    await tracker.initialize();
  });

  tearDown(() async {
    // Clear all data between tests without closing the box
    await tracker.resetAllUsage();
  });

  tearDownAll(() async {
    await tracker.dispose();
    await Hive.deleteFromDisk();
  });

  // ================================================================
  // incrementUsage
  // ================================================================
  group('ExerciseUsageTracker - incrementUsage', () {
    test('creates new entry on first use', () async {
      await tracker.incrementUsage(
        exerciseId: 'bench_press',
        exerciseName: 'Bench Press',
        userId: 'user-001',
      );

      final counts = await tracker.getUserUsageCounts();
      expect(counts['bench_press'], 1);
    });

    test('increments existing entry on second use', () async {
      await tracker.incrementUsage(
        exerciseId: 'squat',
        exerciseName: 'Squat',
        userId: 'user-001',
      );
      await tracker.incrementUsage(
        exerciseId: 'squat',
        exerciseName: 'Squat',
        userId: 'user-001',
      );

      final counts = await tracker.getUserUsageCounts();
      expect(counts['squat'], 2);
    });

    test('increments multiple times correctly', () async {
      for (var i = 0; i < 5; i++) {
        await tracker.incrementUsage(
          exerciseId: 'deadlift',
          exerciseName: 'Deadlift',
          userId: 'user-001',
        );
      }

      final counts = await tracker.getUserUsageCounts();
      expect(counts['deadlift'], 5);
    });

    test('multiple exercises are tracked independently', () async {
      await tracker.incrementUsage(
        exerciseId: 'ex-a',
        exerciseName: 'Exercise A',
        userId: 'user-001',
      );
      await tracker.incrementUsage(
        exerciseId: 'ex-b',
        exerciseName: 'Exercise B',
        userId: 'user-001',
      );
      await tracker.incrementUsage(
        exerciseId: 'ex-a',
        exerciseName: 'Exercise A',
        userId: 'user-001',
      );

      final counts = await tracker.getUserUsageCounts();
      expect(counts['ex-a'], 2);
      expect(counts['ex-b'], 1);
    });
  });

  // ================================================================
  // decrementUsage
  // ================================================================
  group('ExerciseUsageTracker - decrementUsage', () {
    test('decrements usage count', () async {
      await tracker.incrementUsage(
        exerciseId: 'row',
        exerciseName: 'Barbell Row',
        userId: 'user-001',
      );
      await tracker.incrementUsage(
        exerciseId: 'row',
        exerciseName: 'Barbell Row',
        userId: 'user-001',
      );

      await tracker.decrementUsage(exerciseId: 'row');

      final counts = await tracker.getUserUsageCounts();
      expect(counts['row'], 1);
    });

    test('decrement on non-existent exercise does nothing', () async {
      // Should not throw
      await tracker.decrementUsage(exerciseId: 'nonexistent-exercise');

      final counts = await tracker.getUserUsageCounts();
      expect(counts.containsKey('nonexistent-exercise'), false);
    });

    test('decrement does not go below zero', () async {
      // ExerciseUsageModel.decrement() guards usageCount > 0
      await tracker.incrementUsage(
        exerciseId: 'curl',
        exerciseName: 'Bicep Curl',
        userId: 'user-001',
      );

      // Decrement once (1 → 0)
      await tracker.decrementUsage(exerciseId: 'curl');
      // Try to decrement again (already 0)
      await tracker.decrementUsage(exerciseId: 'curl');

      final counts = await tracker.getUserUsageCounts();
      expect(counts['curl'], 0);
    });
  });

  // ================================================================
  // removeExercise
  // ================================================================
  group('ExerciseUsageTracker - removeExercise', () {
    test('removes existing exercise from tracking', () async {
      await tracker.incrementUsage(
        exerciseId: 'press',
        exerciseName: 'Overhead Press',
        userId: 'user-001',
      );

      await tracker.removeExercise(exerciseId: 'press');

      final counts = await tracker.getUserUsageCounts();
      expect(counts.containsKey('press'), false);
    });

    test('remove non-existent exercise does nothing', () async {
      await tracker.incrementUsage(
        exerciseId: 'existing',
        exerciseName: 'Existing Exercise',
        userId: 'user-001',
      );

      // Should not throw
      await tracker.removeExercise(exerciseId: 'not-there');

      final counts = await tracker.getUserUsageCounts();
      expect(counts.containsKey('existing'), true);
      expect(counts.containsKey('not-there'), false);
    });

    test('remove eliminates exercise from top used', () async {
      await tracker.incrementUsage(
        exerciseId: 'to-remove',
        exerciseName: 'To Remove',
        userId: 'user-001',
      );

      await tracker.removeExercise(exerciseId: 'to-remove');
      final top = await tracker.getTopUsedExercises(limit: 10);
      final ids = top.map((e) => e.exerciseId).toList();
      expect(ids.contains('to-remove'), false);
    });
  });

  // ================================================================
  // getBoost
  // ================================================================
  group('ExerciseUsageTracker - getBoost', () {
    test('returns 0.0 for unknown exercise', () async {
      final boost = await tracker.getBoost('totally-unknown-id');
      expect(boost, 0.0);
    });

    test('returns 1.0 for the most-used exercise when it is the only one', () async {
      await tracker.incrementUsage(
        exerciseId: 'top-dog',
        exerciseName: 'Top Dog',
        userId: 'user-001',
      );

      final boost = await tracker.getBoost('top-dog');
      expect(boost, closeTo(1.0, 0.001));
    });

    test('most-used exercise has higher boost than less-used', () async {
      // Exercise A: 10 uses
      for (var i = 0; i < 10; i++) {
        await tracker.incrementUsage(
          exerciseId: 'frequent',
          exerciseName: 'Frequent Exercise',
          userId: 'user-001',
        );
      }
      // Exercise B: 2 uses
      await tracker.incrementUsage(
        exerciseId: 'rare',
        exerciseName: 'Rare Exercise',
        userId: 'user-001',
      );
      await tracker.incrementUsage(
        exerciseId: 'rare',
        exerciseName: 'Rare Exercise',
        userId: 'user-001',
      );

      final freqBoost = await tracker.getBoost('frequent');
      final rareBoost = await tracker.getBoost('rare');

      expect(freqBoost, greaterThan(rareBoost));
    });

    test('boost is in range 0.0 to 1.0', () async {
      await tracker.incrementUsage(
        exerciseId: 'range-test',
        exerciseName: 'Range Test',
        userId: 'user-001',
      );

      final boost = await tracker.getBoost('range-test');
      expect(boost, greaterThanOrEqualTo(0.0));
      expect(boost, lessThanOrEqualTo(1.0));
    });
  });

  // ================================================================
  // getBatchBoosts
  // ================================================================
  group('ExerciseUsageTracker - getBatchBoosts', () {
    test('returns 0.0 for all unknown exercises', () async {
      final boosts = await tracker.getBatchBoosts(['a', 'b', 'c']);
      expect(boosts['a'], 0.0);
      expect(boosts['b'], 0.0);
      expect(boosts['c'], 0.0);
    });

    test('returns 0.0 for empty list', () async {
      final boosts = await tracker.getBatchBoosts([]);
      expect(boosts, isEmpty);
    });

    test('returns map with all requested IDs', () async {
      await tracker.incrementUsage(
        exerciseId: 'ex-1',
        exerciseName: 'Exercise 1',
        userId: 'user-001',
      );

      final boosts = await tracker.getBatchBoosts(['ex-1', 'ex-unknown']);
      expect(boosts.containsKey('ex-1'), true);
      expect(boosts.containsKey('ex-unknown'), true);
      expect(boosts['ex-unknown'], 0.0);
    });

    test('known exercise has higher boost than unknown', () async {
      await tracker.incrementUsage(
        exerciseId: 'known',
        exerciseName: 'Known Exercise',
        userId: 'user-001',
      );

      final boosts = await tracker.getBatchBoosts(['known', 'unknown-one']);
      expect(boosts['known']!, greaterThan(boosts['unknown-one']!));
    });

    test('batch boosts are consistent with individual getBoost', () async {
      for (var i = 0; i < 3; i++) {
        await tracker.incrementUsage(
          exerciseId: 'consistent-ex',
          exerciseName: 'Consistent',
          userId: 'user-001',
        );
      }

      final singleBoost = await tracker.getBoost('consistent-ex');
      final batchBoosts = await tracker.getBatchBoosts(['consistent-ex']);

      expect(batchBoosts['consistent-ex'], closeTo(singleBoost, 0.001));
    });
  });

  // ================================================================
  // getUserUsageCounts
  // ================================================================
  group('ExerciseUsageTracker - getUserUsageCounts', () {
    test('returns empty map when no exercises tracked', () async {
      final counts = await tracker.getUserUsageCounts();
      expect(counts, isEmpty);
    });

    test('returns correct counts for tracked exercises', () async {
      await tracker.incrementUsage(
        exerciseId: 'ex-x',
        exerciseName: 'X',
        userId: 'user-001',
      );
      await tracker.incrementUsage(
        exerciseId: 'ex-y',
        exerciseName: 'Y',
        userId: 'user-001',
      );
      await tracker.incrementUsage(
        exerciseId: 'ex-y',
        exerciseName: 'Y',
        userId: 'user-001',
      );

      final counts = await tracker.getUserUsageCounts();
      expect(counts['ex-x'], 1);
      expect(counts['ex-y'], 2);
    });

    test('returns map keyed by exerciseId', () async {
      await tracker.incrementUsage(
        exerciseId: 'keyed-ex',
        exerciseName: 'Keyed Exercise',
        userId: 'user-001',
      );

      final counts = await tracker.getUserUsageCounts();
      expect(counts.keys, contains('keyed-ex'));
    });
  });

  // ================================================================
  // getTopUsedExercises
  // ================================================================
  group('ExerciseUsageTracker - getTopUsedExercises', () {
    test('returns empty list when no exercises tracked', () async {
      final top = await tracker.getTopUsedExercises();
      expect(top, isEmpty);
    });

    test('returns exercises sorted by usage count descending', () async {
      await tracker.incrementUsage(
        exerciseId: 'low',
        exerciseName: 'Low Usage',
        userId: 'user-001',
      );
      for (var i = 0; i < 5; i++) {
        await tracker.incrementUsage(
          exerciseId: 'high',
          exerciseName: 'High Usage',
          userId: 'user-001',
        );
      }
      for (var i = 0; i < 3; i++) {
        await tracker.incrementUsage(
          exerciseId: 'mid',
          exerciseName: 'Mid Usage',
          userId: 'user-001',
        );
      }

      final top = await tracker.getTopUsedExercises();

      expect(top[0].exerciseId, 'high');
      expect(top[1].exerciseId, 'mid');
      expect(top[2].exerciseId, 'low');
    });

    test('respects limit parameter', () async {
      for (var i = 0; i < 5; i++) {
        await tracker.incrementUsage(
          exerciseId: 'ex-$i',
          exerciseName: 'Exercise $i',
          userId: 'user-001',
        );
      }

      final top = await tracker.getTopUsedExercises(limit: 3);
      expect(top.length, lessThanOrEqualTo(3));
    });

    test('default limit is 10', () async {
      for (var i = 0; i < 15; i++) {
        await tracker.incrementUsage(
          exerciseId: 'many-$i',
          exerciseName: 'Many $i',
          userId: 'user-001',
        );
      }

      final top = await tracker.getTopUsedExercises();
      expect(top.length, lessThanOrEqualTo(10));
    });
  });

  // ================================================================
  // getRecentlyUsedExercises
  // ================================================================
  group('ExerciseUsageTracker - getRecentlyUsedExercises', () {
    test('returns empty list when no exercises tracked', () async {
      final recent = await tracker.getRecentlyUsedExercises();
      expect(recent, isEmpty);
    });

    test('returns tracked exercises', () async {
      await tracker.incrementUsage(
        exerciseId: 'recent-ex',
        exerciseName: 'Recent Exercise',
        userId: 'user-001',
      );

      final recent = await tracker.getRecentlyUsedExercises();
      expect(recent, isNotEmpty);
    });

    test('respects limit parameter', () async {
      for (var i = 0; i < 5; i++) {
        await tracker.incrementUsage(
          exerciseId: 'recent-$i',
          exerciseName: 'Recent $i',
          userId: 'user-001',
        );
      }

      final recent = await tracker.getRecentlyUsedExercises(limit: 2);
      expect(recent.length, lessThanOrEqualTo(2));
    });

    test('default limit is 10', () async {
      for (var i = 0; i < 15; i++) {
        await tracker.incrementUsage(
          exerciseId: 'r-$i',
          exerciseName: 'R $i',
          userId: 'user-001',
        );
      }

      final recent = await tracker.getRecentlyUsedExercises();
      expect(recent.length, lessThanOrEqualTo(10));
    });
  });

  // ================================================================
  // resetAllUsage
  // ================================================================
  group('ExerciseUsageTracker - resetAllUsage', () {
    test('clears all usage data', () async {
      await tracker.incrementUsage(
        exerciseId: 'to-clear',
        exerciseName: 'To Clear',
        userId: 'user-001',
      );

      await tracker.resetAllUsage();

      final counts = await tracker.getUserUsageCounts();
      expect(counts, isEmpty);
    });

    test('after reset, boost returns 0.0 for previously tracked exercise', () async {
      await tracker.incrementUsage(
        exerciseId: 'was-tracked',
        exerciseName: 'Was Tracked',
        userId: 'user-001',
      );

      await tracker.resetAllUsage();

      final boost = await tracker.getBoost('was-tracked');
      expect(boost, 0.0);
    });

    test('after reset, can track new exercises', () async {
      await tracker.incrementUsage(
        exerciseId: 'pre-reset',
        exerciseName: 'Pre Reset',
        userId: 'user-001',
      );
      await tracker.resetAllUsage();

      await tracker.incrementUsage(
        exerciseId: 'post-reset',
        exerciseName: 'Post Reset',
        userId: 'user-001',
      );

      final counts = await tracker.getUserUsageCounts();
      expect(counts.containsKey('pre-reset'), false);
      expect(counts['post-reset'], 1);
    });
  });

  // ================================================================
  // clearOnLogout
  // ================================================================
  group('ExerciseUsageTracker - clearOnLogout', () {
    test('clears all data on logout', () async {
      await tracker.incrementUsage(
        exerciseId: 'logout-ex',
        exerciseName: 'Logout Exercise',
        userId: 'user-001',
      );

      await tracker.clearOnLogout();

      final counts = await tracker.getUserUsageCounts();
      expect(counts, isEmpty);
    });

    test('clearOnLogout is safe to call multiple times', () async {
      await tracker.clearOnLogout();
      await tracker.clearOnLogout();
      // No crash expected
    });
  });

  // ================================================================
  // Edge cases
  // ================================================================
  group('ExerciseUsageTracker - edge cases', () {
    test('exercises with same usage count but tracked at different times', () async {
      await tracker.incrementUsage(
        exerciseId: 'a',
        exerciseName: 'A',
        userId: 'user-001',
      );
      await tracker.incrementUsage(
        exerciseId: 'b',
        exerciseName: 'B',
        userId: 'user-001',
      );

      final top = await tracker.getTopUsedExercises();
      expect(top.length, 2);
      // Both have count 1, order may vary — just verify both are returned
      final ids = top.map((e) => e.exerciseId).toList();
      expect(ids, containsAll(['a', 'b']));
    });

    test('getBatchBoosts handles large list efficiently', () async {
      final ids = List.generate(50, (i) => 'bulk-ex-$i');

      // Track a subset
      await tracker.incrementUsage(
        exerciseId: 'bulk-ex-0',
        exerciseName: 'Bulk Ex 0',
        userId: 'user-001',
      );

      final boosts = await tracker.getBatchBoosts(ids);
      expect(boosts.length, 50);
      expect(boosts['bulk-ex-0'], greaterThan(0.0));
      expect(boosts['bulk-ex-1'], 0.0);
    });
  });
}
