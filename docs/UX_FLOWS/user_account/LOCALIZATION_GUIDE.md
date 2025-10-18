# 🌍 Guida Localizzazione GymBro TrackLog

> **UPDATED**: October 18, 2025 - Now uses `context.l10n` pattern with BuildContext Extensions
> **IMPORTANTE**: Questo file documenta il pattern OBBLIGATORIO per localizzazione

---

## 📋 Regole Fondamentali

### ❌ NON FARE MAI (Pattern Deprecato)
```dart
// ❌ SBAGLIATO - Usare AppLocalizations direttamente (pattern vecchio)
Text(AppLocalizations.of(context)!.welcomeToGymBro)
SnackBar(content: Text(AppLocalizations.of(context)!.successMessage))
AppBar(title: Text(AppLocalizations.of(context)!.settings))
```

### ✅ FARE SEMPRE (Pattern Nuovo - BuildContext Extensions)
```dart
// ✅ CORRETTO - Usa context.l10n (pattern nuovo, obbligatorio)
Text(context.l10n.welcomeToGymBro)
SnackBar(content: Text(context.l10n.successMessage))
AppBar(title: Text(context.l10n.settings))
```

---

## 🔧 Setup Obbligatorio

### 1. Import BuildContext Extensions in OGNI screen
```dart
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
```

**Ubicazione file**:
```
lib/shared/presentation/extensions/build_context_extensions.dart
```

### 2. Template per Nuove Screen
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myScreenTitle),  // ✅ Usa context.l10n
      ),
      body: Center(
        child: Text(context.l10n.myScreenContent),  // ✅ Usa context.l10n
      ),
    );
  }
}
```

---

## 🎯 Why context.l10n vs AppLocalizations?

### BuildContext Extensions (✅ PREFERRED)
```dart
// ✅ VANTAGGI:
// - Più conciso: context.l10n.xxx
// - Meno verbose rispetto a AppLocalizations.of(context)!.xxx
// - Migliore performance (caching a livello extension)
// - Centralizzato: un cambio = modifica una sola extension
// - Type-safe: errori a compile time, non runtime
// - Moderno: pattern Flutter standard per extensions

final text = context.l10n.welcomeMessage  // 1 riga
```

### AppLocalizations (❌ DEPRECATO)
```dart
// ❌ PROBLEMI:
// - Verbose: AppLocalizations.of(context)!.xxx
// - Ripetitivo: duplicato in ogni file
// - Runtime error: null check (!)
// - Difficile da refactor: cambi sparsi
// - Legacy: non è il pattern moderno

final text = AppLocalizations.of(context)!.welcomeMessage  // Lungo e ripetitivo
```

---

## 📚 Aggiungi Nuove Traduzioni

### Passo 1: Aggiungi in `assets/i18n/app_en.arb`
```json
{
  "myNewKey": "English Text",
  "@myNewKey": {
    "description": "Describe what this text is for"
  }
}
```

### Passo 2: Aggiungi in `assets/i18n/app_it.arb`
```json
{
  "myNewKey": "Testo Italiano"
}
```

### Passo 3: Rigenera Localizzazioni
```bash
flutter gen-l10n
```

### Passo 4: Usa nel Codice
```dart
// ✅ CORRETTO - Usa context.l10n
Text(context.l10n.myNewKey)

// ❌ SBAGLIATO - Non usare AppLocalizations
Text(AppLocalizations.of(context)!.myNewKey)
```

---

## 🏗️ Come Funziona context.l10n

### BuildContext Extension
```dart
// File: lib/shared/presentation/extensions/build_context_extensions.dart
extension BuildContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
```

### Usage
```dart
// Dentro qualsiasi Widget che ha BuildContext:
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ Grazie all'extension, puoi usare:
    final greeting = context.l10n.greeting;  // Accesso diretto!
    return Text(greeting);
  }
}
```

---

## 📋 Checklist per Nuove Strings

Prima di aggiungere testo all'app:

1. ✅ **È hardcoded?** → NO! Usa `context.l10n`
2. ✅ **Importi l'extension?** → `import '...build_context_extensions.dart'`
3. ✅ **Aggiungi in ENTRAMBI i file ARB?**
   - [ ] app_en.arb (English)
   - [ ] app_it.arb (Italian)
4. ✅ **Hai eseguito `flutter gen-l10n`?**
5. ✅ **Usi `context.l10n.myKey` nel codice?**

---

## 🎨 Esempi Comuni

### AppBar Title
```dart
// ✅ CORRETTO
AppBar(
  title: Text(context.l10n.myScreenTitle),
)

// ❌ SBAGLIATO
AppBar(
  title: Text('My Screen'),  // Hardcoded!
  title: Text(AppLocalizations.of(context)!.myScreenTitle),  // Deprecato!
)
```

### Dialog/SnackBar
```dart
// ✅ CORRETTO
SnackBar(content: Text(context.l10n.successMessage))
showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text(ctx.l10n.confirmDelete),  // Usa ctx.l10n
  ),
)

// ❌ SBAGLIATO
SnackBar(content: Text('Success!'))  // Hardcoded
showDialog(
  builder: (ctx) => AlertDialog(
    title: Text(AppLocalizations.of(ctx)!.confirmDelete),  // Deprecato
  ),
)
```

### Lists/Dropdowns
```dart
// ✅ CORRETTO
final options = [
  context.l10n.optionA,
  context.l10n.optionB,
  context.l10n.optionC,
];

