import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/exercise_compatibility_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/exercise_json_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/fuzzy_search_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart' as exercise_db;
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/json_exercise_repository.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

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
  bool _isSearching = false;
  Timer? _searchDebounce;
  List<exercise_db.Exercise> _dbExercises = [];
  List<ExerciseSearchResult> _fuzzyResults = [];

  @override
  void initState() {
    super.initState();
    _loadDatabaseExercises();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  /// Load exercises from JSON database for fuzzy search
  Future<void> _loadDatabaseExercises() async {
    try {
      final locale = Localizations.localeOf(context);
      final repository = JsonExerciseRepository(locale: locale);
      final exercises = await repository.getAllExercises();
      if (mounted) {
        setState(() {
          _dbExercises = exercises;
        });
      }
    } catch (e) {
      debugPrint('Error loading database exercises: $e');
    }
  }

  /// Perform fuzzy search with debouncing
  void _performFuzzySearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _fuzzyResults = [];
        _isSearching = false;
      });
      return;
    }

    // Cancel previous search
    _searchDebounce?.cancel();

    // Show loading
    setState(() => _isSearching = true);

    // Debounce search (300ms)
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (_dbExercises.isEmpty) {
        setState(() => _isSearching = false);
        return;
      }

      final locale = Localizations.localeOf(context).languageCode;
      final results = FuzzySearchService.searchExercises(
        query: query,
        allExercises: _dbExercises,
        locale: locale,
      );

      if (mounted) {
        setState(() {
          _fuzzyResults = results;
          _isSearching = false;
        });
      }
    });
  }

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
    
    // Get suggestions or all exercises based on search/toggle
    List<ExerciseSuggestion> displayList;

    if (_searchQuery.isNotEmpty && _fuzzyResults.isNotEmpty) {
      // Use fuzzy search results with hybrid scoring (fuzzy + compatibility)
      displayList = _fuzzyResults.map((fuzzyResult) {
        // Try to find existing workout exercise with same name
        Exercise? matchingWorkoutExercise;
        try {
          matchingWorkoutExercise = allExercises.firstWhere(
            (ex) => ex.name.toLowerCase() == fuzzyResult.exercise.nome.toLowerCase(),
          );
        } catch (e) {
          // Exercise not found in workout provider, create minimal Exercise from DB exercise
          matchingWorkoutExercise = Exercise(
            name: fuzzyResult.exercise.nome,
            type: ExerciseType.single, // Default to single exercise
            category: _mapCategoryFromMuscles(fuzzyResult.exercise.focus),
          );
        }

        // Calculate compatibility between current exercise and candidate
        final compatibility = ExerciseCompatibilityService.calculateCompatibility(
          widget.currentExercise,
          matchingWorkoutExercise,
        );

        // Hybrid score: 50% fuzzy name similarity + 50% muscle/pattern compatibility
        // Fuzzy score is 0-1, compatibility is 0-100
        // Convert fuzzy to 0-100 scale and average
        final fuzzyScore100 = fuzzyResult.score * 100; // 0-1 → 0-100
        final hybridScore = (fuzzyScore100 * 0.5) + (compatibility * 0.5);

        return ExerciseSuggestion(
          exercise: matchingWorkoutExercise,
          compatibilityScore: hybridScore,
          reason: _getCompatibilityReason(compatibility, matchingWorkoutExercise),
        );
      }).toList()
        ..sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));
    } else if (_showOnlyCompatible) {
      // Show smart suggestions only (no search query)
      displayList = ExerciseCompatibilityService.getSuggestedReplacements(
        widget.currentExercise,
        allExercises,
      );
    } else {
      // Show all exercises with compatibility scores (no search query)
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

    // Filter based on category only (search filtering is done by fuzzy search)
    final filteredSuggestions = displayList.where((s) {
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
                      icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
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
                          style: context.textTheme.bodySmall?.copyWith(
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
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _performFuzzySearch(value);
                  },
                  decoration: InputDecoration(
                    hintText: l10n.searchExercises,
                    prefixIcon: const SemanticIcon(
  icon: AppIcons.search,
  semanticLabel: 'Search',
),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: LoadingIndicator(size: 20),
                          )
                        : (_searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                  _performFuzzySearch('');
                                },
                                icon: const SemanticIcon(
  icon: AppIcons.clear,
  semanticLabel: 'Clear',
),
                              )
                            : null),
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
                            SemanticIcon(
  icon: AppIcons.autoAwesome,
  semanticLabel: 'Auto awesome',
  size: AppIconSize.tiny,
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
                child: LoadingIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SemanticIcon(
  icon: AppIcons.error,
  semanticLabel: 'Error',
  size: AppIconSize.medium,
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
                        SemanticIcon(
  icon: AppIcons.searchOff,
  semanticLabel: 'Search off',
  size: AppIconSize.medium,
  color: theme.colorScheme.onSurface.withValues(alpha: 0.3,
),
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
      compatibilityColor = context.colors.success;
      compatibilityIcon = AppIcons.star;
    } else if (suggestion.compatibilityScore >= 60) {
      compatibilityColor = context.colors.secondary;
      compatibilityIcon = AppIcons.starHalf;
    } else if (suggestion.compatibilityScore >= 40) {
      compatibilityColor = context.colors.warning;
      compatibilityIcon = AppIcons.star;
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
                        style: context.textTheme.labelSmall?.copyWith(
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
                  SemanticIcon(
  icon: AppIcons.info,
  semanticLabel: 'Information',
  size: AppIconSize.tiny,
  color: theme.colorScheme.primary,
),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.replacementKeepsSetsAndReps,
                      style: context.textTheme.bodySmall?.copyWith(
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
        return AppIcons.sportsGymnastics;
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
        return context.colors.secondary;
      case ExerciseCategory.legs:
        return context.colors.success;
      case ExerciseCategory.abs:
        return context.colors.tertiary;
      case ExerciseCategory.cardio:
        return context.colors.error;
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

  /// Map database exercise muscles to workout category
  ExerciseCategory _mapCategoryFromMuscles(List<String> muscles) {
    // Convert to uppercase for case-insensitive matching
    final musclesUpper = muscles.map((m) => m.toUpperCase()).toList();

    // Check each muscle group
    if (musclesUpper.any((m) => m.contains('PETT') || m.contains('CHEST') || m.contains('PECS'))) {
      return ExerciseCategory.chest;
    } else if (musclesUpper.any((m) => m.contains('DORS') || m.contains('LAT') || m.contains('BACK'))) {
      return ExerciseCategory.back;
    } else if (musclesUpper.any((m) => m.contains('SPALL') || m.contains('DELT') || m.contains('SHOULDER'))) {
      return ExerciseCategory.shoulders;
    } else if (musclesUpper.any((m) => m.contains('BRAC') || m.contains('BICIP') || m.contains('TRIC') || m.contains('ARM'))) {
      return ExerciseCategory.arms;
    } else if (musclesUpper.any((m) => m.contains('QUAD') || m.contains('GLUT') || m.contains('FEMO') || m.contains('POLP') || m.contains('LEG'))) {
      return ExerciseCategory.legs;
    } else if (musclesUpper.any((m) => m.contains('CORE') || m.contains('ABS') || m.contains('ADDOME'))) {
      return ExerciseCategory.abs;
    } else if (musclesUpper.any((m) => m.contains('CARDIO'))) {
      return ExerciseCategory.cardio;
    }

    return ExerciseCategory.other;
  }
}
