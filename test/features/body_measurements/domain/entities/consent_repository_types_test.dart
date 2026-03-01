// Tests for ConsentFailure subtypes and related types from consent_repository.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/consent_repository.dart';

void main() {
  // ---------------------------------------------------------------------------
  // ConsentFailure subtypes
  // ---------------------------------------------------------------------------
  group('ConsentNotFoundFailure', () {
    test('is a ConsentFailure', () {
      const failure = ConsentNotFoundFailure();
      expect(failure, isA<ConsentFailure>());
    });

    test('two instances are identical type', () {
      const a = ConsentNotFoundFailure();
      const b = ConsentNotFoundFailure();
      expect(a, isA<ConsentNotFoundFailure>());
      expect(b, isA<ConsentNotFoundFailure>());
    });
  });

  group('ConsentAlreadyExistsFailure', () {
    test('is a ConsentFailure', () {
      const failure = ConsentAlreadyExistsFailure();
      expect(failure, isA<ConsentFailure>());
    });
  });

  group('InvalidVersionFailure', () {
    test('stores currentVersion and attemptedVersion', () {
      const failure = InvalidVersionFailure(
        currentVersion: 2,
        attemptedVersion: 1,
      );

      expect(failure.currentVersion, 2);
      expect(failure.attemptedVersion, 1);
      expect(failure, isA<ConsentFailure>());
    });

    test('downgrade attempt: attempted < current', () {
      const failure = InvalidVersionFailure(
        currentVersion: 5,
        attemptedVersion: 3,
      );

      expect(failure.currentVersion, greaterThan(failure.attemptedVersion));
    });

    test('same version is also invalid', () {
      const failure = InvalidVersionFailure(
        currentVersion: 1,
        attemptedVersion: 1,
      );

      expect(failure.currentVersion, equals(failure.attemptedVersion));
    });
  });

  group('FirebaseConsentFailure', () {
    test('stores message', () {
      const failure = FirebaseConsentFailure(message: 'Permission denied');
      expect(failure.message, 'Permission denied');
      expect(failure, isA<ConsentFailure>());
    });

    test('stores optional error code', () {
      const failure = FirebaseConsentFailure(
        message: 'PERMISSION_DENIED',
        code: 'permission-denied',
      );

      expect(failure.code, 'permission-denied');
    });

    test('code defaults to null', () {
      const failure = FirebaseConsentFailure(message: 'Error');
      expect(failure.code, isNull);
    });
  });

  group('RateLimitExceededFailure', () {
    test('stores limitPerDay and currentCount', () {
      const failure = RateLimitExceededFailure(
        limitPerDay: 10,
        currentCount: 11,
      );

      expect(failure.limitPerDay, 10);
      expect(failure.currentCount, 11);
      expect(failure, isA<ConsentFailure>());
    });

    test('currentCount exceeds limitPerDay', () {
      const failure = RateLimitExceededFailure(
        limitPerDay: 10,
        currentCount: 15,
      );

      expect(failure.currentCount, greaterThan(failure.limitPerDay));
    });

    test('exactly at limit (currentCount == limitPerDay + 1)', () {
      const failure = RateLimitExceededFailure(
        limitPerDay: 10,
        currentCount: 11,
      );

      expect(failure.currentCount - failure.limitPerDay, 1);
    });
  });

  group('ConsentFailure type hierarchy', () {
    test('all subtypes extend ConsentFailure', () {
      const notFound = ConsentNotFoundFailure();
      const alreadyExists = ConsentAlreadyExistsFailure();
      const invalidVersion = InvalidVersionFailure(
        currentVersion: 2,
        attemptedVersion: 1,
      );
      const firebase = FirebaseConsentFailure(message: 'err');
      const rateLimit = RateLimitExceededFailure(
        limitPerDay: 10,
        currentCount: 11,
      );

      expect(notFound, isA<ConsentFailure>());
      expect(alreadyExists, isA<ConsentFailure>());
      expect(invalidVersion, isA<ConsentFailure>());
      expect(firebase, isA<ConsentFailure>());
      expect(rateLimit, isA<ConsentFailure>());
    });

    test('subtypes are distinct from each other', () {
      const notFound = ConsentNotFoundFailure();
      const alreadyExists = ConsentAlreadyExistsFailure();

      expect(notFound, isNot(isA<ConsentAlreadyExistsFailure>()));
      expect(alreadyExists, isNot(isA<ConsentNotFoundFailure>()));
    });
  });
}
