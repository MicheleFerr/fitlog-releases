import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/warmup_info_dialog.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/warmup_suggestion_chips.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/warmup_suggestion.dart';

/// Enhanced modal for displaying exercise details with improved aesthetics
/// following Apple HIG and Material Design 3 principles
class ExerciseDetailsModal extends StatefulWidget {
  const ExerciseDetailsModal({
    super.key,
    required this.exercise,
    this.currentExerciseIndex,
    this.onWarmupExerciseAdded,
  });

  final Exercise exercise;
  final int? currentExerciseIndex;
  final void Function(WarmupSuggestion suggestion, int beforeIndex)?
  onWarmupExerciseAdded;

  /// Show the modal as a bottom sheet
  static Future<void> show(
    BuildContext context,
    Exercise exercise, {
    int? currentExerciseIndex,
    void Function(WarmupSuggestion, int)? onWarmupExerciseAdded,
  }) {
    return ModalService.showSheet(context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => ExerciseDetailsModal(
        exercise: exercise,
        currentExerciseIndex: currentExerciseIndex,
        onWarmupExerciseAdded: onWarmupExerciseAdded,
      ),
    );
  }

  @override
  State<ExerciseDetailsModal> createState() => _ExerciseDetailsModalState();
}

class _ExerciseDetailsModalState extends State<ExerciseDetailsModal> {
  final Set<String> _addedExerciseIds = {};

  @override
  Widget build(BuildContext context) {
    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.9);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: safeMax,
      minChildSize: 0.5,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            _buildHandleBar(context),

            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context),
                    const SizedBox(height: 24),

                    // Technical Notes Section
                    if (widget.exercise.noteTecniche != null) ...[
                      _buildTechnicalNotesSection(context),
                      const SizedBox(height: 24),
                    ],

                    // Warmup Protocol Section
                    if (_hasWarmupProtocol()) ...[_buildWarmupSection(context)],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 20),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.colors.onSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise Name - Large title
        Text(
          widget.exercise.nome,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),

        // Full-width info section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Focus Row
              _buildInfoRow(
                context,
                icon: AppIcons.workout,
                label: context.l10n.primaryMuscle,
                value: widget.exercise.focusDisplayName,
              ),
              _buildDivider(context),

              // Equipment Row
              _buildInfoRow(
                context,
                icon: AppIcons.sportsGymnastics,
                label: context.l10n.equipment,
                value: widget.exercise.attrezzatura,
              ),
              _buildDivider(context),

              // Difficulty Row
              _buildInfoRow(
                context,
                icon: AppIcons.barChart,
                label: context.l10n.difficulty,
                value: widget.exercise.difficolta,
                valueColor: _getDifficultyColor(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: context.colors.primary),
          ),
          const SizedBox(width: 12),

          // Label
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),

          const Spacer(),

          // Value
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: valueColor ?? context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.colors.outline.withValues(alpha: 0.1),
    );
  }

  Color _getDifficultyColor(BuildContext context) {
    switch (widget.exercise.difficolta.toLowerCase()) {
      case 'principiante':
        return context.colors.success;
      case 'intermedio':
        return context.colors.secondary;
      case 'avanzato':
        return context.colors.error;
      default:
        return context.colors.onSurface;
    }
  }

  Widget _buildTechnicalNotesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SemanticIcon(
                  icon: AppIcons.tip,
                  semanticLabel: 'Tip',
                  size: AppIconSize.small,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.technicalNotes,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Steps
          ..._buildFormattedSteps(context, widget.exercise.noteTecniche!),
        ],
      ),
    );
  }

  Widget _buildWarmupSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Info Button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SemanticIcon(
                  icon: AppIcons.wbSunnyOutlined,
                  semanticLabel: 'Wb sunny outlined',
                  size: AppIconSize.small,
                  color: context.colors.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.warmupProtocol,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => WarmupInfoDialog.show(context),
                icon: Icon(
                  AppIcons.info,
                  color: context.colors.primary,
                  size: 20,
                ),
                tooltip: context.l10n.warmupPhaseInfo,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Structured chips (if available and callback provided)
          if (widget.exercise.warmupSuggestions?.isNotEmpty == true &&
              widget.onWarmupExerciseAdded != null) ...[
            WarmupSuggestionChips(
              suggestions: widget.exercise.warmupSuggestions!,
              addedExerciseIds: _addedExerciseIds,
              onAdd: _handleAddWarmupExercise,
            ),
            const SizedBox(height: 16),
          ],

          // Warmup Phases
          if (widget.exercise.mobilitaPre != null) ...[
            _buildWarmupPhase(
              context,
              icon: '🔄',
              title: context.l10n.warmupPhase1Title.replaceAll('🔄 ', ''),
              content: widget.exercise.mobilitaPre!,
            ),
            const SizedBox(height: 12),
          ],

          if (widget.exercise.attivazionePre != null) ...[
            _buildWarmupPhase(
              context,
              icon: '⚡',
              title: context.l10n.warmupPhase2Title.replaceAll('⚡ ', ''),
              content: widget.exercise.attivazionePre!,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildWarmupPhase(
    BuildContext context, {
    required String icon,
    required String title,
    required String content,
    bool isMonospace = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: context.textTheme.bodyLarge),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.8),
              fontFamily: isMonospace ? 'monospace' : null,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFormattedSteps(BuildContext context, String text) {
    final steps = text
        .split(' | ')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (steps.isEmpty) {
      return [
        Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ];
    }

    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;

      return Padding(
        padding: EdgeInsets.only(bottom: index < steps.length - 1 ? 12 : 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  bool _hasWarmupProtocol() {
    return widget.exercise.mobilitaPre != null ||
        widget.exercise.attivazionePre != null;
  }

  void _handleAddWarmupExercise(WarmupSuggestion suggestion) {
    if (widget.currentExerciseIndex == null ||
        widget.onWarmupExerciseAdded == null) {
      return;
    }

    setState(() {
      _addedExerciseIds.add(suggestion.exerciseId);
    });

    widget.onWarmupExerciseAdded!(suggestion, widget.currentExerciseIndex!);

    SnackBarService.showSuccess(
      context,
      context.l10n.warmupExerciseAddedBefore(
        suggestion.exerciseName,
        widget.exercise.nome,
      ),
    );
  }
}
