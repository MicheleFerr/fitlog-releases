/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: iOS/Android/Universal
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Bottom sheet for selecting workout category or entering custom name.
///
/// Features:
/// - 8 category chips (Chest, Legs, Back, Arms, Cardio, Full Body, HIIT, Custom)
/// - Custom name input with validation
/// - Full accessibility support (screen reader, keyboard navigation)
/// - Material Design 3 compliant
/// - Theme-aware colors (dark/light mode)
class WorkoutCategoryBottomSheet extends StatefulWidget {
  const WorkoutCategoryBottomSheet({super.key});

  @override
  State<WorkoutCategoryBottomSheet> createState() =>
      _WorkoutCategoryBottomSheetState();
}

class _WorkoutCategoryBottomSheetState
    extends State<WorkoutCategoryBottomSheet> {
  bool _isCustomMode = false;
  final TextEditingController _customNameController = TextEditingController();
  final FocusNode _customFieldFocus = FocusNode();

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
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildCategoryChip(context, 'chest', '💪', 0),
          _buildCategoryChip(context, 'legs', '🦵', 1),
          _buildCategoryChip(context, 'back', '🔙', 2),
          _buildCategoryChip(context, 'arms', '💪', 3),
          _buildCategoryChip(context, 'cardio', '❤️', 4),
          _buildCategoryChip(context, 'fullBody', '🏋️', 5),
          _buildCategoryChip(context, 'hiit', '🔥', 6),
          _buildCustomChip(context, 7),
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

    switch (category) {
      case 'chest':
        label = context.l10n.chest;
        workoutName = context.l10n.chestWorkout;
        semanticLabel = context.l10n.selectChestWorkout;
        break;
      case 'legs':
        label = context.l10n.legs;
        workoutName = context.l10n.legsWorkout;
        semanticLabel = context.l10n.selectLegsWorkout;
        break;
      case 'back':
        label = context.l10n.back;
        workoutName = context.l10n.backWorkout;
        semanticLabel = context.l10n.selectBackWorkout;
        break;
      case 'arms':
        label = context.l10n.arms;
        workoutName = context.l10n.armsWorkout;
        semanticLabel = context.l10n.selectArmsWorkout;
        break;
      case 'cardio':
        label = context.l10n.cardio;
        workoutName = context.l10n.cardioWorkout;
        semanticLabel = context.l10n.selectCardioWorkout;
        break;
      case 'fullBody':
        label = context.l10n.fullBody;
        workoutName = context.l10n.fullBodyWorkout;
        semanticLabel = context.l10n.selectFullBodyWorkout;
        break;
      case 'hiit':
        label = context.l10n.hiit;
        workoutName = context.l10n.hiitWorkout;
        semanticLabel = context.l10n.selectHiitWorkout;
        break;
      default:
        label = category;
        workoutName = '$category Workout';
        semanticLabel = 'Select $category workout';
    }

    return FocusTraversalOrder(
      order: NumericFocusOrder(order.toDouble()),
      child: Semantics(
        label: semanticLabel,
        button: true,
        enabled: true,
        child: FilterChip(
          label: Text('$emoji $label'),
          selected: false,
          onSelected: (selected) => _onCategorySelected(context, workoutName),
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

  Widget _buildCustomChip(BuildContext context, int order) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(order.toDouble()),
      child: Semantics(
        label: context.l10n.selectCustomWorkout,
        button: true,
        enabled: true,
        child: FilterChip(
          label: Text('✏️ ${context.l10n.customWorkout}'),
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
      order: NumericFocusOrder(8.0),
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

  void _onCategorySelected(BuildContext context, String workoutName) {
    // Get WidgetRef from context
    final ref = ProviderScope.containerOf(context);

    // Add time-of-day prefix: "🌅 Morning Chest" / "🌅 Petto Mattutino"
    final timePrefix = _getTimeOfDayPrefix(context);
    final fullWorkoutName = '$timePrefix $workoutName';

    // Announce to screen reader (BEFORE navigate)
    SemanticsService.announce(
      context.l10n.workoutCreated(fullWorkoutName),
      TextDirection.ltr,
    );

    // Create workout with time-prefixed name
    ref.read(currentWorkoutProvider.notifier).createWorkout(fullWorkoutName);

    // Start workout
    ref.read(currentWorkoutProvider.notifier).startWorkout();

    // Close bottom sheet
    Navigator.pop(context);
  }

  void _onCustomWorkoutConfirm(BuildContext context) {
    final name = _customNameController.text.trim();

    // Validation: empty name
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.workoutNameRequired),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    // Validation: too short
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.workoutNameTooShort),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    // Validation: too long
    if (name.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.workoutNameTooLong),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    // Validation passed, create workout
    _onCategorySelected(context, name);
  }
}
