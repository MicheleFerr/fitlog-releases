import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/warmup_info_dialog.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Enhanced modal for displaying exercise details with improved aesthetics
/// following Apple HIG and Material Design 3 principles
class ExerciseDetailsModal extends StatelessWidget {

  const ExerciseDetailsModal({
    super.key,
    required this.exercise,
  });
  final Exercise exercise;

  /// Show the modal as a bottom sheet
  static Future<void> show(BuildContext context, Exercise exercise) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseDetailsModal(exercise: exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
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
                    if (exercise.noteTecniche != null) ...[
                      _buildTechnicalNotesSection(context),
                      const SizedBox(height: 24),
                    ],

                    // Warmup Protocol Section
                    if (_hasWarmupProtocol()) ...[
                      _buildWarmupSection(context),
                    ],
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
        // Exercise Name
        Text(
          exercise.nome,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Focus and Equipment Row
        Row(
          children: [
            // Focus Badge
            _buildInfoChip(
              context,
              icon: Icons.fitness_center,
              label: exercise.focusDisplayName,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),

            // Difficulty Badge
            _buildDifficultyChip(context),
          ],
        ),

        const SizedBox(height: 8),

        // Equipment
        _buildInfoChip(
          context,
          icon: Icons.sports_gymnastics,
          label: exercise.attrezzatura,
          color: context.colors.tertiary,
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(BuildContext context) {
    final color = _getDifficultyColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        exercise.difficolta,
        style: context.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getDifficultyColor(BuildContext context) {
    switch (exercise.difficolta.toLowerCase()) {
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
                child: Icon(
                  Icons.lightbulb_outline,
                  size: 20,
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
          ..._buildFormattedSteps(context, exercise.noteTecniche!),
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
                child: Icon(
                  Icons.wb_sunny_outlined,
                  size: 20,
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
                  Icons.info_outline,
                  color: context.colors.primary,
                  size: 20,
                ),
                tooltip: context.l10n.warmupPhaseInfo,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Warmup Phases
          if (exercise.mobilitaPre != null) ...[
            _buildWarmupPhase(
              context,
              icon: '🔄',
              title: context.l10n.warmupPhase1Title.replaceAll('🔄 ', ''),
              content: exercise.mobilitaPre!,
            ),
            const SizedBox(height: 12),
          ],

          if (exercise.attivazionePre != null) ...[
            _buildWarmupPhase(
              context,
              icon: '⚡',
              title: context.l10n.warmupPhase2Title.replaceAll('⚡ ', ''),
              content: exercise.attivazionePre!,
            ),
            const SizedBox(height: 12),
          ],

          if (exercise.warmupSets != null) ...[
            _buildWarmupPhase(
              context,
              icon: '🏋️',
              title: context.l10n.warmupSetsLabel,
              content: exercise.warmupSets!,
              isMonospace: true,
            ),
            const SizedBox(height: 12),
          ],

          if (exercise.tempoWarmup != null) ...[
            _buildWarmupPhase(
              context,
              icon: '⏱️',
              title: context.l10n.warmupTimeLabel,
              content: exercise.tempoWarmup!,
            ),
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
              Text(
                icon,
                style: const TextStyle(fontSize: 18),
              ),
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
        padding: EdgeInsets.only(
          bottom: index < steps.length - 1 ? 12 : 0,
        ),
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
    return exercise.mobilitaPre != null ||
        exercise.attivazionePre != null ||
        exercise.warmupSets != null ||
        exercise.tempoWarmup != null;
  }
}
