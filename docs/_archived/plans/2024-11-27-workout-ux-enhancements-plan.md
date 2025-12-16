# Workout UX Enhancements - Design Plan

**Generated**: 2024-11-27 16:30
**Source**: Brainstorming session with research
**Complexity Score**: HIGH
**Total Features**: 3
**Estimated Time**: ~12-16h total

---

## 1. Original Request

> Implementare 3 feature UX per migliorare l'esperienza workout:
> 1. Pre-fill last workout data per TUTTI i tipi di esercizio
> 2. Progress arrows per mostrare miglioramento/peggioramento in OGNI riga set
> 3. Template saving per esercizi avanzati con limite freemium (Max 3 per free users)

---

## 2. Research Findings

### 2.1 Pre-fill Best Practices
- **Opt-in approach** (not auto-fill) prevents confusion about whether data is old or new target
- **Button/badge click** to apply last workout data
- **Show context**: weight, reps, RPE, date of last session
- **Apps reference**: Hevy, Strong, JEFIT

### 2.2 Progress Indicators Best Practices
- **Color-coded arrows**: Green = improvement, Red = regression
- **Real-time feedback** during workout
- **Comparison basis**: Same exercise, same set number, last completed workout
- **Keep it simple**: Single indicator per row, not cluttered

### 2.3 Freemium Templates Best Practices
- **Value staging**: Give enough free to hook, limit to create upgrade desire
- **Smart limits**: 3 templates is enough to try feature, not enough for power users
- **Clear upsell**: Show what they're missing without being annoying
- **Easy conversion path**: One-tap upgrade from limit screen

---

## 3. Feature Specifications

### Feature 1: Pre-fill Last Workout Data

#### 3.1.1 Overview
Add a "Last Workout" badge in QuickEditOverlayV2 that allows users to quickly pre-populate weight and reps from their most recent completed workout for the same exercise.

#### 3.1.2 UI Design

```
┌──────────────────────────────────────────────────────────┐
│ 🏋️ Bench Press - Set 2                         [Copy]   │
│                                                          │
│ ┌──────────────────────────────────────────────────────┐│
│ │ ⚡ LAST: 80kg × 10 (RPE 8) - 3 days ago      [Use]  ││  ← NEW
│ └──────────────────────────────────────────────────────┘│
│                                                          │
│    [Weight Picker]         [Reps Picker]                │
│         80 kg                 10 ×                      │
│                                                          │
│ 📜 Recent: [77.5] [80] [82.5] [85]                      │
│                                                          │
│    [Cancel]                    [Save]                   │
└──────────────────────────────────────────────────────────┘
```

#### 3.1.3 Data Model

```dart
/// Provider to get last completed workout data for an exercise
final lastCompletedWorkoutSetProvider = FutureProvider.family
    .autoDispose<LastWorkoutSetData?, LastWorkoutSetParams>((ref, params) async {
  // params: exerciseName, setNumber
  // Returns: weight, reps, rpe, date from last completed workout
});

class LastWorkoutSetData {
  final double weight;
  final int reps;
  final int? rpe;
  final DateTime date;
  final String workoutName; // e.g., "Push Day"
}

class LastWorkoutSetParams {
  final String exerciseName;
  final int setNumber;
}
```

#### 3.1.4 Implementation Tasks

| Task | Layer | Est. Time | Files |
|------|-------|-----------|-------|
| Create `LastWorkoutSetData` model | Domain | 15 min | `lib/features/workout/domain/entities/last_workout_set_data.dart` |
| Create `lastCompletedWorkoutSetProvider` | Presentation | 45 min | `lib/features/workout/presentation/providers/exercise_history_provider.dart` |
| Add service method to query last workout | Data | 30 min | `lib/features/workout/data/services/exercise_history_service.dart` |
| Add "Last Workout" badge to QuickEditOverlayV2 | Presentation | 1h | `lib/features/workout/presentation/widgets/quick_edit_overlay_v2.dart` |
| Add localization strings | Shared | 15 min | `assets/i18n/app_en.arb`, `app_it.arb` |
| Unit tests for provider | Test | 30 min | `test/features/workout/presentation/providers/` |

