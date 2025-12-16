# Two-Level Notes System Design

**Date**: 2025-12-13
**Status**: Implementation
**Feature**: Form Cues + Session Notes

---

## Overview

Implement a 2-level notes system following industry best practices from apps like Hevy, FitNotes, and Setgraph:

1. **Form Cues** (Persistent) - Technique reminders that appear every time you do an exercise
2. **Session Notes** (Per-workout) - Observations saved in workout history

---

## Data Model

### New Entity: UserExercisePreferences

```dart
// lib/features/workout/data/models/user_exercise_preferences.dart
@HiveType(typeId: 70)
class UserExercisePreferences extends HiveObject {
  @HiveField(0)
  String visibleId;  // normalized name or exerciseId

  @HiveField(1)
  String exerciseName;  // for display

  @HiveField(2)
  String? formCues;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  bool needsSync;  // flag for premium Firebase sync

  // Key generation: use exerciseId if available, else normalized name
  static String generateKey(String? exerciseId, String exerciseName) {
    return exerciseId ?? _normalizeExerciseName(exerciseName);
  }

  static String _normalizeExerciseName(String name) {
    return name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');
  }
}
```

### ExerciseActivity Modification

Add sessionNotes field to capture workout-specific notes:

```dart
// lib/features/workout/domain/entities/exercise_activity.dart
class ExerciseActivity {
  // ... existing fields ...

  final String? sessionNotes;  // NEW: copied from Exercise.notes on completion
}
```

### Storage Pattern

| User Type | Form Cues | Session Notes |
|-----------|-----------|---------------|
| Free | Hive only | In ExerciseActivity (Firestore) |
| Premium | Hive + Firebase sync | In ExerciseActivity (Firestore) |

---

## UI/UX Design

### Enhanced Notes Modal

Single modal with two visually distinct sections:

```
┌─────────────────────────────────────────┐
│               📝 Notes                  │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ 📌 FORM CUES                        │ │
│ │ ─────────────────────────────────── │ │
│ │ [TextField with 3 lines]            │ │
│ │ "Keep elbows tucked..."             │ │
│ │                                     │ │
│ │ 💡 Appears every time you do this   │ │
│ │    exercise                         │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📋 SESSION NOTES                    │ │
│ │ ─────────────────────────────────── │ │
│ │ [TextField with 3 lines]            │ │
│ │ "Felt strong today..."              │ │
│ │                                     │ │
│ │ 💡 Saved in your workout history    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│              [Cancel]  [Save]           │
└─────────────────────────────────────────┘
```

### Visual Hierarchy

**Form Cues (Prominent)**:
```dart
Container(
  decoration: BoxDecoration(
    color: context.colors.primaryContainer.withValues(alpha: 0.3),
    border: Border.all(
      color: context.colors.primary.withValues(alpha: 0.5),
      width: 2,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
)
```

**Session Notes (Subtle)**:
```dart
Container(
  decoration: BoxDecoration(
    color: context.colors.surfaceContainerLowest,
    border: Border.all(
      color: context.colors.outline.withValues(alpha: 0.2),
    ),
    borderRadius: BorderRadius.circular(12),
  ),
)
```

---

## History Integration

### Exercise History Bottom Sheet

```
┌─────────────────────────────────────────┐
│          Bench Press History            │
├─────────────────────────────────────────┤
│ 📌 Keep elbows at 45°, touch chest      │  ← Form Cues (always visible)
├─────────────────────────────────────────┤
│ 📅 Dec 10, 2025 - Push Day              │
│    3x10 @ 80kg  📋                      │  ← Icon indicates session notes
│    "Felt strong, bumped weight"         │  ← Inline session note
│                                         │
│ 📅 Dec 7, 2025 - Upper Body             │
│    3x8 @ 77.5kg                         │  ← No session notes
│                                         │
│ 📅 Dec 3, 2025 - Push Day               │
│    4x8 @ 75kg  📋                       │
│    "Shoulder twinge, careful next time" │
└─────────────────────────────────────────┘
```

### Analytics Detail Screen

```
┌─────────────────────────────────────────┐
│          📊 Bench Press                 │
├─────────────────────────────────────────┤
│ [Progress Chart]                        │
│                                         │
├─────────────────────────────────────────┤
│ 📌 FORM CUES                            │
│ ─────────────────────────────────────── │
│ Keep elbows at 45°, touch chest lightly │
│                                         │
├─────────────────────────────────────────┤
│ 📝 RECENT NOTES                         │
│ ─────────────────────────────────────── │
│ ▼ Dec 10: "Felt strong, bumped weight"  │
│ ▼ Dec 3: "Shoulder twinge, careful..."  │
│ [See all notes →]                       │
└─────────────────────────────────────────┘
```

---

## Implementation Tasks

### Task A: Data Layer
- Create `UserExercisePreferences` entity with Hive adapter
- Create `UserExercisePreferencesRepository`
- Register Hive adapter in main.dart
- Add Riverpod provider for preferences

### Task B: ExerciseActivity Modification
- Add `sessionNotes` field to `ExerciseActivity`
- Update `fromExercise` factory to copy notes
- Update `toFirestore` and `fromFirestore` methods
- Update repository methods

### Task C: Enhanced Notes Modal
- Redesign `ExerciseNotesHandler.showNotesDialog`
- Add two-section layout with visual hierarchy
- Load/save Form Cues from UserExercisePreferences
- Keep Session Notes bound to Exercise.notes

### Task D: History Bottom Sheet Integration
- Show Form Cues in header section
- Display session notes inline in history entries
- Add 📋 indicator for entries with notes

### Task E: Analytics Detail Screen
- Add Form Cues section under chart
- Add expandable recent session notes
- Link to full notes history

### Task F: Firebase Sync (Premium)
- Add Firestore collection `userExercisePreferences`
- Sync on Form Cues save for premium users
- Handle needsSync flag for offline changes

---

## Localization Keys

```json
{
  "formCues": "Form Cues",
  "formCuesHint": "Keep elbows tucked, touch chest...",
  "formCuesHelper": "Appears every time you do this exercise",
  "sessionNotes": "Session Notes",
  "sessionNotesHint": "How did this feel today?",
  "sessionNotesHelper": "Saved in your workout history",
  "recentNotes": "Recent Notes",
  "seeAllNotes": "See all notes"
}
```

---

## Files to Create/Modify

### New Files
- `lib/features/workout/data/models/user_exercise_preferences.dart`
- `lib/features/workout/data/models/user_exercise_preferences.g.dart` (generated)
- `lib/features/workout/data/repositories/user_exercise_preferences_repository.dart`
- `lib/features/workout/presentation/providers/user_exercise_preferences_provider.dart`

### Modified Files
- `lib/features/workout/domain/entities/exercise_activity.dart`
- `lib/features/workout/presentation/widgets/exercise_list_item/utils/exercise_notes_handler.dart`
- `lib/features/workout/presentation/widgets/exercise_history_bottom_sheet.dart`
- `lib/features/analytics/presentation/screens/exercise_detail_screen.dart`
- `lib/main.dart` (Hive adapter registration)
- `assets/i18n/app_en.arb`
- `assets/i18n/app_it.arb`
