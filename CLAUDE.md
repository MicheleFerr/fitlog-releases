# 🤖 CLAUDE.md - Istruzioni per Assistenti AI

> **IMPORTANTE**: Questo file contiene le regole OBBLIGATORIE per qualsiasi assistente AI che lavora su questo progetto Flutter. Leggi SEMPRE questo file prima di fare modifiche al codice.

## 📱 Progetto: FitLog Pro
**Framework**: Flutter
**Architettura**: Clean Architecture + Riverpod
**Stato**: Produzione attiva con utenti iOS/Android

## 🚀 EXERCISE DATABASE IMPLEMENTATION PROJECT

> **STATUS**: In Development (Ready to Start)
> **CURRENT PHASE**: 1 - Foundational (Weeks 1-4)
> **PROGRESS**: 0% - Ready for implementation

### 📋 Project Overview

Building a comprehensive exercise database system with:
- ✅ 1,567 corrected Italian exercises (Sept 2025)
- ✅ Automatic validation and testing
- ✅ User feedback collection
- ✅ Version control system
- ✅ Smart sync (delta-only downloads)
- ✅ Backup & disaster recovery

### 📚 Documentation (Start Here!)

**⭐ ALL DOCUMENTATION IS HERE**: [`📚 docs/INDEX.md`](./docs/INDEX.md)

**QUICK START** (Choose your path):

1. **New Developer?** Start here (15 min):
   ```
   docs/QUICK_REFERENCE.md
   📍 docs/INDEX.md (complete navigation)
   ```

2. **Need Architecture?** Read this (30 min):
   ```
   docs/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md
   ```

3. **Ready to Implement?** Follow this (2-3 hours):
   ```
   docs/EXERCISE_IMPLEMENTATION_PLAYBOOK.md
   ```

4. **Hit an Error?** Check here:
   ```
   docs/ERROR_KB.md
   docs/TIMER_AUDIO_KB.md
   docs/LIVE_ACTIVITY_KB.md
   docs/NOTIFICATION_SYSTEM_KB.md
   ```

5. **Track Progress** (Update weekly!):
   ```
   docs/IMPLEMENTATION_STATUS.json
   ```

**📖 For complete documentation index and navigation**: [`📚 docs/INDEX.md`](./docs/INDEX.md)

### 🎯 How to Resume After Break

```bash
# 1. Check where you left off:
cat docs/IMPLEMENTATION_STATUS.json | jq '.overall_progress_percent, .current_phase'

# 2. Open quick reference:
open docs/QUICK_REFERENCE.md

# 3. Jump to your phase in PLAYBOOK:
open docs/EXERCISE_IMPLEMENTATION_PLAYBOOK.md
# Then Ctrl+F for "FASE 2" or "FASE 3" etc.

# 4. Continue from where you stopped
```

### ⏭️ Next Steps

**This Week:**
- [ ] Read QUICK_REFERENCE.md (15 min)
- [ ] Read ARCHITECTURE doc Executive Summary (20 min)
- [ ] Start Task 1.1: Validation & Testing
- [ ] Update IMPLEMENTATION_STATUS.json

**Timeline:** ~20 weeks total (4 phases)
- Phase 1: 4 weeks (Foundational)
- Phase 2: 6 weeks (Infrastructure)
- Phase 3: 6 weeks (Visibility & Scale)
- Phase 4: 6+ weeks (Expansion)

---

## 🛡️ ENFORCEMENT ATTIVO

**⚠️ CRITICAL**: Tutte le modifiche al codice DEVONO rispettare:

1. **`CODE_QUALITY_RULES.md`** - Regole obbligatorie con enforcement automatico
2. **Questo file (CLAUDE.md)** - Guidelines specifiche del progetto
3. **Pre-commit hooks** - Check automatici prima di ogni commit

```bash
# BEFORE OGNI MODIFICA
./scripts/quality_dashboard.sh  # Vedi stato corrente
flutter analyze                 # DEVE essere 0 errors

# DURING sviluppo
- NO hardcoded strings → usa context.l10n.*
- NO hardcoded colors → usa context.colors.*
- NO raw components → usa LoadingIndicator, SnackBarService, ModalService

# BEFORE commit
git add .
# Pre-commit hook runs automatically
git commit -m "..."
```

---

## 🌍 REGOLA #1: MULTILINGUA OBBLIGATORIO

### ❌ NON FARE MAI:
```dart
// ❌ SBAGLIATO - Testo hardcoded
Text('Welcome to GymBro!')
AppBar(title: Text('Settings'))
SnackBar(content: Text('Success!'))
```

### ✅ FARE SEMPRE (con BuildContext Extensions):
```dart
// ✅ CORRETTO - Usa context.l10n (più conciso)
Text(context.l10n.welcomeToGymBro)
AppBar(title: Text(context.l10n.settings))
SnackBar(content: Text(context.l10n.successMessage))

// ⚠️ DEPRECATO (ancora valido ma verboso)
Text(AppLocalizations.of(context)!.welcomeToGymBro)
```

### 🔧 Setup Richiesto in OGNI Schermata:
```dart
// IMPORT OBBLIGATORIO - BuildContext Extensions
import '../../../../shared/presentation/extensions/build_context_extensions.dart';

// O il percorso corretto in base alla posizione del file
```

### 📝 Processo per Nuove Traduzioni:
1. **Aggiungi in `assets/i18n/app_en.arb`**:
   ```json
   {
     "myNewKey": "English Text",
     "@myNewKey": {
       "description": "What this text is for"
     }
   }
   ```

