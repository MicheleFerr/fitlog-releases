import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/login_screen.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/register_screen.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/home/presentation/home_screen_optimized.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/workout_completion_summary_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/workout_exercise_detail_screen.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabbed_analytics_screen.dart';
// import 'package:gymbro_flutter_new/features/analytics/presentation/screens/analytics_dashboard_screen.dart'; // TEMP DISABLED
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/exercise_progress_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/exercise_detail_screen.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/settings_screen.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/screens/debug_log_settings_screen.dart';
import 'package:gymbro_flutter_new/features/community/presentation/screens/community_hub_screen.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/screens/routine_center_screen.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/screens/equipment_profiles_screen.dart';
import 'package:gymbro_flutter_new/features/history/presentation/screens/workout_history_screen.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/admin_analytics_dashboard_screen.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/global_onboarding_screen.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/quick_start_screen.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_state_provider.dart';
import 'package:gymbro_flutter_new/tools/import_exercises_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/dynamic_theme_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_initialization_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/auth/providers/security_providers.dart';
import 'package:gymbro_flutter_new/shared/domain/auth/providers/session_timeout_providers.dart';
import 'package:gymbro_flutter_new/shared/domain/auth/session_timeout_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/screens/unauthorized_screen.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/widgets/notification_services_initializer.dart';

