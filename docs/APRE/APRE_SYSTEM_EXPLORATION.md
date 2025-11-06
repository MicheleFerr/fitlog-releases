# 🏋️ APRE System - Esplorazione Completa del Codebase

**Data Esplorazione**: 2025-11-06  
**Thoroughness Level**: Very Thorough - ✅ TUTTO IL CODEBASE ESPLORATO

## 📊 RIASSUNTO ESECUTIVO

Il sistema APRE (Autoregulatory Progressive Resistance Exercise) è **completamente implementato** nel codebase con:
- **3 servizi domain** con logica di business
- **3 test suites** per validazione
- **8+ file UI** per l'interazione utente
- **Integrazione con provider state management** (Riverpod)
- **Supporto per 3 protocolli APRE** (3, 6, 10 reps)
- **Caching di calcoli 1RM** (7 giorni di validità)
- **Auto-regolazione del peso** basata su performance

---

## 🎯 ENTRY POINTS - Dove Inizia il Flusso APRE

### 1. **Attivazione APRE a Livello App**
**File**: `/lib/shared/presentation/widgets/workout_customization_modal_v3.dart`
```dart
// Utente abilita APRE globalmente in Settings → Customization Modal
late bool _enableApre;                    // Master toggle
late int _defaultApreProtocol;            // Default: 6 (hypertrophy)
late bool _autoAdjustRestTimeApre;        // Auto-rest based on APRE protocol
```

### 2. **Attivazione APRE per Singolo Esercizio**
**File**: `/lib/features/workout/presentation/widgets/auto_adjustment_modal.dart`
```dart
// Utente abilita APRE per esercizio specifico
AutoAdjustmentType.apre              // Seleziona tra APRE vs RPE
int _apreProtocol = 6                // Protocol: 3 (strength), 6 (hyper), 10 (endurance)
_apreBaseWeightController            // Peso base per APRE
_calculated1RM / 3RM / 6RM / 10RM    // Cached calculations
```

### 3. **Esecuzione APRE durante Workout**
**File**: `/lib/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart`
```dart
// Dopo completamento di un set con APRE attivo:
onAPRESuggestion()                   // Callback per suggerimento peso set 4
exercise.useAPRE                     // Flag per processare APRE logic
```

### 4. **Auto-Adjustment Dopo Set**
**File**: `/lib/features/workout/presentation/widgets/edit_set_modal.dart`
```dart
// Calcola peso suggerito per prossimo set basato su APRE
APREAutoRegulationService.selectProtocolFromTargetReps(targetReps)
APREAutoRegulationService.calculateNextSetWeight(...)
APREAutoRegulationService.getRestTimeForProtocol(...)
```

---

## 📂 STRUTTURA COMPLETA DEI FILE

### 🔵 LAYER DOMAIN - Core Business Logic

#### **1. APREService** (Fondamentale)
**File**: `/lib/features/workout/domain/services/apre_service.dart` (227 righe)

**Responsabilità**:
- Lookup table APRE-3, APRE-6, APRE-10 protocols
- Calcolo adjustments basati su reps completati
- Conversione lbs↔kg

**Struct Principali**:
```dart
class APREAdjustment {
  final double set4Adjustment;          // Peso set 4 (lbs)
  final double nextSessionAdjustment;   // Peso sessione prossima (lbs)
  final String description;             // "Too heavy", "Perfect weight", etc.
  final String repsRange;               // "0-1", "2-3", etc.
}

class APRESetTemplate {
  final int setNumber;                  // 1-4
  final int? percentage;                // % 1RM (50%, 75%, 100%)
  final double? weight;                 // Calculated weight
  final int? targetReps;                // Target reps per set
  final String description;             // "Warm-up", "Max effort", etc.
}
```

