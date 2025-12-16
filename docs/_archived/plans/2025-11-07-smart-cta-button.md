# Smart CTA Button - Phase 1 MVP Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement context-aware CTA button that adapts to user state (completed workout today, rest day, scheduled workout, explore) using only GDPR-safe workout metadata.

**Architecture:** Replace/enhance existing `DailyWorkoutCard` with intelligent state detection logic. Use existing Riverpod providers (`completedWorkoutsByDateProvider`, `activeFlexibleRoutineProvider`) to determine button state without collecting new data.

**Tech Stack:** Flutter, Riverpod, Freezed, Intl (localization)

---

## Prerequisites

- ✅ Design document: `docs/plans/2025-11-07-smart-cta-button-design.md`
- ✅ Existing providers: `completedWorkoutsByDateProvider`, `activeFlexibleRoutineProvider`
- ✅ Existing `DailyWorkoutCard` widget

---

## Task 1: Create SmartButtonState Enum

**Files:**
- Create: `lib/features/routine/presentation/widgets/smart_cta_button/smart_button_state.dart`

**Step 1: Create directory structure**

```bash
mkdir -p lib/features/routine/presentation/widgets/smart_cta_button
```

**Step 2: Create enum file**

Create `lib/features/routine/presentation/widgets/smart_cta_button/smart_button_state.dart`:

```dart
/// Smart CTA Button State
///
/// Defines the possible states of the context-aware CTA button
/// based on user's current training status.
enum SmartButtonState {
  /// User has not completed workout today and has scheduled workout
  /// Shows: "💪 Inizia [Workout Name]"
  activeWorkout,

  /// User has completed workout today
  /// Shows: "✅ Visualizza Recap"
  completedToday,

  /// Today is a scheduled rest day
  /// Shows: "😌 Riposa. Prossimo: [date]"
  restDay,

  /// No workout scheduled today and no workout completed
  /// Shows: "📅 Esplora Workout"
  noScheduled,
}

/// Extension to get user-friendly description
extension SmartButtonStateExtension on SmartButtonState {
  String get description {
    switch (this) {
      case SmartButtonState.activeWorkout:
        return 'Active workout scheduled';
      case SmartButtonState.completedToday:
        return 'Workout completed today';
      case SmartButtonState.restDay:
        return 'Rest day scheduled';
      case SmartButtonState.noScheduled:
        return 'No workout scheduled';
    }
  }
}
```

**Step 3: Verify file compiles**

Run: `flutter analyze lib/features/routine/presentation/widgets/smart_cta_button/smart_button_state.dart`

Expected: "No issues found!"

**Step 4: Commit**

```bash
git add lib/features/routine/presentation/widgets/smart_cta_button/smart_button_state.dart
git commit -m "feat: add SmartButtonState enum for context-aware CTA

- Define 4 states: activeWorkout, completedToday, restDay, noScheduled
- Add extension for user-friendly descriptions
- Part of Smart CTA Button Phase 1 MVP"
```

---

## Task 2: Add Localization Keys

**Files:**
- Modify: `assets/i18n/app_en.arb`
- Modify: `assets/i18n/app_it.arb`

**Step 1: Add English keys**

Add to `assets/i18n/app_en.arb` (after last entry, before closing `}`):

```json
,
"smartButtonStartWorkout": "Start {workoutName}",
"@smartButtonStartWorkout": {
  "description": "CTA button label to start scheduled workout",
  "placeholders": {
    "workoutName": {
      "type": "String"
    }
  }
},
"smartButtonViewRecap": "View Recap",
"@smartButtonViewRecap": {
  "description": "CTA button label to view completed workout"
},
"smartButtonRestDay": "Rest. Next: {nextDate}",
"@smartButtonRestDay": {
  "description": "CTA button label for rest day",
  "placeholders": {
    "nextDate": {
      "type": "String"
    }
  }
},
"smartButtonExploreWorkouts": "Explore Workouts",
"@smartButtonExploreWorkouts": {
  "description": "CTA button label to explore workout library"
},
"smartButtonRecoveryTips": "Recovery Tips",
"@smartButtonRecoveryTips": {
  "description": "Link to view recovery tips on rest day"
}
```

**Step 2: Add Italian translations**

Add to `assets/i18n/app_it.arb` (after last entry, before closing `}`):

