# Template List Redesign - "Lista Verticale Moderna"

**Date**: 2025-01-08
**Status**: Design Complete ✅
**Priority**: B (User Experience Enhancement)

## Overview

Redesign "Le Mie Schede" template list screen from 2×2 grid to vertical list with rich information cards, glass morphism design, smooth animations powered by motor 1.0.1, and swipe-to-reveal actions.

## Problem Statement

Current template list has several UX issues:
- **Monotonous design**: Uniform blue cards, no visual hierarchy
- **Limited information**: Only shows name, exercise count, duration
- **Inefficient layout**: 2×2 grid wastes vertical space
- **Generic naming**: "Giorno A/B/C/D" not descriptive
- **No quick actions**: Must navigate to edit/delete

## Design Goals

### Primary Goals
- ✅ Vertical list layout (one card per row, not 2×2 grid)
- ✅ Rich information display (difficulty, muscle groups, last performed, exercise preview)
- ✅ Category-based gradient colors (strength=red, cardio=blue, flexibility=green, hybrid=purple)
- ✅ Glass morphism design with backdrop blur
- ✅ Smooth animations with motor 1.0.1 package
- ✅ Swipe-to-reveal quick actions (share, duplicate, edit, delete)

### User Requirements (Validated)
- ✅ **Auto-detect** difficulty/duration/muscle groups from exercises (with manual override)
- ✅ **Descriptive names** instead of "Giorno A/B/C/D"
- ✅ **No icons in exercise preview** (clean text: "Panca · Croci · Dips +3")
- ✅ **Keep metadata icons** (⏱️ duration, 🕐 last performed)
- ✅ **No volume in template card** (volume only in post-workout rest mode)

---

## Architecture

### 1. Widget Hierarchy

```
WorkoutTemplateListScreen
├─ AppBar ("Le Mie Schede")
├─ TabBarView
│  ├─ CustomTemplatesTab
│  │  └─ ListView.builder (itemExtent: 200.0)
│  │     └─ SwipeableTemplateCard (Dismissible wrapper)
│  │        └─ TemplateCard (glass design + motor animations)
│  └─ PresetTemplatesTab
│     └─ ListView.builder (itemExtent: 200.0)
│        └─ TemplateCard (no swipe, tap only)
└─ FloatingActionButton ("Crea Template")
```

### 2. TemplateCard Layout (200dp height)

```
┌─────────────────────────────────────────┐
│ [Hero Gradient - 80dp, 40%]             │ ← Category color (glass overlay)
│                                          │
│   Push Day - Petto e Tricipiti          │ ← Bold title (18sp, white)
│   [Intermedio] Petto • Tricipiti        │ ← Badge + muscle groups (14sp)
├─────────────────────────────────────────┤
│ Panca · Croci · Dips +3                 │ ← Exercise preview (no icons)
│ ⏱️ 60 min • 12 esercizi                │ ← Duration + count (keep ⏱️)
│ 🕐 Ultimo: 3 giorni fa                  │ ← Last performed (keep 🕐)
└─────────────────────────────────────────┘
```

**Swipe Actions** (reveal on swipe left):
```
← swipe      [Share] [Duplicate] [Edit] [Delete]
            (green) (blue)       (grey)  (red)
```

### 3. State Management (Riverpod)

**New Provider**:
```dart
final templateStatsProvider = FutureProvider.family
  .autoDispose<TemplateStats?, String>((ref, templateId) async {

  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return null;

  final repository = ref.watch(workoutRepositoryProvider);

  try {
    final workouts = await repository
        .getWorkoutsForTemplate(userId, templateId)
        .timeout(Duration(seconds: 5));

    if (workouts.isEmpty) {
      return TemplateStats(totalCompletions: 0);
    }

    workouts.sort((a, b) => b.startTime.compareTo(a.startTime));

    final avgDuration = _calculateAvgDuration(workouts);

    return TemplateStats(
      lastPerformed: workouts.first.startTime,
      totalCompletions: workouts.length,
      avgDuration: avgDuration,
    );
  } catch (e) {
    debugPrint('❌ templateStatsProvider error: $e');
    return null;
  }
});
```

