# Secondary Actions Minimal Redesign

**Date**: 2025-01-05
**Status**: Design Approved
**Author**: Michele + Claude (Brainstorming Session)
**Feature**: Homepage "Altri Strumenti" Section Redesign

---

## Executive Summary

Complete redesign of the "Altri Strumenti" (Other Tools) section on the homepage, transitioning from a 7-card glassmorphism design to a 4-card minimal flat toolbar. The redesign focuses on:

- **Simplification**: 7 cards → 4 cards (removing redundant/unused features)
- **Modern aesthetics**: Glassmorphism → Minimal flat design
- **Standardization**: Centralized animation system for consistency
- **Performance**: Simplified animations (1 controller vs 3)
- **Maintainability**: Reusable `PressableCard` component

---

## Current State Analysis

### Existing Implementation
**File**: `lib/features/home/presentation/widgets/secondary_actions.dart`

**Current Cards** (7 total):
1. ✅ Analytics - Track progress
2. ✅ Settings - Customize app
3. ❌ Exercises - 3 sub-options (History, Search, Progress) → **Keep only Progress**
4. ❌ Community - Redundant (already exists elsewhere)
5. ✅ History - Past workouts
6. ❌ Notifications - Unused placeholder
7. ❌ Import Exercises - Developer-only tool

**Current Design Style**:
- Glassmorphism with `BackdropFilter` blur effects
- 3 separate `AnimationController`s per card (press, bounce, glow)
- Complex animation stack: scale + bounce + glow + elevation + blur
- 3 columns on mobile, 4 on tablet
- Aspect ratio: 1.0 (square cards)

**Issues Identified**:
- ❌ Too many cards (cognitive overload)
- ❌ Over-animated (bounce + glow unnecessary for minimal design)
- ❌ Performance overhead (blur + multiple controllers)
- ❌ Inconsistent with desired minimal aesthetic
- ❌ No animation standardization (duplicated code)

---

## New Design Specification

### 1. Layout & Structure

**Grid Configuration**:
- **4 columns horizontal** (toolbar-like layout)
- Aspect ratio: **1.2:1** (slightly wider than tall)
- Cross-axis spacing: **8dp** (tight, compact)
- Main-axis spacing: **8dp**
- External padding: **16dp** horizontal

**Responsive Behavior**:
```dart
// Mobile (<600dp width)
crossAxisCount: 4
childAspectRatio: 1.2
spacing: 8dp

// Tablet (>600dp width)
crossAxisCount: 4
childAspectRatio: 1.2
spacing: 12dp (more breathing room)
```

**Final 4 Cards**:

| Card | Route | Icon Outlined | Icon Filled |
|------|-------|---------------|-------------|
| Analytics | `/analytics` | `Icons.analytics_outlined` | `Icons.analytics` |
| Settings | `/settings` | `Icons.settings_outlined` | `Icons.settings` |
| Exercise Progress | `/exercise-progress` | `Icons.insights_outlined` | `Icons.insights` |
| History | `/workout-history` | `Icons.history_outlined` | `Icons.history` |

**Removed Cards**:
- ❌ Community (redundant with existing navigation)
- ❌ Notifications (unused placeholder)
- ❌ Import Exercises (developer tool, not user-facing)
- ❌ Exercise Search/History sub-menu (consolidated to Progress only)

---

### 2. Visual Design - Minimal Flat Style

**Card Base State**:
```dart
Container(
  decoration: BoxDecoration(
    color: context.colors.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

**Key Characteristics**:
- ✅ Flat background (no gradients)
- ✅ Single subtle shadow (2dp elevation feel)
- ✅ No border in default state
- ✅ No glassmorphism/blur effects
- ✅ Theme-aware colors (`context.colors.*`)

**Pressed State** (Scale + Subtle Overlay):
```dart
// Scale animation
Transform.scale(scale: 0.97)

// Background overlay (8% accent color)
Container(
  color: accentColor.withOpacity(0.08),
)

