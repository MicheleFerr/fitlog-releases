import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/current_user_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/datasources/fitness_profile_local_datasource.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/datasources/questionnaire_analytics_datasource.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/datasources/strength_standards_local_datasource.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/repositories/strength_standards_repository_impl.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/exercise_mapping.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/medical_clearance_questionnaire.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/questionnaire_analytics.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/services/weight_suggestion_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ============================================================================
// PROVIDERS - DATA LAYER
// ============================================================================

/// Local datasource provider
final strengthStandardsLocalDataSourceProvider =
    Provider<StrengthStandardsLocalDataSource>((ref) {
  return StrengthStandardsLocalDataSource();
});

/// Fitness profile local datasource provider
final fitnessProfileLocalDataSourceProvider =
    Provider<FitnessProfileLocalDataSource>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return FitnessProfileLocalDataSource(boxManager);
});

/// Questionnaire analytics datasource provider
final questionnaireAnalyticsDataSourceProvider =
    Provider<QuestionnaireAnalyticsDataSource>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return QuestionnaireAnalyticsDataSource(boxManager);
});

/// Repository provider
final strengthStandardsRepositoryProvider =
    Provider<StrengthStandardsRepository>((ref) {
  final localDataSource = ref.watch(strengthStandardsLocalDataSourceProvider);
  return StrengthStandardsRepositoryImpl(localDataSource);
});

// ============================================================================
// PROVIDERS - SERVICES
// ============================================================================

/// Weight suggestion service provider
final weightSuggestionServiceProvider = Provider<WeightSuggestionService>((ref) {
  return WeightSuggestionService();
});

// ============================================================================
// PROVIDERS - DATA ACCESS
// ============================================================================

/// Strength standards list (async loaded, cached)
final strengthStandardsProvider =
    FutureProvider<List<StrengthStandard>>((ref) async {
  final repository = ref.watch(strengthStandardsRepositoryProvider);
  return repository.getStrengthStandards();
});

/// Exercise mappings list (async loaded, cached)
final exerciseMappingsProvider =
    FutureProvider<List<ExerciseMapping>>((ref) async {
  final repository = ref.watch(strengthStandardsRepositoryProvider);
  return repository.getExerciseMappings();
});

/// Get strength standard by ID
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final strengthStandardByIdProvider =
    FutureProvider.autoDispose.family<StrengthStandard?, String>((ref, id) async {
  final repository = ref.watch(strengthStandardsRepositoryProvider);
  return repository.getStrengthStandardById(id);
});

/// Get exercise mapping by exercise ID
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseMappingByIdProvider =
    FutureProvider.autoDispose.family<ExerciseMapping?, String>((ref, exerciseId) async {
  final repository = ref.watch(strengthStandardsRepositoryProvider);
  return repository.getMappingForExercise(exerciseId);
});

/// Get high confidence mappings (≥80%)
final highConfidenceMappingsProvider =
    FutureProvider<List<ExerciseMapping>>((ref) async {
  final repository = ref.watch(strengthStandardsRepositoryProvider);
  return repository.getHighConfidenceMappings();
});

/// Get mappings by status
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final mappingsByStatusProvider = FutureProvider.autoDispose.family<List<ExerciseMapping>,
    MappingStatus>((ref, status) async {
  final repository = ref.watch(strengthStandardsRepositoryProvider);
  return repository.getMappingsByStatus(status);
});

/// Get metadata about data sources
final strengthStandardsMetadataProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(strengthStandardsRepositoryProvider);
  return repository.getMetadata();
});

// ============================================================================
// PROVIDERS - USER FITNESS QUESTIONNAIRE
// ============================================================================

/// User fitness questionnaire state notifier
final userFitnessQuestionnaireProvider = StateNotifierProvider<
    UserFitnessQuestionnaireNotifier, UserFitnessQuestionnaire?>((ref) {
  return UserFitnessQuestionnaireNotifier(ref);
});

