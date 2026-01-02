/// Failure Localization Extension
///
/// Provides localized user-friendly error messages for Failure types.
///
/// **Architecture Rule**: Domain entities cannot depend on presentation layer,
/// so we create this extension in the presentation layer to provide localized
/// error messages using AppLocalizations (which requires BuildContext).
///
/// **Usage**:
/// ```dart
/// final result = await repository.saveWorkout(workout);
/// result.fold(
///   (failure) => showSnackBar(failure.localizedMessage(context)),
///   (_) => showSnackBar(l10n.workoutSaved),
/// );
/// ```
library;

import 'package:flutter/widgets.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Extension for localized Failure messages
extension FailureLocalizationExtension on Failure {
  /// Get localized user-friendly message for the failure
  ///
  /// Maps error codes to localized strings. Falls back to generic
  /// messages when specific translations are not available.
  String localizedMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Try to match by error code first
    if (code != null) {
      final localizedByCode = _getLocalizedByCode(l10n, code!);
      if (localizedByCode != null) return localizedByCode;
    }

    // Fall back to failure type-based messages
    return _getLocalizedByType(l10n);
  }

  /// Map specific error codes to localized strings
  String? _getLocalizedByCode(AppLocalizations l10n, String code) {
    switch (code.toLowerCase()) {
      // Network errors
      case 'unavailable':
      case 'network-request-failed':
        return l10n.errorNetworkConnection;

      // Timeout
      case 'timeout':
      case 'deadline-exceeded':
        return l10n.errorTimeout;

      // Authentication
      case 'unauthenticated':
        return l10n.errorAuthenticationRequired;
      case 'user-not-found':
        return l10n.errorUserNotFound;
      case 'wrong-password':
        return l10n.errorInvalidCredentials;
      case 'email-already-in-use':
        return l10n.errorEmailInUse;
      case 'weak-password':
        return l10n.errorWeakPassword;
      case 'invalid-email':
        return l10n.errorInvalidEmail;
      case 'user-disabled':
        return l10n.errorAccountDisabled;

      // Permission
      case 'permission-denied':
        return l10n.errorPermissionDenied;

      // Rate limiting
      case 'resource-exhausted':
      case 'too-many-requests':
        return l10n.errorRateLimited;

      // Quota
      case 'quota-exceeded':
        return l10n.errorQuotaExceeded;

      // Validation
      case 'invalid-argument':
        return l10n.errorInvalidInput;

      // Conflict
      case 'already-exists':
        return l10n.errorAlreadyExists;

      // Not found
      case 'not-found':
        return l10n.errorNotFound;

      // Cancelled
      case 'cancelled':
        return l10n.errorOperationCancelled;

      default:
        return null;
    }
  }

  /// Fall back to failure type-based localization
  String _getLocalizedByType(AppLocalizations l10n) {
    switch (runtimeType) {
      case const (NetworkFailure):
        return l10n.errorNetworkConnection;
      case const (ServerFailure):
        return l10n.errorServerError;
      case const (TimeoutFailure):
        return l10n.errorTimeout;
      case const (AuthenticationFailure):
        return l10n.errorAuthenticationRequired;
      case const (UnauthorizedFailure):
        return l10n.errorPermissionDenied;
      case const (CacheFailure):
        return l10n.errorCacheError;
      case const (ParseFailure):
        return l10n.errorDataCorrupted;
      case const (ValidationFailure):
        return l10n.errorInvalidInput;
      case const (WorkoutNotFoundFailure):
        return l10n.errorWorkoutNotFound;
      case const (ExerciseNotFoundFailure):
        return l10n.errorExerciseNotFound;
      case const (QuotaExceededFailure):
        return l10n.errorQuotaExceeded;
      case const (PermissionDeniedFailure):
        return l10n.errorPermissionDenied;
      case const (NotFoundFailure):
        return l10n.errorNotFound;
      case const (RateLimitFailure):
        return l10n.errorRateLimited;
      case const (ConflictFailure):
        return l10n.errorAlreadyExists;
      case const (CancelledFailure):
        return l10n.errorOperationCancelled;
      default:
        return l10n.errorUnexpected;
    }
  }

  /// Get a short title for the failure (for dialogs)
  String localizedTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (runtimeType) {
      case const (NetworkFailure):
        return l10n.errorTitleNetwork;
      case const (AuthenticationFailure):
        return l10n.errorTitleAuth;
      case const (PermissionDeniedFailure):
        return l10n.errorTitlePermission;
      case const (ValidationFailure):
        return l10n.errorTitleValidation;
      default:
        return l10n.errorDialogTitle;
    }
  }

  /// Check if the failure has a recoverable action
  bool get isRecoverable {
    return this is NetworkFailure ||
        this is RateLimitFailure ||
        this is TimeoutFailure;
  }

  /// Check if failure requires re-authentication
  bool get requiresReauth {
    return this is AuthenticationFailure || this is UnauthorizedFailure;
  }
}
