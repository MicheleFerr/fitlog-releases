/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/widgets
/// Feature: analytics
/// Type: widget
///
/// Muscle Priority Card - Redesigned card for neglected muscle groups
///
/// Shows severity bar, localized muscle name, template selector,
/// and horizontal grid of exercise compact cards.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/template_coverage.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_template_adder.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/last_used_template_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/template_coverage_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_compact_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/priority_explanation_sheet.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Redesigned card for a neglected muscle group.
///
/// Layout: SeverityBar 4px → Header (name, badges, info) → Template dropdown → Exercise grid
class MusclePriorityCard extends ConsumerStatefulWidget {
  const MusclePriorityCard({
    required this.adjustedMuscle,
    required this.suggestions,
    required this.coverage,
    required this.userTemplates,
    this.onExerciseAdded,
    super.key,
  });

  final AdjustedNeglectedMuscle adjustedMuscle;
  final List<ExerciseSuggestion> suggestions;
  final TemplateCoverageResult coverage;
  final List<WorkoutTemplate> userTemplates;
  final VoidCallback? onExerciseAdded;

  @override
  ConsumerState<MusclePriorityCard> createState() =>
      _MusclePriorityCardState();
}

class _MusclePriorityCardState extends ConsumerState<MusclePriorityCard> {
  String? _selectedTemplateId;

  @override
  void initState() {
    super.initState();
    _selectedTemplateId = ref.read(lastUsedTemplateIdProvider) ??
        widget.userTemplates.firstOrNull?.id;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final severityColor = _getSeverityColor(
      context,
      widget.adjustedMuscle.adjustedSeverity,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Severity bar (4px at top)
          _SeverityBar(severity: widget.adjustedMuscle.adjustedSeverity),
          // Header
          _buildHeader(context, severityColor),
          // Template selector
          if (widget.userTemplates.isNotEmpty) _buildTemplateSelector(context),
          const SizedBox(height: 12),
          // Exercise horizontal grid
          if (widget.suggestions.isNotEmpty) _buildExerciseGrid(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color severityColor) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _getLocalizedMuscleName(
                          context,
                          widget.adjustedMuscle.muscleName,
                        ),
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CompactSeverityBadge(
                      severity: widget.adjustedMuscle.adjustedSeverity,
                      wasReduced: widget.adjustedMuscle.wasSeverityReduced,
                    ),
                    if (widget.adjustedMuscle.hasPlannedExercises) ...[
                      const SizedBox(width: 6),
                      _CompactPlannedBadge(),
                    ],
                  ],
                ),
                if (widget.adjustedMuscle.hasPlannedExercises)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${widget.adjustedMuscle.plannedExerciseCount} ${l10n.exerciseSuggestions.toLowerCase()} ${l10n.inTemplates.toLowerCase()}: ${widget.adjustedMuscle.coveringTemplates.join(", ")}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showPriorityExplanation(context),
            icon: Icon(
              AppIcons.info,
              size: AppIconSize.medium,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: l10n.priority,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSelector(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedTemplateId,
        decoration: InputDecoration(
          labelText: l10n.selectTemplate,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          isDense: true,
        ),
        isExpanded: true,
        items: widget.userTemplates
            .map(
              (t) => DropdownMenuItem(
                value: t.id,
                child: Text(t.name, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (id) {
          setState(() => _selectedTemplateId = id);
          ref.read(lastUsedTemplateIdProvider.notifier).state = id;
        },
      ),
    );
  }

  Widget _buildExerciseGrid(BuildContext context) {
    // Determine which exercises are already in the selected template
    final selectedTemplate = _selectedTemplateId != null
        ? widget.userTemplates
              .where((t) => t.id == _selectedTemplateId)
              .firstOrNull
        : null;

    final templateExerciseIds = selectedTemplate?.exercises
            .map((e) => e.exerciseId.toLowerCase())
            .toSet() ??
        <String>{};

    return SizedBox(
      height: ExerciseCompactCard.cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = widget.suggestions[index];
          final isInTemplate = templateExerciseIds.contains(
            suggestion.exerciseId.toLowerCase(),
          );

          return ExerciseCompactCard(
            suggestion: suggestion,
            isInSelectedTemplate: isInTemplate,
            onAdd: () => _addExercise(suggestion),
          );
        },
      ),
    );
  }

