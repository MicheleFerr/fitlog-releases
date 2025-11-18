/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/providers
/// 🎯 Feature: analytics
/// 🔧 Type: Riverpod providers
///
/// Analytics Providers - Riverpod providers for analytics repository and data
///
/// **Providers**:
/// 1. `analyticsCacheBoxProvider` - Hive cache box for analytics
/// 2. `analyticsRepositoryProvider` - Analytics repository implementation
/// 3. `exerciseHistoryStreamProvider` - Real-time exercise history stream
/// 4. `exerciseHistoryByNameProvider` - Individual exercise history (family)
/// 5. `exerciseSessionsByTimeframeProvider` - Sessions in timeframe (family)
///
/// **Usage**:
/// ```dart
/// // Get repository
/// final repository = ref.watch(analyticsRepositoryProvider);
///
/// // Watch real-time exercise history
/// final historyAsync = ref.watch(exerciseHistoryStreamProvider('user123'));
///
/// // Get specific exercise
/// final benchPressHistory = ref.watch(
///   exerciseHistoryByNameProvider(('user123', 'Bench Press')),
/// );
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:gymbro_flutter_new/features/analytics/data/services/analytics_migration_service.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ============================================================================
// INFRASTRUCTURE PROVIDERS
// ============================================================================

/// Hive cache box for analytics data
///
/// **Box Name**: `analytics_cache`
///
/// **Data Structure**:
/// ```dart
/// {
///   'analytics_user123_BenchPress': {
///     'cachedAt': '2025-01-15T14:30:00.000Z',
///     'data': {...} // ExerciseHistory JSON
///   }
/// }
/// ```
///
/// **TTL**: 5 minutes (enforced by repository)
final analyticsCacheBoxProvider =
    Provider<Box<Map<dynamic, dynamic>>>((ref) {
  // Open Hive box synchronously (must be initialized in main.dart)
  // ✅ FIX: Cast the Box<dynamic> to the correct type
  // The box is opened as Box<dynamic> in HiveBoxManagerEnhanced.initialize()
  return Hive.box('analytics_cache') as Box<Map<dynamic, dynamic>>;
});

/// Firestore instance provider
///
/// **Reuses global Firestore instance** for consistency
final _firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ============================================================================
// REPOSITORY PROVIDER
// ============================================================================

/// Analytics repository implementation
///
/// **Dependencies**:
/// - Firestore instance
/// - Hive cache box
///
/// **Features**:
/// - Real-time sync via Firestore streams
/// - Local cache with 5-min TTL
/// - Write-through strategy
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final firestore = ref.watch(_firestoreProvider);
  final cacheBox = ref.watch(analyticsCacheBoxProvider);

  return AnalyticsRepositoryImpl(
    firestore: firestore,
    cacheBox: cacheBox,
  );
});

// ============================================================================
// DATA PROVIDERS
// ============================================================================

/// Real-time exercise history stream for a user
///
/// **Firestore Query**: `users/{userId}/analytics` (all documents)
///
/// **Returns**: `AsyncValue<List<ExerciseHistory>>`
/// - Loading: Initial fetch from Firestore
/// - Data: List of all exercises with history
/// - Error: Firestore or parsing error
///
/// **Auto-updates**: Emits new data whenever Firestore changes
///
/// **Example**:
/// ```dart
/// Widget build(BuildContext context, WidgetRef ref) {
///   final userId = ref.watch(currentUserIdProvider);
///   final historyAsync = ref.watch(exerciseHistoryStreamProvider(userId!));
///
///   return historyAsync.when(
///     loading: () => LoadingIndicator(),
///     error: (error, stack) => Text('Error: $error'),
///     data: (histories) => ListView(
///       children: histories.map((h) => ExerciseCard(h)).toList(),
///     ),
///   );
/// }
/// ```
final exerciseHistoryStreamProvider = StreamProvider.family
    .autoDispose<List<ExerciseHistory>, String>((ref, userId) {
  final repository = ref.watch(analyticsRepositoryProvider);

  return repository.getExerciseHistory(userId).map((either) {
    return either.fold(
      (failure) => throw Exception(failure.message),
      (histories) => histories,
    );
  });
});

