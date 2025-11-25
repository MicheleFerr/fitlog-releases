import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/domain/services/secure_logger.dart';

/// @deprecated Use [CooldownLimiter] instead to avoid naming conflict with
/// RateLimiter (token bucket) in shared/domain/security/rate_limiter.dart.
@Deprecated('Use CooldownLimiter instead - avoids naming conflict with RateLimiter')
typedef RateLimiter = CooldownLimiter;

/// Servizio di cooldown per prevenire abusi e spam.
///
/// Limita il numero di operazioni che un utente può eseguire in un dato
/// periodo di tempo (es. max 1 reset password ogni 60 secondi).
///
/// **Note**: This is a simple cooldown-based limiter (static class).
/// For API rate limiting with token bucket algorithm, use:
/// `lib/shared/domain/security/rate_limiter.dart`
///
/// Esempio:
/// ```dart
/// // Verifica se l'utente può inviare reset password
/// if (!CooldownLimiter.canAttempt('password_reset')) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text('Troppi tentativi. Riprova tra un minuto.')),
///   );
///   return;
/// }
///
/// // Procedi con l'operazione
/// await authService.sendPasswordResetEmail(email);
/// ```
class CooldownLimiter {
  // Mappa che tiene traccia dell'ultimo tentativo per ogni operazione
  static final Map<String, DateTime> _lastAttempts = {};

  // Configurazione cooldown per tipo di operazione
  static final Map<String, Duration> _cooldowns = {
    // 🔐 Auth operations - SECURITY: Prevent brute force attacks
    'login': const Duration(seconds: 3), // Max 20 tentativi/minuto
    'registration': const Duration(seconds: 5), // Max 12 registrazioni/minuto
    'password_reset': const Duration(seconds: 60), // Max 1/minuto
    'email_verification': const Duration(seconds: 120), // Max 1/2 minuti

    // 👥 Community operations
    'community_contribution': const Duration(seconds: 30),
    'exercise_report': const Duration(seconds: 30),
    'feedback_submission': const Duration(seconds: 30),

    // 👤 Profile operations
    'profile_update': const Duration(seconds: 10),

    // 💪 Workout operations
    'workout_save': const Duration(seconds: 3),

    // 🔍 Search operations
    'exercise_search': const Duration(seconds: 1),
  };

  /// Verifica se è possibile eseguire un'operazione.
  ///
  /// [operation]: Chiave identificativa dell'operazione (es. 'password_reset')
  /// [cooldown]: Durata cooldown custom (opzionale, usa default se non specificato)
  /// [userId]: ID utente per rate limiting per-utente (opzionale)
  ///
  /// Returns: true se l'operazione può essere eseguita, false altrimenti
  static bool canAttempt(
    String operation, {
    Duration? cooldown,
    String? userId,
  }) {
    final key = userId != null ? '${operation}_$userId' : operation;
    final effectiveCooldown = cooldown ?? _getCooldown(operation);

    final lastAttempt = _lastAttempts[key];

    if (lastAttempt == null) {
      // Prima volta, permetti
      _recordAttempt(key);
      return true;
    }

    final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);

    if (timeSinceLastAttempt < effectiveCooldown) {
      // Cooldown ancora attivo
      final remainingSeconds =
          (effectiveCooldown - timeSinceLastAttempt).inSeconds;
      SecureLogger.warning(
        'Rate limit exceeded for operation: $operation. '
        'Wait $remainingSeconds seconds.',
      );
      return false;
    }

