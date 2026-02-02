import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart'
    show WorkoutTemplate, ExerciseTemplate;
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_stats.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_template_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/firebase_workout_template_repository.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/services/template_cloud_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';

// Repository provider - Firebase se utente autenticato, altrimenti locale
final workoutTemplateRepositoryProvider = Provider<dynamic>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (kDebugMode) {
    debugPrint(
      '🔍 REPO: User autenticato: ${user != null ? "SI (${user.uid})" : "NO"}',
    );
    debugPrint('🔍 REPO: User email: ${user?.email ?? "N/A"}');
  }

  // Usa Firebase se l'utente è autenticato
  if (user != null) {
    if (kDebugMode) {
      debugPrint(
        '🔍 REPO: Usando FirebaseWorkoutTemplateRepository per user ${user.uid}',
      );
    }
    return FirebaseWorkoutTemplateRepository();
  }

  // Altrimenti usa repository locale
  if (kDebugMode) {
    debugPrint('🔍 REPO: Usando WorkoutTemplateRepository locale');
  }
  return WorkoutTemplateRepository();
});

// Tutti i template (predefiniti + personalizzati)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final allWorkoutTemplatesProvider =
    FutureProvider.autoDispose<List<WorkoutTemplate>>((ref) async {
      if (kDebugMode || kProfileMode) {
        debugPrint('🔍 [ALL_TEMPLATES] Provider called');
      }

      final repository = ref.watch(workoutTemplateRepositoryProvider);

      if (kDebugMode || kProfileMode) {
        debugPrint(
          '🔍 [ALL_TEMPLATES] Repository type: ${repository.runtimeType}',
        );
      }

      final templates = await repository.getAllTemplates();

      if (kDebugMode || kProfileMode) {
        debugPrint(
          '🔍 [ALL_TEMPLATES] Got ${templates.length} templates from repository',
        );
        for (final template in templates) {
          debugPrint('  - ${template.name} (${template.id})');
        }
      }

      return templates;
    });

// Solo template personalizzati
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final customWorkoutTemplatesProvider = FutureProvider.autoDispose<List<WorkoutTemplate>>((
  ref,
) async {
  if (kDebugMode) {
    debugPrint('🔍 customWorkoutTemplatesProvider: START');
  }

  // 1. Prendi i template dal repository legacy (esistenti)
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  if (kDebugMode) {
    debugPrint(
      '🔍 customWorkoutTemplatesProvider: Repository type: ${repository.runtimeType}',
    );
  }

  final legacyTemplates = await repository.getCustomTemplates();
  if (kDebugMode) {
    debugPrint(
      '🔍 customWorkoutTemplatesProvider: Got ${legacyTemplates.length} legacy templates',
    );

    for (final template in legacyTemplates) {
      debugPrint(
        '  - ${template.name}: isCustom=${template.isCustom}, id=${template.id}',
      );
    }

    debugPrint(
      '🔍 customWorkoutTemplatesProvider: Returning ${legacyTemplates.length} templates',
    );
  }
  return legacyTemplates;
});

// Template più utilizzati (per quick start)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final popularTemplatesProvider = FutureProvider.autoDispose<List<WorkoutTemplate>>((
  ref,
) async {
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  final templates = await repository.getAllTemplates();

  if (kDebugMode) {
    debugPrint(
      '🔍 popularTemplatesProvider: Found ${templates.length} total templates',
    );
    for (final template in templates) {
      debugPrint(
        '  - ${template.name}: usageCount=${template.usageCount}, isCustom=${template.isCustom}',
      );
    }
  }

  // Ordina per utilizzo e prende i primi 6
  templates.sort((a, b) => b.usageCount.compareTo(a.usageCount));

  final popularTemplates = templates.take(6).toList();
  if (kDebugMode) {
    debugPrint(
      '🔍 popularTemplatesProvider: Returning ${popularTemplates.length} popular templates',
    );
  }

  return popularTemplates;
});

// Provider per ricerca template
final templateSearchQueryProvider = StateProvider<String>((ref) => '');

