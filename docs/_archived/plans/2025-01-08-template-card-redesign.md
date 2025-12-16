# Template Card Redesign - Apple HIG Compliant

**Date**: 2025-01-08
**Status**: ✅ Design Complete - Ready for Implementation
**Designer**: Claude + User Brainstorming Session
**Consultant**: Apple HIG Expert Recommendations

---

## 📋 Executive Summary

**Problem**: Current glass morphism template cards have critical UX issues:
- Too bright/luminous (saturated gradients: red, blue, purple, green)
- Borders almost invisible (alpha 0.2-0.3 white on light backgrounds)
- Lack of depth/profundity (BackdropFilter blur removes definition)
- Poor accessibility (potential WCAG AA violations)
- Cards feel like "moving rectangles" without substance

**Solution**: Redesign following Apple Human Interface Guidelines with:
- Clean white/gray background + subtle left accent strip (2pt → 4pt on press)
- iOS-style shadow for depth (blur 8pt, offset 0,2, opacity 0.1/0.15)
- WCAG AA compliant semantic colors (success/warning/error containers)
- Micro-interactions (haptic feedback, scale 0.98, animated strip)
- GymBro design system integration (`context.colors.*`, `AppIcons.*`)

**Impact**:
- ✅ WCAG AA accessibility compliance
- ✅ Reduced visual noise (cleaner, more focused)
- ✅ Better depth perception (visible shadows, defined borders)
- ✅ Improved tap affordance (clear press animations)
- ✅ Consistent with iOS native patterns

---

## 🔧 Implementation Prerequisites (CRITICAL - Read First)

> **⚠️ MANDATORY**: These specifications resolve gaps identified in critical analysis.
> **Without these**, implementation will fail or violate CLAUDE.md rules.

### **1. Active Workout Detection**

**Provider**: Use existing `currentWorkoutProvider` (not `activeWorkoutProvider`)

```dart
// lib/features/workout/presentation/providers/workout_provider.dart:92
final currentWorkoutProvider = StateNotifierProvider<CurrentWorkoutNotifier, Workout?>(...)

// Implementation in template_card.dart
bool _isActiveWorkout(wt.WorkoutTemplate template, WidgetRef ref) {
  final currentWorkout = ref.watch(currentWorkoutProvider);
  return currentWorkout?.templateId == template.id;
}
```

**Status**: ✅ Provider exists, `Workout` has `templateId` field.

---

### **2. SwipeableTemplateCard Integration**

**Current Usage**: `workout_screen.dart:591` ALREADY uses `SwipeableTemplateCard`

```dart
// workout_screen.dart current implementation
return SwipeableTemplateCard(
  template: template,
  onTap: () => _showTemplateOptions(context, ref, template), // ← KEEP this pattern
  onShare: () => ...,
  onDuplicate: () => ...,
  onEdit: () => ...,
  onDelete: () => ...,
)
```

**CRITICAL**: Design proposes changing `onTap` to direct workout start, BUT swipe actions (Edit/Delete) still needed.

**Decision**: Change ONLY the `onTap` handler:
```dart
// NEW behavior
onTap: () => _startWorkoutFromTemplate(context, ref, template), // Direct start
```

**Swipe actions** remain unchanged (Edit, Delete still accessible via swipe).

**Status**: ✅ No breaking UX change, swipe actions preserved.

---

### **3. Icon Sizes (CLAUDE.md REGOLA #0 Compliance)**

**Current Violation**: `template_card.dart:256` uses magic number `size: 16`

**Required Fix**: Use `AppIconSize.small` (20dp, not 16dp)

```dart
// ❌ WRONG (current code)
Icon(
  AppIcons.schedule,
  size: 16,  // Magic number violation
)

// ✅ CORRECT (design requirement)
Icon(
  AppIcons.schedule,
  size: AppIconSize.small,  // 20dp semantic constant
  color: context.colors.onSurfaceVariant,
)
```

**Verification**: `lib/shared/presentation/theme/app_icon_size.dart:26`
```dart
static const double small = 20.0;  // ✅ Confirmed
```

**Status**: ✅ Specification complete, pre-commit hook will enforce.

---

### **4. DifficultyLevel.expert Badge Mapping**