**Key Features**:
- ✅ 5-second timeout protection
- ✅ AutoDispose for cleanup
- ✅ Graceful error recovery (returns null)
- ✅ Single query for all stats (performance)

---

## UI Components

### 1. Glass Morphism Card Design

**Container with backdrop blur**:
```dart
Container(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: context.colors.surface.withValues(alpha: 0.8), // Semi-transparent
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.1), // Subtle border
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.05), // Inner glow
        blurRadius: 10,
        offset: Offset(0, -2),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glass blur
      child: Column(...),
    ),
  ),
)
```

**Import**:
```dart
import 'dart:ui' show ImageFilter;
```

### 2. Hero Gradient System

**TemplateCategory Enum**:
```dart
enum TemplateCategory {
  strength,    // Red gradient
  cardio,      // Blue gradient
  flexibility, // Green gradient
  hybrid,      // Purple gradient
}
```

**Light Theme Colors**:
```dart
strength:    #FF6B6B → #FF8E72
cardio:      #4ECDC4 → #44A5E4
flexibility: #95E1D3 → #6BCB77
hybrid:      #A8E6CF → #B19CD9
```

**Dark Theme Colors** (20% darker):
```dart
strength:    #CC5555 → #CC7160
cardio:      #3EA39D → #3683B6
flexibility: #78B4A9 → #55A260
hybrid:      #87B9A5 → #8E7DAE
```

**Gradient Direction**: `begin: Alignment.topLeft, end: Alignment.bottomRight`

**Hero Layout** (80dp height):
```dart
Container(
  height: 80,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: category.gradientColors(context.isDarkMode),
    ),
  ),
  child: Stack(
    children: [
      // Glass overlay
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ),

      // Content
      Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(template.name, /* Bold 18sp white */),
            SizedBox(height: 4),
            Row(
              children: [
                _buildDifficultyBadge(),
                SizedBox(width: 8),
                _buildMuscleGroups(),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
)
```

### 3. Difficulty Badge Design

**DifficultyLevel Enum**:
```dart
enum DifficultyLevel {
  beginner,    // Green
  intermediate, // Orange
  advanced,    // Red
  expert,      // Purple
}
```

**Badge Colors**:
```dart
beginner:    #6BCB77 (light) / #55A260 (dark)
intermediate: #FF8E72 (light) / #CC7160 (dark)
advanced:    #FF6B6B (light) / #CC5555 (dark)
expert:      #B19CD9 (light) / #8E7DAE (dark)
```

**Badge Widget**:
```dart
Container(
  height: 24,
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  decoration: BoxDecoration(
    color: difficultyColor.withValues(alpha: 0.2),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: difficultyColor, width: 1),
  ),
  child: Text(
    context.l10n.difficulty(level), // "Intermedio"
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.white, // Always white on hero
    ),
  ),
)
```

### 4. Typography & Spacing

**Exercise Preview** (line 1):
```dart
Text(
  'Panca · Croci · Dips +3', // No icons, clean text
  style: context.textTheme.bodyMedium?.copyWith(
    color: context.colors.onSurface,
    fontWeight: FontWeight.w500,
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)
```

**Metadata Row** (line 2):
```dart
Row(
  children: [
    Icon(AppIcons.timer, size: AppIconSize.small, color: context.iconMediumEmphasis),
    SizedBox(width: 4),
    Text('60 min', style: context.textTheme.bodySmall),
    SizedBox(width: 8),
    Text('•', style: context.textTheme.bodySmall),
    SizedBox(width: 8),
    Text('12 esercizi', style: context.textTheme.bodySmall),
  ],
)
```

