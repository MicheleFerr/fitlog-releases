/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/widgets/exercise_picker
/// 🎯 Feature: shared
/// 🔧 Type: widget
///
/// Quick picker semplificato per selezione rapida esercizi (Community)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/json_exercise_repository.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/exercise_picker/exercise_picker_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/exercise_picker/exercise_list_widget.dart';

/// Modal semplificato per quick pick di esercizi
/// Usato in Community per "Contribuisci"
///
/// Features:
/// - Solo search bar (no filtri)
/// - Tap = selezione immediata e chiusura
/// - UI minimale e veloce
class QuickExercisePicker extends ConsumerStatefulWidget {

  const QuickExercisePicker({
    super.key,
    this.onExerciseSelected,
  });
  final void Function(Exercise)? onExerciseSelected;

  @override
  ConsumerState<QuickExercisePicker> createState() => _QuickExercisePickerState();
}

class _QuickExercisePickerState extends ConsumerState<QuickExercisePicker> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final exercisesAsync = ref.watch(jsonExerciseRepositoryProvider);
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.selectExercise,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchExercisesHint,
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
                setState(() => _searchQuery = value);
              },
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // Exercise list
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                final config = ExercisePickerConfig.quickPick(
                  title: l10n.selectExercise,
                  onSelected: widget.onExerciseSelected,
                );

                return ExerciseListWidget(
                  exercises: exercises,
                  config: config,
                  searchQuery: _searchQuery,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Extension per mostrare facilmente il QuickExercisePicker come modal
extension QuickExercisePickerExtension on BuildContext {
  Future<Exercise?> showQuickExercisePicker({
    void Function(Exercise)? onExerciseSelected,
  }) {
    return showModalBottomSheet<Exercise>(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickExercisePicker(
        onExerciseSelected: onExerciseSelected,
      ),
    );
  }
}