2. **Aggiungi in `assets/i18n/app_it.arb`**:
   ```json
   {
     "myNewKey": "Testo Italiano"
   }
   ```

3. **Rigenera**:
   ```bash
   flutter gen-l10n
   ```

4. **Usa nel codice**:
   ```dart
   Text(AppLocalizations.of(context)!.myNewKey)
   ```

---

## 🎨 REGOLA #2: TEMA SCURO/CHIARO

### 🚫 NON Definire Colori Hardcoded:
```dart
// ❌ SBAGLIATO
Container(color: Colors.blue)
Text(style: TextStyle(color: Colors.black))
```

### ✅ USA SEMPRE il ColorScheme del Tema (con BuildContext Extensions):
```dart
// ✅ CORRETTO - Usa context.colors (più conciso)
Container(color: context.colors.primary)
Text(style: TextStyle(color: context.colors.onSurface))
Icon(color: context.colors.secondary)

// ⚠️ DEPRECATO (ancora valido ma verboso)
Container(color: Theme.of(context).colorScheme.primary)
```

### 🎯 Colori Disponibili nel ColorScheme:
- `primary` / `onPrimary`
- `secondary` / `onSecondary`
- `surface` / `onSurface`
- `background` / `onBackground`
- `error` / `onError`
- `outline` / `outlineVariant`

### 📱 Il Sistema di Tema:
- **L'utente può scegliere**: Chiaro, Scuro, Sistema
- **Configurazione**: `lib/shared/presentation/providers/app_config_provider.dart`
- **Temi**: `lib/shared/presentation/theme/app_theme.dart`

---

## 🏗️ REGOLA #3: ARCHITETTURA RIVERPOD

### 📂 Struttura Obbligatoria:
```
lib/
├── features/
│   └── [feature_name]/
│       ├── domain/
│       ├── data/
│       └── presentation/
│           ├── screens/
│           ├── widgets/
│           └── providers/
├── shared/
│   ├── presentation/
│   │   ├── l10n/
│   │   ├── theme/
│   │   └── providers/
│   └── domain/
└── app/
```

### 🔧 Pattern Provider:
```dart
// Provider
final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
  return MyNotifier();
});

// Utilizzo in Widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myProvider);
    return Text(AppLocalizations.of(context)!.myText);
  }
}
```

---

## 🚨 REGOLE CRITICHE

### 1. 🌍 Localizzazione:
- **SEMPRE** usare `AppLocalizations.of(context)!.keyName`
- **MAI** testi hardcoded in italiano o inglese
- **SEMPRE** aggiungere traduzioni EN e IT

### 2. 🎨 Temi:
- **SEMPRE** usare `Theme.of(context).colorScheme.colorName`
- **MAI** colori hardcoded come `Colors.blue`
- **TESTARE** in entrambi i temi (chiaro/scuro)

### 3. 📱 Widget:
- **PREFERIRE** `ConsumerWidget` per accesso ai provider
- **USARE** `const` quando possibile per performance
- **SEGUIRE** Material Design 3 guidelines

### 4. 🔧 Import:
- **SEMPRE** import assoluti da `package:`
- **MAI** import relativi con `../`

---

## 🛠️ COMANDI UTILI

```bash
# Trova testi hardcoded
./scripts/find_hardcoded_strings.sh

# Rigenera localizzazioni  
flutter gen-l10n

# Analizza codice
flutter analyze

# Setup completo
make dev-setup

# Controlli pre-commit
make pre-commit
```

---

## 📚 RISORSE

### Documentazione Generale
- **Guida Localizzazione**: `docs/LOCALIZATION_GUIDE.md`
- **Snippet VSCode**: `.vscode/dart.code-snippets`
- **Script Automatici**: `scripts/`
- **Configurazione Tema**: `lib/shared/presentation/theme/app_theme.dart`

### 🏋️‍♂️ Documentazione Feature Workout (OBBLIGATORIA)
- **📋 Rules of Engagement (ROE)**: `docs/WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md`
  - **LEGGERE PRIMA di ogni modifica al sistema workout**
  - Template architettura obbligatori (Clean Architecture + Riverpod)
  - Pattern hybrid storage (Hive local-first + Firebase cloud-sync)
  - Atomic operations e race condition prevention
  - Test requirements (unit/widget/integration templates)
  - Performance metrics da rispettare (80-90% miglioramenti)
  - Sicurezza: input sanitization e Firestore rules
  - iOS integration: Live Activities, background tasks
  - Pre-commit checklist (40+ verifiche obbligatorie)

- **📖 Overview Non-Tecnico**: `docs/WORKOUT_SYSTEM_OVERVIEW.md`
  - Comprensione del sistema per stakeholders
  - Workflow completo: pianificazione → esecuzione → completamento
  - Strategia data persistence (local + cloud sync)
  - Timer system e iOS features
  - FAQ per domande comuni

### 📋 Documentazione Exercise Card (OBBLIGATORIA)
- **📋 Rules of Engagement (ROE)**: `docs/EXERCISE_CARD_DEVELOPMENT_GUIDE.md`
  - **LEGGERE PRIMA di modificare le card degli esercizi**
  - Template componenti (ExerciseListItem, QuickEdit, Stats, Selector)
  - Widget performance patterns (debounce, pagination, virtualization)
  - BuildContext extensions (colori, temi, localizzazione)
  - Hybrid storage strategy (Hive + Firebase)
  - Search e filter optimization
  - Test templates completi (unit, widget, integration)
  - Input sanitization e sicurezza
  - Pre-commit checklist (30+ verifiche)

