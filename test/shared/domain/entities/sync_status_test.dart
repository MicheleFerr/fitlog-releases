/// SyncStatus entity tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/sync_status.dart';

void main() {
  group('SyncStatus', () {
    test('has 5 values', () {
      expect(SyncStatus.values.length, 5);
      expect(SyncStatus.values, contains(SyncStatus.idle));
      expect(SyncStatus.values, contains(SyncStatus.loading));
      expect(SyncStatus.values, contains(SyncStatus.syncing));
      expect(SyncStatus.values, contains(SyncStatus.success));
      expect(SyncStatus.values, contains(SyncStatus.error));
    });
  });
}
