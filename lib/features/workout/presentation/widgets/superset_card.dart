import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/set_display_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/tut_info_dialog.dart';

/// Tier-1 SupersetCard che mostra tutti gli esercizi del superset in una singola card
class SupersetCard extends ConsumerStatefulWidget {

  const SupersetCard({
    super.key,
    required this.superset,
    required this.index,
    required this.onTap,
    required this.onDelete,
    this.onEdit,
    this.onReplace,
    this.onSetUpdate,
    this.onSetToggleComplete,
    this.onExerciseUpdate,
    this.onSupersetSetUpdate,
    this.isReorderMode = false,
  });
  final SupersetExercise superset;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onReplace;
  final Function(ExerciseSet)? onSetUpdate;
  final Function(ExerciseSet)? onSetToggleComplete;
  final Function(Exercise)? onExerciseUpdate;
  final Function(SupersetSet)? onSupersetSetUpdate;
  final bool isReorderMode;

  @override
  ConsumerState<SupersetCard> createState() => _SupersetCardState();
}

class _SupersetCardState extends ConsumerState<SupersetCard> {
  // ✅ FIX Issue 1: Manual expand override ONLY when all completed (to re-expand)
  bool _manualExpandOverride = false;

  /// Always expanded, auto-collapse ONLY when all sets are completed
  /// Manual toggle only allowed when completed (to re-expand for review)
  bool get _isExpanded {
    final allCompleted = widget.superset.supersetSets.every((s) => s.isFullyCompleted);
    // If not completed → always expanded (no manual override)
    if (!allCompleted) return true;
    // If completed → allow manual re-expand
    return _manualExpandOverride;
  }

  bool get _allSetsCompleted => widget.superset.supersetSets.every((s) => s.isFullyCompleted);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final config = ref.watch(appConfigProvider);
    
