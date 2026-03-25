// Re-export initialDeepLinkProvider for backward compatibility
// (moved to shared/presentation/providers/deep_link_provider.dart
// to break circular dependency with app_router.dart)
export 'package:gymbro_flutter_new/shared/presentation/providers/deep_link_provider.dart'
    show initialDeepLinkProvider;

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_theme.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_theme_mode.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_initialization_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/auth/providers/session_timeout_providers.dart';
import 'package:gymbro_flutter_new/shared/domain/auth/session_timeout_service.dart';
import 'package:gymbro_flutter_new/features/workout/timer/presentation/providers/unified_timer_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_background_sync_provider.dart';
import 'package:gymbro_flutter_new/core/navigation/app_router.dart';
import 'package:gymbro_flutter_new/features/splash/presentation/screens/animated_splash_screen.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/onboarding_orchestrator.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/purchase_providers.dart';

/// Provider for async notification initialization
final notificationInitProvider = FutureProvider<void>((ref) async {
  final scheduler = ref.watch(notificationSchedulerProvider);
  await scheduler.initialize();
  ref.read(notificationInitializedProvider.notifier).state = true;
  if (kDebugMode) {
    debugPrint('🔔 [APP] Notification system initialized');
  }
});

/// Notifier for tracking if animated splash has completed
class AnimatedSplashNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Mark splash as completed
  void complete() {
    state = true;
  }
}

/// Provider to track if animated splash has completed
/// Set to true after 3-second animation finishes
final animatedSplashCompletedProvider =
    NotifierProvider<AnimatedSplashNotifier, bool>(AnimatedSplashNotifier.new);

/// Provider to handle app lifecycle events (background/foreground)
/// P0 FIX: Reset onboarding session step counter when app resumes from background
final appLifecycleProvider = Provider<void>((ref) {
  // P0 FIX: defer la modifica dello state fuori dall'init sincrono
  // (Riverpod non permette di modificare altri provider durante la build)
  Future.microtask(() {
    ref.read(onboardingOrchestratorProvider.notifier).resetSessionSteps();
    if (kDebugMode) {
      debugPrint('🔄 [APP] Initialized onboarding session on app startup');
    }
  });
});

class FitLogApp extends ConsumerWidget {
  const FitLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎬 ANIMATED SPLASH: Show splash with lightning animation before app
    final splashCompleted = ref.watch(animatedSplashCompletedProvider);

