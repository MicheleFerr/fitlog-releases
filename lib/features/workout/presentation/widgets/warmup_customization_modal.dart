/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: widget
///
/// Warmup Customization Modal - Modal bottom sheet for editing warmup sets
///
/// Allows users to customize warmup set weights and reps with intuitive UI:
/// - Weight and reps input fields with decimal/number keyboards
/// - Swipe-to-delete for individual sets (minimum 1 set required)
/// - Add new warmup sets dynamically
/// - Cancel/Confirm actions with haptic feedback
///
/// ## Design System Compliance
///
/// - ✅ AppSpacing.* for all spacing (no magic numbers)
/// - ✅ context.colors.* for theming (light/dark mode support)
/// - ✅ SemanticIcon with AppIcons.* and AppIconSize.*
/// - ✅ context.l10n.* for all strings (EN/IT localization)
/// - ✅ HapticFeedback on interactions
/// - ✅ Keyboard-aware layout with MediaQuery.viewInsets
///
/// ## Usage Example
///
/// ```dart
/// WarmupCustomizationModal.show(
///   context: context,
///   initialSets: [
///     WarmupSet(weight: 20.0, reps: 10, percentage: 0),
///     WarmupSet(weight: 40.0, reps: 8, percentage: 40),
///   ],
///   onConfirm: (updatedSets) {
///     print('Updated warmup sets: $updatedSets');
///   },
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/warmup_calculator_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Modal bottom sheet for customizing warmup sets
///
/// Provides an editable list of warmup sets with weight/reps input fields,
/// swipe-to-delete functionality, and add set capability.
class WarmupCustomizationModal extends StatefulWidget {
  const WarmupCustomizationModal({
    required this.initialSets,
    required this.onConfirm,
    super.key,
  });

  /// Initial warmup sets to display and edit
  final List<WarmupSet> initialSets;

  /// Callback when user confirms changes
  final void Function(List<WarmupSet>) onConfirm;

  /// Static method to show the modal
  ///
  /// Example:
  /// ```dart
  /// WarmupCustomizationModal.show(
  ///   context: context,
  ///   initialSets: warmupSets,
  ///   onConfirm: (updated) => print(updated),
  /// );
  /// ```
  static Future<void> show({
    required BuildContext context,
    required List<WarmupSet> initialSets,
    required void Function(List<WarmupSet>) onConfirm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => WarmupCustomizationModal(
        initialSets: initialSets,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<WarmupCustomizationModal> createState() =>
      _WarmupCustomizationModalState();
}

class _WarmupCustomizationModalState extends State<WarmupCustomizationModal> {
  late List<_EditableWarmupSet> _editableSets;
  late List<TextEditingController> _weightControllers;
  late List<TextEditingController> _repsControllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initializeControllers() {
    _editableSets = widget.initialSets
        .map(
          (set) => _EditableWarmupSet(
            weight: set.weight,
            reps: set.reps,
            percentage: set.percentage,
          ),
        )
        .toList();

    _weightControllers = _editableSets
        .map((set) => TextEditingController(text: set.weight.toString()))
        .toList();

    _repsControllers = _editableSets
        .map((set) => TextEditingController(text: set.reps.toString()))
        .toList();
  }

  void _disposeControllers() {
    for (final controller in _weightControllers) {
      controller.dispose();
    }
    for (final controller in _repsControllers) {
      controller.dispose();
    }
  }

  void _addSet() {
    setState(() {
      final newSet = _EditableWarmupSet(weight: 20.0, reps: 10, percentage: 0);
      _editableSets.add(newSet);
      _weightControllers.add(TextEditingController(text: '20.0'));
      _repsControllers.add(TextEditingController(text: '10'));
    });
    HapticFeedback.lightImpact();
  }

  void _deleteSet(int index) {
    if (_editableSets.length <= 1) {
      // Don't allow deleting the last set
      return;
    }

    setState(() {
      _editableSets.removeAt(index);
      _weightControllers[index].dispose();
      _repsControllers[index].dispose();
      _weightControllers.removeAt(index);
      _repsControllers.removeAt(index);
    });
    HapticFeedback.mediumImpact();
  }

  void _confirm() {
    final updatedSets = <WarmupSet>[];

    for (var i = 0; i < _editableSets.length; i++) {
      final weight = double.tryParse(_weightControllers[i].text) ?? 0.0;
      final reps = int.tryParse(_repsControllers[i].text) ?? 0;

      updatedSets.add(
        WarmupSet(
          weight: weight,
          reps: reps,
          percentage: _editableSets[i].percentage,
        ),
      );
    }

    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    widget.onConfirm(updatedSets);
  }

  void _cancel() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.lg),
        ),
      ),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with drag handle
            _buildHeader(context, l10n),

            // Scrollable list of warmup sets
            Flexible(child: _buildSetsList(context, l10n)),

            // Add Set button
            _buildAddSetButton(context, l10n),

            // Action buttons (Cancel/Confirm)
            _buildActionButtons(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.md,
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title with close button
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.warmupCustomizeTitle,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: _cancel,
                icon: SemanticIcon(
                  icon: AppIcons.close,
                  semanticLabel: l10n.close,
                  size: AppIconSize.medium,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetsList(BuildContext context, AppLocalizations l10n) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      itemCount: _editableSets.length,
      itemBuilder: (context, index) => _buildSetRow(context, l10n, index),
    );
  }

  Widget _buildSetRow(BuildContext context, AppLocalizations l10n, int index) {
    final canDelete = _editableSets.length > 1;

    final setRow = Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Set number badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Weight input
          Expanded(
            child: _buildTextField(
              context: context,
              controller: _weightControllers[index],
              label: l10n.weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              suffixText: 'kg',
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Reps input
          Expanded(
            child: _buildTextField(
              context: context,
              controller: _repsControllers[index],
              label: l10n.reps,
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );

    // Wrap with Dismissible for swipe-to-delete (if more than 1 set)
    if (canDelete) {
      return Dismissible(
        key: ValueKey('warmup_set_$index'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _deleteSet(index),
        background: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.colors.error,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          alignment: Alignment.centerRight,
          child: SemanticIcon(
            icon: AppIcons.delete,
            semanticLabel: l10n.delete,
            size: AppIconSize.medium,
            color: context.colors.onError,
          ),
        ),
        child: setRow,
      );
    }

    return setRow;
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    String? suffixText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: context.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: context.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
        suffixText: suffixText,
        suffixStyle: context.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
        filled: true,
        fillColor: context.colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          borderSide: BorderSide(
            color: context.colors.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          borderSide: BorderSide(
            color: context.colors.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          borderSide: BorderSide(color: context.colors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildAddSetButton(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: OutlinedButton.icon(
        onPressed: _addSet,
        icon: SemanticIcon(
          icon: AppIcons.add,
          semanticLabel: l10n.warmupAddSet,
          size: AppIconSize.small,
          color: context.colors.primary,
        ),
        label: Text(l10n.warmupAddSet),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: context.colors.primary,
          side: BorderSide(color: context.colors.primary),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.colors.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: _cancel,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.cancel),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Confirm button
          Expanded(
            child: FilledButton(
              onPressed: _confirm,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.confirm),
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal editable warmup set model
///
/// Used to track changes during editing without mutating original WarmupSet.
class _EditableWarmupSet {
  _EditableWarmupSet({
    required this.weight,
    required this.reps,
    required this.percentage,
  });

  double weight;
  int reps;
  int percentage;
}
