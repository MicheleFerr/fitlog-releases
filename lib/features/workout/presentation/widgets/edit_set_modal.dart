import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/rest_time_suggestion_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_auto_regulation_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/weight_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/reps_picker_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/suggestion_accuracy.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/datasources/questionnaire_analytics_datasource.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

class EditSetModal extends ConsumerStatefulWidget {

  const EditSetModal({
    super.key,
    required this.exerciseSet,
    required this.onSave,
    this.exercise,
    this.previousSet,
    this.suggestedWeight,
    this.suggestedReps,
  });
  final ExerciseSet exerciseSet;
  final Function(ExerciseSet) onSave;
  final Exercise? exercise;
  final ExerciseSet? previousSet;
  final double? suggestedWeight;
  final int? suggestedReps;

  @override
  ConsumerState<EditSetModal> createState() => _EditSetModalState();
}

class _EditSetModalState extends ConsumerState<EditSetModal> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _actualRepsController;
  late TextEditingController _secondsController;
  late TextEditingController _notesController;

  bool _isCompleted = false;
  int? _selectedRpe;

  // APRE suggestion state
  RestTimeSuggestion? _restTimeSuggestion;
  bool _showRestSuggestionBanner = false;
  double? _suggestedWeight;
  bool _showWeightSuggestionBanner = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.exerciseSet.isCompleted;
    _selectedRpe = widget.exerciseSet.rpe;
    
    _weightController = TextEditingController(
      text: widget.exerciseSet.weight?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.exerciseSet.reps?.toString() ?? '',
    );
    _actualRepsController = TextEditingController(
      text: widget.exerciseSet.actualReps?.toString() ?? '',
    );
    // Show tracked duration if available, otherwise show manual seconds input
    String durationText = '';
    if (widget.exerciseSet.setDurationMillis != null) {
      // Convert milliseconds to seconds,milliseconds format (e.g., "12,34" for 12.34 seconds)
      final totalMillis = widget.exerciseSet.setDurationMillis!.round();
      final seconds = totalMillis ~/ 1000;
      final millis = (totalMillis % 1000) ~/ 10; // Get centiseconds (2 decimal places)
      durationText = '$seconds,${millis.toString().padLeft(2, '0')}';
    } else if (widget.exerciseSet.seconds != null) {
      durationText = '${widget.exerciseSet.seconds},00';
    }
    
    _secondsController = TextEditingController(
      text: durationText,
    );
    _notesController = TextEditingController(
      text: widget.exerciseSet.notes ?? '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _actualRepsController.dispose();
    _secondsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header
          Row(
            children: [
              Text(
                'Edit Set ${widget.exerciseSet.setNumber}',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Completion toggle
          Card(
            child: SwitchListTile(
              title: const Text('Mark as Completed'),
              subtitle: Text(_isCompleted ? 'This set is completed' : 'This set is not completed'),
              value: _isCompleted,
              onChanged: (value) {
                setState(() {
                  _isCompleted = value;
                });
              },
              secondary: Icon(
                _isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: _isCompleted 
                    ? context.colors.tertiary 
                    : context.colors.outline,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Weight and Reps row
          Row(
            children: [
              Expanded(
                child: _buildWeightSelector(context, config),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRepsSelector(context),
              ),
            ],
          ),

          if (widget.previousSet != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _copyPreviousSet,
                icon: const Icon(Icons.copy, size: 16),
                label: Text(context.l10n.copyPreviousSet),
              ),
            ),
          ],
          const SizedBox(height: 16),
          
          // Actual Reps (if set is completed)
          if (_isCompleted) ...[
            _buildActualRepsField(context),
            const SizedBox(height: 16),
          ],
          
          // Duration (for timed exercises) - more compact
          _buildDurationField(context),
          const SizedBox(height: 16),
          
          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              labelText: 'Set Notes',
              hintText: 'RPE, form notes, difficulty...',
              prefixIcon: const Icon(Icons.note),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'Tap "Done" on keyboard to close',
              helperStyle: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // RPE selector (if set is completed)
          if (_isCompleted) ...[
            Text(
              'RPE (Rate of Perceived Exertion)',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(5, (index) {
                final rpe = index + 6; // RPE from 6 to 10
                final isSelected = _selectedRpe == rpe;
                
                return ChoiceChip(
                  label: Text('$rpe'),
                  selected: isSelected,
                  selectedColor: _getRpeChipColor(rpe),
                  onSelected: (selected) {
                    setState(() {
                      _selectedRpe = selected ? rpe : null;
                    });
                  },
                );
              }),
            ),
            if (_selectedRpe != null) ...[
              const SizedBox(height: 8),
              Text(
                'RIR: ${10 - _selectedRpe!} reps in reserve',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ] else ...[
            // Old quick RPE buttons for notes (when not completed)
            Text(
              'Quick RPE (add to notes)',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(10, (index) {
                final rpe = index + 1;
                return FilterChip(
                  label: Text('$rpe'),
                  onSelected: (selected) {
                    if (selected) {
                      final currentNotes = _notesController.text;
                      final rpeNote = 'RPE: $rpe';
                      
                      // Replace existing RPE or add new one
                      if (currentNotes.contains('RPE:')) {
                        final updatedNotes = currentNotes.replaceAll(
                          RegExp(r'RPE:\s*\d+'),
                          rpeNote,
                        );
                        _notesController.text = updatedNotes;
                      } else {
                        _notesController.text = currentNotes.isEmpty 
                            ? rpeNote 
                            : '$currentNotes, $rpeNote';
                      }
                    }
                  },
                );
              }),
            ),
          ],
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _saveSet,
                  child: const Text('Save Set'),
                ),
              ),
            ],
          ),

          // Rest Time Suggestion Banner
          if (_showRestSuggestionBanner && _restTimeSuggestion != null) ...[
            const SizedBox(height: 16),
            _buildRestTimeSuggestionBanner(context),
          ],

          // Weight Adjustment Suggestion Banner
          if (_showWeightSuggestionBanner && _suggestedWeight != null) ...[
            const SizedBox(height: 16),
            _buildWeightSuggestionBanner(context),
          ],

          // Bottom padding for safe area
          SizedBox(height: context.mediaQuery.viewInsets.bottom),
        ],
      ),
      ),
    );
  }

  void _copyPreviousSet() {
    if (widget.previousSet != null) {
      setState(() {
        _weightController.text = widget.previousSet!.weight?.toString() ?? '';
        _repsController.text = widget.previousSet!.reps?.toString() ?? '';
      });
    }
  }

  void _saveSet() {
    try {
      final weight = double.tryParse(_weightController.text);
      final reps = int.tryParse(_repsController.text);
      final actualReps = int.tryParse(_actualRepsController.text);
      
      // Parse duration from format "seconds,centiseconds" (e.g., "12,34")
      double? setDurationMillis;
      int? seconds;
      final durationText = _secondsController.text.trim();
      
      if (durationText.isNotEmpty) {
        if (durationText.contains(',')) {
          // Format: "12,34" -> 12340 milliseconds
          final parts = durationText.split(',');
          if (parts.length == 2) {
            final secs = int.tryParse(parts[0]) ?? 0;
            final centis = int.tryParse(parts[1]) ?? 0;
            // Validate reasonable values
            if (secs >= 0 && secs < 3600 && centis >= 0 && centis <= 99) {
              setDurationMillis = (secs * 1000 + centis * 10).toDouble();
              seconds = secs; // For backward compatibility with seconds field
            }
          }
        } else {
          // Simple seconds format (backward compatibility)
          seconds = int.tryParse(durationText);
          if (seconds != null && seconds >= 0 && seconds < 3600) {
            setDurationMillis = seconds * 1000.0;
          }
        }
      } else if (widget.exerciseSet.setDurationMillis != null) {
        // Preserve original auto-tracked value if field is empty
        setDurationMillis = widget.exerciseSet.setDurationMillis;
        seconds = (setDurationMillis! / 1000).round();
      }
      
      final notes = _notesController.text.trim();

      final updatedSet = widget.exerciseSet.copyWith(
        weight: weight,
        reps: reps,
        actualReps: actualReps,
        rpe: _selectedRpe,
        seconds: seconds,
        notes: notes.isEmpty ? null : notes,
        isCompleted: _isCompleted,
        setDurationMillis: setDurationMillis,
        setStartedAt: widget.exerciseSet.setStartedAt, // Preserve start time
      );

      // Ensure onSave callback exists
      widget.onSave(updatedSet);

      // Track suggestion accuracy if set is completed
      if (_isCompleted &&
          widget.suggestedWeight != null &&
          weight != null &&
          widget.exercise != null) {
        _trackSuggestionAccuracy(
          actualWeight: weight,
          actualReps: actualReps ?? reps ?? 0,
        );
      }

      // Check for APRE suggestions (rest time and weight adjustments)
      if (_isCompleted && widget.exercise != null) {
        final config = ref.read(appConfigProvider);
        final autoAdjustEnabled = config.autoAdjustRestTime ?? false;

        // Check for rest time suggestion
        if (widget.previousSet != null && weight != null) {
          final previousWeight = widget.previousSet!.weight ?? weight;

          final restSuggestion = RestTimeSuggestionService.checkRestTimeSuggestion(
            exercise: widget.exercise!,
            newWeight: weight,
            lastWeight: previousWeight,
            currentRestTime: widget.exercise!.restTime ?? 90,
            autoAdjustEnabled: autoAdjustEnabled,
          );

          if (restSuggestion != null) {
            setState(() {
              _restTimeSuggestion = restSuggestion;
              _showRestSuggestionBanner = true;
            });
            return; // Don't close modal yet, show suggestion
          }
        }

        // Check for APRE weight adjustment
        if (widget.exercise!.autoAdjustmentType == AutoAdjustmentType.apre &&
            reps != null &&
            actualReps != null &&
            weight != null) {
          final targetReps = reps;
          final protocol = widget.exercise!.apreProtocol ??
              APREAutoRegulationService.selectProtocolFromTargetReps(targetReps);

          final suggestedWeight = APREAutoRegulationService.calculateNextSetWeight(
            protocol: protocol,
            currentWeight: weight,
            targetReps: targetReps,
            actualReps: actualReps,
          );

          // Show suggestion if weight changed
          if ((suggestedWeight - weight).abs() > 0.1) {
            setState(() {
              _suggestedWeight = suggestedWeight;
              _showWeightSuggestionBanner = true;
            });
            return; // Don't close modal yet, show suggestion
          }
        }
      }

      // No suggestions, close normally
      if (mounted) {
        Navigator.pop(context);

        SnackBarService.showSuccess(
          context,
          'Set ${widget.exerciseSet.setNumber} updated',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error saving set: $e');
      debugPrint('Stack trace: $stackTrace');

      // Show error message to user
      if (mounted) {
        Navigator.pop(context);
        SnackBarService.showError(
          context,
          'Error updating set. Please try again.',
        );
      }
    }
  }
  /// Track suggestion accuracy for adaptive learning
  Future<void> _trackSuggestionAccuracy({
    required double actualWeight,
    required int actualReps,
  }) async {
    try {
      // Get current user
      final userAsync = ref.read(firebaseUserProvider);
      final user = userAsync.value;
      if (user == null) return;

      // Get user's fitness questionnaire for experience level and goal
      final questionnaire = ref.read(userFitnessQuestionnaireProvider);
      if (questionnaire == null) return;

      // Calculate errors
      final weightError = ((actualWeight - widget.suggestedWeight!).abs() / widget.suggestedWeight!) * 100.0;
      final repsError = actualReps - (widget.suggestedReps ?? 0);

      // Create accuracy record
      final datasource = QuestionnaireAnalyticsDataSource();
      final accuracy = SuggestionAccuracy(
        id: datasource.generateId(),
        userId: user.uid,
        exerciseId: widget.exercise!.id,
        suggestedWeight: widget.suggestedWeight!,
        actualWeight: actualWeight,
        suggestedReps: widget.suggestedReps ?? 0,
        actualReps: actualReps,
        weightErrorPercent: weightError,
        repsError: repsError,
        timestamp: DateTime.now(),
        experienceLevel: questionnaire.experienceLevel.name,
        trainingGoal: questionnaire.trainingGoal.name,
        perceivedExertion: _selectedRpe,
      );

      // Save to datasource
      await datasource.saveSuggestionAccuracy(accuracy);

      if (kDebugMode) {
        debugPrint('✅ Tracked suggestion accuracy: ${widget.exercise!.name}');
        debugPrint('   Suggested: ${widget.suggestedWeight}kg → Actual: ${actualWeight}kg');
        debugPrint('   Error: ${weightError.toStringAsFixed(1)}%');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking suggestion accuracy: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      // Don't show error to user - this is background tracking
    }
  }

  Color _getRpeChipColor(int rpe) {
    if (rpe <= 6) return Colors.green;
    if (rpe <= 7) return Colors.lightGreen;
    if (rpe <= 8) return Colors.orange;
    if (rpe <= 9) return Colors.deepOrange;
    return Colors.red;
  }

  Widget _buildWeightSelector(BuildContext context, AppConfig config) {
    final currentWeight = double.tryParse(_weightController.text) ?? 0.0;
    final hasWeight = currentWeight > 0;
    
    return InkWell(
      onTap: () => _openWeightPicker(context, config),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasWeight 
              ? context.colors.primaryContainer.withOpacity(0.3)
              : context.colors.surfaceContainerHighest,
          border: Border.all(
            color: hasWeight 
                ? context.colors.primary.withOpacity(0.3)
                : context.colors.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              size: 18,
              color: hasWeight 
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasWeight 
                    ? '${currentWeight.toStringAsFixed(currentWeight % 1 == 0 ? 0 : 1)} ${config.measurementUnit}'
                    : 'Weight',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: hasWeight ? FontWeight.w600 : FontWeight.normal,
                  color: hasWeight 
                      ? context.colors.onSurface
                      : context.colors.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!hasWeight)
              Icon(
                Icons.add_circle_outline,
                size: 16,
                color: context.colors.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  void _openWeightPicker(BuildContext context, AppConfig config) async {
    final currentWeight = double.tryParse(_weightController.text) ?? 0.0;

    final selectedWeight = await WeightPickerModal.show(
      context,
      initialWeight: currentWeight,
    );

    if (selectedWeight != null) {
      setState(() {
        _weightController.text = selectedWeight.toString();
      });
    }
  }

  Widget _buildRepsSelector(BuildContext context) {
    final currentReps = int.tryParse(_repsController.text) ?? 0;
    final hasReps = currentReps > 0;
    
    return InkWell(
      onTap: () => _openRepsPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasReps 
              ? context.colors.secondaryContainer.withOpacity(0.3)
              : context.colors.surfaceContainerHighest,
          border: Border.all(
            color: hasReps 
                ? context.colors.secondary.withOpacity(0.3)
                : context.colors.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.repeat,
              size: 18,
              color: hasReps 
                  ? context.colors.secondary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasReps 
                    ? '$currentReps reps'
                    : 'Reps',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: hasReps ? FontWeight.w600 : FontWeight.normal,
                  color: hasReps 
                      ? context.colors.onSurface
                      : context.colors.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!hasReps)
              Icon(
                Icons.add_circle_outline,
                size: 16,
                color: context.colors.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  void _openRepsPicker(BuildContext context) async {
    final currentReps = int.tryParse(_repsController.text) ?? 10;

    final selectedReps = await RepsPickerModal.show(
      context,
      initialReps: currentReps,
    );

    if (selectedReps != null) {
      setState(() {
        _repsController.text = selectedReps.toString();
      });
    }
  }

  Widget _buildActualRepsField(BuildContext context) {
    return TextField(
      controller: _actualRepsController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        labelText: 'Actual Reps Completed',
        hintText: 'How many reps did you actually complete?',
        prefixIcon: const Icon(Icons.fitness_center),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDurationField(BuildContext context) {
    final durationText = _secondsController.text;
    final hasDuration = durationText.isNotEmpty;
    final isAutoTracked = widget.exerciseSet.setDurationMillis != null;
    
    return TextField(
      controller: _secondsController,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        labelText: isAutoTracked ? 'Duration (auto-tracked)' : 'Duration (optional)',
        hintText: hasDuration ? null : 'ss,ms (e.g. 12,34)',
        prefixIcon: Icon(
          Icons.timer,
          size: 18,
          color: hasDuration 
              ? context.colors.tertiary
              : context.colors.onSurfaceVariant,
        ),
        suffixText: hasDuration ? 's' : null,
        helperText: isAutoTracked 
            ? '⏱️ Tracked automatically (seconds,centiseconds)' 
            : 'Format: seconds,centiseconds (e.g., 12,34 = 12.34s)',
        helperStyle: TextStyle(
          color: context.colors.primary,
          fontSize: 11,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.number,
      style: context.textTheme.bodyMedium?.copyWith(
        fontWeight: hasDuration ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  /// Build rest time suggestion banner
  Widget _buildRestTimeSuggestionBanner(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.restTimeSuggestion,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _restTimeSuggestion!.message,
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showRestSuggestionBanner = false;
                  });
                  Navigator.pop(context);
                },
                child: Text(l10n.dismiss),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _showRestSuggestionBanner = false;
                  });
                  // Apply suggestion logic would go here in workout_provider
                  Navigator.pop(context);
                },
                child: Text(l10n.accept),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build weight adjustment suggestion banner
  Widget _buildWeightSuggestionBanner(BuildContext context) {
    final l10n = context.l10n;
    final weightDiff = _suggestedWeight! - double.parse(_weightController.text);
    final isIncrease = weightDiff > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isIncrease
            ? Colors.green.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        border: Border.all(
          color: isIncrease ? Colors.green : Colors.blue,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncrease ? Icons.trending_up : Icons.trending_down,
                color: isIncrease ? Colors.green : Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'APRE Weight Adjustment',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isIncrease ? Colors.green : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Suggested weight for next set: ${_suggestedWeight!.toStringAsFixed(1)}kg '
            '(${weightDiff > 0 ? "+" : ""}${weightDiff.toStringAsFixed(1)}kg)',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showWeightSuggestionBanner = false;
                  });
                  Navigator.pop(context);
                },
                child: Text(l10n.dismiss),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _weightController.text = _suggestedWeight!.toStringAsFixed(1);
                    _showWeightSuggestionBanner = false;
                  });
                  // Don't close modal, let user review the updated weight
                },
                child: Text(l10n.accept),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Extension for easy modal showing
extension EditSetModalExtension on BuildContext {
  Future<void> showEditSetModal(
    ExerciseSet? exerciseSet,
    Function(ExerciseSet)? onSave, {
    Exercise? exercise,
    ExerciseSet? previousSet,
    double? suggestedWeight,
    int? suggestedReps,
  }) async {
    // Validate inputs
    if (exerciseSet == null) {
      debugPrint('Error: Cannot show EditSetModal with null exerciseSet');
      SnackBarService.showError(
        this,
        'Error: Unable to edit this set',
      );
      return;
    }

    if (onSave == null) {
      debugPrint('Error: Cannot show EditSetModal with null onSave callback');
      return;
    }

    try {
      await showModalBottomSheet(
        context: this,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => EditSetModal(
          exerciseSet: exerciseSet,
          onSave: onSave,
          exercise: exercise,
          previousSet: previousSet,
          suggestedWeight: suggestedWeight,
          suggestedReps: suggestedReps,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error showing EditSetModal: $e');
      debugPrint('Stack trace: $stackTrace');

      // Show error message to user
      if (mounted) {
        SnackBarService.showError(
          this,
          'Error opening edit dialog. Please try again.',
        );
      }
    }
  }
}
