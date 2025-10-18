# 🔄 REFACTORING MAP - exercise_list_item.dart

**Data**: 2025-10-03
**Backup**: `exercise_list_item.dart.backup`
**Obiettivo**: Refactoring sicuro usando provider dedicati SENZA perdere funzionalità

---

## 📋 STATO ATTUALE

**File**: 5870 righe
**setState()**: 31 chiamate
**Timer**: 3 simultanei
**Metodi privati**: 41

---

## 🎯 FUNZIONALITÀ DA MANTENERE (CHECKLIST COMPLETA)

### ✅ 1. EXPANSION STATE (→ exerciseExpansionProvider)
- [x] `_isExpanded` - Stato collapsed/expanded
- [x] `_hasAutoCollapsed` - Flag autocollapse avvenuto
- [x] `_userManuallyExpanded` - Flag espansione manuale
- [x] Reset flags quando exercise diventa incomplete
- [x] Tap per expand quando collapsed
- [x] Tap per collapse quando completed ed expanded
- [x] Badge verde quando collapsed e completed

**Metodi**:
- `_areAllSetsCompleted()` - Verifica se tutti i set sono completati
- Logica in `didUpdateWidget()` - Reset flags

---

### ✅ 2. AUTO-COLLAPSE (→ exerciseAutoCollapseProvider)
- [x] `_autoCollapseTimer` - Timer delay iniziale (1.5-2.5s)
- [x] `_countdownTimer` - Timer countdown (3-2-1)
- [x] `_collapseCountdown` - Valore countdown
- [x] `_autoCollapseInProgress` - Flag in progress
- [x] Verifica se autocollapse abilitato in config
- [x] Delay differenziato Base/Pro (simplifiedAnimations)
- [x] Countdown differenziato 2/3 secondi
- [x] Haptic feedback medio su ogni tick
- [x] Cancel su user interaction
- [x] Badge animato con countdown

**Metodi**:
- `_autoCollapseIfCompleted()` - Avvia processo
- `_performCollapse()` - Esegue collapse
- `_showCompletionFeedback()` - Mostra badge
- `_cancelAutoCollapse()` - Cancella timer

---

### ✅ 3. NOTES EDITING (→ exerciseNotesProvider)
- [x] `_notesController` - TextEditingController
- [x] `_isEditingNotes` - Modalità editing
- [x] `_savingNotes` - Stato saving
- [x] `_saveDebounceTimer` - Debounce 750ms
- [x] Auto-save su Firebase
- [x] Snackbar successo con icon verde
- [x] Haptic feedback su save
- [x] Salvataggio su toggle off

**Metodi**:
- `_onNotesChanged()` - Listener con debounce
- `_saveNotes()` - Salva su Firebase
- `_toggleNotesEdit()` - Toggle edit mode
- `_showNotesEditor()` - Modal full-screen (da mantenere separato)

---

### ✅ 4. HISTORY & DATA (DA NON TOCCARE)
- [x] `_lastActivity` - Ultima attività
- [x] `_loadingHistory` - Loading state
- [x] `_exerciseData` - Dati esercizio da JSON

**Metodi**:
- `_loadLastActivity()` - Carica storico
- `_loadLastActivityFallback()` - Fallback
- `_loadExerciseData()` - Carica JSON
- `_showExerciseHistory()` - Mostra modal storico

---

### ✅ 5. COMMUNITY SYSTEM (DA NON TOCCARE)
- [x] `_showCommunitySuggestion` - Mostra chip
- [x] `_suggestionText` - Testo suggerimento
- [x] `_suggestionType` - Tipo contributo
- [x] `_contextType` - Contesto
- [x] `_exerciseData` - Dati esercizio

**Metodi**:
- `_checkForCommunitySuggestions()` - Controlla suggerimenti
- `_handleCommunitySuggestionTap()` - Gestisce tap
- `_showContributionModal()` - Modal contributo
- `_openContributionModal()` - Apri modal
- `_submitContribution()` - Invia contributo
- `_showSuccessDialog()` - Mostra successo

---

### ✅ 6. WARMUP SYSTEM (DA NON TOCCARE)
- [x] `_warmupSuggestionDismissed` - Dismissione warmup
- [x] Card suggestion warmup
- [x] Progressione 40%-60%-80%

**Metodi**:
- `_showWarmupModal()` - Modal warmup
- `_addWarmupSets()` - Aggiungi set warmup

---

