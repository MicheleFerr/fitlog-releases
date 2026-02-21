import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_configuration.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_converter.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/add_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    as ExerciseDB;
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_builder_widget.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/dropset_weight_picker_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/dropset_template_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/rest_pause_template_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/dropset_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/rest_pause_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

class AddExerciseModal extends ConsumerStatefulWidget {
  const AddExerciseModal({
    super.key,
    this.onExerciseAdded,
    this.initialTab = 0,
    this.initialAdvancedTab = 0,
  });
  final Function(Exercise)? onExerciseAdded;
  final int initialTab;
  final int initialAdvancedTab;

  /// ✅ UX: Show modal with proper sizing (80% initial, expandable to ~95%)
  /// This is the recommended way to show the AddExerciseModal
  static Future<void> show(
    BuildContext context, {
    Function(Exercise)? onExerciseAdded,
    int initialTab = 0,
    int initialAdvancedTab = 0,
  }) {
    // ✅ FIX: Calculate safe max size to avoid notch/Dynamic Island
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).viewPadding.top;
    // Leave at least topPadding + 8px clearance from notch
    final maxSize = (screenHeight - topPadding - 8) / screenHeight;
    final safeMaxSize = maxSize.clamp(0.85, 0.96);

    return ModalService.showSheet<void>(context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.80, // 80% initial
        minChildSize: 0.50, // Min 50%
        maxChildSize: safeMaxSize, // Max safe (avoids notch)
        expand: false,
        snap: true,
        snapSizes: [0.80, safeMaxSize], // Snap to 80% or max safe
        builder: (context, scrollController) => AddExerciseModal(
          onExerciseAdded: onExerciseAdded,
          initialTab: initialTab,
          initialAdvancedTab: initialAdvancedTab,
        ),
      ),
    );
  }

  @override
  ConsumerState<AddExerciseModal> createState() => _AddExerciseModalState();
}

