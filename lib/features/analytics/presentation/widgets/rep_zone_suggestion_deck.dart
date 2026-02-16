/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/widgets
/// Feature: analytics
/// Type: widget
///
/// Rep Zone Suggestion Deck v2 - Tinder-style swipe cards with tap-to-expand
///
/// **v2 Changes**:
/// - Uses RepZoneSuggestionCard with tap-to-expand
/// - Supports alternative exercise selection
/// - Up to 10 suggestions (from 5)
///
/// **UX Research**:
/// - Swipe right → Add exercise to template
/// - Swipe left → Skip
/// - Tap → Expand for details + alternatives
/// - Button fallback for accessibility
library;

import 'dart:async';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/rep_zone_suggestion.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_recommendation_service.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/rep_zone_suggestion_card.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Rep Zone Suggestion Deck v2 - Swipeable cards with tap-to-expand
class RepZoneSuggestionDeck extends ConsumerStatefulWidget {
  const RepZoneSuggestionDeck({
    required this.suggestions,
    required this.onComplete,
    this.onSuggestionAdded,
    this.onExerciseAdded,
    super.key,
  });

  /// List of suggestions to show
  final List<RepZoneSuggestion> suggestions;

  /// Called when all cards are swiped
  final VoidCallback onComplete;

  /// Called when an exercise is added to a template
  final VoidCallback? onSuggestionAdded;

  /// Called with exercise ID when an exercise is added (for tracking)
  final void Function(String exerciseId)? onExerciseAdded;

  @override
  ConsumerState<RepZoneSuggestionDeck> createState() =>
      _RepZoneSuggestionDeckState();
}

