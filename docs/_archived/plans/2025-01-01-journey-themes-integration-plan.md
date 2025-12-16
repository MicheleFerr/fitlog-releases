# Journey Themes Integration - Task Plan

**Generated**: 2025-01-01 15:30
**Source**: task-master.dev (WebFetch) + Claude enrichment
**Complexity Score**: HIGH
**Reason**: Multi-system integration + Theme overhaul + 50+ widget updates
**Total Tasks**: 15
**Estimated Time**: ~5.5h
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: 3.16.0
- App Version: 1.0.0+49
- Key Packages: riverpod ^2.4.9, hive_ce_flutter ^2.6.0
- Target Platforms: iOS 14+, Android 8+
- Related PRs/Issues: None
- Parent Milestone: None
- Last Commit: 2bd70fcd feat(templates): add collapsible header with scroll animation

---

## 📋 Original Request

> "Integrate Journey Themes gamification feature into FitLog Pro app UI"
>
> Current state: Themes can be selected but don't change anything visually.
> Goal: Make theme selection actually theme the app with 6 different color schemes.

---

## 🎯 Task Breakdown

### Phase 1: Theme System Setup

- [ ] **Task 1.1**: Connect JourneyThemeExtension to MaterialApp
  - **Layer**: Presentation (App-level)
  - **Files**: `lib/app/app.dart`
  - **Dependencies**: None (blocking: 1.2, 1.3)
  - **Est. Time**: 30 min
  - **Blocking**: Yes (blocks all Phase 2)
  - **Verification**:
    - `MaterialApp.theme.extensions` contains `JourneyThemeExtension`
    - `context.journeyTheme` returns non-null in any widget
  - **Code Prompt**:
    ```dart
    // In app.dart, ThemeData creation:
    ThemeData(
      extensions: [
        JourneyThemeExtension.fromTheme(
          theme: selectedJourneyTheme,
          userTier: currentUserTier,
          brightness: brightness,
        ),
      ],
    )
    ```

- [ ] **Task 1.2**: Create journeyThemeProvider listener in app.dart
  - **Layer**: Presentation (App-level)
  - **Files**: `lib/app/app.dart`
  - **Dependencies**: 1.1
  - **Est. Time**: 45 min
  - **Blocking**: Yes (blocks all Phase 2)
  - **Verification**:
    - App rebuilds when `journeyThemeProvider` changes
    - `ref.watch(journeyThemeProvider)` triggers rebuild
    - Theme changes propagate to all widgets
  - **Code Prompt**:
    ```dart
    // Convert App to ConsumerWidget
    class App extends ConsumerWidget {
      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final journeyThemeState = ref.watch(journeyThemeProvider);
        final themeMode = ref.watch(appConfigProvider).themeMode;

        return MaterialApp(
          theme: _buildTheme(Brightness.light, journeyThemeState),
          darkTheme: _buildTheme(Brightness.dark, journeyThemeState),
          themeMode: themeMode,
        );
      }
    }
    ```

- [ ] **Task 1.3**: Implement smooth theme transition animation
  - **Layer**: Presentation (App-level)
  - **Files**: `lib/app/app.dart`
  - **Dependencies**: 1.2
  - **Est. Time**: 30 min
  - **Blocking**: No
  - **⚠️ IMPORTANT**: This is a UNIVERSAL transition (applies to all themes equally).
    Theme-specific animations are NOT allowed (design policy: avoid inconsistencies).
    The "animations" unlockable feature has been removed from the codebase.
  - **Verification**:
    - 300ms fade transition when switching themes
    - No jarring color jumps
    - Smooth in both light/dark mode
    - Same transition for ALL 6 themes (no theme-specific variants)
  - **Code Prompt**:
    ```dart
    return AnimatedTheme(
      data: currentTheme,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: MaterialApp(...),
    )
    ```

---

### Phase 2: Widget Integration