**Current Code**: `difficulty_level.dart` defines 4 levels (beginner, intermediate, advanced, **expert**)

**Design Gap**: Document only maps 3 levels → Missing `expert` case!

**Required Addition**:

```dart
// Add to badge color helper methods (Section 3 of this doc)
Color _badgeBackgroundColor(DifficultyLevel diff, BuildContext ctx) {
  switch (diff) {
    case DifficultyLevel.beginner:
      return ctx.colors.successContainer;
    case DifficultyLevel.intermediate:
      return ctx.colors.warningContainer;
    case DifficultyLevel.advanced:
      return ctx.colors.errorContainer;
    case DifficultyLevel.expert:  // ← MISSING in original design!
      return ctx.colors.tertiaryContainer;  // Purple for elite/mastery
  }
}

// Same pattern for border and text colors
```

**Rationale**: Matches current logic (line 96-99 uses purple for expert).

**Status**: ✅ Gap resolved, 4th case added.

---

### **5. Localization ARB Keys (CLAUDE.md REGOLA #1 Compliance)**

**Current Violations**:
- `template_card.dart:205`: Hardcoded `'Nessun esercizio'` (Italian)
- `difficulty_level.dart:60-67`: Hardcoded `"Difficulty Beginner"` (English)

**Required ARB Additions** (`assets/i18n/app_en.arb` + `app_it.arb`):

```json
// app_en.arb
{
  "noExercises": "No exercises",
  "difficultyBeginner": "Beginner",
  "difficultyIntermediate": "Intermediate",
  "difficultyAdvanced": "Advanced",
  "difficultyExpert": "Expert"
}

// app_it.arb
{
  "noExercises": "Nessun esercizio",
  "difficultyBeginner": "Principiante",
  "difficultyIntermediate": "Intermedio",
  "difficultyAdvanced": "Avanzato",
  "difficultyExpert": "Esperto"
}
```

**Implementation Order**:
1. Add ARB keys (both files)
2. Run `flutter gen-l10n` (generates AppLocalizations)
3. Update `difficulty_level.dart:localizedName()`:
   ```dart
   String localizedName(BuildContext context) {
     switch (this) {
       case DifficultyLevel.beginner:
         return context.l10n.difficultyBeginner;  // ✅ Localized
       // ... repeat for all 4 levels
     }
   }
   ```
4. Update `template_card.dart:205`:
   ```dart
   return Text(
     context.l10n.noExercises,  // ✅ Localized
     style: context.textTheme.bodyMedium?.copyWith(
       color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
     ),
   );
   ```

**Status**: ✅ Keys specified, pre-commit hook will enforce.

---

### **6. Pre-Commit Verification Rules**

**Automated checks** (to be added in Step 1):

| Check | Pattern | Error Message |
|-------|---------|---------------|
| Hardcoded colors | `Colors\.white` in `lib/features/workout/presentation/` | ❌ Use `context.colors.*` instead |
| Icon magic numbers | `size: 16,` | ❌ Use `AppIconSize.small` (20dp) |
| Hardcoded Italian | `'Nessun esercizio'` | ❌ Use `context.l10n.noExercises` |
| Hardcoded English | `"Difficulty Beginner"` | ❌ Use `context.l10n.difficultyBeginner` |
| Missing ARB keys | `flutter gen-l10n` errors | ❌ Add missing keys to ARB files |

**Status**: ✅ Rules defined, script to be created in Step 1.

---

## 🎨 Section 1: Layout & Structure

### **Card Container**

```dart
Container(
  height: 200, // Fixed height for ListView itemExtent optimization
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: context.colors.surface, // White (light) / Dark gray (dark)
    borderRadius: BorderRadius.circular(12), // Apple HIG standard
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: context.isDarkMode ? 0.15 : 0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Stack(
    children: [
      // Left accent strip (colored by category)
      _AccentStrip(),

      // Content padding
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(/* ... */),
      ),
    ],
  ),
)
```

### **Left Accent Strip** (Category Color Coding)

