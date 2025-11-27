import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/errors/error_handler.dart';

/// Mixin to add error handling capabilities to Notifier
mixin ErrorHandlerMixin<T> on Notifier<T> {
  BuildContext? _context;

  /// Set the context for error handling UI
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Handle error with automatic UI feedback
  Future<void> handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? message,
    VoidCallback? onRetry,
    ErrorSeverity? severity,
  }) async {
    await ErrorHandler.handle(
      error,
      stackTrace: stackTrace,
      context: _context,
      userMessage: message,
      severity: severity,
      onRetry: onRetry,
    );
  }

  /// Wrap async operations with error handling
  Future<R?> guardAsync<R>(
    Future<R> Function() operation, {
    String? errorMessage,
    VoidCallback? onRetry,
    R? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      await handleError(
        error,
        stackTrace: stackTrace,
        message: errorMessage,
        onRetry: onRetry,
      );
      return defaultValue;
    }
  }

  /// Wrap sync operations with error handling
  R? guard<R>(
    R Function() operation, {
    String? errorMessage,
    VoidCallback? onRetry,
    R? defaultValue,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      handleError(
        error,
        stackTrace: stackTrace,
        message: errorMessage,
        onRetry: onRetry,
      );
      return defaultValue;
    }
  }
}

/// Base class for error-aware notifiers
abstract class ErrorAwareNotifier<T> extends Notifier<T> with ErrorHandlerMixin<T> {
  // Subclasses must implement build()
}

/// Extension to make any Notifier error-aware
extension ErrorHandlerExtension<T> on Notifier<T> {
  /// Execute operation with error handling
  Future<R?> withErrorHandling<R>(
    Future<R> Function() operation, {
    BuildContext? context,
    String? errorMessage,
    VoidCallback? onRetry,
    R? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      await ErrorHandler.handle(
        error,
        stackTrace: stackTrace,
        context: context,
        userMessage: errorMessage,
        onRetry: onRetry,
      );
      return defaultValue;
    }
  }
}

/// Widget wrapper that provides error handling context
class ErrorHandlerWrapper extends ConsumerWidget {

  const ErrorHandlerWrapper({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set up global error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      ErrorHandler.handle(
        details.exception,
        stackTrace: details.stack,
        context: context,
        userMessage: 'An unexpected UI error occurred',
        severity: ErrorSeverity.high,
      );
    };

    return child;
  }
}

/// Try-catch wrapper for async operations in widgets
Future<T?> tryAsync<T>(
  BuildContext context,
  Future<T> Function() operation, {
  String? errorMessage,
  VoidCallback? onRetry,
  T? defaultValue,
  bool showError = true,
}) async {
  try {
    return await operation();
  } catch (error, stackTrace) {
    if (showError && context.mounted) {
      await ErrorHandler.handle(
        error,
        stackTrace: stackTrace,
        context: context,
        userMessage: errorMessage,
        onRetry: onRetry,
      );
    }
    return defaultValue;
  }
}

/// Try-catch wrapper for sync operations in widgets
T? trySync<T>(
  BuildContext context,
  T Function() operation, {
  String? errorMessage,
  VoidCallback? onRetry,
  T? defaultValue,
  bool showError = true,
}) {
  try {
    return operation();
  } catch (error, stackTrace) {
    if (showError && context.mounted) {
      ErrorHandler.handle(
        error,
        stackTrace: stackTrace,
        context: context,
        userMessage: errorMessage,
        onRetry: onRetry,
      );
    }
    return defaultValue;
  }
}