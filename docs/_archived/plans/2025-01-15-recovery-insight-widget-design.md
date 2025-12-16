# Recovery Insight Widget - Design Document

**Date**: 2025-01-15
**Status**: Approved
**Feature**: Sleep-Workout Correlation Analysis
**Tier**: Pro (with basic preview for free users)

---

## Overview

Widget che mostra correlazione tra sonno e performance workout, basato su ricerca scientifica e best practices UI/UX 2025.

### Problem Statement

1. Il Readiness Score esistente non usa dati wearables (solo workout history)
2. Utenti non vedono correlazione tra sonno e performance
3. Competitor (WHOOP, Oura) offrono questa feature a €30/mese

### Solution

Widget "Recovery Insight" che:
- Legge dati sonno da Apple Health/Health Connect
- Correla con storico workout (volume, intensità)
- Mostra insight actionable all'utente

---

## Scientific Basis

### Key Studies

| Study | Finding | Application |
|-------|---------|-------------|
| Res et al. | -22% MPS with sleep deprivation | Sleep <6h = warning |
| Knowles et al. | Reduced strength output <6h | Recommend lighter workout |
| AASM/Sleep Research Society | 7-9h recommended | Optimal range indicator |
| Skein et al. 2011 | Cumulative decline with consecutive restriction | Track streak of bad nights |

### Sleep Categories

```
< 6h    = Critical (significant performance impact)
6-7h    = Suboptimal (moderate impact)
7-9h    = Optimal (no impact)
> 9h    = Excessive (may indicate overtraining/illness)
```

---

## UI Design

### Design Principles (2025 Best Practices)

1. **Minimalist** - One prominent number, zero clutter
2. **Progressive Disclosure** - Simple → detailed on demand
3. **Bento Grid** - iOS 17 style modular layout
4. **Dark Mode First** - Sleep feature = night usage
5. **Supportive Microcopy** - Positive, not judgmental
6. **Circular Progress** - Health app standard (Apple, Oura, WHOOP)

### Card Widget (Home)

```
┌─────────────────────────────────────────┐
│                                         │
│   ╭─────────╮                           │
│   │   78    │   Recovery                │
│   │   ●●●●○ │   Pronto per allenar...   │
│   ╰─────────╯                           │
│                                         │
│   💤 6h 32m        ⚡ 3gg streak         │
│                                         │
└─────────────────────────────────────────┘
```

**Elements:**
- Score (0-100) - Large, visible in 50ms
- Progress dots (5) - Less anxiety than percentage bar
- One-line microcopy - Actionable recommendation
- Two secondary metrics - Sleep hours + streak

### Expanded Sheet (Pro)

```
┌─────────────────────────────────────────┐
│  Recovery Insight                  ✕    │
├─────────────────────────────────────────┤
│         ╭───────────────╮               │
│        ╱       78%       ╲              │
│       │    ╭───────╮     │              │
│       │    │ 6h32m │     │              │
│        ╲   ╰───────╯    ╱               │
│         ╰───────────────╯               │
│   Pronto per allenamento moderato       │
├─────────────────────────────────────────┤
│  QUESTA SETTIMANA                       │
│   L   M   M   G   V   S   D             │
│   ▇   ▇   ▅   ▃   ▇   ▇   ▅             │
│  7.2 7.5 6.1 5.2 7.8 8.1 6.5            │
│   Media: 6.9h  │  Ideale: 7-9h          │
├─────────────────────────────────────────┤
│  📊 CORRELAZIONE SONNO-WORKOUT    [PRO] │
│  ┌─────────────────────────────────┐    │
│  │  Notti >7h     →  Volume +8%   │    │
│  │  Notti <6h     →  Volume -15%  │    │
│  └─────────────────────────────────┘    │
│  💡 Le tue 2 notti sotto 6h questa      │
│     settimana potrebbero influenzare    │
│     la performance. Considera riposo.   │
├─────────────────────────────────────────┤
│  📚 Basato su: AASM, Res et al.         │
└─────────────────────────────────────────┘
```

---

## Architecture

### Data Flow

```
Apple Health / Health Connect
         │
         ▼
┌─────────────────────────┐
│  HealthKitDatasource    │  (existing, extended)
│  - getSleepLastNight()  │
│  - getSleepThisWeek()   │
│  - getSleepAnalytics()  │
└─────────────────────────┘
         │
         ▼
┌─────────────────────────┐
│  SleepWorkoutCorrelation│  (new service)
│  Service                │
│  - calculateRecovery()  │
│  - getCorrelation()     │
│  - getRecommendation()  │
└─────────────────────────┘
         │
         ▼
┌─────────────────────────┐
│  RecoveryInsightProvider│  (new provider)
│  - recoveryScore        │
│  - weeklyTrend          │
│  - correlation          │
└─────────────────────────┘
         │
         ▼
┌─────────────────────────┐
│  RecoveryInsightWidget  │  (new widget)
│  - Card (compact)       │
│  - Sheet (expanded)     │
└─────────────────────────┘
```

