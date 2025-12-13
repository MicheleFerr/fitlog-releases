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
      backgroundColor: Colors.transparent,
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
        dividerColor: Colors.transparent,
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
        dividerColor: Colors.transparent,
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

          // Exercise search and selection for DropSet
          _buildExerciseSearchSection(onExerciseSelected: _onDropSetExerciseSelected),
          const SizedBox(height: 20),

          // Show selected exercise
          if (_selectedDropSetExercise != null)
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
          if (_selectedDropSetExercise != null) const SizedBox(height: 20),

          // Exercise name
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: context.l10n.exerciseNameLabel,
              hintText: context.l10n.exerciseNameHintBicepCurl,
              prefixIcon: const Icon(AppIcons.trendDown),
            ),
          ),
          const SizedBox(height: 20),

          // Drop Set Stages - Only show when exercise is selected
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: _selectedDropSetExercise != null
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

                      _buildDropSetStage(context.l10n.stageHeavy, 0),
                      const SizedBox(height: 8),
                      _buildDropSetStage(context.l10n.stageMedium, 1),
                      const SizedBox(height: 8),
                      _buildDropSetStage(context.l10n.stageLight, 2),
                      const SizedBox(height: 16),

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
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          
          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.l10n.notesOptional,
              hintText: context.l10n.notesHintWeightDrops,
              prefixIcon: const Icon(AppIcons.note),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestPauseTab() {
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

          // Exercise search and selection for Rest-Pause
          _buildExerciseSearchSection(onExerciseSelected: _onRestPauseExerciseSelected),
          const SizedBox(height: 20),

          // Show selected exercise
          if (_selectedRestPauseExercise != null)
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
          if (_selectedRestPauseExercise != null) const SizedBox(height: 20),

          // Exercise name
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: context.l10n.exerciseNameLabel,
              hintText: context.l10n.exerciseNameHintBenchPress,
              prefixIcon: const Icon(AppIcons.pauseCircle),
            ),
          ),
          const SizedBox(height: 16),
          
          // Category selection
          _buildCategorySelector(),
          const SizedBox(height: 20),
          
          // Target configuration
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

          // Rest periods
          Text(
            context.l10n.restPauseConfiguration,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _restPauseRestSecondsController,
            decoration: InputDecoration(
              labelText: context.l10n.restPeriodSecondsLabel,
              hintText: context.l10n.restPeriodSecondsHint,
              prefixIcon: const Icon(AppIcons.timer),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _restPauseMaxSetsController,
            decoration: InputDecoration(
              labelText: context.l10n.maxRestPauseSetsLabel,
              hintText: context.l10n.maxRestPauseSetsHint,
              prefixIcon: const Icon(AppIcons.repeat),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.l10n.notesOptional,
              hintText: context.l10n.notesHintFormCues,
              prefixIcon: const Icon(AppIcons.note),
            ),
          ),
        ],
      ),
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
            dividerColor: Colors.transparent,
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

  Widget _buildSupersetExerciseCard(String title, int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: context.l10n.exerciseNameLabel,
                hintText: 'e.g., Push-ups',
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: context.l10n.weightKgLabel,
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('×'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: context.l10n.repsHintLabel,
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

  bool _canAddExercise() {
    return _nameController.text.trim().isNotEmpty;
  }

  void _addExercise() {
    if (!_canAddExercise()) return;

    // Only handle single exercises (tab index 0)
    if (_tabController.index != 0) {
      // Advanced tab - handled by respective widgets
      return;
    }

    final selectedCategory = ref.read(selectedExerciseCategoryProvider);
    final sets = ref.read(exerciseSetsProvider);

    final exercise = Exercise(
      name: _nameController.text.trim(),
      type: ExerciseType.single, // Always single for the first tab
      category: selectedCategory,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      sets: sets,
    );

    // Se c'è un callback, lo usa invece di aggiungere al workout corrente
    if (widget.onExerciseAdded != null) {
      widget.onExerciseAdded!(exercise);
    } else {
      ref.read(currentWorkoutProvider.notifier).addExercise(exercise);
    }

    // Reset the sets for next exercise
    ref.read(exerciseSetsProvider.notifier).reset();

    Navigator.pop(context);

    SnackBarService.showSuccess(
      context,
      '✅ ${context.l10n.exerciseAddedToWorkout(exercise.name)}',
    );
  }

  bool _shouldShowAddButton() {
    // Show for Single tab
    if (_tabController.index == 0) {
      return true;
    }

    // Show for Advanced tab, but not for Superset (it has its own button)
    if (_tabController.index == 1) {
      return _advancedTabController.index != 0; // 0 = Superset tab
    }

    return false;
  }

  bool _canAddAdvancedExercise() {
    if (_tabController.index == 0) {
      // Single tab
      return _canAddExercise();
    }

    // Advanced tabs
    if (_tabController.index == 1) {
      switch (_advancedTabController.index) {
        case 0: // Superset - handled by SupersetBuilderWidget
          return false;
        case 1: // DropSet
          return _nameController.text.trim().isNotEmpty;
        case 2: // Rest-Pause
          return _nameController.text.trim().isNotEmpty &&
                 _restPauseWeightController.text.trim().isNotEmpty &&
                 _restPauseTargetRepsController.text.trim().isNotEmpty;
        default:
          return false;
      }
    }

    return false;
  }

  void _addAdvancedExercise() {
    if (_tabController.index == 0) {
      // Single tab
      _addExercise();
      return;
    }

    // Advanced tabs
    if (_tabController.index == 1) {
      switch (_advancedTabController.index) {
        case 0: // Superset - handled by SupersetBuilderWidget
          break;
        case 1: // DropSet
          _createDropSet();
          break;
        case 2: // Rest-Pause
          _createRestPause();
          break;
      }
    }
  }

  void _onDropSetExerciseSelected(ExerciseDB.Exercise exercise) {
    setState(() {
      _selectedDropSetExercise = exercise;
      _nameController.text = '${exercise.nome} - Drop Set';

      // Map exercise focus to category
      final category = _mapExerciseFocusToCategory(exercise.focus.isNotEmpty ? exercise.focus.first : '');
      ref.read(selectedExerciseCategoryProvider.notifier).state = category;
    });
  }

  void _onRestPauseExerciseSelected(ExerciseDB.Exercise exercise) {
    setState(() {
      _selectedRestPauseExercise = exercise;
      _nameController.text = '${exercise.nome} - Rest-Pause';

      // Map exercise focus to category
      final category = _mapExerciseFocusToCategory(exercise.focus.isNotEmpty ? exercise.focus.first : '');
      ref.read(selectedExerciseCategoryProvider.notifier).state = category;
    });
  }

  ExerciseCategory _mapExerciseFocusToCategory(String focus) {
    final focusLower = focus.toLowerCase();

    // Chest
    if (focusLower.contains('chest') || focusLower.contains('petto') || focusLower.contains('pett')) {
      return ExerciseCategory.chest;
    }

    // Back
    if (focusLower.contains('back') || focusLower.contains('dorso') ||
        focusLower.contains('schiena') || focusLower.contains('lats') ||
        focusLower.contains('dors')) {
      return ExerciseCategory.back;
    }

    // Shoulders
    if (focusLower.contains('shoulder') || focusLower.contains('spalle') ||
        focusLower.contains('delt') || focusLower.contains('spal')) {
      return ExerciseCategory.shoulders;
    }

    // Arms
    if (focusLower.contains('arm') || focusLower.contains('bracci') ||
        focusLower.contains('bicep') || focusLower.contains('tricep') ||
        focusLower.contains('avambracci')) {
      return ExerciseCategory.arms;
    }

    // Legs
    if (focusLower.contains('leg') || focusLower.contains('gambe') ||
        focusLower.contains('quad') || focusLower.contains('hamstring') ||
        focusLower.contains('glut') || focusLower.contains('polp') ||
        focusLower.contains('addut') || focusLower.contains('abdut')) {
      return ExerciseCategory.legs;
    }

    // Abs/Core
    if (focusLower.contains('abs') || focusLower.contains('core') ||
        focusLower.contains('addominali') || focusLower.contains('addome')) {
      return ExerciseCategory.abs;
    }

    // Cardio
    if (focusLower.contains('cardio')) {
      return ExerciseCategory.cardio;
    }

    return ExerciseCategory.other;
  }

  /// Validate weight input (0.1kg - 999.9kg)
  double? _validateWeight(String value) {
    final weight = double.tryParse(value.trim());
    if (weight == null || weight <= 0 || weight > 999.9) {
      return null;
    }
    return weight;
  }

  /// Validate reps input (1-999)
  int? _validateReps(String value) {
    final reps = int.tryParse(value.trim());
    if (reps == null || reps < 1 || reps > 999) {
      return null;
    }
    return reps;
  }

  /// Validate rest seconds (1-600 seconds = 10 minutes max)
  int? _validateRestSeconds(String value) {
    final seconds = int.tryParse(value.trim());
    if (seconds == null || seconds < 1 || seconds > 600) {
      return null;
    }
    return seconds;
  }

  /// Validate max sets (1-20)
  int? _validateMaxSets(String value) {
    final maxSets = int.tryParse(value.trim());
    if (maxSets == null || maxSets < 1 || maxSets > 20) {
      return null;
    }
    return maxSets;
  }

  void _createDropSet() {
    final selectedCategory = ref.read(selectedExerciseCategoryProvider);

    // Validate and parse stages from controllers
    final stages = <DropSetStage>[];
    for (var stageData in _dropsetStages) {
      final weight = _validateWeight(stageData.weightController.text);
      final reps = _validateReps(stageData.repsController.text);

      if (weight == null || reps == null) {
        // Show error for invalid input
        SnackBarService.showError(
          context,
          'Invalid input, please check the values',
        );
        return;
      }

      stages.add(DropSetStage(weight: weight, reps: reps));
    }

    final exercise = DropSetExercise(
      name: _nameController.text.trim(),
      category: selectedCategory,
      stages: stages,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    // Add to workout or use callback
    if (widget.onExerciseAdded != null) {
      widget.onExerciseAdded!(exercise);
    } else {
      ref.read(currentWorkoutProvider.notifier).addExercise(exercise);
    }

    Navigator.pop(context);

    SnackBarService.showSuccess(
      context,
      '✅ ${context.l10n.exerciseAddedDropSet(exercise.name)}',
    );
  }

  void _createRestPause() {
    final selectedCategory = ref.read(selectedExerciseCategoryProvider);

    // Validate all inputs
    final weight = _validateWeight(_restPauseWeightController.text);
    final targetReps = _validateReps(_restPauseTargetRepsController.text);
    final restSeconds = _validateRestSeconds(_restPauseRestSecondsController.text);
    final maxSets = _validateMaxSets(_restPauseMaxSetsController.text);

    // Check if any validation failed
    if (weight == null || targetReps == null || restSeconds == null || maxSets == null) {
      // Show error for invalid input
      SnackBarService.showError(
        context,
        'Invalid input, please check the values',
      );
      return;
    }

    // Create default rest-pause sets (user will complete them during workout)
    final restPauseSets = List.generate(
      maxSets,
      (index) => RestPauseSet(
        reps: 0, // Will be filled during workout
        restSeconds: restSeconds,
      ),
    );

    final exercise = RestPauseExercise(
      name: _nameController.text.trim(),
      category: selectedCategory,
      weight: weight,
      targetReps: targetReps,
      restPauseSets: restPauseSets,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    // Add to workout or use callback
    if (widget.onExerciseAdded != null) {
      widget.onExerciseAdded!(exercise);
    } else {
      ref.read(currentWorkoutProvider.notifier).addExercise(exercise);
    }

    Navigator.pop(context);

    SnackBarService.showSuccess(
      context,
      '✅ ${context.l10n.exerciseAddedRestPause(exercise.name)}',
    );
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