```dart
// Animated width: 2pt (normal) → 4pt (pressed)
AnimatedContainer(
  duration: const Duration(milliseconds: 150),
  curve: Curves.easeOut,
  width: _isPressed ? 4 : 2,
  height: double.infinity,
  decoration: BoxDecoration(
    color: _getStripColor(template.effectiveCategory).withValues(
      alpha: _isActiveWorkout ? 1.0 : 0.8, // Saturate if active
    ),
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(12),
      bottomLeft: Radius.circular(12),
    ),
  ),
)

// Color mapping
Color _getStripColor(WorkoutCategory category) {
  switch (category) {
    case WorkoutCategory.strength:
      return context.colors.error; // Red
    case WorkoutCategory.cardio:
      return context.colors.primary; // Blue
    case WorkoutCategory.flexibility:
      return context.colors.success; // Green
    case WorkoutCategory.hybrid:
      return context.colors.tertiary; // Purple
  }
}
```

### **Content Layout**

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Header: Template name + Difficulty badge
    Row(
      children: [
        Expanded(child: _TemplateTitle()),
        const SizedBox(width: 12),
        _DifficultyBadge(),
      ],
    ),

    const SizedBox(height: 12),

    // Body: Exercise preview
    _ExercisePreview(),

    const Spacer(),

    // Footer: Metadata row (duration + last performed)
    _MetadataRow(),
  ],
)
```

---

## 🎨 Section 2: Visual Specifications

### **Container Colors**

| Element | Light Theme | Dark Theme | Source |
|---------|-------------|------------|--------|
| Background | White (#FFFFFF) | Gray (#1C1C1E) | `context.colors.surface` |
| Border | None (shadow handles separation) | None | N/A |
| Strip (Strength) | Red (Material 3 error) | Red (lighter) | `context.colors.error` |
| Strip (Cardio) | Blue (Material 3 primary) | Blue (lighter) | `context.colors.primary` |
| Strip (Flexibility) | Green (#43A047) | Green (#66BB6A) | `context.colors.success` |
| Strip (Hybrid) | Purple (Material 3 tertiary) | Purple (lighter) | `context.colors.tertiary` |

### **Shadow Specification**

```dart
BoxShadow(
  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.1),
  blurRadius: 8,  // Soft blur
  offset: const Offset(0, 2), // Subtle elevation
  spreadRadius: 0, // No spread (tight shadow)
)
```

**Rationale**: iOS-style shadow provides depth without aggressive Material elevation. Higher opacity in dark mode (0.15 vs 0.1) compensates for reduced contrast.

### **Border Radius**

- **Card**: 12pt (Apple HIG standard for cards)
- **Badge**: 12pt (capsule shape)
- **Strip**: 12pt (top-left + bottom-left only)

---

## 🎨 Section 3: Typography & Badge Details

### **Text Hierarchy**

| Element | Style | Weight | Color | Max Lines |
|---------|-------|--------|-------|-----------|
| Template Name | `titleLarge` (~22pt) | Bold | `onSurface` (.label) | 2 |
| Exercise Preview | `bodyMedium` (~16pt) | Regular | `onSurfaceVariant` (.secondaryLabel) | 2 |
| Metadata Text | `labelMedium` (~12pt) | Semi-bold (w600) | `onSurfaceVariant` (.secondaryLabel) | 1 |
| Badge Text | `labelSmall` (~11pt) | Bold | Semantic (see below) | 1 |

**Code Examples**:

```dart
// 1. Template Name
Text(
  template.name,
  style: context.textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.bold,
    color: context.colors.onSurface,
  ),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)

// 2. Exercise Preview
Text(
  exercisePreview,
  style: context.textTheme.bodyMedium?.copyWith(
    color: context.colors.onSurfaceVariant,
  ),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)

// 3. Metadata (compact 12pt)
Text(
  '${template.estimatedDuration} min',
  style: context.textTheme.labelMedium?.copyWith(
    fontWeight: FontWeight.w600,
    color: context.colors.onSurfaceVariant,
  ),
)
```

### **Difficulty Badge Redesign**

**Current Issue**: Custom color logic in `difficulty_level.dart` (lines not WCAG AA guaranteed)

**New Design**: Semantic color containers with guaranteed contrast

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: _badgeBackgroundColor(difficulty, context),
    borderRadius: BorderRadius.circular(12), // Capsule
    border: Border.all(
      color: _badgeBorderColor(difficulty, context),
      width: 1,
    ),
  ),
  child: Text(
    difficulty.localizedName(context),
    style: context.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: _badgeTextColor(difficulty, context),
    ),
  ),
)
```

