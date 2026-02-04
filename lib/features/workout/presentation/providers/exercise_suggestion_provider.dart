/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 📱 Platform: Universal
///
/// Smart exercise suggestion provider
/// Manages intelligent community suggestions with priority scoring
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';

/// User level based on community contributions
enum UserLevel {
  rookie, // 0-10 contributions
  contributor, // 11-50 contributions
  expert, // 51-200 contributions
  master, // 201+ contributions
}

/// App experience level (how well user knows the APP features)
enum AppExperienceLevel {
  beginner, // < 5 workouts in app OR < 2 weeks using app
  intermediate, // 5-20 workouts
  expert, // 20+ workouts
}

/// Fitness experience level (how experienced in GYM, not app)
enum FitnessExperienceLevel {
  beginner, // Low volume, low weights, few exercises
  intermediate, // Medium volume and weights
  expert, // High volume, heavy weights, variety
}

/// Suggestion context - all data needed for smart suggestions
class SuggestionContext {
  // Average workouts per week (last 4 weeks)

  const SuggestionContext({
    required this.exercise,
    this.exerciseData,
    required this.hasNotes,
    required this.isFirstTime,
    required this.completedSets,
    required this.totalSets,
    this.minWeight,
    this.maxWeight,
    required this.existingContributions,
    required this.userLevel,
    required this.userContributionCount,
    required this.exerciseHistoryCount,
    required this.totalVolume,
    required this.totalWorkoutsCompleted,
    required this.accountAgeInDays,
    this.workoutStartTime,
    required this.isLastExerciseInWorkout,
    required this.currentExerciseIndex,
    required this.totalExercisesInWorkout,
    required this.averageWorkoutVolume,
    required this.uniqueExercisesCount,
    required this.workoutsPerWeek,
  });
  final Exercise exercise;
  final Map<String, dynamic>? exerciseData;
  final bool hasNotes;
  final bool isFirstTime;
  final int completedSets;
  final int totalSets;
  final double? minWeight;
  final double? maxWeight;
  final List<dynamic> existingContributions; // Removed: CommunityContribution
  final UserLevel userLevel;
  final int userContributionCount;
  final int exerciseHistoryCount; // How many times user did this exercise
  final double totalVolume; // Total volume in kg (weight × reps summed)

  // App usage data (for app experience level)
  final int
  totalWorkoutsCompleted; // Total workouts user has completed in THIS app
  final int accountAgeInDays; // Days since account creation
  final DateTime? workoutStartTime; // When current workout started
  final bool isLastExerciseInWorkout; // Is this the last exercise?
  final int currentExerciseIndex; // Position in workout (0-based)
  final int totalExercisesInWorkout; // Total exercises in workout

  // Fitness data (for fitness experience level)
  final double
  averageWorkoutVolume; // Average kg lifted per workout (last 5 workouts)
  final int uniqueExercisesCount; // How many different exercises user has tried
  final double workoutsPerWeek;

  bool get isCompleted => completedSets == totalSets && totalSets > 0;
  bool get hasWeightJump =>
      maxWeight != null && minWeight != null && maxWeight! > minWeight! * 2;
  bool get hasExistingTips =>
      existingContributions.any((c) => c.type == ContributionType.tip);
  bool get hasExistingWarnings =>
      existingContributions.any((c) => c.type == ContributionType.warning);

  /// Determine user's APP experience level (how well they know the app)
  AppExperienceLevel get appExperienceLevel {
    // Beginner: < 5 workouts OR < 2 weeks (14 days)
    if (totalWorkoutsCompleted < 5 || accountAgeInDays < 14) {
      return AppExperienceLevel.beginner;
    }

    // Expert: 20+ workouts
    if (totalWorkoutsCompleted >= 20) {
      return AppExperienceLevel.expert;
    }

    // Intermediate: 5-19 workouts
    return AppExperienceLevel.intermediate;
  }

