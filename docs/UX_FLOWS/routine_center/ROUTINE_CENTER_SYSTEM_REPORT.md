# 📋 ROUTINE CENTER - Report Completo
**Sistema di gestione routine flessibili per allenamenti multi-periodo**

> 📌 **Data**: Ottobre 2025  
> 👥 **Audience**: Developer + Utenti  
> 🎯 **Stato**: Production Ready  

---

## 🔴 SEZIONE DEVELOPER

### 📍 Localizzazione e Componenti

| Componente | File | Lines | Tipo |
|-----------|------|-------|------|
| **Screen principale** | `lib/features/routine/presentation/screens/routine_center_screen.dart` | 1-584 | Widget |
| **Providers dati** | `lib/features/routine/presentation/providers/flexible_routine_provider.dart` | 1-221 | StreamProviders |
| **Notifier CRUD** | `lib/features/routine/presentation/providers/flexible_routine_notifier.dart` | 1-510 | StateNotifier |
| **Data Model** | `lib/features/routine/domain/entities/flexible_routine.dart` | 1-615 | Freezed Entity |
| **Repository** | `lib/features/routine/data/repositories/firebase_flexible_routine_repository.dart` | 1-100+ | Interface + Impl |
| **Auto-completion** | `lib/features/routine/application/services/routine_auto_completion_service.dart` | 1-100+ | Service |

---

### 🏗️ Architettura

```
┌─ PRESENTATION LAYER ────────────────────────────┐
│ RoutineCenterScreen (ConsumerStatefulWidget)   │
│ ├─ Visualizza routine attiva + lista           │
│ ├─ Azioni: Attiva/Archivia/Cancella            │
│ └─ Real-time sync con Riverpod providers       │
├─────────────────────────────────────────────────┤
│ Providers (Riverpod StreamProviders)            │
│ ├─ activeFlexibleRoutineProvider (real-time)    │
│ ├─ userFlexibleRoutinesProvider (lista)         │
│ ├─ archivedFlexibleRoutinesProvider             │
│ └─ routineStatisticsProvider                    │
├─────────────────────────────────────────────────┤
│ FlexibleRoutineNotifier (StateNotifier)         │
│ ├─ createRoutine()                              │
│ ├─ updateRoutine()                              │
│ ├─ activateRoutine() / deactivateCurrentRoutine│
│ ├─ completeDayWorkout() / completeDayManual()  │
│ ├─ skipDay() / recoverDay()                     │
│ └─ archiveRoutine() / unarchiveRoutine()        │
└─────────────────────────────────────────────────┘
         ↓ Usa
┌─ DOMAIN LAYER ──────────────────────────────────┐
│ FlexibleRoutine (Freezed Entity)               │
│ ├─ Metadata: id, userId, name, description    │
│ ├─ Periodo: type, startDate, endDate          │
│ ├─ Pattern: RoutinePattern + schedule         │
│ ├─ State: isActive, isArchived, isCompleted   │
│ ├─ Skip Tracking: skipTracker, recovery       │
│ └─ Statistics: completedDays, lastWorkoutDate │
├─────────────────────────────────────────────────┤
│ ScheduledDay (Freezed)                         │
│ ├─ date: Data del giorno                       │
│ ├─ status: DayStatus (scheduled/completed...)  │
│ ├─ templateId: Workout template da fare       │
│ └─ workoutId: Workout completato              │
└─────────────────────────────────────────────────┘
         ↓ Implementato da
┌─ DATA LAYER ────────────────────────────────────┐
│ FirebaseFlexibleRoutineRepository               │
│ ├─ READ: getRoutineById, getUserRoutines      │
│ ├─ WRITE: createRoutine, updateRoutine        │
│ ├─ DELETE: deleteRoutine                       │
│ ├─ STATE: activateRoutine, archiveRoutine     │
│ └─ FIRESTORE: Collection 'flexibleRoutines'   │
└─────────────────────────────────────────────────┘
```