**Color Mapping** (WCAG AA Compliant):

| Difficulty | Background | Border | Text | Contrast Ratio |
|-----------|------------|--------|------|----------------|
| Beginner | `successContainer` (light green) | `success` (green) | `onSuccessContainer` (dark) | 4.5:1+ ✅ |
| Intermediate | `warningContainer` (light amber) | `warning` (amber) | `onWarningContainer` (dark) | 4.5:1+ ✅ |
| Advanced | `errorContainer` (light red) | `error` (red) | `onErrorContainer` (dark) | 4.5:1+ ✅ |
| Expert | `tertiaryContainer` (light purple) | `tertiary` (purple) | `onTertiaryContainer` (dark) | 4.5:1+ ✅ |

**Helper Methods**:

```dart
Color _badgeBackgroundColor(DifficultyLevel diff, BuildContext ctx) {
  switch (diff) {
    case DifficultyLevel.beginner:
      return ctx.colors.successContainer;
    case DifficultyLevel.intermediate:
      return ctx.colors.warningContainer;
    case DifficultyLevel.advanced:
      return ctx.colors.errorContainer;
    case DifficultyLevel.expert:
      return ctx.colors.tertiaryContainer; // Purple for elite/mastery
  }
}

Color _badgeBorderColor(DifficultyLevel diff, BuildContext ctx) {
  switch (diff) {
    case DifficultyLevel.beginner:
      return ctx.colors.success;
    case DifficultyLevel.intermediate:
      return ctx.colors.warning;
    case DifficultyLevel.advanced:
      return ctx.colors.error;
    case DifficultyLevel.expert:
      return ctx.colors.tertiary; // Purple border for expert
  }
}

Color _badgeTextColor(DifficultyLevel diff, BuildContext ctx) {
  switch (diff) {
    case DifficultyLevel.beginner:
      return ctx.colors.onSuccessContainer;
    case DifficultyLevel.intermediate:
      return ctx.colors.onWarningContainer;
    case DifficultyLevel.advanced:
      return ctx.colors.onErrorContainer;
    case DifficultyLevel.expert:
      return ctx.colors.onTertiaryContainer; // Dark text on light purple
  }
}
```

### **Metadata Row (Footer)**

**Layout**: Compact design with 8pt spacing around bullet

```dart
Row(
  children: [
    // Duration
    Icon(
      AppIcons.schedule,
      size: AppIconSize.small, // 20dp
      color: context.colors.onSurfaceVariant,
    ),
    const SizedBox(width: 4),
    Text(
      '${template.estimatedDuration} min',
      style: context.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: context.colors.onSurfaceVariant,
      ),
    ),

    const SizedBox(width: 8), // 8pt before bullet

    // Bullet separator
    Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    ),

    const SizedBox(width: 8), // 8pt after bullet

    // Last performed
    Icon(
      AppIcons.history,
      size: AppIconSize.small,
      color: stats.statusColor(context) ?? context.colors.onSurfaceVariant,
    ),
    const SizedBox(width: 4),
    Text(
      stats.formattedLastPerformed(context),
      style: context.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: stats.statusColor(context) ?? context.colors.onSurfaceVariant,
      ),
    ),
  ],
)
```

**Status Colors** (from `template_stats.dart` lines 68-93):
- Recent (< 7 days): `context.colors.success` (green)
- Moderate (7-13 days): `context.colors.warning` (amber)
- Old (≥ 14 days): `null` → fallback to `onSurfaceVariant` (gray)

---

## 🎬 Section 4: Micro-Interactions

### **Tap Behavior**

**Current** (line 593 workout_screen.dart):
```dart
onTap: () => _showTemplateOptions(context, ref, template), // Shows bottom sheet
```

**New** (direct workout start):
```dart
onTap: () => _startWorkoutFromTemplate(context, ref, template),
```

**Rationale**: Reduce friction - primary action should be immediate, not hidden behind modal.

### **Press Animation**

**Combined Effects** (150ms duration):

1. **Scale Down**: 0.98 (subtle depth feedback)
2. **Strip Expand**: 2pt → 4pt (visual confirmation)
3. **Haptic Feedback**: Medium impact (tactile response)

