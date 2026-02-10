# 🧪 Firebase gRPC Memory Leak - Testing Instructions

**Goal**: Determinare se offline persistence è la root cause del memory leak gRPC su iOS.

**Durata stimata**: 2-3 ore (45 min setup + 2x 60 min profiling)

---

## 📋 Prerequisites

### Hardware/Software
- Mac con Xcode 15+ installato
- iPhone fisico (iOS 17+) connesso via USB
- Xcode Instruments disponibile
- Flutter 3.x+ installato

### File Necessari
- ✅ `lib/main.dart` (baseline - persistence ON)
- ✅ `lib/main_test_no_persistence.dart` (test - persistence OFF)
- ✅ Build iOS debug configurati

---

## 🔬 Phase 1: Baseline Profiling (CON persistence)

**Goal**: Misurare memory leak con offline persistence abilitata (comportamento corrente).

### Step 1.1: Build Baseline

```bash
cd /Users/michele/gymbro_flutter_new

# Build con main.dart standard (persistence ON)
flutter build ios --debug --no-codesign

# Output: build/ios/iphoneos/Runner.app
```

### Step 1.2: Deploy su Device

1. **Apri Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Seleziona Device**:
   - Top bar: Runner > tuo iPhone fisico
   - Assicurati che sia connesso via USB

3. **Run senza debugger**:
   - Product > Run Without Building (⌘⌃R)
   - Oppure: Click "Run" e poi stacca debugger

4. **Verifica app running**:
   - App si apre su iPhone
   - Login funziona
   - No crash immediato

### Step 1.3: Profile con Instruments (Leaks)

1. **Apri Instruments**:
   ```
   Xcode > Open Developer Tool > Instruments
   ```

2. **Seleziona Template**:
   - Template: **Leaks** (cerca "leak" nella search bar)
   - Target: Runner (tuo iPhone)
   - Click **Choose**

3. **Start Recording**:
   - Click Record button (red circle) in alto
   - Instruments si attacca alla app

4. **Scenario Test Standard** (20 minuti):

   **Login & Navigation** (2 min):
   - Login con utente test
   - Navigate: Home → Exercise DB → Settings → Home

   **Start Workout** (5 min):
   - Tap "Start Workout"
   - Select template (es: "Push Day")
   - Start timer
   - Complete 2-3 set (qualsiasi esercizio)

   **Background Cycles** (3x 3 min = 9 min):
   - Metti app in background (Home button / swipe up)
   - Attendi 90 secondi
   - Riapri app (tap icon)
   - Verifica timer ancora attivo
   - **Ripeti 3 volte**

   **Complete Workout** (4 min):
   - Complete altri 3-4 set
   - Tap "Complete Workout"
   - Navigate: History → Analytics
   - Logout

5. **Stop Recording**:
   - Click Stop button (black square) in Instruments
   - **IMPORTANTE**: Instruments inizierà analisi automatica, attendi 1-2 min

6. **Analizza Leak**:

   **Panel Sinistro** - Leak Summary:
   - Guarda colonna "Leaks" (numero totale)
   - Guarda colonna "Size" (byte totali leakati)

   **Panel Centrale** - Timeline:
   - Identifica quando i leak accadono (durante workout? background?)

   **Panel Destro** - Stack Trace:
   - Click su un leak
   - Espandi stack trace
   - Cerca pattern: `grpc`, `CFNetwork`, `absl`, `SocketStream`

7. **Screenshot**:
   - Screenshot 1: Summary view (con totale leak)
   - Screenshot 2: Timeline con picchi visibili
   - Screenshot 3: Stack trace di un leak gRPC

8. **Save Trace**:
   - File > Save (⌘S)
   - Nome: `baseline_persistence_on_YYYYMMDD.trace`
   - Location: `~/Desktop/firebase_leak_profiling/`

