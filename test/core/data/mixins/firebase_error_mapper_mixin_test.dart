/// Tests for FirebaseErrorMapperMixin
///
/// Tests the mixin by composing a concrete test class that uses it,
/// covering all error mappings, recovery checks, and reauth requirements.
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// ---------------------------------------------------------------------------
// Test subject — a minimal class that mixes in FirebaseErrorMapperMixin
// ---------------------------------------------------------------------------

class _TestRepository with FirebaseErrorMapperMixin {
  /// Expose handleFirebaseOperation for testing
  Future<Either<Failure, T>> run<T>(
    Future<T> Function() op, {
    String? operationName,
  }) =>
      handleFirebaseOperation(op, operationName: operationName);

  /// Expose handleFirebaseVoidOperation for testing
  Future<Either<Failure, Unit>> runVoid(
    Future<void> Function() op, {
    String? operationName,
  }) =>
      handleFirebaseVoidOperation(op, operationName: operationName);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

FirebaseException _firebaseException(String code, {String? message}) =>
    FirebaseException(plugin: 'test', code: code, message: message ?? 'msg-$code');

FirebaseAuthException _authException(String code, {String? message}) =>
    FirebaseAuthException(code: code, message: message ?? 'auth-$code');

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _TestRepository repo;

  setUp(() {
    repo = _TestRepository();
  });

  // =========================================================================
  // handleFirebaseOperation — success path
  // =========================================================================

  group('handleFirebaseOperation - success', () {
    test('returns Right with result when operation succeeds', () async {
      final result = await repo.run(() async => 42);
      expect(result.isRight(), isTrue);
      expect(result.getOrElse((_) => 0), 42);
    });

    test('works with string results', () async {
      final result = await repo.run(() async => 'hello');
      expect(result.getOrElse((_) => ''), 'hello');
    });

    test('works with null-like optional values (nullable int)', () async {
      final result = await repo.run<int?>(() async => null);
      expect(result.isRight(), isTrue);
    });
  });

  // =========================================================================
  // handleFirebaseOperation — FirebaseException mapping
  // =========================================================================

