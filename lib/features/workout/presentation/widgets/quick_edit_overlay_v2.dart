/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// QuickEditOverlayV2 - Optimized version with better UX and performance
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart'; // ✅ NUOVO
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/last_workout_set_data.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/plate_calculator_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class QuickEditOverlayV2 extends ConsumerStatefulWidget {
  const QuickEditOverlayV2({
    super.key,
    this.exerciseSet,
    this.onSave,
    required this.onCancel,
    required this.position,
    this.previousSet,
    this.exerciseName,
    this.setNumber, // For querying last workout data
    this.exerciseNames,
    this.exerciseSets,
    this.onSupersetSave,
    this.isSuperset = false,
    this.countingMode = ExerciseCountingMode.weighted, // ✅ NUOVO
    // ✅ NEW: Quick edit workflow parameters
    this.currentSetIndex,
    this.totalSets,
    this.onSaveAndNext,
    this.onSaveAndPrevious,
    this.onApplyToRemaining,
  }) : assert(
         (!isSuperset && exerciseSet != null && onSave != null) ||
             (isSuperset &&
                 exerciseNames != null &&
                 exerciseSets != null &&
                 onSupersetSave != null),
         'For superset mode, exerciseNames, exerciseSets and onSupersetSave are required',
       );
  final ExerciseSet? exerciseSet; // Nullable per superset
  final Function(ExerciseSet)? onSave; // Nullable per superset
  final VoidCallback onCancel;
  final Offset position;
  final ExerciseSet? previousSet;
  final String? exerciseName;
  final int? setNumber; // For querying last workout data (1-based)
  final ExerciseCountingMode
  countingMode; // ✅ NUOVO: Determines which fields to show/edit

  // ✅ NEW: Quick edit workflow parameters
  final int? currentSetIndex; // 0-based index of current set being edited
  final int? totalSets; // Total number of sets in exercise
  final Function(ExerciseSet)?
  onSaveAndNext; // Callback for swipe left / "Save + Next"
  final Function(ExerciseSet)?
  onSaveAndPrevious; // Callback for swipe right (go to previous set)
  final Function(ExerciseSet, int remainingCount)?
  onApplyToRemaining; // Callback for applying to remaining sets

  // Superset support
  final List<String>? exerciseNames;
  final Map<String, ExerciseSet>? exerciseSets;
  final Function(Map<String, ExerciseSet>)? onSupersetSave;
  final bool isSuperset;

  @override
  ConsumerState<QuickEditOverlayV2> createState() => _QuickEditOverlayV2State();
}

