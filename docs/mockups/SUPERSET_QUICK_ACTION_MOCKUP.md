# Mockup: Quick Superset Action Path

## 🔴 BEFORE (Current State - 4 Taps)

```
Step 1: Tap on exercise menu
┌─────────────────────────────────────┐
│  Bench Press            [⋮] ← Tap  │
│  3 sets × 10 reps                   │
│  80kg, 85kg, 90kg                   │
└─────────────────────────────────────┘

Step 2: Menu opens
┌─────────────────────────────────────┐
│  ✎ Edit Exercise                    │
│  🔁 Replace                          │
│  🔗 Create Superset     ← Tap       │
│  🗑 Delete                           │
└─────────────────────────────────────┘

Step 3: Selection modal opens
┌─────────────────────────────────────┐
│  🔗 Create Superset                 │
│  ┌───────────────────────────────┐  │
│  │ Bench Press            🔒     │  │ (locked)
│  └───────────────────────────────┘  │
│                                     │
│  [In Workout] [From Database]       │
│  ┌───────────────────────────────┐  │
│  │ ☐ Dumbbell Row               │  │ ← Tap to select
│  │ ☐ Lat Pulldown               │  │
│  └───────────────────────────────┘  │
│  1 selected (min 2)                 │
│              [Continue →]           │ ← Tap (disabled)
└─────────────────────────────────────┘

Step 4: Configuration modal
┌─────────────────────────────────────┐
│  Configure Superset                 │
│  Rounds: [3]                        │
│  Rest after round: [90s]            │
│              [Create ✓]  ← Tap      │
└─────────────────────────────────────┘

⏱ Total: 4 taps + 2 modals + typing
```

**PROBLEMI:**
- ❌ 4+ taps richiesti
- ❌ 2 modali sovrapposti (cognitive load)
- ❌ Chiara (busy mom) abbandona per tempo
- ❌ Friction durante workout attivo

---

## 🟢 AFTER (Quick Action - 2 Taps)

```
Step 1: Quick action button on exercise card
┌─────────────────────────────────────┐
│  Bench Press              [⋮]  [🔗] │ ← NEW! Quick superset button
│  3 sets × 10 reps                   │
│  80kg, 85kg, 90kg                   │
└─────────────────────────────────────┘
              ↓ Tap 🔗

Step 2: Inline action sheet (next exercise)
┌─────────────────────────────────────┐
│  ⚡ Quick Superset                   │
│  ┌───────────────────────────────┐  │
│  │ ✓ Bench Press                │  │ (auto-selected)
│  │ ✓ Dumbbell Row               │  │ (next in workout)
│  └───────────────────────────────┘  │
│  3 rounds × 90s rest                │ (smart defaults)
│                                     │
│  [Create ✓]  [Customize ⚙️]         │
└─────────────────────────────────────┘
              ↓ Tap Create

✅ Superset created! (closes automatically)
┌─────────────────────────────────────┐
│  🔗 Bench + Row Superset            │
│  ● ○ ○  (0/3 rounds)                │
│  A: Bench Press    80kg × 10        │
│  B: Dumbbell Row   35kg × 12        │
└─────────────────────────────────────┘

⏱ Total: 2 taps + 0 modals + 0 typing
```

**MIGLIORAMENTI:**
- ✅ 4 taps → 2 taps (-50% friction)
- ✅ 2 modals → 1 inline sheet (-50% cognitive load)
- ✅ Smart defaults (3 rounds, 90s rest, next exercise)
- ✅ Fallback "Customize" per power users

**ADVANCED: If no next exercise**
```
┌─────────────────────────────────────┐
│  ⚡ Quick Superset                   │
│  ┌───────────────────────────────┐  │
│  │ ✓ Bench Press                │  │
│  │ ? Select exercise...         │  │ ← Opens full selector
│  └───────────────────────────────┘  │
│  💡 Suggested pairings:             │ ← NEW! AI suggestions
│  [+ Dumbbell Row] [+ Cable Row]    │
└─────────────────────────────────────┘
```