// Optional subtle border
Border.all(
  color: accentColor.withOpacity(0.30),
  width: 1,
)
```

**Accent Colors** (per category):
```dart
Analytics:        Color(0xFF6750A4)  // Purple - data/insights
Settings:         Color(0xFF625B71)  // Neutral gray
Exercise Progress: Color(0xFF006494)  // Blue - growth
History:          Color(0xFF8B5A3C)  // Brown - archival
```

**Color Usage**:
- Default icon: `context.colors.onSurface.withOpacity(0.75)`
- Pressed icon: `accentColor` (full opacity)
- Pressed overlay: `accentColor.withOpacity(0.08)` on background
- Pressed border: `accentColor.withOpacity(0.30)` (optional)

---

### 3. Icon System - SF Symbols Style

**Icon Approach**:
- Use **Material Icons** with outlined/filled variants (SF Symbols aesthetic)
- Size: **28dp** (balanced for compact layout)
- Swap behavior: `outlined` → `filled` on press
- Animation: `AnimatedSwitcher` with `ScaleTransition` (200ms)

**Icon Selection Rationale**:

| Card | Icon Choice | Why |
|------|-------------|-----|
| Analytics | `analytics` | Standard data visualization icon |
| Settings | `settings` | Universal settings gear |
| Exercise Progress | `insights` | Trending/growth feel (alternative: `trending_up`) |
| History | `history` | Clock/time icon for past data |

**Icon Container**:
- NO background circle/shape (truly minimal)
- Padding: **8dp** around icon (breathing room)
- Color transition: 200ms smooth fade

---

### 4. Typography

**Title** (card label, e.g., "Analytics"):
```dart
Text(
  title,
  style: context.textTheme.titleSmall?.copyWith(
    fontWeight: FontWeight.w600,
    color: context.colors.onSurface,
  ),
  textAlign: TextAlign.center,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)
