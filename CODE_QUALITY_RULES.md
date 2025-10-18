# 🛡️ GymBro Code Quality Rules - MANDATORY

**Status**: ⚠️ ENFORCEMENT ATTIVO
**Last Update**: 2025-01-06
**Version**: 1.0.0

> **CRITICAL**: Queste regole sono OBBLIGATORIE per ogni nuovo codice e PR. Violazioni bloccano il merge.

---

## 📜 REGOLE CORE (Non Negoziabili)

### ⚖️ REGOLA #0: Compilazione Pulita

```bash
✅ REQUIRED: flutter analyze deve passare senza ERRORI
⚠️ ALLOWED: warnings/info sono permessi ma devono essere giustificati
❌ BLOCKED: Nessun PR con errori di compilazione
```

**Pre-Commit Check**:
```bash
#!/bin/bash
# .git/hooks/pre-commit
if flutter analyze | grep -q "error •"; then
  echo "❌ COMMIT BLOCCATO: Errori di compilazione rilevati"
  echo "Run: flutter analyze"
  exit 1
fi
```

---

### 🌍 REGOLA #1: Zero Hardcoded Strings

**Policy**: OGNI testo visibile all'utente DEVE usare `AppLocalizations`

#### ❌ VIETATO

```dart
// ❌ SBAGLIATO - Testo hardcoded
Text('Workout completed!')
AppBar(title: Text('Settings'))
SnackBar(content: Text('Saved successfully'))
showDialog(
  title: Text('Confirm'),
  content: Text('Are you sure?'),
)

// ❌ SBAGLIATO - Anche in variabili
final String message = 'Training started';
const String label = 'Start Workout';
```

#### ✅ CORRETTO

```dart
// ✅ CORRETTO - Usa context.l10n
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

Text(context.l10n.workoutCompleted)
AppBar(title: Text(context.l10n.settings))
SnackBarService.showSuccess(context, context.l10n.savedSuccessfully)
ModalService.showConfirmDialog(
  context,
  title: context.l10n.confirm,
  message: context.l10n.areYouSure,
)
```

#### 📝 Processo per Nuovi Testi

```bash
# 1. Aggiungi in assets/i18n/app_en.arb
{
  "workoutCompleted": "Workout completed!",
  "@workoutCompleted": {
    "description": "Message shown when workout finishes"
  }
}

# 2. Traduci in assets/i18n/app_it.arb
{
  "workoutCompleted": "Allenamento completato!"
}

# 3. Rigenera
flutter gen-l10n

# 4. Usa nel codice
Text(context.l10n.workoutCompleted)
```

#### 🔍 Detection Script

```bash
# Trova violazioni
./scripts/find_hardcoded_strings.sh

# Pre-commit hook
if ./scripts/find_hardcoded_strings.sh | grep -q "Hardcoded string found"; then
  echo "❌ COMMIT BLOCCATO: Hardcoded strings rilevati"
  exit 1
fi
```

#### ⚠️ Eccezioni Permesse

```dart
// ✅ OK - Debug/logging (non visibile all'utente)
print('Debug: workout state = $state');
debugPrint('Error loading data');

// ✅ OK - Key names / identificatori
const String workoutKey = 'workout_v2';
Key('exercise_list_item');

// ✅ OK - URL/path constants
const String apiUrl = 'https://api.example.com';
const String imagePath = 'assets/images/logo.png';

// ✅ OK - Regex patterns
final regex = RegExp(r'^\d{3}-\d{3}$');
```

---

### 🎨 REGOLA #2: Zero Hardcoded Colors

**Policy**: OGNI colore DEVE usare `Theme.of(context).colorScheme` o `context.colors`

#### ❌ VIETATO

```dart
// ❌ SBAGLIATO - Colori hardcoded
Container(color: Colors.blue)
Container(color: Color(0xFF2196F3))
Container(color: Color.fromRGBO(33, 150, 243, 1.0))
Icon(color: Colors.grey)
Text(style: TextStyle(color: Colors.black))
BoxDecoration(color: Colors.white)
LinearGradient(colors: [Colors.blue, Colors.purple])
```

