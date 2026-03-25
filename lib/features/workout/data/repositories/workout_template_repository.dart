import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Local template repository with SharedPreferences storage
///
/// 🔐 USER ISOLATION: Cache keys are now user-scoped to prevent data leakage
/// when switching between accounts. Uses UserCacheKeyManager.
class WorkoutTemplateRepository {
  // 🔐 User-scoped cache keys via UserCacheKeyManager
  // Pattern: 'workout_templates_{userId}' instead of global 'workout_templates'
  String get _templatesKey => userCacheKeys.localTemplatesCacheKey;
  String get _predefinedTemplatesKey => userCacheKeys.predefinedTemplatesKey;

  /// Ottiene tutti i template (predefiniti + personalizzati)
  Future<List<WorkoutTemplate>> getAllTemplates() async {
    final customTemplates = await getCustomTemplates();
    final predefinedTemplates = await getPredefinedTemplates();

    // Combina e ordina per utilizzo e data
    final allTemplates = [...predefinedTemplates, ...customTemplates];
    allTemplates.sort((a, b) {
      // Prima ordina per utilizzo (più usati prima)
      final usageCompare = b.usageCount.compareTo(a.usageCount);
      if (usageCompare != 0) return usageCompare;

      // Poi per data di aggiornamento (più recenti prima)
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return allTemplates;
  }

  /// Ottiene solo i template personalizzati dell'utente
  Future<List<WorkoutTemplate>> getCustomTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getString(_templatesKey);

      if (templatesJson == null) {
        return [];
      }

      final List<dynamic> templatesList = json.decode(templatesJson);
      final customTemplates = templatesList
          .map((json) => WorkoutTemplate.fromJson(json))
          .where((template) => template.isCustom)
          .toList();

      return customTemplates;
    } catch (e) {
      return [];
    }
  }

  /// Ottiene i template predefiniti
  Future<List<WorkoutTemplate>> getPredefinedTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Controlla se i template predefiniti sono già stati inizializzati
      final isInitialized = prefs.getBool(_predefinedTemplatesKey) ?? false;

      if (!isInitialized) {
        await _initializePredefinedTemplates();
        await prefs.setBool(_predefinedTemplatesKey, true);
      }

      final templatesJson = prefs.getString(_templatesKey);
      if (templatesJson == null) return [];

