import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';
import 'package:gymbro_flutter_new/shared/domain/services/request_throttler.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/json_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart' as WorkoutExercise;
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_options_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_history_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_customization_screen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_usage_tracker.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/exercise_search_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/missing_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/widgets/custom_exercise_form_sheet.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/providers/custom_exercise_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/i_exercise_preferences.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';
// Exercise search tutorial REMOVED - UX 2025 analysis: search UI is standard pattern

class ExerciseSearchScreen extends ConsumerStatefulWidget { // New: Just select and return exercise template (for DropSet/Rest-Pause)

  const ExerciseSearchScreen({
    super.key,
    this.onExerciseAdded,
    this.multiSelectMode = false,
    this.selectionMode = false,
  });
  final Function(WorkoutExercise.Exercise)? onExerciseAdded; // 🔥 FIX: Add callback parameter
  final bool multiSelectMode; // New: Support multi-select for superset builder
  final bool selectionMode;

  @override
  ConsumerState<ExerciseSearchScreen> createState() => _ExerciseSearchScreenState();
}

class _ExerciseSearchScreenState extends ConsumerState<ExerciseSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<Exercise> _selectedExercises = <Exercise>{};

  // Widget keys (used for widget identification)
  final GlobalKey _searchBarKey = GlobalKey();
  final GlobalKey _filterButtonKey = GlobalKey();
  final GlobalKey _quickFiltersKey = GlobalKey();
  final GlobalKey _exerciseCardKey = GlobalKey();
  final GlobalKey _addButtonKey = GlobalKey();

  String _searchQuery = '';
  List<String> _selectedFocus = [];
  final List<String> _selectedMuscleGroups = [];
  List<String> _selectedEquipment = [];
  final List<String> _selectedDifficulty = [];
  String? _selectedType;

  bool _showFilters = false;
  bool _showSearch = true; // P1-3 FIX: Show search by default for faster logging
  // Muscle groups filter removed - keeping equipment and difficulty only
  bool _showDifficultyFilter = false;
  bool _showEquipmentFilter = false;

  // 🔐 SECURITY: Fuzzy search state with proper debouncing
  late final Debouncer _searchDebouncer;
  List<ExerciseFuzzyResult> _fuzzyResults = [];
  bool _isSearching = false;
  bool _useFuzzyResults = false;

  // ML-enhanced state (usage tracking)
  Set<String> _frequentExerciseIds = {};
  Set<String> _trendingExerciseIds = {};

  @override
  void initState() {
    super.initState();
    // 🔐 SECURITY: Initialize search debouncer (P1-3: reduced to 200ms for faster logging)
    _searchDebouncer = Debouncer(
      duration: const Duration(milliseconds: 200),
      onError: (error, stackTrace) {
        if (kDebugMode) {
          debugPrint('⚠️ [ExerciseSearch] Debouncer error: $error');
        }
      },
    );
    _loadUsageStats();
    // Exercise search tutorial removed - UX 2025: search UI is intuitive standard pattern
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebouncer.dispose(); // 🔐 SECURITY: Proper cleanup
    super.dispose();
  }

  /// Carica statistiche utilizzo esercizi (frequent/trending)
  Future<void> _loadUsageStats() async {
    try {
      final tracker = ExerciseUsageTracker();

      // Get top used exercises (top 10%)
      final topExercises = await tracker.getTopUsedExercises(limit: 50);

      // Get recently used (last 7 days)
      final recentExercises = await tracker.getRecentlyUsedExercises(limit: 30);
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentIds = recentExercises
          .where((e) => e.lastUsedAt.isAfter(sevenDaysAgo))
          .map((e) => e.exerciseId)
          .toSet();

      if (mounted) {
        setState(() {
          _frequentExerciseIds = topExercises.map((e) => e.exerciseId).toSet();
          _trendingExerciseIds = recentIds;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error loading usage stats: $e');
      }
    }
  }

  /// Gestisce negative feedback con opzioni (decrementa o rimuovi)
  Future<void> _handleNegativeFeedback(Exercise exercise) async {
    // Mostra dialogo con opzioni
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const SemanticIcon(
  icon: AppIcons.feedbackOutlined,
  semanticLabel: 'Feedback outlined',
  size: AppIconSize.medium,
),
            const SizedBox(width: 12),
            Expanded(child: Text(context.l10n.exerciseFeedback)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Come vuoi gestire "${exercise.nome}"?',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '• Riduci priorità: L\'esercizio apparirà meno in alto\n• Rimuovi dai popolari: L\'esercizio non sarà più suggerito come frequente',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop('decrement'),
            icon: const SemanticIcon(
  icon: AppIcons.arrowDownward,
  semanticLabel: 'Arrow downward',
  size: AppIconSize.small,
),
            label: Text(context.l10n.reducePriority),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop('remove'),
            icon: const SemanticIcon(
  icon: AppIcons.deleteOutline,
  semanticLabel: 'Delete outline',
  size: AppIconSize.small,
),
            label: Text(context.l10n.remove),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.errorContainer,
              foregroundColor: context.colors.onErrorContainer,
            ),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;

    try {
      final tracker = ExerciseUsageTracker();

      if (result == 'decrement') {
        // Decrementa boost
        await tracker.decrementUsage(exerciseId: exercise.id);

        if (mounted) {
          SnackBarService.showInfo(context, 'Priorità ridotta per "${exercise.nome}"');
        }
      } else if (result == 'remove') {
        // Rimuovi completamente
        await tracker.removeExercise(exerciseId: exercise.id);

        if (mounted) {
          SnackBarService.showError(
            context,
            '"${exercise.nome}" rimosso dai popolari',
            actionLabel: 'ANNULLA',
            onAction: () async {
              // Re-add with usage count 1
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await tracker.incrementUsage(
                  exerciseId: exercise.id,
                  exerciseName: exercise.nome,
                  userId: user.uid,
                );
                await _loadUsageStats();
              }
            },
          );
        }
      }

      // Reload stats
      await _loadUsageStats();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error handling negative feedback: $e');
      }
    }
  }

  /// Tracka utilizzo esercizio quando viene selezionato
  Future<void> _trackExerciseSelection(Exercise exercise) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final tracker = ExerciseUsageTracker();
      await tracker.incrementUsage(
        exerciseId: exercise.id,
        exerciseName: exercise.nome,
        userId: user.uid,
      );

      // Reload stats in background (no await to not block UI)
      _loadUsageStats();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error tracking exercise selection: $e');
      }
    }
  }

  Future<void> _performFuzzySearch(String query) async {
    if (query.trim().isEmpty || query.length < 2) {
      setState(() {
        _useFuzzyResults = false;
        _fuzzyResults = [];
        _isSearching = false;
      });
      return;
    }

    // OPTIMIZATION: Only show loading indicator after 100ms
    // This prevents flicker for fast typers
    Timer(const Duration(milliseconds: 100), () {
      if (mounted && _isSearching == false) {
        setState(() {
          _isSearching = true;
        });
      }
    });

    // 🔐 SECURITY: Use Debouncer for search throttling (400ms delay)
    _searchDebouncer.run(() async {
      if (!mounted) return;

      final searchStartTime = DateTime.now();

      try {
        // ✅ FIX: Usa esercizi già caricati dal provider (CACHED!)
        // Non ricaricare JSON ogni volta - causa lag UI
        final exercisesAsync = ref.read(jsonExerciseRepositoryProvider);
        final exercises = exercisesAsync.value;

        if (exercises == null) {
          // Provider still loading, skip
          if (mounted) {
            setState(() {
              _isSearching = false;
            });
          }
          return;
        }

        // Get userId for ML-enhanced personalization
        final user = FirebaseAuth.instance.currentUser;
        final userId = user?.uid;

        // Get current category from selected muscle groups (if any)
        final currentCategory = _selectedMuscleGroups.isNotEmpty
            ? _selectedMuscleGroups.first
            : null;

        // 🚀 OPTIMIZED: Persistent isolate + batch ML boosts
        final results = await ExerciseFuzzyMatcher.searchExercises(
          exercises: exercises,
          query: query,
          strictThreshold: 0.65,
          typeThreshold: 0.50,
          maxResults: 50,
          userId: userId,
          currentCategory: currentCategory,
          enableUserBoost: true,
          enableCategoryBoost: true,
        );

        if (!mounted) return;

        // Filter quality (>= 65% score)
        final filteredResults = results.where((r) => r.score >= 0.65).toList();

        // PERFORMANCE METRICS (debug only)
        if (kDebugMode) {
          final duration = DateTime.now().difference(searchStartTime);
          debugPrint('🔍 Fuzzy search completed in ${duration.inMilliseconds}ms (${filteredResults.length} results)');
        }

        // OPTIMIZATION: Batch setState to reduce rebuilds
        setState(() {
          _fuzzyResults = filteredResults;
          _useFuzzyResults = filteredResults.isNotEmpty;
          _isSearching = false;
        });
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Fuzzy search error: $e');
        }
        if (mounted) {
          setState(() {
            _useFuzzyResults = false;
            _fuzzyResults = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  /// Toggle search bar visibility
  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        // Clear search when closing
        _searchController.clear();
        _searchQuery = '';
        _useFuzzyResults = false;
        _fuzzyResults = [];
        _searchDebouncer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use fuzzy search for active queries, fallback to JSON repository for browsing
    final exercisesAsync = ref.watch(jsonExerciseRepositoryProvider);
    final l10n = context.l10n;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.searchExercises} (${_selectedExercises.length})'),
        centerTitle: true,
        leading: IconButton(
          icon: const SemanticIcon(
  icon: AppIcons.back,
  semanticLabel: 'Back',
),
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
              icon: Icon(widget.multiSelectMode ? AppIcons.check : AppIcons.add),
              onPressed: widget.multiSelectMode ? _selectExercises : _addSelectedToWorkout,
              tooltip: widget.multiSelectMode ? 'Select Exercises' : l10n.addToWorkout,
            ),
          IconButton(
            key: _filterButtonKey,
            icon: Icon(_showFilters ? AppIcons.filter : AppIcons.filterListOutlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: l10n.filters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar (shown when FAB is tapped)
          if (_showSearch) ...[
            Container(
              padding: const EdgeInsets.all(16.0),
              color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchExercisesHint,
                  // ✅ FIX: Icona search sempre visibile (mai nascosta dal loader)
                  prefixIcon: const SemanticIcon(
                    icon: AppIcons.search,
                    semanticLabel: 'Search',
                  ),
                  // ✅ FIX: Loader a destra quando carica, altrimenti X per cancellare
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: LoadingIndicator(size: 20),
                        )
                      : (_searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const SemanticIcon(
                                icon: AppIcons.clear,
                                semanticLabel: 'Clear',
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _useFuzzyResults = false;
                                  _fuzzyResults = [];
                                });
                                _searchDebouncer.cancel(); // 🔐 SECURITY: Cancel pending search
                              },
                            )
                          : null),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: context.colors.surface,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                  // Trigger fuzzy search
                  _performFuzzySearch(value);
                },
              ),
            ),
          ],

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
                    l10n.filters,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Quick Filters Row - Improved with smart categories
                  SingleChildScrollView(
                    key: _quickFiltersKey, // Tutorial target
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickFilter('Tutti', _clearAllFilters,
                          isActive: _isAllFiltersEmpty()),
                        const SizedBox(width: 8),
                        ...ExerciseSearchService.quickFilters.map((filter) =>
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildQuickFilterChip(
                              label: filter['label'],
                              icon: filter['icon'],
                              onTap: () => _applySmartFilter(filter['query']),
                              isActive: _searchQuery == filter['query'],
                            ),
                          ),
                        ),
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
            child: _useFuzzyResults
                ? _buildFuzzySearchResults()
                : exercisesAsync.when(
                    data: (exercises) {
                      final filteredExercises = _filterExercises(exercises);

                      if (filteredExercises.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildSearchResults(filteredExercises);
                    },
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, stack) => _buildErrorState(error),
                  ),
          ),
        ],
      ),

      // Selected Exercises Count
      bottomNavigationBar: _selectedExercises.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedExercises.length} ${l10n.exercisesSelected}',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      key: _addButtonKey, // Tutorial target
                      onPressed: widget.multiSelectMode ? _selectExercises : _addSelectedToWorkout,
                      icon: Icon(widget.multiSelectMode ? AppIcons.check : AppIcons.add),
                      label: Text(widget.multiSelectMode ? l10n.confirm : l10n.add),
                    ),
                  ],
                ),
              ),
            )
          : null,

      // FAB for search (always visible)
      floatingActionButton: FloatingActionButton(
        key: _searchBarKey, // Tutorial target for search
        onPressed: _toggleSearch,
        tooltip: _showSearch ? l10n.close : l10n.search,
        child: Icon(_showSearch ? AppIcons.close : AppIcons.search),
      ),
    );
  }

  Widget _buildSearchResults(List<Exercise> exercises) {
    final l10n = context.l10n;

    // Watch custom exercises and merge with catalog
    final customExercisesAsync = ref.watch(activeCustomExercisesProvider);
    final customExercises = customExercisesAsync.valueOrNull ?? [];

    // Convert custom exercises to Exercise format for display
    final customAsExercises = customExercises.map((custom) => Exercise(
      id: custom.id,
      nome: custom.nome,
      focus: custom.focus,
      imageUrl: null,
      muscoliSecondari: custom.muscoliSecondari,
      difficolta: 'Intermedio',
      tipoEsercizio: custom.tipoEsercizio,
      attrezzatura: custom.attrezzatura,
      patternMovimento: custom.patternMovimento,
      rangeRipetizioni: '8-12',
      noteTecniche: '',
      mobilitaPre: null,
      attivazionePre: null,
    )).toList();

    // Merge: custom exercises first, then catalog
    final allExercises = [...customAsExercises, ...exercises];

    // P1-3 FIX: Get recent/frequent exercises for quick access
    final recentExercises = _searchQuery.isEmpty
        ? allExercises.where((e) =>
            _frequentExerciseIds.contains(e.id) || _trendingExerciseIds.contains(e.id)
          ).take(5).toList()
        : <Exercise>[];

    return Column(
      children: [
        // P1-3 FIX: Show recent exercises for quick access (when no search)
        if (recentExercises.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(AppIcons.history, size: 16, color: context.colors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.recentExercises,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: recentExercises.length,
              itemBuilder: (context, index) {
                final exercise = recentExercises[index];
                final isSelected = _selectedExercises.contains(exercise);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    avatar: isSelected
                        ? Icon(AppIcons.check, size: 16, color: context.colors.onPrimary)
                        : null,
                    label: Text(
                      exercise.nome,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: isSelected ? context.colors.onPrimary : null,
                      ),
                    ),
                    backgroundColor: isSelected ? context.colors.primary : null,
                    onPressed: () {
                      // Selection mode: return and close
                      if (widget.selectionMode) {
                        Navigator.of(context).pop(exercise);
                        return;
                      }
                      // Toggle selection
                      setState(() {
                        if (_selectedExercises.contains(exercise)) {
                          _selectedExercises.remove(exercise);
                        } else {
                          _selectedExercises.add(exercise);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 16),
        ],

        // Results count
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          child: Text(
            '${allExercises.length} ${l10n.exercisesFound}',
            style: context.textTheme.bodySmall,
          ),
        ),

        // Exercise List + Missing Exercise Widget
        Expanded(
          child: ListView.builder(
            key: const PageStorageKey('exercise_search_list'),
            itemCount: allExercises.length + 1, // +1 for missing exercise widget
            itemBuilder: (context, index) {
              // Show missing exercise widget as last item
              if (index == allExercises.length) {
                return _buildMissingExerciseWidget();
              }

              final exercise = allExercises[index];
              final isSelected = _selectedExercises.contains(exercise);
              final isCustom = index < customAsExercises.length;

              // Add tutorial key to first exercise card
              return _buildExerciseCard(
                exercise,
                isSelected,
                isCustom: isCustom,
                tutorialKey: index == 0 ? _exerciseCardKey : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFuzzySearchResults() {
    final l10n = context.l10n;

    return Column(
      children: [
        // Results count with fuzzy indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: context.colors.primaryContainer.withValues(alpha: 0.3),
          child: Row(
            children: [
              SemanticIcon(
  icon: AppIcons.autoAwesome,
  semanticLabel: 'Auto awesome',
  size: AppIconSize.tiny,
  color: context.colors.primary,
),
              const SizedBox(width: 8),
              Text(
                '${_fuzzyResults.length} ${l10n.exercisesFound}',
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(Smart Search)',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        // Fuzzy Exercise List + Missing Exercise Widget
        Expanded(
          child: ListView.builder(
            key: const PageStorageKey('exercise_fuzzy_search_list'),
            itemCount: _fuzzyResults.length + 1, // +1 for missing exercise widget
            itemBuilder: (context, index) {
              // Show missing exercise widget as last item
              if (index == _fuzzyResults.length) {
                return _buildMissingExerciseWidget();
              }

              final fuzzyResult = _fuzzyResults[index];
              final exercise = fuzzyResult.exercise;
              final isSelected = _selectedExercises.contains(exercise);

              return _buildFuzzyExerciseCard(
                exercise,
                isSelected,
                fuzzyResult.score,
                fuzzyResult.wasAutoCorrected,
                tutorialKey: index == 0 ? _exerciseCardKey : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMissingExerciseWidget() {
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.help,
                color: context.colors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.exerciseNotFound,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.exerciseNotFoundHelpText,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Create custom exercise button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showCreateCustomSheet(context, _searchController.text),
              icon: const SemanticIcon(
                icon: AppIcons.add,
                semanticLabel: 'Add',
              ),
              label: Text(l10n.createCustomExercise),
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Or add temporary (fallback option)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddTemporaryExerciseDialog,
              icon: const SemanticIcon(
                icon: AppIcons.addCircleOutline,
                semanticLabel: 'Add circle outline',
              ),
              label: Text(l10n.addTemporaryExercise),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTemporaryExerciseDialog() {
    final l10n = context.l10n;
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              AppIcons.workout,
              color: context.colors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l10n.addTemporaryExercise),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.exerciseNotFoundHelpText,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.enterExerciseName,
                hintText: 'es. Bulgarian Split Squat',
                border: const OutlineInputBorder(),
                prefixIcon: const SemanticIcon(
  icon: AppIcons.edit,
  semanticLabel: 'Edit',
),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () {
              final exerciseName = nameController.text.trim();
              if (exerciseName.isEmpty) {
                SnackBarService.showError(context, l10n.enterExerciseName);
                return;
              }

              // Generate ID from exercise name
              final exerciseId = _generateExerciseId(exerciseName);

              // Create temporary exercise
              final temporaryExercise = Exercise(
                id: exerciseId,
                nome: exerciseName,
                focus: const ['VARIO'],
                imageUrl: null,
                muscoliSecondari: const [],
                difficolta: 'Intermedio',
                tipoEsercizio: 'Compound',
                attrezzatura: 'Vario',
                patternMovimento: '',
                rangeRipetizioni: '8-12',
                noteTecniche: 'Esercizio temporaneo - In attesa di approvazione',
                mobilitaPre: null,
                attivazionePre: null,
              );

              // Add to selected exercises so user can use it immediately
              setState(() {
                _selectedExercises.add(temporaryExercise);
              });

              // Send report to Firebase for admin review
              _sendMissingExerciseReport(exerciseName, exerciseId);

              Navigator.of(context).pop();

              // Show confirmation
              SnackBarService.showSuccess(
                context,
                l10n.temporaryExerciseAdded,
                actionLabel: l10n.add,
                onAction: () {
                  // Add to workout directly
                  _addSelectedToWorkout();
                },
              );
            },
            icon: const SemanticIcon(
  icon: AppIcons.check,
  semanticLabel: 'Check',
),
            label: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  String _generateExerciseId(String exerciseName) {
    // Convert exercise name to ID format
    // Example: "Bulgarian Split Squat" -> "bulgarian_split_squat_temp"
    return '${exerciseName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}_temp';
  }

  Future<void> _sendMissingExerciseReport(
      String exerciseName, String exerciseId) async {
    try {
      final service = ref.read(missingExerciseServiceProvider);
      await service.submitRequest(
        exerciseName: exerciseName,
        exerciseId: exerciseId,
      );
    } catch (e) {
      // Silent fail - don't interrupt user flow
      // The temporary exercise is already added
      debugPrint('Failed to submit missing exercise request: $e');
    }
  }

  Widget _buildErrorState(dynamic error) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
  icon: AppIcons.error,
  semanticLabel: 'Error',
  size: AppIconSize.medium,
  color: context.colors.error,
),
          const SizedBox(height: 16),
          Text('${l10n.errorLoadingData}: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(jsonExerciseRepositoryProvider),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilter(String label, VoidCallback onTap, {required bool isActive}) {
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => onTap(),
      backgroundColor: context.colors.surface,
      selectedColor: context.colors.primaryContainer,
    );
  }

  /// Normalize muscle codes to canonical form
  ///
  /// **SINGLE SOURCE OF TRUTH**: Delegates to MuscleAbbreviationMapper.
  String _normalizedMuscleCode(String muscleCode) {
    return MuscleAbbreviationMapper.normalizeToCanonicalId(muscleCode);
  }

  Widget _buildAdvancedFilters(List<Exercise> exercises) {
    final l10n = context.l10n;

    // Note: Muscle groups filter removed per user request
    // Keeping only equipment and difficulty filters

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
        // Difficulty Filter (Collapsible)
        InkWell(
          onTap: () => setState(() => _showDifficultyFilter = !_showDifficultyFilter),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  _showDifficultyFilter ? AppIcons.expandMore : AppIcons.chevronRight,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.difficulty,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedDifficulty.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedDifficulty.length}',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_showDifficultyFilter) ...[
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
        ],

        // Equipment Filter (Collapsible)
        InkWell(
          onTap: () => setState(() => _showEquipmentFilter = !_showEquipmentFilter),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  _showEquipmentFilter ? AppIcons.expandMore : AppIcons.chevronRight,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.equipment,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedEquipment.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedEquipment.length}',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_showEquipmentFilter) ...[
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
      ],
    );
  }

  Widget _buildExerciseLeading(Exercise exercise, bool isSelected) {
    if (isSelected) {
      return CircleAvatar(
        backgroundColor: context.colors.primary,
        child: Icon(AppIcons.check, color: context.colors.surface),
      );
    }
    
    // Se c'è un'immagine, mostra quella, altrimenti l'icona
    if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: context.colors.surfaceContainerHighest,
        radius: 20,
        child: ClipOval(
          child: Image.network(
            exercise.imageUrl!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback all'icona se l'immagine non carica
              return Container(
                width: 40,
                height: 40,
                color: context.colors.surfaceContainerHighest,
                child: Center(
                  child: Text(
                    exercise.attrezzaturaIcon,
                    style: context.textTheme.titleMedium,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 40,
                height: 40,
                color: context.colors.surfaceContainerHighest,
                child: const Center(
                  child: LoadingIndicator(size: 16),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: context.colors.surfaceContainerHighest,
        child: Text(exercise.attrezzaturaIcon),
      );
    }
  }

  Widget _buildExerciseCard(
    Exercise exercise,
    bool isSelected, {
    bool isCustom = false,
    GlobalKey? tutorialKey,
  }) {
    return Card(
      key: tutorialKey,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Stack(
        children: [
          ListTile(
            leading: _buildExerciseLeading(exercise, isSelected),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.nome,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isCustom)
                  Text('⚡', style: context.textTheme.titleMedium),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.focusDisplayName),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(exercise.difficolta).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        exercise.difficolta,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: _getDifficultyColor(exercise.difficolta),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      exercise.attrezzatura,
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Create variant button for catalog exercises
                if (!isCustom && !widget.selectionMode)
                  IconButton(
                    icon: const Icon(AppIcons.copy),
                    tooltip: context.l10n.createVariant,
                    onPressed: () => _showCreateVariantSheet(context, exercise),
                    iconSize: 20,
                  ),
                const SizedBox(width: 8),
                // Selection indicator
                isSelected
                    ? Icon(AppIcons.checkCircle, color: context.colors.primary)
                    : (widget.selectionMode ? const SemanticIcon(
  icon: AppIcons.arrowForwardIos,
  semanticLabel: 'Arrow forward ios',
  size: AppIconSize.tiny,
) : const SemanticIcon(
  icon: AppIcons.radioButtonUnchecked,
  semanticLabel: 'Radio button unchecked',
)),
              ],
            ),
            onTap: () {
              // Selection mode: return exercise and close
              if (widget.selectionMode) {
                Navigator.of(context).pop(exercise);
                return;
              }

              // Multi-select mode or normal mode: toggle selection
              setState(() {
                if (isSelected) {
                  _selectedExercises.remove(exercise);
                } else {
                  _selectedExercises.add(exercise);
                }
              });
            },
            onLongPress: widget.selectionMode ? null : () => _showExerciseOptionsModal(exercise),
          ),
        ],
      ),
    );
  }

  Widget _buildFuzzyExerciseCard(
    Exercise exercise,
    bool isSelected,
    double matchScore,
    bool wasAutoCorrected, {
    GlobalKey? tutorialKey,
  }) {
    final matchPercentage = (matchScore * 100).toInt();

    // Color based on match quality
    Color matchColor;
    if (matchScore >= 0.85) {
      matchColor = context.colors.success;
    } else if (matchScore >= 0.70) {
      matchColor = context.colors.warning;
    } else {
      matchColor = context.colors.surfaceContainerHighest;
    }

    // Check if exercise is frequent or trending (ML-enhanced)
    final isFrequent = _frequentExerciseIds.contains(exercise.id);
    final isTrending = _trendingExerciseIds.contains(exercise.id);

    // Check if category matches (for colored border)
    // ML-enhanced: show green border if exercise matches selected muscle groups
    final hasCategoryMatch = _selectedMuscleGroups.isNotEmpty &&
        exercise.focus.any((focus) =>
            _selectedMuscleGroups.contains(_normalizedMuscleCode(focus))
        );

    return Card(
      key: tutorialKey,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: wasAutoCorrected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasCategoryMatch
            ? BorderSide(color: context.colors.success, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: _buildExerciseLeading(exercise, isSelected),
        title: Row(
          children: [
            Expanded(
              child: Text(
                exercise.nome,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            // Match percentage badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: matchColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: matchColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                '$matchPercentage%',
                style: context.textTheme.labelSmall?.copyWith(
                  color: matchColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Auto-correct icon
            if (wasAutoCorrected) ...[
              const SizedBox(width: 4),
              SemanticIcon(
  icon: AppIcons.autoFixHigh,
  semanticLabel: 'Auto fix high',
  size: AppIconSize.tiny,
  color: context.colors.secondary,
),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ML-enhanced badges row
            if (isFrequent || isTrending) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (isFrequent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.colors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.colors.warning.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('⭐', style: context.textTheme.labelSmall),
                          const SizedBox(width: 2),
                          Text(
                            'Frequente',
                            style: context.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isFrequent && isTrending) const SizedBox(width: 4),
                  if (isTrending)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.colors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.colors.warning.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🔥', style: context.textTheme.labelSmall),
                          const SizedBox(width: 2),
                          Text(
                            'Recente',
                            style: context.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Text(exercise.focusDisplayName),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(exercise.difficolta).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    exercise.difficolta,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: _getDifficultyColor(exercise.difficolta),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  exercise.attrezzatura,
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: isSelected || widget.selectionMode ? 24 : 56,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Negative feedback button (only if not selected)
              if (!isSelected && !widget.selectionMode)
                InkWell(
                  onTap: () => _handleNegativeFeedback(exercise),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
  size: AppIconSize.tiny,
  color: context.colors.error.withValues(alpha: 0.7,
),
                    ),
                  ),
                ),
              // Spacer
              if (!isSelected && !widget.selectionMode) const SizedBox(width: 4),
              // Selection icon
              isSelected
                  ? Icon(AppIcons.complete, color: context.colors.primary)
                  : (widget.selectionMode
                      ? const SemanticIcon(
  icon: AppIcons.arrowForwardIos,
  semanticLabel: 'Arrow forward ios',
  size: AppIconSize.tiny,
)
                      : const SemanticIcon(
  icon: AppIcons.radioButtonUnchecked,
  semanticLabel: 'Radio button unchecked',
)),
            ],
          ),
        ),
        onTap: () {
          // Track selection (ML-enhanced)
          _trackExerciseSelection(exercise);

          // Selection mode: return exercise and close
          if (widget.selectionMode) {
            Navigator.of(context).pop(exercise);
            return;
          }

          // Multi-select mode or normal mode: toggle selection
          setState(() {
            if (isSelected) {
              _selectedExercises.remove(exercise);
            } else {
              _selectedExercises.add(exercise);
            }
          });
        },
        onLongPress: widget.selectionMode
            ? null
            : () => _showExerciseOptionsModal(exercise),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = context.l10n;
    return ListView(
      children: [
        const SizedBox(height: 64),
        SemanticIcon(
  icon: AppIcons.searchOff,
  semanticLabel: 'Search off',
  size: AppIconSize.medium,
  color: context.colors.onSurface.withValues(alpha: 0.5,
),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.noExercisesFound,
          style: context.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.tryModifyingFilters,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: _clearAllFilters,
          child: Text(l10n.clearAllFilters),
        ),
        const SizedBox(height: 24),
        _buildMissingExerciseWidget(),
      ],
    );
  }

  List<Exercise> _filterExercises(List<Exercise> exercises) {
    return exercises.where((exercise) {
      // Search query filter - skip if it's a smart filter
      // (improved search already handled it)
      if (_searchQuery.isNotEmpty && !_isSmartFilter(_searchQuery)) {
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

      // Muscle groups filter
      if (_selectedMuscleGroups.isNotEmpty) {
        final normalizedFocus = exercise.focus.map(_normalizedMuscleCode).toList();
        if (!normalizedFocus.any((focus) => _selectedMuscleGroups.contains(focus))) {
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
        return context.colors.success;
      case 'intermedio':
        return context.colors.warning;
      case 'avanzato':
        return context.colors.error;
      default:
        return context.colors.surfaceContainerHighest;
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFocus.clear();
      _selectedMuscleGroups.clear();
      _selectedEquipment.clear();
      _selectedDifficulty.clear();
      _selectedType = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  bool _isAllFiltersEmpty() {
    return _selectedFocus.isEmpty &&
        _selectedMuscleGroups.isEmpty &&
        _selectedEquipment.isEmpty &&
        _selectedDifficulty.isEmpty &&
        _selectedType == null &&
        _searchQuery.isEmpty;
  }

  bool _isSmartFilter(String query) {
    return ExerciseSearchService.quickFilters
        .any((filter) => filter['query'] == query.toLowerCase());
  }

  void _applySmartFilter(String query) {
    setState(() {
      _searchQuery = query;
      _searchController.text = query;
    });
    // 🔥 FIX: Update provider to trigger improved search
    ref.read(exerciseSearchQueryProvider.notifier).state = query;
  }

  Widget _buildQuickFilterChip({
    required String label,
    required String icon,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return FilterChip(
      avatar: Text(icon, style: context.textTheme.bodyMedium),
      label: Text(label),
      selected: isActive,
      onSelected: (_) => onTap(),
      selectedColor: context.colors.primaryContainer,
      checkmarkColor: context.colors.primary,
      labelStyle: context.textTheme.labelMedium?.copyWith(
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        color: isActive
          ? context.colors.onPrimaryContainer
          : context.colors.onSurfaceVariant,
      ),
    );
  }

  void _addSelectedToWorkout() {
    if (_selectedExercises.isEmpty) return;

    // ✅ Read user's saved counting mode preferences
    final overridesAsync = ref.read(allCountingModeOverridesProvider);
    final Map<String, ExerciseCountingMode> overrides = overridesAsync.when(
      data: (data) => data.map((key, value) => MapEntry(key, ExerciseCountingMode.fromString(value))),
      loading: () => {},
      error: (_, __) => {},
    );

    // Navigate to customization screen and pass callback + overrides
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseCustomizationScreen(
          selectedExercises: _selectedExercises.toList(),
          onExerciseAdded: widget.onExerciseAdded, // 🔥 FIX: Pass callback
          countingModeOverrides: overrides.isEmpty ? null : overrides, // ✅ Pass user preferences
        ),
      ),
    );
  }
  
  void _selectExercises() {
    if (_selectedExercises.isEmpty) return;
    
    // Return selected exercises directly to caller (for superset builder)
    Navigator.of(context).pop(_selectedExercises.toList());
  }

  WorkoutExercise.Exercise _convertToWorkoutExercise(Exercise exercise) {
    // ✅ Check for user-saved counting mode override
    final overridesAsync = ref.read(allCountingModeOverridesProvider);
    ExerciseCountingMode? override;
    overridesAsync.whenData((data) {
      final savedMode = data[exercise.id];
      if (savedMode != null) {
        override = ExerciseCountingMode.fromString(savedMode);
      }
    });

    // Use centralized converter with optional override
    return ExerciseConverter.fromDatabaseExercise(
      exercise,
      countingModeOverride: override,
    );
  }

  void _showExerciseOptionsModal(Exercise exercise) {
    // Converto l'esercizio del database in un esercizio workout per il modal
    final workoutExercise = _convertToWorkoutExercise(exercise);
    final locale = ref.read(localeProvider);

    ExerciseOptionsModal.show(
      context,
      workoutExercise,
      onHistory: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
          builder: (context) => ExerciseHistoryBottomSheet(
            exerciseName: exercise.nome,
            exerciseId: exercise.id,
          ),
        );
      },
      imageUrl: exercise.imageUrl,
      languageCode: locale.languageCode,
    );
  }

  /// Show custom exercise creation sheet (pure custom)
  Future<void> _showCreateCustomSheet(BuildContext context, String initialName) async {
    if (!mounted) return;

    final result = await CustomExerciseFormSheet.show(
      context,
      onSave: (exercise) async {
        final repository = ref.read(customExerciseRepositoryProvider);
        await repository.save(exercise);
      },
    );

    if (result != null && mounted) {
      SnackBarService.showSuccess(
        context,
        '${result.nome} ${context.l10n.addedSuccessfully}',
      );
    }
  }

  /// Show custom exercise creation sheet (variant of base)
  Future<void> _showCreateVariantSheet(BuildContext context, Exercise base) async {
    if (!mounted) return;

    final result = await CustomExerciseFormSheet.show(
      context,
      baseExercise: base,
      onSave: (exercise) async {
        final repository = ref.read(customExerciseRepositoryProvider);
        await repository.save(exercise);
      },
    );

    if (result != null && mounted) {
      SnackBarService.showSuccess(
        context,
        '${result.nome} ${context.l10n.addedSuccessfully}',
      );
    }
  }


}