#### ✅ CORRETTO

```dart
// ✅ CORRETTO - Usa context.colors (BuildContext Extensions)
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

Container(color: context.colors.primary)
Container(color: context.colors.surface)
Icon(color: context.colors.onSurface.withOpacity(0.6))
Text(style: TextStyle(color: context.colors.onBackground))
BoxDecoration(color: context.colors.surfaceContainerHighest)
LinearGradient(colors: [context.colors.primary, context.colors.secondary])

// ✅ ALTERNATIVA - Theme.of(context) (più verboso)
Container(color: Theme.of(context).colorScheme.primary)
```

#### 🎨 ColorScheme Palette Disponibili

```dart
// Colori Primari
context.colors.primary           // Colore brand principale
context.colors.onPrimary          // Testo su primary
context.colors.primaryContainer   // Variante primary
context.colors.onPrimaryContainer // Testo su primaryContainer

// Colori Secondari
context.colors.secondary
context.colors.onSecondary
context.colors.secondaryContainer
context.colors.onSecondaryContainer

// Superficie
context.colors.surface            // Background elementi
context.colors.onSurface          // Testo su surface
context.colors.surfaceContainerHighest  // Card elevated
context.colors.surfaceContainerHigh
context.colors.surfaceContainer
context.colors.surfaceContainerLow
context.colors.surfaceContainerLowest

// Background
context.colors.background
context.colors.onBackground

// Stati
context.colors.error
context.colors.onError
context.colors.errorContainer
context.colors.onErrorContainer

// Utility
context.colors.outline           // Bordi
context.colors.outlineVariant    // Bordi più leggeri
context.colors.shadow            // Ombre
context.colors.scrim             // Overlay scuri
```

#### 🔍 Detection Script

```bash
# Trova violazioni
grep -r "Colors\." lib/features --include="*.dart" \
  | grep -v "context.colors" \
  | grep -v "Theme.of(context)"

# Pre-commit hook aggiunto automaticamente
```

#### ⚠️ Eccezioni Permesse

```dart
// ✅ OK - Colors.transparent (nessuna alternativa nel theme)
Container(color: Colors.transparent)
Divider(color: Colors.transparent)

// ✅ OK - withOpacity/withAlpha su colori del theme
context.colors.primary.withOpacity(0.5)
context.colors.onSurface.withAlpha(128)

// ⚠️ CONDITIONAL OK - Debug overlays (commentati in production)
if (kDebugMode) {
  Container(
    decoration: BoxDecoration(border: Border.all(color: Colors.red)),
    child: widget,
  )
}
```

---

### 🧩 REGOLA #3: Component Unification

**Policy**: USA SEMPRE i componenti unificati invece di implementazioni custom

#### ❌ VIETATO

```dart
// ❌ SBAGLIATO - Loading diretto
Center(child: CircularProgressIndicator())
LinearProgressIndicator(color: Colors.blue)

// ❌ SBAGLIATO - Snackbar diretto
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Success!'))
)

// ❌ SBAGLIATO - Dialog/Modal diretto
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text('Confirm'),
    actions: [/* ... */],
  ),
)
showModalBottomSheet(/* ... */)
```

#### ✅ CORRETTO

```dart
// ✅ CORRETTO - LoadingIndicator unificato
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

LoadingIndicator()
LoadingIndicator(message: context.l10n.loadingWorkouts)
LoadingIndicator.overlay(message: context.l10n.savingChanges)
LoadingIndicator.linear(progress: 0.75)

// ✅ CORRETTO - SnackBarService unificato
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

SnackBarService.showSuccess(context, context.l10n.workoutSaved)
SnackBarService.showError(context, context.l10n.errorOccurred)
SnackBarService.showWarning(context, context.l10n.unsavedChanges)
SnackBarService.showInfo(context, context.l10n.tipOfTheDay)

// ✅ CORRETTO - ModalService unificato
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

final result = await ModalService.showBottomSheet(
  context,
  child: MyWidget(),
)

final confirmed = await ModalService.showConfirmDialog(
  context,
  title: context.l10n.deleteWorkout,
  message: context.l10n.deleteWorkoutConfirmation,
  isDangerous: true,
)
```

