/// Import/Export entities for workout templates
library;

import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/export_format.dart';

/// Workout template import data format
class WorkoutTemplateImportData {

  const WorkoutTemplateImportData({
    required this.name,
    this.description,
    required this.exercises,
    required this.category,
    this.difficulty,
    this.estimatedDurationMinutes,
    this.tags,
    this.requiredEquipment,
    this.targetMuscles,
  });

  factory WorkoutTemplateImportData.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplateImportData(
      name: json['name'] as String,
      description: json['description'] as String?,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseImportData.fromJson(e as Map<String, dynamic>))
          .toList(),
      category: json['category'] as String,
      difficulty: json['difficulty'] as int?,
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      requiredEquipment: (json['requiredEquipment'] as List<dynamic>?)?.cast<String>(),
      targetMuscles: (json['targetMuscles'] as List<dynamic>?)?.cast<String>(),
    );
  }
  final String name;
  final String? description;
  final List<ExerciseImportData> exercises;
  final String category;
  final int? difficulty;
  final int? estimatedDurationMinutes;
  final List<String>? tags;
  final List<String>? requiredEquipment;
  final List<String>? targetMuscles;

  /// Creates a copy with optional new values
  WorkoutTemplateImportData copyWith({
    String? name,
    String? description,
    List<ExerciseImportData>? exercises,
    String? category,
    int? difficulty,
    int? estimatedDurationMinutes,
    List<String>? tags,
    List<String>? requiredEquipment,
    List<String>? targetMuscles,
  }) {
    return WorkoutTemplateImportData(
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      tags: tags ?? this.tags,
      requiredEquipment: requiredEquipment ?? this.requiredEquipment,
      targetMuscles: targetMuscles ?? this.targetMuscles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'category': category,
      if (difficulty != null) 'difficulty': difficulty,
      if (estimatedDurationMinutes != null) 'estimatedDurationMinutes': estimatedDurationMinutes,
      if (tags != null) 'tags': tags,
      if (requiredEquipment != null) 'requiredEquipment': requiredEquipment,
      if (targetMuscles != null) 'targetMuscles': targetMuscles,
    };
  }
}

/// Exercise import data format
class ExerciseImportData {

  const ExerciseImportData({
    required this.name,
    required this.category,
    required this.type,
    required this.sets,
    this.notes,
    this.restTimeSeconds,
  });

  factory ExerciseImportData.fromJson(Map<String, dynamic> json) {
    return ExerciseImportData(
      name: json['name'] as String,
      category: json['category'] as String,
      type: json['type'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((e) => SetImportData.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      restTimeSeconds: json['restTimeSeconds'] as int?,
    );
  }
  final String name;
  final String category;
  final String type;
  final List<SetImportData> sets;
  final String? notes;
  final int? restTimeSeconds;

  /// Creates a copy with optional new values
  ExerciseImportData copyWith({
    String? name,
    String? category,
    String? type,
    List<SetImportData>? sets,
    String? notes,
    int? restTimeSeconds,
  }) {
    return ExerciseImportData(
      name: name ?? this.name,
      category: category ?? this.category,
      type: type ?? this.type,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      restTimeSeconds: restTimeSeconds ?? this.restTimeSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'type': type,
      'sets': sets.map((e) => e.toJson()).toList(),
      if (notes != null) 'notes': notes,
      if (restTimeSeconds != null) 'restTimeSeconds': restTimeSeconds,
    };
  }
}

/// Set import data format
class SetImportData {

  const SetImportData({
    required this.setNumber,
    this.weight,
    this.reps,
    this.notes,
    this.isWarmup,
  });

  factory SetImportData.fromJson(Map<String, dynamic> json) {
    return SetImportData(
      setNumber: json['setNumber'] as int,
      weight: json['weight'] as String?,
      reps: json['reps'] as String?,
      notes: json['notes'] as String?,
      isWarmup: json['isWarmup'] as bool?,
    );
  }
  final int setNumber;
  final String? weight;
  final String? reps;
  final String? notes;
  final bool? isWarmup;

  /// Creates a copy with optional new values
  SetImportData copyWith({
    int? setNumber,
    String? weight,
    String? reps,
    String? notes,
    bool? isWarmup,
  }) {
    return SetImportData(
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      notes: notes ?? this.notes,
      isWarmup: isWarmup ?? this.isWarmup,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
      if (notes != null) 'notes': notes,
      if (isWarmup != null) 'isWarmup': isWarmup,
    };
  }
}

/// Workout template export data with analytics
class WorkoutTemplateExportData {

  const WorkoutTemplateExportData({
    required this.template,
    this.analytics,
    required this.exportedAt,
    required this.exportedBy,
    required this.version,
  });

  factory WorkoutTemplateExportData.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplateExportData(
      template: WorkoutTemplateImportData.fromJson(json['template'] as Map<String, dynamic>),
      analytics: json['analytics'] as Map<String, dynamic>?,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      exportedBy: json['exportedBy'] as String,
      version: json['version'] as String,
    );
  }
  final WorkoutTemplateImportData template;
  final Map<String, dynamic>? analytics;
  final DateTime exportedAt;
  final String exportedBy;
  final String version;

  Map<String, dynamic> toJson() {
    return {
      'template': template.toJson(),
      if (analytics != null) 'analytics': analytics,
      'exportedAt': exportedAt.toIso8601String(),
      'exportedBy': exportedBy,
      'version': version,
    };
  }
}

/// Batch export wrapper
class WorkoutTemplatesBatchExport {

  const WorkoutTemplatesBatchExport({
    required this.templates,
    required this.format,
    required this.exportedAt,
    required this.exportedBy,
    this.metadata,
  });
  final List<WorkoutTemplateExportData> templates;
  final ExportFormat format;
  final DateTime exportedAt;
  final String exportedBy;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'templates': templates.map((e) => e.toJson()).toList(),
      'format': format.name,
      'exportedAt': exportedAt.toIso8601String(),
      'exportedBy': exportedBy,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Batch import wrapper
class WorkoutTemplatesBatchImport {

  const WorkoutTemplatesBatchImport({
    required this.templates,
    this.format,
    this.importedAt,
    this.metadata,
  });

  factory WorkoutTemplatesBatchImport.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplatesBatchImport(
      templates: (json['templates'] as List<dynamic>)
          .map((e) => WorkoutTemplateImportData.fromJson(e as Map<String, dynamic>))
          .toList(),
      format: json['format'] as String?,
      importedAt: json['importedAt'] != null
          ? DateTime.parse(json['importedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
  final List<WorkoutTemplateImportData> templates;
  final String? format;
  final DateTime? importedAt;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'templates': templates.map((e) => e.toJson()).toList(),
      if (format != null) 'format': format,
      if (importedAt != null) 'importedAt': importedAt!.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}
