/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/workout_templates/presentation/providers
/// Feature: Default Templates Provider
/// Type: Provider
///
/// Riverpod providers for accessing default workout templates.
/// Provides cached access to evidence-based training programs.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/datasources/default_templates_datasource.dart';

/// Provider for the DefaultTemplatesDataSource singleton
final defaultTemplatesDataSourceProvider = Provider<DefaultTemplatesDataSource>(
  (ref) {
    return DefaultTemplatesDataSource();
  },
);

/// Provider for all default templates (cached)
///
/// Automatically resolves exercise names from the exercise database
/// using exerciseId to look up the proper name.
final defaultTemplatesProvider =
    FutureProvider.autoDispose<List<WorkoutTemplate>>((ref) async {
      final dataSource = ref.watch(defaultTemplatesDataSourceProvider);
      final rawTemplates = await dataSource.loadAllTemplates();

      // Load exercise database to resolve names
      final allExercises = await ref.watch(allExercisesProvider.future);

      // Create ID -> name map for fast lookup
      final exerciseNameMap = <String, String>{};
      for (final exercise in allExercises) {
        exerciseNameMap[exercise.id] = exercise.nome;
      }

      // Resolve exercise names in all templates
      return rawTemplates.map((template) {
        final resolvedExercises = template.exercises.map((exercise) {
          // Look up name from database if not already set
          final resolvedName = exercise.exerciseName.isNotEmpty
              ? exercise.exerciseName
              : exerciseNameMap[exercise.exerciseId] ?? exercise.exerciseId;

          return exercise.copyWith(exerciseName: resolvedName);
        }).toList();

        return template.copyWith(exercises: resolvedExercises);
      }).toList();
    });

/// Provider for beginner templates only
final beginnerTemplatesProvider =
    FutureProvider.autoDispose<List<WorkoutTemplate>>((ref) async {
      final dataSource = ref.watch(defaultTemplatesDataSourceProvider);
      return dataSource.loadBeginnerTemplates();
    });

/// Provider for intermediate templates only
final intermediateTemplatesProvider =
    FutureProvider.autoDispose<List<WorkoutTemplate>>((ref) async {
      final dataSource = ref.watch(defaultTemplatesDataSourceProvider);
      return dataSource.loadIntermediateTemplates();
    });

/// Provider for template categories
final defaultTemplateCategoriesProvider =
    FutureProvider.autoDispose<List<DefaultTemplateCategory>>((ref) async {
      final dataSource = ref.watch(defaultTemplatesDataSourceProvider);
      return dataSource.loadCategories();
    });

/// Provider for templates filtered by difficulty
final templatesByDifficultyProvider = FutureProvider.autoDispose
    .family<List<WorkoutTemplate>, String>((ref, difficulty) async {
      final dataSource = ref.watch(defaultTemplatesDataSourceProvider);
      return dataSource.loadTemplatesByDifficulty(difficulty);
    });

/// Provider for a single default template by ID
final defaultTemplateByIdProvider = FutureProvider.autoDispose
    .family<WorkoutTemplate?, String>((ref, templateId) async {
      final templates = await ref.watch(defaultTemplatesProvider.future);
      try {
        return templates.firstWhere((t) => t.id == templateId);
      } catch (_) {
        return null;
      }
    });

/// Combined provider: default templates + user's custom templates
/// Useful for showing all available templates in the discovery section
final allAvailableTemplatesProvider =
    FutureProvider.autoDispose<AllAvailableTemplates>((ref) async {
      final defaultTemplates = await ref.watch(defaultTemplatesProvider.future);
      final categories = await ref.watch(
        defaultTemplateCategoriesProvider.future,
      );

      return AllAvailableTemplates(
        defaultTemplates: defaultTemplates,
        categories: categories,
      );
    });

/// Container for all available templates with metadata
class AllAvailableTemplates {
  const AllAvailableTemplates({
    required this.defaultTemplates,
    required this.categories,
  });

  final List<WorkoutTemplate> defaultTemplates;
  final List<DefaultTemplateCategory> categories;

  /// Get templates grouped by category
  Map<String, List<WorkoutTemplate>> get templatesByCategory {
    final grouped = <String, List<WorkoutTemplate>>{};

    for (final template in defaultTemplates) {
      final category = template.difficulty ?? 'other';
      grouped.putIfAbsent(category, () => []).add(template);
    }

    return grouped;
  }

  /// Total number of default templates
  int get totalCount => defaultTemplates.length;

  /// Check if templates are available
  bool get hasTemplates => defaultTemplates.isNotEmpty;
}
