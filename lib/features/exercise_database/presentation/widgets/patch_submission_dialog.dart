/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/presentation/widgets
/// 🎯 Feature: exercise_database
/// 🔧 Type: widget
///
/// Dialog for submitting exercise correction patches
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/exercise_patch_review_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/core/analytics/trackers/patch_event_tracker.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Dialog per sottomettere correzioni agli esercizi
class PatchSubmissionDialog extends ConsumerStatefulWidget {
  const PatchSubmissionDialog({
    required this.exercise,
    super.key,
  });

  final Exercise exercise;

  /// Mostra il dialog come modal bottom sheet
  static Future<void> show(BuildContext context, Exercise exercise) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PatchSubmissionDialog(exercise: exercise),
    );
  }

  @override
  ConsumerState<PatchSubmissionDialog> createState() =>
      _PatchSubmissionDialogState();
}

class _PatchSubmissionDialogState
    extends ConsumerState<PatchSubmissionDialog> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _newValueController = TextEditingController();

  // Field selection
  String? _selectedField;
  String? _currentValue;

  // Loading state
  bool _isSubmitting = false;

  // Available fields map (field key → display name)
  late final Map<String, String> _editableFields;

  @override
  void initState() {
    super.initState();
    _initEditableFields();
  }

  void _initEditableFields() {
    _editableFields = {
      'nome': 'Exercise Name',
      'noteTecniche': 'Technical Notes',
      'attrezzatura': 'Equipment',
      'focusDisplay': 'Focus',
      'difficolta': 'Difficulty',
      'mobilitaPre': 'Pre-Mobility',
      'attivazionePre': 'Pre-Activation',
      'warmupSets': 'Warmup Sets',
      'tempoWarmup': 'Warmup Time',
    };
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _newValueController.dispose();
    super.dispose();
  }

  String _getCurrentFieldValue(String fieldKey) {
    switch (fieldKey) {
      case 'nome':
        return widget.exercise.nome;
      case 'noteTecniche':
        return widget.exercise.noteTecniche ?? '-';
      case 'attrezzatura':
        return widget.exercise.attrezzatura;
      case 'focusDisplay':
        return widget.exercise.focusDisplayName;
      case 'difficolta':
        return widget.exercise.difficolta;
      case 'mobilitaPre':
        return widget.exercise.mobilitaPre ?? '-';
      case 'attivazionePre':
        return widget.exercise.attivazionePre ?? '-';
      case 'warmupSets':
        return widget.exercise.warmupSets ?? '-';
      case 'tempoWarmup':
        return widget.exercise.tempoWarmup ?? '-';
      default:
        return '-';
    }
  }

  void _onFieldSelected(String? fieldKey) {
    if (fieldKey == null) return;

    // Haptic feedback on field selection
    HapticFeedback.selectionClick();

    setState(() {
      _selectedField = fieldKey;
      _currentValue = _getCurrentFieldValue(fieldKey);
      _newValueController.clear();
    });
  }

  Future<void> _submitPatch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedField == null || _currentValue == null) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(exercisePatchRepositoryProvider);
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = PatchEventTracker(analytics);

      final result = await repository.submitPatch(
        exerciseId: widget.exercise.id,
        fieldName: _selectedField!,
        oldValue: _currentValue,
        newValue: _newValueController.text.trim(),
        originalValue: _currentValue,
        reason: _reasonController.text.trim(),
        language: Localizations.localeOf(context).languageCode,
        version: 1, // Default version (Exercise entity doesn't have versioning yet)
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          // Haptic feedback for error
          HapticFeedback.vibrate();

          // Track submission failure
          tracker.trackPatchSubmissionFailed(
            exerciseId: widget.exercise.id,
            fieldName: _selectedField!,
            errorMessage: failure.message,
            errorType: failure.runtimeType.toString(),
            source: 'patch_submission_dialog',
          );

          SnackBarService.showError(
            context,
            '${context.l10n.patchSubmissionError}: ${failure.message}',
          );
        },
        (patchId) {
          // Haptic feedback for success
          HapticFeedback.mediumImpact();

          // Track successful submission
          tracker.trackPatchSubmitted(
            patchId: patchId,
            exerciseId: widget.exercise.id,
            exerciseName: widget.exercise.nome,
            fieldName: _selectedField!,
            source: 'patch_submission_dialog',
          );

          SnackBarService.showSuccess(
            context,
            context.l10n.patchSubmittedSuccess,
          );
          Navigator.of(context).pop();
        },
      );
    } catch (error) {
      if (!mounted) return;

      // Haptic feedback for exception
      HapticFeedback.vibrate();

      // Track exception
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = PatchEventTracker(analytics);
      tracker.trackPatchSubmissionFailed(
        exerciseId: widget.exercise.id,
        fieldName: _selectedField ?? 'unknown',
        errorMessage: error.toString(),
        errorType: 'exception',
        source: 'patch_submission_dialog',
      );

      SnackBarService.showError(
        context,
        '${context.l10n.patchSubmissionError}: $error',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, l10n),
              const SizedBox(height: 24),

              // Exercise info
              _buildExerciseInfo(context, l10n),
              const SizedBox(height: 24),

              // Field selector
              _buildFieldSelector(context, l10n),
              const SizedBox(height: 16),

              // Current value display
              if (_selectedField != null) ...[
                _buildCurrentValueDisplay(context, l10n),
                const SizedBox(height: 16),
              ],

              // New value input
              if (_selectedField != null) ...[
                _buildNewValueInput(context, l10n),
                const SizedBox(height: 16),
              ],

              // Reason input
              if (_selectedField != null) ...[
                _buildReasonInput(context, l10n),
                const SizedBox(height: 24),
              ],

              // Submit button
              if (_selectedField != null) _buildSubmitButton(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            AppIcons.reportProblem,
            color: context.colors.onPrimaryContainer,
            size: AppIconSize.medium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reportExerciseError,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.reportErrorSubtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            AppIcons.close,
            size: AppIconSize.medium,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseInfo(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.workout,
            color: context.colors.primary,
            size: AppIconSize.medium,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.exercise,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.exercise.nome,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSelector(BuildContext context, AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedField,
      decoration: InputDecoration(
        labelText: l10n.selectFieldToCorrect,
        prefixIcon: Icon(AppIcons.edit, size: AppIconSize.medium),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: _editableFields.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: _onFieldSelected,
      validator: (value) {
        if (value == null) {
          return l10n.pleaseSelectField;
        }
        return null;
      },
    );
  }

  Widget _buildCurrentValueDisplay(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SemanticIcon(
  icon: AppIcons.info,
  semanticLabel: 'Information',
  size: AppIconSize.tiny,
  color: context.colors.error,
),
              const SizedBox(width: 8),
              Text(
                l10n.currentValue,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentValue ?? '-',
            style: context.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNewValueInput(BuildContext context, AppLocalizations l10n) {
    return TextFormField(
      controller: _newValueController,
      decoration: InputDecoration(
        labelText: l10n.newValue,
        hintText: l10n.enterCorrectedValue,
        prefixIcon: Icon(AppIcons.check, size: AppIconSize.medium),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.pleaseEnterNewValue;
        }
        if (value.trim() == _currentValue) {
          return l10n.newValueMustDiffer;
        }
        return null;
      },
    );
  }

  Widget _buildReasonInput(BuildContext context, AppLocalizations l10n) {
    return TextFormField(
      controller: _reasonController,
      decoration: InputDecoration(
        labelText: l10n.reason,
        hintText: l10n.explainWhyCorrection,
        prefixIcon: Icon(AppIcons.edit, size: AppIconSize.medium),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.pleaseProvideReason;
        }
        if (value.trim().length < 10) {
          return l10n.reasonTooShort;
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitPatch,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          foregroundColor: context.colors.surface,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? LoadingIndicator(
                size: AppIconSize.medium,
                color: context.colors.surface,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.send, size: AppIconSize.small),
                  const SizedBox(width: 8),
                  Text(
                    l10n.submitCorrection,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colors.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
