# 🤖 CLAUDE.md - Istruzioni Progetto

> **IMPORTANTE**: Questo file contiene le regole obbligatorie per lavorare su questo progetto Flutter.

## 📱 Progetto: FitLog Pro
**Framework**: Flutter | **Architettura**: Clean Architecture + Riverpod | **Stato**: ⚠️ **TESTING PHASE** - Solo utente sviluppatore

> **🧪 NOTA TESTING**: L'app è attualmente in fase di sviluppo e testing con UN SOLO UTENTE (lo sviluppatore).
> **Non esiste base utenti** → Possiamo fare **breaking changes** e **migrazioni dati** senza preoccupazioni di compatibilità retroattiva.
> **Refactoring aggressivi sono permessi** per migliorare architettura e performance.

---

## 📚 STEP 0: LEGGI LA DOCUMENTAZIONE PRIMA DI IMPLEMENTARE

**⚠️ OBBLIGATORIO PRIMA DI QUALSIASI MODIFICA:**

### 🔍 Prima di implementare una feature:

1. **LEGGI** [`docs/NAVIGATION/INDEX.md`](docs/NAVIGATION/INDEX.md) - Mappa completa della documentazione
2. **TROVA** la documentazione della feature che devi implementare/modificare
3. **LEGGI** tutta la documentazione correlata (architettura, esempi, best practices)
4. **IMPLEMENTA** seguendo i pattern documentati
5. **AGGIORNA** la documentazione se necessario

### 📖 Documentazione Disponibile per Feature:

| Feature | Documentazione | Quando Leggerla |
|---------|----------------|-----------------|
| **📚 Comprehensive App Docs** | `docs/STRUTTURA_DATI.md`, `ARCHITETTURA_APP.md`, `SCHERMATE_PRINCIPALI.md`, `FLUSSI_UTENTE.md`, `FEATURES_IMPLEMENTATE.md`, `PROBLEMATICHE_LIMITAZIONI.md` | **ONBOARDING** - Per capire l'intera app (5,445 righe totali) |
| **🎨 Design System** | `docs/DESIGN_GUIDELINES.md` | **SEMPRE** - Prima di creare widget, colori, spacing, animazioni |
| **🎯 UI Flows & Components** | `docs/GymBro-UI-Flows.md` | **UI/UX DEVELOPMENT** - User flows dettagliati, componenti UI con codice Dart completo, interaction patterns |
| **🏋️ Design & Architecture Report** | `docs/GymBro-Design-Report.md` | **ARCHITECTURE REVIEW** - Executive summary, issues identificati, soluzioni proposte, KPIs, roadmap |
| **Timer & Rest Timer** | `docs/UX_FLOWS/notifications_background/TIMER_SYSTEM_DOCUMENTATION.md` | Prima di modificare timer, Live Activities, audio feedback |
| **Analytics & Progress** | `docs/UX_FLOWS/home_dashboard/ANALYTICS_SYSTEM_DOCUMENTATION.md` | Prima di modificare metriche, PR detection, chart data |
| **User Profile & Auth** | `docs/UX_FLOWS/user_account/USER_PROFILE_DOCUMENTATION.md` | Prima di modificare auth, account tiers, quota |
| **Premium & IAP** | `docs/UX_FLOWS/user_account/PREMIUM_IAP_DOCUMENTATION.md` | Prima di modificare subscriptions, IAP, sync premium |
| **Workout History** | `docs/UX_FLOWS/home_dashboard/WORKOUT_HISTORY_DOCUMENTATION.md` | Prima di modificare history, editing, export |
| **Workout Session** | `docs/UX_FLOWS/workout_session/WORKOUT_SYSTEM_OVERVIEW.md` | Prima di modificare workout flow principale |
| **Exercise Database** | `docs/UX_FLOWS/exercise_database/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md` | Prima di modificare esercizi, feedback, sync |
| **Routine Center** | `docs/UX_FLOWS/routine_center/ROUTINE_CENTER_SYSTEM_REPORT.md` | Prima di modificare routine, swap flow, templates |
| **APRE System** | `docs/APRE/APRE_INDEX.md` → Start here, poi `APRE_SYSTEM_EXPLORATION.md` (sistema completo), `APRE_ACTION_ITEMS.md` (implementazione) | Prima di modificare APRE protocol, 1RM calculation, auto-adjustment |

