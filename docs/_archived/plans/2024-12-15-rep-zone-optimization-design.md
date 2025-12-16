# Rep Zone Optimization Feature Design

**Date**: 2024-12-15
**Status**: Implemented
**Feature**: Training variety optimization suggestions

---

## Problem Statement

Users often train in repetitive rep ranges without realizing they're missing opportunities for balanced muscle development. The existing Rep Zone metrics in analytics show distribution but don't help users take action.

## Scientific Basis

### Key Research

1. **Schoenfeld et al. (2021)**: Variety in rep ranges optimizes muscular adaptation
   - High reps (15+): Endurance, metabolic stress
   - Medium reps (6-15): Hypertrophy, mechanical tension
   - Low reps (1-5): Strength, neural adaptations

2. **80/20 Training Principle**: If >80% of training is concentrated in one zone, variety is considered low and may limit progress.

3. **Periodization Research**: Studies show 22% faster gains with varied training stimuli.

### Trigger Thresholds

| Condition | Threshold | Action |
|-----------|-----------|--------|
| Dominant zone | >80% | Low variety warning |
| Dominant zone | >90% | Very low variety warning |
| Neglected zone | 0% for 2+ weeks | Zone neglected warning |
| Minimum data | <10 sets | No suggestions (insufficient data) |

---

## Solution: Hybrid Suggestion System

### User Research Insights

- **Swipe UI**: Increases engagement by 43.9% (Apple Watch study)
- **Pull-based suggestions**: Avoids notification fatigue
- **Choice architecture**: Users prefer selecting their interaction mode

### Implementation Approach

**Hybrid Mode Selection**:
1. User taps "Ottimizza Training" CTA button
2. Modal shows two options:
   - **Swipe Mode**: Tinder-style cards for quick decisions
   - **List Mode**: Traditional expandable list for detailed review
3. User chooses preferred interaction style
4. Suggestions are presented with one-tap addition to templates

---

## Architecture

### Domain Layer

```
lib/features/analytics/domain/
├── entities/
│   └── rep_zone_suggestion.dart     # RepZone enum, RepZoneAnalysis, RepZoneSuggestion
└── services/
    └── rep_zone_suggestion_engine.dart  # Analysis and suggestion generation
```

**Key Classes**:
- `RepZone`: Enum (strength, hypertrophy, endurance) with rep ranges
- `RepZoneAnalysis`: Distribution percentages, variety level, neglected zones
- `RepZoneSuggestion`: Exercise recommendation with template targeting

### Presentation Layer

```
lib/features/analytics/presentation/
├── providers/
│   └── rep_zone_suggestion_provider.dart  # Riverpod providers for analysis
├── tabs/
│   └── rep_zone_tab.dart                  # Entry point with CTA
└── widgets/
    ├── rep_zone_optimization_sheet.dart   # Mode selector modal
    ├── rep_zone_suggestion_deck.dart      # Swipe cards (appinio_swiper)
    └── rep_zone_suggestion_list.dart      # Expandable list alternative
```

### Provider Architecture

```dart
// Analysis from exercise history
final repZoneAnalysisProvider = Provider.family<RepZoneAnalysis, List<ExerciseHistory>>();

// Async suggestions with template matching
final repZoneSuggestionsProvider = FutureProvider.family<List<RepZoneSuggestion>, List<ExerciseHistory>>();

// Boolean trigger for CTA visibility
final needsRepZoneOptimizationProvider = Provider.family<bool, List<ExerciseHistory>>();
```

---

## User Flow

```
┌─────────────────┐
│  Rep Zone Tab   │
│  (shows CTA if  │
│  variety < 80%) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Mode Selector  │
│  - Swipe Mode   │
│  - List Mode    │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐ ┌───────┐
│ Swipe │ │ List  │
│ Cards │ │ View  │
└───┬───┘ └───┬───┘
    │         │
    ▼         ▼
┌─────────────────┐
│ Add to Template │
│ (one tap)       │
└─────────────────┘
```

---

## UI Components

### 1. CTA Button (Rep Zone Tab)

- **Trigger**: `analysis.varietyLevel < low` AND `totalSets >= 10`
- **Style**: Error container background, warning icon
- **Text**: "Varietà bassa rilevata" / "Low variety detected"

### 2. Mode Selector Sheet

Shows analysis summary with distribution bars:
- Strength zone % (red if dominant)
- Hypertrophy zone % (red if dominant)
- Endurance zone % (red if dominant)

Two interaction modes:
- **Swipe Mode**: Cards icon, "Scorre veloce attraverso i suggerimenti"
- **List Mode**: List icon, "Espandi per dettagli, aggiungi con un tap"

### 3. Swipe Cards (appinio_swiper)

- Background cards: 2 visible
- Swipe right: Add to template
- Swipe left: Skip
- Accessibility buttons for non-gesture users

Card content:
- Zone badge (color-coded)
- Exercise name
- Target template
- Volume recommendation (sets/reps/rest)
- Reason for suggestion

### 4. List View

- Collapsible cards
- Skip/Add buttons
- Expanded view shows full details
- Maintains scroll position

---

## Localization Keys

New strings added to `app_en.arb` and `app_it.arb`:

| Key | English | Italian |
|-----|---------|---------|
| `optimizeTraining` | Optimize Training | Ottimizza Allenamento |
| `lowVarietyDetected` | Low variety detected | Varietà bassa rilevata |
| `swipeMode` | Swipe Mode | Modalità Swipe |
| `listMode` | List Mode | Modalità Lista |
| `strengthZone` | Strength | Forza |
| `hypertrophyZone` | Hypertrophy | Ipertrofia |
| `enduranceZone` | Endurance | Resistenza |
| `suggestionsAvailable` | {count} suggestions available | {count} suggerimenti disponibili |
| `exerciseAddedToTemplate` | {exercise} added to {template} | {exercise} aggiunto a {template} |

---

## Dependencies

- `appinio_swiper: ^2.1.1` - Tinder-style swipe cards

---

## Future Enhancements

1. **Smart Periodization**: Suggest zone shifts based on training phase
2. **History Tracking**: Remember which suggestions were accepted/skipped
3. **Personalization**: Weight suggestions by user's stated goals
4. **Batch Actions**: Add multiple suggestions at once

---

## Testing Considerations

- Test with varying distribution percentages (50/50, 80/20, 100/0)
- Verify suggestion generation with empty/full exercise databases
- Test swipe gestures on different device sizes
- Accessibility: Ensure button alternatives work

---

## Files Modified/Created

### New Files
- `lib/features/analytics/domain/entities/rep_zone_suggestion.dart`
- `lib/features/analytics/domain/services/rep_zone_suggestion_engine.dart`
- `lib/features/analytics/presentation/providers/rep_zone_suggestion_provider.dart`
- `lib/features/analytics/presentation/widgets/rep_zone_optimization_sheet.dart`
- `lib/features/analytics/presentation/widgets/rep_zone_suggestion_deck.dart`
- `lib/features/analytics/presentation/widgets/rep_zone_suggestion_list.dart`

### Modified Files
- `pubspec.yaml` (added appinio_swiper)
- `lib/features/analytics/presentation/tabs/rep_zone_tab.dart`
- `assets/i18n/app_en.arb`
- `assets/i18n/app_it.arb`
