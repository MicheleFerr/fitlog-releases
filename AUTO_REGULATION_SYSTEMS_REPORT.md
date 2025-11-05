# GymBro Auto-Regulation Systems Report

**Date**: November 5, 2025  
**Scope**: Weight auto-regulation and timer auto-regulation systems  
**Status**: Comprehensive analysis complete

---

## Executive Summary

GymBro implements **two parallel auto-regulation systems** for intelligent workout adaptation:

1. **Weight Auto-Regulation**: APRE (Autoregulatory Progressive Resistance Exercise) protocol with 3 variants, plus RPE/RIR-based alternative
2. **Rest Timer Auto-Regulation**: Automatic rest time suggestions based on performance changes

Both systems are **opt-in per-exercise** and integrate with a configuration modal for user customization.

---

## Part 1: Weight Auto-Regulation System

### Overview

The system provides intelligent weight suggestions based on actual performance vs. target reps using scientifically-backed protocols.

**Two Implementation Approaches:**
- **APRE Protocol** (Primary): 3 variants for different rep ranges (strength/hypertrophy/endurance)
- **RPE/RIR-Based** (Alternative): Percentage-based adjustments using perceived exertion

### 1.1 APRE Protocol Implementation

**File**: `/lib/features/workout/domain/services/apre_auto_regulation_service.dart` (259 lines)

#### Protocol Selection Logic

```dart
static int selectProtocolFromTargetReps(int targetReps) {
    if (targetReps <= 5) {
      return 3;  // Strength protocol: 180s rest
    } else if (targetReps <= 10) {
      return 6;  // Hypertrophy protocol: 120s rest
    } else {
      return 10; // Endurance protocol: 60s rest
    }
  }
```

**Three APRE Variants:**

| Protocol | Rep Range | Focus | Adjustment Aggressiveness | Rest Time |
|----------|-----------|-------|--------------------------|-----------|
| APRE 3 | 1-5 reps | Strength | Very aggressive (±5-7.5kg) | 3 min (180s) |
| APRE 6 | 6-10 reps | Hypertrophy | Moderate (±2.5-5kg) | 2 min (120s) |
| APRE 10 | 11+ reps | Endurance | Conservative (±2.5-5kg) | 1 min (60s) |

#### Weight Adjustment Algorithm

**Function**: `calculateNextSetWeight()`

The algorithm compares **actual reps** against **target reps** to determine weight adjustment:

```dart
static double calculateNextSetWeight({
  required int protocol,
  required double currentWeight,
  required int targetReps,
  required int actualReps,
}) {
  final repsDifference = actualReps - targetReps;
  double adjustment = 0;

  // Adjustment logic based on rep difference and protocol
  if (repsDifference <= -3) {
    adjustment = protocol == 3 ? -5.0 : -7.5; // Severely under
  } else if (repsDifference == -2) {
    adjustment = -2.5; // Moderately under
  } else if (repsDifference == -1) {
    adjustment = protocol == 3 ? -2.5 : 0; // Slightly under
  } else if (repsDifference == 0) {
    adjustment = 0; // Perfect hit
  } else if (repsDifference == 1) {
    adjustment = 2.5; // Slightly over
  } else if (repsDifference == 2) {
    adjustment = protocol == 10 ? 2.5 : 5.0; // Moderately over
  } else {
    adjustment = protocol == 10 ? 5.0 : 7.5; // Significantly over
  }

  return ((newWeight / 2.5).round() * 2.5).clamp(2.5, double.infinity);
}
```

**Key Characteristics:**
- Adjustments are **relative to target reps**, not absolute rep counts
- Different protocols have different aggressiveness levels
- Always rounds to nearest 2.5kg increment
- Minimum weight clamped to 2.5kg

**Example Scenarios:**

