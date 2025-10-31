import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart'; // ✅ NUOVO
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/rest_time_suggestion_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

// Extension for easy modal showing
extension UnifiedSetInputModalExtension on BuildContext {
  Future<void> showUnifiedSetInputModal(
    ExerciseSet? exerciseSet,
    Function(ExerciseSet)? onSave, {
    ExerciseSet? previousSet,
    String? exerciseName,
    bool isInWorkout = true,
    Exercise? exercise,
    ExerciseCountingMode countingMode = ExerciseCountingMode.weighted, // ✅ NUOVO
  }) async {
    // Validate inputs
    if (exerciseSet == null) {
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: const Text('Error: Unable to edit this set'),
          backgroundColor: this.colors.error,
        ),
      );
      return;
    }
    
    if (onSave == null) {
      return;
    }

    return UnifiedSetInputModal.show(
      context: this,
      exerciseSet: exerciseSet,
      onSave: onSave,
      previousSet: previousSet,
      exerciseName: exerciseName ?? 'Exercise',
      isInWorkout: isInWorkout,
      exercise: exercise,
      countingMode: countingMode, // ✅ NUOVO
    );
  }
}

/// Unified modal for weight, reps, and RPE input with improved UX
/// Based on QuickEditSetOverlay design patterns
class UnifiedSetInputModal extends ConsumerStatefulWidget {
  
  const UnifiedSetInputModal({
    super.key,
    required this.exerciseSet,
    required this.onSave,
    this.onCancel,
    this.previousSet,
    required this.exerciseName,
    this.isInWorkout = true,
    this.exercise,
    this.isSuperset = false,
    this.supersetExerciseNames,
    this.supersetExerciseSets,
    this.onSupersetSave,
    this.initialExerciseIndex = 0,
    this.countingMode = ExerciseCountingMode.weighted, // ✅ NUOVO
  });
  final ExerciseSet exerciseSet;
  final Function(ExerciseSet) onSave;
  final VoidCallback? onCancel;
  final ExerciseSet? previousSet;
  final String exerciseName;
  final bool isInWorkout; // True if editing during workout, false if editing history
  final Exercise? exercise; // Full exercise entity for APRE suggestions
  final ExerciseCountingMode countingMode; // ✅ NUOVO: Determines which fields to show/edit

  // Superset support
  final bool isSuperset;
  final List<String>? supersetExerciseNames;
  final Map<String, ExerciseSet>? supersetExerciseSets;
  final Function(Map<String, ExerciseSet>)? onSupersetSave;
  final int initialExerciseIndex;

  static Future<void> show({
    required BuildContext context,
    required ExerciseSet exerciseSet,
    required Function(ExerciseSet) onSave,
    ExerciseSet? previousSet,
    required String exerciseName,
    bool isInWorkout = true,
    Exercise? exercise,
    ExerciseCountingMode countingMode = ExerciseCountingMode.weighted, // ✅ NUOVO
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: context.colors.onSurface54,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context) => UnifiedSetInputModal(
        exerciseSet: exerciseSet,
        onSave: onSave,
        previousSet: previousSet,
        exerciseName: exerciseName,
        isInWorkout: isInWorkout,
        exercise: exercise,
        countingMode: countingMode, // ✅ NUOVO
      ),
    );
  }
  
  static Future<void> showForSuperset({
    required BuildContext context,
    required List<String> exerciseNames,
    required Map<String, ExerciseSet> exerciseSets,
    required Function(Map<String, ExerciseSet>) onSave,
    int initialExerciseIndex = 0,
    bool isInWorkout = true,
  }) {
    // Ensure initial index is valid
    final safeIndex = initialExerciseIndex.clamp(0, exerciseNames.length - 1);
    final initialExerciseName = exerciseNames[safeIndex];
    
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: context.colors.onSurface54,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context) => UnifiedSetInputModal(
        exerciseSet: exerciseSets[initialExerciseName]!,
        onSave: (set) {}, // Not used for superset
        exerciseName: initialExerciseName,
        isInWorkout: isInWorkout,
        isSuperset: true,
        supersetExerciseNames: exerciseNames,
        supersetExerciseSets: exerciseSets,
        onSupersetSave: onSave,
        initialExerciseIndex: safeIndex,
      ),
    );
  }

  @override
  ConsumerState<UnifiedSetInputModal> createState() => _UnifiedSetInputModalState();
}