- [ ] **Task 2.1**: Update primary CTA buttons with journey theme colors
  - **Layer**: Presentation (Widgets)
  - **Files**:
    - `lib/features/workout/presentation/workout_screen.dart` (start workout button)
    - `lib/features/home/presentation/minimal_home_screen.dart` (quick start)
    - `lib/features/workout/presentation/widgets/*.dart` (action buttons)
  - **Dependencies**: 1.2
  - **Est. Time**: 20 min
  - **Blocking**: No
  - **Verification**:
    - Buttons reflect selected theme in light mode
    - Buttons reflect selected theme in dark mode
    - All 6 themes tested
  - **Code Prompt**:
    ```dart
    // Replace:
    FilledButton(
      style: FilledButton.styleFrom(backgroundColor: context.colors.primary),
    )

    // With:
    FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: context.journeyTheme?.primaryColor ?? context.colors.primary,
      ),
    )
    ```

- [ ] **Task 2.2**: Update card/surface widgets with accent colors
  - **Layer**: Presentation (Widgets)
  - **Files**:
    - `lib/features/analytics/presentation/widgets/*_card.dart`
    - `lib/features/home/presentation/widgets/customizable_workout_card.dart`
    - `lib/features/workout/presentation/widgets/exercise_list_item.dart`
  - **Dependencies**: 1.2
  - **Est. Time**: 25 min
  - **Blocking**: No
  - **Verification**:
    - Card backgrounds use `cardGradient` or `accentColor`
    - Visual distinction between themes clear
  - **Code Prompt**:
    ```dart
    Container(
      decoration: context.journeyTheme?.getCardDecoration(
        borderRadius: BorderRadius.circular(16),
        useGradient: true,
      ) ?? BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
    )
    ```

- [ ] **Task 2.3**: Update progress indicators with theme gradients
  - **Layer**: Presentation (Widgets)
  - **Files**:
    - `lib/features/analytics/presentation/widgets/pr_celebration_modal.dart`
    - `lib/features/home/presentation/widgets/*.dart` (progress widgets)
    - `lib/features/profile/presentation/widgets/compact_profile_header.dart` (XP bar)
  - **Dependencies**: 1.2
  - **Est. Time**: 35 min
  - **Blocking**: No
  - **Verification**:
    - Progress bars use `primaryGradient`
    - Circular indicators themed
  - **Code Prompt**:
    ```dart
    LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
        context.journeyTheme?.primaryColor ?? context.colors.primary,
      ),
      backgroundColor: context.journeyTheme?.accentColor.withValues(alpha: 0.2),
    )
    ```

- [ ] **Task 2.4**: Update navigation elements (bottom bar, app bar)
  - **Layer**: Presentation (Navigation)
  - **Files**:
    - `lib/core/navigation/main_shell.dart`
    - `lib/features/*/presentation/*_screen.dart` (AppBar widgets)
  - **Dependencies**: 1.2
  - **Est. Time**: 30 min
  - **Blocking**: No
  - **Verification**:
    - Bottom nav selected item uses theme color
    - AppBar backgrounds respect theme
  - **Code Prompt**:
    ```dart
    BottomNavigationBar(
      selectedItemColor: context.journeyTheme?.primaryColor ?? context.colors.primary,
    )
    ```

- [ ] **Task 2.5**: Update badge/chip components
  - **Layer**: Presentation (Widgets)
  - **Files**:
    - `lib/features/workout/presentation/widgets/*.dart` (set badges)
    - `lib/features/analytics/presentation/widgets/*.dart` (achievement chips)
  - **Dependencies**: 1.2
  - **Est. Time**: 20 min
  - **Blocking**: No
  - **Verification**:
    - Badges render in theme colors
    - Chips use `accentColor`

---

### Phase 3: Dark Mode Compliance

- [ ] **Task 3.1**: Validate theme contrast in dark mode
  - **Layer**: Testing
  - **Files**: Manual testing across all screens
  - **Dependencies**: 2.5
  - **Est. Time**: 25 min
  - **Blocking**: No
  - **Verification**:
    - All text meets WCAG AA (4.5:1 ratio) in dark mode
    - Use Chrome DevTools contrast checker
    - Test all 6 themes × dark mode
  - **Testing Script**:
    ```bash
    # For each theme in dark mode:
    # 1. Open app in dark mode
    # 2. Select theme
    # 3. Navigate to 5 key screens
    # 4. Screenshot + contrast check
    ```

