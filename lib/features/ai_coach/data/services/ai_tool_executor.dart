/// AI Tool Executor - Thin Dispatcher
///
/// Dispatches AI function calls to specialized executor classes.
/// Each executor handles a logical group of tools.
///
/// **Layer**: Data - Service
/// **Feature**: AI Coach
library;

import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/workout_analytics_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/repositories/health_repository.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/healthkit_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/document_repository.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';
import 'package:flutter/widgets.dart' show Locale;

import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/analytics_tool_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/body_measurement_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/coaching_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/recovery_stats_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/search_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/stats_profile_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/template_exercise_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/template_generation_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/template_query_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/template_setup_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/workout_suggestion_executor.dart';

/// Thin dispatcher: routes tool calls to specialized executors.
class AIToolExecutor {
  AIToolExecutor({
    required this.analyticsRepo,
    required this.historyRepo,
    required this.workoutAnalyticsRepo,
    required this.streakRepo,
    this.measurementRepo,
    this.templateRepo,
    this.locale,
    this.historyDaysLimit,
    this.healthRepo,
    this.documentRepository,
    this.healthKitDatasource,
    this.onboardingState,
    this.accountTier = 'free',
    this.getWorkoutPreferences,
    this.updateWorkoutPreferences,
    ExerciseSearchService? exerciseSearchService,
  }) : exerciseSearchService =
           exerciseSearchService ?? ExerciseSearchService() {
    _analytics = AnalyticsToolExecutor(
      analyticsRepo: analyticsRepo,
      historyDaysLimit: historyDaysLimit,
    );

    _recovery = RecoveryStatsExecutor(
      historyRepo: historyRepo,
      healthRepo: healthRepo,
      healthKitDatasource: healthKitDatasource,
    );

    _workoutSuggestion = WorkoutSuggestionExecutor(
      analyticsExecutor: _analytics,
      recoveryExecutor: _recovery,
      exerciseSearchService: this.exerciseSearchService,
      locale: locale,
    );

    _statsProfile = StatsProfileExecutor(
      analyticsRepo: analyticsRepo,
      workoutAnalyticsRepo: workoutAnalyticsRepo,
      streakRepo: streakRepo,
      historyRepo: historyRepo,
      measurementRepo: measurementRepo,
      onboardingState: onboardingState,
      accountTier: accountTier,
      getWorkoutPreferences: getWorkoutPreferences,
      updateWorkoutPreferences: updateWorkoutPreferences,
      historyDaysLimit: historyDaysLimit,
    );

    _coaching = CoachingExecutor(
      historyRepo: historyRepo,
      workoutAnalyticsRepo: workoutAnalyticsRepo,
      analyticsRepo: analyticsRepo,
      onboardingState: onboardingState,
    );

    _templateGeneration = TemplateGenerationExecutor(
      exerciseSearchService: this.exerciseSearchService,
      locale: locale,
    );

    if (measurementRepo != null) {
      _bodyMeasurement = BodyMeasurementExecutor(
        measurementRepo: measurementRepo!,
      );
    }

    if (templateRepo != null) {
      _templateQuery = TemplateQueryExecutor(
        templateRepo: templateRepo!,
        exerciseSearchService: this.exerciseSearchService,
        locale: locale,
      );
      _templateExercise = TemplateExerciseExecutor(
        templateRepo: templateRepo!,
        exerciseSearchService: this.exerciseSearchService,
        locale: locale,
      );
      _templateSetup = TemplateSetupExecutor(
        templateRepo: templateRepo!,
        exerciseSearchService: this.exerciseSearchService,
        locale: locale,
      );
    }

    _search = SearchExecutor(
      exerciseSearchService: this.exerciseSearchService,
      documentRepository: documentRepository,
      locale: locale,
    );
  }

