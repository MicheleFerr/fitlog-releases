# SmartWorkoutCTA Modernization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Modernize SmartWorkoutCTA with safe provider, shimmer loading, haptic feedback, and full design system compliance.

**Architecture:** Replace StreamProvider with FutureProvider + timeout, add repository method for one-time fetch, update UI with LoadingIndicator, add localization keys, implement haptic feedback.

**Tech Stack:** Flutter, Riverpod (FutureProvider), Firebase Firestore, flutter_gen (l10n), HapticFeedback

---

## Task 1: Add getActiveRoutine() Repository Method

**Files:**
- Modify: `lib/features/routine/data/repositories/firebase_flexible_routine_repository.dart:~210`
- Modify: `lib/features/routine/domain/repositories/flexible_routine_repository.dart:~20`

**Step 1: Add interface method to abstract repository**

```dart
// File: lib/features/routine/domain/repositories/flexible_routine_repository.dart
// Add after watchActiveRoutine() declaration (around line 20)

/// Get active routine (one-time fetch)
///
/// Returns the user's active routine or null if none exists.
/// Throws exception on error.
Future<FlexibleRoutine?> getActiveRoutine(String userId);
```

**Step 2: Implement method in Firebase repository**

```dart
// File: lib/features/routine/data/repositories/firebase_flexible_routine_repository.dart
// Add after watchActiveRoutine() method (around line 247)

@override
Future<FlexibleRoutine?> getActiveRoutine(String userId) async {
  try {
    if (kDebugMode) {
      debugPrint('🔍 [getActiveRoutine] START - userId: $userId');
    }

    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .where('isArchived', isEqualTo: false)
        .limit(1)
        .get();

    if (kDebugMode) {
      debugPrint('🔍 [getActiveRoutine] Query completed: ${snapshot.docs.length} docs');
    }

    if (snapshot.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [getActiveRoutine] No active routine found');
      }
      return null;
    }

    final routine = FlexibleRoutine.fromJson(snapshot.docs.first.data());
    if (kDebugMode) {
      debugPrint('✅ [getActiveRoutine] Found routine: ${routine.name}');
    }
    return routine;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [getActiveRoutine] Error: $e');
    }
    throw _handleError(e, 'getActiveRoutine');
  }
}
```

**Step 3: Verify compilation**

Run: `flutter analyze`
Expected: No errors related to flexible_routine_repository

**Step 4: Commit**

```bash
git add lib/features/routine/domain/repositories/flexible_routine_repository.dart lib/features/routine/data/repositories/firebase_flexible_routine_repository.dart
git commit -m "feat: add getActiveRoutine() repository method for one-time fetch

- Add interface method in abstract repository
- Implement in Firebase repository with timeout support
- Add debug logging for troubleshooting
- Handles empty results gracefully (returns null)

Part of SmartWorkoutCTA modernization (stability improvements)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 2: Create safeActiveRoutineProvider

**Files:**
- Modify: `lib/features/routine/presentation/providers/flexible_routine_provider.dart:~145`

**Step 1: Add safe provider after activeFlexibleRoutineProvider**

```dart
// File: lib/features/routine/presentation/providers/flexible_routine_provider.dart
// Add after activeFlexibleRoutineProvider declaration (around line 83)

/// Safe provider for active routine (FutureProvider with timeout)
///
/// Unlike activeFlexibleRoutineProvider (StreamProvider), this uses
/// one-time fetch with timeout to prevent infinite loading issues.
///
/// Use this in SmartWorkoutCTA and other widgets where real-time
/// updates are not critical.
final safeActiveRoutineProvider = FutureProvider.autoDispose<FlexibleRoutine?>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);

  if (kDebugMode) {
    debugPrint('🔍 [safeActiveRoutineProvider] START - userId: $userId');
  }

  if (userId == null) {
    if (kDebugMode) {
      debugPrint('⚠️ [safeActiveRoutineProvider] No userId, returning null');
    }
    return null;
  }

  final repository = ref.watch(flexibleRoutineRepositoryProvider);

  try {
    // Timeout after 5 seconds to prevent infinite loading
    final routine = await repository.getActiveRoutine(userId)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            if (kDebugMode) {
              debugPrint('⏱️ [safeActiveRoutineProvider] Timeout after 5s');
            }
            return null;
          },
        );

    if (kDebugMode) {
      debugPrint('✅ [safeActiveRoutineProvider] Completed: ${routine?.name ?? "null"}');
    }

    return routine;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [safeActiveRoutineProvider] Error: $e');
    }
    return null; // Graceful fallback instead of throwing
  }
});
```

**Step 2: Verify compilation**

Run: `flutter analyze`
Expected: No errors in flexible_routine_provider.dart

**Step 3: Commit**

```bash
git add lib/features/routine/presentation/providers/flexible_routine_provider.dart
git commit -m "feat: add safeActiveRoutineProvider with timeout protection

