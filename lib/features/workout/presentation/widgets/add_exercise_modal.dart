import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';
import '../providers/workout_provider.dart';
import '../providers/add_exercise_provider.dart';
import '../../../exercise_database/presentation/exercise_search_screen.dart';
import '../../../exercise_database/domain/entities/exercise_template.dart';

class AddExerciseModal extends ConsumerStatefulWidget {
  final Function(Exercise)? onExerciseAdded;
  
  const AddExerciseModal({
    super.key,
    this.onExerciseAdded,
  });

  @override
  ConsumerState<AddExerciseModal> createState() => _AddExerciseModalState();
}

class _AddExerciseModalState extends ConsumerState<AddExerciseModal> with TickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
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
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Exercise',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _canAddExercise() ? _addExercise : null,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          
          // Exercise Type Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Theme.of(context).colorScheme.onPrimary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              tabs: const [
                Tab(text: 'Single'),
                Tab(text: 'Superset'),
                Tab(text: 'DropSet'),
                Tab(text: 'Rest-Pause'),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSingleExerciseTab(),
                _buildSupersetTab(),
                _buildDropSetTab(),
                _buildRestPauseTab(),
              ],
            ),
          ),
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
          // Exercise search and selection
          _buildExerciseSearchSection(),
          const SizedBox(height: 20),
          
          // Exercise name
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Exercise Name',
              hintText: 'e.g., Panca Piana',
              prefixIcon: Icon(Icons.fitness_center),
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
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Add any notes about form, weight progression, etc.',
              prefixIcon: Icon(Icons.note),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupersetTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Superset combines 2+ exercises performed back-to-back with minimal rest.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Superset name
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Superset Name',
              hintText: 'e.g., Chest & Triceps Superset',
              prefixIcon: Icon(Icons.repeat),
            ),
          ),
          const SizedBox(height: 16),
          
          // Exercise 1
          _buildSupersetExerciseCard('Exercise 1', 0),
          const SizedBox(height: 12),
          
          // Exercise 2
          _buildSupersetExerciseCard('Exercise 2', 1),
          const SizedBox(height: 16),
          
          // Add more exercises button
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Add more exercises to superset
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
          ),
          const SizedBox(height: 16),
          
          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Rest time between exercises, form cues, etc.',
              prefixIcon: Icon(Icons.note),
            ),
          ),
        ],
      ),
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
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Drop Set: Perform exercise to failure, then immediately reduce weight and continue.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Exercise name
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Exercise Name',
              hintText: 'e.g., Bicep Curl Drop Set',
              prefixIcon: Icon(Icons.trending_down),
            ),
          ),
          const SizedBox(height: 16),
          
          // Category selection
          _buildCategorySelector(),
          const SizedBox(height: 20),
          
          // Drop Set Stages
          Text(
            'Drop Set Stages',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildDropSetStage('Stage 1 (Heavy)', 0),
          const SizedBox(height: 8),
          _buildDropSetStage('Stage 2 (Medium)', 1),  
          const SizedBox(height: 8),
          _buildDropSetStage('Stage 3 (Light)', 2),
          const SizedBox(height: 16),
          
          // Add stage button
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Add more drop set stages
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Stage'),
          ),
          const SizedBox(height: 16),
          
          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Weight drops, rest between stages, etc.',
              prefixIcon: Icon(Icons.note),
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
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rest-Pause: Perform to failure, rest 10-15 seconds, repeat until target reps.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Exercise name
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Exercise Name',
              hintText: 'e.g., Bench Press Rest-Pause',
              prefixIcon: Icon(Icons.pause_circle),
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
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Target Reps',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Rest periods
          Text(
            'Rest-Pause Configuration',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          TextField(
            decoration: const InputDecoration(
              labelText: 'Rest Period (seconds)',
              hintText: '10-15 seconds typical',
              prefixIcon: Icon(Icons.timer),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          TextField(
            decoration: const InputDecoration(
              labelText: 'Max Rest-Pause Sets',
              hintText: '3-4 typical',
              prefixIcon: Icon(Icons.repeat),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Form cues, progression strategy, etc.',
              prefixIcon: Icon(Icons.note),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Browse exercises from database button
        Card(
          child: ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Browse Exercise Database'),
            subtitle: const Text('Choose from our exercise library'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              print('🔍 ADD_EXERCISE_MODAL: Opening ExerciseSearchScreen with callback: ${widget.onExerciseAdded != null}');
              Navigator.of(context).pop(); // Close current modal
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ExerciseSearchScreen(
                    onExerciseAdded: widget.onExerciseAdded, // 🔥 FIX: Pass callback
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        
        // Manual entry section
        Text(
          'Create Custom Exercise',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _onExerciseTemplateSelected(ExerciseTemplate template) {
    // Convert template to exercise and add to workout
    final exercise = template.toExercise().copyWith(
      sets: [
        ExerciseSet(setNumber: 1, weight: 0, reps: 10),
        ExerciseSet(setNumber: 2, weight: 0, reps: 10),
        ExerciseSet(setNumber: 3, weight: 0, reps: 10),
      ],
    );

    // Se c'è un callback, lo usa invece di aggiungere al workout corrente  
    if (widget.onExerciseAdded != null) {
      widget.onExerciseAdded!(exercise);
      Navigator.pop(context);
      return;
    }
    
    ref.read(currentWorkoutProvider.notifier).addExercise(exercise);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${exercise.name} to workout'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  Widget _buildCategorySelector() {
    final selectedCategory = ref.watch(selectedExerciseCategoryProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise Category',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
              'Sets',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                ref.read(exerciseSetsProvider.notifier).addSet();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Set'),
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
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${set.setNumber}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            initialValue: set.weight?.toString() ?? '0',
            decoration: const InputDecoration(
              hintText: 'Weight (kg)',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(),
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
            decoration: const InputDecoration(
              hintText: 'Reps',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(),
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
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            tooltip: 'Remove Set',
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                hintText: 'e.g., Push-ups',
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
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
                    decoration: const InputDecoration(
                      labelText: 'Reps',
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  labelText: 'Reps',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            if (index > 2)
              IconButton(
                onPressed: () {
                  // TODO: Remove stage
                },
                icon: const Icon(Icons.remove_circle_outline, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return 'Chest';
      case ExerciseCategory.back:
        return 'Back';
      case ExerciseCategory.shoulders:
        return 'Shoulders';
      case ExerciseCategory.arms:
        return 'Arms';
      case ExerciseCategory.legs:
        return 'Legs';
      case ExerciseCategory.abs:
        return 'Abs';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.other:
        return 'Other';
    }
  }

  bool _canAddExercise() {
    return _nameController.text.trim().isNotEmpty;
  }

  void _addExercise() {
    if (!_canAddExercise()) return;

    final selectedCategory = ref.read(selectedExerciseCategoryProvider);
    final exerciseType = ExerciseType.values[_tabController.index];
    final sets = ref.read(exerciseSetsProvider);
    
    final exercise = Exercise(
      name: _nameController.text.trim(),
      type: exerciseType,
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${exercise.name} to workout'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}