- [ ] **Task 3.2**: Add platform-specific dark mode handling
  - **Layer**: Presentation (App-level)
  - **Files**: `lib/app/app.dart`
  - **Dependencies**: 3.1
  - **Est. Time**: 20 min
  - **Blocking**: No
  - **Verification**:
    - iOS system dark mode triggers app dark theme
    - Android system dark mode triggers app dark theme
  - **Code Prompt**:
    ```dart
    themeMode: ref.watch(appConfigProvider).themeMode, // system/light/dark
    ```

---

### Phase 4: Localization & Quality

- [ ] **Task 4.1**: Audit all theme-related strings for hardcoded values
  - **Layer**: Presentation
  - **Files**:
    - `lib/features/journey_themes/presentation/widgets/*.dart`
    - `assets/i18n/app_en.arb`, `app_it.arb`
  - **Dependencies**: 2.5
  - **Est. Time**: 15 min
  - **Blocking**: No
  - **Verification**:
    - Zero hardcoded strings in theme UI
    - `./scripts/find_hardcoded_strings.sh` passes
  - **Script**:
    ```bash
    ./scripts/find_hardcoded_strings.sh lib/features/journey_themes/
    ```

- [ ] **Task 4.2**: Verify EN/IT localization in theme selector
  - **Layer**: Presentation
  - **Files**: `lib/features/journey_themes/presentation/widgets/journey_theme_selector_modal.dart`
  - **Dependencies**: 4.1
  - **Est. Time**: 20 min
  - **Blocking**: No
  - **Verification**:
    - Theme names display in EN/IT
    - `flutter gen-l10n` regenerates strings
  - **Test**:
    ```dart
    // In simulator:
    // Settings → Language → Italian
    // Open Journey Themes modal
    // Verify "Cacciatore" not "Hunter"
    ```

- [ ] **Task 4.3**: Run flutter analyze and fix diagnostics
  - **Layer**: Quality
  - **Files**: All modified files
  - **Dependencies**: All previous tasks
  - **Est. Time**: 30 min
  - **Blocking**: No
  - **Verification**:
    - `flutter analyze` returns 0 issues
    - No unused imports
    - No type warnings
  - **Script**:
    ```bash
    flutter analyze lib/app/app.dart
    flutter analyze lib/features/journey_themes/
    ```

---

### Phase 5: Testing & Rollout

- [ ] **Task 5.1**: Manual theme switching regression test
  - **Layer**: Testing
  - **Files**: Manual test checklist
  - **Dependencies**: All implementation tasks
  - **Est. Time**: 40 min
  - **Blocking**: No
  - **Verification**:
    - 6 themes × 2 modes (light/dark) = 12 combinations tested
    - No UI breaks on 20+ screens
  - **Test Plan**:
    ```
    For each theme (Hunter, Hero, Warrior Goddess, Nature Spirit, Phoenix, Frost):
      1. Light mode: Home → Workout → Analytics → Profile
      2. Dark mode: Home → Workout → Analytics → Profile
      3. Verify colors apply correctly
      4. Screenshot for visual regression baseline
    ```

- [ ] **Task 5.2**: Create theme integration test suite
  - **Layer**: Testing
  - **Files**: `test/features/journey_themes/presentation/theme_integration_test.dart`
  - **Dependencies**: All implementation tasks
  - **Est. Time**: 45 min
  - **Blocking**: No
  - **Verification**:
    - Widget tests confirm `context.journeyTheme` accessible
    - Color application verified for 5+ key widgets
  - **Test Template**:
    ```dart
    testWidgets('Journey theme colors apply to FilledButton', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            journeyThemeProvider.overrideWith((ref) =>
              JourneyThemeState(selectedTheme: JourneyTheme.phoenix)
            ),
          ],
          child: MaterialApp(home: MyButton()),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.style?.backgroundColor?.resolve({}),
        equals(JourneyTheme.phoenix.primaryColor));
    });
    ```

---

## 📊 Implementation Order

