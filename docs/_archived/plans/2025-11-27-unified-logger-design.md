# UnifiedLogger - Design Document

**Data**: 2025-11-27
**Stato**: Approvato
**Effort stimato**: 2-3h implementazione + 1-2h migrazione

---

## Sommario

Sistema di logging unificato per FitLog Pro che consolida 13+ logger esistenti in un singolo `UnifiedLogger` basato su `voo_logging`.

### Obiettivi
- **Developer Experience**: Debug facile, filtering, ricerca log
- **Production Monitoring**: Error tracking, performance metrics
- **GDPR/Audit Compliance**: Audit trail, data masking automatico

### Decisioni Chiave
- Storage: **In-memory** (nessuna persistenza su disco)
- Base: **voo_logging** (già nel progetto)
- Pattern: **Wrapper/Facade** per decoupling

---

## Architettura

### Struttura File

```
lib/core/logging/
├── unified_logger.dart          # Facade principale (singleton)
├── log_level.dart               # Enum livelli
├── log_entry.dart               # Modello entry
├── log_tags.dart                # Tags predefiniti
├── secure_masking.dart          # GDPR data masking
└── log_config.dart              # Configurazione
```

### Classe Principale

```dart
/// UnifiedLogger - Single source of truth per tutti i log dell'app
///
/// Basato su voo_logging, aggiunge:
/// - Secure masking automatico per PII (email, password, userId)
/// - Tag per feature/layer (workout, timer, auth, http, audit)
/// - API semplificata rispetto a VooLogger diretto
class UnifiedLogger {
  static final UnifiedLogger _instance = UnifiedLogger._();
  static UnifiedLogger get instance => _instance;

  UnifiedLogger._();

  /// Inizializza il logger (chiamare in main.dart)
  static Future<void> initialize({
    String appName = 'FitLog Pro',
    LogLevel minLevel = LogLevel.debug,
    bool enableInRelease = false,
  }) async {
    await VooLogger.initialize(
      appName: appName,
      useInMemoryStorage: true,
      config: LoggingConfig(
        enablePrettyLogs: kDebugMode,
        showEmojis: kDebugMode,
        showTimestamp: true,
      ),
    );
  }

  // Metodi statici per accesso rapido
  static void debug(String message, {String? tag, Map<String, dynamic>? data});
  static void info(String message, {String? tag, Map<String, dynamic>? data});
  static void warning(String message, {String? tag, Map<String, dynamic>? data});
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag});
  static void audit(String action, {Map<String, dynamic>? data});  // GDPR trail
  static void secure(String message, {String? email, String? userId});  // Auto-mask
}
```

### Livelli di Log

| Livello | Uso | Visibile in Release |
|---------|-----|---------------------|
| `debug` | Sviluppo, verbose | No |
| `info` | Eventi normali | Configurabile |
| `warning` | Potenziali problemi | Sì |
| `error` | Errori da gestire | Sì |
| `audit` | Azioni utente (GDPR) | Sì |

---

## Secure Masking (GDPR)

### Pattern di Masking

```dart
/// secure_masking.dart
class SecureMasking {
  /// Maschera email: "user@example.com" → "u***@e***.com"
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***@***.***';
    final name = parts[0];
    final domain = parts[1].split('.');
    return '${name[0]}***@${domain[0][0]}***.${domain.last}';
  }

  /// Maschera userId: "abc123xyz" → "abc***xyz"
  static String maskUserId(String id) {
    if (id.length <= 6) return '***';
    return '${id.substring(0, 3)}***${id.substring(id.length - 3)}';
  }

  /// Maschera generica per dati sensibili in Map
  static Map<String, dynamic> maskSensitiveData(Map<String, dynamic> data) {
    final masked = Map<String, dynamic>.from(data);

    const sensitiveKeys = [
      'email', 'password', 'token', 'apiKey', 'secret',
      'userId', 'phone', 'address', 'name', 'creditCard',
    ];

    for (final key in masked.keys) {
      if (sensitiveKeys.any((s) => key.toLowerCase().contains(s))) {
        final value = masked[key];
        if (value is String) {
          masked[key] = key.contains('email')
              ? maskEmail(value)
              : '***REDACTED***';
        }
      }
    }
    return masked;
  }
}
```

### Uso Automatico

```dart
// Il masking avviene AUTOMATICAMENTE
UnifiedLogger.secure(
  'User login attempt',
  email: 'mario.rossi@gmail.com',  // → "m***@g***.com"
  userId: 'user_abc123xyz',         // → "use***xyz"
);

// Anche nei dati strutturati
UnifiedLogger.info(
  'Profile updated',
  tag: 'auth',
  data: {'email': 'test@test.com', 'age': 25},  // email mascherata auto
);
```

### Audit Trail (GDPR Art. 30)

```dart
// Log azioni utente per compliance
UnifiedLogger.audit('workout_deleted', data: {
  'workoutId': 'w123',
  'timestamp': DateTime.now().toIso8601String(),
  // userId aggiunto automaticamente dal logger
});
```

---

## Sistema di Tags

### Tags Predefiniti

```dart
/// log_tags.dart
abstract class LogTag {
  // Layer tags
  static const String domain = 'domain';
  static const String data = 'data';
  static const String presentation = 'ui';

  // Feature tags
  static const String workout = 'workout';
  static const String timer = 'timer';
  static const String auth = 'auth';
  static const String sync = 'sync';
  static const String analytics = 'analytics';
  static const String health = 'health';

  // Technical tags
  static const String http = 'http';
  static const String cache = 'cache';
  static const String performance = 'perf';
  static const String audit = 'audit';
}
```

