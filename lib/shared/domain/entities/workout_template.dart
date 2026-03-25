import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

enum TemplateVisibility { private, unlisted, public }

enum TemplateLineageType { original, fork }

enum TemplateDistributionStatus { active, superseded, hidden }

/// Template per workout riutilizzabili
class WorkoutTemplate {
  // 3, 6, o 10

  WorkoutTemplate({
    String? id,
    required this.name,
    required this.description,
    this.imageUrl,
    List<ExerciseTemplate>? exercises,
    this.estimatedDuration = 45,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isCustom = true,
    this.usageCount = 0,
    this.isPublic = false,
    this.visibility = TemplateVisibility.private,
    this.lineageType = TemplateLineageType.original,
    this.parentTemplateId,
    this.rootTemplateId,
    this.distributionStatus = TemplateDistributionStatus.active,
    this.publishedAt,
    this.versionNumber = 1,
    this.userId,
    this.authorName,
    this.authorPhotoUrl,
    this.downloadCount = 0,
    this.forkCount = 0,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.difficulty,
    this.category,
    this.defaultAutoAdjustmentType,
    this.defaultApreProtocol,
    this.isAnonymous = false,
    this.forkedFromTemplateId,
    this.originalAuthorName,
    this.supersededByTemplateId,
  }) : id = id ?? const Uuid().v4(),
       exercises = exercises ?? [],
       tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    // Parse exercises with enhanced error handling
    final List<ExerciseTemplate> exercises = [];
    if (json['exercises'] != null) {
      if (json['exercises'] is List) {
        final exercisesList = json['exercises'] as List;

        for (int i = 0; i < exercisesList.length; i++) {
          try {
            final exerciseJson = exercisesList[i];
            if (exerciseJson is Map<String, dynamic>) {
              final exerciseTemplate = ExerciseTemplate.fromJson(exerciseJson);
              exercises.add(exerciseTemplate);
            }
          } catch (_) {
            // Skip malformed exercises - better to load partial template than fail completely
          }
        }
      }
    }

    // Parse auto-adjustment type
    AutoAdjustmentType? defaultAutoAdjustmentType;
    if (json['defaultAutoAdjustmentType'] != null) {
      try {
        defaultAutoAdjustmentType = AutoAdjustmentType.values.firstWhere(
          (e) => e.name == json['defaultAutoAdjustmentType'],
        );
      } catch (e) {
        defaultAutoAdjustmentType = null;
      }
    }

    final visibility = _parseVisibility(
      json['visibility']?.toString(),
      fallbackIsPublic: json['isPublic'] == true,
    );
    final lineageType = _parseLineageType(
      json['lineageType']?.toString(),
      fallbackForkedFromTemplateId: json['forkedFromTemplateId']?.toString(),
    );
    final distributionStatus = _parseDistributionStatus(
      json['distributionStatus']?.toString(),
    );

