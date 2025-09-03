import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_database.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_similarity_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/exercise_database_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'dart:math' as math;

/// Tier-1 Exercise Replacement Dialog with intelligent suggestions
class ExerciseReplacementDialog extends ConsumerStatefulWidget {
  final Exercise currentExercise;
  final Function(ExerciseDatabase) onReplace;

  const ExerciseReplacementDialog({
    super.key,
    required this.currentExercise,
    required this.onReplace,
  });

  @override
  ConsumerState<ExerciseReplacementDialog> createState() => _ExerciseReplacementDialogState();
}

class _ExerciseReplacementDialogState extends ConsumerState<ExerciseReplacementDialog>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedEquipment;
  bool _showOnlyFavorites = false;
  
  // Filter mode: 'smart' or 'all'
  String _filterMode = 'smart';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ExerciseRecommendation> _getSmartRecommendations(List<ExerciseDatabase> allExercises) {
    // Find current exercise in database
    final currentDbExercise = allExercises.firstWhere(
      (e) => e.id == widget.currentExercise.id,
      orElse: () => allExercises.first,
    );

    // Get smart recommendations
    return ExerciseSimilarityService.getRecommendations(
      targetExercise: currentDbExercise,
      availableExercises: allExercises,
      maxRecommendations: 20,
      minSimilarityThreshold: 0.2,
    );
  }

  List<ExerciseDatabase> _filterExercises(List<ExerciseDatabase> exercises) {
    var filtered = exercises.where((exercise) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!exercise.name.toLowerCase().contains(query) &&
            !(exercise.primaryMuscleGroups?.any((m) => m.toLowerCase().contains(query)) ?? false)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && exercise.category != _selectedCategory) {
        return false;
      }

      // Equipment filter
      if (_selectedEquipment != null && exercise.equipment != _selectedEquipment) {
        return false;
      }

      // Favorites filter
      if (_showOnlyFavorites && !(exercise.isFavorite ?? false)) {
        return false;
      }

      return true;
    }).toList();

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final exercisesAsync = ref.watch(exerciseDatabaseProvider);

    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.replaceExercise,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.currentExercise.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            tabs: [
              Tab(
                icon: const Icon(Icons.auto_awesome),
                text: l10n.smartSuggestions,
              ),
              Tab(
                icon: const Icon(Icons.list),
                text: l10n.allExercises,
              ),
            ],
          ),
        ),
        body: exercisesAsync.when(
          data: (exercises) => FadeTransition(
            opacity: _fadeAnimation,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Smart suggestions tab
                _buildSmartSuggestionsTab(exercises, theme, l10n),
                // All exercises tab
                _buildAllExercisesTab(exercises, theme, l10n),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(l10n.errorLoadingExercises),
          ),
        ),
      ),
    );
  }

  Widget _buildSmartSuggestionsTab(
    List<ExerciseDatabase> exercises,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final recommendations = _getSmartRecommendations(exercises);
    
    if (recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noSimilarExercisesFound,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Smart filters chip
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(
                  label: l10n.sameMuscleGroup,
                  icon: Icons.fitness_center,
                  isSelected: true,
                  theme: theme,
                ),
                _buildFilterChip(
                  label: l10n.sameEquipment,
                  icon: Icons.sports_gymnastics,
                  isSelected: false,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
        // Recommendations list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final recommendation = recommendations[index];
                return _buildRecommendationCard(
                  recommendation,
                  theme,
                  l10n,
                );
              },
              childCount: recommendations.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllExercisesTab(
    List<ExerciseDatabase> exercises,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final filteredExercises = _filterExercises(exercises);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: l10n.searchExercises,
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
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
          ),
        ),
        // Filter chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip(
                label: l10n.favorites,
                icon: Icons.star,
                isSelected: _showOnlyFavorites,
                onTap: () => setState(() => _showOnlyFavorites = !_showOnlyFavorites),
                theme: theme,
              ),
              const SizedBox(width: 8),
              _buildDropdownChip(
                label: _selectedCategory ?? l10n.allCategories,
                icon: Icons.category,
                theme: theme,
                onTap: () => _showCategoryFilter(theme, l10n),
              ),
              const SizedBox(width: 8),
              _buildDropdownChip(
                label: _selectedEquipment ?? l10n.allEquipment,
                icon: Icons.fitness_center,
                theme: theme,
                onTap: () => _showEquipmentFilter(theme, l10n),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Exercise list
        Expanded(
          child: filteredExercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noExercisesFound,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    return _buildExerciseCard(exercise, theme, l10n);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    ExerciseRecommendation recommendation,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final similarity = recommendation.similarityPercentage;
    final color = _getSimilarityColor(similarity);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _confirmReplacement(recommendation.exercise, theme, l10n),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Similarity indicator
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.1),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$similarity%',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        l10n.match,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Exercise info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.exercise.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (recommendation.primaryReason.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          recommendation.primaryReason,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (recommendation.exercise.equipment != null) ...[
                          Icon(
                            Icons.fitness_center,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recommendation.exercise.equipment!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (recommendation.exercise.category != null) ...[
                          Icon(
                            Icons.category,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recommendation.exercise.category!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    ExerciseDatabase exercise,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => _confirmReplacement(exercise, theme, l10n),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          child: Icon(
            _getCategoryIcon(exercise.category),
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          exercise.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            if (exercise.equipment != null) ...[
              Icon(
                Icons.fitness_center,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                exercise.equipment!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (exercise.primaryMuscleGroups?.isNotEmpty ?? false) ...[
              Icon(
                Icons.sports_gymnastics,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  exercise.primaryMuscleGroups!.join(', '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.swap_horiz,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required ThemeData theme,
    VoidCallback? onTap,
  }) {
    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownChip({
    required String label,
    required IconData icon,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSimilarityColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    if (percentage >= 40) return Colors.amber;
    return Colors.grey;
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'chest':
        return Icons.fitness_center;
      case 'back':
        return Icons.sports_gymnastics;
      case 'legs':
        return Icons.directions_run;
      case 'shoulders':
        return Icons.accessibility_new;
      case 'arms':
        return Icons.sports_handball;
      case 'core':
        return Icons.self_improvement;
      default:
        return Icons.fitness_center;
    }
  }

  void _showCategoryFilter(ThemeData theme, AppLocalizations l10n) {
    // Implementation for category filter modal
  }

  void _showEquipmentFilter(ThemeData theme, AppLocalizations l10n) {
    // Implementation for equipment filter modal
  }

  void _confirmReplacement(
    ExerciseDatabase newExercise,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.confirmReplacement),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyLarge,
                children: [
                  TextSpan(text: l10n.replaceExerciseConfirmation),
                  const TextSpan(text: '\n\n'),
                  TextSpan(
                    text: widget.currentExercise.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const TextSpan(text: '\n↓\n'),
                  TextSpan(
                    text: newExercise.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.warningContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.warning.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.replacementKeepsSetsAndReps,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              widget.onReplace(newExercise);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              
              // Show success snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.exerciseReplaced),
                  backgroundColor: theme.colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text(l10n.replace),
          ),
        ],
      ),
    );
  }
}