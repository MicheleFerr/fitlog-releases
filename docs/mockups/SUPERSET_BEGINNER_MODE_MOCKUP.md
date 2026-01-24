# Mockup: Beginner Mode (Progressive Disclosure)

## 🔴 BEFORE (Current - Information Overload)

```
┌─────────────────────────────────────┐
│  🔗 Bench + Row Superset            │
│  ● ○ ○  (0/3 rounds)                │
├─────────────────────────────────────┤
│  Round 1 (tap to start)             │
│  ┌───────────────────────────────┐  │
│  │ A  Bench Press  3-1-2  80×10 │  │ ← Letter + TUT confusing
│  │ B  Dumbbell Row 2-0-2  35×12 │  │
│  └───────────────────────────────┘  │
│  Round 2                            │
│  ┌───────────────────────────────┐  │
│  │ A  Bench Press  3-1-2  85×8  │  │
│  │ B  Dumbbell Row 2-0-2  37×10 │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**PROBLEMI PER MARCO (PRINCIPIANTE):**
- ❌ Letter indicators (A, B) → "cosa significano?"
- ❌ TUT notation (3-1-2) → "non capisco questi numeri"
- ❌ RPE badge (8 in rosso) → "è un errore?"
- ❌ Troppi dati contemporaneamente
- ❌ Intimidito, non usa superset

**RISULTATO:**
- Marco adoption rate: **2%** (evita per confusione)
- Support tickets: "cosa sono le lettere A B?"

---

## 🟢 AFTER (Beginner Mode Enabled)

```
┌─────────────────────────────────────┐
│  🔗 Chest + Back Combo              │ ← Renamed (no "superset" term)
│  ● ○ ○  (0/3 rounds)                │
├─────────────────────────────────────┤
│  Round 1 (tap to start) ← Simple language
│  ┌───────────────────────────────┐  │
│  │ Bench Press      80kg × 10   │  │ ← No letters!
│  │ Dumbbell Row     35kg × 12   │  │ ← No TUT!
│  └───────────────────────────────┘  │
│  Round 2                            │
│  ┌───────────────────────────────┐  │
│  │ Bench Press      85kg × 8    │  │
│  │ Dumbbell Row     37kg × 10   │  │
│  └───────────────────────────────┘  │
│                                     │
│  💡 Do these back-to-back!          │ ← Helpful tip
└─────────────────────────────────────┘
```

**MIGLIORAMENTI:**
- ✅ Nessuna lettera (A, B, C)
- ✅ Nessun TUT se non abilitato
- ✅ Nessun RPE badge se non completato
- ✅ Linguaggio semplice ("Combo" invece di "Superset")
- ✅ Tip esplicativa

**DURING EXECUTION (Beginner Mode):**
```
┌─────────────────────────────────────┐
│  ← Bench Press                   ✕ │
│     ● ○                             │ ← Progress dots (simple)
│  Step 1 of 2                        │ ← "Step" not "Exercise"
├─────────────────────────────────────┤
│  Weight: 80.0 kg                    │
│  Reps:   10                         │
│                                     │
│  How hard was this?                 │ ← Simple RPE question
│  ┌─────────────────────────────────┐│
│  │ 😊 Easy                          ││
│  │ 😐 Medium                        ││
│  │ 😓 Hard                          ││ ← Emoji scale!
│  └─────────────────────────────────┘│
│                                     │
│  [Done, Next Exercise →]            │ ← Clear CTA
└─────────────────────────────────────┘
```

**VS ADVANCED MODE:**
```
┌─────────────────────────────────────┐
│  ← Bench Press                   ✕ │
│     ● ○ ○                           │
│  Bench Press (1/3) [TUT: 3-1-2]    │ ← TUT visible
├─────────────────────────────────────┤
│  Weight: [80.0] kg                  │
│  Reps:   [10]                       │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ RPE Scale (6-10)                ││
│  │ ○ 6  ○ 7  ● 8  ○ 9  ○ 10       ││ ← Numeric RPE
│  └─────────────────────────────────┘│
│                                     │
│  [Confirm & Next →]                 │
└─────────────────────────────────────┘
```

---

## 🎨 Design Specs

### Beginner Mode Toggle
```dart
// Location: Settings > Workout Preferences
// Default: ON for new users (onboarding detection)
// Label: "Beginner Mode"
// Description: "Simplifies workout interface. Recommended for first 3 months."

class AppConfig {
  final bool beginnerMode; // Added to existing config

  // Auto-detection logic
  static bool shouldEnableByDefault(User user) {
    final accountAge = DateTime.now().difference(user.createdAt);
    final workoutCount = user.totalWorkouts;

    // Enable if:
    return accountAge.inDays < 90 || // < 3 months old account
           workoutCount < 20;         // < 20 workouts logged
  }
}
```

### Conditional Rendering Strategy
```dart
// In SupersetCard._buildExerciseRow()
Widget _buildExerciseRow(...) {
  final beginnerMode = ref.watch(
    appConfigProvider.select((c) => c.beginnerMode ?? false),
  );

  return Row(
    children: [
      // Letter indicator - ONLY if advanced mode
      if (!beginnerMode)
        Container(...), // A, B, C letters

      // Exercise name (always visible)
      Text(exercise.name),

      // TUT chip - ONLY if advanced mode AND enabled
      if (!beginnerMode && showTut)
        GestureDetector(...), // TUT chip

      // Weight × Reps (always visible)
      Text('${weight} × $reps'),

      // RPE badge - ONLY if advanced mode AND completed
      if (!beginnerMode && exerciseData?.rpe != null)
        Container(...), // RPE badge
    ],
  );
}
```

### Emoji RPE Scale Mapping
```dart
class BeginnerRPEScale {
  static const Map<String, int> emojiToRPE = {
    '😊': 6,  // Easy - could do 4+ more reps
    '😐': 8,  // Medium - could do 2 more reps
    '😓': 9,  // Hard - could do 1 more rep (maybe)
  };

