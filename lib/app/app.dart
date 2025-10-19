import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/login_screen.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/register_screen.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/home/presentation/home_screen_optimized.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/workout_completion_summary_screen.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabbed_analytics_screen.dart';
// import 'package:gymbro_flutter_new/features/analytics/presentation/screens/analytics_dashboard_screen.dart'; // TEMP DISABLED
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/exercise_progress_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/exercise_detail_screen.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/settings_screen.dart';
import 'package:gymbro_flutter_new/features/community/presentation/screens/community_hub_screen.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/screens/routine_center_screen.dart';
import 'package:gymbro_flutter_new/features/history/presentation/screens/workout_history_screen.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/admin_analytics_dashboard_screen.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/global_onboarding_screen.dart';
import 'package:gymbro_flutter_new/tools/import_exercises_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_theme.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_initialization_provider.dart';

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
    ref.watch(fitnessProfileAutoLoadProvider);

    // 📊 ANALYTICS: Initialize analytics and set user properties
    // This runs once at app startup and whenever user settings change
    ref.watch(analyticsInitializationProvider);

    return MaterialApp.router(
      title: 'FitLog Pro',
      theme: _buildThemeWithFontSize(AppTheme.lightTheme, config.fontSize),
      darkTheme: _buildThemeWithFontSize(AppTheme.darkTheme, config.fontSize),
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
    );
  }

  ThemeData _buildThemeWithFontSize(ThemeData baseTheme, double fontSize) {
    if (fontSize == 1.0) {
      return baseTheme;
    }
    
    // Create a completely new text theme with scaled font sizes
    final originalTextTheme = baseTheme.textTheme;
    final scaledTextTheme = originalTextTheme.copyWith(
      displayLarge: originalTextTheme.displayLarge?.copyWith(
        fontSize: (originalTextTheme.displayLarge?.fontSize ?? 57) * fontSize,
      ),
      displayMedium: originalTextTheme.displayMedium?.copyWith(
        fontSize: (originalTextTheme.displayMedium?.fontSize ?? 45) * fontSize,
      ),
      displaySmall: originalTextTheme.displaySmall?.copyWith(
        fontSize: (originalTextTheme.displaySmall?.fontSize ?? 36) * fontSize,
      ),
      headlineLarge: originalTextTheme.headlineLarge?.copyWith(
        fontSize: (originalTextTheme.headlineLarge?.fontSize ?? 32) * fontSize,
      ),
      headlineMedium: originalTextTheme.headlineMedium?.copyWith(
        fontSize: (originalTextTheme.headlineMedium?.fontSize ?? 28) * fontSize,
      ),
      headlineSmall: originalTextTheme.headlineSmall?.copyWith(
        fontSize: (originalTextTheme.headlineSmall?.fontSize ?? 24) * fontSize,
      ),
      titleLarge: originalTextTheme.titleLarge?.copyWith(
        fontSize: (originalTextTheme.titleLarge?.fontSize ?? 22) * fontSize,
      ),
      titleMedium: originalTextTheme.titleMedium?.copyWith(
        fontSize: (originalTextTheme.titleMedium?.fontSize ?? 16) * fontSize,
      ),
      titleSmall: originalTextTheme.titleSmall?.copyWith(
        fontSize: (originalTextTheme.titleSmall?.fontSize ?? 14) * fontSize,
      ),
      labelLarge: originalTextTheme.labelLarge?.copyWith(
        fontSize: (originalTextTheme.labelLarge?.fontSize ?? 14) * fontSize,
      ),
      labelMedium: originalTextTheme.labelMedium?.copyWith(
        fontSize: (originalTextTheme.labelMedium?.fontSize ?? 12) * fontSize,
      ),
      labelSmall: originalTextTheme.labelSmall?.copyWith(
        fontSize: (originalTextTheme.labelSmall?.fontSize ?? 11) * fontSize,
      ),
      bodyLarge: originalTextTheme.bodyLarge?.copyWith(
        fontSize: (originalTextTheme.bodyLarge?.fontSize ?? 16) * fontSize,
      ),
      bodyMedium: originalTextTheme.bodyMedium?.copyWith(
        fontSize: (originalTextTheme.bodyMedium?.fontSize ?? 14) * fontSize,
      ),
      bodySmall: originalTextTheme.bodySmall?.copyWith(
        fontSize: (originalTextTheme.bodySmall?.fontSize ?? 12) * fontSize,
      ),
    );
    
    return baseTheme.copyWith(textTheme: scaledTextTheme);
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState == AuthState.authenticated;
      final isLoggingIn = state.fullPath == '/login' || state.fullPath == '/register';
      
      // If not logged in and not on login/register page, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      
      // If logged in and on login page, redirect to home
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }
      
      return null; // No redirect needed
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Page not found: ${state.fullPath ?? state.path ?? 'Unknown'}'),
            const SizedBox(height: 16),
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
        builder: (context, state) => const WorkoutScreen(),
      ),
      GoRoute(
        path: '/workout-completion-summary',
        name: 'workout-completion-summary',
        builder: (context, state) {
          final workout = state.extra as Workout;
          return WorkoutCompletionSummaryScreen(workout: workout);
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
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const GlobalOnboardingScreen(),
      ),
    ],
  );
});