    // Cooldown passato, permetti
    _recordAttempt(key);
    return true;
  }

  /// Registra un tentativo di operazione.
  static void _recordAttempt(String key) {
    _lastAttempts[key] = DateTime.now();

    if (kDebugMode) {
      SecureLogger.verbose('Rate limiter: recorded attempt for $key');
    }
  }

  /// Ottiene la durata del cooldown per un'operazione.
  static Duration _getCooldown(String operation) {
    return _cooldowns[operation] ?? const Duration(seconds: 30);
  }

  /// Configura o aggiorna il cooldown per un'operazione.
  ///
  /// Utile per personalizzare il rate limiting a runtime.
  static void setCooldown(String operation, Duration cooldown) {
    _cooldowns[operation] = cooldown;
    SecureLogger.info(
      'Rate limiter: set cooldown for $operation to ${cooldown.inSeconds}s',
    );
  }

  /// Resetta il rate limiter per un'operazione specifica.
  ///
  /// Utile per testing o per permettere un'operazione immediata in casi speciali.
  static void reset(String operation, {String? userId}) {
    final key = userId != null ? '${operation}_$userId' : operation;
    _lastAttempts.remove(key);

    if (kDebugMode) {
      SecureLogger.verbose('Rate limiter: reset for $key');
    }
  }

  /// Resetta tutti i rate limiter.
  ///
  /// ⚠️ Usare solo in testing o situazioni eccezionali.
  static void resetAll() {
    _lastAttempts.clear();

    if (kDebugMode) {
      SecureLogger.warning('Rate limiter: RESET ALL limits');
    }
  }

  /// Ottiene il tempo rimanente prima che un'operazione possa essere ripetuta.
  ///
  /// Returns: Duration rimanente, o Duration.zero se l'operazione è disponibile
  static Duration getRemainingCooldown(
    String operation, {
    String? userId,
  }) {
    final key = userId != null ? '${operation}_$userId' : operation;
    final lastAttempt = _lastAttempts[key];

    if (lastAttempt == null) {
      return Duration.zero;
    }

    final effectiveCooldown = _getCooldown(operation);
    final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);

    if (timeSinceLastAttempt >= effectiveCooldown) {
      return Duration.zero;
    }

    return effectiveCooldown - timeSinceLastAttempt;
  }

  /// Verifica se un'operazione è attualmente in cooldown.
  static bool isInCooldown(String operation, {String? userId}) {
    return getRemainingCooldown(operation, userId: userId) > Duration.zero;
  }

  /// Ottiene un messaggio user-friendly per il cooldown rimanente.
  ///
  /// Esempio: "Riprova tra 45 secondi"
  static String getCooldownMessage(String operation, {String? userId}) {
    final remaining = getRemainingCooldown(operation, userId: userId);

    if (remaining == Duration.zero) {
      return 'Operazione disponibile';
    }

    final seconds = remaining.inSeconds;

    if (seconds < 60) {
      return 'Riprova tra $seconds second${seconds == 1 ? 'o' : 'i'}';
    }

    final minutes = (seconds / 60).ceil();
    return 'Riprova tra $minutes minut${minutes == 1 ? 'o' : 'i'}';
  }
}

/// @deprecated Use [CooldownLimiterMixin] instead.
@Deprecated('Use CooldownLimiterMixin instead')
typedef RateLimiterMixin = CooldownLimiterMixin;

/// Mixin per aggiungere facilmente cooldown limiting a qualsiasi classe.
///
/// Esempio:
/// ```dart
/// class AuthService with CooldownLimiterMixin {
///   Future<void> sendPasswordReset(String email) async {
///     if (!checkCooldown('password_reset')) {
///       throw Exception('Too many attempts');
///     }
///
///     await _auth.sendPasswordResetEmail(email: email);
///   }
/// }
/// ```
mixin CooldownLimiterMixin {
  /// Verifica il cooldown per un'operazione.
  bool checkCooldown(
    String operation, {
    Duration? cooldown,
    String? userId,
  }) {
    return CooldownLimiter.canAttempt(
      operation,
      cooldown: cooldown,
      userId: userId,
    );
  }

  /// @deprecated Use [checkCooldown] instead.
  @Deprecated('Use checkCooldown instead')
  bool checkRateLimit(
    String operation, {
    Duration? cooldown,
    String? userId,
  }) {
    return checkCooldown(operation, cooldown: cooldown, userId: userId);
  }

  /// Ottiene il messaggio di cooldown.
  String getCooldownMessage(String operation, {String? userId}) {
    return CooldownLimiter.getCooldownMessage(operation, userId: userId);
  }

  /// Verifica se in cooldown.
  bool isInCooldown(String operation, {String? userId}) {
    return CooldownLimiter.isInCooldown(operation, userId: userId);
  }
}
