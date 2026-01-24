# Mockup: Progress Dots in Superset Execution

## 🔴 BEFORE (Current State)

```
┌─────────────────────────────────────┐
│  ← Bench Press                   ✕ │ <- No context di "quale esercizio"
├─────────────────────────────────────┤
│                                     │
│  Weight: [80.0] kg                  │
│  Reps:   [10]                       │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ RPE Scale (6-10)            │   │
│  │ ○ 6  ○ 7  ● 8  ○ 9  ○ 10   │   │
│  └─────────────────────────────┘   │
│                                     │
│        [Confirm & Next →]           │
└─────────────────────────────────────┘
```

**PROBLEMA:**
- ❌ User non sa "sto facendo esercizio 1 di 3"
- ❌ Deve ricordare mentalmente l'ordine
- ❌ Confusione se interrotto (chiamata, etc)

---

## 🟢 AFTER (With Progress Dots)

```
┌─────────────────────────────────────┐
│  ← Bench Press                   ✕ │
│                                     │
│     ● ○ ○                           │ <- NEW! Progress dots
│  Bench Press (1/3)                  │ <- NEW! Exercise counter
├─────────────────────────────────────┤
│                                     │
│  Weight: [80.0] kg                  │
│  Reps:   [10]                       │
│                                     │
│  ┌─────────────────────────────────┐   │
│  │ RPE Scale (6-10)                │   │
│  │ ○ 6  ○ 7  ● 8  ○ 9  ○ 10       │   │
│  └─────────────────────────────────┘   │
│                                     │
│  [Confirm & Next →]  ← Swipe →     │ <- NEW! Swipe hint
└─────────────────────────────────────┘

// After swipe right →

┌─────────────────────────────────────┐
│  ← Dumbbell Row                  ✕ │
│                                     │
│     ○ ● ○                           │ <- Dot 2 filled
│  Dumbbell Row (2/3)                 │
├─────────────────────────────────────┤
│  Weight: [35.0] kg                  │
│  Reps:   [12]                       │
│  ...                                │
└─────────────────────────────────────┘
```

**MIGLIORAMENTI:**
- ✅ Chiaro "sono all'esercizio 2 di 3"
- ✅ Visual progress immediato (dots)
- ✅ Counter testuale come backup
- ✅ Swipe hint per discoverability

**PERSONA IMPACT:**
- Marco: Confidence +30% (sa sempre dove è)
- Chiara: Distraction recovery +50% (se interrotta riprende facilmente)
- Luca: UX polish appreciated

---

## 🎨 Design Specs

### Progress Dots
```dart
// Position: Below header, centered
// Spacing: 8px between dots
// Size: 8x8 dp circle
// Colors:
//   - Active: context.colors.primary
//   - Inactive: context.colors.outline.withOpacity(0.3)
// Animation: Scale 1.0 → 1.2 on transition
```

### Exercise Counter
```dart
// Format: "{exerciseName} ({current}/{total})"
// Font: bodyMedium, fontWeight: w600
// Color: context.colors.onSurface
// Position: Below dots, left-aligned
```

### Swipe Hint
```dart
// Text: "← Swipe →" (only on first time, then dismissed)
// Font: labelSmall, italic
// Color: context.colors.onSurfaceVariant
// Animation: Fade in/out every 2s (3 times max)
```

---

## 📊 A/B Test Hypothesis

**Metric:** User confusion rate (support tickets "non capisco dove sono nel superset")
**Expected:** -80% confusion rate
**Measurement:** Track app analytics evento "superset_execution_navigation_error"

**Metric:** Completion rate (% users che finiscono tutti gli esercizi del round)
**Expected:** +15% completion rate
**Measurement:** Firebase Analytics custom event