**MUST DO FIRST** (blocking tasks):
→ Task 1.1, 1.2 (theme system integration) - ~1h 15min

**THEN** (parallel workable):
→ Task 2.1-2.5 (widget updates) - ~2h 10min
→ Task 1.3 (animations - can be done alongside 2.x) - ~30min

**THEN** (testing & validation):
→ Task 3.1-3.2 (dark mode) - ~45min
→ Task 4.1-4.3 (localization + quality) - ~1h 5min

**FINALLY** (verification):
→ Task 5.1-5.2 (testing) - ~1h 25min

**Total Critical Path**: ~5.5h

---

## 🎯 FitLog Pro Specific Requirements

**Design System Compliance**:
- ✅ Must use `context.l10n.*` (no hardcoded strings)
- ✅ Must use `AppIcons.*` (no `Icons.*` inline)
- ✅ Must use `AppIconSize.*` constants
- ✅ Must use `SemanticIcon` for accessibility
- ✅ Must use `LoadingIndicator` (not raw CircularProgressIndicator)
- ✅ Must test in light AND dark themes

**Pre-commit Hook Checks**:
- ✅ No `const` with `context.l10n` (iOS build error)
- ✅ No hardcoded Colors.* (theme violations)
- ✅ No `Icons.*` inline (use AppIcons)
- ✅ `flutter analyze` must pass

**Testing Phase Note**:
- App in single-user testing → breaking changes OK
- No backward compatibility needed
- Can aggressively refactor

---

## 🔗 Cross-Cutting Concerns

**Fallback Strategy**:
```dart
// Always provide fallback to Material Theme
final themeColor = context.journeyTheme?.primaryColor ?? context.colors.primary;
```

**Breaking Changes**: None - new extension coexists with existing theme system

**Rollout Pattern**:
1. Phase 1 (system) first
2. Phase 2 (high-visibility widgets) second
3. Phase 3-5 (polish) last

**Performance**:
- Theme changes trigger full app rebuild (expected)
- Use `AnimatedTheme` for smooth transitions
- No performance impact on steady state

---

## 📝 Notes & Decisions

**Date**: 2025-01-01 15:30
**Decision**: Use gradual rollout - update high-impact widgets first
**Rationale**: Minimizes risk, allows incremental testing

**Date**: 2025-12-01 (Implementation Phase - Pre-Integration)
**Decision**: NO theme-specific animations allowed
**Rationale**: Avoid visual inconsistencies across themes. Only universal AnimatedTheme transition (300ms fade) is permitted when switching themes. All 6 themes must use identical transition behavior.
**Actions Taken**:
- ✅ Removed "animations" unlockable feature from `unlockable_feature.dart` (Gold tier, lines 148-154)
- ✅ Removed `isAnimationsEnabled` field from `JourneyThemeExtension` (all occurrences: constructor, factory, field declaration, copyWith, lerp)
- ✅ Updated Task 1.3 with warning about universal-only transitions
**Files Modified**:
- `lib/features/journey_themes/domain/entities/unlockable_feature.dart`
- `lib/features/journey_themes/presentation/theme/journey_theme_extension.dart`

---

## ✅ Success Criteria

- [ ] User can select any of 6 themes from Settings → Journey Themes
- [ ] Selected theme visually changes app colors (primary buttons, cards, progress bars)
- [ ] Theme persists across app restarts (Hive storage working)
- [ ] Theme works correctly in light AND dark mode
- [ ] All text remains readable (WCAG AA contrast)
- [ ] No hardcoded strings (localization compliance)
- [ ] `flutter analyze` passes with 0 errors
- [ ] Pre-commit hook passes
- [ ] Manual regression test completed (12 combinations)

---

## 🚀 Next Steps After Completion

1. Document feature in `docs/UX_FLOWS/JOURNEY_THEMES_DOCUMENTATION.md`
2. Update `docs/NAVIGATION/INDEX.md` with new links
3. Update `CLAUDE.md` feature mapping table
4. Consider gradual rollout to more widgets in Phase 2+
5. Gather user feedback on theme variety

---

**Plan saved**: `docs/plans/2025-01-01-journey-themes-integration-plan.md`