### 🎯 Workflow Completo:

```
1. Ricevi richiesta di implementare feature X
   ↓
2. LEGGI docs/NAVIGATION/INDEX.md
   ↓
3. TROVA sezione "Quick Navigation by Task"
   ↓
4. SEGUI link alla documentazione di feature X
   ↓
5. LEGGI documentazione completa (architettura + esempi)
   ↓
6. LEGGI documentazione correlata (se presente)
   ↓
7. IMPLEMENTA seguendo pattern documentati
   ↓
8. TESTA secondo guida di testing
   ↓
9. AGGIORNA documentazione se hai fatto modifiche significative
   ↓
10. COMMIT con messaggio descrittivo
```

**❌ MAI**: Implementare una feature senza aver letto la documentazione esistente
**✅ SEMPRE**: Consultare INDEX.md → Trovare docs → Leggere → Implementare → Aggiornare

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

### 📐 1. AppIcons Centralizzate (100% Coverage)

**SEMPRE** usa `AppIcons.*` - MAI `Icons.*` direttamente

```dart
// ✅ CORRETTO - Icona centralizzata
Icon(AppIcons.workout)
Icon(AppIcons.analytics)
Icon(AppIcons.settings)

// ❌ SBAGLIATO - Icona inline (Material Icons diretti)
Icon(Icons.fitness_center)
Icon(Icons.bar_chart)
Icon(Icons.settings)
```

**Status**: ~445 icone centralizzate (Phase 1+2+3 COMPLETE)
**Import**: `import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';`

### 📏 2. AppIconSize - Semantic Sizing (NEW)

**SEMPRE** usa `AppIconSize.*` constants - MAI magic numbers

```dart
// ✅ CORRETTO - Semantic sizing
Icon(AppIcons.workout, size: AppIconSize.medium)
Icon(AppIcons.timer, size: AppIconSize.large)
Icon(AppIcons.badge, size: AppIconSize.tiny)

// ❌ SBAGLIATO - Magic numbers
Icon(AppIcons.workout, size: 24)
Icon(AppIcons.timer, size: 28)
Icon(AppIcons.badge, size: 16)
```

**Available Sizes**:
- `tiny` (16dp) - Badge icons, small indicators
- `small` (20dp) - Chip icons, compact UI
- `medium` (24dp) - **Default**, standard icons
- `large` (28dp) - Featured icons, emphasis
- `xlarge` (32dp) - Header icons, primary actions
- `xxlarge` (48dp) - Empty states, hero sections

**Context-Specific**: `tabBar`, `buttonPrimary`, `card`, `listTile`, `emptyState`, `loading`

**Import**: `import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';`

### 🎨 3. Semantic Icon Colors (NEW)

**SEMPRE** usa `context.icon*` - MAI hardcoded colors

```dart
// ✅ CORRETTO - Semantic colors
Icon(AppIcons.workout, color: context.iconPrimary)
Icon(AppIcons.success, color: context.iconSuccess)
Icon(AppIcons.error, color: context.iconError)

// ❌ SBAGLIATO - Hardcoded colors
Icon(AppIcons.workout, color: Colors.blue)
Icon(AppIcons.success, color: Colors.green)
Icon(AppIcons.error, color: Colors.red)
```

**Available Colors**:
- **Primary**: `iconPrimary`, `iconSecondary`, `iconTertiary`
- **Semantic**: `iconSuccess`, `iconError`, `iconWarning`, `iconInfo`
- **Emphasis**: `iconDefault`, `iconMediumEmphasis`, `iconLowEmphasis`, `iconDisabled`
- **Inverse**: `iconOnPrimary`, `iconOnSecondary`
- **Workout**: `iconWorkoutActive`, `iconRestTimer`, `iconPersonalRecord`, `iconProgress`

