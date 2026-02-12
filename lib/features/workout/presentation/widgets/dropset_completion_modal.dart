import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Modal shown after completing all stages of a DropSet
///
/// Features:
/// - Summary of all completed stages (weight, reps)
/// - Total volume calculation
/// - Final RPE selection for the overall dropset effort
class DropSetCompletionModal extends ConsumerStatefulWidget {
  const DropSetCompletionModal({
    super.key,
    required this.exerciseName,
    required this.stages,
  });

  final String exerciseName;
  final List<DropSetStage> stages;

  /// Static method to show modal and return final RPE
  static Future<int?> show({
    required BuildContext context,
    required String exerciseName,
    required List<DropSetStage> stages,
  }) {
    return ModalService.showSheet<int>(context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) =>
          DropSetCompletionModal(exerciseName: exerciseName, stages: stages),
    );
  }

  @override
  ConsumerState<DropSetCompletionModal> createState() =>
      _DropSetCompletionModalState();
}

class _DropSetCompletionModalState
    extends ConsumerState<DropSetCompletionModal> {
  int? _selectedRpe;

  /// Calculate total volume (weight × reps for all stages)
  double get _totalVolume {
    return widget.stages.fold(0.0, (sum, stage) {
      return sum + (stage.weight * stage.effectiveReps);
    });
  }

  /// Calculate total reps across all stages
  int get _totalReps {
    return widget.stages.fold(0, (sum, stage) => sum + stage.effectiveReps);
  }

  /// Get RPE color based on value
  Color _getRpeColor(int rpe) {
    switch (rpe) {
      case 6:
      case 7:
        return context.colors.success;
      case 8:
        return context.colors.warning;
      case 9:
      case 10:
        return context.colors.error;
      default:
        return context.colors.primary;
    }
  }

  /// Get RPE emoji
  String _getRpeEmoji(int rpe) {
    switch (rpe) {
      case 6:
        return '😌';
      case 7:
        return '😊';
      case 8:
        return '😤';
      case 9:
        return '😰';
      case 10:
        return '🔥';
      default:
        return '💪';
    }
  }

  /// Get RPE short label
  String _getRpeShortLabel(int rpe) {
    switch (rpe) {
      case 6:
        return 'Easy';
      case 7:
        return 'Moderate';
      case 8:
        return 'Hard';
      case 9:
        return 'Very Hard';
      case 10:
        return 'Max';
      default:
        return '';
    }
  }

  void _confirmWithRpe(int rpe) {
    HapticFeedback.mediumImpact();
    Navigator.pop(context, rpe);
  }

  @override
  Widget build(BuildContext context) {
    final useRir = ref.watch(useRirModeProvider);

    return Container(
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.85),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with success icon
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: SemanticIcon(
                      icon: AppIcons.checkCircle,
                      semanticLabel: 'Completed',
                      size: AppIconSize.medium,
                      color: context.colors.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.dropsetCompleted,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.exerciseName,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stages summary
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary card
                    _buildSummaryCard(),

                    const SizedBox(height: 16),

                    // Stages list
                    _buildStagesList(),

                    const SizedBox(height: 20),

                    // RPE selector
                    _buildRpeSection(useRir),

                    const SizedBox(height: 20),

                    // Action buttons
                    _buildActionButtons(),

                    SizedBox(height: context.bottomPadding + 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primaryContainer.withValues(alpha: 0.3),
            context.colors.primaryContainer.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Stages count
          Expanded(
            child: _buildSummaryItem(
              icon: AppIcons.layers,
              label: context.l10n.stages,
              value: '${widget.stages.length}',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: context.colors.outline.withValues(alpha: 0.2),
          ),
          // Total reps
          Expanded(
            child: _buildSummaryItem(
              icon: AppIcons.repeat,
              label: context.l10n.totalReps,
              value: '$_totalReps',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: context.colors.outline.withValues(alpha: 0.2),
          ),
          // Total volume
          Expanded(
            child: _buildSummaryItem(
              icon: AppIcons.analytics,
              label: context.l10n.volume,
              value: '${_totalVolume.toStringAsFixed(0)} kg',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        SemanticIcon(
          icon: icon,
          semanticLabel: label,
          size: AppIconSize.small,
          color: context.colors.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.primary,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStagesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.stagesBreakdown,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.stages.asMap().entries.map((entry) {
          final index = entry.key;
          final stage = entry.value;
          return _buildStageRow(index, stage);
        }),
      ],
    );
  }

  Widget _buildStageRow(int index, DropSetStage stage) {
    final volume = stage.weight * stage.effectiveReps;
    final isFirst = index == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirst
              ? context.colors.primary.withValues(alpha: 0.3)
              : context.colors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Stage number badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isFirst
                  ? context.colors.primary.withValues(alpha: 0.1)
                  : context.colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isFirst
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Weight
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stage.weight.toStringAsFixed(1)} kg',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.l10n.weight,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Reps
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stage.effectiveReps}',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.l10n.reps,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Volume
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${volume.toStringAsFixed(0)} kg',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.tertiary,
                ),
              ),
              Text(
                context.l10n.volume,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),

          // Weight drop indicator (not for first stage)
          if (!isFirst) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '↓${(widget.stages[index - 1].weight - stage.weight).toStringAsFixed(1)}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRpeSection(bool useRir) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                useRir ? context.l10n.rir : context.l10n.rpe,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(useRir ? context.l10n.rir : context.l10n.rpe),
                      content: Text(
                        useRir
                            ? context.l10n.rirDescription
                            : context.l10n.rpeDescription,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: SemanticIcon(
                  icon: AppIcons.info,
                  semanticLabel: 'Info',
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.howHardWasTheDropset,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          // RPE buttons - same style as RpeSelectorBottomSheet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final rpe = index + 6;
              final isSelected = _selectedRpe == rpe;
              final displayValue = useRir ? rpeToRir(rpe.toDouble()) : rpe;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRpe = rpe;
                      });
                      // Auto-confirm after small delay
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (mounted) {
                          _confirmWithRpe(rpe);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 75,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  _getRpeColor(rpe),
                                  _getRpeColor(rpe).withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: !isSelected
                            ? context.colors.surfaceContainerHighest.withValues(
                                alpha: 0.5,
                              )
                            : null,
                        border: Border.all(
                          color: isSelected
                              ? _getRpeColor(rpe)
                              : context.colors.outline.withValues(alpha: 0.3),
                          width: isSelected ? 2.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _getRpeColor(
                                    rpe,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getRpeEmoji(rpe),
                            style: context.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$displayValue',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? context.colors.surface
                                  : context.colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _getRpeShortLabel(rpe),
                            style: context.textTheme.bodySmall?.copyWith(
                              fontSize: 9,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? context.colors.surface.withValues(
                                      alpha: 0.95,
                                    )
                                  : context.colors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Skip RPE button
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context, 0); // 0 = skipped RPE
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: context.colors.outline.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              context.l10n.skipRpe,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Confirm button (enabled if RPE selected)
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: _selectedRpe != null
                ? () => _confirmWithRpe(_selectedRpe!)
                : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedRpe != null) ...[
                  const SemanticIcon(
                    icon: AppIcons.complete,
                    semanticLabel: 'Complete',
                    size: AppIconSize.small,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  context.l10n.confirmSet,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