---

## 🎨 Design Specs

### Quick Action Button (🔗)
```dart
// Position: Top-right of exercise card, left of menu (⋮)
// Size: 32x32 dp
// Icon: AppIcons.link
// Color: context.colors.secondary (distinctive from menu)
// Tooltip: context.l10n.quickSuperset
// Haptic: lightImpact on tap

// Visibility logic:
if (currentIndex < workout.exercises.length - 1 &&
    !workout.exercises[currentIndex + 1].isSuperset) {
  // Show button
}
```

### Inline Action Sheet
```dart
// Type: showModalBottomSheet with DraggableScrollableSheet
// Height: 0.4 (40% screen) - compact!
// Border radius: 20 top corners
// Background: context.colors.surface
// Padding: 16px all sides

// Smart Defaults:
final defaults = SupersetDefaults(
  rounds: 3,
  restAfterRound: 90, // seconds
  restBetweenExercises: 0, // true superset
);
```

### Suggested Pairings Chips
```dart
// Layout: Horizontal scrollable row
// Chip design:
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: context.colors.secondaryContainer,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: context.colors.secondary),
  ),
  child: Row(
    children: [
      Icon(AppIcons.add, size: 16),
      SizedBox(width: 4),
      Text(exerciseName, style: labelMedium),
    ],
  ),
)

// Tap behavior:
onTap: () {
  setState(() => selectedExercise = suggestion);
}
```

---

## 🎯 Business Logic

### Smart Next Exercise Detection
```dart
Exercise? getNextViableExercise(int currentIndex) {
  for (int i = currentIndex + 1; i < workout.exercises.length; i++) {
    final next = workout.exercises[i];

    // Skip if already in a superset
    if (next is SupersetExercise) continue;

    // Skip if same muscle group (prevent overtraining)
    if (next.category == currentExercise.category) continue;

    return next;
  }
  return null; // No viable next exercise
}
```

### Smart Defaults Strategy
```dart
class SupersetDefaults {
  // Backed by research: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4523889/
  // Optimal rest for hypertrophy: 60-90s
  static const int defaultRounds = 3; // Standard 3x10 protocol
  static const int defaultRest = 90;  // 90s optimal for hypertrophy
  static const int defaultRestBetween = 0; // True superset (no rest)

  // Persona-specific overrides (future enhancement)
  static int getRoundsForPersona(UserPersona persona) {
    return switch (persona) {
      UserPersona.beginner => 2,      // Marco: less volume
      UserPersona.busy => 3,          // Chiara: standard
      UserPersona.powerlifter => 4,   // Luca: more volume
      _ => 3,
    };
  }
}
```

---

## 📊 Expected Impact

### Adoption Metrics
```
Metric: Superset creation rate
Current: 5% of workouts contain supersets
Target:  15% of workouts (+200% increase)
Persona breakdown:
  - Marco (beginner): 2% → 8% (+300%)
  - Chiara (busy): 3% → 12% (+300%)
  - Luca (advanced): 15% → 25% (+67%)
```

### Time to Create
```
Current flow: 45-60 seconds avg
Quick action: 10-15 seconds avg
Improvement: -75% time reduction
```

### User Satisfaction (NPS)
```
Question: "How easy is it to create supersets?"
Current: 6.2/10 (detractors: "too many steps")
Target:  8.5/10 (promoters: "love the quick button!")
```

---

## 🧪 A/B Test Plan

**Control Group (50%):** Current 4-tap flow
**Test Group (50%):** Quick action button visible

**Primary Metric:** Superset creation rate
**Secondary Metrics:**
- Time to create superset
- Completion rate (% finished vs abandoned)
- NPS score on "ease of creating supersets"

**Success Criteria:**
- ✅ +100% adoption rate
- ✅ -50% time to create
- ✅ +2 points NPS improvement

**Rollout Plan:**
- Week 1: A/B test with 50/50 split
- Week 2: Analyze results, iterate on feedback
- Week 3: 100% rollout if success criteria met