```json
,
"smartButtonStartWorkout": "Inizia {workoutName}",
"smartButtonViewRecap": "Visualizza Recap",
"smartButtonRestDay": "Riposa. Prossimo: {nextDate}",
"smartButtonExploreWorkouts": "Esplora Workout",
"smartButtonRecoveryTips": "Consigli Recupero"
```

**Step 3: Regenerate localizations**

Run: `flutter gen-l10n`

Expected: "Generating localizations... Done."

**Step 4: Verify generated files**

Run: `grep -A 5 "smartButtonStartWorkout" lib/shared/presentation/l10n/generated/app_localizations.dart`

Expected: Should see generated getter methods

**Step 5: Commit**

```bash
git add assets/i18n/app_en.arb assets/i18n/app_it.arb lib/shared/presentation/l10n/generated/
git commit -m "feat: add Smart CTA Button localization keys

- Add 5 new keys: startWorkout, viewRecap, restDay, exploreWorkouts, recoveryTips
- English and Italian translations
- Part of Smart CTA Button Phase 1 MVP"
```

---

## Task 3: Create SmartCTAButton Widget (Core Logic)

**Files:**
- Create: `lib/features/routine/presentation/widgets/smart_cta_button/smart_cta_button.dart`

**Step 1: Create widget skeleton**

Create `lib/features/routine/presentation/widgets/smart_cta_button/smart_cta_button.dart`:

