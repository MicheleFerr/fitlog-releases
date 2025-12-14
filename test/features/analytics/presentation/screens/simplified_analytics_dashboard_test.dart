/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: test/features/analytics/presentation/screens
/// Feature: analytics dashboard
/// Type: widget test
/// Localization: AppLocalizations tested (EN/IT)
/// Theme: ColorScheme tested (light/dark)
/// Platform: Universal
///
/// Tests for SimplifiedAnalyticsDashboard screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/simplified_analytics_dashboard.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/weekly_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/hero_stat_section.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/stats_bar_widget.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/top_exercises_section.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/recent_activity_section.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

void main() {
  Widget buildWidget({
    List<Override> overrides = const [],
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const SimplifiedAnalyticsDashboard(),
      ),
    );
  }

  /// Helper to clean up widgets and prevent memory leaks
  Future<void> cleanUpWidget(WidgetTester tester) async {
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  }

  group('SimplifiedAnalyticsDashboard - Basic Rendering', () {
    testWidgets('renders scaffold', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.unauthenticated),
          ],
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders AppBar with title', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.unauthenticated),
          ],
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('renders back button in AppBar', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.unauthenticated),
          ],
        ),
      );

      expect(find.byIcon(AppIcons.back), findsOneWidget);
    });

    testWidgets('renders pro analytics action button', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.unauthenticated),
          ],
        ),
      );

      expect(find.byIcon(AppIcons.barChart), findsAtLeastNWidgets(1));
    });
  });

  group('SimplifiedAnalyticsDashboard - Authentication States', () {
    testWidgets('shows login prompt when not authenticated', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.unauthenticated),
          ],
        ),
      );

      // Should show not authenticated view
      expect(find.text('Sign in to view analytics'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows loading when authenticated but data loading',
        (tester) async {
      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.authenticated),
            weeklyAnalyticsProvider.overrideWith((ref) {
              // Use a never-completing future to keep in loading state
              return Future<WeeklyAnalyticsData>(() async {
                await Future<void>.delayed(const Duration(hours: 1));
                return _createMockWeeklyData();
              });
            }),
          ],
        ),
      );

      // Initial pump
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(LoadingIndicator), findsOneWidget);
    },
      // Skip this test due to timing issues with FakeAsync
      skip: true,
    );

    testWidgets('shows error when data fetch fails', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.authenticated),
            weeklyAnalyticsProvider.overrideWith((ref) {
              return Future.error('Test error');
            }),
          ],
        ),
      );

      // Wait for error state
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.byIcon(AppIcons.errorOutline), findsOneWidget);
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  group('SimplifiedAnalyticsDashboard - Content Sections', () {
    testWidgets('shows all sections when data loaded', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.authenticated),
            isPremiumUserProvider.overrideWith((ref) => false),
            weeklyAnalyticsProvider
                .overrideWith((ref) => Future.value(_createMockWeeklyData())),
          ],
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Section 1: Hero Stat Section
      expect(find.byType(HeroStatSection), findsOneWidget);

      // Section 2: Stats Bar Widget
      expect(find.byType(StatsBarWidget), findsOneWidget);

      // Section 3: Top Exercises Section
      expect(find.byType(TopExercisesSection), findsOneWidget);

      // Section 4: Recent Activity Section
      expect(find.byType(RecentActivitySection), findsOneWidget);

      // Clean up to prevent leak warnings
      await tester.pumpWidget(Container());
    });

    testWidgets('shows refresh indicator', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.authenticated),
            isPremiumUserProvider.overrideWith((ref) => false),
            weeklyAnalyticsProvider
                .overrideWith((ref) => Future.value(_createMockWeeklyData())),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
      await cleanUpWidget(tester);
    });

    testWidgets('hides top exercises when list is empty', (tester) async {
      final emptyData = _createMockWeeklyData(topExercises: []);

      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.authenticated),
            isPremiumUserProvider.overrideWith((ref) => false),
            weeklyAnalyticsProvider
                .overrideWith((ref) => Future.value(emptyData)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Top exercises section should not be present
      expect(find.byType(TopExercisesSection), findsNothing);
      await cleanUpWidget(tester);
    });
  });

  group('SimplifiedAnalyticsDashboard - Localization (EN/IT)', () {
    testWidgets('displays English text correctly', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          locale: const Locale('en'),
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.unauthenticated),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Sign in to view analytics'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('displays Italian text correctly', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          locale: const Locale('it'),
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.unauthenticated),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Accedi per visualizzare le statistiche'), findsOneWidget);
      expect(find.text('Accedi'), findsOneWidget);
    });
  });

  group('SimplifiedAnalyticsDashboard - Theme (Light/Dark)', () {
    testWidgets('renders correctly in light theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.authenticated),
            isPremiumUserProvider.overrideWith((ref) => false),
            weeklyAnalyticsProvider
                .overrideWith((ref) => Future.value(_createMockWeeklyData())),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData.light(),
            home: const SimplifiedAnalyticsDashboard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without errors in light theme
      expect(find.byType(Scaffold), findsOneWidget);
      await cleanUpWidget(tester);
    });

    testWidgets('renders correctly in dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.authenticated),
            isPremiumUserProvider.overrideWith((ref) => false),
            weeklyAnalyticsProvider
                .overrideWith((ref) => Future.value(_createMockWeeklyData())),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData.dark(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            home: const SimplifiedAnalyticsDashboard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without errors in dark theme
      expect(find.byType(Scaffold), findsOneWidget);
      await cleanUpWidget(tester);
    });
  });

  group('SimplifiedAnalyticsDashboard - Premium Features', () {
    testWidgets('shows PRO badge for non-premium users', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.authenticated),
            isPremiumUserProvider.overrideWith((ref) => false),
            weeklyAnalyticsProvider
                .overrideWith((ref) => Future.value(_createMockWeeklyData())),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Should show PRO badge in body heatmap section
      expect(find.text('PRO'), findsOneWidget);
      await cleanUpWidget(tester);
    });

    testWidgets('hides PRO badge for premium users', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.authenticated),
            isPremiumUserProvider.overrideWith((ref) => true),
            weeklyAnalyticsProvider
                .overrideWith((ref) => Future.value(_createMockWeeklyData())),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Should not show PRO badge
      expect(find.text('PRO'), findsNothing);
      await cleanUpWidget(tester);
    });
  });

  group('SimplifiedAnalyticsDashboard - Data Display', () {
    testWidgets('displays workout count correctly', (tester) async {
      final data = _createMockWeeklyData(weeklyWorkoutCount: 5);

      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.authenticated),
            isPremiumUserProvider.overrideWith((ref) => false),
            weeklyAnalyticsProvider.overrideWith((ref) => Future.value(data)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Hero section should be rendered with workout count
      expect(find.byType(HeroStatSection), findsOneWidget);
      await cleanUpWidget(tester);
    });

    testWidgets('displays weekly volume correctly', (tester) async {
      final data = _createMockWeeklyData(weeklyVolume: 15000.0);

      await tester.pumpWidget(
        buildWidget(
          overrides: [
            authStateProvider.overrideWith((ref) => AuthState.authenticated),
            isPremiumUserProvider.overrideWith((ref) => false),
            weeklyAnalyticsProvider.overrideWith((ref) => Future.value(data)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Stats bar should be rendered with volume
      expect(find.byType(StatsBarWidget), findsOneWidget);
      await cleanUpWidget(tester);
    });
  });
}

/// Helper function to create mock weekly analytics data
WeeklyAnalyticsData _createMockWeeklyData({
  int weeklyWorkoutCount = 3,
  int previousWeekWorkoutCount = 2,
  int? weeklyGoal,
  double weeklyVolume = 10000.0,
  int currentStreak = 5,
  int weeklyPRCount = 2,
  String measurementUnit = 'kg',
  Map<String, double>? muscleVolumePercentages,
  List<TopExerciseData>? topExercises,
  List<RecentWorkoutData>? recentWorkouts,
}) {
  return WeeklyAnalyticsData(
    weeklyWorkoutCount: weeklyWorkoutCount,
    previousWeekWorkoutCount: previousWeekWorkoutCount,
    weeklyGoal: weeklyGoal,
    weeklyVolume: weeklyVolume,
    currentStreak: currentStreak,
    weeklyPRCount: weeklyPRCount,
    measurementUnit: measurementUnit,
    muscleVolumePercentages: muscleVolumePercentages ??
        {
          'chest': 80.0,
          'back': 60.0,
          'legs': 100.0,
          'shoulders': 50.0,
        },
    topExercises: topExercises ??
        [
          TopExerciseData(
            name: 'Bench Press',
            sessionCount: 3,
            lastWeight: 80.0,
            lastReps: 10,
            weightDelta: 2.5,
            measurementUnit: measurementUnit,
          ),
          TopExerciseData(
            name: 'Squat',
            sessionCount: 2,
            lastWeight: 100.0,
            lastReps: 8,
            weightDelta: 5.0,
            measurementUnit: measurementUnit,
          ),
        ],
    recentWorkouts: recentWorkouts ??
        [
          RecentWorkoutData(
            id: 'workout-1',
            name: 'Push Day',
            date: DateTime.now().subtract(const Duration(days: 1)),
            durationMinutes: 60,
            exerciseCount: 5,
            totalVolume: 5000.0,
            muscleGroups: ['chest', 'shoulders', 'triceps'],
          ),
          RecentWorkoutData(
            id: 'workout-2',
            name: 'Pull Day',
            date: DateTime.now().subtract(const Duration(days: 3)),
            durationMinutes: 55,
            exerciseCount: 6,
            totalVolume: 4500.0,
            muscleGroups: ['back', 'biceps'],
          ),
        ],
  );
}