  group('handleFirebaseOperation - FirebaseException mapping', () {
    Future<Either<Failure, int>> runWithCode(String code) => repo.run<int>(
          () async => throw _firebaseException(code),
        );

    test('permission-denied → PermissionFailure', () async {
      final result = await runWithCode('permission-denied');
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<PermissionDeniedFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('PERMISSION_DENIED (uppercase) → PermissionFailure', () async {
      final result = await runWithCode('PERMISSION_DENIED');
      result.fold(
        (f) => expect(f, isA<PermissionDeniedFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('not-found → NotFoundFailure', () async {
      final result = await runWithCode('not-found');
      result.fold(
        (f) => expect(f, isA<NotFoundFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('NOT_FOUND → NotFoundFailure', () async {
      final result = await runWithCode('NOT_FOUND');
      result.fold(
        (f) => expect(f, isA<NotFoundFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('unavailable → NetworkFailure', () async {
      final result = await runWithCode('unavailable');
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('UNAVAILABLE → NetworkFailure', () async {
      final result = await runWithCode('UNAVAILABLE');
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('resource-exhausted → RateLimitFailure', () async {
      final result = await runWithCode('resource-exhausted');
      result.fold(
        (f) => expect(f, isA<RateLimitFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('RESOURCE_EXHAUSTED → RateLimitFailure', () async {
      final result = await runWithCode('RESOURCE_EXHAUSTED');
      result.fold(
        (f) => expect(f, isA<RateLimitFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('quota-exceeded → QuotaExceededFailure', () async {
      final result = await runWithCode('quota-exceeded');
      result.fold(
        (f) => expect(f, isA<QuotaExceededFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('invalid-argument → ValidationFailure', () async {
      final result = await runWithCode('invalid-argument');
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('INVALID_ARGUMENT → ValidationFailure', () async {
      final result = await runWithCode('INVALID_ARGUMENT');
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('already-exists → ConflictFailure', () async {
      final result = await runWithCode('already-exists');
      result.fold(
        (f) => expect(f, isA<ConflictFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('ALREADY_EXISTS → ConflictFailure', () async {
      final result = await runWithCode('ALREADY_EXISTS');
      result.fold(
        (f) => expect(f, isA<ConflictFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('cancelled → CancelledFailure', () async {
      final result = await runWithCode('cancelled');
      result.fold(
        (f) => expect(f, isA<CancelledFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('CANCELLED → CancelledFailure', () async {
      final result = await runWithCode('CANCELLED');
      result.fold(
        (f) => expect(f, isA<CancelledFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('deadline-exceeded → NetworkFailure', () async {
      final result = await runWithCode('deadline-exceeded');
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('DEADLINE_EXCEEDED → NetworkFailure', () async {
      final result = await runWithCode('DEADLINE_EXCEEDED');
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('unauthenticated → AuthenticationFailure', () async {
      final result = await runWithCode('unauthenticated');
      result.fold(
        (f) => expect(f, isA<AuthenticationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('UNAUTHENTICATED → AuthenticationFailure', () async {
      final result = await runWithCode('UNAUTHENTICATED');
      result.fold(
        (f) => expect(f, isA<AuthenticationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('unknown code → ServerFailure', () async {
      final result = await runWithCode('some-unknown-error');
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('failure code is preserved', () async {
      final result = await runWithCode('permission-denied');
      result.fold(
        (f) => expect(f.code, 'permission-denied'),
        (_) => fail('expected Left'),
      );
    });

    test('operationName is included in failure message', () async {
      final result = await repo.run<int>(
        () async => throw _firebaseException('not-found', message: 'doc missing'),
        operationName: 'fetchUser',
      );
      result.fold(
        (f) => expect(f.message, contains('fetchUser')),
        (_) => fail('expected Left'),
      );
    });

    test('no operationName — message has no empty prefix', () async {
      final result = await repo.run<int>(
        () async => throw _firebaseException('not-found', message: 'doc missing'),
      );
      result.fold(
        (f) => expect(f.message, isNot(startsWith(':'))),
        (_) => fail('expected Left'),
      );
    });
  });

  // =========================================================================
  // handleFirebaseOperation — FirebaseAuthException mapping
  // =========================================================================

  group('handleFirebaseOperation - FirebaseAuthException mapping', () {
    Future<Either<Failure, int>> runWithAuthCode(String code) => repo.run<int>(
          () async => throw _authException(code),
        );

    test('user-not-found → NotFoundFailure', () async {
      final result = await runWithAuthCode('user-not-found');
      result.fold(
        (f) => expect(f, isA<NotFoundFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('wrong-password → AuthenticationFailure', () async {
      final result = await runWithAuthCode('wrong-password');
      result.fold(
        (f) => expect(f, isA<AuthenticationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('email-already-in-use → ConflictFailure', () async {
      final result = await runWithAuthCode('email-already-in-use');
      result.fold(
        (f) => expect(f, isA<ConflictFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('weak-password → ValidationFailure', () async {
      final result = await runWithAuthCode('weak-password');
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('invalid-email → ValidationFailure', () async {
      final result = await runWithAuthCode('invalid-email');
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('user-disabled → AuthenticationFailure', () async {
      final result = await runWithAuthCode('user-disabled');
      result.fold(
        (f) => expect(f, isA<AuthenticationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('too-many-requests → RateLimitFailure', () async {
      final result = await runWithAuthCode('too-many-requests');
      result.fold(
        (f) => expect(f, isA<RateLimitFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('network-request-failed → NetworkFailure', () async {
      final result = await runWithAuthCode('network-request-failed');
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('unknown auth code → AuthenticationFailure (default)', () async {
      final result = await runWithAuthCode('some-unknown-auth-error');
      result.fold(
        (f) => expect(f, isA<AuthenticationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('FirebaseAuthException is handled before generic FirebaseException', () async {
      // FirebaseAuthException is a subtype of FirebaseException.
      // The mixin must catch it first so it maps to AuthenticationFailure,
      // not ServerFailure.
      final result = await runWithAuthCode('user-disabled');
      result.fold(
        (f) => expect(f, isA<AuthenticationFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('auth code preserved on failure', () async {
      final result = await runWithAuthCode('weak-password');
      result.fold(
        (f) => expect(f.code, 'weak-password'),
        (_) => fail('expected Left'),
      );
    });

    test('operationName included in auth failure message', () async {
      final result = await repo.run<int>(
        () async => throw _authException('user-not-found'),
        operationName: 'signIn',
      );
      result.fold(
        (f) => expect(f.message, contains('signIn')),
        (_) => fail('expected Left'),
      );
    });
  });

  // =========================================================================
  // handleFirebaseOperation — TimeoutException
  // =========================================================================

  group('handleFirebaseOperation - TimeoutException', () {
    test('TimeoutException → NetworkFailure with TIMEOUT code', () async {
      final result = await repo.run<int>(
        () async => throw TimeoutException('took too long'),
      );
      result.fold(
        (f) {
          expect(f, isA<NetworkFailure>());
          expect(f.code, 'TIMEOUT');
        },
        (_) => fail('expected Left'),
      );
    });

    test('TimeoutException message is included', () async {
      final result = await repo.run<int>(
        () async => throw TimeoutException('custom timeout message'),
      );
      result.fold(
        (f) => expect(f.message, contains('custom timeout message')),
        (_) => fail('expected Left'),
      );
    });

    test('TimeoutException with null message does not throw', () async {
      final result = await repo.run<int>(
        () async => throw TimeoutException(null),
      );
      expect(result.isLeft(), isTrue);
    });
  });

  // =========================================================================
  // handleFirebaseOperation — unexpected errors
  // =========================================================================

  group('handleFirebaseOperation - unexpected errors', () {
    test('generic Exception → UnexpectedFailure', () async {
      final result = await repo.run<int>(
        () async => throw Exception('something went wrong'),
      );
      result.fold(
        (f) {
          expect(f, isA<UnexpectedFailure>());
          expect(f.code, 'UNKNOWN_ERROR');
        },
        (_) => fail('expected Left'),
      );
    });

    test('Error subtype → UnexpectedFailure', () async {
      final result = await repo.run<int>(
        () async => throw StateError('bad state'),
      );
      result.fold(
        (f) => expect(f, isA<UnexpectedFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  // =========================================================================
  // handleFirebaseVoidOperation
  // =========================================================================

  group('handleFirebaseVoidOperation', () {
    test('returns Right(unit) when operation succeeds', () async {
      final result = await repo.runVoid(() async {});
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (u) => expect(u, unit),
      );
    });

    test('maps FirebaseException to Left on failure', () async {
      final result = await repo.runVoid(
        () async => throw _firebaseException('permission-denied'),
      );
      result.fold(
        (f) => expect(f, isA<PermissionDeniedFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('maps unexpected exception to Left on failure', () async {
      final result = await repo.runVoid(
        () async => throw Exception('boom'),
      );
      result.fold(
        (f) => expect(f, isA<UnexpectedFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('operationName forwarded to inner handler', () async {
      final result = await repo.runVoid(
        () async => throw _firebaseException('not-found', message: 'missing'),
        operationName: 'deleteDoc',
      );
      result.fold(
        (f) => expect(f.message, contains('deleteDoc')),
        (_) => fail('expected Left'),
      );
    });
  });

  // =========================================================================
  // mapFirebaseException (direct method tests)
  // =========================================================================

  group('mapFirebaseException - direct', () {
    test('returns correct type for each known code', () {
      final cases = <String, Type>{
        'permission-denied': PermissionDeniedFailure,
        'PERMISSION_DENIED': PermissionDeniedFailure,
        'not-found': NotFoundFailure,
        'NOT_FOUND': NotFoundFailure,
        'unavailable': NetworkFailure,
        'UNAVAILABLE': NetworkFailure,
        'resource-exhausted': RateLimitFailure,
        'RESOURCE_EXHAUSTED': RateLimitFailure,
        'quota-exceeded': QuotaExceededFailure,
        'invalid-argument': ValidationFailure,
        'INVALID_ARGUMENT': ValidationFailure,
        'already-exists': ConflictFailure,
        'ALREADY_EXISTS': ConflictFailure,
        'cancelled': CancelledFailure,
        'CANCELLED': CancelledFailure,
        'deadline-exceeded': NetworkFailure,
        'DEADLINE_EXCEEDED': NetworkFailure,
        'unauthenticated': AuthenticationFailure,
        'UNAUTHENTICATED': AuthenticationFailure,
        'unknown-code': ServerFailure,
      };

      for (final entry in cases.entries) {
        final failure = repo.mapFirebaseException(
          _firebaseException(entry.key),
        );
        expect(
          failure.runtimeType,
          entry.value,
          reason: 'code="${entry.key}" should map to ${entry.value}',
        );
      }
    });
  });

  // =========================================================================
  // mapFirebaseAuthException (direct method tests)
  // =========================================================================

  group('mapFirebaseAuthException - direct', () {
    test('returns correct type for each known code', () {
      final cases = <String, Type>{
        'user-not-found': NotFoundFailure,
        'wrong-password': AuthenticationFailure,
        'email-already-in-use': ConflictFailure,
        'weak-password': ValidationFailure,
        'invalid-email': ValidationFailure,
        'user-disabled': AuthenticationFailure,
        'too-many-requests': RateLimitFailure,
        'network-request-failed': NetworkFailure,
        'other-unknown': AuthenticationFailure,
      };

      for (final entry in cases.entries) {
        final failure = repo.mapFirebaseAuthException(
          _authException(entry.key),
        );
        expect(
          failure.runtimeType,
          entry.value,
          reason: 'code="${entry.key}" should map to ${entry.value}',
        );
      }
    });
  });

  // =========================================================================
  // isRecoverableError
  // =========================================================================

  group('isRecoverableError', () {
    test('NetworkFailure is recoverable', () {
      expect(repo.isRecoverableError(const NetworkFailure('net')), isTrue);
    });

    test('RateLimitFailure is recoverable', () {
      expect(repo.isRecoverableError(const RateLimitFailure('rate')), isTrue);
    });

    test('failure with TIMEOUT code is recoverable', () {
      expect(
        repo.isRecoverableError(const NetworkFailure('timeout', code: 'TIMEOUT')),
        isTrue,
      );
    });

    test('ServerFailure without TIMEOUT code is NOT recoverable', () {
      expect(repo.isRecoverableError(const ServerFailure('server')), isFalse);
    });

    test('AuthenticationFailure is NOT recoverable', () {
      expect(repo.isRecoverableError(const AuthenticationFailure('auth')), isFalse);
    });

    test('ValidationFailure is NOT recoverable', () {
      expect(repo.isRecoverableError(const ValidationFailure('val')), isFalse);
    });

    test('UnexpectedFailure is NOT recoverable', () {
      expect(repo.isRecoverableError(const UnexpectedFailure('unexpected')), isFalse);
    });
  });

  // =========================================================================
  // requiresReauth
  // =========================================================================

  group('requiresReauth', () {
    test('AuthenticationFailure requires reauth', () {
      expect(repo.requiresReauth(const AuthenticationFailure('auth')), isTrue);
    });

    test('failure with unauthenticated code requires reauth', () {
      expect(
        repo.requiresReauth(const ServerFailure('s', code: 'unauthenticated')),
        isTrue,
      );
    });

    test('failure with UNAUTHENTICATED code requires reauth', () {
      expect(
        repo.requiresReauth(const ServerFailure('s', code: 'UNAUTHENTICATED')),
        isTrue,
      );
    });

    test('NetworkFailure does NOT require reauth', () {
      expect(repo.requiresReauth(const NetworkFailure('net')), isFalse);
    });

    test('RateLimitFailure does NOT require reauth', () {
      expect(repo.requiresReauth(const RateLimitFailure('rate')), isFalse);
    });

    test('ValidationFailure does NOT require reauth', () {
      expect(repo.requiresReauth(const ValidationFailure('val')), isFalse);
    });

    test('NotFoundFailure does NOT require reauth', () {
      expect(repo.requiresReauth(const NotFoundFailure('nf')), isFalse);
    });
  });
}