/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final templateSearchResultsProvider =
    FutureProvider.autoDispose<List<WorkoutTemplate>>((ref) async {
      final repository = ref.watch(workoutTemplateRepositoryProvider);
      final query = ref.watch(templateSearchQueryProvider);

      if (query.isEmpty) {
        return repository.getAllTemplates();
      }

      return repository.searchTemplates(query);
    });

// Provider per filtri tag
final templateTagFilterProvider = StateProvider<List<String>>((ref) => []);

/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final filteredTemplatesProvider =
    FutureProvider.autoDispose<List<WorkoutTemplate>>((ref) async {
      final repository = ref.watch(workoutTemplateRepositoryProvider);
      final selectedTags = ref.watch(templateTagFilterProvider);

      if (selectedTags.isEmpty) {
        return repository.getAllTemplates();
      }

      return repository.getTemplatesByTags(selectedTags);
    });

// Notifier per gestione template
final workoutTemplateNotifierProvider =
    NotifierProvider<WorkoutTemplateNotifier, WorkoutTemplateState>(
      WorkoutTemplateNotifier.new,
    );

class WorkoutTemplateState {
  const WorkoutTemplateState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
    this.selectedTemplate,
  });
  final List<WorkoutTemplate> templates;
  final bool isLoading;
  final String? error;
  final WorkoutTemplate? selectedTemplate;

  WorkoutTemplateState copyWith({
    List<WorkoutTemplate>? templates,
    bool? isLoading,
    String? error,
    WorkoutTemplate? selectedTemplate,
  }) {
    return WorkoutTemplateState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
    );
  }
}

class WorkoutTemplateNotifier extends Notifier<WorkoutTemplateState> {
  bool _initialized = false;

  @override
  WorkoutTemplateState build() {
    _initialized = false;
    return const WorkoutTemplateState(isLoading: true);
  }