- **📖 Overview Non-Tecnico**: `docs/EXERCISE_CARD_SYSTEM_OVERVIEW.md`
  - Comprensione UI exercise card per non-dev
  - Ciclo di vita della card (creazione → visualizzazione → modifica → esecuzione)
  - Struttura dati (20 campi per esercizio)
  - Metodi di ricerca e filtro
  - Design e tema (colori per categoria)
  - Performance e caching strategy
  - FAQ per domande comuni

### 🔧 Documentazione Exercise Insertion System (OBBLIGATORIA)
- **📋 Rules of Engagement (ROE)**: `docs/EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md`
  - **LEGGERE PRIMA di modificare il flusso di inserimento**
  - Modal architecture template (Single tab + Advanced sub-tabs)
  - Advanced exercise types: Superset, Drop Set, Rest-Pause (con implementazione template)
  - State management per inserimento (Riverpod providers)
  - APRE calculation, caching e invalidation
  - Customization settings storage (Hive + Firebase)
  - Performance optimization (debounce, caching, pagination)
  - Test templates completi (unit, widget, integration)
  - Pre-commit checklist (20+ verifiche)

- **⚙️ Customization & Toggles Guide**: `docs/EXERCISE_INSERTION_CUSTOMIZATION_GUIDE.md`
  - **LEGGERE PER CAPIRE TUTTI I TOGGLE**
  - Global settings (unit system, rest times, database source)
  - APRE settings (enable/disable, protocols, base weight, cache invalidation)
  - Per-exercise customization (sets, weight increments, reps presets)
  - Advanced type settings (superset, drop set, rest-pause)
  - UI/UX customization (modal layout, filters, display modes)
  - Storage locations e sync strategy
  - Troubleshooting guide

- **📖 Overview Non-Tecnico**: `docs/EXERCISE_INSERTION_SYSTEM_OVERVIEW.md`
  - Comprensione del flusso di inserimento per non-dev
  - Fase per fase: Accesso → Tipo → Ricerca → Personalizzazione → Salvataggio
  - Spiegazione esercizi avanzati (Superset, Drop Set, Rest-Pause)
  - Toggle e personalizzazioni spiegate semplicemente
  - APRE auto-regulation spiegato
  - FAQ domande comuni
  - Storage e sincronizzazione dati

### Ottimizzazioni Architetturali
- **📊 Report Completo**: `ARCHITECTURAL_OPTIMIZATIONS_REPORT.md`
  - Dettagli implementazione BuildContext Extensions
  - Metriche di impatto (27,000+ righe ottimizzate)
  - Esempi prima/dopo per ogni ottimizzazione
  - Guida migrazione file esistenti
  - Script automatici disponibili

### Componenti e Servizi Unificati
- **BuildContext Extensions**: `lib/shared/presentation/extensions/build_context_extensions.dart`
- **Loading Component**: `lib/shared/presentation/widgets/loading_indicator.dart`
- **Snackbar Service**: `lib/shared/presentation/services/snackbar_service.dart`
- **Modal Service**: `lib/shared/presentation/services/modal_service.dart`
- **Script Migrazione**: `scripts/migrate_to_context_extensions.sh`

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
- Lint check (`flutter analyze`)
- Hardcoded strings check
- Localizations regen se necessario
- Test execution

---

## ⚡ CHECKLIST RAPIDA

Prima di ogni modifica, verifica:

- [ ] 🌍 Nessun testo hardcoded (usa `context.l10n`)
- [ ] 🎨 Nessun colore hardcoded (usa `context.colors`)
- [ ] 📱 Import di `build_context_extensions.dart` aggiunto
- [ ] 🖨️ **Nessun print() - usa debugPrint() + kDebugMode**
- [ ] 🔤 Traduzioni aggiunte in EN e IT
- [ ] ⚙️ `flutter gen-l10n` eseguito se aggiunte traduzioni
- [ ] 🔍 `flutter analyze` passa senza errori
- [ ] 🧪 Widget testato in entrambi i temi (chiaro/scuro)
- [ ] 📱 Funzionalità testata su iOS E Android (se applicabile)
- [ ] 🔒 Autenticazione controllata se usa Firebase
- [ ] ⚡ Performance ottimizzata (const, select, dispose)
- [ ] 🧭 Named routes usate (non path hardcoded)

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

### 🔐 Sicurezza Obbligatoria:
```dart
// ✅ CORRETTO - Valida sempre input utente
final userId = FirebaseAuth.instance.currentUser?.uid;
if (userId == null) return; // Controlla autenticazione

// ❌ SBAGLIATO - Fidarsi dell'input
await firestore.collection('workouts').doc(inputId).update(data);
```

### 📊 Provider Firebase:
- **AuthProvider**: `lib/features/auth/presentation/providers/auth_provider.dart`
- **Workout Data**: Provider specifici per feature
- **SEMPRE** controllare stato autenticazione

### 🚨 Regole Firestore:
- **Ogni documento** deve avere `userId` per sicurezza
- **Validazione** sempre lato client E server
- **Error handling** obbligatorio per operazioni async

---

## ⚡ REGOLA #6: PERFORMANCE & MEMORIA

### 🏃‍♂️ Widget Performance:
```dart
// ✅ CORRETTO - Usa const quando possibile
const Text('Static text')
const SizedBox(height: 16)

// ✅ CORRETTO - Evita rebuild inutili
final workout = ref.watch(currentWorkoutProvider.select((w) => w?.name));

// ❌ SBAGLIATO - Rebuild eccessivi
final workout = ref.watch(currentWorkoutProvider); // Rebuild per ogni cambio
```

