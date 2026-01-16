# FitLog Pro - Documentation Index

> **Last Updated**: 2025-01-01
> **App Status**: Testing Phase (1 user)

---

## Quick Links

| Documento | Descrizione |
|-----------|-------------|
| [CLAUDE.md](../CLAUDE.md) | Istruzioni per Claude Code |
| [USER_PERSONAS.md](USER_PERSONAS.md) | **12 User Personas** - framework decisionale |
| [DEVELOPMENT_RULES.md](DEVELOPMENT_RULES.md) | Regole sviluppo e convenzioni |
| [CODE_PATTERNS.md](CODE_PATTERNS.md) | Pattern di codice da seguire |
| [DESIGN_GUIDELINES.md](DESIGN_GUIDELINES.md) | Design system e UI guidelines |

---

## App Structure

```
FitLog Pro
├── Workout Tracking     # Core: traccia workout in tempo reale
├── Exercise Database    # Catalogo esercizi con search
├── History & Analytics  # Storico e statistiche
├── Timer & Live Activities  # Timer con iOS Live Activities
├── Templates            # Template workout personalizzabili
└── Custom Exercises     # Esercizi custom utente
```

---

## Feature Documentation

| Feature | File | Status |
|---------|------|--------|
| Workout Tracking | [features/workout.md](features/workout.md) | TODO |
| Exercise Database | [features/exercise-database.md](features/exercise-database.md) | TODO |
| Timer System | [features/timer.md](features/timer.md) | TODO |
| Analytics | [features/analytics.md](features/analytics.md) | TODO |

---

## Architecture

| Documento | Descrizione |
|-----------|-------------|
| [architecture/OVERVIEW.md](architecture/OVERVIEW.md) | Architettura generale |
| [ADR/](ADR/) | Architecture Decision Records |

---

## GDPR & Security

| Documento | Descrizione |
|-----------|-------------|
| [legal/TIA_FIREBASE.md](legal/TIA_FIREBASE.md) | Transfer Impact Assessment (Schrems II) |
| [legal/DPA/README.md](legal/DPA/README.md) | Data Processing Agreement (Google) |
| [security/ENCRYPTION_VERIFICATION.md](security/ENCRYPTION_VERIFICATION.md) | AES-256 encryption audit |
| [security/PENETRATION_TEST_SCHEDULE.md](security/PENETRATION_TEST_SCHEDULE.md) | Pentest Q1 2026 planning |

### Cloud Functions GDPR

| Funzione | Schedule | Scopo |
|----------|----------|-------|
| `gdprCheckInactiveUsers` | Monthly (1st) | 24-month retention check |
| `gdprHardDeletePhotos` | Daily | Hard-delete after 30 days |
| `gdprCleanupAuditLogs` | Monthly (15th) | Audit log 2-year retention |
| `gdprLogAdminAccess` | Callable | Admin access logging |
| `gdprGetAuditLog` | Callable | Art. 15 data access |
| `gdprAuditUserData` | Trigger | User document audit |

---

## Development

### Regole Chiave (da CLAUDE.md)

```dart
// Icone
AppIcons.add           // ✅
Icons.add              // ❌

// Colori
context.colors.primary // ✅
Colors.blue            // ❌

// Testi
context.l10n.title     // ✅
'Hardcoded'            // ❌

// Loading
LoadingIndicator()     // ✅
CircularProgressIndicator() // ❌
```

### Comandi Utili

```bash
flutter gen-l10n              # Rigenera traduzioni
flutter analyze               # Check errori
flutter test                  # Run tests
.claude/scripts/health-check.sh  # Check file zombie
```

---

## Claude Code Integration

### Comandi Disponibili

| Comando | Cosa fa |
|---------|---------|
| `/fitlog <task>` | Suggerisce l'agente/comando giusto |
| `/context` | Carica contesto sessione |
| `/cleanup` | Trova file duplicati/orfani |
| `/bug-detective` | Debug sistematico |

### Agenti Specializzati

| Agente | Quando usarlo |
|--------|---------------|
| `flutter-architect` | Nuove feature, architettura |
| `flutter-debugger` | Errori runtime, crash |
| `ios-specialist` | Live Activities, Swift |
| `firebase-expert` | Firestore, auth, sync |

---

## Archive

La documentazione precedente (318 file) è stata archiviata in `docs/_archived/` il 2024-12-16.

Motivo: documentazione obsoleta e non coerente con lo stato attuale dell'app.

Per consultare vecchi documenti: `docs/_archived/`

---

## Note

- **Breaking changes OK** - App in testing con 1 utente
- **Refactoring aggressivi permessi** - Nessun vincolo legacy
- **Documentazione minima** - Solo ciò che serve davvero
