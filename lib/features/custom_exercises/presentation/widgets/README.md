# Custom Exercise Widgets

Reusable presentation components for custom exercise creation and management.

## Components

### 1. CustomExerciseFormSheet

Main form for creating/editing custom exercises with progressive disclosure pattern.

**Location**: `custom_exercise_form_sheet.dart`

**Features**:
- ✅ Progressive disclosure (starts minimal, expands on demand)
- ✅ Pre-filled from base exercise when creating variant
- ✅ Name field required, rest optional/inherited
- ✅ Inline warning when modifying categorization
- ✅ Full validation and error handling
- ✅ Dark/light theme support
- ✅ Localized (EN/IT)

**Usage**:
```dart
// Create new custom exercise
final result = await CustomExerciseFormSheet.show(
  context,
  onSave: (exercise) {
    // Save to repository
  },
);

// Create variant from base exercise
final result = await CustomExerciseFormSheet.show(
  context,
  baseExercise: selectedExercise,
  onSave: (exercise) {
    // Save variant
  },
);

// Edit existing custom exercise
final result = await CustomExerciseFormSheet.show(
  context,
  existingCustom: customExercise,
  onSave: (exercise) {
    // Update in repository
  },
);
```

**Form Fields**:
- **Name** (required): Text field, auto-focused, max 100 chars
- **Base Exercise Info**: Read-only display when creating variant
- **Primary Muscles**: Multi-select chip selector
- **Secondary Muscles**: Expandable multi-select (inherited by default)
- **Exercise Type**: Segmented button (Compound/Isolation)
- **Movement Pattern**: SegmentedButton (Push/Pull/Hinge/Squat/Accessory)
- **Equipment**: Expandable dropdown (inherited by default)

**Validation**:
- Name cannot be empty
- At least one primary muscle must be selected
- Movement pattern must be selected

**Warnings**:
- Shows inline warning when modifying focus/pattern from base exercise
- Warns when exceeding recommended muscle count (3+)

---

### 2. MuscleChipSelector

Multi-select FilterChips for muscle group selection.

**Location**: `muscle_chip_selector.dart`

**Features**:
- ✅ Italian muscle abbreviations with full name tooltips
- ✅ Multi-select with checkmarks
- ✅ Warning when exceeding recommended count
- ✅ Compact wrapping layout

**Usage**:
```dart
MuscleChipSelector(
  selectedMuscles: _focus,
  onSelectionChanged: (muscles) {
    setState(() => _focus = muscles);
  },
  label: 'Focus Principale',
  maxRecommended: 3,
)
```

**Muscle Abbreviations**:
- PETT - Pettorali
- DELT ANT/LAT/POST - Deltoidi
- TRIC/BIC - Tricipiti/Bicipiti
- LAT - Dorsali
- TRAP - Trapezio
- QUAD/FEMOR/GLUT - Gambe
- POLP - Polpacci
- ADDOM/CORE - Core

---

### 3. PatternSelector

Single-select SegmentedButton for movement pattern selection.

**Location**: `pattern_selector.dart`

**Features**:
- ✅ Icon + label for each pattern
- ✅ Compact segmented button style
- ✅ Optional helper text
- ✅ Empty selection allowed

**Usage**:
```dart
PatternSelector(
  selectedPattern: _pattern,
  onPatternChanged: (pattern) {
    setState(() => _pattern = pattern);
  },
  label: 'Pattern Movimento',
  helperText: 'Seleziona il pattern principale',
)
```

**Movement Patterns**:
- Push (↑ icon)
- Pull (↓ icon)
- Hinge (⇅ icon)
- Squat (♿ icon)
- Accessory (🏋️ icon)

---

## Design System Compliance

All widgets follow project guidelines:

### Icons
✅ Uses `AppIcons.*` constants (not `Icons.*`)

### Localization
✅ Uses `context.l10n.*` for all strings (not hardcoded)

### Colors
✅ Uses `context.colors.*` (not `Colors.*`)

### Theme Support
✅ Tested in both light and dark modes

### Loading States
✅ Uses `LoadingIndicator()` if needed

### Snackbars
✅ Uses `SnackBarService.*` for feedback

---

## Integration Points

### Repositories
- Save/update via `CustomExerciseRepository`
- Query base exercises via `ExerciseRepository`

### Providers
- Premium status check via `PremiumProvider`
- User ID via `AuthProvider`

### Navigation
- Called from exercise selector modals
- Called from workout customization screens
- Returns `CustomExercise?` result

---

## Localization Keys

All required keys added to:
- `/assets/i18n/app_en.arb`
- `/assets/i18n/app_it.arb`

**New Keys**:
- `createVariant` - Create Variant title
- `editCustomExercise` - Edit title
- `basedOn` - Base exercise label
- `categorization` - Section title
- `primaryMuscles` - Primary muscles label
- `secondaryMuscles` - Secondary muscles label
- `exerciseType` - Type field label
- `compound` - Compound type
- `isolation` - Isolation type
- `movementPattern` - Pattern field label
- `equipment` - Equipment field label
- `categorizationWarning` - Warning text
- `exerciseNameRequired` - Validation error
- `barbell/dumbbells/cables/machine/bodyweight` - Equipment types

---

## File Structure

```
lib/features/custom_exercises/presentation/widgets/
├── custom_exercise_form_sheet.dart  (619 lines)
├── muscle_chip_selector.dart        (118 lines)
├── pattern_selector.dart            (99 lines)
└── README.md                         (this file)
```

---

## Testing

**Widget Tests**: TODO - Add comprehensive widget tests
**Integration Tests**: TODO - Add E2E flow tests

**Manual Testing**:
1. Create pure custom exercise
2. Create variant from base exercise
3. Edit existing custom exercise
4. Verify validation works
5. Test in both themes
6. Test in both locales

---

## Next Steps

1. ✅ CustomExerciseFormSheet implementation
2. ⏳ CustomExerciseListScreen (list management)
3. ⏳ CustomExerciseRepository (data persistence)
4. ⏳ Integration with workout flow
5. ⏳ Premium gating logic
6. ⏳ Cloud sync for Premium users

---

Generated: 2025-12-14