### 💾 Gestione Memoria:
- **Timer**: Sempre cancellare con `timer.cancel()`
- **StreamSubscription**: Sempre cancellare con `subscription.cancel()`
- **Controller**: Sempre `dispose()` in StatefulWidget

### 📱 Background Tasks:
- **iOS**: Usare Background App Refresh
- **Limite tempo**: Max 30 secondi background
- **Battery**: Ottimizzare per consumo batteria

---

## 🧪 REGOLA #7: TESTING & DEBUGGING

### ✅ Test Obbligatori:
```dart
// Widget test con localizzazione
testWidgets('should show Italian text', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('it', 'IT'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: MyWidget(),
    ),
  );

  expect(find.text('Testo Italiano'), findsOneWidget);
});
```

### 🖨️ Debug Printing (OBBLIGATORIO)

**❌ MAI usare print() in production:**
```dart
// ❌ SBAGLIATO - print() rallenta production e riempie i log
print('User ID: $userId');
print('Debug: Loading workouts...');
```

**✅ SEMPRE usare debugPrint() con kDebugMode:**
```dart
// ✅ CORRETTO - Solo in debug mode
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  debugPrint('User ID: $userId');
}

// ✅ ALTERNATIVA - Per log critici (errori)
if (kDebugMode) {
  debugPrint('❌ Error loading workout: $error');
}
```

**📋 Regole debugPrint:**
1. **SEMPRE** importare `package:flutter/foundation.dart`
2. **SEMPRE** wrappare `debugPrint()` in `if (kDebugMode)`
3. **MAI** usare `print()` (rallenta performance production)
4. **Script disponibile**: `scripts/fix_print_statements.py` per fix automatici

**💡 Perché debugPrint invece di print:**
- `debugPrint()` non rallenta production (viene rimosso in release)
- `kDebugMode` check previene output in production
- Migliore per performance (no I/O bloccante in release)
- Log più puliti e professionali

### 🐛 Debug Mode:
- **SEMPRE** testare in Release mode prima del deploy
- **Performance**: Profile mode per test performance
- **Memory**: Controllare memory leaks con DevTools

---

## 📱 REGOLA #8: NAVIGATION & ROUTING

### 🧭 GoRouter Pattern:
```dart
// ✅ CORRETTO - Named routes
context.goNamed('workout');
context.goNamed('settings');

// ❌ SBAGLIATO - Path hardcoded
context.go('/workout');
```

### 🔒 Protezione Rotte:
- **Auth Guard**: Automatic redirect se non autenticato
- **Deep Links**: Supporto iOS/Android
- **State Management**: Router integrato con Riverpod

---

## 🏋️‍♂️ REGOLA #9: DOMINIO SPECIFICO (FITNESS APP)

### 📊 Entità Principali:
- **Workout**: Allenamento con timer e live activities
- **Exercise**: Esercizio con sets, reps, peso
- **ExerciseCard**: UI card per visualizzare esercizi
- **WorkoutTemplate**: Template riutilizzabili
- **Analytics**: Progressi e statistiche

### ⏱️ Timer System:
- **Rest Timer**: Tra serie di esercizi
- **Workout Timer**: Durata totale allenamento
- **Live Activity**: Timer visibile in lockscreen (iOS)
- **Background**: Continua anche se app in background

### 💪 Terminologia Fitness:
- **Set/Serie**: Gruppo di ripetizioni
- **Rep/Ripetizioni**: Singola esecuzione movimento
- **Rest/Riposo**: Pausa tra serie
- **Superset**: Esercizi consecutivi senza riposo
- **Drop set**: Riduzione peso a cedimento
- **Rest-pause**: Brevi pause durante serie

### 🚨 IMPORTANTE: Modifiche al Sistema Workout

**PRIMA di implementare/modificare feature workout, DEVI:**

1. **Leggere OBBLIGATORIAMENTE**:
   - `docs/WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md` - ROE complete per workout features
   - `docs/WORKOUT_SYSTEM_OVERVIEW.md` - Comprensione sistema (opzionale)

2. **Seguire le ROE (Rules of Engagement)**:
   - Template architettura obbligatori
   - Pattern hybrid storage (local-first + cloud-sync)
   - Atomic operations per completion flow
   - Test requirements (unit/widget/integration)
   - Performance metrics da rispettare

**Esempi Trigger per Leggere la Guida:**
- Aggiungere un nuovo tipo di esercizio (es: superset, dropset)
- Modificare il flusso di completamento workout
- Cambiare il sistema di persistenza
- Aggiungere analytics o tracking
- Modificare il timer system o Live Activities
- Integrare con routine/programmi

**Se l'utente dice**:
- "Voglio aggiungere..." → Leggi WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md
- "Posso modificare il workout..." → Leggi WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md
- "Come implemento..." → Leggi WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md

### 📋 IMPORTANTE: Modifiche alle Exercise Card

**PRIMA di implementare/modificare feature delle exercise card, DEVI:**

1. **Leggere OBBLIGATORIAMENTE**:
   - `docs/EXERCISE_CARD_DEVELOPMENT_GUIDE.md` - ROE complete per exercise card
   - `docs/EXERCISE_CARD_SYSTEM_OVERVIEW.md` - Comprensione sistema (opzionale)