```dart
/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets/smart_cta_button
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// SMART CTA BUTTON - Context-aware call-to-action button
///
/// Features:
/// - Auto-detects user state (completed today, rest day, scheduled, etc.)
/// - Adapts UI and action based on state
/// - GDPR-compliant (uses only workout metadata, no health data)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/smart_cta_button/smart_button_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Smart CTA Button - Context-aware workout action button
class SmartCTAButton extends ConsumerWidget {
  const SmartCTAButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();

    // Watch active routine
    final activeRoutineAsync = ref.watch(activeFlexibleRoutineProvider);

    // Watch completed workouts today
    final completedTodayAsync = ref.watch(
      completedWorkoutsByDateProvider(today),
    );

    return activeRoutineAsync.when(
      data: (routine) {
        if (routine == null) {
          return _buildNoRoutineState(context);
        }

        return completedTodayAsync.when(
          data: (completedWorkouts) {
            final state = _determineState(
              routine: routine,
              today: today,
              hasCompletedToday: completedWorkouts.isNotEmpty,
            );
            return _buildButton(context, state, routine, today);
          },
          loading: () => const LoadingIndicator(),
          error: (_, __) => _buildErrorState(context),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (_, __) => _buildErrorState(context),
    );
  }

  /// Determine button state based on user's current status
  SmartButtonState _determineState({
    required FlexibleRoutine routine,
    required DateTime today,
    required bool hasCompletedToday,
  }) {
    // If workout completed today → show recap
    if (hasCompletedToday) {
      return SmartButtonState.completedToday;
    }

    final dayInfo = routine.getDayInfo(today);

    // No day info → no workout scheduled
    if (dayInfo == null) {
      return SmartButtonState.noScheduled;
    }

    // Rest day scheduled
    if (dayInfo.status == DayStatus.rest) {
      return SmartButtonState.restDay;
    }

    // Workout scheduled but not completed
    if (dayInfo.status == DayStatus.scheduled) {
      return SmartButtonState.activeWorkout;
    }

    // Default: no scheduled
    return SmartButtonState.noScheduled;
  }

  /// Build button based on state
  Widget _buildButton(
    BuildContext context,
    SmartButtonState state,
    FlexibleRoutine routine,
    DateTime today,
  ) {
    switch (state) {
      case SmartButtonState.activeWorkout:
        final dayInfo = routine.getDayInfo(today)!;
        return _buildActiveWorkoutButton(context, dayInfo);

      case SmartButtonState.completedToday:
        return _buildCompletedButton(context);

      case SmartButtonState.restDay:
        final nextWorkoutDate = _findNextWorkoutDate(routine, today);
        return _buildRestButton(context, nextWorkoutDate);

      case SmartButtonState.noScheduled:
        return _buildExploreButton(context);
    }
  }

  /// Build active workout button (primary CTA)
  Widget _buildActiveWorkoutButton(BuildContext context, DayInfo dayInfo) {
    final workoutName = dayInfo.templateId ?? 'Workout';

    return ElevatedButton.icon(
      onPressed: () => _startWorkout(context, dayInfo),
      icon: Icon(AppIcons.workout, size: AppIconSize.medium),
      label: Text(
        context.l10n.smartButtonStartWorkout(workoutName),
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Build completed workout button (view recap)
  Widget _buildCompletedButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _viewWorkoutSummary(context),
      icon: Icon(AppIcons.complete, size: AppIconSize.medium),
      label: Text(
        context.l10n.smartButtonViewRecap,
        style: context.textTheme.titleMedium,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colors.success,
        side: BorderSide(color: context.colors.success, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Build rest day button (with recovery tips)
  Widget _buildRestButton(BuildContext context, DateTime? nextDate) {
    final nextDateStr = nextDate != null
        ? _formatDate(context, nextDate)
        : context.l10n.tomorrow;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.secondary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.bedtime,
            size: AppIconSize.xlarge,
            color: context.colors.secondary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.smartButtonRestDay(nextDateStr),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => _showRecoveryTips(context),
                  child: Text(context.l10n.smartButtonRecoveryTips),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build explore workouts button (fallback)
  Widget _buildExploreButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _exploreWorkouts(context),
      icon: Icon(AppIcons.search, size: AppIconSize.medium),
      label: Text(context.l10n.smartButtonExploreWorkouts),
      style: TextButton.styleFrom(
        foregroundColor: context.colors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }

  /// Build no routine state (create routine CTA)
  Widget _buildNoRoutineState(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/routine/create'),
      child: Text(context.l10n.createRoutine),
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context) {
    return Text(
      context.l10n.errorLoadingData,
      style: TextStyle(color: context.colors.error),
    );
  }

  /// Find next scheduled workout date
  DateTime? _findNextWorkoutDate(FlexibleRoutine routine, DateTime today) {
    for (int i = 1; i <= 7; i++) {
      final nextDate = today.add(Duration(days: i));
      final dayInfo = routine.getDayInfo(nextDate);
      if (dayInfo?.status == DayStatus.scheduled) {
        return nextDate;
      }
    }
    return null;
  }

  /// Format date for display (today/tomorrow/date)
  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final diff = targetDate.difference(today).inDays;

    if (diff == 0) return context.l10n.today;
    if (diff == 1) return context.l10n.tomorrow;

    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('E d MMM', locale);
    return dateFormat.format(date);
  }

  // Action handlers (TODO: implement navigation)

  void _startWorkout(BuildContext context, DayInfo dayInfo) {
    // TODO: Navigate to workout screen
    // Navigator.pushNamed(context, '/workout/start',
    //     arguments: {'templateId': dayInfo.templateId});
    debugPrint('🏋️ Starting workout: ${dayInfo.templateId}');
  }

  void _viewWorkoutSummary(BuildContext context) {
    // TODO: Navigate to today's workout summary
    // Navigator.pushNamed(context, '/workout/history/today');
    debugPrint('📊 Viewing workout summary');
  }

  void _showRecoveryTips(BuildContext context) {
    // TODO: Show recovery tips modal
    // ModalService.showModal(context: context, child: RecoveryTipsModal());
    debugPrint('💡 Showing recovery tips');
  }

  void _exploreWorkouts(BuildContext context) {
    // TODO: Navigate to workout library
    // Navigator.pushNamed(context, '/workout/library');
    debugPrint('🔍 Exploring workouts');
  }
}
```

**Step 2: Verify file compiles**

Run: `flutter analyze lib/features/routine/presentation/widgets/smart_cta_button/smart_cta_button.dart`

Expected: "No issues found!" (or warnings about unused imports, which is ok)

**Step 3: Commit**

```bash
git add lib/features/routine/presentation/widgets/smart_cta_button/smart_cta_button.dart
git commit -m "feat: implement SmartCTAButton core widget

- State detection logic using existing providers
- 4 button states: active, completed, rest, noScheduled
- Localized UI with context-aware labels
- Action handlers (TODOs for navigation)
- GDPR-compliant (workout metadata only)
- Part of Smart CTA Button Phase 1 MVP"
```

---

## Task 4: Create Barrel Export

