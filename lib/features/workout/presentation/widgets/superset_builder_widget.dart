import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart' as ExerciseDB;
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_configuration.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/utils/weight_helper.dart';

/// Tier-1 UX widget for creating supersets with professional fitness app design
class SupersetBuilderWidget extends ConsumerStatefulWidget {
  
  const SupersetBuilderWidget({
    super.key,
    required this.onSupersetCreated,
  });
  final Function(SupersetConfiguration) onSupersetCreated;

  @override
  ConsumerState<SupersetBuilderWidget> createState() => _SupersetBuilderWidgetState();
}

class _SupersetBuilderWidgetState extends ConsumerState<SupersetBuilderWidget>
    with TickerProviderStateMixin {
  
  final List<ExerciseDB.Exercise> _selectedExercises = [];
  final List<SupersetRound> _rounds = [];
  // ✅ restBetweenExercises sempre 0 per superset scientifici (rimosso variabile)
  int _restAfterRound = 90;
  final String _supersetName = 'Superset';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card with superset explanation
            _buildInfoCard(theme, l10n),
            const SizedBox(height: 20),
            
            // Exercise selection section
            _buildExerciseSection(theme, l10n),
            const SizedBox(height: 20),
            
            // Rounds configuration section
            if (_selectedExercises.length >= 2) ...[
              _buildRoundsSection(theme, l10n),
              const SizedBox(height: 20),
            ],
            
            // Rest settings section
            if (_selectedExercises.length >= 2) ...[
              _buildRestSettingsSection(theme, l10n),
              const SizedBox(height: 20),
            ],
            
            // Create superset button
            if (_selectedExercises.length >= 2)
              _buildCreateButton(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.link,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.supersetTraining,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.supersetDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectedExercises,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Selected exercises list
        if (_selectedExercises.isNotEmpty) ...[
          ...List.generate(_selectedExercises.length, (index) {
            final exercise = _selectedExercises[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildExerciseCard(exercise, index, theme),
            );
          }),
          const SizedBox(height: 8),
        ],
        
        // Add exercise button
        _buildAddExerciseButton(theme, l10n),
        
        if (_selectedExercises.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.addAtLeastTwoExercises,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExerciseCard(ExerciseDB.Exercise exercise, int index, ThemeData theme) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        title: Text(
          exercise.nome,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('${exercise.focus} • ${exercise.attrezzatura}'),
        trailing: IconButton(
          onPressed: () {
            setState(() {
              _selectedExercises.removeAt(index);
            });
            HapticFeedback.lightImpact();
          },
          icon: Icon(
            Icons.close,
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }

  Widget _buildAddExerciseButton(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: InkWell(
        onTap: _openExerciseSelection,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.addExercise,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundsSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rounds Configuration',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_rounds.length < 5)
              TextButton.icon(
                onPressed: _addRound,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Round'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        ..._rounds.asMap().entries.map((entry) {
          final index = entry.key;
          final round = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildRoundCard(round, index, theme),
          );
        }),
      ],
    );
  }

  Widget _buildRoundCard(SupersetRound round, int index, ThemeData theme) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header round
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${round.roundNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Round ${round.roundNumber}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_rounds.length > 1)
                  IconButton(
                    onPressed: () => _removeRound(index),
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ NUOVO: Lista esercizi con configurazione individuale
            ..._selectedExercises.asMap().entries.map((entry) {
              final exerciseIndex = entry.key;
              final exercise = entry.value;
              final exerciseConfig = round.exerciseConfigs[exercise.id];

              return Container(
                margin: EdgeInsets.only(
                  bottom: exerciseIndex < _selectedExercises.length - 1 ? 12 : 0,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome esercizio
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${exerciseIndex + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            exercise.nome,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ✅ FIX PROBLEMA 1: Picker buttons instead of TextFields
                    Row(
                      children: [
                        Expanded(
                          child: _buildPickerButton(
                            context: context,
                            theme: theme,
                            label: AppLocalizations.of(context).reps,
                            value: '${exerciseConfig?.targetReps ?? 12}',
                            icon: Icons.repeat,
                            color: theme.colorScheme.secondary,
                            onTap: () => _showRepsPicker(
                              context,
                              index,
                              exercise.id,
                              exerciseConfig?.targetReps ?? 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPickerButton(
                            context: context,
                            theme: theme,
                            label: AppLocalizations.of(context).weight,
                            value: exerciseConfig?.targetWeight?.toStringAsFixed(1) ?? '-',
                            icon: Icons.fitness_center,
                            color: theme.colorScheme.primary,
                            onTap: () => _showWeightPicker(
                              context,
                              index,
                              exercise.id,
                              exerciseConfig?.targetWeight ?? 20.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRestSettingsSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rest Settings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Info box scientifica
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Scientific superset: NO rest between exercises (A→B), rest ONLY after completing the full round',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Rest after round (SOLO questo è configurabile)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rest After Round',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rest time after completing ALL exercises in a round',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: _restAfterRound.toString(),
                        decoration: InputDecoration(
                          suffixText: 's',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          setState(() {
                            _restAfterRound = int.tryParse(value) ?? 90;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(ThemeData theme, AppLocalizations l10n) {
    final config = SupersetConfiguration(
      exercises: _selectedExercises,
      rounds: _rounds,
      restBetweenExercises: 0, // ✅ Sempre 0 per superset scientifici
      restAfterRound: _restAfterRound,
      name: _supersetName,
    );
    
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: config.isValid ? () => _createSuperset(config) : null,
        icon: const Icon(Icons.fitness_center),
        label: Text(l10n.createSuperset),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _openExerciseSelection() async {
    final result = await Navigator.of(context).push<List<ExerciseDB.Exercise>>(
      MaterialPageRoute(
        builder: (context) => const ExerciseSearchScreen(
          multiSelectMode: true,
        ),
      ),
    );
    
    if (result != null && result.isNotEmpty) {
      setState(() {
        // Add new exercises, avoiding duplicates
        for (final exercise in result) {
          if (!_selectedExercises.any((e) => e.id == exercise.id)) {
            _selectedExercises.add(exercise);
          }
        }
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _addRound() {
    if (_selectedExercises.isEmpty) return;

    setState(() {
      final roundNumber = _rounds.length + 1;

      // ✅ FIX PROBLEMA 2: Create individual configs for each exercise
      // instead of using .uniform() which creates same config for all
      final Map<String, SupersetExerciseConfig> exerciseConfigs = {};

      for (final exercise in _selectedExercises) {
        exerciseConfigs[exercise.id] = SupersetExerciseConfig(
          exerciseId: exercise.id,
          targetReps: 12, // Default, can be changed individually
          targetWeight: 20.0, // Default, can be changed individually
        );
      }

      _rounds.add(SupersetRound(
        roundNumber: roundNumber,
        exerciseConfigs: exerciseConfigs,
      ));
    });
    HapticFeedback.lightImpact();
  }

  void _removeRound(int index) {
    if (_rounds.length > 1) {
      setState(() {
        _rounds.removeAt(index);
        // Renumber remaining rounds
        for (int i = 0; i < _rounds.length; i++) {
          _rounds[i] = _rounds[i].copyWith(roundNumber: i + 1);
        }
      });
      HapticFeedback.lightImpact();
    }
  }

  void _createSuperset(SupersetConfiguration config) {
    HapticFeedback.mediumImpact();
    widget.onSupersetCreated(config);
  }

  /// ✅ NUOVO: Aggiorna reps per UN SINGOLO esercizio nel round
  void _updateExerciseReps(int roundIndex, String exerciseId, int reps) {
    setState(() {
      final round = _rounds[roundIndex];
      final updatedConfigs = Map<String, SupersetExerciseConfig>.from(round.exerciseConfigs);

      final currentConfig = updatedConfigs[exerciseId];
      if (currentConfig != null) {
        updatedConfigs[exerciseId] = currentConfig.copyWith(targetReps: reps);
        _rounds[roundIndex] = round.copyWith(exerciseConfigs: updatedConfigs);
      }
    });
  }

  /// ✅ NUOVO: Aggiorna weight per UN SINGOLO esercizio nel round
  void _updateExerciseWeight(int roundIndex, String exerciseId, double? weight) {
    setState(() {
      final round = _rounds[roundIndex];
      final updatedConfigs = Map<String, SupersetExerciseConfig>.from(round.exerciseConfigs);

      final currentConfig = updatedConfigs[exerciseId];
      if (currentConfig != null) {
        updatedConfigs[exerciseId] = currentConfig.copyWith(targetWeight: weight);
        _rounds[roundIndex] = round.copyWith(exerciseConfigs: updatedConfigs);
      }
    });
  }

  /// ✅ FIX PROBLEMA 1: Picker button widget
  Widget _buildPickerButton({
    required BuildContext context,
    required ThemeData theme,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, size: 14, color: color.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  /// ✅ FIX PROBLEMA 1: Show reps picker dialog with quick select buttons
  void _showRepsPicker(BuildContext context, int roundIndex, String exerciseId, int currentReps) {
    final theme = Theme.of(context);
    int selectedReps = currentReps;
    final controller = FixedExtentScrollController(initialItem: currentReps - 1);

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 350,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Text(
                AppLocalizations.of(context).reps,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // ✅ Quick select buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [5, 8, 10, 12, 15].map((reps) {
                  final isSelected = selectedReps == reps;
                  return FilterChip(
                    label: Text('$reps'),
                    selected: isSelected,
                    onSelected: (_) {
                      setModalState(() => selectedReps = reps);
                      controller.animateToItem(
                        reps - 1,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                      HapticFeedback.selectionClick();
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.secondaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              // Picker
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 50, // 1-50 reps
                    builder: (context, index) {
                      final reps = index + 1;
                      final isSelected = reps == selectedReps;
                      return Center(
                        child: Text(
                          reps.toString(),
                          style: theme.textTheme.headlineSmall?.copyWith(
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
                    setModalState(() => selectedReps = index + 1);
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Confirm button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    _updateExerciseReps(roundIndex, exerciseId, selectedReps);
                    Navigator.of(context).pop();
                    HapticFeedback.mediumImpact();
                  },
                  child: Text(AppLocalizations.of(context).confirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Show weight picker dialog with unit support (kg/lbs)
  void _showWeightPicker(BuildContext context, int roundIndex, String exerciseId, double currentWeight) {
    final theme = Theme.of(context);
    final unit = ref.read(measurementUnitProvider);

    // Convert stored weight (kg) to display unit
    double selectedWeight = currentWeight.toDisplayUnit(unit);
    final controller = FixedExtentScrollController(
      initialItem: WeightHelper.weightToIndex(selectedWeight, unit),
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 380,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title and current weight
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).weight,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${WeightHelper.formatPickerWeight(selectedWeight, unit)} $unit',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ✅ Quick jump buttons (dynamic based on current weight and unit)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WeightHelper.getQuickJumps(selectedWeight, unit).map((jump) {
                  return OutlinedButton(
                    onPressed: () {
                      final newWeight = WeightHelper.applyQuickJump(
                        currentWeight: selectedWeight,
                        jump: jump,
                        unit: unit,
                      );
                      setModalState(() => selectedWeight = newWeight);
                      controller.animateToItem(
                        WeightHelper.weightToIndex(newWeight, unit),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      HapticFeedback.mediumImpact();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(60, 36),
                    ),
                    child: Text(
                      jump > 0 ? '+$jump' : '$jump',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: jump > 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              // Picker
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: WeightConversion.getChildCount(unit),
                    builder: (context, index) {
                      final weight = WeightHelper.indexToWeight(index, unit);
                      final isSelected = (weight - selectedWeight).abs() < 0.05;
                      final displayText = WeightHelper.formatPickerWeight(weight, unit);

                      return Center(
                        child: Text(
                          displayText,
                          style: theme.textTheme.headlineSmall?.copyWith(
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
                    setModalState(() => selectedWeight = WeightHelper.indexToWeight(index, unit));
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Confirm button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Convert display weight back to kg for storage
                    final weightInKg = selectedWeight.fromDisplayUnit(unit);
                    _updateExerciseWeight(roundIndex, exerciseId, weightInKg);
                    Navigator.of(context).pop();
                    HapticFeedback.mediumImpact();
                  },
                  child: Text(AppLocalizations.of(context).confirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}