**Helpers**:
- `context.iconStateActive(bool)` - Green if active, gray if not
- `context.iconProgressColor(double %)` - Red/orange/green based on %
- `context.iconPriority(String)` - Error/warning/normal based on priority

**Import**: `import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';`

### ♿ 4. SemanticIcon - Accessibility (NEW)

**SEMPRE** usa `SemanticIcon` per accessibilità screen readers

```dart
// ✅ CORRETTO - Accessible icon
SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: context.l10n.startWorkout,
  size: AppIconSize.medium,
  color: context.iconPrimary,
)

// ✅ CORRETTO - Shorthand extension
AppIcons.workout.semantic(
  label: context.l10n.startWorkout,
  size: AppIconSize.large,
)

// ❌ SBAGLIATO - Icon senza semantic label (screen reader non lo legge)
Icon(AppIcons.workout)
```

**Factory Constructors**:
- `SemanticIcon.button()` - For interactive icons (isButton: true)
- `SemanticIcon.state()` - For toggle states (active/inactive labels)

**Import**: `import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';`

### 🎬 5. AnimatedIconPatterns - Reusable Animations (NEW)

Usa pattern riusabili invece di duplicare animation code

```dart
// ✅ CORRETTO - Reusable pattern
AnimatedIconPatterns.rotating(
  icon: AppIcons.loading,
  duration: Duration(seconds: 2),
  color: context.iconPrimary,
)

AnimatedIconPatterns.pulsing(
  icon: AppIcons.notification,
  scaleAmount: 0.2,
  color: context.iconError,
)

AnimatedIconPatterns.shaking(
  icon: AppIcons.error,
  trigger: hasError,
  color: context.iconError,
)

// ❌ SBAGLIATO - Animation code duplicato ovunque
RotationTransition(...) // ogni volta diverso
```

**Available Patterns**:
- `rotating()` - Infinite spin (loading indicators)
- `pulsing()` - Scale animation (call-to-action)
- `bouncing()` - Elastic entrance (notifications)
- `fading()` - Opacity transitions (state changes)
- `shaking()` - Horizontal shake (errors)

**Import**: `import 'package:gymbro_flutter_new/shared/presentation/widgets/animated_icon_patterns.dart';`

### 🔴 6. BadgedIcon - Unified Badges/Counters (NEW)

Usa `BadgedIcon` per notification counts e dot indicators

```dart
// ✅ CORRETTO - Notification badge
BadgedIcon.notification(
  icon: AppIcons.notifications,
  count: 5,
)

// ✅ CORRETTO - Dot indicator
BadgedIcon.dot(
  icon: AppIcons.mail,
  showDot: hasUnread,
)

// ✅ CORRETTO - Shorthand extension
AppIcons.notifications.withBadge(count: 3)
AppIcons.mail.withDot(showDot: true)

// ❌ SBAGLIATO - Badge code duplicato ovunque
Stack(
  children: [
    Icon(...),
    Positioned(top: -2, right: -4, child: Container(...)), // ogni volta diverso
  ],
)
```

**Features**:
- Auto-sizing (dot: 8dp, single digit: 16dp, multi-digit: 20dp)
- Handles counts > 99 as "99+"
- Border for separation from background
- Customizable position with offset

**Import**: `import 'package:gymbro_flutter_new/shared/presentation/widgets/badged_icon.dart';`

### 🔍 7. Icon Showcase - Discovery Tool (NEW)

**Per sviluppatori**: Screen per esplorare tutte le 445 icone

```dart
// Navigate to showcase
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => IconShowcaseScreen()),
);
```

**Features**:
- Search/filter per nome
- Category grouping (11 categorie)
- Tap to copy "AppIcons.iconName"
- Visual preview di tutte le icone

**Location**: `lib/shared/presentation/screens/icon_showcase_screen.dart`

