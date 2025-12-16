# Warmup Suggestions Feature - Design Document

**Data**: 2025-01-06
**Status**: Approved
**Author**: Claude + Michele

---

## Overview

Permettere agli utenti di aggiungere esercizi di warmup direttamente dal modal dettagli esercizio, con un tap sui suggerimenti mostrati.

### User Flow

```
1. Utente nel workout → vede "Squat"
2. Tap su icona info → apre ExerciseDetailsModal
3. Vede sezione "Riscaldamento" con chips cliccabili
4. Tap su [+ Cat-Cow 2×10]
   → Haptic feedback
   → Chip diventa ✓
   → Toast: "Cat-Cow aggiunto prima di Squat"
5. Torna al workout → Cat-Cow è PRIMA di Squat
```

---

## Research Summary

Fonti consultate:
- [UXMatters - Fitness Platform UX 2025](https://www.uxmatters.com/mt/archives/2025/07/designing-a-fitness-platform-ux-design-challenges-and-solutions.php)
- [NN/g - Progressive Disclosure](https://www.nngroup.com/articles/progressive-disclosure/)
- [Stormotion - Fitness App UX](https://stormotion.io/blog/fitness-app-ux/)

### Key Principles Applied

| Principio | Applicazione |
|-----------|--------------|
| **Fewer taps = better** | Aggiungere warmup = 1 tap |
| **Progressive disclosure** | Warmup visibile solo nel modal dettagli |
| **Contextual suggestions** | Suggerimenti specifici per ogni esercizio |
| **Micro-interactions** | Haptic + animazione chip → ✓ |

---

## Data Model

### New: WarmupSuggestion

```dart
/// Represents a warmup exercise suggestion
class WarmupSuggestion {
  final String exerciseId;   // ID in exercise database
  final String exerciseName; // Display name
  final int sets;
  final int reps;
  final WarmupType type;     // mobility | activation

  const WarmupSuggestion({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.type,
  });
}

enum WarmupType { mobility, activation }
```

### Updated: ExerciseDefinition

```dart
@HiveField(24)
final List<WarmupSuggestion>? warmupSuggestions;

// Backward compatibility: keep mobilitaPre/attivazionePre as fallback display
```

### Updated: Workout

```dart
/// Insert exercise at specific position
Workout insertExerciseAt(int index, Exercise exercise) {
  final newExercises = List<Exercise>.from(exercises);
  newExercises.insert(index, exercise);
  return copyWith(
    exercises: newExercises,
    updatedAt: DateTime.now(),
  );
}
```

---

## JSON Structure

### New Warmup Exercises to Create

```json
[
  {
    "id": "cat-cow",
    "nome": "Cat-Cow",
    "focus": "CORE",
    "difficolta": "Principiante",
    "tipoEsercizio": "Mobilità",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Spine Flexion/Extension",
    "rangeRipetizioni": "8-12",
    "isWarmup": true
  },
  {
    "id": "bird-dog",
    "nome": "Bird Dog",
    "focus": "CORE",
    "difficolta": "Principiante",
    "tipoEsercizio": "Stabilità",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Anti-Rotation",
    "rangeRipetizioni": "8-10",
    "isWarmup": true
  },
  {
    "id": "glute-bridge",
    "nome": "Ponte Glutei",
    "focus": "GLUT",
    "difficolta": "Principiante",
    "tipoEsercizio": "Attivazione",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Hip Extension",
    "rangeRipetizioni": "12-15",
    "isWarmup": true
  },
  {
    "id": "clamshell",
    "nome": "Clamshell",
    "focus": "GLUT",
    "difficolta": "Principiante",
    "tipoEsercizio": "Attivazione",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Hip Abduction",
    "rangeRipetizioni": "12-15",
    "isWarmup": true
  },
  {
    "id": "fire-hydrant",
    "nome": "Fire Hydrant",
    "focus": "GLUT",
    "difficolta": "Principiante",
    "tipoEsercizio": "Attivazione",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Hip Abduction",
    "rangeRipetizioni": "10-12",
    "isWarmup": true
  },
  {
    "id": "hip-circles",
    "nome": "Hip Circles",
    "focus": "ANCA",
    "difficolta": "Principiante",
    "tipoEsercizio": "Mobilità",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Hip Rotation",
    "rangeRipetizioni": "10-12",
    "isWarmup": true
  },
  {
    "id": "torso-rotations",
    "nome": "Rotazioni Torso",
    "focus": "CORE",
    "difficolta": "Principiante",
    "tipoEsercizio": "Mobilità",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Spine Rotation",
    "rangeRipetizioni": "10-12",
    "isWarmup": true
  },
  {
    "id": "arm-circles",
    "nome": "Cerchi con le Braccia",
    "focus": "SPALLE",
    "difficolta": "Principiante",
    "tipoEsercizio": "Mobilità",
    "attrezzatura": "Corpo Libero",
    "patternMovimento": "Shoulder Rotation",
    "rangeRipetizioni": "10-15",
    "isWarmup": true
  }
]
```

### Example: Squat with warmupSuggestions

```json
{
  "id": "squat-bilanciere",
  "nome": "Squat con Bilanciere",
  "warmupSuggestions": [
    {"exerciseId": "hip-circles", "sets": 2, "reps": 10, "type": "mobility"},
    {"exerciseId": "glute-bridge", "sets": 2, "reps": 12, "type": "activation"},
    {"exerciseId": "fire-hydrant", "sets": 2, "reps": 10, "type": "activation"}
  ],
  "mobilitaPre": "Hip circles 2x10, glute bridges 2x12, fire hydrants 2x10"
}
```

---

## UI Design

### ExerciseDetailsModal - Warmup Section

```
┌─────────────────────────────────────────┐
│ ☀️ Riscaldamento Consigliato      ⓘ    │
├─────────────────────────────────────────┤
│                                         │
│ 🔄 Mobilità                             │
│ ┌─────────────┐ ┌─────────────────────┐ │
│ │ + Hip       │ │ + Rotazioni Torso   │ │
│ │   Circles   │ │   2×12              │ │
│ │   2×10      │ │                     │ │
│ └─────────────┘ └─────────────────────┘ │
│                                         │
│ ⚡ Attivazione                          │
│ ┌─────────────┐ ┌─────────────────────┐ │
│ │ + Ponte     │ │ + Fire Hydrant      │ │
│ │   Glutei    │ │   2×10              │ │
│ │   2×12      │ │                     │ │
│ └─────────────┘ └─────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

### Chip States

| State | Appearance |
|-------|------------|
| Default | `+ Nome 2×10` - primary border, surface background |
| Hover/Press | Ripple effect, slight scale |
| Added | `✓ Nome` - success color, disabled |
| Loading | Circular progress indicator |

### Micro-interactions

- **Tap**: Light haptic + ripple
- **Added**: Chip animates to ✓ (200ms ease-out)
- **Toast**: Slide-in from bottom, auto-dismiss 2s

---

## Component Architecture

```
ExerciseDetailsModal
├── _buildWarmupSection()
│   ├── _WarmupSuggestionChips (NEW)
│   │   └── _WarmupChip (NEW)
│   └── _buildWarmupPhase() (existing - fallback for text)
└── onWarmupExerciseAdded callback → WorkoutProvider
```

### New Widgets

```dart
/// Displays warmup suggestion chips
class _WarmupSuggestionChips extends StatelessWidget {
  final List<WarmupSuggestion> suggestions;
  final Set<String> addedExerciseIds;
  final Function(WarmupSuggestion) onAdd;
}

/// Single warmup chip with add functionality
class _WarmupChip extends StatelessWidget {
  final WarmupSuggestion suggestion;
  final bool isAdded;
  final VoidCallback onTap;
}
```

---

## Implementation Checklist

- [ ] Create `WarmupSuggestion` model
- [ ] Add `warmupSuggestions` field to `ExerciseDefinition`
- [ ] Regenerate Hive adapters
- [ ] Add `insertExerciseAt` to `Workout` entity
- [ ] Add new warmup exercises to JSON (8 exercises)
- [ ] Update existing exercises with `warmupSuggestions`
- [ ] Create `_WarmupSuggestionChips` widget
- [ ] Update `ExerciseDetailsModal` to use chips
- [ ] Add callback to insert exercise in workout
- [ ] Add haptic feedback and animations
- [ ] Add toast confirmation
- [ ] Test on iOS and Android

---

## Migration Strategy

1. **Backward compatible**: Keep `mobilitaPre`/`attivazionePre` as fallback
2. **Progressive**: If `warmupSuggestions` exists, show chips; else show text
3. **No breaking changes**: Old JSON format still works

---

## Future Enhancements (Out of Scope)

- AI-generated warmup suggestions based on user history
- Custom warmup routines saved by user
- Integration with wearables for dynamic warmup duration