class _AddExerciseModalState extends ConsumerState<AddExerciseModal>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _advancedTabController;
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();

  // ✅ UX Enhancement: Toggle compaction states
  bool _isMainToggleCompacted = false;
  bool _isAdvancedToggleCompacted = false;

  // DropSet state
  // ✅ UX: Realistic default values (not intimidating 100kg)
  // These will be updated when user selects an exercise
  final List<DropSetStageData> _dropsetStages = [
    DropSetStageData(
      weightController: TextEditingController(text: '30'),
      repsController: TextEditingController(text: '8'),
    ),
    DropSetStageData(
      weightController: TextEditingController(text: '24'),
      repsController: TextEditingController(text: '10'),
    ),
    DropSetStageData(
      weightController: TextEditingController(text: '18'),
      repsController: TextEditingController(text: '12'),
    ),
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
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab, // ✅ Use parameter for initial tab
    );
    _advancedTabController = TabController(
      length: 3,
      vsync: this,
      initialIndex:
          widget.initialAdvancedTab, // ✅ Use parameter for advanced tab
    );

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
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _advancedTabController.dispose();
    _nameController.removeListener(_onNameChanged);
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
    // ✅ FIX: Hide main toggle when deep-linking to specific tab
    final isDeepLink = widget.initialTab != 0;

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
          // ✅ FIX: Hide when deep-linking to specific tab
          if (!isDeepLink) _buildCompactableMainToggle(),

          // Content
          Expanded(
            child: isDeepLink
                // ✅ FIX: Show only selected tab when deep-linking
                ? widget.initialTab == 0
                      ? _buildSingleExerciseTab()
                      : _buildAdvancedTab()
                // Original behavior with TabBarView
                : TabBarView(
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

  /// P3: Build last weight badge for DropSet/RestPause
  /// Shows "Ultima volta: XX kg" when user has previous data for this exercise
  Widget _buildLastWeightBadge(String exerciseName) {
    return Consumer(
      builder: (context, ref, _) {
        final lastDataAsync = ref.watch(lastExerciseDataProvider(exerciseName));

        return lastDataAsync.when(
          data: (data) {
            if (data.weight == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.history,
                      size: 16,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.lastTimeWeight(data.weight!.toStringAsFixed(1)),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  /// P4: Build DropSet preview card
  /// Shows how the exercise will appear in the workout
  Widget _buildDropSetPreview() {
    final exerciseName =
        _selectedDropSetExercise?.nome ?? _nameController.text.trim();
    if (exerciseName.isEmpty) return const SizedBox.shrink();

    // Collect valid stages for preview
    final validStages = <String>[];
    for (final stage in _dropsetStages) {
      final weight = double.tryParse(stage.weightController.text);
      if (weight != null && weight > 0) {
        validStages.add('${weight.toStringAsFixed(0)}kg');
      }
    }

    if (validStages.length < 2) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                AppIcons.preview,
                size: 16,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                context.l10n.preview,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Exercise name with icon
          Row(
            children: [
              Icon(
                AppIcons.trendDown,
                size: 20,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exerciseName,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Drops badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  context.l10n.dropSetBadge(validStages.length),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Weight sequence
          Text(
            validStages.join(' → '),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// P4: Build RestPause preview card
  /// Shows how the exercise will appear in the workout
  Widget _buildRestPausePreview() {
    final exerciseName =
        _selectedRestPauseExercise?.nome ?? _nameController.text.trim();
    if (exerciseName.isEmpty) return const SizedBox.shrink();

    final weight = double.tryParse(_restPauseWeightController.text);
    final targetReps = int.tryParse(_restPauseTargetRepsController.text);
    final restSeconds = int.tryParse(_restPauseRestSecondsController.text) ?? 15;

    if (weight == null || weight <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                AppIcons.preview,
                size: 16,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                context.l10n.preview,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Exercise name with icon
          Row(
            children: [
              Icon(
                AppIcons.pauseCircle,
                size: 20,
                color: context.colors.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exerciseName,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Target reps badge
              if (targetReps != null && targetReps > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$targetReps reps',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Weight and rest info
          Row(
            children: [
              Text(
                '${weight.toStringAsFixed(1)} kg',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                AppIcons.pause,
                size: 14,
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                '${restSeconds}s',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
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
        borderRadius: BorderRadius.circular(
          _isAdvancedToggleCompacted ? 16 : 12,
        ),
      ),
      child: TabBar(
        controller: _advancedTabController,
        indicator: BoxDecoration(
          color: context.colors.secondary,
          borderRadius: BorderRadius.circular(
            _isAdvancedToggleCompacted ? 14 : 8,
          ),
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
    final supersetExercise = SupersetConverter.configurationToSupersetExercise(
      config,
    );

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
    final hasExercise =
        _selectedDropSetExercise != null ||
        _nameController.text.trim().isNotEmpty;

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
                leading: Icon(
                  AppIcons.checkCircle,
                  color: context.colors.primary,
                ),
                title: Text(_selectedDropSetExercise!.nome),
                subtitle: Text(
                  'Focus: ${_selectedDropSetExercise!.focus.join(", ")}',
                ),
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
            // P3: Last weight badge
            _buildLastWeightBadge(_selectedDropSetExercise!.nome),
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
                            : context.l10n.dropsetStage(index + 1);
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
                            final lastWeight =
                                double.tryParse(
                                  lastStage.weightController.text,
                                ) ??
                                60;
                            final lastReps =
                                int.tryParse(lastStage.repsController.text) ??
                                12;

                            _dropsetStages.add(
                              DropSetStageData(
                                weightController: TextEditingController(
                                  text: (lastWeight * 0.8).toStringAsFixed(0),
                                ),
                                repsController: TextEditingController(
                                  text: '${lastReps + 2}',
                                ),
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

                      // P4: DropSet preview card
                      _buildDropSetPreview(),

                      // Add to workout button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _canCreateDropSet()
                              ? _createDropSetExercise
                              : null,
                          icon: const Icon(AppIcons.add),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(context.l10n.createDropset),
                          ),
                        ),
                      ),
                      // P1: Save as Template button
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _canCreateDropSet()
                              ? _showSaveDropsetTemplateDialog
                              : null,
                          icon: const Icon(AppIcons.template),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(context.l10n.saveAsTemplate),
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
    final hasExercise =
        _selectedDropSetExercise != null ||
        _nameController.text.trim().isNotEmpty;
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
        stages.add(
          DropSetStage(weight: weight, reps: reps, isCompleted: false),
        );
      }
    }

    if (stages.length < 2) {
      SnackBarService.showError(context, context.l10n.dropsetNeedsMinStages);
      return;
    }

    // Get exercise name
    final exerciseName =
        _selectedDropSetExercise?.nome ?? _nameController.text.trim();

    if (exerciseName.isEmpty) {
      SnackBarService.showError(context, context.l10n.exerciseNameRequired);
      return;
    }

    // Get category from exercise focus or selected category
    final selectedCategory = ref.read(selectedExerciseCategoryProvider);
    final category = _selectedDropSetExercise != null
        ? MuscleAbbreviationMapper.focusListToExerciseCategory(
            _selectedDropSetExercise!.focus,
          )
        : selectedCategory;

    // Create the DropSetExercise
    final dropsetExercise = DropSetExercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: exerciseName,
      category: category,
      stages: stages,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
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
    final hasExercise =
        _selectedRestPauseExercise != null ||
        _nameController.text.trim().isNotEmpty;

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
                  Icon(AppIcons.info, color: context.colors.onErrorContainer),
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
                leading: Icon(
                  AppIcons.checkCircle,
                  color: context.colors.primary,
                ),
                title: Text(_selectedRestPauseExercise!.nome),
                subtitle: Text(
                  'Focus: ${_selectedRestPauseExercise!.focus.join(", ")}',
                ),
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
            // P3: Last weight badge
            _buildLastWeightBadge(_selectedRestPauseExercise!.nome),
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
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

                      // P4: RestPause preview card
                      _buildRestPausePreview(),

                      // Add to workout button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _canCreateRestPause()
                              ? _createRestPauseExercise
                              : null,
                          icon: const Icon(AppIcons.add),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(context.l10n.createRestPause),
                          ),
                        ),
                      ),
                      // P1: Save as Template button
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _canCreateRestPause()
                              ? _showSaveRestPauseTemplateDialog
                              : null,
                          icon: const Icon(AppIcons.template),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(context.l10n.saveAsTemplate),
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
    final hasExercise =
        _selectedRestPauseExercise != null ||
        _nameController.text.trim().isNotEmpty;
    if (!hasExercise) return false;

    // Must have valid weight and target reps
    final weight = double.tryParse(_restPauseWeightController.text.trim());
    final targetReps = int.tryParse(_restPauseTargetRepsController.text.trim());

    return weight != null && weight > 0 && targetReps != null && targetReps > 0;
  }

  void _createRestPauseExercise() {
    final weight = double.tryParse(_restPauseWeightController.text.trim());
    final targetReps = int.tryParse(_restPauseTargetRepsController.text.trim());
    final restSeconds =
        int.tryParse(_restPauseRestSecondsController.text.trim()) ?? 15;

    if (weight == null || targetReps == null) {
      SnackBarService.showError(context, context.l10n.weightAndRepsRequired);
      return;
    }

    // Get exercise name
    final exerciseName =
        _selectedRestPauseExercise?.nome ?? _nameController.text.trim();

    if (exerciseName.isEmpty) {
      SnackBarService.showError(context, context.l10n.exerciseNameRequired);
      return;
    }

    // Get category from exercise focus or selected category
    final selectedCategory = ref.read(selectedExerciseCategoryProvider);
    final category = _selectedRestPauseExercise != null
        ? MuscleAbbreviationMapper.focusListToExerciseCategory(
            _selectedRestPauseExercise!.focus,
          )
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
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
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

  Widget _buildExerciseSearchSection({
    Function(ExerciseDB.Exercise)? onExerciseSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Browse exercises from database button - Prominent
        Card(
          elevation: 2,
          child: ListTile(
            leading: Icon(AppIcons.libraryBooks, color: context.colors.primary),
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
                debugPrint(
                  '🔍 ADD_EXERCISE_MODAL: Opening ExerciseSearchScreen with callback: ${widget.onExerciseAdded != null}',
                );
              }

              // If we have a custom callback, open search in selection mode
              if (onExerciseSelected != null) {
                final selectedExercise = await Navigator.of(context)
                    .push<ExerciseDB.Exercise>(
                      MaterialPageRoute(
                        builder: (context) => const ExerciseSearchScreen(
                          selectionMode: true,
                          showSupersetTemplates:
                              false, // ✅ FIX: No templates for single selection
                        ),
                      ),
                    );

                if (selectedExercise != null) {
                  onExerciseSelected(selectedExercise);
                }
              } else {
                // Original behavior for single exercise tab
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExerciseSearchScreen(
                      onExerciseAdded: widget.onExerciseAdded,
                      showSupersetTemplates:
                          false, // ✅ FIX: No templates for single exercise
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
              context.l10n.cantFindExercise,
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
        leading: Icon(AppIcons.libraryBooks, color: context.colors.primary),
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
          final selectedExercise = await Navigator.of(context)
              .push<ExerciseDB.Exercise>(
                MaterialPageRoute(
                  builder: (context) => const ExerciseSearchScreen(
                    selectionMode: true,
                    showSupersetTemplates:
                        false, // ✅ FIX: No templates for DropSet/RestPause
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
                  ref.read(selectedExerciseCategoryProvider.notifier).state =
                      category;
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final weight = double.tryParse(value) ?? 0;
              final updatedSet = set.copyWith(weight: weight);
              ref
                  .read(exerciseSetsProvider.notifier)
                  .updateSet(set.id, updatedSet);
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final reps = int.tryParse(value) ?? 10;
              final updatedSet = set.copyWith(reps: reps);
              ref
                  .read(exerciseSetsProvider.notifier)
                  .updateSet(set.id, updatedSet);
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(
                    stageData.weightController.text.isEmpty
                        ? '---'
                        : '${stageData.weightController.text} kg',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: stageData.weightController.text.isEmpty
                          ? context.colors.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            )
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
    if (stageIndex > 0 &&
        _dropsetStages[stageIndex - 1].weightController.text.isNotEmpty) {
      previousWeight = double.tryParse(
        _dropsetStages[stageIndex - 1].weightController.text,
      );
    }

    // Get current weight if exists
    final currentWeightText = _dropsetStages[stageIndex].weightController.text;
    final initialWeight = currentWeightText.isNotEmpty
        ? double.tryParse(currentWeightText)
        : null;

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
        _dropsetStages[stageIndex].weightController.text = selectedWeight
            .toStringAsFixed(1);
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
      final category = MuscleAbbreviationMapper.focusListToExerciseCategory(
        exercise.focus,
      );
      ref.read(selectedExerciseCategoryProvider.notifier).state = category;

      // ✅ UX: Suggest appropriate weights based on exercise type
      // Helps beginners (Marco persona) with realistic starting values
      final suggestedWeights = DropSetWeightSuggester.getSuggestedWeights(
        tipoEsercizio: exercise.tipoEsercizio,
        focus: exercise.focus,
      );

      // Update stage controllers with suggested values
      if (_dropsetStages.isNotEmpty) {
        _dropsetStages[0].weightController.text =
            suggestedWeights.stage1.toStringAsFixed(0);
      }
      if (_dropsetStages.length > 1) {
        _dropsetStages[1].weightController.text =
            suggestedWeights.stage2.toStringAsFixed(0);
      }
      if (_dropsetStages.length > 2) {
        _dropsetStages[2].weightController.text =
            suggestedWeights.stage3.toStringAsFixed(0);
      }
    });
  }

  void _onRestPauseExerciseSelected(ExerciseDB.Exercise exercise) {
    setState(() {
      _selectedRestPauseExercise = exercise;
      _nameController.text = '${exercise.nome} - Rest-Pause';

      // Map exercise focus to category using single source of truth
      final category = MuscleAbbreviationMapper.focusListToExerciseCategory(
        exercise.focus,
      );
      ref.read(selectedExerciseCategoryProvider.notifier).state = category;
    });
  }

  // ===========================================================================
  // P1: Save as Template functionality for DropSet/RestPause
  // ===========================================================================

  /// Show dialog to save current DropSet configuration as template
  Future<void> _showSaveDropsetTemplateDialog() async {
    final templateNameController = TextEditingController();
    final templateNotesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.saveAsTemplate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: templateNameController,
              decoration: InputDecoration(
                labelText: context.l10n.templateName,
                prefixIcon: const Icon(AppIcons.template),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: templateNotesController,
              decoration: InputDecoration(
                labelText: context.l10n.notesOptional,
                prefixIcon: const Icon(AppIcons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );

    if (result == true && templateNameController.text.trim().isNotEmpty) {
      await _saveDropsetTemplate(
        templateNameController.text.trim(),
        templateNotesController.text.trim(),
      );
    }

    templateNameController.dispose();
    templateNotesController.dispose();
  }

  /// Save current DropSet configuration as a custom template
  Future<void> _saveDropsetTemplate(String name, String notes) async {
    try {
      final entitlements = ref.read(tierEntitlementsProvider);
      final maxCustomDropsets = entitlements.maxCustomDropsets;

      // Check current count
      final repository = DropsetTemplateRepository();
      final currentTemplates = await repository.getCustomTemplates();

      if (currentTemplates.length >= maxCustomDropsets) {
        if (mounted) {
          SnackBarService.showError(
            context,
            context.l10n.templateLimitReached(maxCustomDropsets),
          );
        }
        return;
      }

      // Get exercise name
      final exerciseName =
          _selectedDropSetExercise?.nome ?? _nameController.text.trim();

      // Calculate drop percentage from stages
      int dropPercentage = 20; // Default
      if (_dropsetStages.length >= 2) {
        final w1 = double.tryParse(_dropsetStages[0].weightController.text) ?? 0;
        final w2 = double.tryParse(_dropsetStages[1].weightController.text) ?? 0;
        if (w1 > 0 && w2 > 0) {
          dropPercentage = ((1 - w2 / w1) * 100).round();
        }
      }

      // Create template from current state
      final template = DropsetTemplate(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        exerciseName: exerciseName,
        drops: _dropsetStages.length,
        initialReps: _dropsetStages.isNotEmpty
            ? _dropsetStages[0].repsController.text
            : '8',
        dropPercentage: dropPercentage,
        restBetweenDrops: 0, // Dropsets typically have no rest
        totalSets: 1,
        restBetweenSets: 120,
        difficulty: DropsetDifficulty.intermediate,
        estimatedTimeMinutes: _dropsetStages.length * 2,
        scientificBasis: 'Custom template',
        notes: notes.isNotEmpty ? notes : null,
        isCustom: true,
        createdAt: DateTime.now(),
      );

      await repository.saveCustomTemplate(
        template,
        maxCustomDropsets: maxCustomDropsets,
      );

      if (mounted) {
        SnackBarService.showSuccess(context, context.l10n.templateSaved);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, context.l10n.templateSaveError);
      }
    }
  }

  /// Show dialog to save current RestPause configuration as template
  Future<void> _showSaveRestPauseTemplateDialog() async {
    final templateNameController = TextEditingController();
    final templateNotesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.saveAsTemplate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: templateNameController,
              decoration: InputDecoration(
                labelText: context.l10n.templateName,
                prefixIcon: const Icon(AppIcons.template),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: templateNotesController,
              decoration: InputDecoration(
                labelText: context.l10n.notesOptional,
                prefixIcon: const Icon(AppIcons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );

    if (result == true && templateNameController.text.trim().isNotEmpty) {
      await _saveRestPauseTemplate(
        templateNameController.text.trim(),
        templateNotesController.text.trim(),
      );
    }

    templateNameController.dispose();
    templateNotesController.dispose();
  }

  /// Save current RestPause configuration as a custom template
  Future<void> _saveRestPauseTemplate(String name, String notes) async {
    try {
      final entitlements = ref.read(tierEntitlementsProvider);
      final maxCustomRestPause = entitlements.maxCustomRestPause;

      // Check current count
      final repository = RestPauseTemplateRepository();
      final currentTemplates = await repository.getCustomTemplates();

      if (currentTemplates.length >= maxCustomRestPause) {
        if (mounted) {
          SnackBarService.showError(
            context,
            context.l10n.templateLimitReached(maxCustomRestPause),
          );
        }
        return;
      }

      // Get exercise name
      final exerciseName =
          _selectedRestPauseExercise?.nome ?? _nameController.text.trim();

      final restSeconds =
          int.tryParse(_restPauseRestSecondsController.text) ?? 15;
      final targetReps =
          int.tryParse(_restPauseTargetRepsController.text) ?? 20;

      // Create template from current state
      final template = RestPauseTemplate(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        exerciseName: exerciseName,
        initialReps: targetReps.toString(),
        clusters: 3,
        clusterReps: '3-5',
        pauseDuration: restSeconds,
        totalSets: 1,
        restBetweenSets: 180,
        difficulty: RestPauseDifficulty.intermediate,
        estimatedTimeMinutes: 5,
        scientificBasis: 'Custom template',
        notes: notes.isNotEmpty ? notes : null,
        isCustom: true,
        createdAt: DateTime.now(),
      );

      await repository.saveCustomTemplate(
        template,
        maxCustomRestPause: maxCustomRestPause,
      );

      if (mounted) {
        SnackBarService.showSuccess(context, context.l10n.templateSaved);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, context.l10n.templateSaveError);
      }
    }
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

/// Helper class to suggest appropriate weights for dropsets based on exercise type
/// Helps beginners (Marco persona) with realistic starting values
class DropSetWeightSuggester {
  /// Get suggested weights for dropset stages based on exercise characteristics
  ///
  /// Returns a tuple of (stage1, stage2, stage3) weights
  /// Logic:
  /// - Compound exercises (squat, deadlift, bench): higher weights
  /// - Isolation exercises (curls, raises): lower weights
  /// - Adjusted by muscle group size (legs/back > arms/shoulders)
  static ({double stage1, double stage2, double stage3}) getSuggestedWeights({
    required String tipoEsercizio,
    required List<String> focus,
    double dropPercentage = 0.20, // 20% drop between stages
  }) {
    // Base weight depends on exercise type
    double baseWeight;

    final isCompound = tipoEsercizio.toLowerCase() == 'compound';
    final focusLower = focus.map((f) => f.toLowerCase()).toList();

    // Determine base weight from muscle group
    if (_isLargeMuscleGroup(focusLower)) {
      // Legs, Back, Chest → heavier base
      baseWeight = isCompound ? 60.0 : 30.0;
    } else if (_isMediumMuscleGroup(focusLower)) {
      // Shoulders → medium base
      baseWeight = isCompound ? 40.0 : 20.0;
    } else {
      // Arms, Abs → lighter base
      baseWeight = isCompound ? 30.0 : 15.0;
    }

    // Calculate stages with 20% drop
    final stage1 = baseWeight;
    final stage2 = (baseWeight * (1 - dropPercentage)).roundToDouble();
    final stage3 = (baseWeight * (1 - dropPercentage * 2)).roundToDouble();

    return (stage1: stage1, stage2: stage2, stage3: stage3);
  }

  static bool _isLargeMuscleGroup(List<String> focus) {
    const largeGroups = [
      'quadriceps',
      'quad',
      'hamstrings',
      'glutes',
      'glutei',
      'gambe',
      'legs',
      'back',
      'dorso',
      'lat',
      'dorsali',
      'schiena',
      'chest',
      'petto',
      'pettorali',
    ];
    return focus.any(
      (f) => largeGroups.any((g) => f.contains(g)),
    );
  }

  static bool _isMediumMuscleGroup(List<String> focus) {
    const mediumGroups = [
      'shoulder',
      'spalle',
      'deltoidi',
      'delt',
      'trap',
      'trapezio',
    ];
    return focus.any(
      (f) => mediumGroups.any((g) => f.contains(g)),
    );
  }
}
