import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_activity.dart';
import '../../data/repositories/exercise_activity_repository.dart';
import 'edit_set_modal.dart';
import 'unified_set_input_modal.dart';
import 'quick_edit_overlay_v2.dart';
import 'edit_exercise_modal.dart';
import 'rpe_selector_bottom_sheet.dart';
import 'superset_exercises_tooltip.dart';
import '../../../../shared/presentation/providers/app_config_provider.dart';
import '../../../../shared/domain/entities/app_config.dart';
import '../../../timer/presentation/providers/unified_timer_provider.dart';
import '../../../timer/presentation/providers/unified_timer_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/set_duration_tracker_provider.dart';
import 'exercise_start_button.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';
import 'warmup_suggestion_card.dart';
import 'scrollable_exercise_chips.dart';
import '../../../community/presentation/widgets/smart_suggestion_chip.dart';
import '../../../community/presentation/providers/community_provider.dart';
import '../../../community/presentation/providers/exercise_data_provider.dart';
import '../../../community/domain/entities/community_contribution.dart';
import '../../../community/presentation/widgets/animated_xp_bar.dart';
import '../providers/workout_provider.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import 'superset_execution_sheet_v2.dart';
import 'dropset_execution_sheet.dart';
import 'restpause_execution_sheet.dart';
import 'set_execution_timer_widget.dart';

class OptimizedExerciseListItem extends ConsumerStatefulWidget {
  final String exerciseId;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(ExerciseSet)? onSetUpdate;
  final Function(ExerciseSet)? onSetToggleComplete;
  final Function(Exercise)? onExerciseUpdate;

  const OptimizedExerciseListItem({
    super.key,
    required this.exerciseId,
    required this.index,
    required this.onTap,
    required this.onDelete,
    this.onSetUpdate,
    this.onSetToggleComplete,
    this.onExerciseUpdate,
  });

  @override
  ConsumerState<OptimizedExerciseListItem> createState() => _OptimizedExerciseListItemState();
}

class _OptimizedExerciseListItemState extends ConsumerState<OptimizedExerciseListItem> {
  Exercise? get exercise => ref.read(exerciseByIdProvider(widget.exerciseId));
  
  bool _exerciseStarted = false;
  ExerciseActivity? _lastActivity;
  bool _loadingHistory = false;
  bool _warmupSuggestionDismissed = false;
  bool _isEditingNotes = false;
  late TextEditingController _notesController;
  Timer? _saveDebounceTimer;
  bool _savingNotes = false;
  bool _showCommunitySuggestion = false;
  String? _suggestionText;
  ContributionType? _suggestionType;
  String? _contextType;
  Map<String, dynamic>? _exerciseData;
  
  // Quick edit prevention after set completion
  bool _isQuickEditBlocked = false;
  Timer? _quickEditBlockTimer;
  
  // TIER-1 Real-time tracking state
  int? _currentTrackingSetNumber;
  bool _isTrackingSet = false;
  List<double> _completedSetTimes = [];
  
  @override
  void initState() {
    super.initState();
    _loadLastActivity();
    _notesController = TextEditingController(text: exercise?.notes ?? '');
    _notesController.addListener(_onNotesChanged);
    _checkForCommunitySuggestions();
    _loadExerciseData();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload last activity when returning to screen or after workout completion
    _loadLastActivity();
  }
  
  Future<void> _loadExerciseData() async {
    final data = await _loadExerciseDataFromJson();
    if (mounted && data != null) {
      setState(() {
        _exerciseData = data;
      });
    }
  }
  
  @override
  void dispose() {
    _notesController.removeListener(_onNotesChanged);
    _notesController.dispose();
    _saveDebounceTimer?.cancel();
    _quickEditBlockTimer?.cancel();
    super.dispose();
  }

  void _onNotesChanged() {
    if (!_isEditingNotes) return;
    
    // Cancel previous timer
    _saveDebounceTimer?.cancel();
    
    // Start new timer for auto-save after 750ms
    _saveDebounceTimer = Timer(const Duration(milliseconds: 750), () {
      _saveNotes();
    });
  }
  
