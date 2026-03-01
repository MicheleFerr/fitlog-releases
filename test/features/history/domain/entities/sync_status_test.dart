import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/sync_status.dart';

void main() {
  group('SyncStatus', () {
    test('ha tutti i valori attesi', () {
      expect(SyncStatus.values.length, equals(6));
      expect(SyncStatus.values, contains(SyncStatus.notSynced));
      expect(SyncStatus.values, contains(SyncStatus.initialSyncing));
      expect(SyncStatus.values, contains(SyncStatus.syncing));
      expect(SyncStatus.values, contains(SyncStatus.synced));
      expect(SyncStatus.values, contains(SyncStatus.needsSync));
      expect(SyncStatus.values, contains(SyncStatus.error));
    });

    test('i nomi degli enum sono corretti', () {
      expect(SyncStatus.notSynced.name, equals('notSynced'));
      expect(SyncStatus.initialSyncing.name, equals('initialSyncing'));
      expect(SyncStatus.syncing.name, equals('syncing'));
      expect(SyncStatus.synced.name, equals('synced'));
      expect(SyncStatus.needsSync.name, equals('needsSync'));
      expect(SyncStatus.error.name, equals('error'));
    });

    test('i valori possono essere confrontati per uguaglianza', () {
      const status1 = SyncStatus.synced;
      const status2 = SyncStatus.synced;
      expect(status1, equals(status2));
    });

    test('valori diversi non sono uguali', () {
      expect(SyncStatus.synced, isNot(equals(SyncStatus.error)));
      expect(SyncStatus.notSynced, isNot(equals(SyncStatus.syncing)));
    });

    test('può essere usato in switch statement', () {
      String describe(SyncStatus s) {
        switch (s) {
          case SyncStatus.notSynced:
            return 'not_synced';
          case SyncStatus.initialSyncing:
            return 'initial_syncing';
          case SyncStatus.syncing:
            return 'syncing';
          case SyncStatus.synced:
            return 'synced';
          case SyncStatus.needsSync:
            return 'needs_sync';
          case SyncStatus.error:
            return 'error';
        }
      }

      expect(describe(SyncStatus.synced), equals('synced'));
      expect(describe(SyncStatus.error), equals('error'));
      expect(describe(SyncStatus.notSynced), equals('not_synced'));
    });
  });
}