/// Get exercise history for a specific exercise
///
/// **Parameters**: `(String userId, String exerciseName)`
///
/// **Firestore Query**: `users/{userId}/analytics/{exerciseName}`
///
/// **Cache Strategy**: Checks Hive first (5-min TTL), then Firestore
///
/// **Returns**: `AsyncValue<ExerciseHistory>`
///
/// **Example**:
/// ```dart
/// final benchPress = ref.watch(
///   exerciseHistoryByNameProvider(('user123', 'Bench Press')),
/// );
///
/// benchPress.when(
///   loading: () => LoadingIndicator(),
///   error: (error, stack) => Text('Not found'),
///   data: (history) => Text('PR: ${history.personalRecord} kg'),
/// );
/// ```
final exerciseHistoryByNameProvider = FutureProvider.autoDispose
    .family<ExerciseHistory, (String, String)>((ref, params) async {
  final (userId, exerciseName) = params;
  final repository = ref.watch(analyticsRepositoryProvider);

  final result = await repository.getExerciseHistoryByName(
    userId: userId,
    exerciseName: exerciseName,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (history) => history,
  );
});

/// Get sessions for a specific exercise within a timeframe
///
/// **Parameters**: `(String userId, String exerciseName, DateTime start, DateTime end)`
///
/// **Use Cases**:
/// - Weekly volume charts
/// - Monthly progression
/// - Custom date ranges
///
/// **Returns**: `AsyncValue<List<ExerciseSession>>`
///
/// **Example**:
/// ```dart
/// final params = (
///   'user123',
///   'Bench Press',
///   DateTime.now().subtract(Duration(days: 30)),
///   DateTime.now(),
/// );
///
/// final sessionsAsync = ref.watch(exerciseSessionsByTimeframeProvider(params));
/// ```
final exerciseSessionsByTimeframeProvider = FutureProvider.autoDispose
    .family<List<ExerciseSession>, (String, String, DateTime, DateTime)>(
        (ref, params) async {
  final (userId, exerciseName, start, end) = params;
  final repository = ref.watch(analyticsRepositoryProvider);

  final result = await repository.getSessionsByTimeframe(
    userId: userId,
    exerciseName: exerciseName,
    start: start,
    end: end,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (sessions) => sessions,
  );
});

/// Search exercises by name (fuzzy search)
///
/// **Parameters**: `(String userId, String query)`
///
/// **Search Logic**: Case-insensitive, partial matches
///
/// **Returns**: `AsyncValue<List<ExerciseHistory>>`
///
/// **Example**:
/// ```dart
/// final searchResults = ref.watch(
///   searchExercisesProvider(('user123', 'bench')),
/// );
/// // Returns: ["Bench Press", "Incline Bench Press", "Dumbbell Bench"]
/// ```
final searchExercisesProvider = FutureProvider.autoDispose
    .family<List<ExerciseHistory>, (String, String)>((ref, params) async {
  final (userId, query) = params;
  final repository = ref.watch(analyticsRepositoryProvider);

  final result = await repository.searchExercises(
    userId: userId,
    query: query,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (histories) => histories,
  );
});

// ============================================================================
// UTILITY PROVIDERS
// ============================================================================

/// Clear analytics cache
///
/// **Use Case**: Force refresh from Firestore
///
/// **Example**:
/// ```dart
/// ElevatedButton(
///   onPressed: () async {
///     final repository = ref.read(analyticsRepositoryProvider);
///     await repository.clearCache();
///     ref.invalidate(exerciseHistoryStreamProvider); // Force refresh
///   },
///   child: Text('Force Refresh'),
/// )
/// ```
///
/// **Note**: This doesn't invalidate providers automatically.
/// Use `ref.invalidate(exerciseHistoryStreamProvider)` after clearing cache.

/// Check if cache is valid for current user
///
/// **Use Case**: Show "cache outdated" indicator
///
/// **Example**:
/// ```dart
/// final userId = ref.watch(currentUserIdProvider);
/// final repository = ref.read(analyticsRepositoryProvider);
/// final isCacheValid = await repository.isCacheValid(userId!);
///
/// if (!isCacheValid) {
///   // Show refresh indicator
/// }
/// ```

// ============================================================================
// MIGRATION PROVIDER
// ============================================================================

/// Analytics migration service
///
/// **Purpose**: One-time migration of historical workout data
///
/// **Usage**:
/// ```dart
/// final migrationService = ref.read(analyticsMigrationServiceProvider);
/// final userId = ref.watch(currentUserIdProvider);
///
/// final result = await migrationService.migrateUserWorkouts(userId: userId!);
/// result.fold(
///   (failure) => print('Migration failed: $failure'),
///   (stats) => print('Migrated: ${stats.totalWorkouts} workouts'),
/// );
/// ```
final analyticsMigrationServiceProvider =
    Provider<AnalyticsMigrationService>((ref) {
  final firestore = ref.watch(_firestoreProvider);

  return AnalyticsMigrationService(firestore: firestore);
});
