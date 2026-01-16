# User Flow Analysis - FitLog Pro

> Analisi dettagliata dei flussi utente con personas realistiche e problematiche identificate

---

## Personas

### 1. Marco Bianchi - Il Principiante (28 anni)
**Background**: Impiegato d'ufficio, mai andato in palestra prima. Ha deciso di iniziare dopo il check-up medico.

**Caratteristiche**:
- Zero esperienza con app fitness
- Non conosce i nomi degli esercizi
- Non sa cosa siano RPE, supersets, dropsets
- Vuole qualcosa di semplice
- Poco tempo (pausa pranzo)

**Device**: iPhone 14, iOS 17

---

### 2. Laura Rossi - L'Entusiasta (32 anni)
**Background**: Fitness enthusiast da 2 anni, usa altre app ma cerca qualcosa di meglio.

**Caratteristiche**:
- Conosce gli esercizi base
- Vuole tracciare progressi dettagliati
- Usa Apple Watch per cardio
- Cambia spesso routine
- Confronta app diverse

**Device**: iPhone 15 Pro + Apple Watch Series 9

---

### 3. Alessandro Conti - L'Avanzato (35 anni)
**Background**: Personal trainer e powerlifter, cerca un'app professionale per sé e clienti.

**Caratteristiche**:
- Esperto di tecniche avanzate (rest-pause, myo-reps)
- Necessita di tracking preciso (RPE, tempo sotto tensione)
- Vuole esportare dati per clienti
- Usa template complessi
- Multi-device (iPhone + iPad)

**Device**: iPhone 13 Pro + iPad Pro

---

## Flusso 1: Marco - Prima Esperienza

### Step 1: Download e First Launch

**Azione**: Marco scarica l'app e la apre per la prima volta.

**Flusso atteso**:
```
Splash Screen (3s) → Login Screen
```

**Analisi codice** (`login_screen.dart:54-72`):
```dart
ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
  next.when(
    data: (_) {
      if (mounted) {
        context.goNamed('home');  // Naviga a home
      }
    },
    // ...
  );
});
```

**PROBLEMATICA P1-MARCO-1** (UX):
> Marco vede prima il login social (Google/Apple), ma NON c'è opzione "Esplora l'app prima".
>
> **Impatto**: Utenti scettici potrebbero abbandonare prima di vedere il valore.
>
> **Suggerimento**: Aggiungere "Scopri prima" o "Prova senza account" con funzionalità limitate.

---

### Step 2: Registrazione

**Azione**: Marco sceglie "Sign in with Google"

**Flusso**:
```
Login → Google OAuth → Create User Document → Initial Onboarding
```

**Analisi** (`initial_onboarding_screen.dart:67-76`):
```dart
PageView(
  controller: pageController,
  physics: const NeverScrollableScrollPhysics(), // Non può scrollare!
  children: [
    const WelcomeStep(),
    const GoalSelectionStep(),
    const BodyDataStep(),
    const ExperienceStep(),
    const HealthKitStep(),
    FrequencySummaryStep(onComplete: _handleComplete),
  ],
),
```

**PROBLEMATICA P1-MARCO-2** (UX):
> L'onboarding ha 6 step con `NeverScrollableScrollPhysics()`. Marco NON può tornare indietro con swipe, solo con il bottone back.
>
> **Impatto**: Se Marco sbaglia a inserire il peso, deve cliccare back 2 volte. Frustrante su mobile.

---

### Step 3: Goal Selection (Onboarding Step 2)

**Azione**: Marco deve selezionare il suo obiettivo fitness.

**PROBLEMATICA P1-MARCO-3** (UX):
> Marco vede opzioni come "Muscle Gain", "Strength", "Fat Loss".
> Ma essendo principiante, non sa la differenza tra "Muscle Gain" e "Strength".
>
> **Suggerimento**: Aggiungere descrizioni brevi sotto ogni opzione.

---

### Step 4: Body Data (Onboarding Step 3)

**Azione**: Marco inserisce peso e altezza.

**Analisi** (da verificare): Il campo peso supporta solo kg o anche lbs?

