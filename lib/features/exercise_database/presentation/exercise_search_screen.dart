import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

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

  String _searchQuery = '';
  List<String> _selectedFocus = [];
  final List<String> _selectedMuscleGroups = [];
  List<String> _selectedEquipment = [];
  final List<String> _selectedDifficulty = [];
  String? _selectedType;

  bool _showFilters = false;
  bool _showMuscleGroupsFilter = false;
  bool _showDifficultyFilter = false;
  bool _showEquipmentFilter = false;

  // Fuzzy search state
  Timer? _searchDebounce;
  List<ExerciseFuzzyResult> _fuzzyResults = [];
  bool _isSearching = false;
  bool _useFuzzyResults = false;

  // ML-enhanced state (usage tracking)
  Set<String> _frequentExerciseIds = {};
  Set<String> _trendingExerciseIds = {};

  @override
  void initState() {
    super.initState();
    _loadUsageStats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
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
        title: const Row(
          children: [
            Icon(Icons.feedback_outlined, size: 24),
            SizedBox(width: 12),
            Expanded(child: Text('Feedback Esercizio')),
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
            child: const Text('Annulla'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop('decrement'),
            icon: const Icon(AppIcons.arrowDownward, size: 18),
            label: const Text('Riduci priorità'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop('remove'),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Rimuovi'),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Priorità ridotta per "${exercise.nome}"'),
              duration: const Duration(seconds: 2),
              backgroundColor: context.colors.tertiary,
            ),
          );
        }
      } else if (result == 'remove') {
        // Rimuovi completamente
        await tracker.removeExercise(exerciseId: exercise.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${exercise.nome}" rimosso dai popolari'),
              duration: const Duration(seconds: 3),
              backgroundColor: context.colors.error,
              action: SnackBarAction(
                label: 'ANNULLA',
                textColor: Colors.white,
                onPressed: () async {
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
              ),
            ),
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
    // Cancel previous timer
    _searchDebounce?.cancel();

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

    // Debounce for 400ms (increased from 300ms for better batching)
    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
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
              icon: Icon(widget.multiSelectMode ? Icons.check : Icons.add),
              onPressed: widget.multiSelectMode ? _selectExercises : _addSelectedToWorkout,
              tooltip: widget.multiSelectMode ? 'Select Exercises' : l10n.addToWorkout,
            ),
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: l10n.filters,
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
                hintText: l10n.searchExercisesHint,
                prefixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _useFuzzyResults = false;
                            _fuzzyResults = [];
                          });
                          _searchDebounce?.cancel();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
                // Trigger fuzzy search
                _performFuzzySearch(value);
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
                    l10n.filters,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Quick Filters Row - Improved with smart categories
                  SingleChildScrollView(
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
                    loading: () => const Center(child: CircularProgressIndicator()),
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
                      onPressed: widget.multiSelectMode ? _selectExercises : _addSelectedToWorkout,
                      icon: Icon(widget.multiSelectMode ? Icons.check : Icons.add),
                      label: Text(widget.multiSelectMode ? l10n.confirm : l10n.add),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSearchResults(List<Exercise> exercises) {
    final l10n = context.l10n;

    return Column(
      children: [
        // Results count
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          child: Text(
            '${exercises.length} ${l10n.exercisesFound}',
            style: context.textTheme.bodySmall,
          ),
        ),

        // Exercise List + Missing Exercise Widget
        Expanded(
          child: ListView.builder(
            itemCount: exercises.length + 1, // +1 for missing exercise widget
            itemBuilder: (context, index) {
              // Show missing exercise widget as last item
              if (index == exercises.length) {
                return _buildMissingExerciseWidget();
              }

              final exercise = exercises[index];
              final isSelected = _selectedExercises.contains(exercise);

              return _buildExerciseCard(exercise, isSelected);
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
              Icon(
                Icons.auto_awesome,
                size: 16,
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
                Icons.help_outline,
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
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _showAddTemporaryExerciseDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: Text(l10n.addTemporaryExercise),
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primaryContainer,
                foregroundColor: context.colors.onPrimaryContainer,
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
              Icons.fitness_center,
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
                prefixIcon: const Icon(Icons.edit),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.enterExerciseName),
                    backgroundColor: context.colors.error,
                  ),
                );
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
                warmupSets: null,
                tempoWarmup: null,
                drillTecnico: null,
                prevenzioneInfortuni: null,
                cooldownConsigliato: null,
                spiegazioneTermini: null,
                tempoEsecuzione: null,
                tempoNote: null,
              );

              // Add to selected exercises so user can use it immediately
              setState(() {
                _selectedExercises.add(temporaryExercise);
              });

              // Send report to Firebase for admin review
              _sendMissingExerciseReport(exerciseName, exerciseId);

              Navigator.of(context).pop();

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.temporaryExerciseAdded),
                  backgroundColor: context.colors.primary,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: l10n.add,
                    textColor: context.colors.onPrimary,
                    onPressed: () {
                      // Add to workout directly
                      _addSelectedToWorkout();
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.check),
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
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
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

  String _normalizedMuscleCode(String muscleCode) {
    // Normalize muscle codes to canonical form
    final normalized = muscleCode.toUpperCase().trim();

    // Map variations to canonical codes
    switch (normalized) {
      case 'BICI': return 'BIC';
      case 'PETT': return 'PET';
      case 'AVA': return 'AVAMB';
      case 'ADDO': return 'ADD';
      default: return normalized;
    }
  }

  String _getMuscleGroupLocalizedName(String muscleCode) {
    final l10n = context.l10n;
    final normalized = _normalizedMuscleCode(muscleCode);

    // Map muscle codes to localized names
    switch (normalized) {
      case 'PET':
        return l10n.musclePectorals;
      case 'LAT':
      case 'SCH':
      case 'DORS':
      case 'DORSO':
        return l10n.muscleLats;
      case 'DELT':
      case 'DEL':
      case 'SPALLA':
        return l10n.muscleDeltoids;
      case 'BIC':
        return l10n.muscleBiceps;
      case 'TRIC':
        return l10n.muscleTriceps;
      case 'TRAP':
        return l10n.muscleTrapezius;
      case 'ROMBOIDI':
        return l10n.muscleRhomboids;
      case 'QUAD':
        return l10n.muscleQuads;
      case 'GLUT':
      case 'GLUTEI':
        return l10n.muscleGlutes;
      case 'FEMOR':
        return l10n.muscleHamstrings;
      case 'POLP':
        return l10n.muscleCalves;
      case 'ADDOM':
      case 'ABD':
      case 'ADD':
        return l10n.muscleAbs;
      case 'OBLIQ':
        return l10n.muscleObliques;
      case 'CORE':
        return l10n.muscleCore;
      case 'AVAMB':
        return l10n.muscleForearms;
      case 'ADDU':
        return l10n.muscleAdductors;
      case 'LOM':
        return l10n.muscleLowerBack;
      default:
        return muscleCode;
    }
  }

  Widget _buildAdvancedFilters(List<Exercise> exercises) {
    final l10n = context.l10n;

    // Extract unique muscle groups and map to localized names
    final muscleGroupsMap = <String, String>{};
    for (final exercise in exercises) {
      for (final muscleCode in exercise.focus) {
        final normalized = _normalizedMuscleCode(muscleCode);
        final localizedName = _getMuscleGroupLocalizedName(muscleCode);
        muscleGroupsMap[normalized] = localizedName;
      }
    }
    // Sort by localized name
    final muscleGroupOptions = muscleGroupsMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

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
        // Muscle Groups Filter (Collapsible)
        InkWell(
          onTap: () => setState(() => _showMuscleGroupsFilter = !_showMuscleGroupsFilter),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  _showMuscleGroupsFilter ? Icons.expand_more : Icons.chevron_right,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.muscleGroups,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedMuscleGroups.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedMuscleGroups.length}',
                      style: TextStyle(
                        color: context.colors.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_showMuscleGroupsFilter) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: muscleGroupOptions.map((entry) {
              final muscleCode = entry.key;
              final localizedName = entry.value;
              final isSelected = _selectedMuscleGroups.contains(muscleCode);
              return FilterChip(
                label: Text(localizedName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedMuscleGroups.add(muscleCode);
                    } else {
                      _selectedMuscleGroups.remove(muscleCode);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Difficulty Filter (Collapsible)
        InkWell(
          onTap: () => setState(() => _showDifficultyFilter = !_showDifficultyFilter),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  _showDifficultyFilter ? Icons.expand_more : Icons.chevron_right,
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
                      style: TextStyle(
                        color: context.colors.onPrimary,
                        fontSize: 12,
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
                  _showEquipmentFilter ? Icons.expand_more : Icons.chevron_right,
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
                      style: TextStyle(
                        color: context.colors.onPrimary,
                        fontSize: 12,
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
        child: const Icon(Icons.check, color: Colors.white),
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
                    style: const TextStyle(fontSize: 20),
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
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
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

  Widget _buildExerciseCard(Exercise exercise, bool isSelected) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildExerciseLeading(exercise, isSelected),
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
                    color: _getDifficultyColor(exercise.difficolta).withValues(alpha: 0.2),
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
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: context.colors.primary)
            : (widget.selectionMode ? const Icon(Icons.arrow_forward_ios, size: 16) : const Icon(AppIcons.radioButtonUnchecked)),
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
    );
  }

  Widget _buildFuzzyExerciseCard(
    Exercise exercise,
    bool isSelected,
    double matchScore,
    bool wasAutoCorrected,
  ) {
    final matchPercentage = (matchScore * 100).toInt();

    // Color based on match quality
    Color matchColor;
    if (matchScore >= 0.85) {
      matchColor = Colors.green;
    } else if (matchScore >= 0.70) {
      matchColor = Colors.orange;
    } else {
      matchColor = Colors.grey;
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: wasAutoCorrected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasCategoryMatch
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: _buildExerciseLeading(exercise, isSelected),
        title: Row(
          children: [
            Expanded(
              child: Text(
                exercise.nome,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            // Match percentage badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                style: TextStyle(
                  fontSize: 10,
                  color: matchColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Auto-correct icon
            if (wasAutoCorrected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.auto_fix_high,
                size: 16,
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
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('⭐', style: TextStyle(fontSize: 10)),
                          SizedBox(width: 2),
                          Text(
                            'Frequente',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isFrequent && isTrending) const SizedBox(width: 4),
                  if (isTrending)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.deepOrange.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🔥', style: TextStyle(fontSize: 10)),
                          SizedBox(width: 2),
                          Text(
                            'Recente',
                            style: TextStyle(
                              fontSize: 9,
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(exercise.difficolta).withValues(alpha: 0.2),
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
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: context.colors.error.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              // Spacer
              if (!isSelected && !widget.selectionMode) const SizedBox(width: 4),
              // Selection icon
              isSelected
                  ? Icon(Icons.check_circle, color: context.colors.primary)
                  : (widget.selectionMode
                      ? const Icon(Icons.arrow_forward_ios, size: 16)
                      : const Icon(AppIcons.radioButtonUnchecked)),
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
        Icon(
          Icons.search_off,
          size: 64,
          color: context.colors.onSurface.withValues(alpha: 0.5),
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

  void _applyQuickFilter(List<String> focusGroups) {
    setState(() {
      _selectedFocus = focusGroups;
      _selectedMuscleGroups.clear();
      _selectedEquipment.clear();
      _selectedDifficulty.clear();
    });
  }

  void _applyEquipmentFilter(List<String> equipment) {
    setState(() {
      _selectedEquipment = equipment;
      _selectedFocus.clear();
      _selectedMuscleGroups.clear();
      _selectedDifficulty.clear();
    });
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
      avatar: Text(icon, style: const TextStyle(fontSize: 16)),
      label: Text(label),
      selected: isActive,
      onSelected: (_) => onTap(),
      selectedColor: context.colors.primaryContainer,
      checkmarkColor: context.colors.primary,
      labelStyle: TextStyle(
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        color: isActive
          ? context.colors.onPrimaryContainer
          : context.colors.onSurfaceVariant,
      ),
    );
  }

  void _addSelectedToWorkout() {
    if (_selectedExercises.isEmpty) return;
    
    // Navigate to customization screen with selected exercises
    
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
  
  void _selectExercises() {
    if (_selectedExercises.isEmpty) return;
    
    // Return selected exercises directly to caller (for superset builder)
    Navigator.of(context).pop(_selectedExercises.toList());
  }

  WorkoutExercise.Exercise _convertToWorkoutExercise(Exercise exercise) {
    // Use centralized converter
    return ExerciseConverter.fromDatabaseExercise(exercise);
  }

  WorkoutExercise.ExerciseCategory _mapFocusToCategory(List<String> focus) {
    // Use centralized converter
    return ExerciseConverter.mapFocusToCategory(focus);
  }

  String _mapMuscleNameToCode(String muscleName) {
    // Use centralized converter
    return ExerciseConverter.mapMuscleNameToCode(muscleName);
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
          backgroundColor: Colors.transparent,
          builder: (context) => ExerciseHistoryBottomSheet(
            exerciseName: exercise.nome,
          ),
        );
      },
      imageUrl: exercise.imageUrl,
      languageCode: locale.languageCode,
    );
  }


}