      final List<dynamic> templatesList = json.decode(templatesJson);
      return templatesList
          .map((json) => WorkoutTemplate.fromJson(json))
          .where((template) => !template.isCustom)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Salva un template personalizzato
  Future<void> saveTemplate(WorkoutTemplate template) async {
    if (kDebugMode) {
      debugPrint(
        '💾 LOCAL: Salvando template "${template.name}" con ${template.exercises.length} esercizi',
      );
    }

    try {
      // Work with custom templates only
      final customTemplates = await getCustomTemplates();

      // Rimuovi il template esistente se è un aggiornamento
      customTemplates.removeWhere((t) => t.id == template.id);

      // Aggiungi il template aggiornato (ensure it's marked as custom)
      final customTemplate = template.copyWith(isCustom: true);
      customTemplates.add(customTemplate);

      if (kDebugMode) {
        debugPrint(
          '💾 LOCAL: Template aggiunto, totale custom templates: ${customTemplates.length}',
        );
      }
      debugPrint(
        '💾 LOCAL: Template appena aggiunto ha ${customTemplate.exercises.length} esercizi',
      );

      // Save only custom templates
      await _saveCustomTemplates(customTemplates);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ LOCAL: Errore nel salvataggio template: $e');
      }
      throw Exception('Impossibile salvare il template: $e');
    }
  }

  /// Local repository templates are always editable.
  Future<WorkoutTemplate> ensureEditableTemplate(
    WorkoutTemplate template,
  ) async {
    return template;
  }

  /// Elimina un template personalizzato
  Future<void> deleteTemplate(String templateId) async {
    try {
      // IMPORTANT: Only work with custom templates, not ALL templates
      final customTemplates = await getCustomTemplates();
      final templateToDelete = customTemplates.firstWhere(
        (t) => t.id == templateId,
        orElse: () => throw Exception('Template non trovato'),
      );

      // Non permettere l'eliminazione di template predefiniti (double check)
      if (!templateToDelete.isCustom) {
        throw Exception('Non puoi eliminare template predefiniti');
      }

      // Remove from custom templates only
      customTemplates.removeWhere((t) => t.id == templateId);

      // Save only the custom templates (not predefined ones)
      await _saveCustomTemplates(customTemplates);

      if (kDebugMode) {
        debugPrint('✅ LOCAL REPO: Template $templateId deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ LOCAL REPO: Error deleting template $templateId: $e');
      }
      throw Exception('Impossibile eliminare il template: $e');
    }
  }

  /// Incrementa il contatore di utilizzo di un template
  Future<void> incrementUsage(String templateId) async {
    try {
      // Check if it's a custom template first
      final customTemplates = await getCustomTemplates();
      final customIndex = customTemplates.indexWhere((t) => t.id == templateId);

      if (customIndex != -1) {
        // It's a custom template, update and save
        customTemplates[customIndex] = customTemplates[customIndex]
            .incrementUsage();
        await _saveCustomTemplates(customTemplates);
        if (kDebugMode) {
          debugPrint(
            '✅ LOCAL REPO: Incremented usage for custom template $templateId',
          );
        }
      } else {
        // It might be a predefined template - we don't persist usage for those
        // Or we could track usage separately for predefined templates
        if (kDebugMode) {
          debugPrint(
            'ℹ️ LOCAL REPO: Template $templateId is not a custom template, usage not tracked',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ LOCAL REPO: Error updating template usage: $e');
      }
    }
  }

  /// Cerca template per nome o tag
  Future<List<WorkoutTemplate>> searchTemplates(String query) async {
    final templates = await getAllTemplates();
    final lowerQuery = query.toLowerCase();

    return templates.where((template) {
      return template.name.toLowerCase().contains(lowerQuery) ||
          template.description.toLowerCase().contains(lowerQuery) ||
          template.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Filtra template per tag
  Future<List<WorkoutTemplate>> getTemplatesByTags(List<String> tags) async {
    final templates = await getAllTemplates();

    return templates.where((template) {
      return tags.any((tag) => template.tags.contains(tag));
    }).toList();
  }

  /// Crea un template da un workout esistente
  Future<WorkoutTemplate> createTemplateFromWorkout({
    required String name,
    required String description,
    required List<Exercise> exercises,
    List<String>? tags,
    String? imageUrl,
  }) async {
    // ✅ FIX: Use fromExercise() to properly preserve all fields including TUT
    final exerciseTemplates = exercises.map((exercise) {
      return ExerciseTemplate.fromExercise(exercise);
    }).toList();

    final template = WorkoutTemplate(
      name: name,
      description: description,
      exercises: exerciseTemplates,
      tags: tags ?? [],
      imageUrl: imageUrl,
      estimatedDuration: _estimateDuration(exercises),
    );

    await saveTemplate(template);
    return template;
  }

  /// Inizializza i template predefiniti
  Future<void> _initializePredefinedTemplates() async {
    final predefinedTemplates = [
      WorkoutTemplate(
        name: 'Upper Body Strength',
        description:
            'Allenamento completo parte superiore: petto, schiena, spalle e braccia',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'panca_piana',
            exerciseName: 'Panca Piana',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 8),
              SetTemplate(setNumber: 4, targetReps: 6),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'trazioni',
            exerciseName: 'Trazioni',
            category: ExerciseCategory.back,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 8),
              SetTemplate(setNumber: 2, targetReps: 8),
              SetTemplate(setNumber: 3, targetReps: 6),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'shoulder_press',
            exerciseName: 'Shoulder Press',
            category: ExerciseCategory.shoulders,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 8),
            ],
          ),
        ],
        tags: ['upper', 'strength', 'intermediate'],
        estimatedDuration: 60,
        isCustom: false,
      ),

      WorkoutTemplate(
        name: 'Lower Body Power',
        description: 'Allenamento gambe e glutei: squat, stacchi e affondi',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'squat',
            exerciseName: 'Squat',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 8),
              SetTemplate(setNumber: 4, targetReps: 6),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'stacco_da_terra',
            exerciseName: 'Stacco da Terra',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 8),
              SetTemplate(setNumber: 2, targetReps: 6),
              SetTemplate(setNumber: 3, targetReps: 4),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'affondi',
            exerciseName: 'Affondi',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 12),
              SetTemplate(setNumber: 3, targetReps: 10),
            ],
          ),
        ],
        tags: ['lower', 'power', 'intermediate'],
        estimatedDuration: 55,
        isCustom: false,
      ),

      WorkoutTemplate(
        name: 'HIIT Cardio',
        description: 'Allenamento ad alta intensità per cardio e resistenza',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'burpees',
            exerciseName: 'Burpees',
            category: ExerciseCategory.cardio,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 15),
              SetTemplate(setNumber: 3, targetReps: 12),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'mountain_climbers',
            exerciseName: 'Mountain Climbers',
            category: ExerciseCategory.cardio,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 30),
              SetTemplate(setNumber: 2, targetReps: 30),
              SetTemplate(setNumber: 3, targetReps: 25),
            ],
          ),
        ],
        tags: ['hiit', 'cardio', 'beginner'],
        estimatedDuration: 25,
        isCustom: false,
      ),

      WorkoutTemplate(
        name: 'Core & Abs',
        description: 'Allenamento mirato per addominali e core stability',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'plank',
            exerciseName: 'Plank',
            category: ExerciseCategory.abs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 60), // 60 secondi
              SetTemplate(setNumber: 2, targetReps: 45),
              SetTemplate(setNumber: 3, targetReps: 30),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'crunches',
            exerciseName: 'Crunches',
            category: ExerciseCategory.abs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 20),
              SetTemplate(setNumber: 2, targetReps: 20),
              SetTemplate(setNumber: 3, targetReps: 15),
            ],
          ),
        ],
        tags: ['core', 'abs', 'beginner'],
        estimatedDuration: 20,
        isCustom: false,
      ),
    ];

    // Salva tutti i template predefiniti
    await _saveAllTemplates(predefinedTemplates);
  }

  /// Salva tutti i template nel storage
  Future<void> _saveAllTemplates(List<WorkoutTemplate> templates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = json.encode(
        templates.map((template) => template.toJson()).toList(),
      );
      await prefs.setString(_templatesKey, templatesJson);
    } catch (e) {
      throw Exception('Impossibile salvare i template');
    }
  }

  /// Salva solo i template personalizzati nel storage
  Future<void> _saveCustomTemplates(
    List<WorkoutTemplate> customTemplates,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Filter to ensure only custom templates are saved
      final customOnly = customTemplates.where((t) => t.isCustom).toList();
      final templatesJson = json.encode(
        customOnly.map((template) => template.toJson()).toList(),
      );
      await prefs.setString(_templatesKey, templatesJson);
      if (kDebugMode) {
        debugPrint('✅ LOCAL REPO: Saved ${customOnly.length} custom templates');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ LOCAL REPO: Error saving custom templates: $e');
      }
      throw Exception('Impossibile salvare i template personalizzati');
    }
  }

  /// Stima la durata del workout basata sugli esercizi
  int _estimateDuration(List<Exercise> exercises) {
    final int totalSets = exercises.fold(
      0,
      (sum, exercise) => sum + exercise.sets.length,
    );
    final int restTime = exercises.fold(
      0,
      (sum, exercise) => sum + (exercise.restTime ?? 90),
    );

    // Stima: 2 minuti per set + tempo di riposo
    return (totalSets * 2) + (restTime ~/ 60);
  }
}