---

### 📊 Data Model Principale

#### **FlexibleRoutine** (Freezed Entity)

```dart
@freezed
class FlexibleRoutine with _$FlexibleRoutine {
  const factory FlexibleRoutine({
    // === IDENTIFICAZIONE ===
    required String id,                    // Unique ID
    required String userId,                // Owner
    
    // === INFORMAZIONI ===
    @Default('My Routine') String name,
    @Default('') String description,
    
    // === PERIODO ===
    required RoutineType type,             // weekly | monthly | bimonthly | semester | custom
    required DateTime startDate,           // Inizio routine
    required DateTime endDate,             // Fine routine
    
    // === PATTERN ===
    required RoutinePattern pattern,       // Generazione giorni workout
    required Map<String, ScheduledDay> schedule,
    
    // === SKIP & RECOVERY ===
    required SkipTracker skipTracker,      // Giorni saltati
    required RecoverySettings recoverySettings,
    
    // === STATO ===
    @Default(true) bool isActive,          // È la routine attiva?
    @Default(false) bool isArchived,       // Archiviata?
    @Default(false) bool isCompleted,      // Terminata?
    
    // === METADATA ===
    required DateTime createdAt,
    DateTime? updatedAt,
    
    // === STATISTICHE ===
    @Default(0) int totalWorkoutDays,      // Giorni workout previsti
    @Default(0) int completedDays,         // Giorni workout completati
    DateTime? lastWorkoutDate,             // Ultimo workout fatto
    
    // === SINCRONIZZAZIONE ===
    @Default(false) bool isSyncPending,    // Sync in corso?
  }) = _FlexibleRoutine;
}
```

#### **ScheduledDay** (Status di ogni giorno)

```dart
@freezed
class ScheduledDay with _$ScheduledDay {
  const factory ScheduledDay({
    required DateTime date,                // Quale giorno
    required DayStatus status,             // ⊙ ✓ ✗ ↻ - (vedi enum)
    String? templateId,                    // Workout template da fare
    String? workoutId,                     // Workout completato (se ✓)
    String? skipReason,                    // Motivo skip (se ✗)
    DateTime? originalDate,                // Data originale se recuperato (↻)
    String? notes,                         // Note aggiuntive
  }) = _ScheduledDay;
}

enum DayStatus {
  scheduled,   // ⊙ = Workout pianificato non ancora fatto
  completed,   // ✓ = Workout completato
  skipped,     // ✗ = Workout saltato
  recovered,   // ↻ = Skip recuperato in altro giorno
  rest,        // - = Giorno riposo (no workout)
}
```

#### **RoutineType** (Tipi di Periodo)

```dart
enum RoutineType {
  weekly,      // 7 giorni
  monthly,     // 30 giorni
  bimonthly,   // 60 giorni
  semester,    // 180 giorni (6 mesi)
  custom,      // Personalizzato
}
```

---

### 🔄 Flusso Dati (Data Flow)