### 📦 8. AppIconCategory - Type-Safe Organization (NEW - Priority 3)

**Enum-based categories** per organizzare le 445 icone in modo type-safe

```dart
// ✅ CORRETTO - Type-safe category access
final workoutIcons = AppIconCategory.workout.icons;
final timerIcons = AppIconCategory.timer.icons;

// ✅ CORRETTO - Check icon category
if (AppIcons.workout.category == AppIconCategory.workout) {
  // This icon belongs to workout category
}

// ✅ CORRETTO - Find category for any icon
final category = AppIconCategory.categoryFor(AppIcons.timer);
print(category?.displayName); // "Timer"

// ❌ SBAGLIATO - String-based categories (no compile-time safety)
final icons = getCategoryIcons('workout'); // typo = runtime error
```

**Available Categories** (11 total):
- `workout` - Exercise and training icons
- `timer` - Time tracking and scheduling
- `analytics` - Data visualization and metrics
- `status` - State and feedback indicators
- `action` - User actions and CRUD operations
- `navigation` - Navigation and directional
- `social` - Social and user interaction
- `settings` - Configuration and settings
- `premium` - Premium features
- `media` - Media playback and capture
- `misc` - Utility and miscellaneous

**Methods**:
- `category.icons` - Get all icons in category as `Map<String, IconData>`
- `category.contains(icon)` - Check if icon belongs to category
- `AppIconCategory.categoryFor(icon)` - Get category for any icon
- `AppIconCategory.allIcons` - Get all icons across all categories
- `icon.category` - Extension to get category from IconData

**Import**: `import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_category.dart';`

### 🔄 9. AppIconVariants - Outlined/Filled Alternatives (NEW - Priority 3)

**Factory system** per icone con varianti filled/outlined (perfetto per toggle states)

```dart
// ✅ CORRETTO - Toggle between filled/outlined
Icon(
  isActive
    ? AppIconVariants.star.filled
    : AppIconVariants.star.outlined,
)

// ✅ CORRETTO - Using ToggleIcon widget
ToggleIcon(
  isActive: isFavorite,
  variant: AppIconVariants.star,
  activeColor: context.iconSuccess,
  inactiveColor: context.iconDisabled,
)

// ✅ CORRETTO - Extension toggle
Icon(AppIcons.star.toggled) // Switch between filled/outlined

// ❌ SBAGLIATO - Hardcoding both variants
Icon(isFavorite ? Icons.star : Icons.star_border)
```

**Available Variants** (13 pre-defined):
- **Status**: `checkCircle`, `star`, `info`, `error`
- **Action**: `addCircle`, `delete`
- **Social**: `people`, `thumbUp`, `thumbDown`
- **Media**: `playCircle`, `pauseCircle`
- **Navigation**: `home`, `settings`

**Features**:
- `variant.filled` - Get filled variant
- `variant.outlined` - Get outlined variant (nullable)
- `variant.outlinedOrFilled` - Fallback to filled if no outlined
- `variant.hasOutlined` - Check if outlined variant exists
- `icon.outlined` / `icon.filled` - Extensions for dynamic lookup
- `icon.toggled` - Smart toggle between variants

**Import**: `import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_variants.dart';`

### 📚 10. AppIconMetadata - Rich Discovery System (NEW - Priority 3)

**Metadata completo** per ogni icona: descrizioni, use cases, keywords, semantic labels suggeriti

```dart
// ✅ CORRETTO - Get metadata
final metadata = AppIcons.workout.metadata;
print(metadata?.description); // "Exercise and workout tracking"
print(metadata?.suggestedSemanticLabel); // "Workout"

// ✅ CORRETTO - Search by keyword
final results = AppIconMetadata.search('timer');
for (final entry in results) {
  print(entry.key); // IconData
  print(entry.value.description); // IconMetadata
}

// ✅ CORRETTO - Get related icons
final relatedIcons = AppIcons.cardio.relatedIcons;
// Returns: [AppIcons.workout, AppIcons.speed]

// ✅ CORRETTO - Get suggested semantic label
SemanticIcon(
  icon: AppIcons.timer,
  semanticLabel: AppIcons.timer.suggestedSemanticLabel ?? 'Timer',
)
```

