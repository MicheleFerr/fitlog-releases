/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Firebase: None
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/rpe_autoregulation_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

class SupersetExerciseCompleteData {

  const SupersetExerciseCompleteData({
    required this.actualReps,
    required this.actualWeight,
    required this.rpe,
  });
  final int actualReps;
  final double actualWeight;
  final int rpe;
}

class RpeSelectorBottomSheet extends ConsumerStatefulWidget {

  const RpeSelectorBottomSheet({
    super.key,
    required this.set,
    required this.targetReps,
    required this.onConfirm,
    this.exercise,
    this.onAPRESuggestion,
    this.onRPESuggestion,
    this.isPartOfSuperset = false,
    this.supersetName,
    this.supersetExercises,
    this.supersetSet,
    this.currentExerciseIndex = 0,
    this.onSupersetCompleteAll,
  });
  final ExerciseSet set;
  final int targetReps;
  final Function(int actualReps, double actualWeight, int rpe) onConfirm;

  // APRE parameters
  final Exercise? exercise; // Full exercise for APRE checking
  final Function(double suggestedWeight)? onAPRESuggestion;

  // RPE Autoregulation parameters
  final Function(double suggestedWeight)? onRPESuggestion;

  // Optional superset context parameters
  final bool isPartOfSuperset;
  final String? supersetName;
  final List<Exercise>? supersetExercises;
  final SupersetSet? supersetSet;
  final int currentExerciseIndex;
  final Function(Map<int, SupersetExerciseCompleteData>)? onSupersetCompleteAll;

  static Future<void> show({
    required BuildContext context,
    required ExerciseSet set,
    required int targetReps,
    required Function(int actualReps, double actualWeight, int rpe) onConfirm,
    Exercise? exercise,
    Function(double suggestedWeight)? onAPRESuggestion,
    Function(double suggestedWeight)? onRPESuggestion,
    bool isPartOfSuperset = false,
    String? supersetName,
    List<Exercise>? supersetExercises,
    SupersetSet? supersetSet,
    int currentExerciseIndex = 0,
    Function(Map<int, SupersetExerciseCompleteData>)? onSupersetCompleteAll,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Remove fixed constraints to allow dynamic sizing
      builder: (context) => RpeSelectorBottomSheet(
        set: set,
        targetReps: targetReps,
        onConfirm: onConfirm,
        exercise: exercise,
        onAPRESuggestion: onAPRESuggestion,
        onRPESuggestion: onRPESuggestion,
        isPartOfSuperset: isPartOfSuperset,
        supersetName: supersetName,
        supersetExercises: supersetExercises,
        supersetSet: supersetSet,
        currentExerciseIndex: currentExerciseIndex,
        onSupersetCompleteAll: onSupersetCompleteAll,
      ),
    );
  }

  @override
  ConsumerState<RpeSelectorBottomSheet> createState() => _RpeSelectorBottomSheetState();
}

class _RpeSelectorBottomSheetState extends ConsumerState<RpeSelectorBottomSheet> {
  late int _actualReps;
  double _actualWeight = 0.0;
  int? _selectedRpe;
  int? _calculatedRir;
  bool _showWeightAndReps = true;
  bool _isSetCompleted = false; // ✅ Toggle state for set completion
  bool _originallyCompleted = false; // ✅ Track original completion state for button logic

  // ✅ NEW: For time-based exercises (counting mode = time)
  int _actualMinutes = 0;
  int _actualSeconds = 0;

  // Superset navigation state
  PageController? _pageController;
  int _currentExerciseIndex = 0;
  late ExerciseSet _currentExerciseSet;

  // Superset batch completion data
  final Map<int, SupersetExerciseCompleteData> _supersetCompleteData = {};

