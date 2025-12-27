import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_configuration.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_converter.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/add_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart' as ExerciseDB;
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_builder_widget.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/dropset_weight_picker_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';

class AddExerciseModal extends ConsumerStatefulWidget {

  const AddExerciseModal({
    super.key,
    this.onExerciseAdded,
  });
  final Function(Exercise)? onExerciseAdded;

  /// ✅ UX: Show modal with proper sizing (80% initial, expandable to ~95%)
  /// This is the recommended way to show the AddExerciseModal
  static Future<void> show(
    BuildContext context, {
    Function(Exercise)? onExerciseAdded,
  }) {
    // ✅ FIX: Calculate safe max size to avoid notch/Dynamic Island
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).viewPadding.top;
    // Leave at least topPadding + 8px clearance from notch
    final maxSize = (screenHeight - topPadding - 8) / screenHeight;
    final safeMaxSize = maxSize.clamp(0.85, 0.96);

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.80,        // 80% initial
        minChildSize: 0.50,            // Min 50%
        maxChildSize: safeMaxSize,     // Max safe (avoids notch)
        expand: false,
        snap: true,
        snapSizes: [0.80, safeMaxSize], // Snap to 80% or max safe
        builder: (context, scrollController) => AddExerciseModal(
          onExerciseAdded: onExerciseAdded,
        ),
      ),
    );
  }

  @override
  ConsumerState<AddExerciseModal> createState() => _AddExerciseModalState();
}

