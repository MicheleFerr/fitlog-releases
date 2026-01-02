/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: shared/domain
/// 🎯 Feature: error_handling
/// 🔧 Type: failure
/// 🌍 Localization: ✅ Error codes for AppLocalizations
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - None (pure domain)
library;

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  
  const Failure(this.message, {this.code});
  final String message;
  final String? code;
  
  @override
  List<Object?> get props => [message, code];
}

// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, {super.code});
}

// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.code});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.code});
}

// Data-related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class ParseFailure extends Failure {
  const ParseFailure(super.message, {super.code});
}

// Business logic failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

class WorkoutNotFoundFailure extends Failure {
  const WorkoutNotFoundFailure(super.message, {super.code});
}

class ExerciseNotFoundFailure extends Failure {
  const ExerciseNotFoundFailure(super.message, {super.code});
}

// Quota/Permission failures
class QuotaExceededFailure extends Failure {
  const QuotaExceededFailure(super.message, {super.code});
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure(super.message, {super.code});
}

// Generic failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.code});
}

// Resource not found (generic)
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

// Rate limiting
class RateLimitFailure extends Failure {
  const RateLimitFailure(super.message, {super.code});
}

// Alias for quota failures
typedef QuotaFailure = QuotaExceededFailure;

// Alias for permission failures
typedef PermissionFailure = PermissionDeniedFailure;

// Conflict (resource already exists)
class ConflictFailure extends Failure {
  const ConflictFailure(super.message, {super.code});
}

// Operation cancelled
class CancelledFailure extends Failure {
  const CancelledFailure(super.message, {super.code});
}