```
┌─ COLD START ───────────────────────────────────────┐
│ RoutineCenterScreen                                │
│   ↓                                                │
│   ref.watch(userFlexibleRoutinesProvider)          │
│   └─→ FlexibleRoutineRepository                    │
│       └─→ Firestore: GET /flexibleRoutines         │
│           └─→ return: List<FlexibleRoutine>        │
│                                                    │
│   ref.watch(activeFlexibleRoutineProvider)         │
│   └─→ FlexibleRoutineRepository                    │
│       └─→ Firestore: GET /flexibleRoutines         │
│           where isActive = true                    │
│           └─→ return: FlexibleRoutine? (stream)    │
└────────────────────────────────────────────────────┘

┌─ REAL-TIME UPDATES ────────────────────────────────┐
│ Firestore Listeners (StreamProvider)               │
│   ↓                                                │
│   watchUserRoutines(userId)                        │
│   └─→ return: Stream<List<FlexibleRoutine>>        │
│       └─→ RoutineCenterScreen rebuilds             │
│           on each Firestore change                 │
└────────────────────────────────────────────────────┘

┌─ USER ACTION: Attiva Routine ──────────────────────┐
│ User tap "Attiva"                                  │
│   ↓                                                │
│ ref.read(flexibleRoutineNotifierProvider.notifier) │
│   ↓                                                │
│ .activateRoutine(routineId)                        │
│   ↓                                                │
│ FlexibleRoutineRepository.activateRoutine()        │
│   ↓                                                │
│ Firestore: UPDATE /flexibleRoutines/{routineId}    │
│   {isActive: true, updatedAt: now}                 │
│   ↓                                                │
│ StreamProvider rebuild (real-time)                 │
│   ↓                                                │
│ UI aggiornata con nuova routine attiva             │
└────────────────────────────────────────────────────┘

┌─ AUTO-COMPLETION FLOW ─────────────────────────────┐
│ Workout completato                                 │
│   ↓                                                │
│ workout_provider                                   │
│   ↓                                                │
│ RoutineAutoCompletionService.tryAutoCompleteRoutineDay()
│   ↓                                                │
│ Trova routine attiva (activeFlexibleRoutineProvider)
│   ↓                                                │
│ Match: templateId = workout template?              │
│   ├─ NO MATCH → skip silenzioso                   │
│   ├─ SINGLE MATCH → auto-complete + toast        │
│   └─ MULTI MATCH → mostra dialog selezione        │
│   ↓                                                │
│ FlexibleRoutineNotifier.completeDayWorkout()      │
│   ↓                                                │
│ Firestore: UPDATE schedule day                     │
│   {status: 'completed', workoutId: ...}           │
│   ↓                                                │
│ Stream rebuild → UI updated                        │
└────────────────────────────────────────────────────┘
```

---

### 🔧 Metodi Principali del Notifier

| Metodo | Signature | Righe | Uso |
|--------|-----------|-------|-----|
| **createRoutine** | `Future<void> createRoutine(FlexibleRoutine)` | 75-118 | Crea nuova routine |
| **updateRoutine** | `Future<void> updateRoutine(FlexibleRoutine)` | 121-139 | Aggiorna routine |
| **deleteRoutine** | `Future<void> deleteRoutine(String id)` | 142-160 | Cancella routine |
| **activateRoutine** | `Future<void> activateRoutine(String id)` | 165-183 | Attiva routine (una sola attiva) |
| **deactivateCurrentRoutine** | `Future<void> deactivateCurrentRoutine()` | 186-204 | Disattiva routine attiva |
| **archiveRoutine** | `Future<void> archiveRoutine(String id)` | 209-227 | Archivia routine (nasconde dalla lista) |
| **unarchiveRoutine** | `Future<void> unarchiveRoutine(String id)` | 230-248 | Sarchiva routine |
| **completeRoutine** | `Future<void> completeRoutine(String id)` | 251-269 | Marca routine come completata |
| **completeDayWorkout** | `Future<void> completeDayWorkout(String, DateTime, String)` | 274-300 | Completa workout per giorno specifico |
| **completeDayManual** | `Future<void> completeDayManual(String, DateTime)` | 303-343 | Completa manualmente giorno (no workout) |
| **skipDay** | `Future<void> skipDay(String, DateTime, String?)` | 346-374 | Salta giorno con motivo |
| **recoverDay** | `Future<void> recoverDay(String, DateTime)` | 377-405 | Recupera giorno saltato |

---

### 📡 Providers Riverpod