  @override
  void initState() {
    super.initState();
    
    // Initialize superset navigation if needed
    if (widget.isPartOfSuperset) {
      _currentExerciseIndex = widget.currentExerciseIndex;
      _pageController = PageController(initialPage: _currentExerciseIndex);
      _currentExerciseSet = _getExerciseSetForIndex(_currentExerciseIndex);
    } else {
      _currentExerciseSet = widget.set;
    }
    
    _loadExerciseData(_currentExerciseSet);
  }
  
  void _loadExerciseData(ExerciseSet exerciseSet) {
    // Check if we have completion data for this exercise in our batch
    final storedData = _supersetCompleteData[_currentExerciseIndex];
    if (storedData != null) {
      // Load from our stored completion data
      _actualReps = storedData.actualReps;
      _actualWeight = storedData.actualWeight;
      _selectedRpe = storedData.rpe;
      // ✅ For superset batch data, assume completion if data exists
      _isSetCompleted = true; // Data exists = was completed
      _originallyCompleted = true;
    } else {
      // Load from exercise set
      _actualReps = exerciseSet.actualReps ?? widget.targetReps;
      _actualWeight = exerciseSet.weight ?? 0.0;
      _selectedRpe = exerciseSet.rpe;
      _isSetCompleted = exerciseSet.isCompleted; // ✅ Initialize from set state
      _originallyCompleted = exerciseSet.isCompleted; // ✅ Track original state (set once)

      // ✅ NEW: Initialize time variables for time-based exercises
      final totalSeconds = exerciseSet.seconds ?? 60; // Default 60 seconds if not set
      _actualMinutes = totalSeconds ~/ 60; // Integer division for minutes
      _actualSeconds = totalSeconds % 60;  // Remainder for seconds
    }
    _updateRir();
  }
  
