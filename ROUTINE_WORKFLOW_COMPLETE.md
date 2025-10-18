# 🏋️ Flusso Completo delle Routine - GymBro TrackLog

> Documentazione completa del sistema di routine flessibili e collegamento con le sessioni di workout

## 📋 Indice

1. [Architettura Generale](#architettura-generale)
2. [Entities e Relazioni](#entities-e-relazioni)
3. [Flusso Completo: Dalla Creazione all'Esecuzione](#flusso-completo)
4. [Collegamento Routine ↔ Workout](#collegamento-routine--workout)
5. [Providers e State Management](#providers-e-state-management)
6. [Auto-Complete dei Giorni](#auto-complete-dei-giorni)
7. [Diagrammi di Flusso](#diagrammi-di-flusso)

---

## 🏗️ Architettura Generale

```
┌─────────────────────────────────────────────────────────────┐
│                      USER INTERFACE                          │
│  RoutineEditorScreen │ RoutineCenterScreen │ WorkoutScreen  │
└──────────────┬──────────────────┬──────────────────┬────────┘
               │                  │                  │
               ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│                     PROVIDERS (Riverpod)                     │
│  routineEditorProvider │ activeRoutineProvider │ workoutProv │
└──────────────┬──────────────────┬──────────────────┬────────┘
               │                  │                  │
               ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│                   REPOSITORIES (Domain)                      │
│  FlexibleRoutineRepository │ WorkoutRepository              │
└──────────────┬──────────────────┬─────────────────────────┘
               │                  │
               ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│                 DATA SOURCES (Firebase)                      │
│  flexibleRoutines collection │ workouts collection          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Entities e Relazioni

### 1. **WorkoutTemplate** (Template di Allenamento)
```dart
WorkoutTemplate {
  id: "template-123"
  name: "Push Day A"
  description: "Petto, spalle, tricipiti"
  exercises: [...]  // Lista di esercizi predefiniti
  estimatedDuration: 60
  isCustom: true
  createdAt: DateTime
}
```
**Scopo**: Template riutilizzabile di allenamento

---

### 2. **FlexibleRoutine** (Routine Pianificata)
```dart
FlexibleRoutine {
  id: "routine-456"
  userId: "user-789"
  name: "PPL 6 Days"
  type: RoutineType.weekly
  startDate: 2025-10-01
  endDate: 2025-12-31

  // Pattern di rotazione
  pattern: RoutinePattern {
    sequence: ["Push", "Pull", "Legs", "Rest", "Push", "Pull", "Legs"]
    type: PatternType.repeating
  }

  // Schedule generato dal pattern
  schedule: {
    "2025-10-01": ScheduledDay {
      date: 2025-10-01
      templateId: "template-123"  // 🔗 Link al template
      status: DayStatus.scheduled
      workoutId: null  // Null finché non completato
    },
    "2025-10-02": ScheduledDay {
      date: 2025-10-02
      templateId: "template-456"
      status: DayStatus.scheduled
    },
    ...
  }

  // Stato della routine
  isActive: false  // ⚠️ Ora creata come INACTIVE
  isArchived: false
  isCompleted: false

  // Statistiche
  totalWorkoutDays: 78
  completedDays: 0
  lastWorkoutDate: null
}
```
**Scopo**: Pianificazione multi-periodo con rotazione automatica dei template

---

### 3. **Workout** (Sessione di Allenamento Effettiva)
```dart
Workout {
  id: "workout-999"
  name: "Push Day A"
  templateId: "template-123"  // 🔗 Link al template di origine
  userId: "user-789"

  exercises: [...]  // Copia degli esercizi con dati REALI

  status: WorkoutStatus.completed
  startTime: 2025-10-01 09:00:00
  endTime: 2025-10-01 10:15:00
  completedAt: 2025-10-01 10:15:00

  notes: "Ottima sessione!"
}
```
**Scopo**: Istanza REALE di allenamento eseguito dall'utente

---

## 🔄 Flusso Completo

### **FASE 1: Creazione Routine** (Wizard 5 Step)

```
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: Basic Info                                          │
│ ────────────────                                            │
│ Input: name, description, type, startDate, endDate         │
│ Output: RoutineEditorState con dati base                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: Pattern Selection                                   │
│ ──────────────────────                                      │
│ Options:                                                     │
│ - Preset: "PPL", "Upper/Lower", "Full Body", etc.          │
│ - Custom: Drag & drop giorni personalizzati                │
│                                                              │
│ Output: RoutinePattern {                                    │
│   sequence: ["Push", "Pull", "Legs", "Rest"]               │
│   type: PatternType.repeating                               │
│ }                                                            │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: Template Selection                                  │
│ ───────────────────────                                     │
│ - Lista di tutti i WorkoutTemplate dell'utente             │
│ - Checkbox per selezionare quali usare                     │
│ - Empty state se nessun template disponibile               │
│                                                              │
│ Output: List<String> selectedTemplates = [                 │
│   "template-push-a",                                        │
│   "template-pull-a",                                        │
│   "template-legs-a"                                         │
│ ]                                                            │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 4: Template Rotation                                   │
│ ────────────────────────                                    │
│ - Drag & drop per riordinare i template selezionati        │
│ - Preview della distribuzione sui primi 10 giorni          │
│                                                              │
│ Esempio Preview:                                            │
│ Day 1 (1/10): 💪 Push Day A                                │
│ Day 2 (2/10): 🏋️ Pull Day A                                │
│ Day 3 (3/10): 🦵 Legs Day A                                 │
│ Day 4 (4/10): 😴 Rest                                       │
│ Day 5 (5/10): 💪 Push Day A (rotation restart)             │
│ ...                                                          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 5: Review & Create                                     │
│ ───────────────────────                                     │
│ - Riepilogo di tutti i dati                                │
│ - Validazione finale                                        │
│ - Click "Create" → chiama createRoutine()                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ FlexibleRoutineNotifier.createRoutine()                    │
│ ───────────────────────────────────────                    │
│ 1. Crea FlexibleRoutine.create() con isActive = FALSE ⚠️  │
│ 2. Genera schedule completo con _generateScheduleWith...  │
│ 3. Rotazione automatica template sui giorni workout        │
│ 4. Salva su Firebase: collection('flexibleRoutines')      │
│ 5. Mostra: "Routine creata! Vai al Centro per attivarla"  │
└─────────────────────────────────────────────────────────────┘
```

**Risultato FASE 1**:
```dart
// Firebase: collection('flexibleRoutines')
{
  id: "routine-new-123"
  userId: "user-789"
  name: "My PPL Routine"
  isActive: false  // ⚠️ NON ATTIVA - deve essere attivata manualmente
  schedule: {
    "2025-10-14": {
      templateId: "template-push-a",
      status: "scheduled",
      workoutId: null
    },
    "2025-10-15": {
      templateId: "template-pull-a",
      status: "scheduled",
      workoutId: null
    },
    // ... 90 giorni schedulati
  }
}
```

---

### **FASE 2: Attivazione Routine** (Routine Center)

```
┌─────────────────────────────────────────────────────────────┐
│ RoutineCenterScreen                                         │
│ ───────────────────                                         │
│ Stream: userFlexibleRoutinesProvider                       │
│ ↓ Mostra TUTTE le routine (attive e non)                   │
│                                                              │
│ 📋 Active Routines:                                         │
│   ✅ [My Old Routine] (Active)                             │
│                                                              │
│ 📋 Available Routines:                                      │
│   ⭕ [My PPL Routine] (Inactive) ← Tap per attivare        │
│   ⭕ [Summer Shred] (Inactive)                              │
└─────────────────────────────────────────────────────────────┘
                            │
                     User taps "Activate"
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ FlexibleRoutineNotifier.activateRoutine(routineId)        │
│ ───────────────────────────────────────────────            │
│ 1. Repository.activateRoutine()                            │
│ 2. Batch operation su Firebase:                            │
│    a. Deactivate ALL routines (isActive = false)           │
│    b. Activate target routine (isActive = true)            │
│ 3. Stream aggiorna automaticamente la UI                   │
└─────────────────────────────────────────────────────────────┘
```

**Risultato FASE 2**:
```dart
// Firebase dopo attivazione
{
  id: "routine-new-123"
  isActive: true  // ✅ ORA ATTIVA
  // ... resto invariato
}

// Stream aggiorna automaticamente:
activeFlexibleRoutineProvider → emette la nuova routine attiva
```

---

### **FASE 3: Esecuzione Workout** (Collegamento Routine → Workout)

```
┌─────────────────────────────────────────────────────────────┐
│ Home Screen / Workout Screen                                │
│ ───────────────────────────                                 │
│ 1. activeFlexibleRoutineProvider fornisce routine attiva   │
│ 2. routine.nextWorkoutDate → data prossimo allenamento     │
│ 3. routine.getScheduledDay(today) → templateId per oggi    │
└─────────────────────────────────────────────────────────────┘
                            │
                User clicks "Start Workout"
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ Create Workout Instance                                     │
│ ───────────────────────                                     │
│ WorkoutFromTemplate.create(template) {                     │
│   id: "workout-new-abc"                                     │
│   name: template.name                                       │
│   templateId: "template-push-a"  // 🔗 Link              │
│   exercises: [...] // Copia da template                    │
│   status: WorkoutStatus.inProgress                          │
│   startTime: DateTime.now()                                 │
│ }                                                            │
└─────────────────────────────────────────────────────────────┘
                            │
                   User completa workout
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ Complete Workout                                            │
│ ────────────────                                            │
│ 1. workout.completeWorkout()                                │
│ 2. Salva su Firebase: collection('workouts')               │
│    - userId: "user-789"                                     │
│    - templateId: "template-push-a"                          │
│    - completedAt: DateTime.now()                            │
│    - exercises: [...] con dati REALI (peso, reps, etc)    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ Auto-Complete Routine Day                                   │
│ ──────────────────────────                                  │
│ dayAutoCompleteStatusProvider rileva:                       │
│ 1. Workout completato oggi ✅                               │
│ 2. templateId match con scheduledDay ✅                     │
│ 3. Auto-aggiorna la routine:                                │
│                                                              │
│ routine.completeDay(date, workoutId) {                     │
│   schedule["2025-10-14"] = ScheduledDay {                  │
│     status: DayStatus.completed  // ✅ COMPLETATO          │
│     workoutId: "workout-new-abc"  // 🔗 Link al workout   │
│     templateId: "template-push-a"                           │
│   }                                                          │
│   completedDays: 1  // incrementato                         │
│   lastWorkoutDate: 2025-10-14                               │
│ }                                                            │
└─────────────────────────────────────────────────────────────┘
```

**Risultato FASE 3**:
```dart
// Firebase: collection('workouts')
{
  id: "workout-abc"
  userId: "user-789"
  name: "Push Day A"
  templateId: "template-push-a"  // 🔗 Link
  completedAt: "2025-10-14T10:15:00Z"
  exercises: [
    {
      name: "Panca Piana",
      sets: [
        { weight: 80, reps: 8, isCompleted: true },
        { weight: 85, reps: 6, isCompleted: true }
      ]
    }
  ]
}

// Firebase: collection('flexibleRoutines') - AGGIORNATO
{
  id: "routine-new-123"
  schedule: {
    "2025-10-14": {
      status: "completed",  // ✅ Auto-completato
      workoutId: "workout-abc",  // 🔗 Link al workout
      templateId: "template-push-a"
    }
  },
  completedDays: 1,
  lastWorkoutDate: "2025-10-14"
}
```

---

## 🔗 Collegamento Routine ↔ Workout

### Struttura delle Relazioni

```
WorkoutTemplate (Reusable)
    ↓ id: "template-push-a"
    │
    ├──→ FlexibleRoutine.schedule["2025-10-14"]
    │    └── templateId: "template-push-a"  (PIANIFICATO)
    │
    └──→ Workout (Instance)
         ├── templateId: "template-push-a"  (ESEGUITO)
         └── workoutId: "workout-abc"
              ↓
         FlexibleRoutine.schedule["2025-10-14"]
         └── workoutId: "workout-abc"  (COLLEGATO)
```

### Query per Auto-Complete

```dart
// Provider: completedWorkoutsByDateProvider
FirebaseFirestore.instance
  .collection('workouts')
  .where('userId', isEqualTo: userId)
  .where('completedAt', isGreaterThanOrEqualTo: startOfDay)
  .where('completedAt', isLessThanOrEqualTo: endOfDay)
  .get()

// Logica di match:
for (workout in completedWorkouts) {
  if (workout.templateId == scheduledDay.templateId) {
    // ✅ MATCH! Auto-complete il giorno della routine
    routine.completeDay(date, workout.id);
  }
}
```

---

## 🎮 Providers e State Management

### Provider Hierarchy

```dart
// 1. USER AUTHENTICATION
_currentUserIdProvider → userId from FirebaseAuth

// 2. ROUTINE PROVIDERS (Real-time Streams)
activeFlexibleRoutineProvider
  ├─→ Stream<FlexibleRoutine?> della routine ATTIVA
  └─→ Usato da: HomeScreen, WorkoutScreen

userFlexibleRoutinesProvider
  ├─→ Stream<List<FlexibleRoutine>> di TUTTE le routine
  └─→ Usato da: RoutineCenterScreen

routineByIdProvider(id)
  ├─→ Stream<FlexibleRoutine?> di una specifica routine
  └─→ Usato da: RoutineDetailScreen

// 3. WORKOUT PROVIDERS
completedWorkoutsByDateProvider(date)
  ├─→ Future<List<Workout>> dei workout completati in una data
  └─→ Usato da: Auto-complete logic

dayAutoCompleteStatusProvider(params)
  ├─→ Future<DayAutoCompleteStatus> verifica se auto-completare
  └─→ Usato da: WorkoutCompletionFlow

// 4. TEMPLATE PROVIDERS
allWorkoutTemplatesProvider
  ├─→ Stream<List<WorkoutTemplate>> di tutti i template
  └─→ Usato da: TemplateSelectionStep, WorkoutCreation
```

---

## 🤖 Auto-Complete dei Giorni

### Flusso Automatico

```
User Completa Workout
        ↓
1. Salva workout su Firebase
        ↓
2. dayAutoCompleteStatusProvider si attiva
        ↓
3. Controlla: workout.templateId == scheduledDay.templateId?
        ↓
   ┌─────YES─────┐        ┌─────NO─────┐
   │             │        │            │
   ▼             │        ▼            │
✅ AUTO-COMPLETE │    ❌ NON AUTO    │
   │             │        │            │
   ├─→ Update    │        ├─→ Mostra  │
   │   routine   │        │   dialog   │
   │   schedule  │        │   "Vuoi    │
   │             │        │   contare  │
   ├─→ Mark day  │        │   come     │
   │   completed │        │   sostituto?"
   │             │        │            │
   ├─→ Link      │        └────────────┘
   │   workoutId │
   │             │
   └─→ Increment │
       stats     │
```

### Codice Auto-Complete

```dart
// lib/features/routine/presentation/providers/flexible_routine_provider.dart:186

final dayAutoCompleteStatusProvider =
    FutureProvider.family<DayAutoCompleteStatus, DayCheckParams>(
  (ref, params) async {
    // 1. Ottieni workout completati oggi
    final completedWorkouts = await ref.watch(
      completedWorkoutsByDateProvider(params.date).future
    );

    if (completedWorkouts.isEmpty) {
      return DayAutoCompleteStatus(
        shouldAutoComplete: false,
        reason: 'No workouts completed'
      );
    }

    // 2. Cerca match con template schedulato
    for (final workout in completedWorkouts) {
      if (workout['templateId'] == params.scheduledTemplateId) {
        // ✅ MATCH TROVATO!
        return DayAutoCompleteStatus(
          shouldAutoComplete: true,
          reason: 'Match con template schedulato',
          workoutId: workout['id'],
          completedTemplateId: workout['templateId']
        );
      }
    }

    // 3. Workout fatto ma non match → suggerisci sostituzione
    return DayAutoCompleteStatus(
      shouldAutoComplete: false,
      reason: 'Workout diverso dal programmato',
      hasAlternativeWorkout: true,
      workoutId: completedWorkouts.first['id']
    );
  }
);
```

---

## 📊 Diagrammi di Flusso

### Diagramma Temporale Completo

```
TEMPO →

DAY 0: Creazione
├─ User crea routine con wizard
├─ FlexibleRoutine salvata (isActive=false)
└─ 90 giorni schedulati con template rotation

DAY 1: Attivazione
├─ User va al Routine Center
├─ Attiva la routine creata
└─ isActive = true, altre routine disattivate

DAY 5: Primo Workout
├─ User apre app
├─ activeFlexibleRoutineProvider mostra routine attiva
├─ routine.getScheduledDay(today) → templateId: "push-a"
├─ User clicca "Start Workout"
├─ Carica template e crea Workout instance
├─ User esegue allenamento (45 min)
├─ User clicca "Complete"
├─ Salva workout su Firebase
└─ Auto-complete: schedule["2025-10-19"].status = completed ✅

DAY 6: Secondo Workout
├─ Schedule mostra: Day 5 ✅ completed
├─ Today (Day 6): templateId: "pull-a"
├─ ... stesso flusso

DAY 10: Skip Day
├─ User non può allenarsi
├─ Clicca "Skip Day"
├─ schedule["2025-10-24"].status = skipped ❌
└─ skipTracker aggiornato

DAY 11: Recovery
├─ User vuole recuperare il giorno saltato
├─ Clicca "Recover Day"
├─ Seleziona original date + recovery date
└─ schedule["2025-10-25"] = recovery day ↻

DAY 90: Completamento
├─ routine.endDate raggiunta
├─ Auto-mark: isCompleted = true
└─ Archivio automatico o suggerimento nuova routine
```

---

## 🎯 Key Points

### ✅ Vantaggi del Sistema

1. **Separazione Template/Workout**
   - Template = riutilizzabili, immutabili
   - Workout = istanze reali con dati specifici
   - Link via `templateId`

2. **Routine Flessibili**
   - Multi-periodo (settimanale, mensile, custom)
   - Pattern ripetibili o custom
   - Rotazione automatica template
   - Skip & recovery tracking

3. **Auto-Complete Intelligente**
   - Match automatico template → workout
   - Suggerimento sostituzione se mismatch
   - Aggiornamento stats in tempo reale

4. **Multiple Routine**
   - Crea infinite routine
   - Solo 1 attiva alla volta (enforcement automatico)
   - Gestione da Routine Center

5. **Real-Time Sync**
   - StreamProviders per aggiornamenti live
   - Cambio routine → UI aggiorna automaticamente
   - Statistiche sempre aggiornate

### ⚠️ Limitazioni Attuali

1. **Nessuna "sostituzione template" in-app**
   - Se fai workout diverso, serve conferma manuale

2. **Pattern fissi dopo creazione**
   - Non puoi modificare il pattern di una routine esistente
   - Devi creare nuova routine

3. **Single active routine**
   - Solo 1 routine può essere attiva
   - Feature by design (evita confusione)

---

## 📚 File di Riferimento

### Domain Layer
- `lib/features/routine/domain/entities/flexible_routine.dart` - Entity principale
- `lib/features/workout/domain/entities/workout.dart` - Workout instance
- `lib/features/workout/domain/entities/workout_template.dart` - Template

### Data Layer
- `lib/features/routine/data/repositories/firebase_flexible_routine_repository.dart`
- Collection: `flexibleRoutines`
- Collection: `workouts`

### Presentation Layer
- `lib/features/routine/presentation/providers/flexible_routine_provider.dart` - Providers
- `lib/features/routine/presentation/providers/flexible_routine_notifier.dart` - CRUD
- `lib/features/routine/presentation/screens/routine_editor_screen.dart` - Wizard

### Auto-Complete
- Provider: `dayAutoCompleteStatusProvider` (line 186)
- Provider: `completedWorkoutsByDateProvider` (line 155)
- Logic: Match `workout.templateId` con `scheduledDay.templateId`

---

## 🎬 Conclusione

Il sistema di routine è **completamente scollegato** dalle sessioni di workout a livello di storage (collection separate), ma **collegato logicamente** tramite:

1. **templateId**: Link tra template → routine schedule e template → workout instance
2. **workoutId**: Link tra workout completato → giorno routine completato
3. **Auto-complete**: Logica automatica che rileva match e aggiorna lo stato

Questo design permette:
- ✅ Flessibilità massima (routine indipendenti da workout)
- ✅ Tracking preciso (ogni workout linkato al template di origine)
- ✅ Statistiche accurate (completamento giorni basato su workout reali)
- ✅ Multiple routine (storage separato, attivazione singola)

**Il workout è INDIPENDENTE dalla routine** - puoi fare allenamenti liberi senza routine attiva, ma se hai una routine attiva il sistema rileva automaticamente i match e aggiorna lo stato. 🎯
