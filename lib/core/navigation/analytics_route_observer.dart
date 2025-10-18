/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/navigation
/// 🎯 Feature: analytics
/// 🔧 Type: route observer
///
/// Route observer for automatic screen view tracking
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';

/// Analytics route observer
///
/// Automatically tracks screen views when users navigate between screens.
/// Integrates with Flutter's Navigator to log analytics events on route changes.
///
/// Features:
/// - Automatic screen view tracking on push/pop
/// - Extracts screen name from route settings
/// - Works with named routes and GoRouter
/// - No-op if analytics service is null
///
/// Usage with MaterialApp:
/// ```dart
/// final analyticsObserver = AnalyticsRouteObserver(
///   analytics: ref.read(analyticsServiceProvider),
/// );
///
/// MaterialApp(
///   navigatorObservers: [analyticsObserver],
///   // ...
/// );
/// ```
///
/// Usage with GoRouter:
/// ```dart
/// final goRouter = GoRouter(
///   observers: [
///     AnalyticsRouteObserver(
///       analytics: ref.read(analyticsServiceProvider),
///     ),
///   ],
///   routes: [
///     GoRoute(
///       name: 'home',
///       path: '/',
///       builder: (context, state) => HomeScreen(),
///     ),
///   ],
/// );
/// ```
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver({
    required this.analytics,
  });

  final IAnalyticsService analytics;

  /// Track screen view when route is pushed
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logScreenView(route);
  }

  /// Track screen view when route is popped and previous route is visible
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _logScreenView(previousRoute);
    }
  }

  /// Track screen view when route is replaced
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logScreenView(newRoute);
    }
  }

  /// Track screen view when route is removed and previous route is visible
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (previousRoute != null) {
      _logScreenView(previousRoute);
    }
  }

  /// Extract screen name and log to analytics
  void _logScreenView(Route<dynamic> route) {
    // Extract screen name from route settings
    final screenName = _extractScreenName(route);

    if (screenName != null && screenName.isNotEmpty) {
      // Log screen view
      analytics.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );

      if (kDebugMode) {
        debugPrint('📊 Screen view tracked: $screenName');
      }
    }
  }

  /// Extract screen name from route
  ///
  /// Priority:
  /// 1. Route settings name (GoRouter named routes)
  /// 2. Route name from Route class
  /// 3. Fallback to 'unknown'
  String? _extractScreenName(Route<dynamic> route) {
    // Try route settings name first (GoRouter uses this)
    if (route.settings.name != null && route.settings.name!.isNotEmpty) {
      // Remove leading slash if present (e.g., '/home' -> 'home')
      var name = route.settings.name!;
      if (name.startsWith('/')) {
        name = name.substring(1);
      }
      // If still empty after removing slash, use 'home'
      return name.isEmpty ? 'home' : name;
    }

    // Try getting class name from route
    final routeType = route.runtimeType.toString();
    if (routeType != 'MaterialPageRoute' &&
        routeType != 'CupertinoPageRoute' &&
        routeType != 'PageRoute') {
      return routeType;
    }

    // Fallback
    return 'unknown';
  }
}

/// Analytics mixin for widgets
///
/// Provides convenient methods for tracking analytics events from widgets.
/// Mix this into your ConsumerWidget or StatefulWidget for easy access.
///
/// Features:
/// - Event logging helpers
/// - Screen view tracking
/// - User property setters
/// - Performance tracing
///
/// Usage:
/// ```dart
/// class MyWidget extends ConsumerWidget with AnalyticsMixin {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return ElevatedButton(
///       onPressed: () => logEvent(
///         ref,
///         name: 'button_clicked',
///         parameters: {'screen': 'MyWidget'},
///       ),
///       child: Text('Click Me'),
///     );
///   }
/// }
/// ```
mixin AnalyticsMixin {
  /// Log an analytics event
  Future<void> logEvent(
    WidgetRef ref, {
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    final analytics = _getAnalytics(ref);
    await analytics.logEvent(name: name, parameters: parameters);
  }

  /// Log screen view
  Future<void> logScreenView(
    WidgetRef ref, {
    required String screenName,
    String? screenClass,
  }) async {
    final analytics = _getAnalytics(ref);
    await analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Set user property
  Future<void> setUserProperty(
    WidgetRef ref, {
    required String name,
    required String? value,
  }) async {
    final analytics = _getAnalytics(ref);
    await analytics.setUserProperty(name: name, value: value);
  }

  /// Start performance trace
  Future<String> startTrace(WidgetRef ref, String name) async {
    final analytics = _getAnalytics(ref);
    return await analytics.startTrace(name);
  }

  /// Stop performance trace
  Future<void> stopTrace(
    WidgetRef ref,
    String traceId, {
    Map<String, int>? metrics,
  }) async {
    final analytics = _getAnalytics(ref);
    await analytics.stopTrace(traceId, metrics: metrics);
  }

  /// Helper to trace an async operation
  ///
  /// Automatically starts trace, runs operation, and stops trace.
  /// Returns the result of the operation.
  ///
  /// Usage:
  /// ```dart
  /// final result = await traceOperation(
  ///   ref,
  ///   name: 'save_workout',
  ///   operation: () async => await saveWorkout(),
  /// );
  /// ```
  Future<T> traceOperation<T>(
    WidgetRef ref, {
    required String name,
    required Future<T> Function() operation,
    Map<String, int>? metrics,
  }) async {
    final traceId = await startTrace(ref, name);
    try {
      final result = await operation();
      await stopTrace(ref, traceId, metrics: metrics);
      return result;
    } catch (e) {
      await stopTrace(ref, traceId, metrics: metrics);
      rethrow;
    }
  }

  /// Get analytics service from ref
  IAnalyticsService _getAnalytics(WidgetRef ref) {
    return ref.read(analyticsServiceProvider);
  }
}
