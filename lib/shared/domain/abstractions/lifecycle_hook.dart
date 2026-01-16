/// Lifecycle Hook Abstraction
///
/// Allows features to register callbacks for app lifecycle events
/// without requiring direct imports in AppLifecycleManager.
///
/// Usage:
/// ```dart
/// // In feature's provider setup
/// final myFeatureLifecycleHook = Provider<LifecycleHook>((ref) {
///   return LifecycleHook(
///     onPause: () async {
///       // Save state when app goes to background
///     },
///     onResume: () async {
///       // Restore state when app comes to foreground
///     },
///   );
/// });
///
/// // In main.dart or app initialization
/// ProviderScope(
///   overrides: [
///     lifecycleHooksProvider.overrideWith((ref) => [
///       ref.watch(workoutLifecycleHook),
///       ref.watch(notificationLifecycleHook),
///       // ... other hooks
///     ]),
///   ],
/// )
/// ```
library;

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Callback type for lifecycle events
typedef LifecycleCallback = FutureOr<void> Function();

/// Hook for app lifecycle events
///
/// Features can create hooks to respond to lifecycle changes
/// without coupling to the central lifecycle manager.
class LifecycleHook {
  const LifecycleHook({
    this.onPause,
    this.onResume,
    this.onInactive,
    this.onDetached,
    this.onHidden,
    this.priority = 0,
    this.name,
  });

  /// Called when app goes to background (paused state)
  final LifecycleCallback? onPause;

  /// Called when app returns to foreground (resumed state)
  final LifecycleCallback? onResume;

  /// Called when app becomes inactive (losing focus)
  final LifecycleCallback? onInactive;

  /// Called when app is about to be terminated
  final LifecycleCallback? onDetached;

  /// Called when app is hidden (iOS specific)
  final LifecycleCallback? onHidden;

  /// Priority for execution order (higher = earlier)
  final int priority;

  /// Name for debugging
  final String? name;

  /// Execute the appropriate callback for a lifecycle state
  Future<void> handleStateChange(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        await onPause?.call();
      case AppLifecycleState.resumed:
        await onResume?.call();
      case AppLifecycleState.inactive:
        await onInactive?.call();
      case AppLifecycleState.detached:
        await onDetached?.call();
      case AppLifecycleState.hidden:
        await onHidden?.call();
    }
  }
}

/// Provider for registered lifecycle hooks
///
/// Override this in ProviderScope with feature-specific hooks
final lifecycleHooksProvider = Provider<List<LifecycleHook>>((ref) {
  // Default: no hooks registered
  // Features should override this with their hooks
  return const [];
});

/// Helper to execute all hooks for a lifecycle state
Future<void> executeLifecycleHooks(
  List<LifecycleHook> hooks,
  AppLifecycleState state,
) async {
  // Sort by priority (higher first)
  final sortedHooks = List<LifecycleHook>.from(hooks)
    ..sort((a, b) => b.priority.compareTo(a.priority));

  for (final hook in sortedHooks) {
    try {
      await hook.handleStateChange(state);
    } catch (e) {
      // Log error but don't break other hooks
      debugPrint('❌ [Lifecycle] Hook ${hook.name ?? 'unknown'} failed: $e');
    }
  }
}