  Future<void> _saveNotes() async {
    final ex = exercise;
    if (ex == null || _notesController.text == ex.notes) return;
    
    setState(() {
      _savingNotes = true;
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Save notes
    final updated = ex.copyWith(notes: _notesController.text);
    widget.onExerciseUpdate?.call(updated);
    
    // Show success animation
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      setState(() {
        _savingNotes = false;
      });
      
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('Note salvate'),
            ],
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
  
  void _toggleNotesEdit() {
    setState(() {
      _isEditingNotes = !_isEditingNotes;
    });
    
    if (_isEditingNotes) {
      HapticFeedback.lightImpact();
      // Focus on text field will be handled by autofocus
    } else {
      // Save if there are changes
      final ex = exercise;
      if (ex != null && _notesController.text != ex.notes) {
        _saveNotes();
      }
    }
  }

  Future<void> _loadLastActivity() async {
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;
    
    if (currentUser?.email != null) {
      // Use hybrid repository to get data from Hive for non-premium users
      final repository = ref.read(exerciseActivityRepositoryProvider);
      
      // Get recent activities for this exercise
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final allActivities = await repository.getUserActivities(
        userEmail: currentUser!.email!,
        limit: 100,
      );
      
      // Filter for this specific exercise
      final ex = exercise;
      if (ex == null) return;
      
      final activities = allActivities
          .where((activity) => activity.exerciseName == ex.name)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      if (mounted && activities.isNotEmpty) {
        setState(() {
          _lastActivity = activities.first;
        });
      }
    }
  }
  
  void _checkForCommunitySuggestions() {
    final ex = exercise;
    if (ex == null) return;
    
    // Check various conditions that might warrant a suggestion
    
    // 1. Exercise has no notes but community has popular tips
    if (ex.notes?.isEmpty ?? true) {
      setState(() {
        _suggestionText = '💡 Tips disponibili dalla community';
        _suggestionType = ContributionType.tip;
        _showCommunitySuggestion = true;
      });
      return;
    }
    
    // 2. Check if weight jumps are unusual
    if (ex.sets.length > 1) {
      final weights = ex.sets
          .map((s) => s.weight)
          .where((w) => w != null)
          .cast<double>()
          .toList();
      
      if (weights.isNotEmpty && weights.length > 1) {
        final maxWeight = weights.reduce((a, b) => a > b ? a : b);
        final minWeight = weights.reduce((a, b) => a < b ? a : b);
        
        if (maxWeight > 0 && minWeight > 0 && maxWeight > minWeight * 2) {
          setState(() {
            _suggestionText = '⚠️ Grande differenza di peso tra le serie';
            _suggestionType = ContributionType.warning;
            _showCommunitySuggestion = true;
          });
          return;
        }
      }
    }
    
    // 3. First time doing this exercise (no history)
    if (_lastActivity == null && ex.sets.isNotEmpty) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _suggestionText = AppLocalizations.of(context)!.longPressForExerciseInfo;
            _suggestionType = ContributionType.tip;
            _showCommunitySuggestion = true;
          });
        }
      });
    }
  }
  
  void _handleCommunitySuggestionTap() {
    // Simply dismiss the hint since it's just informational
    setState(() {
      _showCommunitySuggestion = false;
    });
  }
  
  void _showContributionModal() {
    final ex = exercise;
    if (ex == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommunityContributionModal(
        exercise: ex,
        suggestionType: _suggestionType ?? ContributionType.tip,
        initialSuggestion: _suggestionText,
        contextType: _contextType,
        exerciseData: _exerciseData,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exercise = ref.watch(exerciseByIdProvider(widget.exerciseId));
    if (exercise == null) {
      return const SizedBox.shrink();
    }
    
    // Watch analytics state to trigger reload when data changes
    ref.watch(analyticsProvider);
    
    final config = ref.watch(appConfigProvider);
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: () => _showExerciseOptions(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise header
              Row(
                children: [
                  _buildExerciseTypeIcon(context, exercise),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (exercise.type == ExerciseType.superset) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            l10n.superset,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.primary,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: Text(
                                          exercise!.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Show superset exercises if it's a superset
                                  if (exercise.type == ExerciseType.superset && exercise is SupersetExercise) ...[
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () => _showSupersetTooltip(context, exercise as SupersetExercise),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.link,
                                                size: 16,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${(exercise as SupersetExercise).exercises.length} esercizi',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Rest timer indicator (tappable)
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _showQuickTimerSettings(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: exercise.restTime != null
                                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                                      : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: exercise.restTime != null
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      exercise.restTime != null 
                                          ? Icons.timer_outlined
                                          : Icons.timer_off_outlined,
                                      size: 14,
                                      color: exercise.restTime != null
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      exercise.restTime != null
                                          ? _formatRestTime(exercise.restTime!)
                                          : 'Default',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: exercise.restTime != null 
                                            ? FontWeight.w600 
                                            : FontWeight.w500,
                                        color: exercise.restTime != null
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.edit,
                                      size: 10,
                                      color: exercise.restTime != null
                                          ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                                          : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        ScrollableExerciseChips(
                          exercise: exercise,
                          exerciseData: _exerciseData,
                          onTutTap: () {
                            // Mostra modal con spiegazione TUT
                            _showTutExplanationModal(context);
                          },
                        ),
                        if (_lastActivity != null) ...[
                          const SizedBox(height: 4),
                          _buildInsightChip(context),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showExerciseEditor(context);
                          break;
                        case 'duplicate':
                          _duplicateExercise();
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context);
                          break;
                        case 'insight':
                          _showExerciseHistory(context);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 20),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'insight',
                        child: Row(
                          children: [
                            Icon(Icons.insights, size: 20),
                            SizedBox(width: 8),
                            Text('Insight'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Notes section - always visible for editing
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _toggleNotesEdit,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  padding: EdgeInsets.all(_isEditingNotes ? 12 : 8),
                  decoration: BoxDecoration(
                    color: _isEditingNotes 
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isEditingNotes 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                      width: _isEditingNotes ? 2 : 0,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: _isEditingNotes ? 0.125 : 0, // 45 degree rotation
                        child: Icon(
                          _isEditingNotes ? Icons.edit : Icons.note,
                          size: 16,
                          color: _isEditingNotes 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isEditingNotes
                            ? TextField(
                                key: const ValueKey('notes-editor'),
                                controller: _notesController,
                                autofocus: true,
                                maxLines: null,
                                style: Theme.of(context).textTheme.bodySmall,
                                decoration: InputDecoration(
                                  hintText: 'Aggiungi note...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _toggleNotesEdit(),
                              )
                            : Text(
                                key: const ValueKey('notes-text'),
                                exercise.notes?.isNotEmpty == true 
                                  ? exercise.notes!
                                  : 'Tocca per aggiungere note',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: exercise.notes?.isNotEmpty == true
                                    ? Theme.of(context).colorScheme.onSurfaceVariant
                                    : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                                  fontStyle: exercise.notes?.isNotEmpty == true
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                                ),
                              ),
                        ),
                      ),
                      if (_savingNotes)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Start button for first set duration tracking
              if (!_exerciseStarted && exercise.sets.isNotEmpty)
                ExerciseStartButton(
                  exerciseId: exercise!.id,
                  exerciseName: exercise!.name,
                  onStarted: () {
                    setState(() {
                      _exerciseStarted = true;
                    });
                  },
                  isFirstSet: exercise.sets.where((s) => s.isCompleted).isEmpty,
                ),
              
              // Warmup suggestion (smart display logic)
              if (_shouldShowWarmupSuggestion(exercise!))
                WarmupSuggestionCard(
                  exerciseName: exercise!.name,
                  workingWeight: _getMaxWorkingWeight(exercise!),
                  targetReps: _getTargetReps(exercise!),
                  onAddWarmupSets: _addWarmupSets,
                  onDismiss: () {
                    // Store dismissal in local state or preferences
                  },
                ),
              
              // Community suggestion chip
              if (_showCommunitySuggestion && _suggestionText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SmartSuggestionChip(
                    suggestion: _suggestionText!,
                    icon: _getSuggestionIcon(),
                    onTap: _handleCommunitySuggestionTap,
                    onDismiss: () {
                      setState(() {
                        _showCommunitySuggestion = false;
                      });
                    },
                    displayDuration: const Duration(seconds: 7),
                  ),
                ),
              
              // Sets display
              _buildSetsSection(context, config, exercise),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseTypeIcon(BuildContext context, Exercise exercise) {
    final ex = exercise;
    if (ex == null) return const Icon(Icons.fitness_center);
    
    IconData icon;
    Color color;

    switch (ex.type) {
      case ExerciseType.single:
        icon = Icons.fitness_center;
        color = Theme.of(context).colorScheme.primary;
        break;
      case ExerciseType.superset:
        icon = Icons.repeat;
        color = Theme.of(context).colorScheme.secondary;  
        break;
      case ExerciseType.dropset:
        icon = Icons.trending_down;
        color = Theme.of(context).colorScheme.tertiary;
        break;
      case ExerciseType.restPause:
        icon = Icons.pause_circle;
        color = Theme.of(context).colorScheme.error;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  IconData _getSuggestionIcon() {
    switch (_suggestionType) {
      case ContributionType.tip:
        return Icons.lightbulb_outline;
      case ContributionType.warning:
        return Icons.warning_amber_rounded;
      case ContributionType.correction:
        return Icons.edit_note;
      case ContributionType.technique:
        return Icons.fitness_center;
      default:
        return Icons.tips_and_updates;
    }
  }
  
  Widget _buildCategoryChip(BuildContext context, Exercise exercise) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        exercise.category.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, Exercise exercise) {
    Color color;
    switch (exercise.type) {
      case ExerciseType.single:
        color = Theme.of(context).colorScheme.primary;
        break;
      case ExerciseType.superset:
        color = Theme.of(context).colorScheme.secondary;  
        break;
      case ExerciseType.dropset:
        color = Theme.of(context).colorScheme.tertiary;
        break;
      case ExerciseType.restPause:
        color = Theme.of(context).colorScheme.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        exercise.type.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSetsSection(BuildContext context, AppConfig config, Exercise exercise) {
    if (exercise.sets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'No sets yet - tap to add',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Sets (${exercise.sets.where((s) => s.isCompleted).length}/${exercise.sets.length})',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (exercise.sets.isNotEmpty)
              Text(
                'Weight × Reps',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        // TIER-1 Real-time execution timer
        if (_exerciseStarted && exercise.sets.any((s) => !s.isCompleted))
          _buildRealTimeTracker(context),
        
        ...exercise.sets.asMap().entries.map((entry) => 
          _buildSetItem(context, entry.key, entry.value, config, exercise),
        ),
        const SizedBox(height: 8),
        // Add set button
        InkWell(
          onTap: () => _addNewSet(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Set',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetItem(BuildContext context, int index, ExerciseSet set, AppConfig config, Exercise exercise) {
    final isWarmup = set.isWarmup;
    
    // Special handling for different exercise types
    if (exercise.type == ExerciseType.superset && exercise is SupersetExercise) {
      return _buildSupersetItem(context, index, set, config, exercise as SupersetExercise);
    }
    
    if (exercise.type == ExerciseType.dropset && exercise is DropSetExercise) {
      return _buildDropSetItem(context, index, set, config, exercise as DropSetExercise);
    }
    
    if (exercise.type == ExerciseType.restPause && exercise is RestPauseExercise) {
      return _buildRestPauseItem(context, index, set, config, exercise as RestPauseExercise);
    }
    
    return Dismissible(
      key: Key('${exercise.id}_set_${set.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(isWarmup ? 'Delete warmup set?' : 'Delete set ${index + 1}?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _deleteSet(set, index);
      },
      child: GestureDetector(
        onTap: widget.onSetToggleComplete != null 
            ? () => _toggleSetCompletionWithFeedback(context, set)
            : null,
        onDoubleTap: widget.onSetUpdate != null && !_isQuickEditBlocked
            ? () => _quickEditSet(context, set)
            : null,
        onLongPress: widget.onSetUpdate != null 
            ? () => _editSet(context, set)
            : null,
        child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isWarmup
              ? Colors.orange.withOpacity(0.05) // Warmup color
              : set.isCompleted 
                  ? Theme.of(context).colorScheme.tertiary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: isWarmup
              ? Border.all(color: Colors.orange.withOpacity(0.3))
              : set.isCompleted 
                  ? Border.all(color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3))
                  : null,
        ),
        child: Row(
          children: [
          // Set number with warmup indicator
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isWarmup
                  ? Colors.orange.withOpacity(0.3)
                  : set.isCompleted 
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isWarmup
                  ? const Icon(Icons.local_fire_department, size: 14, color: Colors.orange)
                  : Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: set.isCompleted 
                            ? Theme.of(context).colorScheme.onTertiary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Warmup badge
          if (isWarmup) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'W',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Set details
          Expanded(
            child: Row(
              children: [
                if (set.weight != null) ...[
                  Text(
                    set.weight!.formatWeight(config.measurementUnit),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: set.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('×', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 4),
                ],
                if (set.reps != null)
                  Text(
                    set.actualReps != null && set.isCompleted
                        ? '${set.actualReps}/${set.reps} reps'
                        : '${set.reps} reps',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: set.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                if (set.seconds != null)
                  Text(
                    '${set.seconds}s',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: set.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                
                // RPE indicator if completed
                if (set.isCompleted && set.rpe != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRpeIndicatorColor(set.rpe!).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getRpeIndicatorColor(set.rpe!).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'RPE ${set.rpe}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getRpeIndicatorColor(set.rpe!),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                
                // Duration indicator if completed and tracked
                if (set.isCompleted && set.setDurationMillis != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 10,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          SetDurationTracker.formatDuration(set.setDurationMillis),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Quick edit hint
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '✏️',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Completion status - clickable toggle
          InkWell(
            onTap: widget.onSetToggleComplete != null 
                ? () => _toggleSetCompletionWithFeedback(context, set) 
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: set.isCompleted
                    ? Icon(
                        Icons.check_circle,
                        key: const ValueKey('completed'),
                        size: 20,
                        color: Theme.of(context).colorScheme.tertiary,
                      )
                    : Icon(
                        Icons.radio_button_unchecked,
                        key: const ValueKey('uncompleted'),
                        size: 20,
                        color: Theme.of(context).colorScheme.outline,
                      ),
              ),
            ),
          ),
          ],
        ),
      ),
      ),
    );
  }
  
  void _addNewSet() {
    if (widget.onExerciseUpdate == null) return;
    final ex = exercise;
    if (ex == null) return;
    
    // Special handling for superset
    if (ex is SupersetExercise) {
      debugPrint('🔄 Adding new set to superset with ${ex.exercises.length} exercises');
      
      // Add a new set to each exercise in the superset
      final updatedExercises = ex.exercises.map((exercise) {
        // Get the last set's values as defaults for the new set
        ExerciseSet? lastSet;
        if (exercise.sets.isNotEmpty) {
          // Find the last non-warmup set
          final workingSets = exercise.sets.where((s) => !s.isWarmup).toList();
          lastSet = workingSets.isNotEmpty ? workingSets.last : exercise.sets.last;
        }
        
        // Create new set with default or copied values from THIS exercise
        final newSet = ExerciseSet(
          setNumber: exercise.sets.length + 1,
          weight: lastSet?.weight ?? 20.0,
          reps: lastSet?.reps ?? 10,
          isWarmup: false,
        );
        
        debugPrint('  - Adding set ${newSet.setNumber} to ${exercise.name}: ${newSet.weight}kg x ${newSet.reps} reps');
        
        final updatedSets = [...exercise.sets, newSet];
        return exercise.copyWith(sets: updatedSets);
      }).toList();
      
      // Also add a set to the superset's own sets array
      final newSupersetSet = ExerciseSet(
        setNumber: ex.sets.length + 1,
        weight: 0,
        reps: 0,
        isWarmup: false,
      );
      
      final updatedSupersetSets = [...ex.sets, newSupersetSet];
      
      final updatedSuperset = ex.copyWith(
        exercises: updatedExercises,
        sets: updatedSupersetSets,
      );
      
      widget.onExerciseUpdate!(updatedSuperset);
      
      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Superset ${newSupersetSet.setNumber} added'),
          duration: const Duration(milliseconds: 1200),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    } else {
      // Normal exercise handling
      // Get the last set's values as defaults for the new set
      ExerciseSet? lastSet;
      if (ex.sets.isNotEmpty) {
        // Find the last non-warmup set
        final workingSets = ex.sets.where((s) => !s.isWarmup).toList();
        lastSet = workingSets.isNotEmpty ? workingSets.last : ex.sets.last;
      }
      
      // Create new set with default or copied values
      final newSet = ExerciseSet(
        setNumber: ex.sets.length + 1,
        weight: lastSet?.weight ?? 0.0,
        reps: lastSet?.reps ?? 10,
        isWarmup: false,
      );
      
      final updatedSets = [...ex.sets, newSet];
      final updatedExercise = ex.copyWith(sets: updatedSets);
      widget.onExerciseUpdate!(updatedExercise);
      
      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Set ${newSet.setNumber} added'),
          duration: const Duration(milliseconds: 1200),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    
    HapticFeedback.lightImpact();
  }
  
  void _deleteSet(ExerciseSet set, int index) {
    if (widget.onExerciseUpdate == null) return;
    final ex = exercise;
    if (ex == null) return;
    
    // Special handling for superset
    if (ex is SupersetExercise) {
      debugPrint('🗑️ Deleting set ${index + 1} from superset');
      
      // Remove the set from each exercise in the superset
      final updatedExercises = ex.exercises.map((exercise) {
        if (index < exercise.sets.length) {
          final updatedSets = List<ExerciseSet>.from(exercise.sets);
          updatedSets.removeAt(index);
          
          // Renumber remaining sets
          for (var i = 0; i < updatedSets.length; i++) {
            updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
          }
          
          debugPrint('  - Removed set ${index + 1} from ${exercise.name}');
          return exercise.copyWith(sets: updatedSets);
        }
        return exercise;
      }).toList();
      
      // Also remove from superset's own sets
      final updatedSupersetSets = List<ExerciseSet>.from(ex.sets);
      if (index < updatedSupersetSets.length) {
        updatedSupersetSets.removeAt(index);
        
        // Renumber remaining sets
        for (var i = 0; i < updatedSupersetSets.length; i++) {
          updatedSupersetSets[i] = updatedSupersetSets[i].copyWith(setNumber: i + 1);
        }
      }
      
      final updatedSuperset = ex.copyWith(
        exercises: updatedExercises,
        sets: updatedSupersetSets,
      );
      widget.onExerciseUpdate!(updatedSuperset);
    } else {
      // Normal exercise handling
      // Remove the set from the list
      final updatedSets = List<ExerciseSet>.from(ex.sets);
      updatedSets.removeAt(index);
      
      // Renumber remaining sets
      for (var i = 0; i < updatedSets.length; i++) {
        updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
      }
      
      final updatedExercise = ex.copyWith(sets: updatedSets);
      widget.onExerciseUpdate!(updatedExercise);
    }
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(set.isWarmup 
            ? 'Warmup set deleted' 
            : 'Set ${index + 1} deleted'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Restore the set
            final restoredSets = List<ExerciseSet>.from(ex.sets);
            restoredSets.insert(index, set);
            
            // Renumber again
            for (var i = 0; i < restoredSets.length; i++) {
              restoredSets[i] = restoredSets[i].copyWith(setNumber: i + 1);
            }
            
            final restoredExercise = ex.copyWith(sets: restoredSets);
            widget.onExerciseUpdate!(restoredExercise);
          },
        ),
      ),
    );
    
    HapticFeedback.mediumImpact();
  }

  void _showExerciseOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Modifica nome e note'),
                subtitle: const Text('Personalizza nome esercizio e aggiungi note'),
                onTap: () {
                  Navigator.pop(context);
                  _showExerciseEditor(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Info esercizio'),
                subtitle: const Text('Muscoli coinvolti e tecnica'),
                onTap: () async {
                  Navigator.pop(context);
                  final exerciseData = await _loadExerciseDataFromJson();
                  if (exerciseData != null && context.mounted) {
                    _showExerciseInfoModal(context, exerciseData);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.whatshot, color: Colors.orange),
                title: const Text('Info riscaldamento'),
                subtitle: const Text('Consigli per il warmup'),
                onTap: () async {
                  Navigator.pop(context);
                  final exerciseData = await _loadExerciseDataFromJson();
                  if (exerciseData != null && _hasWarmupData(exerciseData) && context.mounted) {
                    _showWarmupModal(context, exerciseData);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.shield_outlined, color: Colors.green),
                title: const Text('Prevenzione infortuni'),
                subtitle: const Text('Consigli per evitare infortuni'),
                onTap: () async {
                  Navigator.pop(context);
                  final exerciseData = await _loadExerciseDataFromJson();
                  if (exerciseData != null && _hasInjuryPreventionData(exerciseData) && context.mounted) {
                    _showInjuryPreventionModal(context, exerciseData);
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Storico'),
                onTap: () {
                  Navigator.pop(context);
                  _showExerciseHistory(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Duplica esercizio'),
                onTap: () {
                  Navigator.pop(context);
                  _duplicateExercise();
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Elimina esercizio',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
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
            ],
          ),
        ),
      ),
    );
  }
  
  void _openContributionModal(ContributionType type, {String? contextType}) {
    _suggestionType = type;
    _contextType = contextType;
    _showContributionModal();
  }
  
  void _showExerciseEditor(BuildContext context) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Modifica esercizio',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Editor form
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: exercise != null ? EditExerciseModal(
                    exercise: exercise!,
                    onSave: (updatedExercise) {
                      // Close the modal FIRST
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      
                      // Then update the exercise
                      Future.microtask(() {
                        widget.onExerciseUpdate?.call(updatedExercise);
                      });
                    },
                  ) : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _duplicateExercise() {
    final ex = exercise;
    if (ex == null) return;
    
    // Crea una copia dell'esercizio
    final duplicatedExercise = Exercise(
      name: '${ex.name} (Copy)',
      type: ex.type,
      category: ex.category,
      sets: ex.sets.map((set) => ExerciseSet(
        setNumber: set.setNumber,
        weight: set.weight,
        reps: set.reps,
        notes: set.notes,
      )).toList(),
      notes: ex.notes,
      restTime: ex.restTime,
    );
    
    // Aggiungi l'esercizio duplicato
    widget.onExerciseUpdate?.call(duplicatedExercise);
    
    // Mostra feedback
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Duplicated "${ex.name}"'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _showQuickTimerSettings(BuildContext context) {
    if (exercise == null) return;
    
    // Haptic feedback per feedback tattile
    HapticFeedback.lightImpact();
    
    int? selectedTime = exercise!.restTime;
    final List<int> quickOptions = [30, 60, 90, 120, 150, 180, 240, 300];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(20),
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
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Rest Timer Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Set rest time between sets for "${exercise!.name}"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              
              // Default option
              Card(
                elevation: 0,
                color: selectedTime == null 
                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                    : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                child: InkWell(
                  onTap: () {
                    setState(() => selectedTime = null);
                    HapticFeedback.selectionClick();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_off,
                          color: selectedTime == null
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Use Default Timer',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: selectedTime == null
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Uses global rest timer (2 minutes)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selectedTime == null)
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Quick options
              Text(
                'Quick Options',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickOptions.map((seconds) {
                  final isSelected = selectedTime == seconds;
                  return FilterChip(
                    selected: isSelected,
                    label: Text(_formatRestTime(seconds)),
                    onSelected: (selected) {
                      setState(() => selectedTime = selected ? seconds : null);
                      HapticFeedback.selectionClick();
                    },
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              
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
                      onPressed: selectedTime != exercise!.restTime ? () {
                        final updated = exercise!.copyWith(restTime: selectedTime);
                        widget.onExerciseUpdate?.call(updated);
                        Navigator.pop(context);
                        
                        // Show feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              selectedTime != null 
                                  ? 'Rest timer set to ${_formatRestTime(selectedTime!)}'
                                  : 'Using default rest timer',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      } : null,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showRestTimerSettings(BuildContext context) {
    if (exercise == null) return;
    
    int? selectedTime = exercise!.restTime;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const Text(
                'Set Rest Timer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Timer options
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [30, 60, 90, 120, 180, 240, 300].map((seconds) {
                  final minutes = seconds ~/ 60;
                  final remainingSeconds = seconds % 60;
                  final label = minutes > 0 
                    ? (remainingSeconds > 0 ? '${minutes}m ${remainingSeconds}s' : '${minutes}m')
                    : '${seconds}s';
                    
                  return ChoiceChip(
                    label: Text(label),
                    selected: selectedTime == seconds,
                    onSelected: (selected) {
                      setState(() {
                        selectedTime = selected ? seconds : null;
                      });
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 8),
              
              // Custom time option
              OutlinedButton.icon(
                onPressed: () async {
                  // Show time picker per tempo personalizzato
                  final customTime = await _showCustomTimePicker(context, selectedTime ?? 60);
                  if (customTime != null) {
                    setState(() {
                      selectedTime = customTime;
                    });
                  }
                },
                icon: const Icon(Icons.edit, size: 18),
                label: Text(selectedTime != null && ![30, 60, 90, 120, 180, 240, 300].contains(selectedTime)
                  ? 'Custom: ${_formatTime(selectedTime!)}'
                  : 'Custom'),
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: selectedTime != null ? () {
                      final updated = exercise!.copyWith(restTime: selectedTime);
                      widget.onExerciseUpdate?.call(updated);
                      Navigator.pop(context);
                      
                      // Show confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Rest timer set to ${_formatTime(selectedTime!)}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } : null,
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<int?> _showCustomTimePicker(BuildContext context, int initialSeconds) async {
    int minutes = initialSeconds ~/ 60;
    int seconds = initialSeconds % 60;
    
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Rest Time'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minutes picker
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Minutes', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: TextEditingController(text: minutes.toString()),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      minutes = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            const Text(':', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            // Seconds picker
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Seconds', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: TextEditingController(text: seconds.toString()),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      seconds = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final totalSeconds = (minutes * 60) + seconds;
              Navigator.pop(context, totalSeconds > 0 ? totalSeconds : null);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return remainingSeconds > 0 ? '${minutes}m ${remainingSeconds}s' : '${minutes}m';
    }
    return '${seconds}s';
  }
  
  String _formatRestTime(int seconds) {
    // Format più compatto per il badge del timer
    if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) {
        return '${minutes}m';
      } else if (remainingSeconds == 30) {
        return '${minutes}:30';
      } else {
        return '${minutes}m${remainingSeconds}s';
      }
    }
    return '${seconds}s';
  }
  
  String _calculateAverageWeight() {
    if (exercise == null) return '0';
    
    final weightsWithValues = exercise!.sets
        .where((s) => s.weight != null && s.weight! > 0)
        .map((s) => s.weight!)
        .toList();
    
    if (weightsWithValues.isEmpty) return '0';
    
    final average = weightsWithValues.reduce((a, b) => a + b) / weightsWithValues.length;
    return average % 1 == 0 ? average.toInt().toString() : average.toStringAsFixed(1);
  }
  
  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showNotesEditor(BuildContext context) {
    if (exercise == null) return;
    
    final controller = TextEditingController(text: exercise!.notes);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Exercise Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Add notes for this exercise...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      final updated = exercise!.copyWith(notes: controller.text);
                      widget.onExerciseUpdate?.call(updated);
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    if (exercise == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: Text('Are you sure you want to delete "${exercise!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editSet(BuildContext context, ExerciseSet set) {
    if (widget.onSetUpdate == null) return;
    
    // Duration tracking is handled when set is completed
    // No need to track on edit
    
    // Get previous set for context
    final sets = exercise?.sets ?? [];
    final currentIndex = sets.indexWhere((s) => s.id == set.id);
    final previousSet = currentIndex > 0 ? sets[currentIndex - 1] : null;
    
    context.showUnifiedSetInputModal(
      set, 
      widget.onSetUpdate!,
      previousSet: previousSet,
      exerciseName: exercise?.name ?? 'Exercise',
      isInWorkout: true,
    );
  }

  void _quickEditSet(BuildContext context, ExerciseSet set) {
    if (exercise == null || widget.onSetUpdate == null || _isQuickEditBlocked) {
      print('🚫 DEBUG: Quick edit blocked - preventing accidental overlay');
      return;
    }
    
    // Duration tracking is handled when set is completed
    // No need to track on quick edit
    
    print('⚠️ DEBUG: _quickEditSet called - THIS WILL CREATE GRAY OVERLAY!');
    
    // Get the position of the set item for the overlay
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    
    // Find the previous set for copying values
    ExerciseSet? previousSet;
    final currentSetIndex = exercise!.sets.indexWhere((s) => s.id == set.id);
    if (currentSetIndex > 0) {
      previousSet = exercise!.sets[currentSetIndex - 1];
    }
    
    // Get recent weights from completed sets
    List<double> recentWeights = [];
    for (final s in exercise!.sets) {
      if (s.weight != null && s.isCompleted) {
        if (!recentWeights.contains(s.weight)) {
          recentWeights.add(s.weight!);
        }
      }
    }
    recentWeights = recentWeights.take(3).toList(); // Max 3 recent weights
    
    // Calculate estimated 1RM from best set
    double? oneRepMax;
    for (final s in exercise!.sets) {
      if (s.weight != null && s.actualReps != null && s.actualReps! > 0) {
        // Epley formula: 1RM = weight × (1 + reps/30)
        final estimated1RM = s.weight! * (1 + s.actualReps! / 30);
        if (oneRepMax == null || estimated1RM > oneRepMax) {
          oneRepMax = estimated1RM;
        }
      }
    }
    
    // Haptic feedback for quick edit
    HapticFeedback.selectionClick();
    
    // Use optimized quick edit overlay v2
    print('🔥 DEBUG: About to call showQuickEditOverlayV2 - GRAY OVERLAY INCOMING!');
    context.showQuickEditOverlayV2(
      exerciseSet: set,
      onSave: widget.onSetUpdate!,
      position: position,
      previousSet: previousSet,
      exerciseName: exercise?.name ?? '',
    );
    print('🔥 DEBUG: showQuickEditOverlayV2 called - overlay should be visible now');
  }

  void _toggleSetCompletion(ExerciseSet set) {
    if (widget.onSetToggleComplete == null) return;
    
    final updatedSet = set.copyWith(isCompleted: !set.isCompleted);
    widget.onSetToggleComplete!(updatedSet);
  }

  void _toggleSetCompletionWithFeedback(BuildContext context, ExerciseSet set) {
    if (exercise == null) return;
    
    print('🔍 DEBUG: _toggleSetCompletionWithFeedback called for set ${set.setNumber}');
    
    // Block quick edit for 1 second to prevent accidental double tap conflicts
    _isQuickEditBlocked = true;
    _quickEditBlockTimer?.cancel();
    _quickEditBlockTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isQuickEditBlocked = false;
        });
      }
    });
    
    // Store the original state to determine what action was taken
    final wasCompleted = set.isCompleted;
    print('🔍 DEBUG: wasCompleted = $wasCompleted');
    
    // Check if RPE tracking is enabled and if it's NOT a warmup set
    final config = ref.read(appConfigProvider);
    final rpeEnabled = config.rpeTracking ?? true; // Default to true
    final isWarmupSet = set.isWarmup;
    
    if (!wasCompleted) {
      // Ensure tracking is started for this set
      // (might already be started from rest timer, but safe to call)
      if (!isWarmupSet) {
        final durationTracker = ref.read(setDurationTrackerProvider);
        // This will only create a start time if not already exists
        durationTracker.markSetStartedAfterRest(exercise!.id, set.setNumber);
      }
      // If RPE tracking is disabled OR it's a warmup set, complete directly
      if (!rpeEnabled || isWarmupSet) {
        debugPrint('🔥 Completing set ${set.setNumber} (warmup: $isWarmupSet)');
        double? duration;
        
        // Only track duration for non-warmup sets
        if (!isWarmupSet) {
          final durationTracker = ref.read(setDurationTrackerProvider);
          
          // First, ensure we have a start time for this set
          // This should have been set when rest timer ended or when user started working
          var existingStartTime = durationTracker.getSetStartTime(
            exercise!.id, 
            set.setNumber
          );
          
          // If no start time exists, it means user completed set without proper tracking
          // We need to estimate the duration
          if (existingStartTime == null) {
            print('⚠️ No start time tracked for set ${set.setNumber}');
            
            // For first set or sets without rest timer, use reasonable default
            duration = 30000; // Default 30 seconds
            print('   Using default duration: 30s');
          } else {
            // Calculate actual duration from when set started to now
            duration = DateTime.now().difference(existingStartTime).inMilliseconds.toDouble();
            
            // Sanity check - cap at 5 minutes max
            if (duration > 300000) {
              print('⚠️ Duration too long: ${(duration/1000).toStringAsFixed(1)}s, capping at 30s');
              duration = 30000; // Default to 30 seconds
            } else if (duration < 1000) {
              print('⚠️ Duration too short: ${(duration/1000).toStringAsFixed(1)}s, using 30s');
              duration = 30000; // Default to 30 seconds if less than 1 second
            } else {
              print('✅ Set ${set.setNumber} duration: ${(duration/1000).toStringAsFixed(1)}s');
            }
          }
        }
        
        // Save time for chart visualization
        if (duration != null && !isWarmupSet) {
          setState(() {
            _completedSetTimes.add(duration!); // Already in seconds
            // Stop tracking if this was the tracked set
            if (_isTrackingSet && _currentTrackingSetNumber == set.setNumber) {
              _isTrackingSet = false;
              _currentTrackingSetNumber = null;
            }
          });
        }
        
        // Update set with duration (null for warmup sets)
        // IMPORTANT: Preserve warmup flag
        final updatedSet = set.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
          setDurationMillis: duration,
          isWarmup: set.isWarmup, // Explicitly preserve warmup flag
        );
        
        debugPrint('✅ Set completed: #${set.setNumber}, warmup: ${set.isWarmup}, preserved: ${updatedSet.isWarmup}');
        
        print('🚨 DEBUG: About to call onSetToggleComplete - OVERLAY MIGHT APPEAR HERE');
        widget.onSetToggleComplete!(updatedSet);
        print('🚨 DEBUG: Called onSetToggleComplete - overlay should be visible now');
        
        // Start rest timer for next set (if not warmup)
        if (!isWarmupSet) {
          print('🚨 DEBUG: About to start timer - OVERLAY MIGHT APPEAR HERE TOO');
          _startRestTimerWithSetInfo(context, updatedSet);
          print('🚨 DEBUG: Timer started - checking if overlay appeared');
        }
        
        // Show feedback
        if (isWarmupSet) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Warmup set ${set.setNumber} completed! 🔥'),
              duration: const Duration(milliseconds: 1200),
              backgroundColor: Colors.orange.shade600,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Set ${set.setNumber} completed!'),
              duration: const Duration(milliseconds: 1200),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
        }
        return;
      }
      
      // Show RPE selector when completing a set
      final targetReps = set.reps ?? 10;
      
      RpeSelectorBottomSheet.show(
        context: context,
        set: set,
        targetReps: targetReps,
        onConfirm: (actualReps, actualWeight, rpe) {
          final durationTracker = ref.read(setDurationTrackerProvider);
          
          // Get the actual start time for this set
          // This should be when rest timer ended or when user started working
          var existingStartTime = durationTracker.getSetStartTime(
            exercise!.id, 
            set.setNumber
          );
          
          // Calculate duration
          double? duration;
          if (existingStartTime != null) {
            // We have a proper start time - calculate actual duration
            duration = DateTime.now().difference(existingStartTime).inMilliseconds.toDouble();
            
            // Sanity checks
            if (duration > 300000) {
              // More than 5 minutes - probably tracking error
              duration = 30000;
              print('⚠️ Set ${set.setNumber}: Duration too long (${(duration/1000).toStringAsFixed(1)}s), using 30s');
            } else if (duration < 1000) {
              // Less than 1 second - probably tracking error
              duration = 30000;
              print('⚠️ Set ${set.setNumber}: Duration too short, using 30s');
            } else {
              print('✅ Set ${set.setNumber} actual duration: ${(duration/1000).toStringAsFixed(1)}s');
            }
          } else {
            // No tracking available - use default
            duration = 30000;
            print('⚠️ Set ${set.setNumber}: No tracking data, using default 30s');
          }
          
          // Save time for chart visualization
          if (duration != null) {
            setState(() {
              _completedSetTimes.add(duration!); // Already in seconds
              // Stop tracking if this was the tracked set
              if (_isTrackingSet && _currentTrackingSetNumber == set.setNumber) {
                _isTrackingSet = false;
                _currentTrackingSetNumber = null;
              }
            });
          }
          
          // Update set with RPE, actual reps, weight and calculated duration
          final updatedSet = set.copyWith(
            actualReps: actualReps,
            rpe: rpe,
            weight: actualWeight,
            isCompleted: true,
            setDurationMillis: duration, // Duration of actual set execution
            completedAt: DateTime.now(),
          );
          
          widget.onSetToggleComplete!(updatedSet);
          
          // Haptic feedback
          HapticFeedback.lightImpact();
          
          // Start rest timer
          _startRestTimerWithSetInfo(context, updatedSet);
          
          // Mark next set as starting when rest timer ends
          final nextSetNumber = set.setNumber + 1;
          if (nextSetNumber <= exercise!.sets.length) {
            // The timer provider will call onRestTimerEnded when it reaches 00:00
            // We'll use that timestamp for the next set when it starts
            // The actual tracking happens when the user starts working on the next set
          }
          
          // Visual feedback with snackbar
          final rpeText = rpe > 0 ? ' (RPE $rpe)' : '';
          final message = 'Set ${set.setNumber} completed! 💪$rpeText';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(milliseconds: 1200),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
        },
      );
    } else {
      // Set already completed - show RPE selector to allow editing
      final targetReps = set.reps ?? 10;
      
      RpeSelectorBottomSheet.show(
        context: context,
        set: set,
        targetReps: targetReps,
        onConfirm: (actualReps, actualWeight, rpe) {
          if (rpe == 0) {
            // User chose to mark as incomplete
            _toggleSetCompletion(set);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Set ${set.setNumber} marked as incomplete'),
                duration: const Duration(milliseconds: 800),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            );
          } else {
            // Update set with new RPE values - preserve existing duration if present
            final updatedSet = set.copyWith(
              actualReps: actualReps,
              weight: actualWeight,
              rpe: rpe,
              isCompleted: true,
              // Keep existing duration if already tracked
              setDurationMillis: set.setDurationMillis,
              setStartedAt: set.setStartedAt,
            );
            
            widget.onSetToggleComplete!(updatedSet);
            
            // Haptic feedback
            HapticFeedback.lightImpact();
            
            // Visual feedback with snackbar
            final rpeText = ' (RPE $rpe updated)';
            final message = 'Set ${set.setNumber} updated! 💪$rpeText';
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(milliseconds: 1200),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              ),
            );
          }
        },
      );
    }
  }

  void _startRestTimer(BuildContext context) {
    if (exercise == null) return;
    
    final autoStartTimer = ref.read(autoStartTimerProvider);
    
    // Only start timer if auto-start is enabled
    if (!autoStartTimer) return;
    
    // Find completed sets
    final completedSets = exercise!.sets.where((set) => set.isCompleted).toList();
    if (completedSets.isEmpty) return;
    
    final totalSets = exercise!.sets.length;
    final completedSetCount = completedSets.length;
    
    // Don't start timer if this is the last set of the exercise
    if (completedSetCount >= totalSets) return;
    
    final lastSet = completedSets.last;
    final reps = lastSet.reps ?? 10; // Default to 10 if reps not set
    
    // Start smart rest timer based on rep range using tier1 timer
    final timerActions = ref.read(tier1TimerActionsProvider);
    timerActions.startExerciseRest(
      seconds: _calculateSmartRestTime(reps),
      exerciseName: exercise!.name,
      currentSet: completedSetCount + 1, // Next set
      totalSets: totalSets,
    );
  }

  Color _getRpeIndicatorColor(int rpe) {
    if (rpe <= 6) return Colors.green;
    if (rpe <= 7) return Colors.lightGreen;
    if (rpe <= 8) return Colors.orange;
    if (rpe <= 9) return Colors.deepOrange;
    return Colors.red;
  }

  void _startRestTimerWithSetInfo(BuildContext context, ExerciseSet completedSet) async {
    if (exercise == null) return;
    
    final autoStartTimer = ref.read(autoStartTimerProvider);
    
    // Only start timer if auto-start is enabled
    if (!autoStartTimer) return;
    
    print('🔧 FIXED: Using safe timer activation to prevent overlay issue');
    
    final totalSets = exercise!.sets.length;
    final currentSetNumber = completedSet.setNumber;
    
    // Don't start timer if this is the last set of the exercise
    if (currentSetNumber >= totalSets) return;
    
    final reps = completedSet.reps ?? 10; // Default to 10 if reps not set
    
    // Use exercise-specific rest time if set, otherwise use smart calculation
    final exerciseRestTime = exercise!.restTime;
    
    if (exerciseRestTime != null) {
      // Use unified timer to ensure UI overlay is shown
      debugPrint('🎯 Starting unified timer for ${exercise!.name} with $exerciseRestTime seconds');
      await ref.read(unifiedTimerProvider.notifier).startTimer(
        durationSeconds: exerciseRestTime,
        exerciseName: exercise!.name,
        currentSet: currentSetNumber + 1,
        totalSets: totalSets,
        workoutId: null,
      );
    } else {
      // Use smart timer calculation
      debugPrint('🎯 Starting smart timer for ${exercise!.name} based on $reps reps');
      
      // Calculate smart rest time based on reps
      int smartRestSeconds;
      if (reps <= 5) {
        smartRestSeconds = 180; // 3 minutes for heavy sets
      } else if (reps <= 8) {
        smartRestSeconds = 120; // 2 minutes for medium sets
      } else if (reps <= 12) {
        smartRestSeconds = 90; // 1.5 minutes for higher rep sets
      } else {
        smartRestSeconds = 60; // 1 minute for light sets
      }
      
      // Use tier1 timer for consistent UI display
      final timerActions = ref.read(tier1TimerActionsProvider);
      await timerActions.startExerciseRest(
        seconds: smartRestSeconds,
        exerciseName: exercise!.name,
        currentSet: currentSetNumber + 1,
        totalSets: totalSets,
      );
    }
  }

  Widget _buildInsightChip(BuildContext context) {
    if (_lastActivity == null || _lastActivity!.sets.isEmpty) return const SizedBox.shrink();
    
    // Trova il peso massimo usato nell'ultimo allenamento
    double maxWeight = 0;
    int maxReps = 0;
    
    for (final set in _lastActivity!.sets) {
      if (set.done) {
        final weight = double.tryParse(set.weight.toString()) ?? 0;
        final reps = int.tryParse(set.reps.toString()) ?? 0;
        if (weight > maxWeight) {
          maxWeight = weight;
          maxReps = reps;
        }
      }
    }
    
    if (maxWeight == 0) return const SizedBox.shrink();
    
    final daysAgo = DateTime.now().difference(_lastActivity!.createdAt).inDays;
    String timeAgo = daysAgo == 0 ? 'Oggi' : 
                     daysAgo == 1 ? 'Ieri' : 
                     '$daysAgo giorni fa';
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          _showExerciseHistory(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0, end: 1),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Icon(
                      Icons.insights,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              Text(
                'Ultimo: ${maxWeight.toStringAsFixed(1)}kg x $maxReps ($timeAgo)',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 14,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showExerciseHistory(BuildContext context) async {
    if (exercise == null) return;
    
    setState(() {
      _loadingHistory = true;
    });
    
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;
    
    List<ExerciseActivity> activities = [];
    
    if (currentUser?.email != null) {
      // Use hybrid repository to get data from Hive for non-premium users
      final repository = ref.read(exerciseActivityRepositoryProvider);
      
      // Get all recent activities and filter for this exercise
      final allActivities = await repository.getUserActivities(
        userEmail: currentUser!.email!,
        limit: 100,
      );
      
      // Filter for this specific exercise and limit to 10
      activities = allActivities
          .where((activity) => activity.exerciseName == exercise!.name)
          .take(10)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    setState(() {
      _loadingHistory = false;
    });
    
    if (!mounted) return;
    
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Storico: ${exercise!.name}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ultimi ${activities.length} allenamenti',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Content
              Expanded(
                child: activities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 48,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nessun allenamento precedente',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          final activity = activities[index];
                          return _buildHistoryCard(context, activity);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ExerciseActivity activity) {
    final date = activity.createdAt;
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    
    // Calcola statistiche
    double maxWeight = 0;
    int totalSets = 0;
    int totalReps = 0;
    double totalVolume = 0;
    
    for (final set in activity.sets) {
      if (set.done) {
        final weight = double.tryParse(set.weight.toString()) ?? 0;
        final reps = int.tryParse(set.reps.toString()) ?? 0;
        
        if (weight > maxWeight) maxWeight = weight;
        totalSets++;
        totalReps += reps;
        totalVolume += weight * reps;
      }
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (activity.schedaName != null && activity.schedaName!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      activity.schedaName!,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Statistiche riassuntive
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Serie', '$totalSets'),
                _buildStatItem(context, 'Max', '${maxWeight.toStringAsFixed(1)}kg'),
                _buildStatItem(context, 'Reps Tot', '$totalReps'),
                _buildStatItem(context, 'Volume', '${totalVolume.toStringAsFixed(0)}kg'),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Dettaglio serie
            ExpansionTile(
              title: Text(
                'Dettaglio serie',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              children: activity.sets.where((s) => s.done).map((set) {
                final weight = double.tryParse(set.weight.toString()) ?? 0;
                final reps = int.tryParse(set.reps.toString()) ?? 0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Center(
                          child: Text(
                            '${activity.sets.indexOf(set) + 1}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${weight.toStringAsFixed(1)}kg x $reps',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (set.effort != null && set.effort! > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getEffortColorByNumber(set.effort!).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'RPE ${set.effort}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _getEffortColorByNumber(set.effort!),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (set.setDurationMillis != null) ...[
                        const Spacer(),
                        Text(
                          SetDurationTracker.formatDuration(set.setDurationMillis),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeTracker(BuildContext context) {
    if (exercise == null) return const SizedBox.shrink();
    
    // Find the next incomplete set
    final nextSetIndex = exercise!.sets.indexWhere((s) => !s.isCompleted);
    if (nextSetIndex == -1) return const SizedBox.shrink();
    
    final nextSet = exercise!.sets[nextSetIndex];
    final setNumber = nextSetIndex + 1;
    
    return Column(
      children: [
        // Main timer widget
        SetExecutionTimerWidget(
          exercise: exercise!,
          setNumber: setNumber,
          isTracking: _isTrackingSet && _currentTrackingSetNumber == setNumber,
          onTap: () {
            if (_isTrackingSet && _currentTrackingSetNumber == setNumber) {
              // Complete the set
              _toggleSetCompletionWithFeedback(context, nextSet);
            } else {
              // Start tracking this set
              _startSetTracking(setNumber);
            }
          },
        ),
        
        // Show completed set times chart if we have data
        if (_completedSetTimes.isNotEmpty) ...[
          const SizedBox(height: 12),
          SetTimesChartWidget(
            setTimes: _completedSetTimes,
            currentSetIndex: nextSetIndex,
          ),
        ],
        
        // Velocity indicator (mock data for now)
        if (_isTrackingSet && _currentTrackingSetNumber == setNumber) ...[
          const SizedBox(height: 12),
          VelocityIndicatorWidget(
            currentVelocity: 0.45, // Mock value
            targetVelocity: 0.50,
            personalBestVelocity: 0.52,
          ),
        ],
        
        const SizedBox(height: 12),
      ],
    );
  }
  
  void _startSetTracking(int setNumber) {
    if (exercise == null) return;
    
    setState(() {
      _isTrackingSet = true;
      _currentTrackingSetNumber = setNumber;
    });
    
    // IMPORTANTE: Quando l'utente inizia manualmente il tracking,
    // vogliamo usare NOW come tempo di inizio, non il tempo del timer
    final durationTracker = ref.read(setDurationTrackerProvider);
    durationTracker.setStartTime(exercise!.id, setNumber, DateTime.now());
  }
  
  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getEffortColor(String effort) {
    switch (effort.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getEffortColorByNumber(int effort) {
    if (effort <= 6) {
      return Colors.green;
    } else if (effort <= 8) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _editExercise(BuildContext context) {
    if (exercise == null || widget.onExerciseUpdate == null) return;
    
    context.showEditExerciseModal(
      exercise,
      widget.onExerciseUpdate!,
    );
  }

  // Load exercise data from JSON with Community Corrections merged
  Future<Map<String, dynamic>?> _loadExerciseDataFromJson() async {
    if (exercise == null) return null;
    
    try {
      // Prima prova a caricare i dati merged con correzioni community
      final mergedData = await ref.read(
        exerciseDataProvider(exercise!.name).future
      );
      
      if (mergedData.isNotEmpty) {
        // Se ci sono correzioni community, mostra un indicatore
        if (mergedData['hasCommunityCorrections'] == true) {
          print('✅ Using community-corrected data for ${exercise!.name}');
        }
        return mergedData;
      }
    } catch (e) {
      print('Could not load merged data, falling back to JSON: $e');
    }
    
    // Fallback: carica solo dal JSON se il provider fallisce
    try {
      final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
      final List<dynamic> exercises = json.decode(jsonString);
      
      // Search for exercise by name (case insensitive)
      final exerciseName = exercise!.name.toLowerCase();
      
      // Try exact match first
      for (var exercise in exercises) {
        if (exercise['nome']?.toString().toLowerCase() == exerciseName) {
          return exercise as Map<String, dynamic>;
        }
      }
      
      // Try partial match
      for (var exercise in exercises) {
        final exerciseNameInJson = exercise['nome']?.toString().toLowerCase() ?? '';
        if (exerciseNameInJson.contains(exerciseName) ||
            exerciseName.contains(exerciseNameInJson)) {
          return exercise as Map<String, dynamic>;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error loading exercise data: $e');
      return null;
    }
  }

  // Check if exercise has warmup data
  bool _hasWarmupData(Map<String, dynamic> data) {
    return data['mobilitaPre'] != null || 
           data['attivazionePre'] != null || 
           data['warmupSets'] != null ||
           data['tempoWarmup'] != null;
  }

  // Check if exercise has injury prevention data
  bool _hasInjuryPreventionData(Map<String, dynamic> data) {
    return data['prevenzioneInfortuni'] != null || 
           data['cooldownConsigliato'] != null || 
           data['drillTecnico'] != null ||
           data['noteTecniche'] != null;
  }

  // Build interactive chip widget
  Widget _buildInteractiveChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show warmup modal
  void _showWarmupModal(BuildContext context, Map<String, dynamic> data) {
    if (exercise == null) return;
    
    final groups = <_GroupedModalSection>[];
    
    // Group 1: Preparation (Mobility + Activation)
    final preparationItems = <_ModalItem>[];
    if (data['mobilitaPre'] != null) {
      preparationItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.preWorkoutMobility,
        value: data['mobilitaPre'],
        icon: Icons.accessibility_new,
      ));
    }
    if (data['attivazionePre'] != null) {
      preparationItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.muscleActivation,
        value: data['attivazionePre'],
        icon: Icons.flash_on,
      ));
    }
    if (preparationItems.isNotEmpty) {
      groups.add(_GroupedModalSection(
        groupTitle: AppLocalizations.of(context)!.preparation,
        groupIcon: Icons.accessibility_new,
        items: preparationItems,
        accentColor: Colors.orange,
      ));
    }
    
    // Group 2: Specific Warmup (Sets + Duration)
    final warmupItems = <_ModalItem>[];
    if (data['warmupSets'] != null) {
      warmupItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.warmupSets,
        value: data['warmupSets'].toString(),
        icon: Icons.fitness_center,
      ));
    }
    if (data['tempoWarmup'] != null) {
      warmupItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.warmupDuration,
        value: data['tempoWarmup'],
        icon: Icons.timer,
      ));
    }
    if (warmupItems.isNotEmpty) {
      groups.add(_GroupedModalSection(
        groupTitle: AppLocalizations.of(context)!.specificWarmup,
        groupIcon: Icons.whatshot,
        items: warmupItems,
        accentColor: Colors.deepOrange,
      ));
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGroupedPremiumModal(
        context: context,
        title: AppLocalizations.of(context)!.warmupAndMobility,
        icon: Icons.whatshot,
        color: Colors.orange,
        groups: groups,
        onCorrection: () {
          Navigator.pop(context);
          _openContributionModal(ContributionType.correction, contextType: 'warmup');
        },
        onAddTip: () {
          Navigator.pop(context);
          _openContributionModal(ContributionType.tip, contextType: 'warmup');
        },
      ),
    );
  }

  // Show exercise info modal
  void _showExerciseInfoModal(BuildContext context, Map<String, dynamic> data) {
    if (exercise == null) return;
    
    final groups = <_GroupedModalSection>[];
    
    // Group 1: Target Muscles
    final muscleItems = <_ModalItem>[];
    if (data['focus'] != null) {
      muscleItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.primaryMuscles,
        value: data['focus'],
        icon: Icons.fitness_center,
      ));
    }
    if (data['muscoliSecondari'] != null) {
      muscleItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.secondaryMuscles,
        value: data['muscoliSecondari'],
        icon: Icons.sports_gymnastics,
      ));
    }
    if (muscleItems.isNotEmpty) {
      groups.add(_GroupedModalSection(
        groupTitle: AppLocalizations.of(context)!.targetMuscles,
        groupIcon: Icons.fitness_center,
        items: muscleItems,
        accentColor: Theme.of(context).colorScheme.primary,
      ));
    }
    
    // Group 2: Exercise Details
    final detailItems = <_ModalItem>[];
    if (data['difficolta'] != null) {
      detailItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.difficultyLevel,
        value: data['difficolta'],
        icon: Icons.trending_up,
      ));
    }
    if (data['tipoEsercizio'] != null) {
      detailItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.exerciseType,
        value: data['tipoEsercizio'],
        icon: Icons.category,
      ));
    }
    if (data['attrezzatura'] != null) {
      detailItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.equipment,
        value: data['attrezzatura'],
        icon: Icons.build,
      ));
    }
    if (data['patternMovimento'] != null) {
      detailItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.movementPattern,
        value: data['patternMovimento'],
        icon: Icons.repeat,
      ));
    }
    if (detailItems.isNotEmpty) {
      groups.add(_GroupedModalSection(
        groupTitle: AppLocalizations.of(context)!.exerciseDetails,
        groupIcon: Icons.info_outline,
        items: detailItems,
        accentColor: Colors.blue.shade600,
      ));
    }
    
    // Group 3: Rep Range (standalone)
    if (data['rangeRipetizioni'] != null) {
      groups.add(_GroupedModalSection(
        groupTitle: AppLocalizations.of(context)!.repRange,
        groupIcon: Icons.format_list_numbered,
        items: [
          _ModalItem(
            label: '',
            value: data['rangeRipetizioni'],
          ),
        ],
        accentColor: Colors.purple.shade600,
      ));
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGroupedPremiumModal(
        context: context,
        title: AppLocalizations.of(context)!.exerciseInformation,
        icon: Icons.info,
        color: Theme.of(context).colorScheme.primary,
        groups: groups,
        onCorrection: () {
          Navigator.pop(context);
          _openContributionModal(ContributionType.correction, contextType: 'exercise_info');
        },
        onAddTip: () {
          Navigator.pop(context);
          _openContributionModal(ContributionType.tip, contextType: 'exercise_info');
        },
      ),
    );
  }

  // Show injury prevention modal
  void _showInjuryPreventionModal(BuildContext context, Map<String, dynamic> data) {
    if (exercise == null) return;
    
    final groups = <_GroupedModalSection>[];
    
    // Group 1: Safety & Technique (Prevention + Technical Notes + Drills)
    final safetyItems = <_ModalItem>[];
    if (data['prevenzioneInfortuni'] != null) {
      safetyItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.injuryPrevention,
        value: data['prevenzioneInfortuni'],
        icon: Icons.shield,
      ));
    }
    if (data['noteTecniche'] != null) {
      safetyItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.technicalNotes,
        value: data['noteTecniche'],
        icon: Icons.note,
      ));
    }
    if (data['drillTecnico'] != null) {
      safetyItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.technicalDrills,
        value: data['drillTecnico'],
        icon: Icons.sports,
      ));
    }
    if (safetyItems.isNotEmpty) {
      groups.add(_GroupedModalSection(
        groupTitle: AppLocalizations.of(context)!.safetyAndTechnique,
        groupIcon: Icons.health_and_safety,
        items: safetyItems,
        accentColor: Colors.red.shade600,
      ));
    }
    
    // Group 2: Recovery (Cooldown standalone)
    if (data['cooldownConsigliato'] != null) {
      groups.add(_GroupedModalSection(
        groupTitle: AppLocalizations.of(context)!.recovery,
        groupIcon: Icons.ac_unit,
        items: [
          _ModalItem(
            label: AppLocalizations.of(context)!.recommendedCooldown,
            value: data['cooldownConsigliato'],
            icon: Icons.ac_unit,
          ),
        ],
        accentColor: Colors.cyan.shade600,
      ));
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGroupedPremiumModal(
        context: context,
        title: AppLocalizations.of(context)!.safetyAndPrevention,
        icon: Icons.health_and_safety,
        color: Colors.red.shade600,
        groups: groups,
        onCorrection: () {
          Navigator.pop(context);
          _openContributionModal(ContributionType.correction, contextType: 'injury_prevention');
        },
        onAddTip: () {
          Navigator.pop(context);
          _openContributionModal(ContributionType.warning, contextType: 'injury_prevention');
        },
      ),
    );
  }

  // Show TUT explanation modal
  void _showTutExplanationModal(BuildContext context) {
    if (_exerciseData == null) return;
    
    final tut = _exerciseData!['tempoEsecuzione'];
    final tutNote = _exerciseData!['tempoNote'];
    
    if (tut == null || tut == '') return;
    
    // Parse TUT format (e.g., "2-0-1-0" or special values like "ISO", "EXP")
    List<String> phases = [];
    String explanation = '';
    
    if (tut == 'ISO') {
      explanation = 'Contrazione isometrica - mantieni la posizione per il tempo specificato';
    } else if (tut == 'EXP') {
      explanation = 'Movimento esplosivo - esegui il movimento il più velocemente possibile';
    } else {
      final parts = tut.toString().split('-');
      if (parts.length == 4) {
        final l10n = AppLocalizations.of(context)!;
        // Format: X-Y-Z-W dove:
        // X = Eccentrica (discesa/abbassamento)
        // Y = Pausa in basso  
        // Z = Concentrica (salita/spinta)
        // W = Pausa in alto
        phases = [
          '${parts[0]}s Eccentrica (discesa/abbassamento)',
          '${parts[1]}s Pausa in basso',
          '${parts[2]}s Concentrica (salita/spinta)', 
          '${parts[3]}s Pausa in alto',
        ];
        explanation = 'Il TUT controlla il tempo di ogni fase del movimento:';
      }
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.98),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.withOpacity(0.2),
                            Colors.deepPurple.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.timer_outlined, color: Colors.deepPurple, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.tutExplanationTitle,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tut.toString(),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Explanation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        explanation,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                    
                    // Phase breakdown (for standard TUT format)
                    if (phases.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      ...phases.asMap().entries.map((entry) {
                        final index = entry.key;
                        final phase = entry.value;
                        final icons = [Icons.arrow_downward, Icons.pause, Icons.arrow_upward, Icons.pause];
                        final colors = [Colors.blue, Colors.grey, Colors.green, Colors.orange];
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors[index].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors[index].withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colors[index].withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icons[index],
                                  color: colors[index],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  phase,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      
                      // Zero note
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.tutExplosiveNote,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Additional note if available
                    if (tutNote != null && tutNote.toString().isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Suggerimento',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tutNote.toString(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build grouped premium modal
  Widget _buildGroupedPremiumModal({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<_GroupedModalSection> groups,
    VoidCallback? onCorrection,
    VoidCallback? onAddTip,
  }) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.98),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise!.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content with grouped sections
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...groups.map((group) => Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: (group.accentColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.08),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                group.groupIcon,
                                size: 20,
                                color: group.accentColor ?? Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                group.groupTitle,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: group.accentColor ?? Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Group items
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: group.items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (index > 0) 
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(
                                        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                                        height: 1,
                                      ),
                                    ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (item.icon != null) ...[
                                        Icon(
                                          item.icon,
                                          size: 16,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.label,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.value,
                                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Context-aware contribution buttons
            if (onCorrection != null || onAddTip != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (onCorrection != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCorrection,
                          icon: const Icon(Icons.edit_note, size: 18),
                          label: const Text('Correggi info'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                          ),
                        ),
                      ),
                    if (onCorrection != null && onAddTip != null)
                      const SizedBox(width: 12),
                    if (onAddTip != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onAddTip,
                          icon: const Icon(Icons.lightbulb_outline, size: 18),
                          label: const Text('Aggiungi tip'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            foregroundColor: Theme.of(context).colorScheme.primary,
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

  // Build premium modal (old version kept for compatibility)
  Widget _buildPremiumModal({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<_ModalSection> sections,
  }) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.98),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise!.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...sections.map((section) => Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                section.icon,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                section.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            section.content,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for modal sections
class _ModalSection {
  final String title;
  final String content;
  final IconData icon;

  const _ModalSection({
    required this.title,
    required this.content,
    required this.icon,
  });
}

// Helper class for grouped modal sections
class _GroupedModalSection {
  final String groupTitle;
  final IconData groupIcon;
  final List<_ModalItem> items;
  final Color? accentColor;

  const _GroupedModalSection({
    required this.groupTitle,
    required this.groupIcon,
    required this.items,
    this.accentColor,
  });
}

// Individual item within a grouped section
class _ModalItem {
  final String label;
  final String value;
  final IconData? icon;
  
  const _ModalItem({
    required this.label,
    required this.value,
    this.icon,
  });
}

// Extension methods for OptimizedExerciseListItem
extension _OptimizedExerciseListItemHelpers on _OptimizedExerciseListItemState {
  bool _shouldShowWarmupSuggestion(Exercise exercise) {
    final config = ref.watch(appConfigProvider);
    
    // Check if warmup suggestions are enabled
    if (config.warmupSuggestions == false) return false;
    
    // Don't show if already dismissed
    if (_warmupSuggestionDismissed) return false;
    
    // Don't show if there are no sets
    if (exercise.sets.isEmpty) return false;
    
    // Don't show if there are already warmup sets
    if (exercise.sets.any((s) => s.isWarmup)) return false;
    
    // Check if it's a compound exercise or heavy enough
    final maxWeight = _getMaxWorkingWeight(exercise);
    if (maxWeight < 40) return false; // Too light for warmup
    
    // Check exercise type (compound movements need warmup)
    final exerciseLower = exercise.name.toLowerCase();
    final isCompound = exerciseLower.contains('squat') ||
        exerciseLower.contains('bench') ||
        exerciseLower.contains('deadlift') ||
        exerciseLower.contains('press') ||
        exerciseLower.contains('row') ||
        exerciseLower.contains('pull');
    
    return isCompound || maxWeight >= 60;
  }
  
  double _getMaxWorkingWeight(Exercise exercise) {
    if (exercise.sets.isEmpty) return 0;
    
    double maxWeight = 0;
    for (final set in exercise.sets) {
      if (!set.isWarmup && set.weight != null && set.weight! > maxWeight) {
        maxWeight = set.weight!;
      }
    }
    return maxWeight;
  }
  
  int _getTargetReps(Exercise exercise) {
    if (exercise.sets.isEmpty) return 8;
    
    // Get the average reps from non-warmup sets
    final workingSets = exercise.sets.where((s) => !s.isWarmup && s.reps != null);
    if (workingSets.isEmpty) return 8;
    
    final totalReps = workingSets.fold(0, (sum, set) => sum + set.reps!);
    return (totalReps / workingSets.length).round();
  }
  
  Widget _buildSupersetItem(BuildContext context, int index, ExerciseSet set, AppConfig config, SupersetExercise superset) {
    final l10n = AppLocalizations.of(context)!;
    
    // Wrap with Dismissible for swipe-to-delete
    return Dismissible(
      key: Key('${superset.id}_superset_${set.id}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.error,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(l10n.deleteSet),
              content: Text(l10n.confirmDeleteSet),
              actions: [
                TextButton(
                  child: Text(l10n.cancel),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(
                    l10n.delete,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteSet(set, index);
      },
      child: GestureDetector(
      onTap: widget.onSetUpdate != null
          ? () => _openSupersetBottomSheet(context, index, set)
          : null,
      onDoubleTap: widget.onSetUpdate != null && !_isQuickEditBlocked
          ? () => _quickEditSuperset(context, index)
          : null,
      onLongPress: widget.onSetUpdate != null && set.isCompleted
          ? () => _showSupersetUncompleteDialog(context, index)
          : () => _openSupersetBottomSheet(context, index, set),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: set.isCompleted 
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: set.isCompleted 
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header con numero set
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: set.isCompleted 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: set.isCompleted 
                              ? Theme.of(context).colorScheme.onSecondary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${l10n.superset.toUpperCase()} ${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  if (set.isCompleted)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.completed.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.touch_app,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ],
                    )
                  else
                    Text(
                      l10n.tapToExecute,
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            
            // Esercizi del superset
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...superset.exercises.asMap().entries.map((entry) {
                    final exerciseIndex = entry.key;
                    final exerciseItem = entry.value;
                    
                    // Get the corresponding set for this exercise
                    if (exerciseIndex < exerciseItem.sets.length && index < exerciseItem.sets.length) {
                      final exerciseSet = exerciseItem.sets[index];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: set.isCompleted 
                                    ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                                    : Theme.of(context).colorScheme.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${exerciseIndex + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: set.isCompleted 
                                        ? Theme.of(context).colorScheme.secondary
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          exerciseItem.name,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: set.isCompleted 
                                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                                                : Theme.of(context).colorScheme.onSurface,
                                            decoration: set.isCompleted ? TextDecoration.lineThrough : null,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Show RPE if completed
                                      if (set.isCompleted && exerciseSet.rpe != null && exerciseSet.rpe! > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getRpeColor(exerciseSet.rpe!).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: _getRpeColor(exerciseSet.rpe!).withOpacity(0.4),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            'RPE ${exerciseSet.rpe}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getRpeColor(exerciseSet.rpe!),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    set.isCompleted && exerciseSet.actualReps != null
                                        ? '${exerciseSet.weight?.toStringAsFixed(1) ?? '0'} kg × ${exerciseSet.actualReps} reps'
                                        : 'Target: ${exerciseSet.weight?.toStringAsFixed(1) ?? '0'} kg × ${exerciseSet.reps ?? 0} reps',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (set.isCompleted)
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            else
                              Icon(
                                Icons.radio_button_unchecked,
                                size: 16,
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                              ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            
            // Completion indicator
            const SizedBox(width: 8),
            if (set.isCompleted)
              Icon(
                Icons.check_circle,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              )
            else
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Theme.of(context).colorScheme.outline,
              ),
          ],
        ),
      ),
      ),
    );
  }

  void _openSupersetBottomSheet(BuildContext context, int setIndex, ExerciseSet set) {
    if (set.isCompleted) {
      // If already completed, allow editing
      _editSuperset(context, setIndex);
      return;
    }
    
    // Start tracking duration for this superset set
    final durationTracker = ref.read(setDurationTrackerProvider);
    durationTracker.setStartTime(exercise!.id, setIndex + 1, DateTime.now());
    debugPrint('⏱️ Started tracking superset ${setIndex + 1} execution');
    
    if (exercise is! SupersetExercise) {
      debugPrint('❌ Error: exercise is not SupersetExercise, it is ${exercise.runtimeType}');
      return;
    }
    
    final superset = exercise as SupersetExercise;
    
    // Prepare exercise names and sets for superset modal
    final exerciseNames = superset.exercises.map((e) => e.name).toList();
    final exerciseSets = <String, ExerciseSet>{};
    
    debugPrint('🔍 Superset "${superset.name}" has ${superset.exercises.length} exercises');
    for (int i = 0; i < superset.exercises.length; i++) {
      debugPrint('   ${i + 1}. ${superset.exercises[i].name}');
    }
    debugPrint('🔍 exerciseNames: $exerciseNames');
    
    for (final ex in superset.exercises) {
      // Get the corresponding set for this exercise, or create a default one
      ExerciseSet exerciseSet;
      if (setIndex < ex.sets.length) {
        exerciseSet = ex.sets[setIndex];
        debugPrint('📦 Using existing set for ${ex.name}: weight=${exerciseSet.weight}, reps=${exerciseSet.reps}, actualReps=${exerciseSet.actualReps}');
      } else {
        // Create a new set based on the last set's values
        final defaultWeight = ex.sets.isNotEmpty ? ex.sets.last.weight : 20.0;
        final defaultReps = ex.sets.isNotEmpty ? ex.sets.last.reps : 10;
        exerciseSet = ExerciseSet(
          setNumber: setIndex + 1,
          weight: defaultWeight,
          reps: defaultReps,
          isCompleted: false,
        );
        debugPrint('📦 Creating new set for ${ex.name}: weight=$defaultWeight, reps=$defaultReps');
      }
      exerciseSets[ex.name] = exerciseSet;
    }
    
    RpeSelectorBottomSheet.showForSuperset(
      context: context,
      exerciseNames: exerciseNames,
      exerciseSets: exerciseSets,
      onConfirm: (updatedSets) {
        _completeSupersetWithData(context, setIndex, updatedSets);
      },
    );
  }
  
  void _completeSupersetWithData(
    BuildContext context, 
    int setIndex, 
    Map<String, ExerciseSet> exerciseSets,
  ) {
    // Track set duration for the superset
    final durationTracker = ref.read(setDurationTrackerProvider);
    final durationMs = durationTracker.onSetCompleted(exercise!.id, setIndex + 1);
    
    final superset = exercise as SupersetExercise;
    final updatedExercises = <Exercise>[];
    
    // Update each exercise in the superset
    debugPrint('🔄 Updating ${superset.exercises.length} exercises in superset');
    
    for (final ex in superset.exercises) {
      debugPrint('🔄 Processing exercise: ${ex.name}');
      final exerciseSet = exerciseSets[ex.name];
      
      if (exerciseSet != null) {
        final updatedSets = List<ExerciseSet>.from(ex.sets);
        debugPrint('  - Original sets count: ${updatedSets.length}');
        debugPrint('  - Set index to update: $setIndex');
        debugPrint('  - New set data: ${exerciseSet.weight}kg x ${exerciseSet.actualReps ?? exerciseSet.reps} reps, RPE: ${exerciseSet.rpe}, completed: ${exerciseSet.isCompleted}');
        
        // Ensure we have enough sets
        while (updatedSets.length <= setIndex) {
          updatedSets.add(ExerciseSet(
            setNumber: updatedSets.length + 1,
            weight: updatedSets.isNotEmpty ? updatedSets.last.weight : 20.0,
            reps: updatedSets.isNotEmpty ? updatedSets.last.reps : 10,
            isCompleted: false,
          ));
          debugPrint('  - Added placeholder set ${updatedSets.length}');
        }
        
        // Update the specific set
        final oldSet = updatedSets[setIndex];
        updatedSets[setIndex] = exerciseSet;
        debugPrint('  - Updated set ${setIndex + 1}: ${oldSet.isCompleted} -> ${exerciseSet.isCompleted}');
        debugPrint('  - Final exerciseSet details: weight=${exerciseSet.weight}, reps=${exerciseSet.actualReps ?? exerciseSet.reps}, isCompleted=${exerciseSet.isCompleted}');
        
        final updatedExercise = ex.copyWith(sets: updatedSets);
        updatedExercises.add(updatedExercise);
        debugPrint('  - ✅ Exercise ${ex.name} updated successfully');
      } else {
        debugPrint('  - ⚠️ No set data found for ${ex.name}, keeping original');
        updatedExercises.add(ex);
      }
    }
    
    // Update the main superset - ALSO update its sets to reflect completion
    // The superset's sets should mirror the completion state of its exercises
    final updatedSupersetSets = List<ExerciseSet>.from(superset.sets);
    
    // Ensure we have enough sets
    while (updatedSupersetSets.length <= setIndex) {
      updatedSupersetSets.add(ExerciseSet(
        setNumber: updatedSupersetSets.length + 1,
        weight: 0,
        reps: 0,
        isCompleted: false,
      ));
    }
    
    // Mark this set as completed in the superset's own sets
    updatedSupersetSets[setIndex] = ExerciseSet(
      setNumber: setIndex + 1,
      weight: 0, // Superset doesn't have specific weight/reps
      reps: 0,
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    
    final updatedSuperset = superset.copyWith(
      exercises: updatedExercises,
      sets: updatedSupersetSets, // Also update the superset's own sets!
    );
    
    debugPrint('🔄 About to call widget.onExerciseUpdate with updated superset');
    debugPrint('🔄 Updated superset has ${updatedSuperset.exercises.length} exercises');
    debugPrint('🔄 Superset sets count: ${updatedSuperset.sets.length}, current set completed: ${updatedSupersetSets[setIndex].isCompleted}');
    
    for (int i = 0; i < updatedSuperset.exercises.length; i++) {
      final ex = updatedSuperset.exercises[i];
      if (setIndex < ex.sets.length) {
        final updatedSet = ex.sets[setIndex];
        debugPrint('🔄   ${ex.name} set ${setIndex + 1}: completed=${updatedSet.isCompleted}, reps=${updatedSet.actualReps ?? updatedSet.reps}, weight=${updatedSet.weight}');
        debugPrint('🔄   Full set data: $updatedSet');
      }
    }
    
    widget.onExerciseUpdate?.call(updatedSuperset);
    debugPrint('🔄 widget.onExerciseUpdate called successfully');
    
    // Log the completion with details
    debugPrint('🏋️ Superset ${setIndex + 1} completed:');
    exerciseSets.forEach((exerciseName, set) {
      debugPrint('  - Exercise $exerciseName: ${set.reps} reps, RPE ${set.rpe}, ${set.weight}kg');
    });
    if (durationMs != null) {
      debugPrint('  - Duration: ${(durationMs / 1000).toStringAsFixed(1)}s');
    }
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Superset ${setIndex + 1} completed! 💪'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        duration: const Duration(milliseconds: 1500),
      ),
    );
    
    // Start rest timer only if not the last set
    debugPrint('🕰️ Timer check: setIndex=$setIndex, totalSets=${updatedSuperset.sets.length}');
    
    if (setIndex < updatedSuperset.sets.length - 1) {
      debugPrint('🕰️ Starting rest timer for superset...');
      // Create a representative set for the rest timer
      final representativeSet = ExerciseSet(
        setNumber: setIndex + 1,
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      _startRestTimerWithSetInfo(context, representativeSet);
      debugPrint('🕰️ Rest timer started!');
    } else {
      debugPrint('🏁 This is the last set, no timer needed');
    }
    
    HapticFeedback.mediumImpact();
    
    // Force UI refresh
    if (mounted) {
      setState(() {
        // Trigger rebuild to show updated state
      });
    }
  }
  
  void _quickEditSuperset(BuildContext context, int setIndex) {
    if (exercise == null || widget.onExerciseUpdate == null || _isQuickEditBlocked) {
      debugPrint('🚫 Quick edit superset blocked - preventing accidental overlay');
      return;
    }
    
    final supersetExercise = exercise as SupersetExercise;
    debugPrint('⚡ Quick edit superset set ${setIndex + 1}');
    
    // Get the position of the set item for the overlay
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    
    // Prepare exercise names and sets for superset overlay
    final exerciseNames = supersetExercise.exercises.map((e) => e.name).toList();
    final exerciseSets = <String, ExerciseSet>{};
    
    for (final ex in supersetExercise.exercises) {
      // Get the corresponding set for this exercise, or create a default one
      ExerciseSet exerciseSet;
      if (setIndex < ex.sets.length) {
        exerciseSet = ex.sets[setIndex];
      } else {
        exerciseSet = ExerciseSet(
          setNumber: setIndex + 1,
          weight: ex.sets.isNotEmpty ? ex.sets.last.weight : 20.0,
          reps: ex.sets.isNotEmpty ? ex.sets.last.reps : 10,
          isCompleted: false,
        );
      }
      exerciseSets[ex.name] = exerciseSet;
    }
    
    debugPrint('⚡ Quick edit data: ${exerciseNames.length} exercises');
    
    // Haptic feedback for quick edit
    HapticFeedback.selectionClick();
    
    // Show superset quick edit overlay using unified QuickEditOverlayV2
    context.showQuickEditOverlayV2ForSuperset(
      exerciseNames: exerciseNames,
      exerciseSets: exerciseSets,
      position: position,
      onSave: (updatedSets) {
        _updateSupersetQuickEdit(context, setIndex, updatedSets);
      },
    );
  }
  
  void _updateSupersetQuickEdit(
    BuildContext context, 
    int setIndex, 
    Map<String, ExerciseSet> updatedSets,
  ) {
    final superset = exercise as SupersetExercise;
    final updatedExercises = <Exercise>[];
    
    debugPrint('🔄 Quick edit update: updating ${updatedSets.length} exercises');
    
    // Update each exercise in the superset
    for (final ex in superset.exercises) {
      final updatedSet = updatedSets[ex.name];
      if (updatedSet != null) {
        final updatedSetsList = List<ExerciseSet>.from(ex.sets);
        
        // Ensure we have enough sets
        while (updatedSetsList.length <= setIndex) {
          updatedSetsList.add(ExerciseSet(
            setNumber: updatedSetsList.length + 1,
            weight: updatedSetsList.isNotEmpty ? updatedSetsList.last.weight : 20.0,
            reps: updatedSetsList.isNotEmpty ? updatedSetsList.last.reps : 10,
            isCompleted: false,
          ));
        }
        
        // Update the specific set
        updatedSetsList[setIndex] = updatedSet;
        updatedExercises.add(ex.copyWith(sets: updatedSetsList));
        
        debugPrint('🔄   ${ex.name}: ${updatedSet.weight}kg x ${updatedSet.reps} reps');
      } else {
        updatedExercises.add(ex);
      }
    }
    
    // Update the main superset
    final updatedSuperset = superset.copyWith(exercises: updatedExercises);
    widget.onExerciseUpdate?.call(updatedSuperset);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Superset set ${setIndex + 1} updated! ⚡'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(milliseconds: 1200),
      ),
    );
    
    HapticFeedback.lightImpact();
  }
  
  void _showSupersetTooltip(BuildContext context, SupersetExercise superset) {
    SupersetExercisesTooltip.show(
      context: context,
      supersetExercise: superset,
      onExerciseInfo: (exercise) async {
        final exerciseData = await _loadExerciseDataFromJsonForExercise(exercise.name);
        if (exerciseData != null && context.mounted) {
          _showExerciseInfoModalForExercise(context, exercise.name, exerciseData);
        }
      },
      onWarmupPrevention: (exercise) async {
        final exerciseData = await _loadExerciseDataFromJsonForExercise(exercise.name);
        if (exerciseData != null && _hasWarmupData(exerciseData) && context.mounted) {
          _showWarmupModalForExercise(context, exercise.name, exerciseData);
        }
      },
      onTechniqueTips: (exercise) async {
        final exerciseData = await _loadExerciseDataFromJsonForExercise(exercise.name);
        if (exerciseData != null && context.mounted) {
          _showTechniqueTipsModalForExercise(context, exercise.name, exerciseData);
        }
      },
    );
  }

  Future<Map<String, dynamic>?> _loadExerciseDataFromJsonForExercise(String exerciseName) async {
    try {
      // Prima prova a caricare i dati merged con correzioni community
      final mergedData = await ref.read(
        exerciseDataProvider(exerciseName).future
      );
      
      if (mergedData.isNotEmpty) {
        // Se ci sono correzioni community, mostra un indicatore
        if (mergedData['hasCommunityCorrections'] == true) {
          print('✅ Using community-corrected data for $exerciseName');
        }
        return mergedData;
      }
    } catch (e) {
      print('Could not load merged data, falling back to JSON: $e');
    }
    
    try {
      final String response = await rootBundle.loadString('assets/data/exercises.json');
      final Map<String, dynamic> data = jsonDecode(response);
      
      // Trova l'esercizio per nome (case insensitive)
      for (final entry in data.entries) {
        final exerciseData = entry.value as Map<String, dynamic>;
        if (exerciseData['nome']?.toString().toLowerCase() == exerciseName.toLowerCase()) {
          return exerciseData;
        }
      }
      
      print('Exercise $exerciseName not found in JSON data');
      return null;
    } catch (e) {
      print('Error loading exercise data: $e');
      return null;
    }
  }

  void _showExerciseInfoModalForExercise(BuildContext context, String exerciseName, Map<String, dynamic> data) {
    final groups = <_GroupedModalSection>[];
    
    // Group 1: Target Muscles
    final muscleItems = <_ModalItem>[];
    if (data['focus'] != null) {
      muscleItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.primaryMuscles,
        value: data['focus'] is List 
            ? (data['focus'] as List).join(', ')
            : data['focus'].toString(),
        icon: Icons.accessibility_new,
      ));
    }
    
    if (data['secondari'] != null) {
      muscleItems.add(_ModalItem(
        label: AppLocalizations.of(context)!.secondaryMuscles,
        value: data['secondari'] is List
            ? (data['secondari'] as List).join(', ')
            : data['secondari'].toString(),
        icon: Icons.accessibility,
      ));
    }
    
    if (muscleItems.isNotEmpty) {
      groups.add(_GroupedModalSection(
        groupTitle: 'Muscoli coinvolti',
        groupIcon: Icons.fitness_center,
        items: muscleItems,
        accentColor: Colors.blueAccent,
      ));
    }
    
    // Group 2: Exercise Details
    final detailItems = <_ModalItem>[];
    
    if (data['tipoEsercizio'] != null) {
      detailItems.add(_ModalItem(
        label: 'Tipo esercizio',
        value: data['tipoEsercizio'].toString(),
        icon: Icons.category,
      ));
    }
    
    if (data['attrezzatura'] != null) {
      detailItems.add(_ModalItem(
        label: 'Attrezzatura',
        value: data['attrezzatura'] is List
            ? (data['attrezzatura'] as List).join(', ')
            : data['attrezzatura'].toString(),
        icon: Icons.fitness_center,
      ));
    }
    
    if (data['rangeRipetizioni'] != null) {
      detailItems.add(_ModalItem(
        label: 'Range ripetizioni',
        value: data['rangeRipetizioni'].toString(),
        icon: Icons.repeat,
      ));
    }
    
    if (detailItems.isNotEmpty) {
      groups.add(_GroupedModalSection(
        groupTitle: 'Dettagli esercizio',
        groupIcon: Icons.info,
        items: detailItems,
        accentColor: Colors.green,
      ));
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGroupedPremiumModal(
        context: context,
        title: exerciseName,
        icon: Icons.info_outline,
        color: Colors.blue,
        groups: groups,
        onCorrection: () {
          Navigator.pop(context);
          _openContributionModal(ContributionType.correction, contextType: 'exercise_info');
        },
        onAddTip: () {
          Navigator.pop(context);
          _openContributionModal(ContributionType.tip, contextType: 'exercise_info');
        },
      ),
    );
  }

  void _showWarmupModalForExercise(BuildContext context, String exerciseName, Map<String, dynamic> data) {
    final groups = <_GroupedModalSection>[];
    
    // Group 1: Warmup
    final warmupItems = <_ModalItem>[];
    
    if (data['riscaldamentoGenerale'] != null) {
      warmupItems.add(_ModalItem(
        label: 'Riscaldamento generale',
        value: data['riscaldamentoGenerale'].toString(),
        icon: Icons.directions_run,
      ));
    }
    
    if (data['riscaldamentoSpecifico'] != null) {
      warmupItems.add(_ModalItem(
        label: 'Riscaldamento specifico',
        value: data['riscaldamentoSpecifico'].toString(),
        icon: Icons.track_changes,
      ));
    }
    
    if (data['mobilita'] != null) {
      warmupItems.add(_ModalItem(
        label: 'Mobilità',
        value: data['mobilita'].toString(),
        icon: Icons.accessibility_new,
      ));
    }
    
    if (warmupItems.isNotEmpty) {
      groups.add(_GroupedModalSection(
        groupTitle: 'Riscaldamento',
        groupIcon: Icons.whatshot,
        items: warmupItems,
        accentColor: Colors.orange,
      ));
    }
    
    // Group 2: Prevention
    final preventionItems = <_ModalItem>[];
    
    if (data['prevenzioneInfortuni'] != null) {
      preventionItems.add(_ModalItem(
        label: 'Prevenzione infortuni',
        value: data['prevenzioneInfortuni'].toString(),
        icon: Icons.healing,
      ));
    }
    
    if (data['erroriComuni'] != null) {
      preventionItems.add(_ModalItem(
        label: 'Errori comuni',
        value: data['erroriComuni'].toString(),
        icon: Icons.warning,
      ));
    }
    
    if (preventionItems.isNotEmpty) {
      groups.add(_GroupedModalSection(
        groupTitle: 'Prevenzione',
        groupIcon: Icons.shield,
        items: preventionItems,
        accentColor: Colors.red,
      ));
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGroupedPremiumModal(
        context: context,
        title: '$exerciseName - Riscaldamento',
        icon: Icons.whatshot,
        color: Colors.orange,
        groups: groups,
        onCorrection: () {
          Navigator.pop(context);
          _openContributionModal(ContributionType.correction, contextType: 'warmup');
        },
        onAddTip: () {
          Navigator.pop(context);
          _openContributionModal(ContributionType.tip, contextType: 'warmup');
        },
      ),
    );
  }

  void _showTechniqueTipsModalForExercise(BuildContext context, String exerciseName, Map<String, dynamic> data) {
    final groups = <_GroupedModalSection>[];
    
    // Group 1: Technique Details
    final techniqueItems = <_ModalItem>[];
    
    if (data['tecnicaEsecuzione'] != null) {
      techniqueItems.add(_ModalItem(
        label: 'Tecnica esecuzione',
        value: data['tecnicaEsecuzione'].toString(),
        icon: Icons.school,
      ));
    }
    
    if (data['setup'] != null) {
      techniqueItems.add(_ModalItem(
        label: 'Setup',
        value: data['setup'].toString(),
        icon: Icons.settings,
      ));
    }
    
    if (data['faseConcentrica'] != null) {
      techniqueItems.add(_ModalItem(
        label: 'Fase concentrica',
        value: data['faseConcentrica'].toString(),
        icon: Icons.arrow_upward,
      ));
    }
    
    if (data['faseEccentrica'] != null) {
      techniqueItems.add(_ModalItem(
        label: 'Fase eccentrica',
        value: data['faseEccentrica'].toString(),
        icon: Icons.arrow_downward,
      ));
    }
    
    if (techniqueItems.isNotEmpty) {
      groups.add(_GroupedModalSection(
        groupTitle: 'Tecnica',
        groupIcon: Icons.school,
        items: techniqueItems,
        accentColor: Colors.purple,
      ));
    }
    
    // Group 2: Tips & Corrections
    final tipsItems = <_ModalItem>[];
    
    if (data['consigli'] != null) {
      tipsItems.add(_ModalItem(
        label: 'Consigli',
        value: data['consigli'].toString(),
        icon: Icons.lightbulb,
      ));
    }
    
    if (data['variazioni'] != null) {
      tipsItems.add(_ModalItem(
        label: 'Variazioni',
        value: data['variazioni'].toString(),
        icon: Icons.swap_horiz,
      ));
    }
    
    if (data['progressioni'] != null) {
      tipsItems.add(_ModalItem(
        label: 'Progressioni',
        value: data['progressioni'].toString(),
        icon: Icons.trending_up,
      ));
    }
    
    if (tipsItems.isNotEmpty) {
      groups.add(_GroupedModalSection(
        groupTitle: 'Tips & Progressioni',
        groupIcon: Icons.tips_and_updates,
        items: tipsItems,
        accentColor: Colors.teal,
      ));
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGroupedPremiumModal(
        context: context,
        title: '$exerciseName - Tecnica',
        icon: Icons.school,
        color: Colors.purple,
        groups: groups,
        onCorrection: () {
          Navigator.pop(context);
          _openContributionModal(ContributionType.correction, contextType: 'technique');
        },
        onAddTip: () {
          Navigator.pop(context);
          _openContributionModal(ContributionType.tip, contextType: 'technique');
        },
      ),
    );
  }

  void _editSuperset(BuildContext context, int setIndex) {
    if (exercise is! SupersetExercise) return;
    
    final superset = exercise as SupersetExercise;
    
    // Prepare exercise names and sets for editing completed superset
    final exerciseNames = superset.exercises.map((e) => e.name).toList();
    final exerciseSets = <String, ExerciseSet>{};
    
    // Get the completed sets with their values
    for (final ex in superset.exercises) {
      if (setIndex < ex.sets.length) {
        exerciseSets[ex.name] = ex.sets[setIndex];
      }
    }
    
    // Show RPE selector to edit the completed superset
    RpeSelectorBottomSheet.showForSuperset(
      context: context,
      exerciseNames: exerciseNames,
      exerciseSets: exerciseSets,
      onConfirm: (updatedSets) {
        _updateSupersetFromEdit(context, setIndex, updatedSets);
      },
    );
  }
  
  Color _getRpeColor(int rpe) {
    if (rpe <= 6) return Colors.green;
    if (rpe <= 7) return Colors.lightGreen;
    if (rpe <= 8) return Colors.orange;
    if (rpe <= 9) return Colors.deepOrange;
    return Colors.red;
  }
  
  int _calculateSmartRestTime(int reps) {
    // Smart rest time calculation based on rep range
    if (reps <= 5) {
      return 180; // 3 minutes for strength
    } else if (reps <= 8) {
      return 120; // 2 minutes for hypertrophy
    } else if (reps <= 12) {
      return 90;  // 1.5 minutes for muscle building
    } else {
      return 60;  // 1 minute for endurance
    }
  }
  
  void _showSupersetUncompleteDialog(BuildContext context, int setIndex) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.uncompleteSet),
        content: Text(l10n.confirmUncompleteSet),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _uncompleteSupersetSet(context, setIndex);
            },
            child: Text(
              l10n.uncomplete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
  
  void _uncompleteSupersetSet(BuildContext context, int setIndex) {
    if (exercise is! SupersetExercise) return;
    
    final l10n = AppLocalizations.of(context)!;
    final superset = exercise as SupersetExercise;
    
    // Reset each exercise set to uncompleted state
    final updatedExercises = superset.exercises.map((ex) {
      if (setIndex < ex.sets.length) {
        final updatedSets = List<ExerciseSet>.from(ex.sets);
        updatedSets[setIndex] = updatedSets[setIndex].copyWith(
          isCompleted: false,
          actualReps: null,
          rpe: null,
          completedAt: null,
        );
        return ex.copyWith(sets: updatedSets);
      }
      return ex;
    }).toList();
    
    // Reset the superset's main set
    final updatedSupersetSets = List<ExerciseSet>.from(superset.sets);
    if (setIndex < updatedSupersetSets.length) {
      updatedSupersetSets[setIndex] = updatedSupersetSets[setIndex].copyWith(
        isCompleted: false,
        completedAt: null,
      );
    }
    
    final updatedSuperset = superset.copyWith(
      exercises: updatedExercises,
      sets: updatedSupersetSets,
    );
    
    widget.onExerciseUpdate?.call(updatedSuperset);
    
    // Show feedback
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Set ${setIndex + 1} ${l10n.uncompleted}'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }
  
  void _updateSupersetFromEdit(BuildContext context, int setIndex, Map<String, ExerciseSet> updatedSets) {
    if (exercise is! SupersetExercise) return;
    final superset = exercise as SupersetExercise;
    
    // Update each exercise with the new values
    final updatedExercises = superset.exercises.map((ex) {
      if (updatedSets.containsKey(ex.name)) {
        final updatedSet = updatedSets[ex.name]!;
        final updatedExerciseSets = List<ExerciseSet>.from(ex.sets);
        if (setIndex < updatedExerciseSets.length) {
          updatedExerciseSets[setIndex] = updatedSet;
        }
        return ex.copyWith(sets: updatedExerciseSets);
      }
      return ex;
    }).toList();
    
    // Update the superset's main sets array
    final updatedSupersetSets = List<ExerciseSet>.from(superset.sets);
    if (setIndex < updatedSupersetSets.length) {
      updatedSupersetSets[setIndex] = updatedSupersetSets[setIndex].copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
    }
    
    final updatedSuperset = superset.copyWith(
      exercises: updatedExercises,
      sets: updatedSupersetSets,
    );
    
    widget.onExerciseUpdate?.call(updatedSuperset);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Set ${setIndex + 1} aggiornato'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }
  
  // DROPSET METHODS
  Widget _buildDropSetItem(BuildContext context, int index, ExerciseSet set, AppConfig config, DropSetExercise dropset) {
    
    return GestureDetector(
      onTap: () => _openDropSetBottomSheet(context, index, set),
      onDoubleTap: widget.onSetUpdate != null && !_isQuickEditBlocked
          ? () => _quickEditDropSet(context, index)
          : null,
      onLongPress: widget.onSetUpdate != null 
          ? () => _editDropSet(context, index)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: set.isCompleted 
                ? [
                    Theme.of(context).colorScheme.error.withOpacity(0.15),
                    Theme.of(context).colorScheme.error.withOpacity(0.05),
                  ]
                : [
                    Theme.of(context).colorScheme.error.withOpacity(0.08),
                    Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: set.isCompleted 
                ? Theme.of(context).colorScheme.error.withOpacity(0.4)
                : Theme.of(context).colorScheme.error.withOpacity(0.2),
            width: set.isCompleted ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Drop indicator
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: set.isCompleted 
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.error.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: set.isCompleted 
                          ? Theme.of(context).colorScheme.onError
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Dropset info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'DROPSET',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${dropset.stages.length} drops',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      set.isCompleted 
                          ? 'Completato ✓'
                          : 'Tap per eseguire',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: set.isCompleted 
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Completion indicator
              if (set.isCompleted)
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                )
              else
                Icon(
                  Icons.arrow_drop_down_circle,
                  size: 20,
                  color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _openDropSetBottomSheet(BuildContext context, int setIndex, ExerciseSet set) {
    if (exercise == null) return;
    
    if (set.isCompleted) {
      _editDropSet(context, setIndex);
      return;
    }
    
    final dropset = exercise! as DropSetExercise;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DropSetExecutionSheet(
        dropset: dropset,
        setIndex: setIndex,
        onComplete: (weights, actualReps, rpes) {
          _completeDropSetWithFeedback(context, setIndex, weights, actualReps, rpes);
        },
      ),
    );
  }
  
  void _completeDropSetWithFeedback(
    BuildContext context,
    int setIndex,
    List<double> weights,
    List<int> actualReps,
    List<int> rpes,
  ) {
    if (exercise == null) return;
    
    // Mark the set as completed
    final updatedSet = exercise!.sets[setIndex].copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    
    final updatedSets = List<ExerciseSet>.from(exercise!.sets);
    updatedSets[setIndex] = updatedSet;
    
    final updatedExercise = exercise!.copyWith(sets: updatedSets);
    widget.onExerciseUpdate?.call(updatedExercise);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dropset ${setIndex + 1} completato! 🔥'),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(milliseconds: 1500),
      ),
    );
    
    // Start rest timer if not the last set
    if (setIndex < exercise!.sets.length - 1) {
      _startRestTimerWithSetInfo(context, updatedSet);
    }
    
    HapticFeedback.mediumImpact();
  }
  
  void _quickEditDropSet(BuildContext context, int setIndex) {
    // TODO: Implement quick edit for dropset
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quick edit for dropset coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  void _editDropSet(BuildContext context, int setIndex) {
    // TODO: Implement full edit for dropset
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit dropset coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  // REST-PAUSE METHODS
  Widget _buildRestPauseItem(BuildContext context, int index, ExerciseSet set, AppConfig config, RestPauseExercise restPause) {
    
    return GestureDetector(
      onTap: () => _openRestPauseBottomSheet(context, index, set),
      onDoubleTap: widget.onSetUpdate != null && !_isQuickEditBlocked
          ? () => _quickEditRestPause(context, index)
          : null,
      onLongPress: widget.onSetUpdate != null 
          ? () => _editRestPause(context, index)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: set.isCompleted 
                ? [
                    Theme.of(context).colorScheme.tertiary.withOpacity(0.15),
                    Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
                  ]
                : [
                    Theme.of(context).colorScheme.tertiary.withOpacity(0.08),
                    Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: set.isCompleted 
                ? Theme.of(context).colorScheme.tertiary.withOpacity(0.4)
                : Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
            width: set.isCompleted ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Rest-pause indicator
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: set.isCompleted 
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: set.isCompleted 
                          ? Theme.of(context).colorScheme.onTertiary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Rest-pause info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'REST-PAUSE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${restPause.pauseDuration}s pause · ${restPause.miniSets} mini-set',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      set.isCompleted 
                          ? 'Completato ✓'
                          : 'Tap per eseguire',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: set.isCompleted 
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Completion indicator
              if (set.isCompleted)
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                )
              else
                Icon(
                  Icons.pause_circle_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _openRestPauseBottomSheet(BuildContext context, int setIndex, ExerciseSet set) {
    if (exercise == null) return;
    
    if (set.isCompleted) {
      _editRestPause(context, setIndex);
      return;
    }
    
    final restPause = exercise! as RestPauseExercise;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RestPauseExecutionSheet(
        restPause: restPause,
        setIndex: setIndex,
        onComplete: (weight, reps, rpe) {
          _completeRestPauseWithFeedback(context, setIndex, weight, reps, rpe);
        },
      ),
    );
  }
  
  void _completeRestPauseWithFeedback(
    BuildContext context,
    int setIndex,
    double weight,
    List<int> reps,
    int rpe,
  ) {
    if (exercise == null) return;
    
    // Calculate total reps
    final totalReps = reps.fold(0, (sum, r) => sum + r);
    
    // Mark the set as completed
    final updatedSet = exercise!.sets[setIndex].copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      weight: weight,
      reps: totalReps,
      rpe: rpe,
    );
    
    final updatedSets = List<ExerciseSet>.from(exercise!.sets);
    updatedSets[setIndex] = updatedSet;
    
    final updatedExercise = exercise!.copyWith(sets: updatedSets);
    widget.onExerciseUpdate?.call(updatedExercise);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rest-Pause ${setIndex + 1} completato! 💪 Totale: $totalReps reps'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        duration: const Duration(milliseconds: 2000),
      ),
    );
    
    // Start rest timer if not the last set
    if (setIndex < exercise!.sets.length - 1) {
      _startRestTimerWithSetInfo(context, updatedSet);
    }
    
    HapticFeedback.mediumImpact();
  }
  
  void _quickEditRestPause(BuildContext context, int setIndex) {
    // TODO: Implement quick edit for rest-pause
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quick edit for rest-pause coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  void _editRestPause(BuildContext context, int setIndex) {
    // TODO: Implement full edit for rest-pause
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit rest-pause coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _addWarmupSets(List<ExerciseSet> warmupSets) {
    if (exercise == null || widget.onExerciseUpdate == null) return;
    
    // Special handling for superset
    final ex = exercise;
    if (ex is SupersetExercise) {
      debugPrint('🔥 Adding warmup sets to superset');
      
      // Add warmup sets to each exercise in the superset
      final updatedExercises = ex.exercises.map((ex) {
        final updatedSets = <ExerciseSet>[];
        
        // Add warmup sets with correct numbering and warmup flag
        for (var i = 0; i < warmupSets.length; i++) {
          // Use weights appropriate for this specific exercise if available
          final warmupWeight = warmupSets[i].weight ?? 
              (ex.sets.isNotEmpty ? (ex.sets.first.weight ?? 20.0) * 0.5 : 20.0);
          
          updatedSets.add(ExerciseSet(
            setNumber: i + 1,
            weight: warmupWeight,
            reps: warmupSets[i].reps ?? 10,
            isWarmup: true,
          ));
        }
        
        debugPrint('  - Added ${warmupSets.length} warmup sets to ${ex.name}');
        
        // Renumber existing sets
        for (var i = 0; i < ex.sets.length; i++) {
          updatedSets.add(ex.sets[i].copyWith(
            setNumber: updatedSets.length + 1,
          ));
        }
        
        return ex.copyWith(sets: updatedSets);
      }).toList();
      
      // Also update superset's own sets
      final updatedSupersetSets = <ExerciseSet>[];
      
      // Add warmup sets
      for (var i = 0; i < warmupSets.length; i++) {
        updatedSupersetSets.add(ExerciseSet(
          setNumber: i + 1,
          weight: 0,
          reps: 0,
          isWarmup: true,
        ));
      }
      
      // Renumber existing sets
      for (var i = 0; i < ex.sets.length; i++) {
        updatedSupersetSets.add(ex.sets[i].copyWith(
          setNumber: updatedSupersetSets.length + 1,
        ));
      }
      
      final updatedSuperset = ex.copyWith(
        exercises: updatedExercises,
        sets: updatedSupersetSets,
      );
      
      widget.onExerciseUpdate!(updatedSuperset);
    } else {
      // Normal exercise handling
      // Add warmup sets at the beginning with proper numbering
      final updatedSets = <ExerciseSet>[];
      
      // Add warmup sets with correct numbering and warmup flag
      for (var i = 0; i < warmupSets.length; i++) {
        updatedSets.add(warmupSets[i].copyWith(
          setNumber: i + 1,
          isWarmup: true, // Ensure warmup flag is set
        ));
      }
      
      debugPrint('🔥 Adding ${warmupSets.length} warmup sets');
      
      // Renumber existing sets
      for (var i = 0; i < exercise!.sets.length; i++) {
        updatedSets.add(exercise!.sets[i].copyWith(
          setNumber: updatedSets.length + 1,
        ));
      }
      
      final updatedExercise = exercise!.copyWith(
        sets: updatedSets,
      );
      
      widget.onExerciseUpdate!(updatedExercise);
    }
    
    setState(() {
      _warmupSuggestionDismissed = true;
    });
  }
}

// Community Contribution Modal
class _CommunityContributionModal extends ConsumerStatefulWidget {
  final Exercise exercise;
  final ContributionType suggestionType;
  final String? initialSuggestion;
  final String? contextType;
  final Map<String, dynamic>? exerciseData;
  
  const _CommunityContributionModal({
    required this.exercise,
    required this.suggestionType,
    this.initialSuggestion,
    this.contextType,
    this.exerciseData,
  });
  
  @override
  ConsumerState<_CommunityContributionModal> createState() => 
      _CommunityContributionModalState();
}

class _CommunityContributionModalState 
    extends ConsumerState<_CommunityContributionModal> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  ContributionType _selectedType = ContributionType.tip;
  String? _selectedSection;
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    _selectedType = widget.suggestionType;
    _titleController = TextEditingController(
      text: _getContextualTitle(),
    );
    _descriptionController = TextEditingController(
      text: widget.initialSuggestion ?? '',
    );
  }
  
  String _getContextualTitle() {
    if (widget.contextType == null) return '';
    
    switch (widget.contextType) {
      case 'exercise_info':
        return _selectedType == ContributionType.correction
            ? 'Correzione info muscoli/tecnica'
            : 'Nuovo tip per ${widget.exercise.name}';
      case 'warmup':
        return _selectedType == ContributionType.correction
            ? 'Correzione info riscaldamento'
            : 'Consiglio warmup per ${widget.exercise.name}';
      case 'injury_prevention':
        return _selectedType == ContributionType.correction
            ? 'Correzione info sicurezza'
            : 'Avviso sicurezza per ${widget.exercise.name}';
      default:
        return '';
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _submitContribution() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Compila tutti i campi obbligatori'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Per le correzioni, salva anche il campo specifico e i valori
      String? originalValue;
      String? suggestedValue;
      
      if (_selectedType == ContributionType.correction && _selectedSection != null) {
        originalValue = _getCurrentSectionValue(_selectedSection!);
        suggestedValue = _descriptionController.text;
      }
      
      await ref.read(contributionSubmissionProvider.notifier).submitContribution(
        exerciseId: widget.exercise.id,
        exerciseName: widget.exercise.name,
        type: _selectedType,
        title: _titleController.text,
        description: _descriptionController.text,
        originalValue: originalValue,
        suggestedValue: suggestedValue,
        metadata: _selectedType == ContributionType.correction && _selectedSection != null
          ? {'field': _selectedSection}
          : null,
      );
      
      if (mounted) {
        // Haptic feedback di successo
        HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        HapticFeedback.lightImpact();
        
        // Chiudi modal
        Navigator.of(context).pop();
        
        // Mostra dialogo di successo premium
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Errore: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ContributionSuccessDialog(
        contributionType: _selectedType,
        onViewContribution: () {
          Navigator.of(context).pop();
          // Naviga alla tab "I Miei" nel Community Hub
          Navigator.pushNamed(context, '/community_hub');
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
    
    // Auto-dismiss dopo 5 secondi
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.people_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contribuisci alla Community',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Aiuta altri utenti con ${widget.exercise.name}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type selector
                  Text(
                    'Tipo di contributo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTypeChip(
                        ContributionType.tip, 
                        '💡 Consiglio', 
                        theme
                      ),
                      _buildTypeChip(
                        ContributionType.warning, 
                        '⚠️ Avviso', 
                        theme
                      ),
                      _buildTypeChip(
                        ContributionType.correction, 
                        '✏️ Correzione', 
                        theme
                      ),
                      _buildTypeChip(
                        ContributionType.technique, 
                        '🎯 Tecnica', 
                        theme
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Section selector for corrections
                  if (_selectedType == ContributionType.correction && widget.contextType != null)
                    ...[
                      Text(
                        'Sezione da correggere',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _getSectionOptions().map((section) {
                          final isSelected = _selectedSection == section;
                          return ChoiceChip(
                            label: Text(section),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSection = selected ? section : null;
                                // Update title based on section
                                if (selected) {
                                  _titleController.text = 'Correzione: $section';
                                  // Pre-populate with current value
                                  _populateCurrentValue(section);
                                }
                              });
                            },
                            selectedColor: theme.colorScheme.primaryContainer,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Show current value
                      if (_selectedSection != null && _getCurrentSectionValue(_selectedSection!) != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.error.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: theme.colorScheme.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Valore attuale da correggere:',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getCurrentSectionValue(_selectedSection!) ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  
                  // Title input
                  Text(
                    'Titolo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Es: Posizione corretta della schiena',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description input
                  Text(
                    'Descrizione',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: _getDescriptionPlaceholder(),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Info box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Il tuo contributo sarà revisionato dalla community prima di essere approvato',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Submit button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submitContribution,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Invia Contributo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<String> _getSectionOptions() {
    switch (widget.contextType) {
      case 'exercise_info':
        return [
          'Muscoli primari',
          'Muscoli secondari',
          'Tipo esercizio',
          'Attrezzatura',
          'Range ripetizioni',
          'Pattern movimento',
        ];
      case 'warmup':
        return [
          'Serie riscaldamento',
          'Durata riscaldamento',
          'Mobilità articolare',
          'Attivazione muscolare',
          'Progressione carico',
        ];
      case 'injury_prevention':
        return [
          'Prevenzione infortuni',
          'Note tecniche',
          'Drill tecnico',
          'Cooldown consigliato',
          'Errori comuni',
        ];
      default:
        return [];
    }
  }
  
  String _getDescriptionPlaceholder() {
    switch (_selectedType) {
      case ContributionType.tip:
        return 'Condividi un consiglio utile che hai scoperto per questo esercizio...';
      case ContributionType.warning:
        return 'Segnala un rischio o errore comune da evitare...';
      case ContributionType.correction:
        if (_selectedSection != null) {
          return 'Spiega cosa correggere in "$_selectedSection"...';
        }
        return 'Descrivi cosa deve essere corretto e perché...';
      case ContributionType.technique:
        return 'Descrivi la tecnica corretta per eseguire questo esercizio...';
      default:
        return 'Scrivi qui il tuo contributo...';
    }
  }
  
  String? _getCurrentSectionValue(String section) {
    // Get the current value from loaded exercise data
    if (widget.exerciseData == null) return null;
    
    switch (section) {
      case 'Nome':
        return widget.exercise.name;
      case 'Serie riscaldamento':
        return widget.exerciseData?['warmupSets'];
      case 'Durata riscaldamento':
        return widget.exerciseData?['tempoWarmup'];
      case 'Tipo riscaldamento':
        return widget.exerciseData?['attivazionePre'];
      case 'Muscoli target':
        return widget.exerciseData?['focus'];
      case 'Muscoli secondari':
        return widget.exerciseData?['muscoliSecondari'];
      case 'Attrezzatura':
        return widget.exerciseData?['attrezzatura'];
      case 'Descrizione':
        return widget.exerciseData?['noteTecniche'];
      case 'Mobilità articolare':
        return widget.exerciseData?['mobilitaPre'];
      case 'Attivazione muscolare':
        return widget.exerciseData?['attivazionePre'];
      case 'Progressione carico':
        return widget.exerciseData?['warmupSets'];
      case 'Prevenzione infortuni':
        return widget.exerciseData?['prevenzioneInfortuni'];
      case 'Note tecniche':
        return widget.exerciseData?['noteTecniche'];
      case 'Drill tecnico':
        return widget.exerciseData?['drillTecnico'];
      case 'Cooldown consigliato':
        return widget.exerciseData?['cooldownConsigliato'];
      case 'Errori comuni':
        return widget.exerciseData?['erroriComuni'];
      case 'Difficoltà':
        return widget.exerciseData?['difficolta'];
      case 'Tipo esercizio':
        return widget.exerciseData?['tipoEsercizio'];
      case 'Range ripetizioni':
        return widget.exerciseData?['rangeRipetizioni'];
      case 'Pattern movimento':
        return widget.exerciseData?['patternMovimento'];
      default:
        return null;
    }
  }
  
  void _populateCurrentValue(String section) {
    final currentValue = _getCurrentSectionValue(section);
    if (currentValue != null) {
      // Pre-fill the description with current value for easy editing
      _descriptionController.text = 'Valore attuale: "$currentValue"\n\nValore corretto: ';
    }
  }
  
  Widget _buildTypeChip(ContributionType type, String label, ThemeData theme) {
    final isSelected = _selectedType == type;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedType = type;
          });
        }
      },
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
    );
  }
}

// Premium Success Dialog Widget
class _ContributionSuccessDialog extends ConsumerStatefulWidget {
  final ContributionType contributionType;
  final VoidCallback onViewContribution;
  final VoidCallback onClose;
  
  const _ContributionSuccessDialog({
    required this.contributionType,
    required this.onViewContribution,
    required this.onClose,
  });

  @override
  ConsumerState<_ContributionSuccessDialog> createState() => _ContributionSuccessDialogState();
}

class _ContributionSuccessDialogState extends ConsumerState<_ContributionSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _xpController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _xpAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _xpController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOutCubic,
    );
    
    _xpAnimation = CurvedAnimation(
      parent: _xpController,
      curve: Curves.bounceOut,
    );
    
    // Start animations in sequence
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _xpController.forward();
      HapticFeedback.lightImpact();
    });
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _xpController.dispose();
    super.dispose();
  }
  
  String _getContributionText() {
    switch (widget.contributionType) {
      case ContributionType.correction:
        return 'Correzione Inviata!';
      case ContributionType.tip:
        return 'Consiglio Inviato!';
      case ContributionType.warning:
        return 'Avviso Inviato!';
      case ContributionType.variant:
        return 'Variante Inviata!';
      case ContributionType.translation:
        return 'Traduzione Inviata!';
      case ContributionType.technique:
        return 'Tecnica Inviata!';
    }
  }
  
  int _getXPValue() {
    // Con auto-approvazione ottieni submitContribution (10) + contributionApproved (50) = 60 XP
    // Mostriamo il totale che l'utente riceverà
    return 60; // Total XP con auto-approvazione
  }
  
  String _getXPAmount() {
    return '+${_getXPValue()} XP';
  }
  
  IconData _getIcon() {
    switch (widget.contributionType) {
      case ContributionType.correction:
        return Icons.edit;
      case ContributionType.tip:
        return Icons.lightbulb;
      case ContributionType.warning:
        return Icons.warning;
      case ContributionType.variant:
        return Icons.tune;
      case ContributionType.translation:
        return Icons.translate;
      case ContributionType.technique:
        return Icons.sports_gymnastics;
    }
  }
  
  Color _getColor() {
    switch (widget.contributionType) {
      case ContributionType.correction:
        return Colors.blue;
      case ContributionType.tip:
        return Colors.green;
      case ContributionType.warning:
        return Colors.orange;
      case ContributionType.variant:
        return Colors.purple;
      case ContributionType.translation:
        return Colors.teal;
      case ContributionType.technique:
        return Colors.indigo;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor();
    
    // Get user stats for XP calculation
    final userStatsAsync = ref.watch(userContributionStatsProvider);
    final previousXP = userStatsAsync.valueOrNull?.totalPoints ?? 0;
    final xpGained = _getXPValue();
    final currentXP = previousXP + xpGained;
    final currentLevel = (currentXP / 500).floor() + 1;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with success animation
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      // Success Icon with Animation
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  color.withOpacity(0.2),
                                  color.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _checkAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _checkAnimation.value,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [color, color.withOpacity(0.8)],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        _getContributionText(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      Text(
                        'La community ti ringrazia! 🙏',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Animated XP Bar
                AnimatedBuilder(
                  animation: _xpAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * _xpAnimation.value),
                      child: Opacity(
                        opacity: _xpAnimation.value,
                        child: AnimatedXPBar(
                          currentXP: currentXP,
                          previousXP: previousXP,
                          xpGained: xpGained,
                          currentLevel: currentLevel,
                          onAnimationComplete: () {
                            // Auto close after animation completes
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) {
                                widget.onClose();
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onViewContribution,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('I Miei Contributi'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: widget.onClose,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Fantastico!'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}