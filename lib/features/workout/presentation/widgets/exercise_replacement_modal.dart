import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/exercise_compatibility_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/exercise_json_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ExerciseReplacementModal extends ConsumerStatefulWidget {
  
  const ExerciseReplacementModal({
    super.key,
    required this.currentExercise,
    required this.onReplace,
  });
  final Exercise currentExercise;
  final Function(Exercise) onReplace;
  
  static Future<void> show(
    BuildContext context,
    Exercise currentExercise,
    Function(Exercise) onReplace,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseReplacementModal(
        currentExercise: currentExercise,
        onReplace: onReplace,
      ),
    );
  }
  
  @override
  ConsumerState<ExerciseReplacementModal> createState() => _ExerciseReplacementModalState();
}

class _ExerciseReplacementModalState extends ConsumerState<ExerciseReplacementModal> {
  String _searchQuery = '';
  ExerciseCategory? _filterCategory;
  bool _showOnlyCompatible = false; // Mostra tutti di default
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final exercisesAsync = ref.watch(exerciseJsonProvider);
    
    // Get exercises from provider
    final allExercises = exercisesAsync.maybeWhen(
      data: (exercises) => exercises,
      orElse: () => <Exercise>[],
    );
    
    // Get suggestions or all exercises based on toggle
    List<ExerciseSuggestion> displayList;
    
    if (_showOnlyCompatible) {
      // Show smart suggestions only
      displayList = ExerciseCompatibilityService.getSuggestedReplacements(
        widget.currentExercise,
        allExercises,
      );
    } else {
      // Show all exercises with compatibility scores
      displayList = allExercises.map((exercise) {
        // Special handling for same exercise
        if (exercise.name == widget.currentExercise.name) {
          return ExerciseSuggestion(
            exercise: exercise,
            compatibilityScore: 100, // Show current exercise at top
            reason: _getCompatibilityReason(100, exercise),
          );
        }
        
        final compatibility = ExerciseCompatibilityService.calculateCompatibility(
          widget.currentExercise,
          exercise,
        );
        return ExerciseSuggestion(
          exercise: exercise,
          compatibilityScore: compatibility,
          reason: _getCompatibilityReason(compatibility, exercise),
        );
      }).toList()
        ..sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));
    }
    
    // Filter based on search and category
    final filteredSuggestions = displayList.where((s) {
      if (_searchQuery.isNotEmpty && 
          !s.exercise.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_filterCategory != null && s.exercise.category != _filterCategory) {
        return false;
      }
      return true;
    }).toList();
    
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.swapHorizRounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.replaceExercise,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.currentExercise.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(AppIcons.close),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Info card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.info,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.replacementKeepsSetsAndReps,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Search bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: l10n.searchExercises,
                    prefixIcon: const Icon(AppIcons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () => setState(() => _searchQuery = ''),
                            icon: const Icon(AppIcons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Compatibility toggle
                      FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.autoAwesome,
                              size: 16,
                              color: _showOnlyCompatible 
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                            const SizedBox(width: 4),
                            Text(l10n.smartSuggestions),
                          ],
                        ),
                        selected: _showOnlyCompatible,
                        onSelected: (value) => setState(() => _showOnlyCompatible = value),
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        selectedColor: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      
                      // Category filters
                      for (final category in ExerciseCategory.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(_getCategoryName(category)),
                            selected: _filterCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _filterCategory = selected ? category : null;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Exercise list
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.error,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorLoadingExercises,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              data: (_) => filteredSuggestions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          AppIcons.searchOff,
                          size: 64,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noExercisesFound,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = filteredSuggestions[index];
                      return _buildExerciseTile(context, suggestion);
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExerciseTile(BuildContext context, ExerciseSuggestion suggestion) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    // Calculate color based on compatibility
    Color compatibilityColor;
    IconData compatibilityIcon;
    
    if (suggestion.compatibilityScore >= 80) {
      compatibilityColor = Colors.green;
      compatibilityIcon = AppIcons.star;
    } else if (suggestion.compatibilityScore >= 60) {
      compatibilityColor = Colors.orange;
      compatibilityIcon = AppIcons.starHalfIcon;
    } else if (suggestion.compatibilityScore >= 40) {
      compatibilityColor = Colors.amber;
      compatibilityIcon = AppIcons.starOutlineIcon;
    } else {
      compatibilityColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);
      compatibilityIcon = AppIcons.starOutline;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _confirmReplacement(context, suggestion.exercise),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(suggestion.exercise.category).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(suggestion.exercise.category),
                    color: _getCategoryColor(suggestion.exercise.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Exercise info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.exercise.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion.reason,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Compatibility score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: compatibilityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: compatibilityColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        compatibilityIcon,
                        size: 16,
                        color: compatibilityColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${suggestion.compatibilityScore.toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: compatibilityColor,
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
  
  void _confirmReplacement(BuildContext context, Exercise newExercise) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmReplacement),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.replaceExerciseConfirmation(
                widget.currentExercise.name,
                newExercise.name,
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.info,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.replacementKeepsSetsAndReps,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
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
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close modal
              widget.onReplace(newExercise);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        AppIcons.complete,
                        color: theme.colorScheme.onTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.exerciseReplaced),
                    ],
                  ),
                  backgroundColor: theme.colorScheme.tertiary,
                ),
              );
            },
            child: Text(l10n.replace),
          ),
        ],
      ),
    );
  }
  
  String _getCategoryName(ExerciseCategory category) {
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
  
  IconData _getCategoryIcon(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return AppIcons.workout;
      case ExerciseCategory.back:
        return AppIcons.rowing;
      case ExerciseCategory.shoulders:
        return AppIcons.accessibility;
      case ExerciseCategory.arms:
        return AppIcons.gymnastics;
      case ExerciseCategory.legs:
        return AppIcons.cardio;
      case ExerciseCategory.abs:
        return AppIcons.flexibility;
      case ExerciseCategory.cardio:
        return AppIcons.favorite;
      case ExerciseCategory.other:
        return AppIcons.sports;
    }
  }
  
  Color _getCategoryColor(ExerciseCategory category) {
    final colors = Theme.of(context).colorScheme;
    switch (category) {
      case ExerciseCategory.chest:
        return colors.primary;
      case ExerciseCategory.back:
        return colors.secondary;
      case ExerciseCategory.shoulders:
        return colors.tertiary;
      case ExerciseCategory.arms:
        return Colors.orange;
      case ExerciseCategory.legs:
        return Colors.green;
      case ExerciseCategory.abs:
        return Colors.purple;
      case ExerciseCategory.cardio:
        return Colors.red;
      case ExerciseCategory.other:
        return colors.onSurface.withValues(alpha: 0.5);
    }
  }
  
  String _getCompatibilityReason(double score, Exercise exercise) {
    final l10n = AppLocalizations.of(context);
    
    if (exercise.name == widget.currentExercise.name) {
      return l10n.currentExercise;
    }
    
    if (score >= 80) {
      if (exercise.category == widget.currentExercise.category) {
        return l10n.excellentReplacement;
      }
      return l10n.highlyCompatible;
    } else if (score >= 60) {
      return l10n.goodAlternative;
    } else if (score >= 40) {
      return l10n.possibleAlternative;
    } else {
      return l10n.differentMuscleGroup;
    }
  }
}