  // ── Dependencies (kept for external callers that read these fields) ──
  final AnalyticsRepository analyticsRepo;
  final WorkoutHistoryRepositoryEnhanced historyRepo;
  final WorkoutAnalyticsRepository workoutAnalyticsRepo;
  final StreakRepository streakRepo;
  final MeasurementRepository? measurementRepo;
  final TemplateRepository? templateRepo;
  final ExerciseSearchService exerciseSearchService;
  final IHealthRepository? healthRepo;
  final DocumentRepository? documentRepository;
  final HealthKitDatasource? healthKitDatasource;
  final OnboardingState? onboardingState;
  final String accountTier;
  final Future<Map<String, dynamic>> Function()? getWorkoutPreferences;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> updates)?
  updateWorkoutPreferences;

  /// User's locale for localized exercise names
  final Locale? locale;

  /// Max history days for free users (null = unlimited/premium)
  final int? historyDaysLimit;

  // ── Executor instances ──
  late final AnalyticsToolExecutor _analytics;
  late final RecoveryStatsExecutor _recovery;
  late final WorkoutSuggestionExecutor _workoutSuggestion;
  late final StatsProfileExecutor _statsProfile;
  late final CoachingExecutor _coaching;
  late final TemplateGenerationExecutor _templateGeneration;
  BodyMeasurementExecutor? _bodyMeasurement;
  TemplateQueryExecutor? _templateQuery;
  TemplateExerciseExecutor? _templateExercise;
  TemplateSetupExecutor? _templateSetup;
  late final SearchExecutor _search;

  /// Execute a tool by name with given arguments.
  ///
  /// Returns a JSON-encoded string result.
  Future<String> executeTool({
    required String toolName,
    required Map<String, dynamic> arguments,
    required String userId,
  }) async {
    switch (toolName) {
      // ── Analytics (1RM, volume, muscle balance) ──
      case 'get1RMHistory':
        return _analytics.get1RMHistory(arguments, userId);
      case 'getWeeklyVolume':
        return _analytics.getWeeklyVolume(arguments, userId);
      case 'analyzeMuscleBalance':
        return _analytics.analyzeMuscleBalance(arguments, userId);

      // ── Recovery ──
      case 'getRecoveryData':
        return _recovery.getRecoveryData(arguments, userId);

      // ── Workout suggestion & standards ──
      case 'suggestWorkout':
        return _workoutSuggestion.suggestWorkout(arguments, userId);
      case 'compareToStandards':
        return _workoutSuggestion.compareToStandards(arguments, userId);

      // ── Stats & Profile ──
      case 'getWorkoutStats':
        return _statsProfile.getWorkoutStats(arguments, userId);
      case 'getPersonalRecords':
        return _statsProfile.getPersonalRecords(arguments, userId);
      case 'getStreak':
        return _statsProfile.getStreak(arguments, userId);
      case 'getWorkoutHistory':
        return _statsProfile.getWorkoutHistory(arguments, userId);
      case 'getUserProfileContext':
        return _statsProfile.getUserProfileContext(arguments, userId);
      case 'updateUserProfilePreferences':
        return _statsProfile.updateUserProfilePreferences(arguments, userId);
      case 'getWorkoutPreferences':
        return _statsProfile.getWorkoutPreferencesResult(arguments, userId);
      case 'updateWorkoutPreferences':
        return _statsProfile.updateWorkoutPreferencesResult(arguments, userId);

      // ── Coaching ──
      case 'getWeeklyCheckin':
        return _coaching.getWeeklyCheckin(arguments, userId);
      case 'getAutoProgressionPlan':
        return _coaching.getAutoProgressionPlan(arguments, userId);
      case 'getAdherenceInsights':
        return _coaching.getAdherenceInsights(arguments, userId);

      // ── Template generation ──
      case 'generateTemplate':
        return _templateGeneration.generateTemplate(arguments, userId);

      // ── Body measurements ──
      case 'getBodyProgress':
        if (_bodyMeasurement == null) {
          return Future.value(
            '{"error":"measurementRepo not available","toolName":"getBodyProgress"}',
          );
        }
        return _bodyMeasurement!.getBodyProgress(arguments, userId);
      case 'addBodyMeasurement':
        if (_bodyMeasurement == null) {
          return Future.value(
            '{"error":"measurementRepo not available","toolName":"addBodyMeasurement"}',
          );
        }
        return _bodyMeasurement!.addBodyMeasurement(arguments, userId);

      // ── Template CRUD ──
      case 'getUserTemplates':
        if (_templateQuery == null) {
          return Future.value(
            '{"error":"templateRepo not available","toolName":"getUserTemplates"}',
          );
        }
        return _templateQuery!.getUserTemplates(arguments, userId);
      case 'getTemplateDetails':
        if (_templateQuery == null) {
          return Future.value(
            '{"error":"templateRepo not available","toolName":"getTemplateDetails"}',
          );
        }
        return _templateQuery!.getTemplateDetails(arguments, userId);
      case 'addExerciseToTemplate':
        if (_templateExercise == null) {
          return Future.value(
            '{"error":"templateRepo not available","toolName":"addExerciseToTemplate"}',
          );
        }
        return _templateExercise!.addExerciseToTemplate(arguments, userId);
      case 'replaceExerciseInTemplate':
        if (_templateExercise == null) {
          return Future.value(
            '{"error":"templateRepo not available","toolName":"replaceExerciseInTemplate"}',
          );
        }
        return _templateExercise!.replaceExerciseInTemplate(arguments, userId);
      case 'removeExerciseFromTemplate':
        if (_templateExercise == null) {
          return Future.value(
            '{"error":"templateRepo not available","toolName":"removeExerciseFromTemplate"}',
          );
        }
        return _templateExercise!.removeExerciseFromTemplate(arguments, userId);
      case 'updateTemplateRestTime':
        if (_templateSetup == null) {
          return Future.value(
            '{"error":"templateRepo not available","toolName":"updateTemplateRestTime"}',
          );
        }
        return _templateSetup!.updateTemplateRestTime(arguments, userId);
      case 'updateTemplateExerciseSetup':
        if (_templateSetup == null) {
          return Future.value(
            '{"error":"templateRepo not available","toolName":"updateTemplateExerciseSetup"}',
          );
        }
        return _templateSetup!.updateTemplateExerciseSetup(arguments, userId);

      // ── Search ──
      case 'searchExercises':
        return _search.searchExercises(arguments, userId);
      case 'getAccessoryExercises':
        return _search.getAccessoryExercises(arguments, userId);
      case 'searchScientificSources':
        return _search.searchScientificSources(arguments, userId);

      default:
        throw Exception('Unknown tool: $toolName');
    }
  }

}
