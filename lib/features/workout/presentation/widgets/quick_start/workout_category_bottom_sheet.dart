/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: presentation
/// Feature: workout
/// Type: widget
///
/// Bottom sheet for selecting workout category.
/// When a category is selected, it uses the TemplateSuggestionService
/// to find a matching predefined template based on user context
/// (time, level, gender) and creates a workout with pre-populated exercises.
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/template_suggestion_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_context_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Bottom sheet for selecting workout category or entering custom name.
///
/// Features:
/// - 8 category chips (Chest, Legs, Back, Arms, Cardio, Full Body, HIIT, Custom)
/// - Template suggestion based on user context (time, level, gender)
/// - Pre-populated exercises from matched templates
/// - Custom name input with validation
/// - Full accessibility support (screen reader, keyboard navigation)
/// - Material Design 3 compliant
/// - Theme-aware colors (dark/light mode)
class WorkoutCategoryBottomSheet extends ConsumerStatefulWidget {
  const WorkoutCategoryBottomSheet({super.key});

  @override
  ConsumerState<WorkoutCategoryBottomSheet> createState() =>
      _WorkoutCategoryBottomSheetState();
}

class _WorkoutCategoryBottomSheetState
    extends ConsumerState<WorkoutCategoryBottomSheet> {
  bool _isCustomMode = false;
  final TextEditingController _customNameController = TextEditingController();
  final FocusNode _customFieldFocus = FocusNode();
  final TemplateSuggestionService _templateService =
      TemplateSuggestionService();

  @override
  void dispose() {
    _customNameController.dispose();
    _customFieldFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            context.l10n.chooseWorkoutCategory,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Category chips or custom input
          if (!_isCustomMode)
            _buildCategoryChips(context)
          else
            _buildCustomInput(context),

          const SizedBox(height: 16),

          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        children: [
          // Row 1: Chest + Legs
          Row(
            children: [
              Expanded(child: _buildCategoryChip(context, 'chest', '💪', 0)),
              const SizedBox(width: 12),
              Expanded(child: _buildCategoryChip(context, 'legs', '🦵', 1)),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Back + Arms
          Row(
            children: [
              Expanded(child: _buildCategoryChip(context, 'back', '🔙', 2)),
              const SizedBox(width: 12),
              Expanded(child: _buildCategoryChip(context, 'arms', '💪', 3)),
            ],
          ),
          const SizedBox(height: 12),
          // Row 3: Cardio + Full Body
          Row(
            children: [
              Expanded(child: _buildCategoryChip(context, 'cardio', '❤️', 4)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryChip(context, 'fullBody', '🏋️', 5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 4: HIIT + Custom
          Row(
            children: [
              Expanded(child: _buildCategoryChip(context, 'hiit', '🔥', 6)),
              const SizedBox(width: 12),
              Expanded(child: _buildCustomChip(context, 7)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String category,
    String emoji,
    int order,
  ) {
    // Get localized labels
    String label;
    String workoutName;
    String semanticLabel;
    Color categoryColor;

    switch (category) {
      case 'chest':
        label = context.l10n.chest;
        workoutName = context.l10n.chestWorkout;
        semanticLabel = context.l10n.selectChestWorkout;
        categoryColor = context.colors.error;
        break;
      case 'legs':
        label = context.l10n.legs;
        workoutName = context.l10n.legsWorkout;
        semanticLabel = context.l10n.selectLegsWorkout;
        categoryColor = context.colors.primary;
        break;
      case 'back':
        label = context.l10n.back;
        workoutName = context.l10n.backWorkout;
        semanticLabel = context.l10n.selectBackWorkout;
        categoryColor = context.colors.tertiary;
        break;
      case 'arms':
        label = context.l10n.arms;
        workoutName = context.l10n.armsWorkout;
        semanticLabel = context.l10n.selectArmsWorkout;
        categoryColor = context.colors.secondary;
        break;
      case 'cardio':
        label = context.l10n.cardio;
        workoutName = context.l10n.cardioWorkout;
        semanticLabel = context.l10n.selectCardioWorkout;
        categoryColor = context.colors.error;
        break;
      case 'fullBody':
        label = context.l10n.fullBody;
        workoutName = context.l10n.fullBodyWorkout;
        semanticLabel = context.l10n.selectFullBodyWorkout;
        categoryColor = context.colors.success;
        break;
      case 'hiit':
        label = context.l10n.hiit;
        workoutName = context.l10n.hiitWorkout;
        semanticLabel = context.l10n.selectHiitWorkout;
        categoryColor = context.colors.warning;
        break;
      default:
        label = category;
        workoutName = '$category Workout';
        semanticLabel = 'Select $category workout';
        categoryColor = context.colors.primary;
    }

    return FocusTraversalOrder(
      order: NumericFocusOrder(order.toDouble()),
      child: Semantics(
        label: semanticLabel,
        button: true,
        enabled: true,
        child: Material(
          color: context.colors.surface.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _onCategorySelected(context, category, workoutName),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: categoryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: context.textTheme.headlineSmall),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomChip(BuildContext context, int order) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(order.toDouble()),
      child: Semantics(
        label: context.l10n.selectCustomWorkout,
        button: true,
        enabled: true,
        child: FilterChip(
          label: Center(child: Text('✏️ ${context.l10n.customWorkout}')),
          selected: false,
          onSelected: (selected) => _toggleCustomMode(),
          backgroundColor: context.colors.surfaceContainerHighest,
          selectedColor: context.colors.primary.withValues(alpha: 0.2),
          labelStyle: context.textTheme.bodyLarge,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          elevation: 0,
          pressElevation: 4,
          shadowColor: context.colors.shadow,
        ),
      ),
    );
  }

  Widget _buildCustomInput(BuildContext context) {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.enterWorkoutName,
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customNameController,
            focusNode: _customFieldFocus,
            autofocus: true,
            decoration: InputDecoration(
              hintText: context.l10n.workoutNameHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.outline, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.primary, width: 2),
              ),
              filled: true,
              fillColor: context.colors.surfaceContainerHighest,
            ),
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _isCustomMode = false),
                child: Text(context.l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _onCustomWorkoutConfirm(context),
                child: Text(context.l10n.confirm),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get time-of-day prefix based on current hour
  /// 🌅 Morning (5:00-11:59)
  /// ☀️ Afternoon (12:00-17:59)
  /// 🌆 Evening (18:00-21:59)
  /// 🌙 Night (22:00-4:59)
  String _getTimeOfDayPrefix(BuildContext context) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return context.l10n.morningPrefix; // 🌅 Morning / Mattutino
    } else if (hour >= 12 && hour < 18) {
      return context.l10n.afternoonPrefix; // ☀️ Afternoon / Pomeridiano
    } else if (hour >= 18 && hour < 22) {
      return context.l10n.eveningPrefix; // 🌆 Evening / Serale
    } else {
      return context.l10n.nightPrefix; // 🌙 Night / Notturno
    }
  }

  void _toggleCustomMode() {
    setState(() {
      _isCustomMode = true;
    });
    // Focus automatically after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _customFieldFocus.requestFocus();
    });
  }

  void _onCategorySelected(
    BuildContext context,
    String category,
    String workoutName,
  ) {
    // Get workout context from provider
    final workoutContext = ref.read(workoutContextProvider);

    // Add time-of-day prefix: "🌅 Morning Chest" / "🌅 Petto Mattutino"
    final timePrefix = _getTimeOfDayPrefix(context);
    String fullWorkoutName = '$timePrefix $workoutName';

    // Try to find a matching template based on context
    if (workoutContext != null) {
      final suggestedTemplate = _templateService.getSuggestedTemplate(
        context: workoutContext,
        category: category,
      );

      if (suggestedTemplate != null) {
        // Use template name with time prefix
        fullWorkoutName = '$timePrefix ${suggestedTemplate.name}';

        // Announce to screen reader (BEFORE navigate)
        SemanticsService.announce(
          context.l10n.workoutCreated(fullWorkoutName),
          TextDirection.ltr,
        );

        // Create a modified template with custom name
        final templateWithName = suggestedTemplate.copyWith(
          name: fullWorkoutName,
        );

        // Start workout from template with pre-populated exercises
        ref
            .read(currentWorkoutProvider.notifier)
            .startFromTemplate(templateWithName);

        // Close bottom sheet
        Navigator.pop(context);
        return;
      }
    }

    // Fallback: create empty workout if no template matches
    SemanticsService.announce(
      context.l10n.workoutCreated(fullWorkoutName),
      TextDirection.ltr,
    );

    ref.read(currentWorkoutProvider.notifier).createWorkout(fullWorkoutName);
    ref.read(currentWorkoutProvider.notifier).startWorkout();

    Navigator.pop(context);
  }

  void _onCustomWorkoutConfirm(BuildContext context) {
    final name = _customNameController.text.trim();

    // Validation: empty name
    if (name.isEmpty) {
      SnackBarService.showError(context, context.l10n.workoutNameRequired);
      return;
    }

    // Validation: too short
    if (name.length < 2) {
      SnackBarService.showError(context, context.l10n.workoutNameTooShort);
      return;
    }

    // Validation: too long
    if (name.length > 50) {
      SnackBarService.showError(context, context.l10n.workoutNameTooLong);
      return;
    }

    // Validation passed, create workout with custom category (no template matching)
    _onCategorySelected(context, 'custom', name);
  }
}
