/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/providers
/// 🎯 Feature: exercise_database
/// 🔧 Type: Riverpod provider
///
/// Riverpod provider for IExerciseUsageRepository
///
/// This provider enables Dependency Injection throughout the app,
/// making it easy to:
/// - Swap implementations (Hive → Firebase → InMemory)
/// - Mock in tests
/// - Manage lifecycle (initialization, disposal)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/repositories/i_exercise_usage_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/hive_exercise_usage_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_usage_model.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

/// Provider for IExerciseUsageRepository
///
/// Returns Hive implementation by default. Can be overridden in tests.
///
/// Example usage in widgets:
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final repository = ref.watch(exerciseUsageRepositoryProvider);
///
///     // Use repository
///     final boosts = await repository.getBatchBoosts(exerciseIds);
///   }
/// }
/// ```
///
/// Example override in tests:
/// ```dart
/// testWidgets('should use mock repository', (tester) async {
///   await tester.pumpWidget(
///     ProviderScope(
///       overrides: [
///         exerciseUsageRepositoryProvider.overrideWithValue(mockRepository),
///       ],
///       child: MyApp(),
///     ),
///   );
/// });
/// ```
final exerciseUsageRepositoryProvider = Provider<IExerciseUsageRepository>((ref) {
  // Open Hive box (lazy initialization)
  final box = Hive.box<ExerciseUsageModel>('exercise_usage');

  // Create repository instance
  final repository = HiveExerciseUsageRepository(box);

  // Initialize repository
  // Note: This is synchronous because box is already open at app startup
  repository.initialize();

  // Dispose on provider disposal
  ref.onDispose(() {
    repository.dispose();
  });

  return repository;
});

/// Async provider variant for advanced use cases
///
/// Use this when you need to ensure box is open before creating repository.
/// Most cases should use the synchronous `exerciseUsageRepositoryProvider`.
///
/// Example usage:
/// ```dart
/// final repositoryAsync = ref.watch(exerciseUsageRepositoryAsyncProvider);
///
/// repositoryAsync.when(
///   data: (repository) => // Use repository,
///   loading: () => LoadingIndicator(),
///   error: (e, s) => ErrorWidget(e),
/// );
/// ```
final exerciseUsageRepositoryAsyncProvider =
    FutureProvider<IExerciseUsageRepository>((ref) async {
  // Ensure Hive adapter is registered
  if (!Hive.isAdapterRegistered(30)) {
    Hive.registerAdapter(ExerciseUsageModelAdapter());
  }

  // Open box (async) using HiveBoxManagerEnhanced
  final boxManager = ref.watch(hiveBoxManagerProvider);
  final box = await boxManager.openBox<ExerciseUsageModel>('exercise_usage');

  // Create and initialize repository
  final repository = HiveExerciseUsageRepository(box);
  await repository.initialize();

  // Dispose on provider disposal
  ref.onDispose(() {
    repository.dispose();
  });

  return repository;
});

/// Provider for checking if repository is initialized
///
/// Useful for app startup logic to ensure data layer is ready
final isRepositoryInitializedProvider = StateProvider<bool>((ref) => false);