class _RepZoneSuggestionDeckState extends ConsumerState<RepZoneSuggestionDeck> {
  late final AppinioSwiperController _controller;
  int _currentIndex = 0;
  int _addedCount = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AppinioSwiperController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Column(
      children: [
        // Header with progress
        _buildHeader(context),
        const SizedBox(height: 16),

        // Swipe deck
        Expanded(
          child: AppinioSwiper(
            controller: _controller,
            cardCount: widget.suggestions.length,
            swipeOptions: const SwipeOptions.symmetric(horizontal: true),
            loop: false,
            backgroundCardCount: 2,
            onSwipeEnd: _onSwipeEnd,
            onEnd: () {
              HapticFeedback.mediumImpact();
              widget.onComplete();
            },
            cardBuilder: (context, index) {
              final suggestion = widget.suggestions[index];
              return RepZoneSuggestionCard(
                suggestion: suggestion,
                isTop: index == _currentIndex,
                onAdd: () => _controller.swipeRight(),
                onSkip: () => _controller.swipeLeft(),
                onAlternativeSelected: (alt) =>
                    _addAlternativeExercise(suggestion, alt),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Action buttons (accessibility fallback)
        _buildActionButtons(context),
        const SizedBox(height: 8),

        // Instructions
        Text(
          l10n.swipeInstructions,
          style: context.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Progress indicator
        Text(
          '${_currentIndex + 1}/${widget.suggestions.length}',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        // Added count badge
        if (_addedCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.checkCircle,
                  size: AppIconSize.small,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.addedCount(_addedCount),
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Skip button
        _ActionButton(
          icon: AppIcons.close,
          color: colorScheme.error,
          onTap: _isProcessing ? null : () => _controller.swipeLeft(),
          label: context.l10n.skip,
        ),

        // Add button
        _ActionButton(
          icon: AppIcons.check,
          color: colorScheme.primary,
          onTap: _isProcessing ? null : () => _controller.swipeRight(),
          label: context.l10n.add,
          isPrimary: true,
        ),
      ],
    );
  }

  void _onSwipeEnd(
    int previousIndex,
    int targetIndex,
    SwiperActivity activity,
  ) {
    if (activity is Swipe) {
      setState(() {
        _currentIndex = targetIndex;
      });

      if (activity.direction == AxisDirection.right) {
        // Add exercise to template
        _addExerciseToTemplate(widget.suggestions[previousIndex]);
      } else if (activity.direction == AxisDirection.left) {
        // Skip - just haptic feedback
        HapticFeedback.lightImpact();
      }
    }
  }

  Future<void> _addExerciseToTemplate(RepZoneSuggestion suggestion) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Get the template
      final templates = await ref.read(customWorkoutTemplatesProvider.future);
      final targetTemplate = templates.firstWhere(
        (t) => t.id == suggestion.targetTemplateId,
        orElse: () => templates.first,
      );

      // Get personalized volume
      final questionnaire = ref.read(userFitnessQuestionnaireProvider);
      const volumeService = VolumeRecommendationService();

      final VolumeRecommendation volume;
      if (questionnaire != null) {
        volume = volumeService.calculate(
          experience: questionnaire.experienceLevel,
          goal: questionnaire.trainingGoal,
          hasInjuryHistory: questionnaire.hasInjuryHistory,
        );
      } else {
        volume = VolumeRecommendation(
          sets: suggestion.recommendedSets,
          reps: suggestion.recommendedReps,
          restSeconds: suggestion.recommendedRestSeconds,
        );
      }

      // Create exercise template
      final sets = List.generate(
        volume.sets,
        (index) => SetTemplate(
          setNumber: index + 1,
          targetReps: suggestion.recommendedReps,
        ),
      );

      final newExercise = ExerciseTemplate(
        exerciseId: suggestion.exerciseId,
        exerciseName: suggestion.exerciseName,
        category: MuscleAbbreviationMapper.focusListToExerciseCategory(
          suggestion.musclesFocus,
        ),
        type: ExerciseType.single,
        sets: sets,
        restTime: suggestion.recommendedRestSeconds,
        countingMode: suggestion.countingMode,
      );

      // Add to template
      final updatedExercises = [...targetTemplate.exercises, newExercise];
      final updatedTemplate = targetTemplate.copyWith(
        exercises: updatedExercises,
        updatedAt: DateTime.now(),
      );

      await ref
          .read(workoutTemplateNotifierProvider.notifier)
          .saveTemplate(updatedTemplate);

      // Update state
      if (mounted) {
        setState(() {
          _addedCount++;
          _isProcessing = false;
        });
      }

      await HapticFeedback.mediumImpact();
      widget.onSuggestionAdded?.call();
      widget.onExerciseAdded?.call(suggestion.exerciseId);

      if (mounted) {
        SnackBarService.showSuccess(
          context,
          context.l10n.exerciseAddedToTemplate(
            suggestion.exerciseName,
            suggestion.targetTemplate,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        SnackBarService.showError(context, context.l10n.errorAddingExercise);
      }
    }
  }

  /// Add an alternative exercise instead of the main suggestion
  Future<void> _addAlternativeExercise(
    RepZoneSuggestion mainSuggestion,
    AlternativeExercise alternative,
  ) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Get the template
      final templates = await ref.read(customWorkoutTemplatesProvider.future);
      final targetTemplate = templates.firstWhere(
        (t) => t.id == mainSuggestion.targetTemplateId,
        orElse: () => templates.first,
      );

      // Get personalized volume
      final questionnaire = ref.read(userFitnessQuestionnaireProvider);
      const volumeService = VolumeRecommendationService();

      final VolumeRecommendation volume;
      if (questionnaire != null) {
        volume = volumeService.calculate(
          experience: questionnaire.experienceLevel,
          goal: questionnaire.trainingGoal,
          hasInjuryHistory: questionnaire.hasInjuryHistory,
        );
      } else {
        volume = VolumeRecommendation(
          sets: mainSuggestion.recommendedSets,
          reps: mainSuggestion.recommendedReps,
          restSeconds: mainSuggestion.recommendedRestSeconds,
        );
      }

      // Create exercise template from alternative
      final sets = List.generate(
        volume.sets,
        (index) => SetTemplate(
          setNumber: index + 1,
          targetReps: mainSuggestion.recommendedReps,
        ),
      );

      final newExercise = ExerciseTemplate(
        exerciseId: alternative.exerciseId,
        exerciseName: alternative.exerciseName,
        category: MuscleAbbreviationMapper.focusListToExerciseCategory(
          mainSuggestion.musclesFocus,
        ),
        type: ExerciseType.single,
        sets: sets,
        restTime: mainSuggestion.recommendedRestSeconds,
        countingMode: alternative.countingMode,
      );

      // Add to template
      final updatedExercises = [...targetTemplate.exercises, newExercise];
      final updatedTemplate = targetTemplate.copyWith(
        exercises: updatedExercises,
        updatedAt: DateTime.now(),
      );

      await ref
          .read(workoutTemplateNotifierProvider.notifier)
          .saveTemplate(updatedTemplate);

      // Update state
      if (mounted) {
        setState(() {
          _addedCount++;
          _isProcessing = false;
        });
      }

      await HapticFeedback.mediumImpact();
      widget.onSuggestionAdded?.call();
      widget.onExerciseAdded?.call(alternative.exerciseId);

      // Advance to next card
      unawaited(_controller.swipeRight());

      if (mounted) {
        SnackBarService.showSuccess(
          context,
          context.l10n.exerciseAddedToTemplate(
            alternative.exerciseName,
            mainSuggestion.targetTemplate,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        SnackBarService.showError(context, context.l10n.errorAddingExercise);
      }
    }
  }
}

/// Action button for skip/add
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.label,
    this.isPrimary = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: isPrimary ? color : color.withValues(alpha: 0.1),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: isPrimary ? context.colors.onPrimary : color,
                size: AppIconSize.medium,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