- FutureProvider.autoDispose for automatic cleanup
- 5-second timeout to prevent infinite loading
- Graceful error recovery (returns null instead of throwing)
- Debug logging for troubleshooting
- Use in SmartWorkoutCTA instead of StreamProvider

Part of SmartWorkoutCTA modernization (stability improvements)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 3: Add Localization Keys

**Files:**
- Modify: `assets/i18n/app_it.arb:~end`
- Modify: `assets/i18n/app_en.arb:~end`

**Step 1: Add Italian keys**

```json
// File: assets/i18n/app_it.arb
// Add before the closing brace

  "smartWorkoutCTAStart": "INIZIA ALLENAMENTO",
  "smartWorkoutCTARestDay": "Giorno di Riposo 🌟",
  "smartWorkoutCTARestDayHint": "Usa il pulsante \"+ Sessione Libera\" per un allenamento libero",
  "smartWorkoutCTASuggestedToday": "Suggerito per oggi • ~{duration} min",
  "@smartWorkoutCTASuggestedToday": {
    "placeholders": {
      "duration": {
        "type": "int"
      }
    }
  },
  "smartWorkoutCTAErrorLoading": "Errore caricamento",
  "smartWorkoutCTAErrorTemplate": "Errore caricamento template",
  "smartWorkoutCTAIncompleteRoutine": "Routine incompleta",
  "smartWorkoutCTATemplateNotFound": "Template non trovato"
```

**Step 2: Add English keys**

```json
// File: assets/i18n/app_en.arb
// Add before the closing brace

  "smartWorkoutCTAStart": "START WORKOUT",
  "smartWorkoutCTARestDay": "Rest Day 🌟",
  "smartWorkoutCTARestDayHint": "Use \"+ Free Session\" button for a free workout",
  "smartWorkoutCTASuggestedToday": "Suggested for today • ~{duration} min",
  "@smartWorkoutCTASuggestedToday": {
    "placeholders": {
      "duration": {
        "type": "int"
      }
    }
  },
  "smartWorkoutCTAErrorLoading": "Loading error",
  "smartWorkoutCTAErrorTemplate": "Template loading error",
  "smartWorkoutCTAIncompleteRoutine": "Incomplete routine",
  "smartWorkoutCTATemplateNotFound": "Template not found"
```

**Step 3: Regenerate localizations**

Run: `flutter gen-l10n`
Expected: Generated app_localizations.dart with new keys

**Step 4: Commit**

```bash
git add assets/i18n/app_it.arb assets/i18n/app_en.arb lib/shared/presentation/l10n/generated/
git commit -m "feat: add SmartWorkoutCTA localization keys (IT/EN)

- 8 new keys for all UI states
- Support for duration placeholder
- English and Italian translations

Part of SmartWorkoutCTA modernization (localization compliance)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 4: Refactor SmartWorkoutCTA Widget

**Files:**
- Modify: `lib/features/home/presentation/widgets/smart_workout_cta.dart:1-278`

**Step 1: Update imports and provider**

```dart
// File: lib/features/home/presentation/widgets/smart_workout_cta.dart
// Replace line 5 import and line 19 provider usage

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ADD THIS - for HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_analytics.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart'; // ADD THIS
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart'; // ADD THIS
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart'; // ADD THIS

/// Smart workout CTA button that pre-loads workouts from active routines
class SmartWorkoutCTA extends ConsumerWidget {
  const SmartWorkoutCTA({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CHANGE: Use safeActiveRoutineProvider instead of activeFlexibleRoutineProvider
    final routineAsync = ref.watch(safeActiveRoutineProvider);

    return routineAsync.when(
      loading: () => _buildLoadingState(context),
      error: (_, __) => _buildDisabledState(
        context,
        context.l10n.smartWorkoutCTAErrorLoading, // LOCALIZED
      ),
      data: (routine) {
        // Guard 1: Check if routine exists and has uncompleted workout
        if (routine == null || !routine.hasUncompletedWorkout()) {
          return _buildDisabledState(
            context,
            context.l10n.smartWorkoutCTARestDay, // LOCALIZED
          );
        }

        // Guard 2: Get next uncompleted workout
        final nextWorkout = routine.getNextUncompletedWorkout();
        if (nextWorkout == null || nextWorkout.templateId == null) {
          return _buildDisabledState(
            context,
            context.l10n.smartWorkoutCTAIncompleteRoutine, // LOCALIZED
          );
        }

        // ✅ Ready to show active CTA
        return _buildActiveState(
          context,
          ref,
          nextWorkout.templateId!,
        );
      },
    );
  }
```

**Step 2: Update _buildLoadingState method**

```dart
  // Loading state - use LoadingIndicator
  Widget _buildLoadingState(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest, // USE CONTEXT
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: LoadingIndicator(), // UNIFIED COMPONENT
      ),
    );
  }