9. **Take Notes**:

   Crea file `~/Desktop/firebase_leak_profiling/baseline_notes.txt`:
   ```
   === BASELINE PROFILING (Persistence ON) ===
   Date: YYYY-MM-DD
   Device: iPhone [model]
   iOS Version: [version]
   Duration: 20 min

   Leak Totals:
   - grpc: [X KB]
   - CFNetwork: [Y KB]
   - absl: [Z KB]
   - Total: [TOTAL KB]

   Timeline Notes:
   - Leak started at: [timestamp/event]
   - Biggest spike during: [workout/background/navigation]
   - Rate: ~[X KB/minute]

   Stack Traces:
   - Most common: [grpc::method_name or CFStreamEndpointImpl]
   - Frequency: [every N seconds]
   ```

---

## 🧪 Phase 2: Test Profiling (SENZA persistence)

**Goal**: Misurare memory leak con offline persistence disabilitata (ipotesi fix).

### Step 2.1: Build Test

```bash
cd /Users/michele/gymbro_flutter_new

# Build con main_test_no_persistence.dart (persistence OFF)
flutter build ios --target=lib/main_test_no_persistence.dart --debug --no-codesign

# Output: build/ios/iphoneos/Runner.app (sovrascritto)
```

### Step 2.2: Deploy su Device

1. **Chiudi app corrente** su iPhone:
   - Swipe up > swipe up su Runner
   - Assicurati app completamente chiusa

2. **Apri Xcode** (se chiuso):
   ```bash
   open ios/Runner.xcworkspace
   ```

3. **Run senza debugger**:
   - Product > Run Without Building (⌘⌃R)
   - App si apre con build "test"

4. **Verifica test mode attivo**:
   - Console Xcode dovrebbe mostrare:
     ```
     🧪 [TEST MODE] Firestore: Offline persistence DISABLED
        Goal: Diagnose gRPC memory leak
        See: docs/FIREBASE_GRPC_MEMORY_LEAK_FIX.md
     ```

### Step 2.3: Profile con Instruments (Leaks)

**Ripeti ESATTAMENTE gli stessi step di Phase 1.3**:

1. Instruments > Leaks template
2. Record
3. **Stesso scenario test** (login, workout, 3x background, complete, logout)
4. Stop recording
5. Analizza leak (stessi criteri)
6. Screenshot (3 immagini)
7. Save trace: `test_persistence_off_YYYYMMDD.trace`
8. Take notes: `test_notes.txt`

---

## 📊 Phase 3: Confronto Risultati

### Step 3.1: Confronta Trace Files

1. **Apri entrambi i trace** in Instruments:
   - File > Open: `baseline_persistence_on_YYYYMMDD.trace`
   - File > Open: `test_persistence_off_YYYYMMDD.trace`

2. **Affianca le finestre** (macOS):
   - Window > Tile Window to Left/Right

3. **Confronta Summary**:

   | Metric | Baseline (ON) | Test (OFF) | Differenza |
   |--------|---------------|------------|------------|
   | Total Leaks | [X KB] | [Y KB] | [X-Y KB] |
   | grpc leaks | [A KB] | [B KB] | [A-B KB] |
   | CFNetwork leaks | [C KB] | [D KB] | [C-D KB] |
   | Leak rate (KB/min) | [R1] | [R2] | [R1-R2] |

4. **Confronta Timeline**:
   - Baseline ha spike durante background? Test anche?
   - Baseline leak continui? Test leak ridotti/assenti?

### Step 3.2: Interpreta Risultati

**Scenario A: Test riduce leak >50%**
```
Baseline: 15 KB totale
Test:     5 KB totale
Riduzione: 67%
```
✅ **Conclusione**: Persistence è la root cause principale.

**Action Items**:
- Disabilita persistence in produzione (iOS only)
- Update `main.dart`: `persistenceEnabled: false` se `Platform.isIOS`
- Deploy su TestFlight per verifica estesa

---

**Scenario B: Test NON riduce leak (<20%)**
```
Baseline: 15 KB totale
Test:     13 KB totale
Riduzione: 13%
```
⚠️ **Conclusione**: Bug gRPC intrinseco, non legato a persistence.

**Action Items**:
- Implementa Lazy Listeners (Workaround 2 dal doc)
- Report dettagliato a Firebase team
- Monitora leak growth con Crashlytics

---

**Scenario C: Test AUMENTA leak**
```
Baseline: 15 KB totale
Test:     20 KB totale
Aumento: +33%
```
❌ **Conclusione**: Persistence aiutava, disabilitarla peggiora.

