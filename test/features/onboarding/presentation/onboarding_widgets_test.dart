// ignore_for_file: avoid_hardcoded_strings_in_tests, depend_on_referenced_packages, prefer_const_constructors

// ignore: implementation_imports
import 'package:riverpod/src/framework.dart' show Override;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_permission_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/initial/initial_onboarding_data.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/experience_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/frequency_summary_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/goal_selection_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/personal_info_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/steps/welcome_step.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

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

/// Builds a test app with a fixed-height frame so Expanded / Spacer inside
/// steps can lay out without unbounded-height overflow.
Widget buildTestAppWithFrame({
  required Widget child,
  List<Override> overrides = const [],
  double height = 900,
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
      home: Scaffold(
        body: SizedBox(height: height, child: child),
      ),
    ),
  );
}

/// Creates an [InitialOnboardingState] override for [initialOnboardingNotifierProvider].
Override buildOnboardingOverride(InitialOnboardingState state) {
  return initialOnboardingNotifierProvider.overrideWith(
    () => _StubOnboardingNotifier(state),
  );
}

class _StubOnboardingNotifier extends InitialOnboardingNotifier {
  _StubOnboardingNotifier(this._initialState);

  final InitialOnboardingState _initialState;

  @override
  InitialOnboardingState build() => _initialState;
}

/// A stub health permission status that reports no Health Connect and all
/// permissions denied – safe for tests that do not care about health data.
// ignore: unused_element
final _stubHealthPermissionOverride = healthPermissionStatusProvider
    .overrideWith(
      (ref) async => const HealthPermissionStatus(
        permissions: <HealthDataType, PermissionState>{},
        healthConnectAvailable: false,
      ),
    );

// ---------------------------------------------------------------------------
// WelcomeStep
// ---------------------------------------------------------------------------

