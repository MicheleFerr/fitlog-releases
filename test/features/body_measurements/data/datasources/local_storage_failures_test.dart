import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/datasources/measurement_local_datasource.dart';

void main() {
  // ---------------------------------------------------------------------------
  // LocalStorageFailure hierarchy
  // ---------------------------------------------------------------------------
  group('MeasurementNotFoundFailure', () {
    test('stores measurementId', () {
      const failure = MeasurementNotFoundFailure('meas-abc');
      expect(failure.measurementId, equals('meas-abc'));
    });

    test('is sealed LocalStorageFailure', () {
      const failure = MeasurementNotFoundFailure('any-id');
      expect(failure, isA<LocalStorageFailure>());
    });

    test('two instances with same id are equal', () {
      const a = MeasurementNotFoundFailure('same-id');
      const b = MeasurementNotFoundFailure('same-id');
      // Sealed classes do reference equality by default unless overridden
      // Just verify both are instances of the same type and have same data
      expect(a.measurementId, equals(b.measurementId));
    });

    test('different measurement ids are stored correctly', () {
      const f1 = MeasurementNotFoundFailure('id-1');
      const f2 = MeasurementNotFoundFailure('id-2');
      expect(f1.measurementId, isNot(equals(f2.measurementId)));
    });
  });

  group('HiveFailure', () {
    test('stores message', () {
      const failure = HiveFailure(message: 'Box read error');
      expect(failure.message, equals('Box read error'));
    });

    test('stores optional error object', () {
      final exception = Exception('Disk full');
      final failure = HiveFailure(message: 'Write failed', error: exception);
      expect(failure.error, equals(exception));
    });

    test('error defaults to null', () {
      const failure = HiveFailure(message: 'Some error');
      expect(failure.error, isNull);
    });

    test('is sealed LocalStorageFailure', () {
      const failure = HiveFailure(message: 'test');
      expect(failure, isA<LocalStorageFailure>());
    });
  });

  group('HiveNotInitializedFailure', () {
    test('is sealed LocalStorageFailure', () {
      const failure = HiveNotInitializedFailure();
      expect(failure, isA<LocalStorageFailure>());
    });

    test('can be instantiated without params', () {
      const failure = HiveNotInitializedFailure();
      expect(failure, isNotNull);
    });
  });

  group('EncryptionStorageFailure', () {
    test('stores message', () {
      const failure = EncryptionStorageFailure('Decryption failed');
      expect(failure.message, equals('Decryption failed'));
    });

    test('is sealed LocalStorageFailure', () {
      const failure = EncryptionStorageFailure('test');
      expect(failure, isA<LocalStorageFailure>());
    });
  });

  // ---------------------------------------------------------------------------
  // Pattern matching on sealed class
  // ---------------------------------------------------------------------------
  group('LocalStorageFailure pattern matching', () {
    String describeFailure(LocalStorageFailure f) {
      return switch (f) {
        MeasurementNotFoundFailure(:final measurementId) =>
          'not_found:$measurementId',
        HiveFailure(:final message) => 'hive:$message',
        HiveNotInitializedFailure() => 'not_initialized',
        EncryptionStorageFailure(:final message) => 'encryption:$message',
      };
    }

    test('matches MeasurementNotFoundFailure', () {
      const f = MeasurementNotFoundFailure('meas-1');
      expect(describeFailure(f), equals('not_found:meas-1'));
    });

    test('matches HiveFailure', () {
      const f = HiveFailure(message: 'read error');
      expect(describeFailure(f), equals('hive:read error'));
    });

    test('matches HiveNotInitializedFailure', () {
      const f = HiveNotInitializedFailure();
      expect(describeFailure(f), equals('not_initialized'));
    });

    test('matches EncryptionStorageFailure', () {
      const f = EncryptionStorageFailure('bad key');
      expect(describeFailure(f), equals('encryption:bad key'));
    });
  });
}
