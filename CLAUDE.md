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

**Documentazione chiave**: `DESIGN_GUIDELINES.md` (design system), `TIMER_SYSTEM_DOCUMENTATION.md` (timer), `ANALYTICS_SYSTEM_DOCUMENTATION.md` (analytics), `USER_PROFILE_DOCUMENTATION.md` (auth), `WORKOUT_SYSTEM_OVERVIEW.md` (workout), `ROUTINE_CENTER_SYSTEM_REPORT.md` (routine), `APRE_INDEX.md` (APRE)

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

**CLAUDE.md Auto-Staging** (ATTIVO):
- ✅ CLAUDE.md viene **automaticamente staged** se modificato
- ✅ Incluso nella commit corrente (no commit separati)
- ✅ Implementato nel pre-commit hook (check #8/8)

**Workflow**:
```bash
# 1. Modifica CLAUDE.md
vim CLAUDE.md

# 2. Commit normale (hook auto-aggiunge CLAUDE.md)
git commit -m "feat: add new feature"

# Output del hook:
# [8/8] Checking CLAUDE.md auto-staging...
# 📝 Auto-staging CLAUDE.md (modified)...
# ✅ CLAUDE.md added to commit
```

---

> **⚠️ TESTING PHASE**: App in sviluppo con solo lo sviluppatore come utente. Breaking changes e migrazioni aggressive sono permesse. Seguire SEMPRE le regole di clean code sopra.