/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: core/navigation
/// Feature: Application Route Constants
/// Type: Constants
///
/// Single source of truth for all route paths and names.
///
/// **Usage**:
/// ```dart
/// context.goNamed(AppRoutes.home);
/// context.push(AppRoutes.workoutPath);
/// ```
library;

import 'package:flutter/material.dart';

/// Route constants for type-safe navigation
///
/// Centralizes all route paths and names to prevent typos
/// and ensure consistency across the app.
abstract final class AppRoutes {
  // ═══════════════════════════════════════════════════════════════════════════
  // Navigation Keys (for StatefulShellRoute state preservation)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Navigator key for Home branch
  static final GlobalKey<NavigatorState> homeNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'home');

  /// Navigator key for Workout branch
  static final GlobalKey<NavigatorState> workoutNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'workout');

  /// Navigator key for Profile branch (replaces Analytics + Settings tabs)
  static final GlobalKey<NavigatorState> profileNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'profile');

  /// Root navigator key
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  // ═══════════════════════════════════════════════════════════════════════════
  // Authentication Routes
  // ═══════════════════════════════════════════════════════════════════════════

  static const String loginPath = '/login';
  static const String loginName = 'login';

  static const String registerPath = '/register';
  static const String registerName = 'register';

  // ═══════════════════════════════════════════════════════════════════════════
  // Main Tab Routes (StatefulShellRoute branches)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Home tab - landing page with quick actions
  static const String homePath = '/';
  static const String homeName = 'home';

  /// Workout tab - active workout and templates
  static const String workoutPath = '/workout';
  static const String workoutName = 'workout';

  /// Profile tab - user hub with quick actions
  static const String profilePath = '/profile';
  static const String profileName = 'profile';

  // Note: Analytics and Settings are now pushed routes from Profile hub
  /// Analytics screen - pushed from Profile > Statistiche
  static const String analyticsPath = '/profile/analytics';
  static const String analyticsName = 'analytics';

  /// Settings screen - pushed from Profile > ⚙️ icon
  static const String settingsPath = '/profile/settings';
  static const String settingsName = 'settings';

  // ═══════════════════════════════════════════════════════════════════════════
  // Workout Sub-Routes
  // ═══════════════════════════════════════════════════════════════════════════

  static const String workoutCompletionPath = '/workout/completion';
  static const String workoutCompletionName = 'workout-completion';

  static const String workoutExerciseDetailPath =
      '/workout/exercise/:exerciseName';
  static const String workoutExerciseDetailName = 'workout-exercise-detail';

  static const String exercisesPath = '/workout/exercises';
  static const String exercisesName = 'exercises';

  static const String workoutHistoryPath = '/workout/history';
  static const String workoutHistoryName = 'workout-history';

  // ═══════════════════════════════════════════════════════════════════════════
  // Analytics Sub-Routes (under /profile/analytics)
  // ═══════════════════════════════════════════════════════════════════════════

  static const String analyticsOverviewPath = '/profile/analytics/overview';
  static const String analyticsOverviewName = 'analytics-overview';

  static const String analyticsExerciseDetailPath =
      '/profile/analytics/exercise/:exerciseName';
  static const String analyticsExerciseDetailName = 'analytics-exercise-detail';

  static const String exerciseProgressPath = '/profile/analytics/exercise-progress';
  static const String exerciseProgressName = 'exercise-progress';

  static const String exerciseProgressDetailPath = '/profile/analytics/exercise-progress/detail';
  static const String exerciseProgressDetailName = 'exercise-progress-detail';

  static const String proAnalyticsPath = '/profile/analytics/pro';
  static const String proAnalyticsName = 'pro-analytics';

  // ═══════════════════════════════════════════════════════════════════════════
  // Settings Sub-Routes
  // ═══════════════════════════════════════════════════════════════════════════

  static const String healthSyncPath = '/settings/health-sync';
  static const String healthSyncName = 'health-sync';

  static const String healthDebugPath = '/settings/health-debug';
  static const String healthDebugName = 'health-debug';

  static const String importDataPath = '/profile/settings/import';
  static const String importDataName = 'import-data';

  // ═══════════════════════════════════════════════════════════════════════════
  // Feature Routes (outside shell)
  // ═══════════════════════════════════════════════════════════════════════════

  static const String aiCoachPath = '/ai-coach';
  static const String aiCoachName = 'ai-coach';

  static const String communityPath = '/community';
  static const String communityName = 'community';

  static const String routinePath = '/routine';
  static const String routineName = 'routine';

  static const String templatesPath = '/templates';
  static const String templatesName = 'templates';

  static const String templateDetailPath = '/templates/detail';
  static const String templateDetailName = 'template-detail';

  static const String onboardingPath = '/onboarding';
  static const String onboardingName = 'onboarding';

  static const String adminPath = '/admin';
  static const String adminName = 'admin';

  static const String importExercisesPath = '/import-exercises';
  static const String importExercisesName = 'import-exercises';

  static const String unauthorizedPath = '/unauthorized';
  static const String unauthorizedName = 'unauthorized';

  // ═══════════════════════════════════════════════════════════════════════════
  // Profile Sub-Routes (pushed from Profile hub quick actions)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Body measurements screen - pushed from Profile > Misurazioni
  static const String bodyMeasurementsPath = '/profile/measurements';
  static const String bodyMeasurementsName = 'body-measurements';

  /// Streak calendar screen - pushed from Profile > Calendario
  static const String streakCalendarPath = '/profile/calendar';
  static const String streakCalendarName = 'streak-calendar';

  /// Exercise database/history - pushed from Profile > Esercizi
  static const String exerciseDatabasePath = '/profile/exercises';
  static const String exerciseDatabaseName = 'exercise-database';

  /// Edit profile screen - pushed from Profile > ✏️ icon
  static const String editProfilePath = '/profile/edit';
  static const String editProfileName = 'edit-profile';

  /// Premium screen - pushed from Profile or other screens
  static const String premiumPath = '/profile/premium';
  static const String premiumName = 'premium';

  /// Exercise merge screen - consolidate similar exercises
  static const String exerciseMergePath = '/profile/exercise-merge';
  static const String exerciseMergeName = 'exercise-merge';

  // ═══════════════════════════════════════════════════════════════════════════
  // Coach Mode Routes
  // ═══════════════════════════════════════════════════════════════════════════

  /// Coach dashboard - main hub for coaches
  static const String coachDashboardPath = '/profile/coach';
  static const String coachDashboardName = 'coach-dashboard';

  /// Athletes list - all athletes for a coach
  static const String athletesListPath = '/profile/coach/athletes';
  static const String athletesListName = 'athletes-list';

  /// Link to coach - for athletes to enter coach code
  static const String linkCoachPath = '/profile/link-coach';
  static const String linkCoachName = 'link-coach';

  /// Athlete detail - coach view of a specific athlete
  static const String athleteDetailPath = '/profile/coach/athletes/:athleteId';
  static const String athleteDetailName = 'athlete-detail';

  // ═══════════════════════════════════════════════════════════════════════════
  // Branch Index Mapping (for StatefulShellRoute)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Branch index for each main tab (3 tabs: Home, Workout, Profile)
  static const int homeBranchIndex = 0;
  static const int workoutBranchIndex = 1;
  static const int profileBranchIndex = 2;

  /// Get branch index from route path
  static int? getBranchIndex(String path) {
    if (path == homePath || path.startsWith('/home')) {
      return homeBranchIndex;
    }
    if (path.startsWith(workoutPath)) {
      return workoutBranchIndex;
    }
    if (path.startsWith(profilePath)) {
      return profileBranchIndex;
    }
    return null; // Not a shell route
  }
}