**Metodi Critici**:
```dart
// Lookup adjustment table per protocol
static APREAdjustment? getAdjustment(int protocol, int repsCompleted)
  // protocol: 3, 6, 10
  // repsCompleted: actual reps done
  // → APREAdjustment con peso/sessione adjustments

// Calcola nuovo peso per Set 4
static double calculateNextWeight(
  double currentWeight,
  int repsCompleted,
  int protocol,
  {bool isForSet4 = true, bool useKilograms = true}
)

// APRE Set Structure 1-4
static List<APRESetTemplate> getAPRESetStructure(int protocol, double baseWeight)
  // Ritorna: [Warm-up (50%), Preparation (75%), Max (100%), Adjusted (?)]

// Helpers
static bool isAPREKeySet(int setNumber)         // true se set 3 o 4
static String getProtocolDescription(int protocol)
static String getAdjustmentReason(int protocol, int targetReps, int actualReps)
```

**APRE Lookup Tables** (Inline nel file):
```
APRE-3 (Max Strength - 92% 1RM):
  0-1 reps → -10.0 lbs (too heavy)
  2-3 reps → 0.0 lbs (perfect)
  4-5 reps → +5.0 lbs (good)
  6+ reps → +10.0 lbs (too easy)

APRE-6 (Strength-Hypertrophy - 83% 1RM):
  0-2 reps → -10.0 lbs
  3-4 reps → -5.0 lbs
  5-7 reps → 0.0 lbs (perfect)
  8-12 reps → +5.0 lbs
  13+ reps → +10.0 lbs

APRE-10 (Hypertrophy-Endurance - 75% 1RM):
  0-7 reps → -10.0 lbs
  8-12 reps → 0.0 lbs (perfect)
  13-17 reps → +5.0 lbs
  18+ reps → +10.0 lbs
```

---

#### **2. APREAutoRegulationService** (Logica di Auto-Regolazione)
**File**: `/lib/features/workout/domain/services/apre_auto_regulation_service.dart` (259 righe)

**Responsabilità**:
- Selezione protocol basata su target reps
- Calcolo 1RM da storico esercizi
- Configurazione esercizio con APRE
- Cache management (7 giorni)

**Key Features**:
```dart
// Seleziona protocol basato su TARGET reps (non actual reps!)
static int selectProtocolFromTargetReps(int targetReps)
  // 1-5 reps → Protocol 3 (strength, 3min rest)
  // 6-10 reps → Protocol 6 (hypertrophy, 2min rest)
  // 11+ reps → Protocol 10 (endurance, 1min rest)

// Tempo rest per protocol
static int getRestTimeForProtocol(int protocol, {
  int strengthRestTime = 180,      // 3 minuti
  int hypertrophyRestTime = 120,   // 2 minuti
  int enduranceRestTime = 60,      // 1 minuto
})

// Calcola 1RM, 3RM, 6RM, 10RM da storico
static Map<String, dynamic> calculateAPREWeights({
  required List<dynamic> historicalSets,
  required int protocol,
  bool useMetricSystem = true,
})
  // Input: Top 10 sets più pesanti da storico
  // Output: {
  //   'calculated1RM': 100.0,
  //   'calculated3RM': 92.0,
  //   'calculated6RM': 83.0,
  //   'calculated10RM': 75.0,
  //   'baseWeight': 83.0 (per protocol),
  //   'metadata': 'Based on 10 sets (Confidence: High)',
  //   'confidence': 'High',
  //   'dataPoints': 10,
  // }

// Configura esercizio con APRE settings + cached calculations
static Exercise configureAPREForExercise({
  required Exercise exercise,
  required Map<String, dynamic> calculations,
  required int protocol,
  required int restTime,
})

// Determina se calcoli sono stali (>7 giorni)
static bool shouldRecalculate(Exercise exercise)

// Calcola peso prossimo set basato su performance
static double calculateNextSetWeight({
  required int protocol,
  required double currentWeight,
  required int targetReps,
  required int actualReps,
})
  // Considera: target reps, actual reps, protocol aggressiveness
  // Rounding: 2.5kg (kg) o 5lbs (lbs)
```