  /// Ensures templates are loaded (called before any operation)
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      _initialized = true;
      await _doLoadTemplates();
    }
  }

  /// Carica tutti i template
  Future<void> loadTemplates() async {
    await _doLoadTemplates();
  }

  Future<void> _doLoadTemplates() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(workoutTemplateRepositoryProvider);
      final templates = await repository.getAllTemplates();

      state = state.copyWith(templates: templates, isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PROVIDER: Error loading templates: $e');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Salva un nuovo template
  Future<void> saveTemplate(WorkoutTemplate template) async {
    // Ensure provider is initialized before saving
    await _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint('💾 PROVIDER: Starting template save for "${template.name}"');
        debugPrint('   - Template has ${template.exercises.length} exercises');
      }

      final repository = ref.read(workoutTemplateRepositoryProvider);
      await repository.saveTemplate(template);

      if (kDebugMode) {
        debugPrint('💾 PROVIDER: Template saved to repository, reloading local state...');
      }

      // Ricarica i template
      await loadTemplates();

      if (kDebugMode) {
        debugPrint('💾 PROVIDER: Invalidating all related providers...');
      }

      // Invalida TUTTI i provider cache - Enhanced invalidation
      ref.invalidate(allWorkoutTemplatesProvider);
      ref.invalidate(customWorkoutTemplatesProvider);
      ref.invalidate(popularTemplatesProvider);
      ref.invalidate(templateSearchResultsProvider);
      ref.invalidate(filteredTemplatesProvider);
      ref.invalidate(availableTemplateTagsProvider);

      // Force refresh dei provider che potrebbero essere cached
      try {
        final _ = await ref.refresh(allWorkoutTemplatesProvider.future);
        if (kDebugMode) {
          debugPrint(
            '✅ PROVIDER: Successfully refreshed allWorkoutTemplatesProvider',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '⚠️  PROVIDER: Error refreshing allWorkoutTemplatesProvider: $e',
          );
        }
      }

      try {
        final _ = await ref.refresh(customWorkoutTemplatesProvider.future);
        if (kDebugMode) {
          debugPrint(
            '✅ PROVIDER: Successfully refreshed customWorkoutTemplatesProvider',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '⚠️  PROVIDER: Error refreshing customWorkoutTemplatesProvider: $e',
          );
        }
      }

      if (kDebugMode) {
        debugPrint('✅ PROVIDER: Template save and invalidation completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PROVIDER: Error saving template: $e');
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Elimina un template
  Future<void> deleteTemplate(String templateId) async {
    // Ensure provider is initialized before deleting
    await _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint('🗑️ PROVIDER: Deleting template with ID: $templateId');
      }

      // Delete from legacy repository
      final repository = ref.read(workoutTemplateRepositoryProvider);
      await repository.deleteTemplate(templateId);
      if (kDebugMode) {
        debugPrint('🗑️ PROVIDER: Deleted from legacy repository');
      }

      // Rimuovi dalla lista locale
      final updatedTemplates = state.templates
          .where((template) => template.id != templateId)
          .toList();

      state = state.copyWith(templates: updatedTemplates);

      if (kDebugMode) {
        debugPrint('🗑️ PROVIDER: Template deleted, invalidating providers...');
      }

      // Invalida TUTTI i provider cache - Enhanced invalidation
      ref.invalidate(allWorkoutTemplatesProvider);
      ref.invalidate(customWorkoutTemplatesProvider);
      ref.invalidate(popularTemplatesProvider);
      ref.invalidate(templateSearchResultsProvider);
      ref.invalidate(filteredTemplatesProvider);
      ref.invalidate(availableTemplateTagsProvider);

      // Force refresh key providers
      await Future.wait([
        ref.refresh(customWorkoutTemplatesProvider.future),
      ]).catchError((e) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ PROVIDER: Error refreshing providers after delete: $e',
          );
        }
        return [<WorkoutTemplate>[]];
      });

      if (kDebugMode) {
        debugPrint('✅ PROVIDER: Template deletion completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PROVIDER: Error deleting template: $e');
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Crea un template da un workout esistente
  ///
  /// 🔐 SECURITY: Uses Cloud Function for server-side quota enforcement.
  /// Direct Firestore writes are BLOCKED by Security Rules.
  ///
  /// **Quota Tiers**:
  /// - Free: 4 private templates
  /// - Premium: 20 private templates
  /// - Pro: 999 private templates (unlimited)
  ///
  /// **Throws**:
  /// - `TemplateQuotaExceededException` if quota exceeded
  /// - `FirebaseFunctionsException` for other errors
  Future<WorkoutTemplate> createTemplateFromWorkout({
    required String name,
    required String description,
    required List<Exercise> exercises,
    List<String>? tags,
    String? imageUrl,
  }) async {
    // Ensure provider is initialized before creating
    await _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint('🆕 PROVIDER: Creating template from workout: "$name"');
        debugPrint('   - Source exercises: ${exercises.length}');
        debugPrint('   - Using Cloud Function for quota enforcement');
      }

      // 🔐 SECURITY: Use Cloud Function for server-side quota enforcement
      // Direct Firestore writes are BLOCKED by Security Rules
      final result = await TemplateCloudService.createTemplate(
        name: name,
        description: description,
        exercises: exercises,
        tags: tags ?? [],
        isPublic: false, // Default to private template
      );

      if (!result.success) {
        throw Exception(result.error ?? 'Failed to create template');
      }

      if (kDebugMode) {
        debugPrint('🆕 PROVIDER: Template created via Cloud Function');
        debugPrint('   - Template ID: ${result.templateId}');
        debugPrint('   - Quota: ${result.quota.privateUsed}/${result.quota.privateMax} private templates');
      }

      // ✅ FIX: Use ExerciseTemplate.fromExercise() to properly handle
      // SupersetExercise, DropSetExercise, and RestPauseExercise
      final exerciseTemplates = exercises.map((exercise) {
        return ExerciseTemplate.fromExercise(exercise);
      }).toList();

      // Create a local WorkoutTemplate object from the result
      // This is needed for the return value and local state
      final template = WorkoutTemplate(
        id: result.templateId,
        name: name,
        description: description,
        exercises: exerciseTemplates,
        tags: tags ?? [],
        isCustom: true,
        imageUrl: imageUrl,
        userId: FirebaseAuth.instance.currentUser?.uid,
      );

      // ✅ FIX: Add template to local cache BEFORE reloading
      // Cloud Function saves to Firestore, but cache was not updated!
      final repository = ref.read(workoutTemplateRepositoryProvider);
      if (repository is FirebaseWorkoutTemplateRepository) {
        await repository.addTemplateToCache(template);
        if (kDebugMode) {
          debugPrint('✅ PROVIDER: Template added to local cache');
        }
      }

      // Ricarica i template
      await loadTemplates();

      // Invalida TUTTI i provider cache - Enhanced invalidation
      ref.invalidate(allWorkoutTemplatesProvider);
      ref.invalidate(customWorkoutTemplatesProvider);
      ref.invalidate(popularTemplatesProvider);
      ref.invalidate(templateSearchResultsProvider);
      ref.invalidate(filteredTemplatesProvider);
      ref.invalidate(availableTemplateTagsProvider);

      if (kDebugMode) {
        debugPrint('✅ PROVIDER: Template creation completed');
        debugPrint('   - Remaining quota: ${result.quota.privateRemaining} private templates');
      }

      return template;
    } on TemplateQuotaExceededException catch (e) {
      if (kDebugMode) {
        debugPrint('🚨 PROVIDER: Template quota exceeded!');
        debugPrint('   - ${e.quota.privateUsed}/${e.quota.privateMax} private templates');
        debugPrint('   - Account tier: ${e.quota.accountTier}');
      }
      state = state.copyWith(error: 'quota exceeded: ${e.message}');
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PROVIDER: Error creating template from workout: $e');
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Incrementa il contatore di utilizzo
  Future<void> incrementUsage(String templateId) async {
    await _ensureInitialized();

    try {
      final repository = ref.read(workoutTemplateRepositoryProvider);
      await repository.incrementUsage(templateId);

      // Aggiorna la lista locale
      final updatedTemplates = state.templates.map((template) {
        if (template.id == templateId) {
          return template.incrementUsage();
        }
        return template;
      }).toList();

      state = state.copyWith(templates: updatedTemplates);

      // Invalida i provider cache
      ref.invalidate(popularTemplatesProvider);
    } catch (e) {
      // Silently fail per incrementUsage
      if (kDebugMode) {
        debugPrint('Errore nell\'incremento utilizzo: $e');
      }
    }
  }

  /// Duplica un template esistente
  ///
  /// Creates a copy of the template with a new ID and modified name.
  /// Returns the duplicated template.
  Future<WorkoutTemplate> duplicateTemplate(WorkoutTemplate template) async {
    await _ensureInitialized();

    try {
      if (kDebugMode) {
        debugPrint('📋 PROVIDER: Duplicating template "${template.name}"');
      }

      // Create a new template with the same content but new ID
      final duplicatedTemplate = WorkoutTemplate(
        // id is auto-generated, createdAt/updatedAt are auto-set to now
        name: '${template.name} (Copy)',
        description: template.description,
        imageUrl: template.imageUrl,
        exercises: List.from(template.exercises), // Copy the list
        estimatedDuration: template.estimatedDuration,
        tags: List.from(template.tags), // Copy the list
        isCustom: true, // Always custom since user duplicated it
        usageCount: 0, // Reset usage count for the copy
        isPublic: false, // Not public by default
        userId: template.userId,
        difficulty: template.difficulty,
        defaultAutoAdjustmentType: template.defaultAutoAdjustmentType,
        defaultApreProtocol: template.defaultApreProtocol,
      );

      // Save the duplicated template
      await saveTemplate(duplicatedTemplate);

      if (kDebugMode) {
        debugPrint('✅ PROVIDER: Template duplicated successfully as "${duplicatedTemplate.name}"');
      }

      return duplicatedTemplate;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PROVIDER: Error duplicating template: $e');
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Seleziona un template
  void selectTemplate(WorkoutTemplate? template) {
    state = state.copyWith(selectedTemplate: template);
  }

  /// Pulisce gli errori
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// ⌚ Aggiorna template dal database esercizi (sincronizza TUT e altri campi)
  ///
  /// Questa funzione recupera i dati più recenti dal database esercizi
  /// per ogni esercizio nel template, aggiornando campi come TUT (tempoEsecuzione).
  ///
  /// Utile per template creati prima dell'aggiunta del campo TUT.
  Future<int> refreshTemplateFromDatabase(WorkoutTemplate template) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 PROVIDER: Refreshing template "${template.name}" from exercise database');
      }

      // Get exercise database
      final exerciseDatabase = await ref.read(allExercisesProvider.future);

      // Create a lookup map by exercise ID and name for fast matching
      final exerciseMap = <String, dynamic>{};
      for (final dbExercise in exerciseDatabase) {
        exerciseMap[dbExercise.id] = dbExercise;
        // Also map by normalized name for fallback matching
        final normalizedName = dbExercise.nome.toLowerCase().replaceAll(' ', '_');
        exerciseMap[normalizedName] = dbExercise;
      }

      var updatedCount = 0;

      // Update each exercise in the template
      final updatedExercises = template.exercises.map((exerciseTemplate) {
        // Try to find matching exercise in database
        dynamic dbExercise = exerciseMap[exerciseTemplate.exerciseId];

        // Fallback: try by normalized exercise name
        if (dbExercise == null) {
          final normalizedName = exerciseTemplate.exerciseName.toLowerCase().replaceAll(' ', '_');
          dbExercise = exerciseMap[normalizedName];
        }

        if (dbExercise != null) {
          // Check if TUT needs updating
          final dbTut = dbExercise.tempoEsecuzione as String?;
          if (dbTut != null && dbTut != exerciseTemplate.tut) {
            updatedCount++;
            if (kDebugMode) {
              debugPrint('   📝 Updated TUT for "${exerciseTemplate.exerciseName}": ${exerciseTemplate.tut} → $dbTut');
            }
            return exerciseTemplate.copyWith(tut: dbTut);
          }
        }

        return exerciseTemplate;
      }).toList();

      if (updatedCount > 0) {
        // Save updated template
        final updatedTemplate = template.copyWith(
          exercises: updatedExercises,
          updatedAt: DateTime.now(),
        );

        await saveTemplate(updatedTemplate);

        if (kDebugMode) {
          debugPrint('✅ PROVIDER: Template refreshed - $updatedCount exercises updated');
        }
      } else {
        if (kDebugMode) {
          debugPrint('ℹ️ PROVIDER: Template already up to date, no changes needed');
        }
      }

      return updatedCount;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PROVIDER: Error refreshing template: $e');
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// ⌚ Check if a template has exercises that need TUT sync from database
  /// Returns true if at least one exercise has different TUT in database
  Future<bool> templateNeedsRefresh(WorkoutTemplate template) async {
    try {
      // Get exercise database
      final exerciseDatabase = await ref.read(allExercisesProvider.future);

      // Create a lookup map by exercise ID and name for fast matching
      final exerciseMap = <String, dynamic>{};
      for (final dbExercise in exerciseDatabase) {
        exerciseMap[dbExercise.id] = dbExercise;
        final normalizedName = dbExercise.nome.toLowerCase().replaceAll(' ', '_');
        exerciseMap[normalizedName] = dbExercise;
      }

      // Check each exercise in the template
      for (final exerciseTemplate in template.exercises) {
        dynamic dbExercise = exerciseMap[exerciseTemplate.exerciseId];

        if (dbExercise == null) {
          final normalizedName = exerciseTemplate.exerciseName.toLowerCase().replaceAll(' ', '_');
          dbExercise = exerciseMap[normalizedName];
        }

        if (dbExercise != null) {
          final dbTut = dbExercise.tempoEsecuzione as String?;
          // If database has TUT and it's different from template, needs refresh
          if (dbTut != null && dbTut.isNotEmpty && dbTut != exerciseTemplate.tut) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PROVIDER: Error checking template refresh: $e');
      }
      return false;
    }
  }
}

/// Provider that returns a Set of template IDs that need TUT refresh
/// Reads exercise database ONCE and checks ALL custom templates in a single pass
/// This avoids N separate database reads (one per template in the list)
final templatesNeedingRefreshProvider = FutureProvider.autoDispose<Set<String>>((ref) async {
  try {
    // Get all custom templates and exercise database in parallel
    final customTemplates = await ref.watch(customWorkoutTemplatesProvider.future);
    final exerciseDatabase = await ref.read(allExercisesProvider.future);

    // Create a lookup map for fast matching
    final exerciseMap = <String, dynamic>{};
    for (final dbExercise in exerciseDatabase) {
      exerciseMap[dbExercise.id] = dbExercise;
      final normalizedName = dbExercise.nome.toLowerCase().replaceAll(' ', '_');
      exerciseMap[normalizedName] = dbExercise;
    }

    // Check each custom template
    final needsRefresh = <String>{};
    for (final template in customTemplates) {
      if (!template.isCustom) continue;

      for (final exerciseTemplate in template.exercises) {
        dynamic dbExercise = exerciseMap[exerciseTemplate.exerciseId];
        if (dbExercise == null) {
          final normalizedName =
              exerciseTemplate.exerciseName.toLowerCase().replaceAll(' ', '_');
          dbExercise = exerciseMap[normalizedName];
        }

        if (dbExercise != null) {
          final dbTut = dbExercise.tempoEsecuzione as String?;
          if (dbTut != null && dbTut.isNotEmpty && dbTut != exerciseTemplate.tut) {
            needsRefresh.add(template.id);
            break; // Found one mismatch, no need to check more exercises
          }
        }
      }
    }

    return needsRefresh;
  } catch (e) {
    return <String>{};
  }
});

/// Provider to check if a specific template needs TUT refresh (uses cached Set)
/// This is now O(1) lookup instead of a full database read per template
final templateNeedsRefreshProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  templateId,
) async {
  final needsRefreshSet = await ref.watch(templatesNeedingRefreshProvider.future);
  return needsRefreshSet.contains(templateId);
});