2. **Seguire le ROE (Rules of Engagement)**:
   - Template architettura obbligatori (ExerciseListItem, QuickEdit, Stats, Selector)
   - Pattern hybrid storage (Hive local-first + Firebase cloud-sync)
   - Widget performance requirements (debounce, pagination, virtualization)
   - BuildContext extensions per colori, temi e localizzazione
   - Test requirements (unit/widget/integration test templates)
   - Performance metrics da rispettare (60 FPS, < 50MB memory)
   - Sicurezza: input sanitization per nomi esercizi
   - iOS integration: fallback per Android

**Esempi Trigger per Leggere la Guida:**
- Modificare card degli esercizi (colori, layout, campi)
- Aggiungere campi all'esercizio (difficulty, technique, etc)
- Cambiare il sistema di ricerca/filtro esercizi
- Ottimizzare performance della lista esercizi
- Integrare con sistema di categorie
- Aggiungere selettore di esercizi
- Modificare cache strategy per esercizi

**Se l'utente dice**:
- "Modifica le card degli esercizi..." → Leggi EXERCISE_CARD_DEVELOPMENT_GUIDE.md
- "Voglio aggiungere campi all'esercizio..." → Leggi EXERCISE_CARD_DEVELOPMENT_GUIDE.md
- "Come miglioro la ricerca esercizi..." → Leggi EXERCISE_CARD_DEVELOPMENT_GUIDE.md

### 🔧 IMPORTANTE: Modifiche al Sistema di Inserimento Esercizi

**PRIMA di implementare/modificare il flusso di inserimento esercizi o i toggle, DEVI:**

1. **Leggere OBBLIGATORIAMENTE**:
   - `docs/EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md` - ROE complete
   - `docs/EXERCISE_INSERTION_CUSTOMIZATION_GUIDE.md` - Tutti i toggle e settings
   - `docs/EXERCISE_INSERTION_SYSTEM_OVERVIEW.md` - Comprensione sistema (opzionale)

2. **Seguire le ROE (Rules of Engagement)**:
   - Template modal architecture (Single tab, Advanced tab con sub-tabs)
   - Advanced exercise types: Superset, Drop Set, Rest-Pause
   - State management patterns (Riverpod providers)
   - APRE calculation e caching
   - Customization settings storage
   - Test templates obbligatori
   - Performance requirements

**Esempi Trigger per Leggere la Guida:**
- Modificare il flusso di aggiunta esercizi
- Aggiungere nuovi toggle o impostazioni
- Cambiar il sistema di APRE (Auto-Programmed Resistance)
- Implementare advanced exercise types
- Personalizzare UI della modal
- Modificare storage delle preferenze
- Aggiungere nuove customization options

**Se l'utente dice**:
- "Modifica il flusso di inserimento esercizi..." → Leggi EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md
- "Aggiungi un toggle per..." → Leggi EXERCISE_INSERTION_CUSTOMIZATION_GUIDE.md
- "Come funziona APRE..." → Leggi EXERCISE_INSERTION_CUSTOMIZATION_GUIDE.md
- "Voglio aggiungere una opzione di personalizzazione..." → Leggi EXERCISE_INSERTION_CUSTOMIZATION_GUIDE.md

---

## 🚫 REGOLA #10: COSA NON TOCCARE

### ⛔ File da NON Modificare:
- `ios/Runner/LiveActivityTimer/` (Swift nativo)
- `ios/Runner/BackgroundTaskManager/` (Swift nativo)
- `lib/shared/presentation/l10n/generated/` (File generati)
- `.dart_tool/` e `build/` (Build artifacts)

### 🔐 Configurazioni Sensibili:
- `firebase_options.dart` (API keys)
- `ios/Runner/GoogleService-Info.plist`
- `android/app/google-services.json`

### 📱 Capability iOS:
- Background App Refresh
- Live Activities
- Push Notifications
- Apple Health (se implementato)

---

## 🔨 REGOLA #12: BUILD & COMPILATION

### 🚫 NON Fare Build Automatici:
- **MAI** eseguire `flutter build ios` o `flutter build android` automaticamente
- **MAI** fare rebuild dopo modifiche al codice senza esplicita richiesta
- **SOLO** fare build se:
  - L'utente lo richiede esplicitamente
  - È necessario per risolvere un errore di compilazione specifico
  - Fa parte della risoluzione di un problema critico

### ✅ Quando È Permesso:
```bash
# SOLO se richiesto dall'utente o per fix critici
flutter build ios --release  # Solo se esplicitamente richiesto
flutter run                  # Solo per debug se richiesto
```

### 💡 Motivazione:
- Risparmio token nella conversazione
- L'utente preferisce fare build da Xcode/Android Studio
- Build più veloce con IDE native
- Migliore controllo del processo di build

---

## 🎯 REGOLA #13: BUILDCONTEXT EXTENSIONS (OBBLIGATORIO)

### 📝 Overview
Per ridurre verbosità e migliorare leggibilità, **SEMPRE** usare le BuildContext extensions invece degli accessor verbosi.

### ✅ Extensions Disponibili

```dart
// SEMPRE importare le extensions
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

// 🎨 Theme & Colors
context.colors           // invece di Theme.of(context).colorScheme
context.textTheme        // invece di Theme.of(context).textTheme
context.theme            // invece di Theme.of(context)

// 🌍 Localizzazione
context.l10n             // invece di AppLocalizations.of(context)!

// 📱 Media Query
context.mediaQuery       // invece di MediaQuery.of(context)
context.screenWidth      // invece di MediaQuery.of(context).size.width
context.screenHeight     // invece di MediaQuery.of(context).size.height

// 🔦 Utility
context.isDarkMode       // verifica se tema scuro attivo
context.isLightMode      // verifica se tema chiaro attivo
context.topPadding       // safe area top (notch, ecc.)
context.bottomPadding    // safe area bottom (home indicator)
context.isKeyboardVisible // verifica se tastiera è visibile
```