```
Scenario 1: APRE 3 (Strength, target 3 reps)
  Current: 80kg × 3 reps
  Next set actual: 80kg × 2 reps (1 rep short)
  Adjustment: -2.5kg → 77.5kg (protocol 3: -2.5kg for -1 rep)

Scenario 2: APRE 6 (Hypertrophy, target 8 reps)
  Current: 60kg × 8 reps
  Next set actual: 60kg × 10 reps (2 reps over)
  Adjustment: +5kg → 65kg (protocol 6: +5kg for +2 reps)

Scenario 3: APRE 10 (Endurance, target 12 reps)
  Current: 40kg × 12 reps
  Next set actual: 40kg × 9 reps (3 reps short)
  Adjustment: -7.5kg → 32.5kg (protocol 10: -7.5kg for ≤-3 reps)
```

#### 1RM Calculation & Caching

**Function**: `calculateAPREWeights()`

Estimates one-rep maximum from historical workout data:

```dart
static Map<String, dynamic> calculateAPREWeights({
  required List<dynamic> historicalSets,
  required int protocol,
  bool useMetricSystem = true,
}) {
  // 1. Filter valid sets (weight > 0, reps 1-15)
  // 2. Sort by estimated 1RM (descending) to get heaviest lifts
  // 3. Take top 10 sets for calculation
  // 4. Calculate average 1RM across top 10 using OneRMCalculator
  // 5. Derive 3RM, 6RM, 10RM from estimated 1RM using Brzycki formula
  // 6. Round to nearest 2.5kg
  // 7. Cache all values with metadata (confidence level, data points)
}
```

**Cached Values** in Exercise entity:
- `calculated1RM`: Estimated one-rep max
- `calculated3RM`: Max weight for 3 reps (strength)
- `calculated6RM`: Max weight for 6 reps (hypertrophy)
- `calculated10RM`: Max weight for 10 reps (endurance)
- `lastCalculationDate`: Timestamp for staleness check
- `calculationMetadata`: Confidence level ("High"/"Medium"/"Low") based on data points

**Cache Staleness**: Recalculates if > 7 days old (checked via `shouldRecalculate()`)

**Example Calculation**:
```
Historical data for Bench Press: [80×5, 75×8, 70×10, 85×3, ...]
→ Sort by 1RM estimate (descending)
→ Take top 10 sets
→ Average 1RM = 95kg
→ 3RM = 90kg, 6RM = 82.5kg, 10RM = 70kg
→ Select protocol-specific base weight (e.g., 6RM=82.5kg for APRE 6)
→ Cache: calculated6RM = 82.5kg
```

### 1.2 RPE/RIR Auto-Regulation System

**File**: `/lib/features/workout/domain/services/rpe_autoregulation_service.dart` (214 lines)

Alternative to APRE, based on perceived exertion instead of rep targets.

#### RPE-Based Adjustment

**Function**: `calculateRPEAdjustment()`

Uses Helms et al. (2018) scientific formula:

```dart
static WeightAdjustment calculateRPEAdjustment({
  required double currentWeight,
  required double actualRPE,
  required double targetRPEMin,
  required double targetRPEMax,
})
```

**Formula**: For every 0.5 RPE outside target range, adjust load by 2%

**Adjustment Scale**:
- RPE 1-2 points **below** target: +4% to +8% weight
- RPE 0.5 points **below**: +2% weight
- RPE within target: No change
- RPE 0.5 points **above**: -2% weight
- RPE 1-2 points **above** target: -4% to -8% weight
- Cap: ±20% maximum adjustment

**Example**:
```
Target RPE: 7-9 (hypertrophy range)
Current weight: 80kg
Actual RPE: 6 (1 point below minimum)
Deviation: 1.0 points
Adjustment: (1.0 / 0.5) × 2% = 4% increase
New weight: 80kg × 1.04 = 83.2kg → rounds to 82.5kg
```

#### RIR-Based Adjustment

**Function**: `calculateRIRAdjustment()`

RIR (Reps In Reserve) inverse to RPE:

```dart
static WeightAdjustment calculateRIRAdjustment({
  required double currentWeight,
  required int actualRIR,
  required int targetRIR,
})
```

