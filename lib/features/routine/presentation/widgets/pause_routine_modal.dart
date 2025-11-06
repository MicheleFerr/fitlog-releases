/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation
/// 🎯 Feature: routine_pause
/// 🔧 Type: widget
/// 🌍 Localization: ✅ ENFORCED (context.l10n.*)
/// 🎨 Theme: ✅ ENFORCED (context.colors.*)
/// 📱 Platform: Universal
///
/// PAUSE ROUTINE MODAL - UI for creating routine pause
///
/// This modal provides:
/// - Reason selection (radio buttons)
/// - Date range picker (start/end)
/// - Optional notes field
/// - Validation with user-friendly errors
/// - Conflict detection (workouts in range)
///
/// Example:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => PauseRoutineModal(
///     routineId: 'routine_123',
///     routineName: 'Push Pull Legs',
///   ),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_pause.dart';
import 'package:gymbro_flutter_new/features/routine/domain/validators/pause_range_validator.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_pause_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:intl/intl.dart';

/// Modal for pausing a routine
class PauseRoutineModal extends ConsumerStatefulWidget {
  const PauseRoutineModal({
    required this.routineId,
    required this.routineName,
    super.key,
  });

  final String routineId;
  final String routineName;

  @override
  ConsumerState<PauseRoutineModal> createState() => _PauseRoutineModalState();
}

class _PauseRoutineModalState extends ConsumerState<PauseRoutineModal> {
  // Form state
  PauseReason _selectedReason = PauseReason.injury;
  DateTime? _startDate;
  DateTime? _endDate;
  final _notesController = TextEditingController();

  // Validation
  final _validator = PauseRangeValidator();
  String? _validationError;

  // Loading state
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Default: start today, end in 7 days
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              SizedBox(height: 20),

              // Description
              Text(
                context.l10n.pauseRoutineDescription,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Reason selection
              _buildReasonSelection(),
              const SizedBox(height: 24),

              // Date pickers
              _buildDatePickers(),
              const SizedBox(height: 24),

              // Notes field
              _buildNotesField(),
              const SizedBox(height: 24),

              // Validation error
              if (_validationError != null) ...[
                _buildErrorBanner(),
                const SizedBox(height: 16),
              ],

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with title and close button
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.pauseRoutineTitle,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SemanticIcon(
            icon: AppIcons.close,
            semanticLabel: context.l10n.close,
            size: AppIconSize.medium,
          ),
        ),
      ],
    );
  }

  /// Reason selection with radio buttons
  Widget _buildReasonSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.pauseReason,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...PauseReason.values.map(
          (reason) => RadioListTile<PauseReason>(
            value: reason,
            groupValue: _selectedReason,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedReason = value);
                HapticFeedback.selectionClick();
              }
            },
            title: Text(_getReasonDisplayName(reason)),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  /// Date pickers for start/end
  Widget _buildDatePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Start date
        _buildDatePickerTile(
          label: context.l10n.startDate,
          date: _startDate,
          onTap: () => _selectDate(isStartDate: true),
        ),
        SizedBox(height: 12),

        // End date
        _buildDatePickerTile(
          label: context.l10n.endDate,
          date: _endDate,
          onTap: () => _selectDate(isStartDate: false),
        ),

        // Duration preview
        if (_startDate != null && _endDate != null) ...[
          const SizedBox(height: 8),
          _buildDurationPreview(),
        ],
      ],
    );
  }

  /// Single date picker tile
  Widget _buildDatePickerTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SemanticIcon(
              icon: AppIcons.calendar,
              semanticLabel: label,
              size: AppIconSize.medium,
              color: context.colors.primary,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    date != null
                        ? DateFormat.yMMMd().format(date)
                        : context.l10n.selectDate,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
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

  /// Duration preview chip
  Widget _buildDurationPreview() {
    final duration = _endDate!.difference(_startDate!).inDays + 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
            icon: AppIcons.timer,
            semanticLabel: context.l10n.duration,
            size: AppIconSize.small,
            color: context.colors.onPrimaryContainer,
          ),
          SizedBox(width: 6),
          Text(
            '$duration ${context.l10n.days}',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Notes text field
  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 3,
      maxLength: 200,
      decoration: InputDecoration(
        labelText: context.l10n.pauseNotes,
        hintText: context.l10n.pauseNotesHint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SemanticIcon(
            icon: AppIcons.notes,
            semanticLabel: context.l10n.notes,
            size: AppIconSize.medium,
          ),
        ),
      ),
    );
  }

  /// Error banner
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.error,
            semanticLabel: context.l10n.error,
            size: AppIconSize.small,
            color: context.colors.onErrorContainer,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _validationError!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Action buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(context.l10n.cancel),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _isSubmitting ? null : _handleSubmit,
            icon: _isSubmitting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: LoadingIndicator(),
                  )
                : SemanticIcon(
                    icon: AppIcons.pause,
                    semanticLabel: context.l10n.pause,
                    size: AppIconSize.buttonPrimary,
                  ),
            label: Text(context.l10n.confirmPause),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // === ACTIONS ===

  /// Show date picker
  Future<void> _selectDate({required bool isStartDate}) async {
    await HapticFeedback.selectionClick();

    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now().add(const Duration(days: 7)));

    final firstDate = isStartDate
        ? DateTime.now()
        : (_startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Auto-adjust end date if before start
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked.add(const Duration(days: 7));
          }
        } else {
          _endDate = picked;
        }
        _validationError = null; // Clear error on date change
      });
    }
  }

  /// Handle submit
  Future<void> _handleSubmit() async {
    // Validate
    if (_startDate == null || _endDate == null) {
      setState(() {
        _validationError = 'Please select both start and end dates';
      });
      return;
    }

    // Get existing pauses for overlap check
    final existingPausesAsync = ref.read(routinePauseProvider(widget.routineId));
    final existingPauses = existingPausesAsync.value ?? [];

    final validation = _validator.validateRange(
      startDate: _startDate!,
      endDate: _endDate!,
      existingPauses: existingPauses,
    );

    if (validation.isFailure) {
      setState(() {
        _validationError = validation.error;
      });
      return;
    }

    // Create pause
    setState(() => _isSubmitting = true);

    try {
      final pause = RoutinePause.create(
        routineId: widget.routineId,
        userId: ref.read(currentUserIdProvider), // TODO: Add provider
        reason: _selectedReason,
        startDate: _startDate!,
        endDate: _endDate!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await ref
          .read(routinePauseNotifierProvider(widget.routineId).notifier)
          .createPause(pause);

      if (!mounted) return;

      // Show success and close
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.routinePaused),
          backgroundColor: context.colors.primary,
        ),
      );
    } catch (e) {
      setState(() {
        _validationError = 'Failed to pause routine: $e';
        _isSubmitting = false;
      });
    }
  }

  // === HELPERS ===

  /// Get localized reason display name
  String _getReasonDisplayName(PauseReason reason) {
    switch (reason) {
      case PauseReason.injury:
        return context.l10n.pauseReasonInjury;
      case PauseReason.sick:
        return context.l10n.pauseReasonSick;
      case PauseReason.vacation:
        return context.l10n.pauseReasonVacation;
      case PauseReason.busy:
        return context.l10n.pauseReasonBusy;
      case PauseReason.burnout:
        return context.l10n.pauseReasonBurnout;
      case PauseReason.other:
        return context.l10n.pauseReasonOther;
    }
  }
}

/// Placeholder provider for current user ID
/// TODO: Replace with actual user provider
final currentUserIdProvider = Provider<String>((ref) {
  // This should come from AuthProvider or similar
  return 'user_placeholder';
});