**Last Performed** (line 3 - conditional styling):
```dart
final isRecent = daysSince < 7;
final color = isRecent
  ? context.colors.success       // Green if < 7 days
  : context.iconMediumEmphasis;  // Grey if older

Row(
  children: [
    Icon(AppIcons.calendar, size: AppIconSize.small, color: color),
    SizedBox(width: 4),
    Text(
      _formatLastPerformed(lastPerformed), // "3 giorni fa" / "🆕 Nuovo" / "✅ Oggi"
      style: context.textTheme.bodySmall?.copyWith(color: color),
    ),
  ],
)
```

**Body Padding**:
```dart
Padding(
  padding: EdgeInsets.all(16), // Uniform 16dp
  child: Column(
    spacing: 8, // 8dp between lines
    children: [...],
  ),
)
```

---

## Animations (Motor 1.0.1)

### Setup

**pubspec.yaml**:
```yaml
dependencies:
  motor: ^1.0.1
```

**Import**:
```dart
import 'package:motor/motor.dart';
```

### Swipe Reveal Animation

```dart
Dismissible(
  key: ValueKey(template.id),
  direction: DismissDirection.endToStart, // Swipe left only
  confirmDismiss: (direction) async => false, // Prevent dismiss
  movementDuration: MotionDurations.medium, // 300ms
  resizeDuration: MotionDurations.short,     // 200ms
  background: AnimatedBuilder(
    animation: _swipeAnimation,
    builder: (context, child) {
      return Transform.scale(
        scale: 0.9 + (_swipeAnimation.value * 0.1), // Scale up
        child: Opacity(
          opacity: _swipeAnimation.value, // Fade in
          child: _buildSwipeActionsBackground(),
        ),
      );
    },
  ),
  child: TemplateCard(...),
)
```

**Curve**: `MotionCurves.emphasized` (Material 3 standard)

### Card Tap Animation

```dart
GestureDetector(
  onTapDown: (_) => setState(() => _isPressed = true),
  onTapUp: (_) => setState(() => _isPressed = false),
  onTapCancel: () => setState(() => _isPressed = false),
  onTap: () => _onTemplateTap(template),
  child: AnimatedContainer(
    duration: MotionDurations.short, // 200ms
    curve: MotionCurves.emphasized,
    transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0), // Subtle press
    child: /* Card */,
  ),
)
```

### Action Button Spring

```dart
TweenAnimationBuilder<double>(
  duration: MotionDurations.short, // 200ms
  curve: MotionCurves.spring,      // Spring bounce
  tween: Tween(begin: 1.0, end: 1.0),
  builder: (context, scale, child) {
    return Transform.scale(
      scale: scale,
      child: Material(/* Action button */),
    );
  },
)
```

### Hero Content Fade-In

```dart
TweenAnimationBuilder<double>(
  duration: MotionDurations.long, // 500ms
  curve: MotionCurves.emphasized,
  tween: Tween(begin: 0.0, end: 1.0),
  builder: (context, value, child) {
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 10 * (1 - value)), // Slide up
        child: child,
      ),
    );
  },
  child: Text(template.name),
)
```

### Motor Timing Reference

```dart
MotionDurations.short   // 200ms - Button press, action tap
MotionDurations.medium  // 300ms - Swipe reveal, card slide
MotionDurations.long    // 500ms - Hero transitions, fade-ins

MotionCurves.emphasized // Material 3 standard ease
MotionCurves.spring     // Spring bounce (subtle)
MotionCurves.decelerate // Smooth slow-down
```

### Performance Optimization

```dart
RepaintBoundary(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: /* Card */,
  ),
)
```

---

## Swipe Interactions

### Quick Actions Background

```dart
Widget _buildSwipeActionsBackground() {
  return Container(
    decoration: BoxDecoration(
      color: context.colors.surfaceVariant,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildActionButton(icon: AppIcons.share, color: context.colors.success),
        SizedBox(width: 8),
        _buildActionButton(icon: AppIcons.duplicate, color: context.colors.primary),
        SizedBox(width: 8),
        _buildActionButton(icon: AppIcons.edit, color: context.iconMediumEmphasis),
        SizedBox(width: 8),
        _buildActionButton(icon: AppIcons.delete, color: context.colors.error),
        SizedBox(width: 16),
      ],
    ),
  );
}
```