  ExerciseSet _getExerciseSetForIndex(int index) {
    if (!widget.isPartOfSuperset || 
        widget.supersetExercises == null || 
        widget.supersetSet == null ||
        index >= widget.supersetExercises!.length) {
      return widget.set;
    }
    
    final exercise = widget.supersetExercises![index];
    final exerciseData = widget.supersetSet!.exerciseData[exercise.id];
    
    if (exerciseData == null) return widget.set;
    
    // Create ExerciseSet from SupersetExerciseData
    return ExerciseSet(
      setNumber: 1,
      weight: exerciseData.targetWeight,
      reps: exerciseData.targetReps,
      actualReps: exerciseData.actualReps,
      rpe: exerciseData.rpe,
      isCompleted: exerciseData.isCompleted,
      notes: exerciseData.notes,
    );
  }
  
  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }
  
  void _onPageChanged(int index) {
    if (!widget.isPartOfSuperset) return;
    
    setState(() {
      _currentExerciseIndex = index;
      _currentExerciseSet = _getExerciseSetForIndex(index);
      _loadExerciseData(_currentExerciseSet);
    });
    
    HapticFeedback.lightImpact();
  }

  void _updateRir() {
    if (_selectedRpe != null) {
      // Simple RIR calculation: RIR ≈ 10 - RPE
      _calculatedRir = 10 - _selectedRpe!;
    } else {
      _calculatedRir = null;
    }
  }
  
  /// ✅ NEW: Calculate data to pass to onConfirm based on counting mode
  (int, double) _getConfirmData() {
    final countingMode = widget.exercise?.countingMode ?? ExerciseCountingMode.weighted;

    switch (countingMode) {
      case ExerciseCountingMode.time:
        // For time-based: pass total seconds via actualReps (workaround), weight = 0
        final totalSeconds = (_actualMinutes * 60) + _actualSeconds;
        return (totalSeconds, 0.0);

      case ExerciseCountingMode.reps:
        // For reps-only: pass reps, weight = 0
        return (_actualReps, 0.0);

      case ExerciseCountingMode.weighted:
        // For weighted: pass both reps and weight
        return (_actualReps, _actualWeight);
    }
  }

  void _saveCurrentExerciseData(int rpe) {
    if (widget.isPartOfSuperset) {
      _supersetCompleteData[_currentExerciseIndex] = SupersetExerciseCompleteData(
        actualReps: _actualReps,
        actualWeight: _actualWeight,
        rpe: rpe,
      );
    }
  }
  
  bool _allExercisesCompleted() {
    if (!widget.isPartOfSuperset || widget.supersetExercises == null) {
      return true;
    }
    return _supersetCompleteData.length == widget.supersetExercises!.length;
  }

  // RPE Helper Methods
  Color _getRpeColor(int rpe, ColorScheme colorScheme) {
    switch (rpe) {
      case 6:
        return Colors.green;
      case 7:
        return Colors.lightGreen;
      case 8:
        return Colors.yellow;
      case 9:
        return Colors.orange;
      case 10:
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }

  String _getRpeEmoji(int rpe) {
    switch (rpe) {
      case 6:
        return '😌';
      case 7:
        return '😊';
      case 8:
        return '😤';
      case 9:
        return '😰';
      case 10:
        return '🔥';
      default:
        return '💪';
    }
  }

  String _getRpeShortLabel(int rpe) {
    switch (rpe) {
      case 6:
        return 'Easy';
      case 7:
        return 'Moderate';
      case 8:
        return 'Hard';
      case 9:
        return 'Very Hard';
      case 10:
        return 'Max';
      default:
        return '';
    }
  }

  /// ✅ FIX: Get verify text based on exercise counting mode
  String _getVerifyText(AppLocalizations l10n) {
    final countingMode = widget.exercise?.countingMode ?? ExerciseCountingMode.weighted;
    switch (countingMode) {
      case ExerciseCountingMode.time:
        return l10n.verifyTime; // "Verify Minutes & Seconds"
      case ExerciseCountingMode.reps:
        return l10n.verifyReps; // "Verify Reps"
      case ExerciseCountingMode.weighted:
        return l10n.verifyWeightReps; // "Verify Weight & Reps"
    }
  }

  /// ✅ FIX: Build input fields dynamically based on counting mode
  Widget _buildInputFieldsBasedOnCountingMode(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final countingMode = widget.exercise?.countingMode ?? ExerciseCountingMode.weighted;

    switch (countingMode) {
      case ExerciseCountingMode.time:
        // Show Minutes & Seconds pickers
        return _buildTimeInputSection(context, theme, colorScheme);
      case ExerciseCountingMode.reps:
        // Show only Reps picker
        return _buildRepsOnlySection(context, theme, colorScheme);
      case ExerciseCountingMode.weighted:
        // Show Weight & Reps (existing behavior)
        return _buildWeightAndRepsSection(context, theme, colorScheme);
    }
  }

  List<Color> _getRpeGradient(int rpe) {
    final baseColor = _getRpeColor(rpe, Theme.of(context).colorScheme);
    return [
      baseColor,
      baseColor.withValues(alpha: 0.7),
    ];
  }

  Widget _buildRpeScale(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final rpe = index + 6; // RPE from 6 to 10
        final isSelected = _selectedRpe == rpe;
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRpe = (_selectedRpe == rpe) ? null : rpe;
                  _updateRir();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 75,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: _getRpeGradient(rpe),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: !isSelected
                      ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                      : null,
                  border: Border.all(
                    color: isSelected
                        ? _getRpeColor(rpe, colorScheme)
                        : colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _getRpeColor(rpe, colorScheme)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getRpeEmoji(rpe),
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$rpe',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _getRpeShortLabel(rpe),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.95)
                            : colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSupersetHeader(BuildContext context, ThemeData theme, AppLocalizations l10n, ColorScheme colorScheme) {
    if (!widget.isPartOfSuperset || widget.supersetExercises == null) {
      return const SizedBox.shrink();
    }
    
    final currentExercise = widget.supersetExercises![_currentExerciseIndex];
    final totalExercises = widget.supersetExercises!.length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.3),
            colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Progress indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalExercises, (index) {
              final isActive = index == _currentExerciseIndex;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive 
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.3),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          
          // Exercise name and progress text
          Text(
            currentExercise.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.supersetProgress(_currentExerciseIndex + 1, totalExercises),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          
          // Swipe hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.swipe,
                size: 16,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.swipeToNavigate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ThemeData theme, AppLocalizations l10n, ColorScheme colorScheme) {
    // Check for APRE suggestion
    final showAPRESuggestion = _shouldShowAPRESuggestion();
    final apreSuggestion = showAPRESuggestion ? _calculateAPRESuggestion() : null;

    // Check for RPE suggestion
    final showRPESuggestion = _shouldShowRPESuggestion();
    final rpeSuggestion = showRPESuggestion ? _calculateRPESuggestion() : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // APRE Suggestion Card (if applicable)
        if (showAPRESuggestion && apreSuggestion != null)
          _buildAPRESuggestionCard(context, theme, l10n, colorScheme, apreSuggestion),

        // RPE Suggestion Card (if applicable)
        if (showRPESuggestion && rpeSuggestion != null && rpeSuggestion.adjustmentPercent != 0)
          _buildRPESuggestionCard(context, theme, l10n, colorScheme, rpeSuggestion),

        // Toggle for Weight & Reps (dynamic text based on counting mode)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // ✅ FIX: Dynamic text based on counting mode
                _getVerifyText(l10n),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: _showWeightAndReps,
                  onChanged: (value) {
                    setState(() {
                      _showWeightAndReps = value;
                    });
                  },
                  thumbColor: WidgetStateProperty.all(colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
        
        // Weight & Reps Section - Premium design (dynamic based on counting mode)
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _showWeightAndReps ? _buildInputFieldsBasedOnCountingMode(context, theme, colorScheme) : const SizedBox.shrink(),
        ),

        const SizedBox(height: 16),

        // ✅ NEW: Set Completion Toggle
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isSetCompleted
                ? colorScheme.tertiaryContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isSetCompleted
                  ? colorScheme.tertiary.withValues(alpha: 0.4)
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _isSetCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 20,
                    color: _isSetCompleted ? colorScheme.tertiary : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.setCompleted,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _isSetCompleted ? colorScheme.tertiary : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: _isSetCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isSetCompleted = value;
                    });
                    HapticFeedback.lightImpact();
                  },
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return colorScheme.tertiary;
                    }
                    return colorScheme.outline;
                  }),
                  trackColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return colorScheme.tertiaryContainer;
                    }
                    return colorScheme.surfaceContainerHighest;
                  }),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // RPE Section
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.rpe,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.rpe),
                          content: Text(l10n.rpeDescription),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Icon(
                      AppIcons.info,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                l10n.howHardWasTheSet,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),
              
              // RPE buttons - Responsive row
              _buildRpeScale(theme, colorScheme),
              
              // RIR display
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _calculatedRir != null
                    ? Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primaryContainer.withValues(alpha: 0.5),
                              colorScheme.primaryContainer.withValues(alpha: 0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                AppIcons.trendUp,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l10n.rir}: $_calculatedRir',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  l10n.repsInReserve,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Action buttons - Premium design with SafeArea
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              // ✅ Context-aware left button (Skip RPE / Cancel)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (_originallyCompleted) {
                      // Set was already completed → "Cancel" button (safe exit)
                      Navigator.of(context).pop();
                      // Don't call onConfirm - just close without changes
                    } else {
                      // Set was NOT completed → "Skip RPE" button (complete with rpe=0)
                      if (widget.isPartOfSuperset) {
                        _saveCurrentExerciseData(0);
                        if (_allExercisesCompleted() && widget.onSupersetCompleteAll != null) {
                          Navigator.of(context).pop();
                          widget.onSupersetCompleteAll!(_supersetCompleteData);
                        }
                      } else {
                        Navigator.of(context).pop();
                        // ✅ NEW: Get correct data based on counting mode
                        final (actualReps, actualWeight) = _getConfirmData();
                        widget.onConfirm(actualReps, actualWeight, 0);
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _originallyCompleted ? l10n.cancel : l10n.skipRpe,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Confirm button - Premium gradient
              Expanded(
                flex: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _selectedRpe != null
                        ? LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _selectedRpe != null
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: FilledButton(
                    // ✅ Enable button if RPE selected OR user unchecked completion toggle (unmarca)
                    onPressed: (_selectedRpe != null || !_isSetCompleted)
                        ? () {
                            HapticFeedback.mediumImpact();
                            if (widget.isPartOfSuperset) {
                              _saveCurrentExerciseData(_selectedRpe ?? 0);
                              if (_allExercisesCompleted() && widget.onSupersetCompleteAll != null) {
                                // Tutti gli esercizi completati → chiudi e callback
                                Navigator.of(context).pop();
                                widget.onSupersetCompleteAll!(_supersetCompleteData);
                              } else {
                                // ✅ FIX: Avanza automaticamente al prossimo esercizio
                                if (_currentExerciseIndex < (widget.supersetExercises?.length ?? 0) - 1) {
                                  _pageController?.animateToPage(
                                    _currentExerciseIndex + 1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              }
                            } else {
                              Navigator.of(context).pop();
                              // ✅ Pass rpe = -1 if user toggled OFF (unmarca set)
                              // rpe = 0 if user skipped RPE but kept toggle ON
                              // rpe > 0 if user selected RPE
                              final rpeToSend = !_isSetCompleted ? -1 : (_selectedRpe ?? 0);
                              // ✅ NEW: Get correct data based on counting mode
                              final (actualReps, actualWeight) = _getConfirmData();
                              widget.onConfirm(actualReps, actualWeight, rpeToSend);
                            }
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_selectedRpe != null) ...[
                          const Icon(AppIcons.complete, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.isPartOfSuperset 
                              ? (_allExercisesCompleted() 
                                  ? l10n.completeSet 
                                  : '${l10n.save} (${_supersetCompleteData.length}/${widget.supersetExercises?.length ?? 0})')
                              : l10n.confirmSet,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
  
  // APRE Helper Methods
  bool _shouldShowAPRESuggestion() {
    if (widget.exercise == null || !widget.exercise!.useAPRE) return false;
    if (widget.exercise!.apreProtocol == null) return false;
    if (_currentExerciseSet.setNumber != 3) return false; // APRE only applies to set 3
    return true;
  }

  // RPE Autoregulation Helper Methods
  bool _shouldShowRPESuggestion() {
    if (widget.exercise == null) return false;
    if (widget.exercise!.autoAdjustmentType != AutoAdjustmentType.rpe) return false;
    if (_selectedRpe == null) return false;

    // Check if we have valid RPE targets
    if (widget.exercise!.targetRPEMin == null || widget.exercise!.targetRPEMax == null) {
      // Check for RIR mode
      if (widget.exercise!.targetRIR == null) return false;
    }

    return true;
  }

  WeightAdjustment? _calculateRPESuggestion() {
    if (widget.exercise == null || _selectedRpe == null || _actualWeight == 0) {
      return null;
    }

    // Check if using RPE range mode
    if (widget.exercise!.targetRPEMin != null && widget.exercise!.targetRPEMax != null) {
      return RPEAutoregulationService.calculateRPEAdjustment(
        currentWeight: _actualWeight,
        actualRPE: _selectedRpe!.toDouble(),
        targetRPEMin: widget.exercise!.targetRPEMin!,
        targetRPEMax: widget.exercise!.targetRPEMax!,
      );
    }

    // Check if using RIR mode
    if (widget.exercise!.targetRIR != null) {
      final actualRIR = RPEAutoregulationService.rpeToRIR(_selectedRpe!.toDouble());
      return RPEAutoregulationService.calculateRIRAdjustment(
        currentWeight: _actualWeight,
        actualRIR: actualRIR,
        targetRIR: widget.exercise!.targetRIR!,
      );
    }

    return null;
  }

  APREAdjustment? _calculateAPRESuggestion() {
    if (widget.exercise == null || widget.exercise!.apreProtocol == null) {
      return null;
    }
    return APREService.getAdjustment(widget.exercise!.apreProtocol!, _actualReps);
  }

  Widget _buildRPESuggestionCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    WeightAdjustment suggestion,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            suggestion.shouldIncrease
                ? Colors.green.withValues(alpha: 0.2)
                : suggestion.shouldDecrease
                    ? Colors.orange.withValues(alpha: 0.2)
                    : colorScheme.primaryContainer.withValues(alpha: 0.5),
            colorScheme.primaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: suggestion.shouldIncrease
              ? Colors.green.withValues(alpha: 0.3)
              : suggestion.shouldDecrease
                  ? Colors.orange.withValues(alpha: 0.3)
                  : colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.trendUp,
                size: 20,
                color: suggestion.shouldIncrease
                    ? Colors.green
                    : suggestion.shouldDecrease
                        ? Colors.orange
                        : colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.rpeAutoregulation,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            suggestion.actualRPE != null
                ? '${l10n.actualRpe}: ${suggestion.actualRPE!.toStringAsFixed(0)}'
                : '${l10n.actualRir}: ${suggestion.actualRIR}',
            style: theme.textTheme.bodyMedium,
          ),
          if (suggestion.targetRPERange != null)
            Text(
              '${l10n.targetRange}: ${suggestion.targetRPERange}',
              style: theme.textTheme.bodyMedium,
            )
          else if (suggestion.targetRIR != null)
            Text(
              '${l10n.targetRir}: ${suggestion.targetRIR}',
              style: theme.textTheme.bodyMedium,
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.suggestedWeight,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${suggestion.adjustedWeight.toStringAsFixed(1)} kg',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      suggestion.adjustmentPercent > 0
                          ? '+${suggestion.adjustmentPercent.toStringAsFixed(1)}%'
                          : '${suggestion.adjustmentPercent.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: suggestion.shouldIncrease
                            ? Colors.green
                            : suggestion.shouldDecrease
                                ? Colors.orange
                                : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (widget.onRPESuggestion != null) {
                      widget.onRPESuggestion!(suggestion.adjustedWeight);
                    }
                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${l10n.nextSetWeight}: ${suggestion.adjustedWeight.toStringAsFixed(1)} kg'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(l10n.apply),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.reason,
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAPRESuggestionCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    APREAdjustment suggestion,
  ) {
    final suggestedWeight = APREService.calculateNextWeight(
      _actualWeight,
      _actualReps,
      widget.exercise!.apreProtocol!,
      isForSet4: true,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.5),
            colorScheme.primaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.autoAwesome,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'APRE ${widget.exercise!.apreProtocol} Protocol',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You completed $_actualReps reps (target: ${widget.exercise!.apreProtocol})',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set 4 Weight:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${suggestedWeight.toStringAsFixed(1)} kg',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      suggestion.set4AdjustmentKg > 0
                          ? '+${suggestion.set4AdjustmentKg.toStringAsFixed(1)} kg'
                          : '${suggestion.set4AdjustmentKg.toStringAsFixed(1)} kg',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: suggestion.set4AdjustmentKg > 0
                            ? Colors.green
                            : suggestion.set4AdjustmentKg < 0
                                ? Colors.orange
                                : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (widget.onAPRESuggestion != null) {
                      widget.onAPRESuggestion!(suggestedWeight);
                    }
                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Set 4 weight: ${suggestedWeight.toStringAsFixed(1)} kg'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.description,
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightAndRepsSection(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Weight Section
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppIcons.workout, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      l10n.weight,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decrease weight
                    InkWell(
                      onTap: _actualWeight > 0
                          ? () {
                              HapticFeedback.lightImpact();
                              setState(() => _actualWeight = (_actualWeight - 2.5).clamp(0, 999));
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(AppIcons.remove, size: 18, color: colorScheme.error),
                      ),
                    ),
                    // Weight display
                    Container(
                      width: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _actualWeight == _currentExerciseSet.weight
                              ? colorScheme.primary.withValues(alpha: 0.5)
                              : colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _actualWeight.toStringAsFixed(1),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'kg',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Increase weight
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _actualWeight += 2.5);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(AppIcons.add, size: 18, color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            width: 1,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          
          // Reps Section
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppIcons.repeat, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      l10n.reps,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decrease reps
                    InkWell(
                      onTap: _actualReps > 0
                          ? () {
                              HapticFeedback.lightImpact();
                              setState(() => _actualReps--);
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(AppIcons.remove, size: 18, color: colorScheme.error),
                      ),
                    ),
                    // Reps display
                    Container(
                      width: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _actualReps == widget.targetReps
                              ? colorScheme.primary.withValues(alpha: 0.5)
                              : colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$_actualReps',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            l10n.reps,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Increase reps
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _actualReps++);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(AppIcons.add, size: 18, color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ FIX: Build reps-only section (for reps counting mode)
  Widget _buildRepsOnlySection(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.repeat, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.reps,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrease reps
              InkWell(
                onTap: _actualReps > 1
                    ? () {
                        HapticFeedback.lightImpact();
                        setState(() => _actualReps--);
                      }
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.remove, size: 24, color: colorScheme.error),
                ),
              ),
              // Reps display
              Container(
                width: 100,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _actualReps == widget.targetReps
                        ? colorScheme.primary.withValues(alpha: 0.5)
                        : colorScheme.outline.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Text(
                  '$_actualReps',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // Increase reps
              InkWell(
                onTap: _actualReps < 50
                    ? () {
                        HapticFeedback.lightImpact();
                        setState(() => _actualReps++);
                      }
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add, size: 24, color: colorScheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ FIX: Build time input section (for time counting mode)
  Widget _buildTimeInputSection(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Minutes Section
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Minuti', // TODO: Add localization
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decrease minutes
                    InkWell(
                      onTap: _actualMinutes > 0
                          ? () {
                              HapticFeedback.lightImpact();
                              setState(() => _actualMinutes--);
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.remove, size: 18, color: colorScheme.error),
                      ),
                    ),
                    // Minutes display
                    Container(
                      width: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$_actualMinutes',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'min',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Increase minutes
                    InkWell(
                      onTap: _actualMinutes < 6
                          ? () {
                              HapticFeedback.lightImpact();
                              setState(() => _actualMinutes++);
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add, size: 18, color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),

          // Seconds Section
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Secondi', // TODO: Add localization
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decrease seconds
                    InkWell(
                      onTap: _actualSeconds > 0
                          ? () {
                              HapticFeedback.lightImpact();
                              setState(() => _actualSeconds = (_actualSeconds - 5).clamp(0, 60));
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.remove, size: 18, color: colorScheme.error),
                      ),
                    ),
                    // Seconds display
                    Container(
                      width: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _actualSeconds.toString().padLeft(2, '0'),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'sec',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Increase seconds
                    InkWell(
                      onTap: _actualSeconds < 60
                          ? () {
                              HapticFeedback.lightImpact();
                              setState(() => _actualSeconds = (_actualSeconds + 5).clamp(0, 60));
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add, size: 18, color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    // Main content of the bottom sheet
    final mainContent = DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            _buildSupersetHeader(context, theme, l10n, colorScheme),
            _buildMainContent(context, theme, l10n, colorScheme),
          ],
        ),
      ),
      ),
    );

    // If part of a superset, use a PageView
    if (widget.isPartOfSuperset) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.supersetExercises?.length ?? 0,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            return mainContent;
          },
        ),
      );
    }

    // Otherwise, return the main content directly
    return mainContent;
  }
}