#### 📦 Component Catalog

| Use Case | ❌ SBAGLIATO | ✅ CORRETTO |
|----------|-------------|-----------|
| Loading spinner | `CircularProgressIndicator()` | `LoadingIndicator()` |
| Progress bar | `LinearProgressIndicator()` | `LoadingIndicator.linear(progress: 0.5)` |
| Success message | `ScaffoldMessenger.showSnackBar()` | `SnackBarService.showSuccess()` |
| Error message | `SnackBar(backgroundColor: Colors.red)` | `SnackBarService.showError()` |
| Confirm dialog | `showDialog(AlertDialog(...))` | `ModalService.showConfirmDialog()` |
| Bottom sheet | `showModalBottomSheet()` | `ModalService.showBottomSheet()` |
| Info dialog | `AlertDialog(...)` | `ModalService.showInfoDialog()` |

#### 🔍 Detection

```bash
# Find raw CircularProgressIndicator
grep -r "CircularProgressIndicator()" lib/features --include="*.dart"

# Find raw ScaffoldMessenger
grep -r "ScaffoldMessenger.of(context)" lib/features --include="*.dart"

# Find raw showDialog
grep -r "showDialog(" lib/features --include="*.dart"
```

---

### 📁 REGOLA #4: Import Assoluti (No Relative Paths)

**Policy**: SEMPRE usare import assoluti con `package:`

#### ❌ VIETATO

```dart
// ❌ SBAGLIATO - Import relativi
import '../../../shared/domain/entities/exercise.dart';
import '../../data/repositories/workout_repository.dart';
import '../widgets/exercise_card.dart';
```

#### ✅ CORRETTO

```dart
// ✅ CORRETTO - Import assoluti
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_card.dart';
```

#### 🛠️ Auto-Fix Script

```bash
# Convert relative to absolute imports
./scripts/fix_relative_imports.sh
```

---

### 🧪 REGOLA #5: Import Required Extensions

**Policy**: SEMPRE importare BuildContext extensions quando si usa Theme o Localizations

#### ❌ VIETATO

```dart
// ❌ SBAGLIATO - Accesso verboso senza extensions
final color = Theme.of(context).colorScheme.primary;
final text = AppLocalizations.of(context)!.title;
final width = MediaQuery.of(context).size.width;
```

#### ✅ CORRETTO

```dart
// ✅ CORRETTO - Sempre importare extensions
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

final color = context.colors.primary;
final text = context.l10n.title;
final width = context.screenWidth;
final isDark = context.isDarkMode;
```

#### 📋 Extension Checklist

Quando vedi questi pattern, assicurati che extensions sia importato:

```dart
✅ Se usi: Theme.of(context) → import extensions + usa context.theme
✅ Se usi: AppLocalizations.of(context) → import extensions + usa context.l10n
✅ Se usi: MediaQuery.of(context) → import extensions + usa context.mediaQuery
```

---

## 🏗️ REGOLE ARCHITETTURALI

### REGOLA #6: Clean Architecture Layers

```
lib/
├── features/
│   └── [feature_name]/
│       ├── domain/          # ✅ Solo entities, repositories (interfaces), use cases
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── services/
│       ├── data/            # ✅ Solo implementazioni repositories, data sources
│       │   ├── repositories/
│       │   ├── models/
│       │   └── datasources/
│       └── presentation/    # ✅ Solo UI, widgets, providers
│           ├── screens/
│           ├── widgets/
│           └── providers/
└── shared/                  # ✅ Solo codice condiviso tra features
    ├── domain/
    ├── data/
    └── presentation/
```

#### ❌ VIETATO