#### Stream Providers (Real-time)
```dart
// Routine attiva dell'utente corrente
final activeFlexibleRoutineProvider = StreamProvider<FlexibleRoutine?>((ref) {
  // Streams changes in real-time from Firestore
  // Used by RoutineCenterScreen badge
});

// Tutte le routine dell'utente (active + archived)
final userFlexibleRoutinesProvider = StreamProvider<List<FlexibleRoutine>>((ref) {
  // Streams all user routines
  // Used by RoutineCenterScreen list
});

// Solo routine non archiviate
final activeFlexibleRoutinesProvider = StreamProvider<List<FlexibleRoutine>>((ref) {
  // Filters: !isArchived && !isCompleted
});

// Solo routine archiviate
final archivedFlexibleRoutinesProvider = StreamProvider<List<FlexibleRoutine>>((ref) {
  // Filters: isArchived
});

// Routine specifica per ID
final routineByIdProvider = StreamProvider.family<FlexibleRoutine?, String>((ref, id) {
  // Real-time stream per routine ID specifica
});
```

#### State Notifier Provider (CRUD)
```dart
// Operazioni CRUD sulla routine
final flexibleRoutineNotifierProvider =
    StateNotifierProvider<FlexibleRoutineNotifier, FlexibleRoutineState>((ref) {
  final repository = ref.watch(flexibleRoutineRepositoryProvider);
  final userId = FirebaseAuth.instance.currentUser?.uid;
  return FlexibleRoutineNotifier(repository, userId);
});
```

#### Derived Providers
```dart
// Check if user has active routine
final hasActiveFlexibleRoutinesProvider = Provider<bool>((ref) {
  final active = ref.watch(activeFlexibleRoutineProvider);
  return active.whenData((r) => r != null).value ?? false;
});

// Statistiche routine specifica
final routineStatisticsProvider = Provider.family<RoutineStatistics?, String>((ref, id) {
  // Calculate: completionRate, skipRate, currentStreak, etc.
});

// Workout completati in data specifica
final completedWorkoutsByDateProvider = 
    Provider.family<List<Workout>, DateTime>((ref, date) {
  // Get workouts completati in data
});

// Auto-complete check per giorno
final dayAutoCompleteStatusProvider = 
    Provider.family<bool, (String routineId, DateTime date)>((ref, args) {
  // Check if day already auto-completed
});
```

---

### 🚨 Gestione Errori

| Scenario | Comportamento | Code |
|----------|---------------|------|
| **User not authenticated** | Stream error con messaggio | `StreamProvider` line 15 |
| **Firebase connection lost** | Stream stall, retry automatico | Firestore listener |
| **Routine not found** | Return null (handled in UI) | `getRoutineById` |
| **Invalid update** | Throw exception, caught in UI | `updateRoutine` validation |
| **Sync conflict** | Last-write-wins (Firestore) | Timestamp-based |
| **Offline mode** | Hive caching + pending sync flag | `isSyncPending` field |

---

### 🧪 Test Cases Suggeriti

**Unit Tests**:
- ✅ RoutinePattern generation per ogni tipo
- ✅ ScheduledDay status transitions
- ✅ Skip/Recovery logic
- ✅ Statistics calculation

**Widget Tests**:
- ✅ RoutineCenterScreen visualizzazione
- ✅ Routine card display con stati
- ✅ Actions menu (attiva/archivia/cancella)
- ✅ Loading/error states

**Integration Tests**:
- ✅ Create routine → Firebase sync
- ✅ Activate routine → Real-time update
- ✅ Complete day → Statistics refresh
- ✅ Auto-completion trigger dopo workout

**E2E Tests (Patrol)**:
- ✅ User flow: View → Create → Activate → Complete
- ✅ Skip/Recovery flow
- ✅ Offline sync behavior

---

### 📊 Performance Metrics

| Metrica | Target | Stato |
|---------|--------|-------|
| Screen load | <500ms | ✅ StreamProvider cached |
| List scroll (50 routine) | 60fps | ✅ Riverpod select() used |
| Firestore read | <200ms | ✅ Indexed queries |
| Auto-complete detection | <100ms | ✅ Async service |
| Memory (screen) | <50MB | ✅ StreamProvider cleaning |

---

### 🔐 Sicurezza