**Adjustment Scale**: 4% per RIR deviation

```
Target RIR: 2
Actual RIR: 0 (2 reps fewer than target)
Adjustment: 2 × 4% = -8% decrease
```

#### RPE ↔ RIR Conversion

```dart
static int rpeToRIR(double rpe) {
  RPE 10 → RIR 0
  RPE 9  → RIR 1
  RPE 8  → RIR 2
  RPE 7  → RIR 3
  RPE 6  → RIR 4
  RPE <6 → RIR 5+
}
```

### 1.3 Configuration Flow

**File**: `/lib/features/workout/presentation/widgets/auto_adjustment_modal.dart` (987 lines)

Users configure auto-adjustment per exercise through a modal interface.

#### APRE Configuration Steps:

1. **Protocol Selection**: Choose APRE 3/6/10 via segmented buttons
2. **Automatic 1RM Calculation**:
   - Fetches exercise history from `exerciseHistoryFromWorkoutsProvider`
   - Calculates 1RM from historical performance
   - Displays calculated 3RM/6RM/10RM in cards
   - Shows confidence level (High/Medium/Low)
3. **Base Weight Input**: User confirms or adjusts base weight
4. **Save**: Caches to Exercise entity

**Key Code Snippet:**
```dart
// Initialize from existing exercise
_apreProtocol = widget.exercise.apreProtocol ?? 6;
_apreBaseWeightController.text = widget.exercise.apreBaseWeight?.toString() ?? '';

// Use cached values if available
if (_calculated1RM != null && _calculated3RM != null) {
  // Use cached values (no recalculation needed)
} else {
  // Fetch history and calculate
  final historyData = await ref.read(exerciseHistoryFromWorkoutsProvider(...).future);
  // Perform 1RM calculation
}
```

#### RPE Configuration Steps:

1. **RPE vs RIR Selection**: Choose between RPE range or RIR target
2. **Input Values**:
   - RPE mode: Min RPE (e.g., 7) and Max RPE (e.g., 9)
   - RIR mode: Target RIR (e.g., 2)
3. **Save**: Stores targetRPEMin, targetRPEMax, or targetRIR to Exercise

### 1.4 Weight Suggestion Integration

**Primary Integration**: `/lib/features/workout/presentation/widgets/edit_set_modal.dart`

**Trigger Point**: After user completes a set and saves (lines 432-482)

**Flow**:
```
1. User marks set as completed and enters actualReps
2. _saveSet() method called
3. Check: exercise.autoAdjustmentType == AutoAdjustmentType.apre?
4. YES → Calculate suggested next weight:
   - Get protocol from exercise.apreProtocol or select based on targetReps
   - Call APREAutoRegulationService.calculateNextSetWeight()
   - Pass: protocol, current weight, target reps, actual reps
5. If weight change > 0.1kg:
   - Show weight suggestion banner with old/new weight
   - User can accept or skip suggestion
6. No change → Close modal normally
```

**Visual Feedback**:
- Weight suggestion banner appears if calculated weight differs > 0.1kg
- Shows original weight, suggested weight, and percentage change
- User can accept suggestion (auto-fill next set) or dismiss

---

## Part 2: Rest Timer Auto-Regulation System

### Overview

Automatically adjusts recommended rest time between sets based on performance indicators.

**File**: `/lib/features/workout/domain/services/rest_time_suggestion_service.dart` (118 lines)

### 2.1 Rest Time Adjustment Logic

**Trigger Conditions**:
- Weight decreases between sets (performance drop)
- Weight increases significantly (performance gain)
- Only for APRE exercises with `autoAdjustEnabled` config flag

**Function**: `checkRestTimeSuggestion()`

#### Performance Drop Handling

When new weight < last weight:

```dart
final weightDrop = lastWeight - newWeight;
final dropPercentage = (weightDrop / lastWeight) * 100;

// Suggest rest increase based on severity
if (dropPercentage > 10) {
  suggestion = 60;     // +1 minute (significant drop)
} else if (dropPercentage > 5) {
  suggestion = 30;     // +30 seconds (moderate drop)
} else {
  suggestion = 15;     // +15 seconds (small drop)
}

suggestedRestTime = currentRestTime + suggestion;
```