**Total: ~3h**

#### 3.1.5 Applicability

| Exercise Type | Support | Notes |
|---------------|---------|-------|
| Single | ✅ Full | Each set row |
| Superset | ✅ Full | Each exercise in round |
| Dropset | ✅ Partial | First stage only |
| Rest-Pause | ✅ Partial | Initial set only |

---

### Feature 2: Progress Arrows

#### 3.2.1 Overview
Display inline progress indicators in each set row showing whether the user is improving or regressing compared to their last workout.

#### 3.2.2 UI Design

```
┌─────────────────────────────────────────────────────────┐
│  Bench Press                                            │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Set 1   80kg × 10   ↗️ +2.5kg    ✅              │   │
│  │ Set 2   80kg × 12   ↗️ +2 reps   ✅              │   │
│  │ Set 3   77.5kg × 8  ↘️ -2.5kg    ⬜              │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

#### 3.2.3 Progress Logic

```dart
enum ProgressDirection { improved, same, regressed }

class SetProgressData {
  final ProgressDirection direction;
  final String label; // e.g., "+2.5kg", "-2 reps", "="
  final double? weightDiff;
  final int? repsDiff;
}

SetProgressData calculateProgress(ExerciseSet current, ExerciseSet? last) {
  if (last == null) return SetProgressData(direction: same, label: "New");

  final weightDiff = (current.weight ?? 0) - (last.weight ?? 0);
  final repsDiff = (current.reps ?? 0) - (last.reps ?? 0);

  // Priority: weight change > reps change
  if (weightDiff > 0) {
    return SetProgressData(
      direction: improved,
      label: "+${weightDiff.toStringAsFixed(1)}kg",
      weightDiff: weightDiff,
    );
  } else if (weightDiff < 0) {
    return SetProgressData(
      direction: regressed,
      label: "${weightDiff.toStringAsFixed(1)}kg",
      weightDiff: weightDiff,
    );
  } else if (repsDiff > 0) {
    return SetProgressData(
      direction: improved,
      label: "+$repsDiff reps",
      repsDiff: repsDiff,
    );
  } else if (repsDiff < 0) {
    return SetProgressData(
      direction: regressed,
      label: "$repsDiff reps",
      repsDiff: repsDiff,
    );
  }

  return SetProgressData(direction: same, label: "=");
}
```

#### 3.2.4 Visual Design

| Direction | Icon | Color | Example |
|-----------|------|-------|---------|
| Improved | `↗️` or `Icons.trending_up` | `context.colors.success` (green) | "+2.5kg" |
| Same | `→` or `Icons.remove` | `context.colors.outline` (grey) | "=" |
| Regressed | `↘️` or `Icons.trending_down` | `context.colors.error` (red) | "-2.5kg" |

#### 3.2.5 Implementation Tasks

| Task | Layer | Est. Time | Files |
|------|-------|-----------|-------|
| Create `SetProgressData` model | Domain | 15 min | `lib/features/workout/domain/entities/set_progress_data.dart` |
| Create `calculateProgress` utility | Domain | 30 min | `lib/features/workout/domain/services/progress_calculator_service.dart` |
| Create `lastWorkoutSetsProvider` | Presentation | 45 min | `lib/features/workout/presentation/providers/exercise_history_provider.dart` |
| Create `ProgressArrowWidget` | Presentation | 45 min | `lib/features/workout/presentation/widgets/progress_arrow_widget.dart` |
| Integrate into `ExerciseSetRow` | Presentation | 1h | `lib/features/workout/presentation/widgets/exercise_list_item/` |
| Add to Superset/Dropset/RestPause | Presentation | 1h | Multiple files |
| Localization strings | Shared | 15 min | `assets/i18n/*.arb` |
| Unit tests | Test | 30 min | `test/` |

**Total: ~5h**

#### 3.2.6 Applicability

| Exercise Type | Support | Comparison Basis |
|---------------|---------|------------------|
| Single | ✅ Full | Same set number |
| Superset | ✅ Full | Same exercise, same round |
| Dropset | ✅ Partial | Same stage number |
| Rest-Pause | ✅ Partial | Same mini-set index |

---

### Feature 3: Advanced Exercise Templates (Freemium)

#### 3.3.1 Overview
Allow users to save superset, dropset, and rest-pause configurations as reusable templates. Free users are limited to 3 total templates.

#### 3.3.2 UI Design - Template List

```
┌─────────────────────────────────────────────────────────┐
│  🔄 My Advanced Templates                    [+ New]    │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │ 💪 Push Superset                           [Use]  │ │
│  │    Bench Press + Incline DB Press                 │ │
│  │    4 rounds × 10 reps • Rest: 90s                 │ │
│  │    Last used: 2 days ago                          │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │ 🔥 Biceps Dropset                          [Use]  │ │
│  │    Barbell Curl: 30→25→20→15kg                    │ │
│  │    To failure each stage                          │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │ ⏸️ Chest Rest-Pause                        [Use]  │ │
│  │    Dumbbell Fly: 15kg × 3 mini-sets              │ │
│  │    15s rest between                               │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ╔═══════════════════════════════════════════════════╗ │
│  ║  🔒 You've used 3/3 free template slots          ║ │
│  ║     Upgrade to Premium for unlimited templates   ║ │
│  ║                                                   ║ │
│  ║     [See Premium]        [Maybe Later]           ║ │
│  ╚═══════════════════════════════════════════════════╝ │
└─────────────────────────────────────────────────────────┘
```

#### 3.3.3 Data Model

```dart
@freezed
class AdvancedExerciseTemplate with _$AdvancedExerciseTemplate {
  const factory AdvancedExerciseTemplate({
    required String id,
    required String userId,
    required String name,
    required AdvancedExerciseType type, // superset, dropset, restPause
    required Map<String, dynamic> configuration,
    required DateTime createdAt,
    DateTime? lastUsedAt,
    @Default(0) int usageCount,
  }) = _AdvancedExerciseTemplate;
}

enum AdvancedExerciseType { superset, dropset, restPause }

// Configuration examples:
// Superset: { exercises: [...], rounds: 4, restTime: 90 }
// Dropset: { exerciseId: "...", stages: [...] }
// RestPause: { exerciseId: "...", weight: 15, miniSets: 3, restSeconds: 15 }
```

#### 3.3.4 Freemium Logic

```dart
const kFreeTemplateLimit = 3;

class AdvancedTemplateService {
  Future<bool> canCreateTemplate(String userId) async {
    final isPremium = await _premiumService.isPremium(userId);
    if (isPremium) return true;

    final templateCount = await _repository.getTemplateCount(userId);
    return templateCount < kFreeTemplateLimit;
  }

  Future<TemplateCreationResult> createTemplate(
    String userId,
    AdvancedExerciseTemplate template,
  ) async {
    if (!await canCreateTemplate(userId)) {
      return TemplateCreationResult.limitReached(
        current: kFreeTemplateLimit,
        limit: kFreeTemplateLimit,
      );
    }

    await _repository.save(template);
    return TemplateCreationResult.success(template);
  }
}
```

#### 3.3.5 UX Flows

**Save Template Flow:**
```
1. User completes superset/dropset/rest-pause execution
2. Show toast: "💾 Save as template?"
3. User taps → Name input dialog
4. Check limit → Save OR show upgrade prompt
5. Success toast: "Template saved!"
```

**Use Template Flow:**
```
1. User taps "Add Advanced Exercise"
2. Tab bar: [Create New] [My Templates]
3. User selects "My Templates" tab
4. Shows list of saved templates
5. Tap template → Added to workout
```

**Upgrade Prompt Flow:**
```
1. User tries to save 4th template (free user)
2. Show modal: "You've reached the free limit!"
3. Options: [See Premium] [Continue Free]
4. Premium button → Navigate to premium screen
```

#### 3.3.6 Implementation Tasks

| Task | Layer | Est. Time | Files |
|------|-------|-----------|-------|
| Create `AdvancedExerciseTemplate` entity | Domain | 30 min | `lib/features/workout_templates/domain/entities/advanced_exercise_template.dart` |
| Create repository interface | Domain | 15 min | `lib/features/workout_templates/domain/repositories/` |
| Implement Firestore repository | Data | 1h | `lib/features/workout_templates/data/repositories/` |
| Create `AdvancedTemplateService` | Domain | 45 min | `lib/features/workout_templates/domain/services/` |
| Create `advancedTemplatesProvider` | Presentation | 30 min | `lib/features/workout_templates/presentation/providers/` |
| Create `AdvancedTemplateListWidget` | Presentation | 1h | `lib/features/workout_templates/presentation/widgets/` |
| Create `SaveTemplateDialog` | Presentation | 45 min | `lib/features/workout_templates/presentation/widgets/` |
| Create `TemplateLimitReachedModal` | Presentation | 30 min | `lib/features/workout_templates/presentation/widgets/` |
| Integrate into "Add Exercise" flow | Presentation | 1h | Multiple files |
| Add "Save as Template" after execution | Presentation | 45 min | Superset/Dropset/RestPause sheets |
| Localization strings | Shared | 20 min | `assets/i18n/*.arb` |
| Unit tests | Test | 1h | `test/` |
| Integration tests | Test | 45 min | `integration_test/` |

**Total: ~9h**

---

## 4. Implementation Priority

### Phase 1: Foundation (Week 1)
1. ✅ Fix existing "Recent Weights" not showing (bug fix)
2. Feature 1: Pre-fill Last Workout (~3h)
3. Feature 2: Progress Arrows (~5h)

### Phase 2: Advanced (Week 2)
4. Feature 3: Advanced Templates (~9h)

---

## 5. Dependencies

```
Feature 1 (Pre-fill) ──────┐
                           ├──► Feature 2 (Progress Arrows)
exerciseHistoryProvider ───┘    └──► Uses same data source

Feature 3 (Templates) ──► Independent, can be developed in parallel
                          └──► Requires premium service integration
```

---

## 6. Testing Checklist

### 6.1 Pre-fill Feature
- [ ] Shows badge when history exists
- [ ] Hides badge when no history
- [ ] Correctly fetches last workout data
- [ ] Works for all exercise types
- [ ] Handles exercises with name variations

### 6.2 Progress Arrows
- [ ] Green arrow for weight increase
- [ ] Green arrow for reps increase (same weight)
- [ ] Red arrow for regression
- [ ] Grey for same values
- [ ] "New" label when no history
- [ ] Works in all exercise types

### 6.3 Templates
- [ ] Free user can create 3 templates
- [ ] 4th template shows limit modal
- [ ] Premium user has no limit
- [ ] Templates persist across sessions
- [ ] Templates can be edited/deleted
- [ ] Usage tracking works

---

## 7. Localization Keys

```json
// app_en.arb
"lastWorkout": "Last workout",
"useLastValues": "Use",
"daysAgo": "{count} days ago",
"improved": "Improved",
"regressed": "Regressed",
"sameAsLast": "Same",
"myTemplates": "My Templates",
"saveAsTemplate": "Save as template",
"templateSaved": "Template saved!",
"templateLimitReached": "Template limit reached",
"upgradeForMoreTemplates": "Upgrade to Premium for unlimited templates",
"templateSlots": "{used}/{total} template slots"
```

---

## 8. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Exercise name mismatch | Medium | High | Fuzzy matching, normalization |
| Performance with large history | Low | Medium | Limit queries, caching |
| Premium detection issues | Low | High | Robust fallback to free limits |
| Complex template serialization | Medium | Medium | Thorough testing, versioned schema |

---

## 9. Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Pre-fill usage rate | >50% of sets | Analytics event |
| Progress arrow engagement | >70% notice it | User survey |
| Template creation rate | >30% of active users | Firestore count |
| Premium conversion from limit | >5% | Analytics funnel |

---

**Plan Version**: 1.0
**Last Updated**: 2024-11-27