```

**Subtitle** (description, e.g., "Track progress"):
```dart
Text(
  subtitle,
  style: context.textTheme.bodySmall?.copyWith(
    fontWeight: FontWeight.w400,
    color: context.colors.onSurface.withOpacity(0.65),
  ),
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

**Vertical Layout**:
```
┌─────────────┐
│   [Icon]    │  28dp, centered
│             │  8dp spacing
│   Title     │  titleSmall, semi-bold
│             │  4dp spacing
│  Subtitle   │  bodySmall, regular
└─────────────┘
```

**Spacing**:
- Icon → Title: **8dp**
- Title → Subtitle: **4dp**
- Card padding: **16dp** all sides

---

### 5. Animations & Interactions

**Animation Philosophy**:
- ✅ **Simple and fast** (150-200ms durations)
- ✅ **One purpose per animation** (no bounce + glow combos)
- ✅ **Consistent across app** (reusable system)
- ✅ **Performance-first** (minimal controllers)

**Press Interaction Flow**:

**onTapDown**:
1. `HapticFeedback.lightImpact()` - tactile feedback
2. Scale: `1.0 → 0.97` (150ms, easeOut)
3. Background overlay: `0% → 8%` accent color (150ms)
4. Icon swap: `outlined → filled` (200ms, ScaleTransition)
5. Border: `0% → 30%` accent color opacity (150ms, optional)

**onTapUp / onTap**:
1. Scale reverse: `0.97 → 1.0` (150ms, easeOut)
2. Background overlay fade out: `8% → 0%` (150ms)
3. Icon swap back: `filled → outlined` (200ms)
4. Border fade out: `30% → 0%` (150ms)
5. **Navigate** to destination route

**onTapCancel** (user drag outside):
- Same as onTapUp but **NO navigation**
- Smooth rollback to default state

**Animation Controllers**:
- **1 controller** for scale (vs 3 in old design)
- `AnimatedSwitcher` for icon (built-in)
- `AnimatedContainer` for background/border (implicit animations)
- **NO bounce, NO glow, NO elevation change**

**Removed Animations**:
- ❌ Bounce animation on release (ElasticOut curve)
- ❌ Glow effect (BoxShadow color spread)
- ❌ Elevation change (2dp → 8dp)
- ❌ Blur intensity change (BackdropFilter)

---

### 6. Standardization - Animation System

**Architecture Decision**: Constants + Wrapper Widget

This approach aligns with existing design system (`LoadingIndicator`, `SnackBarService`, `SemanticIcon`).

**Components**:

#### A. `AppAnimations` Constants
**File**: `lib/shared/presentation/constants/app_animations.dart`

```dart
/// Centralized animation constants for app-wide consistency
class AppAnimations {
  // === Durations ===
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration iconSwap = Duration(milliseconds: 200);

  // === Curves ===
  static const Curve standard = Curves.easeOut;
  static const Curve decelerate = Curves.easeOutCubic;

  // === Card Press Values ===
  static const double cardPressScale = 0.97;
  static const double pressOverlayOpacity = 0.08;
  static const double pressedBorderOpacity = 0.30;

  // === Icon Sizes ===
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 28.0;
  static const double iconSizeLarge = 32.0;

  private AppAnimations(); // Prevent instantiation
}
```

**Usage**:
```dart
// Anywhere in the app
AnimationController(
  duration: AppAnimations.fast,
  vsync: this,
);

Tween<double>(
  begin: 1.0,
  end: AppAnimations.cardPressScale,
);
```

**Benefits**:
- ✅ Single source of truth for animation values
- ✅ Easy to adjust app-wide timing/feel
- ✅ Prevents magic numbers
- ✅ Self-documenting code

---

#### B. `PressableCard` Widget
**File**: `lib/shared/presentation/widgets/pressable_card.dart`

**Purpose**: Reusable wrapper that handles press animations, haptics, and styling.

**API**:
```dart
class PressableCard extends StatefulWidget {
  const PressableCard({
    super.key,
    required this.child,
    required this.onTap,
    this.accentColor,
    this.showBorder = false,
    this.enableHaptics = true,
  });

  /// Content to display inside the card (icon + text layout)
  final Widget child;

  /// Callback when card is tapped
  final VoidCallback onTap;

  /// Accent color for pressed state (overlay, border, icon)
  final Color? accentColor;

  /// Whether to show border on press (default: false)
  final bool showBorder;

  /// Enable haptic feedback (default: true)
  final bool enableHaptics;
}
```

**Responsibilities**:
- ✅ Manage scale animation controller
- ✅ Handle gesture detection (onTapDown/Up/Cancel)
- ✅ Apply pressed state styling (overlay, border)
- ✅ Trigger haptic feedback
- ✅ Provide clean card container

**Does NOT handle**:
- ❌ Icon swap (responsibility of child widget)
- ❌ Navigation (caller provides onTap callback)
- ❌ Content layout (child widget provides it)

**Usage Example**:
```dart
PressableCard(
  accentColor: Color(0xFF6750A4),
  onTap: () => context.goNamed('analytics'),
  child: Column(
    children: [
      AnimatedIconSwap(
        outlinedIcon: Icons.analytics_outlined,
        filledIcon: Icons.analytics,
        isPressed: isPressed,
      ),
      SizedBox(height: 8),
      Text('Analytics'),
      Text('Track progress'),
    ],
  ),
)
```

**Benefits**:
- ✅ Reusable across entire app (not just homepage)
- ✅ Consistent press behavior everywhere
- ✅ Encapsulates animation complexity
- ✅ Easy to test in isolation
- ✅ Composition > inheritance (flexible content)

---

### 7. Implementation Architecture

**File Structure**:
```
lib/shared/presentation/
├── constants/
│   └── app_animations.dart          (NEW)
├── widgets/
│   ├── pressable_card.dart          (NEW)
│   └── animated_icon_swap.dart      (NEW - optional helper)

lib/features/home/presentation/widgets/
└── secondary_actions.dart           (REFACTOR)
```

**Changes to `secondary_actions.dart`**:

**Remove**:
- ❌ `_SecondaryActionCard` StatefulWidget (entire class)
- ❌ `_SecondaryActionCardState` with 3 animation controllers
- ❌ `_SecondaryActionColors` (move to constants if needed)
- ❌ `_showExerciseOptions` bottom sheet (consolidate to Progress only)

**Refactor**:
```dart
// Before: 7 complex cards with custom animations
_getSecondaryActions() {
  return [
    _SecondaryActionCard(...), // 7 times
  ];
}

// After: 4 simple cards using PressableCard
_getSecondaryActions() {
  return [
    PressableCard(
      accentColor: AppColors.analytics,
      onTap: () => context.goNamed('analytics'),
      child: _buildCardContent(
        icon: Icons.analytics_outlined,
        filledIcon: Icons.analytics,
        title: context.l10n.analytics,
        subtitle: context.l10n.trackProgress,
      ),
    ),
    // ... 3 more cards
  ];
}
```

**Grid Configuration**:
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,  // Changed from 3
    crossAxisSpacing: 8, // Changed from 12
    mainAxisSpacing: 8,  // Changed from 12
    childAspectRatio: 1.2, // Changed from 1.0
  ),
  itemCount: 4, // Changed from 7
  itemBuilder: (context, index) => actions[index],
)
```

**Navigation Mapping**:
```dart
final actions = [
  // Analytics
  onTap: () => context.goNamed('analytics'),

  // Settings
  onTap: () => context.goNamed('settings'),

  // Exercise Progress (new single destination)
  onTap: () => context.push('/exercise-progress'),

  // History
  onTap: () => context.pushNamed('workout-history'),
];
```

---

### 8. Accessibility

**Requirements**:

1. **Semantics Labels**:
```dart
Semantics(
  label: '${context.l10n.analytics} button. ${context.l10n.trackProgress}',
  button: true,
  child: PressableCard(...),
)
```

2. **Minimum Touch Targets**:
- Cards already >48x48dp (GridView handles sizing)
- If card is smaller, extend hit area with `SizedBox` wrapper

3. **Screen Reader Support**:
- Clear, descriptive labels
- Announce when pressed (platform handles with `button: true`)

4. **High Contrast Mode**:
- Test with system high contrast enabled
- Ensure border visibility in pressed state

5. **Dark/Light Mode**:
- All colors use `context.colors.*` (theme-aware)
- Test both modes for sufficient contrast

---

### 9. Testing Strategy

**Unit Tests**:
```dart
// test/shared/presentation/constants/app_animations_test.dart
test('AppAnimations constants are defined correctly', () {
  expect(AppAnimations.fast, Duration(milliseconds: 150));
  expect(AppAnimations.cardPressScale, 0.97);
});
```

**Widget Tests**:
```dart
// test/shared/presentation/widgets/pressable_card_test.dart
testWidgets('PressableCard scales on press', (tester) async {
  await tester.pumpWidget(
    PressableCard(
      onTap: () {},
      child: Text('Test'),
    ),
  );

  await tester.press(find.byType(PressableCard));
  await tester.pump();

  // Verify scale animation started
  expect(find.byWidgetPredicate((w) => w is Transform), findsOneWidget);
});