**Files:**
- Create: `lib/features/routine/presentation/widgets/smart_cta_button/smart_cta_button_exports.dart`

**Step 1: Create barrel export file**

Create `lib/features/routine/presentation/widgets/smart_cta_button/smart_cta_button_exports.dart`:

```dart
/// Smart CTA Button - Barrel export
///
/// Exports all public classes for Smart CTA Button feature
library;

export 'smart_button_state.dart';
export 'smart_cta_button.dart';
```

**Step 2: Verify file compiles**

Run: `flutter analyze lib/features/routine/presentation/widgets/smart_cta_button/`

Expected: "No issues found!"

**Step 3: Commit**

```bash
git add lib/features/routine/presentation/widgets/smart_cta_button/smart_cta_button_exports.dart
git commit -m "feat: add barrel export for SmartCTAButton

- Export smart_button_state and smart_cta_button
- Clean import syntax for consumers"
```

---

## Task 5: Integrate into Home Screen

**Files:**
- Modify: `lib/features/routine/presentation/screens/routine_home_screen.dart` (or wherever DailyWorkoutCard is used)

**Step 1: Find current usage of DailyWorkoutCard**

Run: `grep -rn "DailyWorkoutCard" lib/features/routine/presentation/screens/ --include="*.dart"`

Expected: Should show file(s) using DailyWorkoutCard

**Step 2: Add SmartCTAButton import**

Add to imports section of the file found in Step 1:

```dart
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/smart_cta_button/smart_cta_button_exports.dart';
```

**Step 3: Replace or add SmartCTAButton**

Option A - If replacing DailyWorkoutCard entirely:
```dart
// Before:
DailyWorkoutCard(
  routine: routine,
  date: today,
  onComplete: () => ...,
  onSkip: () => ...,
)

// After:
SmartCTAButton()
```

Option B - If adding alongside existing card:
```dart
Column(
  children: [
    // Existing DailyWorkoutCard (keep for now)
    DailyWorkoutCard(...),

    const SizedBox(height: 16),

    // New SmartCTAButton
    SmartCTAButton(),
  ],
)
```

**Note:** Exact modification depends on current structure. Engineer should inspect file and adapt accordingly.

**Step 4: Test in running app**

Run: `flutter run` (if not already running) or hot reload

Expected: Should see button rendering with appropriate state

**Step 5: Verify different states**

Test scenarios:
1. **No workout today + scheduled** → Should show "Inizia [workout]"
2. **Completed workout today** → Should show "Visualizza Recap"
3. **Rest day scheduled** → Should show "Riposa. Prossimo: [date]"
4. **No workout scheduled** → Should show "Esplora Workout"

**Step 6: Commit**

```bash
git add lib/features/routine/presentation/screens/[filename].dart
git commit -m "feat: integrate SmartCTAButton into home screen

- Add SmartCTAButton to routine home screen
- [Replace/Add alongside] existing DailyWorkoutCard
- Part of Smart CTA Button Phase 1 MVP"
```

---

## Task 6: Manual Testing Checklist

**Files:**
- None (manual testing)

**Step 1: Test Active Workout State**

Preconditions:
- Have active routine with today scheduled
- No workout completed today

Actions:
1. Open app
2. Navigate to home screen
3. Verify button shows "💪 Inizia [Workout Name]"
4. Tap button
5. Verify debug print: "🏋️ Starting workout: [templateId]"

**Step 2: Test Completed Today State**

Preconditions:
- Have active routine
- Complete a workout today

Actions:
1. Complete a workout (any workout)
2. Return to home screen
3. Verify button shows "✅ Visualizza Recap"
4. Tap button
5. Verify debug print: "📊 Viewing workout summary"

**Step 3: Test Rest Day State**

Preconditions:
- Have active routine with today as rest day

Actions:
1. Navigate to routine editor
2. Set today as rest day
3. Return to home screen
4. Verify button shows "😌 Riposa. Prossimo: [date]"
5. Tap "Consigli Recupero" link
6. Verify debug print: "💡 Showing recovery tips"

**Step 4: Test No Scheduled State**

Preconditions:
- Have active routine
- Today not scheduled
- No workout completed today

