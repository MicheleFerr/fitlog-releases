/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: widget
///
/// Exercise name autocomplete with ML-enhanced fuzzy search
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart' as ExerciseDB;
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/json_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/models/search_config.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/providers/exercise_search_service_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Autocomplete widget for exercise name with ML-enhanced fuzzy search
///
/// Features:
/// - Debounced fuzzy search (400ms)
/// - ML-enhanced ranking (user boost + category boost)
/// - Match percentage badges
/// - Typo tolerance
/// - Performance optimized (persistent isolate + batch ML boosts)
///
/// Refactored to use DI via IExerciseSearchService (Phase 2)
class ExerciseNameAutocomplete extends ConsumerStatefulWidget {
  const ExerciseNameAutocomplete({
    super.key,
    required this.controller,
    required this.onExerciseSelected,
    this.userId,
    this.currentCategory,
    this.decoration,
    this.hint,
  });

  final TextEditingController controller;
  final Function(ExerciseDB.Exercise exercise) onExerciseSelected;
  final String? userId;
  final String? currentCategory;
  final InputDecoration? decoration;
  final String? hint;

  @override
  ConsumerState<ExerciseNameAutocomplete> createState() =>
      _ExerciseNameAutocompleteState();
}

class _ExerciseNameAutocompleteState
    extends ConsumerState<ExerciseNameAutocomplete> {
  Timer? _debounce;
  List<ExerciseFuzzyResult> _suggestions = [];
  bool _isSearching = false;
  final _overlayController = OverlayPortalController();

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Performs debounced fuzzy search using injected IExerciseSearchService
  ///
  /// ARCHITECTURE (Phase 2 Refactoring):
  /// - Uses DI via exerciseSearchServiceProvider
  /// - Configuration via SearchConfig.autocomplete
  /// - Analytics tracking via injected IAnalyticsService
  /// - No direct dependencies on FirebaseAuth or ExerciseFuzzyMatcher
  ///
  /// Backward compatible: Caller must pass userId parameter
  Future<void> _performFuzzySearch(String query) async {
    _debounce?.cancel();

    if (query.trim().isEmpty || query.length < 2) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      _overlayController.hide();
      return;
    }

    // Show searching indicator after 100ms (prevent flicker)
    Timer(const Duration(milliseconds: 100), () {
      if (mounted && _isSearching == false) {
        setState(() => _isSearching = true);
      }
    });

    // Debounce for 400ms
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;

      try {
        // Get cached exercises from provider
        final exercisesAsync = ref.read(jsonExerciseRepositoryProvider);
        final exercises = exercisesAsync.value;

        if (exercises == null) {
          if (mounted) {
            setState(() {
              _isSearching = false;
              _suggestions = [];
            });
          }
          return;
        }

        // 🚀 ML-Enhanced Fuzzy Search via DI service (Phase 2)
        final searchService = ref.read(exerciseSearchServiceProvider);
        final results = await searchService.searchExercises(
          exercises: exercises,
          query: query,
          userId: widget.userId,
          currentCategory: widget.currentCategory,
          config: SearchConfig.autocomplete, // Optimized for autocomplete
        );

        if (!mounted) return;

        // Filter high-quality matches (>= 65% score)
        final filteredResults = results.where((r) => r.score >= 0.65).toList();

        setState(() {
          _suggestions = filteredResults;
          _isSearching = false;
        });

        // Show/hide overlay based on results
        if (filteredResults.isNotEmpty) {
          _overlayController.show();
        } else {
          _overlayController.hide();
        }

        if (kDebugMode) {
          debugPrint(
              '🔍 Autocomplete: ${filteredResults.length} suggestions for "$query"');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Autocomplete error: $e');
        }
        if (mounted) {
          setState(() {
            _suggestions = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  void _selectExercise(ExerciseDB.Exercise exercise) {
    widget.controller.text = exercise.nome;
    widget.onExerciseSelected(exercise);
    setState(() {
      _suggestions = [];
    });
    _overlayController.hide();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (BuildContext context) {
        return Positioned(
          width: MediaQuery.of(context).size.width - 32,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 60),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final fuzzyResult = _suggestions[index];
                    final exercise = fuzzyResult.exercise;
                    final matchPercentage = (fuzzyResult.score * 100).toInt();

                    // Match color based on score
                    Color matchColor;
                    if (fuzzyResult.score >= 0.85) {
                      matchColor = context.colors.success;
                    } else if (fuzzyResult.score >= 0.70) {
                      matchColor = context.colors.secondary;
                    } else {
                      matchColor = context.colors.surfaceContainerHighest;
                    }

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: context.colors.surfaceContainerHighest,
                        radius: 16,
                        child: Text(
                          exercise.attrezzaturaIcon,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.nome,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          // Match percentage badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
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
                                fontSize: 9,
                                color: matchColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Auto-correct icon
                          if (fuzzyResult.wasAutoCorrected) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.auto_fix_high,
                              size: 14,
                              color: context.colors.secondary,
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        exercise.focusDisplayName,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () => _selectExercise(exercise),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: TextField(
          controller: widget.controller,
          decoration: (widget.decoration ?? const InputDecoration())
              .copyWith(
                hintText: widget.hint ?? context.l10n.exerciseNameHint,
                prefixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(14.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.fitness_center),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          widget.controller.clear();
                          setState(() {
                            _suggestions = [];
                          });
                          _overlayController.hide();
                        },
                      )
                    : null,
              )
              .copyWith(
                // Maintain original decoration properties
                labelText: widget.decoration?.labelText,
                prefixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(14.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : widget.decoration?.prefixIcon ??
                        const Icon(Icons.fitness_center),
              ),
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            setState(() {}); // Update suffix icon visibility
            _performFuzzySearch(value);
          },
        ),
      ),
    );
  }

  final LayerLink _layerLink = LayerLink();
}