**Firestore Security Rules** (Deve avere):
```javascript
match /flexibleRoutines/{routineId} {
  allow read: if request.auth.uid == resource.data.userId;
  allow create: if request.auth.uid == request.resource.data.userId;
  allow update: if request.auth.uid == resource.data.userId;
  allow delete: if request.auth.uid == resource.data.userId;
}
```

**Input Validation**:
- ✅ Nomi routine sanitizzati (InputSanitizer)
- ✅ Date range validation (start < end)
- ✅ RoutineType enum validation
- ✅ userId check before operations

**Considerations**:
- Una sola routine attiva per utente (enforce lato server)
- Archived routine non modifiable (check in notifier)
- Completed routine read-only

---

### 🔄 Integrazione con altre Feature

| Feature | Integrazione | Come |
|---------|-------------|------|
| **Workout** | Auto-completion quando workout finisce | Via `RoutineAutoCompletionService` |
| **Analytics** | Tab "Routine" mostra adherence rate | Via `routineStatisticsProvider` |
| **Templates** | Giorno routine usa workout template | Via `templateId` in `ScheduledDay` |
| **Notifications** | Reminder workout giornaliero | Via scheduled notification job |
| **Dashboard** | Widget streak routine attuale | Via `routineStatisticsProvider` |

---

### 📝 Implementazione Pattern

**Création di Nuova Routine**:
```dart
// 1. Build FlexibleRoutine entity
final routine = FlexibleRoutine(
  id: const Uuid().v4(),
  userId: currentUserId,
  name: 'Push/Pull/Legs',
  type: RoutineType.weekly,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 90)),
  pattern: RoutinePattern.createWeeklyPattern([true, true, true, false, ...]),
  schedule: <String, ScheduledDay>{...},
  skipTracker: const SkipTracker(),
  recoverySettings: const RecoverySettings(),
);

// 2. Call notifier
await ref.read(flexibleRoutineNotifierProvider.notifier)
    .createRoutine(routine);

// 3. StreamProvider rebuilds automatically
// 4. UI reflects new routine in list
```

**Completamento Workout**:
```dart
// 1. Workout completed (in workout_provider)
// 2. Auto-completion service triggered
final result = await routineAutoCompletionService.tryAutoCompleteRoutineDay(
  completedWorkout: workout,
  context: context,
);

// 3. If matches routine day:
await ref.read(flexibleRoutineNotifierProvider.notifier)
    .completeDayWorkout(
      routineId,
      dateToComplete,
      workout.id,
    );

// 4. Firebase updates, stream rebuild, UI refreshes
```

---

## 🟢 SEZIONE UTENTE

### 💪 Che cos'è il Routine Center?

Il **Routine Center** è il cuore del tuo allenamento personalizzato. È il luogo dove:
- Crei programmi di allenamento flessibili (da 7 giorni a 6 mesi)
- Segui i tuoi progressi giorno per giorno
- Gestisci giorni saltati e recuperi
- Vedi statistiche di adherence (quanto segui il programma)

**In poche parole**: È il tuo coach che ti organizza i workout e traccia se li stai seguendo.

---

### 🎯 Come Funziona

#### **1. La Routine Attiva (Badge in Alto)**

Quando entri nel Routine Center, vedi in alto un **badge colorato** con scritto:

```
📋 PUSH/PULL/LEGS (Attivo)
Giorno 23 di 90 | 18 workout completati
```

Questo significa:
- ✅ Hai una routine in corso
- 📊 Sei al giorno 23 dei 90 giorni totali
- 💪 Hai già fatto 18 allenamenti

Se **non hai alcuna routine attiva**, vedrai un messaggio invitandoti a crearne una.

---

#### **2. Creare una Nuova Routine**

Clicca il pulsante **+ Nuova Routine** e scegli:

**📅 Durata**:
- **Settimanale** (7 giorni) - Ideale per provare un nuovo programma
- **Mensile** (30 giorni) - Programma standard
- **Bimestrale** (60 giorni) - Mesociclo completo
- **Semestrale** (180 giorni) - Programma annuale lungo
- **Personalizzato** - Tu decidi la durata