// Provider per ottenere tutti i tag disponibili
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final availableTemplateTagsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final repository = ref.watch(workoutTemplateRepositoryProvider);
  final templates = await repository.getAllTemplates();

  final allTags = <String>{};
  for (final template in templates) {
    allTags.addAll(template.tags);
  }

  final sortedTags = allTags.toList()..sort();
  return sortedTags;
});

/// Family provider to get a single template by ID
/// FIX: Use customWorkoutTemplatesProvider to include templates from unified repository
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final templateByIdProvider = FutureProvider.autoDispose.family<WorkoutTemplate?, String>((
  ref,
  templateId,
) async {
  // Use customWorkoutTemplatesProvider which includes both legacy and unified repository templates
  final templates = await ref.watch(customWorkoutTemplatesProvider.future);

  try {
    return templates.firstWhere((template) => template.id == templateId);
  } catch (e) {
    if (kDebugMode) {
      debugPrint(
        '⚠️ Template with ID $templateId not found in ${templates.length} available templates',
      );
      debugPrint(
        '   Available template IDs: ${templates.map((t) => t.id).take(5).join(", ")}${templates.length > 5 ? "..." : ""}',
      );
    }
    return null;
  }
});

/// Provider for template statistics (average duration, last performed, completions)
///
/// Calculates real statistics based on completed workouts that used this template.
/// Returns TemplateStats with:
/// - avgDuration: Average duration of completed workouts
/// - lastPerformed: Date of most recent workout with this template
/// - totalCompletions: Number of times this template was used
///
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final templateStatsProvider = FutureProvider.autoDispose
    .family<TemplateStats, String>((ref, templateId) async {
      // Get all workouts from history
      final workoutsAsync = ref.watch(workoutHistoryProvider);

      return workoutsAsync.when(
        data: (workouts) {
          // Filter completed workouts that used this template
          final templateWorkouts = workouts
              .where(
                (workout) =>
                    workout.templateId == templateId,
              )
              .toList();

          if (templateWorkouts.isEmpty) {
            return TemplateStats.empty();
          }

          // Sort by date (newest first) to get lastPerformed
          templateWorkouts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final lastPerformed =
              templateWorkouts.first.startedAt;

          // Calculate average duration
          final totalMinutes = templateWorkouts
              .map((w) => w.duration.inMinutes)
              .fold<int>(0, (sum, minutes) => sum + minutes);
          final avgMinutes = totalMinutes ~/ templateWorkouts.length;

          if (kDebugMode) {
            debugPrint(
              '📊 [templateStatsProvider] Template $templateId: '
              '${templateWorkouts.length} completions, '
              'avg ${avgMinutes}min, '
              'last ${lastPerformed.toIso8601String()}',
            );
          }

          return TemplateStats(
            lastPerformed: lastPerformed,
            totalCompletions: templateWorkouts.length,
            avgDuration: Duration(minutes: avgMinutes),
          );
        },
        loading: () => TemplateStats.empty(),
        error: (_, __) => TemplateStats.empty(),
      );
    });

