# 📋 Routine Flow V2 - Requirements & Specifications
**Nuovo sistema intelligente di matching routine workout**

> 📅 Data: Ottobre 2025  
> 🎯 Status: Requirements Definition  
> 👤 Designer: Michele (User)  

---

## 🎯 Obiettivo Generale

Creare un sistema di routine intelligente che:

1. **Auto-completa quando è semplice** (giorno pianificato = workout fatto)
2. **Chiede conferma e scambia quando c'è conflitto** (giorno diverso ma utente vuole farlo comunque)
3. **Ricorda all'utente i giorni saltati** (notifiche reminder)

---

## 📊 I 3 Scenari

### SCENARIO 1: Simple Match ✅ (70% dei casi)

**Situazione**:
- Routine dice: "Oggi lunedì = LEG"
- Utente fa: LEG workout
- Orario: Entro la stessa giornata

**Flow Atteso**:
```
Utente completa LEG
    ↓
Sistema: "Questo è LEG, la routine prevede LEG oggi?"
    ↓
✅ MATCH PERFETTO
    ↓
Auto-completa il giorno → Segna ✓ nella routine
    ↓
Toast: "✅ Routine updated: LEG completato!"
```

**Codice Attuale**:
- ✅ Funziona (quando c'è 1 solo candidato)

**Codice Futuro**:
- ✅ Rimane uguale

---

### SCENARIO 2: Swap & Exchange 🔄 (20% dei casi)

**Situazione**:
- Routine dice: 
  - Lunedì (oggi) = LEG
  - Martedì (domani) = PUSH
- Utente vuole: PUSH OGGI (perché ha altro domani)
- Utente fa: PUSH workout OGGI

**Flow Atteso**:

```
Utente avvia workout PUSH
    ↓
Sistema legge template PUSH
    ↓
Routine attiva = ?
    ├─ Contiene PUSH? Sì
    ├─ Dove? Martedì (domani)
    ├─ Oggi (lunedì) prevede: LEG
    ↓
⚠️ MISMATCH RILEVATO
    ↓
    ┌─ DIALOG MOSTRATO ─────────────────────────────┐
    │                                               │
    │  ⚠️ Scambio di Giorni?                        │
    │                                               │
    │  La tua routine prevede:                      │
    │  🟢 Lunedì (oggi) = LEG                       │
    │  🔵 Martedì = PUSH                            │
    │                                               │
    │  Tu hai selezionato: PUSH                     │
    │                                               │
    │  Opzioni:                                     │
    │  1️⃣ [Continua Normal] ─ Fai PUSH, non        │
    │     aggiornare routine                        │
    │  2️⃣ [Scambia i Giorni] ─ PUSH oggi,          │
    │     LEG domani (Consigliato ✓)                │
    │  3️⃣ [Salta LEG] ─ Salta LEG, fai PUSH       │
    │                                               │
    └───────────────────────────────────────────────┘
    ↓
Utente sceglie: [2️⃣ Scambia i Giorni]
    ↓
Sistema esegue lo SWAP:
    ├─ Lunedì: LEG → PUSH ✓
    ├─ Martedì: PUSH → LEG (non completato)
    ├─ Salva su Firestore
    ├─ Notifica: "✅ Giorni scambiati: PUSH oggi, LEG domani"
    ↓
Utente continua il PUSH workout
    ↓
Workout completato
    ↓
Auto-completa il giorno PUSH (lunedì) ✓
    ↓
Toast: "✅ Routine updated: PUSH completato!"
```

**Cosa Succede nei Database**:

**Prima dello swap**:
```json
{
  "schedule": {
    "2025-10-20": {  // Lunedì
      "date": "2025-10-20",
      "status": "scheduled",
      "templateId": "leg_template_id"
    },
    "2025-10-21": {  // Martedì
      "date": "2025-10-21",
      "status": "scheduled",
      "templateId": "push_template_id"
    }
  }
}
```

**Dopo lo swap (utente ha confermato)**:
```json
{
  "schedule": {
    "2025-10-20": {  // Lunedì
      "date": "2025-10-20",
      "status": "scheduled",
      "templateId": "push_template_id",  // ← CAMBIATO
      "notes": "Swapped with 2025-10-21"  // ← LOG
    },
    "2025-10-21": {  // Martedì
      "date": "2025-10-21",
      "status": "scheduled",
      "templateId": "leg_template_id",    // ← CAMBIATO
      "notes": "Swapped with 2025-10-20"  // ← LOG
    }
  }
}
```

---

### SCENARIO 3: Skip & Reminder ⏰ (10% dei casi)

**Situazione A: Giorno Appena Terminato Senza Workout**:
- Routine dice: "Oggi lunedì = LEG"
- Utente: non fa nulla tutto il giorno
- Orario: 21:00 (sera)

**Flow Atteso**:
```
Giorno = "lunedì" (scheduled LEG)
    ↓
Sono le 21:00 (user può ancora fare LEG ma sera tardi)
    ↓
Sistema: dovrebbe rimanere in "scheduled"
Oppure: mostrare reminder "Devi ancora fare LEG"
    ↓
Se utente non fa nulla e si va a dormir
    ↓
Domani mattina (martedì): 
Notification: "📌 Hai saltato LEG ieri. Puoi recuperare?"
```

**Situazione B: Giorno Completamente Saltato (Next Day)**:
- Routine dice: "Lunedì = LEG"
- È ora martedì mattina e lunedì rimane "scheduled"

**Flow Atteso**:
```
Martedì mattina
    ↓
Controllare routine attiva
    ↓
Se lunedì = "scheduled" e ormai è martedì?
    ├─ Significa: Lunedì non è stato completato
    ├─ Status dovrebbe → "skipped"
    ↓
Inviare notifica (locale):
"📌 Hai saltato LEG ieri (lunedì).
 Puoi recuperare con skip recovery?"
    ↓
Se utente tap notifica:
    ├─ Vai a Routine Center
    ├─ Mostra lunedì come "✗ Skipped"
    ├─ Opzione: [Recupera] → completa LEG in giorno libero
    ↓
Se utente ignora:
    ├─ Rimane marcato come "✗ Skipped"
    ├─ Statistiche: Skip Rate ↑
```

---

## 🏗️ Architettura della Soluzione

### Flusso Generale (Tutti i 3 Scenari)

```
┌─ WORKOUT COMPLETED ─────────────────────────────┐
│ Utente preme "Fine Allenamento"                 │
│ workout.templateId = "push_template"            │
└─────────────────────────────────────────────────┘
          ↓
┌─ ROUTINE AUTO-COMPLETION SERVICE ──────────────┐
│ Chiama: tryAutoCompleteRoutineDay()             │
│   1. Carica routine attiva                      │
│   2. Controlla templateId del workout           │
│   3. Cerca matching days nella routine          │
└─────────────────────────────────────────────────┘
          ↓ Risultato?
    ┌─────┴─────────────┬────────────────┐
    ↓                   ↓                ↓
[No Match]        [Single Match]    [Multiple]
    ↓                   ↓           [Candidates]
    ↓                   ↓                ↓
 SKIP                AUTO-             ↓
 (Log)              COMPLETE          ↓
                    (Simple)      ┌──────────────────────┐
                                  │ SWAP DETECTION LOGIC │
                                  │                      │
                                  │ Controlla:           │
                                  │ - Oggi cosa prevede? │
                                  │ - Domani cosa?       │
                                  │ - Giorni prossimi?   │
                                  │                      │
                                  │ Se match perfetto→   │
                                  │ Auto-complete        │
                                  │                      │
                                  │ Se mismatch→         │
                                  │ Mostra SWAP DIALOG   │
                                  └──────────────────────┘
                                            ↓
                                    ┌───────┴───────┐
                                    ↓               ↓
                            [User Confirms]  [User Declines]
                                    ↓               ↓
                                [SWAP]         [CONTINUE]
                                    ↓               ↓
                            Update Firestore  Ignora routine
```

---

### Componenti da Implementare

#### 1️⃣ **RoutineMatchingService** (NEW)

Responsabilità:
- Analizzare il workout completato
- Cercare matching days nella routine attiva
- Rilevare swap opportunities
- Determinare quale azione intraprendere

**Metodi**:
```dart
class RoutineMatchingService {
  // Analizza mismatch e determina se è uno swap
  Future<RoutineSwapOption?> detectSwapOpportunity({
    required Workout completedWorkout,
    required FlexibleRoutine activeRoutine,
  });
  
  // Dato un template, trova i prossimi N giorni che lo contengono
  List<DateTime> findFutureDaysWithTemplate({
    required String templateId,
    required FlexibleRoutine routine,
    required int lookAheadDays,
  });
  
  // Controlla se c'è un template diverso "pronto" per oggi
  ScheduledDay? getTodayScheduledDay(FlexibleRoutine routine);
}
```

#### 2️⃣ **RoutineSwapFlow** (NEW)

Responsabilità:
- Mostrare il dialog di conferma
- Gestire la logica dello swap
- Aggiornare Firestore

**Metodi**:
```dart
class RoutineSwapFlow {
  // Mostra il dialog e ritorna la scelta dell'utente
  Future<SwapDecision?> showSwapDialog({
    required BuildContext context,
    required ScheduledDay todayScheduledDay,
    required ScheduledDay swapWithDay,
    required Workout workoutCompleted,
  });
  
  // Esegue lo swap su Firestore
  Future<void> performSwap({
    required FlexibleRoutine routine,
    required DateTime day1,
    required DateTime day2,
  });
}

enum SwapDecision {
  continueNormal,      // 1️⃣ Fai il workout, non aggiornare routine
  swapDays,            // 2️⃣ Scambia i giorni (Consigliato)
  skipToday,           // 3️⃣ Salta il giorno di oggi
}
```

#### 3️⃣ **RoutineReminderService** (NEW)

Responsabilità:
- Tracciare giorni saltati
- Inviare notifiche di reminder
- Gestire il skip recovery flow

**Metodi**:
```dart
class RoutineReminderService {
  // Check se ci sono giorni passati non completati
  Future<List<SkippedDay>> getSkippedDays(FlexibleRoutine routine);
  
  // Invia notifica reminder
  Future<void> sendSkippedDayReminder(SkippedDay skippedDay);
  
  // Mark giorno come saltato quando il giorno successivo inizia
  Future<void> markPastDaysAsSkipped(FlexibleRoutine routine);
}
```

#### 4️⃣ **Aggiornare RoutineAutoCompletionService**

Integrare i nuovi servizi:
```dart
Future<RoutineAutoCompletionResult> tryAutoCompleteRoutineDay({...}) {
  // 1. Carica routine attiva
  // 2. Controlla match semplice
  
  if (singleMatch) {
    // Scenario 1: Simple Match
    return autoComplete();
  }
  
  if (multipleMatches) {
    // Scenario 2: Possibile SWAP
    final swapOption = await matchingService.detectSwapOpportunity(...);
    if (swapOption != null) {
      // Mostra UI di swap
      return RoutineAutoCompletionResult.pendingSwapConfirmation(swapOption);
    }
  }
  
  if (noMatch) {
    // Scenario 3: Nessun match - check reminder
    return RoutineAutoCompletionResult.skipped('No match found');
  }
}
```

---

## 🎬 User Journeys Dettagliati

### Journey 1: Simple Match

```
Time: Lunedì 18:00

1️⃣ User: Legge routine → vede "Lunedì = LEG" ✓
2️⃣ User: Esegue LEG workout (25 min)
3️⃣ User: Preme "Fine Allenamento"
4️⃣ System: Salva workout con template_id="leg_template"
5️⃣ System: Chiama RoutineAutoCompletionService
6️⃣ System: Trova 1 match perfetto → lunedì = leg
7️⃣ System: Auto-completa il giorno
8️⃣ System: Mostra toast: "✅ LEG completato nella routine!"
9️⃣ System: Naviga a WorkoutSummary
🔟 User: Vede routine aggiornata: lunedì = "✓"

Duration: Instant (nessuna interazione richiesta)
```

---

### Journey 2: Swap & Exchange

```
Time: Lunedì 10:00

1️⃣ User: Legge routine → vede:
   - Lunedì (oggi) = LEG
   - Martedì = PUSH
2️⃣ User: Decide "Voglio fare PUSH oggi"
3️⃣ User: Apre "Seleziona Esercizio" → cerca "push"
4️⃣ User: Seleziona template "Push Workout"
5️⃣ System: Riconosce template PUSH (non LEG)
6️⃣ System: Chiama RoutineMatchingService.detectSwapOpportunity()
7️⃣ System: Trova:
   - Oggi (lunedì): LEG (scheduled)
   - Domani (martedì): PUSH (scheduled)
   - Mismatch! Possibile swap
8️⃣ System: Mostra DIALOG (vedi screenshot)
9️⃣ User: Legge "Scambia i giorni?" → clicca [2️⃣ Scambia]
🔟 System: Chiama RoutineSwapFlow.performSwap()
   - Lunedì.templateId = PUSH
   - Martedì.templateId = LEG
   - Salva su Firestore
   - Aggiorna local state
1️⃣1️⃣ System: Toast "✅ Giorni scambiati!"
1️⃣2️⃣ User: Continua il PUSH workout
1️⃣3️⃣ User: Preme "Fine Allenamento"
1️⃣4️⃣ System: Auto-completa lunedì con PUSH
1️⃣5️⃣ System: Toast "✅ PUSH completato!"
1️⃣6️⃣ Routine aggiornata:
   - Lunedì: ✓ PUSH
   - Martedì: ⊙ LEG (scheduled per domani)

Duration: 3-5 secondi (dialog interaction)
Notification: Mostrata (user sa cosa è successo)
```

---

### Journey 3: Skip & Reminder

```
Time: Lunedì (giorno intero passa)

1️⃣ 08:00: User apre app
   - Routine = "Lunedì = LEG" (scheduled)
   - User vede: "Oggi dovresti fare LEG"
2️⃣ 14:00: User ancora non ha fatto nulla
   - App mostra reminder leggero? (TBD: badge count?)
3️⃣ 21:00: Fine della giornata
   - User non ha fatto LEG
   - Status rimane "scheduled"

---

Time: Martedì mattina 08:00

4️⃣ System: Avvia background task
   - Controlla routine attiva
   - Trova lunedì = "scheduled" ma ormai è martedì
5️⃣ System: Mark lunedì come "skipped" (auto)
6️⃣ System: Invia LOCAL NOTIFICATION:
   📱 "📌 Hai saltato LEG ieri (lunedì)"
      "Vuoi recuperarlo in un giorno libero?"
      [Vedi Routine] [Recupera] [Ignora]

7️⃣ User: Clicca [Vedi Routine]
8️⃣ System: Naviga a RoutineCenter
9️⃣ User: Vede lunedì marcato con ✗ (skipped)
   - Pulsante "Recupera" visibile
🔟 User: Clicca [Recupera] su un giorno libero (es: mercoledì)
1️⃣1️⃣ System: Aggiorna mercoledì con LEG template
1️⃣2️⃣ System: Notifica "✅ LEG recovery programmato per mercoledì"
1️⃣3️⃣ Mercoledì:
   - ⊙ LEG (recovered)
   - User può fare LEG

---

Statistics Impacted:
- Adherence Rate: 66% (2 di 3 giorni completati)
- Skip Rate: 33%
- Current Streak: Broken (ma lunedì può essere recuperato)

Duration: Automated (nessuna azione richiesta fino al recovery)
Notification: Sent next morning
```

---

## 🔔 Notification Strategy

### Tipo 1: Simple Completion (In-App Toast)
```
✅ Routine updated: LEG completato!
```
- Quando: Subito dopo auto-completion
- Dove: Toast in WorkoutSummary
- Durata: 3 secondi

### Tipo 2: Swap Confirmation (Modal Dialog)
```
⚠️ Scambio di Giorni?
[Continua Normal] [Scambia] [Salta]
```
- Quando: Quando mismatch rilevato
- Dove: Modal dialog fullscreen
- Durata: User-controlled

### Tipo 3: Skip Reminder (Push Notification)
```
📌 Hai saltato LEG ieri
Vuoi recuperare? [Sì] [No]
```
- Quando: Prossima mattina
- Dove: Local notification (se user ha permessi)
- Durata: Persistent until tap

### Tipo 4: Analytics Update (Silent)
```
No notification - background update
```
- Quando: Ogni giorno a mezzanotte
- Dati: Skip rate ↑, streak reset, etc.

---

## 🔄 Data Flow - Firestore Updates

### Scenario: Swap Execute

**Before**:
```json
{
  "flexibleRoutines/{routineId}": {
    "schedule": {
      "2025-10-20": {
        "date": "2025-10-20",
        "status": "scheduled",
        "templateId": "leg_abc123",
        "dayName": "Lunedì"
      },
      "2025-10-21": {
        "date": "2025-10-21",
        "status": "scheduled",
        "templateId": "push_xyz789",
        "dayName": "Martedì"
      }
    }
  }
}
```

**Swap Transaction**:
```dart
batch.update(routineRef, {
  'schedule.2025-10-20.templateId': 'push_xyz789',
  'schedule.2025-10-20.notes': 'Swapped with 2025-10-21',
  'schedule.2025-10-20.updatedAt': DateTime.now(),
  
  'schedule.2025-10-21.templateId': 'leg_abc123',
  'schedule.2025-10-21.notes': 'Swapped with 2025-10-20',
  'schedule.2025-10-21.updatedAt': DateTime.now(),
});
await batch.commit();
```

**After**:
```json
{
  "schedule": {
    "2025-10-20": {
      "templateId": "push_xyz789",    // ← Swapped
      "notes": "Swapped with 2025-10-21",
      "updatedAt": "2025-10-20T10:15:00Z"
    },
    "2025-10-21": {
      "templateId": "leg_abc123",     // ← Swapped
      "notes": "Swapped with 2025-10-20",
      "updatedAt": "2025-10-20T10:15:00Z"
    }
  }
}
```

---

## 📱 UI/UX Specifications

### 1. Swap Confirmation Dialog

```
┌─────────────────────────────────────────────┐
│                                             │
│  ⚠️ Scambio di Giorni Proposto             │
│                                             │
│  La tua routine prevede:                    │
│  🟢 Lunedì = LEG                           │
│  🔵 Martedì = PUSH                         │
│                                             │
│  Tu hai selezionato: PUSH                  │
│                                             │
│  ───────────────────────────────────────── │
│                                             │
│  Cosa vuoi fare?                           │
│                                             │
│  [1️⃣ Continua Normal]                     │
│  Fai PUSH oggi, la routine rimane immutata │
│                                             │
│  [2️⃣ Scambia i Giorni] ✓ Consigliato      │
│  PUSH oggi, LEG domani (più logico)        │
│                                             │
│  [3️⃣ Salta LEG Oggi]                     │
│  Segna LEG come skipped, fai PUSH          │
│                                             │
│  [Cancel]                                  │
│                                             │
└─────────────────────────────────────────────┘
```

**Implementazione**:
- ModalService.showSwapDialog()
- Builder: RoutineSwapConfirmationDialog
- Returns: SwapDecision enum

---

### 2. Skip Reminder Notification

```
iOS Local Notification:

Title:   📌 Allenamento saltato
Body:    Hai saltato LEG ieri (lunedì)
         Vuoi recuperare?
Actions: [Recupera] [Ignora]
Badge:   1
Sound:   Default
```

**Implementazione**:
- flutter_local_notifications package
- Scheduled per domani mattina 08:00
- Tap → NavigazionARoutineCenter + pre-select skip recovery

---

### 3. Routine Center - Skip Recovery UI

```
┌─ LUNEDÌ (Skipped) ────────────────────────┐
│                                            │
│ ✗ LEG Saltato                             │
│ Motivo: (none - auto-skipped overnight)   │
│                                            │
│ [Recupera in altro giorno] [Ignora]      │
│                                            │
│ Se [Recupera]:                             │
│ └─ Mostra list di giorni liberi futuri    │
│    - Mercoledì (riposo)                   │
│    - Sabato (riposo)                      │
│    User seleziona → LEG spostato ↻       │
│                                            │
└────────────────────────────────────────────┘
```

---

## 🧪 Test Cases

### Unit Tests

```dart
test('Simple match auto-completes immediately', () async {
  // Setup: Routine with "Monday = LEG"
  // Action: Complete LEG workout on Monday
  // Assert: Day marked as ✓, no dialog shown
});

test('Swap detection finds mismatch', () async {
  // Setup: Routine with "Mon=LEG, Tue=PUSH"
  // Action: Complete PUSH workout on Monday
  // Assert: detectSwapOpportunity returns swap option
});

test('Skip marking happens next day', () async {
  // Setup: Routine with "Monday = LEG", now Tuesday
  // Setup: Monday was "scheduled" (never completed)
  // Action: Call markPastDaysAsSkipped()
  // Assert: Monday marked as "✗ skipped"
});
```

### Widget Tests

```dart
testWidgets('Swap dialog shows correct info', (tester) async {
  // Render SwapConfirmationDialog
  // Assert: Today's exercise shown
  // Assert: Future exercise shown
  // Assert: All 3 buttons present
  // Assert: "Recommended" badge on option 2
});

testWidgets('Skip recovery UI shows available days', (tester) async {
  // Navigate to RoutineCenter
  // Tap [Recupera] on skipped day
  // Assert: Shows list of future rest days
  // Assert: User can select a day
});
```

### Integration Tests

```dart
testWidgets('Full simple match flow works', (tester) async {
  // 1. Complete workout matching routine
  // 2. Assert: Auto-completes
  // 3. Assert: Toast shown
  // 4. Navigate to RoutineCenter
  // 5. Assert: Day marked as ✓
});

testWidgets('Full swap flow works', (tester) async {
  // 1. Start workout with mismatch
  // 2. Assert: Dialog shown
  // 3. Tap [Scambia i Giorni]
  // 4. Assert: Swap happens on Firebase
  // 5. Complete workout
  // 6. Assert: Correct day marked as ✓
});

testWidgets('Skip reminder flow works', (tester) async {
  // 1. Skip a day (don't do scheduled workout)
  // 2. Wait until next day
  // 3. Assert: Notification sent
  // 4. Tap notification
  // 5. Assert: Recovery UI shown
});
```

---

## 🚀 Roadmap di Implementazione

### Phase 1: Foundation (1-2 giorni)
- [ ] Creare RoutineMatchingService
- [ ] Creare RoutineSwapFlow
- [ ] Aggiornare RoutineAutoCompletionService per supportare swap

### Phase 2: UI & UX (1-2 giorni)
- [ ] Implementare SwapConfirmationDialog
- [ ] Implementare Skip Recovery UI
- [ ] Testare flow completo

### Phase 3: Notifications (1 giorno)
- [ ] Setup flutter_local_notifications
- [ ] Implementare skip reminders
- [ ] Schedule background tasks

### Phase 4: Testing & Refinement (1-2 giorni)
- [ ] Unit tests completi
- [ ] Widget tests
- [ ] Integration tests
- [ ] User acceptance testing

---

## 📊 Success Metrics

| Metrica | Target | Come Misurare |
|---------|--------|---------------|
| Auto-completion rate | >95% | Analytics tracking |
| Swap usage | 10-20% | Event tracking |
| Skip reminder CTR | >30% | Notification analytics |
| User satisfaction | >4.5/5 | In-app rating |
| Routine adherence | 5-10% ↑ | Adherence % comparison |

---

**Next Step**: Approvazione di questo spec prima di iniziare lo sviluppo.

Concordi con il flow? Vuoi modifiche?