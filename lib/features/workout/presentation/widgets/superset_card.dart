import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_options_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_history_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_sequential_execution_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

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
  bool _isExpanded = false;

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
              icon: Icons.swap_horiz,
              label: l10n.replace,
              color: Colors.green,
              onTap: () {
                HapticFeedback.mediumImpact();
                if (widget.onReplace != null) widget.onReplace!();
              },
            ),
            const SizedBox(width: 8),
            _buildSwipeAction(
              context,
              icon: Icons.edit,
              label: l10n.edit,
              color: Colors.blue,
              onTap: () {
                HapticFeedback.mediumImpact();
                if (widget.onEdit != null) widget.onEdit!();
              },
            ),
            const SizedBox(width: 8),
            _buildSwipeAction(
              context,
              icon: Icons.delete,
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
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: widget.isReorderMode ? null : widget.onTap,
          onLongPress: widget.isReorderMode ? null : () => _showSupersetOptions(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del superset
                _buildSupersetHeader(context, l10n),
                const SizedBox(height: 12),
                
                // Lista degli esercizi nel superset
                _buildExercisesList(context, l10n),
                const SizedBox(height: 16),
                
                // Set del superset
                _buildSupersetSets(context, l10n, config),
                
                // Note del superset (se presenti)
                if (widget.superset.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  _buildNotesSection(context, l10n),
                ],
              ],
            ),
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
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
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
        title: Text(l10n.deleteSuperset ?? 'Delete Superset'),
        content: const Text('Are you sure you want to delete this superset?'),
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
    return Row(
      children: [
        // Icona superset
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.secondary,
                context.colors.secondary.withValues(alpha: 0.7),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.link,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        
        // Titolo e badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Badge SUPERSET
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: context.colors.secondary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      l10n.exerciseTypeSuperset.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: context.colors.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Nome del superset
                  Expanded(
                    child: Text(
                      widget.superset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Info sui set
              Text(
                '${widget.superset.supersetSets.length} rounds • ${widget.superset.exercises.length} exercises',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
        
        // Menu button
        IconButton(
          onPressed: () => _showSupersetOptions(context),
          icon: const Icon(Icons.more_vert),
          tooltip: 'Options',
        ),
      ],
    );
  }

  Widget _buildExercisesList(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
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
                Icons.fitness_center,
                size: 16,
                color: context.colors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Exercises',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
              const Spacer(),

              // Expand/collapse button - hidden in reorder mode
              if (!widget.isReorderMode)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isExpanded ? 'Less' : 'More',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 16,
                        color: context.colors.primary,
                      ),
                    ],
                  ),
                )
              else
                // Reorder mode indicator
                Text(
                  '${widget.superset.exercises.length} esercizi',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Lista esercizi - always collapsed in reorder mode
          if (!widget.isReorderMode && _isExpanded) ...[
            ...widget.superset.exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index < widget.superset.exercises.length - 1 ? 8 : 0),
                child: _buildExerciseRow(context, exercise, index + 1),
              );
            }),
          ] else ...[
            // Vista compatta - prima riga degli esercizi (or reorder mode)
            _buildCompactExercisesList(context),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseRow(BuildContext context, Exercise exercise, int number) {
    return InkWell(
      onTap: () => _showExerciseOptions(context, exercise),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            // Numero esercizio
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Nome esercizio
            Expanded(
              child: Text(
                exercise.name,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Icona per indicare che è cliccabile
            Icon(
              Icons.info_outline,
              size: 16,
              color: context.colors.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            
            // Categoria
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                exercise.category.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactExercisesList(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: widget.superset.exercises.asMap().entries.map((entry) {
        final index = entry.key;
        final exercise = entry.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${index + 1}.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                exercise.name,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSupersetSets(BuildContext context, AppLocalizations l10n, config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.repeat,
              size: 16,
              color: context.colors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Sets (${widget.superset.supersetSets.where((s) => s.isFullyCompleted).length}/${widget.superset.supersetSets.length})',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        ...widget.superset.supersetSets.asMap().entries.map((entry) {
          final index = entry.key;
          final supersetSet = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index < widget.superset.supersetSets.length - 1 ? 12 : 0),
            child: _buildEnhancedSupersetSetRow(context, supersetSet, index + 1, l10n, config),
          );
        }),
      ],
    );
  }


  Widget _buildNotesSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note,
                size: 16,
                color: context.colors.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.notes,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.superset.notes!,
            style: context.textTheme.bodySmall,
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
              leading: const Icon(Icons.edit),
              title: const Text('Edit Superset'),
              onTap: () {
                Navigator.pop(context);
                if (widget.onEdit != null) widget.onEdit!();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement duplicate functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: context.colors.error),
              title: Text(
                'Delete Superset',
                style: TextStyle(color: context.colors.error),
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


  Widget _buildEnhancedSupersetSetRow(BuildContext context, SupersetSet supersetSet, int setNumber, AppLocalizations l10n, config) {
    final isFullyCompleted = supersetSet.isFullyCompleted;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFullyCompleted 
            ? context.colors.primaryContainer.withValues(alpha: 0.2)
            : context.colors.surfaceContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFullyCompleted 
              ? context.colors.primary.withValues(alpha: 0.3)
              : context.colors.outline.withValues(alpha: 0.2),
          width: isFullyCompleted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Set header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isFullyCompleted 
                      ? context.colors.primary
                      : context.colors.outline.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isFullyCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          '$setNumber',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Set $setNumber',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${supersetSet.completedExercisesCount}/${supersetSet.exerciseData.length} completed',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Exercise rows with individual toggles
          ...widget.superset.exercises.map((exercise) {
            final exerciseData = supersetSet.exerciseData[exercise.id];
            if (exerciseData == null) return const SizedBox.shrink();
            
            return _buildExerciseSetRow(
              context, 
              exercise, 
              exerciseData, 
              supersetSet,
              setNumber,
              l10n,
              config,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExerciseSetRow(
    BuildContext context, 
    Exercise exercise, 
    SupersetExerciseData exerciseData,
    SupersetSet supersetSet,
    int setNumber,
    AppLocalizations l10n,
    config,
  ) {
    return GestureDetector(
      onTap: () => _handleExerciseToggle(context, exercise, exerciseData, supersetSet),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: exerciseData.isCompleted 
              ? context.colors.tertiary.withValues(alpha: 0.1)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: exerciseData.isCompleted 
                ? context.colors.tertiary.withValues(alpha: 0.3)
                : context.colors.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            // Weight display
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Text(
                    (exerciseData.actualWeight ?? exerciseData.targetWeight ?? 0).toStringAsFixed(1),
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: exerciseData.isCompleted 
                          ? context.colors.tertiary
                          : context.colors.onSurface,
                    ),
                  ),
                  Text(
                    'kg',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            // Reps display
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Text(
                    '×',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${exerciseData.actualReps ?? exerciseData.targetReps ?? 0}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: exerciseData.isCompleted 
                          ? context.colors.tertiary
                          : context.colors.onSurface,
                    ),
                  ),
                  Text(
                    ' reps',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            // RPE display (if available)
            if (exerciseData.rpe != null)
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRPEColor(exerciseData.rpe!).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'RPE ${exerciseData.rpe}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getRPEColor(exerciseData.rpe!),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              const Expanded(flex: 1, child: SizedBox()),
            
            const SizedBox(width: 12),
            
            // Completion toggle on the right (like single cards)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: exerciseData.isCompleted 
                      ? context.colors.tertiary
                      : context.colors.outline,
                  width: 2,
                ),
                color: exerciseData.isCompleted 
                    ? context.colors.tertiary
                    : Colors.transparent,
              ),
              child: exerciseData.isCompleted 
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRPEColor(int rpe) {
    if (rpe <= 6) return Colors.green;
    if (rpe <= 7) return Colors.lightGreen;
    if (rpe <= 8) return Colors.orange;
    if (rpe <= 9) return Colors.deepOrange;
    return Colors.red;
  }

  void _handleExerciseToggle(
    BuildContext context,
    Exercise exercise,
    SupersetExerciseData exerciseData,
    SupersetSet supersetSet,
  ) {
    HapticFeedback.lightImpact();

    // ✅ NUOVO COMPORTAMENTO: Esegui TUTTO il round in modo sequenziale
    if (!supersetSet.isFullyCompleted) {
      // Apri il nuovo widget sequenziale per completare TUTTO il round
      _startSupersetRound(context, supersetSet);
    } else {
      // Round già completato → deseleziona TUTTO il round
      _undoRoundCompletion(context, supersetSet);
    }
  }

  /// ✅ NUOVO: Avvia esecuzione sequenziale del round completo
  void _startSupersetRound(BuildContext context, SupersetSet supersetSet) {
    HapticFeedback.mediumImpact();

    final roundIndex = supersetSet.setNumber - 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // Non permettere chiusura accidentale
      enableDrag: false, // Non permettere drag down per chiudere
      backgroundColor: Colors.transparent,
      builder: (context) => SupersetSequentialExecutionSheet(
        superset: widget.superset,
        roundIndex: roundIndex,
        onRoundCompleted: (completedRound) {
          // Aggiorna lo stato del round completato
          widget.onSupersetSetUpdate?.call(completedRound);
        },
        onAllRoundsCompleted: () {
          // Tutti i round completati
          debugPrint('✅ Tutti i round del superset completati!');
        },
      ),
    );
  }

  /// ✅ NUOVO: Annulla completamento di tutto il round
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

  void _showExerciseOptions(BuildContext context, Exercise exercise) {
    ExerciseOptionsModal.show(
      context,
      exercise,
      onHistory: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ExerciseHistoryBottomSheet(
            exerciseName: exercise.name,
          ),
        );
      },
    );
  }
}