```dart
// ❌ SBAGLIATO - Import data layer in domain
// File: lib/features/workout/domain/repositories/workout_repository.dart
import '../../data/models/workout_model.dart';  // ❌ domain → data

// ❌ SBAGLIATO - Import presentation in domain
import '../../presentation/providers/workout_provider.dart';  // ❌ domain → presentation

// ❌ SBAGLIATO - Logica business in presentation
class WorkoutScreen extends ConsumerWidget {
  void calculateTotalVolume() {  // ❌ Business logic in UI
    // Complex calculation...
  }
}
```

#### ✅ CORRETTO

```dart
// ✅ CORRETTO - Domain → Domain only
// File: lib/features/workout/domain/repositories/workout_repository.dart
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

// ✅ CORRETTO - Presentation → Domain
// File: lib/features/workout/presentation/providers/workout_provider.dart
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

// ✅ CORRETTO - Business logic in domain service
class WorkoutService {
  double calculateTotalVolume(Workout workout) {
    return workout.exercises.fold(0.0, (sum, ex) => sum + ex.totalVolume);
  }
}
```

---

### REGOLA #7: Provider Naming Conventions

```dart
// ✅ CORRETTO - Provider naming
final workoutProvider = StateNotifierProvider<WorkoutNotifier, WorkoutState>(...);
final currentWorkoutProvider = StateProvider<Workout?>(...);
final workoutListProvider = FutureProvider<List<Workout>>(...);
final workoutStreamProvider = StreamProvider<Workout>(...);

// Pattern: [entity][optional_qualifier]Provider
```

---

### REGOLA #8: File Naming Conventions

```dart
// ✅ CORRETTO - snake_case per file
workout_screen.dart
exercise_list_item.dart
workout_repository.dart
build_context_extensions.dart

// ❌ SBAGLIATO
WorkoutScreen.dart
ExerciseListItem.dart
workoutRepository.dart
```

---

## 🚨 ENFORCEMENT AUTOMATION

### Pre-Commit Hook

Creare `.git/hooks/pre-commit`:

```bash
#!/bin/bash

echo "🔍 Running GymBro Code Quality Checks..."

# Check 1: Compilazione
echo "1️⃣ Checking compilation..."
if flutter analyze 2>&1 | grep -q "error •"; then
  echo "❌ BLOCKED: Compilation errors found"
  flutter analyze | grep "error •" | head -10
  exit 1
fi
echo "✅ Compilation OK"

# Check 2: Hardcoded strings
echo "2️⃣ Checking hardcoded strings..."
if ./scripts/find_hardcoded_strings.sh 2>&1 | grep -q "Hardcoded string found"; then
  echo "⚠️  WARNING: Hardcoded strings found (non-blocking)"
  ./scripts/find_hardcoded_strings.sh 2>&1 | grep "Hardcoded string found" | head -5
  # Non blocca ma avvisa
fi

# Check 3: Hardcoded colors
echo "3️⃣ Checking hardcoded colors..."
COLORS_COUNT=$(grep -r "Colors\." lib/features --include="*.dart" | grep -v "Colors.transparent" | wc -l)
if [ "$COLORS_COUNT" -gt 0 ]; then
  echo "⚠️  WARNING: Found $COLORS_COUNT hardcoded Colors (non-blocking)"
fi

# Check 4: Relative imports
echo "4️⃣ Checking import paths..."
if grep -r "import '\.\." lib/features --include="*.dart" | grep -q "import"; then
  echo "❌ BLOCKED: Relative imports found"
  grep -r "import '\.\." lib/features --include="*.dart" | head -5
  exit 1
fi
echo "✅ Import paths OK"

echo "✨ All critical checks passed!"
```

### CI/CD GitHub Actions

`.github/workflows/code_quality.yml`:

```yaml
name: Code Quality

on: [pull_request]

jobs:
  quality_check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Run flutter analyze
        run: |
          if flutter analyze 2>&1 | grep -q "error •"; then
            echo "❌ Compilation errors found"
            exit 1
          fi

      - name: Check hardcoded strings
        run: |
          chmod +x ./scripts/find_hardcoded_strings.sh
          ./scripts/find_hardcoded_strings.sh || true

      - name: Check relative imports
        run: |
          if grep -r "import '\.\." lib/features --include="*.dart"; then
            echo "❌ Relative imports found"
            exit 1
          fi
```

---

## 📊 METRICS & MONITORING

### Dashboard di Qualità

Eseguire periodicamente:

```bash
#!/bin/bash
# scripts/quality_dashboard.sh

echo "📊 GymBro Code Quality Dashboard"
echo "================================"
echo ""

# Compilation errors
ERRORS=$(flutter analyze 2>&1 | grep "error •" | wc -l)
echo "🔴 Compilation Errors: $ERRORS"

# Hardcoded strings
STRINGS=$(./scripts/find_hardcoded_strings.sh 2>&1 | grep "Hardcoded string found" | wc -l)
echo "🟡 Hardcoded Strings: $STRINGS"

# Hardcoded colors
COLORS=$(grep -r "Colors\." lib/features --include="*.dart" | grep -v "Colors.transparent" | wc -l)
echo "🟡 Hardcoded Colors: $COLORS"

# Relative imports
IMPORTS=$(grep -r "import '\.\." lib/features --include="*.dart" | wc -l)
echo "🔴 Relative Imports: $IMPORTS"

# Raw CircularProgressIndicator
SPINNERS=$(grep -r "CircularProgressIndicator()" lib/features --include="*.dart" | wc -l)
echo "🟡 Raw Loading Indicators: $SPINNERS"

echo ""
echo "🎯 Target: All metrics to 0"
```

---

## 📚 TRAINING & ONBOARDING

### New Developer Checklist

Quando un nuovo developer entra nel progetto:

- [ ] Leggere `CLAUDE.md` completo
- [ ] Leggere `CODE_QUALITY_RULES.md` (questo file)
- [ ] Leggere `ARCHITECTURAL_OPTIMIZATIONS_REPORT.md`
- [ ] Setup pre-commit hooks (`cp scripts/pre-commit .git/hooks/`)
- [ ] Run `./scripts/quality_dashboard.sh` per vedere baseline
- [ ] Fare una PR di esempio con review del team
- [ ] Verificare che IDE abbia flutter analyzer configurato

### Quick Reference Card

Stampare e mettere vicino al monitor:

```
🛡️ GYMBRO CODE RULES QUICK REF

✅ DO:
- context.l10n.* (NO hardcoded text)
- context.colors.* (NO Colors.*)
- LoadingIndicator() (NO CircularProgressIndicator)
- SnackBarService.showSuccess() (NO ScaffoldMessenger)
- ModalService.showDialog() (NO showDialog)
- package: imports (NO ../)
- import build_context_extensions.dart

❌ DON'T:
- Text('hardcoded')
- Colors.blue
- CircularProgressIndicator()
- ScaffoldMessenger
- import '../'

💾 BEFORE COMMIT:
flutter analyze (must be 0 errors)
```

---

## 🔄 CONTINUOUS IMPROVEMENT

### Quarterly Review

Ogni 3 mesi:

1. Review `quality_dashboard.sh` metrics trend
2. Update rules based on common violations
3. Add new automated checks
4. Training session su nuove best practices

### Rule Versioning

Questo documento segue semantic versioning:

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes alle regole
- **MINOR** (1.0.0 → 1.1.0): Nuove regole aggiunte
- **PATCH** (1.0.0 → 1.0.1): Clarifications, esempi aggiuntivi

---

## 📞 SUPPORT

Domande sulle regole?

1. Check questo documento
2. Check `CLAUDE.md`
3. Check `ARCHITECTURAL_OPTIMIZATIONS_REPORT.md`
4. Ask team lead
5. Create issue su GitHub con label `code-quality`

---

**🏆 Remember: Code quality is not negotiable. These rules protect user experience and developer sanity.**