### 📊 Prima vs Dopo

**❌ DEPRECATO (Verboso):**
```dart
Container(
  height: MediaQuery.of(context).size.height * 0.9,
  color: Theme.of(context).colorScheme.surface,
  child: Column(
    children: [
      Text(
        AppLocalizations.of(context)!.title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      if (Theme.of(context).brightness == Brightness.dark)
        Icon(Icons.dark_mode),
    ],
  ),
)
```

**✅ CORRETTO (Conciso con Extensions):**
```dart
Container(
  height: context.screenHeight * 0.9,
  color: context.colors.surface,
  child: Column(
    children: [
      Text(
        context.l10n.title,
        style: context.textTheme.headlineSmall?.copyWith(
          color: context.colors.primary,
        ),
      ),
      if (context.isDarkMode)
        Icon(Icons.dark_mode),
    ],
  ),
)
```

### 📈 Benefici Misurabili

- **Leggibilità**: 40-60% meno caratteri per accesso tema/localizzazioni
- **Manutenibilità**: Cambio centralizzato se cambia API Flutter
- **Performance**: Stesso identico costo (zero overhead)
- **Developer Experience**: IntelliSense più veloce e chiaro

### 🚨 Regole di Utilizzo

1. **SEMPRE** importare le extensions in OGNI file che usa Theme, Localizations o MediaQuery
2. **SEMPRE** preferire `context.colors` invece di `Theme.of(context).colorScheme`
3. **SEMPRE** preferire `context.l10n` invece di `AppLocalizations.of(context)!`
4. **SEMPRE** preferire `context.screenWidth/Height` invece di `MediaQuery.of(context).size`
5. **MAI** usare la forma verbosa in nuovo codice (solo per compatibilità legacy)

### 📂 Dove Trovarle

- **File**: `lib/shared/presentation/extensions/build_context_extensions.dart`
- **Esempio Migrato**: `lib/features/workout/presentation/widgets/add_exercise_modal.dart`
- **Script Migrazione**: `scripts/migrate_to_context_extensions.sh`

### 🔄 Migrazione Graduale

- **Nuovo codice**: DEVE usare extensions
- **Codice esistente**: Migrare opportunisticamente quando si tocca il file
- **Compatibilità**: Entrambe le forme funzionano, ma preferire extensions

### 📖 Documentazione Dettagliata

Per informazioni complete su implementazione, metriche di impatto e guida alla migrazione, consulta:
**`ARCHITECTURAL_OPTIMIZATIONS_REPORT.md`** - Sezione "FASE 1: BuildContext Extensions"

---

## 🧩 REGOLA #14: COMPONENTI E SERVIZI UNIFICATI (OBBLIGATORIO)

### 📝 Overview
Per ridurre duplicazione e garantire UX consistente, **SEMPRE** usare i componenti e servizi unificati invece di implementazioni sparse.

### 🔄 Loading States

**❌ NON Usare Direttamente:**
```dart
// ❌ SBAGLIATO - CircularProgressIndicator diretto
Center(child: CircularProgressIndicator())

// ❌ SBAGLIATO - LinearProgressIndicator custom
LinearProgressIndicator(
  color: Theme.of(context).colorScheme.primary,
  backgroundColor: Colors.grey,
)
```

**✅ USA LoadingIndicator:**
```dart
// ✅ CORRETTO - Loading semplice
LoadingIndicator()

// ✅ CORRETTO - Loading con messaggio
LoadingIndicator(message: context.l10n.loadingWorkouts)

// ✅ CORRETTO - Loading overlay fullscreen
LoadingIndicator.overlay(message: context.l10n.savingChanges)

// ✅ CORRETTO - Progress bar
LoadingIndicator.linear(progress: 0.75)

// ✅ CORRETTO - Wrapper condizionale
LoadingWrapper(
  isLoading: isLoading,
  child: MyContent(),
)

// ✅ CORRETTO - Con mixin per async operations
class MyWidget extends ConsumerWidget with LoadingMixin {
  Future<void> saveWorkout() async {
    await withLoading(context, () async {
      // Operazione async
    }, message: context.l10n.saving);
  }
}
```

**Importare:**
```dart
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
```

---

### 📢 Snackbar Messages

**❌ NON Usare Direttamente:**
```dart
// ❌ SBAGLIATO - ScaffoldMessenger diretto
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Success!'),
    backgroundColor: Colors.green,
  ),
);
```

**✅ USA SnackBarService:**
```dart
// ✅ CORRETTO - Success message
SnackBarService.showSuccess(context, context.l10n.workoutSaved);

// ✅ CORRETTO - Error message
SnackBarService.showError(context, context.l10n.errorSavingWorkout);

// ✅ CORRETTO - Warning message
SnackBarService.showWarning(context, context.l10n.unsavedChanges);

// ✅ CORRETTO - Info message
SnackBarService.showInfo(context, context.l10n.tipOfTheDay);

// ✅ CORRETTO - Custom con azione
SnackBarService.showCustom(
  context,
  message: 'Exercise deleted',
  actionLabel: 'UNDO',
  onAction: () => undoDelete(),
);

// ✅ CORRETTO - Con mixin
class MyWidget extends ConsumerWidget with SnackBarMixin {
  void save() {
    // ...
    showSuccess(context, context.l10n.saved);
  }
}
```

