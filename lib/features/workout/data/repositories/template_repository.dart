import 'package:hive/hive.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_template.dart';

/// Repository for managing exercise templates with Hive storage
///
/// Templates are stored as JSON in Hive box using exerciseName as key
/// Provides CRUD operations for quick exercise logging
abstract class TemplateRepository {
  Future<List<ExerciseTemplate>> getAllTemplates();
  Future<ExerciseTemplate?> getTemplate(String exerciseName);
  Future<void> saveTemplate(ExerciseTemplate template);
  Future<void> deleteTemplate(String exerciseName);
}

class TemplateRepositoryImpl implements TemplateRepository {
  static const String _boxName = 'exercise_templates';

  @override
  Future<List<ExerciseTemplate>> getAllTemplates() async {
    final box = await Hive.openBox<Map>(_boxName);
    return box.values
        .map((json) => ExerciseTemplate.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<ExerciseTemplate?> getTemplate(String exerciseName) async {
    final box = await Hive.openBox<Map>(_boxName);
    final json = box.get(exerciseName);
    if (json == null) return null;
    return ExerciseTemplate.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<void> saveTemplate(ExerciseTemplate template) async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.put(template.exerciseName, template.toJson());
  }

  @override
  Future<void> deleteTemplate(String exerciseName) async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.delete(exerciseName);
  }
}