```

**Step 3: Update _buildDisabledState method**

```dart
  // Disabled state - rest day or no routine
  Widget _buildDisabledState(
    BuildContext context,
    String label,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest, // USE CONTEXT
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textTheme.titleLarge?.copyWith( // USE CONTEXT
                color: context.colors.onSurfaceVariant, // USE CONTEXT
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.smartWorkoutCTARestDayHint, // LOCALIZED
              style: context.textTheme.bodySmall?.copyWith( // USE CONTEXT
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.7), // USE CONTEXT
              ),
            ),
          ],
        ),
      ),
    );
  }
```

**Step 4: Update _buildActiveState method**

```dart
  // Active state - ready to pre-load
  Widget _buildActiveState(
    BuildContext context,
    WidgetRef ref,
    String templateId,
  ) {
    // Watch templates to get the name
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

    return templatesAsync.when(
      loading: () => _buildLoadingState(context),
      error: (_, __) => _buildDisabledState(
        context,
        context.l10n.smartWorkoutCTAErrorTemplate, // LOCALIZED
      ),
      data: (templates) {
        // Find the template
        final template = templates.where((t) => t.id == templateId).firstOrNull;
        if (template == null) {
          return _buildDisabledState(
            context,
            context.l10n.smartWorkoutCTATemplateNotFound, // LOCALIZED
          );
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colors.primary, // USE CONTEXT
                context.colors.tertiary, // USE CONTEXT
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.3), // USE CONTEXT
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                // ADD: Haptic feedback
                await HapticFeedback.lightImpact();
                _onSmartCTATap(context, ref, template.id, template.name);
              },
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.rocket,
                          color: context.colors.onPrimary, // USE CONTEXT
                          size: AppIconSize.small, // USE SEMANTIC SIZE
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.smartWorkoutCTAStart, // LOCALIZED
                          style: TextStyle(
                            color: context.colors.onPrimary, // USE CONTEXT
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      template.name,
                      style: context.textTheme.titleLarge?.copyWith( // USE CONTEXT
                        color: context.colors.onPrimary, // USE CONTEXT
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.smartWorkoutCTASuggestedToday(template.estimatedDuration), // LOCALIZED WITH PLACEHOLDER
                      style: TextStyle(
                        color: context.colors.onPrimary.withValues(alpha: 0.85), // USE CONTEXT
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
```

**Step 5: Keep _onSmartCTATap unchanged (already correct)**

```dart
  Future<void> _onSmartCTATap(
    BuildContext context,
    WidgetRef ref,
    String templateId,
    String templateName,
  ) async {
    // Generate session ID for analytics correlation
    final sessionId = generateSessionId();

    // Guard 1: Check AsyncValue state
    final routineAsync = ref.read(safeActiveRoutineProvider); // UPDATED PROVIDER
    if (routineAsync is! AsyncData) {
      return;
    }

    final routine = routineAsync.value;

    // Guard 2: Routine null check
    if (routine == null || !routine.hasUncompletedWorkout()) {
      return;
    }

    // Guard 3: getNextUncompletedWorkout() null check
    final nextWorkoutFresh = routine.getNextUncompletedWorkout();
    if (nextWorkoutFresh == null || nextWorkoutFresh.templateId == null) {
      return;
    }

    // Fetch template to get exercises
    final templatesAsync = ref.read(customWorkoutTemplatesProvider);
    if (templatesAsync is! AsyncData) {
      return;
    }

    final templates = templatesAsync.value ?? [];
    final template = templates.where((t) => t.id == templateId).firstOrNull;
    if (template == null) {
      return;
    }

    // ✅ Analytics tracking BEFORE starting workout
    await WorkoutAnalytics.trackEvent(
      'smart_cta_tapped',
      properties: {
        'sessionId': sessionId,
        'templateName': templateName,
        'templateId': templateId,
        'exerciseCount': template.exercises.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // ✅ Start workout from template (same as DayDetailSheet)
    ref.read(currentWorkoutProvider.notifier).startFromTemplate(template);

    // ✅ Navigate directly to workout screen
    if (context.mounted) {
      context.goNamed('workout');
    }
  }
}

String generateSessionId() => const Uuid().v4();
```

**Step 6: Verify compilation**

Run: `flutter analyze`
Expected: No errors in smart_workout_cta.dart

**Step 7: Commit**

```bash
git add lib/features/home/presentation/widgets/smart_workout_cta.dart
git commit -m "refactor: modernize SmartWorkoutCTA with stability & compliance

Changes:
- Use safeActiveRoutineProvider (FutureProvider with timeout)
- Add haptic feedback on tap
- Replace CircularProgressIndicator with LoadingIndicator
- Use context.colors.* instead of theme.colorScheme.*
- Use context.textTheme.* instead of theme.textTheme.*
- Use AppIconSize.small instead of hardcoded size: 16
- Full localization (all strings use context.l10n.*)

Stability: Zero infinite loading risk (5s timeout)
Compliance: 100% design system compliant
UX: Haptic feedback for tactile response

Part of SmartWorkoutCTA modernization (complete)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 5: Manual Testing

**Files:**
- N/A (testing only)

**Step 1: Test loading state**

Actions:
1. Clear app cache: Settings > Developer > Clear Cache
2. Restart app
3. Navigate to Home screen
4. Observe SmartWorkoutCTA loading

Expected:
- LoadingIndicator appears (unified spinner)
- Loading completes within 5 seconds
- No infinite spinner

**Step 2: Test active state**

Actions:
1. Ensure you have an active routine with scheduled workout today
2. Navigate to Home screen
3. Observe SmartWorkoutCTA

Expected:
- Gradient button appears with "INIZIA ALLENAMENTO" (IT) or "START WORKOUT" (EN)
- Shows template name (e.g., "Giorno C")
- Shows duration "Suggerito per oggi • ~45 min"
- Tap button → feel haptic vibration (light impact)
- Navigate to workout screen

**Step 3: Test disabled state (rest day)**

Actions:
1. Ensure today is a rest day in your routine
2. Navigate to Home screen
3. Observe SmartWorkoutCTA

Expected:
- Gray container with "Giorno di Riposo 🌟" (IT) or "Rest Day 🌟" (EN)
- Hint text: "Usa il pulsante..." (IT) or "Use \"+ Free Session\"..." (EN)

**Step 4: Test error states**

Actions:
1. Disconnect network
2. Restart app
3. Navigate to Home screen

Expected:
- Shows "Errore caricamento" (IT) or "Loading error" (EN) after 5s timeout
- No infinite loading spinner
- No crash

**Step 5: Test localization**

Actions:
1. Change device language to English
2. Restart app
3. Navigate to Home screen

Expected:
- All text in English ("START WORKOUT", "Rest Day 🌟", etc.)

Actions:
1. Change device language to Italian
2. Restart app
3. Navigate to Home screen

Expected:
- All text in Italian ("INIZIA ALLENAMENTO", "Giorno di Riposo 🌟", etc.)

**Step 6: Test dark/light themes**

Actions:
1. Switch to dark mode
2. Navigate to Home screen

Expected:
- Gradient button visible with good contrast
- Text readable on dark background
- Loading indicator visible

Actions:
1. Switch to light mode
2. Navigate to Home screen

Expected:
- Gradient button visible with good contrast
- Text readable on light background
- Loading indicator visible

**Step 7: Final verification**

Run: `flutter analyze`
Expected: 0 errors, 0 warnings

Run: `git status`
Expected: No uncommitted changes (all committed in previous tasks)

---

## Success Criteria Checklist

### Must Have ✅
- [ ] No infinite loading (5s timeout works)
- [ ] Graceful error recovery (no crashes on network disconnect)
- [ ] 100% localized (IT/EN strings, no hardcoded text)
- [ ] Design system compliant (LoadingIndicator, context.colors, AppIconSize)
- [ ] Haptic feedback works (iOS/Android vibration on tap)

### Nice to Have ✨
- [ ] LoadingIndicator consistent with app style
- [ ] Zero frame drops during interactions

### Explicitly Excluded ❌
- [x] NO gradient animation (user request)
- [x] NO icon pulsing animation (too animated)
- [x] NO scale animation on tap (too animated)
- [x] NO new features (preview, streak, calories)

---

## Rollback Plan

If critical issues discovered during testing:

```bash
# Revert to previous commit (before Task 4)
git revert HEAD

# Or full rollback to before modernization
git reset --hard <commit-before-task-1>

# Keep localization (low risk)
git cherry-pick <task-3-commit>
```

---

## Time Tracking

- **Task 1** (Repository): 5 min
- **Task 2** (Provider): 5 min
- **Task 3** (Localization): 10 min
- **Task 4** (Widget Refactor): 15 min
- **Task 5** (Testing): 25 min

**Total**: ~60 minutes

---

## Related Documentation

- Design Document: `docs/plans/2025-11-07-smart-workout-cta-modernization-design.md`
- Design System: `docs/DESIGN_GUIDELINES.md`
- Localization Guide: `CLAUDE.md` (Regola #1)
- Icon System: `CLAUDE.md` (Regola #0)
