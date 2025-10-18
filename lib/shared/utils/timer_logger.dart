import 'package:flutter/foundation.dart';

/// Log levels for timer operations
enum LogLevel { debug, info, warning, error }

/// Standardized logger for timer operations
/// Provides consistent logging format across Flutter and iOS bridge
class TimerLogger {
  static const String _prefix = '[TIMER]';

  /// Main logging method
  static void log(
    LogLevel level,
    String message, {
    String? category,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Skip debug logs in production
    if (!kDebugMode && level == LogLevel.debug) return;

    final categoryStr = category != null ? '[$category]' : '';
    final emoji = _getEmoji(level);
    final timestamp = DateTime.now().toIso8601String();

    final fullMessage = '$emoji $_prefix$categoryStr $message';

    switch (level) {
      case LogLevel.debug:
        debugPrint('🔍 $timestamp $fullMessage');
        break;
      case LogLevel.info:
        debugPrint('ℹ️ $timestamp $fullMessage');
        break;
      case LogLevel.warning:
        debugPrint('⚠️ $timestamp $fullMessage');
        break;
      case LogLevel.error:
        debugPrint('❌ $timestamp $fullMessage');
        if (error != null) {
          debugPrint('  Error: $error');
        }
        if (stackTrace != null) {
          debugPrint('  Stack: $stackTrace');
        }
        break;
    }
  }

  static String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug: return '🔍';
      case LogLevel.info: return 'ℹ️';
      case LogLevel.warning: return '⚠️';
      case LogLevel.error: return '❌';
    }
  }

  // Convenience methods
  static void debug(String message, {String? category}) =>
      log(LogLevel.debug, message, category: category);

  static void info(String message, {String? category}) =>
      log(LogLevel.info, message, category: category);

  static void warning(String message, {String? category}) =>
      log(LogLevel.warning, message, category: category);

  static void error(String message, {String? category, Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.error, message, category: category, error: error, stackTrace: stackTrace);
}