    return WorkoutTemplate(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      exercises: exercises,
      estimatedDuration: json['estimatedDuration'] is int
          ? json['estimatedDuration']
          : 45,
      tags: json['tags'] is List
          ? List<String>.from(json['tags'].map((t) => t.toString()))
          : [],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      isCustom: json['isCustom'] is bool ? json['isCustom'] : true,
      usageCount: json['usageCount'] is int ? json['usageCount'] : 0,
      isPublic: visibility == TemplateVisibility.public,
      visibility: visibility,
      lineageType: lineageType,
      parentTemplateId: json['parentTemplateId']?.toString(),
      rootTemplateId: json['rootTemplateId']?.toString(),
      distributionStatus: distributionStatus,
      publishedAt: _parseNullableDateTime(json['publishedAt']),
      versionNumber: json['versionNumber'] is int ? json['versionNumber'] : 1,
      userId: json['userId']?.toString(),
      authorName: json['authorName']?.toString(),
      authorPhotoUrl: json['authorPhotoUrl']?.toString(),
      downloadCount: json['downloadCount'] is int ? json['downloadCount'] : 0,
      forkCount: json['forkCount'] is int ? json['forkCount'] : 0,
      averageRating: json['averageRating'] is num
          ? json['averageRating'].toDouble()
          : 0.0,
      reviewCount: json['reviewCount'] is int ? json['reviewCount'] : 0,
      difficulty: json['difficulty']?.toString(),
      category: json['category']?.toString(),
      defaultAutoAdjustmentType: defaultAutoAdjustmentType,
      defaultApreProtocol: json['defaultApreProtocol'] is int
          ? json['defaultApreProtocol']
          : null,
      isAnonymous: json['isAnonymous'] is bool ? json['isAnonymous'] : false,
      forkedFromTemplateId: json['forkedFromTemplateId']?.toString(),
      originalAuthorName: json['originalAuthorName']?.toString(),
      supersededByTemplateId: json['supersededByTemplateId']?.toString(),
    );
  }
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<ExerciseTemplate> exercises;
  final int estimatedDuration; // in minutes
  final List<String> tags; // es: ["upper", "strength", "beginner"]
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCustom; // true se creato dall'utente, false se predefinito
  final int usageCount; // quante volte è stato utilizzato

  // Campi per condivisione pubblica
  final bool isPublic; // true se condiviso pubblicamente
  final TemplateVisibility visibility;
  final TemplateLineageType lineageType;
  final String? parentTemplateId;
  final String? rootTemplateId;
  final TemplateDistributionStatus distributionStatus;
  final DateTime? publishedAt;
  final int versionNumber;
  final String? userId; // ID dell'utente creatore
  final String? authorName; // Nome dell'autore per template pubblici
  final String? authorPhotoUrl;
  final int downloadCount; // Numero di download (per template pubblici)
  final int forkCount; // Numero di fork del template
  final double averageRating; // Rating medio (1-5)
  final int reviewCount; // Numero di recensioni
  final String? difficulty; // beginner, intermediate, advanced, expert
  final String?
  category; // beginner, intermediate, advanced, home, dumbbell, express, specialty

  // Auto-regolazione predefinita
  final AutoAdjustmentType? defaultAutoAdjustmentType; // APRE o RPE
  final int? defaultApreProtocol;

  // GDPR: Pubblicazione anonima
  final bool isAnonymous;

  // Fork attribution
  final String? forkedFromTemplateId;
  final String? originalAuthorName;
  final String? supersededByTemplateId;

  bool get isShared => visibility != TemplateVisibility.private;

  bool get isDistributedTemplate =>
      visibility != TemplateVisibility.private && isActiveDistribution;

  bool get isEditable => visibility == TemplateVisibility.private;

  bool get isLibraryTemplate => isEditable;

  bool get isOriginalTemplate => lineageType == TemplateLineageType.original;

  bool get isForkTemplate => lineageType == TemplateLineageType.fork;

  bool get isActiveDistribution =>
      distributionStatus == TemplateDistributionStatus.active;

  bool get isDiscoverablePublic =>
      visibility == TemplateVisibility.public &&
      lineageType == TemplateLineageType.original &&
      distributionStatus == TemplateDistributionStatus.active;

  bool get isStoreTemplate => isDiscoverablePublic;

  bool get canPublishPublic =>
      lineageType == TemplateLineageType.original &&
      distributionStatus == TemplateDistributionStatus.active &&
      visibility != TemplateVisibility.public;

  bool get canShareUnlisted =>
      distributionStatus == TemplateDistributionStatus.active &&
      (visibility == TemplateVisibility.private ||
          visibility == TemplateVisibility.unlisted);

  String get effectiveRootTemplateId =>
      rootTemplateId ?? forkedFromTemplateId ?? id;

  WorkoutTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    List<ExerciseTemplate>? exercises,
    int? estimatedDuration,
    List<String>? tags,
    DateTime? updatedAt,
    bool? isCustom,
    int? usageCount,
    bool? isPublic,
    TemplateVisibility? visibility,
    TemplateLineageType? lineageType,
    String? parentTemplateId,
    String? rootTemplateId,
    TemplateDistributionStatus? distributionStatus,
    DateTime? publishedAt,
    int? versionNumber,
    String? userId,
    String? authorName,
    String? authorPhotoUrl,
    int? downloadCount,
    int? forkCount,
    double? averageRating,
    int? reviewCount,
    String? difficulty,
    String? category,
    AutoAdjustmentType? defaultAutoAdjustmentType,
    int? defaultApreProtocol,
    bool? isAnonymous,
    String? forkedFromTemplateId,
    String? originalAuthorName,
    String? supersededByTemplateId,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      exercises: exercises ?? this.exercises,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isCustom: isCustom ?? this.isCustom,
      usageCount: usageCount ?? this.usageCount,
      isPublic:
          isPublic ??
          ((visibility ?? this.visibility) == TemplateVisibility.public),
      visibility: visibility ?? this.visibility,
      lineageType: lineageType ?? this.lineageType,
      parentTemplateId: parentTemplateId ?? this.parentTemplateId,
      rootTemplateId: rootTemplateId ?? this.rootTemplateId,
      distributionStatus: distributionStatus ?? this.distributionStatus,
      publishedAt: publishedAt ?? this.publishedAt,
      versionNumber: versionNumber ?? this.versionNumber,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      downloadCount: downloadCount ?? this.downloadCount,
      forkCount: forkCount ?? this.forkCount,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      defaultAutoAdjustmentType:
          defaultAutoAdjustmentType ?? this.defaultAutoAdjustmentType,
      defaultApreProtocol: defaultApreProtocol ?? this.defaultApreProtocol,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      forkedFromTemplateId: forkedFromTemplateId ?? this.forkedFromTemplateId,
      originalAuthorName: originalAuthorName ?? this.originalAuthorName,
      supersededByTemplateId:
          supersededByTemplateId ?? this.supersededByTemplateId,
    );
  }

  /// Incrementa il contatore di utilizzo
  WorkoutTemplate incrementUsage() {
    return copyWith(usageCount: usageCount + 1, updatedAt: DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'estimatedDuration': estimatedDuration,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCustom': isCustom,
      'usageCount': usageCount,
      'isPublic': isPublic,
      'visibility': visibility.name,
      'lineageType': lineageType.name,
      if (parentTemplateId != null) 'parentTemplateId': parentTemplateId,
      'rootTemplateId': effectiveRootTemplateId,
      'distributionStatus': distributionStatus.name,
      if (publishedAt != null) 'publishedAt': publishedAt!.toIso8601String(),
      'versionNumber': versionNumber,
      'userId': userId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'downloadCount': downloadCount,
      'forkCount': forkCount,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'difficulty': difficulty,
      'category': category,
      'defaultAutoAdjustmentType': defaultAutoAdjustmentType?.name,
      'defaultApreProtocol': defaultApreProtocol,
      'isAnonymous': isAnonymous,
      if (forkedFromTemplateId != null)
        'forkedFromTemplateId': forkedFromTemplateId,
      if (originalAuthorName != null) 'originalAuthorName': originalAuthorName,
      if (supersededByTemplateId != null)
        'supersededByTemplateId': supersededByTemplateId,
    };
  }

  /// Crea un workout dal template
  List<Exercise> toWorkoutExercises() {
    return exercises.map((template) => template.toWorkoutExercise()).toList();
  }
}

