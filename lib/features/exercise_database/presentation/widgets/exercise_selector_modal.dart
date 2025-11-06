import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/exercise_search_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ExerciseSelectorModal extends ConsumerStatefulWidget {

  const ExerciseSelectorModal({
    super.key,
    required this.onExerciseSelected,
  });
  final Function(ExerciseTemplate) onExerciseSelected;

  @override
  ConsumerState<ExerciseSelectorModal> createState() => _ExerciseSelectorModalState();
}

class _ExerciseSelectorModalState extends ConsumerState<ExerciseSelectorModal>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          _buildSearchBar(context),
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchTab(context),
                _buildCategoriesTab(context),
                _buildPopularTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(AppIcons.workout),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add Exercise',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(AppIcons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          ref.read(exerciseSearchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          prefixIcon: const Icon(AppIcons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    ref.read(exerciseSearchQueryProvider.notifier).state = '';
                  },
                  icon: Icon(AppIcons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Search', icon: Icon(AppIcons.search, size: 20)),
          Tab(text: 'Categories', icon: Icon(AppIcons.category, size: 20)),
          Tab(text: 'Popular', icon: Icon(AppIcons.star, size: 20)),
        ],
      ),
    );
  }

  Widget _buildSearchTab(BuildContext context) {
    final searchResults = ref.watch(exerciseSearchResultsProvider);
    
    return searchResults.when(
      data: (exercises) {
        if (exercises.isEmpty) {
          return _buildEmptyState(context, 'No exercises found');
        }
        
        return _buildExerciseList(context, exercises);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildCategoriesTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: ExerciseCategory.values.map((category) {
        return _buildCategoryCard(context, category);
      }).toList(),
    );
  }

  Widget _buildPopularTab(BuildContext context) {
    final popularExercises = ref.watch(popularExercisesProvider);
    
    return popularExercises.when(
      data: (exercises) {
        if (exercises.isEmpty) {
          return _buildEmptyState(context, 'No popular exercises available');
        }
        
        return _buildExerciseList(context, exercises);
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ExerciseCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _getCategoryIcon(category),
        title: Text(
          category.name.toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(_getCategoryDescription(category)),
        trailing: const Icon(AppIcons.forwardIos, size: 16),
        onTap: () {
          ref.read(exerciseCategoryFilterProvider.notifier).state = category;
          _tabController.animateTo(0); // Switch to search tab
        },
      ),
    );
  }

  Widget _buildExerciseList(BuildContext context, List<ExerciseTemplate> exercises) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return _buildExerciseCard(context, exercise);
      },
    );
  }

  Widget _buildExerciseCard(BuildContext context, ExerciseTemplate exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getCategoryColor(exercise.category).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getCategoryIcon(exercise.category).icon,
            color: _getCategoryColor(exercise.category),
            size: 20,
          ),
        ),
        title: Text(
          exercise.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: exercise.muscleGroups.take(3).map((muscle) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    muscle,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          widget.onExerciseSelected(exercise);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.searchOff,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.error,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 16),
          Text(
            'Error loading exercises',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Icon _getCategoryIcon(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return const Icon(AppIcons.workout);
      case ExerciseCategory.cardio:
        return const Icon(AppIcons.cardio);
      case ExerciseCategory.back:
        return const Icon(AppIcons.workout);
      case ExerciseCategory.shoulders:
        return const Icon(AppIcons.workout);
      case ExerciseCategory.arms:
        return Icon(AppIcons.workout);
      case ExerciseCategory.legs:
        return Icon(AppIcons.workout);
      case ExerciseCategory.abs:
        return Icon(AppIcons.workout);
      case ExerciseCategory.other:
        return Icon(AppIcons.workout);
    }
  }

  Color _getCategoryColor(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return Theme.of(context).colorScheme.primary;
      case ExerciseCategory.cardio:
        return Theme.of(context).colorScheme.secondary;
      case ExerciseCategory.back:
        return Theme.of(context).colorScheme.tertiary;
      case ExerciseCategory.shoulders:
        return Theme.of(context).colorScheme.primary;
      case ExerciseCategory.arms:
        return Theme.of(context).colorScheme.secondary;
      case ExerciseCategory.legs:
        return Theme.of(context).colorScheme.tertiary;
      case ExerciseCategory.abs:
        return Theme.of(context).colorScheme.primary;
      case ExerciseCategory.other:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  String _getCategoryDescription(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return 'Chest and pectoral exercises';
      case ExerciseCategory.cardio:
        return 'Cardiovascular and endurance training';
      case ExerciseCategory.back:
        return 'Back and latissimus exercises';
      case ExerciseCategory.shoulders:
        return 'Shoulder and deltoid exercises';
      case ExerciseCategory.arms:
        return 'Arm, bicep, and tricep exercises';
      case ExerciseCategory.legs:
        return 'Leg and lower body exercises';
      case ExerciseCategory.abs:
        return 'Abdominal and core exercises';
      case ExerciseCategory.other:
        return 'General and miscellaneous exercises';
    }
  }
}

// Extension method to show the modal
extension ExerciseSelectorModalExtension on BuildContext {
  Future<void> showExerciseSelectorModal(Function(ExerciseTemplate) onExerciseSelected) {
    return showModalBottomSheet<void>(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseSelectorModal(
        onExerciseSelected: onExerciseSelected,
      ),
    );
  }
}
