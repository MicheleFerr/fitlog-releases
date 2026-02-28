/// GymBro TrackLog - Flutter Fitness App
///
/// Widget Tests: Home Feature - Presentation Layer
///
/// Covers:
/// - StartWorkoutCard: inactive state (no active workout)
/// - StartWorkoutCard: active state (workout in progress)
/// - TemplateWizardReminderCard: visible / hidden states, dismiss action
/// - WeightUpdateNudgeCard: visible / hidden states, swipe-to-dismiss
/// - XPProgressBar: loading skeleton, data render, max-tier render
/// - ActivityRingsWidget: loading state, error state, data state
///
/// SKIPPED (too many providers / Firebase / GoRouter):
/// - ProInsightsPreviewSection: depends on currentUserIdProvider,
///   exerciseHistoryStreamProvider (Firebase stream), cachedMuscleBalanceProvider,
///   sleepAwareStressDataProvider (5+ providers backed by Firebase streams).
///   Testing in isolation would require mocking an entire Firebase stack including
///   Firestore, Auth, and multiple domain-level stream providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
// Override is a sealed class internal to riverpod; it is the element type of
// ProviderScope.overrides but is not re-exported from the public riverpod API.
// ignore: implementation_imports
import 'package:riverpod/src/framework.dart' show Override;

// Widgets under test
import 'package:gymbro_flutter_new/features/home/presentation/widgets/start_workout_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/template_wizard_reminder_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/weight_update_nudge_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/xp_progress_bar.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/activity_rings_widget.dart';