    return Dismissible(
      key: Key('superset_${widget.superset.name}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Don't actually dismiss - just handle the gesture
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              context.colors.error.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSwipeAction(
              context,
              icon: AppIcons.swapHoriz,
              label: l10n.replace,
              color: context.colors.success,
              onTap: () {
                HapticFeedback.mediumImpact();
                if (widget.onReplace != null) widget.onReplace!();
              },
            ),
            const SizedBox(width: 8),
            _buildSwipeAction(
              context,
              icon: AppIcons.edit,
              label: l10n.edit,
              color: context.colors.primary,
              onTap: () {
                HapticFeedback.mediumImpact();
                if (widget.onEdit != null) widget.onEdit!();
              },
            ),
            const SizedBox(width: 8),
            _buildSwipeAction(
              context,
              icon: AppIcons.delete,
              label: l10n.delete,
              color: context.colors.error,
              onTap: () {
                HapticFeedback.mediumImpact();
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: widget.isReorderMode ? null : widget.onTap,
        onLongPress: widget.isReorderMode ? null : () => _showSupersetOptions(context),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del superset (compact)
              _buildSupersetHeader(context, l10n),

              // Sets section (collapsible)
              if (_isExpanded) ...[
                const Divider(height: 1),
                _buildSupersetSets(context, l10n, config),
              ],

              // Note del superset (se presenti)
              if (widget.superset.notes?.isNotEmpty == true && _isExpanded) ...[
                const Divider(height: 1),
                _buildNotesSection(context, l10n),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: context.colors.surface, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.surface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSuperset),
        content: Text(l10n.confirmDeleteSupersetMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildSupersetHeader(BuildContext context, AppLocalizations l10n) {
    final completedSets = widget.superset.supersetSets.where((s) => s.isFullyCompleted).length;
    final totalSets = widget.superset.supersetSets.length;
    final allCompleted = completedSets == totalSets;

    return GestureDetector(
      // ✅ FIX Issue 1: Only allow toggle when ALL sets are completed
      onTap: _allSetsCompleted ? () {
        setState(() {
          _manualExpandOverride = !_manualExpandOverride;
        });
        HapticFeedback.lightImpact();
      } : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Compact superset icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: allCompleted
                    ? context.colors.tertiary.withValues(alpha: 0.15)
                    : context.colors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                AppIcons.link,
                color: allCompleted ? context.colors.tertiary : context.colors.secondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),

            // Nome del superset + info compatta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.superset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: allCompleted ? TextDecoration.lineThrough : null,
                      color: allCompleted ? context.colors.onSurfaceVariant : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Compact exercise names preview
                  Text(
                    widget.superset.exercises.map((e) => e.name).join(' + '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Progress indicator (compact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: allCompleted
                    ? context.colors.tertiary.withValues(alpha: 0.1)
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$completedSets/$totalSets',
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: allCompleted ? context.colors.tertiary : context.colors.onSurfaceVariant,
                ),
              ),
            ),
            // ✅ FIX Issue 1: Only show chevron when completed (can re-expand)
            if (_allSetsCompleted) ...[
              const SizedBox(width: 4),
              Icon(
                _isExpanded ? AppIcons.keyboardArrowUp : AppIcons.keyboardArrowDown,
                size: 20,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSupersetSets(BuildContext context, AppLocalizations l10n, config) {
    final completedSets = widget.superset.supersetSets.where((s) => s.isFullyCompleted).length;
    final totalSets = widget.superset.supersetSets.length;
    // ✅ FIX Issue 2: Use setDisplayProvider for Comodo/Compatto mode
    final displayMode = ref.watch(setDisplayProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header "Serie (0/3)" + "Weight × Reps" - like ExerciseListItem
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  l10n.exerciseListSetsProgress(completedSets, totalSets),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'Weight × Reps',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Set rows - pass displayMode for Comodo/Compatto styling
          ...widget.superset.supersetSets.asMap().entries.map((entry) {
            final index = entry.key;
            final supersetSet = entry.value;
            return _buildSetRowLikeExerciseListItem(
              context, supersetSet, index + 1, l10n, config, displayMode,
            );
          }),
        ],
      ),
    );
  }


  Widget _buildNotesSection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemanticIcon(
            icon: AppIcons.note,
            semanticLabel: 'Note',
            size: AppIconSize.tiny,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.superset.notes!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupersetOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const SemanticIcon(
  icon: AppIcons.edit,
  semanticLabel: 'Edit',
),
              title: Text(context.l10n.editSuperset),
              onTap: () {
                Navigator.pop(context);
                if (widget.onEdit != null) widget.onEdit!();
              },
            ),
            ListTile(
              leading: const SemanticIcon(
  icon: AppIcons.iconCopy,
  semanticLabel: 'Icon copy',
),
              title: Text(context.l10n.duplicate),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement duplicate functionality
              },
            ),
            ListTile(
              leading: Icon(AppIcons.delete, color: context.colors.error),
              title: Text(
                context.l10n.deleteSuperset,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getRPEColor(int rpe) {
    if (rpe <= 6) return context.colors.success;
    if (rpe <= 7) return context.colors.success;
    if (rpe <= 8) return context.colors.secondary;
    if (rpe <= 9) return context.colors.warning;
    return context.colors.error;
  }

  /// Set row styled to show ALL exercises in the round
  /// ✅ NEW: Shows each exercise with its weight × reps so user knows what to do
  /// ✅ FIX Issue 2: Uses SetDisplayMode for Comodo/Compatto styling
  Widget _buildSetRowLikeExerciseListItem(
    BuildContext context,
    SupersetSet supersetSet,
    int setNumber,
    AppLocalizations l10n,
    config,
    SetDisplayMode displayMode,
  ) {
    final isFullyCompleted = supersetSet.isFullyCompleted;
    final exercises = widget.superset.exercises;

    return GestureDetector(
      onTap: () {
        if (!isFullyCompleted) {
          _startSupersetRound(context, supersetSet);
        } else {
          _undoRoundCompletion(context, supersetSet);
        }
      },
      // ✅ FIX: Use deferToChild so edit button can receive taps
      behavior: HitTestBehavior.deferToChild,
      child: Container(
        margin: EdgeInsets.only(bottom: displayMode.bottomMargin),
        padding: EdgeInsets.symmetric(
          horizontal: displayMode.horizontalPadding,
          vertical: displayMode.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: isFullyCompleted
              ? context.colors.tertiary.withValues(alpha: 0.1)
              : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(displayMode.borderRadius),
          border: isFullyCompleted
              ? Border.all(color: context.colors.tertiary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Round number in circle
            Container(
              width: displayMode.circleSize,
              height: displayMode.circleSize,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isFullyCompleted
                    ? context.colors.tertiary
                    : context.colors.outline.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$setNumber',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isFullyCompleted
                        ? context.colors.onTertiary
                        : context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ✅ NEW: Show ALL exercises in this round
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < exercises.length; i++) ...[
                    _buildExerciseRow(
                      context,
                      exercises[i],
                      supersetSet.exerciseData[exercises[i].id],
                      i,
                      exercises.length,
                      displayMode,
                    ),
                    if (i < exercises.length - 1)
                      SizedBox(height: displayMode == SetDisplayMode.compact ? 2 : 4),
                  ],
                ],
              ),
            ),

            // Action icons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Completion checkmark
                if (isFullyCompleted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SemanticIcon(
                      icon: AppIcons.checkCircle,
                      semanticLabel: 'Completed',
                      size: AppIconSize.small,
                      color: context.colors.tertiary,
                    ),
                  ),
                // Edit button
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _startSupersetRound(context, supersetSet);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SemanticIcon(
                      icon: AppIcons.edit,
                      semanticLabel: l10n.edit,
                      size: AppIconSize.small,
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build a single exercise row within a round
  Widget _buildExerciseRow(
    BuildContext context,
    Exercise exercise,
    SupersetExerciseData? exerciseData,
    int index,
    int totalExercises,
    SetDisplayMode displayMode,
  ) {
    final isCompleted = exerciseData?.isCompleted ?? false;
    final weight = exerciseData?.actualWeight ?? exerciseData?.targetWeight ?? 0.0;
    final reps = exerciseData?.actualReps ?? exerciseData?.targetReps ?? 0;

    // ✅ TUT visibility controlled by setDurationTracking toggle
    final config = ref.watch(appConfigProvider);
    final showTut = exercise.tut != null && (config.setDurationTracking ?? false);

    // Truncate exercise name if too long
    final maxNameLength = displayMode == SetDisplayMode.compact ? 12 : 16;
    final displayName = exercise.name.length > maxNameLength
        ? '${exercise.name.substring(0, maxNameLength)}...'
        : exercise.name;

    return Row(
      children: [
        // Exercise letter indicator (A, B, C...)
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isCompleted
                ? context.colors.tertiary.withValues(alpha: 0.2)
                : context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              String.fromCharCode(65 + index), // A, B, C...
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isCompleted
                    ? context.colors.tertiary
                    : context.colors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Exercise name
        Expanded(
          child: Text(
            displayName,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isCompleted
                  ? context.colors.onSurface.withValues(alpha: 0.7)
                  : context.colors.onSurface,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // ✅ TUT chip (if enabled and available) - Unified design with tap action
        if (showTut) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => showTutInfoBottomSheet(context, exercise.tut!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.colors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.secondary.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticIcon(
                    icon: AppIcons.timer,
                    semanticLabel: 'TUT',
                    size: 12, // Compact size for superset row
                    color: context.colors.secondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    exercise.tut!,
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 10, // Slightly smaller for superset row
                      fontWeight: FontWeight.w600,
                      color: context.colors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(width: 4),

        // Weight × Reps
        Text(
          '${weight.toStringAsFixed(1)} × $reps',
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: context.colors.onSurfaceVariant,
          ),
        ),

        // RPE badge (if completed)
        if (exerciseData?.rpe != null) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: _getRPEColor(exerciseData!.rpe!).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${exerciseData.rpe}',
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getRPEColor(exerciseData.rpe!),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// ✅ FIX Issue 3: Direttamente apre RpeSelectorBottomSheet con superset mode
  /// invece di SupersetSequentialExecutionSheet - uguale agli esercizi singoli
  void _startSupersetRound(BuildContext context, SupersetSet supersetSet) {
    HapticFeedback.mediumImpact();

    // ✅ Safety check: ensure exercises exist
    if (widget.superset.exercises.isEmpty) return;

    // Get first exercise data to create ExerciseSet
    final firstExercise = widget.superset.exercises.first;
    final exerciseData = supersetSet.exerciseData[firstExercise.id];

    if (exerciseData == null) return;

    // Create ExerciseSet from SupersetExerciseData
    final exerciseSet = ExerciseSet(
      id: firstExercise.id,
      setNumber: supersetSet.setNumber,
      weight: exerciseData.actualWeight ?? exerciseData.targetWeight,
      reps: exerciseData.targetReps,
      isCompleted: false,
    );

    // ✅ Open RpeSelectorBottomSheet directly with superset mode (swipe navigation)
    RpeSelectorBottomSheet.show(
      context: context,
      set: exerciseSet,
      targetReps: exerciseData.targetReps ?? 10,
      exercise: firstExercise,

      // ✅ SUPERSET MODE - enables swipe left/right between exercises
      isPartOfSuperset: true,
      supersetName: widget.superset.name,
      supersetExercises: widget.superset.exercises,
      supersetSet: supersetSet,
      currentExerciseIndex: 0,

      // ✅ Callback quando TUTTI gli esercizi del round sono completati
      onSupersetCompleteAll: (completeDataMap) {
        _handleRoundCompletion(supersetSet, completeDataMap);
      },

      // ✅ Callback per singolo esercizio (non usato in superset mode)
      onConfirm: (actualReps, actualWeight, rpe) {
        // Not used when isPartOfSuperset=true
      },
    );
  }

  /// Gestisce il completamento di tutti gli esercizi del round
  void _handleRoundCompletion(
    SupersetSet supersetSet,
    Map<int, SupersetExerciseCompleteData> completeDataMap,
  ) {
    // Converti i dati da index-based a ID-based
    final exerciseData = <String, SupersetExerciseData>{};

    for (var i = 0; i < widget.superset.exercises.length; i++) {
      final exercise = widget.superset.exercises[i];
      final data = completeDataMap[i];

      if (data != null) {
        final existing = supersetSet.exerciseData[exercise.id];

        exerciseData[exercise.id] = SupersetExerciseData(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          targetWeight: existing?.targetWeight ?? 0.0,
          targetReps: existing?.targetReps ?? 10,
          actualWeight: data.actualWeight,
          actualReps: data.actualReps,
          rpe: data.rpe,
          isCompleted: true,
        );
      }
    }

    // Crea SupersetSet completato
    final completedSet = SupersetSet(
      id: supersetSet.id,
      setNumber: supersetSet.setNumber,
      exerciseData: exerciseData,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    // Notifica completamento round
    widget.onSupersetSetUpdate?.call(completedSet);
  }

  /// Annulla completamento di tutto il round
  void _undoRoundCompletion(BuildContext context, SupersetSet supersetSet) {
    HapticFeedback.mediumImpact();

    // Deseleziona tutti gli esercizi del round
    final updatedExerciseData = <String, SupersetExerciseData>{};

    for (final entry in supersetSet.exerciseData.entries) {
      updatedExerciseData[entry.key] = entry.value.copyWith(
        isCompleted: false,
      );
    }

    final updatedSet = supersetSet.copyWith(
      exerciseData: updatedExerciseData,
      isCompleted: false,
      completedAt: null,
    );

    widget.onSupersetSetUpdate?.call(updatedSet);
  }
}