### Uso con Tags

```dart
UnifiedLogger.debug(
  'Workout started',
  tag: LogTag.workout,
  data: {'templateId': 't123'},
);

UnifiedLogger.warning(
  'Slow query detected',
  tag: LogTag.performance,
  data: {'query': 'getWorkouts', 'ms': 800},
);
```

### Filtering

```dart
/// Recupera log filtrati per tag
static Future<List<LogEntry>> getLogs({
  String? tag,
  LogLevel? minLevel,
  DateTime? since,
}) async {
  var logs = await VooLogger.getLogs();

  if (tag != null) {
    logs = logs.where((l) => l.tag == tag).toList();
  }
  if (minLevel != null) {
    logs = logs.where((l) => l.level.index >= minLevel.index).toList();
  }
  if (since != null) {
    logs = logs.where((l) => l.timestamp.isAfter(since)).toList();
  }

  return logs;
}
```

### Output Console (Debug Mode)

```
🔵 14:32:01 [workout] Workout started {templateId: t123}
🔵 14:32:05 [timer] Rest timer started {duration: 90}
🟡 14:32:10 [perf] Slow query detected {query: getWorkouts, ms: 800}
🔴 14:32:15 [sync] Firebase sync failed {error: timeout}
🟣 14:32:20 [audit] Set completed {setId: s456}
```

---

## Piano di Migrazione

### Logger da Eliminare

| Logger Attuale | Migrazione |
|----------------|------------|
| `AppLogger` | → `UnifiedLogger.info/debug` |
| `DebugLogger` | → `UnifiedLogger.debug` |
| `ProductionLogger` | → `UnifiedLogger.error/warning` |
| `SecureLogger` | → `UnifiedLogger.secure` |
| `HttpLogger` | → `UnifiedLogger` con `tag: LogTag.http` |
| `TimerLogger` | → `UnifiedLogger` con `tag: LogTag.timer` |
| `PerformanceLogger` | → `UnifiedLogger` con `tag: LogTag.performance` |
| `AuditLoggerService` | → `UnifiedLogger.audit` |
| `PersistentLogger` | → Eliminato (in-memory only) |
| `_CacheLogger` | → Eliminato, usa `UnifiedLogger` |
| `_WidgetLogger` | → Eliminato, usa `UnifiedLogger` |
| `_CarouselLogger` | → Eliminato, usa `UnifiedLogger` |
| `_HybridTemplateLogger` | → Eliminato, usa `UnifiedLogger` |

### Fasi di Migrazione

1. **Fase 1**: Creare `UnifiedLogger` e file correlati
2. **Fase 2**: Aggiornare `main.dart` con inizializzazione
3. **Fase 3**: Migrare logger uno alla volta (partendo dai più usati)
4. **Fase 4**: Eliminare file logger obsoleti
5. **Fase 5**: Aggiungere pre-commit hook

---

## Enforcement

### Pre-commit Hook

```bash
# [X/X] Check UnifiedLogger usage
echo "🔍 Checking logger usage..."

# Blocca creazione di nuovi logger
if git diff --cached --name-only | xargs grep -l "class.*Logger" 2>/dev/null | \
   grep -v "unified_logger.dart" | grep -v "test/"; then
  echo "❌ ERROR: New logger class detected!"
  echo "   Use UnifiedLogger instead. See docs/LOGGING_STANDARD.md"
  exit 1
fi

# Warn su uso diretto di print/debugPrint
if git diff --cached | grep -E "^\+.*\b(print|debugPrint)\s*\(" | \
   grep -v "// ignore-logger-check"; then
  echo "⚠️  WARNING: Direct print() usage detected"
  echo "   Consider using UnifiedLogger.debug() instead"
fi
```

### Update CLAUDE.md

Aggiungere alla checklist:

```markdown
### 🔧 Logging (OBBLIGATORIO)
- [ ] ✅ **Usa `UnifiedLogger`** (MAI print/debugPrint/altri logger)
- [ ] ✅ **Specifica tag** appropriato (LogTag.workout, etc.)
- [ ] ✅ **Usa `.secure()`** per email, userId, dati sensibili
- [ ] ✅ **Usa `.audit()`** per azioni utente tracciabili
```

---

## Fonti e Best Practices

Design basato su ricerca delle best practices recenti:

- [Flutter Logging Best Practices - LogRocket](https://blog.logrocket.com/flutter-logging-best-practices/)
- [Beyond print(): Levelling Up Flutter Logging (2025)](https://tomasrepcik.dev/blog/2025/2025-08-03-flutter-logging/)
- [voo_logging - pub.dev](https://pub.dev/packages/voo_logging)
- [GDPR Logging Best Practices - Sematext](https://sematext.com/blog/gdpr-top-5-logging-best-practices/)
- [Loggy Library Pattern - Infinum](https://infinum.com/blog/logging-in-flutter/)

---

## Checklist Implementazione

- [ ] Creare `lib/core/logging/unified_logger.dart`
- [ ] Creare `lib/core/logging/log_level.dart`
- [ ] Creare `lib/core/logging/log_tags.dart`
- [ ] Creare `lib/core/logging/secure_masking.dart`
- [ ] Creare `lib/core/logging/log_config.dart`
- [ ] Aggiornare `main.dart` con `UnifiedLogger.initialize()`
- [ ] Creare `docs/LOGGING_STANDARD.md`
- [ ] Aggiornare `CLAUDE.md` con regole logging
- [ ] Aggiornare pre-commit hook
- [ ] Migrare logger esistenti (13+ file)
- [ ] Eliminare file logger obsoleti
- [ ] Test del sistema
