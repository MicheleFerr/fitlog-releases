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
import 'package:gymbro_flutter_new/features/home/presentation/minimal_home_screen.dart';
import 'package:gymbro_flutter_new/features/help_center/presentation/screens/help_center_screen.dart';
import 'package:gymbro_flutter_new/features/community/presentation/screens/community_hub_screen.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/global_onboarding_screen.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/screens/templates_home_screen.dart';

// Workout branch
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/workout_completion_summary_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/workout_exercise_detail_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/template_view_screen.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/features/history/presentation/screens/workout_history_screen.dart';

// Analytics branch
import 'package:gymbro_flutter_new/features/analytics/presentation/analytics_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabbed_analytics_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/exercise_detail_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/exercise_progress_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/pro_analytics_tabbed_screen.dart';

// Settings (pushed from Profile)
import 'package:gymbro_flutter_new/features/settings/presentation/settings_screen.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/screens/health_sync_settings_screen.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/screens/healthkit_debug_screen.dart';
import 'package:gymbro_flutter_new/features/import/presentation/screens/import_screen.dart';

// Profile branch
import 'package:gymbro_flutter_new/features/profile/presentation/screens/profile_hub_screen.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/screens/streak_calendar_screen.dart';
import 'package:gymbro_flutter_new/features/body_measurements/presentation/screens/measurement_list_screen.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/user_consent.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/screens/simple_premium_screen.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/presentation/screens/exercise_merge_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