class _UnifiedSetInputModalState extends ConsumerState<UnifiedSetInputModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  late FixedExtentScrollController _weightController;
  late FixedExtentScrollController _repsController;
  late FixedExtentScrollController _secondsController; // ✅ NUOVO: For time-based exercises

  // Tab controller for superset
  late TabController? _tabController;

  // Single exercise state
  double _selectedWeight = 0.0;
  int _selectedReps = 0;
  int _selectedSeconds = 0; // ✅ NUOVO: For time-based exercises (in seconds)
  int? _selectedRpe;
  int? _calculatedRir;
  bool _isCompleted = false;

  // Rest time suggestion state
  RestTimeSuggestion? _restTimeSuggestion;
  bool _showSuggestionBanner = false;
  
  // Superset state - maps exercise name to its values
  final Map<String, double> _supersetWeights = {};
  final Map<String, int> _supersetReps = {};
  final Map<String, int> _supersetSeconds = {}; // ✅ NUOVO: For time-based exercises in supersets
  final Map<String, int?> _supersetRpes = {};
  final Map<String, bool> _supersetCompleted = {};
  int _currentTabIndex = 0;
  
  // Quick adjustment values
  static const List<double> _weightIncrements = [-5, -2.5, -1, 1, 2.5, 5];
  static const List<int> _repsIncrements = [-3, -2, -1, 1, 2, 3];
  static const List<int> _secondsIncrements = [-30, -15, -5, 5, 15, 30]; // ✅ NUOVO: For time adjustments
  
  @override
  void initState() {
    super.initState();
    
    // Initialize Tab Controller for superset with initial index
    if (widget.isSuperset && widget.supersetExerciseNames != null) {
      _tabController = TabController(
        length: widget.supersetExerciseNames!.length,
        initialIndex: widget.initialExerciseIndex,
        vsync: this,
      );
      _tabController!.addListener(_onTabChanged);
      _currentTabIndex = widget.initialExerciseIndex;
      
      // Initialize superset states
      for (final exerciseName in widget.supersetExerciseNames!) {
        final exerciseSet = widget.supersetExerciseSets![exerciseName];
        _supersetWeights[exerciseName] = exerciseSet?.weight ?? 20.0;
        _supersetReps[exerciseName] = exerciseSet?.reps ?? 10;
        _supersetSeconds[exerciseName] = exerciseSet?.seconds ?? 60; // ✅ NUOVO
        _supersetRpes[exerciseName] = exerciseSet?.rpe;
        _supersetCompleted[exerciseName] = exerciseSet?.isCompleted ?? false;
      }

      // Set current values to first exercise
      final firstExercise = widget.supersetExerciseNames!.first;
      _selectedWeight = _supersetWeights[firstExercise]!;
      _selectedReps = _supersetReps[firstExercise]!;
      _selectedSeconds = _supersetSeconds[firstExercise]!; // ✅ NUOVO
      _selectedRpe = _supersetRpes[firstExercise];
      _isCompleted = _supersetCompleted[firstExercise]!;
    } else {
      // Initialize single exercise values
      _selectedWeight = widget.exerciseSet.weight ?? widget.previousSet?.weight ?? 20.0;
      _selectedReps = widget.exerciseSet.reps ?? widget.previousSet?.reps ?? 10;
      _selectedSeconds = widget.exerciseSet.seconds ?? widget.previousSet?.seconds ?? 60; // ✅ NUOVO: Default 60 seconds
      _selectedRpe = widget.exerciseSet.rpe;
      _isCompleted = widget.exerciseSet.isCompleted;
    }

    _updateRir();

    // Initialize scroll controllers based on counting mode
    final weightIndex = (_selectedWeight * 2).round().clamp(0, 400);
    final repsIndex = (_selectedReps - 1).clamp(0, 49);
    final secondsIndex = _selectedSeconds.clamp(0, 600); // ✅ NUOVO: Up to 600 seconds (10 minutes)

    _weightController = FixedExtentScrollController(initialItem: weightIndex);
    _repsController = FixedExtentScrollController(initialItem: repsIndex);
    _secondsController = FixedExtentScrollController(initialItem: secondsIndex); // ✅ NUOVO
    
    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    // Start pulse for attention
    if (widget.isInWorkout && !widget.exerciseSet.isCompleted) {
      _pulseController.repeat(reverse: true);
    }
  }
  
  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _secondsController.dispose(); // ✅ NUOVO
    _animationController.dispose();
    _pulseController.dispose();
    _tabController?.dispose();
    super.dispose();
  }
  
  void _onTabChanged() {
    if (!widget.isSuperset || widget.supersetExerciseNames == null) return;

    // Save current exercise values
    final currentExercise = widget.supersetExerciseNames![_currentTabIndex];
    _supersetWeights[currentExercise] = _selectedWeight;
    _supersetReps[currentExercise] = _selectedReps;
    _supersetSeconds[currentExercise] = _selectedSeconds; // ✅ NUOVO
    _supersetRpes[currentExercise] = _selectedRpe;
    _supersetCompleted[currentExercise] = _isCompleted;

    // Switch to new exercise
    _currentTabIndex = _tabController!.index;
    final newExercise = widget.supersetExerciseNames![_currentTabIndex];

    setState(() {
      _selectedWeight = _supersetWeights[newExercise]!;
      _selectedReps = _supersetReps[newExercise]!;
      _selectedSeconds = _supersetSeconds[newExercise]!; // ✅ NUOVO
      _selectedRpe = _supersetRpes[newExercise];
      _isCompleted = _supersetCompleted[newExercise]!;

      // Update controllers
      final weightIndex = (_selectedWeight * 2).round().clamp(0, 400);
      final repsIndex = (_selectedReps - 1).clamp(0, 49);
      final secondsIndex = _selectedSeconds.clamp(0, 600); // ✅ NUOVO
      _weightController.animateToItem(
        weightIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      _repsController.animateToItem(
        repsIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      _secondsController.animateToItem(
        secondsIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      ); // ✅ NUOVO

      _updateRir();
    });
  }
  
  void _updateRir() {
    if (_selectedRpe != null) {
      setState(() {
        _calculatedRir = 10 - _selectedRpe!;
      });
    }
  }
  
  void _copyFromPreviousSet() {
    if (widget.previousSet != null) {
      setState(() {
        if (widget.previousSet!.weight != null) {
          _selectedWeight = widget.previousSet!.weight!;
          final weightIndex = (_selectedWeight * 2).round().clamp(0, 400);
          _weightController.jumpToItem(weightIndex);
        }
        if (widget.previousSet!.reps != null) {
          _selectedReps = widget.previousSet!.reps!;
          final repsIndex = (_selectedReps - 1).clamp(0, 49);
          _repsController.jumpToItem(repsIndex);
        }
        // ✅ NUOVO: Copy seconds for time-based exercises
        if (widget.previousSet!.seconds != null) {
          _selectedSeconds = widget.previousSet!.seconds!;
          final secondsIndex = _selectedSeconds.clamp(0, 600);
          _secondsController.jumpToItem(secondsIndex);
        }
      });
      HapticFeedback.mediumImpact();
    }
  }
  
  void _quickAdjustWeight(double increment) {
    setState(() {
      _selectedWeight = (_selectedWeight + increment).clamp(0, 200);
      final weightIndex = (_selectedWeight * 2).round().clamp(0, 400);
      _weightController.animateToItem(
        weightIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
    HapticFeedback.lightImpact();
  }
  
  void _quickAdjustReps(int increment) {
    setState(() {
      _selectedReps = (_selectedReps + increment).clamp(1, 50);
      final repsIndex = (_selectedReps - 1).clamp(0, 49);
      _repsController.animateToItem(
        repsIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
    HapticFeedback.lightImpact();
  }

  // ✅ NUOVO: Quick adjustment for seconds (time-based exercises)
  void _quickAdjustSeconds(int increment) {
    setState(() {
      _selectedSeconds = (_selectedSeconds + increment).clamp(1, 600);
      final secondsIndex = _selectedSeconds.clamp(0, 600);
      _secondsController.animateToItem(
        secondsIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
    HapticFeedback.lightImpact();
  }
  
  void _selectRecentWeight(double weight) {
    setState(() {
      _selectedWeight = weight;
      final weightIndex = (_selectedWeight * 2).round().clamp(0, 400);
      _weightController.animateToItem(
        weightIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
    HapticFeedback.mediumImpact();
  }
  
  void _save() {
    if (widget.isSuperset) {
      _saveSuperset();
    } else {
      _saveSingleExercise();
    }
  }
  
  void _saveSingleExercise() {
    // ✅ NUOVO: Build set data based on counting mode
    final updatedSet = widget.exerciseSet.copyWith(
      weight: widget.countingMode.requiresWeight ? _selectedWeight : null,
      reps: widget.countingMode.requiresReps ? _selectedReps : null,
      actualReps: _isCompleted && widget.countingMode.requiresReps ? _selectedReps : null,
      seconds: widget.countingMode.requiresTime ? _selectedSeconds : null, // ✅ NUOVO
      rpe: _selectedRpe,
      isCompleted: _isCompleted,
      completedAt: _isCompleted ? DateTime.now() : null,
    );

    // Check for rest time suggestion (only if set is completed and exercise data is available)
    debugPrint('[APRE-DEBUG] Rest Time Check: _isCompleted=$_isCompleted, exercise=${widget.exercise?.name}, previousSet=${widget.previousSet?.weight}');

    if (_isCompleted && widget.exercise != null && widget.previousSet != null) {
      final config = ref.read(appConfigProvider);
      final autoAdjustEnabled = config.autoAdjustRestTime ?? false;

      debugPrint('[APRE-DEBUG] AutoAdjustRestTime config: $autoAdjustEnabled');
      debugPrint('[APRE-DEBUG] Exercise autoAdjustmentType: ${widget.exercise!.autoAdjustmentType}');
      debugPrint('[APRE-DEBUG] Weight comparison: prev=${widget.previousSet!.weight}, new=$_selectedWeight');

      final suggestion = RestTimeSuggestionService.checkRestTimeSuggestion(
        exercise: widget.exercise!,
        newWeight: _selectedWeight,
        lastWeight: widget.previousSet!.weight ?? _selectedWeight,
        currentRestTime: widget.exercise!.restTime ?? 90,
        autoAdjustEnabled: autoAdjustEnabled,
      );

      debugPrint('[APRE-DEBUG] Suggestion result: ${suggestion != null ? suggestion.message : "null"}');

      if (suggestion != null) {
        // Show suggestion banner instead of closing immediately
        setState(() {
          _restTimeSuggestion = suggestion;
          _showSuggestionBanner = true;
        });
        HapticFeedback.mediumImpact();
        widget.onSave(updatedSet);
        return; // Don't close modal yet
      }
    }

    HapticFeedback.mediumImpact();
    widget.onSave(updatedSet);
    Navigator.of(context).pop();
  }
  
  void _saveSuperset() {
    if (widget.supersetExerciseNames == null || widget.onSupersetSave == null) return;

    // Save current exercise values before saving
    final currentExercise = widget.supersetExerciseNames![_currentTabIndex];
    _supersetWeights[currentExercise] = _selectedWeight;
    _supersetReps[currentExercise] = _selectedReps;
    _supersetSeconds[currentExercise] = _selectedSeconds; // ✅ NUOVO
    _supersetRpes[currentExercise] = _selectedRpe;
    _supersetCompleted[currentExercise] = _isCompleted;

    // Build exercise sets map
    final Map<String, ExerciseSet> exerciseSets = {};
    for (final exerciseName in widget.supersetExerciseNames!) {
      final originalSet = widget.supersetExerciseSets![exerciseName];
      final isCompleted = _supersetCompleted[exerciseName] ?? false;
      final reps = _supersetReps[exerciseName] ?? 0;
      final seconds = _supersetSeconds[exerciseName] ?? 0; // ✅ NUOVO

      exerciseSets[exerciseName] = originalSet?.copyWith(
        weight: _supersetWeights[exerciseName],
        reps: reps,
        actualReps: isCompleted ? reps : null,
        seconds: seconds, // ✅ NUOVO
        rpe: _supersetRpes[exerciseName],
        isCompleted: isCompleted,
        completedAt: isCompleted ? DateTime.now() : null,
      ) ?? ExerciseSet(
        setNumber: originalSet?.setNumber ?? 1,
        weight: _supersetWeights[exerciseName] ?? 0.0,
        reps: reps,
        actualReps: isCompleted ? reps : null,
        seconds: seconds, // ✅ NUOVO
        rpe: _supersetRpes[exerciseName],
        isCompleted: isCompleted,
        completedAt: isCompleted ? DateTime.now() : null,
      );
    }
    
    HapticFeedback.mediumImpact();
    widget.onSupersetSave!(exerciseSets);
    Navigator.of(context).pop();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final recentWeightsAsync = ref.watch(recentWeightsProvider(widget.exerciseName));
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.onSurface.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar
                        Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 4),
                          height: 4,
                          width: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        
                        // Header with set info
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Set indicator
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          widget.isSuperset ? Icons.repeat : Icons.fitness_center,
                                          size: 16,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          widget.isSuperset 
                                            ? 'Superset Set ${widget.exerciseSet.setNumber} - ${_currentTabIndex + 1}/${widget.supersetExerciseNames?.length ?? 1}'
                                            : 'Set ${widget.exerciseSet.setNumber}',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const Spacer(),
                                  
                                  // Quick complete toggle
                                  if (widget.isInWorkout)
                                    AnimatedBuilder(
                                      animation: _pulseAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: !_isCompleted ? _pulseAnimation.value : 1.0,
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _isCompleted = !_isCompleted;
                                                if (_isCompleted) {
                                                  _pulseController.stop();
                                                } else {
                                                  _pulseController.repeat(reverse: true);
                                                }
                                              });
                                              HapticFeedback.mediumImpact();
                                            },
                                            icon: Icon(
                                              _isCompleted 
                                                ? Icons.check_circle 
                                                : Icons.radio_button_unchecked,
                                              color: _isCompleted 
                                                ? colorScheme.tertiary 
                                                : colorScheme.outline,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                              
                              // Exercise name - always shown
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  widget.isSuperset && widget.supersetExerciseNames != null
                                    ? widget.supersetExerciseNames![_currentTabIndex]
                                    : widget.exerciseName,
                                  style: theme.textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              
                              // Tab bar for superset only
                              if (widget.isSuperset && widget.supersetExerciseNames != null && _tabController != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TabBar(
                                      controller: _tabController!,
                                      isScrollable: widget.supersetExerciseNames!.length > 3,
                                      indicatorColor: colorScheme.primary,
                                      indicatorWeight: 3,
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      labelColor: colorScheme.primary,
                                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                                      labelStyle: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.normal,
                                      ),
                                      tabs: widget.supersetExerciseNames!.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final exerciseName = entry.value;
                                        final isCompleted = _supersetCompleted[exerciseName] ?? false;
                                        
                                        return Tab(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isCompleted) ...[
                                                Icon(
                                                  Icons.check_circle,
                                                  size: 16,
                                                  color: colorScheme.tertiary,
                                                ),
                                                const SizedBox(width: 4),
                                              ],
                                              Flexible(
                                                child: Text(
                                                  exerciseName.length > 12 
                                                    ? '${exerciseName.substring(0, 12)}...'
                                                    : exerciseName,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        // Copy from previous set button
                        if (widget.previousSet != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            child: InkWell(
                              onTap: _copyFromPreviousSet,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.secondary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.content_copy,
                                      size: 16,
                                      color: colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Copy from Set ${widget.previousSet!.setNumber}: '
                                      '${widget.previousSet!.weight?.toStringAsFixed(1) ?? '-'}${config.measurementUnit} × '
                                      '${widget.previousSet!.reps ?? '-'} reps',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: colorScheme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        
                        // Recent weights chips
                        recentWeightsAsync.when(
                          data: (weights) {
                            if (weights.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.history,
                                          size: 14,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          l10n.recentWeights,
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 36,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: weights.length > 6 ? 6 : weights.length,
                                        itemBuilder: (context, index) {
                                          final weight = weights[index];
                                          final isSelected = (_selectedWeight - weight).abs() < 0.1;
                                          
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Material(
                                              color: isSelected
                                                  ? colorScheme.primaryContainer
                                                  : colorScheme.surfaceContainerHighest,
                                              borderRadius: BorderRadius.circular(18),
                                              child: InkWell(
                                                onTap: () => _selectRecentWeight(weight),
                                                borderRadius: BorderRadius.circular(18),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(18),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? colorScheme.primary
                                                          : colorScheme.outline.withValues(alpha: 0.3),
                                                      width: isSelected ? 2 : 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)}${config.measurementUnit}',
                                                    style: theme.textTheme.labelLarge?.copyWith(
                                                      fontWeight: isSelected 
                                                          ? FontWeight.bold 
                                                          : FontWeight.normal,
                                                      color: isSelected
                                                          ? colorScheme.primary
                                                          : colorScheme.onSurface,
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
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        
                        // Main input section
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              // ✅ NUOVO: Conditional weight section (only for weighted exercises)
                              if (widget.countingMode.requiresWeight)
                                Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.fitness_center,
                                          size: 18,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Weight',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Weight display
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colorScheme.primary.withValues(alpha: 0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: Text(
                                        _selectedWeight.toStringAsFixed(_selectedWeight % 1 == 0 ? 0 : 1),
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 8),
                                    Text(
                                      config.measurementUnit,
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Weight wheel picker
                                    Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListWheelScrollView.useDelegate(
                                        controller: _weightController,
                                        itemExtent: 32,
                                        perspective: 0.005,
                                        diameterRatio: 2.0,
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
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  fontWeight: isSelected 
                                                      ? FontWeight.bold 
                                                      : FontWeight.normal,
                                                  color: isSelected
                                                      ? colorScheme.primary
                                                      : colorScheme.onSurface.withValues(alpha: 0.5),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        onSelectedItemChanged: (index) {
                                          setState(() {
                                            _selectedWeight = index / 2.0;
                                          });
                                          HapticFeedback.selectionClick();
                                        },
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Quick weight adjustments
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      alignment: WrapAlignment.center,
                                      children: _weightIncrements.map((increment) {
                                        final isNegative = increment < 0;
                                        return Material(
                                          color: isNegative
                                              ? colorScheme.errorContainer.withValues(alpha: 0.3)
                                              : colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(8),
                                          child: InkWell(
                                            onTap: () => _quickAdjustWeight(increment),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              child: Text(
                                                '${increment > 0 ? '+' : ''}$increment',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isNegative
                                                      ? colorScheme.error
                                                      : colorScheme.tertiary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),

                              // ✅ NUOVO: Conditional spacing (only when both weight and reps/time are shown)
                              if (widget.countingMode.requiresWeight &&
                                  (widget.countingMode.requiresReps || widget.countingMode.requiresTime))
                                const SizedBox(width: 20),

                              // ✅ NUOVO: Conditional reps section (only for weighted/reps exercises)
                              if (widget.countingMode.requiresReps)
                                Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.repeat,
                                          size: 18,
                                          color: colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Reps',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Reps display
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colorScheme.secondary.withValues(alpha: 0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: Text(
                                        '$_selectedReps',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 8),
                                    Text(
                                      'repetitions',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Reps wheel picker
                                    Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListWheelScrollView.useDelegate(
                                        controller: _repsController,
                                        itemExtent: 32,
                                        perspective: 0.005,
                                        diameterRatio: 2.0,
                                        physics: const FixedExtentScrollPhysics(),
                                        childDelegate: ListWheelChildBuilderDelegate(
                                          childCount: 50,
                                          builder: (context, index) {
                                            final reps = index + 1;
                                            final isSelected = reps == _selectedReps;
                                            return Center(
                                              child: Text(
                                                '$reps',
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  fontWeight: isSelected 
                                                      ? FontWeight.bold 
                                                      : FontWeight.normal,
                                                  color: isSelected
                                                      ? colorScheme.secondary
                                                      : colorScheme.onSurface.withValues(alpha: 0.5),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        onSelectedItemChanged: (index) {
                                          setState(() {
                                            _selectedReps = index + 1;
                                          });
                                          HapticFeedback.selectionClick();
                                        },
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Quick reps adjustments
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      alignment: WrapAlignment.center,
                                      children: _repsIncrements.map((increment) {
                                        final isNegative = increment < 0;
                                        return Material(
                                          color: isNegative
                                              ? colorScheme.errorContainer.withValues(alpha: 0.3)
                                              : colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(8),
                                          child: InkWell(
                                            onTap: () => _quickAdjustReps(increment),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              child: Text(
                                                '${increment > 0 ? '+' : ''}$increment',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isNegative
                                                      ? colorScheme.error
                                                      : colorScheme.tertiary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),

                              // ✅ NUOVO: Time/Duration section (only for time-based exercises)
                              if (widget.countingMode.requiresTime)
                                Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          size: 18,
                                          color: colorScheme.tertiary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Duration',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.tertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Duration display
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colorScheme.tertiary.withValues(alpha: 0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: Text(
                                        _selectedSeconds < 60
                                            ? '${_selectedSeconds}s'
                                            : '${_selectedSeconds ~/ 60}m ${_selectedSeconds % 60}s',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.tertiary,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),
                                    Text(
                                      'seconds',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Seconds wheel picker
                                    Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListWheelScrollView.useDelegate(
                                        controller: _secondsController,
                                        itemExtent: 32,
                                        perspective: 0.005,
                                        diameterRatio: 2.0,
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
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: isSelected
                                                      ? colorScheme.tertiary
                                                      : colorScheme.onSurface.withValues(alpha: 0.5),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        onSelectedItemChanged: (index) {
                                          setState(() {
                                            _selectedSeconds = index;
                                          });
                                          HapticFeedback.selectionClick();
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Quick seconds adjustments
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      alignment: WrapAlignment.center,
                                      children: _secondsIncrements.map((increment) {
                                        final isNegative = increment < 0;
                                        return Material(
                                          color: isNegative
                                              ? colorScheme.errorContainer.withValues(alpha: 0.3)
                                              : colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(8),
                                          child: InkWell(
                                            onTap: () => _quickAdjustSeconds(increment),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              child: Text(
                                                '${increment > 0 ? '+' : ''}${increment}s',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isNegative
                                                      ? colorScheme.error
                                                      : colorScheme.tertiary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // RPE Selection
                        if (_isCompleted || widget.isInWorkout)
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.speed,
                                      size: 18,
                                      color: colorScheme.tertiary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'RPE - Rate of Perceived Exertion',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // RPE chips with color coding
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(5, (index) {
                                    final rpe = index + 6;
                                    final isSelected = _selectedRpe == rpe;
                                    
                                    // Color based on RPE value
                                    Color chipColor;
                                    if (rpe <= 6) {
                                      chipColor = context.colors.success;
                                    } else if (rpe <= 7) {
                                      chipColor = context.colors.success;
                                    } else if (rpe <= 8) {
                                      chipColor = context.colors.secondary;
                                    } else if (rpe <= 9) {
                                      chipColor = context.colors.warning;
                                    } else {
                                      chipColor = context.colors.error;
                                    }
                                    
                                    return Material(
                                      color: isSelected
                                          ? chipColor.withValues(alpha: 0.2)
                                          : colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(20),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedRpe = isSelected ? null : rpe;
                                            _updateRir();
                                          });
                                          HapticFeedback.lightImpact();
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isSelected
                                                  ? chipColor
                                                  : colorScheme.outline.withValues(alpha: 0.3),
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                '$rpe',
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected ? chipColor : colorScheme.onSurface,
                                                ),
                                              ),
                                              Text(
                                                '${10 - rpe} RIR',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: isSelected 
                                                      ? chipColor 
                                                      : colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                
                                if (_selectedRpe != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _calculatedRir == 0
                                                ? 'Maximum effort - no reps left in reserve'
                                                : _calculatedRir == 1
                                                    ? 'Near maximum - could do 1 more rep'
                                                    : 'Good effort - could do $_calculatedRir more reps',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        
                        // ✅ NUOVO: Conditional summary display (volume for weighted, duration for time-based)
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.countingMode == ExerciseCountingMode.time
                                    ? Icons.timer
                                    : Icons.calculate,
                                size: 16,
                                color: colorScheme.tertiary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.countingMode == ExerciseCountingMode.time
                                    ? 'Duration: ${_selectedSeconds < 60 ? '${_selectedSeconds}s' : '${_selectedSeconds ~/ 60}m ${_selectedSeconds % 60}s'}'
                                    : widget.countingMode == ExerciseCountingMode.reps
                                        ? 'Reps: $_selectedReps'
                                        : 'Volume: ${(_selectedWeight * _selectedReps).toStringAsFixed(0)}${config.measurementUnit}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.tertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Rest time suggestion banner
                        if (_showSuggestionBanner && _restTimeSuggestion != null)
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _restTimeSuggestion!.type == RestTimeSuggestionType.increase
                                    ? context.colors.secondary.withValues(alpha: 0.15)
                                    : context.colors.success.withValues(alpha: 0.15),
                                  _restTimeSuggestion!.type == RestTimeSuggestionType.increase
                                    ? context.colors.warning.withValues(alpha: 0.1)
                                    : context.colors.success.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _restTimeSuggestion!.type == RestTimeSuggestionType.increase
                                  ? context.colors.secondary.withValues(alpha: 0.5)
                                  : context.colors.success.withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _restTimeSuggestion!.type == RestTimeSuggestionType.increase
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                      color: _restTimeSuggestion!.type == RestTimeSuggestionType.increase
                                        ? context.colors.secondary
                                        : context.colors.success,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.restTimeSuggestion,
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: _restTimeSuggestion!.type == RestTimeSuggestionType.increase
                                                ? context.colors.secondary
                                                : context.colors.success,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _restTimeSuggestion!.reason,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Recupero attuale: ${RestTimeSuggestionService.formatTime(_restTimeSuggestion!.currentRestTime)}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward, size: 16, color: colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Suggerito: ${RestTimeSuggestionService.formatTime(_restTimeSuggestion!.suggestedRestTime)}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _showSuggestionBanner = false;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(l10n.dismiss),
                                    ),
                                    const SizedBox(width: 8),
                                    FilledButton.icon(
                                      onPressed: () {
                                        // Accept suggestion and update exercise rest time
                                        if (widget.exercise != null) {
                                          final updatedExercise = widget.exercise!.copyWith(
                                            restTime: _restTimeSuggestion!.suggestedRestTime,
                                          );
                                          ref.read(currentWorkoutProvider.notifier).updateExercise(
                                            widget.exercise!.name,
                                            updatedExercise,
                                          );
                                        }
                                        HapticFeedback.mediumImpact();
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(Icons.check, size: 18),
                                      label: Text(l10n.accept),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _restTimeSuggestion!.type == RestTimeSuggestionType.increase
                                          ? context.colors.secondary
                                          : context.colors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        // Action buttons
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Row(
                            children: [
                              // Cancel button
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.of(context).pop();
                                    widget.onCancel?.call();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              // Save button
                              Expanded(
                                flex: 2,
                                child: FilledButton(
                                  onPressed: _save,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: _isCompleted 
                                        ? colorScheme.tertiary 
                                        : colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isCompleted ? Icons.check_circle : Icons.save,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isCompleted 
                                          ? (widget.isSuperset ? 'Complete Superset' : 'Complete Set')
                                          : 'Save',
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}