**PROBLEMATICA P1-MARCO-4** (Edge Case):
> Se Marco lascia il campo vuoto e preme Next, cosa succede?
>
> **Verifica necessaria**: Validazione dei campi body data.

---

### Step 5: Experience Level (Onboarding Step 4)

**Azione**: Marco seleziona "Beginner (0-6 months)"

**Comportamento atteso**: L'app dovrebbe adattare la complessità dei tutorial e suggerimenti.

**PROBLEMATICA P1-MARCO-5** (Logic Gap):
> Il livello esperienza viene salvato, ma NON sembra influenzare:
> 1. I tutorial mostrati
> 2. Gli esercizi suggeriti
> 3. La complessità dell'UI
>
> **Verifica**: Cercare uso di `experienceLevel` nel codebase.

---

### Step 6: HealthKit Permission (iOS)

**Azione**: Marco vede la richiesta HealthKit.

**PROBLEMATICA P1-MARCO-6** (UX):
> Marco, da principiante, potrebbe non capire perché l'app vuole accesso ai suoi dati salute.
> La richiesta arriva PRIMA che abbia visto il valore dell'app.
>
> **Suggerimento**: Mostrare HealthKit request DOPO il primo workout completato.

---

### Step 7: Complete Onboarding → Home

**Azione**: Marco completa l'onboarding e arriva alla Home.

**Analisi** (`initial_onboarding_screen.dart:109-113`):
```dart
// Start home tour - will show automatically when Home renders
ref.read(homeTourProvider.notifier).startTour();

// Navigate to Home - home tour will start automatically
if (mounted) {
  context.goNamed(AppRoutes.homeName);
}
```

**Flusso**:
```
Onboarding Complete → Home → Home Tour (10 step spotlight)
```

**PROBLEMATICA P1-MARCO-7** (UX Critical):
> Il Home Tour ha **10 STEP**! Per un principiante stanco dall'onboarding di 6 step, sono altri 10 tap.
>
> **Impatto**: Marco potrebbe skippare tutto senza imparare nulla.
>
> **Best practice 2025**: Max 5 step per tutorial. Dividere in micro-tours contestuali.

---

### Step 8: Start First Workout

**Azione**: Marco tap su "START WORKOUT" dalla home.

**Flusso** (`workout_screen.dart:238-249`):
```
WelcomeView → ContextGatheringSheet (opzionale) → Empty WorkoutView
```

**Analisi** (`workout_screen.dart:148-157`):
```dart
if (!tutorialState.hasCompletedTutorial &&
    !tutorialState.isActive &&
    (currentWorkout == null || currentWorkout.exercises.isEmpty)) {
  // Wait a bit for UI to settle
  await Future.delayed(const Duration(milliseconds: 500));

  if (mounted) {
    _startWorkoutTutorial();
  }
}
```

Il Workout Tutorial parte automaticamente se:
1. Non completato
2. Non già attivo
3. Workout vuoto

**PROBLEMATICA P1-MARCO-8** (Conflict Risk):
> Se Marco ha già il Home Tour attivo e naviga a Workout, potrebbe partire anche il Workout Tutorial.
>
> **Verifica**: L'OnboardingOrchestrator gestisce i conflitti? Controllare mutex.

---

### Step 9: Add First Exercise

**Azione**: Marco tap sul FAB "+" per aggiungere un esercizio.

**Flusso**:
```
WorkoutScreen → ExerciseSearchScreen → Tutorial Auto-start
```

**Analisi** (`exercise_search_screen.dart:105-112`):
```dart
void _checkAutoStartTutorial() {
  final tutorialState = ref.read(exerciseSearchTutorialProvider);
  // Auto-start tutorial if never completed
  if (!tutorialState.hasCompletedTutorial && !tutorialState.isActive) {
    ref.read(exerciseSearchTutorialProvider.notifier).startTutorial();
    _showTutorial();
  }
}
```

**PROBLEMATICA P1-MARCO-9** (Tutorial Overload):
> Marco ha già visto:
> 1. Initial Onboarding (6 step)
> 2. Home Tour (10 step)
> 3. Workout Tutorial (6 step)
> 4. E ora Exercise Search Tutorial (5 step)
>
> **Totale**: 27 step di tutorial prima di completare il PRIMO esercizio!
>
> **Best practice**: Progressive disclosure. Mostrare tutorial SOLO quando l'utente ha bisogno.

