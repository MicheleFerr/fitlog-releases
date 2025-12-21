import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Modal for adding a new set to an existing Rest-Pause exercise
///
/// Features:
/// - Reps input with suggestion based on previous sets
/// - Rest time configuration
/// - Shows current progress for reference
class AddRestPauseSetModal extends StatefulWidget {
  const AddRestPauseSetModal({
    super.key,
    required this.exerciseName,
    required this.weight,
    required this.targetReps,
    required this.completedSets,
    required this.setNumber,
    this.defaultRestSeconds = 15,
  });

  /// Name of the exercise
  final String exerciseName;

  /// Weight being used
  final double weight;

  /// Target total reps
  final int targetReps;

  /// List of already completed sets
  final List<RestPauseSet> completedSets;

  /// The new set number (1-indexed for display)
  final int setNumber;

  /// Default rest time in seconds
  final int defaultRestSeconds;

  @override
  State<AddRestPauseSetModal> createState() => _AddRestPauseSetModalState();

  /// Show the modal and return the new set if confirmed
  static Future<RestPauseSet?> show({
    required BuildContext context,
    required String exerciseName,
    required double weight,
    required int targetReps,
    required List<RestPauseSet> completedSets,
    required int setNumber,
    int defaultRestSeconds = 15,
  }) {
    return showModalBottomSheet<RestPauseSet>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddRestPauseSetModal(
        exerciseName: exerciseName,
        weight: weight,
        targetReps: targetReps,
        completedSets: completedSets,
        setNumber: setNumber,
        defaultRestSeconds: defaultRestSeconds,
      ),
    );
  }
}

class _AddRestPauseSetModalState extends State<AddRestPauseSetModal> {
  late final TextEditingController _repsController;
  late final TextEditingController _restController;

  // Quick rep suggestions based on decreasing pattern
  List<int> get quickRepSuggestions {
    if (widget.completedSets.isEmpty) return [8, 6, 4];

    final lastReps = widget.completedSets.last.effectiveReps;
    // Suggest decreasing reps for rest-pause
    return [
      (lastReps * 0.75).round().clamp(1, lastReps),
      (lastReps * 0.5).round().clamp(1, lastReps),
      (lastReps * 0.25).round().clamp(1, lastReps - 1),
    ].toSet().toList(); // Remove duplicates
  }

  int get totalRepsCompleted =>
      widget.completedSets.fold(0, (sum, s) => sum + s.effectiveReps);

  int get repsRemaining => (widget.targetReps - totalRepsCompleted).clamp(0, widget.targetReps);

  @override
  void initState() {
    super.initState();

    // Suggest reps based on remaining to target
    final suggestedReps = repsRemaining > 0
        ? repsRemaining.clamp(1, 10)
        : (widget.completedSets.isNotEmpty
            ? (widget.completedSets.last.effectiveReps * 0.5).round().clamp(1, 10)
            : 5);

    _repsController = TextEditingController(text: suggestedReps.toString());
    _restController = TextEditingController(text: widget.defaultRestSeconds.toString());
  }

  @override
  void dispose() {
    _repsController.dispose();
    _restController.dispose();
    super.dispose();
  }

  void _applyQuickReps(int reps) {
    setState(() {
      _repsController.text = reps.toString();
    });
    HapticFeedback.selectionClick();
  }

  bool _canConfirm() {
    final reps = int.tryParse(_repsController.text.trim());
    final rest = int.tryParse(_restController.text.trim());
    return reps != null && reps > 0 && rest != null && rest >= 0;
  }

  void _confirm() {
    final reps = int.tryParse(_repsController.text.trim());
    final rest = int.tryParse(_restController.text.trim());

    if (reps == null || rest == null) return;

    final newSet = RestPauseSet(
      reps: reps,
      restSeconds: rest,
      actualReps: reps,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    HapticFeedback.mediumImpact();
    Navigator.pop(context, newSet);
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.targetReps > 0
        ? (totalRepsCompleted / widget.targetReps).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: context.screenHeight * 0.75,
      ),
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
                      color: context.colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.add,
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.addRestPauseSet,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Set ${widget.setNumber} - ${widget.exerciseName}',
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
                    // Progress info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    AppIcons.fitnessCenter,
                                    size: 20,
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${widget.weight.toStringAsFixed(1)} kg',
                                    style: context.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$totalRepsCompleted / ${widget.targetReps} reps',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: progress >= 1.0
                                      ? context.colors.success
                                      : context.colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: context.colors.outline.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation(
                                progress >= 1.0 ? context.colors.success : context.colors.primary,
                              ),
                            ),
                          ),
                          if (repsRemaining > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.repsRemaining(repsRemaining),
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick rep chips
                    Text(
                      context.l10n.quickRepSelection,
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...quickRepSuggestions.map((reps) {
                          return ActionChip(
                            label: Text('$reps reps'),
                            onPressed: () => _applyQuickReps(reps),
                            avatar: Icon(
                              AppIcons.fitnessCenter,
                              size: 16,
                              color: context.colors.primary,
                            ),
                          );
                        }),
                        if (repsRemaining > 0 && !quickRepSuggestions.contains(repsRemaining))
                          ActionChip(
                            label: Text('$repsRemaining reps'),
                            onPressed: () => _applyQuickReps(repsRemaining),
                            avatar: Icon(
                              AppIcons.flagOutlined,
                              size: 16,
                              color: context.colors.tertiary,
                            ),
                            backgroundColor: context.colors.tertiaryContainer.withValues(alpha: 0.3),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Reps and Rest input
                    Row(
                      children: [
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
                                autofocus: true,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  suffixText: 'reps',
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
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
                                context.l10n.restTime,
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _restController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  suffixText: 's',
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
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
                          context.l10n.addSet,
                          style: context.textTheme.titleMedium,
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
