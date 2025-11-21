# 🤖 CLAUDE.md - Istruzioni Progetto

> **IMPORTANTE**: Questo file contiene le regole obbligatorie per lavorare su questo progetto Flutter.

## 📱 Progetto: FitLog Pro
**Framework**: Flutter | **Architettura**: Clean Architecture + Riverpod | **Stato**: ⚠️ **TESTING PHASE** - Solo utente sviluppatore

> **🧪 NOTA TESTING**: L'app è attualmente in fase di sviluppo e testing con UN SOLO UTENTE (lo sviluppatore).
> **Non esiste base utenti** → Possiamo fare **breaking changes** e **migrazioni dati** senza preoccupazioni di compatibilità retroattiva.
> **Refactoring aggressivi sono permessi** per migliorare architettura e performance.

---

## 📚 STEP 0: LEGGI LA DOCUMENTAZIONE PRIMA DI IMPLEMENTARE

**⚠️ OBBLIGATORIO**: Prima di qualsiasi modifica, leggi [`docs/NAVIGATION/INDEX.md`](docs/NAVIGATION/INDEX.md) → trova docs feature → leggi → implementa

**Documentazione chiave**: `DESIGN_GUIDELINES.md` (design system), `TIMER_SYSTEM_DOCUMENTATION.md` (timer), `ANALYTICS_SYSTEM_DOCUMENTATION.md` (analytics), `USER_PROFILE_DOCUMENTATION.md` (auth), `WORKOUT_SYSTEM_OVERVIEW.md` (workout), `ROUTINE_CENTER_V2_IMPLEMENTATION.md` (routine v2.0 - START HERE), `FASE_1_PRESET_TEMPLATES_UI_ENHANCEMENT.md` (routine preset UI), `APRE_INDEX.md` (APRE), `AI_COACH_COMPREHENSIVE_DOCUMENTATION.md` (AI coach feature gating)

**Workflow**: INDEX.md → Trova feature → Leggi docs → Implementa → Aggiorna docs → Commit

---

## 🛡️ ENFORCEMENT REGOLE CRITICHE

**Tutte le modifiche DEVONO rispettare:**
1. **Icon Design System Tier-1** 🆕:
   - `AppIcons.*` per tutte le icone (MAI `Icons.*` inline)
   - `AppIconSize.*` per sizing (MAI magic numbers 24, 28)
   - `context.icon*` per colors (MAI `Colors.blue/red/green`)
   - `SemanticIcon` preferito (accessibility screen readers)
2. **Nessun testo hardcoded** → `context.l10n.*`
3. **Nessun colore hardcoded** → `context.colors.*`
4. **No componenti raw** → usa `LoadingIndicator`, `SnackBarService`, `ModalService`
5. **`flutter analyze` deve passare** prima di commit

**Pre-commit hook BLOCCA automaticamente violazioni di regole 1-3.**

---

## 🎯 REGOLA #0: TIER-1 ICON DESIGN SYSTEM (MANDATORY)

> **⚠️ CRITICAL**: Sistema icone completo con centralizzazione, semantic sizing, colors, accessibility, animations e badges.

### 📐 1. AppIcons Centralizzate
**SEMPRE** `AppIcons.*` - MAI `Icons.*` | ~445 icone | Import: `app_icons.dart`
```dart
Icon(AppIcons.workout) // ✅ | Icon(Icons.fitness_center) // ❌
```

### 📏 2. AppIconSize
**SEMPRE** `AppIconSize.*` - MAI magic numbers | Sizes: tiny(16), small(20), medium(24), large(28), xlarge(32), xxlarge(48) | Import: `app_icon_size.dart`
```dart
Icon(AppIcons.workout, size: AppIconSize.medium) // ✅ | size: 24 // ❌
```

### 🎨 3. Semantic Icon Colors
**SEMPRE** `context.icon*` - MAI hardcoded | Colors: Primary/Secondary/Tertiary, Success/Error/Warning/Info, Emphasis levels, Workout-specific | Helpers: `iconStateActive()`, `iconProgressColor()`, `iconPriority()` | Import: `app_icon_colors.dart`
```dart
Icon(AppIcons.workout, color: context.iconPrimary) // ✅ | Colors.blue // ❌
```

### ♿ 4. SemanticIcon - Accessibility
**SEMPRE** usa `SemanticIcon` per screen readers | Factories: `.button()`, `.state()` | Import: `semantic_icon.dart`
```dart
SemanticIcon(icon: AppIcons.workout, semanticLabel: context.l10n.start) // ✅
AppIcons.workout.semantic(label: context.l10n.start) // ✅ shorthand
```

### 🎬 5. AnimatedIconPatterns
Patterns: `rotating()`, `pulsing()`, `bouncing()`, `fading()`, `shaking()` | Import: `animated_icon_patterns.dart`
```dart
AnimatedIconPatterns.rotating(icon: AppIcons.loading) // ✅
```

### 🔴 6. BadgedIcon
Factories: `.notification(count)`, `.dot(showDot)` | Extensions: `.withBadge()`, `.withDot()` | Import: `badged_icon.dart`
```dart
AppIcons.notifications.withBadge(count: 3) // ✅
```

### 🔍 7. Icon Showcase
Tool per esplorare 445 icone | Features: search, 11 categories, copy name | Location: `icon_showcase_screen.dart`

### 📦 8-10. Advanced Features (Priority 3)
- **AppIconCategory**: Type-safe 11 categories | `app_icon_category.dart`
- **AppIconVariants**: Filled/outlined toggle (13 variants) | `app_icon_variants.dart` | `ToggleIcon` widget
- **AppIconMetadata**: Rich metadata (descriptions, keywords, semantic labels) | `app_icon_metadata.dart`

### 🚫 Enforcement
Pre-commit hook: blocca `Icons.*` inline, warn su `Icon()` senza SemanticIcon/hardcoded sizes | 100% coverage (~445 icone)

### ⚡ Quick Examples
```dart
SemanticIcon(icon: AppIcons.workout, semanticLabel: context.l10n.start, size: AppIconSize.large, color: context.iconPrimary)
AppIcons.notifications.withBadge(count: 3) // Badge
AnimatedIconPatterns.rotating(icon: AppIcons.loading) // Animation
Icon(AppIcons.wifi, color: context.iconStateActive(isConnected)) // State color
```

---

## 🏗️ iOS BUILD COMPLIANCE (CRITICAL - ENFORCED BY PRE-COMMIT)

> **⚠️ MANDATORY**: These patterns prevent the 998 iOS build errors that were fixed in November 2024.
> **Pre-commit hook automatically enforces these rules** - violations will block commits.
> **Reference**: See `BUILD_FIX_SUMMARY.md` for complete fix documentation.

### 🚫 Pattern 1: NEVER `const` with `context.l10n` (CRITICAL - BLOCKS COMMIT)
Runtime evaluation → incompatible with `const`
```dart
Text(context.l10n.title) // ✅ | const Text(context.l10n.title) // ❌ iOS build error
```

### 🏛️ Pattern 2: Architecture Boundaries (WARNING)
- **Presentation** (widgets/screens): ✅ CAN use `context.l10n`
- **Provider**: ❌ SHOULD NOT (use hardcoded strings)
- **Domain/Data**: ❌ NEVER (use hardcoded strings)

