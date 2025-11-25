/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/screens
/// 🎯 Feature: flexible_routine
/// 🔧 Type: screen
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// ROUTINE EDITOR SCREEN - Multi-step wizard for creating flexible routines
///
/// Features:
/// - Step 1: Basic info (name, type, dates)
/// - Step 2: Pattern selection (presets or custom)
/// - Step 3: Template selection (choose which templates to use)
/// - Step 4: Rotation order (arrange template distribution)
/// - Step 5: Review and create
/// - Validation at each step
/// - Navigation between steps
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_editor_state.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_notifier.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/editor_steps/basic_info_step.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/editor_steps/pattern_selection_step.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/editor_steps/template_selection_step.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/editor_steps/template_rotation_step.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/editor_steps/review_step.dart';

/// Main wizard screen for creating/editing flexible routines
class RoutineEditorScreen extends ConsumerWidget { // For editing existing routines

  const RoutineEditorScreen({
    super.key,
    this.routineId,
  });
  final String? routineId;

  bool get isEditing => routineId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(routineEditorProvider);
    final flexibleRoutineState = ref.watch(flexibleRoutineNotifierProvider);

    return PopScope(
      canPop: !flexibleRoutineState.isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPress(context, ref);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing ? context.l10n.routineEditorEditTitle : context.l10n.routineEditorTitle,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          backgroundColor: context.colors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _handleBackPress(context, ref),
          ),
        ),
        body: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(context, editorState),

            // Stepper content
            Expanded(
              child: _buildStepContent(context, ref, editorState),
            ),

            // Navigation buttons
            _buildNavigationButtons(context, ref, editorState,
                flexibleRoutineState.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    RoutineEditorState state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(
            color: context.colors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStepIndicator(
              context,
              stepNumber: 1,
              label: 'Info',
              isActive: state.currentStep == 0,
              isCompleted: state.currentStep > 0,
            ),
            _buildDivider(context, state.currentStep > 0),
            _buildStepIndicator(
              context,
              stepNumber: 2,
              label: 'Pattern',
              isActive: state.currentStep == 1,
              isCompleted: state.currentStep > 1,
            ),
            _buildDivider(context, state.currentStep > 1),
            _buildStepIndicator(
              context,
              stepNumber: 3,
              label: 'Selection',
              isActive: state.currentStep == 2,
              isCompleted: state.currentStep > 2,
            ),
            _buildDivider(context, state.currentStep > 2),
            _buildStepIndicator(
              context,
              stepNumber: 4,
              label: 'Rotation',
              isActive: state.currentStep == 3,
              isCompleted: state.currentStep > 3,
            ),
            _buildDivider(context, state.currentStep > 3),
            _buildStepIndicator(
              context,
              stepNumber: 5,
              label: 'Review',
              isActive: state.currentStep == 4,
              isCompleted: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context, bool isCompleted) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isCompleted
          ? context.colors.primary
          : context.colors.outlineVariant.withValues(alpha: 0.3),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context, {
    required int stepNumber,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color color;
    if (isCompleted) {
      color = context.colors.primary;
    } else if (isActive) {
      color = context.colors.primary;
    } else {
      color = context.colors.outlineVariant;
    }

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (isActive || isCompleted)
                ? color
                : context.colors.surface,
            border: Border.all(
              color: color,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    color: context.colors.onPrimary,
                    size: 20,
                  )
                : Text(
                    '$stepNumber',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: (isActive || isCompleted)
                          ? context.colors.onPrimary
                          : color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: isActive
                ? context.colors.primary
                : context.colors.onSurface.withValues(alpha: 0.6),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    WidgetRef ref,
    RoutineEditorState state,
  ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _getStepWidget(state.currentStep),
    );
  }

  Widget _getStepWidget(int step) {
    switch (step) {
      case 0:
        return const BasicInfoStep(key: ValueKey(0));
      case 1:
        return const PatternSelectionStep(key: ValueKey(1));
      case 2:
        return const TemplateSelectionStep(key: ValueKey(2));
      case 3:
        return const TemplateRotationStep(key: ValueKey(3));
      case 4:
        return const ReviewStep(key: ValueKey(4));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    WidgetRef ref,
    RoutineEditorState state,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back button
            if (state.currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          ref.read(routineEditorProvider.notifier).previousStep();
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: context.colors.primary),
                  ),
                  child: Text(context.l10n.routineButtonBack),
                ),
              ),
            if (state.currentStep > 0) const SizedBox(width: 12),

            // Next/Create button
            Expanded(
              flex: state.currentStep == 0 ? 1 : 1,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => _handleNextButton(context, ref, state),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(context.colors.surface),
                        ),
                      )
                    : Text(
                        _getNextButtonLabel(context, state.currentStep),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNextButtonLabel(BuildContext context, int step) {
    switch (step) {
      case 0:
      case 1:
      case 2:
      case 3:
        return context.l10n.routineButtonNext;
      case 4:
        return context.l10n.routineButtonCreate;
      default:
        return context.l10n.routineButtonNext;
    }
  }

  void _handleNextButton(
    BuildContext context,
    WidgetRef ref,
    RoutineEditorState state,
  ) {
    final notifier = ref.read(routineEditorProvider.notifier);

    // Validate current step
    if (!state.isStepValid(state.currentStep)) {
      SnackBarService.showWarning(
        context,
        context.l10n.routineErrorIncomplete,
      );
      return;
    }

    if (state.currentStep < 4) {
      // Move to next step
      notifier.nextStep();
    } else {
      // Create routine (final step)
      _createRoutine(context, ref, state);
    }
  }

  Future<void> _createRoutine(
    BuildContext context,
    WidgetRef ref,
    RoutineEditorState state,
  ) async {
    final pattern = state.finalPattern;
    if (pattern == null) {
      SnackBarService.showError(context, context.l10n.routineErrorNoPattern);
      return;
    }

    final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);

    final success = await notifier.createRoutine(
      name: state.name,
      type: state.type,
      startDate: state.startDate,
      endDate: state.endDate,
      pattern: pattern,
      templateIds: state.selectedTemplates,
      description: state.description,
    );

    if (context.mounted) {
      if (success) {
        // Reset wizard state
        ref.read(routineEditorProvider.notifier).reset();

        // Show success with info about activation
        SnackBarService.showInfo(
          context,
          context.l10n.routineSuccessCreatedInactive(state.name),
        );

        // Navigate back
        context.pop();
      } else {
        final error = ref.read(flexibleRoutineNotifierProvider).error;
        SnackBarService.showError(
          context,
          error ?? context.l10n.routineErrorCreateFailed,
        );
      }
    }
  }

  void _handleBackPress(BuildContext context, WidgetRef ref) {
    final editorState = ref.read(routineEditorProvider);

    // If on first step or no data entered, just go back
    if (editorState.currentStep == 0 && editorState.name.isEmpty) {
      context.pop();
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.routineDiscardTitle),
        content: Text(context.l10n.routineDiscardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(routineEditorProvider.notifier).reset();
              Navigator.pop(dialogContext); // Close dialog
              context.pop(); // Close wizard
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: Text(context.l10n.discard),
          ),
        ],
      ),
    );
  }
}
