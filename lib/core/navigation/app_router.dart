/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: core/navigation
/// Feature: Application Router
/// Type: GoRouter Configuration
///
/// Complete router implementation using StatefulShellRoute for
/// persistent bottom navigation with 4 branches.
///
/// **Architecture** (2024/2025 Best Practices):
/// ```
/// GoRouter
///   ├── Auth Routes (login, register) - outside shell
///   ├── StatefulShellRoute (MainShell)
///   │   ├── Branch 0: Home
///   │   │   └── Sub-routes (community, ai-coach, etc.)
///   │   ├── Branch 1: Workout
///   │   │   └── Sub-routes (completion, exercises, history)
///   │   ├── Branch 2: Analytics
///   │   │   └── Sub-routes (overview, exercise-detail, progress)
///   │   └── Branch 3: Settings
///   │       └── Sub-routes (notifications, health-sync, debug)
///   └── Modal Routes (outside shell, full-screen)
/// ```
///
/// **Performance**:
/// - State preservation across branch switching
/// - Lazy route building (deferred loading)
/// - Navigator key separation (independent back stacks)
library;

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/core/navigation/main_shell.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

// Auth
import 'package:gymbro_flutter_new/features/auth/presentation/login_screen.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/register_screen.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';

// Home branch
import 'package:gymbro_flutter_new/features/home/presentation/home_screen_optimized.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/screens/ai_coach_screen.dart';
import 'package:gymbro_flutter_new/features/community/presentation/screens/community_hub_screen.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/global_onboarding_screen.dart';

// Workout branch
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/workout_completion_summary_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/workout_exercise_detail_screen.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/features/history/presentation/screens/workout_history_screen.dart';

// Analytics branch
import 'package:gymbro_flutter_new/features/analytics/presentation/analytics_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabbed_analytics_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/exercise_detail_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/exercise_progress_screen.dart';

// Settings branch
import 'package:gymbro_flutter_new/features/settings/presentation/settings_screen.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/screens/debug_log_settings_screen.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/screens/notification_settings_screen_v2.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/screens/health_sync_settings_screen.dart';

// Other routes
import 'package:gymbro_flutter_new/features/admin/presentation/screens/admin_analytics_dashboard_screen.dart';
import 'package:gymbro_flutter_new/tools/import_exercises_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/screens/unauthorized_screen.dart';
import 'package:gymbro_flutter_new/shared/domain/auth/providers/security_providers.dart';