**Action Items**:
- Mantieni persistence abilitata
- Focus su listener management
- Verifica audit StreamSubscription

---

## 📝 Phase 4: Documentazione Finale

### Step 4.1: Report Risultati

Crea file `~/Desktop/firebase_leak_profiling/RESULTS.md`:

```markdown
# Firebase gRPC Memory Leak - Testing Results

**Date**: YYYY-MM-DD
**Tester**: [Your Name]
**Device**: iPhone [model], iOS [version]
**Test Duration**: [X hours]

## Summary

[Scenario A/B/C from above]

## Detailed Metrics

### Baseline (Persistence ON)
- Total Leaks: [X KB]
- grpc: [A KB]
- CFNetwork: [B KB]
- absl: [C KB]
- Rate: [R KB/min]

### Test (Persistence OFF)
- Total Leaks: [Y KB]
- grpc: [D KB]
- CFNetwork: [E KB]
- absl: [F KB]
- Rate: [S KB/min]

## Timeline Analysis

[Descrivi quando i leak accadono: durante workout, background, navigation]

## Conclusion

[Persistence è/non è la root cause]

## Next Steps

[Action items based on Scenario A/B/C]

## Attachments

- baseline_persistence_on_YYYYMMDD.trace
- test_persistence_off_YYYYMMDD.trace
- baseline_notes.txt
- test_notes.txt
- Screenshots (6 immagini totali)
```

### Step 4.2: Share con Team

1. **Comprimi folder**:
   ```bash
   cd ~/Desktop
   zip -r firebase_leak_profiling.zip firebase_leak_profiling/
   ```

2. **Upload**:
   - Google Drive / Dropbox
   - Share link con team

3. **Update `FIREBASE_GRPC_MEMORY_LEAK_FIX.md`**:
   - Aggiungi sezione "Phase 1 Results"
   - Link al report completo
   - Update decisione finale (Scenario A/B/C)

---

## 🛠️ Troubleshooting

### Build Fallisce

**Error**: `No such file or directory: lib/main_test_no_persistence.dart`
```bash
# Verifica file esiste
ls -la lib/main_test_no_persistence.dart

# Se mancante, rigeneralo da main.dart cambiando:
# FirebaseFirestore.instance.settings = const Settings(
#   persistenceEnabled: false,  // ← questa riga
# );
```

### App Crasha Immediatamente

**Cause possibili**:
1. `.env` file mancante
2. Firebase config errato
3. GoogleSignIn init failed

**Debug**:
```bash
# Run con verbose logging
flutter run --target=lib/main_test_no_persistence.dart --verbose
```

### Instruments Non Trova App

**Soluzione**:
1. Chiudi completamente app su iPhone
2. Chiudi Xcode
3. Disconnetti/riconnetti iPhone
4. Riapri Xcode > Run
5. Poi apri Instruments

### Leak Non Visibili

**Possibili motivi**:
- Test troppo breve (< 15 min)
- Scenario troppo leggero (pochi set completati)
- Background cycles insufficienti

**Soluzione**: Estendi test a 30 min con più background cycles.

---

## ✅ Checklist Finale

Prima di concludere Phase 1 testing:

- [ ] Entrambi i build completati senza errori
- [ ] Baseline profiling eseguito (20+ min)
- [ ] Test profiling eseguito (20+ min)
- [ ] Trace files salvati (2 file .trace)
- [ ] Screenshot salvati (6 totali)
- [ ] Notes files creati (2 file .txt)
- [ ] Confronto risultati completato
- [ ] Scenario A/B/C identificato
- [ ] Report RESULTS.md creato
- [ ] Action items definiti
- [ ] `FIREBASE_GRPC_MEMORY_LEAK_FIX.md` aggiornato

---

**Next Steps**: Vedi "Phase 4.2: Share con Team" per condividere risultati.

**Questions?**: Consulta `docs/FIREBASE_GRPC_MEMORY_LEAK_FIX.md` per dettagli tecnici.

**Estimated Time**: 2-3 ore totali (45 min setup + 2x 60 min profiling + 30 min report)