**Metadata Fields**:
- `description` - Human-readable description
- `useCases` - Suggested use cases (List<String>)
- `relatedIcons` - Alternative/complementary icons (List<IconData>)
- `suggestedSemanticLabel` - WCAG 2.1 AA accessibility label
- `keywords` - Search keywords/tags (List<String>)
- `platformNotes` - iOS/Android specific notes (optional)
- `exampleUsage` - Code example (optional)

**Methods**:
- `AppIconMetadata.metadataFor(icon)` - Get metadata for specific icon
- `AppIconMetadata.search(query)` - Search by keyword/description
- `AppIconMetadata.byCategory(category)` - Get metadata by category
- `AppIconMetadata.byKeyword(keyword)` - Filter by specific keyword
- `AppIconMetadata.relatedTo(icon)` - Get related icons
- `icon.metadata` - Extension to get metadata from IconData
- `icon.hasMetadata` - Check if metadata exists

**Coverage**: ~30 core icons have rich metadata (workout, timer, analytics, status, action, navigation, social, settings, premium, media, misc)

**Import**: `import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_metadata.dart';`

### 🚫 Enforcement Automatico

- ✅ **Pre-commit hook** blocca `Icons.*` inline
- ✅ **Pre-commit hook** warn su `Icon()` senza SemanticIcon
- ✅ **Pre-commit hook** warn su hardcoded sizes
- ✅ **100% coverage** - ~445 icone centralizzate
- ✅ **Zero tolleranza** - Qualsiasi `Icons.*` deve essere in `AppIcons`

### 📊 Perché Tier-1 Design System?

1. **Consistency** - Stessi size/color ovunque (no magic numbers)
2. **Accessibility** - Screen readers leggono tutte le icone (WCAG 2.1 AA compliant)
3. **Reusability** - Animation/badge patterns riusabili (no duplication)
4. **Developer Experience** - Icon showcase + auto-complete + metadata search
5. **Maintainability** - Refactoring facile (semantic constants)
6. **Performance** - Widget ottimizzati con const
7. **Type Safety** - Enum-based categories (compile-time safety) 🆕
8. **Discoverability** - Rich metadata system (search by keyword/use case) 🆕
9. **Flexibility** - Icon variants (filled/outlined toggle states) 🆕
10. **Documentation** - Every icon has description, use cases, related icons 🆕

### ⚡ Quick Examples

```dart
// 🎯 Perfect icon usage (tier-1)
SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: context.l10n.startWorkout,
  size: AppIconSize.large,
  color: context.iconPrimary,
)

// 🔴 Notification badge
AppIcons.notifications.withBadge(count: unreadCount)

// 🎬 Loading animation
AnimatedIconPatterns.rotating(
  icon: AppIcons.loading,
  color: context.iconPrimary,
)

// 🎨 State-based icon color
Icon(
  AppIcons.wifi,
  size: AppIconSize.medium,
  color: context.iconStateActive(isConnected),
)

// 📦 Type-safe category access (Priority 3)
final timerIcons = AppIconCategory.timer.icons;
final category = AppIcons.workout.category;

// 🔄 Icon variants for toggle states (Priority 3)
ToggleIcon(
  isActive: isFavorite,
  variant: AppIconVariants.star,
  activeColor: context.iconSuccess,
)

// 📚 Rich metadata discovery (Priority 3)
final metadata = AppIcons.timer.metadata;
final suggestedLabel = AppIcons.workout.suggestedSemanticLabel;
final results = AppIconMetadata.search('workout');
```

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

> **⚠️ TESTING PHASE**: App in sviluppo con solo lo sviluppatore come utente. Breaking changes e migrazioni aggressive sono permesse. Seguire SEMPRE le regole di clean code sopra.