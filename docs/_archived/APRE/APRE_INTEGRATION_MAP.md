# 🗺️ APRE System - Integration Map & Architecture Diagram

**Generated**: 2025-11-06

---

## 🏗️ ARCHITECTURE LAYERS

```
┌─────────────────────────────────────────────────────────────────┐
│                    📱 PRESENTATION LAYER (UI)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  WorkoutCustomizationModalV3    AutoAdjustmentModal              │
│  ├─ enableApre (toggle)         ├─ Type selector (APRE vs RPE)   │
│  ├─ defaultApreProtocol         ├─ Protocol picker (3/6/10)      │
│  └─ autoAdjustRestTime          ├─ Base weight input             │
│                                 └─ Cached calculations display   │
│                                                                   │
│  RpeSelectorBottomSheet         EditSetModal                    │
│  ├─ onAPRESuggestion()          ├─ Weight suggestion banner      │
│  └─ Call APRE lookup            └─ calculateNextSetWeight()      │
│                                                                   │
│  ExerciseListItem               WorkoutProvider (Riverpod)       │
│  └─ Show APRE indicator         └─ Orchestrate APRE logic        │
│                                                                   │
└────────────────────────┬───────────────────────────────────────┘
                         │
                  ┌──────▼────────┐
                  │ RIVERPOD      │
                  │ STATE MGMT    │
                  └────────────────┘
                         │
┌────────────────────────▼──────────────────────────────────────────┐
│                  🔧 DOMAIN LAYER (Business Logic)                 │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────┐   ┌──────────────────────────────────┐  │
│  │  APREService         │   │ APREAutoRegulationService        │  │
│  ├──────────────────────┤   ├──────────────────────────────────┤  │
│  │ • getAdjustment()    │   │ • selectProtocolFromTargetReps() │  │
│  │   - 3RM, 6RM, 10RM   │   │   (1-5→3, 6-10→6, 11+→10)      │  │
│  │   - Lookup table     │   │                                  │  │
│  │                      │   │ • getRestTimeForProtocol()       │  │
│  │ • calculateNextWeight()  │   (180s, 120s, 60s)              │  │
│  │   - Set 4 adjustment │   │                                  │  │
│  │   - Next session adj │   │ • calculateAPREWeights()         │  │
│  │                      │   │   - 1RM → 3/6/10RM              │  │
│  │ • getAPRESetStructure() │ │   - From historical data       │  │
│  │   - Sets 1-4 weights │   │                                  │  │
│  │   - (50%,75%,100%,?) │   │ • configureAPREForExercise()     │  │
│  └──────────────────────┘   │   - Update exercise entity      │  │
│                              │                                  │  │
│                              │ • shouldRecalculate() - 7 days  │  │
│                              │                                  │  │
│                              │ • calculateNextSetWeight()       │  │
│                              │   - Relative to protocol        │  │
│                              └──────────────────────────────────┘  │
│                                                                     │
│  APRECalculationService (WIP)                                      │
│  └─ Batch pre-calculations                                         │
│                                                                     │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼──────────────────────────────────────────┐
│                   📦 DATA LAYER (Entities & Storage)              │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Exercise Entity (Domain Model)                                    │
│  ├─ APRE Configuration:                                           │
│  │  ├─ useAPRE: boolean                                          │
│  │  ├─ apreProtocol: 3|6|10                                      │
│  │  └─ apreBaseWeight: double (kg)                               │
│  │                                                                 │
│  ├─ Cached Calculations:                                          │
│  │  ├─ calculated1RM: double                                     │
│  │  ├─ calculated3RM: double (92% 1RM)                          │
│  │  ├─ calculated6RM: double (83% 1RM)                          │
│  │  ├─ calculated10RM: double (75% 1RM)                         │
│  │  ├─ lastCalculationDate: DateTime                            │
│  │  └─ calculationMetadata: String (confidence)                 │
│  │                                                                 │
│  └─ Auto-adjustment Type:                                         │
│     └─ autoAdjustmentType: APRE|RPE                             │
│                                                                     │
│  AppConfig Entity (Hive Storage)                                   │
│  ├─ enableApre: boolean (app-wide master toggle)                 │
│  ├─ defaultApreProtocol: int (3|6|10)                            │
│  ├─ autoAdjustRestTime: boolean                                  │
│  │                                                                 │
│  └─ Rest Time Config:                                             │
│     ├─ strengthRestTime: 180s (APRE-3)                           │
│     ├─ hypertrophyRestTime: 120s (APRE-6)                        │
│     └─ enduranceRestTime: 60s (APRE-10)                          │
│                                                                     │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼──────────────────────────────────────────┐
│                   💾 PERSISTENCE (Hive & Firebase)               │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Hive Storage:           Firebase (Sync):                          │
│  ├─ exercises.hive      ├─ /users/{id}/exercises/{id}            │
│  └─ app_config.hive     ├─ APRE fields sync'd                    │
│                         └─ Calculation metadata preserved         │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘
```

