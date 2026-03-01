/// Failure hierarchy tests - types, equality, code.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

void main() {
  group('Failure types', () {
    test('NetworkFailure', () {
      const f = NetworkFailure('No internet', code: 'NETWORK_001');
      expect(f.message, 'No internet');
      expect(f.code, 'NETWORK_001');
    });

    test('ServerFailure', () {
      const f = ServerFailure('Internal error');
      expect(f.message, 'Internal error');
      expect(f.code, isNull);
    });

    test('TimeoutFailure', () {
      const f = TimeoutFailure('Request timed out');
      expect(f.message, 'Request timed out');
    });

    test('AuthenticationFailure', () {
      const f = AuthenticationFailure('Invalid credentials');
      expect(f.message, 'Invalid credentials');
    });

    test('UnauthorizedFailure', () {
      const f = UnauthorizedFailure('Not allowed');
      expect(f.message, 'Not allowed');
    });

    test('CacheFailure', () {
      const f = CacheFailure('Cache miss');
      expect(f.message, 'Cache miss');
    });

    test('ParseFailure', () {
      const f = ParseFailure('Invalid JSON');
      expect(f.message, 'Invalid JSON');
    });

    test('ValidationFailure', () {
      const f = ValidationFailure('Invalid input');
      expect(f.message, 'Invalid input');
    });

    test('WorkoutNotFoundFailure', () {
      const f = WorkoutNotFoundFailure('Workout not found');
      expect(f.message, 'Workout not found');
    });

    test('ExerciseNotFoundFailure', () {
      const f = ExerciseNotFoundFailure('Exercise not found');
      expect(f.message, 'Exercise not found');
    });

    test('QuotaExceededFailure', () {
      const f = QuotaExceededFailure('Limit reached');
      expect(f.message, 'Limit reached');
    });

    test('PermissionDeniedFailure', () {
      const f = PermissionDeniedFailure('Access denied');
      expect(f.message, 'Access denied');
    });

    test('UnexpectedFailure', () {
      const f = UnexpectedFailure('Unknown error');
      expect(f.message, 'Unknown error');
    });

    test('NotFoundFailure', () {
      const f = NotFoundFailure('Resource not found');
      expect(f.message, 'Resource not found');
    });

    test('RateLimitFailure', () {
      const f = RateLimitFailure('Too many requests', code: 'RATE_429');
      expect(f.message, 'Too many requests');
      expect(f.code, 'RATE_429');
    });

    test('ConflictFailure', () {
      const f = ConflictFailure('Already exists');
      expect(f.message, 'Already exists');
    });

    test('CancelledFailure', () {
      const f = CancelledFailure('Operation cancelled');
      expect(f.message, 'Operation cancelled');
    });
  });

  group('Failure equality', () {
    test('same type and message are equal', () {
      const a = NetworkFailure('error');
      const b = NetworkFailure('error');
      expect(a, equals(b));
    });

    test('same type different message are not equal', () {
      const a = NetworkFailure('error1');
      const b = NetworkFailure('error2');
      expect(a, isNot(equals(b)));
    });

    test('different types same message are not equal', () {
      const a = NetworkFailure('error');
      const b = ServerFailure('error');
      expect(a, isNot(equals(b)));
    });

    test('equality includes code', () {
      const a = NetworkFailure('error', code: '001');
      const b = NetworkFailure('error', code: '002');
      expect(a, isNot(equals(b)));
    });
  });

  group('Type aliases', () {
    test('QuotaFailure is QuotaExceededFailure', () {
      const f = QuotaFailure('limit');
      expect(f, isA<QuotaExceededFailure>());
    });

    test('PermissionFailure is PermissionDeniedFailure', () {
      const f = PermissionFailure('denied');
      expect(f, isA<PermissionDeniedFailure>());
    });
  });
}
