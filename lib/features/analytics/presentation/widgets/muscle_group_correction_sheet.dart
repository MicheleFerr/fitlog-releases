/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget (bottom sheet)
///
/// MuscleGroupCorrectionSheet - BottomSheet for correcting exercise muscle groups
///
/// **Purpose**: Allow users to correct incorrect muscle group assignments
///
/// **UX Flow**:
/// 1. User long-presses exercise card
/// 2. This BottomSheet appears with dropdown
/// 3. User selects correct muscle group
/// 4. "Save" button → saves locally (immediate UI effect)
/// 5. Dialog asks "Report to admin?" (see FeedbackSubmissionDialog)
///
/// **Features**:
/// - Dropdown with all muscle groups (localized)
/// - Shows old vs new comparison
/// - Save button only enabled when selection differs from current
/// - Haptic feedback on selection change
/// - Loading state during save operation
///
/// **Dependencies**:
/// - muscle_correction_repository_provider
/// - muscle_group_expansion_provider (to get available groups)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_correction.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/muscle_correction_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/mixins/safe_set_state_mixin.dart';

/// BottomSheet for correcting exercise muscle groups
///
/// **Usage**:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => MuscleGroupCorrectionSheet(
///     exerciseName: 'Bench Press',
///     currentMuscleGroup: 'Back', // Incorrect
///   ),
/// );
/// ```
class MuscleGroupCorrectionSheet extends ConsumerStatefulWidget {
  const MuscleGroupCorrectionSheet({
    required this.exerciseName,
    required this.currentMuscleGroup,
    super.key,
  });

  /// Exercise name to correct
  final String exerciseName;

  /// Current (incorrect) muscle group
  final String currentMuscleGroup;

  @override
  ConsumerState<MuscleGroupCorrectionSheet> createState() =>
      _MuscleGroupCorrectionSheetState();
}

class _MuscleGroupCorrectionSheetState
    extends ConsumerState<MuscleGroupCorrectionSheet>
    with SafeSetStateMixin {
  /// Selected new muscle group (null = not selected yet)
  String? _selectedMuscleGroup;

  /// Loading state during save operation
  bool _isSaving = false;

  /// Available muscle groups (hardcoded standard list)
  ///
  /// **Note**: These match the localization keys in app_en.arb/app_it.arb
  static const List<String> _muscleGroups = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
  ];

  /// Get localized muscle group name
  String _getLocalizedMuscleGroupName(BuildContext context, String group) {
    final l10n = context.l10n;
    switch (group) {
      case 'Chest':
        return l10n.muscleGroupChest;
      case 'Back':
        return l10n.muscleGroupBack;
      case 'Legs':
        return l10n.muscleGroupLegs;
      case 'Shoulders':
        return l10n.muscleGroupShoulders;
      case 'Arms':
        return l10n.muscleGroupArms;
      case 'Core':
        return l10n.muscleGroupCore;
      default:
        return group;
    }
  }

  /// Save correction locally
  Future<void> _saveCorrection() async {
    if (_selectedMuscleGroup == null ||
        _selectedMuscleGroup == widget.currentMuscleGroup) {
      return;
    }

    safeSetState(() {
      _isSaving = true;
    });

    // Create correction entity
    final correction = MuscleCorrection(
      exerciseName: widget.exerciseName,
      oldMuscleGroup: widget.currentMuscleGroup,
      newMuscleGroup: _selectedMuscleGroup!,
      timestamp: DateTime.now(),
    );

    // Save to local storage (Hive)
    final result = await ref
        .read(muscleCorrectionRepositoryProvider)
        .saveLocalCorrection(correction);

    if (!mounted) return;

    safeSetState(() {
      _isSaving = false;
    });

    result.fold(
      (failure) {
        // Show error
        SnackBarService.showError(
          context,
          failure.message,
        );
      },
      (_) {
        // Success - show success message
        HapticFeedback.mediumImpact();
        SnackBarService.showSuccess(
          context,
          context.l10n.correctionSavedLocally,
        );

        // Close bottom sheet and return correction
        Navigator.of(context).pop(correction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    // Check if selection is valid (different from current)
    final isSelectionValid = _selectedMuscleGroup != null &&
        _selectedMuscleGroup != widget.currentMuscleGroup;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Icon(
                AppIcons.edit,
                color: colors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.correctMuscleGroup,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.exerciseName,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  AppIcons.close,
                  color: colors.onSurfaceVariant,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Current muscle group (read-only)
          Text(
            context.l10n.currentMuscleGroup,
            style: textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.error.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.error,
                  color: colors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getLocalizedMuscleGroupName(
                    context,
                    widget.currentMuscleGroup,
                  ),
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // New muscle group (dropdown)
          Text(
            context.l10n.correctMuscleGroup,
            style: textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMuscleGroup,
                hint: Text(
                  context.l10n.selectMuscleGroup,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                isExpanded: true,
                icon: Icon(
                  AppIcons.arrowDropDown,
                  color: colors.onSurfaceVariant,
                ),
                dropdownColor: colors.surfaceContainerHighest,
                items: _muscleGroups.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Row(
                      children: [
                        if (group == widget.currentMuscleGroup) ...[
                          Icon(
                            AppIcons.error,
                            size: 16,
                            color: colors.error,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _getLocalizedMuscleGroupName(context, group),
                          style: textTheme.bodyLarge?.copyWith(
                            color: group == widget.currentMuscleGroup
                                ? colors.error
                                : colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          HapticFeedback.selectionClick();
                          safeSetState(() {
                            _selectedMuscleGroup = value;
                          });
                        }
                      },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Save button
          FilledButton(
            onPressed: (!isSelectionValid || _isSaving) ? null : _saveCorrection,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: LoadingIndicator(
                      color: colors.onPrimary,
                      size: 20,
                    ),
                  )
                : Text(
                    context.l10n.saveCorrection,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          const SizedBox(height: 8),

          // Cancel button
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: colors.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              context.l10n.cancel,
              style: textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