**Algoritmo Calcolo Next Set Weight**:
```
Differenza = actualReps - targetReps

Protocol 3 (Strength):
  diff ≤ -3: -5.0kg (severely under)
  diff = -2: -2.5kg (moderately under)
  diff = -1: -2.5kg (slightly under)
  diff = 0:  0.0kg (perfect)
  diff = 1:  +2.5kg (slightly over)
  diff = 2:  +5.0kg (moderately over)
  diff ≥ 3:  +7.5kg (significantly over)

Protocol 6 (Hypertrophy):
  diff ≤ -3: -7.5kg (less aggressive than 3)
  diff = -2: -2.5kg
  diff = -1: 0.0kg (no decrease for -1)
  diff = 0:  0.0kg
  diff = 1:  +2.5kg
  diff = 2:  +5.0kg
  diff ≥ 3:  +7.5kg

Protocol 10 (Endurance):
  diff ≤ -3: -7.5kg
  diff = -2: -2.5kg
  diff = -1: 0.0kg
  diff = 0:  0.0kg
  diff = 1:  +2.5kg
  diff = 2:  +2.5kg (less aggressive increase)
  diff ≥ 3:  +5.0kg (less aggressive than others)
```

---

#### **3. APRECalculationService** (Batch Calculations - WIP)
**File**: `/lib/features/workout/domain/services/apre_calculation_service.dart` (102 righe)

**Status**: 🟡 **PARZIALE** - TODO implementazioni rimanenti

**Responsabilità**:
- Pre-calcolo batch di APRE weights per tutti esercizi
- Prevent concurrent calculations
- Merge risultati back nel workout

**Note**: Molti TODO nel file - calcoli effettivi delegati a APREAutoRegulationService

---

### 🟢 LAYER DATA & CONFIG - Storage & Configuration

#### **4. Exercise Entity** (Domain Model)
**File**: `/lib/features/workout/domain/entities/exercise.dart` (225 righe)

**APRE Fields Aggiunti**:
```dart
// Auto-regolazione type selection
final AutoAdjustmentType? autoAdjustmentType;  // enum: apre, rpe

// APRE Configuration
final bool useAPRE;                           // Master flag
final int? apreProtocol;                      // 3, 6, or 10
final double? apreBaseWeight;                 // Base weight for APRE

// APRE Cached Calculations (Performance)
final double? calculated1RM;                  // Cached 1RM
final double? calculated3RM;                  // Cached 3RM (92% 1RM)
final double? calculated6RM;                  // Cached 6RM (83% 1RM)
final double? calculated10RM;                 // Cached 10RM (75% 1RM)
final DateTime? lastCalculationDate;          // When last calculated
final String? calculationMetadata;            // Confidence level, data points
```

**AutoAdjustmentType Enum**:
```dart
enum AutoAdjustmentType {
  apre,     // APRE protocol
  rpe,      // RPE/RIR based
}
```

---

#### **5. AppConfig Entity** (Global APRE Settings)
**File**: `/lib/shared/domain/entities/app_config.dart` (250+ righe)

**APRE Config Fields**:
```dart
@HiveField(37)
final bool? enableApre;                  // Master APRE toggle (app-wide)

@HiveField(38)
final int? defaultApreProtocol;          // Default protocol: 3, 6, or 10

@HiveField(39)
final bool? autoAdjustRestTime;          // Auto-adjust rest based on protocol
```

**Rest Time Config** (APRE-aware):
```dart
final int strengthRestTime = 180;        // 3 min (APRE-3, 1-5 reps)
final int hypertrophyRestTime = 120;     // 2 min (APRE-6, 6-10 reps)
final int enduranceRestTime = 60;        // 1 min (APRE-10, 11+ reps)
```

---

### 🟠 LAYER PRESENTATION - UI & State Management

#### **6. WorkoutCustomizationModalV3** (Settings Panel)
**File**: `/lib/features/workout/presentation/widgets/workout_customization_modal_v3.dart` (500+ righe)

**APRE UI Controls**:
```dart
late bool _enableApre;                        // Toggle APRE ON/OFF
late int _defaultApreProtocol;                // Dropdown: 3, 6, 10
late bool _autoAdjustRestTimeApre;            // Rest timer auto-adjust

// Validated with:
// - autoEnableFeature() cascade: enableApre must be enabled first
// - autoDisableFeature() cascade: if disabled, disables sub-features
```

