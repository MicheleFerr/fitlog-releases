import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Error types for categorization
enum ErrorType {
  network,
  authentication,
  firebase,
  validation,
  permission,
  storage,
  unknown,
}

/// Error severity levels
enum ErrorSeverity {
  low,      // Log only
  medium,   // Show toast
  high,     // Show dialog
  critical, // Show full screen error
}

/// Centralized error handling system for GymBro
class ErrorHandler {
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();
  static final ErrorHandler _instance = ErrorHandler._internal();

  /// Handle error with appropriate UI feedback
  static Future<void> handle(
    dynamic error, {
    StackTrace? stackTrace,
    BuildContext? context,
    String? userMessage,
    ErrorSeverity? severity,
    VoidCallback? onRetry,
  }) async {
    final errorType = _categorizeError(error);
    final finalSeverity = severity ?? _determineSeverity(errorType, error);
    
    // Log error in debug mode
    if (kDebugMode) {
      debugPrint('🔴 ERROR: $error');
      if (stackTrace != null) {
        debugPrint('📍 STACK: $stackTrace');
      }
    }

    // Send to crash reporting (Sentry/Crashlytics)
    await _sendToCrashReporting(error, stackTrace, errorType);

    // Show UI feedback if context available
    if (context != null && context.mounted) {
      await _showErrorFeedback(
        context,
        error,
        errorType,
        finalSeverity,
        userMessage,
        onRetry,
      );
    }
  }

  /// Categorize error type
  static ErrorType _categorizeError(dynamic error) {
    if (error is FirebaseAuthException) {
      return ErrorType.authentication;
    } else if (error is FirebaseException) {
      return ErrorType.firebase;
    } else if (error.toString().contains('SocketException') ||
               error.toString().contains('Connection')) {
      return ErrorType.network;
    } else if (error is FormatException || 
               error is TypeError ||
               error.toString().contains('Invalid')) {
      return ErrorType.validation;
    } else if (error.toString().contains('Permission') ||
               error.toString().contains('denied')) {
      return ErrorType.permission;
    } else if (error.toString().contains('Storage') ||
               error.toString().contains('Hive')) {
      return ErrorType.storage;
    }
    return ErrorType.unknown;
  }

  /// Determine error severity
  static ErrorSeverity _determineSeverity(ErrorType type, dynamic error) {
    switch (type) {
      case ErrorType.authentication:
        return ErrorSeverity.high;
      case ErrorType.firebase:
        return error.toString().contains('PERMISSION_DENIED') 
            ? ErrorSeverity.critical 
            : ErrorSeverity.medium;
      case ErrorType.network:
        return ErrorSeverity.medium;
      case ErrorType.permission:
        return ErrorSeverity.high;
      case ErrorType.validation:
        return ErrorSeverity.low;
      case ErrorType.storage:
        return ErrorSeverity.medium;
      case ErrorType.unknown:
        return ErrorSeverity.medium;
    }
  }

  /// Send error to crash reporting service
  static Future<void> _sendToCrashReporting(
    dynamic error,
    StackTrace? stackTrace,
    ErrorType type,
  ) async {
    // TODO: Integrate with Sentry or Firebase Crashlytics
    // For now, just log
    if (!kDebugMode) {
      // In production, would send to crash reporting service
    }
  }

  /// Show appropriate error feedback UI
  static Future<void> _showErrorFeedback(
    BuildContext context,
    dynamic error,
    ErrorType type,
    ErrorSeverity severity,
    String? userMessage,
    VoidCallback? onRetry,
  ) async {
    final l10n = AppLocalizations.of(context);
    final message = userMessage ?? _getLocalizedMessage(context, type, error);

    switch (severity) {
      case ErrorSeverity.low:
        // Just log, no UI
        break;
        
      case ErrorSeverity.medium:
        // Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: onRetry != null
                ? SnackBarAction(
                    label: l10n.retry,
                    onPressed: onRetry,
                    textColor: Theme.of(context).colorScheme.onError,
                  )
                : null,
          ),
        );
        break;
        
      case ErrorSeverity.high:
        // Show dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.errorOccurred),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(message),
                if (kDebugMode) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Debug: ${error.toString()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.ok),
              ),
              if (onRetry != null)
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
                  child: Text(l10n.retry),
                ),
            ],
          ),
        );
        break;
        
      case ErrorSeverity.critical:
        // Show full screen error
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ErrorScreen(
              error: error,
              message: message,
              onRetry: onRetry,
            ),
          ),
        );
        break;
    }
  }

  /// Get localized error message
  static String _getLocalizedMessage(
    BuildContext context,
    ErrorType type,
    dynamic error,
  ) {
    final l10n = AppLocalizations.of(context);
    
    switch (type) {
      case ErrorType.network:
        return l10n.networkError;
      case ErrorType.authentication:
        return _getAuthErrorMessage(context, error as FirebaseAuthException);
      case ErrorType.firebase:
        return l10n.databaseError;
      case ErrorType.validation:
        return l10n.validationError;
      case ErrorType.permission:
        return l10n.permissionDenied;
      case ErrorType.storage:
        return l10n.storageError;
      case ErrorType.unknown:
        return l10n.unknownError;
    }
  }

  /// Get specific auth error message
  static String _getAuthErrorMessage(
    BuildContext context,
    FirebaseAuthException error,
  ) {
    final l10n = AppLocalizations.of(context);
    
    switch (error.code) {
      case 'user-not-found':
        return l10n.userNotFound;
      case 'wrong-password':
        return l10n.wrongPassword;
      case 'email-already-in-use':
        return l10n.emailAlreadyInUse;
      case 'invalid-email':
        return l10n.invalidEmail;
      case 'weak-password':
        return l10n.weakPassword;
      case 'network-request-failed':
        return l10n.networkError;
      default:
        return l10n.authenticationError;
    }
  }
}

/// Full screen error widget for critical errors
class ErrorScreen extends StatelessWidget {

  const ErrorScreen({
    super.key,
    required this.error,
    required this.message,
    this.onRetry,
  });
  final dynamic error;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.criticalError,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error.toString(),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.goBack),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: onRetry,
                      child: Text(l10n.retry),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Provider for error handling
final errorHandlerProvider = Provider((ref) => ErrorHandler());

/// Extension for easy error handling in widgets
extension ErrorHandlingExtension on BuildContext {
  Future<void> handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? message,
    VoidCallback? onRetry,
  }) async {
    await ErrorHandler.handle(
      error,
      stackTrace: stackTrace,
      context: this,
      userMessage: message,
      onRetry: onRetry,
    );
  }
}