TemplateVisibility _parseVisibility(
  String? raw, {
  required bool fallbackIsPublic,
}) {
  switch (raw) {
    case 'public':
      return TemplateVisibility.public;
    case 'unlisted':
      return TemplateVisibility.unlisted;
    case 'private':
      return TemplateVisibility.private;
    default:
      return fallbackIsPublic
          ? TemplateVisibility.public
          : TemplateVisibility.private;
  }
}

TemplateLineageType _parseLineageType(
  String? raw, {
  required String? fallbackForkedFromTemplateId,
}) {
  switch (raw) {
    case 'fork':
      return TemplateLineageType.fork;
    case 'original':
      return TemplateLineageType.original;
    default:
      return fallbackForkedFromTemplateId != null
          ? TemplateLineageType.fork
          : TemplateLineageType.original;
  }
}

TemplateDistributionStatus _parseDistributionStatus(String? raw) {
  switch (raw) {
    case 'superseded':
      return TemplateDistributionStatus.superseded;
    case 'hidden':
      return TemplateDistributionStatus.hidden;
    case 'active':
    default:
      return TemplateDistributionStatus.active;
  }
}

DateTime _parseDateTime(dynamic value) {
  return _parseNullableDateTime(value) ?? DateTime.now();
}

DateTime? _parseNullableDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  try {
    final parsed = value.toDate();
    if (parsed is DateTime) {
      return parsed;
    }
  } catch (_) {
    // Ignore unsupported timestamp-like values.
  }
  return null;
}

