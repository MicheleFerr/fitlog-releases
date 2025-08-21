import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/workout_template.dart';
import '../../domain/entities/exercise.dart';

class WorkoutTemplateRepository {
  static const String _templatesKey = 'workout_templates';
  static const String _predefinedTemplatesKey = 'predefined_templates_v1';

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
      print('Errore nel caricamento template personalizzati: $e');
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
      print('Errore nel caricamento template predefiniti: $e');
      return [];
    }
  }

  /// Salva un template personalizzato
  Future<void> saveTemplate(WorkoutTemplate template) async {
    print('💾 LOCAL: Salvando template "${template.name}" con ${template.exercises.length} esercizi');
    
    try {
      final templates = await getAllTemplates();
      
      // Rimuovi il template esistente se è un aggiornamento
      templates.removeWhere((t) => t.id == template.id);
      
      // Aggiungi il template aggiornato
      templates.add(template);
      
      print('💾 LOCAL: Template aggiunto, totale templates: ${templates.length}');
      print('💾 LOCAL: Template appena aggiunto ha ${template.exercises.length} esercizi');
      
      await _saveAllTemplates(templates);
    } catch (e) {
      print('Errore nel salvataggio template: $e');
      throw Exception('Impossibile salvare il template');
    }
  }

  /// Elimina un template personalizzato
  Future<void> deleteTemplate(String templateId) async {
    try {
      final templates = await getAllTemplates();
      final templateToDelete = templates.firstWhere((t) => t.id == templateId);
      
      // Non permettere l'eliminazione di template predefiniti
      if (!templateToDelete.isCustom) {
        throw Exception('Non puoi eliminare template predefiniti');
      }
      
      templates.removeWhere((t) => t.id == templateId);
      await _saveAllTemplates(templates);
    } catch (e) {
      print('Errore nell\'eliminazione template: $e');
      throw Exception('Impossibile eliminare il template');
    }
  }

  /// Incrementa il contatore di utilizzo di un template
  Future<void> incrementUsage(String templateId) async {
    try {
      final templates = await getAllTemplates();
      final templateIndex = templates.indexWhere((t) => t.id == templateId);
      
      if (templateIndex != -1) {
        templates[templateIndex] = templates[templateIndex].incrementUsage();
        await _saveAllTemplates(templates);
      }
    } catch (e) {
      print('Errore nell\'aggiornamento utilizzo template: $e');
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
    final exerciseTemplates = exercises.map((exercise) {
      return ExerciseTemplate(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        category: exercise.category,
        type: exercise.type,
        sets: exercise.sets.map((set) {
          return SetTemplate(
            setNumber: set.setNumber,
            targetWeight: set.weight,
            targetReps: set.reps,
            notes: set.notes,
          );
        }).toList(),
        notes: exercise.notes,
        restTime: exercise.restTime,
      );
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
        description: 'Allenamento completo parte superiore: petto, schiena, spalle e braccia',
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
      print('Errore nel salvataggio template: $e');
      throw Exception('Impossibile salvare i template');
    }
  }

  /// Stima la durata del workout basata sugli esercizi
  int _estimateDuration(List<Exercise> exercises) {
    int totalSets = exercises.fold(0, (sum, exercise) => sum + exercise.sets.length);
    int restTime = exercises.fold(0, (sum, exercise) => sum + (exercise.restTime ?? 90));
    
    // Stima: 2 minuti per set + tempo di riposo
    return (totalSets * 2) + (restTime ~/ 60);
  }
}