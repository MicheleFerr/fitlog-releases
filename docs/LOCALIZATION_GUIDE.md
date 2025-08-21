# 🌍 Guida Localizzazione GymBro TrackLog

## 📋 Regole Fondamentali

### ❌ NON FARE MAI:
```dart
// ❌ SBAGLIATO - Testo hardcoded
Text('Welcome to GymBro!')
SnackBar(content: Text('Success!'))
AppBar(title: Text('Settings'))
```

### ✅ FARE SEMPRE:
```dart
// ✅ CORRETTO - Usa AppLocalizations
Text(AppLocalizations.of(context)!.welcomeToGymBro)
SnackBar(content: Text(AppLocalizations.of(context)!.successMessage))
AppBar(title: Text(AppLocalizations.of(context)!.settings))
```

## 🔧 Setup Iniziale

### 1. Import obbligatorio in ogni screen:
```dart
import '../../../shared/presentation/l10n/generated/app_localizations.dart';
```

### 2. Template per nuove screen:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/l10n/generated/app_localizations.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myScreenTitle),
      ),
      body: Center(
        child: Text(AppLocalizations.of(context)!.myScreenContent),
      ),
    );
  }
}
```

## 📝 Processo per Aggiungere Nuove Traduzioni

### 1. Aggiungi in `assets/i18n/app_en.arb`:
```json
{
  "myNewKey": "My English Text",
  "@myNewKey": {
    "description": "Description of what this text is for"
  }
}
```

### 2. Aggiungi in `assets/i18n/app_it.arb`:
```json
{
  "myNewKey": "Il Mio Testo Italiano"
}
```

### 3. Rigenera i file di localizzazione:
```bash
flutter gen-l10n
```

### 4. Usa nel codice:
```dart
Text(AppLocalizations.of(context)!.myNewKey)
```

## 🚨 Convenzioni di Naming

### Chiavi per Titoli:
- `screenNameTitle` (es. `settingsTitle`, `workoutTitle`)

### Chiavi per Descrizioni:
- `screenNameDescription` (es. `homeWelcomeDescription`)

### Chiavi per Bottoni:
- `actionButton` (es. `continueButton`, `saveButton`, `cancelButton`)

### Chiavi per Messaggi:
- `actionMessage` (es. `successMessage`, `errorMessage`)

### Chiavi per Stati:
- `itemState` (es. `activeWorkout`, `pausedWorkout`)

## 🛠️ Strumenti di Controllo

### Script per trovare testi hardcoded:
```bash
./scripts/find_hardcoded_strings.sh
```

### Lint del progetto:
```bash
flutter analyze
```

## ⚠️ Parole Riservate Dart
Evita queste parole come chiavi (usa suffissi):
- `continue` → `continueButton`
- `new` → `newItem`
- `class` → `className`
- `import` → `importAction`

## 🧪 Testing Multilingua

### Test manuale:
1. Cambia lingua nelle Settings
2. Riavvia l'app
3. Verifica che tutti i testi cambino

### Test automatico:
```dart
testWidgets('should display Italian text when locale is IT', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('it', 'IT'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: MyScreen(),
    ),
  );
  
  expect(find.text('Testo Italiano'), findsOneWidget);
});
```

## 📦 Checklist per PR

- [ ] Nessun testo hardcoded nei file modificati
- [ ] Tutte le nuove stringhe hanno traduzioni EN e IT
- [ ] `flutter gen-l10n` eseguito
- [ ] `flutter analyze` passa senza errori
- [ ] App testata in entrambe le lingue

## 🔍 Pattern Comuni da Evitare

### ❌ Concatenazione di stringhe:
```dart
Text('Hello ' + userName + '!') // NO
```

### ✅ Usa parametri:
```json
{
  "helloUser": "Hello {name}!",
  "@helloUser": {
    "description": "Greeting with user name",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

```dart
Text(AppLocalizations.of(context)!.helloUser(userName)) // SI
```

## 🚀 Best Practices

1. **Aggiungi sempre traduzioni EN e IT contemporaneamente**
2. **Usa descrizioni chiare nei file .arb**
3. **Testa sempre in entrambe le lingue**
4. **Esegui il lint prima di ogni commit**
5. **Usa naming consistente per le chiavi**