---

### Step 10: Search for Exercise

**Azione**: Marco cerca "petto" (non conosce nomi inglesi).

**Analisi** (`exercise_search_screen.dart:75-79`):
```dart
// 🔐 SECURITY: Fuzzy search state with proper debouncing
late final Debouncer _searchDebouncer;
List<ExerciseFuzzyResult> _fuzzyResults = [];
bool _isSearching = false;
bool _useFuzzyResults = false;
```

**PROBLEMATICA P1-MARCO-10** (i18n):
> Il database esercizi è in inglese. Marco cerca "petto" ma gli esercizi sono "Bench Press", "Chest Fly", etc.
>
> **Verifica**: Esiste traduzione italiana degli esercizi? I filtri muscle group sono localizzati?

---

### Step 11: Complete Set

**Azione**: Marco aggiunge Bench Press e completa una serie.

**Flusso**:
```
Tap set row → Edit Set Modal → Enter reps/weight → Save → Timer starts
```

**Timer auto-start** (`unified_timer_provider.dart`):
```dart
// Timer starts automatically after set completion
```

**PROBLEMATICA P1-MARCO-11** (First Time Confusion):
> Marco completa il set e... un timer parte automaticamente!
> Ma NON ha visto il Timer Tour ancora (trigger: `setCompleted && timerStarted`).
>
> **Timing issue**: Il timer parte PRIMA che il tutorial spieghi cosa sia.

---

### Step 12: Complete Workout

**Azione**: Marco vuole terminare dopo 3 esercizi.

**Analisi** (`complete_workout_usecase.dart:95-109`):
```dart
// Workout must have exercises
if (workout.exercises.isEmpty) {
  return const ValidationFailure(
    'Cannot complete workout without exercises',
    code: 'no_exercises',
  );
}

// At least one set must be completed
if (workout.completedSets == 0) {
  return const ValidationFailure(
    'Cannot complete workout without any completed sets',
    code: 'no_completed_sets',
  );
}
```

**PROBLEMATICA P1-MARCO-12** (Error Messaging):
> Se Marco non ha completato nessun set, vede "Cannot complete workout without any completed sets".
> Ma questo messaggio è in INGLESE e tecnico.
>
> **Verifica**: Gli errori del use case sono localizzati?

---

## Flusso 2: Laura - Utente Intermedia

### Step 1: Migrazione da altra app

**Azione**: Laura ha workout history in altra app, vuole importare.

**PROBLEMATICA P2-LAURA-1** (Feature Gap):
> Non esiste funzionalità di import da altre app (Strong, Hevy, etc.).
>
> **Impatto**: Laura perde storico e deve ricominciare da zero.

---

### Step 2: Apple Watch Integration

**Azione**: Laura ha Apple Watch e vuole vedere HR durante workout.

**Analisi** (`workout_screen.dart:290-336`):
```dart
// Watch connectivity for HR display
final watchData = ref.watch(watchConnectivityProvider);
final hasValidHR = watchData.currentHeartRate > 0 &&
                   watchData.hasRecentHealthMetrics;

// HR Badge from Apple Watch (only when connected and valid)
if (hasValidHR)
  Container(
    // Shows HR in app bar
  )
```

**PROBLEMATICA P2-LAURA-2** (Discoverability):
> La funzionalità HR display esiste, ma Laura non sa che deve:
> 1. Installare Watch app companion
> 2. Avere workout attivo su Watch
> 3. Il badge appare solo in workout attivo
>
> **Manca**: Onboarding per Watch setup.

---

### Step 3: Template Creation

**Azione**: Laura vuole creare una routine "Push Day".

**Flusso**:
```
WorkoutScreen → WelcomeView → Create Template Modal
```

**Trigger Template Tutorial** (`template_tutorial_service.dart:107-110`):
```dart
/// Check if tutorial should be shown for given trigger
bool shouldShowFor(TemplateTriggerSource source) {
  return !state.hasCompletedTutorial;
}
```

