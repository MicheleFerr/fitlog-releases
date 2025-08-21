import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/entities/exercise.dart';
import '../data/repositories/json_exercise_repository.dart';
import '../../workout/domain/entities/exercise.dart' as WorkoutExercise;
import '../../workout/presentation/providers/workout_provider.dart';
import 'widgets/exercise_customization_screen.dart';

class ExerciseSearchScreen extends ConsumerStatefulWidget {
  final Function(WorkoutExercise.Exercise)? onExerciseAdded; // 🔥 FIX: Add callback parameter
  
  const ExerciseSearchScreen({
    super.key,
    this.onExerciseAdded,
  });

  @override
  ConsumerState<ExerciseSearchScreen> createState() => _ExerciseSearchScreenState();
}

class _ExerciseSearchScreenState extends ConsumerState<ExerciseSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<Exercise> _selectedExercises = <Exercise>{};
  
  String _searchQuery = '';
  List<String> _selectedFocus = [];
  List<String> _selectedEquipment = [];
  List<String> _selectedDifficulty = [];
  String? _selectedType;
  
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(jsonExerciseRepositoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Cerca Esercizi (${_selectedExercises.length})'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          if (_selectedExercises.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addSelectedToWorkout,
              tooltip: 'Aggiungi alla Scheda',
            ),
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: 'Filtri',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca esercizi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          
          // Filters Section
          if (_showFilters) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Filtri',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Quick Filters Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickFilter('Tutti', _clearAllFilters, 
                          isActive: _isAllFiltersEmpty()),
                        const SizedBox(width: 8),
                        _buildQuickFilter('Upper Body', () => _applyQuickFilter(['PETTO', 'SPALLE', 'BICIPITI', 'TRICIPITI', 'DORSO']), 
                          isActive: false),
                        const SizedBox(width: 8),
                        _buildQuickFilter('Lower Body', () => _applyQuickFilter(['QUAD', 'GLUT', 'FEMOR', 'POLP']), 
                          isActive: false),
                        const SizedBox(width: 8),
                        _buildQuickFilter('Core', () => _applyQuickFilter(['CORE', 'ADDOME']), 
                          isActive: false),
                        const SizedBox(width: 8),
                        _buildQuickFilter('Corpo Libero', () => _applyEquipmentFilter(['Corpo Libero']), 
                          isActive: _selectedEquipment.contains('Corpo Libero')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  exercisesAsync.when(
                    data: (exercises) => _buildAdvancedFilters(exercises),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  
                  const SizedBox(height: 8),
                  const Divider(),
                ],
              ),
            ),
          ],
          
          // Results
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                final filteredExercises = _filterExercises(exercises);
                
                if (filteredExercises.isEmpty) {
                  return _buildEmptyState();
                }
                
                return Column(
                  children: [
                    // Results count
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                      child: Text(
                        '${filteredExercises.length} esercizi trovati',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    
                    // Exercise List
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = filteredExercises[index];
                          final isSelected = _selectedExercises.contains(exercise);
                          
                          return _buildExerciseCard(exercise, isSelected);
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Errore nel caricamento: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(jsonExerciseRepositoryProvider),
                      child: const Text('Riprova'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      
      // Selected Exercises Count
      bottomNavigationBar: _selectedExercises.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedExercises.length} esercizi selezionati',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _addSelectedToWorkout,
                      icon: const Icon(Icons.add),
                      label: const Text('Aggiungi'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildQuickFilter(String label, VoidCallback onTap, {required bool isActive}) {
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => onTap(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildAdvancedFilters(List<Exercise> exercises) {
    // Extract unique values for filters
    final focusOptions = exercises
        .expand((e) => e.focus)
        .toSet()
        .toList()..sort();
    
    final equipmentOptions = exercises
        .map((e) => e.attrezzatura)
        .toSet()
        .toList()..sort();
        
    final difficultyOptions = exercises
        .map((e) => e.difficolta)
        .toSet()
        .toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Difficulty Filter
        Text('Difficoltà:', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: difficultyOptions.map((difficulty) {
            final isSelected = _selectedDifficulty.contains(difficulty);
            return FilterChip(
              label: Text(difficulty),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDifficulty.add(difficulty);
                  } else {
                    _selectedDifficulty.remove(difficulty);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        
        // Equipment Filter
        Text('Attrezzatura:', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: equipmentOptions.map((equipment) {
            final isSelected = _selectedEquipment.contains(equipment);
            return FilterChip(
              label: Text(equipment),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedEquipment.add(equipment);
                  } else {
                    _selectedEquipment.remove(equipment);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(Exercise exercise, bool isSelected) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white)
              : Text(exercise.attrezzaturaIcon),
        ),
        title: Text(
          exercise.nome,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.focusDisplayName),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(exercise.difficolta).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    exercise.difficolta,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getDifficultyColor(exercise.difficolta),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  exercise.attrezzatura,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
            : const Icon(Icons.radio_button_unchecked),
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedExercises.remove(exercise);
            } else {
              _selectedExercises.add(exercise);
            }
          });
        },
        onLongPress: () => _showExerciseDetails(exercise),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nessun esercizio trovato',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Prova a modificare i filtri di ricerca',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Rimuovi tutti i filtri'),
          ),
        ],
      ),
    );
  }

  List<Exercise> _filterExercises(List<Exercise> exercises) {
    return exercises.where((exercise) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!exercise.nome.toLowerCase().contains(query) &&
            !exercise.focusDisplayName.toLowerCase().contains(query) &&
            !exercise.attrezzatura.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Focus filter
      if (_selectedFocus.isNotEmpty) {
        if (!exercise.focus.any((focus) => _selectedFocus.contains(focus))) {
          return false;
        }
      }

      // Equipment filter
      if (_selectedEquipment.isNotEmpty) {
        if (!_selectedEquipment.contains(exercise.attrezzatura)) {
          return false;
        }
      }

      // Difficulty filter
      if (_selectedDifficulty.isNotEmpty) {
        if (!_selectedDifficulty.contains(exercise.difficolta)) {
          return false;
        }
      }

      // Type filter
      if (_selectedType != null) {
        if (exercise.tipoEsercizio != _selectedType) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'principiante':
        return Colors.green;
      case 'intermedio':
        return Colors.orange;
      case 'avanzato':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFocus.clear();
      _selectedEquipment.clear();
      _selectedDifficulty.clear();
      _selectedType = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  bool _isAllFiltersEmpty() {
    return _selectedFocus.isEmpty &&
        _selectedEquipment.isEmpty &&
        _selectedDifficulty.isEmpty &&
        _selectedType == null &&
        _searchQuery.isEmpty;
  }

  void _applyQuickFilter(List<String> focusGroups) {
    setState(() {
      _selectedFocus = focusGroups;
      _selectedEquipment.clear();
      _selectedDifficulty.clear();
    });
  }

  void _applyEquipmentFilter(List<String> equipment) {
    setState(() {
      _selectedEquipment = equipment;
      _selectedFocus.clear();
      _selectedDifficulty.clear();
    });
  }

  void _addSelectedToWorkout() {
    if (_selectedExercises.isEmpty) return;
    
    print('🔍 EXERCISE_SEARCH: Selected ${_selectedExercises.length} exercises, callback: ${widget.onExerciseAdded != null}');
    
    // Navigate to customization screen and pass callback
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseCustomizationScreen(
          selectedExercises: _selectedExercises.toList(),
          onExerciseAdded: widget.onExerciseAdded, // 🔥 FIX: Pass callback
        ),
      ),
    );
  }

  WorkoutExercise.Exercise _convertToWorkoutExercise(Exercise exercise) {
    // Map focus to category
    final category = _mapFocusToCategory(exercise.focus);
    
    return WorkoutExercise.Exercise(
      name: exercise.nome,
      type: WorkoutExercise.ExerciseType.single,
      category: category,
      notes: exercise.noteTecniche,
      sets: [
        WorkoutExercise.ExerciseSet(setNumber: 1, weight: 0, reps: 10),
        WorkoutExercise.ExerciseSet(setNumber: 2, weight: 0, reps: 10),
        WorkoutExercise.ExerciseSet(setNumber: 3, weight: 0, reps: 10),
      ],
    );
  }

  WorkoutExercise.ExerciseCategory _mapFocusToCategory(List<String> focus) {
    // Map our exercise focus to workout categories
    if (focus.any((f) => ['PETTO', 'CHEST'].contains(f.toUpperCase()))) {
      return WorkoutExercise.ExerciseCategory.chest;
    }
    if (focus.any((f) => ['DORSO', 'BACK', 'LAT'].contains(f.toUpperCase()))) {
      return WorkoutExercise.ExerciseCategory.back;
    }
    if (focus.any((f) => ['SPALLE', 'DELT', 'SHOULDERS'].contains(f.toUpperCase()))) {
      return WorkoutExercise.ExerciseCategory.shoulders;
    }
    if (focus.any((f) => ['BICIPITI', 'TRICIPITI', 'ARMS', 'BRACCI'].contains(f.toUpperCase()))) {
      return WorkoutExercise.ExerciseCategory.arms;
    }
    if (focus.any((f) => ['QUAD', 'GLUT', 'FEMOR', 'POLP', 'LEGS'].contains(f.toUpperCase()))) {
      return WorkoutExercise.ExerciseCategory.legs;
    }
    if (focus.any((f) => ['CORE', 'ADDOME', 'ABS'].contains(f.toUpperCase()))) {
      return WorkoutExercise.ExerciseCategory.abs;
    }
    
    return WorkoutExercise.ExerciseCategory.other;
  }

  void _showExerciseDetails(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  exercise.nome,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Focus: ${exercise.focusDisplayName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                
                if (exercise.noteTecniche != null) ...[
                  Text('Note Tecniche:', style: Theme.of(context).textTheme.titleSmall),
                  Text(exercise.noteTecniche!),
                  const SizedBox(height: 12),
                ],
                
                if (exercise.mobilitaPre != null) ...[
                  Text('Mobilità Pre-Workout:', style: Theme.of(context).textTheme.titleSmall),
                  Text(exercise.mobilitaPre!),
                  const SizedBox(height: 12),
                ],
                
                if (exercise.attivazionePre != null) ...[
                  Text('Attivazione Pre-Workout:', style: Theme.of(context).textTheme.titleSmall),
                  Text(exercise.attivazionePre!),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}