**Location**: Workout Settings → Customization Modal → "APRE Auto-regulation" section

---

#### **7. AutoAdjustmentModal** (Per-Exercise APRE Config)
**File**: `/lib/features/workout/presentation/widgets/auto_adjustment_modal.dart` (600+ righe)

**Flow**:
1. Utente clicca "Auto Adjustment" su esercizio
2. Modal mostra scelta: APRE vs RPE
3. Se APRE selezionato:
   - Visualizza Calcoli 1RM da storico (se disponibili)
   - Dropdown per scegliere Protocol (3, 6, 10)
   - Input peso base APRE
   - Mostra: calculated 3RM, 6RM, 10RM
   - Helper text per protocol

**UI Segmentato**:
```dart
// Protocol selection
SegmentedButton<int>: [3] [6] [10]

// Base weight input
TextField: "APRE Base Weight (kg)"

// Cached calculations display
Text: "Calculated 1RM: 100.0kg"
Text: "Calculated 3RM: 92.0kg"
Text: "Calculated 6RM: 83.0kg"
Text: "Calculated 10RM: 75.0kg"
Text: "Based on 10 sets (Confidence: High)"
```

**Key Methods**:
```dart
_calculate1RMAndBaseWeight()           // Auto-calcola da storico
_buildAPREConfiguration(l10n)          // Render APRE config section
_buildRPEConfiguration(l10n)           // Render RPE config section
_saveSettings()                        // Save exercise con APRE settings
```

---

#### **8. RpeSelectorBottomSheet** (Set Completion with APRE)
**File**: `/lib/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart` (600+ righe)

**APRE Integration**:
```dart
// Constructor parameters
final Exercise? exercise;                     // For APRE checking
final Function(double suggestedWeight)? onAPRESuggestion;

// Logic
if (exercise?.useAPRE == true) {
  // Calculate suggested weight per Set 4
  final adjustment = APREService.getAdjustment(
    exercise.apreProtocol!,
    actualReps
  );
  final suggestedWeight = APREService.calculateNextWeight(...);
  onAPRESuggestion?.call(suggestedWeight);  // Callback al parent
}
```

---

#### **9. EditSetModal** (Set Edit with APRE Suggestion)
**File**: `/lib/features/workout/presentation/widgets/edit_set_modal.dart` (500+ righe)

**APRE Integration**:
```dart
// APRE suggestion state
double? _suggestedWeight;
bool _showWeightSuggestionBanner = false;

// Calculate suggestion on set completion
if (_isCompleted && widget.exercise?.useAPRE == true) {
  final targetReps = int.parse(_repsController.text);
  final actualReps = int.parse(_actualRepsController.text);
  final protocol = APREAutoRegulationService.selectProtocolFromTargetReps(targetReps);
  final suggestedWeight = APREAutoRegulationService.calculateNextSetWeight(
    protocol: protocol,
    currentWeight: double.parse(_weightController.text),
    targetReps: targetReps,
    actualReps: actualReps,
  );
  setState(() {
    _suggestedWeight = suggestedWeight;
    _showWeightSuggestionBanner = true;
  });
}
```

**Banner Suggestion**:
```
📊 APRE Suggestion
Set next weight to: 97.5 kg
(Based on 10 actual reps vs 8 target)
```

---

#### **10. WorkoutProvider** (Workout State Management)
**File**: `/lib/features/workout/presentation/providers/workout_provider.dart` (1000+ righe)

**APRE Integration Points**:
```dart
// On exercise add with APRE enabled
if (config.enableApre && exercise.useAPRE) {
  // Auto-adjust rest time based on protocol
  final protocol = APREAutoRegulationService.selectProtocolFromTargetReps(targetReps);
  final restTime = APREAutoRegulationService.getRestTimeForProtocol(protocol);
  exercise = exercise.copyWith(restTime: restTime);
}

// During workout, suggest weights via APRE
```

---