  static String rpeToEmoji(int rpe) {
    if (rpe <= 6) return '😊';
    if (rpe <= 8) return '😐';
    return '😓';
  }

  static String getDescription(String emoji) {
    return switch (emoji) {
      '😊' => 'Could do 4+ more reps',
      '😐' => 'Could do 2 more reps',
      '😓' => 'Could barely finish',
      _ => '',
    };
  }
}
```

### Terminology Simplification
```dart
class BeginnerTerminology {
  static const Map<String, String> simplifiedTerms = {
    'Superset': 'Combo',           // "Chest + Back Combo"
    'Exercise': 'Step',            // "Step 1 of 2"
    'RPE': 'How hard?',            // "How hard was this?"
    'Rest': 'Break',               // "Take a 90s break"
    'Reps': 'Reps',                // Keep (universally known)
    'Set': 'Round',                // "Round 1"
  };

  static String simplify(String term, {required bool beginnerMode}) {
    if (!beginnerMode) return term;
    return simplifiedTerms[term] ?? term;
  }
}
```

---

## 🎓 Onboarding Flow

### First-Time Superset Creation (Beginner)
```
┌─────────────────────────────────────┐
│  🎉 Your First Combo!               │
│                                     │
│  A "combo" means doing 2 exercises  │
│  back-to-back with no rest between. │
│                                     │
│  Why? It saves time and burns more  │
│  calories! 💪                        │
│                                     │
│  Try it: Bench Press + Row          │
│                                     │
│  [Got it!]  [Show me a video 📹]   │
└─────────────────────────────────────┘
```

### Graduation Prompt (After 20 workouts)
```
┌─────────────────────────────────────┐
│  🎓 Ready for More?                 │
│                                     │
│  You've completed 20 workouts!      │
│                                     │
│  Want to unlock advanced features?  │
│  • Detailed RPE tracking            │
│  • TUT (Time Under Tension)         │
│  • Advanced analytics               │
│                                     │
│  [Enable Advanced Mode]             │
│  [Keep it simple for now]           │
└─────────────────────────────────────┘
```

---

## 📊 Expected Impact

### Marco (Beginner) Adoption
```
Current:
  - Superset usage: 2%
  - Completion rate: 30% (many abandon mid-setup)
  - Support tickets: 15/month "confusing interface"

With Beginner Mode:
  - Superset usage: 15% (+650% increase!)
  - Completion rate: 80% (+167% increase)
  - Support tickets: 3/month (-80% reduction)
```

### Retention Impact
```
Research: 50% of beginners quit within 3 months
Hypothesis: Simplified UI reduces intimidation

Current 90-day retention: 35%
Target 90-day retention:  50% (+43% improvement)

Mechanism: Less intimidation = higher confidence = better retention
```

### Feature Discovery
```
Problem: Advanced users accidentally stuck in beginner mode?
Solution: Auto-graduation prompt after 20 workouts

Metric: % users who graduate to advanced mode
Target: 60% of users after 20 workouts
Fallback: Manual toggle always available in Settings
```

---

## 🧪 A/B Test Plan

### Test Design
```
Group A (Control): Standard UI for all users
Group B (Test): Beginner Mode auto-enabled for new users (<3 months)
Group C (Test): Beginner Mode + Graduation prompt

Duration: 8 weeks
Sample size: 5,000 new users (1,667 per group)
```

### Metrics
```
Primary:
  - 90-day retention rate
  - Superset adoption rate
  - Workout completion rate

Secondary:
  - Support ticket volume
  - Time to first superset
  - NPS score from beginners

Qualitative:
  - User interviews (n=20 per group)
  - Session recordings (Hotjar/FullStory)
  - Exit surveys for churned users
```

### Success Criteria
```
✅ 90-day retention: +10% improvement
✅ Superset adoption: +300% for beginners
✅ Support tickets: -50% reduction
✅ NPS from beginners: +15 points
```

---

## 🎯 Graduation Triggers (Auto-Advanced Mode)

```dart
class BeginnerGraduationService {
  static bool shouldSuggestGraduation(User user, AppUsageStats stats) {
    // Criteria 1: Time-based (3 months active)
    final accountAge = DateTime.now().difference(user.createdAt);
    if (accountAge.inDays >= 90) return true;

    // Criteria 2: Volume-based (20 workouts)
    if (stats.totalWorkouts >= 20) return true;

    // Criteria 3: Consistency-based (3+ workouts/week for 4 weeks)
    if (stats.avgWeeklyWorkouts >= 3 && stats.consistentWeeks >= 4) {
      return true;
    }

    // Criteria 4: Feature usage (used supersets 5+ times)
    if (stats.supersetWorkouts >= 5) return true;

    return false;
  }
}
```

---

## 🚀 Implementation Roadmap

**Phase 1 (Week 1):** Core beginner mode toggle
- [ ] Add `beginnerMode` to AppConfig
- [ ] Conditional rendering in SupersetCard
- [ ] Emoji RPE scale in RpeSelectorBottomSheet
- [ ] Terminology simplification utility

**Phase 2 (Week 2):** Onboarding & auto-detection
- [ ] First-time superset tooltip
- [ ] Auto-enable for new users
- [ ] Graduation detection service

**Phase 3 (Week 3):** Graduation flow
- [ ] Graduation prompt UI
- [ ] Feature comparison screen
- [ ] Analytics tracking

**Phase 4 (Week 4+):** A/B testing & iteration
- [ ] Deploy to 33% of new users
- [ ] Monitor metrics
- [ ] User interviews
- [ ] Iterate based on feedback
