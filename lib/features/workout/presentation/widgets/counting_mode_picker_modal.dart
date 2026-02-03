import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Result of the counting mode picker modal
///
/// Contains both the selected mode and whether to save it as default
typedef CountingModePickerResult = ({
  ExerciseCountingMode mode,
  bool saveAsDefault,
});

/// 🎯 TIER-1: Modal per cambiare il counting mode di un esercizio
///
/// Mostra 3 opzioni (weighted/reps/time) con preview e conferma.
/// Usato durante workout attivo per correggere errori di template.
/// Ora supporta anche il salvataggio permanente del counting mode scelto.
class CountingModePickerModal extends StatefulWidget {
  const CountingModePickerModal({
    super.key,
    required this.currentMode,
    required this.onConfirm,
    this.exerciseId,
    this.exerciseName,
    this.showSaveAsDefault = true,
  });

  final ExerciseCountingMode currentMode;
  final void Function(CountingModePickerResult result) onConfirm;

  /// Optional exercise ID for saving the preference permanently
  final String? exerciseId;

  /// Optional exercise name for display in the save default checkbox
  final String? exerciseName;

  /// Whether to show the "Save as default" checkbox
  final bool showSaveAsDefault;

  @override
  State<CountingModePickerModal> createState() =>
      _CountingModePickerModalState();

  /// Static helper to show modal
  ///
  /// Returns a [CountingModePickerResult] with the selected mode and
  /// whether to save it as the default for future workouts.
  static Future<CountingModePickerResult?> show(
    BuildContext context, {
    required ExerciseCountingMode currentMode,
    String? exerciseId,
    String? exerciseName,
    bool showSaveAsDefault = true,
  }) async {
    unawaited(HapticFeedback.mediumImpact());
    return showModalBottomSheet<CountingModePickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => CountingModePickerModal(
        currentMode: currentMode,
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        showSaveAsDefault: showSaveAsDefault,
        onConfirm: (result) => Navigator.pop(context, result),
      ),
    );
  }
}

class _CountingModePickerModalState extends State<CountingModePickerModal> {
  late ExerciseCountingMode _selectedMode;
  bool _saveAsDefault = false;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.currentMode;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.85,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.swapHoriz,
                    semanticLabel: context.l10n.changeCountingFormat,
                    size: AppIconSize.large,
                    color: context.iconPrimary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.changeCountingFormat,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Current mode indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    SemanticIcon(
                      icon: AppIcons.info,
                      semanticLabel: 'Info',
                      size: AppIconSize.small,
                      color: context.iconMediumEmphasis,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${context.l10n.currentFormat}: ${widget.currentMode.getDisplayName(context.l10n)}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Mode options
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildModeOption(
                    context,
                    mode: ExerciseCountingMode.weighted,
                    title: context.l10n.countingModeWeighted,
                    description: context.l10n.countingModeWeightedDesc,
                    example: context.l10n.countingModeWeightedExample,
                    icon: AppIcons.workout,
                  ),
                  const SizedBox(height: 12),
                  _buildModeOption(
                    context,
                    mode: ExerciseCountingMode.reps,
                    title: context.l10n.countingModeReps,
                    description: context.l10n.countingModeRepsDesc,
                    example: context.l10n.countingModeRepsExample,
                    icon: AppIcons.repeat,
                  ),
                  const SizedBox(height: 12),
                  _buildModeOption(
                    context,
                    mode: ExerciseCountingMode.time,
                    title: context.l10n.countingModeTime,
                    description: context.l10n.countingModeTimeDesc,
                    example: context.l10n.countingModeTimeExample,
                    icon: AppIcons.timer,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Save as default checkbox
            if (widget.showSaveAsDefault && widget.exerciseId != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _saveAsDefault = !_saveAsDefault;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _saveAsDefault
                          ? context.colors.primaryContainer.withValues(
                              alpha: 0.3,
                            )
                          : context.colors.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _saveAsDefault
                            ? context.colors.primary
                            : context.colors.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _saveAsDefault,
                          onChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _saveAsDefault = value ?? false;
                            });
                          },
                          activeColor: context.colors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.saveAsDefaultForExercise,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.l10n.saveAsDefaultForExerciseDesc,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: context.colors.outline),
                      ),
                      child: Text(
                        context.l10n.cancel,
                        style: TextStyle(color: context.colors.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _selectedMode != widget.currentMode
                          ? () {
                              HapticFeedback.mediumImpact();
                              widget.onConfirm((
                                mode: _selectedMode,
                                saveAsDefault: _saveAsDefault,
                              ));
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: context.colors.primary,
                        disabledBackgroundColor:
                            context.colors.surfaceContainerHighest,
                      ),
                      child: Text(
                        context.l10n.confirmChange,
                        style: TextStyle(
                          color: _selectedMode != widget.currentMode
                              ? context.colors.onPrimary
                              : context.colors.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(
    BuildContext context, {
    required ExerciseCountingMode mode,
    required String title,
    required String description,
    required String example,
    required IconData icon,
  }) {
    final isSelected = _selectedMode == mode;
    final isCurrentMode = widget.currentMode == mode;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryContainer.withValues(alpha: 0.3)
              : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.outline,
                  width: 2,
                ),
                color: isSelected
                    ? context.colors.primary
                    : context.colors.surface.withValues(alpha: 0),
              ),
              child: isSelected
                  ? SemanticIcon(
                      icon: AppIcons.check,
                      semanticLabel: 'Check',
                      size: AppIconSize.tiny,
                      color: context.colors.onPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Icon
            SemanticIcon(
              icon: icon,
              semanticLabel: title,
              size: AppIconSize.medium,
              color: isSelected
                  ? context.iconPrimary
                  : context.iconMediumEmphasis,
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? context.colors.primary
                                : context.colors.onSurface,
                          ),
                        ),
                      ),
                      if (isCurrentMode) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.l10n.current,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    example,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