### 🔧 Pattern 3: BuildContext Parameter (CRITICAL)
Methods using `context.l10n` MUST have `BuildContext context` parameter
```dart
String _format(BuildContext context, ...) { return context.l10n.text; } // ✅
```

### 📦 Pattern 4: Import Disambiguation
```dart
import 'package:fpdart/fpdart.dart' hide Either, Right, Left; // ✅
```

---

### 📚 Quick Reference Table

| Pattern | Severity | Pre-commit | Fix |
|---------|----------|------------|-----|
| `const` with `context.l10n` | 🔴 CRITICAL | ❌ BLOCKS | Remove `const` |
| `context.l10n` in providers | 🟡 WARNING | ⚠️ WARNS | Use hardcoded strings |
| `context.l10n` in domain/data | 🟡 WARNING | ⚠️ WARNS | Use hardcoded strings |
| Missing BuildContext param | 🔴 CRITICAL | (manual) | Add `BuildContext context` |
| Import conflicts | 🔵 INFO | ℹ️ INFO | Add `hide Either, Right, Left` |

**Pre-commit hook**: `.git/hooks/pre-commit` (section 5/5) | Full docs: `BUILD_FIX_SUMMARY.md`

---

## 🛡️ PARSING SAFETY (CRITICAL - ENFORCED BY PRE-COMMIT)

> **⚠️ MANDATORY**: Use `lib/shared/utils/safe_parsing.dart` utilities to prevent FormatException crashes.
> **Pre-commit hook BLOCKS** commits with unsafe `Color(int.parse()` patterns.

### Pattern da Evitare:

```dart
// ❌ UNSAFE - Crash se invalid hex
Color(int.parse('FF$hex', radix: 16))

// ✅ SAFE - Usa utility con fallback
parseColorSafe(hex, fallback: Colors.blue)
```

### Safe Parsing Utilities:

```dart
import 'package:gymbro_flutter_new/shared/utils/safe_parsing.dart';

parseColorSafe('#2196F3', fallback: Colors.blue) // Color + named colors
parseIntSafe(input, fallback: 0)                  // Integer
parseDoubleSafe(input, fallback: 0.0)             // Double
parseDateTimeSafe(jsonDate, fallback: DateTime.now()) // DateTime
parseBoolSafe(jsonData['enabled'], fallback: false)   // Boolean
parseEnumSafe('active', Status.values, fallback: Status.pending) // Enum
```

**Pre-commit hook**: Section 8/9 - Blocca commit con `Color(int.parse()` unsafe

---

## 🌍 REGOLA #1: MULTILINGUA OBBLIGATORIO

✅ **SEMPRE**: `context.l10n.keyName` (BuildContext extensions)
- Importa: `build_context_extensions.dart`
- Aggiungi traduzioni in `assets/i18n/app_en.arb` e `app_it.arb`
- Rigenera: `flutter gen-l10n`

❌ **MAI**: Testi hardcoded o `AppLocalizations.of(context)!`

---

## 🎨 REGOLA #2: TEMA SCURO/CHIARO (TEMA CENTRALIZZATO OBBLIGATORIO)

### 📖 Sistema Tema

L'app usa un **sistema tema centralizzato** in `lib/shared/presentation/theme/app_theme.dart` che supporta:
- ✅ Dark/Light mode automatico
- ✅ Material 3 design system
- ✅ Colori custom estesi (success, warning)
- ✅ Rebranding istantaneo (cambia 5 colori → intera app aggiornata)

### ✅ SEMPRE Usa Theme-Aware Colors

```dart
// ✅ CORRETTO - Theme-aware
Container(color: context.colors.primary)
Icon(Icons.check, color: context.colors.success)
Text('Error', style: TextStyle(color: context.colors.error))

// ❌ SBAGLIATO - Hardcoded
Container(color: Colors.blue)
Icon(Icons.check, color: Colors.green)
Text('Error', style: TextStyle(color: Colors.red))
```

### 📋 Color Mapping Reference

| Hardcoded | Theme Alternative | Uso |
|-----------|-------------------|-----|
| `Colors.blue` | `context.colors.primary` | Brand color, pulsanti principali |
| `Colors.orange` | `context.colors.secondary` | Accent, azioni secondarie |
| `Colors.green` | `context.colors.success` | Success, completato, positivo |
| `Colors.red` | `context.colors.error` | Errore, danger, elimina |
| `Colors.amber` / `Colors.yellow` | `context.colors.warning` | Warning, attenzione |
| `Colors.purple` / `Colors.deepPurple` | `context.colors.tertiary` | Azioni terziarie, info |
| `Colors.white` | `context.colors.surface` | Sfondi, card |
| `Colors.grey` | `context.colors.surfaceVariant` | Sfondi sottili |
| `Colors.black` | `context.colors.onSurface` | Testo primario |

**⚠️ Eccezione**: `Colors.transparent` è permesso (universale, valido in tutti i temi)

### 📦 Import Richiesti

```dart
// Per context.colors.*
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

// Per .success, .warning custom extensions
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
```

### 🛠️ Tool Automatici Disponibili

**Fixare violazioni automaticamente**:
```bash
# Single file
./scripts/fix_theme_violations.sh --file path/to/file.dart

# Dry-run (anteprima)
./scripts/fix_theme_violations.sh --dry-run --file path/to/file.dart

# All files (163 file automatici, ~1110 sostituzioni)
./scripts/fix_theme_violations.sh
```

**Rollback se necessario**:
```bash
./scripts/rollback_theme_fixes.sh --file path/to/file.dart
```

### 🔒 Pre-Commit Hook Integrato

Il pre-commit hook automaticamente:
- ✅ Scansiona ogni file .dart staged
- ✅ Rileva hardcoded `Colors.*` violations
- ❌ **BLOCCA commit** se trova violazioni
- 💡 Mostra fix automatico suggerito

**⚠️ Bypass (NON RACCOMANDATO)**: `git commit --no-verify`

### 📚 Documentazione Completa

Vedi: `scripts/THEME_FIX_README.md` per:
- Guida completa utilizzo script
- Test results e statistics
- FAQ e troubleshooting
- Color mapping dettagliato

---

## 🏗️ REGOLA #3: ARCHITETTURA RIVERPOD

Struttura: `features/[name]/{domain,data,presentation}` + `shared/`
Widget pattern: `ConsumerWidget` + `ref.watch()`/`ref.read()`

---

## 🔧 WIDGET PATTERN ESSENZIALI

- ✅ Usa `const` quando possibile
- ✅ Import assoluti: `package:...` (mai `../`)
- ✅ Usa `select()` per evitare rebuild inutili: `ref.watch(provider.select((x) => x.field))`
- ✅ Manage resources: cancella `Timer`, `StreamSubscription`, `Controller`
- ✅ Testa in entrambi i temi (chiaro/scuro)

---

## 🍎 REGOLA #4: iOS SPECIFICO

- Live Activities (iOS 16.1+), Dynamic Island, Background Tasks
- Controlla sempre `Platform.isIOS` prima di codice iOS-only
- Files nativi in `ios/Runner/LiveActivityTimer/` e `BackgroundTaskManager/` - NON modificare

---

## 🔄 REGOLA #11: GIT & VERSIONING

### 📝 Commit Message Format:
```
feat: add rest timer with live activity support
fix: resolve workout timer not pausing in background  
refactor: improve workout provider memory usage
docs: update localization guide with new patterns
```

