/// Firebase Error Mapper Mixin
///
/// Provides standardized error handling for Firebase operations.
/// Maps Firebase exceptions to domain Failure types.
///
/// ## Usage
/// ```dart
/// class MyRepository with FirebaseErrorMapperMixin {
///   Future<Either<Failure, Data>> getData() async {
///     return handleFirebaseOperation(() async {
///       final doc = await firestore.doc('items/1').get();
///       return Data.fromJson(doc.data()!);
///     });
///   }
/// }
/// ```
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

/// Mixin providing standardized Firebase error handling
mixin FirebaseErrorMapperMixin {
  /// Execute a Firebase operation and map errors to Failures
  ///
  /// [operation] - The async operation to execute
  /// [operationName] - Name for debugging/logging
  ///
  /// Returns [Right] with result on success, [Left] with [Failure] on error
  Future<Either<Failure, T>> handleFirebaseOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      final result = await operation();
      return Right(result);
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException first (it's a subtype of FirebaseException)
      final failure = mapFirebaseAuthException(e, operationName: operationName);
      if (kDebugMode) {
        debugPrint('❌ [FirebaseAuth] ${operationName ?? "Operation"}: ${e.message}');
      }
      return Left(failure);
    } on FirebaseException catch (e) {
      final failure = mapFirebaseException(e, operationName: operationName);
      if (kDebugMode) {
        debugPrint('❌ [Firebase] ${operationName ?? "Operation"}: ${e.message}');
      }
      return Left(failure);
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('⏱️ [Timeout] ${operationName ?? "Operation"}: $e');
      }
      return Left(
        NetworkFailure(
          'Operation timed out: ${e.message}',
          code: 'TIMEOUT',
        ),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [Unexpected] ${operationName ?? "Operation"}: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      return Left(
        UnexpectedFailure(
          'Unexpected error: $e',
          code: 'UNKNOWN_ERROR',
        ),
      );
    }
  }

  /// Execute a Firebase operation that returns void
  Future<Either<Failure, Unit>> handleFirebaseVoidOperation(
    Future<void> Function() operation, {
    String? operationName,
  }) async {
    final result = await handleFirebaseOperation(
      () async {
        await operation();
        return unit;
      },
      operationName: operationName,
    );
    return result;
  }

  /// Map Firebase exception to domain Failure
  Failure mapFirebaseException(
    FirebaseException e, {
    String? operationName,
  }) {
    final prefix = operationName != null ? '$operationName: ' : '';

    switch (e.code) {
      // Permission errors
      case 'permission-denied':
      case 'PERMISSION_DENIED':
        return PermissionFailure(
          '${prefix}Permission denied: ${e.message}',
          code: e.code,
        );

      // Not found errors
      case 'not-found':
      case 'NOT_FOUND':
        return NotFoundFailure(
          '${prefix}Resource not found: ${e.message}',
          code: e.code,
        );

      // Network/availability errors
      case 'unavailable':
      case 'UNAVAILABLE':
        return NetworkFailure(
          '${prefix}Service unavailable: ${e.message}',
          code: e.code,
        );

      // Rate limiting
      case 'resource-exhausted':
      case 'RESOURCE_EXHAUSTED':
        return RateLimitFailure(
          '${prefix}Rate limit exceeded: ${e.message}',
          code: e.code,
        );

      // Quota exceeded
      case 'quota-exceeded':
        return QuotaFailure(
          '${prefix}Quota exceeded: ${e.message}',
          code: e.code,
        );

      // Invalid argument
      case 'invalid-argument':
      case 'INVALID_ARGUMENT':
        return ValidationFailure(
          '${prefix}Invalid argument: ${e.message}',
          code: e.code,
        );

      // Already exists
      case 'already-exists':
      case 'ALREADY_EXISTS':
        return ConflictFailure(
          '${prefix}Resource already exists: ${e.message}',
          code: e.code,
        );

      // Cancelled
      case 'cancelled':
      case 'CANCELLED':
        return CancelledFailure(
          '${prefix}Operation cancelled: ${e.message}',
          code: e.code,
        );

      // Deadline exceeded
      case 'deadline-exceeded':
      case 'DEADLINE_EXCEEDED':
        return NetworkFailure(
          '${prefix}Operation timed out: ${e.message}',
          code: e.code,
        );

      // Unauthenticated
      case 'unauthenticated':
      case 'UNAUTHENTICATED':
        return AuthenticationFailure(
          '${prefix}Authentication required: ${e.message}',
          code: e.code,
        );

      // Default server failure
      default:
        return ServerFailure(
          '${prefix}Firebase error: ${e.message}',
          code: e.code,
        );
    }
  }

  /// Map Firebase Auth exception to domain Failure
  Failure mapFirebaseAuthException(
    FirebaseAuthException e, {
    String? operationName,
  }) {
    final prefix = operationName != null ? '$operationName: ' : '';

    switch (e.code) {
      case 'user-not-found':
        return NotFoundFailure(
          '${prefix}User not found',
          code: e.code,
        );

      case 'wrong-password':
        return AuthenticationFailure(
          '${prefix}Invalid credentials',
          code: e.code,
        );

      case 'email-already-in-use':
        return ConflictFailure(
          '${prefix}Email already in use',
          code: e.code,
        );

      case 'weak-password':
        return ValidationFailure(
          '${prefix}Password is too weak',
          code: e.code,
        );

      case 'invalid-email':
        return ValidationFailure(
          '${prefix}Invalid email format',
          code: e.code,
        );

      case 'user-disabled':
        return AuthenticationFailure(
          '${prefix}User account is disabled',
          code: e.code,
        );

      case 'too-many-requests':
        return RateLimitFailure(
          '${prefix}Too many requests, try again later',
          code: e.code,
        );

      case 'network-request-failed':
        return NetworkFailure(
          '${prefix}Network error',
          code: e.code,
        );

      default:
        return AuthenticationFailure(
          '${prefix}Authentication error: ${e.message}',
          code: e.code,
        );
    }
  }

  /// Check if error is recoverable (can retry)
  bool isRecoverableError(Failure failure) {
    return failure is NetworkFailure ||
        failure is RateLimitFailure ||
        failure.code == 'TIMEOUT';
  }

  /// Check if error requires re-authentication
  bool requiresReauth(Failure failure) {
    return failure is AuthenticationFailure ||
        failure.code == 'unauthenticated' ||
        failure.code == 'UNAUTHENTICATED';
  }
}