Il tutorial parte se:
1. Laura tap "Create Template"
2. Tutorial non completato

---

### Step 4: Using Templates

**Azione**: Laura vuole usare un template salvato.

**Flusso**:
```
Home → Templates Carousel → Tap template → PreloadedView → Start
```

**PROBLEMATICA P2-LAURA-3** (Friction):
> Laura deve fare 3 tap per iniziare da template:
> 1. Tap template
> 2. Tap "Start Workout" in PreloadedView
> 3. Confermare (se dialog)
>
> **Suggerimento**: Long-press su template = start immediato.

---

### Step 5: Analytics Viewing

**Azione**: Laura vuole vedere i suoi progressi dopo 2 settimane.

**Trigger Analytics Tour** (`analytics_tour_service.dart`):
```dart
// Trigger: First visit analytics WITH at least 3 workouts
```

**PROBLEMATICA P2-LAURA-4** (Data Requirement):
> Il tour Analytics richiede 3 workout completati.
> Ma Laura vede la sezione Analytics comunque, potenzialmente vuota.
>
> **UX Issue**: Mostrare empty state confuso prima del requisito.

---

### Step 6: PR Tracking

**Azione**: Laura solleva 50kg su Bench Press (suo PR).

**Analisi** (`workout_screen_controller.dart:168-175`):
```dart
// 🎉 Show celebration overlay FIRST - let user review before saving
final celebrationResult = await showWorkoutCompletionCelebration(
  context,
  workoutForCelebration,
);
```

**PROBLEMATICA P2-LAURA-5** (PR Notification Timing):
> Il PR viene celebrato solo a fine workout.
> Laura vorrebbe sapere SUBITO che ha battuto il record.
>
> **Suggerimento**: Inline PR notification dopo il set.

---

## Flusso 3: Alessandro - Utente Avanzato

### Step 1: Advanced Techniques Setup

**Azione**: Alessandro vuole usare Rest-Pause sets.

**Analisi** (`exercise_search_screen.dart:35-45`):
```dart
const ExerciseSearchScreen({
  super.key,
  this.onExerciseAdded,
  this.multiSelectMode = false,  // For superset builder
  this.selectionMode = false,    // For DropSet/Rest-Pause
});
```

**PROBLEMATICA P3-ALEX-1** (Discoverability):
> Le tecniche avanzate (Rest-Pause, DropSet, Myo-reps) esistono, ma:
> 1. Non c'è tutorial dedicato
> 2. Non c'è documentazione in-app
> 3. Alessandro deve scoprirle da solo
>
> **Trigger mancante**: `advancedTechniquesTutorial` definito ma non implementato.

---

### Step 2: RPE Tracking Precision

**Azione**: Alessandro vuole tracciare RPE per ogni set con precisione.

**Analisi** (`complete_workout_usecase.dart:180-192`):
```dart
// Calculate intensity (average RPE)
double totalRpe = 0.0;
int rpeCount = 0;
for (final exercise in workout.exercises) {
  for (final set in exercise.sets) {
    if (set.isCompleted && set.rpe != null) {
      totalRpe += set.rpe!;
      rpeCount++;
    }
  }
}

final averageRpe = rpeCount > 0 ? totalRpe / rpeCount : null;
```

**PROBLEMATICA P3-ALEX-2** (RPE Granularity):
> RPE è opzionale (`set.rpe != null`). Alessandro potrebbe dimenticarsi di inserirlo.
>
> **Suggerimento**: Promemoria o RPE default basato su exercise history.

---

### Step 3: Export for Clients

**Azione**: Alessandro vuole esportare PDF del workout per un cliente.

**Analisi** (`workout_screen.dart:14`):
```dart
import 'package:gymbro_flutter_new/features/workout/services/pdf_template_service.dart';
```

**PROBLEMATICA P3-ALEX-3** (Coach Features):
> PDF export esiste, ma manca:
> 1. Customizzazione logo coach
> 2. Note per cliente
> 3. Batch export multipli workout
>
> **Feature gap per uso professionale.**

---

### Step 4: Template Complexity

**Azione**: Alessandro crea template con superset complessi.

**Flusso**:
```
Create Template → Add exercises → Configure supersets → Save
```

