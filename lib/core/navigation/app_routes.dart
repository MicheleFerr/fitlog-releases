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

  /// Navigator key for Analytics branch
  static final GlobalKey<NavigatorState> analyticsNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'analytics');

  /// Navigator key for Settings branch
  static final GlobalKey<NavigatorState> settingsNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'settings');

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

  /// Analytics tab - stats and progress
  static const String analyticsPath = '/analytics';
  static const String analyticsName = 'analytics';

  /// Settings tab - app configuration
  static const String settingsPath = '/settings';
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
  // Analytics Sub-Routes
  // ═══════════════════════════════════════════════════════════════════════════

  static const String analyticsOverviewPath = '/analytics/overview';
  static const String analyticsOverviewName = 'analytics-overview';

  static const String analyticsExerciseDetailPath =
      '/analytics/exercise/:exerciseName';
  static const String analyticsExerciseDetailName = 'analytics-exercise-detail';

  static const String exerciseProgressPath = '/analytics/exercise-progress';
  static const String exerciseProgressName = 'exercise-progress';

  // ═══════════════════════════════════════════════════════════════════════════
  // Settings Sub-Routes
  // ═══════════════════════════════════════════════════════════════════════════

  static const String debugLogSettingsPath = '/settings/debug-log';
  static const String debugLogSettingsName = 'debug-log-settings';

  static const String notificationsPath = '/settings/notifications';
  static const String notificationsName = 'notifications';

  static const String healthSyncPath = '/settings/health-sync';
  static const String healthSyncName = 'health-sync';

  // ═══════════════════════════════════════════════════════════════════════════
  // Feature Routes (outside shell)
  // ═══════════════════════════════════════════════════════════════════════════

  static const String aiCoachPath = '/ai-coach';
  static const String aiCoachName = 'ai-coach';

  static const String communityPath = '/community';
  static const String communityName = 'community';

  static const String routinePath = '/routine';
  static const String routineName = 'routine';

  static const String onboardingPath = '/onboarding';
  static const String onboardingName = 'onboarding';

  static const String adminPath = '/admin';
  static const String adminName = 'admin';

  static const String importExercisesPath = '/import-exercises';
  static const String importExercisesName = 'import-exercises';

  static const String unauthorizedPath = '/unauthorized';
  static const String unauthorizedName = 'unauthorized';

  // ═══════════════════════════════════════════════════════════════════════════
  // Branch Index Mapping (for StatefulShellRoute)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Branch index for each main tab
  static const int homeBranchIndex = 0;
  static const int workoutBranchIndex = 1;
  static const int analyticsBranchIndex = 2;
  static const int settingsBranchIndex = 3;

  /// Get branch index from route path
  static int? getBranchIndex(String path) {
    if (path == homePath || path.startsWith('/home')) {
      return homeBranchIndex;
    }
    if (path.startsWith(workoutPath)) {
      return workoutBranchIndex;
    }
    if (path.startsWith(analyticsPath)) {
      return analyticsBranchIndex;
    }
    if (path.startsWith(settingsPath)) {
      return settingsBranchIndex;
    }
    return null; // Not a shell route
  }
}