### ✅ 7. SET MANAGEMENT (DA NON TOCCARE)
**Metodi**:
- `_addNewSet()` - Aggiungi set
- `_deleteSet()` - Elimina set
- `_editSet()` - Modifica set (modal)
- `_quickEditSet()` - Quick edit (overlay V2)
- `_toggleSetCompletion()` - Toggle completamento
- `_toggleSetCompletionWithFeedback()` - Con feedback

---

### ✅ 8. APRE SYSTEM (DA NON TOCCARE)
**Metodi**:
- `_handleAPRESuggestion()` - Gestisce suggerimento APRE
- `_handleRPESuggestion()` - Gestisce suggerimento RPE
- `_showAutoAdjustmentModal()` - Modal APRE settings

---

### ✅ 9. TIMER INTEGRATION (DA NON TOCCARE)
**Metodi**:
- `_startRestTimer()` - Avvia rest timer
- `_startRestTimerWithSetInfo()` - Con info set
- `_showQuickTimerSettings()` - Settings timer
- `_showRestTimerSettings()` - Settings rest

---

### ✅ 10. MODALS & DIALOGS (DA NON TOCCARE)
**Metodi**:
- `_showExerciseOptions()` - Menu contestuale
- `_showExerciseEditor()` - Editor esercizio
- `_showExerciseInfoModal()` - Info esercizio
- `_showInjuryPreventionModal()` - Prevenzione infortuni
- `_showTutExplanationModal()` - Spiegazione TUT
- `_showCommunityAdvice()` - Consigli community
- `_showDeleteConfirmation()` - Conferma eliminazione

---

### ✅ 11. OTHER ACTIONS (DA NON TOCCARE)
- [x] `_exerciseStarted` - Exercise iniziato
- [x] `_cachedCompletionStatus` - Cache completion

**Metodi**:
- `_duplicateExercise()` - Duplica esercizio
- `_editExercise()` - Modifica esercizio
- `_populateCurrentValue()` - Popola valori correnti

---

## 🔧 STRATEGIA REFACTORING

### FASE 1: EXPANSION STATE
1. Importare `exercise_expansion_provider.dart`
2. Sostituire:
   - `_isExpanded` → `ref.watch(exerciseExpansionProvider(widget.exercise.id))`
   - `_hasAutoCollapsed` → `.hasAutoCollapsed`
   - `_userManuallyExpanded` → `.userManuallyExpanded`
3. Rimuovere setState per questi campi
4. Mantenere TUTTA la logica in `didUpdateWidget()`

### FASE 2: NOTES EDITING
1. Importare `exercise_notes_provider.dart`
2. Sostituire:
   - `_notesController` → provider managed
   - `_saveDebounceTimer` → gestito dal provider
   - `_savingNotes` → `.isSaving`
3. Mantenere snackbar e haptic feedback
4. Callback `onSave` collegato a `widget.onExerciseUpdate`

### FASE 3: AUTO-COLLAPSE
1. Importare `exercise_autocollapse_provider.dart`
2. Sostituire:
   - `_autoCollapseTimer` → gestito dal provider
   - `_countdownTimer` → gestito dal provider
   - `_collapseCountdown` → `.countdown`
3. Callback `onComplete` collegato a `_performCollapse()`
4. Mantenere TUTTA la logica di verifica

---

## ⚠️ COSA **NON** TOCCARE

1. **UI Components** - Tutti i Widget builder
2. **Business Logic** - APRE, History, Community
3. **Callbacks** - onTap, onDelete, onSetUpdate, etc.
4. **Modals** - Tutti i modal e dialog
5. **Timer Integration** - Rest timer, Live Activities
6. **Set Management** - Add, delete, edit sets
7. **Warmup** - Sistema warmup completo

---

## 🧪 TEST CHECKLIST

Dopo ogni fase verificare:
- [ ] Expansion/collapse funziona
- [ ] Autocollapse funziona con countdown
- [ ] Cancel autocollapse funziona
- [ ] Notes editing + auto-save funziona
- [ ] Snackbar successo appare
- [ ] Reset flags su incomplete funziona
- [ ] Nessun crash o errore
- [ ] Performance non peggiorate
- [ ] Timer correttamente disposed

---

## 🔙 ROLLBACK

Se qualcosa va male:
```bash
cp exercise_list_item.dart.backup exercise_list_item.dart
```

---

## 📊 METRICHE ATTESE

**Prima**:
- setState: 31
- Righe: 5870
- Timer locali: 3
- Complexity: Alta

**Dopo**:
- setState: ~10-12
- Righe: ~5500-5600 (-300 righe)
- Timer locali: 0 (gestiti da provider)
- Complexity: Media