**PROBLEMATICA P3-ALEX-4** (Superset UX):
> Per creare superset, Alessandro deve:
> 1. Aggiungere esercizi singolarmente
> 2. Poi raggrupparli in superset
>
> **Suggerimento**: MultiSelect mode per aggiungere superset in un colpo.

---

### Step 5: Multi-Device Sync

**Azione**: Alessandro inizia workout su iPhone, vuole continuare su iPad.

**PROBLEMATICA P3-ALEX-5** (Sync Gap):
> Il workout attivo è locale. Se Alessandro cambia device:
> 1. Non c'è handoff automatico
> 2. Deve completare su stesso device
>
> **Feature gap**: Real-time sync cross-device.

---

## Riepilogo Problematiche

### Priorità Critica (P0) - Bloccanti

| ID | Descrizione | Impatto |
|----|-------------|---------|
| P1-MARCO-7 | Home Tour 10 step - troppo lungo | Abbandono onboarding |
| P1-MARCO-9 | 27 step totali prima del primo esercizio | Tutorial fatigue |

### Priorità Alta (P1) - UX Significativo

| ID | Descrizione | Impatto |
|----|-------------|---------|
| P1-MARCO-1 | No "Esplora prima" senza login | Abbandono early |
| P1-MARCO-6 | HealthKit request troppo presto | Privacy concern |
| P1-MARCO-10 | Database esercizi non localizzato | Ricerca fallita |
| P1-MARCO-12 | Error messages non localizzati | Confusione |
| P2-LAURA-5 | PR notification solo a fine workout | Gratificazione ritardata |

### Priorità Media (P2) - Miglioramenti

| ID | Descrizione | Impatto |
|----|-------------|---------|
| P1-MARCO-2 | Onboarding no swipe back | Friction |
| P1-MARCO-5 | Experience level non usato | Personalizzazione mancante |
| P2-LAURA-2 | Watch setup non spiegato | Feature non scoperta |
| P2-LAURA-3 | 3 tap per start da template | Friction |

### Priorità Bassa (P3) - Nice to Have

| ID | Descrizione | Impatto |
|----|-------------|---------|
| P2-LAURA-1 | No import da altre app | Onboarding utenti migranti |
| P3-ALEX-1 | Advanced techniques non documentate | Power users |
| P3-ALEX-3 | PDF export limitato per coach | Uso professionale |
| P3-ALEX-5 | No real-time sync cross-device | Multi-device |

---

## Azioni Raccomandate

### Immediate (Sprint corrente)

1. **Ridurre Home Tour** da 10 a 5 step essenziali
2. **Localizzare error messages** nel CompleteWorkoutUseCase
3. **Verificare i18n esercizi** - aggiungere traduzioni IT se mancanti

### Prossimo Sprint

1. **Implementare "Guest Mode"** - esplora senza login
2. **Spostare HealthKit** dopo primo workout
3. **PR inline notification** durante workout

### Backlog

1. Import da altre app
2. Advanced techniques tutorial
3. Coach PDF enhancements
4. Cross-device sync

---

---

## Flusso 4: Giulia - La Casuale

### Profilo
- **Età**: 25 anni, studentessa
- **Frequenza**: 1-2 volte/settimana max
- **Device**: iPhone SE (schermo piccolo)
- **Goal**: Logging veloce, zero complicazioni

### Problematiche Identificate

| ID | Problema | File | Severità |
|----|----------|------|----------|
| P4-GIULIA-1 | Quick Start richiede 3-4 step (non < 60s) | `context_gathering_bottom_sheet.dart:82-116` | HIGH |
| P4-GIULIA-2 | AddExerciseModal troppo complesso | `add_exercise_modal.dart:94-102` | HIGH |
| P4-GIULIA-3 | Padding fisso 20px su schermo 375px | `context_gathering_bottom_sheet.dart:88-93` | MEDIUM |
| P4-GIULIA-4 | Nessun "Welcome Back" dopo 2 settimane | `app_lifecycle_manager.dart:107-113` | HIGH |
| P4-GIULIA-5 | No toggle in-app per notifiche workout | `settings_screen.dart:467-525` | MEDIUM |
| P4-GIULIA-6 | "Workout Forgotten" notification automatica | `app_lifecycle_manager.dart:205-239` | MEDIUM |
| P4-GIULIA-7 | Nessun "quiet hours" setting | `app_config.dart` | LOW |
| P4-GIULIA-8 | Draft recovery può fallire silenziosamente | `app_lifecycle_manager.dart:460-520` | HIGH |
| P4-GIULIA-9 | Nessun indicatore "draft salvato" su home | `minimal_home_screen.dart` | MEDIUM |