// Providers overridden in tests
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/onboarding_choice_service.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/providers/weight_update_nudge_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/user/user_xp_provider.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/activity_rings_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../test_helpers/firebase_test_helper.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Minimal test app wrapper that satisfies localisation and Riverpod
/// requirements for all widgets under test.
Widget buildTestApp({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('it')],
      locale: const Locale('en'),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

/// Builds a minimal [Workout] in the given status.
Workout _buildWorkout({
  WorkoutStatus status = WorkoutStatus.inProgress,
  String name = 'Chest Day',
}) {
  return Workout(
    id: 'test-workout-id',
    name: name,
    exercises: const [],
    status: status,
    startTime: DateTime(2026, 2, 28, 10),
    createdAt: DateTime(2026, 2, 28),
    updatedAt: DateTime(2026, 2, 28),
  );
}

// ---------------------------------------------------------------------------
// Fake notifiers
// ---------------------------------------------------------------------------

/// Returns a fixed [Workout?] without hitting any real service.
class _FakeCurrentWorkoutNotifier extends CurrentWorkoutNotifier {
  _FakeCurrentWorkoutNotifier(this._value);

  final Workout? _value;

  @override
  Workout? build() => _value;
}

/// Returns a fixed [UserXPState] without running the real Firebase-dependent
/// [UserXPNotifier.build] logic.
///
/// Requires Firebase to be initialised (via [setupFirebaseCoreMocks]) so that
/// the `FirebaseFirestore.instance` field initializer on [UserXPNotifier] does
/// not throw. The overridden [build] method returns the fixed state immediately
/// without triggering any Firestore reads.
class _FakeUserXPNotifier extends UserXPNotifier {
  _FakeUserXPNotifier(this._state);

  final UserXPState _state;

  @override
  UserXPState build() => _state;
}

/// Returns a fixed [ActivityRingsData] without calling HealthKit.
class _FakeActivityRingsNotifier extends ActivityRingsNotifier {
  _FakeActivityRingsNotifier(this._data);

  final ActivityRingsData _data;

  @override
  ActivityRingsData build() => _data;

  // Prevent real fetch calls in tests
  @override
  Future<void> fetchActivityData() async {}
}

/// Fake [WeightUpdateNudgeNotifier] that avoids [SharedPreferences] access.
class _FakeWeightNudgeNotifier extends WeightUpdateNudgeNotifier {
  @override
  Future<WeightNudgeState> build() async {
    return const WeightNudgeState(
      shouldShowNudge: true,
      daysSinceLastUpdate: 30,
      lastUpdateDate: null,
      isDismissed: false,
    );
  }

  @override
  Future<void> dismissNudge() async {
    state = const AsyncValue.data(
      WeightNudgeState(
        shouldShowNudge: false,
        daysSinceLastUpdate: 30,
        lastUpdateDate: null,
        isDismissed: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // StartWorkoutCard
  // -------------------------------------------------------------------------
  group('StartWorkoutCard', () {
    testWidgets(
      'shows "Start Now" card when no workout is active',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              currentWorkoutProvider.overrideWith(
                () => _FakeCurrentWorkoutNotifier(null),
              ),
            ],
            child: const StartWorkoutCard(),
          ),
        );
        await tester.pumpAndSettle();

        // l10n key startNow = "Start Now"
        expect(find.text('Start Now'), findsOneWidget);
      },
    );

    testWidgets(
      'shows "Resume" card when a workout is in progress',
      (WidgetTester tester) async {
        final workout = _buildWorkout(
          status: WorkoutStatus.inProgress,
          name: 'Push Day',
        );

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              currentWorkoutProvider.overrideWith(
                () => _FakeCurrentWorkoutNotifier(workout),
              ),
            ],
            child: const StartWorkoutCard(),
          ),
        );
        await tester.pumpAndSettle();

        // Active card must show the workout name and the Resume button text
        expect(find.text('Push Day'), findsOneWidget);
        expect(find.text('Resume'), findsWidgets);
      },
    );

    testWidgets(
      'active card shows Finish and Discard secondary action buttons',
      (WidgetTester tester) async {
        final workout = _buildWorkout(status: WorkoutStatus.inProgress);

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              currentWorkoutProvider.overrideWith(
                () => _FakeCurrentWorkoutNotifier(workout),
              ),
            ],
            child: const StartWorkoutCard(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Finish'), findsWidgets);
        expect(find.text('Discard'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Finish on active card opens confirmation dialog',
      (WidgetTester tester) async {
        final workout = _buildWorkout(status: WorkoutStatus.inProgress);

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              currentWorkoutProvider.overrideWith(
                () => _FakeCurrentWorkoutNotifier(workout),
              ),
            ],
            child: const StartWorkoutCard(),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the OutlinedButton "Finish" that is the secondary action in the
        // active card body (not the FilledButton inside the yet-to-appear dialog)
        final finishButtons = find.text('Finish');
        await tester.tap(finishButtons.first);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Discard on active card opens confirmation dialog',
      (WidgetTester tester) async {
        final workout = _buildWorkout(status: WorkoutStatus.inProgress);

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              currentWorkoutProvider.overrideWith(
                () => _FakeCurrentWorkoutNotifier(workout),
              ),
            ],
            child: const StartWorkoutCard(),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Discard'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Cancel in Finish confirmation dialog closes the dialog',
      (WidgetTester tester) async {
        final workout = _buildWorkout(status: WorkoutStatus.inProgress);

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              currentWorkoutProvider.overrideWith(
                () => _FakeCurrentWorkoutNotifier(workout),
              ),
            ],
            child: const StartWorkoutCard(),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Finish').first);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets(
      'inactive card renders in dark theme without errors',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentWorkoutProvider.overrideWith(
                () => _FakeCurrentWorkoutNotifier(null),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              locale: const Locale('en'),
              themeMode: ThemeMode.dark,
              darkTheme: ThemeData.dark(useMaterial3: true),
              home: const Scaffold(
                body: SingleChildScrollView(child: StartWorkoutCard()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // l10n key startNow = "Start Now"
        expect(find.text('Start Now'), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  // TemplateWizardReminderCard
  // -------------------------------------------------------------------------
  group('TemplateWizardReminderCard', () {
    testWidgets(
      'renders card when shouldShowTemplateWizardReminderProvider is true',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              shouldShowTemplateWizardReminderProvider.overrideWithValue(true),
            ],
            child: const TemplateWizardReminderCard(),
          ),
        );
        await tester.pumpAndSettle();

        // l10n key templateWizardReminderTitle = "Create Your First Routine"
        expect(find.text('Create Your First Routine'), findsOneWidget);
      },
    );

    testWidgets(
      'hides card when shouldShowTemplateWizardReminderProvider is false',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              shouldShowTemplateWizardReminderProvider.overrideWithValue(false),
            ],
            child: const TemplateWizardReminderCard(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Create Your First Routine'), findsNothing);
      },
    );

    testWidgets(
      'shows dismiss and action buttons when visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              shouldShowTemplateWizardReminderProvider.overrideWithValue(true),
            ],
            child: const TemplateWizardReminderCard(),
          ),
        );
        await tester.pumpAndSettle();

        // l10n key templateWizardReminderDismiss = "Later"
        expect(find.text('Later'), findsOneWidget);
        // l10n key templateWizardReminderAction = "Start Wizard"
        expect(find.text('Start Wizard'), findsOneWidget);
      },
    );

    testWidgets(
      'card renders in Italian locale without crashing',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              shouldShowTemplateWizardReminderProvider.overrideWithValue(true),
            ],
            child: const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('en'), Locale('it')],
              locale: Locale('it'),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: TemplateWizardReminderCard(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Italian locale – just verify widget builds and shows some text
        expect(find.byType(TemplateWizardReminderCard), findsOneWidget);
        expect(find.byType(Text), isNot(findsNothing));
      },
    );
  });

  // -------------------------------------------------------------------------
  // WeightUpdateNudgeCard
  // -------------------------------------------------------------------------
  group('WeightUpdateNudgeCard', () {
    testWidgets(
      'renders nudge card when shouldShowWeightNudgeProvider is true',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              shouldShowWeightNudgeProvider.overrideWithValue(true),
              daysSinceWeightUpdateProvider.overrideWithValue(35),
            ],
            child: const WeightUpdateNudgeCard(),
          ),
        );
        await tester.pumpAndSettle();

        // l10n key weightUpdateNudgeTitle = "Update your weight"
        expect(find.text('Update your weight'), findsOneWidget);
      },
    );

    testWidgets(
      'hides nudge card when shouldShowWeightNudgeProvider is false',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              shouldShowWeightNudgeProvider.overrideWithValue(false),
              daysSinceWeightUpdateProvider.overrideWithValue(0),
            ],
            child: const WeightUpdateNudgeCard(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Update your weight'), findsNothing);
      },
    );

    testWidgets(
      'shows days-since value in nudge card subtitle',
      (WidgetTester tester) async {
        const daysSince = 42;

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              shouldShowWeightNudgeProvider.overrideWithValue(true),
              daysSinceWeightUpdateProvider.overrideWithValue(daysSince),
            ],
            child: const WeightUpdateNudgeCard(),
          ),
        );
        await tester.pumpAndSettle();

        // The subtitle contains the number of days
        expect(find.textContaining('$daysSince'), findsWidgets);
      },
    );

    testWidgets(
      'nudge card can be swiped horizontally to dismiss',
      (WidgetTester tester) async {
        // Override only the async notifier (source of truth). The derived
        // shouldShowWeightNudgeProvider and daysSinceWeightUpdateProvider are
        // NOT overridden so they derive their values from the fake notifier
        // state and correctly reflect the dismissed state after swipe.
        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              weightUpdateNudgeProvider.overrideWith(
                () => _FakeWeightNudgeNotifier(),
              ),
            ],
            child: const WeightUpdateNudgeCard(),
          ),
        );
        // Wait for async notifier build
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('weight_update_nudge')), findsOneWidget);

        // Fling far to the right to exceed the dismissal threshold
        await tester.fling(
          find.byKey(const Key('weight_update_nudge')),
          const Offset(800, 0),
          1500,
        );
        await tester.pumpAndSettle();

        // After dismissal the Dismissible and the card are removed
        expect(find.byKey(const Key('weight_update_nudge')), findsNothing);
      },
    );
  });

  // -------------------------------------------------------------------------
  // XPProgressBar
  // -------------------------------------------------------------------------
  group('XPProgressBar', () {
    // _FakeUserXPNotifier subclasses UserXPNotifier which accesses
    // FirebaseFirestore.instance at field init time.  Firebase must be set up
    // before the first test in this group runs.
    setUpAll(() async {
      setupFirebaseCoreMocks();
      await Firebase.initializeApp();
    });

    testWidgets(
      'shows loading skeleton when isLoading is true',
      (WidgetTester tester) async {
        const loadingState = UserXPState(isLoading: true);

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              // Use overrideWith and a plain Notifier to avoid Firebase init
              userXPProvider.overrideWith(() => _FakeUserXPNotifier(loadingState)),
            ],
            child: const XPProgressBar(),
          ),
        );
        await tester.pump();

        // Loading skeleton is a Container with height 80 – no tier label shown
        expect(find.text('Starter'), findsNothing);
        expect(find.text('Bronze'), findsNothing);
      },
    );

    testWidgets(
      'renders nothing (SizedBox.shrink) when error is set',
      (WidgetTester tester) async {
        const errorState = UserXPState(error: 'Firestore unavailable');

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              userXPProvider.overrideWith(() => _FakeUserXPNotifier(errorState)),
            ],
            child: const XPProgressBar(),
          ),
        );
        await tester.pumpAndSettle();

        // Nothing should be rendered on error
        expect(find.text('Starter'), findsNothing);
      },
    );

    testWidgets(
      'shows tier name and XP when data is available',
      (WidgetTester tester) async {
        // 50 XP is below the 100-XP bronze threshold → Starter tier
        const xpState = UserXPState(workoutXP: 50);

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              userXPProvider.overrideWith(() => _FakeUserXPNotifier(xpState)),
            ],
            child: const XPProgressBar(),
          ),
        );
        await tester.pumpAndSettle();

        // Tier: Starter (0-99 XP) – text may appear more than once
        // (e.g. in the tier name row and the progress section)
        expect(find.text(UserTier.starter.displayName), findsWidgets);
        // XP total text
        expect(find.textContaining('50 XP'), findsWidgets);
      },
    );

    testWidgets(
      'shows "MAX" badge when user is at Platinum tier',
      (WidgetTester tester) async {
        // Platinum requires 5000+ XP
        const xpState = UserXPState(workoutXP: 6000);

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              userXPProvider.overrideWith(() => _FakeUserXPNotifier(xpState)),
            ],
            child: const XPProgressBar(),
          ),
        );
        await tester.pumpAndSettle();

        // l10n key maxLevel = "MAX"
        expect(find.text('MAX'), findsOneWidget);
      },
    );

    testWidgets(
      'XPProgressBar renders without crash in dark theme',
      (WidgetTester tester) async {
        const xpState = UserXPState(workoutXP: 500);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userXPProvider.overrideWith(() => _FakeUserXPNotifier(xpState)),
            ],
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              locale: const Locale('en'),
              themeMode: ThemeMode.dark,
              darkTheme: ThemeData.dark(useMaterial3: true),
              home: const Scaffold(
                body: SingleChildScrollView(child: XPProgressBar()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(XPProgressBar), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  // ActivityRingsWidget
  // -------------------------------------------------------------------------
  group('ActivityRingsWidget', () {
    // The widget starts a 5-second Future in initState. Use
    // tester.pump(Duration(seconds: 5)) to advance fake timers past it.

    testWidgets(
      'shows "Activity" header while data is loading (before timeout)',
      (WidgetTester tester) async {
        // empty() means hasData == false, hasError == false → loading state
        const emptyData = ActivityRingsData.empty();

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              activityRingsProvider.overrideWith(
                () => _FakeActivityRingsNotifier(emptyData),
              ),
            ],
            child: const ActivityRingsWidget(),
          ),
        );

        // One frame only (before the 5 s timeout fires)
        await tester.pump();

        // Header "Activity" is always rendered
        expect(find.text('Activity'), findsOneWidget);

        // Advance past the 5-second timer so no pending timer assertion fires
        await tester.pump(const Duration(seconds: 5));
      },
    );

    testWidgets(
      'shows data rings and stats when ActivityRingsData is loaded',
      (WidgetTester tester) async {
        final loadedData = ActivityRingsData(
          moveCalories: 350,
          moveGoal: 500,
          exerciseMinutes: 25,
          exerciseGoal: 30,
          standHours: 8,
          standGoal: 12,
          lastUpdated: DateTime(2026, 2, 28),
        );

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              activityRingsProvider.overrideWith(
                () => _FakeActivityRingsNotifier(loadedData),
              ),
            ],
            child: const ActivityRingsWidget(),
          ),
        );
        // Advance past the 5-second initState timer
        await tester.pump(const Duration(seconds: 5));

        // Stats labels visible
        expect(find.text('Move'), findsOneWidget);
        expect(find.text('Exercise'), findsOneWidget);
        expect(find.text('Stand'), findsOneWidget);

        // Calorie value
        expect(find.textContaining('350'), findsWidgets);
        // "HealthKit" badge is shown when hasData is true
        expect(find.text('HealthKit'), findsOneWidget);
      },
    );

    testWidgets(
      'shows "Connect Health" error state when data has an error message',
      (WidgetTester tester) async {
        const errorData = ActivityRingsData(
          moveCalories: 0,
          moveGoal: 500,
          exerciseMinutes: 0,
          exerciseGoal: 30,
          standHours: 0,
          standGoal: 12,
          lastUpdated: null, // hasData == false triggers error/timeout path
          errorMessage: 'HealthKit permission denied',
        );

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              activityRingsProvider.overrideWith(
                () => _FakeActivityRingsNotifier(errorData),
              ),
            ],
            child: const ActivityRingsWidget(),
          ),
        );
        await tester.pump(const Duration(seconds: 5));

        // Error state renders "Connect Health" button
        expect(find.text('Connect Health'), findsOneWidget);
      },
    );

    testWidgets(
      'showLabels=false hides Move/Exercise/Stand stat rows',
      (WidgetTester tester) async {
        final loadedData = ActivityRingsData(
          moveCalories: 200,
          moveGoal: 500,
          exerciseMinutes: 15,
          exerciseGoal: 30,
          standHours: 4,
          standGoal: 12,
          lastUpdated: DateTime(2026, 2, 28),
        );

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              activityRingsProvider.overrideWith(
                () => _FakeActivityRingsNotifier(loadedData),
              ),
            ],
            child: const ActivityRingsWidget(
              size: 80,
              strokeWidth: 8,
              showLabels: false,
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 5));

        // With showLabels=false the stat rows are absent
        expect(find.text('Move'), findsNothing);
        expect(find.text('Exercise'), findsNothing);
        expect(find.text('Stand'), findsNothing);
      },
    );

    testWidgets(
      'custom onTap callback is invoked when widget is tapped',
      (WidgetTester tester) async {
        final loadedData = ActivityRingsData(
          moveCalories: 300,
          moveGoal: 500,
          exerciseMinutes: 20,
          exerciseGoal: 30,
          standHours: 6,
          standGoal: 12,
          lastUpdated: DateTime(2026, 2, 28),
        );

        var tapped = false;

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              activityRingsProvider.overrideWith(
                () => _FakeActivityRingsNotifier(loadedData),
              ),
            ],
            child: ActivityRingsWidget(
              onTap: () => tapped = true,
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 5));

        await tester.tap(find.byType(GestureDetector).first);
        await tester.pump();

        expect(tapped, isTrue);
      },
    );
  });
}