  /// Determine user's FITNESS experience level (gym experience, NOT app)
  FitnessExperienceLevel get fitnessExperienceLevel {
    // Not enough data - assume beginner for safety
    if (totalWorkoutsCompleted < 3) {
      return FitnessExperienceLevel.beginner;
    }

    // Calculate expert score based on performance metrics
    int expertScore = 0;

    // 1. Average workout volume (strongest indicator)
    if (averageWorkoutVolume > 8000) {
      expertScore += 3; // Very high volume = expert
    } else if (averageWorkoutVolume > 3000) {
      expertScore += 1; // Medium volume = intermediate
    }
    // < 3000 = beginner (no points)

    // 2. Exercise variety (shows exploration and commitment)
    if (uniqueExercisesCount > 30) {
      expertScore += 2; // Many exercises = expert
    } else if (uniqueExercisesCount > 10) {
      expertScore += 1; // Some variety = intermediate
    }

    // 3. Training frequency (consistency indicator)
    if (workoutsPerWeek >= 4) {
      expertScore += 2; // High frequency = expert
    } else if (workoutsPerWeek >= 2.5) {
      expertScore += 1; // Medium frequency = intermediate
    }

    // Score ranges:
    // 0-1: Beginner (low volume, low variety, inconsistent)
    // 2-4: Intermediate (decent performance)
    // 5+: Expert (high performance across metrics)
    if (expertScore >= 5) {
      return FitnessExperienceLevel.expert;
    } else if (expertScore >= 2) {
      return FitnessExperienceLevel.intermediate;
    } else {
      return FitnessExperienceLevel.beginner;
    }
  }

  /// Check if it's the right time to show suggestions (non-invasive timing)
  bool get shouldShowSuggestions {
    // Always show if it's the last exercise and it's completed
    if (isLastExerciseInWorkout && isCompleted) {
      return true;
    }

    // Show after 30-60 minutes of workout (if we have start time)
    if (workoutStartTime != null) {
      final duration = DateTime.now().difference(workoutStartTime!);
      // Show suggestions after 30 minutes
      if (duration.inMinutes >= 30) {
        return true;
      }
    }

    // Show after completing at least 3 exercises (mid-workout check-in)
    if (currentExerciseIndex >= 2 && isCompleted) {
      return true;
    }

    // Don't show during active workout
    return false;
  }

  /// Check if user is experienced enough with THIS specific exercise to suggest data corrections
  /// Based on: frequency (times done) + volume (kg lifted)
  bool get isExperiencedWithExercise {
    // Need at least 5 times doing this exercise
    if (exerciseHistoryCount < 5) return false;

    // AND need decent volume in current workout (at least 500kg total)
    // This filters out both beginners AND one-time heavy lifts
    if (totalVolume < 500) return false;

    // OR if they're already a community Expert/Master with good volume
    if ((userLevel == UserLevel.expert || userLevel == UserLevel.master) &&
        totalVolume >= 300) {
      return true;
    }

    return true;
  }
}

/// Smart suggestion with priority
class SmartSuggestion {
  // For analytics

  const SmartSuggestion({
    required this.id,
    required this.text,
    required this.type,
    required this.contextType,
    required this.priority,
    required this.createdAt,
    required this.trigger,
  });
  final String id;
  final String text;
  final ContributionType type;
  final String contextType;
  final int priority; // 0-100, higher = more important
  final DateTime createdAt;
  final String trigger;

  SmartSuggestion copyWith({
    String? id,
    String? text,
    ContributionType? type,
    String? contextType,
    int? priority,
    DateTime? createdAt,
    String? trigger,
  }) {
    return SmartSuggestion(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      contextType: contextType ?? this.contextType,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      trigger: trigger ?? this.trigger,
    );
  }
}

