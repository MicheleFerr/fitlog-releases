/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: workout_templates
/// 🔧 Type: widget
/// 🌍 Localization: Supported
/// 🎨 Theme: Supported
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - AppLocalizations: l10n
/// - Theme: ColorScheme
/// - ExerciseMatchingService: exercise matching
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/services/exercise_matching_service.dart';

class ExerciseSelectionDialog extends StatefulWidget {

  const ExerciseSelectionDialog({
    super.key,
    required this.originalExerciseName,
    required this.suggestedMatches,
    required this.onExerciseSelected,
    required this.onSkipExercise,
    required this.onCreateNew,
  });
  final String originalExerciseName;
  final List<ExerciseMatch> suggestedMatches;
  final Function(String exerciseId, String exerciseName) onExerciseSelected;
  final VoidCallback onSkipExercise;
  final VoidCallback onCreateNew;

  @override
  State<ExerciseSelectionDialog> createState() => _ExerciseSelectionDialogState();
}

class _ExerciseSelectionDialogState extends State<ExerciseSelectionDialog> {
  String? _selectedExerciseId;
  final TextEditingController _searchController = TextEditingController();
  List<ExerciseMatch> _filteredMatches = [];

  @override
  void initState() {
    super.initState();
    _filteredMatches = widget.suggestedMatches;
    _searchController.addListener(_filterMatches);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMatches() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredMatches = widget.suggestedMatches;
      });
    } else {
      setState(() {
        _filteredMatches = widget.suggestedMatches.where((match) {
          return match.exercise.nome.toLowerCase().contains(query) ||
                 match.exercise.focus.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.selectExercise),
          const SizedBox(height: 8),
          Text(
            '${l10n.originalExercise}: "${widget.originalExerciseName}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchExercises,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Suggested matches
            if (_filteredMatches.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.suggestedMatches,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Exercise list
            Expanded(
              child: _filteredMatches.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noExercisesFound,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredMatches.length,
                      itemBuilder: (context, index) {
                        final match = _filteredMatches[index];
                        final isSelected = _selectedExerciseId == match.exercise.id;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(match.exercise.nome),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${l10n.targetMuscles}: ${match.exercise.focus}'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${(match.similarity * 100).round()}% ${l10n.match}',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        match.matchReason,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            leading: Radio<String>(
                              value: match.exercise.id,
                              groupValue: _selectedExerciseId,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExerciseId = value;
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                _selectedExerciseId = match.exercise.id;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        // Skip exercise button
        TextButton(
          onPressed: widget.onSkipExercise,
          child: Text(
            l10n.skipExercise,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        
        // Create new exercise button
        TextButton(
          onPressed: widget.onCreateNew,
          child: Text(
            l10n.createNewExercise,
            style: TextStyle(color: colorScheme.secondary),
          ),
        ),
        
        // Use selected exercise button
        FilledButton(
          onPressed: _selectedExerciseId != null
              ? () {
                  final selectedMatch = _filteredMatches.firstWhere(
                    (match) => match.exercise.id == _selectedExerciseId,
                  );
                  widget.onExerciseSelected(
                    selectedMatch.exercise.id,
                    selectedMatch.exercise.nome,
                  );
                }
              : null,
          child: Text(l10n.useSelectedExercise),
        ),
      ],
    );
  }
}