### Action Button Design

```dart
Widget _buildActionButton({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return Material(
    color: color.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: () async {
        await HapticFeedback.lightImpact(); // Tactile feedback
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1), // Glass effect
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: AppIconSize.medium),
      ),
    ),
  );
}
```

### Action Behaviors

#### 1. Share (Green)
```dart
Future<void> _shareTemplate(WorkoutTemplate template) async {
  final text = '''
🏋️ ${template.name}

📋 ${template.exercises.length} esercizi
⏱️ ${template.estimatedDuration} min
💪 ${template.difficulty ?? 'Intermedio'}

${template.exercises.take(3).map((e) => '• ${e.exerciseName}').join('\n')}
${template.exercises.length > 3 ? '... +${template.exercises.length - 3} esercizi' : ''}

Scarica GymBro: [link]
  '''.trim();

  await Share.share(text);

  await WorkoutAnalytics.trackEvent('template_shared', properties: {
    'templateId': template.id,
    'templateName': template.name,
  });
}
```

#### 2. Duplicate (Blue)
```dart
Future<void> _duplicateTemplate(WorkoutTemplate template) async {
  final duplicated = template.copyWith(
    id: Uuid().v4(),
    name: '${template.name} (Copia)',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    usageCount: 0,
  );

  await ref.read(workoutTemplateRepositoryProvider).saveTemplate(duplicated);

  if (mounted) {
    SnackBarService.showSuccess(
      context,
      context.l10n.templateDuplicated(template.name),
    );
  }
}
```

#### 3. Edit (Grey)
```dart
void _editTemplate(WorkoutTemplate template) {
  context.pushNamed('template-editor', extra: template);
}
```

#### 4. Delete (Red)
```dart
Future<void> _deleteTemplate(WorkoutTemplate template) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.deleteTemplateTitle),
      content: Text(context.l10n.deleteTemplateMessage(template.name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: context.colors.error),
          child: Text(context.l10n.delete),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await ref.read(workoutTemplateRepositoryProvider).deleteTemplate(template.id);

    if (mounted) {
      SnackBarService.showSuccess(
        context,
        context.l10n.templateDeleted(template.name),
      );
    }
  }
}
```

### Preset Templates: No Swipe

```dart
if (template.isCustom) {
  return Dismissible(...); // Swipe enabled
} else {
  return TemplateCard(...); // No swipe, tap only
}
```

---

## Data Model

### 1. New Entities

#### TemplateCategory Enum
```dart
enum TemplateCategory {
  strength,
  cardio,
  flexibility,
  hybrid;

  String localizedName(BuildContext context) { /* ... */ }
  List<Color> gradientColors(bool isDark) { /* ... */ }
}
```

#### DifficultyLevel Enum
```dart
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert;

  static DifficultyLevel fromString(String? value) { /* ... */ }
  String localizedName(BuildContext context) { /* ... */ }
  Color badgeColor(bool isDark) { /* ... */ }
}
```

#### TemplateStats Model
```dart
class TemplateStats {
  final DateTime? lastPerformed;
  final int totalCompletions;
  final Duration? avgDuration;

  String formattedLastPerformed(BuildContext context) {
    if (lastPerformed == null) return context.l10n.templateNeverPerformed; // "🆕 Nuovo"

    final daysSince = DateTime.now().difference(lastPerformed!).inDays;

    if (daysSince == 0) return context.l10n.templatePerformedToday; // "✅ Oggi"
    if (daysSince < 7) return context.l10n.templatePerformedDaysAgo(daysSince); // "3 giorni fa"
    if (daysSince >= 30) return context.l10n.templatePerformedResume; // "🔄 Riprendi?"

    return context.l10n.templatePerformedDaysAgo(daysSince);
  }

  Color? statusColor(BuildContext context) {
    if (lastPerformed == null) return null;

    final daysSince = DateTime.now().difference(lastPerformed!).inDays;
    if (daysSince < 7) return context.colors.success;
    if (daysSince >= 30) return context.colors.warning;
    return null;
  }
}
```