  Future<void> _addExercise(ExerciseSuggestion suggestion) async {
    if (_selectedTemplateId == null) return;

    final template = widget.userTemplates
        .where((t) => t.id == _selectedTemplateId)
        .firstOrNull;
    if (template == null) return;

    try {
      await ExerciseTemplateAdder.addSuggestionToTemplate(
        suggestion: suggestion,
        template: template,
        ref: ref,
      );

      HapticFeedback.mediumImpact();
      widget.onExerciseAdded?.call();

      // Refresh template coverage
      ref.invalidate(templateCoverageProvider);

      if (mounted) {
        SnackBarService.showSuccess(
          context,
          context.l10n.exerciseAddedToTemplate(
            suggestion.exerciseName,
            template.name,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, context.l10n.errorAddingExercise);
      }
    }
  }

  void _showPriorityExplanation(BuildContext context) {
    HapticFeedback.selectionClick();
    ModalService.showSheet<void>(
      context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => PriorityExplanationSheet(
        neglectedMuscle: widget.adjustedMuscle.original,
      ),
    );
  }

  Color _getSeverityColor(BuildContext context, NeglectSeverity severity) {
    return switch (severity) {
      NeglectSeverity.critical => context.colors.error,
      NeglectSeverity.high => context.colors.warning,
      NeglectSeverity.medium => context.colors.tertiary,
    };
  }

  /// Maps muscle key to localized full name
  String _getLocalizedMuscleName(BuildContext context, String key) {
    final l10n = context.l10n;
    return switch (key.toLowerCase()) {
      'chest' => l10n.muscleChest,
      'back' => l10n.muscleBack,
      'shoulders' => l10n.muscleShoulders,
      'biceps' => l10n.muscleBiceps,
      'triceps' => l10n.muscleTriceps,
      'forearms' => l10n.muscleForearms,
      'quads' => l10n.muscleQuads,
      'hamstrings' => l10n.muscleHamstrings,
      'glutes' => l10n.muscleGlutes,
      'calves' => l10n.muscleCalves,
      'abs' => l10n.muscleAbs,
      'lower_back' => l10n.muscleLowerBack,
      'rear_delts' => l10n.muscleRearDelts,
      _ => key,
    };
  }
}

/// 4px severity bar at top of card
class _SeverityBar extends StatelessWidget {
  const _SeverityBar({required this.severity});

  final NeglectSeverity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: _colorForSeverity(context, severity),
      ),
    );
  }

  Color _colorForSeverity(BuildContext context, NeglectSeverity s) {
    return switch (s) {
      NeglectSeverity.critical => context.colors.error,
      NeglectSeverity.high => context.colors.warning,
      NeglectSeverity.medium => context.colors.tertiary,
    };
  }
}

/// Compact severity badge
class _CompactSeverityBadge extends StatelessWidget {
  const _CompactSeverityBadge({
    required this.severity,
    this.wasReduced = false,
  });

  final NeglectSeverity severity;
  final bool wasReduced;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = _getSeverityColor(context, severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getSeverityLabel(l10n, severity),
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          if (wasReduced) ...[
            const SizedBox(width: 2),
            Icon(AppIcons.arrowDropDown, size: AppIconSize.tiny, color: color),
          ],
        ],
      ),
    );
  }

  String _getSeverityLabel(dynamic l10n, NeglectSeverity severity) {
    return switch (severity) {
      NeglectSeverity.critical => l10n.severityCritical,
      NeglectSeverity.high => l10n.severityHigh,
      NeglectSeverity.medium => l10n.severityMedium,
    };
  }

  Color _getSeverityColor(BuildContext context, NeglectSeverity severity) {
    return switch (severity) {
      NeglectSeverity.critical => context.colors.error,
      NeglectSeverity.high => context.colors.warning,
      NeglectSeverity.medium => context.colors.tertiary,
    };
  }
}

/// Compact planned badge
class _CompactPlannedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.schedule,
            size: AppIconSize.tiny,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 2),
          Text(
            l10n.planned,
            style: context.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