### 🚫 NON Committare Mai:
- File con testi hardcoded
- API keys o secrets
- File di build (`build/`, `.dart_tool/`)
- File IDE specifici (`.vscode/settings.json` personali)

### ✅ Pre-commit Automatici:
- ✅ Lint check (`flutter analyze`)
- ✅ **Theme violations check** (hardcoded Colors.* detection) 🆕
- ✅ Hardcoded strings check
- ✅ Localizations regen se necessario
- ✅ Test execution

---

## ⚡ CHECKLIST RAPIDA

Prima di ogni modifica, verifica:

### 🎯 Icon Design System (CRITICO - Bloccato da pre-commit hook)
- [ ] ✅ **Nessun `Icons.*` inline** (usa `AppIcons.*`)
- [ ] ✅ **Usa `AppIconSize.*`** (non magic numbers: 24, 28, etc.)
- [ ] ✅ **Usa `context.icon*` colors** (non `Colors.blue/green/red`)
- [ ] ✅ **Preferisci `SemanticIcon`** (per accessibility)
- [ ] ✅ Import necessari: `app_icons.dart`, `app_icon_size.dart`, `app_icon_colors.dart`

### 🌍 Localizzazione
- [ ] ✅ Nessun testo hardcoded (usa `context.l10n`)
- [ ] ✅ Traduzioni aggiunte in EN e IT (`assets/i18n/*.arb`)
- [ ] ✅ `flutter gen-l10n` eseguito se aggiunte traduzioni

### 🎨 Tema (CRITICO - Bloccato da pre-commit hook)
- [ ] ✅ **Nessun `Colors.blue/red/green/etc.`** (usa `context.colors.primary/error/success`)
- [ ] ✅ **Nessun `Color(0xFF...)`** (usa tema, o giustifica)
- [ ] ✅ Import `build_context_extensions.dart` + `color_scheme_extensions.dart`
- [ ] ✅ Widget testato in **Dark E Light mode** (cambia tema in settings)
- [ ] ✅ Solo `Colors.transparent` è permesso (eccezione universale)

### 🔧 Code Quality
- [ ] ✅ **Nessun print()** - usa `debugPrint() + kDebugMode`
- [ ] ✅ `flutter analyze` passa senza errori
- [ ] ✅ Performance ottimizzata (`const`, `select`, `dispose`)
- [ ] ✅ Named routes usate (non path hardcoded)

### 🧪 Testing & Platform
- [ ] ✅ Funzionalità testata su iOS E Android (se applicabile)
- [ ] ✅ Autenticazione controllata se usa Firebase
- [ ] ✅ Platform-specific: `Platform.isIOS` check prima di iOS-only code

### 🏗️ iOS Build Compliance (CRITICO - Bloccato da pre-commit hook)
- [ ] ❌ **NEVER `const` with `context.l10n`** (CRITICAL - blocks commit)
- [ ] ❌ **NO `context.l10n` in providers** (use hardcoded strings)
- [ ] ❌ **NO `context.l10n` in domain/data layers** (use hardcoded strings)
- [ ] ✅ **BuildContext parameter** for methods using `context.l10n`
- [ ] ✅ **Import disambiguation**: `hide Either, Right, Left` if using fpdart

---

## 🍎 REGOLA #4: PIATTAFORMA iOS SPECIFICA

### 📱 Funzionalità iOS Esclusive:
- **Live Activities** (iOS 16.1+)
- **Dynamic Island** (iPhone 14 Pro+)
- **Background Tasks** (iOS specifici)
- **Apple Health Integration**
- **Sign in with Apple**

### ⚠️ Gestione Piattaforma:
```dart
// ✅ CORRETTO - Controlla piattaforma
if (Platform.isIOS) {
  // Codice specifico iOS
  await _startLiveActivity();
}

// ❌ SBAGLIATO - Assumere che sia sempre iOS
await _startLiveActivity(); // Crash su Android!
```

### 📂 File iOS Nativi:
- `ios/Runner/LiveActivityTimer/` - Live Activities
- `ios/Runner/BackgroundTaskManager/` - Background tasks
- **NON modificare** senza conoscenze Swift/iOS

---

## 🔥 REGOLA #5: FIREBASE & SICUREZZA

- Valida SEMPRE input utente e stato autenticazione
- Ogni documento Firestore deve avere `userId` per sicurezza
- Validazione lato client E server
- Error handling obbligatorio per operazioni async

---

## 🧪 REGOLA #6: TESTING & DEBUG

- ✅ Testa con localizzazione (IT/EN)
- ✅ Usa `debugPrint()` + `kDebugMode` (mai `print()`)
- ✅ Testa in Release mode prima di deploy
- ❌ MAI usare `print()` in production

---

## 🏋️‍♂️ REGOLA #7: DOMINIO FITNESS

Entità: Workout, Exercise, ExerciseCard, WorkoutTemplate, Analytics
Terminologia: Set/Serie, Rep, Rest, Superset, Drop Set, Rest-Pause
Timer: Rest Timer (tra serie), Workout Timer, Live Activity (iOS), Background

---

## 🚫 REGOLA #8: COSA NON TOCCARE

- `ios/Runner/LiveActivityTimer/` e `BackgroundTaskManager/` (Swift nativo)
- `lib/shared/presentation/l10n/generated/` (File generati)
- `.dart_tool/`, `build/`, `firebase_options.dart`, plist, keys

---

## 🔨 REGOLA #9: BUILD & COMPILATION

❌ **MAI** fare build automatici
- ✅ Solo se esplicitamente richiesto
- ✅ Solo per fix critici di compilazione
- ✅ Sempre lasciar fare build a Xcode/Android Studio per preferenza utente

---

## 🎯 REGOLA #10: BUILDCONTEXT EXTENSIONS (OBBLIGATORIO)

Importa: `build_context_extensions.dart`
- `context.l10n.*` - Localizzazioni
- `context.colors.*` - Colori tema
- `context.textTheme`, `context.screenHeight`, `context.isDarkMode` etc.

---

## 🧩 REGOLA #11: COMPONENTI UNIFICATI (OBBLIGATORIO)

**LoadingIndicator** per loading states (mai `CircularProgressIndicator` diretto)
**SnackBarService** per messaggi (mai `ScaffoldMessenger.showSnackBar` diretto)
**ModalService** per modals/dialogs (mai `showModalBottomSheet` diretto)

---

## 📝 REGOLA #12: DOCUMENTAZIONE AUTOMATICA POST-IMPLEMENTAZIONE (COMPORTAMENTO AUTOMATICO)

**⚠️ COMPORTAMENTO OBBLIGATORIO DI CLAUDE DOPO OGNI IMPLEMENTAZIONE:**

### 🤖 Workflow Automatico (Claude lo fa SEMPRE):

```
Appena finita un'implementazione di feature/modifica significativa
                    ↓
Claude AUTOMATICAMENTE rileva che hai implementato qualcosa
                    ↓
Claude CHIEDE: "🤖 Ho notato che hai implementato [nome-feature].
                Vuoi che generi automaticamente la documentazione
                completa e la colleghi a INDEX.md e CLAUDE.md?"
                    ↓
            [Sì]              [No/Dopo]
             ↓                     ↓
    Claude AUTOMATICAMENTE    Salta per ora
    esegue tutto:             (ma ricorda)
    1. Analizza git diff
    2. Genera docs completa
    3. Aggiorna INDEX.md
    4. Aggiorna CLAUDE.md
    5. Cross-references
    6. Commit documentazione
             ↓
    ✅ FATTO: Feature documentata e interconnessa
```

