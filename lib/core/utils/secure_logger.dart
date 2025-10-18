import 'package:flutter/foundation.dart';

/// Logger sicuro che sanitizza automaticamente informazioni sensibili nei log.
///
/// **SEMPRE usare questo logger invece di print() o debugPrint() diretto**
/// per evitare di loggare dati sensibili in produzione.
///
/// Esempio:
/// ```dart
/// SecureLogger.log('User logged in with uid: 123abc');
/// // Output: 'User logged in with uid: [REDACTED]'
///
/// SecureLogger.error('Failed to load data', error, stackTrace);
/// // Include error ma sanitizza stackTrace
/// ```
class SecureLogger {
  // Pattern per identificare dati sensibili
  static final _uidPattern = RegExp(r'uid["\s:]+[\w-]+', caseSensitive: false);
  static final _emailPattern = RegExp(r'email["\s:]+[\w@.+-]+', caseSensitive: false);
  static final _tokenPattern = RegExp(r'token["\s:]+[\w.-]+', caseSensitive: false);
  static final _passwordPattern = RegExp(r'password["\s:]+[\w!@#$%^&*]+', caseSensitive: false);
  static final _apiKeyPattern = RegExp(r'(api[_-]?key|apikey)["\s:]+[\w-]+', caseSensitive: false);
  static final _authPattern = RegExp(r'authorization["\s:]+[\w.-]+', caseSensitive: false);

  /// Log un messaggio generico con sanitizzazione automatica.
  ///
  /// [message]: Il messaggio da loggare
  /// [sanitize]: Se true (default), sanitizza automaticamente dati sensibili
  static void log(String message, {bool sanitize = true}) {
    if (kDebugMode) {
      final sanitized = sanitize ? _sanitize(message) : message;
      debugPrint('[LOG] $sanitized');
    }
  }

  /// Log un messaggio di informazione.
  static void info(String message, {bool sanitize = true}) {
    if (kDebugMode) {
      final sanitized = sanitize ? _sanitize(message) : message;
      debugPrint('[INFO] $sanitized');
    }
  }

  /// Log un warning.
  static void warning(String message, {bool sanitize = true}) {
    if (kDebugMode) {
      final sanitized = sanitize ? _sanitize(message) : message;
      debugPrint('[WARNING] ⚠️ $sanitized');
    }
  }

  /// Log un errore con errore e stackTrace opzionali.
  ///
  /// ⚠️ NOTA: Gli errori vengono sempre sanitizzati per sicurezza.
  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      final sanitizedMessage = _sanitize(message);
      debugPrint('[ERROR] ❌ $sanitizedMessage');

      if (error != null) {
        final sanitizedError = _sanitize(error.toString());
        debugPrint('[ERROR] Exception: $sanitizedError');
      }

      if (stackTrace != null) {
        // Log solo le prime 5 righe dello stackTrace per evitare spam
        final lines = stackTrace.toString().split('\n').take(5).join('\n');
        debugPrint('[ERROR] StackTrace:\n$lines');
      }
    }
  }

  /// Log di successo per operazioni importanti.
  static void success(String message, {bool sanitize = true}) {
    if (kDebugMode) {
      final sanitized = sanitize ? _sanitize(message) : message;
      debugPrint('[SUCCESS] ✅ $sanitized');
    }
  }

  /// Sanitizza una stringa rimuovendo informazioni sensibili.
  ///
  /// Oscura:
  /// - UID utente
  /// - Email
  /// - Token di autenticazione
  /// - Password
  /// - API keys
  /// - Header Authorization
  static String _sanitize(String message) {
    var sanitized = message;

    // Sostituisci pattern sensibili con [REDACTED]
    sanitized = sanitized.replaceAll(_uidPattern, 'uid: [REDACTED]');
    sanitized = sanitized.replaceAll(_emailPattern, 'email: [REDACTED]');
    sanitized = sanitized.replaceAll(_tokenPattern, 'token: [REDACTED]');
    sanitized = sanitized.replaceAll(_passwordPattern, 'password: [REDACTED]');
    sanitized = sanitized.replaceAll(_apiKeyPattern, 'api_key: [REDACTED]');
    sanitized = sanitized.replaceAll(_authPattern, 'authorization: [REDACTED]');

    return sanitized;
  }

  /// Verifica se un messaggio contiene dati potenzialmente sensibili.
  ///
  /// Utile per testing o validazione.
  static bool containsSensitiveData(String message) {
    return _uidPattern.hasMatch(message) ||
        _emailPattern.hasMatch(message) ||
        _tokenPattern.hasMatch(message) ||
        _passwordPattern.hasMatch(message) ||
        _apiKeyPattern.hasMatch(message) ||
        _authPattern.hasMatch(message);
  }

  /// Log solo in debug mode per operazioni molto frequenti (es. timer tick).
  ///
  /// Usa con parsimonia per evitare spam nei log.
  static void verbose(String message, {bool sanitize = true}) {
    if (kDebugMode) {
      final sanitized = sanitize ? _sanitize(message) : message;
      debugPrint('[VERBOSE] $sanitized');
    }
  }
}

/// Mixin per aggiungere facilmente logging sicuro a qualsiasi classe.
///
/// Esempio:
/// ```dart
/// class MyService with SecureLoggingMixin {
///   void doSomething() {
///     logInfo('Doing something');
///     try {
///       // ...
///     } catch (e, st) {
///       logError('Failed', e, st);
///     }
///   }
/// }
/// ```
mixin SecureLoggingMixin {
  void logInfo(String message) => SecureLogger.info(message);
  void logWarning(String message) => SecureLogger.warning(message);
  void logError(String message, [Object? error, StackTrace? stackTrace]) =>
      SecureLogger.error(message, error, stackTrace);
  void logSuccess(String message) => SecureLogger.success(message);
  void logVerbose(String message) => SecureLogger.verbose(message);
}