#### **11. ExerciseListItem** (Exercise Row in Workout)
**File**: `/lib/features/workout/presentation/widgets/exercise_list_item.dart` (800+ righe)

**APRE Indication**:
- Icona 🔄 (auto-regulate) se exercise.useAPRE == true
- Click → Opens AutoAdjustmentModal

---

### 🔵 LOCALIZATION - Translations

#### **12. Localization Keys** (EN & IT)
**Files**:
- `/lib/shared/presentation/l10n/generated/app_localizations_en.dart`
- `/lib/shared/presentation/l10n/generated/app_localizations_it.dart`
- `/assets/i18n/app_en.arb` (source)
- `/assets/i18n/app_it.arb` (source)

**APRE-Specific Keys**:
```
apreProtocol                          → "APRE Protocol"
apreProtocolSelect                    → "Select APRE Protocol"
apreProtocol3Description              → "Maximum Strength (3RM @ 92%)"
apreProtocol6Description              → "Strength-Hypertrophy (6RM @ 83%)"
apreProtocol10Description             → "Hypertrophy-Endurance (10RM @ 75%)"
apreProtocol3Helper                   → "Use your 3 rep max weight"
apreProtocol6Helper                   → "Use your 6 rep max weight"
apreProtocol10Helper                  → "Use your 10 rep max weight"
apreAutoregulationDescription          → "Automatically adjust weights..."
apreProtocolTitle                     → "APRE Protocol"
```

---

## 🧪 TEST COVERAGE

### **Test Suites** (3 files):

#### **1. APREService Tests**
**File**: `/test/features/workout/domain/services/apre_service_test.dart` (180+ righe)

**Coverage**:
- ✅ APRE-3 Protocol: 0-1, 2-3, 4-5, 6+ reps
- ✅ APRE-6 Protocol: 0-2, 3-4, 5-7, 8-12, 13+ reps
- ✅ APRE-10 Protocol: 0-7, 8-12, 13-17, 18+ reps
- ✅ Weight calculation: kg/lbs conversion, rounding
- ✅ Set structure generation

---

#### **2. APREAutoRegulationService Tests**
**File**: `/test/features/workout/domain/services/apre_auto_regulation_service_test.dart` (600+ righe)

**Coverage**:
- ✅ Protocol selection: 1-5 → 3, 6-10 → 6, 11+ → 10
- ✅ Rest time: strength (180s), hypertrophy (120s), endurance (60s)
- ✅ Weight calculation: relative to target reps
- ✅ Protocol aggressiveness: strength > hypertrophy > endurance
- ✅ Boundary conditions: 5↔6 reps, 10↔11 reps

**Test Scenarios**:
```
selectProtocolFromTargetReps:
  - 1, 3, 5 reps → Protocol 3 ✓
  - 6, 8, 10 reps → Protocol 6 ✓
  - 11, 15, 20 reps → Protocol 10 ✓
  - Boundaries (5/6, 10/11) → Correct transitions ✓

getRestTimeForProtocol:
  - Protocol 3 → 180s (3 min) ✓
  - Protocol 6 → 120s (2 min) ✓
  - Protocol 10 → 60s (1 min) ✓
  - Custom overrides → Respected ✓

calculateNextSetWeight:
  - diff ≤ -3 (target miss) → Weight decrease ✓
  - diff = 0 (target hit) → Weight maintain ✓
  - diff ≥ 3 (target easy) → Weight increase ✓
  - Protocol aggressiveness → Respected ✓
  - Rounding → To nearest 2.5kg ✓
```

---

#### **3. APRECalculationService Tests**
**File**: `/test/features/workout/domain/services/apre_calculation_service_test.dart` (100+ righe)

**Status**: 🟡 **WIP** - Tests skeleton, implementation pending

---

## 🔄 WORKFLOW COMPLETO: APRE in Azione

### **Scenario**: Utente abilita APRE per esercizio "Bench Press" con Protocol 6