testWidgets('PressableCard triggers haptic feedback', (tester) async {
  // Mock HapticFeedback and verify call
});

testWidgets('PressableCard calls onTap callback', (tester) async {
  var tapped = false;
  await tester.pumpWidget(
    PressableCard(
      onTap: () => tapped = true,
      child: Text('Test'),
    ),
  );

  await tester.tap(find.byType(PressableCard));
  await tester.pumpAndSettle();

  expect(tapped, isTrue);
});
```

**Integration Tests**:
```dart
// test/features/home/presentation/widgets/secondary_actions_test.dart
testWidgets('SecondaryActions displays 4 cards', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SecondaryActions(),
        ),
      ),
    ),
  );

  expect(find.byType(PressableCard), findsNWidgets(4));
});

testWidgets('Analytics card navigates correctly', (tester) async {
  // Test navigation with mocked GoRouter
});
```

**Manual Testing Checklist**:
- [ ] Test on multiple screen sizes (phone, tablet)
- [ ] Test in dark and light themes
- [ ] Test with screen reader (VoiceOver/TalkBack)
- [ ] Test with high contrast mode
- [ ] Verify haptic feedback on physical device
- [ ] Test press animation smoothness (60fps)
- [ ] Test navigation to all 4 destinations
- [ ] Verify localization (EN + IT)

---

### 10. Performance Considerations

**Optimizations**:

1. **Reduced Animation Controllers**:
   - Old: 3 controllers per card × 7 cards = **21 controllers**
   - New: 1 controller per card × 4 cards = **4 controllers**
   - **81% reduction** in controller overhead

2. **No Blur Effects**:
   - Removed `BackdropFilter` (expensive on older devices)
   - Flat design = faster renders

3. **Const Constructors**:
```dart
const PressableCard(
  child: const Column(
    children: const [
      const Text('Analytics'),
    ],
  ),
)
```

4. **RepaintBoundary** (if needed):
```dart
RepaintBoundary(
  child: PressableCard(...),
)
```

5. **AnimatedBuilder Optimization**:
```dart
// Only rebuild what changes
AnimatedBuilder(
  animation: scaleAnimation,
  builder: (context, child) => Transform.scale(
    scale: scaleAnimation.value,
    child: child, // child is cached, doesn't rebuild
  ),
  child: _StaticCardContent(), // Built once
)
```

**Expected Performance Gains**:
- ✅ Faster initial render (less widgets)
- ✅ Smoother animations (fewer controllers)
- ✅ Lower memory usage (no blur buffers)
- ✅ Better battery life (less compositing)

---

### 11. Migration Path

**Step-by-Step Implementation**:

1. **Phase 1: Create Shared Components** (no breaking changes)
   - Create `app_animations.dart`
   - Create `pressable_card.dart`
   - Add tests for both
   - **Result**: New components available, old code unchanged

2. **Phase 2: Refactor SecondaryActions** (breaking changes)
   - Remove 3 cards (Community, Notifications, Import)
   - Replace `_SecondaryActionCard` with `PressableCard`
   - Update grid to 4 columns
   - Change Exercise card to single destination
   - **Result**: New design active

3. **Phase 3: Cleanup** (post-deployment)
   - Remove `_SecondaryActionCard` class
   - Remove `_SecondaryActionColors` class
   - Remove `_showExerciseOptions` method
   - **Result**: Cleaner codebase

**Rollback Strategy**:
- Keep old `_SecondaryActionCard` in git history
- If issues arise, revert `secondary_actions.dart` only
- Shared components (`PressableCard`) remain for future use

---

### 12. Localization Requirements

**New/Updated Keys**:

**Already Exist** (verify in ARB files):
- ✅ `analytics` - "Analytics"
- ✅ `trackProgress` - "Track Progress"
- ✅ `settings` - "Settings"
- ✅ `customizeApp` - "Customize App"
- ✅ `history` - "History"
- ✅ `viewPastWorkouts` - "View Past Workouts"

**Need to Add** (if missing):
```json
// assets/i18n/app_en.arb
{
  "exerciseProgress": "Exercise Progress",
  "trackExerciseGrowth": "Track your exercise gains"
}