### 2. WorkoutTemplate Extensions (Auto-Detection)

```dart
extension WorkoutTemplateExtensions on WorkoutTemplate {
  /// Auto-detect category from exercises
  TemplateCategory detectCategory() {
    final hasCardio = exercises.any((e) => e.category == ExerciseCategory.cardio);
    final hasStrength = exercises.any((e) =>
      e.category == ExerciseCategory.chest ||
      e.category == ExerciseCategory.back ||
      e.category == ExerciseCategory.legs ||
      e.category == ExerciseCategory.shoulders ||
      e.category == ExerciseCategory.arms
    );
    final hasFlexibility = exercises.any((e) => e.category == ExerciseCategory.flexibility);

    if ((hasCardio && hasStrength) || (hasCardio && hasFlexibility)) {
      return TemplateCategory.hybrid;
    }
    if (hasCardio) return TemplateCategory.cardio;
    if (hasFlexibility) return TemplateCategory.flexibility;
    return TemplateCategory.strength;
  }

  /// Auto-detect difficulty from volume
  DifficultyLevel detectDifficulty() {
    final totalSets = exercises.fold(0, (sum, e) => sum + e.sets.length);
    final hasComplexExercises = exercises.any((e) =>
      e.type == ExerciseType.superset || e.type == ExerciseType.dropset
    );

    if (totalSets < 12 && !hasComplexExercises) return DifficultyLevel.beginner;
    if (totalSets < 18) return DifficultyLevel.intermediate;
    if (totalSets < 24) return DifficultyLevel.advanced;
    return DifficultyLevel.expert;
  }

  /// Extract muscle groups from exercises
  List<String> extractMuscleGroups(BuildContext context) {
    final categories = exercises.map((e) => e.category).toSet();

    return categories.map((cat) {
      switch (cat) {
        case ExerciseCategory.chest: return context.l10n.muscleGroupChest;
        case ExerciseCategory.back: return context.l10n.muscleGroupBack;
        case ExerciseCategory.shoulders: return context.l10n.muscleGroupShoulders;
        case ExerciseCategory.arms: return context.l10n.muscleGroupArms;
        case ExerciseCategory.legs: return context.l10n.muscleGroupLegs;
        case ExerciseCategory.core: return context.l10n.muscleGroupCore;
        default: return null;
      }
    }).whereType<String>().toList();
  }

  /// Get first 3 exercises for preview
  String exercisePreview(BuildContext context) {
    final preview = exercises.take(3).map((e) => e.exerciseName).join(' · ');
    final remaining = exercises.length - 3;

    return remaining > 0 ? '$preview +$remaining' : preview;
  }
}
```

### 3. Auto-Detection Strategy (Option B)

**When to auto-detect**:
- Template creation/update → calculate values, show as placeholders
- User can override if detection is wrong
- If user leaves empty → use auto-detected values

**Benefits**:
- ✅ Zero friction for user (no mandatory fields)
- ✅ Cards always populated (no null/empty states)
- ✅ Smart detection (90% accuracy)
- ✅ Override available for edge cases

---

## Localization

### New Keys Required

**app_it.arb**:
```json
{
  "templateCategoryStrength": "Forza",
  "templateCategoryCardio": "Cardio",
  "templateCategoryFlexibility": "Flessibilità",
  "templateCategoryHybrid": "Ibrido",

  "difficultyBeginner": "Principiante",
  "difficultyIntermediate": "Intermedio",
  "difficultyAdvanced": "Avanzato",
  "difficultyExpert": "Esperto",

  "muscleGroupChest": "Petto",
  "muscleGroupBack": "Dorso",
  "muscleGroupShoulders": "Spalle",
  "muscleGroupArms": "Braccia",
  "muscleGroupLegs": "Gambe",
  "muscleGroupCore": "Core",

  "templateNeverPerformed": "🆕 Nuovo",
  "templatePerformedToday": "✅ Oggi",
  "templatePerformedDaysAgo": "{days} giorni fa",
  "@templatePerformedDaysAgo": {
    "placeholders": {"days": {"type": "int"}}
  },
  "templatePerformedResume": "🔄 Riprendi?",

  "templateDuplicated": "Template \"{name}\" duplicato",
  "@templateDuplicated": {
    "placeholders": {"name": {"type": "String"}}
  },
  "templateDeleted": "Template \"{name}\" eliminato",
  "@templateDeleted": {
    "placeholders": {"name": {"type": "String"}}
  },

  "deleteTemplateTitle": "Elimina Template",
  "deleteTemplateMessage": "Vuoi eliminare \"{name}\"? Questa azione non può essere annullata.",
  "@deleteTemplateMessage": {
    "placeholders": {"name": {"type": "String"}}
  }
}
```