/// Main router provider using StatefulShellRoute
///
/// Provides:
/// - Auth-aware routing with redirect
/// - 4-branch bottom navigation with state preservation
/// - Deep linking support
/// - Error handling
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final rbacService = ref.watch(rbacServiceProvider);

  return GoRouter(
    navigatorKey: AppRoutes.rootNavigatorKey,
    initialLocation: AppRoutes.homePath,
    debugLogDiagnostics: kDebugMode,
    // ═══════════════════════════════════════════════════════════════════════
    // REDIRECT LOGIC
    // ═══════════════════════════════════════════════════════════════════════
    redirect: (context, state) {
      final isLoggedIn = authState == AuthState.authenticated;
      final isLoggingIn = state.fullPath == AppRoutes.loginPath ||
          state.fullPath == AppRoutes.registerPath;
      final currentPath = state.fullPath ?? state.path ?? '/';

      // Wait for auth to initialize
      if (authState == AuthState.loading) {
        return null;
      }

      // Record user activity (reset session timeout)
      if (isLoggedIn) {
        ref.read(sessionActivityRecorderProvider);
      }

      // Not logged in and not on auth pages → redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return AppRoutes.loginPath;
      }

      // Logged in and on auth pages → redirect to home
      if (isLoggedIn && isLoggingIn) {
        return AppRoutes.homePath;
      }

      // RBAC check
      if (isLoggedIn && !rbacService.canAccessRoute(currentPath)) {
        if (kDebugMode) {
          debugPrint(
              '🚨 [RBAC] Access denied to $currentPath for role: ${rbacService.currentRole}');
        }
        return AppRoutes.unauthorizedPath;
      }

      return null;
    },
    // ═══════════════════════════════════════════════════════════════════════
    // ERROR HANDLING
    // ═══════════════════════════════════════════════════════════════════════
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: Text(context.l10n.pageNotFound)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(AppIcons.error, size: 64),
            const SizedBox(height: 16),
            Text('Page not found: ${state.fullPath ?? 'Unknown'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.goNamed(AppRoutes.homeName),
              child: Text(context.l10n.goBack),
            ),
          ],
        ),
      ),
    ),
    // ═══════════════════════════════════════════════════════════════════════
    // ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    routes: [
      // ─────────────────────────────────────────────────────────────────────
      // AUTH ROUTES (outside shell)
      // ─────────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        parentNavigatorKey: AppRoutes.rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerPath,
        name: AppRoutes.registerName,
        parentNavigatorKey: AppRoutes.rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // MAIN SHELL (4-branch bottom navigation)
      // ─────────────────────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // ═════════════════════════════════════════════════════════════════
          // BRANCH 0: HOME
          // ═════════════════════════════════════════════════════════════════
          StatefulShellBranch(
            navigatorKey: AppRoutes.homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.homePath,
                name: AppRoutes.homeName,
                builder: (context, state) => const HomeScreenOptimized(),
                routes: [
                  // AI Coach (sub-route of home)
                  GoRoute(
                    path: 'ai-coach',
                    name: AppRoutes.aiCoachName,
                    builder: (context, state) => const AICoachScreen(),
                  ),
                  // Community
                  GoRoute(
                    path: 'community',
                    name: AppRoutes.communityName,
                    builder: (context, state) => const CommunityHubScreen(),
                  ),
                  // Onboarding
                  GoRoute(
                    path: 'onboarding',
                    name: AppRoutes.onboardingName,
                    builder: (context, state) => const GlobalOnboardingScreen(),
                  ),
                  // Routine placeholder
                  GoRoute(
                    path: 'routine',
                    name: AppRoutes.routineName,
                    builder: (context, state) =>
                        const _RoutineComingSoonPlaceholder(),
                  ),
                ],
              ),
            ],
          ),

          // ═════════════════════════════════════════════════════════════════
          // BRANCH 1: WORKOUT
          // ═════════════════════════════════════════════════════════════════
          StatefulShellBranch(
            navigatorKey: AppRoutes.workoutNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.workoutPath,
                name: AppRoutes.workoutName,
                builder: (context, state) => const WorkoutScreen(),
                routes: [
                  // Workout completion
                  GoRoute(
                    path: 'completion',
                    name: AppRoutes.workoutCompletionName,
                    builder: (context, state) {
                      final workout = state.extra as Workout;
                      return WorkoutCompletionSummaryScreen(workout: workout);
                    },
                  ),
                  // Exercise detail in workout
                  GoRoute(
                    path: 'exercise/:exerciseName',
                    name: AppRoutes.workoutExerciseDetailName,
                    builder: (context, state) {
                      final exerciseName = state.pathParameters['exerciseName']!;
                      return WorkoutExerciseDetailScreen(
                        exerciseName: Uri.decodeComponent(exerciseName),
                      );
                    },
                  ),
                  // Exercise search
                  GoRoute(
                    path: 'exercises',
                    name: AppRoutes.exercisesName,
                    builder: (context, state) => const ExerciseSearchScreen(),
                  ),
                  // Workout history
                  GoRoute(
                    path: 'history',
                    name: AppRoutes.workoutHistoryName,
                    builder: (context, state) => const WorkoutHistoryScreen(),
                  ),
                ],
              ),
            ],
          ),

          // ═════════════════════════════════════════════════════════════════
          // BRANCH 2: ANALYTICS
          // ═════════════════════════════════════════════════════════════════
          StatefulShellBranch(
            navigatorKey: AppRoutes.analyticsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.analyticsPath,
                name: AppRoutes.analyticsName,
                builder: (context, state) => const AnalyticsScreen(),
                routes: [
                  // Analytics overview (tabbed)
                  GoRoute(
                    path: 'overview',
                    name: AppRoutes.analyticsOverviewName,
                    builder: (context, state) => const TabbedAnalyticsScreen(),
                  ),
                  // Exercise detail
                  GoRoute(
                    path: 'exercise/:exerciseName',
                    name: AppRoutes.analyticsExerciseDetailName,
                    builder: (context, state) {
                      final exerciseName = state.pathParameters['exerciseName']!;
                      return ExerciseDetailScreen(
                        exerciseName: Uri.decodeComponent(exerciseName),
                      );
                    },
                  ),
                  // Exercise progress
                  GoRoute(
                    path: 'exercise-progress',
                    name: AppRoutes.exerciseProgressName,
                    builder: (context, state) => const ExerciseProgressScreen(),
                  ),
                ],
              ),
            ],
          ),

          // ═════════════════════════════════════════════════════════════════
          // BRANCH 3: SETTINGS
          // ═════════════════════════════════════════════════════════════════
          StatefulShellBranch(
            navigatorKey: AppRoutes.settingsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.settingsPath,
                name: AppRoutes.settingsName,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  // Debug log settings
                  GoRoute(
                    path: 'debug-log',
                    name: AppRoutes.debugLogSettingsName,
                    builder: (context, state) => const DebugLogSettingsScreen(),
                  ),
                  // Notifications
                  GoRoute(
                    path: 'notifications',
                    name: AppRoutes.notificationsName,
                    builder: (context, state) =>
                        const NotificationSettingsScreenV2(),
                  ),
                  // Health sync
                  GoRoute(
                    path: 'health-sync',
                    name: AppRoutes.healthSyncName,
                    builder: (context, state) =>
                        const HealthSyncSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────────────
      // MODAL/FULL-SCREEN ROUTES (outside shell)
      // ─────────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.adminPath,
        name: AppRoutes.adminName,
        parentNavigatorKey: AppRoutes.rootNavigatorKey,
        builder: (context, state) => const AdminAnalyticsDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.importExercisesPath,
        name: AppRoutes.importExercisesName,
        parentNavigatorKey: AppRoutes.rootNavigatorKey,
        builder: (context, state) => const ImportExercisesScreen(),
      ),
      GoRoute(
        path: AppRoutes.unauthorizedPath,
        name: AppRoutes.unauthorizedName,
        parentNavigatorKey: AppRoutes.rootNavigatorKey,
        builder: (context, state) => const UnauthorizedScreen(),
      ),
    ],
  );
});

/// Placeholder widget for disabled routine feature
class _RoutineComingSoonPlaceholder extends StatelessWidget {
  const _RoutineComingSoonPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.routine),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.construction,
                size: 64,
                color: context.colors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.comingSoon,
                style: context.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Routine feature is being rebuilt',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
