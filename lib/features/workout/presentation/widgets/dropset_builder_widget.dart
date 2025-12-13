import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart' as ExerciseDB;
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/utils/weight_helper.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Builder widget for creating dropset exercises
/// Reuses UI patterns from SupersetBuilderWidget
class DropsetBuilderWidget extends ConsumerStatefulWidget {

  const DropsetBuilderWidget({
    super.key,
    required this.onDropsetCreated,
  });
  final Function(DropSetExercise) onDropsetCreated;

  @override
  ConsumerState<DropsetBuilderWidget> createState() => _DropsetBuilderWidgetState();
}

class _DropsetBuilderWidgetState extends ConsumerState<DropsetBuilderWidget>
    with TickerProviderStateMixin {

  ExerciseDB.Exercise? _selectedExercise;
  double _initialWeight = 0.0;
  int _targetReps = 8;
  int _numberOfDrops = 2; // 1-3 drops
  double _dropPercentage = 20.0; // 10-25%

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

  List<DropSetStage> _calculateDropStages() {
    final stages = <DropSetStage>[];
    double currentWeight = _initialWeight;

    // Main set (100%)
    stages.add(DropSetStage(
      weight: currentWeight,
      reps: _targetReps,
      isCompleted: false,
    ));

    // Calculate drops
    for (int i = 0; i < _numberOfDrops; i++) {
      currentWeight = currentWeight * (1 - _dropPercentage / 100);
      // Round to nearest 0.25 kg
      currentWeight = (currentWeight * 4).round() / 4;

      stages.add(DropSetStage(
        weight: currentWeight,
        reps: _targetReps,
        isCompleted: false,
      ));
    }

    return stages;
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

  void _createDropset() {
    if (_selectedExercise == null || _initialWeight <= 0) {
      SnackBarService.showError(context, AppLocalizations.of(context).pleaseSelectExerciseAndWeight);
      return;
    }

    final dropset = DropSetExercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _selectedExercise!.nome,
      category: _inferCategoryFromExercise(_selectedExercise!),
      stages: _calculateDropStages(),
      notes: null,
    );

    widget.onDropsetCreated(dropset);
    HapticFeedback.mediumImpact();
  }

  void _openExerciseSelection() async {
    final selected = await Navigator.push<ExerciseDB.Exercise>(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseSearchScreen(
          multiSelectMode: false,
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
    double selectedWeight = _initialWeight.toDisplayUnit(unit);

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
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    AppLocalizations.of(context).selectInitialWeight,
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
                    color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(AppIcons.workout, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 12),
                      Text(
                        '${WeightHelper.formatPickerWeight(selectedWeight, unit)} $unit',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
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
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.onSurface.withValues(
                                      alpha: isSelected ? 1.0 : 0.5,
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
                          _initialWeight = selectedWeight.fromDisplayUnit(unit);
                        });
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
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
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
                          color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$selectedReps ${AppLocalizations.of(context).reps}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.error,
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
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
                        backgroundColor: Theme.of(context).colorScheme.error,
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

              // Drop stages preview
              _buildDropStagesPreview(theme, l10n, unit),
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
            theme.colorScheme.errorContainer.withValues(alpha: 0.8),
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.trendDown,
              color: theme.colorScheme.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dropsetTraining,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.dropsetDescription,
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
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.workout,
                  color: theme.colorScheme.error,
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
                icon: Icon(AppIcons.close, color: theme.colorScheme.error),
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
                    Icon(AppIcons.addCircleOutline, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Text(
                      l10n.addExercise,
                      style: TextStyle(
                        color: theme.colorScheme.error,
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
              l10n.dropsetConfiguration,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Initial weight button
            _buildPickerButton(
              context: context,
              label: l10n.initialWeight,
              value: _initialWeight > 0
                  ? _initialWeight.formatWeight(unit)
                  : l10n.selectWeight,
              icon: AppIcons.workout,
              onTap: () => _showWeightPicker(context),
              theme: theme,
            ),

            const SizedBox(height: 12),

            // Target reps button
            _buildPickerButton(
              context: context,
              label: l10n.targetReps(_targetReps),
              value: '$_targetReps ${l10n.reps}',
              icon: AppIcons.repeat,
              onTap: () => _showRepsPicker(context),
              theme: theme,
            ),

            const SizedBox(height: 16),

            // Number of drops slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.numberOfDrops,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '$_numberOfDrops ${l10n.drops}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _numberOfDrops.toDouble(),
                  min: 1,
                  max: 3,
                  divisions: 2,
                  activeColor: theme.colorScheme.error,
                  onChanged: (value) {
                    setState(() => _numberOfDrops = value.toInt());
                    HapticFeedback.selectionClick();
                  },
                ),
              ],
            ),

            // Drop percentage slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.dropPercentage,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${_dropPercentage.toInt()}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _dropPercentage,
                  min: 10,
                  max: 25,
                  divisions: 15,
                  activeColor: theme.colorScheme.error,
                  label: '${_dropPercentage.toInt()}%',
                  onChanged: (value) {
                    setState(() => _dropPercentage = value);
                    HapticFeedback.selectionClick();
                  },
                ),
              ],
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
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
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
            Icon(AppIcons.arrowDropDown, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildDropStagesPreview(ThemeData theme, AppLocalizations l10n, String unit) {
    if (_initialWeight <= 0) return const SizedBox.shrink();

    final stages = _calculateDropStages();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.preview, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  l10n.dropStagesPreview,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ...stages.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              final displayWeight = stage.weight.toDisplayUnit(unit);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: index == 0
                      ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            index == 0 ? l10n.mainSet : '${l10n.drop} $index',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            // TODO: DropSetStage doesn't have percentageOfMax yet - need to calculate from weight
                            // widget.stages doesn't exist - using _initialWeight as reference
                            '${_initialWeight > 0 ? (stage.weight * 100 / _initialWeight).toInt() : 100}% ${l10n.ofMax}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${WeightHelper.formatPickerWeight(displayWeight, unit)} $unit',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '× $_targetReps',
                      style: theme.textTheme.bodyMedium,
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

  Widget _buildCreateButton(ThemeData theme, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _createDropset,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: const SemanticIcon(
  icon: AppIcons.addCircle,
  semanticLabel: 'Add circle',
),
        label: Text(l10n.createDropset),
      ),
    );
  }
}