class _AddExerciseModalState extends ConsumerState<AddExerciseModal> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _advancedTabController;
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();

  // ✅ UX Enhancement: Toggle compaction states
  bool _isMainToggleCompacted = false;
  bool _isAdvancedToggleCompacted = false;

  // DropSet state
  final List<DropSetStageData> _dropsetStages = [
    DropSetStageData(weightController: TextEditingController(text: '100'), repsController: TextEditingController(text: '8')),
    DropSetStageData(weightController: TextEditingController(text: '80'), repsController: TextEditingController(text: '10')),
    DropSetStageData(weightController: TextEditingController(text: '60'), repsController: TextEditingController(text: '12')),
  ];

  // Rest-Pause state
  final _restPauseWeightController = TextEditingController();
  final _restPauseTargetRepsController = TextEditingController();
  final _restPauseRestSecondsController = TextEditingController(text: '15');
  final _restPauseMaxSetsController = TextEditingController(text: '3');

  // Selected exercise from database (for DropSet/Rest-Pause)
  ExerciseDB.Exercise? _selectedDropSetExercise;
  ExerciseDB.Exercise? _selectedRestPauseExercise;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Simplified to 2 tabs
    _advancedTabController = TabController(length: 3, vsync: this); // 3 advanced tabs

    // ✅ UX: Auto-compact main toggle after 600ms
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && !_isMainToggleCompacted) {
        setState(() => _isMainToggleCompacted = true);
      }
    });

    // Add listeners to update UI when tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // Rebuild to show/hide Add button

        // ✅ UX: Compact main toggle when switching to Advanced
        if (_tabController.index == 1 && !_isMainToggleCompacted) {
          setState(() => _isMainToggleCompacted = true);
        }
      }
    });

    _advancedTabController.addListener(() {
      if (_advancedTabController.indexIsChanging) {
        setState(() {}); // Rebuild to show/hide Add button for advanced tabs

        // ✅ UX: Compact advanced toggle when navigating within tabs
        if (!_isAdvancedToggleCompacted) {
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) {
              setState(() => _isAdvancedToggleCompacted = true);
            }
          });
        }
      }
    });

    // ✅ FIX: Rebuild UI when exercise name changes to show/hide stages
    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _advancedTabController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _searchController.dispose();

    // Dispose DropSet controllers
    for (var stage in _dropsetStages) {
      stage.weightController.dispose();
      stage.repsController.dispose();
    }

    // Dispose Rest-Pause controllers
    _restPauseWeightController.dispose();
    _restPauseTargetRepsController.dispose();
    _restPauseRestSecondsController.dispose();
    _restPauseMaxSetsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ✅ UX: Drag handle for dismissal (replaces X button)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          // ✅ UX: Simplified header - title only (removed X and Aggiungi)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Text(
              context.l10n.addExerciseTitle,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // ✅ UX: Compactable Exercise Type Toggle (Singolo / Avanzati)
          _buildCompactableMainToggle(),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSingleExerciseTab(),
                _buildAdvancedTab(), // New tab for advanced options
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ UX: Main toggle (Singolo / Avanzati) with smooth compaction animation
  Widget _buildCompactableMainToggle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(
        horizontal: _isMainToggleCompacted ? 32 : 16,
        vertical: _isMainToggleCompacted ? 4 : 8,
      ),
      height: _isMainToggleCompacted ? 36 : 48,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(_isMainToggleCompacted ? 18 : 12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(_isMainToggleCompacted ? 16 : 8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: context.colors.surface.withValues(alpha: 0),
        labelColor: context.colors.onPrimary,
        unselectedLabelColor: context.colors.onSurfaceVariant,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: _isMainToggleCompacted ? 11 : 12,
        ),
        labelPadding: EdgeInsets.zero,
        tabs: [
          Tab(text: context.l10n.tabSingle),
          Tab(text: context.l10n.tabAdvanced),
        ],
      ),
    );
  }

  Widget _buildSingleExerciseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise search and selection with custom exercise form
          _buildExerciseSearchSection(),
        ],
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return Column(
      children: [
        const SizedBox(height: 8),
        // ✅ UX: Compactable sub-tabs for advanced exercises
        _buildCompactableAdvancedToggle(),
        Expanded(
          child: TabBarView(
            controller: _advancedTabController,
            children: [
              _buildSupersetTab(),
              _buildDropSetTab(),
              _buildRestPauseTab(),
            ],
          ),
        ),
      ],
    );
  }

  /// ✅ UX: Advanced toggle (Superset / DropSet / RestPause) with smooth compaction
  Widget _buildCompactableAdvancedToggle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(
        horizontal: _isAdvancedToggleCompacted ? 24 : 16,
        vertical: _isAdvancedToggleCompacted ? 4 : 8,
      ),
      height: _isAdvancedToggleCompacted ? 32 : 44,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(_isAdvancedToggleCompacted ? 16 : 12),
      ),
      child: TabBar(
        controller: _advancedTabController,
        indicator: BoxDecoration(
          color: context.colors.secondary,
          borderRadius: BorderRadius.circular(_isAdvancedToggleCompacted ? 14 : 8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: context.colors.surface.withValues(alpha: 0),
        labelColor: context.colors.onSecondary,
        unselectedLabelColor: context.colors.onSurfaceVariant,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: _isAdvancedToggleCompacted ? 10 : 11,
        ),
        labelPadding: EdgeInsets.zero,
        tabs: [
          Tab(text: context.l10n.tabSuperset),
          Tab(text: context.l10n.tabDropSet),
          Tab(text: context.l10n.tabRestPause),
        ],
      ),
    );
  }

  Widget _buildSupersetTab() {
    return SupersetBuilderWidget(
      onSupersetCreated: _createSupersetFromConfiguration,
    );
  }

  void _createSupersetFromConfiguration(SupersetConfiguration config) {
    // Convert SupersetConfiguration to SupersetExercise
    final supersetExercise = SupersetConverter.configurationToSupersetExercise(config);

    // Add the superset to the workout
    if (widget.onExerciseAdded != null) {
      widget.onExerciseAdded!(supersetExercise);
    } else {
      ref.read(currentWorkoutProvider.notifier).addExercise(supersetExercise);
    }

    // Close the modal
    Navigator.of(context).pop();

    // Show success message
    SnackBarService.showSuccess(
      context,
      '✅ ${context.l10n.exerciseAddedToWorkout(supersetExercise.name)}',
    );
  }

  Widget _buildDropSetTab() {
    final hasExercise = _selectedDropSetExercise != null || _nameController.text.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Card(
            color: context.colors.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    AppIcons.info,
                    color: context.colors.onTertiaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.dropSetInfoCard,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════════
          // SECTION 1: Exercise Selection from Database (Primary)
          // ═══════════════════════════════════════════════════════════════
          _buildAdvancedExerciseSearchButton(
            onExerciseSelected: _onDropSetExerciseSelected,
          ),

          // Show selected exercise
          if (_selectedDropSetExercise != null) ...[
            const SizedBox(height: 12),
            Card(
              color: context.colors.primaryContainer.withValues(alpha: 0.3),
              child: ListTile(
                leading: Icon(AppIcons.checkCircle, color: context.colors.primary),
                title: Text(_selectedDropSetExercise!.nome),
                subtitle: Text('Focus: ${_selectedDropSetExercise!.focus.join(", ")}'),
                trailing: IconButton(
                  icon: const Icon(AppIcons.close),
                  onPressed: () {
                    setState(() {
                      _selectedDropSetExercise = null;
                      _nameController.clear();
                    });
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════════
          // SECTION 2: DropSet Configuration (show when exercise selected)
          // ═══════════════════════════════════════════════════════════════
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: hasExercise
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.dropSetStagesTitle,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Dynamically render ALL stages
                      ..._dropsetStages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final stageLabel = index == 0
                            ? context.l10n.stageHeavy
                            : index == 1
                                ? context.l10n.stageMedium
                                : index == 2
                                    ? context.l10n.stageLight
                                    : '${context.l10n.dropsetStage(index + 1)}';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildDropSetStage(stageLabel, index),
                        );
                      }),
                      const SizedBox(height: 8),

                      // Add stage button
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            final lastStage = _dropsetStages.last;
                            final lastWeight = double.tryParse(lastStage.weightController.text) ?? 60;
                            final lastReps = int.tryParse(lastStage.repsController.text) ?? 12;

                            _dropsetStages.add(
                              DropSetStageData(
                                weightController: TextEditingController(text: (lastWeight * 0.8).toStringAsFixed(0)),
                                repsController: TextEditingController(text: '${lastReps + 2}'),
                              ),
                            );
                          });
                        },
                        icon: const Icon(AppIcons.add),
                        label: Text(context.l10n.addStageButton),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: context.l10n.notesOptional,
                          hintText: context.l10n.notesHintWeightDrops,
                          prefixIcon: const Icon(AppIcons.note),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Add to workout button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _canCreateDropSet() ? _createDropSetExercise : null,
                          icon: const Icon(AppIcons.add),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(context.l10n.createDropset),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // ═══════════════════════════════════════════════════════════════
          // SECTION 3: Custom Exercise (at bottom, separate section)
          // ═══════════════════════════════════════════════════════════════
          if (_selectedDropSetExercise == null) ...[
            const SizedBox(height: 24),
            _buildCustomExerciseSection(
              icon: AppIcons.trendDown,
              hintText: context.l10n.exerciseNameHintBicepCurl,
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool _canCreateDropSet() {
    // Must have an exercise selected OR a name entered
    final hasExercise = _selectedDropSetExercise != null || _nameController.text.trim().isNotEmpty;
    if (!hasExercise) return false;

    // Must have at least 2 stages with valid weights
    int validStages = 0;
    for (final stage in _dropsetStages) {
      final weight = double.tryParse(stage.weightController.text);
      if (weight != null && weight > 0) {
        validStages++;
      }
    }
    return validStages >= 2;
  }

  void _createDropSetExercise() {
    // Build stages from UI state
    final stages = <DropSetStage>[];
    for (final stageData in _dropsetStages) {
      final weight = double.tryParse(stageData.weightController.text);
      final reps = int.tryParse(stageData.repsController.text) ?? 8;
      if (weight != null && weight > 0) {
        stages.add(DropSetStage(
          weight: weight,
          reps: reps,
          isCompleted: false,
        ));
      }
    }

    if (stages.length < 2) {
      SnackBarService.showError(context, context.l10n.dropsetNeedsMinStages);
      return;
    }

    // Get exercise name
    final exerciseName = _selectedDropSetExercise?.nome ??
        _nameController.text.trim();

    if (exerciseName.isEmpty) {
      SnackBarService.showError(context, context.l10n.exerciseNameRequired);
      return;
    }

    // Get category from exercise focus or selected category
    final selectedCategory = ref.read(selectedExerciseCategoryProvider);
    final category = _selectedDropSetExercise != null
        ? MuscleAbbreviationMapper.focusListToExerciseCategory(_selectedDropSetExercise!.focus)
        : selectedCategory;

    // Create the DropSetExercise
    final dropsetExercise = DropSetExercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: exerciseName,
      category: category,
      stages: stages,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    // Add to workout
    if (widget.onExerciseAdded != null) {
      widget.onExerciseAdded!(dropsetExercise);
    } else {
      ref.read(currentWorkoutProvider.notifier).addExercise(dropsetExercise);
    }

    // Close modal
    Navigator.of(context).pop();

    // Show success message
    SnackBarService.showSuccess(
      context,
      context.l10n.dropsetAddedMessage(exerciseName),
    );
  }

  Widget _buildRestPauseTab() {
    final hasExercise = _selectedRestPauseExercise != null || _nameController.text.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Card(
            color: context.colors.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    AppIcons.info,
                    color: context.colors.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.restPauseInfoCard,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════════
          // SECTION 1: Exercise Selection from Database (Primary)
          // ═══════════════════════════════════════════════════════════════
          _buildAdvancedExerciseSearchButton(
            onExerciseSelected: _onRestPauseExerciseSelected,
          ),

          // Show selected exercise
          if (_selectedRestPauseExercise != null) ...[
            const SizedBox(height: 12),
            Card(
              color: context.colors.primaryContainer.withValues(alpha: 0.3),
              child: ListTile(
                leading: Icon(AppIcons.checkCircle, color: context.colors.primary),
                title: Text(_selectedRestPauseExercise!.nome),
                subtitle: Text('Focus: ${_selectedRestPauseExercise!.focus.join(", ")}'),
                trailing: IconButton(
                  icon: const Icon(AppIcons.close),
                  onPressed: () {
                    setState(() {
                      _selectedRestPauseExercise = null;
                      _nameController.clear();
                    });
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════════
          // SECTION 2: Rest-Pause Configuration (show when exercise selected)
          // ═══════════════════════════════════════════════════════════════
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: hasExercise
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.restPauseConfiguration,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Weight and Target Reps
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _restPauseWeightController,
                              decoration: InputDecoration(
                                labelText: context.l10n.weightKgLabel,
                                prefixIcon: const Icon(AppIcons.workout),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _restPauseTargetRepsController,
                              decoration: InputDecoration(
                                labelText: context.l10n.targetRepsLabel,
                                prefixIcon: const Icon(AppIcons.repeat),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Rest period and max sets
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _restPauseRestSecondsController,
                              decoration: InputDecoration(
                                labelText: context.l10n.restPeriodSecondsLabel,
                                hintText: '15',
                                prefixIcon: const Icon(AppIcons.timer),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _restPauseMaxSetsController,
                              decoration: InputDecoration(
                                labelText: context.l10n.maxRestPauseSetsLabel,
                                hintText: '3-5',
                                prefixIcon: const Icon(AppIcons.repeat),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: context.l10n.notesOptional,
                          hintText: context.l10n.notesHintFormCues,
                          prefixIcon: const Icon(AppIcons.note),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Add to workout button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _canCreateRestPause() ? _createRestPauseExercise : null,
                          icon: const Icon(AppIcons.add),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(context.l10n.createRestPause),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // ═══════════════════════════════════════════════════════════════
          // SECTION 3: Custom Exercise (at bottom, separate section)
          // ═══════════════════════════════════════════════════════════════
          if (_selectedRestPauseExercise == null) ...[
            const SizedBox(height: 24),
            _buildCustomExerciseSection(
              icon: AppIcons.pauseCircle,
              hintText: context.l10n.exerciseNameHintBenchPress,
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool _canCreateRestPause() {
    // Must have an exercise selected OR a name entered
    final hasExercise = _selectedRestPauseExercise != null || _nameController.text.trim().isNotEmpty;
    if (!hasExercise) return false;

    // Must have valid weight and target reps
    final weight = double.tryParse(_restPauseWeightController.text.trim());
    final targetReps = int.tryParse(_restPauseTargetRepsController.text.trim());

    return weight != null && weight > 0 && targetReps != null && targetReps > 0;
  }

  void _createRestPauseExercise() {
    final weight = double.tryParse(_restPauseWeightController.text.trim());
    final targetReps = int.tryParse(_restPauseTargetRepsController.text.trim());
    final restSeconds = int.tryParse(_restPauseRestSecondsController.text.trim()) ?? 15;

    if (weight == null || targetReps == null) {
      SnackBarService.showError(context, context.l10n.weightAndRepsRequired);
      return;
    }

    // Get exercise name
    final exerciseName = _selectedRestPauseExercise?.nome ?? _nameController.text.trim();

    if (exerciseName.isEmpty) {
      SnackBarService.showError(context, context.l10n.exerciseNameRequired);
      return;
    }

    // Get category from exercise focus or selected category
    final selectedCategory = ref.read(selectedExerciseCategoryProvider);
    final category = _selectedRestPauseExercise != null
        ? MuscleAbbreviationMapper.focusListToExerciseCategory(_selectedRestPauseExercise!.focus)
        : selectedCategory;

    // Create the RestPauseExercise with empty sets - will be filled during execution
    final restPauseExercise = RestPauseExercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: exerciseName,
      category: category,
      weight: weight,
      targetReps: targetReps,
      restPauseSets: [], // Start with empty sets - filled during execution
      restTime: restSeconds,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    // Add to workout
    if (widget.onExerciseAdded != null) {
      widget.onExerciseAdded!(restPauseExercise);
    } else {
      ref.read(currentWorkoutProvider.notifier).addExercise(restPauseExercise);
    }

    // Close modal
    Navigator.of(context).pop();

    // Show success message
    SnackBarService.showSuccess(
      context,
      context.l10n.restPauseAddedMessage(exerciseName),
    );
  }

  Widget _buildExerciseSearchSection({Function(ExerciseDB.Exercise)? onExerciseSelected}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Browse exercises from database button - Prominent
        Card(
          elevation: 2,
          child: ListTile(
            leading: Icon(
              AppIcons.libraryBooks,
              color: context.colors.primary,
            ),
            title: Text(
              context.l10n.browseExerciseDatabase,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(context.l10n.chooseFromLibrary),
            trailing: Icon(
              AppIcons.arrowForwardIos,
              size: 16,
              color: context.colors.primary,
            ),
            onTap: () async {
              if (kDebugMode) {
                debugPrint('🔍 ADD_EXERCISE_MODAL: Opening ExerciseSearchScreen with callback: ${widget.onExerciseAdded != null}');
              }

              // If we have a custom callback, open search in selection mode
              if (onExerciseSelected != null) {
                final selectedExercise = await Navigator.of(context).push<ExerciseDB.Exercise>(
                  MaterialPageRoute(
                    builder: (context) => const ExerciseSearchScreen(
                      selectionMode: true,
                    ),
                  ),
                );

                if (selectedExercise != null) {
                  onExerciseSelected(selectedExercise);
                }
              } else {
                // Original behavior for single exercise tab
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExerciseSearchScreen(
                      onExerciseAdded: widget.onExerciseAdded,
                    ),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 16),

        // Expandable section for custom exercise - Hidden by default
        Theme(
          data: context.theme.copyWith(
            dividerColor: context.colors.surface.withValues(alpha: 0),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(
              AppIcons.addCircleOutline,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            title: Text(
              'Non trovi l\'esercizio? Creane uno personalizzato',
              style: TextStyle(
                fontSize: 14,
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.customExerciseDetails,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    // Exercise name
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: context.l10n.exerciseNameLabel,
                        hintText: context.l10n.exerciseNameHint,
                        prefixIcon: const Icon(AppIcons.workout),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category selection
                    _buildCategorySelector(),
                    const SizedBox(height: 20),

                    // Sets configuration
                    _buildSetsSection(ref),
                    const SizedBox(height: 16),

                    // Notes
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: context.l10n.notesOptional,
                        hintText: context.l10n.notesHint,
                        prefixIcon: const Icon(AppIcons.note),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Simplified exercise search for advanced tabs (DropSet/RestPause)
  /// Shows only the database browse button - custom exercise is handled separately at bottom
  Widget _buildAdvancedExerciseSearchButton({
    required Function(ExerciseDB.Exercise) onExerciseSelected,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(
          AppIcons.libraryBooks,
          color: context.colors.primary,
        ),
        title: Text(
          context.l10n.browseExerciseDatabase,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(context.l10n.chooseFromLibrary),
        trailing: Icon(
          AppIcons.arrowForwardIos,
          size: 16,
          color: context.colors.primary,
        ),
        onTap: () async {
          final selectedExercise = await Navigator.of(context).push<ExerciseDB.Exercise>(
            MaterialPageRoute(
              builder: (context) => const ExerciseSearchScreen(
                selectionMode: true,
              ),
            ),
          );

          if (selectedExercise != null) {
            onExerciseSelected(selectedExercise);
          }
        },
      ),
    );
  }

  /// Custom exercise section for advanced tabs - shown at bottom
  Widget _buildCustomExerciseSection({
    required IconData icon,
    required String hintText,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.addCircleOutline,
                size: 20,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.cantFindExercise,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: context.l10n.exerciseNameLabel,
              hintText: hintText,
              prefixIcon: Icon(icon),
              filled: true,
              fillColor: context.colors.surface,
            ),
          ),
          const SizedBox(height: 12),
          _buildCategorySelector(),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final selectedCategory = ref.watch(selectedExerciseCategoryProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.exerciseCategoryLabel,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ExerciseCategory.values.map((category) {
            final isSelected = category == selectedCategory;
            return FilterChip(
              label: Text(_getCategoryDisplayName(category)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedExerciseCategoryProvider.notifier).state = category;
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSetsSection(WidgetRef ref) {
    final sets = ref.watch(exerciseSetsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.setsLabel,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                ref.read(exerciseSetsProvider.notifier).addSet();
              },
              icon: const Icon(AppIcons.add, size: 18),
              label: Text(context.l10n.addSetLabel),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Dynamic sets
        ...sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildSetRow(set, ref),
          );
        }),
      ],
    );
  }

  Widget _buildSetRow(ExerciseSet set, WidgetRef ref) {
    final sets = ref.watch(exerciseSetsProvider);
    
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${set.setNumber}',
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            initialValue: set.weight?.toString() ?? '0',
            decoration: InputDecoration(
              hintText: context.l10n.weightHintKg,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final weight = double.tryParse(value) ?? 0;
              final updatedSet = set.copyWith(weight: weight);
              ref.read(exerciseSetsProvider.notifier).updateSet(set.id, updatedSet);
            },
          ),
        ),
        const SizedBox(width: 8),
        const Text('×'),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: set.reps?.toString() ?? '10',
            decoration: InputDecoration(
              hintText: context.l10n.repsHintLabel,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final reps = int.tryParse(value) ?? 10;
              final updatedSet = set.copyWith(reps: reps);
              ref.read(exerciseSetsProvider.notifier).updateSet(set.id, updatedSet);
            },
          ),
        ),
        const SizedBox(width: 8),
        if (sets.length > 1)
          IconButton(
            onPressed: () {
              ref.read(exerciseSetsProvider.notifier).removeSet(set.id);
            },
            icon: const Icon(AppIcons.removeCircleOutline, size: 20),
            tooltip: context.l10n.removeSetTooltip,
          ),
      ],
    );
  }

  Widget _buildDropSetStage(String title, int index) {
    if (index >= _dropsetStages.length) {
      return const SizedBox.shrink();
    }

    final stageData = _dropsetStages[index];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.colors.tertiaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onTertiaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _openWeightPicker(index),
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: context.l10n.weightKgLabel,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(
                    stageData.weightController.text.isEmpty
                        ? '---'
                        : '${stageData.weightController.text} kg',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: stageData.weightController.text.isEmpty
                          ? context.colors.onSurfaceVariant.withValues(alpha: 0.5)
                          : context.colors.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('×'),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: stageData.repsController,
                decoration: InputDecoration(
                  labelText: context.l10n.repsHintLabel,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            if (index > 2)
              IconButton(
                onPressed: () {
                  setState(() {
                    stageData.weightController.dispose();
                    stageData.repsController.dispose();
                    _dropsetStages.removeAt(index);
                  });
                },
                icon: const Icon(AppIcons.removeCircleOutline, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWeightPicker(int stageIndex) async {
    // Get previous stage weight if not first stage
    double? previousWeight;
    if (stageIndex > 0 && _dropsetStages[stageIndex - 1].weightController.text.isNotEmpty) {
      previousWeight = double.tryParse(_dropsetStages[stageIndex - 1].weightController.text);
    }

    // Get current weight if exists
    final currentWeightText = _dropsetStages[stageIndex].weightController.text;
    final initialWeight = currentWeightText.isNotEmpty ? double.tryParse(currentWeightText) : null;

    final selectedWeight = await DropSetWeightPickerModal.show(
      context: context,
      stageIndex: stageIndex,
      previousStageWeight: previousWeight,
      initialWeight: initialWeight,
      selectedExercise: _selectedDropSetExercise,
      exerciseName: _nameController.text.isEmpty ? null : _nameController.text,
    );

    if (selectedWeight != null && mounted) {
      setState(() {
        _dropsetStages[stageIndex].weightController.text = selectedWeight.toStringAsFixed(1);
      });
    }
  }

  String _getCategoryDisplayName(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return context.l10n.categoryChest;
      case ExerciseCategory.back:
        return context.l10n.categoryBack;
      case ExerciseCategory.shoulders:
        return context.l10n.categoryShoulders;
      case ExerciseCategory.arms:
        return context.l10n.categoryArms;
      case ExerciseCategory.legs:
        return context.l10n.categoryLegs;
      case ExerciseCategory.abs:
        return context.l10n.categoryAbs;
      case ExerciseCategory.cardio:
        return context.l10n.categoryCardio;
      case ExerciseCategory.other:
        return context.l10n.categoryOther;
    }
  }

  void _onDropSetExerciseSelected(ExerciseDB.Exercise exercise) {
    setState(() {
      _selectedDropSetExercise = exercise;
      _nameController.text = '${exercise.nome} - Drop Set';

      // Map exercise focus to category using single source of truth
      final category = MuscleAbbreviationMapper.focusListToExerciseCategory(exercise.focus);
      ref.read(selectedExerciseCategoryProvider.notifier).state = category;
    });
  }

  void _onRestPauseExerciseSelected(ExerciseDB.Exercise exercise) {
    setState(() {
      _selectedRestPauseExercise = exercise;
      _nameController.text = '${exercise.nome} - Rest-Pause';

      // Map exercise focus to category using single source of truth
      final category = MuscleAbbreviationMapper.focusListToExerciseCategory(exercise.focus);
      ref.read(selectedExerciseCategoryProvider.notifier).state = category;
    });
  }
}

// Helper class to manage DropSet stage controllers
class DropSetStageData {

  DropSetStageData({
    required this.weightController,
    required this.repsController,
  });
  final TextEditingController weightController;
  final TextEditingController repsController;
}