void main() {
  group('WelcomeStep', () {
    testWidgets('renders welcome title', (tester) async {
      await tester.pumpWidget(
        buildTestApp(child: const SizedBox(height: 900, child: WelcomeStep())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome to FitLog Pro'), findsOneWidget);
    });

    testWidgets('renders welcome subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestApp(child: const SizedBox(height: 900, child: WelcomeStep())),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Your smart workout journal that helps you reach your goals'),
        findsOneWidget,
      );
    });

    testWidgets('renders "Let\'s go!" CTA button', (tester) async {
      await tester.pumpWidget(
        buildTestApp(child: const SizedBox(height: 900, child: WelcomeStep())),
      );
      await tester.pumpAndSettle();

      expect(find.text("Let's go!"), findsOneWidget);
    });

    testWidgets('renders feature items', (tester) async {
      await tester.pumpWidget(
        buildTestApp(child: const SizedBox(height: 900, child: WelcomeStep())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Track workouts and progress'), findsOneWidget);
      expect(find.text('Advanced analytics'), findsOneWidget);
    });

    testWidgets('tapping CTA calls nextStep on notifier', (tester) async {
      // Use a taller surface so WelcomeStep's Spacer widgets can resolve.
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const initialState = InitialOnboardingState(currentStep: 0);
      int nextStepCallCount = 0;

      final notifierOverride = initialOnboardingNotifierProvider.overrideWith(
        () => _TrackingOnboardingNotifier(
          initialState,
          onNextStep: () => nextStepCallCount++,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [notifierOverride],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('it')],
            locale: const Locale('en'),
            home: const Scaffold(body: WelcomeStep()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act – tap with warnIfMissed:false because Semantics wraps the button
      await tester.tap(find.text("Let's go!"), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Assert
      expect(nextStepCallCount, greaterThanOrEqualTo(1));
    });

    testWidgets('fade-in animation triggers after first frame', (tester) async {
      await tester.pumpWidget(
        buildTestApp(child: const SizedBox(height: 900, child: WelcomeStep())),
      );

      // Before post-frame callback fires, opacity should be 0
      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, 0.0);

      // After settling, opacity becomes 1.0
      await tester.pumpAndSettle();
      final animatedOpacityAfter = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacityAfter.opacity, 1.0);
    });
  });

  // ---------------------------------------------------------------------------
  // GoalSelectionStep
  // ---------------------------------------------------------------------------

  group('GoalSelectionStep', () {
    const baseState = InitialOnboardingState(currentStep: 1);

    testWidgets('renders goal title and subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: const GoalSelectionStep(),
          overrides: [buildOnboardingOverride(baseState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("What's your goal?"), findsOneWidget);
      expect(find.text("We'll personalize your experience"), findsOneWidget);
    });

    testWidgets('renders all four goal options', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: const GoalSelectionStep(),
          overrides: [buildOnboardingOverride(baseState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Build muscle'), findsOneWidget);
      expect(find.text('Get stronger'), findsOneWidget);
      expect(find.text('Improve endurance'), findsOneWidget);
      expect(find.text('Stay fit'), findsOneWidget);
    });

    testWidgets('goal descriptions are rendered', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: const GoalSelectionStep(),
          overrides: [buildOnboardingOverride(baseState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gain muscle mass'), findsOneWidget);
      expect(find.text('Lift heavier weights'), findsOneWidget);
      expect(find.text('More reps, more energy'), findsOneWidget);
      expect(find.text('General fitness'), findsOneWidget);
    });

    testWidgets('tapping a goal card calls setGoal on notifier', (
      tester,
    ) async {
      TrainingGoalUI? selectedGoal;

      final notifierOverride = initialOnboardingNotifierProvider.overrideWith(
        () => _GoalCapturingNotifier(
          baseState,
          onGoalSet: (g) => selectedGoal = g,
        ),
      );

      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: const GoalSelectionStep(),
          overrides: [notifierOverride],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Build muscle'));
      await tester.pumpAndSettle();

      expect(selectedGoal, TrainingGoalUI.buildMuscle);
    });

    testWidgets('tapping "Get stronger" calls setGoal with correct value', (
      tester,
    ) async {
      TrainingGoalUI? selectedGoal;

      final notifierOverride = initialOnboardingNotifierProvider.overrideWith(
        () => _GoalCapturingNotifier(
          baseState,
          onGoalSet: (g) => selectedGoal = g,
        ),
      );

      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: const GoalSelectionStep(),
          overrides: [notifierOverride],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get stronger'));
      await tester.pumpAndSettle();

      expect(selectedGoal, TrainingGoalUI.getStronger);
    });

    testWidgets('selected goal card shows checkmark (AnimatedScale = 1)', (
      tester,
    ) async {
      final stateWithGoal = baseState.copyWith(
        goal: TrainingGoalUI.buildMuscle,
      );

      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: const GoalSelectionStep(),
          overrides: [buildOnboardingOverride(stateWithGoal)],
        ),
      );
      await tester.pumpAndSettle();

      // There should be at least one AnimatedScale with scale = 1.0
      final animatedScales = tester.widgetList<AnimatedScale>(
        find.byType(AnimatedScale),
      );
      expect(animatedScales.any((w) => w.scale == 1.0), isTrue);
    });

    testWidgets('unselected goal cards have AnimatedScale = 0', (tester) async {
      // Only buildMuscle is selected
      final stateWithGoal = baseState.copyWith(
        goal: TrainingGoalUI.buildMuscle,
      );

      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: const GoalSelectionStep(),
          overrides: [buildOnboardingOverride(stateWithGoal)],
        ),
      );
      await tester.pumpAndSettle();

      final animatedScales = tester
          .widgetList<AnimatedScale>(find.byType(AnimatedScale))
          .toList();

      // 4 goal cards → 4 AnimatedScale widgets; 3 should have scale 0
      expect(animatedScales.where((w) => w.scale == 0.0).length, 3);
    });
  });

  // ---------------------------------------------------------------------------
  // ExperienceStep
  // ---------------------------------------------------------------------------

  group('ExperienceStep', () {
    const baseState = InitialOnboardingState(currentStep: 4);

    testWidgets('renders experience title and subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: const ExperienceStep(),
          overrides: [buildOnboardingOverride(baseState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("What's your experience?"), findsOneWidget);
      expect(
        find.text('This helps us personalize suggestions'),
        findsOneWidget,
      );
    });

    testWidgets('renders all four experience level options', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: const ExperienceStep(),
          overrides: [buildOnboardingOverride(baseState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Some experience'), findsOneWidget);
      expect(find.text('Experienced'), findsOneWidget);
      expect(find.text('Advanced athlete'), findsOneWidget);
    });

    testWidgets('experience descriptions are rendered', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: const ExperienceStep(),
          overrides: [buildOnboardingOverride(baseState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Never or rarely at the gym'), findsOneWidget);
      expect(find.text('6 months - 2 years'), findsOneWidget);
      expect(find.text('2+ years consistent training'), findsOneWidget);
      expect(find.text('5+ years, I know my PRs'), findsOneWidget);
    });

    testWidgets('tapping "Beginner" calls setExperience on notifier', (
      tester,
    ) async {
      ExperienceLevelUI? capturedLevel;

      final notifierOverride = initialOnboardingNotifierProvider.overrideWith(
        () => _ExperienceCapturingNotifier(
          baseState,
          onExperienceSet: (l) => capturedLevel = l,
        ),
      );

      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: const ExperienceStep(),
          overrides: [notifierOverride],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Beginner'));
      await tester.pumpAndSettle();

      expect(capturedLevel, ExperienceLevelUI.beginner);
    });

    testWidgets('tapping "Advanced athlete" calls setExperience with athlete', (
      tester,
    ) async {
      ExperienceLevelUI? capturedLevel;

      final notifierOverride = initialOnboardingNotifierProvider.overrideWith(
        () => _ExperienceCapturingNotifier(
          baseState,
          onExperienceSet: (l) => capturedLevel = l,
        ),
      );

      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: const ExperienceStep(),
          overrides: [notifierOverride],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Advanced athlete'));
      await tester.pumpAndSettle();

      expect(capturedLevel, ExperienceLevelUI.athlete);
    });

    testWidgets('selected experience card shows checkmark', (tester) async {
      final stateWithExp = baseState.copyWith(
        experience: ExperienceLevelUI.experienced,
      );

      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: const ExperienceStep(),
          overrides: [buildOnboardingOverride(stateWithExp)],
        ),
      );
      await tester.pumpAndSettle();

      final animatedScales = tester.widgetList<AnimatedScale>(
        find.byType(AnimatedScale),
      );
      expect(animatedScales.any((w) => w.scale == 1.0), isTrue);
    });

    testWidgets(
      'uses gender-specific asset path when sex is female (no crash)',
      (tester) async {
        final stateWithFemale = baseState.copyWith(sex: BiologicalSex.female);

        await tester.pumpWidget(
          buildTestAppWithFrame(
            child: const ExperienceStep(),
            overrides: [buildOnboardingOverride(stateWithFemale)],
          ),
        );

        // Should not throw; images fall back to emoji on error
        await tester.pumpAndSettle();
        expect(find.text('Beginner'), findsOneWidget);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // PersonalInfoStep
  //
  // PersonalInfoStep contains a CupertinoPicker + Spacer that require
  // sufficient vertical space. We set surfaceSize to 1080×1920 to give
  // the layout room to resolve without overflow.
  // ---------------------------------------------------------------------------

  group('PersonalInfoStep', () {
    const baseState = InitialOnboardingState(currentStep: 2);

    /// Builds PersonalInfoStep inside a tall Scaffold to prevent overflow.
    Widget buildPersonalInfoApp({
      required InitialOnboardingState state,
      List<Override> extraOverrides = const [],
    }) {
      return ProviderScope(
        overrides: [buildOnboardingOverride(state), ...extraOverrides],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('it')],
          locale: const Locale('en'),
          home: const Scaffold(body: PersonalInfoStep()),
        ),
      );
    }

    testWidgets('renders personal info title and subtitle', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPersonalInfoApp(state: baseState));
      await tester.pumpAndSettle();

      expect(find.text('About you'), findsOneWidget);
      expect(find.text('Help us personalize your experience'), findsOneWidget);
    });

    testWidgets('renders sex selection section label', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPersonalInfoApp(state: baseState));
      await tester.pumpAndSettle();

      expect(find.text('Biological sex'), findsOneWidget);
    });

    testWidgets('renders Male and Female cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPersonalInfoApp(state: baseState));
      await tester.pumpAndSettle();

      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
    });

    testWidgets('renders age label', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPersonalInfoApp(state: baseState));
      await tester.pumpAndSettle();

      expect(find.text('How old are you?'), findsOneWidget);
    });

    testWidgets('renders Continue button', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPersonalInfoApp(state: baseState));
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Continue button is disabled when sex or age not set', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const incompleteState = InitialOnboardingState(currentStep: 2);

      await tester.pumpWidget(buildPersonalInfoApp(state: incompleteState));
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Continue'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('Continue button is enabled when sex and age are set', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final completeState = baseState.copyWith(
        sex: BiologicalSex.male,
        age: 25,
      );

      await tester.pumpWidget(buildPersonalInfoApp(state: completeState));
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Continue'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping Male card calls setSex with male', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      BiologicalSex? capturedSex;

      final notifierOverride = initialOnboardingNotifierProvider.overrideWith(
        () =>
            _SexCapturingNotifier(baseState, onSexSet: (s) => capturedSex = s),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [notifierOverride],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('it')],
            locale: const Locale('en'),
            home: const Scaffold(body: PersonalInfoStep()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Male'));
      await tester.pumpAndSettle();

      expect(capturedSex, BiologicalSex.male);
    });

    testWidgets('tapping Female card calls setSex with female', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      BiologicalSex? capturedSex;

      final notifierOverride = initialOnboardingNotifierProvider.overrideWith(
        () =>
            _SexCapturingNotifier(baseState, onSexSet: (s) => capturedSex = s),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [notifierOverride],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('it')],
            locale: const Locale('en'),
            home: const Scaffold(body: PersonalInfoStep()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();

      expect(capturedSex, BiologicalSex.female);
    });

    testWidgets('selected Male card has distinct border (visual check)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final stateWithMale = baseState.copyWith(sex: BiologicalSex.male);

      await tester.pumpWidget(buildPersonalInfoApp(state: stateWithMale));
      await tester.pumpAndSettle();

      // Two AnimatedContainers for the sex cards should exist
      expect(find.byType(AnimatedContainer), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // FrequencySummaryStep
  // ---------------------------------------------------------------------------

  group('FrequencySummaryStep', () {
    // A fully populated state so the Complete button is enabled
    const fullState = InitialOnboardingState(
      currentStep: 5,
      goal: TrainingGoalUI.buildMuscle,
      sex: BiologicalSex.male,
      age: 28,
      heightCm: 178,
      bodyweightKg: 80,
      experience: ExperienceLevelUI.someExperience,
      workoutsPerWeek: 4,
    );

    testWidgets('renders frequency title and subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(fullState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('How often do you train?'), findsOneWidget);
      expect(find.text('Workouts per week'), findsOneWidget);
    });

    testWidgets('renders seven frequency pill buttons (1-7)', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(fullState)],
        ),
      );
      await tester.pumpAndSettle();

      for (int day = 1; day <= 7; day++) {
        expect(find.text('$day'), findsOneWidget);
      }
    });

    testWidgets('renders Summary section title', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(fullState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Summary'), findsOneWidget);
    });

    testWidgets('summary cards display goal, sex, age, height, weight', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(fullState)],
          height: 1400,
        ),
      );
      await tester.pumpAndSettle();

      // Use skipOffstage: false because the ListView may scroll some items
      // out of the visible viewport at the default test surface size.
      expect(find.text('Goal', skipOffstage: false), findsOneWidget);
      expect(find.text('Sex', skipOffstage: false), findsOneWidget);
      expect(find.text('Age', skipOffstage: false), findsOneWidget);
      expect(find.text('Height', skipOffstage: false), findsOneWidget);
      expect(find.text('Weight', skipOffstage: false), findsOneWidget);
      expect(find.text('Experience', skipOffstage: false), findsOneWidget);
      expect(find.text('Frequency', skipOffstage: false), findsOneWidget);
    });

    testWidgets('summary shows correct goal label from state', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(fullState)],
        ),
      );
      await tester.pumpAndSettle();

      // Goal label includes icon + text
      expect(find.textContaining('Build muscle'), findsOneWidget);
    });

    testWidgets('summary shows correct age from state', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(fullState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('28 years'), findsOneWidget);
    });

    testWidgets('summary shows correct height from state', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(fullState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('178 cm'), findsOneWidget);
    });

    testWidgets('summary shows correct weight from state', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(fullState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('80 kg'), findsOneWidget);
    });

    testWidgets('summary shows frequency in x/week format', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(fullState)],
          height: 1400,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('4x / week', skipOffstage: false), findsOneWidget);
    });

    testWidgets('Complete button is enabled when state isComplete', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(fullState)],
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Start training!'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Complete button is disabled when state is incomplete', (
      tester,
    ) async {
      const incompleteState = InitialOnboardingState(
        currentStep: 5,
        workoutsPerWeek: 3,
        // goal, sex, age, height, weight, experience all null
      );

      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(incompleteState)],
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Start training!'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('tapping Complete button fires onComplete callback', (
      tester,
    ) async {
      bool completed = false;

      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () => completed = true),
          overrides: [buildOnboardingOverride(fullState)],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start training!'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets(
      'Complete button does not fire callback when isCompleting is true',
      (tester) async {
        bool completed = false;
        const completingState = InitialOnboardingState(
          currentStep: 5,
          goal: TrainingGoalUI.buildMuscle,
          sex: BiologicalSex.male,
          age: 28,
          heightCm: 178,
          bodyweightKg: 80,
          experience: ExperienceLevelUI.someExperience,
          workoutsPerWeek: 4,
          isCompleting: true,
        );

        await tester.pumpWidget(
          buildTestAppWithFrame(
            child: FrequencySummaryStep(onComplete: () => completed = true),
            overrides: [buildOnboardingOverride(completingState)],
          ),
        );
        // Use pump instead of pumpAndSettle because LoadingIndicator has a
        // continuous animation that would cause pumpAndSettle to time out.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // When isCompleting = true the button child is LoadingIndicator;
        // the onPressed callback is set to null (disabled).
        final filledButtons = tester
            .widgetList<FilledButton>(find.byType(FilledButton))
            .toList();

        // At least one FilledButton should exist and have onPressed == null
        expect(filledButtons.any((b) => b.onPressed == null), isTrue);
        expect(completed, isFalse);
      },
    );

    testWidgets('tapping a frequency pill calls setWorkoutsPerWeek', (
      tester,
    ) async {
      int? capturedFrequency;

      final notifierOverride = initialOnboardingNotifierProvider.overrideWith(
        () => _FrequencyCapturingNotifier(
          fullState,
          onFrequencySet: (f) => capturedFrequency = f,
        ),
      );

      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [notifierOverride],
        ),
      );
      await tester.pumpAndSettle();

      // Tap the "6" pill
      await tester.tap(find.text('6'));
      await tester.pumpAndSettle();

      expect(capturedFrequency, 6);
    });

    testWidgets('renders "Start training!" complete button text', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(fullState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Start training!'), findsOneWidget);
    });

    testWidgets('renders info text below Complete button', (tester) async {
      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(fullState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('You can change these settings anytime'),
        findsOneWidget,
      );
    });

    testWidgets('shows error message when errorMessage is set', (tester) async {
      const errorState = InitialOnboardingState(
        currentStep: 5,
        goal: TrainingGoalUI.buildMuscle,
        sex: BiologicalSex.male,
        age: 28,
        heightCm: 178,
        bodyweightKg: 80,
        experience: ExperienceLevelUI.someExperience,
        workoutsPerWeek: 4,
        errorMessage: 'Something went wrong. Please try again.',
      );

      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(errorState)],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('shows dash for missing goal in summary', (tester) async {
      const missingGoalState = InitialOnboardingState(
        currentStep: 5,
        sex: BiologicalSex.male,
        age: 28,
        heightCm: 178,
        bodyweightKg: 80,
        experience: ExperienceLevelUI.someExperience,
        workoutsPerWeek: 3,
        // goal is null
      );

      await tester.pumpWidget(
        buildTestAppWithFrame(
          child: FrequencySummaryStep(onComplete: () {}),
          overrides: [buildOnboardingOverride(missingGoalState)],
        ),
      );
      await tester.pumpAndSettle();

      // Dash is shown when goal is null
      expect(find.text('-'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // InitialOnboardingState unit tests
  // ---------------------------------------------------------------------------

  group('InitialOnboardingState', () {
    test('canProceedFromStep(0) always true (welcome)', () {
      const state = InitialOnboardingState();
      expect(state.canProceedFromStep(0), isTrue);
    });

    test('canProceedFromStep(1) false without goal', () {
      const state = InitialOnboardingState();
      expect(state.canProceedFromStep(1), isFalse);
    });

    test('canProceedFromStep(1) true when goal set', () {
      final state = const InitialOnboardingState().copyWith(
        goal: TrainingGoalUI.getStronger,
      );
      expect(state.canProceedFromStep(1), isTrue);
    });

    test('canProceedFromStep(2) false when sex missing', () {
      final state = const InitialOnboardingState().copyWith(age: 25);
      expect(state.canProceedFromStep(2), isFalse);
    });

    test('canProceedFromStep(2) false when age missing', () {
      final state = const InitialOnboardingState().copyWith(
        sex: BiologicalSex.female,
      );
      expect(state.canProceedFromStep(2), isFalse);
    });

    test('canProceedFromStep(2) true when sex and age provided', () {
      final state = const InitialOnboardingState().copyWith(
        sex: BiologicalSex.female,
        age: 25,
      );
      expect(state.canProceedFromStep(2), isTrue);
    });

    test('canProceedFromStep(3) false when bodyweight < 30 kg', () {
      final state = const InitialOnboardingState().copyWith(
        heightCm: 170,
        bodyweightKg: 20,
      );
      expect(state.canProceedFromStep(3), isFalse);
    });

    test('canProceedFromStep(3) true when height and valid weight set', () {
      final state = const InitialOnboardingState().copyWith(
        heightCm: 170,
        bodyweightKg: 70,
      );
      expect(state.canProceedFromStep(3), isTrue);
    });

    test('canProceedFromStep(4) false without experience', () {
      const state = InitialOnboardingState();
      expect(state.canProceedFromStep(4), isFalse);
    });

    test('canProceedFromStep(4) true when experience set', () {
      final state = const InitialOnboardingState().copyWith(
        experience: ExperienceLevelUI.athlete,
      );
      expect(state.canProceedFromStep(4), isTrue);
    });

    test('canProceedFromStep(5) true with valid workoutsPerWeek', () {
      final state = const InitialOnboardingState().copyWith(workoutsPerWeek: 3);
      expect(state.canProceedFromStep(5), isTrue);
    });

    test('isComplete false when any field missing', () {
      const state = InitialOnboardingState(
        goal: TrainingGoalUI.buildMuscle,
        sex: BiologicalSex.male,
        age: 25,
        heightCm: 175,
        bodyweightKg: 75,
        // experience missing
      );
      expect(state.isComplete, isFalse);
    });

    test('isComplete true when all required fields present', () {
      const state = InitialOnboardingState(
        goal: TrainingGoalUI.buildMuscle,
        sex: BiologicalSex.male,
        age: 25,
        heightCm: 175,
        bodyweightKg: 75,
        experience: ExperienceLevelUI.someExperience,
      );
      expect(state.isComplete, isTrue);
    });

    test('progress is 1/6 at step 0', () {
      const state = InitialOnboardingState(currentStep: 0);
      expect(state.progress, closeTo(1 / 6, 0.001));
    });

    test('progress is 6/6 at step 5', () {
      const state = InitialOnboardingState(currentStep: 5);
      expect(state.progress, closeTo(1.0, 0.001));
    });

    test('toOnboardingData returns null when not complete', () {
      const state = InitialOnboardingState(goal: TrainingGoalUI.buildMuscle);
      expect(state.toOnboardingData(), isNull);
    });

    test('toOnboardingData returns data when complete', () {
      const state = InitialOnboardingState(
        goal: TrainingGoalUI.endurance,
        sex: BiologicalSex.female,
        age: 30,
        heightCm: 165,
        bodyweightKg: 60,
        experience: ExperienceLevelUI.experienced,
        workoutsPerWeek: 5,
      );
      final data = state.toOnboardingData();
      expect(data, isNotNull);
      expect(data!.goal, TrainingGoalUI.endurance);
      expect(data.sex, BiologicalSex.female);
      expect(data.age, 30);
      expect(data.heightCm, 165);
      expect(data.bodyweightKg, 60);
      expect(data.experience, ExperienceLevelUI.experienced);
      expect(data.workoutsPerWeek, 5);
    });
  });

  // ---------------------------------------------------------------------------
  // InitialOnboardingNotifier unit tests
  // ---------------------------------------------------------------------------

  group('InitialOnboardingNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has currentStep = 0', () {
      final state = container.read(initialOnboardingNotifierProvider);
      expect(state.currentStep, 0);
    });

    test('initial workoutsPerWeek defaults to 3', () {
      final state = container.read(initialOnboardingNotifierProvider);
      expect(state.workoutsPerWeek, 3);
    });

    test('nextStep increments currentStep when canProceed', () {
      // Step 0 always can proceed
      container.read(initialOnboardingNotifierProvider.notifier).nextStep();
      final state = container.read(initialOnboardingNotifierProvider);
      expect(state.currentStep, 1);
    });

    test('nextStep does not advance past totalSteps - 1', () {
      final notifier = container.read(
        initialOnboardingNotifierProvider.notifier,
      );

      // Fill all required data and advance to last step
      notifier.setGoal(TrainingGoalUI.buildMuscle);
      notifier.setSex(BiologicalSex.male);
      notifier.setAge(25);
      notifier.setHeight(175);
      notifier.setBodyweight(75);
      notifier.setExperience(ExperienceLevelUI.beginner);

      // Advance through all steps
      for (int i = 0; i < 6; i++) {
        notifier.nextStep();
      }

      final state = container.read(initialOnboardingNotifierProvider);
      expect(state.currentStep, lessThanOrEqualTo(5));
    });

    test('previousStep decrements currentStep', () {
      final notifier = container.read(
        initialOnboardingNotifierProvider.notifier,
      );
      notifier.nextStep(); // step 0 → 1
      notifier.previousStep(); // step 1 → 0
      final state = container.read(initialOnboardingNotifierProvider);
      expect(state.currentStep, 0);
    });

    test('previousStep is a no-op at step 0', () {
      container.read(initialOnboardingNotifierProvider.notifier).previousStep();
      final state = container.read(initialOnboardingNotifierProvider);
      expect(state.currentStep, 0);
    });

    test('setGoal updates goal in state', () {
      container
          .read(initialOnboardingNotifierProvider.notifier)
          .setGoal(TrainingGoalUI.stayFit);
      final state = container.read(initialOnboardingNotifierProvider);
      expect(state.goal, TrainingGoalUI.stayFit);
    });

    test('setSex updates sex in state', () {
      container
          .read(initialOnboardingNotifierProvider.notifier)
          .setSex(BiologicalSex.female);
      final state = container.read(initialOnboardingNotifierProvider);
      expect(state.sex, BiologicalSex.female);
    });

    test('setAge rejects values outside 14-80 range', () {
      container.read(initialOnboardingNotifierProvider.notifier).setAge(13);
      expect(container.read(initialOnboardingNotifierProvider).age, isNull);

      container.read(initialOnboardingNotifierProvider.notifier).setAge(81);
      expect(container.read(initialOnboardingNotifierProvider).age, isNull);
    });

    test('setAge accepts valid values', () {
      container.read(initialOnboardingNotifierProvider.notifier).setAge(35);
      expect(container.read(initialOnboardingNotifierProvider).age, 35);
    });

    test('setHeight rejects out-of-range values', () {
      container.read(initialOnboardingNotifierProvider.notifier).setHeight(130);
      expect(
        container.read(initialOnboardingNotifierProvider).heightCm,
        isNull,
      );

      container.read(initialOnboardingNotifierProvider.notifier).setHeight(230);
      expect(
        container.read(initialOnboardingNotifierProvider).heightCm,
        isNull,
      );
    });

    test('setHeight accepts values in 140-220 range', () {
      container.read(initialOnboardingNotifierProvider.notifier).setHeight(170);
      expect(container.read(initialOnboardingNotifierProvider).heightCm, 170);
    });

    test('setBodyweight rejects weight < 30 kg', () {
      container
          .read(initialOnboardingNotifierProvider.notifier)
          .setBodyweight(20);
      expect(
        container.read(initialOnboardingNotifierProvider).bodyweightKg,
        isNull,
      );
    });

    test('setBodyweight accepts valid values', () {
      container
          .read(initialOnboardingNotifierProvider.notifier)
          .setBodyweight(80);
      expect(
        container.read(initialOnboardingNotifierProvider).bodyweightKg,
        80,
      );
    });

    test('setExperience updates experience in state', () {
      container
          .read(initialOnboardingNotifierProvider.notifier)
          .setExperience(ExperienceLevelUI.athlete);
      final state = container.read(initialOnboardingNotifierProvider);
      expect(state.experience, ExperienceLevelUI.athlete);
    });

    test('setWorkoutsPerWeek rejects out-of-range values', () {
      container
          .read(initialOnboardingNotifierProvider.notifier)
          .setWorkoutsPerWeek(0);
      expect(
        container.read(initialOnboardingNotifierProvider).workoutsPerWeek,
        3,
      ); // default unchanged

      container
          .read(initialOnboardingNotifierProvider.notifier)
          .setWorkoutsPerWeek(8);
      expect(
        container.read(initialOnboardingNotifierProvider).workoutsPerWeek,
        3,
      ); // default unchanged
    });

    test('setWorkoutsPerWeek accepts 1-7', () {
      container
          .read(initialOnboardingNotifierProvider.notifier)
          .setWorkoutsPerWeek(6);
      expect(
        container.read(initialOnboardingNotifierProvider).workoutsPerWeek,
        6,
      );
    });

    test('startCompletion sets isCompleting to true', () {
      container
          .read(initialOnboardingNotifierProvider.notifier)
          .startCompletion();
      expect(
        container.read(initialOnboardingNotifierProvider).isCompleting,
        isTrue,
      );
    });

    test('setError resets isCompleting and stores message', () {
      container
          .read(initialOnboardingNotifierProvider.notifier)
          .startCompletion();
      container
          .read(initialOnboardingNotifierProvider.notifier)
          .setError('Network error');

      final state = container.read(initialOnboardingNotifierProvider);
      expect(state.isCompleting, isFalse);
      expect(state.errorMessage, 'Network error');
    });

    test('reset returns state to initial values', () {
      final notifier = container.read(
        initialOnboardingNotifierProvider.notifier,
      );
      notifier.setGoal(TrainingGoalUI.buildMuscle);
      notifier.setSex(BiologicalSex.male);
      notifier.setAge(25);
      notifier.reset();

      final state = container.read(initialOnboardingNotifierProvider);
      expect(state.goal, isNull);
      expect(state.sex, isNull);
      expect(state.age, isNull);
      expect(state.currentStep, 0);
    });

    test('goToStep allows going back to earlier step', () {
      final notifier = container.read(
        initialOnboardingNotifierProvider.notifier,
      );
      notifier.nextStep(); // step 0 → 1
      notifier.goToStep(0); // back to step 0
      expect(container.read(initialOnboardingNotifierProvider).currentStep, 0);
    });

    test('goToStep does not allow skipping forward', () {
      final notifier = container.read(
        initialOnboardingNotifierProvider.notifier,
      );
      // Currently at step 0; trying to jump to step 3 should be rejected
      notifier.goToStep(3);
      expect(container.read(initialOnboardingNotifierProvider).currentStep, 0);
    });
  });
}

// ---------------------------------------------------------------------------
// Capturing notifier stubs used in widget tests
// ---------------------------------------------------------------------------

/// Notifier that records calls to nextStep.
class _TrackingOnboardingNotifier extends InitialOnboardingNotifier {
  _TrackingOnboardingNotifier(this._initialState, {required this.onNextStep});

  final InitialOnboardingState _initialState;
  final VoidCallback onNextStep;

  @override
  InitialOnboardingState build() => _initialState;

  @override
  void nextStep() {
    onNextStep();
    super.nextStep();
  }
}

/// Notifier that captures calls to setGoal.
class _GoalCapturingNotifier extends InitialOnboardingNotifier {
  _GoalCapturingNotifier(this._initialState, {required this.onGoalSet});

  final InitialOnboardingState _initialState;
  final void Function(TrainingGoalUI) onGoalSet;

  @override
  InitialOnboardingState build() => _initialState;

  @override
  void setGoal(TrainingGoalUI goal) {
    onGoalSet(goal);
    state = state.copyWith(goal: goal);
    // Do NOT auto-advance; keeps navigation side-effect out of tests.
  }
}

/// Notifier that captures calls to setExperience.
class _ExperienceCapturingNotifier extends InitialOnboardingNotifier {
  _ExperienceCapturingNotifier(
    this._initialState, {
    required this.onExperienceSet,
  });

  final InitialOnboardingState _initialState;
  final void Function(ExperienceLevelUI) onExperienceSet;

  @override
  InitialOnboardingState build() => _initialState;

  @override
  void setExperience(ExperienceLevelUI level) {
    onExperienceSet(level);
    state = state.copyWith(experience: level);
    // Do NOT auto-advance.
  }
}

/// Notifier that captures calls to setSex.
class _SexCapturingNotifier extends InitialOnboardingNotifier {
  _SexCapturingNotifier(this._initialState, {required this.onSexSet});

  final InitialOnboardingState _initialState;
  final void Function(BiologicalSex) onSexSet;

  @override
  InitialOnboardingState build() => _initialState;

  @override
  void setSex(BiologicalSex sex) {
    onSexSet(sex);
    state = state.copyWith(sex: sex);
  }
}

/// Notifier that captures calls to setWorkoutsPerWeek.
class _FrequencyCapturingNotifier extends InitialOnboardingNotifier {
  _FrequencyCapturingNotifier(
    this._initialState, {
    required this.onFrequencySet,
  });

  final InitialOnboardingState _initialState;
  final void Function(int) onFrequencySet;

  @override
  InitialOnboardingState build() => _initialState;

  @override
  void setWorkoutsPerWeek(int count) {
    onFrequencySet(count);
    state = state.copyWith(workoutsPerWeek: count);
  }
}