    if (!splashCompleted) {
      // Wrap in MaterialApp to provide Directionality and other required ancestors
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
          onComplete: () {
            ref.read(animatedSplashCompletedProvider.notifier).complete();
          },
        ),
      );
    }

    // Use new StatefulShellRoute-based router
    final router = ref.watch(appRouterProvider);

    // 🔔 DEEP LINK: Navigate when notification tapped while app is running (warm-start)
    ref.listen(pendingNotificationDeepLinkProvider, (previous, next) {
      if (next != null) {
        if (kDebugMode) {
          debugPrint('🔔 [DeepLink] Warm-start navigation → $next');
        }
        router.go(next);
        // Clear after navigation to prevent re-navigation on rebuild
        ref.read(pendingNotificationDeepLinkProvider.notifier).state = null;
      }
    });
    // 🔧 PERF FIX: Use .select() to watch ONLY specific fields needed by MaterialApp
    // This prevents full app rebuild when unrelated settings change (e.g., soundEnabled, vibrationsEnabled)
    // Before: ANY config change → full MaterialApp rebuild → blank screen flash
    // After: ONLY fontSize/primaryColor changes → rebuild
    final fontSize = ref.watch(appConfigProvider.select((c) => c.fontSize));
    final primaryColor = ref.watch(
      appConfigProvider.select((c) => c.primaryColor),
    );
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final appThemeMode = ref.watch(appThemeModeProvider);

    // 🔥 CRITICAL: Load fitness questionnaire at app startup
    // This ensures weight suggestions work immediately without needing to visit settings first
    // ✅ FIX: Don't block UI if loading fails - use .whenOrNull to handle error states
    ref
        .watch(fitnessProfileAutoLoadProvider)
        .whenOrNull(
          error: (error, stack) {
            if (kDebugMode) {
              debugPrint('⚠️ [APP] Fitness profile auto-load failed: $error');
            }
          },
        );

    // 📊 ANALYTICS: Initialize analytics and set user properties
    // This runs once at app startup and whenever user settings change
    // ✅ FIX: Don't block UI if analytics fails - gracefully degrade
    ref
        .watch(analyticsInitializationProvider)
        .whenOrNull(
          error: (error, stack) {
            if (kDebugMode) {
              debugPrint('⚠️ [APP] Analytics initialization failed: $error');
            }
          },
        );

    // 💳 PREMIUM: Initialize RevenueCat early so premium access can resolve
    // before premium-gated UI renders for the current session.
    ref
        .watch(revenueCatInitProvider)
        .whenOrNull(
          error: (error, stack) {
            if (kDebugMode) {
              debugPrint('⚠️ [APP] Premium initialization failed: $error');
            }
          },
        );

    // 🔒 SECURITY: Initialize session timeout monitoring
    // Auto-logout after 30 minutes of inactivity (GDPR compliance)
    ref.watch(sessionTimeoutServiceProvider);

    // Ensure Health sync startup refresh runs app-wide when enabled.
    ref.watch(healthBackgroundSyncControllerProvider);

    // ⏱️ TIMER FIX: Pre-initialize timer provider at app startup
    // This prevents the 10+ second delay on first timer use
    // ✅ FIX: Watch the provider to ensure it's initialized
    ref.watch(unifiedTimerProvider);

    // 🏋️ EXERCISE SYNC: Initialize sync service for auto-updates
    // This enables automatic exercise database updates when new version is available
    ref
        .watch(exerciseSyncInitProvider)
        .whenOrNull(
          error: (error, stack) {
            if (kDebugMode) {
              debugPrint(
                '⚠️ [APP] Exercise sync initialization failed: $error',
              );
            }
          },
        );

    // 🔄 APP LIFECYCLE: P0 FIX - Reset onboarding session steps on app resume
    ref.watch(appLifecycleProvider);

    // 🔔 NOTIFICATIONS: Initialize notification system for retention reminders
    // This enables workout forgotten, inactivity, and insight notifications
    ref
        .watch(notificationInitProvider)
        .whenOrNull(
          error: (error, stack) {
            if (kDebugMode) {
              debugPrint('⚠️ [APP] Notification initialization failed: $error');
            }
          },
        );

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
        theme: _buildThemeWithFontSize(
          AppTheme.buildLightTheme(primaryColor),
          fontSize,
        ),
        darkTheme: _buildThemeWithFontSize(
          AppTheme.buildDarkTheme(primaryColor),
          fontSize,
        ),
        themeMode: themeMode,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoadingIndicator(),
                const SizedBox(height: 24),
                Builder(
                  builder: (context) => Text(
                    'Loading FitLog Pro...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ FIX #5: If router creation fails (e.g., provider errors), show error screen
    // This prevents black screen when providers fail to initialize
    // NOTE: _AppLifecycleObserver REMOVED - lifecycle handled by AppLifecycleManager (centralized)
    try {
      // Compute effective themes based on AppThemeMode
      final effectiveThemes = _resolveThemes(
        appThemeMode,
        primaryColor,
        fontSize,
      );

      return MaterialApp.router(
        title: 'FitLog Pro',
        theme: effectiveThemes.lightTheme,
        darkTheme: effectiveThemes.darkTheme,
        themeMode: effectiveThemes.themeMode,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US'), Locale('it', 'IT')],
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // Global: dismiss keyboard on tap outside any text field.
          // Use Listener instead of GestureDetector to avoid competing
          // with native platform views (CNTabBar) in the gesture arena.
          return Listener(
            onPointerDown: (_) => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: child,
          );
        },
      );
    } catch (e, stack) {
      // ✅ FIX #5: Graceful error handling - show error screen instead of black screen
      if (kDebugMode) {
        debugPrint('❌ [APP] Router initialization failed: $e');
        debugPrint('Stack trace: $stack');
      }

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _buildThemeWithFontSize(
          AppTheme.buildLightTheme(primaryColor),
          fontSize,
        ),
        darkTheme: _buildThemeWithFontSize(
          AppTheme.buildDarkTheme(primaryColor),
          fontSize,
        ),
        themeMode: themeMode,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.error,
                    size: AppIconSize.xxlarge,
                    color: appThemeMode.isDark
                        ? const Color(0xFFE57373)
                        : const Color(0xFFD32F2F),
                  ),
                  const SizedBox(height: 24),
                  Builder(
                    builder: (ctx) => Text(
                      'Failed to initialize app',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (ctx) => Text(
                      kDebugMode ? 'Error: $e' : 'Please restart the app',
                      style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          ctx,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  /// Resolve effective themes based on AppThemeMode
  _ResolvedThemes _resolveThemes(
    AppThemeMode appThemeMode,
    String primaryColor,
    double fontSize,
  ) {
    final lightTheme = _buildThemeWithFontSize(
      AppTheme.buildLightTheme(primaryColor),
      fontSize,
    );
    final darkTheme = _buildThemeWithFontSize(
      AppTheme.buildDarkTheme(primaryColor),
      fontSize,
    );

    switch (appThemeMode) {
      case AppThemeMode.system:
        return _ResolvedThemes(lightTheme, darkTheme, ThemeMode.system);
      case AppThemeMode.light:
        return _ResolvedThemes(lightTheme, darkTheme, ThemeMode.light);
      case AppThemeMode.dark:
        return _ResolvedThemes(lightTheme, darkTheme, ThemeMode.dark);
      case AppThemeMode.ultraDark:
        final ultraDark = _buildThemeWithFontSize(
          AppTheme.buildUltraDarkTheme(primaryColor),
          fontSize,
        );
        return _ResolvedThemes(ultraDark, ultraDark, ThemeMode.dark);
      case AppThemeMode.pink:
        final pink = _buildThemeWithFontSize(
          AppTheme.buildPinkTheme(primaryColor),
          fontSize,
        );
        return _ResolvedThemes(pink, pink, ThemeMode.light);
      case AppThemeMode.darkPink:
        final darkPink = _buildThemeWithFontSize(
          AppTheme.buildDarkPinkTheme(primaryColor),
          fontSize,
        );
        return _ResolvedThemes(darkPink, darkPink, ThemeMode.dark);
    }
  }

  /// Build theme with font size scaling
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

/// Helper class to pass resolved theme data
class _ResolvedThemes {
  const _ResolvedThemes(this.lightTheme, this.darkTheme, this.themeMode);
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;
}

// NOTE: _AppLifecycleObserver REMOVED (was FIX #3)
//
// The class was 100% redundant - it only did logging with no actual action.
// Its own comments stated: "SessionTimeoutService is monitored automatically via Timer.periodic
// No need to explicitly handle lifecycle changes"
//
// All lifecycle handling is now centralized in AppLifecycleManager (single source of truth):
// - Emergency workout save
// - Template cache save
// - Batch queue flush
// - Workout forgotten notification
// - Draft recovery