Actions:
1. Navigate to routine editor
2. Remove today's scheduled workout
3. Return to home screen
4. Verify button shows "📅 Esplora Workout"
5. Tap button
6. Verify debug print: "🔍 Exploring workouts"

**Step 5: Test No Routine State**

Preconditions:
- No active routine

Actions:
1. Archive/delete all routines
2. Return to home screen
3. Verify button shows "Create Routine" or similar
4. Tap button
5. Verify navigation to routine creation

**Step 6: Test Localization**

Actions:
1. Change app language to Italian
2. Verify all labels are in Italian
3. Change back to English
4. Verify all labels are in English

**Step 7: Test Theme Modes**

Actions:
1. Switch to dark mode
2. Verify button colors adapt correctly
3. Switch to light mode
4. Verify button colors adapt correctly

**Step 8: Document test results**

Create: `docs/plans/2025-11-07-smart-cta-button-test-results.md`

```markdown
# Smart CTA Button - Test Results

Date: [YYYY-MM-DD]
Tester: [Name]

## Test Scenarios

### 1. Active Workout State
- [ ] Button displays correct label
- [ ] Button shows workout name
- [ ] Tap triggers debug print
- [ ] Button styling correct

### 2. Completed Today State
- [ ] Button displays "Visualizza Recap"
- [ ] Button styling (outlined green) correct
- [ ] Tap triggers debug print

### 3. Rest Day State
- [ ] Button displays rest day message
- [ ] Next workout date shown
- [ ] Recovery tips link works
- [ ] Container styling correct

### 4. No Scheduled State
- [ ] Button displays "Esplora Workout"
- [ ] Tap triggers debug print

### 5. No Routine State
- [ ] Button shows create routine CTA
- [ ] Navigation works

### 6. Localization
- [ ] Italian labels correct
- [ ] English labels correct

### 7. Theme Modes
- [ ] Dark mode styling correct
- [ ] Light mode styling correct

## Issues Found

[List any bugs or issues discovered]

## Sign-off

Tested by: [Name]
Date: [Date]
Status: [PASS/FAIL/PARTIAL]
```

**Step 9: Commit test results**

```bash
git add docs/plans/2025-11-07-smart-cta-button-test-results.md
git commit -m "test: add Smart CTA Button manual test results

- Document test scenarios and results
- Part of Smart CTA Button Phase 1 MVP"
```

---

## Task 7: Implement Navigation Actions (Optional - Post-MVP)

**Files:**
- Modify: `lib/features/routine/presentation/widgets/smart_cta_button/smart_cta_button.dart`

**Note:** This task is OPTIONAL for Phase 1 MVP. Debug prints are sufficient for initial testing. Implement actual navigation in Phase 2 or after MVP validation.

**Step 1: Implement _startWorkout navigation**

Replace debug print with actual navigation:

```dart
void _startWorkout(BuildContext context, DayInfo dayInfo) {
  Navigator.pushNamed(
    context,
    '/workout/start',
    arguments: {'templateId': dayInfo.templateId},
  );
}
```

**Step 2: Implement _viewWorkoutSummary navigation**

Replace debug print with actual navigation:

```dart
void _viewWorkoutSummary(BuildContext context) {
  Navigator.pushNamed(context, '/workout/history/today');
}
```

**Step 3: Implement _showRecoveryTips modal**

Replace debug print with modal:

```dart
void _showRecoveryTips(BuildContext context) {
  ModalService.showModal(
    context: context,
    child: RecoveryTipsModal(), // Create this widget if needed
  );
}
```

**Step 4: Implement _exploreWorkouts navigation**

Replace debug print with actual navigation:

```dart
void _exploreWorkouts(BuildContext context) {
  Navigator.pushNamed(context, '/workout/library');
}
```

**Step 5: Test navigation flows**

Verify each navigation works correctly in the app.

**Step 6: Commit**

```bash
git add lib/features/routine/presentation/widgets/smart_cta_button/smart_cta_button.dart
git commit -m "feat: implement navigation actions for SmartCTAButton

- Add actual navigation to workout start
- Add navigation to workout history
- Add recovery tips modal
- Add navigation to workout library
- Part of Smart CTA Button Phase 1 MVP"
```

---

## Task 8: Setup A/B Test Telemetry (Phase 2 - Optional)

**Files:**
- Create: `lib/features/routine/application/services/smart_button_analytics_service.dart`