// assets/i18n/app_it.arb
{
  "exerciseProgress": "Progressi Esercizi",
  "trackExerciseGrowth": "Monitora i tuoi miglioramenti"
}
```

**After adding**:
```bash
flutter gen-l10n
```

---

## Success Metrics

**Quantitative**:
- ✅ Animation controllers reduced by 81% (21 → 4)
- ✅ Card count reduced by 43% (7 → 4)
- ✅ Lines of code reduced by ~50% (628 → ~300 lines)
- ✅ Press interaction latency <150ms
- ✅ Render time <16ms (60fps)

**Qualitative**:
- ✅ Cleaner, more focused UI
- ✅ Easier cognitive load (fewer choices)
- ✅ Consistent with modern minimal design trends
- ✅ Reusable components for future features
- ✅ Better maintainability

---

## Future Enhancements (Out of Scope)

**Potential additions** (not in this phase):

1. **Badge Indicators**:
   - Show notification count on History card
   - "New" badge on recently added features

2. **Customization**:
   - User can reorder cards
   - User can hide/show cards
   - Saved to user preferences

3. **Animation Variants**:
   - Add `AppAnimations.bounce`, `AppAnimations.fade` presets
   - Allow per-card animation customization

4. **Dark Mode Enhancements**:
   - Subtle glow effect in dark mode only
   - Adjust accent colors for OLED screens

5. **Haptic Patterns**:
   - Different haptic feedback per card category
   - Success haptic on navigation

---

## References

**Related Documentation**:
- `docs/DESIGN_GUIDELINES.md` - Design system standards
- `docs/NAVIGATION/INDEX.md` - Documentation map
- `CLAUDE.md` - Project rules (Icon Design System, Localization)

**Related Components**:
- `lib/shared/presentation/theme/app_icons.dart` - Icon centralization
- `lib/shared/presentation/theme/app_icon_size.dart` - Icon sizing
- `lib/shared/presentation/widgets/semantic_icon.dart` - Accessible icons
- `lib/shared/presentation/widgets/loading_indicator.dart` - Unified loading

**Git Commits** (recent relevant changes):
- `b703b3e9` - "fix(workout): resolve exercise expand/collapse + fix all icon violations"
- `292e0ee2` - "feat(home): rename FAB to 'Sessione Libera' with analytics"

---

## Appendix: Visual Mockup

**Before (Current - Glassmorphism, 7 cards, 3 columns)**:
```
┌──────────────────────────────────────┐
│ Altri Strumenti                      │
├─────────┬─────────┬─────────┐
│Analytics│Settings │Exercises│ ← Row 1
│  [blur] │ [blur]  │ [blur]  │
├─────────┼─────────┼─────────┤
│Community│ History │Notific. │ ← Row 2
│ [blur]  │ [blur]  │ [blur]  │
├─────────┴─────────┴─────────┤
│     Import Exercises         │ ← Row 3
│          [blur]              │
└──────────────────────────────┘
```

**After (New - Minimal Flat, 4 cards, 4 columns)**:
```
┌──────────────────────────────────────┐
│ Altri Strumenti                      │
├────────┬────────┬────────┬────────┐
│Analytics│Settings│Progress│History │ ← Single Row
│   📊   │   ⚙️   │   📈   │   📚   │
│  flat  │  flat  │  flat  │  flat  │
└────────┴────────┴────────┴────────┘
```

**Card Detail (Pressed State)**:
```
Default State:           Pressed State:
┌──────────┐            ┌──────────┐
│   📊     │            │   📊     │ ← Icon: outlined → filled
│          │    →       │          │ ← Scale: 1.0 → 0.97
│Analytics │            │Analytics │ ← Color: accent color
│Track...  │            │Track...  │ ← Background: 8% overlay
└──────────┘            └─╌╌╌╌╌╌╌╌─┘ ← Border: 30% accent (optional)
```

---

## Conclusion

This redesign transforms the "Altri Strumenti" section into a modern, performant, and maintainable component that aligns with current design trends while respecting the project's Clean Architecture principles. The standardized animation system (`AppAnimations` + `PressableCard`) provides a foundation for consistent interactions across the entire app.

**Next Steps**:
1. Review and approve this design document
2. Create implementation plan with detailed tasks
3. Set up git worktree for isolated development
4. Implement Phase 1 (shared components)
5. Implement Phase 2 (refactor SecondaryActions)
6. Test thoroughly (unit, widget, integration)
7. Deploy and monitor performance metrics

---

**Design Status**: ✅ **Approved for Implementation**