```
STEP 1: Abilita APRE globalmente
  User → Settings (Customization Modal V3)
  ↓
  Abilita toggle: "APRE Auto-regulation"
  Seleziona Protocol default: 6
  Abilita: "Auto-adjust rest time"
  ↓
  Config salvato in AppConfig (Hive)

STEP 2: Configura Bench Press per APRE
  User → Add/Edit Exercise → "Auto Adjustment"
  ↓
  AutoAdjustmentModal apre
  ↓
  Sistema calcola da storico:
    - Top 10 lift più pesanti
    - Estimated 1RM: 100kg
    - Calculated 3RM: 92kg
    - Calculated 6RM: 83kg
    - Calculated 10RM: 75kg
  ↓
  User seleziona:
    - Type: APRE
    - Protocol: 6 (Hypertrophy)
    - Base Weight: 83kg (auto-filled)
  ↓
  Exercise salvato con:
    - useAPRE = true
    - apreProtocol = 6
    - apreBaseWeight = 83.0
    - calculated3RM = 92.0
    - calculated6RM = 83.0
    - calculated10RM = 75.0
    - lastCalculationDate = now
    - calculationMetadata = "Based on 10 sets (Confidence: High)"

STEP 3: Durante Workout
  User inizia workout con Bench Press
  ↓
  Set structure mostrato:
    - Set 1: 41.5kg x 10 (Warm-up, 50%)
    - Set 2: 62.25kg x 6 (Preparation, 75%)
    - Set 3: 83kg x 6? (Max effort - do max reps)
    - Set 4: ?.?kg x 6? (Adjusted weight - max effort)
  ↓
  User completa Set 3: 83kg x 9 reps

STEP 4: APRE Calculation Triggered
  RpeSelectorBottomSheet apre
  ↓
  System calcola:
    - target reps = 6
    - actual reps = 9
    - difference = +3 (too easy!)
    - protocol = 6
  ↓
  APREService.getAdjustment(6, 9) →
    APREAdjustment(
      set4Adjustment: 5.0 lbs (≈2.27kg),
      nextSessionAdjustment: 5.0 lbs,
      description: "Good strength - increase moderately",
      repsRange: "8-12"
    )
  ↓
  Suggested weight for Set 4:
    83kg + 2.5kg = 85.5kg (rounded to 2.5)

STEP 5: Visualization & Confirmation
  RpeSelectorBottomSheet mostra:
    "APRE Suggestion: Set Set 4 weight to 85.5kg"
    "You completed 9 reps vs 6 target - great job!"
  ↓
  User confirms Set 4 con 85.5kg x ? reps
  ↓
  EditSetModal calcola:
    - New actual reps (es: 7)
    - APREAutoRegulationService.calculateNextSetWeight(...) →
      Per prossima sessione: 85.5kg

STEP 6: Next Session
  - Exercise preserved con updated cache
  - lastCalculationDate still valid (< 7 giorni)
  - Reuse calculated3RM/6RM/10RM
  - Suggested weight: 85.5kg per Set 3
```

---

## 🎯 PATTERN NAMING & CONVENTIONS

### **Enums**:
- `AutoAdjustmentType.apre` - Master type selector
- `ExerciseType.single` - Required for APRE (no superset)

### **Boolean Flags**:
- `exercise.useAPRE` - Master flag per exercise
- `config.enableApre` - Master flag app-wide
- `config.autoAdjustRestTime` - Auto-adjust rest based on protocol

### **Integers**:
- `apreProtocol: 3, 6, 10` - Three protocols
- `targetReps: 1-20+` - Used for protocol selection
- `actualReps: 0-100` - Used for adjustment lookup

### **Doubles**:
- `apreBaseWeight` - In kg (metric system)
- `calculated1RM, 3RM, 6RM, 10RM` - In kg
- Weight adjustments in lbs internally, converted on display

### **DateTime**:
- `lastCalculationDate` - When calculations were last updated
- Valid for 7 days before recalculation needed

### **Strings**:
- `calculationMetadata: "Based on 10 sets (Confidence: High)"`
- Used for confidence/quality indication

---

## 🔌 INTEGRATION POINTS (Key Method Calls)

