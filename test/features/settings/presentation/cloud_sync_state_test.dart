import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/providers/cloud_sync_provider.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════
  // CloudSyncState data class
  // ═══════════════════════════════════════════════════════════════
  group('CloudSyncState', () {
    test('default constructor has sensible defaults', () {
      const state = CloudSyncState();
      expect(state.isSyncing, isFalse);
      expect(state.lastSyncTime, isNull);
      expect(state.progress, isNull);
      expect(state.errors, isEmpty);
      expect(state.lastSyncSummary, isNull);
    });

    test('custom constructor stores values', () {
      final progress = SyncProgress(
        currentItem: 'Syncing...',
        totalItems: 100,
        syncedItems: 50,
      );
      final state = CloudSyncState(
        isSyncing: true,
        lastSyncTime: '2026-03-01T10:00:00',
        progress: progress,
        errors: ['error1'],
      );

      expect(state.isSyncing, isTrue);
      expect(state.lastSyncTime, '2026-03-01T10:00:00');
      expect(state.progress, isNotNull);
      expect(state.errors, ['error1']);
    });

    group('copyWith', () {
      test('copies all fields when specified', () {
        const original = CloudSyncState();
        final copy = original.copyWith(
          isSyncing: true,
          lastSyncTime: '2026-03-01',
          errors: ['err'],
        );

        expect(copy.isSyncing, isTrue);
        expect(copy.lastSyncTime, '2026-03-01');
        expect(copy.errors, ['err']);
      });

      test('preserves unchanged fields', () {
        const original = CloudSyncState(
          isSyncing: true,
          lastSyncTime: '2026-03-01',
          errors: ['err'],
        );

        final copy = original.copyWith();

        expect(copy.isSyncing, isTrue);
        expect(copy.lastSyncTime, '2026-03-01');
        expect(copy.errors, ['err']);
      });

      test('can reset errors to empty', () {
        const original = CloudSyncState(errors: ['err1', 'err2']);
        final copy = original.copyWith(errors: []);

        expect(copy.errors, isEmpty);
      });

      test('does not mutate original', () {
        const original = CloudSyncState(isSyncing: false);
        original.copyWith(isSyncing: true);

        expect(original.isSyncing, isFalse);
      });

      test('updating progress preserves other fields', () {
        const original = CloudSyncState(
          isSyncing: true,
          lastSyncTime: '2026-01-01',
        );
        final progress = SyncProgress(
          currentItem: 'workouts',
          totalItems: 10,
          syncedItems: 5,
        );
        final copy = original.copyWith(progress: progress);

        expect(copy.isSyncing, isTrue);
        expect(copy.lastSyncTime, '2026-01-01');
        expect(copy.progress?.currentItem, 'workouts');
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // SyncProgress
  // ═══════════════════════════════════════════════════════════════
  group('SyncProgress', () {
    test('percentage calculated from syncedItems/totalItems', () {
      final progress = SyncProgress(
        currentItem: 'workouts',
        totalItems: 100,
        syncedItems: 50,
      );
      expect(progress.percentage, 50.0);
    });

    test('percentage = 100 when all synced', () {
      final progress = SyncProgress(
        currentItem: 'done',
        totalItems: 50,
        syncedItems: 50,
      );
      expect(progress.percentage, 100.0);
    });

    test('percentage = 0 when totalItems = 0', () {
      final progress = SyncProgress(
        currentItem: 'idle',
        totalItems: 0,
        syncedItems: 0,
      );
      expect(progress.percentage, 0.0);
    });

    test('percentage = 0 when syncedItems = 0', () {
      final progress = SyncProgress(
        currentItem: 'starting',
        totalItems: 100,
        syncedItems: 0,
      );
      expect(progress.percentage, 0.0);
    });

    test('stores currentItem', () {
      final progress = SyncProgress(
        currentItem: 'Syncing workouts...',
        totalItems: 10,
        syncedItems: 3,
      );
      expect(progress.currentItem, 'Syncing workouts...');
    });

    test('25% progress', () {
      final progress = SyncProgress(
        currentItem: 'templates',
        totalItems: 100,
        syncedItems: 25,
      );
      expect(progress.percentage, 25.0);
    });

    test('partial sync: 1 of 3', () {
      final progress = SyncProgress(
        currentItem: 'item',
        totalItems: 3,
        syncedItems: 1,
      );
      expect(progress.percentage, closeTo(33.33, 0.01));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // SyncSummary
  // ═══════════════════════════════════════════════════════════════
  group('SyncSummary', () {
    SyncSummary buildSummary({
      int workoutsSynced = 10,
      int templatesSynced = 5,
      int exercisesSynced = 3,
      int settingsSynced = 1,
      int personalRecordsSynced = 7,
      bool success = true,
    }) {
      return SyncSummary(
        workoutsSynced: workoutsSynced,
        templatesSynced: templatesSynced,
        exercisesSynced: exercisesSynced,
        settingsSynced: settingsSynced,
        personalRecordsSynced: personalRecordsSynced,
        syncedAt: DateTime(2026, 3, 1),
        success: success,
      );
    }

    test('totalItemsSynced sums all categories', () {
      final summary = buildSummary(
        workoutsSynced: 10,
        templatesSynced: 5,
        exercisesSynced: 3,
        settingsSynced: 1,
        personalRecordsSynced: 7,
      );
      // 10 + 5 + 3 + 1 + 7 = 26
      expect(summary.totalItemsSynced, 26);
    });

    test('totalItemsSynced = 0 when all zeros', () {
      final summary = buildSummary(
        workoutsSynced: 0,
        templatesSynced: 0,
        exercisesSynced: 0,
        settingsSynced: 0,
        personalRecordsSynced: 0,
      );
      expect(summary.totalItemsSynced, 0);
    });

    test('stores success = true', () {
      final summary = buildSummary(success: true);
      expect(summary.success, isTrue);
    });

    test('stores success = false on failure', () {
      final summary = buildSummary(success: false);
      expect(summary.success, isFalse);
    });

    test('stores syncedAt date', () {
      final summary = buildSummary();
      expect(summary.syncedAt, DateTime(2026, 3, 1));
    });

    test('stores individual counts', () {
      final summary = buildSummary(
        workoutsSynced: 42,
        templatesSynced: 7,
      );
      expect(summary.workoutsSynced, 42);
      expect(summary.templatesSynced, 7);
    });

    test('totalItemsSynced with large values', () {
      final summary = buildSummary(
        workoutsSynced: 500,
        templatesSynced: 100,
        exercisesSynced: 200,
        settingsSynced: 1,
        personalRecordsSynced: 150,
      );
      expect(summary.totalItemsSynced, 951);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // getSyncStatusMessage – pure logic
  // ═══════════════════════════════════════════════════════════════
  group('getSyncStatusMessage logic', () {
    String buildStatusMessage({
      bool isSyncing = false,
      String? currentItem,
      String? lastSyncTime,
      DateTime? now,
    }) {
      final effectiveNow = now ?? DateTime(2026, 3, 1, 12, 0);

      if (isSyncing) {
        return currentItem ?? 'Syncing...';
      }

      if (lastSyncTime != null) {
        final lastSync = DateTime.parse(lastSyncTime);
        final diff = effectiveNow.difference(lastSync);

        if (diff.inMinutes < 1) return 'Synced just now';
        if (diff.inHours < 1) return 'Synced ${diff.inMinutes} minutes ago';
        if (diff.inDays < 1) return 'Synced ${diff.inHours} hours ago';
        return 'Synced ${diff.inDays} days ago';
      }

      return 'Never synced';
    }

    test('syncing with progress item', () {
      expect(
        buildStatusMessage(isSyncing: true, currentItem: 'Syncing workouts...'),
        'Syncing workouts...',
      );
    });

    test('syncing without current item defaults to Syncing...', () {
      expect(buildStatusMessage(isSyncing: true), 'Syncing...');
    });

    test('never synced when no lastSyncTime', () {
      expect(buildStatusMessage(), 'Never synced');
    });

    test('synced just now (< 1 minute)', () {
      final now = DateTime(2026, 3, 1, 12, 0, 30);
      final lastSync = DateTime(2026, 3, 1, 12, 0, 0).toIso8601String();
      expect(
        buildStatusMessage(lastSyncTime: lastSync, now: now),
        'Synced just now',
      );
    });

    test('synced X minutes ago (< 1 hour)', () {
      final now = DateTime(2026, 3, 1, 12, 30);
      final lastSync = DateTime(2026, 3, 1, 12, 0).toIso8601String();
      expect(
        buildStatusMessage(lastSyncTime: lastSync, now: now),
        'Synced 30 minutes ago',
      );
    });

    test('synced X hours ago (< 1 day)', () {
      final now = DateTime(2026, 3, 1, 15, 0);
      final lastSync = DateTime(2026, 3, 1, 12, 0).toIso8601String();
      expect(
        buildStatusMessage(lastSyncTime: lastSync, now: now),
        'Synced 3 hours ago',
      );
    });

    test('synced X days ago', () {
      final now = DateTime(2026, 3, 5, 12, 0);
      final lastSync = DateTime(2026, 3, 1, 12, 0).toIso8601String();
      expect(
        buildStatusMessage(lastSyncTime: lastSync, now: now),
        'Synced 4 days ago',
      );
    });
  });
}