**app_en.arb**:
```json
{
  "templateCategoryStrength": "Strength",
  "templateCategoryCardio": "Cardio",
  "templateCategoryFlexibility": "Flexibility",
  "templateCategoryHybrid": "Hybrid",

  "difficultyBeginner": "Beginner",
  "difficultyIntermediate": "Intermediate",
  "difficultyAdvanced": "Advanced",
  "difficultyExpert": "Expert",

  "muscleGroupChest": "Chest",
  "muscleGroupBack": "Back",
  "muscleGroupShoulders": "Shoulders",
  "muscleGroupArms": "Arms",
  "muscleGroupLegs": "Legs",
  "muscleGroupCore": "Core",

  "templateNeverPerformed": "🆕 New",
  "templatePerformedToday": "✅ Today",
  "templatePerformedDaysAgo": "{days} days ago",
  "templatePerformedResume": "🔄 Resume?",

  "templateDuplicated": "Template \"{name}\" duplicated",
  "templateDeleted": "Template \"{name}\" deleted",

  "deleteTemplateTitle": "Delete Template",
  "deleteTemplateMessage": "Delete \"{name}\"? This action cannot be undone."
}
```

---

## Implementation Checklist

### Phase 1: Data Model & Providers
- [ ] Add `motor: ^1.0.1` to pubspec.yaml
- [ ] Create `TemplateCategory` enum with gradient colors
- [ ] Create `DifficultyLevel` enum with badge colors
- [ ] Create `TemplateStats` model with formatting methods
- [ ] Create `WorkoutTemplateExtensions` for auto-detection
- [ ] Create `templateStatsProvider` (FutureProvider.family)
- [ ] Test auto-detection logic (category, difficulty, muscle groups)

### Phase 2: Localization
- [ ] Add 20+ keys to `app_it.arb`
- [ ] Add 20+ keys to `app_en.arb`
- [ ] Run `flutter gen-l10n`
- [ ] Verify generated methods in AppLocalizations

### Phase 3: UI Components
- [ ] Create `TemplateCard` widget with glass morphism
- [ ] Implement hero gradient with category colors
- [ ] Add difficulty badge component
- [ ] Add muscle groups display
- [ ] Add exercise preview (text only, no icons)
- [ ] Add metadata row (duration, count) with icons
- [ ] Add last performed timestamp (conditional styling)
- [ ] Implement backdrop blur (ImageFilter)

### Phase 4: Animations (Motor)
- [ ] Add swipe reveal animation (300ms, emphasized curve)
- [ ] Add card tap animation (press scale 0.98)
- [ ] Add action button spring animation
- [ ] Add hero content fade-in (500ms slide up)
- [ ] Test performance with RepaintBoundary

### Phase 5: Swipe Actions
- [ ] Implement Dismissible with Gmail-style reveal
- [ ] Create action buttons (share, duplicate, edit, delete)
- [ ] Add haptic feedback on tap
- [ ] Implement share action (social share text)
- [ ] Implement duplicate action (copy with new ID)
- [ ] Implement edit action (navigate to editor)
- [ ] Implement delete action (confirmation dialog)
- [ ] Test swipe on custom templates only (no swipe on presets)