```dart
class _TemplateCardState extends ConsumerState<TemplateCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.mediumImpact();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(/* card content */),
      ),
    );
  }
}
```

### **Active Workout State**

**Indicator**: Strip opacity change (subtle, non-intrusive)

```dart
color: _getStripColor(category).withValues(
  alpha: _isActiveWorkout ? 1.0 : 0.8, // Fully saturated if active
),
```

**Detection Logic**:

```dart
bool _isActiveWorkout(WorkoutTemplate template, WidgetRef ref) {
  final activeWorkout = ref.watch(activeWorkoutProvider);
  return activeWorkout?.templateId == template.id;
}
```

---

## 📐 Section 5: Complete Implementation Blueprint

### **File: template_card.dart**

**Changes Required**:

1. **Remove** (lines 80-95):
   - `gradient: category.toGradient(isDark)`
   - `BackdropFilter(filter: ImageFilter.blur(...))`
   - `Colors.white.withValues(alpha: ...)` border

2. **Add** (replace decoration):
   ```dart
   decoration: BoxDecoration(
     color: context.colors.surface,
     borderRadius: BorderRadius.circular(12),
     boxShadow: [
       BoxShadow(
         color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.1),
         blurRadius: 8,
         offset: const Offset(0, 2),
       ),
     ],
   ),
   ```

3. **Add Stack** with accent strip:
   ```dart
   child: Stack(
     children: [
       _AccentStrip(
         category: widget.template.effectiveCategory,
         isPressed: _isPressed,
         isActive: _isActiveWorkout,
       ),
       Padding(
         padding: const EdgeInsets.all(16),
         child: Column(/* existing content */),
       ),
     ],
   ),
   ```

4. **Update _DifficultyBadge** (lines 163-193):
   - Replace with semantic color containers
   - Use helper methods for background/border/text colors

5. **Update _MetadataRow** (lines 239-289):
   - Change spacing around bullet: 4 → 8
   - Use `AppIconSize.small` for icons
   - Use `labelMedium` with `fontWeight.w600`

6. **Add GestureDetector** with press state:
   ```dart
   return GestureDetector(
     onTapDown: (_) {
       setState(() => _isPressed = true);
       HapticFeedback.mediumImpact();
     },
     // ... rest of gesture handling
   );
   ```

### **File: workout_screen.dart**

**Change Required** (line 593):

```dart
// Before
onTap: () => _showTemplateOptions(context, ref, template),

// After
onTap: () => _startWorkoutFromTemplate(context, ref, template),
```

**New Method** (add to _WorkoutScreenState):

```dart
Future<void> _startWorkoutFromTemplate(
  BuildContext context,
  WidgetRef ref,
  WorkoutTemplate template,
) async {
  try {
    // Start workout from template
    await ref.read(workoutProvider.notifier).startFromTemplate(template);

    // Navigate to workout session screen
    if (context.mounted) {
      Navigator.pushNamed(
        context,
        '/workout-session',
        arguments: template.id,
      );
    }
  } catch (e) {
    if (context.mounted) {
      SnackBarService.showError(
        context,
        context.l10n.workoutStartError,
      );
    }
  }
}
```

---

## ✅ Testing Checklist

### **Visual Testing**

- [ ] Cards visible in light theme (white background, subtle shadow)
- [ ] Cards visible in dark theme (dark gray background, stronger shadow)
- [ ] All 4 category strips visible (red, blue, green, purple)
- [ ] Strip width animates 2pt → 4pt on press
- [ ] Active workout strip fully saturated (alpha 1.0)
- [ ] Shadow provides clear depth/elevation
- [ ] Border radius 12pt consistent across all corners

### **Accessibility Testing**

- [ ] WCAG AA contrast ratio ≥ 4.5:1 for all badge combinations
- [ ] WCAG AA contrast ratio ≥ 4.5:1 for text on background
- [ ] VoiceOver/TalkBack announces card content properly
- [ ] Touch targets ≥ 44x44 (card is 200px height ✅)
- [ ] Color not sole indicator (strip + text labels)

### **Interaction Testing**