// ❌ SBAGLIATO
final options = ['Option A', 'Option B', 'Option C'];  // Hardcoded!
```

### Form Labels
```dart
// ✅ CORRETTO
TextField(
  decoration: InputDecoration(
    labelText: context.l10n.emailLabel,
    hintText: context.l10n.emailHint,
  ),
)

// ❌ SBAGLIATO
TextField(
  decoration: InputDecoration(
    labelText: 'Email',  // Hardcoded!
    hintText: 'Enter your email',  // Hardcoded!
  ),
)
```

---

## 🔍 Verifica Hardcoded Strings

### Cerca Hardcoded Strings nel Progetto
```bash
# Cerca strings che potrebbero essere hardcoded
./scripts/find_hardcoded_strings.sh

# O manualmente con grep
grep -r "Text('" lib --include="*.dart" | grep -v "context.l10n"
```

---

## 📱 Platform-Specific Strings

### Stesso Testo, Diverse Piattaforme?

```dart
// ✅ CORRETTO - Localizzazioni gestiscono piattaforma
Text(context.l10n.copyButtonLabel)  // iOS/Android usa stessa stringa

// Se diverso per piattaforma, aggiungi suffisso in ARB:
// app_en.arb: "copyButtonLabelIos": "Copy", "copyButtonLabelAndroid": "Copy"
```

---

## 🚀 Best Practices

### 1. Descrizioni nei File ARB
```json
{
  "welcomeMessage": "Welcome to GymBro!",
  "@welcomeMessage": {
    "description": "Shown on first launch to greet users",
    "context": "Onboarding screen"
  }
}
```

### 2. Nomi Chiavi Descrittive
```dart
// ✅ BUONO - Nomi chiari
context.l10n.restTimerCompleteTitle
context.l10n.exerciseNotFoundError
context.l10n.confirmDeleteWorkoutMessage

// ❌ CATTIVO - Nomi vaghi
context.l10n.title
context.l10n.error
context.l10n.message
```

### 3. Raggruppa per Dominio
```json
// app_en.arb - Organizza per sezione
{
  "workoutTimerStart": "Start Timer",
  "workoutTimerPause": "Pause Timer",
  "workoutTimerReset": "Reset Timer",

  "exerciseSelectionTitle": "Select Exercise",
  "exerciseSelectionEmpty": "No exercises found"
}
```

### 4. Evita Concatenazioni
```dart
// ❌ SBAGLIATO - Concatenazione difficile da tradurre
Text(context.l10n.greeting + " " + userName)

// ✅ CORRETTO - Interpolazione nella stringa
// app_en.arb: "greetingWithName": "Hello, {name}!"
Text(context.l10n.greetingWithName.replaceAll('{name}', userName))
// O meglio con intl package
```

---

## 🔄 Workflow Completo

### 1. Progetta la feature
```
Feature: Aggiungi nuovo messaggio di errore
```

### 2. Aggiungi in app_en.arb
```json
{
  "workoutSaveError": "Failed to save workout. Please try again.",
  "@workoutSaveError": {
    "description": "Error when workout save fails"
  }
}
```

### 3. Aggiungi in app_it.arb
```json
{
  "workoutSaveError": "Errore nel salvataggio dell'allenamento. Riprova."
}
```

### 4. Rigenera
```bash
flutter gen-l10n
```

### 5. Usa nel Codice
```dart
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class WorkoutScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Text(context.l10n.workoutSaveError),  // ✅ context.l10n!
      ),
    );
  }
}
```

### 6. Verifica
```bash
# App in English
flutter run

# App in Italian
flutter run --dart-define=FLUTTER_LOCALE=it_IT
```

---

## 🛠️ Troubleshooting

### "context.l10n not defined"
```
❌ ERRORE: The getter 'l10n' isn't defined for the class 'BuildContext'
```
**Soluzione**: Aggiungi import
```dart
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
```

### "No provider found"
```
❌ ERRORE: Could not find the correct Provider/ProviderScope above this widget
```
**Soluzione**: Assicurati che MaterialApp ha `localizationsDelegates` e `supportedLocales`

### Translations Not Showing
```
❌ Testo rimane in inglese anche in Italian locale
```
**Soluzione**:
1. Esegui `flutter gen-l10n`
2. Ripulisci: `flutter clean && flutter pub get`
3. Ricompila: `flutter run`

---

## 📚 Risorse

- **File Extensions**: `lib/shared/presentation/extensions/build_context_extensions.dart`
- **Localization Config**: `l10n.yaml`
- **English Strings**: `assets/i18n/app_en.arb`
- **Italian Strings**: `assets/i18n/app_it.arb`
- **Flutter Docs**: https://docs.flutter.dev/accessibility-and-localization/internationalization/an-in-depth-explanation

---

## ✅ Checklist Finale

- [ ] Tutti gli import includono `build_context_extensions.dart`
- [ ] Tutte le strings usano `context.l10n.xxx` pattern
- [ ] Nessuna stringa hardcoded rimasta
- [ ] ARB files aggiornati in EN e IT
- [ ] `flutter gen-l10n` eseguito
- [ ] Testato su entrambe le lingue
- [ ] No `AppLocalizations.of(context)` nel codice nuovo

---

**Last Updated**: October 18, 2025 - Rewritten with context.l10n pattern
**Status**: ✅ CURRENT - Matches code in lib/shared/presentation/extensions/