/// Notifier for managing user fitness questionnaire state
class UserFitnessQuestionnaireNotifier
    extends StateNotifier<UserFitnessQuestionnaire?> {

  UserFitnessQuestionnaireNotifier(this._ref) : super(null);
  final Ref _ref;

  /// Update questionnaire data
  void updateQuestionnaire(UserFitnessQuestionnaire questionnaire) {
    state = questionnaire;
  }

  /// Update specific fields (partial update)
  void updateFields({
    double? bodyweightKg,
    int? age,
    BiologicalSex? sex,
    ExperienceLevel? experienceLevel,
    int? monthsOfTraining,
    double? benchPressMax,
    double? squatMax,
    double? deadliftMax,
    double? overheadPressMax,
    TrainingGoal? trainingGoal,
    bool? hasInjuryHistory,
    InjuryDetails? injuryDetails,
    int? currentPainLevel,
    SuggestionStyle? suggestionStyle,
    SelfReportCalibration? selfReportCalibration,
  }) {
    if (state == null) return;

    state = state!.copyWith(
      bodyweightKg: bodyweightKg ?? state!.bodyweightKg,
      age: age ?? state!.age,
      sex: sex ?? state!.sex,
      experienceLevel: experienceLevel ?? state!.experienceLevel,
      monthsOfTraining: monthsOfTraining,
      benchPressMax: benchPressMax,
      squatMax: squatMax,
      deadliftMax: deadliftMax,
      overheadPressMax: overheadPressMax,
      trainingGoal: trainingGoal ?? state!.trainingGoal,
      hasInjuryHistory: hasInjuryHistory ?? state!.hasInjuryHistory,
      injuryDetails: injuryDetails,
      currentPainLevel: currentPainLevel ?? state!.currentPainLevel,
      suggestionStyle: suggestionStyle ?? state!.suggestionStyle,
      selfReportCalibration: selfReportCalibration ?? state!.selfReportCalibration,
    );
  }

  /// Complete the questionnaire (set timestamp)
  void completeQuestionnaire() {
    if (state == null) return;
    state = state!.copyWith(completedAt: DateTime.now());
  }

  /// Clear questionnaire data
  void clearQuestionnaire() {
    state = null;
  }

  /// Load questionnaire from Hive persistence
  Future<void> loadQuestionnaire() async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return;

    final datasource = _ref.read(fitnessProfileLocalDataSourceProvider);
    final questionnaire = await datasource.getFitnessQuestionnaire(userId);

    if (questionnaire != null) {
      state = questionnaire;
    }
  }

  /// Save questionnaire to Hive persistence
  Future<void> saveQuestionnaire() async {
    if (state == null) return;

    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return;

    final datasource = _ref.read(fitnessProfileLocalDataSourceProvider);
    await datasource.saveFitnessQuestionnaire(state!, userId);
  }
}

/// Medical clearance questionnaire state notifier
final medicalClearanceQuestionnaireProvider = StateNotifierProvider<
    MedicalClearanceQuestionnaireNotifier, MedicalClearanceQuestionnaire?>((ref) {
  return MedicalClearanceQuestionnaireNotifier(ref);
});

/// Notifier for managing medical clearance questionnaire state
class MedicalClearanceQuestionnaireNotifier
    extends StateNotifier<MedicalClearanceQuestionnaire?> {

  MedicalClearanceQuestionnaireNotifier(this._ref) : super(null);
  final Ref _ref;

  /// Update medical clearance data
  void updateClearance(MedicalClearanceQuestionnaire clearance) {
    state = clearance;
  }

  /// Complete the medical clearance (set timestamp)
  void completeClearance() {
    if (state == null) return;
    state = state!.copyWith(
      completedAt: DateTime.now(),
      userAcknowledgedRisks: true,
    );
  }

  /// Clear medical clearance data
  void clearClearance() {
    state = null;
  }

  /// Load medical clearance from Hive persistence
  Future<void> loadClearance() async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return;

    final datasource = _ref.read(fitnessProfileLocalDataSourceProvider);
    final clearance = await datasource.getMedicalClearance(userId);

    if (clearance != null) {
      state = clearance;
    }
  }

  /// Save medical clearance to Hive persistence
  Future<void> saveClearance() async {
    if (state == null) return;

    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return;

    final datasource = _ref.read(fitnessProfileLocalDataSourceProvider);
    await datasource.saveMedicalClearance(state!, userId);
  }
}

// ============================================================================
// PROVIDERS - WEIGHT SUGGESTIONS
// ============================================================================