### **From UI → Domain**:
```dart
// In auto_adjustment_modal.dart
APREAutoRegulationService.calculateAPREWeights(...)
APREAutoRegulationService.configureAPREForExercise(...)

// In rpe_selector_bottom_sheet.dart
APREService.getAdjustment(protocol, actualReps)
APREService.calculateNextWeight(...)

// In edit_set_modal.dart
APREAutoRegulationService.selectProtocolFromTargetReps(targetReps)
APREAutoRegulationService.calculateNextSetWeight(...)
APREAutoRegulationService.getRestTimeForProtocol(protocol)

// In workout_provider.dart
APREAutoRegulationService.selectProtocolFromTargetReps(targetReps)
APREAutoRegulationService.getRestTimeForProtocol(protocol)
```

### **From Domain ← Data**:
```dart
// Exercise entity carries APRE fields
exercise.useAPRE
exercise.apreProtocol
exercise.apreBaseWeight
exercise.calculated1RM/3RM/6RM/10RM
exercise.lastCalculationDate
exercise.calculationMetadata
```

### **Configuration ← Storage**:
```dart
// AppConfig via Hive storage
config.enableApre
config.defaultApreProtocol
config.autoAdjustRestTime
config.strengthRestTime / hypertrophyRestTime / enduranceRestTime
```

---

## 📊 LOOKUP TABLE REFERENCE

### **APRE-3 Protocol** (Max Strength, 92% 1RM)
| Reps Completed | Set 4 Adjust | Next Session | Description |
|---|---|---|---|
| 0-1 | -10.0 lbs | -10.0 lbs | Too heavy |
| 2-3 | 0.0 lbs | 0.0 lbs | Perfect weight |
| 4-5 | +5.0 lbs | +5.0 lbs | Good strength |
| 6+ | +10.0 lbs | +10.0 lbs | Too easy |

### **APRE-6 Protocol** (Strength-Hypertrophy, 83% 1RM)
| Reps Completed | Set 4 Adjust | Next Session | Description |
|---|---|---|---|
| 0-2 | -10.0 lbs | -10.0 lbs | Too heavy |
| 3-4 | -5.0 lbs | -5.0 lbs | Slightly heavy |
| 5-7 | 0.0 lbs | 0.0 lbs | Perfect weight |
| 8-12 | +5.0 lbs | +5.0 lbs | Good strength |
| 13+ | +10.0 lbs | +10.0 lbs | Too easy |

### **APRE-10 Protocol** (Hypertrophy-Endurance, 75% 1RM)
| Reps Completed | Set 4 Adjust | Next Session | Description |
|---|---|---|---|
| 0-7 | -10.0 lbs | -10.0 lbs | Too heavy |
| 8-12 | 0.0 lbs | 0.0 lbs | Perfect weight |
| 13-17 | +5.0 lbs | +5.0 lbs | Good endurance |
| 18+ | +10.0 lbs | +10.0 lbs | Too easy |

---

## 🚀 KEY ARCHITECTURAL DECISIONS

1. **Three-Tier APRE Services**:
   - `APREService`: Lookup table + basic calculations
   - `APREAutoRegulationService`: Protocol selection + auto-regulation logic
   - `APRECalculationService`: Batch pre-calculations (WIP)

2. **Cached Calculations**:
   - 1RM/3RM/6RM/10RM cached on Exercise entity
   - Valid for 7 days before refresh
   - Prevents expensive recalculations during workout

3. **Protocol Selection is Target-Based**:
   - Not actual reps, but target reps determine protocol
   - Allows user to train with consistent APRE framework
   - E.g., "I want to train 6 reps" → APRE-6 protocol

4. **Separate APRE vs RPE**:
   - `AutoAdjustmentType.apre` vs `.rpe`
   - Per-exercise choice (can mix in same workout)
   - Prevents accidental interference

5. **Rest Time Auto-Adjustment**:
   - Paired with APRE protocol
   - 180s (APRE-3) → 120s (APRE-6) → 60s (APRE-10)
   - Can be overridden manually

