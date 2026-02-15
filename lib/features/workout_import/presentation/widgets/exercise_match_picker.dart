/// Exercise Match Picker
///
/// Bottom sheet that allows users to search and select a different
/// exercise match from the database.
///
/// **Layer**: Presentation - Widget
/// **Feature**: Workout Import
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    show ExerciseDefinition;
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Result returned when user picks an exercise
class ExercisePickResult {
  const ExercisePickResult({
    required this.exerciseId,
    required this.exerciseName,
  });

  final String exerciseId;
  final String exerciseName;
}

class ExerciseMatchPicker extends ConsumerStatefulWidget {
  const ExerciseMatchPicker({
    required this.initialQuery,
    super.key,
  });

  final String initialQuery;

  @override
  ConsumerState<ExerciseMatchPicker> createState() =>
      _ExerciseMatchPickerState();
}

class _ExerciseMatchPickerState extends ConsumerState<ExerciseMatchPicker> {
  final _searchController = TextEditingController();
  List<ExerciseFuzzyResult> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _searchController.addListener(_onSearchChanged);
    // Run initial search
    _performSearch(widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _performSearch(_searchController.text);
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isSearching = true);

    final exercisesAsync = ref.read(allExercisesProvider);
    final exercises = exercisesAsync.when(
      data: (e) => e,
      loading: () => <ExerciseDefinition>[],
      error: (_, __) => <ExerciseDefinition>[],
    );

    if (exercises.isEmpty) {
      setState(() => _isSearching = false);
      return;
    }

    final results = await ExerciseFuzzyMatcher.searchExercises(
      exercises: exercises,
      query: query,
      maxResults: 20,
    );

    if (mounted) {
      setState(() {
        _results = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.workoutImportSearchExercise,
                prefixIcon:
                    const Icon(AppIcons.search, size: AppIconSize.small),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.close,
                            size: AppIconSize.small),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Results
          Expanded(
            child: _isSearching
                ? Center(
                    child: LoadingIndicator(
                      size: 32,
                      color: context.colors.primary,
                    ),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? l10n.workoutImportSearchExercise
                              : l10n.workoutImportNoMatch,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final result = _results[index];
                          return _buildResultTile(context, result);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, ExerciseFuzzyResult result) {
    final exercise = result.exercise;
    final confidence = (result.score * 100).toInt();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: ExerciseGifWidget(
        gifUrl: exercise.imageUrl,
        exerciseName: exercise.nome,
        size: 48,
      ),
      title: Text(
        exercise.nome,
        style: context.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        exercise.focus.join(', ').toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: confidence >= 80
              ? context.colors.primary.withValues(alpha: 0.12)
              : context.colors.onSurfaceVariant.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$confidence%',
          style: context.textTheme.labelSmall?.copyWith(
            color: confidence >= 80
                ? context.colors.primary
                : context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).pop(
          ExercisePickResult(
            exerciseId: exercise.id,
            exerciseName: exercise.nome,
          ),
        );
      },
    );
  }
}