**Importare:**
```dart
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
```

---

### 🪟 Modals & Bottom Sheets

**❌ NON Usare Direttamente:**
```dart
// ❌ SBAGLIATO - showModalBottomSheet custom
showModalBottomSheet(
  context: context,
  backgroundColor: Theme.of(context).colorScheme.surface,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (_) => MyContent(),
);
```

**✅ USA ModalService:**
```dart
// ✅ CORRETTO - Bottom sheet standard
final result = await ModalService.showBottomSheet(
  context,
  child: MyContentWidget(),
);

// ✅ CORRETTO - Bottom sheet fullscreen
await ModalService.showFullScreenSheet(
  context,
  child: EditWorkoutScreen(),
);

// ✅ CORRETTO - Dialog di conferma
final confirmed = await ModalService.showConfirmDialog(
  context,
  title: context.l10n.deleteWorkout,
  message: context.l10n.deleteWorkoutConfirmation,
  isDangerous: true,  // Red button per azioni pericolose
);

if (confirmed) {
  // Delete workout
}

// ✅ CORRETTO - Dialog informativo
await ModalService.showInfoDialog(
  context,
  title: context.l10n.tip,
  message: context.l10n.restTimerExplanation,
  icon: Icons.info,
);

// ✅ CORRETTO - Dialog con lista
final selected = await ModalService.showListDialog<Exercise>(
  context,
  title: context.l10n.selectExercise,
  items: exercises,
  itemLabel: (ex) => ex.name,
);

// ✅ CORRETTO - Con mixin
class MyWidget extends ConsumerWidget with ModalMixin {
  Future<void> delete() async {
    final confirmed = await showConfirm(
      context,
      title: context.l10n.delete,
      message: context.l10n.confirmDelete,
      isDangerous: true,
    );
    // ...
  }
}
```

**Importare:**
```dart
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
```

---

### 📈 Benefici dei Componenti Unificati

| Componente | Prima | Dopo | Beneficio |
|-----------|-------|------|-----------|
| Loading | 178 implementazioni diverse | 1 componente | UX consistente |
| Snackbar | 258 implementazioni diverse | 1 servizio | Branding unificato |
| Modal | 259 implementazioni diverse | 1 servizio | Manutenzione semplificata |

### 🚨 Regole di Utilizzo

1. **SEMPRE** usare `LoadingIndicator` invece di `CircularProgressIndicator` diretto
2. **SEMPRE** usare `SnackBarService` invece di `ScaffoldMessenger.showSnackBar`
3. **SEMPRE** usare `ModalService` invece di `showModalBottomSheet`/`showDialog`
4. **MAI** creare implementazioni custom senza motivazione tecnica forte
5. **SEMPRE** usare i preset semantici (success/error/warning/info)

### 📂 Dove Trovarli

- **LoadingIndicator**: `lib/shared/presentation/widgets/loading_indicator.dart`
- **SnackBarService**: `lib/shared/presentation/services/snackbar_service.dart`
- **ModalService**: `lib/shared/presentation/services/modal_service.dart`

### 📖 Documentazione Dettagliata

Per esempi completi, API reference e best practices, consulta:
**`ARCHITECTURAL_OPTIMIZATIONS_REPORT.md`** - Sezioni "FASE 2-4: Componenti Unificati"

Il report include:
- 🎯 Esempi d'uso completi per ogni componente
- 📊 Metriche di impatto (178-259 implementazioni → 3 componenti)
- 🔄 Pattern di migrazione da codice legacy
- ✅ Checklist per adozione nei nuovi PR

---

## 🤖 AUTO-CATEGORIZATION HOOK: Report & Documentation

### 📝 Cosa Significa "Scrivi un Report" o "Crea la Documentazione"

Quando l'utente chiede:
- **"Scrivi un report"** - Fine di una task, voglio un summary/documentazione
- **"Crea la documentazione"** - Voglio docs categorizzate e salvate automaticamente
- **"Documenta questo"** - Crea docs per il lavoro appena fatto

### 🤖 Come Claude Deve Rispondere (AUTOMATICO)

**Step 1: Riconosci la Richiesta**
```
User: "Fatto! Scrivi un report con quello che abbiamo fatto"
```

**Step 2: Categorizz automaticamente usando Decision Tree**
1. È relativo a una feature UX? → Va in `docs/UX_FLOWS/[feature]/`
2. È tecnico/architetturale? → Va in `docs/TECHNICAL_FOUNDATION/`
3. È un report di progress? → Va in root `/docs/` o archival

**Step 3: Crea il file nella cartella corretta**
- NON chiedere conferma su dove metterlo
- Crea il file con nome appropriato (es: `FEATURE_IMPLEMENTATION_REPORT.md`)
- Usa la struttura del progetto (vedi `.claude/hooks/document-categorization-guide.md`)

**Step 4: Aggiorna NAVIGATION/INDEX.md**
- Aggiungi il riferimento al nuovo file
- Link alla cartella appropriata

### ✅ Workflow Automatico

```
User: "Scrivi un report su quello che abbiamo fatto oggi"
↓
Claude: Analizza il contenuto della session
↓
Claude: Decide la categoria (UX_FLOWS/workout_session, TECHNICAL_FOUNDATION, etc.)
↓
Claude: Crea il file con nome descrittivo
↓
Claude: Salva in docs/[categoria]/[nome_file].md
↓
Claude: Aggiorna docs/NAVIGATION/INDEX.md
↓
Claude: Mostra all'utente dove è stato salvato
```