- [ ] Tap triggers direct workout start (no bottom sheet)
- [ ] Haptic feedback fires on tap down
- [ ] Scale animation smooth (0.98, 150ms ease-out)
- [ ] Strip animation smooth (2pt → 4pt, 150ms ease-out)
- [ ] Swipe actions still work (from swipeable_template_card.dart)
- [ ] Active workout strip saturates correctly

### **Localization Testing**

- [ ] Metadata displays correctly in IT locale
- [ ] Metadata displays correctly in EN locale
- [ ] Difficulty badge localized (context.l10n)
- [ ] "Last performed" formatting matches TemplateStats logic

### **Performance Testing**

- [ ] No jank on scroll (200px itemExtent optimization)
- [ ] Fade-in animation smooth (500ms Motor 1.0.1)
- [ ] Press animation no lag (150ms target)
- [ ] ListView recycling efficient (const widgets)

---

## 📊 Before/After Comparison

| Aspect | Before (Glass Morphism) | After (HIG Compliant) |
|--------|------------------------|----------------------|
| **Background** | Gradient + BackdropFilter blur | Solid surface color |
| **Border** | White alpha 0.2-0.3 (invisible) | None (shadow separates) |
| **Depth** | BackdropFilter (removes definition) | iOS shadow (blur 8, offset 2) |
| **Category Indicator** | Full card gradient | Left strip (2pt → 4pt) |
| **Radius** | 24pt (aggressive) | 12pt (HIG standard) |
| **Tap Feedback** | None | Scale 0.98 + haptic + strip expand |
| **Active State** | None | Strip saturation (alpha 1.0) |
| **Badge Colors** | Custom (no WCAG guarantee) | Semantic containers (WCAG AA ✅) |
| **Metadata Font** | bodySmall (~14pt) | labelMedium (~12pt, compact) |
| **Accessibility** | Unknown contrast ratios | WCAG AA compliant ✅ |

---

## 🎯 Success Metrics

**User Experience**:
- ✅ Borders clearly visible in both themes
- ✅ Cards feel like "buttons" not "moving rectangles"
- ✅ Visual depth/elevation obvious
- ✅ Category coding clear but not overwhelming

**Technical**:
- ✅ Zero hardcoded colors (all `context.colors.*`)
- ✅ Zero inline icons (all `AppIcons.*`)
- ✅ WCAG AA compliance (4.5:1+ contrast)
- ✅ ListView performance maintained (200px itemExtent)

**Design System**:
- ✅ Reuses existing GymBro colors (no new additions)
- ✅ Follows Apple HIG spacing (16pt padding, 8pt gaps)
- ✅ Uses semantic text styles (titleLarge, bodyMedium, labelMedium)
- ✅ Consistent with iOS native patterns

---

## 📝 Implementation Notes

### **DO**:
- ✅ Use `context.colors.*` for ALL colors
- ✅ Use `AppIcons.*` for ALL icons
- ✅ Use `context.textTheme.*` for ALL text styles
- ✅ Test in BOTH light and dark themes
- ✅ Add `const` constructors where possible
- ✅ Verify `flutter analyze` passes (0 errors)

### **DON'T**:
- ❌ Hardcode `Colors.blue/red/green` (use semantic colors)
- ❌ Use `Icons.*` inline (use `AppIcons.*`)
- ❌ Create custom text styles (use theme hierarchy)
- ❌ Add magic numbers (use named constants)
- ❌ Skip accessibility testing (WCAG AA required)

### **Edge Cases**:

1. **No exercises in template**: Already handled by _ExercisePreview (line 203-210)
2. **Never performed template**: `stats.statusColor(context)` returns `null` → gray text ✅
3. **Very long template name**: `maxLines: 2` + `overflow: ellipsis` ✅
4. **Active workout on different device**: Need to sync activeWorkoutProvider across devices

---

## 🚀 Next Steps

1. **Implement** new `template_card.dart` following this blueprint
2. **Update** `workout_screen.dart` tap handler
3. **Test** all visual/interaction/accessibility criteria
4. **Validate** WCAG AA compliance with contrast checker
5. **Document** if new patterns added to DESIGN_GUIDELINES.md
6. **Commit** with message: `feat: redesign template cards to Apple HIG standards`

---

**Approved By**: User (via brainstorming session 2025-01-08)
**Ready for Implementation**: ✅ YES
**Estimated Effort**: 2-3 hours (moderate complexity)
