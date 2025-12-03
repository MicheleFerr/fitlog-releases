/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/data/providers
/// 🎯 Feature: workout
/// 🔧 Type: Riverpod provider
///
/// Riverpod provider for IPresetService
///
/// ARCHITECTURE (Phase 3 Refactoring):
/// - Provides singleton instance of preset service
/// - Automatic initialization and disposal
/// - Easy to override in tests
/// - Supports both sync and async initialization
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/i_preset_service.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/json_preset_repository.dart';

/// Provider for IPresetService
///
/// Automatically wires up dependencies via Riverpod:
/// ```
/// presetServiceProvider
///   └── creates JSONPresetService
///       └── loads presets from JSON assets
/// ```
///
/// Example usage in widgets:
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final presetService = ref.watch(presetServiceProvider);
///
///     // Use service
///     final repPresets = await presetService.getRepRangePresets();
///     final setPresets = await presetService.getSetCountPresets();
///     final restPresets = await presetService.getRestTimePresets();
///   }
/// }
/// ```
///
/// Example override in tests:
/// ```dart
/// testWidgets('should use mock preset service', (tester) async {
///   await tester.pumpWidget(
///     ProviderScope(
///       overrides: [
///         presetServiceProvider.overrideWithValue(mockPresetService),
///       ],
///       child: MyApp(),
///     ),
///   );
/// });
/// ```
final presetServiceProvider = Provider<IPresetService>((ref) {
  // Create service
  final service = JSONPresetService();

  // Initialize service asynchronously
  // Note: This runs in background, service will throw if used before init completes
  service.initialize().catchError((e) {
    // Log error but don't crash app
    if (kDebugMode) {
      debugPrint('❌ Failed to initialize preset service: $e');
    }
  });

  // Dispose service when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Async provider variant for ensuring service is initialized
///
/// Use this when you need to ensure the service is fully initialized
/// before using it (e.g., in app startup logic)
///
/// Most cases should use the synchronous `presetServiceProvider`
/// which initializes in background
///
/// Example usage:
/// ```dart
/// final serviceAsync = ref.watch(presetServiceAsyncProvider);
///
/// serviceAsync.when(
///   data: (service) => // Use fully initialized service,
///   loading: () => LoadingIndicator(),
///   error: (e, s) => ErrorWidget(e),
/// );
/// ```
/// Provider variant that ensures service is fully initialized before use
/// NOTE: NOT auto-dispose to prevent recreation and race conditions
final presetServiceAsyncProvider = FutureProvider<IPresetService>((ref) async {
  // Create service
  final service = JSONPresetService();

  // Initialize service (await completion)
  await service.initialize();

  // Dispose on provider disposal
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for checking if preset service is initialized
///
/// Useful for app startup logic to ensure presets are ready
final isPresetServiceInitializedProvider = StateProvider<bool>((ref) => false);