**🏋️ Pattern**:
Seleziona quali giorni fare workout e quali no:
```
Lunedì:    💪 Workout
Martedì:   💪 Workout
Mercoledì: 😴 Riposo
Giovedì:   💪 Workout
Venerdì:   😴 Riposo
Sabato:    💪 Workout
Domenica:  😴 Riposo
```

**📋 Nome & Descrizione**:
- Nome: "Push/Pull/Legs" o "Full Body PPL"
- Descrizione: "Programma di 12 settimane per ipertrofia" (opzionale)

---

#### **3. La Lista delle Routine**

Nel Routine Center vedrai tre sezioni:

**🟢 Routine Attiva** (in cima)
- La routine che stai seguendo ora
- Mostra: nome, giorni completati, percentuale progresso

**🟡 Altre Routine** (al centro)
- Routine passate non archiviate
- Puoi attivarle di nuovo con un tap
- Azioni: Attiva | Archivia | Cancella

**🔵 Routine Archiviate** (in basso)
- Routine vecchie nascoste dalla vista
- Puoi sarchiviarle se vuoi rivederle

---

### 📊 Cosa Succede Durante la Routine

#### **Completare i Workout**

Ogni giorno della tua routine ha uno stato simbolo:

```
⊙ = Workout pianificato (non ancora fatto)
✓ = Workout completato ✅
✗ = Workout saltato ⏭️
↻ = Skip recuperato in altro giorno 🔄
-  = Giorno riposo (no workout) 😴
```

**Flusso automatico**:
1. Apri la routine
2. Vedi quale workout fare oggi (es: "Push")
3. Fai il workout
4. Clicca "Completa" nel timer
5. **Magico**: GymBro automaticamente segna il giorno come ✓ nella routine!

Non devi fare nulla, è tutto automatico. 🎉

---

#### **Saltare un Giorno (Skip)**

A volte saltate un giorno. Succede!

```
Lunedì: ⊙ Workout pianificato → skippa
        ↓
        ✗ Workout saltato (con motivo: "Malato")
        ↓
Giovedì: ↻ Puoi recuperare qui
        (completi il workout del lunedì)
        ↓
        ✓ Skip recuperato!
```

**Come funziona**:
1. Tap su un giorno: "Salta questo workout"
2. Scegli motivo: Malato, Troppo stanco, Urgenza, Altro
3. Il giorno diventa ✗ (saltato)
4. Puoi recuperarlo quando vuoi in un altro giorno di riposo

---

### 📈 Statistiche della Routine

Nel tab **Analytics** vedi:

**📊 Adherence Rate** (%) 
- Es: 85% = hai completato 85 dei workout pianificati
- Il goal è rimanere sopra 80%

**⏭️ Skip Rate** (%)
- Es: 10% = hai saltato il 10% dei workout

**🔥 Current Streak**
- Es: "7 giorni di fila" = hai completato 7 workout consecutivi

**📅 Total Progress**
- Es: "32 di 90 giorni" = sei al giorno 32 della routine di 90

**⏱️ Last Workout**
- Es: "2 giorni fa" = ultimo workout fatto 2 giorni fa

---

### ❓ Domande Comuni

**D: Che succede se finiscono i 90 giorni?**

R: La routine diventa "Completata" (blu). Puoi:
- ✅ Vederla nei record storici
- 🔄 Attivarla di nuovo se vuoi ripeterla
- 📦 Archiviarla per nasconderla
- 🗑️ Cancellarla

---

**D: Posso avere più routine contemporaneamente?**

