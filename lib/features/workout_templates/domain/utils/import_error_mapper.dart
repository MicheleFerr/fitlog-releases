/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain
/// 🎯 Feature: workout_templates
/// 🔧 Type: utils
/// 🌍 Localization: ✅ Uses AppLocalizations
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Central error mapper for import operations - converts technical errors to user-friendly messages
library;

import 'dart:io';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Maps technical errors to user-friendly localized messages
class ImportErrorMapper {

  /// Map any error to a user-friendly message
  static String mapToUserMessage(dynamic error, AppLocalizations l10n) {
    // JSON parsing errors
    if (error is FormatException) {
      return _mapFormatException(error, l10n);
    }

    // File system errors
    if (error is FileSystemException) {
      return _mapFileSystemException(error, l10n);
    }

    // String-based error matching (for custom exceptions)
    final errorString = error.toString();

    // File-related errors
    if (errorString.contains('File too large')) {
      return l10n.errorFileTooLarge;
    }

    if (errorString.contains('File is empty') || errorString.contains('empty')) {
      return l10n.errorFileEmpty;
    }

    if (errorString.contains('File not found')) {
      return l10n.errorFileNotFound;
    }

    // Validation errors
    if (errorString.contains('Template name is required') ||
        errorString.contains('name cannot be empty')) {
      return l10n.errorTemplateNameMissing;
    }

    if (errorString.contains('exercises')) {
      if (errorString.contains('empty') || errorString.contains('at least one')) {
        return l10n.errorNoExercises;
      }
      if (errorString.contains('invalid')) {
        return l10n.errorExercisesInvalid;
      }
      return l10n.errorExercisesInvalid;
    }

    if (errorString.contains('sets')) {
      if (errorString.contains('at least one')) {
        return l10n.errorSetsRequired;
      }
      return l10n.errorSetsRequired;
    }

    if (errorString.contains('weight') || errorString.contains('reps')) {
      return l10n.errorInvalidNumbers;
    }

    if (errorString.contains('Duplicate')) {
      return l10n.errorDuplicateTemplate;
    }

    // Permission errors
    if (errorString.contains('permission') || errorString.contains('EACCES')) {
      return l10n.errorFilePermission;
    }

    // Network/Firebase errors (if applicable)
    if (errorString.contains('network') || errorString.contains('connection')) {
      return l10n.errorNetworkConnection;
    }

    // Generic fallback
    return l10n.errorImportFailed;
  }

  /// Map FormatException to user message
  static String _mapFormatException(FormatException error, AppLocalizations l10n) {
    final message = error.message.toLowerCase();

    if (message.contains('unexpected character') ||
        message.contains('unexpected token')) {
      return l10n.errorJsonUnexpectedCharacter;
    }

    if (message.contains('missing') || message.contains('required')) {
      return l10n.errorJsonMissingFields;
    }

    // Generic JSON error
    return l10n.errorJsonMalformed;
  }

  /// Map FileSystemException to user message
  static String _mapFileSystemException(
    FileSystemException error,
    AppLocalizations l10n,
  ) {
    final osErrorCode = error.osError?.errorCode;
    final message = error.message.toLowerCase();

    // File not found (ENOENT = 2)
    if (osErrorCode == 2 || message.contains('no such file')) {
      return l10n.errorFileNotFound;
    }

    // Permission denied (EACCES = 13)
    if (osErrorCode == 13 || message.contains('permission denied')) {
      return l10n.errorFilePermission;
    }

    // File already exists (EEXIST = 17)
    if (osErrorCode == 17 || message.contains('already exists')) {
      return l10n.errorFileAlreadyExists;
    }

    // Disk full (ENOSPC = 28)
    if (osErrorCode == 28 || message.contains('no space')) {
      return l10n.errorDiskFull;
    }

    // Generic file access error
    return l10n.errorFileAccess;
  }

  /// Get error with additional context
  static String mapErrorWithContext(
    dynamic error,
    AppLocalizations l10n, {
    String? field,
    String? templateName,
    int? exerciseIndex,
  }) {
    final baseMessage = mapToUserMessage(error, l10n);

    // Add context if available
    final contextParts = <String>[];

    if (templateName != null && templateName.isNotEmpty) {
      contextParts.add('Template: "$templateName"');
    }

    if (exerciseIndex != null) {
      contextParts.add('Exercise #${exerciseIndex + 1}');
    }

    if (field != null && field.isNotEmpty) {
      contextParts.add('Field: $field');
    }

    if (contextParts.isEmpty) {
      return baseMessage;
    }

    return '$baseMessage\n${contextParts.join(' • ')}';
  }

  /// Check if error is recoverable (user can fix it)
  static bool isRecoverable(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Recoverable errors (user can fix)
    final recoverablePatterns = [
      'format',
      'invalid json',
      'missing',
      'required',
      'empty',
      'duplicate',
      'weight',
      'reps',
      'sets',
    ];

    return recoverablePatterns.any((pattern) => errorString.contains(pattern));
  }

  /// Get severity level of error
  static ErrorSeverity getSeverity(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Critical errors (need developer attention)
    if (error is OutOfMemoryError ||
        errorString.contains('disk full') ||
        errorString.contains('permission denied')) {
      return ErrorSeverity.critical;
    }

    // High severity (blocking)
    if (error is FormatException ||
        errorString.contains('invalid json') ||
        errorString.contains('file not found')) {
      return ErrorSeverity.high;
    }

    // Medium severity (can work around)
    if (errorString.contains('duplicate') ||
        errorString.contains('invalid numbers')) {
      return ErrorSeverity.medium;
    }

    // Low severity (warnings)
    return ErrorSeverity.low;
  }

  /// Generate user-friendly suggestions for fixing error
  static List<String> getSuggestions(dynamic error, AppLocalizations l10n) {
    final suggestions = <String>[];
    final errorString = error.toString().toLowerCase();

    // JSON format errors
    if (error is FormatException || errorString.contains('json')) {
      suggestions.addAll([
        l10n.suggestionCheckJsonFormat,
        l10n.suggestionUseJsonValidator,
        l10n.suggestionCopyExample,
      ]);
    }

    // File errors
    if (errorString.contains('file')) {
      if (errorString.contains('not found')) {
        suggestions.add(l10n.suggestionCheckFilePath);
      }
      if (errorString.contains('too large')) {
        suggestions.add(l10n.suggestionReduceFileSize);
      }
      if (errorString.contains('permission')) {
        suggestions.add(l10n.suggestionCheckPermissions);
      }
    }

    // Validation errors
    if (errorString.contains('name')) {
      suggestions.add(l10n.suggestionAddTemplateName);
    }

    if (errorString.contains('exercise')) {
      suggestions.add(l10n.suggestionAddExercises);
    }

    if (errorString.contains('sets')) {
      suggestions.add(l10n.suggestionAddSets);
    }

    // Generic fallback
    if (suggestions.isEmpty) {
      suggestions.add(l10n.suggestionCheckFormat);
    }

    return suggestions;
  }
}

/// Error severity levels
enum ErrorSeverity {
  low,      // Warnings, can continue
  medium,   // Issues but can work around
  high,     // Blocking errors
  critical, // System errors, need developer
}