**Example**:
```
Current rest time: 90 seconds
Previous weight: 80kg
New weight: 70kg
Drop percentage: 12.5% (>10%)
Suggested adjustment: +60 seconds
New rest time: 150 seconds (2:30)
```

#### Performance Gain Handling

When weight increases significantly:

```dart
if (newWeight > lastWeight + 5 && currentRestTime > 60) {
  suggestedRestTime = (currentRestTime - 15).clamp(60, currentRestTime);
  reason = 'Peso aumentato! Puoi ridurre il recupero';
}
```

Never decreases rest below 60 seconds.

### 2.2 Rest Time Integration

**Integration Points**:
- `/lib/features/workout/presentation/widgets/edit_set_modal.dart` (lines 441-455)
- `/lib/features/workout/presentation/widgets/unified_set_input_modal.dart`

**Flow**:
```
1. Set saved with new weight
2. If previousSet exists and weight available:
   - Get lastWeight from previousSet
   - Call RestTimeSuggestionService.checkRestTimeSuggestion()
   - Pass: exercise, newWeight, lastWeight, currentRestTime, autoAdjustEnabled
3. If suggestion returned:
   - setState() sets _restTimeSuggestion and _showRestSuggestionBanner = true
   - Modal stays open to show suggestion banner
   - User can accept or continue
4. Banner displays:
   - Current vs suggested rest time
   - Reason for suggestion
   - Action buttons to apply or dismiss
```

**Visual Feedback**:
- Rest time suggestion banner (similar to weight banner)
- Formatted time display (MM:SS)
- Color coding: green for increase, amber for decrease
- One-tap acceptance to update exercise rest time

### 2.3 Configuration Control

**Config Flag**: `appConfigProvider.autoAdjustRestTime`

Set in app configuration to enable/disable rest time auto-suggestions globally.

Only works for APRE exercises (not RPE-based).

---

## Part 3: Data Model

### Exercise Entity Auto-Adjustment Fields

**File**: `/lib/features/workout/domain/entities/exercise.dart`

#### Auto-Adjustment Type
```dart
enum AutoAdjustmentType {
  apre,     // APRE protocol
  rpe,      // RPE/RIR based
}

final AutoAdjustmentType? autoAdjustmentType; // Type of auto adjustment
```

#### APRE Fields
```dart
final bool useAPRE;              // Enable/disable APRE
final int? apreProtocol;         // 3, 6, or 10
final double? apreBaseWeight;    // Base weight for calculations

// Cached 1RM calculations
final double? calculated1RM;
final double? calculated3RM;
final double? calculated6RM;
final double? calculated10RM;
final DateTime? lastCalculationDate;
final String? calculationMetadata; // Confidence info
```

#### RPE Fields
```dart
final double? targetRPEMin;      // e.g., 7.0
final double? targetRPEMax;      // e.g., 9.0
final int? targetRIR;            // e.g., 2
```

#### Rest Time
```dart
final int? restTime;  // Rest time in seconds (e.g., 90)
```

---

## Part 4: Integration Architecture

### Data Flow Diagram

```
Exercise Configuration (Modal)
    ↓
Exercise Entity (APRE + Cache)
    ↓
Set Completion (Edit Set Modal)
    ↓
├─→ Weight Auto-Regulation
│   ├─→ APREAutoRegulationService.calculateNextSetWeight()
│   │   └─→ Compare: actualReps vs targetReps
│   │       └─→ Adjust weight based on protocol
│   │
│   └─→ RPEAutoregulationService.calculateRPEAdjustment()
│       └─→ Compare: actualRPE vs targetRPERange
│           └─→ Adjust weight by percentage
│
└─→ Rest Time Auto-Regulation
    └─→ RestTimeSuggestionService.checkRestTimeSuggestion()
        └─→ Compare: newWeight vs lastWeight
            └─→ Adjust rest time based on drop %

    ↓
Suggestion Banners (User Confirmation)
    ↓
Next Set (with suggestions pre-filled)
```

