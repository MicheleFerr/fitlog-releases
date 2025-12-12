/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/datasources
/// 🎯 Feature: ai_coach
/// 🔧 Type: chatbot_logic
///
/// ChatBot Datasource - Pattern-based chat bot (NO LLM, NO API)
///
/// **Purpose**: Provide conversational AI experience using local rules
///
/// **Architecture**:
/// 1. IntentDetector → Classify user input
/// 2. ContextAnalyzer → Fetch relevant data from 6 existing analyzers
/// 3. ResponseRepository → Generate personalized response with data
/// 4. Stream simulation → Typewriter effect for UX
///
/// **No External APIs**: Everything runs locally (instant, free, private)
///
/// **Data Sources**:
/// - Existing 6 analyzers: Volume, Progression, Recovery, Form, Balance, Efficiency
/// - User profile data (name, goals, preferences)
/// - Recent workout history
library;

import 'dart:async';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/analyzer_registry.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/intent_detector.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/response_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/simple_entity_extractor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/services/ai_coach_analytics.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/services/tone_adapter.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/hybrid_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart'
    as fitness;
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart'
    as standards;
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';
import 'package:uuid/uuid.dart';

/// ChatBot datasource for pattern-based responses
///
/// **Usage**:
/// ```dart
/// final bot = ChatBotDatasource(
///   intentDetector: IntentDetector(),
///   responseRepository: ResponseRepository(),
/// );
///
/// final stream = bot.sendMessage(
///   prompt: "How am I progressing?",
///   userId: "user123",
///   userContext: {'username': 'Mike', 'locale': 'en'},
/// );
///
/// await for (final message in stream) {
///   print(message.content); // Streamed token-by-token
/// }
/// ```
class ChatBotDatasource {

  ChatBotDatasource({
    required this.intentDetector,
    required this.responseRepository,
    required this.workoutRepository,
    required this.analyzerRegistry,
    required this.exerciseRepository,
    required this.entityExtractor,
    required this.analyticsRepository,
    required this.aiCoachAnalytics,
    required this.toneAdapter,
    required this.toneProfile,
    this.fitnessQuestionnaire,
    required this.streakRepository,
  });
  final IntentDetector intentDetector;
  final ResponseRepository responseRepository;
  final WorkoutRepository workoutRepository;
  final AnalyzerRegistry analyzerRegistry;
  final HybridExerciseRepository exerciseRepository;
  final SimpleEntityExtractor entityExtractor;
  final AnalyticsRepository analyticsRepository;
  final AICoachAnalytics aiCoachAnalytics;
  final ToneAdapter toneAdapter;
  final ToneProfile toneProfile;
  final fitness.UserFitnessQuestionnaire? fitnessQuestionnaire;
  final StreakRepository streakRepository;
  final Uuid _uuid = const Uuid();

  /// Send message and stream bot response
  ///
  /// **Parameters**:
  /// - `prompt`: User's input message
  /// - `userId`: User ID for analytics context
  /// - `userContext`: User data (name, locale, metrics)
  /// - `streamDelay`: Delay between tokens (default: 30ms for typewriter effect)
  ///
  /// **Returns**: Stream<AIMessage> with typewriter simulation
  ///
  /// **Flow**:
  /// 1. Detect intent from user message
  /// 2. Fetch relevant analyzer data (based on intent)
  /// 3. Generate response using template + data
  /// 4. Stream response token-by-token (simulated)
  /// 5. Emit final message
  Stream<AIMessage> sendMessage({
    required String prompt,
    required String userId,
    required Map<String, dynamic> userContext,
    Duration streamDelay = const Duration(milliseconds: 30),
  }) async* {
    // 1. Detect user intent
    final intent = intentDetector.detectIntent(prompt);

    // 2. Get locale for localized responses
    final locale = userContext['locale'] ?? 'en';

    // 3. Fetch analyzer data based on intent (with locale for localization)
    final analyzerData = await _fetchAnalyzerData(
      intent,
      userId,
      locale,
      prompt: prompt,
    );

    // 4. Build response context (user data + analyzer data)
    final responseContext = <String, String>{
      'username': (userContext['username'] ?? 'there').toString(),
      ...analyzerData,
    };

    // 5. Detect user's preferred tone from message style
    final detectedTone = _detectToneFromMessage(prompt);

    // 6. Generate response from templates with detected tone
    var fullResponse = responseRepository.getResponse(
      intent: intent,
      context: responseContext,
      locale: locale,
      tone: detectedTone,
    );

    // 6.1. Apply experience-level tone adaptation (Phase 3.2)
    fullResponse = _applyToneAdaptation(fullResponse, intent, locale);

    // 7. Stream response token-by-token (typewriter effect)
    final messageId = _uuid.v4();
    final buffer = StringBuffer();

    // Split into words for natural streaming
    final words = fullResponse.split(' ');

    for (int i = 0; i < words.length; i++) {
      // Add word + space
      buffer.write(words[i]);
      if (i < words.length - 1) {
        buffer.write(' ');
      }

      // Emit streaming chunk
      yield AIMessage(
        id: messageId,
        content: buffer.toString(),
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        isStreaming: i < words.length - 1, // Last word = final
      );

      // Delay between words (typewriter effect)
      if (i < words.length - 1) {
        await Future.delayed(streamDelay);
      }
    }

    // 8. Generate follow-up chips for branching conversations
    List<FollowUpChip> followUpChips;

    if (intent == UserIntent.prQuery) {
      // Check if this is PR data display (has_data = true) or exercise search
      final hasData = analyzerData['has_data'] == 'true';

      if (hasData) {
        // PR data displayed → no follow-up chips (conversation ends here)
        followUpChips = [];
      } else if (analyzerData.containsKey('exercise_matches')) {
        // Exercise search mode → generate chips with exercise names
        final matchesString = analyzerData['exercise_matches'] ?? '';

        if (matchesString.isNotEmpty) {
          // Parse pipe-delimited exercise names
          final exerciseNames = matchesString.split('|');

          // Generate chips with exercise names
          followUpChips = exerciseNames.map((name) => FollowUpChip(
            label: name,
            intent: 'prQuery.select_exercise', // Intent for chip click
          )).toList();
        } else {
          // No matches found → no chips
          followUpChips = [];
        }
      } else {
        // Generic prQuery without matches → no chips
        followUpChips = [];
      }
    } else {
      // For other intents, use static follow-up chips from repository
      followUpChips = responseRepository.getFollowUpChips(
        intent: intent,
        locale: locale,
        depth: 0, // TODO: Track depth from conversation history in Task 5
      );
    }

    // 9. Generate chart metadata for visual responses (Phase 2.2)
    Map<String, dynamic>? metadata;

    if (intent == UserIntent.progression || intent == UserIntent.volume) {
      // Note: Using empty workouts list for now (Phase 2.2 uses mock data)
      // TODO: Pass real workouts from _fetchAnalyzerData in Phase 2.4
      metadata = await _generateChartMetadata(intent, analyzerData, <Workout>[]);
    }

    // 10. Track message sent analytics (Phase 2.4)
    await aiCoachAnalytics.trackMessageSent(
      userId: userId,
      intent: intent.toString(),
      hasChart: metadata != null && metadata.containsKey('chartType'),
      conversationDepth: 0, // TODO: Track depth in Task 5
    );

    // 11. Generate reasoning for transparency (Phase 3.3)
    final reasoning = _generateReasoning(
      intent: intent,
      analyzerData: analyzerData,
    );

    // 12. Generate multi-modal metadata (Phase 3.4)
    final multiModalMetadata = _generateMultiModalMetadata(
      intent: intent,
      analyzerData: analyzerData,
    );

    // Merge all metadata: charts + reasoning + multi-modal
    final finalMetadata = <String, dynamic>{
      ...?metadata, // Chart data (if any)
      if (reasoning != null) ...reasoning, // Reasoning data
      if (multiModalMetadata != null) ...multiModalMetadata, // Multi-modal data
    };

    // 13. Emit final message (isStreaming=false) with follow-up chips, chart, and reasoning
    yield AIMessage(
      id: messageId,
      content: fullResponse,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isStreaming: false,
      followUpChips: followUpChips,
      conversationDepth: 0, // TODO: Track depth in Task 5
      parentIntent: intent.toString(), // Root intent
      metadata: finalMetadata, // Chart + reasoning data for rendering
    );
  }