### File Structure

```
lib/features/recovery_insight/
├── domain/
│   ├── entities/
│   │   ├── recovery_score.dart
│   │   ├── sleep_data.dart
│   │   └── sleep_workout_correlation.dart
│   └── services/
│       └── sleep_workout_correlation_service.dart
├── data/
│   └── repositories/
│       └── recovery_insight_repository.dart
└── presentation/
    ├── providers/
    │   └── recovery_insight_provider.dart
    └── widgets/
        ├── recovery_insight_card.dart
        ├── recovery_insight_sheet.dart
        └── weekly_sleep_chart.dart
```

---

## Recovery Score Calculation

### Formula

```dart
/// Recovery Score = Base Score × Sleep Modifier
///
/// Base Score (from workout history):
/// - Days since last workout: 0-3 days = good, 4+ = needs workout
/// - Weekly frequency: on track vs behind
/// - Consistency: streak bonus
///
/// Sleep Modifier:
/// - <6h average (3 nights): ×0.70 (critical)
/// - 6-7h average: ×0.85 (suboptimal)
/// - 7-9h average: ×1.00 (optimal)
/// - >9h average: ×0.95 (excessive)
///
/// Consecutive Bad Nights Penalty:
/// - 1 night <6h: no extra penalty
/// - 2 consecutive: additional -5%
/// - 3+ consecutive: additional -10%
```

### Example

```dart
// User: 2 days since workout, good frequency, 3-day streak
// Sleep: 6.5h average, 2 consecutive nights <6h

baseScore = 82  // Good workout pattern
sleepModifier = 0.85  // 6-7h range
consecutivePenalty = 0.95  // 2 consecutive bad nights

finalScore = 82 × 0.85 × 0.95 = 66
category = "moderate"
recommendation = "Pronto per allenamento leggero-moderato"
```

---

## Microcopy Guidelines

### Tone: Supportive, Not Judgmental

```
❌ "Sonno scarso - devi dormire di più"
✅ "Pronto per allenamento moderato"

❌ "Performance compromessa!"
✅ "Potrebbero influenzare la performance"

❌ "Hai dormito male"
✅ "6h 32m - sotto il tuo obiettivo"
```

### Score Categories

| Score | Category | Message (IT) |
|-------|----------|--------------|
| 85-100 | Optimal | "Ottimo recupero! Pronto per allenamento intenso" |
| 70-84 | Good | "Buon recupero. Pronto per allenamento normale" |
| 55-69 | Moderate | "Recupero moderato. Considera allenamento leggero" |
| 40-54 | Low | "Recupero in corso. Prioritizza il riposo oggi" |
| 0-39 | Critical | "Corpo in recupero. Giornata di riposo consigliata" |

---

## Tier Access

### Free Users
- Recovery score (number only)
- Last night sleep hours
- Basic recommendation

### Pro Users
- Full weekly chart
- Sleep-workout correlation analysis
- Personalized insights
- Scientific basis citations

---

## Implementation Phases

### Phase 1: Data Layer (2-3h)
- [x] Add sleep types to HealthKitDatasource
- [ ] Add getSleepLastNight(), getSleepThisWeek()
- [ ] Add getSleepAnalytics() for detailed stats

### Phase 2: Domain Layer (2-3h)
- [ ] Create SleepWorkoutCorrelationService
- [ ] Implement recovery score calculation
- [ ] Implement correlation analysis

### Phase 3: Presentation Layer (3-4h)
- [ ] Create RecoveryInsightProvider
- [ ] Create RecoveryInsightCard widget
- [ ] Create RecoveryInsightSheet widget
- [ ] Create WeeklySleepChart widget

### Phase 4: Integration (1-2h)
- [ ] Add widget to home customization options
- [ ] Connect to existing workout history
- [ ] Test with real HealthKit data

---

## Testing Strategy

### Unit Tests
- SleepWorkoutCorrelationService calculation accuracy
- Recovery score boundary conditions
- Microcopy category selection

### Widget Tests
- Card renders correctly with various states
- Sheet expands/collapses properly
- Pro/Free tier gating works

### Integration Tests
- HealthKit permission flow
- Data refresh on app foreground
- Offline graceful degradation

---

## Success Metrics

1. **Engagement**: Widget tap rate (target: >15%)
2. **Retention**: Users who enable sleep tracking stay longer
3. **Pro Conversion**: Sleep correlation as Pro differentiator
4. **User Satisfaction**: No "anxiety" complaints about scores

---

## References

- [AASM Sleep Recommendations](https://aasm.org/)
- [Res et al. - Sleep and Muscle Protein Synthesis](https://pubmed.ncbi.nlm.nih.gov/)
- [Oura Readiness Score](https://ouraring.com/blog/readiness-score/)
- [WHOOP Sleep Performance](https://www.whoop.com/us/en/thelocker/how-well-whoop-measures-sleep/)
- [UI/UX Trends 2025](https://www.chopdawg.com/ui-ux-design-trends-in-mobile-apps-for-2025/)
