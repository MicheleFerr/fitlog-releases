import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Modal for adding a new stage to an existing DropSet
///
/// Features:
/// - Weight input with suggestion based on previous stage drop
/// - Reps input with default from previous stage
/// - Shows current weight for reference
class AddDropsetStageModal extends StatefulWidget {
  const AddDropsetStageModal({
    super.key,
    required this.exerciseName,
    required this.lastStageWeight,
    required this.lastStageReps,
    required this.stageNumber,
  });

  /// Name of the exercise
  final String exerciseName;

  /// Weight of the last completed stage (for suggestion)
  final double lastStageWeight;

  /// Reps of the last completed stage (for default)
  final int lastStageReps;

  /// The new stage number (1-indexed for display)
  final int stageNumber;

  @override
  State<AddDropsetStageModal> createState() => _AddDropsetStageModalState();

  /// Show the modal and return the new stage if confirmed
  static Future<DropSetStage?> show({
    required BuildContext context,
    required String exerciseName,
    required double lastStageWeight,
    required int lastStageReps,
    required int stageNumber,
  }) {
    return showModalBottomSheet<DropSetStage>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => AddDropsetStageModal(
        exerciseName: exerciseName,
        lastStageWeight: lastStageWeight,
        lastStageReps: lastStageReps,
        stageNumber: stageNumber,
      ),
    );
  }
}

class _AddDropsetStageModalState extends State<AddDropsetStageModal> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;

  // Standard weight drops for quick selection
  static const List<double> quickDropValues = [2.5, 5.0, 10.0];

  @override
  void initState() {
    super.initState();

    // Suggest a -5kg drop by default
    final suggestedWeight = (widget.lastStageWeight - 5.0).clamp(
      0.0,
      double.infinity,
    );

    _weightController = TextEditingController(
      text: suggestedWeight > 0 ? suggestedWeight.toStringAsFixed(1) : '',
    );
    _repsController = TextEditingController(
      text: widget.lastStageReps.toString(),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _applyQuickDrop(double dropAmount) {
    final newWeight = (widget.lastStageWeight - dropAmount).clamp(
      0.0,
      double.infinity,
    );
    setState(() {
      _weightController.text = newWeight.toStringAsFixed(1);
    });
  }

  bool _canConfirm() {
    final weight = double.tryParse(_weightController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());
    return weight != null && weight >= 0 && reps != null && reps > 0;
  }

  void _confirm() {
    final weight = double.tryParse(_weightController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());

    if (weight == null || reps == null) return;

    final newStage = DropSetStage(
      weight: weight,
      reps: reps,
      isCompleted: false,
    );

    Navigator.pop(context, newStage);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.7),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.tertiaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.add,
                      color: context.colors.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.addDropsetStage,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Stage ${widget.stageNumber} - ${widget.exerciseName}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(AppIcons.close),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Previous stage info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.info,
                            size: 20,
                            color: context.colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.previousStageInfo(
                              widget.lastStageWeight.toStringAsFixed(1),
                              widget.lastStageReps,
                            ),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick drop chips
                    Text(
                      context.l10n.quickWeightDrop,
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: quickDropValues.map((drop) {
                        return ActionChip(
                          label: Text(
                            '-${drop.toStringAsFixed(drop == 2.5 ? 1 : 0)} kg',
                          ),
                          onPressed: () => _applyQuickDrop(drop),
                          avatar: Icon(
                            AppIcons.arrowDownward,
                            size: 16,
                            color: context.colors.tertiary,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Weight input
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.weight,
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _weightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,1}'),
                                  ),
                                ],
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  suffixText: 'kg',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.reps,
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _repsController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  suffixText: 'reps',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Confirm button
                    FilledButton(
                      onPressed: _canConfirm() ? _confirm : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          context.l10n.addStage,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    SizedBox(height: context.bottomPadding + 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