// Coach
import 'package:gymbro_flutter_new/features/coach/presentation/screens/coach_dashboard_screen.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/screens/athletes_list_screen.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/screens/link_coach_screen.dart';

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
                builder: (context, state) => const MinimalHomeScreen(),
                routes: [
                  // Help Center (replaces AI Coach)
                  GoRoute(
                    path: 'ai-coach', // Keep same path for backwards compatibility
                    name: AppRoutes.aiCoachName,
                    builder: (context, state) => const HelpCenterScreen(),
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
                  // Templates
                  GoRoute(
                    path: 'templates',
                    name: AppRoutes.templatesName,
                    builder: (context, state) => const TemplatesHomeScreen(),
                    routes: [
                      // Template detail (view mode)
                      GoRoute(
                        path: 'detail',
                        name: AppRoutes.templateDetailName,
                        builder: (context, state) {
                          final templateId = state.extra as String;
                          return TemplateViewScreen(templateId: templateId);
                        },
                      ),
                    ],
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
                      final exerciseId = state.uri.queryParameters['id'];
                      return WorkoutExerciseDetailScreen(
                        exerciseName: Uri.decodeComponent(exerciseName),
                        exerciseId: exerciseId,
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
          // BRANCH 2: PROFILE (replaces Analytics + Settings tabs)
          // ═════════════════════════════════════════════════════════════════
          StatefulShellBranch(
            navigatorKey: AppRoutes.profileNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.profilePath,
                name: AppRoutes.profileName,
                builder: (context, state) => const ProfileHubScreen(),
                routes: [
                  // Analytics (pushed from Statistiche quick action)
                  GoRoute(
                    path: 'analytics',
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
                        routes: [
                          // Exercise progress detail
                          GoRoute(
                            path: 'detail',
                            name: AppRoutes.exerciseProgressDetailName,
                            builder: (context, state) {
                              final exerciseName = state.extra as String;
                              return ExerciseDetailScreen(
                                exerciseName: exerciseName,
                              );
                            },
                          ),
                        ],
                      ),
                      // Pro Analytics (tabbed version)
                      GoRoute(
                        path: 'pro',
                        name: AppRoutes.proAnalyticsName,
                        builder: (context, state) => const ProAnalyticsTabbedScreen(),
                      ),
                    ],
                  ),
                  // Settings (pushed from ⚙️ icon)
                  GoRoute(
                    path: 'settings',
                    name: AppRoutes.settingsName,
                    builder: (context, state) => const SettingsScreen(),
                    routes: [
                      // Health sync
                      GoRoute(
                        path: 'health-sync',
                        name: AppRoutes.healthSyncName,
                        builder: (context, state) =>
                            const HealthSyncSettingsScreen(),
                      ),
                      // Health debug (HealthKit/Health Connect diagnostic)
                      GoRoute(
                        path: 'health-debug',
                        name: AppRoutes.healthDebugName,
                        builder: (context, state) =>
                            const HealthKitDebugScreen(),
                      ),
                      // Import data from other apps
                      GoRoute(
                        path: 'import',
                        name: AppRoutes.importDataName,
                        builder: (context, state) => const ImportScreen(),
                      ),
                    ],
                  ),
                  // Body measurements (pushed from Misurazioni quick action)
                  GoRoute(
                    path: 'measurements',
                    name: AppRoutes.bodyMeasurementsName,
                    builder: (context, state) => const _MeasurementListWrapper(),
                  ),
                  // Streak calendar (pushed from Calendario quick action)
                  GoRoute(
                    path: 'calendar',
                    name: AppRoutes.streakCalendarName,
                    builder: (context, state) => const StreakCalendarScreen(),
                  ),
                  // Exercise database (pushed from Esercizi quick action)
                  GoRoute(
                    path: 'exercises',
                    name: AppRoutes.exerciseDatabaseName,
                    builder: (context, state) => const WorkoutHistoryScreen(),
                  ),
                  // Edit profile (pushed from ✏️ icon)
                  GoRoute(
                    path: 'edit',
                    name: AppRoutes.editProfileName,
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  // Premium screen
                  GoRoute(
                    path: 'premium',
                    name: AppRoutes.premiumName,
                    builder: (context, state) => const SimplePremiumScreen(),
                  ),
                  // Exercise merge (consolidate custom exercises)
                  GoRoute(
                    path: 'exercise-merge',
                    name: AppRoutes.exerciseMergeName,
                    builder: (context, state) => const ExerciseMergeScreen(),
                  ),
                  // Coach dashboard (for users in coach mode)
                  GoRoute(
                    path: 'coach',
                    name: AppRoutes.coachDashboardName,
                    builder: (context, state) => const CoachDashboardScreen(),
                    routes: [
                      // Athletes list
                      GoRoute(
                        path: 'athletes',
                        name: AppRoutes.athletesListName,
                        builder: (context, state) => const AthletesListScreen(),
                      ),
                    ],
                  ),
                  // Link to coach (for athletes to enter coach code)
                  GoRoute(
                    path: 'link-coach',
                    name: AppRoutes.linkCoachName,
                    builder: (context, state) => const LinkCoachScreen(),
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


/// Wrapper to provide userId to MeasurementListScreen with GDPR consent handling
class _MeasurementListWrapper extends ConsumerStatefulWidget {
  const _MeasurementListWrapper();

  @override
  ConsumerState<_MeasurementListWrapper> createState() =>
      _MeasurementListWrapperState();
}

class _MeasurementListWrapperState
    extends ConsumerState<_MeasurementListWrapper> {
  bool _isCheckingConsent = true;
  bool _hasConsent = false;
  bool _isGrantingConsent = false;

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    final userAsync = ref.read(firebaseUserProvider);
    final user = userAsync.valueOrNull;
    if (user == null) {
      setState(() {
        _isCheckingConsent = false;
      });
      return;
    }

    final consentRepo = ref.read(consentRepositoryProvider);
    final result = await consentRepo.getConsent(user.uid);

    if (!mounted) return;

    result.fold(
      (failure) {
        // ConsentNotFoundFailure means no consent yet - show consent request
        setState(() {
          _isCheckingConsent = false;
          _hasConsent = false;
        });
      },
      (consent) {
        // Check if user has granted consent for at least essential metrics
        final hasEssentialConsent =
            consent.groupConsents[MetricGroup.essential] == ConsentState.granted;
        setState(() {
          _isCheckingConsent = false;
          _hasConsent = hasEssentialConsent;
        });
      },
    );
  }

  Future<void> _grantConsent(String userId) async {
    setState(() {
      _isGrantingConsent = true;
    });

    final consentRepo = ref.read(consentRepositoryProvider);

    // First try to create initial consent
    var result = await consentRepo.createInitialConsent(
      userId: userId,
      ipAddress: '0.0.0.***', // Privacy: masked IP
    );

    // If consent already exists, we can proceed to grant
    if (result.isLeft()) {
      // Consent might already exist, try to grant directly
      result = await consentRepo.grantConsent(
        userId: userId,
        group: MetricGroup.essential,
        ipAddress: '0.0.0.***',
      );

      // Also grant measurements consent
      await consentRepo.grantConsent(
        userId: userId,
        group: MetricGroup.measurements,
        ipAddress: '0.0.0.***',
      );
    } else {
      // Initial consent created, now grant essential + measurements
      await consentRepo.grantConsent(
        userId: userId,
        group: MetricGroup.essential,
        ipAddress: '0.0.0.***',
      );
      await consentRepo.grantConsent(
        userId: userId,
        group: MetricGroup.measurements,
        ipAddress: '0.0.0.***',
      );
    }

    if (!mounted) return;

    setState(() {
      _isGrantingConsent = false;
      _hasConsent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(firebaseUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.measurements)),
            body: Center(child: Text(context.l10n.pleaseSignIn)),
          );
        }

        if (_isCheckingConsent) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.measurements)),
            body: const Center(child: LoadingIndicator()),
          );
        }

        if (!_hasConsent) {
          return _buildConsentRequestScreen(context, user.uid);
        }

        return MeasurementListScreen(userId: user.uid);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(context.l10n.measurements)),
        body: const Center(child: LoadingIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.measurements)),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildConsentRequestScreen(BuildContext context, String userId) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.measurements)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.bodyMeasurements,
                size: 64,
                color: context.colors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.bodyMeasurementsConsentTitle,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.bodyMeasurementsConsentDescription,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _isGrantingConsent
                  ? const LoadingIndicator()
                  : FilledButton.icon(
                      onPressed: () => _grantConsent(userId),
                      icon: const Icon(AppIcons.check),
                      label: Text(context.l10n.bodyMeasurementsGrantConsent),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(context.l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