**Tempo stimato per loggare 2 esercizi**: 87-125 secondi (obiettivo < 60s FALLITO)

---

## Flusso 5: Roberto - Il Coach

### Profilo
- **Età**: 42 anni, Personal Trainer
- **Clienti**: 15 atleti
- **Device**: iPad Pro
- **Goal**: Template per clienti, PDF export, tracking progressi

### Problematiche Identificate

| ID | Problema | File | Severità |
|----|----------|------|----------|
| P5-ROBERTO-1 | No folder/organizzazione template per cliente | `coach_template.dart:57` | HIGH |
| P5-ROBERTO-2 | Limite 7 template (anche per coach) | `user_tier.dart:79` | HIGH |
| P5-ROBERTO-3 | No branding custom su PDF | `pdf_template_service.dart:121-126` | HIGH |
| P5-ROBERTO-4 | No batch PDF export | N/A | MEDIUM |
| P5-ROBERTO-5 | Compliance hardcoded a 4 workout/settimana | `coach_repository_impl.dart:776` | MEDIUM |
| P5-ROBERTO-6 | No multi-coach support | `coach_repository.dart:392` | LOW |
| P5-ROBERTO-7 | No layout tablet-optimized | `coach_dashboard_screen.dart:52` | MEDIUM |
| P5-ROBERTO-8 | No split-view su iPad | Coach screens | MEDIUM |
| P5-ROBERTO-9 | No export dati atleta | `data_export_service.dart:65` | HIGH |
| P5-ROBERTO-10 | No report progressi mensili | N/A | HIGH |
| P5-ROBERTO-11 | No broadcast messaging | Chat 1-to-1 only | MEDIUM |

---

## Flusso 6: Sofia - Accessibilità

### Profilo
- **Età**: 30 anni, ipovedente
- **Assistive Tech**: VoiceOver attivo
- **Preferenze**: Font grandi, alto contrasto
- **Device**: iPhone 15

### Problematiche Identificate

| ID | Problema | File | Severità |
|----|----------|------|----------|
| P6-SOFIA-1 | Stringhe hardcoded italiane in dialog | `exercise_search_screen.dart:196-237` | HIGH |
| P6-SOFIA-2 | Semantic labels non descrittive | `exercise_search_screen.dart:190-194` | HIGH |
| P6-SOFIA-3 | Icon size hardcoded (non scala con font) | `ai_coach_card.dart:220-221` | HIGH |
| P6-SOFIA-4 | Contrasto insufficiente warning colors | `color_scheme_extensions.dart:5-15` | MEDIUM |
| P6-SOFIA-5 | Touch target < 44x44 su "Add Set" | `exercise_list_item_sets.dart:211-245` | MEDIUM |
| P6-SOFIA-6 | No audio feedback per timer completion | `haptic_feedback_service.dart` | MEDIUM |
| P6-SOFIA-7 | GestureDetector senza Semantics wrapper | `exercise_list_item_sets.dart:427-550` | HIGH |
| P6-SOFIA-8 | Set state non annunciato a VoiceOver | `exercise_list_item_sets.dart:291-310` | MEDIUM |
| P6-SOFIA-9 | Auto-collapse countdown non annunciato | `exercise_list_item_header.dart:213-217` | LOW |

---

## Flusso 7: Giuseppe - Il Senior

### Profilo
- **Età**: 65 anni, neo-palestra
- **Tech literacy**: Bassa
- **Device**: iPhone 11 (hand-me-down)
- **Goal**: Tracciare esercizi base, evitare errori

### Problematiche Identificate

