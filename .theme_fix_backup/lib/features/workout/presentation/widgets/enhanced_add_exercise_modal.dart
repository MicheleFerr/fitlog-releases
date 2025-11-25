import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_selection_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_selection_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_onboarding_overlay.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// 🚀 TIER-1: Enhanced Add Exercise Modal with database selection
class EnhancedAddExerciseModal extends ConsumerStatefulWidget {
  
  const EnhancedAddExerciseModal({
    super.key,
    this.onExerciseAdded,
  });
  final Function(Exercise)? onExerciseAdded;

  @override
  ConsumerState<EnhancedAddExerciseModal> createState() => _EnhancedAddExerciseModalState();
}

class _EnhancedAddExerciseModalState extends ConsumerState<EnhancedAddExerciseModal>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // GlobalKeys for onboarding
  final _singleExerciseTabKey = GlobalKey();
  final _selectExerciseButtonKey = GlobalKey();

  // Single exercise
  ExerciseData? _selectedSingleExercise;
  final List<ExerciseSet> _sets = [
    ExerciseSet(setNumber: 1, weight: 0, reps: 10),
    ExerciseSet(setNumber: 2, weight: 0, reps: 10),
    ExerciseSet(setNumber: 3, weight: 0, reps: 10),
  ];
  
  // Superset
  final List<ExerciseData?> _supersetExercises = [null, null];
  final Map<int, List<ExerciseSet>> _supersetSets = {
    0: [ExerciseSet(setNumber: 1, weight: 0, reps: 10)],
    1: [ExerciseSet(setNumber: 1, weight: 0, reps: 10)],
  };
  int _restBetweenSuperset = 0;
  
  // Dropset
  ExerciseData? _dropsetExercise;
  final List<DropSetStage> _dropsetStages = [
    DropSetStage(weight: 100, reps: 8),
    DropSetStage(weight: 80, reps: 10),
    DropSetStage(weight: 60, reps: 12),
  ];
  
  // Rest-Pause
  ExerciseData? _restPauseExercise;
  double _restPauseWeight = 0;
  final List<RestPauseSet> _restPauseSets = [
    RestPauseSet(reps: 0, restSeconds: 15),
    RestPauseSet(reps: 0, restSeconds: 15),
    RestPauseSet(reps: 0, restSeconds: 15),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Start onboarding after widgets are rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ref.read(exerciseOnboardingProvider.notifier).startOnboarding();
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openExerciseSelection(ExerciseType targetType, {int? supersetIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseSelectionSheet(
        targetType: targetType,
        onConfirm: (exercises) async {
          setState(() {
            switch (targetType) {
              case ExerciseType.single:
                if (exercises.isNotEmpty) {
                  _selectedSingleExercise = exercises.first;
                  // Load previous weights for this exercise
                  _loadPreviousWeights(exercises.first.nome);
                }
                break;
              case ExerciseType.superset:
                if (supersetIndex != null && exercises.isNotEmpty) {
                  _supersetExercises[supersetIndex] = exercises.first;
                } else {
                  // Multi-select for superset
                  for (int i = 0; i < exercises.length && i < _supersetExercises.length; i++) {
                    _supersetExercises[i] = exercises[i];
                  }
                }
                break;
              case ExerciseType.dropset:
                if (exercises.isNotEmpty) {
                  _dropsetExercise = exercises.first;
                }
                break;
              case ExerciseType.restPause:
                if (exercises.isNotEmpty) {
                  _restPauseExercise = exercises.first;
                }
                break;
            }
          });
        },
      ),
    );
  }

  bool _canAddExercise() {
    switch (_tabController.index) {
      case 0: // Single
        return _selectedSingleExercise != null;
      case 1: // Superset
        return _supersetExercises.where((e) => e != null).length >= 2;
      case 2: // Dropset
        return _dropsetExercise != null;
      case 3: // Rest-Pause
        return _restPauseExercise != null;
      default:
        return false;
    }
  }

  void _addExercise() {
    if (!_canAddExercise()) return;
    
    final workoutNotifier = ref.read(currentWorkoutProvider.notifier);
    Exercise? newExercise;
    
    switch (_tabController.index) {
      case 0: // Single
        if (_selectedSingleExercise != null) {
          newExercise = Exercise(
            name: _selectedSingleExercise!.nome,
            type: ExerciseType.single,
            category: _mapCategory(_selectedSingleExercise!.focus),
            sets: List.from(_sets),
          );
        }
        break;
        
      case 1: // Superset
        final validExercises = _supersetExercises
            .where((e) => e != null)
            .cast<ExerciseData>()
            .toList();
        
        if (validExercises.length >= 2) {
          // Create exercises with unique IDs - they'll use shared superset sets
          final exercises = validExercises.map((e) {
            final exerciseId = '${DateTime.now().millisecondsSinceEpoch}_${e.nome}';
            return Exercise(
              id: exerciseId,
              name: e.nome,
              type: ExerciseType.single,
              category: _mapCategory(e.focus),
              sets: [], // No individual sets for superset exercises
            );
          }).toList();
          
          // Create shared superset sets - each set contains data for ALL exercises
          final supersetSets = <SupersetSet>[];

          // ✅ FIX: Genera timestamp UNA VOLTA per evitare ID duplicati
          final baseTimestamp = DateTime.now().millisecondsSinceEpoch;

          // Create 3 default superset sets
          for (int setNumber = 1; setNumber <= 3; setNumber++) {
            final exerciseData = <String, SupersetExerciseData>{};

            // Add data for each exercise in the superset using their IDs
            for (int i = 0; i < exercises.length; i++) {
              final exercise = exercises[i];

              exerciseData[exercise.id] = SupersetExerciseData(
                exerciseId: exercise.id,
                exerciseName: exercise.name,
                targetWeight: 0, // Default weight
                targetReps: 10,  // Default reps
                actualWeight: null,
                actualReps: null,
                rpe: null,
                isCompleted: false,
              );
            }

            // ✅ FIX: Usa index (setNumber-1) per garantire ID univoco
            supersetSets.add(SupersetSet(
              id: 'superset_set_${baseTimestamp}_${setNumber - 1}_$setNumber',
              setNumber: setNumber,
              exerciseData: exerciseData,
              isCompleted: false,
            ));
          }
          
          newExercise = SupersetExercise(
            name: exercises.map((e) => e.name).join(' + '),
            exercises: exercises,
            supersetSets: supersetSets,
            notes: _restBetweenSuperset > 0 ? 'Rest between exercises: ${_restBetweenSuperset}s' : null,
          );
        }
        break;
        
      case 2: // Dropset
        if (_dropsetExercise != null) {
          newExercise = DropSetExercise(
            name: _dropsetExercise!.nome,
            category: _mapCategory(_dropsetExercise!.focus),
            stages: List.from(_dropsetStages),
          );
        }
        break;
        
      case 3: // Rest-Pause
        if (_restPauseExercise != null) {
          newExercise = RestPauseExercise(
            name: _restPauseExercise!.nome,
            category: _mapCategory(_restPauseExercise!.focus),
            weight: _restPauseWeight,
            targetReps: 20,
            restPauseSets: List.from(_restPauseSets),
          );
        }
        break;
    }
    
    if (newExercise != null) {
      workoutNotifier.addExercise(newExercise);
      widget.onExerciseAdded?.call(newExercise);
      Navigator.pop(context);
    }
  }

  ExerciseCategory _mapCategory(String focus) {
    final primary = focus.split(',').first.trim().toUpperCase();
    switch (primary) {
      case 'PETTO':
        return ExerciseCategory.chest;
      case 'DORSO':
      case 'DORSALI':
        return ExerciseCategory.back;
      case 'SPALLE':
        return ExerciseCategory.shoulders;
      case 'BRACCIA':
      case 'BICIPITI':
      case 'TRICIPITI':
        return ExerciseCategory.arms;
      case 'GAMBE':
      case 'QUADRICIPITI':
      case 'FEMORALI':
      case 'GLUTEI':
        return ExerciseCategory.legs;
      case 'ADDOME':
      case 'CORE':
        return ExerciseCategory.abs;
      case 'CARDIO':
        return ExerciseCategory.cardio;
      default:
        return ExerciseCategory.other;
    }
  }

  // Load previous weights for an exercise
  Future<void> _loadPreviousWeights(String exerciseName) async {
    try {
      final workouts = ref.read(workoutHistoryProvider);
      
      // Find the most recent workout with this exercise
      for (final workout in workouts) {
        if (!workout.isCompleted) continue;
        
        final exercise = workout.exercises.firstWhere(
          (e) => e.name == exerciseName,
          orElse: () => Exercise(
            name: '',
            type: ExerciseType.single,
            category: ExerciseCategory.other,
          ),
        );
        
        if (exercise.name.isNotEmpty && exercise.sets.isNotEmpty) {
          // Get completed sets with weights
          final completedSets = exercise.sets.where((s) => s.isCompleted && (s.weight ?? 0) > 0).toList();
          
          if (completedSets.isNotEmpty) {
            setState(() {
              _sets.clear();
              // Create new sets based on previous workout
              for (int i = 0; i < completedSets.length && i < 5; i++) {
                final prevSet = completedSets[i];
                _sets.add(ExerciseSet(
                  setNumber: i + 1,
                  weight: (prevSet.weight ?? 0).toDouble(),
                  reps: prevSet.actualReps ?? prevSet.reps,
                ));
              }
              
              // If we have less than 3 sets, add default ones
              while (_sets.length < 3) {
                final lastWeight = _sets.isNotEmpty ? _sets.last.weight : 0.0;
                final lastReps = _sets.isNotEmpty ? _sets.last.reps : 10;
                _sets.add(ExerciseSet(
                  setNumber: _sets.length + 1,
                  weight: lastWeight,
                  reps: lastReps,
                ));
              }
            });
            
            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).previousWeightsLoaded),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            return; // Found previous workout, exit
          }
        }
      }
    } catch (e) {
      // If error loading previous weights, keep default sets
      debugPrint('Error loading previous weights: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.addExercise,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _canAddExercise() ? _addExercise : null,
                  child: Text(l10n.add),
                ),
              ],
            ),
          ),
          
          // Exercise Type Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: theme.colorScheme.onPrimary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              tabs: [
                Tab(key: _singleExerciseTabKey, text: l10n.single),
                Tab(text: l10n.superset),
                Tab(text: l10n.dropset),
                Tab(text: l10n.restPause),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSingleTab(),
                _buildSupersetTab(),
                _buildDropsetTab(),
                _buildRestPauseTab(),
              ],
            ),
          ),
        ],
      ),
        ),

        // Onboarding overlay (steps 0-1 only visible in this modal)
        // Steps 2-5 will be shown in ExerciseSelectionSheet
        ExerciseOnboardingOverlay(
          singleExerciseTabKey: _singleExerciseTabKey,
          selectExerciseButtonKey: _selectExerciseButtonKey,
          searchBarKey: GlobalKey(), // Dummy - used in ExerciseSelectionSheet
          firstExerciseKey: GlobalKey(), // Dummy - used in ExerciseSelectionSheet
          filtersKey: GlobalKey(), // Dummy - used in ExerciseSelectionSheet
          confirmButtonKey: GlobalKey(), // Dummy - used in ExerciseSelectionSheet
        ),
      ],
    );
  }

  Widget _buildSingleTab() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise selection
          Card(
            key: _selectExerciseButtonKey,
            child: ListTile(
              leading: const SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
),
              title: Text(_selectedSingleExercise?.nome ?? l10n.selectExercise),
              subtitle: _selectedSingleExercise != null
                  ? Text('${_selectedSingleExercise!.focus} • ${_selectedSingleExercise!.attrezzatura}')
                  : Text(l10n.tapToSelectFromDatabase),
              trailing: const SemanticIcon(
  icon: AppIcons.forwardIos,
  semanticLabel: 'Forward ios',
),
              onTap: () => _openExerciseSelection(ExerciseType.single),
            ),
          ),
          
          if (_selectedSingleExercise != null) ...[
            const SizedBox(height: 16),
            Text(
              l10n.sets,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: set.weight.toString(),
                          decoration: InputDecoration(
                            labelText: l10n.weight,
                            suffixText: 'kg',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _sets[index] = set.copyWith(
                              weight: double.tryParse(value) ?? 0,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: set.reps.toString(),
                          decoration: InputDecoration(
                            labelText: l10n.reps,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _sets[index] = set.copyWith(
                              reps: int.tryParse(value) ?? 0,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const SemanticIcon(
  icon: AppIcons.deleteOutline,
  semanticLabel: 'Delete outline',
),
                    onPressed: () {
                      setState(() {
                        _sets.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            }),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _sets.add(ExerciseSet(
                    setNumber: _sets.length + 1,
                    weight: _sets.lastOrNull?.weight ?? 0,
                    reps: _sets.lastOrNull?.reps ?? 10,
                  ));
                });
              },
              icon: const SemanticIcon(
  icon: AppIcons.add,
  semanticLabel: 'Add',
),
              label: Text(l10n.addSet),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSupersetTab() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    AppIcons.info,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.supersetInfo,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Exercise slots
          ..._supersetExercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(exercise?.nome ?? '${l10n.selectExercise} ${index + 1}'),
                  subtitle: exercise != null
                      ? Text('${exercise.focus} • ${exercise.attrezzatura}')
                      : Text(l10n.tapToSelectFromDatabase),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (exercise != null)
                        IconButton(
                          icon: const SemanticIcon(
  icon: AppIcons.clear,
  semanticLabel: 'Clear',
),
                          onPressed: () {
                            setState(() {
                              _supersetExercises[index] = null;
                            });
                          },
                        ),
                      const SemanticIcon(
  icon: AppIcons.forwardIos,
  semanticLabel: 'Forward ios',
),
                    ],
                  ),
                  onTap: () => _openExerciseSelection(
                    ExerciseType.superset,
                    supersetIndex: index,
                  ),
                ),
              ),
            );
          }),
          
          if (_supersetExercises.length < 4)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _supersetExercises.add(null);
                  _supersetSets[_supersetExercises.length - 1] = [
                    ExerciseSet(setNumber: 1, weight: 0, reps: 10),
                  ];
                });
              },
              icon: const SemanticIcon(
  icon: AppIcons.add,
  semanticLabel: 'Add',
),
              label: Text(l10n.addExercise),
            ),
          
          const SizedBox(height: 16),
          
          // Rest between exercises
          ListTile(
            title: Text(l10n.restBetweenExercises),
            subtitle: Text('$_restBetweenSuperset ${l10n.seconds}'),
            trailing: SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: _restBetweenSuperset.toString(),
                decoration: const InputDecoration(
                  suffixText: 's',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _restBetweenSuperset = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropsetTab() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    AppIcons.trendDown,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.dropsetInfo,
                      style: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Exercise selection
          Card(
            child: ListTile(
              leading: const SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
),
              title: Text(_dropsetExercise?.nome ?? l10n.selectExercise),
              subtitle: _dropsetExercise != null
                  ? Text('${_dropsetExercise!.focus} • ${_dropsetExercise!.attrezzatura}')
                  : Text(l10n.tapToSelectFromDatabase),
              trailing: const SemanticIcon(
  icon: AppIcons.forwardIos,
  semanticLabel: 'Forward ios',
),
              onTap: () => _openExerciseSelection(ExerciseType.dropset),
            ),
          ),
          
          if (_dropsetExercise != null) ...[
            const SizedBox(height: 16),
            Text(
              l10n.stages,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._dropsetStages.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              final labels = ['🔴 Heavy', '🟡 Medium', '🟢 Light', '⚪ Extra'];
              
              return Card(
                child: ListTile(
                  leading: Text(
                    labels[index < labels.length ? index : labels.length - 1],
                    style: const TextStyle(fontSize: 20),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: stage.weight.toString(),
                          decoration: InputDecoration(
                            labelText: l10n.weight,
                            suffixText: 'kg',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _dropsetStages[index] = DropSetStage(
                                weight: double.tryParse(value) ?? 0,
                                reps: stage.reps,
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: stage.reps.toString(),
                          decoration: InputDecoration(
                            labelText: l10n.reps,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _dropsetStages[index] = DropSetStage(
                                weight: stage.weight,
                                reps: int.tryParse(value) ?? 0,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  trailing: _dropsetStages.length > 2
                      ? IconButton(
                          icon: const SemanticIcon(
  icon: AppIcons.deleteOutline,
  semanticLabel: 'Delete outline',
),
                          onPressed: () {
                            setState(() {
                              _dropsetStages.removeAt(index);
                            });
                          },
                        )
                      : null,
                ),
              );
            }),
            if (_dropsetStages.length < 5)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    final lastStage = _dropsetStages.last;
                    _dropsetStages.add(DropSetStage(
                      weight: lastStage.weight * 0.8,
                      reps: lastStage.reps + 2,
                    ));
                  });
                },
                icon: const SemanticIcon(
  icon: AppIcons.add,
  semanticLabel: 'Add',
),
                label: Text(l10n.addStage),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildRestPauseTab() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Card(
            color: theme.colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    AppIcons.pauseCircle,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.restPauseInfo,
                      style: TextStyle(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Exercise selection
          Card(
            child: ListTile(
              leading: const SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
),
              title: Text(_restPauseExercise?.nome ?? l10n.selectExercise),
              subtitle: _restPauseExercise != null
                  ? Text('${_restPauseExercise!.focus} • ${_restPauseExercise!.attrezzatura}')
                  : Text(l10n.tapToSelectFromDatabase),
              trailing: const SemanticIcon(
  icon: AppIcons.forwardIos,
  semanticLabel: 'Forward ios',
),
              onTap: () => _openExerciseSelection(ExerciseType.restPause),
            ),
          ),
          
          if (_restPauseExercise != null) ...[
            const SizedBox(height: 16),
            
            // Weight
            ListTile(
              title: Text(l10n.weight),
              trailing: SizedBox(
                width: 100,
                child: TextFormField(
                  initialValue: _restPauseWeight.toString(),
                  decoration: const InputDecoration(
                    suffixText: 'kg',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _restPauseWeight = double.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Text(
              l10n.miniSets,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._restPauseSets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text('Mini-set ${index + 1}'),
                  subtitle: Text('${l10n.restTime}: ${set.restSeconds}s'),
                  trailing: index < _restPauseSets.length - 1
                      ? SizedBox(
                          width: 80,
                          child: TextFormField(
                            initialValue: set.restSeconds.toString(),
                            decoration: const InputDecoration(
                              suffixText: 's',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _restPauseSets[index] = RestPauseSet(
                                  reps: set.reps,
                                  restSeconds: int.tryParse(value) ?? 15,
                                );
                              });
                            },
                          ),
                        )
                      : null,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
