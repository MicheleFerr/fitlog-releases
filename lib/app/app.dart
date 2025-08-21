import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../shared/presentation/l10n/generated/app_localizations.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/home_screen_tier1.dart';
import '../features/workout/presentation/workout_screen.dart';
import '../features/exercise_database/presentation/exercise_search_screen.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/workout/presentation/screens/workout_templates_screen.dart';
import '../features/community/presentation/screens/community_hub_screen.dart';
import '../tools/import_exercises_screen.dart';
import '../shared/presentation/theme/app_theme.dart';
import '../shared/presentation/providers/app_config_provider.dart';

class GymBroApp extends ConsumerWidget {
  const GymBroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final config = ref.watch(appConfigProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'GymBro TrackLog',
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
        builder: (context, state) => const HomeScreenTier1(),
      ),
      GoRoute(
        path: '/home-legacy',
        name: 'home-legacy',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/workout',
        name: 'workout',
        builder: (context, state) => const WorkoutScreen(),
      ),
      GoRoute(
        path: '/timer',
        name: 'timer',
        builder: (context, state) => const WorkoutScreen(), // Will create separate timer screen later
      ),
      GoRoute(
        path: '/exercises',
        name: 'exercises',
        builder: (context, state) => const ExerciseSearchScreen(),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
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
        path: '/workout-templates',
        name: 'workout-templates',
        builder: (context, state) => const WorkoutTemplatesScreen(),
      ),
      GoRoute(
        path: '/community',
        name: 'community',
        builder: (context, state) => const CommunityHubScreen(),
      ),
    ],
  );
});