### Provider Integration

**Key Providers**:
- `appConfigProvider`: Global settings (autoAdjustRestTime, measurementUnit)
- `exerciseHistoryFromWorkoutsProvider`: Historical performance data
- `currentWorkoutProvider`: Current workout state
- `workoutAnalyticsProvider`: Analytics tracking

---

## Part 5: Issues & Concerns

### Critical Issues

#### Issue #1: Fatigue Accumulation Not Modeled
**Severity**: Medium  
**Description**: Weight adjustments are based solely on rep performance in the current set, not cumulative fatigue across multiple sets in a workout.

**Example**: User does 3 sets of bench press:
- Set 1: 80kg × 5 reps → suggest 82.5kg
- Set 2: 82.5kg × 4 reps → suggest 80kg (back to original)
- Set 3: 80kg × 3 reps → suggest 77.5kg

The system doesn't recognize increasing fatigue trend.

**Recommended Fix**: Implement set sequence analysis to detect fatigue patterns and adjust thresholds dynamically.

---

#### Issue #2: Rest Time Suggestions Ignore RPE
**Severity**: Medium  
**Description**: Rest time suggestions only consider weight changes, not perceived exertion (RPE) data, which is often a better fatigue indicator.

**Current**: Only triggered on weight drop > 5%  
**Missing**: Consider RPE value for rest adjustment (e.g., RPE 9+ always suggests +30s)

**Recommended Fix**: Integrate RPE as secondary trigger for rest time adjustment.

---

#### Issue #3: Protocol Selection Not User-Adaptive
**Severity**: Low  
**Description**: Protocol selection (APRE 3/6/10) is purely deterministic based on target reps, not considering user experience level or training history.

**Current Logic**:
```
targetReps 1-5   → APRE 3
targetReps 6-10  → APRE 6
targetReps 11+   → APRE 10
```

**Missing**: Consideration of:
- User's experience level (beginner vs advanced)
- Historical performance consistency
- User-stated training goal

**Recommended Fix**: Add experience-level-aware protocol selection.

---

#### Issue #4: Inconsistent Adjustment Magnitudes
**Severity**: Low  
**Description**: APRE 3 and APRE 10 have different adjustment magnitudes for the same rep difference without clear documentation.

```
APRE 3 for -1 rep:  -2.5kg
APRE 6 for -1 rep:  0kg (maintain)
APRE 10 for -1 rep: 0kg (maintain)

APRE 3 for ≥+3 reps: +7.5kg
APRE 10 for ≥+3 reps: +5kg
```

**Recommended Fix**: Document rationale or add user-customizable adjustment factors.

---

#### Issue #5: Cache Invalidation Strategy
**Severity**: Medium  
**Description**: 1RM cache only checks age (7 days), not actual performance changes.

**Scenarios not invalidating cache:**
- User performs significantly heavier weight (e.g., 1RM improves)
- Multiple failed sets below previous performance
- Equipment/gym change affecting baseline strength

**Recommended Fix**: Implement content-based invalidation:
- If new max weight > cached 1RM + 5%, recalculate
- If failed set < cached 1RM - 10%, recalculate
- Track failed vs successful set ratio

---

#### Issue #6: Suggestion Accuracy Tracking Disabled
**Severity**: Medium  
**Description**: Code to track suggestion accuracy (for machine learning) is disabled due to GDPR compliance.

```dart
// Lines 513-566 in edit_set_modal.dart: DISABLED
// Reason: GDPR compliance - depends on medical questionnaire data
```

**Impact**: Cannot learn from user behavior patterns or improve suggestions over time.

**Recommended Fix**: Implement privacy-preserving analytics (anonymized, on-device, optional consent).

---

### Medium Issues

