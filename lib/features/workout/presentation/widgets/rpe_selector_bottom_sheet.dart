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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/rpe_autoregulation_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Helper function to convert RPE to RIR
int rpeToRir(double rpe) => (10 - rpe).round();

/// Helper function to format effort value based on user preference
String formatEffortValue(double rpe, bool useRir) {
  if (useRir) {
    return 'RIR ${rpeToRir(rpe)}';
  }
  return 'RPE ${rpe.toStringAsFixed(1)}';
}

class SupersetExerciseCompleteData {
  const SupersetExerciseCompleteData({
    required this.actualReps,
    required this.actualWeight,
    required this.rpe,
    this.actualMinutes = 0,
    this.actualSeconds = 0,
  });
  final int actualReps;
  final double actualWeight;
  final int rpe;
  final int actualMinutes;
  final int actualSeconds;
}

class RpeSelectorBottomSheet extends ConsumerStatefulWidget {
  const RpeSelectorBottomSheet({
    super.key,
    required this.set,
    required this.targetReps,
    required this.onConfirm,
    this.exercise,
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

  // Exercise for RPE checking
  final Exercise? exercise;

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
    Function(double suggestedWeight)? onRPESuggestion,
    bool isPartOfSuperset = false,
    String? supersetName,
    List<Exercise>? supersetExercises,
    SupersetSet? supersetSet,
    int currentExerciseIndex = 0,
    Function(Map<int, SupersetExerciseCompleteData>)? onSupersetCompleteAll,
  }) {
    return ModalService.showSheet(context,
      isScrollControlled: true,
      // Remove fixed constraints to allow dynamic sizing
      builder: (context) => RpeSelectorBottomSheet(
        set: set,
        targetReps: targetReps,
        onConfirm: onConfirm,
        exercise: exercise,
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
  ConsumerState<RpeSelectorBottomSheet> createState() =>
      _RpeSelectorBottomSheetState();
}

class _RpeSelectorBottomSheetState
    extends ConsumerState<RpeSelectorBottomSheet> {
  late int _actualReps;
  double _actualWeight = 0.0;
  int? _selectedRpe;
  int? _calculatedRir;
  bool _showWeightAndReps = true;

  // Wheel controllers for weight/reps pickers
  late FixedExtentScrollController _weightWheelController;
  late FixedExtentScrollController _repsWheelController;

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

    // Initialize wheel controllers after _loadExerciseData sets _actualWeight/_actualReps
    final weightIndex = (_actualWeight / 0.5).round().clamp(0, 600);
    final repsIndex = _actualReps.clamp(0, 100);
    _weightWheelController = FixedExtentScrollController(initialItem: weightIndex);
    _repsWheelController = FixedExtentScrollController(initialItem: repsIndex);

    // Load saved preference for weight/reps verification toggle
    final config = ref.read(appConfigProvider);
    _showWeightAndReps = config.showWeightVerification;
  }

  void _loadExerciseData(ExerciseSet exerciseSet) {
    // Check if we have completion data for this exercise in our batch
    final storedData = _supersetCompleteData[_currentExerciseIndex];
    if (storedData != null) {
      // Load from our stored completion data
      _actualReps = storedData.actualReps;
      _actualWeight = storedData.actualWeight;
      _selectedRpe = storedData.rpe;
      // Restore time data if saved
      _actualMinutes = storedData.actualMinutes;
      _actualSeconds = storedData.actualSeconds;
    } else {
      // Load from exercise set
      _actualReps = exerciseSet.actualReps ?? widget.targetReps;
      _actualWeight = exerciseSet.weight ?? 0.0;
      _selectedRpe = exerciseSet.rpe;

      // Initialize time variables for time-based exercises
      final totalSeconds = exerciseSet.seconds ?? 60;
      _actualMinutes = totalSeconds ~/ 60;
      _actualSeconds = totalSeconds % 60;
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
    _weightWheelController.dispose();
    _repsWheelController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (!widget.isPartOfSuperset) return;

    setState(() {
      _currentExerciseIndex = index;
      _currentExerciseSet = _getExerciseSetForIndex(index);
      _loadExerciseData(_currentExerciseSet);
    });

    // Sync wheel positions to reflect the newly loaded exercise data
    _weightWheelController.jumpToItem(
      (_actualWeight / 0.5).round().clamp(0, 600),
    );
    _repsWheelController.jumpToItem(_actualReps.clamp(0, 100));

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
    final countingMode =
        widget.exercise?.countingMode ?? ExerciseCountingMode.weighted;

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
      _supersetCompleteData[_currentExerciseIndex] =
          SupersetExerciseCompleteData(
            actualReps: _actualReps,
            actualWeight: _actualWeight,
            rpe: rpe,
            actualMinutes: _actualMinutes,
            actualSeconds: _actualSeconds,
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
        return context.colors.success;
      case 7:
        return context.colors.success;
      case 8:
        return context.colors.warning;
      case 9:
        return context.colors.warning;
      case 10:
        return context.colors.error;
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
    final countingMode =
        widget.exercise?.countingMode ?? ExerciseCountingMode.weighted;
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
  Widget _buildInputFieldsBasedOnCountingMode(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final countingMode =
        widget.exercise?.countingMode ?? ExerciseCountingMode.weighted;

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
    return [baseColor, baseColor.withValues(alpha: 0.7)];
  }

  Widget _buildRpeScale(ThemeData theme, ColorScheme colorScheme, bool useRir) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final rpe = index + 6; // RPE from 6 to 10
        final isSelected = _selectedRpe == rpe;
        // Convert to RIR if needed: RIR = 10 - RPE
        final displayValue = useRir ? rpeToRir(rpe.toDouble()) : rpe;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Semantics(
              label: useRir ? 'RIR $displayValue: ${_getRpeShortLabel(rpe)}' : 'RPE $displayValue: ${_getRpeShortLabel(rpe)}',
              button: true,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedRpe = rpe;
                    _updateRir();
                  });
                  // Auto-confirm e dismiss per tutti i valori tranne RPE 10.
                  // RPE 10 rimane aperto per permettere review prima di confermare.
                  if (rpe != 10 && !widget.isPartOfSuperset) {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop();
                    final (actualReps, actualWeight) = _getConfirmData();
                    widget.onConfirm(actualReps, actualWeight, rpe);
                  }
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
                      ? colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        )
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
                            color: _getRpeColor(
                              rpe,
                              colorScheme,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_getRpeEmoji(rpe), style: theme.textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      '$displayValue',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? context.colors.surface
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _getRpeShortLabel(rpe),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? context.colors.surface.withValues(alpha: 0.95)
                            : colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      }),
    );
  }

