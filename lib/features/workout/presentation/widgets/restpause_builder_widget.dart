import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart' as ExerciseDB;
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/utils/weight_helper.dart';

/// Builder widget for creating rest-pause exercises
/// Reuses UI patterns from SupersetBuilderWidget and DropsetBuilderWidget
class RestPauseBuilderWidget extends ConsumerStatefulWidget {

  const RestPauseBuilderWidget({
    super.key,
    required this.onRestPauseCreated,
  });
  final Function(RestPauseExercise) onRestPauseCreated;

  @override
  ConsumerState<RestPauseBuilderWidget> createState() => _RestPauseBuilderWidgetState();
}

class _RestPauseBuilderWidgetState extends ConsumerState<RestPauseBuilderWidget>
    with TickerProviderStateMixin {

  ExerciseDB.Exercise? _selectedExercise;
  double _weight = 0.0;
  int _targetReps = 8;
  int _miniSets = 3; // Number of mini-sets after main set (typically 2-4)
  int _pauseDuration = 15; // Pause duration in seconds (10-30s)

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

  /// Infer ExerciseCategory from exercise database focus
  ExerciseCategory _inferCategoryFromExercise(ExerciseDB.Exercise exercise) {
    final focus = exercise.focus.join(' ').toLowerCase();

    if (focus.contains('petto') || focus.contains('chest')) return ExerciseCategory.chest;
    if (focus.contains('dorso') || focus.contains('schiena') || focus.contains('back')) return ExerciseCategory.back;
    if (focus.contains('spalle') || focus.contains('shoulder')) return ExerciseCategory.shoulders;
    if (focus.contains('braccia') || focus.contains('bicipiti') || focus.contains('tricipiti') || focus.contains('arm') || focus.contains('bicep') || focus.contains('tricep')) {
      return ExerciseCategory.arms;
    }
    if (focus.contains('gambe') || focus.contains('quadricipiti') || focus.contains('femorali') || focus.contains('glutei') || focus.contains('polpacci') || focus.contains('leg') || focus.contains('quad') || focus.contains('hamstring') || focus.contains('glute') || focus.contains('calf')) {
      return ExerciseCategory.legs;
    }
    if (focus.contains('addominali') || focus.contains('core') || focus.contains('ab')) return ExerciseCategory.abs;
    if (focus.contains('cardio')) return ExerciseCategory.cardio;

    return ExerciseCategory.other;
  }

  void _createRestPause() {
    if (_selectedExercise == null || _weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectExerciseAndWeight),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Build restPauseSets based on configuration
    final restPauseSets = List.generate(_miniSets, (index) {
      return RestPauseSet(
        reps: _targetReps ~/ (_miniSets - index), // Decreasing reps per mini-set
        restSeconds: _pauseDuration,
        isCompleted: false,
      );
    });

    final restPause = RestPauseExercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _selectedExercise!.nome,
      category: _inferCategoryFromExercise(_selectedExercise!),
      weight: _weight,
      targetReps: _targetReps,
      restPauseSets: restPauseSets,
      notes: null,
    );

    widget.onRestPauseCreated(restPause);
    HapticFeedback.mediumImpact();
  }

  void _openExerciseSelection() async {
    final selected = await Navigator.push<ExerciseDB.Exercise>(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseSearchScreen(
          allowMultipleSelection: false,
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedExercise = selected;
      });
    }
  }

  void _showWeightPicker(BuildContext context) {
    final unit = ref.read(measurementUnitProvider);
    double selectedWeight = _weight.toDisplayUnit(unit);

    final controller = FixedExtentScrollController(
      initialItem: WeightHelper.weightToIndex(selectedWeight, unit),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    AppLocalizations.of(context).selectWeight,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Current weight display
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.tertiary),
                      const SizedBox(width: 12),
                      Text(
                        '${WeightHelper.formatPickerWeight(selectedWeight, unit)} $unit',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick jumps
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: WeightHelper.getQuickJumps(selectedWeight, unit).map((jump) {
                      return FilterChip(
                        label: Text('${jump > 0 ? '+' : ''}$jump'),
                        onSelected: (_) {
                          final newWeight = WeightHelper.applyQuickJump(
                            currentWeight: selectedWeight,
                            jump: jump,
                            unit: unit,
                          );
                          setModalState(() => selectedWeight = newWeight);
                          controller.animateToItem(
                            WeightHelper.weightToIndex(newWeight, unit),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                          HapticFeedback.selectionClick();
                        },
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Weight picker
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: controller,
                    itemExtent: 50,
                    physics: const FixedExtentScrollPhysics(),
                    diameterRatio: 1.5,
                    onSelectedItemChanged: (index) {
                      setModalState(() {
                        selectedWeight = WeightHelper.indexToWeight(index, unit);
                      });
                      HapticFeedback.selectionClick();
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: WeightConversion.getChildCount(unit),
                      builder: (context, index) {
                        final weight = WeightHelper.indexToWeight(index, unit);
                        final displayText = WeightHelper.formatPickerWeight(weight, unit);
                        final isSelected = weight == selectedWeight;

                        return Center(
                          child: Text(
                            displayText,
                            style: TextStyle(
                              fontSize: isSelected ? 28 : 20,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(
                                      isSelected ? 1.0 : 0.5,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Confirm button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _weight = selectedWeight.fromDisplayUnit(unit);
                        });
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(AppLocalizations.of(context).confirm),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRepsPicker(BuildContext context) {
    int selectedReps = _targetReps;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context).selectTargetReps,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$selectedReps ${AppLocalizations.of(context).reps}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [5, 8, 10, 12, 15].map((reps) {
                          return FilterChip(
                            label: Text('$reps'),
                            selected: selectedReps == reps,
                            onSelected: (_) {
                              setModalState(() => selectedReps = reps);
                              HapticFeedback.selectionClick();
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: FixedExtentScrollController(
                      initialItem: selectedReps - 1,
                    ),
                    itemExtent: 50,
                    physics: const FixedExtentScrollPhysics(),
                    diameterRatio: 1.5,
                    onSelectedItemChanged: (index) {
                      setModalState(() => selectedReps = index + 1);
                      HapticFeedback.selectionClick();
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 30,
                      builder: (context, index) {
                        final reps = index + 1;
                        final isSelected = reps == selectedReps;
                        return Center(
                          child: Text(
                            reps.toString(),
                            style: TextStyle(
                              fontSize: isSelected ? 28 : 20,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setState(() => _targetReps = selectedReps);
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(AppLocalizations.of(context).confirm),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final unit = ref.watch(measurementUnitProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            _buildInfoCard(theme, l10n),
            const SizedBox(height: 20),

            // Exercise selection
            _buildExerciseSection(theme, l10n),
            const SizedBox(height: 20),

            // Configuration section
            if (_selectedExercise != null) ...[
              _buildConfigurationSection(theme, l10n, unit),
              const SizedBox(height: 20),

              // Create button
              _buildCreateButton(theme, l10n),
            ],
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
            theme.colorScheme.tertiaryContainer.withOpacity(0.8),
            theme.colorScheme.primaryContainer.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.tertiary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timer,
              color: theme.colorScheme.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.restPauseTraining,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.restPauseDescription,
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
          l10n.selectedExercise,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        if (_selectedExercise != null)
          Card(
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
              ),
              title: Text(
                _selectedExercise!.nome,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text('${_selectedExercise!.focus} • ${_selectedExercise!.attrezzatura}'),
              trailing: IconButton(
                onPressed: () {
                  setState(() => _selectedExercise = null);
                  HapticFeedback.lightImpact();
                },
                icon: Icon(Icons.close, color: theme.colorScheme.tertiary),
              ),
            ),
          )
        else
          Card(
            child: InkWell(
              onTap: _openExerciseSelection,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: theme.colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.addExercise,
                      style: TextStyle(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConfigurationSection(ThemeData theme, AppLocalizations l10n, String unit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.restPauseConfiguration,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Weight button
            _buildPickerButton(
              context: context,
              label: l10n.weight,
              value: _weight > 0
                  ? _weight.formatWeight(unit)
                  : l10n.selectWeight,
              icon: Icons.fitness_center,
              onTap: () => _showWeightPicker(context),
              theme: theme,
            ),

            const SizedBox(height: 12),

            // Target reps button
            _buildPickerButton(
              context: context,
              label: l10n.targetReps,
              value: '$_targetReps ${l10n.reps}',
              icon: Icons.repeat,
              onTap: () => _showRepsPicker(context),
              theme: theme,
            ),

            const SizedBox(height: 16),

            // Mini-sets slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.miniSets,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '$_miniSets ${l10n.miniSets}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _miniSets.toDouble(),
                  min: 2,
                  max: 4,
                  divisions: 2,
                  activeColor: theme.colorScheme.tertiary,
                  onChanged: (value) {
                    setState(() => _miniSets = value.toInt());
                    HapticFeedback.selectionClick();
                  },
                ),
              ],
            ),

            // Pause duration slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.pauseDuration,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${_pauseDuration}s',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _pauseDuration.toDouble(),
                  min: 10,
                  max: 30,
                  divisions: 20,
                  activeColor: theme.colorScheme.tertiary,
                  label: '${_pauseDuration}s',
                  onChanged: (value) {
                    setState(() => _pauseDuration = value.toInt());
                    HapticFeedback.selectionClick();
                  },
                ),
              ],
            ),

            // Info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.restPauseInstructions,
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(ThemeData theme, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _createRestPause,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.tertiary,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: const Icon(Icons.add_circle),
        label: Text(l10n.createRestPause),
      ),
    );
  }
}