  /// Fetch relevant analyzer data based on detected intent
  ///
  /// **Intent → Analyzer Mapping**:
  /// - `progression` → ProgressiveOverloadAnalyzer
  /// - `recovery` → RecoveryPatternAnalyzer + CNSFatigueAnalyzer
  /// - `form` → MobilityAnalyzer
  /// - `plan` → PeriodizationAnalyzer
  /// - `volume` → Mock (TODO: VolumeBalanceAnalyzer requires exerciseDatabase)
  /// - `balance` → Mock (TODO: VolumeBalanceAnalyzer requires exerciseDatabase)
  /// - `motivation` → Mock (no analyzer)
  /// - `prQuery` → Search exercises and return matches
  ///
  /// **Returns**: Map of context variables for response template
  Future<Map<String, String>> _fetchAnalyzerData(
    UserIntent intent,
    String userId,
    String locale, {
    String? prompt,
  }) async {
    // Map fitness questionnaire data to AI Coach UserContext
    final userContext = _createUserContextFromQuestionnaire(userId);

    // Fetch user workouts (last 30 days for analysis)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final workoutsResult = await workoutRepository.getWorkouts(
      startDate: thirtyDaysAgo,
    );

    // Handle error or empty result
    final workouts = workoutsResult.fold(
      (failure) => <Workout>[], // No workouts = fallback to mock data
      (workoutList) => workoutList,
    );