/// Get weight suggestion for a specific exercise
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final weightSuggestionProvider = FutureProvider.autoDispose.family<WeightSuggestion?,
    String>((ref, exerciseId) async {
  // Get dependencies
  final service = ref.watch(weightSuggestionServiceProvider);
  final questionnaire = ref.watch(userFitnessQuestionnaireProvider);
  final repository = ref.watch(strengthStandardsRepositoryProvider);

  // Validate questionnaire exists
  if (questionnaire == null || !questionnaire.isValid) {
    return null;
  }

  // Get mapping for exercise
  final mapping = await repository.getMappingForExercise(exerciseId);
  if (mapping == null) {
    return null;
  }

  // Get strength standard if mapping is reliable
  StrengthStandard? standard;
  if (mapping.canSuggestWeight && mapping.standardId != null) {
    standard = await repository.getStrengthStandardById(mapping.standardId!);
  }

  // Calculate suggestion
  return service.getSuggestedWeight(
    exerciseId: exerciseId,
    questionnaire: questionnaire,
    mapping: mapping,
    standard: standard,
  );
});

/// Get weight suggestions for multiple exercises (batch)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final batchWeightSuggestionsProvider = FutureProvider.autoDispose.family<
    Map<String, WeightSuggestion?>, List<String>>((ref, exerciseIds) async {
  final suggestions = <String, WeightSuggestion?>{};

  for (final exerciseId in exerciseIds) {
    final suggestion =
        await ref.watch(weightSuggestionProvider(exerciseId).future);
    suggestions[exerciseId] = suggestion;
  }

  return suggestions;
});

/// Whether weight suggestions feature is enabled
final weightSuggestionsEnabledProvider = StateProvider<bool>((ref) {
  // Check if questionnaire is complete
  final questionnaire = ref.watch(userFitnessQuestionnaireProvider);
  return questionnaire != null && questionnaire.isValid;
});

/// Whether to show weight suggestion prompts
final showWeightSuggestionPromptsProvider = StateProvider<bool>((ref) {
  return true; // Can be toggled in settings
});

// ============================================================================
// PROVIDERS - FITNESS PROFILE AUTO-LOAD
// ============================================================================

/// Auto-load fitness profile when user is authenticated
final fitnessProfileAutoLoadProvider = FutureProvider<void>((ref) async {
  final userId = ref.watch(currentUserIdProvider);

  if (userId != null) {
    // Load questionnaire from Hive
    final notifier = ref.read(userFitnessQuestionnaireProvider.notifier);
    await notifier.loadQuestionnaire();

    // Load medical clearance
    final clearanceNotifier = ref.read(medicalClearanceQuestionnaireProvider.notifier);
    await clearanceNotifier.loadClearance();
  }
});

// ============================================================================
// PROVIDERS - STATISTICS & ANALYTICS
// ============================================================================

/// Get statistics about exercise mappings coverage
final mappingStatisticsProvider =
    FutureProvider<MappingStatistics>((ref) async {
  final mappings = await ref.watch(exerciseMappingsProvider.future);

  final autoCount = mappings.where((m) => m.status == MappingStatus.auto).length;
  final reviewCount =
      mappings.where((m) => m.status == MappingStatus.review).length;
  final fallbackCount =
      mappings.where((m) => m.status == MappingStatus.fallback).length;

  final avgConfidence = mappings.isNotEmpty
      ? mappings.map((m) => m.confidence).reduce((a, b) => a + b) /
          mappings.length
      : 0.0;

  return MappingStatistics(
    totalMappings: mappings.length,
    autoMappings: autoCount,
    reviewMappings: reviewCount,
    fallbackMappings: fallbackCount,
    averageConfidence: avgConfidence,
  );
});

/// Statistics about exercise mappings
class MappingStatistics {

  const MappingStatistics({
    required this.totalMappings,
    required this.autoMappings,
    required this.reviewMappings,
    required this.fallbackMappings,
    required this.averageConfidence,
  });
  final int totalMappings;
  final int autoMappings;
  final int reviewMappings;
  final int fallbackMappings;
  final double averageConfidence;

  double get autoPercentage => autoMappings / totalMappings * 100;
  double get reviewPercentage => reviewMappings / totalMappings * 100;
  double get fallbackPercentage => fallbackMappings / totalMappings * 100;
  double get reliablePercentage =>
      (autoMappings + reviewMappings) / totalMappings * 100;
}