/// Provider for all template stats at once (batch loading for list view)
///
/// More efficient than calling templateStatsProvider for each template
/// when displaying a list of templates.
final allTemplateStatsProvider =
    FutureProvider.autoDispose<Map<String, TemplateStats>>((ref) async {
      // Get all workouts from history
      final workoutsAsync = ref.watch(workoutHistoryProvider);

      return workoutsAsync.when(
        data: (workouts) {
          final statsMap = <String, TemplateStats>{};

          // Group completed workouts by templateId
          final workoutsByTemplate = <String, List<_WorkoutData>>{};

          for (final workout in workouts) {
            if (workout.templateId != null) {
              workoutsByTemplate
                  .putIfAbsent(workout.templateId!, () => [])
                  .add(
                    _WorkoutData(
                      startTime: workout.startedAt,
                      durationMinutes: workout.duration.inMinutes,
                    ),
                  );
            }
          }

          // Calculate stats for each template
          for (final entry in workoutsByTemplate.entries) {
            final templateId = entry.key;
            final templateWorkouts = entry.value;

            // Sort by date (newest first)
            templateWorkouts.sort((a, b) => b.startTime.compareTo(a.startTime));

            // Calculate average duration
            final totalMinutes = templateWorkouts
                .map((w) => w.durationMinutes)
                .fold<int>(0, (sum, minutes) => sum + minutes);
            final avgMinutes = totalMinutes ~/ templateWorkouts.length;

            statsMap[templateId] = TemplateStats(
              lastPerformed: templateWorkouts.first.startTime,
              totalCompletions: templateWorkouts.length,
              avgDuration: Duration(minutes: avgMinutes),
            );
          }

          if (kDebugMode) {
            debugPrint(
              '📊 [allTemplateStatsProvider] Calculated stats for ${statsMap.length} templates',
            );
          }

          return statsMap;
        },
        loading: () => {},
        error: (_, __) => {},
      );
    });

/// Helper class for workout data aggregation
class _WorkoutData {
  const _WorkoutData({required this.startTime, required this.durationMinutes});

  final DateTime startTime;
  final int durationMinutes;
}

/// Provider for template quota information
///
/// 🔐 SECURITY: Fetches quota from Cloud Function (server-side source of truth)
///
/// **Usage**:
/// ```dart
/// final quotaAsync = ref.watch(templateQuotaProvider);
///
/// quotaAsync.when(
///   data: (quota) {
///     if (!quota.canCreatePrivate) {
///       // Show upgrade dialog
///     }
///   },
///   loading: () => LoadingIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
/// 🔧 FIX BUG #5: Watch currentUserProvider to invalidate on logout/switch
/// Previously used FirebaseAuth.instance.currentUser directly which didn't react to auth changes
final templateQuotaProvider = FutureProvider.autoDispose<TemplateQuotaInfo>((ref) async {
  // Watch auth stream - provider will invalidate when user changes
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;

  if (user == null) {
    // Not authenticated - return default free quota
    return TemplateQuotaInfo.empty();
  }

  return TemplateCloudService.getTemplateQuota();
});