### 🎯 Cosa Fa Claude AUTOMATICAMENTE (senza comandi):

**Quando**: Dopo ogni implementazione significativa (nuova feature, modifica importante, nuovo screen/provider/repository)

**Claude automaticamente**:

1. **🔍 RILEVA**: Analizza i file modificati/creati
   ```
   - git diff --cached
   - git status
   - Nuovi file in lib/features/
   ```

2. **💬 CHIEDE**: "Vuoi che documenti questa implementazione?"
   - Se sì → procede automaticamente
   - Se no → ricorda per dopo

3. **📝 GENERA**: Crea documentazione completa
   ```markdown
   docs/UX_FLOWS/[category]/[FEATURE]_DOCUMENTATION.md
   - Overview
   - Architecture (domain/data/presentation)
   - Key features
   - Implementation details
   - UI components
   - Related documentation
   ```

4. **🔗 INTERCONNETTE**: Aggiorna tutto
   - **INDEX.md**: Aggiunge "Quick Navigation by Feature" entry
   - **CLAUDE.md**: Aggiunge feature mapping table entry
   - **Cross-refs**: Link bidirezionali con docs correlate

5. **💾 COMMIT**: Salva tutto
   ```bash
   git commit -m "docs: add [feature] documentation with interconnection"
   ```

### 📖 Esempio Conversazione Automatica:

```
User: "Implementa una pagina A/B testing dinamica"
       ↓
Claude: [implementa il codice]
       ↓
Claude: "✅ Implementazione completata!

        🤖 Ho notato che hai implementato una nuova feature:
           'Dynamic A/B Testing Page'

        Vuoi che generi automaticamente:
        - Documentazione completa (450+ righe)
        - Aggiornamento INDEX.md con link
        - Aggiornamento CLAUDE.md con mapping
        - Cross-references con docs correlate
        - Commit della documentazione

        Risposta: sì/no"
       ↓
User: "sì"
       ↓
Claude: [AUTOMATICAMENTE esegue tutto]
       ↓
Claude: "✅ Documentazione completata!

        📄 Creato: docs/UX_FLOWS/ab_testing/AB_TESTING_PAGE_DOCUMENTATION.md (450 righe)
        🔗 Aggiornato: INDEX.md (nuovo link in Quick Navigation)
        🔗 Aggiornato: CLAUDE.md (nuovo mapping feature)
        🔗 Cross-referenced: Analytics, User Profile, Firebase docs
        💾 Commit: docs: add A/B testing page documentation

        ✨ Ora la feature è completamente documentata e interconnessa!
           CLAUDE.md → INDEX.md → AB Testing docs"
```

### ⚙️ Regole di Rilevamento Automatico:

Claude rileva automaticamente quando hai implementato qualcosa se:

| Condizione | Claude chiede documentazione |
|-----------|------------------------------|
| ✅ Nuovi file in `lib/features/` | SÌ - Nuova feature |
| ✅ Nuovi screen `*_screen.dart` | SÌ - Nuova UI |
| ✅ Nuovi provider `*_provider.dart` | SÌ - Nuovo state management |
| ✅ Nuovi repository `*_repository.dart` | SÌ - Nuovo data layer |
| ✅ Modifiche significative (>100 righe) | SÌ - Major refactor |
| ❌ Piccoli fix (<50 righe) | NO - Non necessario |
| ❌ Solo commenti/formattazione | NO - Non necessario |

### 🎯 Nessun Comando Manuale Necessario:

**PRIMA (manuale)**:
```bash
# Implementa
# Ricordati di documentare
/finalize-feature "nome"  ← Devi ricordartelo!
```

**ORA (automatico)**:
```bash
# Implementa
# Claude automaticamente chiede e fa tutto
✨ Zero sforzo - tutto automatico
```

### ⚠️ Importante per Claude:

- **SEMPRE** chiedi dopo ogni implementazione significativa
- **MAI** committare senza aver offerto di documentare
- **SEMPRE** aspetta conferma dell'utente prima di procedere
- **MAI** documentare piccoli fix o refactor minori

---

## 🎨 REGOLA #13: DESIGN SYSTEM (COMPORTAMENTO AUTOMATICO)

**⚠️ COMPORTAMENTO OBBLIGATORIO DI CLAUDE QUANDO LAVORA SU UI:**

Ogni volta che crei o modifici UI (widget, screen, dialog, card, button), devi **AUTOMATICAMENTE**:

### 📋 PRIMA di Scrivere Codice:

1. **Leggi** `docs/DESIGN_GUIDELINES.md` (sezione rilevante)
2. **Identifica** pattern standard da riutilizzare
3. **Crea TODO** con checklist design completa

### 🔧 DURANTE l'Implementazione:

**SEMPRE usa**:
- `context.colors.*` (MAI colori hardcoded)
- `context.textTheme.*` (MAI TextStyle hardcoded)
- `context.l10n.*` (MAI stringhe hardcoded)
- Spacing = multipli di 4 (4, 8, 12, 16, 20, 24, 32)
- Border radius = 8, 12, 16, 20, 24
- HapticFeedback su azioni interattive
- LoadingIndicator (MAI CircularProgressIndicator diretto)
- SnackBarService (MAI ScaffoldMessenger diretto)

**Pattern Standard** (vedi DESIGN_GUIDELINES.md):
```dart
// Standard Card
Container(
  decoration: BoxDecoration(
    color: context.colors.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: /* Content */,
  ),
)
```

### ✅ DOPO l'Implementazione:

**Aggiungi SEMPRE al TODO questa checklist** (copiala letteralmente):

```
Design System Checklist:
- [ ] ✅ `context.colors.*` (NO hardcoded colors)
- [ ] ✅ `context.textTheme.*` (NO hardcoded TextStyle)
- [ ] ✅ `context.l10n.*` (NO hardcoded strings)
- [ ] ✅ Spacing = multipli di 4
- [ ] ✅ Border radius = 8/12/16/20/24
- [ ] ✅ Testato in light AND dark themes
- [ ] ✅ Traduzioni in app_en.arb + app_it.arb
- [ ] ✅ `flutter gen-l10n` eseguito
- [ ] ✅ Date con DateFormat + locale
- [ ] ✅ HapticFeedback su azioni
- [ ] ✅ Touch targets ≥ 44x44
- [ ] ✅ LoadingIndicator (non CircularProgressIndicator)
- [ ] ✅ SnackBarService (non ScaffoldMessenger)
- [ ] ✅ `const` dove possibile
- [ ] ✅ `flutter analyze` passa (0 errori)
```

**NON marcare il task come completato** finché TUTTI i punti non sono verificati.

### 🚨 Violazioni Comuni da Evitare:

| ❌ SBAGLIATO | ✅ CORRETTO |
|--------------|-------------|
| `color: Colors.blue` | `color: context.colors.primary` |
| `Text('Welcome')` | `Text(context.l10n.welcome)` |
| `TextStyle(fontSize: 16)` | `context.textTheme.bodyMedium` |
| `padding: EdgeInsets.all(15)` | `padding: const EdgeInsets.all(16)` |
| `'Today', 'Yesterday'` | `context.l10n.today, context.l10n.yesterday` |
| `CircularProgressIndicator()` | `LoadingIndicator()` |
| `ScaffoldMessenger.of(context)` | `SnackBarService.showSuccess(context, msg)` |

