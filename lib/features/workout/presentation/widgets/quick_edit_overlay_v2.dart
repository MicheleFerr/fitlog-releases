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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart'; // ✅ NUOVO
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/plate_calculator_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class QuickEditOverlayV2 extends ConsumerStatefulWidget {

  const QuickEditOverlayV2({
    super.key,
    this.exerciseSet,
    this.onSave,
    required this.onCancel,
    required this.position,
    this.previousSet,
    this.exerciseName,
    this.exerciseNames,
    this.exerciseSets,
    this.onSupersetSave,
    this.isSuperset = false,
    this.countingMode = ExerciseCountingMode.weighted, // ✅ NUOVO
  }) : assert(
         (!isSuperset && exerciseSet != null && onSave != null) ||
         (isSuperset && exerciseNames != null && exerciseSets != null && onSupersetSave != null),
         'For superset mode, exerciseNames, exerciseSets and onSupersetSave are required'
       );
  final ExerciseSet? exerciseSet; // Nullable per superset
  final Function(ExerciseSet)? onSave; // Nullable per superset
  final VoidCallback onCancel;
  final Offset position;
  final ExerciseSet? previousSet;
  final String? exerciseName;
  final ExerciseCountingMode countingMode; // ✅ NUOVO: Determines which fields to show/edit

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
      _selectedSeconds = widget.exerciseSet!.seconds ?? 60; // ✅ NUOVO: Default 60 seconds
    }
    
    // Controllers
    _weightController = FixedExtentScrollController(
      initialItem: (_selectedWeight * 2).round(),
    );
    _repsController = FixedExtentScrollController(
      initialItem: _selectedReps > 0 ? _selectedReps - 1 : 0,
    );
    _secondsController = FixedExtentScrollController(
      initialItem: _selectedSeconds.clamp(0, 600), // ✅ NUOVO: 0-600 seconds range
    );

    _weightTextController = TextEditingController(text: _selectedWeight.toString());
    _repsTextController = TextEditingController(text: _selectedReps.toString());
    _secondsTextController = TextEditingController(text: _selectedSeconds.toString()); // ✅ NUOVO
    
    // OPTIMIZED: Simpler, faster animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 20,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
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
    // Get initial screen measurements
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final statusBarHeight = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    const overlayWidth = 340.0;
    const overlayHeight = 600.0;
    const padding = 16.0;

    return _calculateSmartPosition(
      tapPosition: widget.position,
      screenSize: screenSize,
      overlaySize: const Size(overlayWidth, overlayHeight),
      keyboardHeight: 0, // Don't consider keyboard on initial positioning
      statusBarHeight: statusBarHeight,
      bottomPadding: bottomPadding,
      padding: padding,
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
      appConfigProvider.select((config) => config.measurementUnit)
    );

    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size; // Get screen size here
    const overlayWidth = 340.0;

    // Use pre-calculated position
    final double left = _positioning.left;
    final double top = _positioning.top;
    final bool showAsBottomSheet = _positioning.showAsBottomSheet;

    if (showAsBottomSheet) {
      // Show as bottom sheet when no space available
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 10),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Align(
                alignment: Alignment.bottomCenter,
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
                        color: theme.colorScheme.shadow.withValues(alpha: 0.2),
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
                        SizedBox(height: 12),
                        _buildContent(theme, measurementUnit),
                      ],
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
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
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
                    SizedBox(height: 12),
                    _buildContent(theme, measurementUnit),
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
                widget.isSuperset ? Icons.fitness_center : AppIcons.editNoteRounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isSuperset 
                    ? 'Quick Edit Superset'  // TODO: Add localization key
                    : (widget.exerciseName ?? 'Quick Edit Set ${widget.exerciseSet?.setNumber ?? ""}'),
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
                  icon: Icon(AppIcons.contentCopyRounded, size: 16),
                  label: Text(AppLocalizations.of(context).copy, style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          if (widget.isSuperset) ...[
            SizedBox(height: 12),
            _buildExerciseTabs(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, String measurementUnit) {
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
                  (widget.countingMode.requiresReps || widget.countingMode.requiresTime))
                SizedBox(width: 16),

              // Conditional reps picker (for weighted + reps modes)
              if (widget.countingMode.requiresReps)
                Expanded(child: _buildRepsPicker(theme)),

              // Conditional seconds picker (for time mode)
              if (widget.countingMode.requiresTime)
                Expanded(child: _buildSecondsPicker(theme)),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Recent Weights (if available)
          if (widget.exerciseName != null || (widget.isSuperset && widget.exerciseNames != null)) ...[
            _buildRecentWeights(theme),
            SizedBox(height: 16),
          ],
          
          // Apply to All buttons for superset
          if (widget.isSuperset) ...[
            _buildApplyToAllButtons(theme),
            SizedBox(height: 16),
          ],
          
          // NEW: Primary Control Toolbar
          _buildPrimaryToolbar(theme, measurementUnit),
          
          SizedBox(height: 12),
          
          // Adjustment Buttons
          _buildAdjustmentButtons(theme),
          
          SizedBox(height: 20),
          
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
            Icon(Icons.fitness_center, size: 14, color: theme.colorScheme.primary),
            SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).weightKg.replaceAll('kg', measurementUnit),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
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
        SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            fontSize: _selectedWeight >= 100 ? 20 : 24, // Dynamic font size
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
                            final weight = double.tryParse(value.replaceAll(',', '.'));
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
                      SizedBox(width: 4),
                      IconButton(
                        onPressed: _confirmManualWeight,
                        icon: Icon(
                          Icons.check_circle,
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
                          weight % 1 == 0 ? weight.toInt().toString() : weight.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
            Icon(Icons.repeat, size: 14, color: theme.colorScheme.secondary),
            SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).reps,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
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
        SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                      SizedBox(width: 4),
                      IconButton(
                        onPressed: _confirmManualReps,
                        icon: Icon(
                          Icons.check_circle,
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
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
            Icon(Icons.timer, size: 14, color: theme.colorScheme.tertiary),
            SizedBox(width: 4),
            Text(
              'Duration',  // TODO: Add localization
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
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
        SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                        width: 110, // ✅ MODIFICATO: Increased from 80 to 110 for 3-digit seconds (e.g., "100s")
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
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            suffix: Text('s', style: TextStyle(fontSize: 12)),
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
                      SizedBox(width: 4),
                      IconButton(
                        onPressed: _confirmManualSeconds,
                        icon: Icon(
                          Icons.check_circle,
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
                    childCount: 601, // 0-600 seconds (10 minutes)
                    builder: (context, index) {
                      final seconds = index;
                      final isSelected = seconds == _selectedSeconds;
                      return Center(
                        child: Text(
                          seconds < 60
                              ? '${seconds}s'
                              : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
          recentWeightsWithDetailsProvider(exerciseName)
        );
        
        return recentWeightsAsync.when(
          data: (weights) {
            if (weights.isEmpty) return const SizedBox.shrink();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context).recentWeights,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: weights.take(8).map((data) {
                    final weight = data.weight ?? 0;
                    final isSelected = (_selectedWeight - weight).abs() < 0.1;
                    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
                    final isFromLast3Days = data.date.isAfter(threeDaysAgo);
                    
                    return ActionChip(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _setWeight(weight);
                      },
                      label: Text(
                        '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)}kg',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected 
                            ? theme.colorScheme.onPrimary
                            : isFromLast3Days 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      backgroundColor: isSelected 
                        ? theme.colorScheme.primary
                        : isFromLast3Days 
                          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.8)
                          : theme.colorScheme.surfaceContainerHighest,
                      side: BorderSide(
                        color: isSelected
                          ? theme.colorScheme.primary
                          : isFromLast3Days
                            ? theme.colorScheme.primary.withValues(alpha: 0.5)
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      elevation: isSelected ? 2 : 0,
                      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    );
                  }).toList(),
                ),
              ],
            );
          },
          loading: () => Container(
            height: 60,
            alignment: Alignment.center,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  // NEW: Redesigned Primary Toolbar
  Widget _buildPrimaryToolbar(ThemeData theme, String measurementUnit) {
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
          _buildModeToggle(theme),

          SizedBox(width: 12),

          // Dynamic content area
          Expanded(
            child: _usePercentage
              ? _buildPercentageSlider(theme)
              : const SizedBox.shrink(),
          ),

          SizedBox(width: 12),

          // ✅ MODIFICATO: Plate Calculator - Only visible for weighted mode
          if (widget.countingMode.requiresWeight)
            _buildPlateCalculatorButton(theme, measurementUnit),
        ],
      ),
    );
  }

  Widget _buildModeToggle(ThemeData theme) {
    // ✅ MODIFICATO: Different labels based on counting mode
    final String absoluteLabel = widget.countingMode.requiresTime
        ? AppLocalizations.of(context).duration // "Secondi" or "Duration"
        : 'KG';

    return Container(
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

  Widget _buildModeButton(String label, bool isSelected, ThemeData theme, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
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
              inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.2),
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
      color: Colors.transparent,
      child: InkWell(
        onTap: hasWeight ? () => _showPlateCalculator(context) : null,
        borderRadius: BorderRadius.circular(8),
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
            color: !hasWeight ? theme.colorScheme.surfaceContainerHighest : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calculate_rounded,
                size: 16,
                color: hasWeight 
                  ? theme.colorScheme.onSecondary 
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              SizedBox(width: 6),
              Text(
                'Plates',  // Using simple English until localization key is added
                style: theme.textTheme.labelMedium?.copyWith(
                  color: hasWeight 
                    ? theme.colorScheme.onSecondary 
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
          SizedBox(width: 12),
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
          _buildAdjustButton('-20s', () => _adjustSeconds(-20), theme.colorScheme.error, theme),
          SizedBox(width: 8),
          _buildAdjustButton('-5s', () => _adjustSeconds(-5), theme.colorScheme.error.withValues(alpha: 0.7), theme),
          SizedBox(width: 8),
          _buildAdjustButton('+5s', () => _adjustSeconds(5), theme.colorScheme.primary, theme),
          SizedBox(width: 8),
          _buildAdjustButton('+20s', () => _adjustSeconds(20), theme.colorScheme.tertiary, theme),
        ],
      );
    }

    // Weight mode: -2.5, +2.5, +5, +10
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAdjustButton('-2.5', () => _adjustWeight(-2.5), theme.colorScheme.error, theme),
        SizedBox(width: 8),
        _buildAdjustButton('+2.5', () => _adjustWeight(2.5), theme.colorScheme.primary, theme),
        SizedBox(width: 8),
        _buildAdjustButton('+5', () => _adjustWeight(5), theme.colorScheme.primary, theme),
        SizedBox(width: 8),
        _buildAdjustButton('+10', () => _adjustWeight(10), theme.colorScheme.tertiary, theme),
      ],
    );
  }

  Widget _buildAdjustButton(String label, VoidCallback onTap, Color color, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
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
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _cancel,
            icon: Icon(AppIcons.closeRounded, size: 18),
            label: Text(AppLocalizations.of(context).cancel),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        // Save button
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _save,
            icon: Icon(AppIcons.checkRounded, size: 18),
            label: Text(AppLocalizations.of(context).save),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: theme.colorScheme.primary,
            ),
          ),
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
    final weight = double.tryParse(_weightTextController.text.replaceAll(',', '.'));
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
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _switchToExercise(index),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                icon: Icon(Icons.fitness_center, size: 16),
                label: Text('Weight to All'),  // TODO: Add localization
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              )
            : OutlinedButton.icon(
                onPressed: _applyWeightToAll,
                icon: Icon(Icons.fitness_center, size: 16),
                label: Text('Weight to All'),  // TODO: Add localization
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
        ),
        SizedBox(width: 12),
        // Reps to All button
        Expanded(
          child: _isRepsAppliedToAll
            ? FilledButton.icon(
                onPressed: _applyRepsToAll,
                icon: Icon(Icons.repeat, size: 16),
                label: Text('Reps to All'),  // TODO: Add localization
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              )
            : OutlinedButton.icon(
                onPressed: _applyRepsToAll,
                icon: Icon(Icons.repeat, size: 16),
                label: Text('Reps to All'),  // TODO: Add localization
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
          final updatedSet = widget.exerciseSet!.copyWith(
            weight: widget.countingMode.requiresWeight && _selectedWeight > 0 ? _selectedWeight : null,
            reps: widget.countingMode.requiresReps && _selectedReps > 0 ? _selectedReps : null,
            seconds: widget.countingMode.requiresTime && _selectedSeconds > 0 ? _selectedSeconds : null,
          );
          widget.onSave!(updatedSet);
        }
      }
    });
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
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calculate_rounded,
                      color: theme.colorScheme.secondary,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Plate Calculator',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),
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
  
  // Smart positioning calculation
  _SmartPositioning _calculateSmartPosition({
    required Offset tapPosition,
    required Size screenSize,
    required Size overlaySize,
    required double keyboardHeight,
    required double statusBarHeight,
    required double bottomPadding,
    required double padding,
  }) {
    final availableHeight = screenSize.height - keyboardHeight - statusBarHeight - bottomPadding;
    final availableWidth = screenSize.width;
    
    // Calculate preferred position (centered on tap)
    final double preferredLeft = tapPosition.dx - (overlaySize.width / 2);
    double preferredTop = tapPosition.dy - (overlaySize.height / 2);
    
    // Check available space above and below tap point
    final spaceAbove = tapPosition.dy - statusBarHeight - padding;
    final spaceBelow = availableHeight - tapPosition.dy + statusBarHeight - padding;
    
    // Minimum space required for overlay
    const minSpaceRequired = 400.0;
    
    // If neither above nor below has enough space, show as bottom sheet
    if (spaceAbove < minSpaceRequired && spaceBelow < minSpaceRequired) {
      return const _SmartPositioning(
        left: 0,
        top: 0,
        showAsBottomSheet: true,
      );
    }
    
    // Determine optimal vertical position
    if (spaceBelow >= minSpaceRequired) {
      // Show below tap point
      preferredTop = tapPosition.dy + 20;
    } else if (spaceAbove >= minSpaceRequired) {
      // Show above tap point
      preferredTop = tapPosition.dy - overlaySize.height - 20;
    }
    
    // Constrain horizontal position
    final constrainedLeft = preferredLeft.clamp(
      padding,
      availableWidth - overlaySize.width - padding,
    );
    
    // Constrain vertical position
    final constrainedTop = preferredTop.clamp(
      statusBarHeight + padding,
      availableHeight - overlaySize.height + statusBarHeight - padding,
    );
    
    return _SmartPositioning(
      left: constrainedLeft,
      top: constrainedTop,
      showAsBottomSheet: false,
    );
  }
  
  // Removed: All gesture handlers and hint methods to fix overlay issues
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
    required Offset position,
    ExerciseSet? previousSet,
    String? exerciseName,
    ExerciseCountingMode countingMode = ExerciseCountingMode.weighted, // ✅ NUOVO
  }) {
    return showDialog(
      context: this,
      barrierColor: this.colors.onSurface.withValues(alpha: 0.54),
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          QuickEditOverlayV2(
            exerciseSet: exerciseSet,
            onSave: (updatedSet) {
              // First close the dialog
              Navigator.of(context).pop();
              // Then call the save callback
              onSave(updatedSet);
            },
            onCancel: () {
              // Just close the dialog, no need to call anything else
              Navigator.of(context).pop();
            },
            position: position,
            previousSet: previousSet,
            exerciseName: exerciseName,
            countingMode: countingMode, // ✅ NUOVO
          ),
        ],
      ),
    );
  }

  Future<void> showQuickEditOverlayV2ForSuperset({
    required List<String> exerciseNames,
    required Map<String, ExerciseSet> exerciseSets,
    required Function(Map<String, ExerciseSet>) onSave,
    required Offset position,
  }) {
    return showDialog(
      context: this,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          QuickEditOverlayV2(
            isSuperset: true,
            exerciseNames: exerciseNames,
            exerciseSets: exerciseSets,
            onSupersetSave: (updatedSets) {
              // First close the dialog
              Navigator.of(context).pop();
              // Then call the save callback
              onSave(updatedSets);
            },
            onCancel: () {
              // Just close the dialog
              Navigator.of(context).pop();
            },
            position: position,
          ),
        ],
      ),
    );
  }
}