/// Notifier for exercise suggestions (Riverpod 2.0)
/* TEMPORARY: Disabled for Riverpod 3.x migration - TODO: Migrate to @riverpod codegen
class ExerciseSuggestionsNotifier
    extends AutoDisposeFamilyNotifier<List<SmartSuggestion>, String> {
  @override
  List<SmartSuggestion> build(String exerciseId) => [];

  /// Generate suggestions based on context (uses inherited arg from build)
  Future<void> generateSuggestions(SuggestionContext context) async {
    final suggestions = <SmartSuggestion>[];

    // TIMING CHECK: Only show suggestions at appropriate moments
    if (!context.shouldShowSuggestions) {
      state = []; // Clear suggestions during active workout
      return;
    }

    // DUAL-LEVEL SUGGESTIONS (app experience + fitness experience)
    // App beginners always get app education suggestions
    if (context.appExperienceLevel == AppExperienceLevel.beginner) {
      _generateAppEducationSuggestions(context, suggestions);
    }

    // Fitness level determines community engagement level
    switch (context.fitnessExperienceLevel) {
      case FitnessExperienceLevel.beginner:
        await _generateFitnessBeginnerSuggestions(context, suggestions);
        break;
      case FitnessExperienceLevel.intermediate:
        await _generateFitnessIntermediateSuggestions(context, suggestions);
        break;
      case FitnessExperienceLevel.expert:
        await _generateFitnessExpertSuggestions(context, suggestions);
        break;
    }

    // Sort by priority (highest first) and take top 3
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));
    final newSuggestions = suggestions.take(3).toList();

    // Only update state if suggestions have changed (prevent unnecessary rebuilds)
    final hasChanged = !_areSuggestionsEqual(state, newSuggestions);
    if (!hasChanged) {
      if (kDebugMode) {
        debugPrint('🎯 [Suggestions] No changes detected, skipping update');
      }
      return;
    }

    state = newSuggestions;

    if (kDebugMode) {
      debugPrint(
        '🎯 [Suggestions] App: ${context.appExperienceLevel.name.toUpperCase()} | Fitness: ${context.fitnessExperienceLevel.name.toUpperCase()}',
      );
      debugPrint(
        '   📊 ${context.totalWorkoutsCompleted} workouts, ${context.averageWorkoutVolume.toStringAsFixed(0)}kg avg, ${context.uniqueExercisesCount} exercises, ${context.workoutsPerWeek.toStringAsFixed(1)}/week',
      );
      debugPrint(
        '   ⏰ Timing: ${context.isLastExerciseInWorkout ? "Last exercise" : "Exercise ${context.currentExerciseIndex + 1}/${context.totalExercisesInWorkout}"}',
      );
      debugPrint(
        '   💪 Current: ${context.totalVolume.toStringAsFixed(0)}kg volume',
      );
      for (var s in state) {
        debugPrint('   - [${s.priority}] ${s.trigger}: ${s.text}');
      }
    }
  }

  /// Compare two suggestion lists for equality
  bool _areSuggestionsEqual(List<SmartSuggestion> a, List<SmartSuggestion> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].text != b[i].text ||
          a[i].type != b[i].type) {
        return false;
      }
    }
    return true;
  }

  /// App education suggestions (for app beginners, regardless of fitness level)
  void _generateAppEducationSuggestions(
    SuggestionContext context,
    List<SmartSuggestion> suggestions,
  ) {
    // Teach app features only - these are for new app users

    // 1. Note tecniche (highest priority if they haven't used notes)
    if (!context.hasNotes && context.exerciseData != null) {
      suggestions.add(
        SmartSuggestion(
          id: 'discover_technique_notes',
          text:
              '💡 Sai che puoi visualizzare le note tecniche dell\'esercizio?',
          type: ContributionType.tip,
          contextType: 'app_feature',
          priority: 90,
          createdAt: DateTime.now(),
          trigger: 'teach_technique_notes',
        ),
      );
    }

    // 2. Warmup suggestion
    if (!context.exercise.sets.any((s) => s.isWarmup)) {
      suggestions.add(
        SmartSuggestion(
          id: 'discover_warmup',
          text:
              '🔥 Suggerimento: aggiungi serie di riscaldamento prima di iniziare',
          type: ContributionType.tip,
          contextType: 'app_feature',
          priority: 85,
          createdAt: DateTime.now(),
          trigger: 'teach_warmup',
        ),
      );
    }

    // 3. Rest timer
    suggestions.add(
      SmartSuggestion(
        id: 'discover_rest_timer',
        text: '⏱️ Puoi impostare un timer automatico tra le serie',
        type: ContributionType.tip,
        contextType: 'app_feature',
        priority: 80,
        createdAt: DateTime.now(),
        trigger: 'teach_rest_timer',
      ),
    );

    // 4. RPE tracking
    suggestions.add(
      SmartSuggestion(
        id: 'discover_rpe',
        text: '📊 Prova a tracciare RPE per misurare la fatica percepita',
        type: ContributionType.tip,
        contextType: 'app_feature',
        priority: 60,
        createdAt: DateTime.now(),
        trigger: 'teach_rpe',
      ),
    );
  }

  /// Fitness beginner suggestions: Safety warnings only, NO data corrections
  Future<void> _generateFitnessBeginnerSuggestions(
    SuggestionContext context,
    List<SmartSuggestion> suggestions,
  ) async {
    // Safety warnings (always important)
    if (context.hasWeightJump && !context.hasExistingWarnings) {
      suggestions.add(
        SmartSuggestion(
          id: 'weight_jump_safety',
          text:
              '⚠️ Salto di peso rilevato - fai attenzione alla tecnica e forma',
          type: ContributionType.warning,
          contextType: 'weight_progression',
          priority: 85,
          createdAt: DateTime.now(),
          trigger: 'safety_weight_jump',
        ),
      );
    }

    // PR celebration (encourage positive reinforcement)
    final isPersonalRecord = await _checkPersonalRecord(context);
    if (isPersonalRecord) {
      suggestions.add(
        SmartSuggestion(
          id: 'pr_beginner',
          text: '🎉 Nuovo record personale! Continua così!',
          type: ContributionType.tip,
          contextType: 'achievement',
          priority: 75,
          createdAt: DateTime.now(),
          trigger: 'personal_record',
        ),
      );
    }

    // NOTE: Workout-level motivation messages moved to workout completion flow
    // (shown via snackbar/modal when finishing workout, not on exercise cards)
  }

  /// Fitness intermediate suggestions: Light community engagement
  Future<void> _generateFitnessIntermediateSuggestions(
    SuggestionContext context,
    List<SmartSuggestion> suggestions,
  ) async {
    // Safety warnings (highest priority)
    if (context.hasWeightJump && !context.hasExistingWarnings) {
      suggestions.add(
        SmartSuggestion(
          id: 'weight_jump_warning',
          text: '⚠️ Salto di peso rilevato - fai attenzione alla tecnica',
          type: ContributionType.warning,
          contextType: 'weight_progression',
          priority: 85,
          createdAt: DateTime.now(),
          trigger: 'weight_jump_detected',
        ),
      );
    }

    // PR celebration
    final isPersonalRecord = await _checkPersonalRecord(context);
    if (isPersonalRecord) {
      suggestions.add(
        SmartSuggestion(
          id: 'pr_celebration',
          text: '🎉 Nuovo record personale! Ottimo lavoro!',
          type: ContributionType.tip,
          contextType: 'achievement',
          priority: 75,
          createdAt: DateTime.now(),
          trigger: 'personal_record',
        ),
      );
    }

    // Technique variation tip
    if (context.totalSets >= 4 && _hasVaryingReps(context)) {
      suggestions.add(
        SmartSuggestion(
          id: 'technique_variation',
          text:
              '💪 Pattern ripetizioni variabile - tecnica drop set o piramidale?',
          type: ContributionType.technique,
          contextType: 'rep_variation',
          priority: 60,
          createdAt: DateTime.now(),
          trigger: 'varying_reps',
        ),
      );
    }

    // NOTE: Workout-level reflection messages moved to workout completion flow
    // (shown via snackbar/modal when finishing workout, not on exercise cards)
  }

  /// Fitness expert suggestions: Full community engagement + data corrections
  Future<void> _generateFitnessExpertSuggestions(
    SuggestionContext context,
    List<SmartSuggestion> suggestions,
  ) async {
    // Data corrections (highest priority if qualified)
    if (context.isExperiencedWithExercise &&
        context.exerciseData != null &&
        context.isCompleted) {
      final hasCorrectionType = context.existingContributions.any(
        (c) => c.type == ContributionType.correction,
      );

      if (!hasCorrectionType) {
        final muscles = context.exerciseData?['primaryMuscles'] as List?;
        if (muscles != null && muscles.isNotEmpty) {
          suggestions.add(
            SmartSuggestion(
              id: 'verify_muscles',
              text:
                  '📝 I muscoli target sono corretti? (${muscles.join(", ")})',
              type: ContributionType.correction,
              contextType: 'muscle_groups',
              priority: 95,
              createdAt: DateTime.now(),
              trigger: 'verify_exercise_data',
            ),
          );
        } else {
          suggestions.add(
            SmartSuggestion(
              id: 'add_muscles',
              text: '📝 Aggiungi i muscoli target per questo esercizio',
              type: ContributionType.correction,
              contextType: 'muscle_groups',
              priority: 95,
              createdAt: DateTime.now(),
              trigger: 'missing_muscle_data',
            ),
          );
        }
      }
    }

    // Technique verification
    if (context.isExperiencedWithExercise &&
        context.isCompleted &&
        context.exerciseData != null) {
      final hasTechniqueContribution = context.existingContributions.any(
        (c) => c.type == ContributionType.technique,
      );

      if (!hasTechniqueContribution) {
        suggestions.add(
          SmartSuggestion(
            id: 'verify_technique',
            text:
                '🔧 La tecnica descritta è accurata? Suggerisci miglioramenti',
            type: ContributionType.correction,
            contextType: 'exercise_technique',
            priority: 85,
            createdAt: DateTime.now(),
            trigger: 'verify_technique',
          ),
        );
      }
    }

    // Safety warnings
    if (context.hasWeightJump && !context.hasExistingWarnings) {
      suggestions.add(
        SmartSuggestion(
          id: 'weight_jump_warning',
          text: '⚠️ Salto di peso rilevato - aggiungi un avviso sicurezza?',
          type: ContributionType.warning,
          contextType: 'weight_progression',
          priority: 80,
          createdAt: DateTime.now(),
          trigger: 'weight_jump_detected',
        ),
      );
    }

    // Missing safety info
    if (context.isCompleted && !context.hasExistingWarnings) {
      suggestions.add(
        SmartSuggestion(
          id: 'add_safety_warning',
          text: '⚠️ Aggiungi avvertimenti di sicurezza se ne conosci',
          type: ContributionType.warning,
          contextType: 'safety_info',
          priority: 70,
          createdAt: DateTime.now(),
          trigger: 'missing_safety_warnings',
        ),
      );
    }

    // PR celebration
    final isPersonalRecord = await _checkPersonalRecord(context);
    if (isPersonalRecord) {
      suggestions.add(
        SmartSuggestion(
          id: 'pr_celebration',
          text: '🎉 Nuovo record! La tecnica usata è stata buona?',
          type: ContributionType.technique,
          contextType: 'achievement',
          priority: 65,
          createdAt: DateTime.now(),
          trigger: 'personal_record',
        ),
      );
    }
  }

  /// Check if exercise is a personal record
  Future<bool> _checkPersonalRecord(SuggestionContext context) async {
    if (context.maxWeight == null) return false;

    try {
      final history = await ref.read(
        recentWeightsWithDetailsProvider(context.exercise.name).future,
      );

      if (history.isEmpty) return false;

      // Extract all weights from history and find max
      final historicalWeights = history
          .map((h) => h.weight)
          .whereType<double>()
          .toList();

      if (historicalWeights.isEmpty) return false;

      final historicalMaxWeight = historicalWeights.reduce(
        (a, b) => a > b ? a : b,
      );

      return context.maxWeight! > historicalMaxWeight;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [Suggestions] Error checking PR: $e');
      }
      return false;
    }
  }

  /// Check if exercise has varying reps
  bool _hasVaryingReps(SuggestionContext context) {
    final reps = context.exercise.sets
        .map((s) => s.reps)
        .whereType<int>()
        .toList();

    if (reps.length < 3) return false;

    final maxReps = reps.reduce((a, b) => a > b ? a : b);
    final minReps = reps.reduce((a, b) => a < b ? a : b);

    return (maxReps - minReps) >= 3; // Difference of 3+ reps
  }

  /// Dismiss a suggestion
  void dismissSuggestion(String suggestionId) {
    state = state.where((s) => s.id != suggestionId).toList();

    if (kDebugMode) {
      debugPrint('❌ [Suggestions] Dismissed suggestion: $suggestionId');
    }
  }

  /// Clear all suggestions
  void clearSuggestions() {
    state = [];

    if (kDebugMode) {
      debugPrint('🗑️ [Suggestions] Cleared all suggestions');
    }
  }
}
*/

/// TEMPORARY: Disabled for Riverpod 3.x migration (StateProvider removed)
/// TODO: Migrate to @riverpod codegen
final exerciseSuggestionsProvider =
    Provider.family.autoDispose<List<SmartSuggestion>, String>(
  (ref, exerciseId) => <SmartSuggestion>[],
);

/// Helper provider to determine user level based on contribution count
final userLevelProvider = Provider<UserLevel>((ref) {
  final stats = ref.watch(userContributionStatsProvider);

  return stats.when(
    data: (stats) {
      final count = stats.totalContributions;
      if (count >= 201) return UserLevel.master;
      if (count >= 51) return UserLevel.expert;
      if (count >= 11) return UserLevel.contributor;
      return UserLevel.rookie;
    },
    loading: () => UserLevel.rookie,
    error: (_, __) => UserLevel.rookie,
  );
});