/// Template per esercizio all'interno di un workout template
class ExerciseTemplate {
  // For superset, dropset, etc.

  const ExerciseTemplate({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    this.type = ExerciseType.single,
    List<SetTemplate>? sets,
    this.notes,
    this.restTime,
    this.tut, // ⌚ Time Under Tension (e.g., "3-1-2-0")
    this.subExercises,
    this.countingMode, // How this exercise is counted (weighted/reps/time)
  }) : sets = sets ?? const [];

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) {
    // FIX: Support both old format ('id', 'name') and new format ('exerciseId', 'exerciseName')
    // for backward compatibility with templates saved via Cloud Function
    final exerciseId =
        json['exerciseId']?.toString() ?? json['id']?.toString() ?? '';
    final exerciseName =
        json['exerciseName']?.toString() ?? json['name']?.toString() ?? '';

    // Validate required fields (after fallback)
    if (exerciseId.isEmpty) {
      // Silent - will use empty string
    }
    if (exerciseName.isEmpty) {
      // Silent - will use empty string
    }

    // Parse category with better error handling
    ExerciseCategory category;
    try {
      category = ExerciseCategory.values.firstWhere(
        (e) => e.name == json['category'],
      );
    } catch (e) {
      category = ExerciseCategory.other;
    }

    // Parse type with better error handling
    ExerciseType type;
    try {
      type = ExerciseType.values.firstWhere((e) => e.name == json['type']);
    } catch (e) {
      type = ExerciseType.single;
    }

    // Parse sets with validation
    List<SetTemplate> sets = [];
    if (json['sets'] != null) {
      try {
        sets = (json['sets'] as List)
            .map((s) => SetTemplate.fromJson(s as Map<String, dynamic>))
            .toList();
      } catch (e) {
        sets = [];
      }
    }

    // ✅ FIX: For supersets, also check supersetSets to determine round count
    // If sets is empty but supersetSets exists, create sets from supersetSets
    if (sets.isEmpty &&
        type == ExerciseType.superset &&
        json['supersetSets'] != null) {
      try {
        final supersetSetsJson = json['supersetSets'] as List;
        sets = supersetSetsJson.asMap().entries.map((entry) {
          final index = entry.key;
          final roundJson = entry.value as Map<String, dynamic>;

          // Try to extract target values from exerciseData if available
          double? targetWeight;
          int? targetReps;

          if (roundJson['exerciseData'] != null) {
            final exerciseDataMap = roundJson['exerciseData'] as Map;
            if (exerciseDataMap.isNotEmpty) {
              final firstExerciseData = exerciseDataMap.values.first;
              if (firstExerciseData is Map) {
                targetWeight = (firstExerciseData['targetWeight'] as num?)
                    ?.toDouble();
                targetReps = firstExerciseData['targetReps'] as int?;
              }
            }
          }

          return SetTemplate(
            setNumber: roundJson['setNumber'] as int? ?? index + 1,
            targetWeight: targetWeight,
            targetReps: targetReps,
          );
        }).toList();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error parsing supersetSets: $e');
        }
      }
    }

    // Parse sub-exercises for superset/dropset
    List<ExerciseTemplate>? subExercises;
    if (json['exercises'] != null && json['exercises'] is List) {
      try {
        subExercises = (json['exercises'] as List)
            .map((e) => ExerciseTemplate.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error parsing sub-exercises: $e');
        }
        subExercises = null;
      }
    }

    // Parse countingMode if present
    ExerciseCountingMode? countingMode;
    if (json['countingMode'] != null) {
      countingMode = ExerciseCountingMode.fromString(
        json['countingMode'] as String?,
      );
    }

    final exerciseTemplate = ExerciseTemplate(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      category: category,
      type: type,
      sets: sets,
      notes: json['notes']?.toString(),
      // FIX: Firebase may return restTime as double, use num to handle both int and double
      restTime: json['restTime'] is num
          ? (json['restTime'] as num).toInt()
          : null,
      tut: json['tut']?.toString(), // ⌚ Time Under Tension
      subExercises: subExercises,
      countingMode: countingMode,
    );

    return exerciseTemplate;
  }

  /// ✅ FIX: Factory method to create ExerciseTemplate from Exercise
  /// Properly handles SupersetExercise by extracting supersetSets and child exercises
  factory ExerciseTemplate.fromExercise(Exercise exercise) {
    // Handle SupersetExercise specially
    if (exercise is SupersetExercise) {
      // Create sets from supersetSets (one per round)
      final sets = exercise.supersetSets.asMap().entries.map((entry) {
        final index = entry.key;
        final supersetSet = entry.value;

        // Get target values from first exercise in round
        double? targetWeight;
        int? targetReps;
        int? targetMinReps;
        int? targetMaxReps;
        if (supersetSet.exerciseData.isNotEmpty) {
          final firstData = supersetSet.exerciseData.values.first;
          targetWeight = firstData.targetWeight;
          targetReps = firstData.targetReps;
          targetMinReps = firstData.targetMinReps;
          targetMaxReps = firstData.targetMaxReps;
        }

        return SetTemplate(
          setNumber: index + 1,
          targetWeight: targetWeight,
          targetReps: targetReps,
          targetMinReps: targetMinReps,
          targetMaxReps: targetMaxReps,
        );
      }).toList();

      // Create subExercises from the child exercises
      final subExercises = exercise.exercises.map((childExercise) {
        return ExerciseTemplate.fromExercise(childExercise);
      }).toList();

      return ExerciseTemplate(
        exerciseId: exercise.stableExerciseId,
        exerciseName: exercise.name,
        category: exercise.category,
        type: exercise.type,
        sets: sets,
        notes: exercise.notes,
        restTime: exercise.restTime,
        tut: exercise.tut, // ⌚ Time Under Tension
        subExercises: subExercises,
        countingMode: exercise.countingMode,
      );
    }

    // Handle DropSetExercise
    if (exercise is DropSetExercise) {
      final sets = exercise.stages.asMap().entries.map((entry) {
        final index = entry.key;
        final stage = entry.value;
        return SetTemplate(
          setNumber: index + 1,
          targetWeight: stage.weight,
          targetReps: stage.reps,
          targetMinReps: stage.minReps,
          targetMaxReps: stage.maxReps,
        );
      }).toList();

      return ExerciseTemplate(
        exerciseId: exercise.stableExerciseId,
        exerciseName: exercise.name,
        category: exercise.category,
        type: exercise.type,
        sets: sets,
        notes: exercise.notes,
        restTime: exercise.restTime,
        tut: exercise.tut, // ⌚ Time Under Tension
        countingMode: exercise.countingMode,
      );
    }

    // Handle RestPauseExercise
    if (exercise is RestPauseExercise) {
      final sets = exercise.restPauseSets.asMap().entries.map((entry) {
        final index = entry.key;
        final rpSet = entry.value;
        return SetTemplate(
          setNumber: index + 1,
          targetWeight: exercise.weight, // ✅ Preserve weight for all sets
          targetReps: rpSet.reps,
          targetMinReps: rpSet.minReps,
          targetMaxReps: rpSet.maxReps,
          restSeconds: rpSet.restSeconds, // ✅ Preserve restSeconds
        );
      }).toList();

      return ExerciseTemplate(
        exerciseId: exercise.stableExerciseId,
        exerciseName: exercise.name,
        category: exercise.category,
        type: exercise.type,
        sets: sets,
        notes: exercise.notes,
        restTime: exercise.restTime,
        tut: exercise.tut, // ⌚ Time Under Tension
        countingMode: exercise.countingMode,
      );
    }

    // Standard exercise - use the regular sets
    return ExerciseTemplate(
      exerciseId: exercise.stableExerciseId,
      exerciseName: exercise.name,
      category: exercise.category,
      type: exercise.type,
      sets: exercise.sets.map((set) {
        return SetTemplate(
          setNumber: set.setNumber,
          targetWeight: set.weight,
          targetReps: set.reps,
          targetMinReps: set.minReps,
          targetMaxReps: set.maxReps,
          targetRpe: set.rpe,
          notes: set.notes,
        );
      }).toList(),
      notes: exercise.notes,
      restTime: exercise.restTime,
      tut: exercise.tut, // ⌚ Time Under Tension
      countingMode: exercise.countingMode,
    );
  }

  final String exerciseId; // ID dell'esercizio nel database
  final String exerciseName;
  final ExerciseCategory category;
  final ExerciseType type;
  final List<SetTemplate> sets;
  final String? notes;
  final int? restTime;
  final String? tut; // ⌚ Time Under Tension (e.g., "3-1-2-0")
  final List<ExerciseTemplate>? subExercises;
  final ExerciseCountingMode?
  countingMode; // How this exercise is counted (weighted/reps/time)

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'category': category.name,
      'type': type.name,
      'sets': sets.map((s) => s.toJson()).toList(),
      'notes': notes,
      'restTime': restTime,
      'tut': tut, // ⌚ Time Under Tension
      if (subExercises != null && subExercises!.isNotEmpty)
        'exercises': subExercises!.map((e) => e.toJson()).toList(),
      if (countingMode != null) 'countingMode': countingMode!.name,
    };
  }

  /// Crea una copia con modifiche
  ExerciseTemplate copyWith({
    String? exerciseId,
    String? exerciseName,
    ExerciseCategory? category,
    ExerciseType? type,
    List<SetTemplate>? sets,
    String? notes,
    int? restTime,
    String? tut, // ⌚ Time Under Tension
    List<ExerciseTemplate>? subExercises,
    ExerciseCountingMode? countingMode,
  }) {
    return ExerciseTemplate(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      category: category ?? this.category,
      type: type ?? this.type,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      restTime: restTime ?? this.restTime,
      tut: tut ?? this.tut, // ⌚ Time Under Tension
      subExercises: subExercises ?? this.subExercises,
      countingMode: countingMode ?? this.countingMode,
    );
  }

  /// Converte il template in un esercizio per il workout
  Exercise toWorkoutExercise() {
    // If it's a superset and has sub-exercises, create a SupersetExercise
    if (type == ExerciseType.superset &&
        subExercises != null &&
        subExercises!.isNotEmpty) {
      final exercises = subExercises!
          .map(
            (subTemplate) => Exercise(
              databaseExerciseId: subTemplate.exerciseId,
              name: subTemplate.exerciseName,
              type: ExerciseType.single, // Sub-exercises are singles
              category: subTemplate.category,
              sets: subTemplate.sets.map((s) => s.toExerciseSet()).toList(),
              notes: subTemplate.notes,
              restTime: subTemplate.restTime,
              tut: subTemplate.tut, // ⌚ Time Under Tension
              countingMode:
                  subTemplate.countingMode ?? ExerciseCountingMode.weighted,
            ),
          )
          .toList();

      // Create SupersetSets with shared data for all exercises
      final supersetSets = <SupersetSet>[];

      for (int setIndex = 0; setIndex < sets.length; setIndex++) {
        final setTemplate = sets[setIndex];
        final exerciseData = <String, SupersetExerciseData>{};

        // Create data for each exercise in this superset set
        for (final exercise in exercises) {
          // ✅ FIX: Use exercise.id as key (not name) - SupersetCard looks up by ID
          exerciseData[exercise.id] = SupersetExerciseData(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            targetWeight: setTemplate.targetWeight,
            targetReps: setTemplate.targetReps,
            targetMinReps: setTemplate.targetMinReps,
            targetMaxReps: setTemplate.targetMaxReps,
            actualWeight: null,
            actualReps: null,
            rpe: null,
            isCompleted: false,
          );
        }

        // ✅ FIX: Aggiungi timestamp per ID univoco
        supersetSets.add(
          SupersetSet(
            id: 'superset_set_${DateTime.now().millisecondsSinceEpoch}_$setIndex',
            setNumber: setIndex + 1,
            exerciseData: exerciseData,
            isCompleted: false,
          ),
        );
      }

      return SupersetExercise(
        name: exerciseName,
        databaseExerciseId: null,
        exercises: exercises,
        supersetSets: supersetSets,
        notes: notes,
        restTime: restTime,
        tut: tut, // ⌚ Time Under Tension
      );
    }

    // ✅ FIX: Handle DropSetExercise - convert SetTemplates back to DropSetStages
    if (type == ExerciseType.dropset) {
      final stages = sets.map((setTemplate) {
        return DropSetStage(
          weight: setTemplate.targetWeight ?? 0,
          reps: setTemplate.targetReps ?? 8,
          minReps: setTemplate.targetMinReps,
          maxReps: setTemplate.targetMaxReps,
          isCompleted: false,
        );
      }).toList();

      return DropSetExercise(
        databaseExerciseId: exerciseId,
        name: exerciseName,
        category: category,
        stages: stages,
        notes: notes,
        restTime: restTime,
      );
    }

    // ✅ FIX: Handle RestPauseExercise - convert SetTemplates back to RestPauseSets
    if (type == ExerciseType.restPause) {
      // Get weight from first set (all sets share same weight in rest-pause)
      final weight = sets.isNotEmpty ? (sets.first.targetWeight ?? 0) : 0.0;
      final targetReps = sets.isNotEmpty ? (sets.first.targetReps ?? 8) : 8;

      final restPauseSets = sets.map((setTemplate) {
        return RestPauseSet(
          reps: setTemplate.targetReps ?? 0,
          restSeconds:
              setTemplate.restSeconds ?? 15, // Use saved value or default 15s
          minReps: setTemplate.targetMinReps,
          maxReps: setTemplate.targetMaxReps,
          isCompleted: false,
        );
      }).toList();

      // Preserve range from first set for the exercise-level target
      final targetMinReps = sets.isNotEmpty ? sets.first.targetMinReps : null;
      final targetMaxReps = sets.isNotEmpty ? sets.first.targetMaxReps : null;

      return RestPauseExercise(
        databaseExerciseId: exerciseId,
        name: exerciseName,
        category: category,
        weight: weight,
        targetReps: targetReps,
        targetMinReps: targetMinReps,
        targetMaxReps: targetMaxReps,
        restPauseSets: restPauseSets,
        notes: notes,
        restTime: restTime,
      );
    }

    // For normal exercises or superset without sub-exercises
    final exercise = Exercise(
      databaseExerciseId: exerciseId,
      name: exerciseName,
      type: type,
      category: category,
      sets: sets.map((setTemplate) => setTemplate.toExerciseSet()).toList(),
      notes: notes,
      restTime: restTime,
      tut: tut, // ⌚ Time Under Tension
      countingMode: countingMode ?? ExerciseCountingMode.weighted,
    );

    return exercise;
  }
}