class _QuickEditOverlayV2State extends ConsumerState<QuickEditOverlayV2>
    with SingleTickerProviderStateMixin {
  // Animation
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Values - single or superset
  late double _selectedWeight;
  late int _selectedReps;
  late int _selectedSeconds; // ✅ NUOVO: For time-based exercises

  // Superset values
  final Map<String, double> _supersetWeights = {};
  final Map<String, int> _supersetReps = {};
  final Map<String, int> _supersetSeconds = {}; // ✅ NUOVO
  int _currentExerciseIndex = 0;

  // Apply to All states
  bool _isWeightAppliedToAll = false;
  bool _isRepsAppliedToAll = false;

  // ✅ NEW: Apply to remaining sets toggle
  bool _applyToRemaining = false;

  // Controllers
  late FixedExtentScrollController _weightController;
  late FixedExtentScrollController _repsController;
  late FixedExtentScrollController _secondsController; // ✅ NUOVO
  late TextEditingController _weightTextController;
  late TextEditingController _repsTextController;
  late TextEditingController _secondsTextController; // ✅ NUOVO

  // Focus
  final _weightFocusNode = FocusNode();
  final _repsFocusNode = FocusNode();
  final _secondsFocusNode = FocusNode(); // ✅ NUOVO

  // UI State
  bool _isManualWeightEntry = false;
  bool _isManualRepsEntry = false;
  bool _isManualSecondsEntry = false; // ✅ NUOVO
  bool _usePercentage = false;
  double _percentageValue = 5.0;

  // Positioning state - calculate once
  late final _SmartPositioning _positioning;

  // Keyboard state tracking
  bool _isRequestingFocus = false;

  @override
  void initState() {
    super.initState();

    // Calculate position once
    _positioning = _calculateInitialPosition();

    if (widget.isSuperset) {
      // Initialize superset values
      for (String exerciseName in widget.exerciseNames!) {
        final exerciseSet = widget.exerciseSets![exerciseName];
        _supersetWeights[exerciseName] = exerciseSet?.weight ?? 20.0;
        _supersetReps[exerciseName] = exerciseSet?.reps ?? 10;
        _supersetSeconds[exerciseName] = exerciseSet?.seconds ?? 60; // ✅ NUOVO
      }
      // Set current values to first exercise
      final firstExercise = widget.exerciseNames!.first;
      _selectedWeight = _supersetWeights[firstExercise]!;
      _selectedReps = _supersetReps[firstExercise]!;
      _selectedSeconds = _supersetSeconds[firstExercise]!; // ✅ NUOVO
    } else {
      // Initialize single exercise values
      _selectedWeight = widget.exerciseSet!.weight ?? 0.0;
      _selectedReps = widget.exerciseSet!.reps ?? 0;
      _selectedSeconds =
          widget.exerciseSet!.seconds ?? 60; // ✅ NUOVO: Default 60 seconds
    }

    // Controllers
    _weightController = FixedExtentScrollController(
      initialItem: (_selectedWeight * 2).round(),
    );
    _repsController = FixedExtentScrollController(
      initialItem: _selectedReps > 0 ? _selectedReps - 1 : 0,
    );
    _secondsController = FixedExtentScrollController(
      initialItem: _selectedSeconds.clamp(
        0,
        600,
      ), // ✅ NUOVO: 0-600 seconds range
    );

    _weightTextController = TextEditingController(
      text: _selectedWeight.toString(),
    );
    _repsTextController = TextEditingController(text: _selectedReps.toString());
    _secondsTextController = TextEditingController(
      text: _selectedSeconds.toString(),
    ); // ✅ NUOVO

    // OPTIMIZED: Simpler, faster animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Focus listeners
    _weightFocusNode.addListener(_onWeightFocusChanged);
    _repsFocusNode.addListener(_onRepsFocusChanged);
    _secondsFocusNode.addListener(_onSecondsFocusChanged); // ✅ NUOVO
  }

  void _onWeightFocusChanged() {
    if (_weightFocusNode.hasFocus) {
      _weightTextController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _weightTextController.text.length,
      );
    }
  }

  void _onRepsFocusChanged() {
    if (_repsFocusNode.hasFocus) {
      _repsTextController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _repsTextController.text.length,
      );
    }
  }

  // ✅ NUOVO: Focus handler for seconds
  void _onSecondsFocusChanged() {
    if (_secondsFocusNode.hasFocus) {
      _secondsTextController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _secondsTextController.text.length,
      );
    }
  }

  _SmartPositioning _calculateInitialPosition() {
    // ✅ CHANGED: Always use bottom sheet mode for better UX
    // The old positioned overlay approach caused issues with keyboard and space
    return const _SmartPositioning(
      left: 0,
      top: 0,
      showAsBottomSheet: true, // Always show as bottom sheet
    );
  }

  @override
  void dispose() {
    _weightFocusNode.removeListener(_onWeightFocusChanged);
    _repsFocusNode.removeListener(_onRepsFocusChanged);
    _secondsFocusNode.removeListener(_onSecondsFocusChanged); // ✅ NUOVO
    _animationController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _secondsController.dispose(); // ✅ NUOVO
    _weightTextController.dispose();
    _repsTextController.dispose();
    _secondsTextController.dispose(); // ✅ NUOVO
    _weightFocusNode.dispose();
    _repsFocusNode.dispose();
    _secondsFocusNode.dispose(); // ✅ NUOVO
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // OPTIMIZED: Use .select() for better performance
    final measurementUnit = ref.watch(
      appConfigProvider.select((config) => config.measurementUnit),
    );
    final plateCalculatorEnabled = ref.watch(
      appConfigProvider.select((config) => config.plateCalculator ?? true),
    );

    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size; // Get screen size here
    const overlayWidth = 340.0;

    // Use pre-calculated position
    final double left = _positioning.left;
    final double top = _positioning.top;
    final bool showAsBottomSheet = _positioning.showAsBottomSheet;

    if (showAsBottomSheet) {
      // Show as bottom sheet - always used now
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 10),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Align(
                alignment: Alignment.bottomCenter,
                // ✅ NEW: Wrap in GestureDetector for swipe navigation
                child: Semantics(
                  label: 'Quick edit overlay',
                  hint: 'Swipe horizontally to navigate between sets, swipe down to close',
                  child: GestureDetector(
                    onHorizontalDragEnd: _handleHorizontalSwipe,
                    onVerticalDragEnd: _handleVerticalSwipe,
                    child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxHeight: screenSize.height * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 24,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(theme),
                          // ✅ NEW: Show swipe hint if navigation is available
                          if (_hasSwipeNavigation) _buildSwipeHint(theme),
                          const SizedBox(height: 12),
                          _buildContent(
                            theme,
                            measurementUnit,
                            plateCalculatorEnabled,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ),
          );
        },
      );
    }

    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(opacity: _fadeAnimation.value, child: child),
          );
        },
        child: Material(
          color: theme.colorScheme.surface.withValues(alpha: 0),
          child: Stack(
            children: [
              Container(
                width: overlayWidth,
                constraints: const BoxConstraints(maxHeight: 600),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 12),
                    _buildContent(
                      theme,
                      measurementUnit,
                      plateCalculatorEnabled,
                    ),
                  ],
                ),
              ),
              // Removed: Gesture hint overlay - no longer needed
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                widget.isSuperset
                    ? AppIcons.fitnessCenter
                    : AppIcons.editNoteRounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isSuperset
                      ? 'Quick Edit Superset' // TODO: Add localization key
                      : (widget.exerciseName ??
                            'Quick Edit Set ${widget.exerciseSet?.setNumber ?? ""}'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.previousSet != null && !widget.isSuperset)
                TextButton.icon(
                  onPressed: _copyFromPreviousSet,
                  icon: const SemanticIcon(
                    icon: AppIcons.contentCopyRounded,
                    semanticLabel: 'Content copy rounded',
                    size: AppIconSize.tiny,
                  ),
                  label: Text(
                    AppLocalizations.of(context).copy,
                    style: theme.textTheme.labelMedium,
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          if (widget.isSuperset) ...[
            const SizedBox(height: 12),
            _buildExerciseTabs(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    String measurementUnit,
    bool plateCalculatorEnabled,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ NUOVO: Conditional pickers based on counting mode
          Row(
            children: [
              // Conditional weight picker (only for weighted mode)
              if (widget.countingMode.requiresWeight)
                Expanded(child: _buildWeightPicker(theme, measurementUnit)),

              // Conditional spacing
              if (widget.countingMode.requiresWeight &&
                  (widget.countingMode.requiresReps ||
                      widget.countingMode.requiresTime))
                const SizedBox(width: 16),

              // Conditional reps picker (for weighted + reps modes)
              if (widget.countingMode.requiresReps)
                Expanded(child: _buildRepsPicker(theme)),

              // Conditional seconds picker (for time mode)
              if (widget.countingMode.requiresTime)
                Expanded(child: _buildSecondsPicker(theme)),
            ],
          ),

          const SizedBox(height: 16),

          // Last Workout badge (Feature 1 - Pre-fill)
          if (widget.exerciseName != null &&
              widget.setNumber != null &&
              !widget.isSuperset) ...[
            _buildLastWorkoutBadge(theme),
            const SizedBox(height: 12),
          ],

          // Recent Weights (if available)
          if (widget.exerciseName != null ||
              (widget.isSuperset && widget.exerciseNames != null)) ...[
            _buildRecentWeights(theme),
            const SizedBox(height: 16),
          ],

          // Apply to All buttons for superset
          if (widget.isSuperset) ...[
            _buildApplyToAllButtons(theme),
            const SizedBox(height: 16),
          ],

          // NEW: Primary Control Toolbar
          _buildPrimaryToolbar(theme, measurementUnit, plateCalculatorEnabled),

          const SizedBox(height: 12),

          // Adjustment Buttons
          _buildAdjustmentButtons(theme),

          const SizedBox(height: 20),

          // Action Buttons
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildWeightPicker(ThemeData theme, String measurementUnit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SemanticIcon(
              icon: AppIcons.workout,
              semanticLabel: 'Workout',
              size: AppIconSize.tiny,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(
                context,
              ).weightKg.replaceAll('kg', measurementUnit),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                _isManualWeightEntry ? Icons.dialpad : AppIcons.keyboard,
                size: 16,
              ),
              onPressed: () {
                setState(() {
                  _isManualWeightEntry = !_isManualWeightEntry;
                });
                if (!_isManualWeightEntry) {
                  // Unfocus when going back to wheel mode
                  _weightFocusNode.unfocus();
                } else if (!_isRequestingFocus) {
                  // Prevent multiple focus requests
                  _isRequestingFocus = true;
                  // Use a longer delay to ensure the widget is fully built
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted && _isManualWeightEntry) {
                      _weightFocusNode.requestFocus();
                      _isRequestingFocus = false;
                    }
                  });
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: _isManualWeightEntry ? 'Use wheel' : 'Type manually',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: _isManualWeightEntry
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _weightTextController,
                          focusNode: _weightFocusNode,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            fontSize: _selectedWeight >= 100
                                ? 20
                                : 24, // Dynamic font size
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffix: Text(
                              measurementUnit,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            // Update weight as user types
                            final weight = double.tryParse(
                              value.replaceAll(',', '.'),
                            );
                            if (weight != null) {
                              setState(() {
                                _selectedWeight = weight;
                              });
                            }
                          },
                          onSubmitted: (value) {
                            _confirmManualWeight();
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: _confirmManualWeight,
                        icon: Icon(
                          AppIcons.complete,
                          color: theme.colorScheme.primary,
                        ),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        tooltip: 'Done',
                      ),
                    ],
                  ),
                )
              : ListWheelScrollView.useDelegate(
                  controller: _weightController,
                  itemExtent: 36,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 401,
                    builder: (context, index) {
                      final weight = index / 2.0;
                      final isSelected = (weight - _selectedWeight).abs() < 0.1;
                      return Center(
                        child: Text(
                          weight % 1 == 0
                              ? weight.toInt().toString()
                              : weight.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedWeight = index / 2.0;
                      _weightTextController.text = _selectedWeight.toString();

                      // Auto-apply to all if weight mode is active
                      if (widget.isSuperset && _isWeightAppliedToAll) {
                        for (String exerciseName in widget.exerciseNames!) {
                          _supersetWeights[exerciseName] = _selectedWeight;
                        }
                      }
                    });
                    HapticFeedback.selectionClick();
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRepsPicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SemanticIcon(
              icon: AppIcons.repeat,
              semanticLabel: 'Repeat',
              size: AppIconSize.tiny,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).reps,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                _isManualRepsEntry ? Icons.dialpad : AppIcons.keyboard,
                size: 16,
              ),
              onPressed: () {
                setState(() {
                  _isManualRepsEntry = !_isManualRepsEntry;
                });
                if (!_isManualRepsEntry) {
                  // Unfocus when going back to wheel mode
                  _repsFocusNode.unfocus();
                } else if (!_isRequestingFocus) {
                  // Prevent multiple focus requests
                  _isRequestingFocus = true;
                  // Use a longer delay to ensure the widget is fully built
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted && _isManualRepsEntry) {
                      _repsFocusNode.requestFocus();
                      _isRequestingFocus = false;
                    }
                  });
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: _isManualRepsEntry ? 'Use wheel' : 'Type manually',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.secondary.withValues(alpha: 0.2),
            ),
          ),
          child: _isManualRepsEntry
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _repsTextController,
                          focusNode: _repsFocusNode,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                            fontSize: 24,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            // Update reps as user types
                            final reps = int.tryParse(value);
                            if (reps != null && reps > 0) {
                              setState(() {
                                _selectedReps = reps;
                              });
                            }
                          },
                          onSubmitted: (value) {
                            _confirmManualReps();
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: _confirmManualReps,
                        icon: Icon(
                          AppIcons.complete,
                          color: theme.colorScheme.secondary,
                        ),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        tooltip: 'Done',
                      ),
                    ],
                  ),
                )
              : ListWheelScrollView.useDelegate(
                  controller: _repsController,
                  itemExtent: 36,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 50,
                    builder: (context, index) {
                      final reps = index + 1;
                      final isSelected = reps == _selectedReps;
                      return Center(
                        child: Text(
                          reps.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedReps = index + 1;
                      _repsTextController.text = _selectedReps.toString();

                      // Auto-apply to all if reps mode is active
                      if (widget.isSuperset && _isRepsAppliedToAll) {
                        for (String exerciseName in widget.exerciseNames!) {
                          _supersetReps[exerciseName] = _selectedReps;
                        }
                      }
                    });
                    HapticFeedback.selectionClick();
                  },
                ),
        ),
      ],
    );
  }

  // ✅ NUOVO: Seconds picker for time-based exercises
  Widget _buildSecondsPicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SemanticIcon(
              icon: AppIcons.timer,
              semanticLabel: 'Timer',
              size: AppIconSize.tiny,
              color: theme.colorScheme.tertiary,
            ),
            const SizedBox(width: 4),
            Text(
              'Duration', // TODO: Add localization
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                _isManualSecondsEntry ? Icons.dialpad : AppIcons.keyboard,
                size: 16,
              ),
              onPressed: () {
                setState(() {
                  _isManualSecondsEntry = !_isManualSecondsEntry;
                });
                if (!_isManualSecondsEntry) {
                  _secondsFocusNode.unfocus();
                } else if (!_isRequestingFocus) {
                  _isRequestingFocus = true;
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted && _isManualSecondsEntry) {
                      _secondsFocusNode.requestFocus();
                      _isRequestingFocus = false;
                    }
                  });
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: _isManualSecondsEntry ? 'Use wheel' : 'Type manually',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
            ),
          ),
          child: _isManualSecondsEntry
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width:
                            110, // ✅ MODIFICATO: Increased from 80 to 110 for 3-digit seconds (e.g., "100s")
                        child: TextField(
                          controller: _secondsTextController,
                          focusNode: _secondsFocusNode,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.tertiary,
                            fontSize: 24,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffix: Text(
                              's',
                              style: theme.textTheme.labelMedium,
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            final seconds = int.tryParse(value);
                            if (seconds != null && seconds > 0) {
                              setState(() {
                                _selectedSeconds = seconds;
                              });
                            }
                          },
                          onSubmitted: (value) {
                            _confirmManualSeconds();
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: _confirmManualSeconds,
                        icon: Icon(
                          AppIcons.checkCircle,
                          color: theme.colorScheme.tertiary,
                        ),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        tooltip: 'Done',
                      ),
                    ],
                  ),
                )
              : ListWheelScrollView.useDelegate(
                  controller: _secondsController,
                  itemExtent: 36,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    // ✅ FIX: Limit to 6:00 (360 seconds) for time-based exercises
                    // User requested "fino a 5 minuti e 60 secondi" = 5:60 = 6:00
                    childCount: 361, // 0-360 seconds (0:00 to 6:00)
                    builder: (context, index) {
                      final seconds = index;
                      final isSelected = seconds == _selectedSeconds;
                      return Center(
                        child: Text(
                          seconds < 60
                              ? '${seconds}s'
                              : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedSeconds = index;
                      _secondsTextController.text = _selectedSeconds.toString();

                      // Auto-apply to all if seconds mode is active (for superset)
                      if (widget.isSuperset && _isRepsAppliedToAll) {
                        for (String exerciseName in widget.exerciseNames!) {
                          _supersetSeconds[exerciseName] = _selectedSeconds;
                        }
                      }
                    });
                    HapticFeedback.selectionClick();
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRecentWeights(ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        // Get exercise name for recent weights
        final exerciseName = widget.isSuperset
            ? widget.exerciseNames![_currentExerciseIndex]
            : widget.exerciseName!;

        final recentWeightsAsync = ref.watch(
          recentWeightsWithDetailsProvider(exerciseName),
        );

        return recentWeightsAsync.when(
          data: (weights) {
            // DEBUG: Show message when no history found
            if (weights.isEmpty) {
              if (kDebugMode) {
                debugPrint('[QuickEdit] No recent weights for: $exerciseName');
              }
              return const SizedBox.shrink();
            }

            // Take up to 10 weights for horizontal slider
            final displayWeights = weights.take(10).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SemanticIcon(
                      icon: AppIcons.history,
                      semanticLabel: 'History',
                      size: AppIconSize.tiny,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context).recentWeights,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // ✅ HORIZONTAL SLIDER instead of Wrap (saves vertical space)
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: displayWeights.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final data = displayWeights[index];
                      final weight = data.weight ?? 0;
                      final isSelected = (_selectedWeight - weight).abs() < 0.1;
                      final threeDaysAgo = DateTime.now().subtract(
                        const Duration(days: 3),
                      );
                      final isFromLast3Days = data.date.isAfter(threeDaysAgo);

                      return Semantics(
                        label: 'Select weight ${weight.toStringAsFixed(1)}kg',
                        button: true,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _setWeight(weight);
                          },
                          child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : isFromLast3Days
                                ? theme.colorScheme.primaryContainer.withValues(
                                    alpha: 0.8,
                                  )
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : isFromLast3Days
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.5,
                                    )
                                  : theme.colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : isFromLast3Days
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 36,
            child: Center(child: LoadingIndicator(size: 16)),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  /// Build "Last Workout" badge for pre-fill functionality (Feature 1)
  /// Shows weight/reps from the same set number in the previous completed workout
  /// ✅ COMPACT VERSION - Single row to save vertical space
  Widget _buildLastWorkoutBadge(ThemeData theme) {
    // Only show for single exercise mode (not superset) with valid exercise name and set number
    if (widget.isSuperset ||
        widget.exerciseName == null ||
        widget.setNumber == null) {
      return const SizedBox.shrink();
    }

    return Consumer(
      builder: (context, ref, child) {
        final lastWorkoutAsync = ref.watch(
          lastCompletedWorkoutSetProvider(
            LastWorkoutSetParams(
              exerciseName: widget.exerciseName!,
              setNumber: widget.setNumber!,
            ),
          ),
        );

        return lastWorkoutAsync.when(
          data: (lastWorkoutData) {
            if (lastWorkoutData == null) {
              return const SizedBox.shrink();
            }

            // Format the date compactly
            final now = DateTime.now();
            final daysDiff = now.difference(lastWorkoutData.date).inDays;
            String dateLabel;
            if (daysDiff == 0) {
              dateLabel = AppLocalizations.of(context).today;
            } else if (daysDiff == 1) {
              dateLabel = AppLocalizations.of(context).yesterday;
            } else if (daysDiff < 7) {
              dateLabel = '${daysDiff}d';
            } else {
              dateLabel =
                  '${lastWorkoutData.date.day}/${lastWorkoutData.date.month}';
            }

            // ✅ COMPACT SINGLE-ROW LAYOUT
            return Material(
              color: context.colors.surface.withValues(alpha: 0),
              child: Semantics(
                label: 'Apply last workout values',
                button: true,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _applyLastWorkoutValues(lastWorkoutData);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.tertiaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        theme.colorScheme.tertiaryContainer.withValues(
                          alpha: 0.3,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon + Label
                      SemanticIcon(
                        icon: AppIcons.history,
                        semanticLabel: 'Last Workout',
                        size: AppIconSize.tiny,
                        color: theme.colorScheme.tertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context).lastWorkout,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Date badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dateLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Weight + Reps compact
                      Text(
                        '${lastWorkoutData.weight.toStringAsFixed(lastWorkoutData.weight % 1 == 0 ? 0 : 1)}kg',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                      Text(
                        ' × ',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '${lastWorkoutData.reps}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tap hint
                      SemanticIcon(
                        icon: AppIcons.touchApp,
                        semanticLabel: 'Tap to apply',
                        size: AppIconSize.tiny,
                        color: theme.colorScheme.tertiary.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          },
          loading: () => const SizedBox.shrink(), // Don't show loading state
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  /// Apply values from last workout to current fields
  void _applyLastWorkoutValues(LastWorkoutSetData data) {
    // Apply weight
    _setWeight(data.weight);

    // Apply reps
    setState(() {
      _selectedReps = data.reps;
      _repsTextController.text = _selectedReps.toString();
    });
    _repsController.animateToItem(
      _selectedReps > 0 ? _selectedReps - 1 : 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    HapticFeedback.mediumImpact();
  }

  // NEW: Redesigned Primary Toolbar
  Widget _buildPrimaryToolbar(
    ThemeData theme,
    String measurementUnit,
    bool plateCalculatorEnabled,
  ) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // Mode Toggle - Clear segmented control
          _buildModeToggle(theme, plateCalculatorEnabled, measurementUnit),

          const SizedBox(width: 12),

          // Dynamic content area
          Expanded(
            child: _usePercentage
                ? _buildPercentageSlider(theme)
                : const SizedBox.shrink(),
          ),

          const SizedBox(width: 12),

          // ✅ FIXED: Plate Calculator - Only visible for weighted mode AND when toggle enabled
          if (widget.countingMode.requiresWeight && plateCalculatorEnabled)
            _buildPlateCalculatorButton(theme, measurementUnit),
        ],
      ),
    );
  }

  Widget _buildModeToggle(
    ThemeData theme,
    bool plateCalculatorEnabled,
    String measurementUnit,
  ) {
    // ✅ MODIFICATO: Different labels based on counting mode
    final String absoluteLabel = widget.countingMode.requiresTime
        ? AppLocalizations.of(context)
              .duration // "Secondi" or "Duration"
        : 'KG';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(absoluteLabel, !_usePercentage, theme, () {
            setState(() => _usePercentage = false);
            HapticFeedback.selectionClick();
          }),
          _buildModeButton('%', _usePercentage, theme, () {
            setState(() => _usePercentage = true);
            HapticFeedback.selectionClick();
          }),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    String label,
    bool isSelected,
    ThemeData theme,
    VoidCallback onTap,
  ) {
    return Semantics(
      label: 'Switch to $label mode',
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
      ),
    );
  }

  // NEW: Intuitive percentage slider
  Widget _buildPercentageSlider(ThemeData theme) {
    return Row(
      children: [
        Text(
          '${_percentageValue.toInt()}%',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: theme.colorScheme.primary.withValues(
                alpha: 0.2,
              ),
              thumbColor: theme.colorScheme.primary,
              overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: _percentageValue,
              min: 1,
              max: 20,
              divisions: 19,
              onChanged: (value) {
                setState(() => _percentageValue = value);
                HapticFeedback.selectionClick();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlateCalculatorButton(ThemeData theme, String measurementUnit) {
    final hasWeight = _selectedWeight > 0;

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0),
      child: Semantics(
        label: 'Plate calculator',
        hint: hasWeight ? 'Calculate barbell plates for $_selectedWeight kg' : null,
        button: true,
        child: InkWell(
          onTap: hasWeight ? () => _showPlateCalculator(context) : null,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: hasWeight
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.secondary,
                      theme.colorScheme.secondary.withValues(alpha: 0.8),
                    ],
                  )
                : null,
            color: !hasWeight
                ? theme.colorScheme.surfaceContainerHighest
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SemanticIcon(
                icon: AppIcons.calculateRounded,
                semanticLabel: 'Calculate rounded',
                size: AppIconSize.tiny,
                color: hasWeight
                    ? theme.colorScheme.onSecondary
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Text(
                'Plates', // Using simple English until localization key is added
                style: theme.textTheme.labelMedium?.copyWith(
                  color: hasWeight
                      ? theme.colorScheme.onSecondary
                      : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdjustmentButtons(ThemeData theme) {
    // ✅ MODIFICATO: Different buttons based on counting mode
    if (_usePercentage) {
      // Percentage mode - works for both weight and time
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAdjustButton(
            '-${_percentageValue.toInt()}%',
            () => widget.countingMode.requiresTime
                ? _adjustSecondsByPercentage(-_percentageValue)
                : _adjustWeightByPercentage(-_percentageValue),
            theme.colorScheme.error,
            theme,
          ),
          const SizedBox(width: 12),
          _buildAdjustButton(
            '+${_percentageValue.toInt()}%',
            () => widget.countingMode.requiresTime
                ? _adjustSecondsByPercentage(_percentageValue)
                : _adjustWeightByPercentage(_percentageValue),
            theme.colorScheme.primary,
            theme,
          ),
        ],
      );
    }

    // Absolute mode - different buttons for time vs weight
    if (widget.countingMode.requiresTime) {
      // Time mode: -20s, -5s, +5s, +20s
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAdjustButton(
            '-20s',
            () => _adjustSeconds(-20),
            theme.colorScheme.error,
            theme,
          ),
          const SizedBox(width: 8),
          _buildAdjustButton(
            '-5s',
            () => _adjustSeconds(-5),
            theme.colorScheme.error.withValues(alpha: 0.7),
            theme,
          ),
          const SizedBox(width: 8),
          _buildAdjustButton(
            '+5s',
            () => _adjustSeconds(5),
            theme.colorScheme.primary,
            theme,
          ),
          const SizedBox(width: 8),
          _buildAdjustButton(
            '+20s',
            () => _adjustSeconds(20),
            theme.colorScheme.tertiary,
            theme,
          ),
        ],
      );
    }

    // Weight mode: -2.5, +2.5, +5, +10
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAdjustButton(
          '-2.5',
          () => _adjustWeight(-2.5),
          theme.colorScheme.error,
          theme,
        ),
        const SizedBox(width: 8),
        _buildAdjustButton(
          '+2.5',
          () => _adjustWeight(2.5),
          theme.colorScheme.primary,
          theme,
        ),
        const SizedBox(width: 8),
        _buildAdjustButton(
          '+5',
          () => _adjustWeight(5),
          theme.colorScheme.primary,
          theme,
        ),
        const SizedBox(width: 8),
        _buildAdjustButton(
          '+10',
          () => _adjustWeight(10),
          theme.colorScheme.tertiary,
          theme,
        ),
      ],
    );
  }

  Widget _buildAdjustButton(
    String label,
    VoidCallback onTap,
    Color color,
    ThemeData theme,
  ) {
    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0),
      child: Semantics(
        label: 'Adjust weight $label kg',
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    // Calculate remaining sets for "Apply to remaining" toggle
    final hasRemainingSets =
        widget.currentSetIndex != null &&
        widget.totalSets != null &&
        widget.currentSetIndex! < widget.totalSets! - 1;
    final remainingCount = hasRemainingSets
        ? widget.totalSets! - widget.currentSetIndex! - 1
        : 0;

    // Check if "Save + Next" should be shown
    final showSaveAndNext = widget.onSaveAndNext != null && hasRemainingSets;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ NEW: Apply to remaining sets toggle (only if there are remaining sets)
        if (hasRemainingSets && widget.onApplyToRemaining != null) ...[
          Material(
            color: theme.colorScheme.surface.withValues(alpha: 0),
            child: Semantics(
              label: AppLocalizations.of(context).applyToRemainingNSets(remainingCount),
              button: true,
              selected: _applyToRemaining,
              child: InkWell(
                onTap: () {
                  setState(() => _applyToRemaining = !_applyToRemaining);
                  HapticFeedback.selectionClick();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _applyToRemaining
                      ? theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.5,
                        )
                      : theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _applyToRemaining
                        ? theme.colorScheme.primary.withValues(alpha: 0.5)
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    SemanticIcon(
                      icon: _applyToRemaining
                          ? AppIcons.checkCircle
                          : AppIcons.circleOutlined,
                      semanticLabel: 'Apply toggle',
                      size: AppIconSize.small,
                      color: _applyToRemaining
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).applyToRemainingNSets(remainingCount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _applyToRemaining
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight: _applyToRemaining
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
          const SizedBox(height: 12),
        ],

        // Action buttons row
        Row(
          children: [
            // Cancel button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _cancel,
                icon: const SemanticIcon(
                  icon: AppIcons.closeRounded,
                  semanticLabel: 'Close rounded',
                  size: AppIconSize.small,
                ),
                label: Text(AppLocalizations.of(context).cancel),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ✅ NEW: Save + Next button (only if there are more sets)
            if (showSaveAndNext) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveAndNext,
                  icon: const SemanticIcon(
                    icon: AppIcons.skipNext,
                    semanticLabel: 'Next',
                    size: AppIconSize.small,
                  ),
                  label: Text(AppLocalizations.of(context).saveAndNext),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Save button
            Expanded(
              flex: showSaveAndNext ? 1 : 2,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const SemanticIcon(
                  icon: AppIcons.checkRounded,
                  semanticLabel: 'Check rounded',
                  size: AppIconSize.small,
                ),
                label: Text(AppLocalizations.of(context).save),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _setWeight(double weight) {
    setState(() {
      _selectedWeight = weight;
      _weightTextController.text = weight.toString();
    });

    final newIndex = (weight * 2).round();
    _weightController.animateToItem(
      newIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    HapticFeedback.lightImpact();
  }

  void _confirmManualWeight() {
    final weight = double.tryParse(
      _weightTextController.text.replaceAll(',', '.'),
    );
    if (weight != null && weight > 0) {
      setState(() {
        _selectedWeight = weight;
        _isManualWeightEntry = false;
      });
      _weightController.animateToItem(
        (weight * 2).round(),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _weightFocusNode.unfocus();
      HapticFeedback.lightImpact();
    }
  }

  void _confirmManualReps() {
    final reps = int.tryParse(_repsTextController.text);
    if (reps != null && reps > 0) {
      setState(() {
        _selectedReps = reps;
        _isManualRepsEntry = false;
      });
      _repsController.animateToItem(
        reps - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _repsFocusNode.unfocus();
      HapticFeedback.lightImpact();
    }
  }

  // ✅ NUOVO: Confirm manual seconds entry
  void _confirmManualSeconds() {
    final seconds = int.tryParse(_secondsTextController.text);
    if (seconds != null && seconds > 0) {
      setState(() {
        _selectedSeconds = seconds.clamp(0, 600);
        _isManualSecondsEntry = false;
      });
      _secondsController.animateToItem(
        _selectedSeconds,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _secondsFocusNode.unfocus();
      HapticFeedback.lightImpact();
    }
  }

  void _adjustWeight(double delta) {
    final newWeight = (_selectedWeight + delta).clamp(0.0, 500.0);
    _setWeight((newWeight * 2).round() / 2); // Round to 0.5kg
  }

  void _adjustWeightByPercentage(double percentage) {
    final adjustment = _selectedWeight * (percentage / 100);
    final newWeight = (_selectedWeight + adjustment).clamp(0.0, 500.0);
    _setWeight((newWeight * 2).round() / 2); // Round to 0.5kg
  }

  // ✅ NUOVO: Adjust seconds by fixed amount
  void _adjustSeconds(int delta) {
    final newSeconds = (_selectedSeconds + delta).clamp(5, 600); // 5s to 10min
    _setSeconds(newSeconds);
  }

  // ✅ NUOVO: Adjust seconds by percentage
  void _adjustSecondsByPercentage(double percentage) {
    final adjustment = (_selectedSeconds * (percentage / 100)).round();
    final newSeconds = (_selectedSeconds + adjustment).clamp(5, 600);
    _setSeconds(newSeconds);
  }

  // ✅ NUOVO: Set seconds value
  void _setSeconds(int seconds) {
    setState(() {
      _selectedSeconds = seconds;
      _secondsTextController.text = seconds.toString();

      if (widget.isSuperset) {
        final currentExercise = widget.exerciseNames![_currentExerciseIndex];
        _supersetSeconds[currentExercise] = _selectedSeconds;
      }
    });

    // Update controller
    _secondsController.animateToItem(
      seconds,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );

    HapticFeedback.selectionClick();
  }

  void _copyFromPreviousSet() {
    final previousSet = widget.previousSet;
    if (previousSet == null) return;

    final weight = previousSet.weight;
    if (weight != null) {
      _setWeight(weight);
    }

    final reps = previousSet.reps;
    if (reps != null) {
      setState(() {
        _selectedReps = reps;
        _repsTextController.text = _selectedReps.toString();
      });
      _repsController.animateToItem(
        _selectedReps - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    // ✅ NUOVO: Copy seconds for time-based exercises
    final seconds = previousSet.seconds;
    if (seconds != null) {
      setState(() {
        _selectedSeconds = seconds;
        _secondsTextController.text = _selectedSeconds.toString();
      });
      _secondsController.animateToItem(
        _selectedSeconds,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    HapticFeedback.mediumImpact();
  }

  Widget _buildExerciseTabs(ThemeData theme) {
    if (!widget.isSuperset) return const SizedBox.shrink();

    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.exerciseNames!.length,
        itemBuilder: (context, index) {
          final exerciseName = widget.exerciseNames![index];
          final isSelected = index == _currentExerciseIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: theme.colorScheme.surface.withValues(alpha: 0),
              child: Semantics(
                label: exerciseName,
                button: true,
                selected: isSelected,
                child: InkWell(
                  onTap: () => _switchToExercise(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    exerciseName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplyToAllButtons(ThemeData theme) {
    if (!widget.isSuperset) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Weight to All button
        Expanded(
          child: _isWeightAppliedToAll
              ? FilledButton.icon(
                  onPressed: _applyWeightToAll,
                  icon: const SemanticIcon(
                    icon: AppIcons.workout,
                    semanticLabel: 'Workout',
                    size: AppIconSize.tiny,
                  ),
                  label: Text(context.l10n.weightToAll),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: _applyWeightToAll,
                  icon: const SemanticIcon(
                    icon: AppIcons.workout,
                    semanticLabel: 'Workout',
                    size: AppIconSize.tiny,
                  ),
                  label: Text(context.l10n.weightToAll),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        // Reps to All button
        Expanded(
          child: _isRepsAppliedToAll
              ? FilledButton.icon(
                  onPressed: _applyRepsToAll,
                  icon: const SemanticIcon(
                    icon: AppIcons.repeat,
                    semanticLabel: 'Repeat',
                    size: AppIconSize.tiny,
                  ),
                  label: Text(context.l10n.repsToAll),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: _applyRepsToAll,
                  icon: const SemanticIcon(
                    icon: AppIcons.repeat,
                    semanticLabel: 'Repeat',
                    size: AppIconSize.tiny,
                  ),
                  label: Text(context.l10n.repsToAll),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                    ),
                    foregroundColor: theme.colorScheme.secondary,
                  ),
                ),
        ),
      ],
    );
  }

  void _switchToExercise(int index) {
    if (index == _currentExerciseIndex) return;

    // Save current exercise values
    final currentExercise = widget.exerciseNames![_currentExerciseIndex];
    _supersetWeights[currentExercise] = _selectedWeight;
    _supersetReps[currentExercise] = _selectedReps;
    _supersetSeconds[currentExercise] = _selectedSeconds; // ✅ NUOVO

    // Switch to new exercise
    _currentExerciseIndex = index;
    final newExercise = widget.exerciseNames![index];

    setState(() {
      _selectedWeight = _supersetWeights[newExercise]!;
      _selectedReps = _supersetReps[newExercise]!;
      _selectedSeconds = _supersetSeconds[newExercise]!; // ✅ NUOVO

      // Update text controllers
      _weightTextController.text = _selectedWeight.toString();
      _repsTextController.text = _selectedReps.toString();
      _secondsTextController.text = _selectedSeconds.toString(); // ✅ NUOVO
    });

    // Animate wheel controllers to new values
    _weightController.animateToItem(
      (_selectedWeight * 2).round(),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    _repsController.animateToItem(
      _selectedReps > 0 ? _selectedReps - 1 : 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    _secondsController.animateToItem(
      _selectedSeconds,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    ); // ✅ NUOVO

    HapticFeedback.selectionClick();
  }

  void _applyWeightToAll() {
    setState(() {
      if (_isWeightAppliedToAll) {
        // Turn off - reset to individual values (no change to data)
        _isWeightAppliedToAll = false;
      } else {
        // Turn on - apply current weight to all exercises
        for (String exerciseName in widget.exerciseNames!) {
          _supersetWeights[exerciseName] = _selectedWeight;
        }
        _isWeightAppliedToAll = true;
        // Reset reps state when switching
        _isRepsAppliedToAll = false;
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _applyRepsToAll() {
    setState(() {
      if (_isRepsAppliedToAll) {
        // Turn off - reset to individual values (no change to data)
        _isRepsAppliedToAll = false;
      } else {
        // Turn on - apply current reps to all exercises
        for (String exerciseName in widget.exerciseNames!) {
          _supersetReps[exerciseName] = _selectedReps;
        }
        _isRepsAppliedToAll = true;
        // Reset weight state when switching
        _isWeightAppliedToAll = false;
      }
    });
    HapticFeedback.mediumImpact();
  }

  /// Creates the updated ExerciseSet with current values
  ExerciseSet _createUpdatedSet() {
    return widget.exerciseSet!.copyWith(
      weight: widget.countingMode.requiresWeight && _selectedWeight > 0
          ? _selectedWeight
          : null,
      reps: widget.countingMode.requiresReps && _selectedReps > 0
          ? _selectedReps
          : null,
      seconds: widget.countingMode.requiresTime && _selectedSeconds > 0
          ? _selectedSeconds
          : null,
    );
  }

  void _save() {
    HapticFeedback.lightImpact();

    // Update current exercise values before saving
    if (widget.isSuperset) {
      final currentExercise = widget.exerciseNames![_currentExerciseIndex];
      _supersetWeights[currentExercise] = _selectedWeight;
      _supersetReps[currentExercise] = _selectedReps;
      _supersetSeconds[currentExercise] = _selectedSeconds; // ✅ NUOVO
    }

    // Animate out first, then call the callback (which will handle navigation)
    _animationController.reverse().then((_) {
      if (mounted) {
        if (widget.isSuperset) {
          // Create updated sets map for superset
          final updatedSets = <String, ExerciseSet>{};

          for (String exerciseName in widget.exerciseNames!) {
            final originalSet = widget.exerciseSets![exerciseName]!;
            updatedSets[exerciseName] = originalSet.copyWith(
              weight: _supersetWeights[exerciseName],
              reps: _supersetReps[exerciseName],
              seconds: _supersetSeconds[exerciseName], // ✅ NUOVO
            );
          }

          widget.onSupersetSave!(updatedSets);
        } else {
          // ✅ NUOVO: Single exercise save based on counting mode
          final updatedSet = _createUpdatedSet();

          // ✅ NEW: Handle "Apply to remaining" if toggled
          if (_applyToRemaining && widget.onApplyToRemaining != null) {
            final remainingCount =
                widget.totalSets! - widget.currentSetIndex! - 1;
            widget.onApplyToRemaining!(updatedSet, remainingCount);
          } else {
            widget.onSave!(updatedSet);
          }
        }
      }
    });
  }

  /// ✅ NEW: Save current set and immediately open edit for next set (swipe left)
  void _saveAndNext() {
    HapticFeedback.lightImpact();

    if (widget.onSaveAndNext == null) return;

    // Create the updated set
    final updatedSet = _createUpdatedSet();

    // Animate out first, then call the callback
    _animationController.reverse().then((_) {
      if (mounted) {
        // Handle "Apply to remaining" if toggled AND save+next
        if (_applyToRemaining && widget.onApplyToRemaining != null) {
          final remainingCount =
              widget.totalSets! - widget.currentSetIndex! - 1;
          widget.onApplyToRemaining!(updatedSet, remainingCount);
        } else {
          widget.onSaveAndNext!(updatedSet);
        }
      }
    });
  }

  /// ✅ NEW: Save current set and go back to previous set (swipe right)
  void _saveAndPrevious() {
    HapticFeedback.lightImpact();

    if (widget.onSaveAndPrevious == null) return;

    // Create the updated set
    final updatedSet = _createUpdatedSet();

    // Animate out first, then call the callback
    _animationController.reverse().then((_) {
      if (mounted) {
        widget.onSaveAndPrevious!(updatedSet);
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SWIPE GESTURE HANDLERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if swipe navigation is available
  bool get _hasSwipeNavigation {
    final hasNext =
        widget.onSaveAndNext != null &&
        widget.currentSetIndex != null &&
        widget.totalSets != null &&
        widget.currentSetIndex! < widget.totalSets! - 1;
    final hasPrevious =
        widget.onSaveAndPrevious != null &&
        widget.currentSetIndex != null &&
        widget.currentSetIndex! > 0;
    return hasNext || hasPrevious;
  }

  /// Check if can swipe to next set
  bool get _canSwipeNext {
    return widget.onSaveAndNext != null &&
        widget.currentSetIndex != null &&
        widget.totalSets != null &&
        widget.currentSetIndex! < widget.totalSets! - 1;
  }

  /// Check if can swipe to previous set
  bool get _canSwipePrevious {
    return widget.onSaveAndPrevious != null &&
        widget.currentSetIndex != null &&
        widget.currentSetIndex! > 0;
  }

  /// Handle horizontal swipe gestures
  void _handleHorizontalSwipe(DragEndDetails details) {
    const swipeThreshold = 300.0; // Velocity threshold for swipe detection
    final velocity = details.primaryVelocity ?? 0;

    if (velocity.abs() < swipeThreshold) return;

    if (velocity < 0 && _canSwipeNext) {
      // Swipe left → go to next set
      _saveAndNext();
    } else if (velocity > 0 && _canSwipePrevious) {
      // Swipe right → go to previous set
      _saveAndPrevious();
    }
  }

  /// Handle vertical swipe gestures (swipe down to save and close)
  void _handleVerticalSwipe(DragEndDetails details) {
    const swipeThreshold = 300.0;
    final velocity = details.primaryVelocity ?? 0;

    if (velocity > swipeThreshold) {
      // Swipe down → save and close
      _save();
    }
  }

  /// Build swipe hint indicator
  Widget _buildSwipeHint(ThemeData theme) {
    final currentSet = (widget.currentSetIndex ?? 0) + 1;
    final totalSets = widget.totalSets ?? 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left arrow (previous)
          if (_canSwipePrevious) ...[
            Icon(
              AppIcons.arrowBack,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
          ],
          // Set indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Set $currentSet / $totalSets',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Right arrow (next)
          if (_canSwipeNext) ...[
            const SizedBox(width: 8),
            Icon(
              AppIcons.forwardIos,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ],
      ),
    );
  }

  void _cancel() {
    HapticFeedback.lightImpact();

    // Animate out first, then call the callback (which will handle navigation)
    _animationController.reverse().then((_) {
      if (mounted) {
        widget.onCancel();
      }
    });
  }

  void _showPlateCalculator(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      AppIcons.calculateRounded,
                      color: theme.colorScheme.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Plate Calculator',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const SemanticIcon(
                        icon: AppIcons.close,
                        semanticLabel: 'Close',
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: PlateCalculatorWidget(
                      targetWeight: _selectedWeight,
                      onWeightChanged: (weight) {
                        Navigator.pop(context);
                        _setWeight(weight);
                      },
                      unit: ref.read(appConfigProvider).measurementUnit,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    HapticFeedback.lightImpact();
  }

  // NOTE: _calculateSmartPosition removed - now always using bottom sheet mode
}

// Helper class for smart positioning
class _SmartPositioning {
  const _SmartPositioning({
    required this.left,
    required this.top,
    required this.showAsBottomSheet,
  });
  final double left;
  final double top;
  final bool showAsBottomSheet;
}

// Extension for easy usage
extension QuickEditOverlayV2Extension on BuildContext {
  Future<void> showQuickEditOverlayV2({
    required ExerciseSet exerciseSet,
    required Function(ExerciseSet) onSave,
    required Offset position, // Kept for API compatibility
    ExerciseSet? previousSet,
    String? exerciseName,
    int? setNumber, // For querying last workout data
    ExerciseCountingMode countingMode = ExerciseCountingMode.weighted,
    // Quick edit workflow parameters
    int? currentSetIndex,
    int? totalSets,
    Function(ExerciseSet)? onSaveAndNext,
    Function(ExerciseSet)? onSaveAndPrevious,
    Function(ExerciseSet, int remainingCount)? onApplyToRemaining,
  }) {
    // ✅ CHANGED: Use showModalBottomSheet instead of showDialog
    return showModalBottomSheet<void>(
      context: this,
      isScrollControlled: true,
      backgroundColor: colors.surface.withValues(alpha: 0),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: QuickEditOverlayV2(
          exerciseSet: exerciseSet,
          onSave: (updatedSet) {
            Navigator.of(context).pop();
            onSave(updatedSet);
          },
          onCancel: () => Navigator.of(context).pop(),
          position: position,
          previousSet: previousSet,
          exerciseName: exerciseName,
          setNumber: setNumber,
          countingMode: countingMode,
          currentSetIndex: currentSetIndex,
          totalSets: totalSets,
          onSaveAndNext: onSaveAndNext != null
              ? (updatedSet) {
                  Navigator.of(context).pop();
                  onSaveAndNext(updatedSet);
                }
              : null,
          onSaveAndPrevious: onSaveAndPrevious != null
              ? (updatedSet) {
                  Navigator.of(context).pop();
                  onSaveAndPrevious(updatedSet);
                }
              : null,
          onApplyToRemaining: onApplyToRemaining != null
              ? (updatedSet, remainingCount) {
                  Navigator.of(context).pop();
                  onApplyToRemaining(updatedSet, remainingCount);
                }
              : null,
        ),
      ),
    );
  }

  Future<void> showQuickEditOverlayV2ForSuperset({
    required List<String> exerciseNames,
    required Map<String, ExerciseSet> exerciseSets,
    required Function(Map<String, ExerciseSet>) onSave,
    required Offset position,
  }) {
    // ✅ CHANGED: Use showModalBottomSheet for superset too
    return showModalBottomSheet<void>(
      context: this,
      isScrollControlled: true,
      backgroundColor: colors.surface.withValues(alpha: 0),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: QuickEditOverlayV2(
          isSuperset: true,
          exerciseNames: exerciseNames,
          exerciseSets: exerciseSets,
          onSupersetSave: (updatedSets) {
            Navigator.of(context).pop();
            onSave(updatedSets);
          },
          onCancel: () => Navigator.of(context).pop(),
          position: position,
        ),
      ),
    );
  }
}