### 📚 Risorse:

- **Guida completa**: `docs/DESIGN_GUIDELINES.md` (600+ righe)
- **Pattern standard**: Cerca in DESIGN_GUIDELINES.md sezioni:
  - Cards (3 pattern)
  - Dialogs & Modals
  - Buttons (4 tipi)
  - Empty States
  - Animations
- **Esempio reale**: `lib/features/routine/presentation/widgets/skip_recovery_dialog.dart`

### 🎯 Golden Rule:

**"Se tocchi UI, applica DESIGN_GUIDELINES.md. NO eccezioni."**

Quando in dubbio:
1. Cerca widget simile già esistente
2. Copia pattern da DESIGN_GUIDELINES.md
3. Chiedi conferma all'utente se non trovi pattern

---

## ⚡ CHECKLIST COMPLETA

### 📖 PRIMA di Implementare:
- [ ] ✅ Letto `docs/NAVIGATION/INDEX.md`
- [ ] ✅ Trovata e letta documentazione della feature
- [ ] ✅ Letta documentazione correlata

### 🔧 DURANTE l'Implementazione:
- [ ] ✅ **Nessun `Icons.*` inline** (usa `AppIcons.*`)
- [ ] ✅ **Usa `AppIconSize.*` constants** (no magic numbers)
- [ ] ✅ **Usa `context.icon*` per colori** (no hardcoded)
- [ ] ✅ **Preferisci `SemanticIcon`** per accessibility
- [ ] ✅ Nessun testo hardcoded (`context.l10n.*`)
- [ ] ✅ Nessun colore hardcoded (`context.colors.*`)
- [ ] ✅ Import necessari: `app_icons.dart`, `app_icon_size.dart`, `app_icon_colors.dart`, `build_context_extensions.dart`
- [ ] ✅ Nessun `print()` → usa `debugPrint() + kDebugMode`
- [ ] ✅ Traduzioni aggiunte (EN + IT)
- [ ] ✅ `flutter gen-l10n` eseguito
- [ ] ✅ `flutter analyze` senza errori
- [ ] ✅ Testato in chiaro/scuro
- [ ] ✅ iOS E Android (se applicabile)
- [ ] ✅ Autenticazione controllata (se Firebase)
- [ ] ✅ Performance ottimizzata (`const`, `select`, `dispose`)
- [ ] ✅ Named routes usate
- [ ] ✅ **iOS Build Compliance** (vedi sezione iOS BUILD COMPLIANCE):
  - [ ] ❌ NEVER `const` with `context.l10n` (CRITICAL - blocks commit)
  - [ ] ❌ NO `context.l10n` in providers (use hardcoded strings)
  - [ ] ❌ NO `context.l10n` in domain/data layers (use hardcoded strings)
  - [ ] ✅ BuildContext parameter for methods using `context.l10n`
  - [ ] ✅ Import disambiguation: `hide Either, Right, Left` if using fpdart

### 📝 DOPO l'Implementazione (AUTOMATICO):
- [ ] ✅ **Claude chiede automaticamente di documentare** ← Claude lo fa SEMPRE
- [ ] ✅ Rispondo "sì" → Claude genera tutto automaticamente
- [ ] ✅ Documentazione generata e verificata (automatico)
- [ ] ✅ INDEX.md aggiornato (automatico)
- [ ] ✅ CLAUDE.md aggiornato (automatico)
- [ ] ✅ Cross-references create (automatico)
- [ ] ✅ Commit documentazione (automatico)

---

## 🆘 RISORSE

- **Icon System**: `app_icons.dart` (445 icons), `app_icon_size.dart`, `app_icon_colors.dart`, `semantic_icon.dart`, `badged_icon.dart`, `animated_icon_patterns.dart`
- **Icon Showcase**: `IconShowcaseScreen()` per esplorare tutte le icone con search/copy
- **Locale/Tema**: `build_context_extensions.dart`
- **Loading/Snackbar/Modal**: Usa i servizi unificati
- **Documentazione**: Vedi `docs/INDEX.md`
- **Script**: `scripts/find_hardcoded_strings.sh`, `flutter analyze`

---

## 🔧 AUTOMAZIONE PRE-COMMIT

### 1. CLAUDE.md Auto-Staging (ATTIVO)

