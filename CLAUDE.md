# 🤖 CLAUDE.md - FitLog Pro

**Framework**: Flutter | **Arch**: Clean Architecture + Riverpod | **Status**: 🧪 Testing Phase (1 user)

> Breaking changes OK. Refactoring aggressivi permessi.

---

## 📚 DOCUMENTATION FIRST

**Entry point**: [`docs/INDEX.md`](docs/INDEX.md) → documentazione essenziale

**Dettagli regole**: [`docs/DEVELOPMENT_RULES.md`](docs/DEVELOPMENT_RULES.md) | **Code patterns**: [`docs/CODE_PATTERNS.md`](docs/CODE_PATTERNS.md)

---

## 🛡️ REGOLE CRITICHE (Pre-commit enforced)

| Regola | Corretto | Sbagliato |
|--------|----------|-----------|
| **Icone** | `AppIcons.*` | `Icons.*` |
| **Testi** | `context.l10n.*` | `'Hardcoded'` |
| **Colori** | `context.colors.*` | `Colors.blue` |
| **Loading** | `LoadingIndicator()` | `CircularProgressIndicator()` |
| **Snackbar** | `SnackBarService.*` | `ScaffoldMessenger.*` |
| **Icon Size** | `AppIconSize.medium` | `24` |

---

## 🏗️ iOS BUILD COMPLIANCE (CRITICAL)

```dart
Text(context.l10n.title)        // ✅
const Text(context.l10n.title)  // ❌ iOS build error!
```

- `context.l10n` solo in **Presentation layer** (widgets/screens)
- **MAI** in providers/domain/data → usa stringhe hardcoded
- Import: `hide Either, Right, Left` se usi fpdart

---

## 🎨 TEMA & COLORI

```dart
context.colors.primary    // invece di Colors.blue
context.colors.success    // invece di Colors.green
context.colors.error      // invece di Colors.red
context.colors.warning    // invece di Colors.amber
```

Import: `build_context_extensions.dart` + `color_scheme_extensions.dart`

---

## 🧩 ARCHITETTURA

```
lib/features/{name}/
├── domain/     # Entities, Repository interfaces
├── data/       # Repository impl, DataSources
└── presentation/ # Providers, Screens, Widgets
```

- **Provider THIN, Service FAT** - logica nel service
- **Repository estende BaseHybridRepository**
- **DataSource pattern** - repository NON tocca Firestore diretto

---

## ⚡ CHECKLIST RAPIDA

- [ ] `AppIcons.*` (no `Icons.*`)
- [ ] `context.l10n.*` (no hardcoded)
- [ ] `context.colors.*` (no `Colors.*`)
- [ ] `flutter gen-l10n` se nuove traduzioni
- [ ] `flutter analyze` passa
- [ ] Testato dark/light mode
- [ ] NO `const` con `context.l10n`

---

## 🚫 NON TOCCARE

- `ios/Runner/LiveActivityTimer/` - Swift nativo
- `ios/Runner/BackgroundTaskManager/` - Swift nativo
- `lib/shared/presentation/l10n/generated/` - Auto-generati
- `.dart_tool/`, `build/`, `firebase_options.dart`

---

## 🚀 FITLOG COPILOT

Comandi intelligenti per migliorare il workflow:

| Comando | Cosa fa |
|---------|---------|
| `/fitlog <task>` | Suggerisce l'agente/comando giusto per il task |
| `/context` | Carica contesto sessione (git, file recenti, TODO) |
| `/cleanup` | Trova file zombie (duplicati, orfani, stale) |

### Agenti Specializzati

| Agente | Quando usarlo |
|--------|---------------|
| `flutter-architect` | Nuove feature, architettura |
| `flutter-debugger` | Errori runtime, crash |
| `ios-specialist` | Live Activities, Swift |
| `timer-live-activity-specialist` | Timer, notifiche |
| `firebase-expert` | Firestore, auth, sync |
| `performance-optimizer` | Rebuild, memoria |

### Rules Enforcer (automatico)

Hook attivo su ogni Edit/Write che blocca violazioni:
- `Icons.*` → usa `AppIcons.*`
- `Colors.*` → usa `context.colors.*`
- Hardcoded strings → usa `context.l10n.*`
- `CircularProgressIndicator` → usa `LoadingIndicator()`

---

## 🔧 COMANDI UTILI

```bash
flutter gen-l10n              # Rigenera traduzioni
flutter analyze               # Check errori
./scripts/checkpoint.sh       # Auto-commit checkpoint
.claude/scripts/health-check.sh  # Check file zombie
.claude/scripts/gather-context.sh # Carica contesto
```

---

## 📖 DOCUMENTAZIONE

| Argomento | File |
|-----------|------|
| Entry point | [`docs/INDEX.md`](docs/INDEX.md) |
| Architettura | [`docs/architecture/OVERVIEW.md`](docs/architecture/OVERVIEW.md) |
| Regole sviluppo | [`docs/DEVELOPMENT_RULES.md`](docs/DEVELOPMENT_RULES.md) |
| Pattern codice | [`docs/CODE_PATTERNS.md`](docs/CODE_PATTERNS.md) |
| Design system | [`docs/DESIGN_GUIDELINES.md`](docs/DESIGN_GUIDELINES.md) |
| ADR | [`docs/ADR/`](docs/ADR/) |

> Documentazione precedente archiviata in `docs/_archived/`

---

## 🎯 GOLDEN RULES

```
╔═══════════════════════════════════════════════════════════╗
║  CERCA prima di creare. CONSOLIDA invece di duplicare.   ║
║  Se esiste → ESTENDI. Se serve in 2+ feature → SHARED.   ║
╚═══════════════════════════════════════════════════════════╝
```