  Widget _buildSupersetHeader(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
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
              SemanticIcon(
                icon: AppIcons.swipe,
                semanticLabel: 'Swipe',
                size: AppIconSize.tiny,
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

  Widget _buildMainContent(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    // Watch the global RIR mode setting
    final useRir = ref.watch(useRirModeProvider);

    // Check for RPE suggestion
    final showRPESuggestion = _shouldShowRPESuggestion();
    final rpeSuggestion = showRPESuggestion ? _calculateRPESuggestion() : null;

    // ✅ Calculate rest time adjustment preview
    final config = ref.read(appConfigProvider);
    final showRestAdjustment = (config.autoAdjustRestFromRpe ?? false) &&
        _selectedRpe != null;
    RestTimeAdjustment? restSuggestion;
    if (showRestAdjustment) {
      final baseRestSeconds =
          widget.set.restTime ?? widget.exercise?.restTime ?? 90;
      restSuggestion = RPEAutoregulationService.calculateRestTimeAdjustment(
        baseRestSeconds: baseRestSeconds,
        actualRPE: _selectedRpe!.toDouble(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // RPE Suggestion Card (if applicable)
        if (showRPESuggestion &&
            rpeSuggestion != null &&
            rpeSuggestion.adjustmentPercent != 0)
          _buildRPESuggestionCard(
            context,
            theme,
            l10n,
            colorScheme,
            rpeSuggestion,
            useRir,
            restSuggestion: restSuggestion,
          ),

        // ✅ Show rest adjustment preview even without weight suggestion
        if (!showRPESuggestion &&
            restSuggestion != null &&
            restSuggestion.hasAdjustment)
          _buildRestOnlyCard(context, theme, l10n, colorScheme, restSuggestion),

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
                child: CupertinoSwitch(
                  value: _showWeightAndReps,
                  onChanged: (value) {
                    setState(() {
                      _showWeightAndReps = value;
                    });
                    // Save preference
                    final config = ref.read(appConfigProvider);
                    ref.read(appConfigProvider.notifier).updateConfig(
                      config.copyWith(showWeightVerification: value),
                    );
                  },
                  activeTrackColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        // Weight & Reps Section - Premium design (dynamic based on counting mode)
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _showWeightAndReps
              ? _buildInputFieldsBasedOnCountingMode(
                  context,
                  theme,
                  colorScheme,
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 16),

        // RPE/RIR Section (adapts based on user preference)
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
                    useRir ? l10n.rir : l10n.rpe,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    label: useRir ? 'RIR information' : 'RPE information',
                    hint: 'Tap to view explanation',
                    button: true,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(useRir ? l10n.rir : l10n.rpe),
                            content: Text(
                              useRir ? l10n.rirDescription : l10n.rpeDescription,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: SemanticIcon(
                      icon: AppIcons.info,
                      semanticLabel: 'Information',
                      size: AppIconSize.small,
                      color: colorScheme.primary,
                    ),
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

              // RPE/RIR buttons - Responsive row (displays based on preference)
              _buildRpeScale(theme, colorScheme, useRir),

              // Complementary display (show RIR when in RPE mode, show RPE when in RIR mode)
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
                              colorScheme.primaryContainer.withValues(
                                alpha: 0.5,
                              ),
                              colorScheme.primaryContainer.withValues(
                                alpha: 0.3,
                              ),
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: SemanticIcon(
                                icon: AppIcons.trendUp,
                                semanticLabel: 'Trend up',
                                size: AppIconSize.small,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  // Show opposite scale for reference
                                  useRir
                                      ? '${l10n.rpe}: ${_selectedRpe ?? 0}'
                                      : '${l10n.rir}: $_calculatedRir',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  useRir
                                      ? l10n.rpeDescription
                                      : l10n.repsInReserve,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                child: Semantics(
                  label: widget.set.isCompleted ? l10n.cancel : l10n.skipRpe,
                  button: true,
                  child: OutlinedButton(
                    onPressed: () {
                    if (widget.set.isCompleted) {
                      // Set was already completed → "Cancel" button (safe exit)
                      Navigator.of(context).pop();
                      // Don't call onConfirm - just close without changes
                    } else {
                      // Set was NOT completed → "Skip RPE" button (complete with rpe=0)
                      if (widget.isPartOfSuperset) {
                        _saveCurrentExerciseData(0);
                        if (_allExercisesCompleted() &&
                            widget.onSupersetCompleteAll != null) {
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
                    widget.set.isCompleted ? l10n.cancel : l10n.skipRpe,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
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
                  child: Semantics(
                    label: widget.isPartOfSuperset
                        ? (_allExercisesCompleted()
                              ? l10n.completeSet
                              : '${l10n.save} (${_supersetCompleteData.length}/${widget.supersetExercises?.length ?? 0})')
                        : l10n.confirmSet,
                    button: true,
                    child: FilledButton(
                      onPressed: _selectedRpe != null
                        ? () {
                            HapticFeedback.mediumImpact();
                            if (widget.isPartOfSuperset) {
                              _saveCurrentExerciseData(_selectedRpe ?? 0);
                              if (_allExercisesCompleted() &&
                                  widget.onSupersetCompleteAll != null) {
                                // Tutti gli esercizi completati → chiudi e callback
                                Navigator.of(context).pop();
                                widget.onSupersetCompleteAll!(
                                  _supersetCompleteData,
                                );
                              } else {
                                // ✅ FIX: Avanza automaticamente al prossimo esercizio
                                if (_currentExerciseIndex <
                                    (widget.supersetExercises?.length ?? 0) -
                                        1) {
                                  _pageController?.animateToPage(
                                    _currentExerciseIndex + 1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              }
                            } else {
                              Navigator.of(context).pop();
                              final rpeToSend = _selectedRpe ?? 0;
                              // ✅ NEW: Get correct data based on counting mode
                              final (actualReps, actualWeight) =
                                  _getConfirmData();
                              widget.onConfirm(
                                actualReps,
                                actualWeight,
                                rpeToSend,
                              );
                            }
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: context.colors.surface.withValues(
                        alpha: 0,
                      ),
                      foregroundColor: context.colors.surface,
                      disabledBackgroundColor:
                          colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_selectedRpe != null) ...[
                          const SemanticIcon(
                            icon: AppIcons.complete,
                            semanticLabel: 'Complete',
                            size: AppIconSize.small,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.isPartOfSuperset
                              ? (_allExercisesCompleted()
                                    ? l10n.completeSet
                                    : '${l10n.save} (${_supersetCompleteData.length}/${widget.supersetExercises?.length ?? 0})')
                              : l10n.confirmSet,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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

  // RPE Autoregulation Helper Methods
  //
  // ✅ SIMPLIFIED: Now uses global config.autoAdjustWeightFromRpe setting
  // instead of requiring per-exercise configuration (autoAdjustmentType).
  // Uses sensible defaults: RPE 7-9 range or RIR 2 target.
  bool _shouldShowRPESuggestion() {
    if (widget.exercise == null) return false;
    if (_selectedRpe == null) return false;

    // ✅ Check global setting instead of per-exercise config
    final config = ref.read(appConfigProvider);
    if (config.autoAdjustWeightFromRpe != true) return false;

    // Need actual weight to calculate suggestion
    if (_actualWeight <= 0) return false;

    return true;
  }

  WeightAdjustment? _calculateRPESuggestion() {
    if (widget.exercise == null || _selectedRpe == null || _actualWeight == 0) {
      return null;
    }

    final useRir = ref.read(useRirModeProvider);

    // ✅ Use exercise-specific targets if available, otherwise use defaults
    // Default RPE range: 7-9 (optimal training zone)
    // Default RIR target: 2 (2 reps in reserve)
    const defaultRPEMin = 7.0;
    const defaultRPEMax = 9.0;
    const defaultRIR = 2;

    if (!useRir) {
      // RPE mode - use configured range or defaults
      final targetMin = widget.exercise!.targetRPEMin ?? defaultRPEMin;
      final targetMax = widget.exercise!.targetRPEMax ?? defaultRPEMax;

      return RPEAutoregulationService.calculateRPEAdjustment(
        currentWeight: _actualWeight,
        actualRPE: _selectedRpe!.toDouble(),
        targetRPEMin: targetMin,
        targetRPEMax: targetMax,
      );
    } else {
      // RIR mode - use configured target or default
      final targetRIR = widget.exercise!.targetRIR ?? defaultRIR;
      final actualRIR = RPEAutoregulationService.rpeToRIR(
        _selectedRpe!.toDouble(),
      );

      return RPEAutoregulationService.calculateRIRAdjustment(
        currentWeight: _actualWeight,
        actualRIR: actualRIR,
        targetRIR: targetRIR,
      );
    }
  }

  Widget _buildRPESuggestionCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    WeightAdjustment suggestion,
    bool useRir, {
    RestTimeAdjustment? restSuggestion,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            suggestion.shouldIncrease
                ? context.colors.success.withValues(alpha: 0.2)
                : suggestion.shouldDecrease
                ? context.colors.warning.withValues(alpha: 0.2)
                : colorScheme.primaryContainer.withValues(alpha: 0.5),
            colorScheme.primaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: suggestion.shouldIncrease
              ? context.colors.success.withValues(alpha: 0.3)
              : suggestion.shouldDecrease
              ? context.colors.warning.withValues(alpha: 0.3)
              : colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.trendUp,
                semanticLabel: 'Trend up',
                size: AppIconSize.small,
                color: suggestion.shouldIncrease
                    ? context.colors.success
                    : suggestion.shouldDecrease
                    ? context.colors.warning
                    : colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                useRir ? l10n.rirAutoregulation : l10n.rpeAutoregulation,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Display actual effort value based on preference
          Text(
            suggestion.actualRPE != null
                ? useRir
                      ? '${l10n.actualRir}: ${rpeToRir(suggestion.actualRPE!)}'
                      : '${l10n.actualRpe}: ${suggestion.actualRPE!.toStringAsFixed(0)}'
                : '${l10n.actualRir}: ${suggestion.actualRIR}',
            style: theme.textTheme.bodyMedium,
          ),
          // Display target range based on preference
          if (suggestion.targetRPERange != null)
            Text(
              useRir
                  ? () {
                      // Parse RPE range and convert to RIR
                      final parts = suggestion.targetRPERange!.split('-');
                      if (parts.length == 2) {
                        final minRpe =
                            double.tryParse(parts.first.trim()) ?? 6.0;
                        final maxRpe =
                            double.tryParse(parts.last.trim()) ?? 10.0;
                        return '${l10n.targetRir}: ${rpeToRir(maxRpe)} - ${rpeToRir(minRpe)}';
                      }
                      return l10n.targetRange(suggestion.targetRPERange!);
                    }()
                  : l10n.targetRange(suggestion.targetRPERange!),
              style: theme.textTheme.bodyMedium,
            )
          else if (suggestion.targetRIR != null)
            Text(
              '${l10n.targetRir}: ${suggestion.targetRIR}',
              style: theme.textTheme.bodyMedium,
            ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
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
                            ? context.colors.success
                            : suggestion.shouldDecrease
                            ? context.colors.warning
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
                    SnackBarService.showInfo(
                      context,
                      '${l10n.nextSetWeight}: ${suggestion.adjustedWeight.toStringAsFixed(1)} kg',
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

          // ✅ Rest time adjustment preview (if applicable)
          if (restSuggestion != null && restSuggestion.hasAdjustment) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.timer,
                    semanticLabel: l10n.adjustRestTitle,
                    size: AppIconSize.small,
                    color: restSuggestion.needsMoreRest
                        ? context.colors.warning
                        : context.colors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.adjustRestTitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${restSuggestion.baseRestSeconds}s → ${restSuggestion.adjustedRestSeconds}s',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: restSuggestion.needsMoreRest
                                ? context.colors.warning
                                : context.colors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: restSuggestion.needsMoreRest
                          ? context.colors.warning.withValues(alpha: 0.2)
                          : context.colors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      restSuggestion.needsMoreRest
                          ? '+${restSuggestion.adjustmentSeconds}s'
                          : '${restSuggestion.adjustmentSeconds}s',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: restSuggestion.needsMoreRest
                            ? context.colors.warning
                            : context.colors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 4),
          Text(
            _getLocalizedAdjustmentReason(l10n, suggestion),
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Card for rest-only adjustment (when weight suggestion is disabled)
  Widget _buildRestOnlyCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    RestTimeAdjustment restSuggestion,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: restSuggestion.needsMoreRest
              ? context.colors.warning.withValues(alpha: 0.3)
              : context.colors.success.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.timer,
            semanticLabel: l10n.adjustRestTitle,
            size: AppIconSize.medium,
            color: restSuggestion.needsMoreRest
                ? context.colors.warning
                : context.colors.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.adjustRestTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${restSuggestion.baseRestSeconds}s → ${restSuggestion.adjustedRestSeconds}s',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: restSuggestion.needsMoreRest
                        ? context.colors.warning
                        : context.colors.success,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: restSuggestion.needsMoreRest
                  ? context.colors.warning.withValues(alpha: 0.2)
                  : context.colors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              restSuggestion.needsMoreRest
                  ? '+${restSuggestion.adjustmentSeconds}s'
                  : '${restSuggestion.adjustmentSeconds}s',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: restSuggestion.needsMoreRest
                    ? context.colors.warning
                    : context.colors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns a localized reason message based on the adjustment suggestion
  String _getLocalizedAdjustmentReason(
    AppLocalizations l10n,
    WeightAdjustment suggestion,
  ) {
    final percent = suggestion.adjustmentPercent.abs().toStringAsFixed(1);

    if (suggestion.shouldIncrease) {
      return l10n.increaseWeightBy(percent);
    } else if (suggestion.shouldDecrease) {
      return l10n.decreaseWeightBy(percent);
    } else {
      return l10n.maintainWeight;
    }
  }

  Widget _buildWeightAndRepsSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context);
    const double wheelHeight = 120;
    const double itemExtent = 36;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          // Weight Wheel
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SemanticIcon(
                      icon: AppIcons.workout,
                      semanticLabel: 'Workout',
                      size: AppIconSize.tiny,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.weight,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: wheelHeight,
                  child: CupertinoPicker(
                    scrollController: _weightWheelController,
                    itemExtent: itemExtent,
                    diameterRatio: 1.2,
                    squeeze: 1.0,
                    useMagnifier: true,
                    magnification: 1.15,
                    selectionOverlay: Container(
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    onSelectedItemChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _actualWeight = index * 0.5;
                      });
                    },
                    // 0 to 300kg in 0.5kg steps = 601 items
                    children: List.generate(601, (index) {
                      final weight = index * 0.5;
                      final isTarget =
                          weight == _currentExerciseSet.weight;
                      return Center(
                        child: Text(
                          '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isTarget
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isTarget
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: wheelHeight - 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),

          // Reps Wheel
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SemanticIcon(
                      icon: AppIcons.repeat,
                      semanticLabel: 'Repeat',
                      size: AppIconSize.tiny,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.reps,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: wheelHeight,
                  child: CupertinoPicker(
                    scrollController: _repsWheelController,
                    itemExtent: itemExtent,
                    diameterRatio: 1.2,
                    squeeze: 1.0,
                    useMagnifier: true,
                    magnification: 1.15,
                    selectionOverlay: Container(
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    onSelectedItemChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _actualReps = index;
                      });
                    },
                    // 0 to 100 reps
                    children: List.generate(101, (index) {
                      final isTarget = index == widget.targetReps;
                      return Center(
                        child: Text(
                          '$index ${l10n.reps}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isTarget
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isTarget
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build reps-only section (for reps counting mode) — Cupertino wheel
  Widget _buildRepsOnlySection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context);
    const double wheelHeight = 120;
    const double itemExtent = 36;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              SemanticIcon(
                icon: AppIcons.repeat,
                semanticLabel: 'Repeat',
                size: AppIconSize.small,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.reps,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: wheelHeight,
            child: CupertinoPicker(
              scrollController: _repsWheelController,
              itemExtent: itemExtent,
              diameterRatio: 1.2,
              squeeze: 1.0,
              useMagnifier: true,
              magnification: 1.15,
              selectionOverlay: Container(
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
              onSelectedItemChanged: (index) {
                HapticFeedback.selectionClick();
                setState(() {
                  _actualReps = index;
                });
              },
              children: List.generate(101, (index) {
                final isTarget = index == widget.targetReps;
                return Center(
                  child: Text(
                    '$index ${l10n.reps}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: isTarget
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isTarget
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ FIX: Build time input section (for time counting mode)
  Widget _buildTimeInputSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
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
                    SemanticIcon(
                      icon: AppIcons.schedule,
                      semanticLabel: 'Schedule',
                      size: AppIconSize.tiny,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.exerciseListMinutes,
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
                    Semantics(
                      label: 'Decrease minutes by 1',
                      button: true,
                      child: InkWell(
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
                            color: colorScheme.errorContainer.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SemanticIcon(
                            icon: AppIcons.remove,
                            semanticLabel: 'Remove',
                            size: AppIconSize.small,
                            color: colorScheme.error,
                          ),
                        ),
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
                            l10n.minutes,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Increase minutes
                    Semantics(
                      label: 'Increase minutes by 1',
                      button: true,
                      child: InkWell(
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
                            color: colorScheme.primaryContainer.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SemanticIcon(
                            icon: AppIcons.add,
                            semanticLabel: 'Add',
                            size: AppIconSize.small,
                            color: colorScheme.primary,
                          ),
                        ),
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
                    SemanticIcon(
                      icon: AppIcons.timer,
                      semanticLabel: 'Timer',
                      size: AppIconSize.tiny,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.exerciseListSeconds,
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
                    Semantics(
                      label: 'Decrease seconds by 5',
                      button: true,
                      child: InkWell(
                        onTap: _actualSeconds > 0
                            ? () {
                                HapticFeedback.lightImpact();
                                setState(
                                  () => _actualSeconds = (_actualSeconds - 5)
                                      .clamp(0, 59),
                                );
                              }
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SemanticIcon(
                            icon: AppIcons.remove,
                            semanticLabel: 'Remove',
                            size: AppIconSize.small,
                            color: colorScheme.error,
                          ),
                        ),
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
                            l10n.seconds,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Increase seconds
                    Semantics(
                      label: 'Increase seconds by 5',
                      button: true,
                      child: InkWell(
                        onTap: _actualSeconds < 59
                            ? () {
                                HapticFeedback.lightImpact();
                                setState(
                                  () => _actualSeconds = (_actualSeconds + 5)
                                      .clamp(0, 59),
                                );
                              }
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SemanticIcon(
                            icon: AppIcons.add,
                            semanticLabel: 'Add',
                            size: AppIconSize.small,
                            color: colorScheme.primary,
                          ),
                        ),
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
    // NOTE: No DecoratedBox needed - BottomSheetThemeData already provides
    // background color, shape, and clipBehavior: Clip.antiAlias
    final mainContent = SafeArea(
      top: false, // Bottom sheet doesn't need top safe area
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
    );

    // If part of a superset, use a PageView with explicit height
    // ✅ FIX: IntrinsicHeight + PageView causes layout failure - PageView needs explicit constraints
    if (widget.isPartOfSuperset) {
      return SizedBox(
        // Use fixed height for superset mode (PageView can't calculate intrinsic height)
        height: MediaQuery.of(context).size.height * 0.75,
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