### 📍 Esempi di Categorizzazione Automatica

| Richiesta | Categoria | Risultato |
|-----------|-----------|-----------|
| "Scrivi report timer fixes" | workout_session | `docs/UX_FLOWS/workout_session/TIMER_FIXES_REPORT.md` |
| "Documenta la nuova architettura" | TECHNICAL_FOUNDATION | `docs/TECHNICAL_FOUNDATION/NEW_ARCHITECTURE_REPORT.md` |
| "Crea docs per exercise database" | exercise_database | `docs/UX_FLOWS/exercise_database/[nome_report].md` |
| "Report session progress" | root/archived | `docs/SESSION_PROGRESS_REPORT.md` |

### 🔄 Smart Update - Se il Doc Esiste Già

**Step 1: Riconosci se il file esiste**
```
User: "Scrivi un report sul timer system"
Claude: "Aspetta, c'è già docs/UX_FLOWS/workout_session/TIMER_AUDIO_KB.md?"
→ Sì, esiste
```

**Step 2: Leggi il file esistente**
- Analizza il contenuto attuale
- Nota l'ultimo aggiornamento (data nel file)
- Identifica le sezioni principali

**Step 3: Confronta con il Codice Attuale**
- Esegui una verifica codice-doc
- Identifica: Cosa è cambiato? Cosa è deprecato? Cosa è nuovo?
- Marcare come: ✅ CURRENT, ⚠️ OUTDATED, 🆕 NEW INFO

**Step 4: Decidi l'Azione**
- **Se CURRENT**: "✅ Già aggiornato (Oct 18, 2025)"
- **Se OUTDATED**: Aggiorna intelligentemente (mantieni custom, aggiorna tecnico)
- **Se ha NEW INFO**: Aggiungi le nuove sezioni

**Step 5: Comunica l'Azione**
```
"✅ UPDATED: docs/UX_FLOWS/workout_session/TIMER_AUDIO_KB.md
- Sezione 'iOS Audio Session' aggiornata (nuove patterns)
- Aggiunto: LiveActivity integration notes
- Rimosso: Deprecated AppLocalizations pattern
- Data: Oct 18, 2025"
```

### 🚨 IMPORTANTE

- **MAI** chiedere "dove vuoi il file?" - Decidi tu basato sul contenuto
- **SEMPRE** aggiungi il file a NAVIGATION/INDEX.md se nuovo
- **SEMPRE** crea con nome descrittivo e data se è un report
- **SEMPRE** verifica che vada nella cartella corretta della struttura UX flows
- **SE ESISTE**: Leggi, analizza, paragona, aggiorna intelligentemente

---

## 🔄 Slash Command: `/sync-docs` - Sincronizza Automaticamente TUTTI i Docs

### Cosa Fa
```
/sync-docs
↓ Legge TUTTI i docs
↓ Analizza il codice attuale
↓ Per ogni doc: UPDATE / DELETE / CREATE / ARCHIVE
↓ Commit automatico con report
```

### Quando Usare
- **Dopo grandi refactoring**: `/sync-docs` per aggiornare tutta la doc
- **Prima di release**: Sincronizza tutto prima di taggare
- **Trimestrale**: Ogni 3 mesi per evitare drift
- **Manualmente**: Quando senti che i docs sono outdated

### Azioni Automatiche

| Situazione | Azione | Risultato |
|-----------|--------|-----------|
| Doc matchato col codice | ✅ KEEP | "Already current" |
| Doc outdated ma rilevante | 🔄 UPDATE | Aggiorna intelligentemente |
| Codice senza documentazione | ➕ CREATE | Crea doc in cartella corretta |
| Documentazione di feature rimossa | 🗑️ DELETE | Rimuove il file |
| Documentazione speculativa | 📦 ARCHIVE | Sposta in `archived/` |

### Esempio Uso
```
User: "Fammi un sync-docs per verificare che tutto sia aggiornato"
Claude: "✅ SYNC-DOCS REPORT: Scanned 32 docs, 24 current, 5 updated, 2 created, 1 deleted"
```

**Vedi**: `.claude/commands/sync-docs.md` per dettagli completi

---

## 🆘 IN CASO DI DUBBI

### 📖 Documentazione da Consultare (in ordine)

1. **Questo file CLAUDE.md** - Regole obbligatorie e quick reference
2. **`ARCHITECTURAL_OPTIMIZATIONS_REPORT.md`** - Guida completa alle ottimizzazioni:
   - BuildContext Extensions (esempi, migrazione, metriche)
   - Loading Component (API completa, use cases)
   - Snackbar Service (preset semantici, custom options)
   - Modal Service (bottom sheets, dialogs, confirm flows)
3. **`docs/LOCALIZATION_GUIDE.md`** - Guida localizzazione dettagliata
4. **File esistenti come esempi**:
   - `lib/features/workout/presentation/widgets/add_exercise_modal.dart` (migrato)
   - `lib/features/workout/presentation/widgets/exercise_list_item.dart` (migrato)
   - Altri top 10 file migrati (vedi report)

### 🔧 Script e Tool Utili

- `./scripts/find_hardcoded_strings.sh` - Trova testi hardcoded
- `./scripts/migrate_to_context_extensions.sh <file>` - Migra file a extensions
- `flutter analyze` - Verifica qualità codice

---

> **⚠️ ATTENZIONE**: Questo progetto è in produzione. Ogni violazione di queste regole può causare problemi agli utenti. SEMPRE seguire le linee guida sopra indicate.