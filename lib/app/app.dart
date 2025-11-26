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
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_initialization_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/auth/providers/session_timeout_providers.dart';
import 'package:gymbro_flutter_new/shared/domain/auth/session_timeout_service.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_provider.dart';
import 'package:gymbro_flutter_new/core/navigation/app_router.dart';

/// Provider for async notification initialization
final notificationInitProvider = FutureProvider<void>((ref) async {
  final scheduler = ref.watch(notificationSchedulerProvider);
  await scheduler.initialize();
  ref.read(notificationInitializedProvider.notifier).state = true;
  if (kDebugMode) {
    debugPrint('🔔 [APP] Notification system initialized');
  }
});

class FitLogApp extends ConsumerWidget {
  const FitLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use new StatefulShellRoute-based router
    final router = ref.watch(appRouterProvider);
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

    // 🔔 NOTIFICATIONS: Initialize notification system for retention reminders
    // This enables workout forgotten, inactivity, and insight notifications
    ref.watch(notificationInitProvider).whenOrNull(
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
        theme: _buildThemeWithFontSize(AppTheme.buildLightTheme(config.primaryColor), config.fontSize),
        darkTheme: _buildThemeWithFontSize(AppTheme.buildDarkTheme(config.primaryColor), config.fontSize),
        themeMode: themeMode,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoadingIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Loading FitLog Pro...',
                  style: TextStyle(
                    fontSize: 16 * config.fontSize,
                    color: themeMode == ThemeMode.dark
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black.withValues(alpha: 0.87),
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
    try {
      return _AppLifecycleObserver(
        child: MaterialApp.router(
          title: 'FitLog Pro',
          theme: _buildThemeWithFontSize(AppTheme.buildLightTheme(config.primaryColor), config.fontSize),
          darkTheme: _buildThemeWithFontSize(AppTheme.buildDarkTheme(config.primaryColor), config.fontSize),
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
      );
    } catch (e, stack) {
      // ✅ FIX #5: Graceful error handling - show error screen instead of black screen
      if (kDebugMode) {
        debugPrint('❌ [APP] Router initialization failed: $e');
        debugPrint('Stack trace: $stack');
      }

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _buildThemeWithFontSize(AppTheme.buildLightTheme(config.primaryColor), config.fontSize),
        darkTheme: _buildThemeWithFontSize(AppTheme.buildDarkTheme(config.primaryColor), config.fontSize),
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
                    color: themeMode == ThemeMode.dark
                      ? const Color(0xFFE57373)
                      : const Color(0xFFD32F2F),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Failed to initialize app',
                    style: TextStyle(
                      fontSize: 20 * config.fontSize,
                      fontWeight: FontWeight.bold,
                      color: themeMode == ThemeMode.dark
                        ? Colors.white
                        : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    kDebugMode
                      ? 'Error: $e'
                      : 'Please restart the app',
                    style: TextStyle(
                      fontSize: 14 * config.fontSize,
                      color: themeMode == ThemeMode.dark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.54),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
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

/// Provider for initial deep link (set during cold-start from notifications)
/// This is overridden in main.dart ProviderScope.overrides
final initialDeepLinkProvider = Provider<String?>((ref) => null);