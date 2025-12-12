# 🔧 Code Patterns - Esempi e Reference

> **Questo file contiene esempi di codice e pattern reference. Per le regole, vedi [DEVELOPMENT_RULES.md](./DEVELOPMENT_RULES.md).**

---

## 🎨 COLOR MAPPING REFERENCE

| Hardcoded | Theme Alternative | Uso |
|-----------|-------------------|-----|
| `Colors.blue` | `context.colors.primary` | Brand color, pulsanti principali |
| `Colors.orange` | `context.colors.secondary` | Accent, azioni secondarie |
| `Colors.green` | `context.colors.success` | Success, completato, positivo |
| `Colors.red` | `context.colors.error` | Errore, danger, elimina |
| `Colors.amber/yellow` | `context.colors.warning` | Warning, attenzione |
| `Colors.purple` | `context.colors.tertiary` | Azioni terziarie, info |
| `Colors.white` | `context.colors.surface` | Sfondi, card |
| `Colors.grey` | `context.colors.surfaceVariant` | Sfondi sottili |
| `Colors.black` | `context.colors.onSurface` | Testo primario |

**Eccezione**: `Colors.transparent` è permesso (universale)

### Import Richiesti
```dart
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
```

### Script Fix Automatico
```bash
./scripts/fix_theme_violations.sh --file path/to/file.dart
./scripts/fix_theme_violations.sh --dry-run  # Preview
```

---

## 🛡️ SAFE PARSING UTILITIES

> Import: `package:gymbro_flutter_new/shared/utils/safe_parsing.dart`

### Pattern da Evitare
```dart
// ❌ UNSAFE - Crash se invalid hex
Color(int.parse('FF$hex', radix: 16))

// ✅ SAFE - Usa utility con fallback
parseColorSafe(hex, fallback: Colors.blue)
```

### Utilities Disponibili
```dart
parseColorSafe('#2196F3', fallback: Colors.blue)           // Color
parseIntSafe(input, fallback: 0)                           // Integer
parseDoubleSafe(input, fallback: 0.0)                      // Double
parseDateTimeSafe(jsonDate, fallback: DateTime.now())      // DateTime
parseBoolSafe(jsonData['enabled'], fallback: false)        // Boolean
parseEnumSafe('active', Status.values, fallback: Status.pending) // Enum
```

---

## 🏗️ iOS BUILD COMPLIANCE

### Pattern 1: NEVER `const` with `context.l10n`
```dart
Text(context.l10n.title) // ✅
const Text(context.l10n.title) // ❌ iOS build error
```

### Pattern 2: Architecture Boundaries
| Layer | `context.l10n` |
|-------|----------------|
| Presentation (widgets/screens) | ✅ CAN use |
| Provider | ❌ SHOULD NOT |
| Domain/Data | ❌ NEVER |

### Pattern 3: BuildContext Parameter
```dart
String _format(BuildContext context, ...) {
  return context.l10n.text; // ✅
}
```

### Pattern 4: Import Disambiguation
```dart
import 'package:fpdart/fpdart.dart' hide Either, Right, Left; // ✅
```

### Quick Reference Table
| Pattern | Severity | Pre-commit |
|---------|----------|------------|
| `const` with `context.l10n` | 🔴 CRITICAL | ❌ BLOCKS |
| `context.l10n` in providers | 🟡 WARNING | ⚠️ WARNS |
| Missing BuildContext param | 🔴 CRITICAL | (manual) |

---

## 🍎 iOS SPECIFICO

### Gestione Piattaforma
```dart
// ✅ CORRETTO
if (Platform.isIOS) {
  await _startLiveActivity();
}

// ❌ SBAGLIATO - Crash su Android!
await _startLiveActivity();
```

### File Nativi (NON modificare senza Swift knowledge)
- `ios/Runner/LiveActivityTimer/`
- `ios/Runner/BackgroundTaskManager/`

### Funzionalità iOS Esclusive
- Live Activities (iOS 16.1+)
- Dynamic Island (iPhone 14 Pro+)
- Background Tasks
- Apple Health Integration
- Sign in with Apple

---

## 🔥 FIREBASE & SICUREZZA

```dart
// ✅ Validazione obbligatoria
if (userId == null) throw AuthException('User not authenticated');

// ✅ Ogni documento DEVE avere userId
await _firestore.collection('workouts').add({
  'userId': userId,
  'data': workoutData,
});
```

---

## 🧪 TESTING & DEBUG

```dart
// ✅ CORRETTO
if (kDebugMode) {
  debugPrint('Debug info: $data');
}

// ❌ MAI in production
print('Debug info');
```

---

## 📋 DESIGN SYSTEM CHECKLIST

Copia questa checklist dopo ogni implementazione UI:

```
Design System Checklist:
- [ ] `context.colors.*` (NO hardcoded colors)
- [ ] `context.textTheme.*` (NO hardcoded TextStyle)
- [ ] `context.l10n.*` (NO hardcoded strings)
- [ ] Spacing = multipli di 4
- [ ] Border radius = 8/12/16/20/24
- [ ] Testato in light AND dark themes
- [ ] Traduzioni in app_en.arb + app_it.arb
- [ ] `flutter gen-l10n` eseguito
- [ ] HapticFeedback su azioni
- [ ] Touch targets ≥ 44x44
- [ ] LoadingIndicator (non CircularProgressIndicator)
- [ ] SnackBarService (non ScaffoldMessenger)
- [ ] `const` dove possibile
- [ ] `flutter analyze` passa (0 errori)
```

---

## 🚨 VIOLAZIONI COMUNI

| ❌ SBAGLIATO | ✅ CORRETTO |
|--------------|-------------|
| `color: Colors.blue` | `color: context.colors.primary` |
| `Text('Welcome')` | `Text(context.l10n.welcome)` |
| `TextStyle(fontSize: 16)` | `context.textTheme.bodyMedium` |
| `padding: EdgeInsets.all(15)` | `padding: const EdgeInsets.all(16)` |
| `CircularProgressIndicator()` | `LoadingIndicator()` |
| `ScaffoldMessenger.of(context)` | `SnackBarService.showSuccess(...)` |
| `Icon(Icons.check)` | `Icon(AppIcons.check)` |
| `size: 24` | `size: AppIconSize.medium` |

---

## 📦 FONTI DI VERITÀ CANONICHE

| Dominio | File Canonico |
|---------|---------------|
| Exercise (workout) | `lib/features/workout/domain/entities/exercise.dart` |
| ExerciseDefinition (catalog) | `lib/features/exercise_database/domain/entities/exercise.dart` |
| Workout entity | `lib/features/workout/domain/entities/workout.dart` |
| User profile | `unifiedUserProfileProvider` |
| BuildContext ext | `lib/shared/presentation/extensions/build_context_extensions.dart` |

---

## 🏋️ DOMINIO FITNESS - Terminologia

| Termine | Descrizione |
|---------|-------------|
| **Set/Serie** | Gruppo di ripetizioni consecutive |
| **Rep** | Singola ripetizione |
| **Rest** | Pausa tra serie |
| **Superset** | 2+ esercizi senza pausa |
| **Drop Set** | Riduzione peso senza pausa |
| **Rest-Pause** | Breve pausa durante serie |
| **Rest Timer** | Timer tra serie |
| **Workout Timer** | Durata totale workout |
| **Live Activity** | Timer iOS su lock screen |