#### Issue #7: Hardcoded Rest Time Thresholds
**Severity**: Medium  
**Description**: Rest time suggestion thresholds (10%, 5%) are hardcoded without user customization.

```dart
if (dropPercentage > 10) {
  suggestion = 60;     // Hardcoded +60 seconds
} else if (dropPercentage > 5) {
  suggestion = 30;     // Hardcoded +30 seconds
}
```

**Missing**: User-configurable sensitivity:
- Conservative: only suggest for >15% drops
- Moderate: default (>10%, >5%)
- Aggressive: suggest for >3% drops

**Recommended Fix**: Add sensitivity setting to app config.

---

#### Issue #8: 1RM Calculation Bias
**Severity**: Low  
**Description**: Averaging top 10 sets by estimated 1RM could be biased by:
- Test sets or warm-ups recorded with full effort
- Equipment variations (dumbbells vs barbell)
- Form changes affecting estimate accuracy

**Algorithm**:
```dart
validSets.sort((a, b) {
  final aEstimate = OneRMCalculator.calculateAverage(a.weight!, a.reps!);
  final bEstimate = OneRMCalculator.calculateAverage(b.weight!, b.reps!);
  return bEstimate.compareTo(aEstimate);
});
final topSets = validSets.take(10).toList();
double total1RM = topSets.map(estimate).reduce((a,b) => a+b) / count;
```

**Recommended Fix**: Use median instead of mean, or implement outlier detection.

---

#### Issue #9: Fixed RPE-RIR Conversion
**Severity**: Low  
**Description**: RPE-RIR conversion table is universal, but actual correlation varies by:
- Individual perception of exertion
- Exercise type (compound vs isolation)
- Training experience

```dart
static int rpeToRIR(double rpe) {
  if (rpe >= 10) return 0;  // Assumes fixed mapping
  if (rpe >= 9) return 1;
  if (rpe >= 8) return 2;
  // ...
}
```

**Recommended Fix**: Calibration step during onboarding to personalize RPE-RIR scale.

---

#### Issue #10: Weight Plate Standardization
**Severity**: Low  
**Description**: Weights always round to 2.5kg increments, but not all equipment uses this.

**Common alternatives:**
- Hex dumbbells: 1kg increments
- Machines: 2.5kg increments
- Barbells: 1.25kg plates available

**Current rounding**:
```dart
final roundedWeight = ((newWeight / 2.5).round() * 2.5);
```

**Recommended Fix**: Make plate size configurable per exercise or gym.

---

### Low Issues

#### Issue #11: Auto-Adjustment Modal Complexity
The modal is 987 lines and handles too many concerns (APRE setup, RPE setup, calculation logic, UI). Should be refactored into smaller components.

#### Issue #12: Missing Visual Feedback for Cache Status
Users don't know if 1RM calculation is cached or fresh. Could add timestamp display in configuration modal.

#### Issue #13: No A/B Testing Framework
Multiple adjustment strategies exist but no framework for testing which works best for different user profiles.

---

## Part 6: Key Code Locations

### Service Layer
```
Domain Services (Business Logic)
├── apre_auto_regulation_service.dart (259 lines)
│   ├── selectProtocolFromTargetReps()
│   ├── getRestTimeForProtocol()
│   ├── calculateAPREWeights()
│   ├── calculateNextSetWeight()
│   └── getProtocolDescription()
│
├── rpe_autoregulation_service.dart (214 lines)
│   ├── calculateRPEAdjustment()
│   ├── calculateRIRAdjustment()
│   ├── rpeToRIR()
│   └── _roundWeight()
│
└── rest_time_suggestion_service.dart (118 lines)
    └── checkRestTimeSuggestion()
```

