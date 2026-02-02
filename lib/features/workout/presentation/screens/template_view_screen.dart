import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/edit_template_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Read-only view screen for workout templates
///
/// Designed for "presentation mode" - showing templates to others
/// without the edit interface clutter.
///
/// Features:
/// - Compact-Smart display: groups sets intelligently
/// - Clean, distraction-free layout
/// - FAB for starting workout
/// - Edit action in AppBar menu
class TemplateViewScreen extends ConsumerWidget {
  const TemplateViewScreen({super.key, required this.templateId});

  final String templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all custom templates and find the one we need
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

    return templatesAsync.when(
      data: (templates) {
        final template = templates.where((t) => t.id == templateId).firstOrNull;

        if (template == null) {
          return _buildNotFoundScreen(context);
        }

        return _TemplateViewContent(template: template);
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: LoadingIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('${context.l10n.errorGeneric}: $error')),
      ),
    );
  }

  Widget _buildNotFoundScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.error,
              semanticLabel: context.l10n.errorGeneric,
              size: 64,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.templateNotFound,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pop(),
              child: Text(context.l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateViewContent extends ConsumerWidget {
  const _TemplateViewContent({required this.template});

  final WorkoutTemplate template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(template.name),
        actions: [
          // Edit action in menu
          PopupMenuButton<String>(
            icon: SemanticIcon(
              icon: AppIcons.menu,
              semanticLabel: context.l10n.menuOptions,
              size: AppIconSize.medium,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _navigateToEdit(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    SemanticIcon(
                      icon: AppIcons.edit,
                      semanticLabel: context.l10n.edit,
                      size: AppIconSize.small,
                    ),
                    const SizedBox(width: 12),
                    Text(context.l10n.edit),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Presentation mode banner
          _buildPresentationBanner(context),

          // Template info header
          _buildTemplateHeader(context),

          // Exercise list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: template.exercises.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final exercise = template.exercises[index];
                return _ExerciseViewTile(exercise: exercise, index: index + 1);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border(
              top: BorderSide(
                color: context.colors.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: FilledButton.icon(
            onPressed: () => _startWorkout(context, ref),
            icon: SemanticIcon(
              icon: AppIcons.play,
              semanticLabel: context.l10n.startWorkout,
              size: AppIconSize.medium,
            ),
            label: Text(context.l10n.startWorkout),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              textStyle: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresentationBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: context.colors.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.visibility,
            semanticLabel: context.l10n.templateViewMode,
            size: AppIconSize.small,
            color: context.colors.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.templateViewMode,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colors.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description (if present)
          if (template.description.isNotEmpty) ...[
            Text(
              template.description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Metadata row
          Row(
            children: [
              _buildMetadataChip(
                context,
                icon: AppIcons.workout,
                label: context.l10n.exerciseCount(template.exercises.length),
              ),
              const SizedBox(width: 12),
              _buildMetadataChip(
                context,
                icon: AppIcons.timer,
                label: '~${template.estimatedDuration} min',
              ),
              if (template.difficulty != null) ...[
                const SizedBox(width: 12),
                _buildMetadataChip(
                  context,
                  icon: AppIcons.analytics,
                  label: template.difficulty!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
            icon: icon,
            semanticLabel: label,
            size: AppIconSize.tiny,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditTemplateScreen(template: template),
      ),
    );
  }

  void _startWorkout(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    // Pop back and trigger workout start
    // The parent screen handles the actual workout start logic
    context.pop(template);
  }
}

/// Display tile for a single exercise in view mode
///
/// Uses Compact-Smart display logic:
/// - Same weight, same reps: "80kg: 10 • 10 • 10 • 10"
/// - Same weight, different reps: "60kg: 12 • 10 • 8"
/// - Different weights: one line per weight
/// - Drop sets: arrows "20kg ×10 → 15kg ×12 → 10kg ×15"
class _ExerciseViewTile extends StatelessWidget {
  const _ExerciseViewTile({required this.exercise, required this.index});

  final ExerciseTemplate exercise;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Row(
            children: [
              // Index number
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Exercise name and type indicator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.exerciseName,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (exercise.type != ExerciseType.single)
                      Text(
                        _getTypeLabel(context, exercise.type),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                  ],
                ),
              ),

              // Rest time badge
              if (exercise.restTime != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${exercise.restTime}s',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Sets display with Compact-Smart logic
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: _buildSetsDisplay(context),
          ),

          // TUT indicator (if present)
          if (exercise.tut != null && exercise.tut!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: Text(
                'TUT: ${exercise.tut}',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Notes (if present)
          if (exercise.notes != null && exercise.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: Text(
                exercise.notes!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTypeLabel(BuildContext context, ExerciseType type) {
    switch (type) {
      case ExerciseType.superset:
        return 'Superset';
      case ExerciseType.dropset:
        return 'Drop Set';
      case ExerciseType.restPause:
        return 'Rest-Pause';
      case ExerciseType.single:
        return '';
    }
  }

  Widget _buildSetsDisplay(BuildContext context) {
    final sets = exercise.sets;

    if (sets.isEmpty) {
      return Text(
        context.l10n.noSetsConfigured,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Check if this is a drop set type
    if (exercise.type == ExerciseType.dropset) {
      return _buildDropSetDisplay(context, sets);
    }

    // Group sets by weight for Compact-Smart display
    return _buildCompactSmartDisplay(context, sets);
  }

  /// Drop set display: "20kg ×10 → 15kg ×12 → 10kg ×15"
  Widget _buildDropSetDisplay(BuildContext context, List<SetTemplate> sets) {
    final parts = sets.map((s) {
      final weight = s.targetWeight != null
          ? '${_formatWeight(s.targetWeight!)}'
          : '?';
      final reps = s.targetReps != null ? '×${s.targetReps}' : '';
      return '$weight$reps';
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        parts.join(' → '),
        style: context.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Compact-Smart display logic
  Widget _buildCompactSmartDisplay(
    BuildContext context,
    List<SetTemplate> sets,
  ) {
    // Group sets by weight
    final Map<double?, List<SetTemplate>> groupedByWeight = {};

    for (final set in sets) {
      final weight = set.targetWeight;
      groupedByWeight.putIfAbsent(weight, () => []).add(set);
    }

    // If all sets have the same weight, show compact format
    if (groupedByWeight.length == 1) {
      final weight = groupedByWeight.keys.first;
      final setsForWeight = groupedByWeight[weight]!;
      return _buildSingleWeightRow(context, weight, setsForWeight);
    }

    // Multiple weights - show one row per weight
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedByWeight.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildSingleWeightRow(context, entry.key, entry.value),
        );
      }).toList(),
    );
  }

  /// Build a single row for sets with the same weight
  /// Format: "80kg: 10 • 10 • 10" or "80kg: ×10 ×10 ×10"
  Widget _buildSingleWeightRow(
    BuildContext context,
    double? weight,
    List<SetTemplate> sets,
  ) {
    final weightStr = weight != null ? _formatWeight(weight) : '—';
    final repsStr = sets
        .map((s) => s.targetReps?.toString() ?? '?')
        .join(' • ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Weight
          Text(
            weightStr,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          // Reps
          Expanded(
            child: Text(
              repsStr,
              style: context.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatWeight(double weight) {
    // Remove decimal if it's a whole number
    if (weight == weight.roundToDouble()) {
      return '${weight.toInt()}kg';
    }
    return '${weight.toStringAsFixed(1)}kg';
  }
}