---

## 🔗 DATA FLOW DIAGRAM

### **Flow 1: APRE Setup**
```
User Settings
     │
     ▼
WorkoutCustomizationModalV3
  • enableApre = true
  • defaultApreProtocol = 6
     │
     ▼
AppConfig Provider (Riverpod)
     │
     ▼
Hive Storage (Persisted)
     │
     ▼
Next Workout Session (Accessed)
```

### **Flow 2: Per-Exercise APRE Configuration**
```
User Clicks "Auto Adjustment"
     │
     ▼
AutoAdjustmentModal opens
  • Loads exercise history
  • APREAutoRegulationService.calculateAPREWeights()
     │
     ▼
Displays:
  • Calculated 1RM/3RM/6RM/10RM
  • Confidence level
  • Protocol helpers
     │
     ▼
User selects:
  • Protocol (3, 6, or 10)
  • Base weight
     │
     ▼
Exercise Entity updated:
  • useAPRE = true
  • apreProtocol = selected
  • apreBaseWeight = entered
  • calculated*RM = cached
  • lastCalculationDate = now
     │
     ▼
Hive + Firebase (if sync enabled)
```

### **Flow 3: During Workout - Set Completion**
```
Set 3 Completed (Max Effort)
  • Actual reps: 9
  • Target reps: 6 (from protocol)
     │
     ▼
RpeSelectorBottomSheet
  • User confirms set completion
  • Triggers: onAPRESuggestion()
     │
     ▼
APREService.getAdjustment(6, 9)
  • Lookup table: 8-12 reps → +5.0 lbs
     │
     ▼
APREService.calculateNextWeight(83kg + 2.5kg)
  • Adjusted: 85.5kg
     │
     ▼
UI Suggestion Banner:
  "APRE: Set Set 4 to 85.5kg"
     │
     ▼
User Sets Set 4 weight
     │
     ▼
EditSetModal
  • User confirms actual reps (e.g., 7)
  • APREAutoRegulationService.calculateNextSetWeight()
  • For next session: 85.5kg preserved
```

### **Flow 4: Next Workout Session**
```
Load Workout with APRE Exercise
     │
     ▼
Check: lastCalculationDate < 7 days?
     │
     ├─ YES (Fresh): Reuse cached 3RM/6RM/10RM
     │
     └─ NO (Stale): 
        └─ APREAutoRegulationService.calculateAPREWeights()
           └─ Update calculations
                │
                ▼
Set 3 Suggested Weight: 85.5kg (from previous session)
     │
     ▼
User Trains → Repeat Flow 3
```

---

## 📊 STATE DEPENDENCIES & CASCADING

### **From Settings Modal (WorkoutCustomizationModalV3)**
```
enableApre (Master Toggle)
    │
    ├─ ON  ─► defaultApreProtocol (can be set)
    │        ├─ Can choose: 3, 6, 10
    │        └─ Rest time auto-adjusts
    │
    ├─ ON  ─► autoAdjustRestTime (can be set)
    │        └─ Depends on: enableApre
    │
    └─ OFF ─► Both sub-features disabled

[Validation in toggle_dependency_validation.dart]
```

### **From Exercise Configuration (AutoAdjustmentModal)**
```
AutoAdjustmentType
    │
    ├─ APRE Selected
    │   │
    │   ├─ Show: Protocol picker
    │   ├─ Show: Base weight input
    │   ├─ Show: Calculated 1RM/3RM/6RM/10RM
    │   ├─ Show: Confidence indicator
    │   └─ Enable: Calculate button
    │
    └─ RPE Selected
        │
        ├─ Show: RPE range input
        └─ Show: RIR input
```

