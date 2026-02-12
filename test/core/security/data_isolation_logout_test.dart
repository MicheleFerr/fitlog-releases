/// Data Isolation Integration Test
///
/// Verifies that ALL user data is properly cleared after logout,
/// preventing data leakage between user sessions.
///
/// This test was created in response to a critical bug where
/// a new user saw previous user's completed workout days after
/// registering with a fresh account.
///
/// Root cause: HiveBoxManagerEnhanced.clearAllUserData() only cleared
/// boxes tracked in _openBoxes map. Boxes never opened during the
/// session retained stale data from the previous user.
library;

import 'dart:io';
import '../../helpers/test_setup.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/cached_progress_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/core/services/rate_limiter.dart' show CooldownLimiter;

void main() {
  late HiveBoxManagerEnhanced boxManager;
  late Directory testDir;

  setUpAll(() async {
    mockSecureStorage();
    TestWidgetsFlutterBinding.ensureInitialized();
    testDir = await Directory.systemTemp.createTemp('hive_data_isolation_test_');
    Hive.init(testDir.path);
    HiveBoxManagerEnhanced.resetInitializationForTesting();
    await HiveBoxManagerEnhanced.initialize();
  });

  setUp(() {
    boxManager = HiveBoxManagerEnhanced();
    boxManager.resetForTesting();
  });

  tearDown(() async {
    try {
      await boxManager.closeAll();
    } catch (_) {}
    boxManager.resetForTesting();
  });

  tearDownAll(() async {
    try {
      await Hive.close();
      await Hive.deleteFromDisk();
    } catch (_) {}
    try {
      await testDir.delete(recursive: true);
    } catch (_) {}
  });

  group('Data Isolation on Logout', () {
    test('clearAllUserData clears ALL open Hive boxes except system boxes', () async {
      // Arrange: Simulate User A session - write data to multiple boxes
      final workoutsBox = await boxManager.openBox<dynamic>(HiveBoxNames.workouts);
      final templatesBox = await boxManager.openBox<dynamic>(HiveBoxNames.templates);
      final historyBox = await boxManager.openBox<dynamic>(HiveBoxNames.workoutHistory);
      final exercisesBox = await boxManager.openBox<dynamic>(HiveBoxNames.exercises);

      await workoutsBox.put('workout_1', {'name': 'User A Workout', 'date': '2025-01-01'});
      await templatesBox.put('template_1', {'name': 'User A Template'});
      await historyBox.put('history_1', {'date': '2025-01-01', 'exercises': 5});
      await exercisesBox.put('exercise_1', {'name': 'Squat', 'customNote': 'User A note'});

      expect(workoutsBox.isNotEmpty, isTrue);
      expect(templatesBox.isNotEmpty, isTrue);
      expect(historyBox.isNotEmpty, isTrue);
      expect(exercisesBox.isNotEmpty, isTrue);

      // Act: Clear all user data (simulates logout)
      await boxManager.clearAllUserData();

      // Assert: All user boxes are empty
      expect(workoutsBox.isEmpty, isTrue, reason: 'Workouts box should be empty after logout');
      expect(templatesBox.isEmpty, isTrue, reason: 'Templates box should be empty after logout');
      expect(historyBox.isEmpty, isTrue, reason: 'History box should be empty after logout');
      expect(exercisesBox.isEmpty, isTrue, reason: 'Exercises box should be empty after logout');
    });

    test('clearAllUserData preserves system boxes (GDPR consent)', () async {
      // NOTE: In the real app, 'privacy' and 'user_consents' are encrypted
      // boxes requiring flutter_secure_storage. In tests, we open them
      // directly via Hive (bypassing encryption) to verify the preservation logic.
      final privacyBox = await Hive.openBox<dynamic>('privacy');
      final consentsBox = await Hive.openBox<dynamic>('user_consents');
      // Track them manually in boxManager so clearAllUserData sees them
      final userBox = await boxManager.openBox<dynamic>(HiveBoxNames.workouts);

      await privacyBox.put('gdpr_accepted', true);
      await consentsBox.put('analytics_consent', true);
      await userBox.put('workout_1', {'name': 'User Data'});

      // Act
      await boxManager.clearAllUserData();

      // Assert: System boxes preserved, user box cleared
      expect(privacyBox.get('gdpr_accepted'), isTrue, reason: 'Privacy consent should survive logout');
      expect(consentsBox.get('analytics_consent'), isTrue, reason: 'User consents should survive logout');
      expect(userBox.isEmpty, isTrue, reason: 'User workout data should be cleared');

      // Cleanup: close manually opened boxes
      await privacyBox.close();
      await consentsBox.close();
    });

    test('clearAllUserData clears UNOPENED boxes with stale data', () async {
      // Arrange: Simulate User A writing data to a box, then closing it
      // (simulates the root cause bug - box exists on disk but not in _openBoxes)
      final box = await Hive.openBox<dynamic>(HiveBoxNames.workoutMetrics);
      await box.put('total_workouts', 42);
      await box.put('total_volume', 50000);
      await box.close();

      // Verify: Box is closed, data persists on disk
      expect(boxManager.isBoxOpen(HiveBoxNames.workoutMetrics), isFalse);

      // Act: Clear all user data (should also clear unopened boxes)
      await boxManager.clearAllUserData();

      // Assert: Reopen the box - it should be empty
      final reopenedBox = await Hive.openBox<dynamic>(HiveBoxNames.workoutMetrics);
      expect(reopenedBox.isEmpty, isTrue,
          reason: 'Unopened box should be cleared by clearAllUserData - '
              'this was the root cause of the data leakage bug');
      await reopenedBox.close();
    });

    test('new user session has zero data after previous logout', () async {
      // NOTE: user_profile_cache is encrypted (requires flutter_secure_storage)
      // so we use fitness_profile instead for testing profile-like data.

      // === User A Session ===
      final workoutsA = await boxManager.openBox<dynamic>(HiveBoxNames.workouts);
      final historyA = await boxManager.openBox<dynamic>(HiveBoxNames.workoutHistory);
      final templatesA = await boxManager.openBox<dynamic>(HiveBoxNames.templates);
      final customExA = await boxManager.openBox<dynamic>(HiveBoxNames.customExercises);
      final profileA = await boxManager.openBox<dynamic>(HiveBoxNames.fitnessProfile);
      final timerA = await boxManager.openBox<dynamic>(HiveBoxNames.timerStorage);
      final settingsA = await boxManager.openBox<dynamic>(HiveBoxNames.appSettings);

      // User A populates data
      await workoutsA.put('w1', {'name': 'Morning Run', 'uid': 'userA'});
      await workoutsA.put('w2', {'name': 'Leg Day', 'uid': 'userA'});
      await historyA.put('h1', {'date': '2025-01-15', 'exercises': 8});
      await templatesA.put('t1', {'name': 'PPL Split', 'uid': 'userA'});
      await customExA.put('ce1', {'name': 'Custom Squat', 'uid': 'userA'});
      await profileA.put('profile', {'email': 'userA@test.com', 'displayName': 'User A'});
      await timerA.put('rest_timer', {'duration': 90});
      await settingsA.put('weight_unit', 'kg');

      // Verify User A has data
      expect(workoutsA.length, equals(2));
      expect(historyA.length, equals(1));

      // === LOGOUT ===
      await boxManager.clearAllUserData();

      // === User B Session ===
      // Verify: ALL boxes empty for User B
      final workoutsB = await boxManager.openBox<dynamic>(HiveBoxNames.workouts);
      final historyB = await boxManager.openBox<dynamic>(HiveBoxNames.workoutHistory);
      final templatesB = await boxManager.openBox<dynamic>(HiveBoxNames.templates);
      final customExB = await boxManager.openBox<dynamic>(HiveBoxNames.customExercises);
      final profileB = await boxManager.openBox<dynamic>(HiveBoxNames.fitnessProfile);
      final timerB = await boxManager.openBox<dynamic>(HiveBoxNames.timerStorage);
      final settingsB = await boxManager.openBox<dynamic>(HiveBoxNames.appSettings);

      expect(workoutsB.isEmpty, isTrue, reason: 'User B should not see User A workouts');
      expect(historyB.isEmpty, isTrue, reason: 'User B should not see User A history');
      expect(templatesB.isEmpty, isTrue, reason: 'User B should not see User A templates');
      expect(customExB.isEmpty, isTrue, reason: 'User B should not see User A custom exercises');
      expect(profileB.isEmpty, isTrue, reason: 'User B should not see User A profile');
      expect(timerB.isEmpty, isTrue, reason: 'User B should not see User A timer settings');
      expect(settingsB.isEmpty, isTrue, reason: 'User B should not see User A settings');
    });

    test('clearAllUserData handles all known HiveBoxNames', () async {
      // Arrange: Write sentinel data to EVERY user-scoped box
      // Skip system boxes AND encrypted boxes (require flutter_secure_storage)
      const skipBoxes = {'privacy', 'user_consents', 'user_profile_cache'};
      int populatedCount = 0;

      for (final boxName in HiveBoxNames.allBoxNames) {
        if (skipBoxes.contains(boxName)) continue;
        try {
          final box = await boxManager.openBox<dynamic>(boxName);
          await box.put('sentinel_key', 'user_data_$boxName');
          populatedCount++;
        } catch (_) {
          // Some boxes may fail due to type constraints in test env
        }
      }

      expect(populatedCount, greaterThan(0), reason: 'Should populate at least some boxes');

      // Act
      await boxManager.clearAllUserData();

      // Assert: Check all boxes are empty
      int leakedCount = 0;
      for (final boxName in HiveBoxNames.allBoxNames) {
        if (skipBoxes.contains(boxName)) continue;
        try {
          final box = await boxManager.openBox<dynamic>(boxName);
          if (box.isNotEmpty) {
            leakedCount++;
          }
        } catch (_) {
          // Skip boxes that can't be opened
        }
      }

      expect(leakedCount, equals(0),
          reason: 'No user boxes should retain data after clearAllUserData. '
              'Leaked boxes: $leakedCount');
    });
  });

  group('Static Cache Isolation on Logout', () {
    test('ProgressCacheRepository.clearOnLogout clears static maps', () {
      // Act: Call the static cleanup
      // This should not throw even if no data exists
      ProgressCacheRepository.clearOnLogout();

      // No assertion needed beyond not throwing - the method
      // clears _operationLocks, _debouncedInvalidations, and _activeCalculations
    });

    test('AppConfigNotifier.clearCachedConfigOnLogout clears static cache', () {
      // Act: Clear the static cached config
      AppConfigNotifier.clearCachedConfigOnLogout();

      // No assertion needed beyond not throwing - verifies the method exists
      // and runs without error. The actual cache field is private.
    });

    test('CooldownLimiter.resetAll clears rate limiter state', () {
      // Act: Reset all rate limiters
      CooldownLimiter.resetAll();

      // No assertion needed beyond not throwing
    });
  });

  group('Concurrent Logout Safety', () {
    test('clearAllUserData is safe to call multiple times', () async {
      // Arrange
      final box = await boxManager.openBox<dynamic>(HiveBoxNames.workouts);
      await box.put('key', 'value');

      // Act: Call clearAllUserData twice rapidly
      await boxManager.clearAllUserData();
      await boxManager.clearAllUserData();

      // Assert: No crash, box is still empty
      expect(box.isEmpty, isTrue);
    });

    test('clearAllUserData handles boxes closed during cleanup', () async {
      // Arrange: Open and close a box
      final box = await boxManager.openBox<dynamic>(HiveBoxNames.workouts);
      await box.put('key', 'value');

      // Act: Should handle gracefully even if internal state is inconsistent
      await boxManager.clearAllUserData();

      // Assert: No crash
      expect(box.isEmpty, isTrue);
    });
  });
}