6. **Weight Rounding**:
   - 2.5kg increments (metric)
   - 5lbs increments (imperial)
   - Prevents micro-adjustments

---

## 🔮 TODO & FUTURE ENHANCEMENTS

### **In APRECalculationService**:
- [ ] Implement full batch calculation logic
- [ ] Integrate with exerciseHistoryProvider
- [ ] Parallel calculation optimization
- [ ] Error recovery for stale data

### **UI Enhancements**:
- [ ] Visualization of APRE progression chart
- [ ] Confidence level indicator (High/Medium/Low)
- [ ] Historical data age indicator ("Calculated 3 days ago")
- [ ] Manual recalculation button in AutoAdjustmentModal

### **Integration**:
- [ ] APRE-aware workout template suggestions
- [ ] A/B testing: APRE vs Fixed weights
- [ ] Analytics: APRE adherence rate

---

## 📚 REFERENCES

**Dr. Bryan Mann's APRE Research**:
- APRE-3: Maximum Strength (3RM, 92% 1RM)
- APRE-6: Strength-Hypertrophy (6RM, 83% 1RM)
- APRE-10: Hypertrophy-Endurance (10RM, 75% 1RM)

---

## 📋 COMPLETE FILE LISTING

### **Domain Services** (Business Logic)
- ✅ `/lib/features/workout/domain/services/apre_service.dart` (227L)
- ✅ `/lib/features/workout/domain/services/apre_auto_regulation_service.dart` (259L)
- 🟡 `/lib/features/workout/domain/services/apre_calculation_service.dart` (102L, WIP)

### **Domain Entities** (Data Models)
- ✅ `/lib/features/workout/domain/entities/exercise.dart` (225L+, APRE fields)
- ✅ `/lib/shared/domain/entities/app_config.dart` (250L+, APRE config)

### **Presentation Widgets** (UI)
- ✅ `/lib/features/workout/presentation/widgets/workout_customization_modal_v3.dart` (500L+)
- ✅ `/lib/features/workout/presentation/widgets/auto_adjustment_modal.dart` (600L+)
- ✅ `/lib/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart` (600L+)
- ✅ `/lib/features/workout/presentation/widgets/edit_set_modal.dart` (500L+)
- ✅ `/lib/features/workout/presentation/widgets/exercise_list_item.dart` (800L+)

### **State Management** (Riverpod Providers)
- ✅ `/lib/features/workout/presentation/providers/workout_provider.dart` (1000L+)
- ✅ `/lib/shared/presentation/providers/app_config_provider.dart`

### **Localization** (Translations)
- ✅ `/assets/i18n/app_en.arb` (APRE keys EN)
- ✅ `/assets/i18n/app_it.arb` (APRE keys IT)
- ✅ `/lib/shared/presentation/l10n/generated/app_localizations.dart` (Generated)
- ✅ `/lib/shared/presentation/l10n/generated/app_localizations_en.dart` (Generated)
- ✅ `/lib/shared/presentation/l10n/generated/app_localizations_it.dart` (Generated)

### **Tests** (Unit & Integration)
- ✅ `/test/features/workout/domain/services/apre_service_test.dart` (180L+)
- ✅ `/test/features/workout/domain/services/apre_auto_regulation_service_test.dart` (600L+)
- 🟡 `/test/features/workout/domain/services/apre_calculation_service_test.dart` (WIP)

---

## 🎓 LEARNING PATH

**For Understanding APRE System**:

1. **Start Here**: `APREService` - Simple lookup table, foundation
2. **Then**: `APREAutoRegulationService` - Selection logic, rest times
3. **UI Layer**: `auto_adjustment_modal.dart` - Configuration flow
4. **In Action**: `rpe_selector_bottom_sheet.dart` - Set completion logic
5. **State**: `workout_provider.dart` - Integration with workout state
6. **Tests**: `apre_auto_regulation_service_test.dart` - Comprehensive examples

---

**Generated**: 2025-11-06  
**Status**: ✅ FULLY EXPLORED - Sistema APRE completamente mappato e documentato