### Phase 6: Screen Integration
- [ ] Update `WorkoutTemplatesScreen` with vertical ListView
- [ ] Set `itemExtent: 200.0` for performance
- [ ] Add `BouncingScrollPhysics` for iOS feel
- [ ] Integrate `templateStatsProvider` for each card
- [ ] Handle loading/error states gracefully
- [ ] Test TabBarView (custom vs preset templates)

### Phase 7: Testing
- [ ] Test loading state (shimmer with glass effect)
- [ ] Test empty state (no templates)
- [ ] Test swipe actions (all 4 actions work)
- [ ] Test delete confirmation dialog
- [ ] Test share text formatting
- [ ] Test duplicate (new ID, reset usage count)
- [ ] Test auto-detection accuracy (sample templates)
- [ ] Test dark/light theme (gradient colors correct)
- [ ] Test IT/EN locales (all strings translated)
- [ ] Test performance (60fps scrolling, no jank)
- [ ] Test preset templates (no swipe actions)

---

## Success Criteria

### Must Have ✅
- ✅ Vertical list layout (one card per row)
- ✅ Glass morphism design with backdrop blur
- ✅ Category-based gradient colors (4 categories)
- ✅ Difficulty badge (auto-detected, 4 levels)
- ✅ Muscle groups display (auto-extracted from exercises)
- ✅ Exercise preview (text only, first 3 + counter)
- ✅ Last performed timestamp (conditional styling)
- ✅ Swipe-to-reveal actions (share, duplicate, edit, delete)
- ✅ Smooth animations (motor 1.0.1, 60fps)
- ✅ Full localization (IT/EN)
- ✅ Performance optimized (itemExtent, RepaintBoundary)

### Nice to Have ✨
- ✨ Shimmer loading effect with glass morphism
- ✨ Hero animation when tapping card → detail
- ✨ Pull-to-refresh gesture
- ✨ Drag-to-reorder templates

---

## Time Estimate

- **Phase 1** (Data Model): 1 hour
- **Phase 2** (Localization): 30 min
- **Phase 3** (UI Components): 2 hours
- **Phase 4** (Animations): 1 hour
- **Phase 5** (Swipe Actions): 1.5 hours
- **Phase 6** (Screen Integration): 1 hour
- **Phase 7** (Testing): 1.5 hours

**Total**: ~8.5 hours (1 working day)

---

## Edge Cases

### Workout never performed
**Scenario**: Template created but never used

**Expected**: Show "🆕 Nuovo" in green

**Logic**: `lastPerformed == null`

### Workout performed today
**Scenario**: User completed workout same day

**Expected**: Show "✅ Oggi" in green

**Logic**: `daysSince == 0`

### Workout performed > 30 days ago
**Scenario**: Template not used in a month

**Expected**: Show "🔄 Riprendi?" in amber with subtle pulse

**Logic**: `daysSince >= 30` → amber color + warning state

### Template with no exercises
**Scenario**: Empty template (should not happen, but guard)

**Expected**: Show "Nessun esercizio" placeholder

**Logic**: `template.exercises.isEmpty`

### Auto-detection edge cases
**Scenario**: Hybrid workout (cardio + strength)

**Expected**: Category = `hybrid`, gradient = purple

**Logic**: `hasCardio && hasStrength`

---

## Rollback Plan

If issues arise:
1. Keep data model changes (enums, extensions) - safe
2. Revert to 2×2 grid layout temporarily
3. Keep localization keys (no harm)
4. Disable swipe actions if performance issues
5. Replace motor animations with standard AnimatedContainer

---

## Notes

- **Glass morphism**: Requires iOS 13+ (BackdropFilter support)
- **Motor package**: Tested on Flutter 3.0+, stable
- **Performance**: itemExtent=200 ensures smooth 60fps scrolling
- **Testing phase**: Breaking changes OK (single user)
- **No volume**: Volume metric only in post-workout rest mode (not template card)
- **Auto-detection**: 90% accurate, user can override in template editor
- **Preset templates**: No swipe actions (read-only)
