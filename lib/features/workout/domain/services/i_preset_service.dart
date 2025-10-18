/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/domain/services
/// 🎯 Feature: workout
/// 🔧 Type: service interface
///
/// Service interface for workout presets (rep, set, rest time)
///
/// ARCHITECTURE (Phase 3 Refactoring):
/// - Abstracts preset loading (JSON, Remote Config, Database)
/// - Enables A/B testing and personalization
/// - Supports caching and offline-first
/// - Localization-ready (keys instead of hardcoded text)
library;

import 'package:gymbro_flutter_new/features/workout/domain/models/workout_preset.dart';

/// Service interface for workout presets
///
/// Provides access to configurable presets for:
/// - Rep ranges (strength, hypertrophy, endurance)
/// - Set counts (1-6 sets)
/// - Rest times (30s, 1min, 2min, etc.)
///
/// Example implementations:
/// - `JSONPresetService` - Load presets from local JSON files
/// - `RemoteConfigPresetService` - Load from Firebase Remote Config
/// - `HybridPresetService` - JSON fallback with Remote Config overlay
/// - `MockPresetService` - For testing
///
/// Example usage:
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final presetService = ref.watch(presetServiceProvider);
///
///     final repPresets = await presetService.getRepRangePresets();
///     final setPresets = await presetService.getSetCountPresets();
///     final restPresets = await presetService.getRestTimePresets();
///   }
/// }
/// ```
abstract class IPresetService {
  /// Initialize service (load configs, warm up cache)
  ///
  /// Call this once at app startup for best performance
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   // Initialize preset service
  ///   final presetService = JSONPresetService();
  ///   await presetService.initialize();
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  Future<void> initialize();

  /// Get all rep range presets
  ///
  /// Returns presets sorted by `order` field
  ///
  /// Example:
  /// ```dart
  /// final presets = await presetService.getRepRangePresets();
  ///
  /// for (final preset in presets) {
  ///   print('${preset.labelKey}: ${preset.reps} reps');
  ///   // 'repPreset.strength.label': 3 reps
  ///   // 'repPreset.hypertrophy.label': 10 reps
  /// }
  /// ```
  Future<List<RepRangePreset>> getRepRangePresets();

  /// Get rep range preset by ID
  ///
  /// Returns null if not found
  ///
  /// Example:
  /// ```dart
  /// final preset = await presetService.getRepRangePresetById('hypertrophy');
  /// if (preset != null) {
  ///   print('${preset.reps} reps for hypertrophy');
  /// }
  /// ```
  Future<RepRangePreset?> getRepRangePresetById(String id);

  /// Get all set count presets
  ///
  /// Returns presets sorted by `order` field
  ///
  /// Example:
  /// ```dart
  /// final presets = await presetService.getSetCountPresets();
  ///
  /// for (final preset in presets) {
  ///   print('${preset.sets} sets');
  ///   // 1 sets, 2 sets, 3 sets, ...
  /// }
  /// ```
  Future<List<SetCountPreset>> getSetCountPresets();

  /// Get set count preset by ID
  ///
  /// Returns null if not found
  ///
  /// Example:
  /// ```dart
  /// final preset = await presetService.getSetCountPresetById('sets_3');
  /// if (preset != null) {
  ///   print('${preset.sets} sets');
  /// }
  /// ```
  Future<SetCountPreset?> getSetCountPresetById(String id);

  /// Get all rest time presets
  ///
  /// Returns presets sorted by `order` field
  ///
  /// Example:
  /// ```dart
  /// final presets = await presetService.getRestTimePresets();
  ///
  /// for (final preset in presets) {
  ///   print('${preset.labelKey}: ${preset.seconds}s');
  ///   // 'restPreset.oneMinute': 60s
  /// }
  /// ```
  Future<List<RestTimePreset>> getRestTimePresets();

  /// Get rest time preset by ID
  ///
  /// Returns null if not found
  ///
  /// Example:
  /// ```dart
  /// final preset = await presetService.getRestTimePresetById('rest_60');
  /// if (preset != null) {
  ///   print('${preset.seconds}s rest');
  /// }
  /// ```
  Future<RestTimePreset?> getRestTimePresetById(String id);

  /// Refresh presets from source (e.g., Remote Config)
  ///
  /// Useful for:
  /// - A/B testing (load new preset configs)
  /// - Personalization (update presets based on user level)
  /// - Live updates (push new presets without app update)
  ///
  /// Example:
  /// ```dart
  /// await presetService.refresh();
  /// final updatedPresets = await presetService.getRepRangePresets();
  /// ```
  Future<void> refresh();

  /// Dispose service resources
  ///
  /// Call this when shutting down the app or disposing the service provider
  ///
  /// Example:
  /// ```dart
  /// final presetServiceProvider = Provider<IPresetService>((ref) {
  ///   final service = JSONPresetService();
  ///   ref.onDispose(() => service.dispose());
  ///   return service;
  /// });
  /// ```
  Future<void> dispose();
}
