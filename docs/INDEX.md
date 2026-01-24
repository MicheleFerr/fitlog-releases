# FitLog Pro - Documentation Index

> **Last Updated**: 2026-01-23
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

## Market Intelligence & Strategy

| Documento | Descrizione |
|-----------|-------------|
| [MARKET_INTELLIGENCE_REPORT.md](MARKET_INTELLIGENCE_REPORT.md) | **Analisi competitiva completa** - 6 competitor, user personas, opportunità web |
| [WEB_STRATEGY_EXECUTIVE_SUMMARY.md](WEB_STRATEGY_EXECUTIVE_SUMMARY.md) | **Executive summary strategia web** - pricing, GTM, proiezioni finanziarie |
| [APP_STORE_DESCRIPTIONS.md](APP_STORE_DESCRIPTIONS.md) | Descrizioni App Store e Google Play |

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

## Data Quality & Maintenance

| Documento | Descrizione |
|-----------|-------------|
| [MUSCLE_FOCUS_STANDARDIZATION.md](MUSCLE_FOCUS_STANDARDIZATION.md) | **Fix focus muscolari** - risolte inconsistenze ADDO/ADD, BIC/BICI, ANCA |

---

## UX Mockups & Templates

### Superset Flow Improvements

| Documento | Descrizione | Impatto Atteso |
|-----------|-------------|----------------|
| [mockups/SUPERSET_PROGRESS_DOTS_MOCKUP.md](mockups/SUPERSET_PROGRESS_DOTS_MOCKUP.md) | **Progress indicator durante esecuzione** - dots (● ○ ○) + counter | -80% confusion, +15% completion rate |
| [mockups/SUPERSET_QUICK_ACTION_MOCKUP.md](mockups/SUPERSET_QUICK_ACTION_MOCKUP.md) | **Quick action button** - da 4 taps a 2 taps | +200% adoption, -75% time to create |
| [mockups/SUPERSET_BEGINNER_MODE_MOCKUP.md](mockups/SUPERSET_BEGINNER_MODE_MOCKUP.md) | **Progressive disclosure** - emoji RPE, terminologia semplice | +650% beginner adoption, +43% retention |

### Template System

| Documento | Descrizione | Impatto Atteso |
|-----------|-------------|----------------|
| [mockups/SUPERSET_TEMPLATE_SYSTEM.md](mockups/SUPERSET_TEMPLATE_SYSTEM.md) | **Template superset** - evidence-based + persona-specific | +150% superset adoption |
| [mockups/EXERCISE_SEARCH_WITH_TEMPLATES.md](mockups/EXERCISE_SEARCH_WITH_TEMPLATES.md) | **⭐ Template in Exercise Search** - template dove utente cerca esercizi | +300% adoption, 40% template usage |
| [mockups/WORKOUT_TEMPLATES_SCREEN_WITH_SUPERSET.md](mockups/WORKOUT_TEMPLATES_SCREEN_WITH_SUPERSET.md) | **⭐ Template in Workout Templates** - tab dedicato "Superset" con sezioni smart | +200% adoption, 70% tab visit rate |

### Template Data

| File | Descrizione |
|------|-------------|
| [assets/data/superset_templates.json](../assets/data/superset_templates.json) | **18 template predefiniti** - 3 per Marco, 3 per Chiara, 3 per Luca, 3 per Sofia, 3 per Roberto, 3 evidence-based |

**Evidenze Scientifiche:**
- 36% time savings con agonist-antagonist supersets (PMC 12011898)
- Stessi guadagni in muscle thickness, strength, power, hypertrophy
- Template basati su meta-analysis di 11 studi peer-reviewed

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