---

## 🎯 Key Integration Points

### **1. Exercise History → APRE Calculation**
```
exerciseHistoryProvider
       │
       ▼
Get top 10 historical sets
       │
       ▼
APREAutoRegulationService.calculateAPREWeights()
       │
       ├─ OneRMCalculator.calculateAverage()
       │    (for each set)
       │
       ├─ Sort by estimated 1RM (descending)
       │
       ├─ Average top 10 sets
       │
       └─ Calculate: 3RM (92%), 6RM (83%), 10RM (75%)
              │
              ▼
        Update Exercise Entity
```

### **2. Workout Provider → APRE Logic**
```
CurrentWorkoutNotifier
       │
       ├─ On add exercise with useAPRE=true:
       │   └─ APREAutoRegulationService.selectProtocolFromTargetReps()
       │   └─ APREAutoRegulationService.getRestTimeForProtocol()
       │   └─ Update exercise.restTime
       │
       └─ During workout:
           └─ Pass exercise to RpeSelectorBottomSheet
           └─ Handle onAPRESuggestion callback
```

### **3. Set Completion → Weight Suggestion**
```
RpeSelectorBottomSheet
       │ (User confirms set)
       │
       ├─ Extract: exercise.useAPRE, apreProtocol
       │
       ├─ Call: APREService.getAdjustment()
       │
       ├─ Call: APREService.calculateNextWeight()
       │
       └─ Emit: onAPRESuggestion(suggestedWeight)
              │
              ▼
        EditSetModal
              │
              ├─ Show: Weight suggestion banner
              │
              └─ Apply: Suggested weight to Set 4
```

### **4. AppConfig → Exercise Settings**
```
AppConfig (Hive)
    │
    ├─ enableApre = true/false
    │    └─ Controls if APRE feature is available
    │
    ├─ defaultApreProtocol = 3|6|10
    │    └─ Used when creating new exercises with APRE
    │
    └─ autoAdjustRestTime = true/false
        └─ Auto-adjust rest based on protocol selection
```

---

## 🔄 CIRCULAR DEPENDENCIES (None - Clean Architecture ✓)

```
Presentation (UI) → Domain (Services) → Data (Entities)
                         ↑
                      ONE-WAY
                         │
                    (No backref)

✓ No circular dependencies
✓ Domain doesn't depend on Presentation
✓ Clean separation of concerns
```

---

## 📈 Data Transformation Pipeline

```
INPUT (User Entry)
    │
    ├─ Target reps (e.g., 6)
    │
    ▼
APREAutoRegulationService.selectProtocolFromTargetReps(6)
    │
    ▼
OUTPUT: Protocol 6
    │
    ├─ Used for: Adjustment lookup
    ├─ Used for: Rest time (120s)
    ├─ Used for: Weight calculation aggressiveness
    │
    ▼
COMBINED with:
    ├─ Current weight (e.g., 83kg)
    ├─ Target reps (6)
    ├─ Actual reps completed (e.g., 9)
    │
    ▼
APREAutoRegulationService.calculateNextSetWeight()
    │
    ▼
OUTPUT: Suggested weight (85.5kg)
    │
    └─ Displayed as: "APRE Suggestion: 85.5kg"
    └─ Stored in: Exercise for next session
    └─ Used in: EditSetModal banner
```

---

## 🎛️ Configuration Override Hierarchy

```
1. Exercise-specific APRE settings (HIGHEST PRIORITY)
   └─ exercise.useAPRE
   └─ exercise.apreProtocol
   └─ exercise.apreBaseWeight

2. App-wide default APRE settings
   └─ config.enableApre
   └─ config.defaultApreProtocol
   └─ config.autoAdjustRestTime

3. Hardcoded defaults (LOWEST PRIORITY)
   └─ Default rest times: 180s, 120s, 60s
   └─ Default protocol: 6
   └─ Rounding: 2.5kg
```

---

## 🔐 Thread Safety & Concurrency