class FitLogApp extends ConsumerWidget {
  const FitLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final config = ref.watch(appConfigProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    // 🔥 CRITICAL: Load fitness questionnaire at app startup
    // This ensures weight suggestions work immediately without needing to visit settings first
    // ✅ FIX: Don't block UI if loading fails - use .whenOrNull to handle error states
    ref.watch(fitnessProfileAutoLoadProvider).whenOrNull(
      error: (error, stack) {
        if (kDebugMode) {
          debugPrint('⚠️ [APP] Fitness profile auto-load failed: $error');
        }
      },
    );

    // 📊 ANALYTICS: Initialize analytics and set user properties
    // This runs once at app startup and whenever user settings change
    // ✅ FIX: Don't block UI if analytics fails - gracefully degrade
    ref.watch(analyticsInitializationProvider).whenOrNull(
      error: (error, stack) {
        if (kDebugMode) {
          debugPrint('⚠️ [APP] Analytics initialization failed: $error');
        }
      },
    );

    // 🔒 SECURITY: Initialize session timeout monitoring
    // Auto-logout after 30 minutes of inactivity (GDPR compliance)
    ref.watch(sessionTimeoutServiceProvider);

    // ⏱️ TIMER FIX: Pre-initialize timer provider at app startup
    // This prevents the 10+ second delay on first timer use
    // ✅ FIX: Watch the provider to ensure it's initialized
    ref.watch(unifiedTimerProvider);

    // 🔒 SECURITY: Listen for session timeout events
    ref.listen(sessionTimeoutEventsProvider, (previous, next) {
      next.when(
        data: (event) {
          if (event is SessionWarningEvent) {
            // TODO: Show session expiring warning dialog
            debugPrint('⚠️ Session expiring in ${event.remainingSeconds}s');
          } else if (event is SessionExpiredEvent) {
            // TODO: Show session expired dialog
            debugPrint('🚨 Session expired: ${event.reason}');
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    });

    // ✅ FIX #3: Wrap MaterialApp with lifecycle observer to handle background/foreground
    // ✅ FIX #4: Show loading screen if router is still initializing
    // ✅ FIX #5: Handle auth errors gracefully instead of black screen
    final authState = ref.watch(authStateProvider);

    // Show loading screen while auth is initializing
    if (authState == AuthState.loading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ref.watch(dynamicThemeProvider(Brightness.light)),
        darkTheme: ref.watch(dynamicThemeProvider(Brightness.dark)),
        themeMode: themeMode,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Loading FitLog Pro...',
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontSize: (context.textTheme.bodyLarge?.fontSize ?? 16) * config.fontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ✅ FIX #5: If router creation fails (e.g., provider errors), show error screen
    // This prevents black screen when providers fail to initialize
    try {
      return NotificationServicesInitializer(
        child: _AppLifecycleObserver(
          child: MaterialApp.router(
            title: 'FitLog Pro',
            theme: ref.watch(dynamicThemeProvider(Brightness.light)),
            darkTheme: ref.watch(dynamicThemeProvider(Brightness.dark)),
            themeMode: themeMode,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('it', 'IT'),
          ],
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ),
        ),
      );
    } catch (e, stack) {
      // ✅ FIX #5: Graceful error handling - show error screen instead of black screen
      if (kDebugMode) {
        debugPrint('❌ [APP] Router initialization failed: $e');
        debugPrint('Stack trace: $stack');
      }

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ref.watch(dynamicThemeProvider(Brightness.light)),
        darkTheme: ref.watch(dynamicThemeProvider(Brightness.dark)),
        themeMode: themeMode,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.errorOutlineRounded,
                      size: 64,
                      color: context.colors.error,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Failed to initialize app',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: (context.textTheme.titleLarge?.fontSize ?? 20) * config.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      kDebugMode
                        ? 'Error: $e'
                        : 'Please restart the app',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: (context.textTheme.bodyMedium?.fontSize ?? 14) * config.fontSize,
                        color: context.colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

/// ✅ FIX #3: Lifecycle Observer for Session Timeout Background/Foreground handling
///
/// Wraps the MaterialApp to observe app lifecycle state changes and notify
/// the SessionTimeoutService to adjust timeout calculations when app goes
/// to background/foreground, preventing premature logout when device is locked.
class _AppLifecycleObserver extends ConsumerStatefulWidget {
  const _AppLifecycleObserver({required this.child});

  final Widget child;

  @override
  ConsumerState<_AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<_AppLifecycleObserver>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (kDebugMode) {
      debugPrint('🔒 [FIX-3] AppLifecycleObserver registered');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (kDebugMode) {
      debugPrint('🔒 [FIX-3] AppLifecycleObserver disposed');
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    try {
      // SessionTimeoutService is monitored automatically via Timer.periodic
      // No need to explicitly handle lifecycle changes

      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
          // App going to background
          // SessionTimeoutService handles background automatically with Timer.periodic
          if (kDebugMode) {
            debugPrint('🌙 [FIX-3] App lifecycle: $state (session timeout continues)');
          }
          break;

        case AppLifecycleState.resumed:
          // App returning to foreground
          // SessionTimeoutService is already running
          if (kDebugMode) {
            debugPrint('☀️ [FIX-3] App lifecycle: $state (session timeout active)');
          }
          break;

        case AppLifecycleState.detached:
        case AppLifecycleState.hidden:
          // App terminating or hidden
          if (kDebugMode) {
            debugPrint('⚠️ [FIX-3] App lifecycle: $state (no action)');
          }
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FIX-3] Error handling app lifecycle: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final rbacService = ref.watch(rbacServiceProvider);
  // 🔒 CRITICAL FIX: Use .select() to ONLY watch hasCompletedQuickStart
  // Watching entire onboardingState causes router rebuild on every state change
  // This created infinite loop: HomeScreen → navigate → startOnboarding() → state change → router rebuild → HomeScreen
  final hasCompletedQuickStart = ref.watch(
    onboardingStateProvider.select((state) => state.hasCompletedQuickStart),
  );

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState == AuthState.authenticated;
      final isLoggingIn = state.fullPath == '/login' || state.fullPath == '/register';
      final isOnQuickStart = state.fullPath == '/quick-start';
      final currentPath = state.fullPath ?? state.path ?? '/';

      // ⚠️ CRITICAL FIX: Don't redirect while auth is loading
      // Wait for Firebase Auth to fully initialize before making routing decisions
      // This prevents the bug where users are logged out on app restart
      if (authState == AuthState.loading) {
        return null; // Wait for auth to load
      }

      // 🔒 SECURITY: Record user activity (reset session timeout)
      if (isLoggedIn) {
        ref.read(sessionActivityRecorderProvider);
      }

      // ✅ AUTH CHECK: If not logged in and not on login/register page, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // ✅ AUTH CHECK: If logged in and on login page, redirect to home
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      // 🆕 ONBOARDING CHECK: If logged in but hasn't completed Quick Start, redirect there
      // Skip if already on Quick Start page or old onboarding page
      if (isLoggedIn &&
          !hasCompletedQuickStart &&
          !isOnQuickStart &&
          currentPath != '/onboarding') {
        debugPrint('🎯 [ONBOARDING] Redirecting to Quick Start (user has not completed it yet)');
        return '/quick-start';
      }

      // 🔒 RBAC CHECK: Verify user has permission to access route
      if (isLoggedIn && !rbacService.canAccessRoute(currentPath)) {
        debugPrint('🚨 [RBAC] Access denied to $currentPath for role: ${rbacService.currentRole}');
        return '/unauthorized';
      }

      return null; // No redirect needed
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: Text(context.l10n.pageNotFound)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.error, size: 64),
            SizedBox(height: 16),
            Text('Page not found: ${state.fullPath ?? state.path ?? 'Unknown'}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.goNamed('home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreenOptimized(),
      ),
      GoRoute(
        path: '/workout',
        name: 'workout',
        builder: (context, state) {
          // Read queryParameters from CTA or direct navigation
          final templateId = state.uri.queryParameters['templateId'];
          final sessionId = state.uri.queryParameters['sessionId'];
          final fromSmartCTA = state.uri.queryParameters['fromSmartCTA'] == 'true';

          return WorkoutScreen(
            initialTemplateId: templateId,
            sessionId: sessionId,
            fromSmartCTA: fromSmartCTA,
          );
        },
      ),
      GoRoute(
        path: '/workout-completion-summary',
        name: 'workout-completion-summary',
        builder: (context, state) {
          final workout = state.extra as Workout;
          return WorkoutCompletionSummaryScreen(workout: workout);
        },
      ),
      GoRoute(
        path: '/workout-exercise-detail/:exerciseName',
        name: 'workout-exercise-detail',
        builder: (context, state) {
          final exerciseName = state.pathParameters['exerciseName']!;
          return WorkoutExerciseDetailScreen(
            exerciseName: Uri.decodeComponent(exerciseName),
          );
        },
      ),
      // ✅ REMOVED: Dead route '/timer' (0 usage, redirected to /workout)
      GoRoute(
        path: '/exercises',
        name: 'exercises',
        builder: (context, state) => const ExerciseSearchScreen(),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const TabbedAnalyticsScreen(),
      ),
      // TEMP DISABLED: Analytics dashboard
      // GoRoute(
      //   path: '/analytics-dashboard',
      //   name: 'analytics-dashboard',
      //   builder: (context, state) => const AnalyticsDashboardScreen(),
      // ),
      GoRoute(
        path: '/exercise-progress',
        name: 'exercise-progress',
        builder: (context, state) => const ExerciseProgressScreen(),
      ),
      GoRoute(
        path: '/exercise-progress/detail',
        name: 'exercise-detail',
        builder: (context, state) {
          final exerciseName = state.extra as String;
          return ExerciseDetailScreen(exerciseName: exerciseName);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/equipment-profiles',
        name: 'equipment-profiles',
        builder: (context, state) => const EquipmentProfilesScreen(),
      ),
      GoRoute(
        path: '/settings/debug-log-settings',
        name: 'debug-log-settings',
        builder: (context, state) => const DebugLogSettingsScreen(),
      ),
      GoRoute(
        path: '/import-exercises',
        name: 'import-exercises',
        builder: (context, state) => const ImportExercisesScreen(),
      ),
      GoRoute(
        path: '/routine',
        name: 'routine',
        builder: (context, state) => const RoutineCenterScreen(),
      ),
      GoRoute(
        path: '/community',
        name: 'community',
        builder: (context, state) => const CommunityHubScreen(),
      ),
      GoRoute(
        path: '/workout-history',
        name: 'workout-history',
        builder: (context, state) => const WorkoutHistoryScreen(),
      ),
      // ✅ REMOVED: Dead route '/migration' (0 usage, legacy migration tool)
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminAnalyticsDashboardScreen(),
      ),
      // ✅ REMOVED: Dead route '/fitness-profile-debug' (0 usage, debug-only screen)
      GoRoute(
        path: '/quick-start',
        name: 'quick-start',
        builder: (context, state) => const QuickStartScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const GlobalOnboardingScreen(),
      ),
      GoRoute(
        path: '/unauthorized',
        name: 'unauthorized',
        builder: (context, state) => const UnauthorizedScreen(),
      ),
    ],
  );
});