// ============================================================================
// PROVIDERS - QUESTIONNAIRE ANALYTICS
// ============================================================================

/// Current questionnaire analytics session provider
final currentQuestionnaireAnalyticsProvider = StateNotifierProvider<
    QuestionnaireAnalyticsNotifier, QuestionnaireAnalytics?>((ref) {
  return QuestionnaireAnalyticsNotifier(ref);
});

/// Notifier for managing questionnaire analytics during completion
class QuestionnaireAnalyticsNotifier
    extends StateNotifier<QuestionnaireAnalytics?> {
  QuestionnaireAnalyticsNotifier(this._ref) : super(null);
  final Ref _ref;

  DateTime? _stepStartTime;

  /// Start new analytics session
  Future<void> startSession() async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return;

    // Get platform and app version
    final packageInfo = await PackageInfo.fromPlatform();
    final platform = Platform.isIOS ? 'iOS' : 'Android';

    state = QuestionnaireAnalytics(
      userId: userId,
      startedAt: DateTime.now(),
      platform: platform,
      appVersion: packageInfo.version,
    );

    _stepStartTime = DateTime.now();

    if (kDebugMode) {
      debugPrint('📊 Started questionnaire analytics session for user: $userId');
    }
  }

  /// Track step completion
  void trackStepComplete(int step) {
    if (state == null) return;

    final now = DateTime.now();
    final duration = _stepStartTime != null
        ? now.difference(_stepStartTime!).inSeconds
        : 0;

    state = state!.copyWith(
      lastStepReached: step,
      stepDurations: {
        ...state!.stepDurations,
        step: duration,
      },
    );

    _stepStartTime = now; // Reset for next step

    if (kDebugMode) {
      debugPrint('📊 Step $step completed in ${duration}s');
    }
  }

  /// Track step feedback (1-5 rating)
  void trackStepFeedback(int step, int rating) {
    if (state == null) return;

    state = state!.copyWith(
      stepFeedback: {
        ...state!.stepFeedback,
        step: rating,
      },
    );

    if (kDebugMode) {
      debugPrint('📊 Step $step feedback: $rating/5');
    }
  }

  /// Track completion
  Future<void> trackCompletion() async {
    if (state == null) return;

    final totalDuration = DateTime.now().difference(state!.startedAt).inSeconds;

    state = state!.copyWith(
      completedAt: DateTime.now(),
      wasAbandoned: false,
      totalDurationSeconds: totalDuration,
    );

    // Save to Hive
    await _saveAnalytics();

    if (kDebugMode) {
      debugPrint('📊 Questionnaire completed in ${totalDuration}s');
      debugPrint('📊 Completion rate: ${state!.completionRate * 100}%');
    }
  }

  /// Track abandonment
  Future<void> trackAbandon(int lastStep) async {
    if (state == null) return;

    final totalDuration = DateTime.now().difference(state!.startedAt).inSeconds;

    state = state!.copyWith(
      lastStepReached: lastStep,
      wasAbandoned: true,
      totalDurationSeconds: totalDuration,
    );

    // Save to Hive
    await _saveAnalytics();

    if (kDebugMode) {
      debugPrint('📊 Questionnaire abandoned at step $lastStep');
      debugPrint('📊 Drop-off at step: ${state!.dropOffStep}');
    }
  }

  /// Save analytics to Hive
  Future<void> _saveAnalytics() async {
    if (state == null) return;

    final datasource = _ref.read(questionnaireAnalyticsDataSourceProvider);
    await datasource.saveQuestionnaireAnalytics(state!);
  }

  /// Clear current session
  void clearSession() {
    state = null;
    _stepStartTime = null;
  }
}

/// Get aggregated analytics (admin/debug view)
final aggregatedQuestionnaireAnalyticsProvider =
    FutureProvider<QuestionnaireAnalyticsAggregated>((ref) async {
  final datasource = ref.watch(questionnaireAnalyticsDataSourceProvider);
  return datasource.getAggregatedAnalytics();
});

/// Get latest analytics for current user
final latestQuestionnaireAnalyticsProvider =
    FutureProvider<QuestionnaireAnalytics?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final datasource = ref.watch(questionnaireAnalyticsDataSourceProvider);
  return datasource.getLatestAnalytics(userId);
});