R: No, una sola routine può essere attiva alla volta. Se attivi una nuova routine, la precedente si disattiva. (Ma rimane nella lista se non l'archivi)

---

**D: Cosa significa "completata manualmente"?**

R: Se fai un workout fuori app (senza usare il timer), puoi marcare manualmente il giorno come completato. Utile per gente che non traccia con l'app.

---

**D: Perché GymBro non segna il workout automaticamente?**

R: Succede quando:
- ❌ Il template del workout non corrisponde esattamente
- ❌ Hai più giorni con lo stesso workout
- ❌ Fai un workout diverso da quello pianificato

In questi casi vedrai una domanda: "Quale giorno della routine completare?" Tu scegli.

---

**D: Posso modificare una routine mentre è attiva?**

R: No. Se vuoi cambiarla:
1. Disattivala
2. Cancella/modifica
3. Attiva di nuovo

Questo protegge i tuoi dati storici.

---

### 🎬 Scenario di Utilizzo Tipico

**Lunedì, 9 Maggio**

1. Apri l'app → Routine Center
2. Vedi: "PPL Routine (Giorno 23/90 | 18 workout fatti)"
3. Rileggi il badge per capire che oggi è "Push"
4. Apri il tab "Allenamento"
5. Esegui i 4 esercizi del Push
6. Premi "Completa Workout" → Attiva timer riposo tra serie
7. Finisci l'ultimo esercizio
8. Premi "Fine Allenamento"
9. **Automatico**: GymBro segna il lunedì come ✓ nella routine! 
10. Torna al Routine Center → Vedi: "PPL Routine (Giorno 24/90 | 19 workout fatti)" ✅

---

### 🚀 Best Practices

**✅ Cose che Funzionano**:
- Creare routine che puoi mantenere (es: 4 giorni/settimana)
- Completare i workout tramite l'app (auto-tracking)
- Monitorare Adherence Rate nel tab Analytics
- Recuperare skip entro una settimana (non procrastinare)
- Archiviar routine vecchie per non confondersi

**❌ Cose da Evitare**:
- Avere una routine con troppi giorni workout (>6/settimana → burnout)
- Ignorare gli skip (accumulan debito)
- Cambiare routine ogni settimana (non c'è progressione)
- Fare workout non pianificati e non segnarli (confonde i dati)

---

### 🎯 Quando Usare le Routine

**Perfetto per**:
- 🏋️ Programmi di 8-16 settimane
- 📊 Gente che vuole tracciare adherence
- 🎯 Obiettivi specifici (ipertrofia, forza, resistenza)
- 📈 Periodizzazione strutturata

**Non è necessario per**:
- 🏃 Allenamenti casuali giorno per giorno
- 💬 Semplice tracciamento (usa solo Workout Log)
- 🎪 Varietà massima senza schema

---

## 📌 Integrazione con Altre Feature

### Come le Routine si Connettono

```
📋 ROUTINE CENTER (Tu sei qui)
    ├─→ 🏋️ TAB ALLENAMENTO
    │   └─ Quando completi un workout
    │      → Segna automaticamente giorno routine
    │
    ├─→ 📊 TAB ANALYTICS
    │   └─ Vedi statistiche routine:
    │      • Adherence %
    │      • Skip Rate
    │      • Current Streak
    │
    └─→ 🎯 DASHBOARD
        └─ Widget mostra routine attiva
           e streak corrente
```

---

## 🆘 Risoluzione Problemi

| Problema | Causa | Soluzione |
|----------|-------|----------|
| Routine non si attiva | Sync in corso | Aspetta 3 secondi, riprova |
| Workout non auto-completa | Template mismatch | Scegli il giorno manualmente dal dialog |
| Statistiche non si aggiornano | Cache stale | Pull-to-refresh |
| Routine sparisce | Archiviata | Scorri fino a "Routine Archiviate" |
| Non posso disattivare routine | Una routine attiva sempre necessaria | Attiva un'altra prima di disattivare |

---

## 📞 Supporto

Hai domande? Contatta support@gymbro.com con:
- 📸 Screenshot
- 🔖 Quale routine (nome)
- 📅 Quando è successo
- 📱 iOS o Android

---

**Ultimo aggiornamento**: Ottobre 2025  
**Versione**: 1.0  
**Creato da**: Team GymBro