**Note:** This task is for Phase 2 when you want to measure engagement. Skip for initial MVP.

**Step 1: Create analytics service**

Create `lib/features/routine/application/services/smart_button_analytics_service.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Analytics service for Smart CTA Button
class SmartButtonAnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Track button visibility
  Future<void> trackButtonVisible(String state) async {
    await _analytics.logEvent(
      name: 'smart_button_visible',
      parameters: {'state': state},
    );
  }

  /// Track button tap
  Future<void> trackButtonTap(String state) async {
    await _analytics.logEvent(
      name: 'smart_button_tap',
      parameters: {'state': state},
    );
  }

  /// Track workout start from button
  Future<void> trackWorkoutStarted(String workoutId) async {
    await _analytics.logEvent(
      name: 'smart_button_workout_started',
      parameters: {'workout_id': workoutId},
    );
  }

  /// Get button tap rate for user
  Future<double> getButtonTapRate(String userId) async {
    final doc = await _firestore
        .collection('analytics')
        .doc('smart_button')
        .collection('user_metrics')
        .doc(userId)
        .get();

    if (!doc.exists) return 0.0;

    final data = doc.data()!;
    final taps = data['taps'] as int? ?? 0;
    final impressions = data['impressions'] as int? ?? 0;

    if (impressions == 0) return 0.0;
    return taps / impressions;
  }
}
```

**Step 2: Integrate analytics into widget**

Add analytics calls to `SmartCTAButton`:

```dart
// At build time
@override
Widget build(BuildContext context, WidgetRef ref) {
  // ... existing code ...

  // Track visibility
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _analytics.trackButtonVisible(state.description);
  });

  return _buildButton(context, state, routine, today);
}

// In action handlers
void _startWorkout(BuildContext context, DayInfo dayInfo) {
  _analytics.trackButtonTap('active_workout');
  _analytics.trackWorkoutStarted(dayInfo.templateId ?? 'unknown');
  // ... existing navigation code ...
}
```

**Step 3: Commit**

```bash
git add lib/features/routine/application/services/smart_button_analytics_service.dart
git add lib/features/routine/presentation/widgets/smart_cta_button/smart_cta_button.dart
git commit -m "feat: add analytics tracking for SmartCTAButton

- Track button visibility by state
- Track button taps
- Track workout starts from button
- Part of Smart CTA Button Phase 2 (A/B testing)"
```

---

## Post-Implementation Checklist

- [ ] All files compile without errors (`flutter analyze`)
- [ ] Localizations generated (`flutter gen-l10n`)
- [ ] Manual testing complete (all 4 states tested)
- [ ] Dark and light themes tested
- [ ] English and Italian localization tested
- [ ] Code committed to git (7-8 commits for MVP)
- [ ] Design document cross-referenced
- [ ] Ready for TestFlight deployment (optional)

---

## Phase 2 Next Steps (Future)

After Phase 1 MVP is validated with users:

1. **Add Weekly Volume Tracking**
   - Create provider: `weeklyVolumeProvider`
   - Add logic: if volume > 130% of average → warn user
   - Timeline: 2-3 days

2. **Add Streak Counter**
   - Track last workout date
   - Calculate consecutive days
   - Add streak freeze logic
   - Timeline: 2 days

3. **Implement Navigation Actions**
   - Replace debug prints with actual navigation
   - Create RecoveryTipsModal
   - Timeline: 1 day

4. **A/B Test Rollout**
   - Deploy to 10% of users
   - Collect metrics for 3-4 days
   - Analyze engagement (tap rate, workout starts)
   - Timeline: 1 week

---

## References

- Design Document: `docs/plans/2025-11-07-smart-cta-button-design.md`
- GDPR Compliance: Phase 1 uses only "zona verde" data (safe)
- Existing Providers: `completedWorkoutsByDateProvider`, `activeFlexibleRoutineProvider`
- Localization System: `assets/i18n/*.arb` → `flutter gen-l10n`

---

**Implementation Timeline Estimate:**
- Task 1-6 (MVP): 2-3 hours
- Task 7 (Navigation): +30 minutes
- Task 8 (Analytics): +1 hour
- Testing: +30 minutes
- **Total MVP: 3-4 hours**

---

**END OF IMPLEMENTATION PLAN**
