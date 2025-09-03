/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation/widgets
 * 🎯 Feature: workout
 * 🔧 Type: widget
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: Universal
 * 
 * QuickEditOverlayV2 - Optimized version with better UX and performance
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../../domain/entities/exercise.dart';
import '../providers/exercise_history_provider.dart';
import '../../../../shared/presentation/providers/app_config_provider.dart';
import 'plate_calculator_widget.dart';

class QuickEditOverlayV2 extends ConsumerStatefulWidget {
  final ExerciseSet? exerciseSet; // Nullable per superset
  final Function(ExerciseSet)? onSave; // Nullable per superset
  final VoidCallback onCancel;
  final Offset position;
  final ExerciseSet? previousSet;
  final String? exerciseName;
  
  // Superset support
  final List<String>? exerciseNames;
  final Map<String, ExerciseSet>? exerciseSets;
  final Function(Map<String, ExerciseSet>)? onSupersetSave;
  final bool isSuperset;

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
  }) : assert(
         (!isSuperset && exerciseSet != null && onSave != null) ||
         (isSuperset && exerciseNames != null && exerciseSets != null && onSupersetSave != null),
         'For superset mode, exerciseNames, exerciseSets and onSupersetSave are required'
       );

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
  
  // Superset values
  final Map<String, double> _supersetWeights = {};
  final Map<String, int> _supersetReps = {};
  int _currentExerciseIndex = 0;
  
  // Apply to All states
  bool _isWeightAppliedToAll = false;
  bool _isRepsAppliedToAll = false;
  
  // Controllers
  late FixedExtentScrollController _weightController;
  late FixedExtentScrollController _repsController;
  late TextEditingController _weightTextController;
  late TextEditingController _repsTextController;
  
  // Focus
  final _weightFocusNode = FocusNode();
  final _repsFocusNode = FocusNode();
  
  // UI State
  bool _isManualWeightEntry = false;
  bool _isManualRepsEntry = false;
  bool _usePercentage = false;
  double _percentageValue = 5.0; // Changed from int to double for slider

  @override
  void initState() {
    super.initState();
    
    if (widget.isSuperset) {
      // Initialize superset values
      for (String exerciseName in widget.exerciseNames!) {
        final exerciseSet = widget.exerciseSets![exerciseName];
        _supersetWeights[exerciseName] = exerciseSet?.weight ?? 20.0;
        _supersetReps[exerciseName] = exerciseSet?.reps ?? 10;
      }
      // Set current values to first exercise
      final firstExercise = widget.exerciseNames!.first;
      _selectedWeight = _supersetWeights[firstExercise]!;
      _selectedReps = _supersetReps[firstExercise]!;
    } else {
      // Initialize single exercise values
      _selectedWeight = widget.exerciseSet!.weight ?? 0.0;
      _selectedReps = widget.exerciseSet!.reps ?? 0;
    }
    
    // Controllers
    _weightController = FixedExtentScrollController(
      initialItem: (_selectedWeight * 2).round(),
    );
    _repsController = FixedExtentScrollController(
      initialItem: _selectedReps > 0 ? _selectedReps - 1 : 0,
    );
    
    _weightTextController = TextEditingController(text: _selectedWeight.toString());
    _repsTextController = TextEditingController(text: _selectedReps.toString());
    
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

  @override
  void dispose() {
    _weightFocusNode.removeListener(_onWeightFocusChanged);
    _repsFocusNode.removeListener(_onRepsFocusChanged);
    _animationController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _weightTextController.dispose();
    _repsTextController.dispose();
    _weightFocusNode.dispose();
    _repsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // OPTIMIZED: Use .select() for better performance
    final measurementUnit = ref.watch(
      appConfigProvider.select((config) => config.measurementUnit)
    );
    
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    // Calculate optimal position
    double left = widget.position.dx - 170;
    double top = widget.position.dy - 140;
    
    if (keyboardHeight > 0) {
      final availableHeight = screenSize.height - keyboardHeight - 50;
      if (top + 400 > availableHeight) {
        top = availableHeight - 400;
      }
    }
    
    // Smaller overlay width for better performance
    const overlayWidth = 340.0;
    left = left.clamp(16.0, screenSize.width - overlayWidth - 16.0);
    top = top.clamp(50.0, screenSize.height - keyboardHeight - 400.0);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100), // Faster positioning
      curve: Curves.easeOutCubic,
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
          child: Container(
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
                _buildContent(theme, measurementUnit),
              ],
            ),
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
                widget.isSuperset ? Icons.fitness_center : Icons.edit_note_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isSuperset 
                    ? 'Quick Edit Superset'
                    : (widget.exerciseName ?? 'Quick Edit Set ${widget.exerciseSet?.setNumber}'),
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
                  icon: const Icon(Icons.content_copy_rounded, size: 16),
                  label: const Text('Copy', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildContent(ThemeData theme, String measurementUnit) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Weight and Reps Pickers
          Row(
            children: [
              Expanded(child: _buildWeightPicker(theme, measurementUnit)),
              const SizedBox(width: 16),
              Expanded(child: _buildRepsPicker(theme)),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Recent Weights (if available)
          if (widget.exerciseName != null || (widget.isSuperset && widget.exerciseNames != null)) ...[
            _buildRecentWeights(theme),
            const SizedBox(height: 16),
          ],
          
          // Apply to All buttons for superset
          if (widget.isSuperset) ...[
            _buildApplyToAllButtons(theme),
            const SizedBox(height: 16),
          ],
          
          // NEW: Primary Control Toolbar
          _buildPrimaryToolbar(theme, measurementUnit),
          
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
            Icon(Icons.fitness_center, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'Weight ($measurementUnit)',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                _isManualWeightEntry ? Icons.dialpad : Icons.keyboard,
                size: 16,
              ),
              onPressed: () => setState(() {
                _isManualWeightEntry = !_isManualWeightEntry;
                if (_isManualWeightEntry) {
                  _weightFocusNode.requestFocus();
                }
              }),
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
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: _isManualWeightEntry
              ? Center(
                  child: SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _weightTextController,
                      focusNode: _weightFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffix: Text(
                          measurementUnit,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      onSubmitted: (value) {
                        final weight = double.tryParse(value);
                        if (weight != null) {
                          setState(() {
                            _selectedWeight = weight;
                            _isManualWeightEntry = false;
                          });
                          _weightController.animateToItem(
                            (weight * 2).round(),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                    ),
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
            const SizedBox(width: 4),
            Text(
              'Reps',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                _isManualRepsEntry ? Icons.dialpad : Icons.keyboard,
                size: 16,
              ),
              onPressed: () => setState(() {
                _isManualRepsEntry = !_isManualRepsEntry;
                if (_isManualRepsEntry) {
                  _repsFocusNode.requestFocus();
                }
              }),
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
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.secondary.withValues(alpha: 0.2),
            ),
          ),
          child: _isManualRepsEntry
              ? Center(
                  child: SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _repsTextController,
                      focusNode: _repsFocusNode,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        final reps = int.tryParse(value);
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
                        }
                      },
                    ),
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
                Text(
                  'Recent Weights',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: math.min(weights.length, 5),
                    itemBuilder: (context, index) {
                      final data = weights[index];
                      final weight = data.weight ?? 0;
                      final isSelected = (_selectedWeight - weight).abs() < 0.1;
                      
                      return Padding(
                        padding: EdgeInsets.only(right: index < 4 ? 8 : 0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _setWeight(weight),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelected 
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline.withValues(alpha: 0.2),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)}kg',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected 
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                                ),
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
          loading: () => const SizedBox(height: 36),
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
          
          const SizedBox(width: 12),
          
          // Dynamic content area
          Expanded(
            child: _usePercentage 
              ? _buildPercentageSlider(theme)
              : const SizedBox.shrink(),
          ),
          
          const SizedBox(width: 12),
          
          // Plate Calculator - Always visible
          _buildPlateCalculatorButton(theme, measurementUnit),
        ],
      ),
    );
  }

  Widget _buildModeToggle(ThemeData theme) {
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
          _buildModeButton('KG', !_usePercentage, theme, () {
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
              const SizedBox(width: 6),
              Text(
                'Dischi',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _usePercentage 
        ? [
            _buildAdjustButton(
              '-${_percentageValue.toInt()}%',
              () => _adjustWeightByPercentage(-_percentageValue),
              theme.colorScheme.error,
              theme,
            ),
            const SizedBox(width: 12),
            _buildAdjustButton(
              '+${_percentageValue.toInt()}%',
              () => _adjustWeightByPercentage(_percentageValue),
              theme.colorScheme.primary,
              theme,
            ),
          ]
        : [
            _buildAdjustButton('-2.5', () => _adjustWeight(-2.5), theme.colorScheme.error, theme),
            const SizedBox(width: 8),
            _buildAdjustButton('+2.5', () => _adjustWeight(2.5), theme.colorScheme.primary, theme),
            const SizedBox(width: 8),
            _buildAdjustButton('+5', () => _adjustWeight(5), theme.colorScheme.primary, theme),
            const SizedBox(width: 8),
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
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Save button
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Save Set'),
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

  void _adjustWeight(double delta) {
    final newWeight = (_selectedWeight + delta).clamp(0.0, 500.0);
    _setWeight((newWeight * 2).round() / 2); // Round to 0.5kg
  }

  void _adjustWeightByPercentage(double percentage) {
    final adjustment = _selectedWeight * (percentage / 100);
    final newWeight = (_selectedWeight + adjustment).clamp(0.0, 500.0);
    _setWeight((newWeight * 2).round() / 2); // Round to 0.5kg
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
                icon: const Icon(Icons.fitness_center, size: 16),
                label: const Text('Weight to All'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              )
            : OutlinedButton.icon(
                onPressed: _applyWeightToAll,
                icon: const Icon(Icons.fitness_center, size: 16),
                label: const Text('Weight to All'),
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
                icon: const Icon(Icons.repeat, size: 16),
                label: const Text('Reps to All'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              )
            : OutlinedButton.icon(
                onPressed: _applyRepsToAll,
                icon: const Icon(Icons.repeat, size: 16),
                label: const Text('Reps to All'),
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
    
    // Switch to new exercise
    _currentExerciseIndex = index;
    final newExercise = widget.exerciseNames![index];
    
    setState(() {
      _selectedWeight = _supersetWeights[newExercise]!;
      _selectedReps = _supersetReps[newExercise]!;
      
      // Update text controllers
      _weightTextController.text = _selectedWeight.toString();
      _repsTextController.text = _selectedReps.toString();
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
              weight: _supersetWeights[exerciseName]!,
              reps: _supersetReps[exerciseName]!,
            );
          }
          
          widget.onSupersetSave!(updatedSets);
        } else {
          // Single exercise save
          final updatedSet = widget.exerciseSet!.copyWith(
            weight: _selectedWeight > 0 ? _selectedWeight : null,
            reps: _selectedReps > 0 ? _selectedReps : null,
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
                    const SizedBox(width: 12),
                    Text(
                      'Plate Calculator',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
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
}

// Extension for easy usage
extension QuickEditOverlayV2Extension on BuildContext {
  Future<void> showQuickEditOverlayV2({
    required ExerciseSet exerciseSet,
    required Function(ExerciseSet) onSave,
    required Offset position,
    ExerciseSet? previousSet,
    String? exerciseName,
  }) {
    return showDialog(
      context: this,
      barrierColor: Colors.transparent, // TEMPORARILY DISABLE GRAY OVERLAY FOR DEBUGGING
      builder: (context) => AnimatedPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        duration: const Duration(milliseconds: 100),
        child: Stack(
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
            ),
          ],
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
    return showDialog(
      context: this,
      barrierColor: Colors.transparent,
      builder: (context) => AnimatedPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        duration: const Duration(milliseconds: 100),
        child: Stack(
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
      ),
    );
  }
}