/// Template per set all'interno di un esercizio template
class SetTemplate {
  const SetTemplate({
    required this.setNumber,
    this.targetWeight,
    this.targetReps,
    this.targetMinReps,
    this.targetMaxReps,
    this.targetRpe,
    this.targetSeconds,
    this.restSeconds,
    this.notes,
  });

  factory SetTemplate.fromJson(Map<String, dynamic> json) {
    // Enhanced validation for SetTemplate deserialization
    // FIX: Support both old format ('weight', 'reps', 'rpe') and new format ('targetWeight', 'targetReps', 'targetRpe')
    // for backward compatibility with templates saved via Cloud Function
    final setNumber = json['setNumber'] is int
        ? json['setNumber']
        : (json['setNumber'] is String
              ? int.tryParse(json['setNumber']) ?? 1
              : 1);

    // Fallback: targetWeight ?? weight
    final weightRaw = json['targetWeight'] ?? json['weight'];
    final targetWeight = weightRaw != null
        ? (weightRaw is num
              ? weightRaw.toDouble()
              : double.tryParse(weightRaw.toString()))
        : null;

    // Fallback: targetReps ?? reps
    final repsRaw = json['targetReps'] ?? json['reps'];
    final targetReps = repsRaw is int
        ? repsRaw
        : (repsRaw is String ? int.tryParse(repsRaw) : null);

    // Fallback: targetRpe ?? rpe
    final rpeRaw = json['targetRpe'] ?? json['rpe'];
    final targetRpe = rpeRaw is int
        ? rpeRaw
        : (rpeRaw is String ? int.tryParse(rpeRaw) : null);

    // Parse targetSeconds for time-based exercises
    final targetSecondsRaw = json['targetSeconds'] ?? json['seconds'];
    final targetSeconds = targetSecondsRaw is int
        ? targetSecondsRaw
        : (targetSecondsRaw is String ? int.tryParse(targetSecondsRaw) : null);

    // Parse restSeconds for RestPause sets
    final restSecondsRaw = json['restSeconds'];
    final restSeconds = restSecondsRaw is int
        ? restSecondsRaw
        : (restSecondsRaw is String ? int.tryParse(restSecondsRaw) : null);

    // Parse targetMinReps / targetMaxReps with fallback
    final minRepsRaw = json['targetMinReps'] ?? json['minReps'];
    final targetMinReps = minRepsRaw is int
        ? minRepsRaw
        : (minRepsRaw is String ? int.tryParse(minRepsRaw) : null);

    final maxRepsRaw = json['targetMaxReps'] ?? json['maxReps'];
    final targetMaxReps = maxRepsRaw is int
        ? maxRepsRaw
        : (maxRepsRaw is String ? int.tryParse(maxRepsRaw) : null);

    return SetTemplate(
      setNumber: setNumber,
      targetWeight: targetWeight,
      targetReps: targetReps,
      targetMinReps: targetMinReps,
      targetMaxReps: targetMaxReps,
      targetRpe: targetRpe,
      targetSeconds: targetSeconds,
      restSeconds: restSeconds,
      notes: json['notes']?.toString(),
    );
  }
  final int setNumber;
  final double? targetWeight;
  final int? targetReps;
  final int? targetMinReps;
  final int? targetMaxReps;
  final int? targetRpe; // Rate of Perceived Exertion
  final int? targetSeconds; // For time-based exercises (duration in seconds)
  final int? restSeconds; // For RestPause sets (seconds between mini-sets)
  final String? notes;

  /// True se ha un range di ripetizioni target
  bool get hasRepRange =>
      targetMinReps != null &&
      targetMaxReps != null &&
      targetMinReps != targetMaxReps;

  /// Display string per le reps target: "8-12" per range, "10" per singolo
  String get repsDisplay {
    if (hasRepRange) return '$targetMinReps-$targetMaxReps';
    return '${targetReps ?? targetMinReps ?? targetMaxReps ?? "-"}';
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'targetWeight': targetWeight,
      'targetReps': targetReps,
      if (targetMinReps != null) 'targetMinReps': targetMinReps,
      if (targetMaxReps != null) 'targetMaxReps': targetMaxReps,
      'targetRpe': targetRpe,
      if (targetSeconds != null) 'targetSeconds': targetSeconds,
      if (restSeconds != null) 'restSeconds': restSeconds,
      'notes': notes,
    };
  }

  /// Converte il template in un set per l'esercizio
  ExerciseSet toExerciseSet() {
    return ExerciseSet(
      setNumber: setNumber,
      weight: targetWeight,
      reps: targetReps,
      minReps: targetMinReps,
      maxReps: targetMaxReps,
      seconds: targetSeconds,
      notes: notes,
    );
  }
}