### Presentation Layer
```
UI/Widget Layer (User Interaction)
├── auto_adjustment_modal.dart (987 lines)
│   ├── APRE configuration tab
│   ├── RPE configuration tab
│   ├── 1RM calculation & display
│   └── Exercise history integration
│
├── edit_set_modal.dart (700+ lines)
│   ├── Weight auto-adjustment logic (lines 432-482)
│   ├── Rest time auto-adjustment logic (lines 441-455)
│   ├── Suggestion banner rendering
│   └── Set completion flow
│
├── rpe_selector_bottom_sheet.dart (500+ lines)
│   ├── RPE/RIR input during workout
│   ├── APRE suggestion integration
│   └── Superset navigation
│
└── unified_set_input_modal.dart
    └── Alternative set input with auto-adjustment
```

### Data Layer
```
Exercise Entity
└── exercise.dart
    ├── AutoAdjustmentType enum
    └── Auto-adjustment fields (20+ new fields)

Providers
├── appConfigProvider → autoAdjustRestTime flag
├── exerciseHistoryFromWorkoutsProvider → history for 1RM
└── workoutAnalyticsProvider → event tracking
```

---

## Part 7: Usage Example

### Setup APRE for Bench Press

**Step 1: Open Auto-Adjustment Modal**
```
User taps Exercise Settings → "Configure Auto-Adjustment"
```

**Step 2: Select APRE Protocol**
```
Choose APRE 6 (hypertrophy for 6-8 rep range)
```

**Step 3: Auto-Calculate 1RM**
```
Modal fetches history: [80×8, 75×10, 85×6, ...]
Calculates 1RM = 102kg
Derives 6RM = 82.5kg
Shows: "Based on 12 recent sets (High confidence)"
```

**Step 4: Confirm Base Weight**
```
Base weight auto-set to 82.5kg (the 6RM value)
User can adjust if needed
```

**Step 5: Save Configuration**
```
Exercise now stores:
- autoAdjustmentType: apre
- apreProtocol: 6
- apreBaseWeight: 82.5
- calculated6RM: 82.5
- lastCalculationDate: 2025-11-05
```

### During Workout

**Set 1**: 82.5kg × 8 reps (target) → Hit target exactly ✓  
Suggestion: Keep 82.5kg for Set 2

**Set 2**: 82.5kg × 7 reps (1 rep short)  
Calculation:
- Protocol 6, target 8, actual 7 (repsDifference = -1)
- Protocol 6 adjustment for -1 rep: 0kg (maintain)
- Suggested weight: 82.5kg (unchanged)
- No suggestion banner shown

**Set 3**: 82.5kg × 6 reps (2 reps short)  
Calculation:
- repsDifference = -2
- Protocol 6 adjustment: -2.5kg
- Suggested weight: 80kg
- Weight suggestion banner appears: "80kg suggested (was 82.5kg)"

User accepts → Next set pre-filled with 80kg

---

## Part 8: Future Enhancement Opportunities

1. **Machine Learning**: Train model on suggestion acceptance/rejection patterns
2. **Recovery Integration**: Combine with sleep/HRV data for rest time suggestions
3. **Periodization Awareness**: Vary adjustment aggressiveness by training phase
4. **Social Sharing**: Compare auto-regulation preferences with community
5. **A/B Testing Framework**: Built-in capability to test adjustment algorithms
6. **Microloading**: Support for sub-2.5kg plate increments (requires equipment data)
7. **Exercise-Specific Protocols**: Different protocols for different exercise types
8. **Real-time Feedback**: Visual feedback during set (video analysis) to inform adjustments

---

## Conclusion

GymBro's auto-regulation systems are comprehensive and scientifically grounded, with both APRE and RPE/RIR protocols. However, the system could benefit from:

1. **Fatigue modeling** for multi-set adaptation
2. **RPE-based rest suggestions** for better fatigue sensing
3. **User profile adaptation** for protocol selection
4. **Improved cache invalidation** based on content, not just time
5. **Privacy-preserving analytics** to enable continuous improvement

The implementation is robust but has room for optimization in handling edge cases and providing more intelligent, personalized adjustments.

---

**Report Generated**: November 5, 2025  
**Codebase Version**: feature/routine-center-v2-pattern-detection  
**Analysis Depth**: Medium (all major features covered, select implementation details)
