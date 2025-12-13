/// Exercise Mapping Widget
///
/// Allows users to review and adjust exercise name mappings.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/import/domain/entities/import_result.dart';
import 'package:gymbro_flutter_new/features/import/presentation/providers/import_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Widget for mapping imported exercises to database
class ExerciseMappingWidget extends ConsumerStatefulWidget {
  const ExerciseMappingWidget({super.key, required this.result});

  final ImportParseResult result;

  @override
  ConsumerState<ExerciseMappingWidget> createState() => _ExerciseMappingWidgetState();
}

class _ExerciseMappingWidgetState extends ConsumerState<ExerciseMappingWidget> {
  @override
  Widget build(BuildContext context) {
    final autoMapped = widget.result.autoMappedExercises;
    final unmapped = widget.result.unmappedExercises;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Auto-mapped summary
        if (autoMapped.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            icon: AppIcons.check,
            title: context.l10n.autoMappedExercises(autoMapped.length),
            color: context.colors.success,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.autoMappedDescription,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Unmapped exercises
        if (unmapped.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            icon: AppIcons.warning,
            title: context.l10n.needsMappingExercises(unmapped.length),
            color: context.colors.warning,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.needsMappingDescription,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...unmapped.map((u) => _buildUnmappedTile(context, u)),
        ],

        // All mapped message
        if (unmapped.isEmpty) ...[
          Card(
            color: context.colors.successContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(AppIcons.check, color: context.colors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.allExercisesMapped,
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildUnmappedTile(BuildContext context, UnmappedExercise unmapped) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.warningContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              AppIcons.help,
              color: context.colors.warning,
              size: 20,
            ),
          ),
        ),
        title: Text(unmapped.originalName),
        subtitle: Text(
          context.l10n.occurrences(unmapped.occurrences),
          style: context.textTheme.bodySmall,
        ),
        children: [
          if (unmapped.suggestions.isNotEmpty)
            ...unmapped.suggestions.map((s) => _buildSuggestionTile(context, unmapped, s))
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.l10n.noSuggestionsFound,
                style: context.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          // Search button
          ListTile(
            leading: Icon(AppIcons.search, color: context.colors.primary),
            title: Text(context.l10n.searchExercise),
            onTap: () => _showExerciseSearch(context, unmapped),
          ),
          // Skip button
          ListTile(
            leading: Icon(AppIcons.skipNext, color: context.colors.onSurfaceVariant),
            title: Text(context.l10n.skipThisExercise),
            subtitle: Text(context.l10n.willImportWithOriginalName),
            onTap: () {
              // Mark as "keep original"
              // This is handled by skipUnmapped flag in executeImport
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionTile(
    BuildContext context,
    UnmappedExercise unmapped,
    ExerciseMatch suggestion,
  ) {
    final confidencePercent = (suggestion.confidence * 100).round();
    final isHighConfidence = suggestion.confidence >= 0.7;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isHighConfidence
            ? context.colors.successContainer
            : context.colors.surfaceContainerHighest,
        child: Text(
          '$confidencePercent%',
          style: context.textTheme.labelSmall?.copyWith(
            color: isHighConfidence
                ? context.colors.success
                : context.colors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(suggestion.name),
      trailing: IconButton(
        icon: Icon(AppIcons.check, color: context.colors.primary),
        onPressed: () => _applyMapping(unmapped.originalName, suggestion.exerciseId),
      ),
      onTap: () => _applyMapping(unmapped.originalName, suggestion.exerciseId),
    );
  }

  void _applyMapping(String originalName, String exerciseId) {
    ref.read(importNotifierProvider.notifier).applyManualMapping(
          originalName,
          exerciseId,
        );
  }

  Future<void> _showExerciseSearch(BuildContext context, UnmappedExercise unmapped) async {
    final exercises = ref.read(allExercisesProvider).valueOrNull ?? [];

    final selectedId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _ExerciseSearchSheet(
          exercises: exercises,
          scrollController: scrollController,
          searchHint: unmapped.originalName,
        ),
      ),
    );

    if (selectedId != null) {
      _applyMapping(unmapped.originalName, selectedId);
    }
  }
}

/// Bottom sheet for searching exercises
class _ExerciseSearchSheet extends StatefulWidget {
  const _ExerciseSearchSheet({
    required this.exercises,
    required this.scrollController,
    this.searchHint,
  });

  final List exercises;
  final ScrollController scrollController;
  final String? searchHint;

  @override
  State<_ExerciseSearchSheet> createState() => _ExerciseSearchSheetState();
}

class _ExerciseSearchSheetState extends State<_ExerciseSearchSheet> {
  late TextEditingController _searchController;
  List _filteredExercises = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchHint);
    _filteredExercises = widget.exercises;
    _filterExercises(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterExercises(String query) {
    if (query.isEmpty) {
      setState(() => _filteredExercises = widget.exercises);
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredExercises = widget.exercises
          .where((e) => e.nome.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Search field
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: context.l10n.searchExercise,
              prefixIcon: const Icon(AppIcons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _filterExercises,
          ),
        ),

        // Results
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: _filteredExercises.length,
            itemBuilder: (context, index) {
              final exercise = _filteredExercises[index];
              return ListTile(
                title: Text(exercise.nome),
                subtitle: exercise.focus.isNotEmpty
                    ? Text(exercise.focus.join(', '))
                    : null,
                onTap: () => Navigator.of(context).pop(exercise.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