```
APRECalculationService
    │
    ├─ Flag: _calculationInProgress
    │   └─ Prevents concurrent calculations
    │   └─ Returns early if already running
    │
    └─ Future.wait(futures)
        └─ Parallel calculation for multiple exercises
        └─ Single thread merge at end
```

---

## 📱 APRE in Different Scenarios

### **Scenario A: Single Exercise with APRE**
```
User adds Exercise (e.g., Bench Press)
    │
    ├─ useAPRE = true
    ├─ apreProtocol = 6
    ├─ apreBaseWeight = 83kg
    │
    ▼
Set Structure:
    Set 1: 41.5kg (50%) x 10 reps
    Set 2: 62.25kg (75%) x 6 reps
    Set 3: 83kg (100%) x 6? (max)
    Set 4: ?kg (adjusted) x 6? (max)
```

### **Scenario B: Mixed Protocol Exercises**
```
Workout:
    ├─ Bench Press: APRE-6 (6 reps)
    ├─ Dumbbell Row: APRE-3 (3 reps)
    └─ Leg Press: No APRE (standard)

Each uses own protocol logic, no conflicts
```

### **Scenario C: APRE Switching**
```
Session 1: Train with APRE-6
    └─ Target 6 reps
    
Session 2: Switch to APRE-10
    ├─ Target changes to 10 reps
    ├─ Calculations refresh (if needed)
    └─ Rest time changes: 120s → 60s
```

---

## 🧪 Testing Integration

```
APREService (Unit)
    │
    ├─ Tests lookup tables
    ├─ Tests weight calculations
    └─ Tests set structures
         │
         ▼
APREAutoRegulationService (Integration)
    │
    ├─ Tests protocol selection
    ├─ Tests rest time calculation
    ├─ Tests weight calculation (relative)
    ├─ Tests cache management (7 days)
    └─ Tests protocol aggressiveness
         │
         ▼
APRECalculationService (Integration - WIP)
    │
    ├─ Tests batch calculations
    ├─ Tests concurrent prevention
    └─ Tests result merging
```

---

## 🔍 Debugging Checklist

**If APRE not working**:
```
□ Check: exercise.useAPRE == true
□ Check: exercise.apreProtocol in (3, 6, 10)
□ Check: exercise.apreBaseWeight > 0
□ Check: config.enableApre == true
□ Check: lastCalculationDate < 7 days (or recalculate)
□ Check: Exercise type == ExerciseType.single (not superset)
□ Check: APREService.getAdjustment() returns non-null
□ Check: calculateNextWeight() rounding (2.5kg?)
□ Check: RpeSelectorBottomSheet receives onAPRESuggestion callback
```

**Debug Logging**:
```dart
debugPrint('[APRE] Protocol: $protocol, Target: $targetReps, Actual: $actualReps');
debugPrint('[APRE] Adjustment: ${adjustment.toStringAsFixed(1)}kg');
debugPrint('[APRE] 1RM: ${estimated1RM.toStringAsFixed(1)}kg');
debugPrint('[APRE] Calculation complete: 3RM=$rounded3RM, 6RM=$rounded6RM, 10RM=$rounded10RM');
```

---

## 📡 Data Sync (Hive + Firebase)

```
Local (Hive)
    │
    ├─ Stores: Exercise with APRE fields
    ├─ Stores: AppConfig with APRE settings
    ├─ Auto-saves on exercise update
    │
    ▼
Firebase (Cloud)
    │
    ├─ /users/{userId}/exercises/{id}
    │   └─ All APRE fields synchronized
    │
    ├─ /users/{userId}/config
    │   └─ APRE settings synchronized
    │
    └─ Conflict resolution: Local overwrites (during sync)
```

---

## 🎓 Module Learning Order

**For new developers**:
1. Read: `APRE_SYSTEM_EXPLORATION.md` (overview)
2. Study: `APREService` (simplest, lookup table)
3. Study: `APREAutoRegulationService` (more complex)
4. Read: Tests for both services
5. Trace: `auto_adjustment_modal.dart` (UI integration)
6. Trace: `rpe_selector_bottom_sheet.dart` (in-workout usage)
7. Understand: `workout_provider.dart` (state orchestration)

---

**Generated**: 2025-11-06  
**Status**: ✅ COMPLETE - Integration map fully documented