- ✅ CLAUDE.md viene **automaticamente staged** se modificato
- ✅ Incluso nella commit corrente (no commit separati)
- ✅ Implementato nel pre-commit hook (check #8/8)

**Workflow**:
```bash
# Modifica CLAUDE.md
vim CLAUDE.md

# Commit normale (hook auto-aggiunge CLAUDE.md)
git commit -m "feat: add new feature"

# Output: [8/8] Checking CLAUDE.md auto-staging...
#         📝 Auto-staging CLAUDE.md (modified)...
#         ✅ CLAUDE.md added to commit
```

### 2. Auto-Checkpoint System (NUOVO - ALTAMENTE RACCOMANDATO)

Sistema intelligente che **auto-committa modifiche significative** per triggerare pre-commit hook checks.

**📋 Soglie Default**:
- ✅ **50+ righe modificate** in totale
- ✅ **OPPURE 3+ file .dart modificati**

**🚀 Quick Start**:

```bash
# Modalità 1: Manual checkpoint (commit immediato se soglie superate)
./scripts/checkpoint.sh

# Modalità 2: Watch mode (monitora e auto-committa in background)
./scripts/checkpoint.sh --watch

# Modalità 3: Git alias (super rapido)
git checkpoint        # Commit immediato
git watch            # Watch mode background
```

**⚡ Watch Mode Output**:
```
👁️  Watch mode enabled
   Threshold: 50 lines OR 3 files
   Interval: 30s

📊 Changes detected: 4 files, ~75 lines
⚡ Threshold met: 75 lines (>= 50)
🎯 Significant changes detected!

💾 Creating checkpoint commit...
🎨 Running Design System Checks...
✅ Checkpoint created successfully!
   4 files committed
   Commit: a1b2c3d
```

**🎯 Quando Usare**:
- ✅ **Sessioni sviluppo lunghe** - Watch mode previene perdita lavoro
- ✅ **Refactoring massicci** - Checkpoint frequenti = rollback facile
- ✅ **Debug build errors** - Feedback immediato da `flutter analyze`
- ✅ **Testing phase** - Commit frequenti = cronologia dettagliata

**📚 Documentazione Completa**: `scripts/CHECKPOINT_README.md`

**⚙️ Configurazione Custom**:
```bash
# Soglia personalizzata (100 righe)
./scripts/checkpoint.sh --threshold 100

# Intervallo check (60 secondi invece di 30)
./scripts/checkpoint.sh --watch --interval 60
```

**🔧 Best Practice**:
1. Watch mode in background durante sviluppo attivo
2. Squash checkpoint commits prima di push: `git rebase -i HEAD~5`
3. Stoppa watch quando finisci sessione (Ctrl+C)

---

## 🎯 REGOLA #14: TASKMASTER.DEV INTEGRATION - FASE 1 (AUTOMATIC)

> **⚠️ COMPORTAMENTO OBBLIGATORIO**: Claude automaticamente rileva richieste complesse e propone task-master.dev planning.

### 🧠 Smart Detection Logic (Automatic Trigger)

**Quando ricevi una richiesta dell'utente, ANALIZZA automaticamente la complessità:**

```
Richiesta utente ricevuta
         ↓
Analizza complessità:
1. ✓ Lunghezza > 50 parole?
2. ✓ Keyword presente? ("implement", "refactor", "migrate", "create system", "add feature")
3. ✓ Multi-layer mention? ("domain + data + presentation", "full stack", "end-to-end")
4. ✓ Milestone mention? ("fase 1", "milestone 2", "step by step")
         ↓
Se 2+ condizioni soddisfatte → TRIGGER task-master.dev proposal
```

**Trigger Keywords** (case-insensitive):
- `implement`, `implementa`, `create`, `crea`
- `refactor`, `migrate`, `migra`
- `system`, `sistema`, `feature`
- `add`, `aggiungi`, `build`, `costruisci`
- `milestone`, `fase`, `phase`, `step`

**Example Triggers**:
- ✅ "Implement analytics system with charts" (keyword + system + >50 words)
- ✅ "Refactor workout timer to use background tasks" (keyword + refactor)
- ✅ "Create onboarding flow with 5 screens" (keyword + multi-component)
- ❌ "Fix typo in button text" (too simple, <50 words)
- ❌ "Update color to blue" (trivial task)

### 💬 Automatic Proposal (When Triggered)

**Quando triggered, SEMPRE proponi task-master.dev PRIMA di implementare:**

```dart
"🤖 Ho rilevato una richiesta complessa:
   - Lunghezza: {word_count} parole
   - Keyword rilevata: '{keyword}'
   - Stima complessità: {HIGH/MEDIUM}

   Vuoi che usi task-master.dev per decomporre questo progetto
   in task gestibili?

   [Sì] → Genero piano dettagliato con task-master.dev
   [No, procedi diretto] → Implemento direttamente
   [Mostra preview] → Ti mostro cosa farebbe task-master.dev"
```

**User Response Handling**:
- **Sì**: Procedi con WebFetch call
- **No**: Implementa direttamente (crea TodoWrite basico 3-5 task)
- **Mostra preview**: Spiega cosa farebbe task-master.dev (non chiamarlo ancora)

### 🌐 WebFetch Integration (Core Workflow)

**Step 1: Prepare WebFetch Prompt**

```
User request: "{original_request}"
         ↓
Enriched prompt for task-master.dev:
"Break down the following Flutter/Dart development task into
 manageable, atomic tasks following Clean Architecture pattern:

 Task: {original_request}

 Context:
 - Framework: Flutter
 - Architecture: Clean Architecture (Domain/Data/Presentation)
 - State Management: Riverpod 2.x
 - Platforms: iOS 14+, Android 8+
 - Key requirements: Localization (EN/IT), Theme support (dark/light)

 Output format:
 - Task list with category grouping
 - Estimated time per task (15min - 1.5h max)
 - Dependencies between tasks
 - Verification criteria per task

 Provide 8-15 tasks total."
```

**Step 2: Execute WebFetch Call**

```dart
WebFetch(
  url: "https://www.task-master.dev/",
  prompt: enriched_prompt
)
```

**Step 3: Handle WebFetch Response**

```
WebFetch returns task list
         ↓
Parse response (markdown/structured text)
         ↓
Enrich with Flutter/FitLog Pro specifics:
- Add "Localization" task if missing
- Add "Theme compliance" task if missing
- Add "flutter analyze" task if missing
- Add file paths (lib/features/{feature}/)
- Add test tasks if missing
         ↓
Generate plan document (next section)
```

**Fallback Strategy** (if WebFetch fails):

```
WebFetch timeout/error
         ↓
Claude: "⚠️ task-master.dev non disponibile.

         Opzioni:
         A) Riprovo tra 30 secondi
         B) Genero piano manualmente (Claude autonomo)
         C) Procedo diretto senza planning"
         ↓
User sceglie B
         ↓
Claude genera task breakdown autonomamente usando:
- Analisi della richiesta
- Conoscenza architettura Flutter + FitLog Pro
- Pattern da docs/NAVIGATION/INDEX.md
         ↓
Plan salvato con nota:
  **Source**: Claude Code (task-master.dev unavailable)
  **Fallback**: Manual task breakdown
```

### 📄 Plan Template Generator (Automatic)

**Quando task-master.dev (o fallback) ha generato task list, AUTOMATICAMENTE:**

**Step 1: Read Current Flutter/Project Context**

```bash
# Leggi automaticamente per metadata:
cat pubspec.yaml | grep "version:" # Flutter version
cat pubspec.yaml | grep "riverpod:" # Riverpod version
git log -1 --format="%h %s" # Last commit
git status --short # Modified files
```

**Step 2: Fill Plan Template**

Usa template da `docs/plans/2025-01-15-taskmaster-integration-design.md` (sezione "Plan Document Template v2.0").

**Required Placeholders**:
- `{Topic Title}`: Estratto da user request (es. "Analytics System")
- `{YYYY-MM-DD HH:mm}`: Current timestamp
- `{Complexity Score}`: HIGH (16+ tasks) / MEDIUM (6-15) / LOW (1-5)
- `{Total Tasks}`: Count from task-master.dev response
- `{Estimated Time}`: Sum of individual task estimates
- `{Flutter Version}`: From pubspec.yaml
- `{User's original request verbatim}`: Full user message

**Step 3: Auto-categorize Tasks**

```
task-master.dev tasks → Group by category:
1. Domain Layer (entities, repositories interfaces)
2. Data Layer (repository impl, data sources)
3. Presentation Layer (providers, screens, widgets)
4. Testing (unit, widget, integration tests)
5. Localization & Theme (strings, theme compliance)
6. Documentation (update INDEX.md, CLAUDE.md)
```

**Step 4: Validate Plan Quality**

```
Before saving, auto-validate:

✓ All tasks have:
  - Description (not empty)
  - Layer specified
  - Files path (lib/features/{feature}/...)
  - Estimated time (15min - 1.5h)

✓ FitLog Pro requirements included:
  - Localization task present
  - Theme compliance task present
  - flutter analyze task present
  - Test tasks present (unit + widget)

✓ Dependencies are valid:
  - No circular dependencies (Task A → B → A)
  - Blocking tasks come first

If validation fails → Auto-fix:
- Add missing FitLog Pro tasks
- Fix circular dependencies
- Fill missing file paths
```

### 📝 Example Generated Plan (Preview)

```markdown
# Analytics System - Task Plan

**Generated**: 2025-01-15 16:30
**Source**: task-master.dev (WebFetch)
**Complexity Score**: HIGH
**Reason**: New feature + Multi-system integration + 12 tasks
**Total Tasks**: 12
**Estimated Time**: ~5.5h
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: 3.16.0
- Key Packages: riverpod ^2.4.9, firebase_core ^2.24.2
- Target Platforms: iOS 14+, Android 8+
- Related PRs/Issues: None
- Parent Milestone: None

---

## 📋 Original Request

> Implement analytics system with charts and metrics for workout tracking

---

## 🎯 Task Breakdown

### 1. Domain Layer

- [ ] **Task 1.1**: Create AnalyticsData entity
  - **Layer**: Domain
  - **Files**: `lib/features/analytics/domain/entities/analytics_data.dart`
  - **Dependencies**: None
  - **Est. Time**: 30 min
  - **Blocking**: Yes (blocks Task 1.2, 2.1)
  - **Verification**: Entity compiles + freezed code generated
  - **Code Prompt**:
    ```
    Create AnalyticsData entity with freezed + json_serializable
    Fields: userId, workoutMetrics, dateRange, totalVolume
    ```

... (11 more tasks)

---

## 📊 Implementation Order

**MUST DO FIRST** (blocking tasks):
→ Task 1.1, 1.2 (domain foundation) - ~50 min

**THEN** (parallel workable):
→ Task 2.1, 2.2 (data layer) - ~1.5h

**FINALLY**:
→ Task 4.1-4.3 (UI) - ~2h
→ Task 5.1 (testing) - ~1h

**Total Critical Path**: ~5.5h
```

### 💾 Plan Document Save Workflow

**Dopo plan generation e validation, SEMPRE salva in docs/plans/:**

**Step 1: Generate Filename**

```
Topic extracted from user request → filename slug

Example:
"Implement analytics system" → "analytics-system"
"Refactor workout timer" → "workout-timer-refactor"
"Migrate to Riverpod 2" → "migrate-riverpod-2"

Filename format: YYYY-MM-DD-{topic-slug}-plan.md
Example: 2025-01-15-analytics-system-plan.md
```

**Step 2: Save to Local docs/plans/**

```dart
// Note: docs/plans/ is in .gitignore (local only)
Write plan to: /Users/michele/gymbro_flutter_new/docs/plans/{filename}
```

**Step 3: Confirm Save**

```
Claude: "✅ Piano salvato localmente:
         docs/plans/{filename}

         📊 Riepilogo:
         - Total Tasks: {count}
         - Estimated Time: {hours}
         - Complexity: {HIGH/MEDIUM/LOW}

         Vuoi che crei TodoWrite basato su questo piano?"
```

### 📝 TodoWrite Conversion (Basic - Fase 1)

**Quando user conferma, converti plan → TodoWrite:**

**Smart Grouping Logic**:

```
Plan task count → TodoWrite strategy:

<10 tasks: Direct mapping (1:1)
→ TodoWrite shows all tasks individually

10-20 tasks: Category grouping
→ TodoWrite shows categories as items:
  - [ ] Complete Domain layer (5 sub-tasks)
  - [ ] Complete Data layer (6 sub-tasks)
  - [ ] Complete Presentation layer (4 sub-tasks)

>20 tasks: Milestone grouping
→ Claude asks user:
  "Piano complesso con {count} task. TodoWrite:
   A) Tutti i task (verbose)
   B) Milestone aggregate (recommended)
   C) Solo fasi MUST DO FIRST/THEN/FINALLY"
```

**TodoWrite Format Mapping**:

```dart
Plan task:
- [ ] **Task 1.1**: Create AnalyticsData entity
  - **Layer**: Domain
  - **Est. Time**: 30 min

TodoWrite item:
{
  content: "Create AnalyticsData entity (Domain layer)",
  activeForm: "Creating AnalyticsData entity",
  status: "pending"
}
```

**Two-Way Sync**:

```
User marks task complete in TodoWrite
         ↓
Claude automatically:
1. Updates plan document (checkbox ✓)
2. Adds timestamp to "Notes & Decisions"
3. Offers to auto-commit plan update (if Task 7 implemented)

Example update in plan.md:
- [x] **Task 1.1**: Create AnalyticsData entity ← Auto-updated
  **Completed**: 2025-01-15 14:30

Notes & Decisions:
- **2025-01-15 14:30**: Task 1.1 completed. Entity created
  with freezed + json_serializable as planned.
```

### 🎯 Golden Rules - Task-Master.dev Integration

1. **SEMPRE rileva complessità** prima di implementare
2. **SEMPRE proponi** task-master.dev se triggered (non assumere "no")
3. **SEMPRE arricchisci** con Flutter/FitLog Pro requirements
4. **SEMPRE valida** plan quality prima di salvare
5. **SEMPRE salva** plan in docs/plans/ (local)
6. **SEMPRE crea** TodoWrite dopo plan save
7. **MAI skip** proposal step (anche se sei sicuro)

**Quando in dubbio**: Proponi task-master.dev. È SEMPRE meglio over-plan che under-plan.

**Note**: docs/plans/ è in .gitignore → file restano locali (no git tracking).

### 🚫 Auto-Commit (Disabled in Fase 1)

**Status**: Feature disponibile ma DISABILITATO per default

**Perché disabilitato**:
- docs/plans/ è in .gitignore (scelta deliberata dell'utente)
- Plan documents sono per uso locale / session tracking
- Git tracking non necessario per Fase 1

**Se abilitato in futuro** (Fase 2/3):
1. Rimuovi docs/plans/ da .gitignore
2. Auto-commit workflow:
   ```bash
   git add docs/plans/{filename}
   git commit -m "docs: add {topic} task plan

   Generated by task-master.dev integration
   - Total tasks: {count}
   - Estimated time: {hours}
   - Complexity: {score}

   Plan: docs/plans/{filename}
   ```

**Alternative** (già attivo):
- ✅ CONTEXT.md e LEARNINGS.md già creati (committable se necessario)
- ✅ Plan documents salvati localmente per reference
- ✅ TodoWrite tracking per execution

### 📦 CONTEXT.md Auto-Update (For 5+ Milestones)

**File**: `docs/plans/CONTEXT.md` (already created)

**When to Update** (Claude detects automatically):

```
User completes Milestone 1
         ↓
Claude detects: Feature with 5+ total milestones planned
         ↓
Claude automatically offers:
"🎯 Feature complessa rilevata (5+ milestones).
   Vuoi che aggiorni CONTEXT.md per tracciare dependencies?"
         ↓
User: "Sì"
         ↓
Claude updates CONTEXT.md automatically
```

**Auto-Update Triggers**:
1. ✅ Milestone completion (from retrospective)
2. ✅ New plan created with "Parent Milestone: M{X}" metadata
3. ✅ User mentions "milestone {X} done" in chat
4. ✅ Tech debt discovered during implementation

**What Claude Updates**:

```markdown
## 📦 Milestone {X}: {Feature Name} (✅ Complete)

**Plan**: [YYYY-MM-DD-{topic}-plan.md](./YYYY-MM-DD-{topic}-plan.md)
**Completed**: {timestamp}
**Actual Time**: {hours}h (estimated: {est_hours}h)

**Key Decisions** (inherited by M{X+1}):
- ✅ {Decision 1 from retrospective}
- ✅ {Decision 2 from "Notes & Decisions"}

**Artifacts Created**:
- `lib/features/{feature}/{layer}/{file}.dart`
- ...

**Tech Debt Introduced**:
- {Debt description} ({SEVERITY} severity) → Cleanup in M{X+1}

**Blocks**: M{X+1} ({Next milestone name})
```

**Cross-Milestone Dependency Tracking**:

Claude automatically populates next milestone plan with:

```markdown
## 🔗 Cross-Milestone Dependencies

**Inherited from Milestone {X}**:
- [ ] **Design Decision**: {from CONTEXT.md}
- [ ] **Code Artifacts**: {files from M{X}}
- [ ] **Tech Debt**: {known issues to address}

**Important**: If Milestone {X} not completed, this plan will fail.
**Dependency chain**: M{X}.{Y} → M{X}.{Z} → M{current}.{1}
```

### 📚 LEARNINGS.md Auto-Population (Post-Retrospective)

**File**: `docs/plans/LEARNINGS.md` (already created)

**When to Update** (Claude automatic):

```
Milestone retrospective completed in plan.md
         ↓
Claude extracts learnings automatically:
- Estimation patterns
- Common pitfalls
- Successful patterns
- Tech stack insights
         ↓
Updates LEARNINGS.md
         ↓
Applies adjustments to FUTURE estimates
```

**What Claude Extracts**:

**1. Estimation Patterns** (from "Execution" section):

```
Milestone plan said: "Task 1.1: 30 min"
Actual: 45 min
         ↓
Claude updates LEARNINGS.md:

| Task Type | Initial Estimate | Actual Average | Adjustment Factor |
|-----------|------------------|----------------|-------------------|
| Entity creation | 30 min | 45 min | +50% (+15 min) |
         ↓
Next time Claude estimates "Entity creation" → auto-adds 15 min buffer
```

**2. Common Pitfalls** (from "Learnings" section):

```
Retrospective says:
"Firebase security rules always take longer (estimated 30, took 45)"
         ↓
Claude adds to LEARNINGS.md:

### Firebase Security Rules Always Take Longer
- **Origin**: M1 Analytics (2025-01-15)
- **Issue**: Estimated 30 min, took 45 min
- **Solution**: Always add +15 min buffer to Firebase tasks
         ↓
Next Firebase task → Claude suggests adjusted estimate
```

**3. Successful Patterns** (from "Carry-forward" section):

```
Retrospective says:
"Good: Task ordering by layer worked perfectly"
         ↓
Claude adds to LEARNINGS.md:

### Task Ordering by Layer (Domain → Data → Presentation)
- **Origin**: M1-M3 Analytics (all milestones)
- **Keep doing**: Always order tasks by architectural layer
         ↓
Future plans → Claude auto-orders tasks by layer
```

**Auto-Application to Future Plans**:

```
User: "Implement user profile system"
         ↓
Claude generates plan
         ↓
Before saving, Claude applies LEARNINGS.md adjustments:

Original estimate (task-master.dev): "Entity creation - 30 min"
Adjusted (from LEARNINGS.md): "Entity creation - 45 min (+50% buffer)"

Note added to plan:
"⚙️ Estimate adjusted based on pattern from {X} previous milestones"
```

**🔧 Script-Based Extraction** (Optional, Manual):

For bulk extraction from git history (when you have many completed milestones):

```bash
# Extract learnings from git commits (last 6 months)
./scripts/extract_learnings.sh

# Extract from specific date
./scripts/extract_learnings.sh --since "2024-01-01"

# Dry-run (preview without updating)
./scripts/extract_learnings.sh --dry-run --verbose
```

**What the script extracts**:
- ✅ Estimation patterns from plan retrospectives (avg estimated vs actual)
- ✅ Common pitfalls from "fix:", "bug:", "issue:" commits (recurring themes)
- ✅ Successful patterns from "feat:", "improve:" commits (what works)
- ✅ Tech stack insights (Firebase, Localization, Theme, iOS, etc.)

**When to use**:
- 📅 Monthly review: Extract patterns from completed work
- 🚀 After 3+ milestone completions: Enough data for meaningful patterns
- 🔄 Before major refactor: Learn from past mistakes
- 📊 Quarterly planning: Adjust future estimates based on history

**Output**: Updates `docs/plans/LEARNINGS.md` with discovered patterns

---

### 📦 Plan Versioning Automation (AUTOMATIC)

**Auto-Versioning Behavior** (Claude automatic):

```
User requests modification to existing plan
         ↓
Claude detects: "docs/plans/YYYY-MM-DD-{topic}-plan.md already exists"
         ↓
AUTOMATIC WORKFLOW:
1. Read current plan version (e.g., v1.0)
2. Increment version (v1.0 → v1.1)
3. Log version history with delta
4. Update plan document
5. Preserve old version in history section
```

**Version Detection Logic**:

```markdown
# Plan document header check
**Plan Version**: 1.0

         ↓ (modification requested)

**Plan Version**: 1.1
```

**Version History Section** (auto-appended to plan):

```markdown
---

## 📝 Version History

### v1.1 - {YYYY-MM-DD HH:MM}

**Changes**:
- ✏️ Modified task 3.2: Added Firebase security rules validation
- ➕ Added new task 4.1: Integration testing
- 🔄 Reordered tasks: 2.3 now blocks 3.1 (dependency added)
- 📊 Updated time estimate: 4.5h → 5.5h (+1h)

**Reason**: User feedback after M1 completion

**Modified by**: Claude Code (automatic)

---

### v1.0 - {YYYY-MM-DD HH:MM}

**Initial plan generation** via task-master.dev API

**Total Tasks**: 12
**Estimated Time**: ~4.5h

---
```

**Delta Tracking** (Claude computes automatically):

```
Old plan (v1.0):
- [ ] Task 3.2: Implement workout analytics (30 min)

New plan (v1.1):
- [ ] Task 3.2: Implement workout analytics with Firebase security (45 min)
         ↓
Delta computed:
"✏️ Modified task 3.2: Added Firebase security rules validation (+15 min)"
```

**When to Create New Version** (auto-detect):

| Scenario | Version Increment | Example |
|----------|-------------------|---------|
| ✅ Task added/removed | MINOR (1.0 → 1.1) | Added task 4.1 |
| ✅ Task modified (scope change) | MINOR (1.0 → 1.1) | Task 3.2 now includes security |
| ✅ Dependencies changed | MINOR (1.0 → 1.1) | Task 2.3 now blocks 3.1 |
| ✅ Time estimate changed >30% | MINOR (1.0 → 1.1) | 4.5h → 5.5h |
| ✅ Complexity upgraded (MEDIUM→HIGH) | MAJOR (1.0 → 2.0) | Architecture changed |
| ❌ Typo fixes, formatting | NO INCREMENT | Fixed typo in task 2.1 |
| ❌ Completion status update | NO INCREMENT | Marked task 1.1 complete |

**Automatic Version Commit Message**:

```bash
git commit -m "docs: update {topic} plan to v1.1

Changes:
- Modified task 3.2 (added security rules)
- Added task 4.1 (integration testing)
- Updated time estimate 4.5h → 5.5h

Plan version: 1.0 → 1.1"
```

**Version Rollback Support**:

Claude can restore previous version from history:

```
User: "Rollback plan to v1.0"
         ↓
Claude extracts v1.0 from Version History section
         ↓
Creates new v1.2 with v1.0 content
         ↓
Note: "⏮️ Restored from v1.0 (rolled back v1.1 changes)"
```

**Cross-Reference with CONTEXT.md**:

Version changes auto-update CONTEXT.md milestone table:

```markdown
| Milestone | Feature | Status | Plan Version | Last Updated |
|-----------|---------|--------|--------------|--------------|
| M1 | Analytics | ✅ Complete | v1.2 | 2025-01-15 |
| M2 | Dashboard | 🔄 In Progress | v1.1 | 2025-01-15 |
```

---

> **⚠️ TESTING PHASE**: App in sviluppo con solo lo sviluppatore come utente. Breaking changes e migrazioni aggressive sono permesse. Seguire SEMPRE le regole di clean code sopra.