    switch (intent) {
      case UserIntent.progression:
        return _getProgressionData(workouts, userContext, locale);
      case UserIntent.volume:
        return _getVolumeData(workouts, userContext, locale);
      case UserIntent.recovery:
        return _getRecoveryData(workouts, userContext);
      case UserIntent.balance:
        return _getBalanceData(workouts, userContext);
      case UserIntent.form:
        return _getFormData(workouts, userContext);
      case UserIntent.motivation:
        return _getMotivationData(userId);
      case UserIntent.plan:
        return _getPlanData(workouts, userContext);
      case UserIntent.prQuery:
        return _getPRQueryData(prompt ?? '', userId, locale);
      default:
        return {};
    }
  }

  // ========================================================================
  // Analyzer Data Fetchers (TODO: Replace with real analyzer integration)
  // ========================================================================

  Future<Map<String, String>> _getProgressionData(
    List<Workout> workouts,
    UserContext context,
    String locale,
  ) async {
    // Localize period based on locale
    final period = locale == 'it' ? '30 giorni' : '30 days';

    try {
      // Call ProgressiveOverloadAnalyzer
      final analyzer = analyzerRegistry.getAnalyzer(InsightType.progressOverload);
      final insight = await analyzer.analyze(workouts, context);

      if (insight != null) {
        // Extract metric from analyzer insight dataPoints
        final weightChange = insight.dataPoints?['weightChange'];
        final metric = weightChange != null && weightChange.toString().isNotEmpty
            ? weightChange.toString()
            : _calculateRealProgression(workouts);

        return {
          'period': period,
          'metric': metric,
          'trend': insight.severity == InsightSeverity.high ? '📈 positive' : '📊 stable',
          'recommendation': _localizeRecommendation(insight.recommendation, locale),
        };
      }
    } catch (e) {
      // Analyzer not registered or error - calculate from workouts directly
    }

    // Calculate real progression from workout data when analyzer returns null
    final metric = _calculateRealProgression(workouts);
    final recommendation = locale == 'it'
        ? 'Continua con il sovraccarico progressivo!'
        : 'Keep up the progressive overload!';

    return {
      'period': period,
      'metric': metric,
      'trend': metric.startsWith('+') ? '📈 positive' : '📊 stable',
      'recommendation': recommendation,
    };
  }

  /// Calculate real progression from workout data
  String _calculateRealProgression(List<Workout> workouts) {
    if (workouts.length < 2) return '+0%';

    // Get workouts from last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentWorkouts = workouts
        .where((w) => w.createdAt.isAfter(thirtyDaysAgo))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (recentWorkouts.length < 2) return '+0%';

    // Calculate total volume (weight × reps) for first and last workouts
    double firstVolume = 0;
    double lastVolume = 0;

    for (final exercise in recentWorkouts.first.exercises) {
      for (final set in exercise.sets) {
        if (set.isCompleted) {
          final weight = double.tryParse(set.weight?.toString() ?? '0') ?? 0;
          final reps = set.reps ?? 0;
          firstVolume += weight * reps;
        }
      }
    }

    for (final exercise in recentWorkouts.last.exercises) {
      for (final set in exercise.sets) {
        if (set.isCompleted) {
          final weight = double.tryParse(set.weight?.toString() ?? '0') ?? 0;
          final reps = set.reps ?? 0;
          lastVolume += weight * reps;
        }
      }
    }

    if (firstVolume == 0) return '+0%';

    final change = ((lastVolume - firstVolume) / firstVolume) * 100;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}%';
  }

  Future<Map<String, String>> _getVolumeData(
    List<Workout> workouts,
    UserContext context,
    String locale,
  ) async {
    try {
      // Call VolumeBalanceAnalyzer (uses InsightType.muscleGroupBalance)
      final analyzer = analyzerRegistry.getAnalyzer(InsightType.muscleGroupBalance);
      final insight = await analyzer.analyze(workouts, context);

      if (insight != null) {
        // Extract data from analyzer insight
        final muscleGroup = insight.dataPoints?['muscleGroup']?.toString() ??
            (locale == 'it' ? 'tutti i muscoli' : 'all muscles');

        // Get real sets from analyzer - now properly populated
        final setsValue = insight.dataPoints?['currentSets'];
        final currentSets = (setsValue != null && setsValue.toString() != '0')
            ? setsValue.toString()
            : _calculateRealWeeklySets(workouts).toString();

        // Determine assessment emoji based on severity
        final assessment = switch (insight.severity) {
          InsightSeverity.low => '✅ Optimal',
          InsightSeverity.medium => '⚠️ Below optimal',
          InsightSeverity.high => '🔴 Needs attention',
          InsightSeverity.critical => '🚨 Critical',
        };

        return {
          'volume': '$currentSets sets/week ($muscleGroup)',
          'assessment': assessment,
          'sets_per_week': currentSets,
          'recommendation': _localizeRecommendation(insight.recommendation, locale),
        };
      }
    } catch (e) {
      // Analyzer not registered or error - calculate from workouts directly
    }

    // Calculate real data when analyzer returns null
    final realSets = _calculateRealWeeklySets(workouts);
    final recommendation = locale == 'it'
        ? 'Punta a 10-18 serie per gruppo muscolare a settimana.'
        : 'Aim for 10-18 sets per muscle group per week.';

    return {
      'volume': '$realSets sets/week',
      'assessment': '✅ Optimal',
      'sets_per_week': realSets.toString(),
      'recommendation': recommendation,
    };
  }

  /// Calculate real weekly sets from workout data
  int _calculateRealWeeklySets(List<Workout> workouts) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weeklyWorkouts = workouts.where((w) => w.createdAt.isAfter(weekAgo));

    int totalSets = 0;
    for (final workout in weeklyWorkouts) {
      for (final exercise in workout.exercises) {
        totalSets += exercise.sets.where((s) => s.isCompleted).length;
      }
    }
    return totalSets;
  }

  /// Localize analyzer recommendation based on locale
  String _localizeRecommendation(String recommendation, String locale) {
    if (locale != 'it') return recommendation;

    // Common recommendation translations
    const translations = {
      // Volume recommendations
      'Aim for': 'Punta a',
      'sets per muscle group per week': 'serie per gruppo muscolare a settimana',
      'Maintain this volume': 'Mantieni questo volume',
      'Consider tracking other muscle groups': 'Considera di tracciare altri gruppi muscolari',
      'to ensure balanced development': 'per assicurare uno sviluppo bilanciato',

      // Progression recommendations
      'Try increasing volume': 'Prova ad aumentare il volume',
      'varying rep ranges': 'variando i range di ripetizioni',
      'for strength': 'per la forza',
      'for hypertrophy': 'per l\'ipertrofia',
      'or using advanced techniques': 'o usando tecniche avanzate',
      'drop sets': 'drop set',
      'rest-pause': 'rest-pause',
      'Keep up the progressive overload': 'Continua con il sovraccarico progressivo',

      // Recovery recommendations
      'Well recovered': 'Ben recuperato',
      'Needs rest': 'Serve riposo',

      // General
      'sets/week': 'serie/settimana',
      'per week': 'a settimana',
    };

    var localized = recommendation;
    translations.forEach((en, it) {
      localized = localized.replaceAll(en, it);
    });

    return localized;
  }

  Future<Map<String, String>> _getRecoveryData(
    List<Workout> workouts,
    UserContext context,
  ) async {
    try {
      // Call RecoveryPatternAnalyzer
      final analyzer = analyzerRegistry.getAnalyzer(InsightType.recoveryPattern);
      final insight = await analyzer.analyze(workouts, context);

      if (insight != null) {
        final hoursAgo = insight.dataPoints?['hoursSinceLastWorkout']?.toString() ?? '48';
        final status = insight.severity == InsightSeverity.low ? 'Well recovered' : 'Needs rest';
        final emoji = insight.severity == InsightSeverity.low ? '🟢' : '🟡';

        return {
          'score': '78', // TODO: Add recovery score to analyzer dataPoints
          'status_emoji': emoji,
          'status': status,
          'hours_ago': hoursAgo,
          'recommendation': insight.recommendation,
        };
      }
    } catch (e) {
      // Analyzer not registered or error
    }

    // Fallback to mock data
    return {
      'score': '78',
      'status_emoji': '🟢',
      'status': 'Well recovered',
      'hours_ago': '36',
      'recommendation': "You're ready for your next workout!",
    };
  }

  Future<Map<String, String>> _getBalanceData(
    List<Workout> workouts,
    UserContext context,
  ) async {
    try {
      // Call VolumeBalanceAnalyzer (uses InsightType.muscleGroupBalance)
      // This analyzer detects muscle group imbalances
      final analyzer = analyzerRegistry.getAnalyzer(InsightType.muscleGroupBalance);
      final insight = await analyzer.analyze(workouts, context);

      if (insight != null) {
        // Extract balance data from analyzer insight
        final muscleGroup = insight.dataPoints?['muscleGroup']?.toString() ?? '';
        final deficit = insight.dataPoints?['deficit']?.toString();
        final excess = insight.dataPoints?['excess']?.toString();

        // Determine balance score based on severity
        final balanceScore = switch (insight.severity) {
          InsightSeverity.low => '90', // Optimal
          InsightSeverity.medium => '70', // Below optimal
          InsightSeverity.high => '50', // Needs attention
          InsightSeverity.critical => '30', // Critical
        };

        // Format lagging groups message
        String laggingGroups;
        if (deficit != null && int.tryParse(deficit) != null && int.parse(deficit) > 0) {
          laggingGroups = '$muscleGroup is undertrained by $deficit sets/week.';
        } else if (excess != null && int.tryParse(excess) != null && int.parse(excess) > 0) {
          laggingGroups = '$muscleGroup is overtrained by $excess sets/week.';
        } else {
          laggingGroups = 'Your muscle groups are well balanced.';
        }

        return {
          'balance_score': balanceScore,
          'lagging_groups': laggingGroups,
          'recommendation': insight.recommendation,
        };
      }
    } catch (e) {
      // Analyzer not registered or error - fall through to mock data
    }

    // Fallback to mock data if no real data available
    return {
      'balance_score': '82',
      'lagging_groups': 'Back is slightly behind chest.',
      'recommendation': 'Add 2-3 sets of rows per week.',
    };
  }

  Future<Map<String, String>> _getFormData(
    List<Workout> workouts,
    UserContext context,
  ) async {
    try {
      // Call MobilityAnalyzer (closest match for form guidance)
      final analyzer = analyzerRegistry.getAnalyzer(InsightType.mobility);
      final insight = await analyzer.analyze(workouts, context);

      if (insight != null) {
        return {
          'exercise': insight.affectedExercise ?? 'Your exercises',
          'form_cue': insight.description,
          'safety_tip': insight.recommendation,
        };
      }
    } catch (e) {
      // Analyzer not registered or error
    }

    // Fallback to mock data (generic form tips)
    return {
      'exercise': 'Compound movements',
      'form_cue': 'Focus on full range of motion and controlled tempo',
      'safety_tip': 'Warm up properly and listen to your body.',
    };
  }

  Future<Map<String, String>> _getMotivationData(String userId) async {
    try {
      // Get real streak data from StreakRepository
      final streak = await streakRepository.getCurrentStreak();

      // Build achievement message based on real data
      String achievement;
      if (streak.currentStreak > 0) {
        achievement = "You're on a ${streak.currentStreak}-day workout streak!";
      } else if (streak.totalWorkoutDays > 0) {
        achievement = "You've logged ${streak.totalWorkoutDays} total workout days!";
      } else {
        achievement = "Start your fitness journey today!";
      }

      // Build recent progress message
      String recentProgress;
      if (streak.isActive && streak.lastWorkoutDate != null) {
        final daysSinceLastWorkout = DateTime.now().difference(streak.lastWorkoutDate!).inDays;
        if (daysSinceLastWorkout == 0) {
          recentProgress = "Great job working out today!";
        } else if (daysSinceLastWorkout == 1) {
          recentProgress = "You worked out yesterday. Keep it up!";
        } else {
          recentProgress = "Your last workout was $daysSinceLastWorkout days ago.";
        }
      } else {
        recentProgress = "Ready to start a new workout?";
      }

      // Build strategy based on streak status
      String strategy;
      if (streak.currentStreak >= 7) {
        strategy = "Amazing consistency! Consider a deload week if feeling fatigued.";
      } else if (streak.currentStreak >= 3) {
        strategy = "Great momentum! Keep pushing to build your streak.";
      } else if (streak.totalWorkoutDays > 0) {
        strategy = "Get back to the gym to restart your streak!";
      } else {
        strategy = "Start with 3 workouts this week to build momentum.";
      }

      return {
        'achievement': achievement,
        'recent_progress': recentProgress,
        'strategy': strategy,
      };
    } catch (e) {
      // Fallback to mock data if streak data unavailable
    }

    // Fallback to mock data if no real data available
    return {
      'achievement': "You've logged 25 workouts this month!",
      'recent_progress': 'Last week you hit a PR on squats.',
      'strategy': 'Try a deload week to break through.',
    };
  }

  Future<Map<String, String>> _getPlanData(
    List<Workout> workouts,
    UserContext context,
  ) async {
    try {
      // Call PeriodizationAnalyzer
      final analyzer = analyzerRegistry.getAnalyzer(InsightType.periodization);
      final insight = await analyzer.analyze(workouts, context);

      if (insight != null) {
        return {
          'current_split': insight.dataPoints?['currentSplit'] ?? 'Upper/Lower',
          'recommendation': insight.recommendation,
        };
      }
    } catch (e) {
      // Analyzer not registered or error
    }

    // Fallback to mock data
    return {
      'current_split': 'Push/Pull/Legs',
      'recommendation': 'Your current split is working well. Maintain frequency.',
    };
  }

  /// Get PR query data by searching exercises OR fetching specific exercise PR
  ///
  /// **Flow**:
  /// 1. If prompt is short (<= 50 chars) and matches exact exercise → fetch PR data
  /// 2. Otherwise → search exercises and return matches for chip generation
  ///
  /// **Returns**: Map with exercise data or matches
  Future<Map<String, String>> _getPRQueryData(
    String prompt,
    String userId,
    String locale,
  ) async {
    try {
      final trimmedPrompt = prompt.trim();

      // Check if this is an exercise selection (short, exact match)
      if (trimmedPrompt.length <= 50) {
        // Try to find exact match in exercise database
        final allExercises = await exerciseRepository.getAllExercises();
        final exactMatch = allExercises.where(
          (e) => e.nome.toLowerCase() == trimmedPrompt.toLowerCase(),
        ).firstOrNull;

        if (exactMatch != null) {
          // This is an exercise selection → fetch PR data
          return _getPRDataForExercise(
            exerciseName: exactMatch.nome,
            userId: userId,
            locale: locale,
          );
        }
      }

      // Not an exact match → perform search (Phase 4 logic)
      // 1. Extract keywords from user prompt
      final keywords = entityExtractor.extractKeywords(prompt);

      if (keywords.isEmpty) {
        // No keywords extracted → generic "not found" response
        return {
          'exercise_matches': '',
          'match_count': '0',
          'search_query': prompt,
        };
      }

      // 2. Search exercises using first few keywords
      // Join keywords to create search query (e.g., "panca piana" or "bench press")
      final searchQuery = keywords.take(3).join(' ');
      final matchingExercises = await exerciseRepository.searchExercises(searchQuery);

      // 3. Filter and limit results
      // Take top 5 matches (to avoid overwhelming user with chips)
      final topMatches = matchingExercises.take(5).toList();

      if (topMatches.isEmpty) {
        // No matches found → "exercise not found" response
        return {
          'exercise_matches': '',
          'match_count': '0',
          'search_query': searchQuery,
        };
      }

      // 4. Format matches for chip generation
      // Store as pipe-delimited string: "Exercise1|Exercise2|Exercise3"
      final exerciseNames = topMatches.map((e) => e.nome).join('|');

      return {
        'exercise_matches': exerciseNames,
        'match_count': topMatches.length.toString(),
        'search_query': searchQuery,
      };
    } catch (e) {
      // Error during search → fallback to empty
      return {
        'exercise_matches': '',
        'match_count': '0',
        'search_query': prompt,
        'error': e.toString(),
      };
    }
  }

  /// Get PR data for a specific exercise (Phase 5)
  ///
  /// **Flow**:
  /// 1. Fetch ExerciseHistory from analytics repository
  /// 2. Get personal record (highest 1RM)
  /// 3. Get best session details (weight, reps, date)
  /// 4. Return formatted data for template
  ///
  /// **Returns**: Map with PR data for response template
  Future<Map<String, String>> _getPRDataForExercise({
    required String exerciseName,
    required String userId,
    required String locale,
  }) async {
    try {
      // 1. Fetch exercise history from analytics repository
      final historyStreamResult = analyticsRepository.getExerciseHistory(userId);

      // Take first emission from stream (current data)
      final historyResult = await historyStreamResult.first;

      // Handle Either<Failure, List<ExerciseHistory>>
      return historyResult.fold(
        // Left: Failure
        (failure) {
          return {
            'exercise_name': exerciseName,
            'pr_1rm': '0',
            'pr_weight': '0',
            'pr_reps': '0',
            'pr_date': 'N/A',
            'error': failure.message,
          };
        },
        // Right: Success
        (histories) {
          // Find exercise in history list
          final exerciseHistory = histories.where(
            (h) => h.exerciseName.toLowerCase() == exerciseName.toLowerCase(),
          ).firstOrNull;

          if (exerciseHistory == null || exerciseHistory.sessions.isEmpty) {
            // No data for this exercise
            return {
              'exercise_name': exerciseName,
              'pr_1rm': '0',
              'pr_weight': '0',
              'pr_reps': '0',
              'pr_date': 'N/A',
              'has_data': 'false',
            };
          }

          // 2. Get personal record session
          final prSession = exerciseHistory.personalRecordSession!;
          final pr1RM = exerciseHistory.personalRecord;

          // 3. Get best set from session (set with highest 1RM)
          final bestSet = prSession.sets
              .reduce((a, b) => a.estimatedOneRM > b.estimatedOneRM ? a : b);

          // 4. Format date
          final prDate = _formatDate(prSession.date, locale);

          // 5. Return data for template
          return {
            'exercise_name': exerciseName,
            'pr_1rm': pr1RM.toStringAsFixed(1),
            'pr_weight': bestSet.weight.toStringAsFixed(1),
            'pr_reps': bestSet.reps.toString(),
            'pr_date': prDate,
            'has_data': 'true',
          };
        },
      );
    } catch (e) {
      // Error fetching data
      return {
        'exercise_name': exerciseName,
        'pr_1rm': '0',
        'pr_weight': '0',
        'pr_reps': '0',
        'pr_date': 'N/A',
        'error': e.toString(),
      };
    }
  }

  /// Format date for display
  ///
  /// Returns localized date string
  String _formatDate(DateTime date, String locale) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return locale == 'it' ? 'Oggi' : 'Today';
    } else if (difference.inDays == 1) {
      return locale == 'it' ? 'Ieri' : 'Yesterday';
    } else if (difference.inDays < 7) {
      return locale == 'it'
          ? '${difference.inDays} giorni fa'
          : '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return locale == 'it'
          ? '$weeks ${weeks == 1 ? 'settimana' : 'settimane'} fa'
          : '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return locale == 'it'
          ? '$months ${months == 1 ? 'mese' : 'mesi'} fa'
          : '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }

  // ========================================================================
  // Chart Metadata Generation (Phase 2.2 - Rich Media Responses)
  // ========================================================================

  /// Generate chart metadata for inline visualization in AI messages
  ///
  /// **Supported Intents**:
  /// - `progression`: Line chart showing PR trends over time
  /// - `volume`: Bar chart showing weekly volume comparison
  ///
  /// **Returns**: Map with chartType and chartData, or null if no chart needed
  Future<Map<String, dynamic>?> _generateChartMetadata(
    UserIntent intent,
    Map<String, String> analyzerData,
    List<Workout> workouts,
  ) async {
    try {
      if (intent == UserIntent.progression) {
        // Generate progression chart data (mock for now - TODO: use real workout PRs)
        // Simulate 8 weeks of bench press progression
        final now = DateTime.now();
        final data = <Map<String, dynamic>>[];

        // Mock progression data (realistic trend: +2-5kg per week)
        var currentWeight = 80.0;
        for (var i = 7; i >= 0; i--) {
          final date = now.subtract(Duration(days: i * 7)); // Weekly data points
          data.add({
            'date': date.toIso8601String(),
            'value': currentWeight,
          });
          currentWeight += (2.0 + (i % 2) * 2.0); // +2kg or +4kg progression
        }

        return {
          'chartType': 'line',
          'chartData': {
            'title': 'Bench Press Progression', // TODO: Extract exercise name from analyzerData
            'unit': 'kg',
            'data': data,
          },
        };
      } else if (intent == UserIntent.volume) {
        // Generate volume chart data (mock - TODO: use real workout volume)
        // Simulate 4 weeks of volume comparison
        final now = DateTime.now();
        final data = <Map<String, dynamic>>[];

        // Mock volume data (weekly total volume in kg)
        final volumes = [8500.0, 9200.0, 8800.0, 9500.0];
        for (var i = 3; i >= 0; i--) {
          final weekStart = now.subtract(Duration(days: i * 7));
          data.add({
            'date': weekStart.toIso8601String(),
            'value': volumes[3 - i],
            'label': 'W${4 - i}', // Week label (W1, W2, W3, W4)
          });
        }

        return {
          'chartType': 'bar',
          'chartData': {
            'title': null, // No title for volume chart (embedded in message)
            'unit': 'kg',
            'data': data,
          },
        };
      }
    } catch (e) {
      // Chart generation failed → return null (no chart, just text response)
      return null;
    }

    return null;
  }

  /// Apply tone adaptation to response (Phase 3.2)
  ///
  /// Modifies the bot response based on user's tone profile:
  /// - Beginner: Add encouraging phrases, simplify technical terms
  /// - Intermediate: Balanced tone
  /// - Advanced: Concise, technical language
  ///
  /// **Parameters**:
  /// - `baseResponse`: The response to adapt
  /// - `intent`: User's detected intent
  /// - `locale`: Language code for localized phrases
  ///
  /// **Examples**:
  /// - Beginner + IT → "Ottimo inizio! Focus su..."
  /// - Beginner + EN → "Great start! Focus on..."
  String _applyToneAdaptation(String baseResponse, UserIntent intent, String locale) {
    toneAdapter.logToneAdaptation(toneProfile, intent.toString());

    // Apply encouraging phrases for beginners (locale-aware)
    if (toneProfile.isEncouraging &&
        toneProfile.experienceLevel == ExperienceLevel.beginner) {
      final encouragingPhrases = toneAdapter.getEncouragingPhrases(
        toneProfile,
        locale: locale,
      );

      // Add random encouraging phrase at start (33% chance)
      if (encouragingPhrases.isNotEmpty &&
          DateTime.now().millisecond % 3 == 0) {
        final randomPhrase = encouragingPhrases[
            DateTime.now().millisecond % encouragingPhrases.length];
        return '$randomPhrase $baseResponse';
      }
    }

    // TODO: Replace technical terms for beginners using vocabulary map
    // final vocabulary = toneAdapter.getVocabulary(toneProfile);
    // var adaptedResponse = baseResponse;
    // vocabulary.forEach((technical, simple) {
    //   adaptedResponse = adaptedResponse.replaceAll(technical, simple);
    // });

    return baseResponse;
  }

  /// Generate reasoning explanation for transparency (Phase 3.3)
  ///
  /// Explains WHY the bot generated this response:
  /// - Data sources used (e.g., "last 7 workouts")
  /// - Analysis methods applied
  /// - Confidence level
  /// - Reasoning logic
  ///
  /// **Returns**: Map with reasoning metadata or null if no reasoning available
  Map<String, dynamic>? _generateReasoning({
    required UserIntent intent,
    required Map<String, dynamic> analyzerData,
  }) {
    final reasoning = <String>[];

    switch (intent) {
      case UserIntent.progression:
        // Explain progressive overload analysis
        if (analyzerData['has_data'] == 'true') {
          reasoning.add(
            'I analyzed your workout history for progressive overload patterns '
            '(increasing weight, reps, or volume over time).',
          );

          if (analyzerData.containsKey('workout_count')) {
            reasoning.add(
              'Data source: Last ${analyzerData['workout_count']} workouts.',
            );
          }
        }
        break;

      case UserIntent.recovery:
        // Explain recovery pattern analysis
        if (analyzerData['has_data'] == 'true') {
          reasoning.add(
            'I examined your rest days and muscle group rotation to identify '
            'recovery patterns.',
          );

          reasoning.add(
            'Optimal recovery allows muscles to repair and grow stronger.',
          );
        }
        break;

      case UserIntent.volume:
        // Explain volume analysis
        if (analyzerData['has_data'] == 'true') {
          reasoning.add(
            'I calculated your total training volume (sets × reps × weight) '
            'to check if you\'re in the optimal hypertrophy range.',
          );

          reasoning.add(
            'Recommended: 10-20 sets per muscle group per week for growth.',
          );
        }
        break;

      case UserIntent.form:
        // Explain form analysis (when implemented)
        reasoning.add(
          'Form analysis is based on exercise selection and rest times. '
          'Proper form prevents injury and maximizes muscle activation.',
        );
        break;

      case UserIntent.prQuery:
        // Explain PR tracking
        if (analyzerData['has_data'] == 'true') {
          reasoning.add(
            'I searched your workout history for maximum weight lifted '
            'in the specified exercise.',
          );

          reasoning.add(
            'Personal Records track your strength progression over time.',
          );
        }
        break;

      case UserIntent.plan:
        // Explain workout plan recommendations
        reasoning.add(
          'I recommend workout plans based on your experience level and goals. '
          'Proper programming ensures balanced progress and prevents overtraining.',
        );
        break;

      case UserIntent.motivation:
        // Explain motivational approach
        reasoning.add(
          'I provide motivation by highlighting your progress and effort. '
          'Consistency is the key to long-term success.',
        );
        break;

      default:
        // No specific reasoning for other intents (greeting, help, unknown)
        return null;
    }

    if (reasoning.isEmpty) return null;

    return {
      'reasoning': reasoning,
      'dataSource': analyzerData.containsKey('workout_count')
          ? 'Last ${analyzerData['workout_count']} workouts'
          : 'Your workout history',
      'confidence': 'high', // TODO: Calculate actual confidence
    };
  }

  // ========================================================================
  // Multi-Modal Response Generation (Phase 3.4)
  // ========================================================================

  /// Generate multi-modal metadata for enhanced responses
  ///
  /// **Supported Modalities**:
  /// - Exercise demonstrations (images/videos)
  /// - Workout plan tables (structured format)
  ///
  /// **Returns**: Map with multi-modal data or null if none needed
  Map<String, dynamic>? _generateMultiModalMetadata({
    required UserIntent intent,
    required Map<String, String> analyzerData,
  }) {
    // Form intent: Add exercise demonstration images
    if (intent == UserIntent.form) {
      return _generateExerciseDemonstration(analyzerData);
    }

    // Plan intent: Add workout plan table
    if (intent == UserIntent.plan) {
      return _generateWorkoutPlanTable(analyzerData);
    }

    return null;
  }

  /// Generate exercise demonstration metadata
  ///
  /// **Features**:
  /// - Exercise image URL
  /// - Video tutorial link
  /// - Key form cues
  ///
  /// TODO: Integrate with ExerciseRepository to get real images
  Map<String, dynamic> _generateExerciseDemonstration(
    Map<String, String> analyzerData,
  ) {
    // Mock data - TODO: Get from ExerciseRepository based on detected exercise
    return {
      'exerciseMedia': {
        'exerciseName': 'Bench Press', // TODO: Extract from analyzerData
        'imageUrl':
            'https://via.placeholder.com/400x300.png?text=Bench+Press+Form',
        'videoUrl': null, // TODO: Add video URLs from database
        'formCues': [
          'Keep shoulder blades retracted',
          'Bar path: Straight vertical line',
          'Feet flat on floor, drive through heels',
          'Lower to mid-chest, touch lightly',
          'Press up and slightly back toward rack',
        ],
      },
    };
  }

  /// Generate workout plan table metadata
  ///
  /// **Features**:
  /// - Structured exercise list
  /// - Sets, reps, rest recommendations
  /// - Progressive overload notes
  ///
  /// TODO: Use PeriodizationAnalyzer to generate real plans
  Map<String, dynamic> _generateWorkoutPlanTable(
    Map<String, String> analyzerData,
  ) {
    // Mock data - TODO: Generate from PeriodizationAnalyzer
    return {
      'workoutTable': {
        'title': 'Push Day - Beginner Program',
        'exercises': [
          {
            'name': 'Bench Press',
            'sets': 3,
            'reps': '8-10',
            'rest': '2-3 min',
            'notes': 'Compound movement - go heavy',
          },
          {
            'name': 'Overhead Press',
            'sets': 3,
            'reps': '8-10',
            'rest': '2-3 min',
            'notes': 'Strict form, no leg drive',
          },
          {
            'name': 'Incline Dumbbell Press',
            'sets': 3,
            'reps': '10-12',
            'rest': '90 sec',
            'notes': 'Upper chest focus',
          },
          {
            'name': 'Lateral Raises',
            'sets': 3,
            'reps': '12-15',
            'rest': '60 sec',
            'notes': 'Light weight, control the movement',
          },
          {
            'name': 'Tricep Pushdowns',
            'sets': 3,
            'reps': '12-15',
            'rest': '60 sec',
            'notes': 'Keep elbows tucked',
          },
        ],
        'totalVolume': 15, // Total sets
        'estimatedDuration': '45-60 min',
        'progressionNotes':
            'Increase weight by 2.5kg when you can complete all sets with good form',
      },
    };
  }

  // ========================================================================
  // User Context Mapping (Fitness Questionnaire → AI Coach UserContext)
  // ========================================================================

  /// Create UserContext from fitness questionnaire data stored in Hive
  ///
  /// **Mapping**:
  /// - `fitness.ExperienceLevel` (5 levels) → `ExperienceLevel` (3 levels)
  ///   - untrained, novice → beginner
  ///   - intermediate → intermediate
  ///   - advanced, elite → advanced
  ///
  /// - `fitness.TrainingGoal` → `TrainingGoal`
  ///   - Direct mapping (hypertrophy, strength, endurance)
  ///
  /// **Fallback**: If no questionnaire data, returns default (intermediate, hypertrophy)
  UserContext _createUserContextFromQuestionnaire(String userId) {
    // If no fitness questionnaire data available, use sensible defaults
    if (fitnessQuestionnaire == null) {
      return UserContext(
        userId: userId,
        experienceLevel: ExperienceLevel.intermediate,
        primaryGoal: TrainingGoal.hypertrophy,
        weeklyAvailability: 4,
      );
    }

    // Map fitness questionnaire experience level to AI Coach experience level
    final mappedExperience = _mapExperienceLevel(
      fitnessQuestionnaire!.experienceLevel,
    );

    // Map fitness questionnaire training goal to AI Coach training goal
    final mappedGoal = _mapTrainingGoal(fitnessQuestionnaire!.trainingGoal);

    return UserContext(
      userId: userId,
      experienceLevel: mappedExperience,
      primaryGoal: mappedGoal,
      weeklyAvailability: 4, // TODO: Get from user profile when available
      injuryHistory: fitnessQuestionnaire!.hasInjuryHistory
          ? [fitnessQuestionnaire!.injuryDetails?.injuryType ?? 'Unknown injury']
          : null,
    );
  }

  /// Map fitness questionnaire ExperienceLevel (5 levels) to AI Coach (3 levels)
  ExperienceLevel _mapExperienceLevel(standards.ExperienceLevel fitnessLevel) {
    switch (fitnessLevel) {
      case standards.ExperienceLevel.untrained:
      case standards.ExperienceLevel.novice:
        return ExperienceLevel.beginner;
      case standards.ExperienceLevel.intermediate:
        return ExperienceLevel.intermediate;
      case standards.ExperienceLevel.advanced:
      case standards.ExperienceLevel.elite:
        return ExperienceLevel.advanced;
    }
  }

  /// Map fitness questionnaire TrainingGoal to AI Coach TrainingGoal
  TrainingGoal _mapTrainingGoal(fitness.TrainingGoal fitnessGoal) {
    switch (fitnessGoal) {
      case fitness.TrainingGoal.strength:
        return TrainingGoal.strength;
      case fitness.TrainingGoal.hypertrophy:
        return TrainingGoal.hypertrophy;
      case fitness.TrainingGoal.endurance:
        return TrainingGoal.endurance;
    }
  }

  // ========================================================================
  // Tone Detection (Formal vs Casual)
  // ========================================================================

  /// Detect user's preferred tone from their message style
  ///
  /// **Casual indicators** (Italian):
  /// - "ehi", "we", "uè", "bella", "bro", "fra"
  /// - Informal greetings: "ciao!", "yo!", "wee!"
  /// - Slang: "spaccare", "pompare", "devastato", "cotto"
  /// - Exclamation marks, emojis
  ///
  /// **Casual indicators** (English):
  /// - "hey", "yo", "dude", "bro", "man"
  /// - Slang: "crushing it", "killing it", "beast mode"
  ///
  /// **Default**: Formal tone if no casual indicators detected
  ResponseTone _detectToneFromMessage(String message) {
    final normalized = message.toLowerCase().trim();

    // Casual Italian indicators
    final casualItalian = [
      // Informal greetings
      'ehi', 'we', 'uè', 'bella', 'wee', 'yo',
      // Gym bro terms
      'bro', 'fra', 'zio', 'fratello',
      // Casual slang
      'spaccare', 'spaccando', 'pompare', 'pompando',
      'devastato', 'cotto', 'morto', 'a pezzi',
      'che bomba', 'bestia', 'macchina', 'animale',
      // Casual phrases
      'dammi la carica', 'caricami', 'motivami',
      'sto spaccando', 'sto volando',
      // Exclamations with !
      'ciao!', 'hey!', 'yo!',
    ];

    // Casual English indicators
    final casualEnglish = [
      // Informal greetings
      'hey', 'yo', 'dude', 'bro', 'man',
      // Gym bro terms
      'crushing it', 'killing it', 'beast mode',
      'gains', 'swole', 'shredded', 'jacked',
      // Casual phrases
      'let\'s go', 'let\'s gooo', 'pumped',
      'hyped', 'stoked', 'fired up',
    ];

    // Check for casual indicators
    final allCasualIndicators = [...casualItalian, ...casualEnglish];

    for (final indicator in allCasualIndicators) {
      if (normalized.contains(indicator)) {
        return ResponseTone.casual;
      }
    }

    // Check for multiple exclamation marks or emojis (casual style)
    if (RegExp(r'!{2,}').hasMatch(normalized) ||
        RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true).hasMatch(message)) {
      return ResponseTone.casual;
    }

    // Default to formal
    return ResponseTone.formal;
  }
}