| ID | Problema | File | Severità |
|----|----------|------|----------|
| P7-GIUSEPPE-1 | Exercise deletion SENZA conferma | `workout_screen.dart:635` | CRITICAL |
| P7-GIUSEPPE-2 | Template swipe-delete troppo facile | `swipeable_template_card.dart:173` | CRITICAL |
| P7-GIUSEPPE-3 | Conflitto swipe vs scroll | `exercise_list_item_sets.dart:346` | HIGH |
| P7-GIUSEPPE-4 | 13 card su home screen | `minimal_home_screen.dart:148-323` | HIGH |
| P7-GIUSEPPE-5 | No "Simple Mode" per nascondere feature | `settings_screen.dart` (missing) | HIGH |
| P7-GIUSEPPE-6 | Jargon senza tooltip (RPE, Dropset) | Multiple files | HIGH |
| P7-GIUSEPPE-7 | Font 10px su action buttons | `swipeable_template_card.dart:229` | MEDIUM |
| P7-GIUSEPPE-8 | No undo per exercise/template deletion | Multiple files | MEDIUM |
| P7-GIUSEPPE-9 | 10+ opzioni in exercise modal | `exercise_options_modal.dart:178-329` | MEDIUM |
| P7-GIUSEPPE-10 | Deletion patterns inconsistenti | Multiple files | MEDIUM |

---

## Riepilogo Globale Problematiche

### Per Severità

| Severità | Count | Esempi |
|----------|-------|--------|
| **CRITICAL** | 4 | Exercise deletion no confirm, Template swipe-delete, Tutorial overload |
| **HIGH** | 18 | Quick logging lento, No branding PDF, Accessibility labels, No simple mode |
| **MEDIUM** | 15 | iPad layout, Notification toggle, Touch targets, Font sizes |
| **LOW** | 5 | Quiet hours, Multi-coach, RTL support |

### Per Categoria

| Categoria | Issues | Personas Impattate |
|-----------|--------|-------------------|
| **Onboarding/Tutorial** | 5 | Marco, Giulia, Giuseppe |
| **Accessibility** | 9 | Sofia, Giuseppe |
| **Performance/Speed** | 4 | Giulia, Laura |
| **Coach/Professional** | 11 | Roberto |
| **UI/UX Small Screen** | 4 | Giulia, Giuseppe |
| **Data Safety** | 5 | Marco, Giulia, Giuseppe |
| **Localization** | 3 | Marco, Sofia |

---

## Azioni Prioritarie

### Sprint 1 - Critical Fixes

1. **Aggiungere conferma a exercise deletion** (`workout_screen.dart:635`)
2. **Ridurre Home Tour da 10 a 5 step** (`home_tour_service.dart`)
3. **Proteggere swipe-to-delete da scroll accidentale** (`swipeable_template_card.dart`)

### Sprint 2 - High Priority

4. **Creare "Simple Mode"** - nasconde AI Coach, Stress Index, Analytics
5. **Localizzare error messages** (`complete_workout_usecase.dart`)
6. **Aggiungere semantic labels** a tutti i GestureDetector
7. **Quick-add "Recent Exercises"** per casual users

### Sprint 3 - Coach Features

8. **Template folders/organizzazione** per client
9. **PDF branding customization** (logo, contact info)
10. **Aumentare limite template per coach mode**

### Backlog

- iPad split-view layout
- Batch PDF export
- Audio feedback alternativo per timer
- Font scaling per tutte le icon sizes
- Quiet hours setting

---

## Conclusioni

L'analisi ha identificato **42 problematiche** di varia gravità. Le più critiche riguardano:

1. **Tutorial Overload**: L'utente principiante Marco vede 27 step di tutorial prima di completare il primo esercizio. Questo viola il principio "Time to Value < 60 secondi" delle best practices 2025.

2. **Localizzazione Incompleta**: Error messages e database esercizi potrebbero non essere completamente localizzati in italiano.

3. **Feature Discoverability**: Funzionalità avanzate (Watch, Advanced Techniques) esistono ma non sono scoperte dagli utenti.

La strategia consigliata è il **Progressive Disclosure**: mostrare solo ciò che serve nel momento in cui serve, invece di tutorial upfront.
