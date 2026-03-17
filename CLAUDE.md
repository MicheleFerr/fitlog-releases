# CLAUDE.md - FitLog Pro

Flutter | Clean Architecture + Riverpod 3.x | Testing Phase (1 user)
Breaking changes OK. Refactoring aggressivi permessi.

## WORKFLOW OBBLIGATORIO

**Ogni feature, bugfix o modifica deve essere committata automaticamente al termine del lavoro**, senza attendere istruzioni esplicite dell'utente. Usa il formato standard git commit con prefisso semantico (`feat:`, `fix:`, `chore:`, ecc.).

## REGOLE CRITICHE (Pre-commit + hook enforced)

| Regola | Corretto | Sbagliato |
|--------|----------|-----------|
| **Icone** | `AppIcons.*` | `Icons.*` |
| **Testi** | `context.l10n.*` | `'Hardcoded'` |
| **Colori** | `context.colors.*` | `Colors.blue` |
| **Loading** | `LoadingIndicator()` | `CircularProgressIndicator()` |
| **Snackbar** | `SnackBarService.*` | `ScaffoldMessenger.*` |
| **Icon Size** | `AppIconSize.medium` | `24` |
| **State** | `createStateProvider<T>(v)` | `StateProvider<T>()` (rimosso Riverpod 3.x) |
| **Hive** | `HiveBoxManagerEnhanced().openBox()` | `Hive.openBox()` |
| **Routes** | `AppRoutes.settingsName` | `'/profile/settings'` hardcoded |
| **Action Sheet** | `CupertinoActionSheet` / `showCupertinoModalPopup` | `PopupMenuButton` / Material popup menu |

## iOS BUILD (CRITICAL)

- `const Text(context.l10n.x)` = **iOS build error**. Mai `const` con `context.l10n`
- `context.l10n` solo in **Presentation layer** (widgets/screens), MAI in providers/domain/data
- Import fpdart: `hide Either, Right, Left` se serve con Riverpod AsyncValue

## ARCHITETTURA

```
lib/features/{name}/ -> domain/ | data/ | presentation/
```

- **Provider THIN, Service FAT** - logica nel service, non nel provider
- **DataSource pattern** - repository non tocca Firestore diretto
- **38 feature**: workout, analytics, ai_coach, auth, profile, settings, onboarding, health_sync, body_measurements, coach, chat, exercise_database, custom_exercises, workout_templates, history, progress, progression, strength_standards, stress_index, predictive_balance, recovery_insight, progress_photos, home, landing, splash, notifications, scheduling, feedback, help_center, admin, debug, data_export, import, workout_import, exercise_merge, quick_actions, premium

## NAVIGAZIONE (GoRouter + AppRoutes)

```dart
import 'package:gymbro/core/navigation/app_routes.dart';
context.goNamed(AppRoutes.settingsName);   // navigazione con nome
context.push(AppRoutes.exercisesPath);      // push con path
```

Router: `lib/core/navigation/app_router.dart`. Tutte le route hanno costanti `*Path` e `*Name`.

## LOCALIZZAZIONE

1. Aggiungi chiave in `assets/i18n/app_en.arb` + `assets/i18n/app_it.arb`
2. `flutter gen-l10n`
3. `Text(context.l10n.myNewKey)` nel widget

## UI LAYOUT

MainShell usa `extendBody: true` con padding dinamico. Pagine nella shell: `SafeArea(bottom: false)`. ListView: `MediaQuery.of(context).padding.bottom + AppSpacing.md`.

## IMPORT COMUNI

```dart
import 'package:gymbro/shared/presentation/extensions/build_context_extensions.dart'; // context.colors, context.l10n
import 'package:gymbro/core/providers/state_provider_helper.dart';                    // createStateProvider
import 'package:gymbro/core/navigation/app_routes.dart';                              // AppRoutes.*
import 'package:gymbro/core/data/hive_box_manager_enhanced.dart';                     // HiveBoxManagerEnhanced
```

## DIPENDENZE

Features importano Core/Shared (one-way). MAI cross-feature imports bidirezionali. Cicli noti: `analytics <-> workout`.

## PERFORMANCE

Dopo ogni modifica: `.claude/scripts/performance-check.sh lib/features/<feature>/`
Anti-pattern comuni: I/O in loop, batch ops mancanti, singleton mancanti, sequential awaits. Dettagli: `/performance-rules`

## iOS NATIVO

`ios/Runner/Managers/` (25 Swift files), `ios/FitLogWatch Watch App/` (watchOS), `ios/GymBroTimerWidget/` (Live Activities). Auto-generati da non toccare: `l10n/generated/`, `.dart_tool/`, `build/`. Dettagli: `/ios-architecture`

## TIER SYSTEM

UserTier (XP) ATTIVO: `ref.watch(userTierProvider)`. AccountTier (subscription) NON implementato: tutti `free`. Dettagli: `/tier-system`

## PERSONAS

5 personas: Marco (principiante), Chiara (multitasking), Luca (powerlifter), Sofia (estetica), Roberto (busy). Per feature/UX: `/persona-check [feature]`. Dettagli: `docs/USER_PERSONAS.md`

## TESTING GOTCHAS

- `FilledButton.icon()` -> NON trovabile con `find.byType(FilledButton)`, usare `find.text()` o `find.widgetWithText()`
- Widget test con l10n: wrappare con `MaterialApp` + `AppLocalizations.localizationsDelegates` + `locale: Locale('en')`

## COMANDI

```bash
flutter gen-l10n                                # Rigenera traduzioni
flutter analyze                                 # Check errori
.claude/scripts/performance-check.sh [path]     # Anti-pattern check
.claude/scripts/health-check.sh                 # File zombie
./scripts/checkpoint.sh                         # Auto-commit
```

## DOCUMENTAZIONE

Entry point: `docs/INDEX.md`. Key docs: Template Cloud Sync, AI Coach, Brand Guidelines, iOS/Flutter Audit, WatchOS Audit. Archivio: `docs/_archived/`

## PIANI FUTURI (da implementare)

| Feature | Spec | Note |
|---|---|---|
| Community video link negli esercizi | `docs/superpowers/specs/2026-03-16-exercise-community-videos-design.md` | Chip nel ExerciseDetailsModal → sheet lista video community, whitelist YouTube/TikTok/Instagram, url_launcher inAppBrowserView, Cloud Function + oEmbed |

## GOLDEN RULE

CERCA prima di creare. CONSOLIDA invece di duplicare. Se esiste -> ESTENDI. Se serve in 2+ feature -> SHARED.
