# ⚙️ EXERCISE INSERTION CUSTOMIZATION GUIDE

> **For**: Product Managers, Developers, and Power Users
>
> **Purpose**: Complete reference for all toggles, settings, and customization options in the exercise insertion system

---

## 📋 Table of Contents

1. [Global Customization Settings](#1-global-customization-settings)
2. [APRE (Auto-Programmed Resistance) Settings](#2-apre-auto-programmed-resistance-settings)
3. [Per-Exercise Customization](#3-per-exercise-customization)
4. [UI/UX Customization](#4-uiux-customization)
5. [Advanced Type Settings](#5-advanced-type-settings)
6. [Storage and Persistence](#6-storage-and-persistence)
7. [Configuration Files](#7-configuration-files)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Global Customization Settings

### **1.1 Unit of Measurement**

**Location**: `lib/shared/presentation/providers/app_config_provider.dart`

**Toggle:**
```dart
enum UnitSystem {
  metric,    // Kilograms (kg)
  imperial,  // Pounds (lbs)
}

// In appConfigProvider:
final unitSystem = UnitSystem.metric; // Default
```

**UI Path**: Settings → Units

**Functionality:**
- When user selects "lbs", all weight inputs convert
- Internal storage: Always kg (for consistency)
- Display layer: Converts to user preference
- Sync: Converts between devices

**Example Conversion:**
```
User Input: 220 lbs
├─ Convert to kg: 220 ÷ 2.20462 = 99.79 kg
├─ Store: 99.79 kg
├─ Display to other lbs device: 220 lbs
└─ Display to kg device: 99.79 kg
```

**Configuration:**
```dart
// In app_config_provider.dart
class AppConfig {
  final UnitSystem unitSystem;

  // Helper to convert
  double convertWeight(double weight, {required bool toMetric}) {
    if (toMetric && unitSystem == UnitSystem.imperial) {
      return weight / 2.20462; // lbs to kg
    } else if (!toMetric && unitSystem == UnitSystem.metric) {
      return weight * 2.20462; // kg to lbs
    }
    return weight;
  }
}
```

---

### **1.2 Default Rest Times by Protocol**

**Location**: `lib/features/workout/presentation/providers/app_config_provider.dart`

**Toggle:** Settings → APRE → Rest Times

**Default Values:**
```dart
const restTimeSettings = {
  ApreProtocol.three: 180,    // 3 minutes for strength (3RM)
  ApreProtocol.six: 90,       // 1.5 minutes for hypertrophy (6RM)
  ApreProtocol.ten: 60,       // 1 minute for endurance (10RM)
  defaultRest: 120,           // 2 minutes fallback
};
```

**Rationale:**
| Protocol | Rest | Why |
|----------|------|-----|
| 3RM | 180s | Complete nervous system recovery for strength |
| 6RM | 90s | Partial recovery for hypertrophy balance |
| 10RM | 60s | Maintain metabolic stress for endurance |

**User Can Override:**
```dart
// UI: Show sliders for each protocol
final strength_rest_slider = Slider(
  min: 120,
  max: 300,
  divisions: 18, // 10s increments
  value: restTimeSettings[ApreProtocol.three],
  onChanged: (value) {
    // Save custom rest time
    ref.read(appConfigProvider.notifier).updateRestTime(
      protocol: ApreProtocol.three,
      seconds: value.toInt(),
    );
  },
);
```

---

### **1.3 Exercise Database Source**

**Location**: `lib/features/exercise_database/data/repositories/json_exercise_repository.dart`

**Priority Order:**
```
1. Firebase (if online + premium) → 500+ exercises, real-time sync
2. Hive Cache (local) → Downloaded on first app open
3. JSON Assets (bundled) → 1,989 KB fallback
```

**Configuration File:**
- Path: `assets/data/exercises.json`
- Size: 1,989 KB
- Exercises: 500+
- Updated: Quarterly

**Toggle:** Settings → Data Source

```dart
enum ExerciseDataSource {
  firebase,    // Cloud source (premium only)
  hiveCache,   // Local optimized cache
  jsonAssets,  // Bundled fallback
  hybrid,      // Try Firebase, fallback to Hive, then JSON
}

// Default: hybrid (recommended)
```

---

## 2. APRE (Auto-Programmed Resistance) Settings

### **2.1 Enable/Disable APRE**

**Location**: `lib/features/workout/presentation/providers/app_config_provider.dart`

**Toggle:** ✅ / ❌

**UI Path**: Settings → Strength Training → Auto-APRE

```dart
final enableAPREProvider = StateProvider<bool>((ref) => false);

// When enabled:
// ├─ Auto-calculates weight based on history
// ├─ Suggests rest times by protocol
// └─ Tracks 1RM, 3RM, 6RM, 10RM
```

**Default State**: ❌ OFF (user must enable)

**Why Default OFF:**
- Not all users want auto-regulation
- Requires workout history to be useful
- Some users prefer manual control

---

### **2.2 APRE Protocol Selection**

**Location**: `lib/features/workout/domain/entities/exercise.dart`

**Available Protocols:**
```dart
enum ApreProtocol {
  three,   // 3 Reps Max (3RM) - Strength protocol
  six,     // 6 Reps Max (6RM) - Hypertrophy protocol
  ten,     // 10 Reps Max (10RM) - Endurance protocol
}
```

**Per-Exercise Configuration:**
```dart
class Exercise {
  bool useAPRE;           // Toggle for this exercise
  ApreProtocol apreProtocol; // Which protocol to use
  double? apreBaseWeight; // Optional: user-specified base weight

  // Calculated/cached
  double? calculated1RM;
  double? calculated3RM;
  double? calculated6RM;
  double? calculated10RM;
  DateTime? calculationDate;
}
```

**UI Implementation:**
```dart
// In ExerciseCustomizationScreen:

Row(
  children: [
    Checkbox(
      value: exercise.useAPRE,
      onChanged: (value) {
        // Toggle APRE for this exercise
        updateExercise(exercise.copyWith(useAPRE: value));
      },
    ),
    Text('Use APRE'),
  ],
)

if (exercise.useAPRE)
  DropdownButton(
    value: exercise.apreProtocol,
    items: [
      DropdownMenuItem(
        value: ApreProtocol.three,
        child: Text('🔴 Strength (3RM) - 3 min rest'),
      ),
      DropdownMenuItem(
        value: ApreProtocol.six,
        child: Text('🟡 Hypertrophy (6RM) - 1.5 min rest'),
      ),
      DropdownMenuItem(
        value: ApreProtocol.ten,
        child: Text('🟢 Endurance (10RM) - 1 min rest'),
      ),
    ],
    onChanged: (protocol) {
      updateExercise(
        exercise.copyWith(apreProtocol: protocol),
      );
    },
  )
```

---

### **2.3 APRE Base Weight Configuration**

**Two Modes:**

**Mode 1: Auto (Recommended)**
```
├─ App queries exercise history
├─ Finds maximum weight achieved
├─ Calculates estimated 1RM (using Epley formula)
├─ Suggests weight based on protocol
└─ Result: Consistent with user's abilities
```

**Mode 2: Manual Override**
```
├─ User manually enters 1RM
├─ App uses that as base
├─ Calculates protocol-specific weight
└─ Result: User has control
```

**Implementation:**
```dart
// In ExerciseCustomizationScreen

if (exercise.useAPRE)
  Column(
    children: [
      // ✅ Mode selector
      SegmentedButton(
        segments: [
          ButtonSegment(label: Text('Auto'), value: 'auto'),
          ButtonSegment(label: Text('Manual'), value: 'manual'),
        ],
        selected: {'auto'}, // or {'manual'}
        onSelectionChanged: (selected) {
          // Toggle mode
        },
      ),

      // ✅ Manual input (if selected)
      if (mode == 'manual')
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '1RM (${unitSystem == metric ? 'kg' : 'lbs'})',
            helperText: 'Your one-rep max',
          ),
          onChanged: (value) {
            final rm = double.tryParse(value);
            if (rm != null) {
              updateExercise(
                exercise.copyWith(apreBaseWeight: rm),
              );
            }
          },
        ),
    ],
  )
```

**Calculation Formula (Epley):**
```
1RM = weight × (1 + reps / 30)

Examples:
- Last session: 100kg × 5 reps
- Calculated 1RM = 100 × (1 + 5/30) = 116.67 kg

Protocol percentages:
- 3RM protocol: 1RM × 0.93 = 108.5 kg
- 6RM protocol: 1RM × 0.85 = 99.2 kg
- 10RM protocol: 1RM × 0.75 = 87.5 kg
```

---

### **2.4 APRE Cache Invalidation**

**Location**: `lib/features/workout/presentation/providers/exercise_history_provider.dart`

**Cache Strategy:**
```dart
const APRE_CACHE_VALIDITY_DAYS = 7; // Recalculate every 7 days

// Cache stored as:
class ApreCache {
  final Exercise exercise;
  final double calculatedWeight;
  final DateTime calculatedAt;

  bool get isValid {
    return DateTime.now().difference(calculatedAt).inDays <= APRE_CACHE_VALIDITY_DAYS;
  }
}
```

**User Can Force Recalculation:**
```dart
// Button in settings
ElevatedButton(
  onPressed: () {
    // Clear APRE cache for all exercises
    ref.invalidate(apreCacheProvider);
    // Will recalculate on next usage
  },
  child: Text('Refresh APRE Calculations'),
)
```

---

## 3. Per-Exercise Customization

### **3.1 Set Configuration**

**Modifiable Fields:**
```dart
class ExerciseSet {
  int setNumber;           // 1, 2, 3...
  double weight;           // 95.0 kg
  int reps;                // 10 reps
  int? restSeconds;        // 120 seconds until next set
  bool isWarmupSet;        // Mark as warmup
  String? notes;           // "Felt heavy"
  int? rpe;                // Rate of Perceived Exertion (5-10)
  int? rir;                // Reps In Reserve
}
```

**Default Values:**
```dart
ExerciseSet(
  setNumber: 1,
  weight: 0.0,           // User must enter
  reps: 10,              // Default 10 reps
  restSeconds: 120,      // Default 2 minutes
  isWarmupSet: false,
  notes: null,
  rpe: null,
  rir: null,
)
```

**Toggle Options per Set:**
```
├─ Mark as Warmup (checkbox)
│  └─ If checked: Different color, doesn't count to volume
├─ RPE/RIR Tracking (toggle)
│  └─ If enabled: Show 1-10 slider for feedback
└─ Custom Rest Time (override toggle)
   └─ If enabled: Override default, manually set seconds
```

---

### **3.2 Weight Step Increments**

**Configurable in Settings:**

| Increment | Use Case | Localization |
|-----------|----------|--------------|
| 0.5 kg | Micro-loading (plates not available) | "Micro Step" |
| 1.0 kg | Standard increments | "Standard" |
| 2.5 kg | Common fractional plates | "Fractional" |
| 5.0 kg | Large jumps | "Large Step" |
| 10.0 kg | Heavy lifting | "Extra Large" |

**Default**: 2.5 kg (matches common fractional plates)

**Configuration:**
```dart
// In app_config_provider
enum WeightIncrement {
  point5,  // 0.5 kg
  one,     // 1.0 kg
  point25, // 2.5 kg
  five,    // 5.0 kg
  ten,     // 10.0 kg
}

final weightIncrementProvider = StateProvider<WeightIncrement>(
  (ref) => WeightIncrement.point25,
);

// Usage in weight picker:
final increment = ref.watch(weightIncrementProvider);
final nextWeight = currentWeight + increment.value;
```

---

### **3.3 Reps Quick Presets**

**Available Presets (can be customized):**

**Default:**
```
[5, 8, 10, 12, 15]
```

**Alternative Sets:**
```
Strength:   [1, 3, 5, 8]
Hypertrophy: [6, 8, 10, 12]
Endurance:  [12, 15, 20, 25]
Olympic:    [1, 3, 5, 8, 10]
```

**User Can Customize:**
```dart
// Settings → Reps Presets
TextField(
  controller: TextEditingController(
    text: prefs.repPresets.join(', '),
  ),
  decoration: InputDecoration(
    labelText: 'Reps presets (comma-separated)',
    helperText: 'E.g.: 5, 8, 10, 12, 15',
  ),
  onChanged: (value) {
    final presets = value.split(',').map((s) => int.parse(s.trim())).toList();
    updateRepPresets(presets);
  },
)
```

---

### **3.4 Rest Time Customization**

**Three Modes:**

**Mode 1: Protocol-Based (APRE)**
```
Automatically set based on APRE protocol:
├─ 3RM: 180 seconds
├─ 6RM: 90 seconds
└─ 10RM: 60 seconds
```

**Mode 2: Fixed (Manual)**
```
User sets fixed rest time for all sets:
└─ E.g.: Always 120 seconds
```

**Mode 3: Per-Set (Fine Control)**
```
User can set different rest for each set:
├─ Set 1: 120 seconds
├─ Set 2: 120 seconds
└─ Set 3: 180 seconds (last set harder, more rest)
```

**Implementation Toggle:**
```dart
SegmentedButton(
  segments: [
    ButtonSegment(label: Text('Protocol'), value: 'protocol'),
    ButtonSegment(label: Text('Fixed'), value: 'fixed'),
    ButtonSegment(label: Text('Custom'), value: 'custom'),
  ],
  onSelectionChanged: (selected) {
    ref.read(restTimeMode.notifier).state = selected.first;
  },
)
```

---

## 4. UI/UX Customization

### **4.1 Modal Size and Layout**

**Mobile vs Tablet:**
```dart
// Responsive modal height
final modalHeight = isMobile
  ? 0.95      // 95% of screen on mobile
  : 0.80;     // 80% on tablet

DraggableScrollableSheet(
  initialChildSize: modalHeight,
  minChildSize: 0.5,
  maxChildSize: 1.0,
  expand: false,
  builder: (context, scrollController) {
    return /* modal content */
  },
)
```

---

### **4.2 Search Filter Display**

**Toggle: Show/Hide Filters**

**When Hidden:**
```
┌─────────────────────┐
│ 🔍 Search bar only  │
│ [Search...]         │
└─────────────────────┘
```

**When Shown:**
```
┌──────────────────────────┐
│ 🔍 Search bar            │
│ [Search...]              │
├──────────────────────────┤
│ Filters:                 │
│ ☑️ Chest   ☐ Back       │
│ ☐ Shoulders ☑️ Arms     │
│ ☑️ Legs    ☐ Abs        │
│ ☐ Cardio   ☐ Other      │
├──────────────────────────┤
│ Difficulty:              │
│ ☐ Beginner ☑️ Intermediate |
│ ☑️ Advanced              │
│ [Reset Filters]          │
└──────────────────────────┘
```

**Storage:** `userExerciseFilterPreferences`

---

### **4.3 Result Display Modes**

**Mode 1: Grid (2 columns)**
```
┌──────────┬──────────┐
│ Panca    │ Inclinata│
│ Piana    │          │
│          │          │
│ Petto    │ Petto    │
└──────────┴──────────┘
```

**Mode 2: List (Compact)**
```
1. Panca Piana (Petto)
2. Panca Inclinata (Petto)
3. Dips (Petto, Tricipiti)
4. Pectoral Machine (Petto)
```

**Mode 3: Detailed**
```
┌──────────────────────────────┐
│ Panca Piana                  │
│ Categoria: Petto             │
│ Muscoli: Petto, Spalle       │
│ Difficoltà: Media            │
│ Attrezzo: Bilanciere         │
│ Tempo medio: 45 sec/set      │
└──────────────────────────────┘
```

**Toggle Setting:**
```dart
enum ExerciseListMode {
  grid,       // 2 columns
  compact,    // 1 column, minimal info
  detailed,   // 1 column, all info
}

// In settings
SegmentedButton(
  segments: [
    ButtonSegment(icon: Icon(Icons.grid_3x3), value: 'grid'),
    ButtonSegment(icon: Icon(Icons.list), value: 'list'),
    ButtonSegment(icon: Icon(Icons.description), value: 'detailed'),
  ],
  onSelectionChanged: (selected) {
    updateDisplayMode(selected.first);
  },
)
```

---

## 5. Advanced Type Settings

### **5.1 Superset Configuration**

**Toggles:**
```dart
// Auto-rest between exercises
├─ ☑️ Auto rest between exercises (default)
│  └─ Default: 0 seconds (superset = no rest)
└─ ☐ Manual rest between exercises
   └─ User sets: e.g., 30 seconds

// Rest between rounds
├─ ☑️ Use global rest time (default)
│  └─ Default: 120 seconds
└─ ☐ Custom rest between rounds
   └─ User sets: e.g., 90 seconds

// Display preferences
├─ ☑️ Show exercise grouping (default)
└─ ☐ Show as separate exercises
```

---

### **5.2 Drop Set Configuration**

**Stage Management:**

```
Default: 3 stages
├─ 🔴 Heavy: 100% weight
├─ 🟡 Medium: 80% weight
└─ 🟢 Light: 60% weight

User can add:
└─ ⚪ Extra stages (4th+)
```

**Weight Reduction Modes:**

| Mode | Description | Example |
|------|-------------|---------|
| Percentage | Reduce by % each stage | 100% → 80% → 60% |
| Fixed | Reduce by fixed amount | 100kg → 95kg → 90kg |
| Manual | User sets each stage | 100kg, 85kg, 70kg |

```dart
enum DropSetReductionMode {
  percentage,  // 80%, 60% of previous
  fixed,       // -5kg, -10kg each stage
  manual,      // User enters each
}

// Toggle in UI
SegmentedButton(
  segments: [
    ButtonSegment(label: Text('%'), value: 'percentage'),
    ButtonSegment(label: Text('Δkg'), value: 'fixed'),
    ButtonSegment(label: Text('Manual'), value: 'manual'),
  ],
  onSelectionChanged: (selected) {
    updateReductionMode(selected.first);
  },
)
```

---

### **5.3 Rest-Pause Configuration**

**Toggles:**
```dart
// Mini-set count
├─ Minimum: 2
├─ Default: 3
└─ Maximum: 5

// Rest duration between mini-sets
├─ Default: 15 seconds
├─ Range: 5-60 seconds
└─ Commonly used: [10, 15, 20, 30]

// Weight strategy
├─ ☑️ Weight fixed (all mini-sets same weight) (default)
└─ ☐ Weight varies (optional future feature)
```

---

## 6. Storage and Persistence

### **6.1 Preference Storage Location**

**File**: `lib/shared/presentation/providers/app_config_provider.dart`

**Where Stored:**
```
Database: Hive
Box Name: 'app_config'
Schema:
├─ unitSystem: enum (metric/imperial)
├─ apreEnabled: bool
├─ apreProtocols: Map<int>
├─ restTimeSettings: Map<int, int>
├─ repPresets: List<int>
├─ weightIncrement: enum
├─ exerciseFilterPreferences: Map
├─ exerciseListMode: enum
└─ lastUpdated: DateTime
```

**Sync to Firebase (Premium):**
```
Firestore Path: /users/{userId}/config
Sync Trigger: On app startup + every 30 minutes
Upload: Only if changed
Download: Merge with local (local takes precedence)
Conflict Resolution: Last-write-wins with timestamp
```

---

### **6.2 Preference Export/Import**

**Export Format:**
```json
{
  "exerciseInsertionConfig": {
    "unitSystem": "metric",
    "apreEnabled": true,
    "apreProtocol": "six",
    "restTimes": {
      "strength": 180,
      "hypertrophy": 90,
      "endurance": 60
    },
    "repPresets": [5, 8, 10, 12, 15],
    "weightIncrement": 2.5,
    "displayMode": "detailed",
    "exportDate": "2025-10-16T14:30:00Z",
    "exportVersion": "1.0"
  }
}
```

**Import:**
```dart
// Settings → Import Config
Future<void> importSettings(String json) async {
  final config = jsonDecode(json);
  await ref.read(appConfigProvider.notifier).importConfig(config);
}
```

---

## 7. Configuration Files

### **7.1 Exercise Database Schema**

**File**: `assets/data/exercises.json`

**Sample Entry:**
```json
{
  "id": "bench_press_1",
  "name": "Panca Piana",
  "nameEN": "Bench Press",
  "category": "chest",
  "primaryMuscles": ["chest"],
  "secondaryMuscles": ["shoulders", "triceps"],
  "difficulty": "beginner",
  "equipment": ["barbell"],
  "mechanic": "compound",
  "force": "push",
  "avgSetDuration": 45,
  "avgTUT": 45000,
  "images": ["bench_press.jpg"],
  "description": "Push weight...",
  "descriptionIT": "Spingere il peso...",
  "instructions": ["Setup position", "Lower bar", "Press"],
  "instructionsIT": ["Posizionamento", "Abbassare", "Spingere"],
  "tips": ["Keep chest high", "Full ROM"],
  "tipsIT": ["Mantieni petto alto", "ROM completo"]
}
```

---

## 8. Troubleshooting

### **Issue: APRE Calculation Not Working**

**Diagnosis:**
```
✗ Check 1: Is APRE enabled?
  └─ Settings → Strength Training → APRE

✗ Check 2: Is there exercise history?
  └─ Must have completed this exercise before
  └─ At least 1 completed session needed

✗ Check 3: Is the base weight calculated?
  └─ First time: May take 2-3 seconds
  └─ Check network connection for history fetch

✗ Check 4: Is calculation cached?
  └─ Cache valid for 7 days
  └─ Force recalculation: Settings → Refresh APRE
```

**Solution:**
```dart
// Check cache validity
if (!apreCache.isValid) {
  // Recalculate
  final history = await getExerciseHistory();
  final 1rm = calculate1RM(history);
  updateAPRECalculation(1rm);
}

// Fallback: Use manual base weight
if (calculationFails) {
  showManualBaseWeightInput();
}
```

---

### **Issue: Weight Not Converting Between Units**

**Diagnosis:**
```
✗ Check unitSystem in appConfigProvider
✗ Check if conversion is happening at save time
✗ Verify Firestore has correct unit metadata
✗ Check last sync timestamp
```

**Solution:**
```dart
// Force re-sync
await ref.read(firebaseSyncProvider).syncAll();

// Or convert manually
final convertedWeight = unitSystem == metric
  ? weight / 2.20462
  : weight * 2.20462;
```

---

### **Issue: Rest Times Not Applying**

**Diagnosis:**
```
✗ Check if APRE is enabled (overrides manual)
✗ Check per-set override mode
✗ Verify rest time setting in app_config_provider
✗ Check if timer is starting correctly
```

**Solution:**
```
1. If APRE enabled: Disable and use manual
2. If manual: Check "Fixed" mode selected
3. If per-set: Verify each set has time set
4. Clear cache: Settings → Clear Rest Time Presets
```

---

**Version**: 1.0
**Last Updated**: Ottobre 2025
**Audience**: Product Managers, Developers, Power Users
