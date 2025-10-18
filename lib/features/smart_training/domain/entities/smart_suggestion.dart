import 'package:uuid/uuid.dart';

/// Smart suggestion for training optimization
class SmartSuggestion {

  SmartSuggestion({
    String? id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.reasoning,
    required this.category,
    required this.parameters,
    required this.actions,
    required this.confidence,
    this.isPersonalized = true,
    DateTime? createdAt,
    this.expiresAt,
    this.isDismissed = false,
    this.dismissedAt,
    this.isApplied = false,
    this.appliedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();

  factory SmartSuggestion.fromJson(Map<String, dynamic> json) {
    return SmartSuggestion(
      id: json['id'],
      type: SuggestionType.values.firstWhere((t) => t.name == json['type']),
      priority: SuggestionPriority.values.firstWhere((p) => p.name == json['priority']),
      title: json['title'],
      description: json['description'],
      reasoning: json['reasoning'],
      category: SuggestionCategory.values.firstWhere((c) => c.name == json['category']),
      parameters: Map<String, dynamic>.from(json['parameters']),
      actions: (json['actions'] as List)
          .map((a) => SuggestionAction.fromJson(a))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      isPersonalized: json['isPersonalized'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      isDismissed: json['isDismissed'] ?? false,
      dismissedAt: json['dismissedAt'] != null ? DateTime.parse(json['dismissedAt']) : null,
      isApplied: json['isApplied'] ?? false,
      appliedAt: json['appliedAt'] != null ? DateTime.parse(json['appliedAt']) : null,
    );
  }
  final String id;
  final SuggestionType type;
  final SuggestionPriority priority;
  final String title;
  final String description;
  final String reasoning;
  final SuggestionCategory category;
  final Map<String, dynamic> parameters;
  final List<SuggestionAction> actions;
  final double confidence; // 0-1 scale
  final bool isPersonalized;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isDismissed;
  final DateTime? dismissedAt;
  final bool isApplied;
  final DateTime? appliedAt;

  SmartSuggestion copyWith({
    SuggestionType? type,
    SuggestionPriority? priority,
    String? title,
    String? description,
    String? reasoning,
    SuggestionCategory? category,
    Map<String, dynamic>? parameters,
    List<SuggestionAction>? actions,
    double? confidence,
    bool? isPersonalized,
    DateTime? expiresAt,
    bool? isDismissed,
    DateTime? dismissedAt,
    bool? isApplied,
    DateTime? appliedAt,
  }) {
    return SmartSuggestion(
      id: id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      reasoning: reasoning ?? this.reasoning,
      category: category ?? this.category,
      parameters: parameters ?? this.parameters,
      actions: actions ?? this.actions,
      confidence: confidence ?? this.confidence,
      isPersonalized: isPersonalized ?? this.isPersonalized,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isDismissed: isDismissed ?? this.isDismissed,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      isApplied: isApplied ?? this.isApplied,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }

  bool get isValid => 
    !isDismissed && 
    !isApplied && 
    (expiresAt == null || DateTime.now().isBefore(expiresAt!));

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'reasoning': reasoning,
      'category': category.name,
      'parameters': parameters,
      'actions': actions.map((a) => a.toJson()).toList(),
      'confidence': confidence,
      'isPersonalized': isPersonalized,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isDismissed': isDismissed,
      'dismissedAt': dismissedAt?.toIso8601String(),
      'isApplied': isApplied,
      'appliedAt': appliedAt?.toIso8601String(),
    };
  }
}

/// Action that can be taken from a suggestion
class SuggestionAction {

  SuggestionAction({
    String? id,
    required this.label,
    required this.description,
    required this.type,
    required this.payload,
    this.isPrimary = false,
  }) : id = id ?? const Uuid().v4();

  factory SuggestionAction.fromJson(Map<String, dynamic> json) {
    return SuggestionAction(
      id: json['id'],
      label: json['label'],
      description: json['description'],
      type: SuggestionActionType.values.firstWhere((t) => t.name == json['type']),
      payload: Map<String, dynamic>.from(json['payload']),
      isPrimary: json['isPrimary'] ?? false,
    );
  }
  final String id;
  final String label;
  final String description;
  final SuggestionActionType type;
  final Map<String, dynamic> payload;
  final bool isPrimary;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'description': description,
      'type': type.name,
      'payload': payload,
      'isPrimary': isPrimary,
    };
  }
}

/// Suggestion context for real-time recommendations
class SuggestionContext {

  SuggestionContext({
    required this.userId,
    required this.currentTime,
    this.currentWorkoutId,
    this.currentExerciseId,
    this.currentSetNumber,
    required this.sessionData,
    required this.userPreferences,
    required this.historicalData,
  });

  factory SuggestionContext.fromJson(Map<String, dynamic> json) {
    return SuggestionContext(
      userId: json['userId'],
      currentTime: DateTime.parse(json['currentTime']),
      currentWorkoutId: json['currentWorkoutId'],
      currentExerciseId: json['currentExerciseId'],
      currentSetNumber: json['currentSetNumber'],
      sessionData: Map<String, dynamic>.from(json['sessionData']),
      userPreferences: Map<String, dynamic>.from(json['userPreferences']),
      historicalData: Map<String, dynamic>.from(json['historicalData']),
    );
  }
  final String userId;
  final DateTime currentTime;
  final String? currentWorkoutId;
  final String? currentExerciseId;
  final int? currentSetNumber;
  final Map<String, dynamic> sessionData;
  final Map<String, dynamic> userPreferences;
  final Map<String, dynamic> historicalData;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentTime': currentTime.toIso8601String(),
      'currentWorkoutId': currentWorkoutId,
      'currentExerciseId': currentExerciseId,
      'currentSetNumber': currentSetNumber,
      'sessionData': sessionData,
      'userPreferences': userPreferences,
      'historicalData': historicalData,
    };
  }
}

/// Enums for suggestion system
enum SuggestionType {
  weightIncrease,
  volumeAdjustment,
  restTimeOptimization,
  exerciseSubstitution,
  formCorrection,
  deloadRecommendation,
  plateauBreaker,
  recoveryAdvice,
  nutritionTip,
  progressCelebration,
  workoutRecommendation,
  templateSuggestion,
}

enum SuggestionPriority {
  low,
  medium,
  high,
  critical,
}

enum SuggestionCategory {
  performance,
  safety,
  progression,
  recovery,
  motivation,
  education,
}

enum SuggestionActionType {
  applyChange,
  viewDetails,
  learnMore,
  dismiss,
  remindLater,
  customizeWorkout,
  startTemplate,
  adjustSettings,
}