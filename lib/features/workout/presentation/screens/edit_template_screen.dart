import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/minimal_set_edit_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/reps_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rest_time_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/weight_picker_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/template_view_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/template_muscle_analysis_widget.dart';
import 'package:cupertino_native/cupertino_native.dart';

class EditTemplateScreen extends ConsumerStatefulWidget {
  const EditTemplateScreen({super.key, required this.template});
  final WorkoutTemplate template;

  @override
  ConsumerState<EditTemplateScreen> createState() => _EditTemplateScreenState();
}

class _EditTemplateScreenState extends ConsumerState<EditTemplateScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late List<ExerciseTemplate> _exercises;
  late List<int> _exerciseKeyIds;
  int _nextExerciseKeyId = 0;
  bool _isLoading = false;
  bool _hasChanges = false;
  // Track which exercises are expanded
  final Map<int, bool> _expandedExercises = {};
  // Pulse animation for empty fields
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  // Track warmup enabled per exercise
  final Map<int, bool> _warmupEnabled = {};
  // Manual overrides for warmup sets: {exerciseIndex: {warmupIndex: _WarmupSet}}
  final Map<int, Map<int, _WarmupSet>> _warmupOverrides = {};
  // Warmup percentages (default: 40%, 60%, 75%, 85%)
  List<int> _warmupPercentages = [40, 60, 75, 85];
  // Auto-populate guard
  bool _hasAutoPopulated = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template.name);
    _descriptionController = TextEditingController(
      text: widget.template.description,
    );
    _exercises = List.from(widget.template.exercises);
    _exerciseKeyIds = List.generate(_exercises.length, (_) => _nextExerciseKeyId++);

    // Start first exercise expanded for immediate feedback
    if (_exercises.isNotEmpty) {
      _expandedExercises[0] = true;
    }

    // Pulse animation for empty fields
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-populate empty sets from workout history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoPopulateFromHistory();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasChanges) {
          _showDiscardChangesDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: _showEditNameDialog,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _nameController.text.isEmpty
                        ? context.l10n.templateName
                        : _nameController.text.toUpperCase(),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(AppIcons.edit, size: 14, color: context.colors.onSurface.withValues(alpha: 0.5)),
              ],
            ),
          ),
          actions: [
            // View mode button (presentation mode)
            IconButton(
              onPressed: _navigateToViewMode,
              icon: const SemanticIcon(
                icon: AppIcons.visibility,
                semanticLabel: 'View mode',
                size: AppIconSize.medium,
              ),
              tooltip: context.l10n.templateViewMode,
            ),
            // Save button - always visible
            Semantics(
              label: context.l10n.save,
              button: true,
              enabled: !_isLoading && _hasChanges,
              child: TextButton(
                onPressed: _isLoading || !_hasChanges ? null : _saveTemplate,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: LoadingIndicator(),
                      )
                    : Text(context.l10n.save),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Header - description field only (name is edited via AppBar tap)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: context.l10n.description,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    onChanged: (_) => _markAsChanged(),
                  ),
                  // Toggle pubblico/privato
                  /* Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isPublic ? AppIcons.public : AppIcons.lock,
                                size: 20,
                                color: _isPublic
                                    ? context.colors.primary
                                    : context.colors.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                              SizedBox(width: 8),
                              Text(
                                _isPublic
                                    ? 'Template Pubblico'
                                    : 'Template Privato',
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              CNSwitch(
                                value: _isPublic,
                                onChanged: (value) {
                                  setState(() {
                                    _isPublic = value;
                                  });
                                  _markAsChanged();
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            _isPublic
                                ? 'Altri utenti potranno trovare e utilizzare questo template'
                                : 'Solo tu puoi vedere e utilizzare questo template',
                            style: context.textTheme.bodySmall?.copyWith(
                              color:
                                  context.colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          if (_isPublic) ...[
                            SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.colors.primaryContainer
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: context.colors.primary
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SemanticIcon(
  icon: AppIcons.info,
  semanticLabel: 'Information',
  size: AppIconSize.tiny,
  color: context.colors.primary,
),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Assicurati che il template sia completo e ben descritto',
                                      style: context.textTheme.labelSmall?.copyWith(
                                        color:
                                            context.colors.onPrimaryContainer,
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
                  ), */
                ],
              ),
            ),

            // Muscle balance analysis
            TemplateMuscleAnalysisSection(exercises: _exercises),

            // Lista esercizi con riordinamento
            Expanded(
              child: _exercises.isEmpty
                  ? _buildEmptyState()
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _exercises.length,
                      onReorder: _reorderExercises,
                      buildDefaultDragHandles: false,
                      itemBuilder: (context, index) {
                        return _buildExerciseCard(context, index);
                      },
                    ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: TabBarInset.of(context)),
          child: CNButton.icon(
            icon: const CNSymbol('plus', size: 20, weight: CNSymbolWeight.medium),
            onPressed: _showAddExercise,
            style: CNButtonStyle.glass,
            size: 56,
            tint: context.colors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.fitnessCenterOutlined,
            semanticLabel: 'Fitness center outlined',
            size: AppIconSize.medium,
            color: context.colors.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noExercisesYet,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.tapToAddExercise,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showAddExercise,
            icon: const SemanticIcon(icon: AppIcons.add, semanticLabel: 'Add'),
            label: Text(context.l10n.addExercise),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, int index) {
    final exerciseTemplate = _exercises[index];
    final isExpanded = _expandedExercises[index] ?? false;

    return Padding(
      key: Key('exercise_${_exerciseKeyIds[index]}'),
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key('dismissible_exercise_${_exerciseKeyIds[index]}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: context.colors.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.delete, color: context.colors.surface, size: 28),
              const SizedBox(height: 4),
              Text(
                context.l10n.delete,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.surface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await ModalService.showConfirmDialog(
            context,
            title: context.l10n.removeExercise,
            message: context.l10n.confirmRemoveExercise(
              exerciseTemplate.exerciseName,
            ),
            isDangerous: true,
          );
        },
        onDismissed: (direction) => _removeExercise(index),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise header
              InkWell(
                onTap: () => _toggleExpanded(index),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Drag handle
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          AppIcons.dragHandle,
                          color: context.colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Exercise info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exerciseTemplate.exerciseName,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                // Muscle group chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: context.colors.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    exerciseTemplate.category.name,
                                    style: context.textTheme.labelSmall?.copyWith(
                                      fontSize: 9,
                                      color: context.colors.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  exerciseTemplate.type == ExerciseType.superset &&
                                          exerciseTemplate.subExercises != null &&
                                          exerciseTemplate.subExercises!.isNotEmpty
                                      ? '${exerciseTemplate.sets.length} round × ${exerciseTemplate.subExercises!.length}'
                                      : '${exerciseTemplate.sets.length} set',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colors.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                // Rest time chip - tappable
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    // Prevent parent InkWell
                                    _showRestTimePicker(index);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                        Icon(AppIcons.timer, size: 12, color: context.colors.primary),
                                        if (exerciseTemplate.restTime != null) ...[
                                          const SizedBox(width: 2),
                                          Text(
                                            _formatRestTime(exerciseTemplate.restTime!),
                                            style: context.textTheme.labelSmall?.copyWith(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: context.colors.primary,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Warmup toggle button
                      _buildWarmupToggle(index),
                      const SizedBox(width: 8),
                      // Expand/collapse icon
                      Icon(
                        isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
                        color: context.colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              // Warmup sets (visible when expanded and warmup enabled)
              if (isExpanded && (_warmupEnabled[index] ?? false))
                _buildWarmupSets(index, exerciseTemplate),
              // Expanded sets editor
              if (isExpanded) _buildSetsEditor(index, exerciseTemplate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetsEditor(
    int exerciseIndex,
    ExerciseTemplate exerciseTemplate,
  ) {
    // ✅ FIX: For superset, show different UI - click to edit all exercises in round
    final isSupersetWithSubExercises =
        exerciseTemplate.type == ExerciseType.superset &&
        exerciseTemplate.subExercises != null &&
        exerciseTemplate.subExercises!.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(color: context.colors.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        children: [
          // Sets/Rounds list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: exerciseTemplate.sets.length,
            itemBuilder: (context, setIndex) {
              final set = exerciseTemplate.sets[setIndex];

              // ✅ For superset: show round card that opens edit modal
              if (isSupersetWithSubExercises) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _editSupersetRound(exerciseIndex, setIndex),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.colors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Round number badge
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${set.setNumber}',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Round info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.roundNumber(set.setNumber),
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${exerciseTemplate.subExercises!.length} ${context.l10n.exercises}',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colors.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Edit icon
                          Icon(
                            AppIcons.edit,
                            size: 20,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: 4),
                          // Remove round button
                          if (exerciseTemplate.sets.length > 1)
                            IconButton(
                              onPressed: () =>
                                  _removeSet(exerciseIndex, setIndex),
                              icon: const SemanticIcon(
                                icon: AppIcons.removeCircleOutline,
                                semanticLabel: 'Remove round',
                              ),
                              color: context.colors.error,
                              iconSize: 20,
                              tooltip: context.l10n.removeRound,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Compact inline set row (~38px)
              final mode = exerciseTemplate.countingMode ?? ExerciseCountingMode.weighted;
              final isWeightEmpty = (set.targetWeight ?? 0) == 0;
              final isRepsEmpty = (set.targetReps ?? 0) == 0 && !set.hasRepRange;
              final isSecondsEmpty = (set.targetSeconds ?? 0) == 0;

              return GestureDetector(
                onTap: () => _showEditTemplateSetModal(exerciseIndex, setIndex),
                onLongPress: () {
                  final w = set.targetWeight ?? 0;
                  if (w > 0) _applyWeightToAllSets(exerciseIndex, w);
                },
                child: SizedBox(
                  height: 38,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        // Set number badge
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${set.setNumber}',
                              style: context.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Weight field (only for weighted mode)
                        if (mode.requiresWeight) ...[
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: context.colors.surfaceContainerHighest.withValues(
                                      alpha: isWeightEmpty ? _pulseAnimation.value * 0.3 : 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: isWeightEmpty
                                        ? Border.all(
                                            color: context.colors.primary.withValues(
                                              alpha: _pulseAnimation.value * 0.5,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      isWeightEmpty ? '-' : '${set.targetWeight?.toStringAsFixed(1)} kg',
                                      style: context.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isWeightEmpty
                                            ? context.colors.onSurface.withValues(alpha: 0.3)
                                            : context.colors.onSurface,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '×',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colors.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                        // Reps field (for weighted + reps modes)
                        if (mode.requiresReps)
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: context.colors.surfaceContainerHighest.withValues(
                                      alpha: isRepsEmpty ? _pulseAnimation.value * 0.3 : 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: isRepsEmpty
                                        ? Border.all(
                                            color: context.colors.secondary.withValues(
                                              alpha: _pulseAnimation.value * 0.5,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      isRepsEmpty ? '-' : '${set.repsDisplay} rep',
                                      style: context.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isRepsEmpty
                                            ? context.colors.onSurface.withValues(alpha: 0.3)
                                            : context.colors.onSurface,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        // Duration field (for time mode)
                        if (mode.requiresTime)
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                final secs = set.targetSeconds ?? 0;
                                final display = secs >= 60
                                    ? '${secs ~/ 60}m ${secs % 60 > 0 ? '${secs % 60}s' : ''}'.trim()
                                    : '${secs}s';
                                return Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: context.colors.surfaceContainerHighest.withValues(
                                      alpha: isSecondsEmpty ? _pulseAnimation.value * 0.3 : 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSecondsEmpty
                                        ? Border.all(
                                            color: context.colors.secondary.withValues(
                                              alpha: _pulseAnimation.value * 0.5,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      isSecondsEmpty ? '-' : display,
                                      style: context.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSecondsEmpty
                                            ? context.colors.onSurface.withValues(alpha: 0.3)
                                            : context.colors.onSurface,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        // Remove set
                        if (exerciseTemplate.sets.length > 1)
                          SizedBox(
                            width: 32,
                            child: IconButton(
                              onPressed: () => _removeSet(exerciseIndex, setIndex),
                              icon: Icon(AppIcons.close, size: 14, color: context.colors.error.withValues(alpha: 0.6)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Add set/round button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () => _addSet(exerciseIndex),
              icon: const SemanticIcon(
                icon: AppIcons.add,
                semanticLabel: 'Add',
              ),
              label: Text(
                isSupersetWithSubExercises
                    ? context.l10n.addRound
                    : context.l10n.addSet,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Auto-populate empty template sets from workout history
  Future<void> _autoPopulateFromHistory() async {
    if (_hasAutoPopulated || !mounted) return;
    _hasAutoPopulated = true;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final service = ref.read(workoutHistoryServiceProvider);
    var populated = 0;

    for (int i = 0; i < _exercises.length; i++) {
      final exercise = _exercises[i];
      // Skip supersets and exercises that already have weight data
      if (exercise.type == ExerciseType.superset) continue;
      final hasAnyWeight = exercise.sets.any((s) => (s.targetWeight ?? 0) > 0);
      if (hasAnyWeight) continue;

      try {
        final history = await service.getExerciseHistoryWithSetDetails(
          exerciseName: exercise.exerciseName,
          userId: userId,
          limit: 1,
        );
        if (history.isEmpty || !mounted) continue;

        final lastWorkout = history.first;
        final sets = (lastWorkout['sets'] as List<dynamic>?) ?? [];
        // Filter out warmup sets
        final workingSets = sets
            .where((s) => s['isWarmup'] != true)
            .toList();
        if (workingSets.isEmpty) continue;

        final updatedSets = <SetTemplate>[];
        for (int j = 0; j < exercise.sets.length; j++) {
          final historySet = j < workingSets.length ? workingSets[j] : workingSets.last;
          final weight = (historySet['weight'] as num?)?.toDouble() ?? 0;
          final reps = (historySet['reps'] as num?)?.toInt() ?? 0;
          updatedSets.add(SetTemplate(
            setNumber: exercise.sets[j].setNumber,
            targetWeight: weight > 0 ? weight : exercise.sets[j].targetWeight,
            targetReps: reps > 0 ? reps : exercise.sets[j].targetReps,
            targetMinReps: exercise.sets[j].targetMinReps,
            targetMaxReps: exercise.sets[j].targetMaxReps,
            targetRpe: exercise.sets[j].targetRpe,
            targetSeconds: exercise.sets[j].targetSeconds,
            notes: exercise.sets[j].notes,
          ));
        }

        if (mounted) {
          setState(() {
            _exercises[i] = exercise.copyWith(sets: updatedSets);
          });
          populated++;
        }
      } catch (_) {
        // Skip exercises with no history
        continue;
      }
    }

    if (populated > 0 && mounted) {
      _markAsChanged();
      SnackBarService.showSuccess(
        context,
        context.l10n.autoPopulatedFromHistory,
      );
    }
  }

  /// Show dialog to edit template name from the AppBar
  void _showEditNameDialog() {
    final controller = TextEditingController(text: _nameController.text);
    ModalService.showSheet(
      context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.templateName,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: context.l10n.templateName,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              style: context.textTheme.titleSmall,
              onSubmitted: (_) {
                _nameController.text = controller.text;
                _markAsChanged();
                setState(() {});
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                _nameController.text = controller.text;
                _markAsChanged();
                setState(() {});
                Navigator.pop(ctx);
              },
              child: Text(context.l10n.done),
            ),
          ],
        ),
      ),
    );
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void _toggleExpanded(int index) {
    setState(() {
      _expandedExercises[index] = !(_expandedExercises[index] ?? false);
    });
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final exercise = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, exercise);
      final keyId = _exerciseKeyIds.removeAt(oldIndex);
      _exerciseKeyIds.insert(newIndex, keyId);
    });
    _markAsChanged();
  }

  void _addSet(int exerciseIndex) {
    final exerciseTemplate = _exercises[exerciseIndex];
    final newSetNumber = exerciseTemplate.sets.length + 1;

    final lastSet = exerciseTemplate.sets.lastOrNull;
    final newSet = SetTemplate(
      setNumber: newSetNumber,
      targetWeight: lastSet?.targetWeight ?? 0,
      targetReps: lastSet?.targetReps ?? 0,
      targetMinReps: lastSet?.targetMinReps,
      targetMaxReps: lastSet?.targetMaxReps,
      targetSeconds: lastSet?.targetSeconds,
    );

    setState(() {
      _exercises[exerciseIndex] = exerciseTemplate.copyWith(
        sets: [...exerciseTemplate.sets, newSet],
      );
    });
    _markAsChanged();
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    final exerciseTemplate = _exercises[exerciseIndex];

    final updatedSets = List<SetTemplate>.from(exerciseTemplate.sets);
    updatedSets.removeAt(setIndex);

    // Renumber sets
    for (int i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = SetTemplate(
        setNumber: i + 1,
        targetWeight: updatedSets[i].targetWeight,
        targetReps: updatedSets[i].targetReps,
        targetMinReps: updatedSets[i].targetMinReps,
        targetMaxReps: updatedSets[i].targetMaxReps,
        targetRpe: updatedSets[i].targetRpe,
        targetSeconds: updatedSets[i].targetSeconds,
        notes: updatedSets[i].notes,
      );
    }

    setState(() {
      _exercises[exerciseIndex] = exerciseTemplate.copyWith(sets: updatedSets);
    });
    _markAsChanged();
  }

  void _updateSetWeight(int exerciseIndex, int setIndex, double weight) {
    final exerciseTemplate = _exercises[exerciseIndex];
    final updatedSets = List<SetTemplate>.from(exerciseTemplate.sets);
    updatedSets[setIndex] = SetTemplate(
      setNumber: updatedSets[setIndex].setNumber,
      targetWeight: weight,
      targetReps: updatedSets[setIndex].targetReps,
      targetMinReps: updatedSets[setIndex].targetMinReps,
      targetMaxReps: updatedSets[setIndex].targetMaxReps,
      targetRpe: updatedSets[setIndex].targetRpe,
      targetSeconds: updatedSets[setIndex].targetSeconds,
      notes: updatedSets[setIndex].notes,
    );

    setState(() {
      _exercises[exerciseIndex] = exerciseTemplate.copyWith(sets: updatedSets);
    });
    _markAsChanged();
  }

  void _updateSetReps(
    int exerciseIndex,
    int setIndex,
    int? reps, { // ✅ NULLABLE - può essere null in range mode
    int? minReps,
    int? maxReps,
  }) {
    final exerciseTemplate = _exercises[exerciseIndex];
    final updatedSets = List<SetTemplate>.from(exerciseTemplate.sets);
    updatedSets[setIndex] = SetTemplate(
      setNumber: updatedSets[setIndex].setNumber,
      targetWeight: updatedSets[setIndex].targetWeight,
      targetReps: reps, // ✅ Ora può essere null in range mode
      targetMinReps: minReps,
      targetMaxReps: maxReps,
      targetRpe: updatedSets[setIndex].targetRpe,
      targetSeconds: updatedSets[setIndex].targetSeconds,
      notes: updatedSets[setIndex].notes,
    );

    setState(() {
      _exercises[exerciseIndex] = exerciseTemplate.copyWith(sets: updatedSets);
    });
    _markAsChanged();
  }

  void _updateSetSeconds(int exerciseIndex, int setIndex, int? seconds) {
    final exerciseTemplate = _exercises[exerciseIndex];
    final updatedSets = List<SetTemplate>.from(exerciseTemplate.sets);
    updatedSets[setIndex] = SetTemplate(
      setNumber: updatedSets[setIndex].setNumber,
      targetWeight: updatedSets[setIndex].targetWeight,
      targetReps: updatedSets[setIndex].targetReps,
      targetMinReps: updatedSets[setIndex].targetMinReps,
      targetMaxReps: updatedSets[setIndex].targetMaxReps,
      targetRpe: updatedSets[setIndex].targetRpe,
      targetSeconds: seconds,
      notes: updatedSets[setIndex].notes,
    );

    setState(() {
      _exercises[exerciseIndex] = exerciseTemplate.copyWith(sets: updatedSets);
    });
    _markAsChanged();
  }

  /// ✅ Edit superset round - opens modal to set target weight/reps for all exercises in round
  void _editSupersetRound(int exerciseIndex, int roundIndex) async {
    final exerciseTemplate = _exercises[exerciseIndex];
    final round = exerciseTemplate.sets[roundIndex];

    // Show modal with weight/reps pickers for this round
    await ModalService.showSheet(context,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.roundNumber(round.setNumber),
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const SemanticIcon(
                          icon: AppIcons.close,
                          semanticLabel: 'Close',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.editRoundData,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Exercises list
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.exercises,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...?exerciseTemplate.subExercises?.map((subExercise) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              subExercise.exerciseName,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  // Weight/Reps pickers
                  Row(
                    children: [
                      Expanded(
                        child: _buildPickerButton(
                          label: context.l10n.weight,
                          value: round.targetWeight == 0
                              ? '-'
                              : '${round.targetWeight?.toStringAsFixed(1)} kg',
                          icon: AppIcons.workout,
                          color: context.colors.primary,
                          onTap: () async {
                            final newWeight = await WeightPickerModal.show(
                              context,
                              initialWeight: round.targetWeight ?? 0,
                            );
                            if (newWeight != null) {
                              _updateSetWeight(
                                exerciseIndex,
                                roundIndex,
                                newWeight,
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '×',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPickerButton(
                          label: context.l10n.reps,
                          value: round.repsDisplay,
                          icon: AppIcons.repeat,
                          color: context.colors.secondary,
                          onTap: () async {
                            final result = await RepsPickerModal.showWithRange(
                              context,
                              initialReps: round.targetReps ?? 0,
                              initialMinReps: round.targetMinReps,
                              initialMaxReps: round.targetMaxReps,
                            );
                            if (result != null) {
                              if (result.isRange) {
                                _updateSetReps(
                                  exerciseIndex,
                                  roundIndex,
                                  null, // ✅ NULL in range mode, non minReps!
                                  minReps: result.minReps,
                                  maxReps: result.maxReps,
                                );
                              } else {
                                _updateSetReps(
                                  exerciseIndex,
                                  roundIndex,
                                  result.reps ?? round.targetReps, // ✅ Nullable
                                );
                              }
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddExercise() {
    // ✅ UX: Use the new static show method for proper sizing
    AddExerciseModal.show(
      context,
      onExerciseAdded: (exercise) {
        _addExercise(exercise);
      },
    );
  }

  void _addExercise(Exercise exercise) {
    // ✅ FIX: Use factory method instead of manual conversion
    // ExerciseTemplate.fromExercise() handles all exercise types (standard, superset, dropset, restpause)
    final exerciseTemplate = ExerciseTemplate.fromExercise(exercise);

    setState(() {
      _exercises.add(exerciseTemplate);
      _exerciseKeyIds.add(_nextExerciseKeyId++);
    });
    _markAsChanged();
  }

  void _removeExercise(int index) {
    if (index >= 0 && index < _exercises.length) {
      setState(() {
        _exercises.removeAt(index);
        _exerciseKeyIds.removeAt(index);
      });
      _markAsChanged();
    }
  }

  /// Navigate to presentation/view mode
  void _navigateToViewMode() {
    // If there are unsaved changes, warn the user
    if (_hasChanges) {
      ModalService.showConfirmDialog(
        context,
        title: context.l10n.unsavedChangesTitle,
        message: context.l10n.unsavedChangesMessage,
        confirmText: context.l10n.continueText,
      ).then((confirmed) {
        if (confirmed && mounted) {
          _openViewMode();
        }
      });
    } else {
      _openViewMode();
    }
  }

  void _openViewMode() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TemplateViewScreen(templateId: widget.template.id),
      ),
    );
  }

  Future<void> _saveTemplate() async {
    if (_nameController.text.trim().isEmpty) {
      SnackBarService.showError(context, context.l10n.templateNameRequired);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Ensure userId is set (safety net for templates created without it)
      final currentUserId = ref.read(currentUserIdProvider);
      final templateToSave = widget.template.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        exercises: _exercises,
        updatedAt: DateTime.now(),
        userId:
            widget.template.userId ??
            currentUserId, // ✅ Safety net for Firestore rules
      );

      await ref
          .read(workoutTemplateNotifierProvider.notifier)
          .saveTemplate(templateToSave);

      ref.invalidate(customWorkoutTemplatesProvider);

      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });

      if (mounted) {
        SnackBarService.showSuccess(context, context.l10n.templateSaved);
        context.pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        final errorMsg = e.toString();
        SnackBarService.showError(
          context,
          context.l10n.errorWithMessage(errorMsg),
        );
      }
    }
  }

  Future<void> _showDiscardChangesDialog() async {
    final confirmed = await ModalService.showConfirmDialog(
      context,
      title: context.l10n.unsavedChanges,
      message: context.l10n.discardChangesMessage,
      isDangerous: true,
    );

    if (confirmed && mounted) {
      context.pop();
    }
  }

  /// Apply weight to all sets of an exercise (long-press action)
  void _applyWeightToAllSets(int exerciseIndex, double weight) {
    final exercise = _exercises[exerciseIndex];
    final updatedSets = exercise.sets.map((s) => SetTemplate(
      setNumber: s.setNumber,
      targetWeight: weight,
      targetReps: s.targetReps,
      targetMinReps: s.targetMinReps,
      targetMaxReps: s.targetMaxReps,
      targetRpe: s.targetRpe,
      targetSeconds: s.targetSeconds,
      notes: s.notes,
    )).toList();
    setState(() {
      _exercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);
    });
    _markAsChanged();
    if (mounted) {
      SnackBarService.showSuccess(context, '${weight.toStringAsFixed(1)} kg → ${context.l10n.appliedToAllSets}');
    }
  }

  /// Show MinimalSetEditSheet for editing a template set
  void _showEditTemplateSetModal(int exerciseIndex, int setIndex) {
    final exercise = _exercises[exerciseIndex];
    final set = exercise.sets[setIndex];
    final mode = exercise.countingMode ?? ExerciseCountingMode.weighted;

    // Bridge: convert SetTemplate → ExerciseSet for the modal
    final exerciseSet = ExerciseSet(
      setNumber: set.setNumber,
      weight: set.targetWeight,
      reps: set.targetReps,
      minReps: set.targetMinReps,
      maxReps: set.targetMaxReps,
      seconds: set.targetSeconds,
    );

    final allSets = exercise.sets.map((s) => ExerciseSet(
      setNumber: s.setNumber,
      weight: s.targetWeight,
      reps: s.targetReps,
      minReps: s.targetMinReps,
      maxReps: s.targetMaxReps,
      seconds: s.targetSeconds,
    )).toList();

    final previousSet = setIndex > 0
        ? ExerciseSet(
            setNumber: exercise.sets[setIndex - 1].setNumber,
            weight: exercise.sets[setIndex - 1].targetWeight,
            reps: exercise.sets[setIndex - 1].targetReps,
            minReps: exercise.sets[setIndex - 1].targetMinReps,
            maxReps: exercise.sets[setIndex - 1].targetMaxReps,
            seconds: exercise.sets[setIndex - 1].targetSeconds,
          )
        : null;

    void saveSet(int exIdx, int sIdx, ExerciseSet updatedSet) {
      if (mode.requiresWeight) {
        _updateSetWeight(exIdx, sIdx, updatedSet.weight ?? 0);
      }
      if (mode.requiresReps) {
        _updateSetReps(exIdx, sIdx, updatedSet.reps,
            minReps: updatedSet.minReps, maxReps: updatedSet.maxReps);
      }
      if (mode.requiresTime) {
        _updateSetSeconds(exIdx, sIdx, updatedSet.seconds);
      }
    }

    context.showMinimalSetEditSheet(
      exerciseSet: exerciseSet,
      currentSetIndex: setIndex,
      totalSets: exercise.sets.length,
      allSets: allSets,
      previousSet: previousSet,
      countingMode: mode,
      onSave: (updatedSet) => saveSet(exerciseIndex, setIndex, updatedSet),
      onSaveAndNext: setIndex < exercise.sets.length - 1
          ? (updatedSet) {
              saveSet(exerciseIndex, setIndex, updatedSet);
              Future.microtask(() => _showEditTemplateSetModal(exerciseIndex, setIndex + 1));
            }
          : null,
      onSaveAndPrevious: setIndex > 0
          ? (updatedSet) {
              saveSet(exerciseIndex, setIndex, updatedSet);
              Future.microtask(() => _showEditTemplateSetModal(exerciseIndex, setIndex - 1));
            }
          : null,
      onApplyToAll: (updatedSet) {
        for (int i = 0; i < exercise.sets.length; i++) {
          saveSet(exerciseIndex, i, updatedSet);
        }
      },
    );
  }

  /// Warmup toggle button widget
  Widget _buildWarmupToggle(int index) {
    final exercise = _exercises[index];
    final isSupersetWithSubExercises = exercise.type == ExerciseType.superset &&
        exercise.subExercises != null &&
        exercise.subExercises!.isNotEmpty;

    // Don't show warmup for supersets
    if (isSupersetWithSubExercises) return const SizedBox.shrink();

    final isEnabled = _warmupEnabled[index] ?? false;
    return GestureDetector(
      onTap: () => _toggleWarmup(index),
      onLongPress: () {
        if (isEnabled) _showWarmupPercentageConfig();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isEnabled
              ? context.colors.warning.withValues(alpha: 0.15)
              : context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled
                ? context.colors.warning.withValues(alpha: 0.4)
                : context.colors.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.localFireDepartment,
              size: 14,
              color: isEnabled ? context.colors.warning : context.colors.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 2),
            Text(
              'W',
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isEnabled ? context.colors.warning : context.colors.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle warmup for an exercise
  void _toggleWarmup(int exerciseIndex) {
    final isCurrentlyEnabled = _warmupEnabled[exerciseIndex] ?? false;
    final isExpanded = _expandedExercises[exerciseIndex] ?? false;

    if (!isCurrentlyEnabled) {
      setState(() {
        _warmupEnabled[exerciseIndex] = true;
        if (!isExpanded) _expandedExercises[exerciseIndex] = true;
      });
      _markAsChanged();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWarmupPercentageConfig();
      });
    } else {
      setState(() {
        _warmupEnabled[exerciseIndex] = false;
      });
      _markAsChanged();
    }
  }

  /// Generate warmup sets from percentages
  List<_WarmupSet> _generateWarmupSets(int exerciseIndex, ExerciseTemplate exercise) {
    final firstSet = exercise.sets.firstOrNull;
    final baseWeight = firstSet?.targetWeight ?? 0;
    if (baseWeight <= 0) return [];

    final overrides = _warmupOverrides[exerciseIndex] ?? {};

    return _warmupPercentages.asMap().entries.map((entry) {
      final i = entry.key;
      final percent = entry.value;

      final override = overrides[i];
      if (override != null) {
        return _WarmupSet(weight: override.weight, reps: override.reps, percent: percent);
      }

      final weight = _smartRound(baseWeight * percent / 100);
      final baseReps = firstSet?.targetReps ?? 10;
      final reps = percent <= 50 ? (baseReps * 0.5).round().clamp(3, 8) : (baseReps * 0.6).round().clamp(3, 8);
      return _WarmupSet(weight: weight, reps: reps, percent: percent);
    }).toList();
  }

  /// Smart rounding for plate-friendly weights
  static double _smartRound(double weight) {
    if (weight <= 0) return weight;
    if (weight < 20) {
      return (weight * 2).round() / 2; // Round to 0.5kg
    } else {
      return (weight / 2.5).round() * 2.5; // Round to 2.5kg
    }
  }

  /// Show warmup percentage configuration bottom sheet
  void _showWarmupPercentageConfig() {
    final tempPercentages = List<int>.from(_warmupPercentages);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: context.colors.surface.withValues(alpha: 0),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewPadding.bottom + 16,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.localFireDepartment, color: context.colors.warning, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.warmupConfig,
                        style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const SemanticIcon(icon: AppIcons.close, semanticLabel: 'Close'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.warmupConfigDescription,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              // Percentage chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(tempPercentages.length, (i) {
                  return GestureDetector(
                    onTap: () {
                      final options = [30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90];
                      final currentIdx = options.indexOf(tempPercentages[i]);
                      final nextIdx = (currentIdx + 1) % options.length;
                      setSheetState(() {
                        tempPercentages[i] = options[nextIdx];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: context.colors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.colors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${context.l10n.warmupSetLabel} ${i + 1}',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.warning,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${tempPercentages[i]}%',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              // Add/remove warmup set buttons
              Row(
                children: [
                  if (tempPercentages.length > 1)
                    TextButton.icon(
                      onPressed: () {
                        setSheetState(() => tempPercentages.removeLast());
                      },
                      icon: Icon(AppIcons.removeCircleOutline, size: 16, color: context.colors.error),
                      label: Text(
                        context.l10n.removeSet,
                        style: context.textTheme.labelSmall?.copyWith(color: context.colors.error),
                      ),
                    ),
                  const Spacer(),
                  if (tempPercentages.length < 6)
                    TextButton.icon(
                      onPressed: () {
                        final lastPercent = tempPercentages.last;
                        final newPercent = ((lastPercent + 100) / 2).round();
                        final snapped = (newPercent / 5).round() * 5;
                        setSheetState(() => tempPercentages.add(snapped.clamp(30, 95)));
                      },
                      icon: Icon(AppIcons.add, size: 16, color: context.colors.warning),
                      label: Text(
                        context.l10n.addSet,
                        style: context.textTheme.labelSmall?.copyWith(color: context.colors.warning),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _warmupPercentages = tempPercentages;
                      // Clear overrides when percentages change
                      _warmupOverrides.clear();
                    });
                    _markAsChanged();
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.warning,
                    foregroundColor: context.colors.onPrimary,
                  ),
                  child: Text(context.l10n.done),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Recalculate warmup percent based on actual weight vs base weight
  int _recalcPercent(int exerciseIndex, double weight, int originalPercent) {
    final baseWeight = _exercises[exerciseIndex].sets.firstOrNull?.targetWeight ?? 0;
    if (baseWeight <= 0) return originalPercent;
    return ((weight / baseWeight) * 100).round().clamp(1, 100);
  }

  /// Create a _WarmupSet override with recalculated percent
  _WarmupSet _makeOverride(int exerciseIndex, ExerciseSet updatedSet, _WarmupSet original) {
    final w = updatedSet.weight ?? original.weight;
    final r = updatedSet.reps ?? original.reps;
    return _WarmupSet(
      weight: w,
      reps: r,
      percent: _recalcPercent(exerciseIndex, w, original.percent),
    );
  }

  /// Edit a single warmup set via MinimalSetEditSheet
  void _editWarmupSet(int exerciseIndex, int warmupIndex, _WarmupSet warmup) {
    final exercise = _exercises[exerciseIndex];
    final allWarmups = _generateWarmupSets(exerciseIndex, exercise);
    final baseWeight = exercise.sets.firstOrNull?.targetWeight ?? 0;

    final exerciseSet = ExerciseSet(
      setNumber: warmupIndex + 1,
      weight: warmup.weight,
      reps: warmup.reps,
    );

    final allSets = allWarmups.asMap().entries.map((e) => ExerciseSet(
      setNumber: e.key + 1,
      weight: e.value.weight,
      reps: e.value.reps,
    )).toList();

    // Calculate suggested weight/reps from the percentage
    final suggestedWeight = baseWeight > 0 ? _smartRound(baseWeight * warmup.percent / 100) : null;
    final baseReps = exercise.sets.firstOrNull?.targetReps ?? 10;
    final suggestedReps = warmup.percent <= 50
        ? (baseReps * 0.5).round().clamp(3, 8)
        : (baseReps * 0.6).round().clamp(3, 8);

    context.showMinimalSetEditSheet(
      exerciseSet: exerciseSet,
      currentSetIndex: warmupIndex,
      totalSets: allWarmups.length,
      allSets: allSets,
      suggestedWeight: suggestedWeight,
      suggestedReps: suggestedReps,
      suggestedSource: '${warmup.percent}%',
      onSave: (updatedSet) {
        setState(() {
          _warmupOverrides[exerciseIndex] ??= {};
          _warmupOverrides[exerciseIndex]![warmupIndex] = _makeOverride(exerciseIndex, updatedSet, warmup);
        });
        _markAsChanged();
      },
      onSaveAndNext: warmupIndex < allWarmups.length - 1
          ? (updatedSet) {
              setState(() {
                _warmupOverrides[exerciseIndex] ??= {};
                _warmupOverrides[exerciseIndex]![warmupIndex] = _makeOverride(exerciseIndex, updatedSet, warmup);
              });
              _markAsChanged();
              Future.microtask(() {
                final nextWarmups = _generateWarmupSets(exerciseIndex, _exercises[exerciseIndex]);
                if (warmupIndex + 1 < nextWarmups.length) {
                  _editWarmupSet(exerciseIndex, warmupIndex + 1, nextWarmups[warmupIndex + 1]);
                }
              });
            }
          : null,
      onSaveAndPrevious: warmupIndex > 0
          ? (updatedSet) {
              setState(() {
                _warmupOverrides[exerciseIndex] ??= {};
                _warmupOverrides[exerciseIndex]![warmupIndex] = _makeOverride(exerciseIndex, updatedSet, warmup);
              });
              _markAsChanged();
              Future.microtask(() {
                final prevWarmups = _generateWarmupSets(exerciseIndex, _exercises[exerciseIndex]);
                if (warmupIndex - 1 >= 0) {
                  _editWarmupSet(exerciseIndex, warmupIndex - 1, prevWarmups[warmupIndex - 1]);
                }
              });
            }
          : null,
      onApplyToAll: (updatedSet) {
        setState(() {
          final w = updatedSet.weight ?? warmup.weight;
          final r = updatedSet.reps ?? warmup.reps;
          _warmupOverrides[exerciseIndex] ??= {};
          for (int i = 0; i < allWarmups.length; i++) {
            _warmupOverrides[exerciseIndex]![i] = _WarmupSet(
              weight: w,
              reps: r,
              percent: _recalcPercent(exerciseIndex, w, allWarmups[i].percent),
            );
          }
        });
        _markAsChanged();
      },
    );
  }

  /// Build warmup sets display (2-per-row, amber colored)
  Widget _buildWarmupSets(int exerciseIndex, ExerciseTemplate exercise) {
    final isSupersetWithSubExercises = exercise.type == ExerciseType.superset &&
        exercise.subExercises != null &&
        exercise.subExercises!.isNotEmpty;
    if (isSupersetWithSubExercises) return const SizedBox.shrink();

    final warmupSets = _generateWarmupSets(exerciseIndex, exercise);
    if (warmupSets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.warning.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: context.colors.warning.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(AppIcons.infoOutline, size: 16, color: context.colors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.warmupNeedsWeight,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.warning,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2-per-row layout - each chip individually tappable
    final rows = <Widget>[];
    for (int i = 0; i < warmupSets.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _editWarmupSet(exerciseIndex, i, warmupSets[i]),
                  child: _buildWarmupChip(warmupSets[i]),
                ),
              ),
              const SizedBox(width: 6),
              if (i + 1 < warmupSets.length)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _editWarmupSet(exerciseIndex, i + 1, warmupSets[i + 1]),
                    child: _buildWarmupChip(warmupSets[i + 1]),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warmup label - tappable for percentage config
          GestureDetector(
            onTap: () => _showWarmupPercentageConfig(),
            child: Row(
              children: [
                Icon(AppIcons.localFireDepartment, size: 12, color: context.colors.warning),
                const SizedBox(width: 4),
                Text(
                  context.l10n.warmupSets,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                Icon(AppIcons.edit, size: 12, color: context.colors.warning.withValues(alpha: 0.5)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...rows,
          Divider(color: context.colors.warning.withValues(alpha: 0.2), height: 12),
        ],
      ),
    );
  }

  Widget _buildWarmupChip(_WarmupSet warmup) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: context.colors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${warmup.percent}%',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.warning.withValues(alpha: 0.6),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${warmup.weight.toStringAsFixed(1)} kg',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.warning,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          Text(
            ' × ${warmup.reps}',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.warning.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showRestTimePicker(int exerciseIndex) {
    final exerciseTemplate = _exercises[exerciseIndex];

    ModalService.showBottomSheet(
      context,
      child: RestTimePickerModal(
        initialRestTime: exerciseTemplate.restTime,
        onRestTimeSelected: (restTime) {
          setState(() {
            _exercises[exerciseIndex] = exerciseTemplate.copyWith(
              restTime: restTime,
            );
          });
          _markAsChanged();
        },
      ),
    );
  }

  String _formatRestTime(int seconds) {
    if (seconds == 0) return '0s';

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes == 0) {
      return '${seconds}s';
    } else if (remainingSeconds == 0) {
      return '${minutes}min';
    } else {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }
}

class _WarmupSet {
  const _WarmupSet({
    required this.weight,
    required this.reps,
    required this.percent,
  });
  final double weight;
  final int reps;
  final int percent;
}
